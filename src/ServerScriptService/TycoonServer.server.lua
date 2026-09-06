-- ตรรกะหลักของ Tycoon: รายได้, ซื้อเมนู, Game Pass, Dev Product
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)

local function ownsPass(player, key)
	local id = Config.GamePasses[key].id
	if id == 0 then return false end
	local ok, res = pcall(MPS.UserOwnsGamePassAsync, MPS, player.UserId, id)
	return ok and res
end

local function push(player)
	local d = Data.get(player)
	if d then Remotes.DataUpdate:FireClient(player, d) end
end

local function incomePerTick(player)
	local d = Data.get(player)
	local total = 0
	for _, f in ipairs(Config.Foods) do
		if d.foods[f.id] then total += f.income end
	end
	if ownsPass(player, "DoubleIncome") then total *= 2 end
	if ownsPass(player, "SecondStall") then total *= 1.5 end
	return math.floor(total)
end

local function onPlayer(player)
	Data.load(player)
	push(player)
	task.spawn(function()
		while player.Parent do
			task.wait(Config.PayoutInterval)
			local d = Data.get(player)
			if not d then break end
			local earned = incomePerTick(player)
			if ownsPass(player, "AutoWorker") then
				d.cash += earned -- เข้ากระเป๋าโดยตรง
			else
				d.pending += earned -- ต้องมากดเก็บเอง
			end
			push(player)
		end
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end

Remotes.GetData.OnServerInvoke = function(player)
	return Data.get(player) or Data.load(player)
end

Remotes.Collect.OnServerInvoke = function(player)
	local d = Data.get(player)
	d.cash += d.pending
	d.pending = 0
	push(player)
	return d.cash
end

Remotes.BuyFood.OnServerInvoke = function(player, foodId)
	local d = Data.get(player)
	for _, f in ipairs(Config.Foods) do
		if f.id == foodId then
			if d.foods[foodId] then return false, "มีแล้ว" end
			if d.cash < f.cost then return false, "เงินไม่พอ" end
			d.cash -= f.cost
			d.foods[foodId] = true
			push(player)
			return true
		end
	end
	return false, "ไม่พบเมนู"
end

-- ขอเปิดหน้าต่างซื้อ
Remotes.PromptPass.OnServerEvent:Connect(function(player, kind, key)
	if kind == "pass" and Config.GamePasses[key] then
		MPS:PromptGamePassPurchase(player, Config.GamePasses[key].id)
	elseif kind == "product" and Config.DevProducts[key] then
		MPS:PromptProductPurchase(player, Config.DevProducts[key].id)
	end
end)

-- รับเงินจาก Dev Product
MPS.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	for _, p in pairs(Config.DevProducts) do
		if p.id == receipt.ProductId then
			local d = Data.get(player)
			d.cash += p.cash
			Data.save(player)
			push(player)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MPS.PromptGamePassPurchaseFinished:Connect(function(player, _, bought)
	if bought then push(player) end
end)
