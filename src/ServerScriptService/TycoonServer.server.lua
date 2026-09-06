-- ตรรกะหลัก: รายได้, ซื้อเมนู, Game Pass, Dev Product, แปลงร้าน
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Remotes = require(RS.Remotes)
local Data = require(script.Parent.DataService)
local Plot = require(script.Parent.PlotService)

local passCache = {}
local function ownsPass(player, key)
	local id
	for _, gp in ipairs(Config.GamePasses) do if gp.key == key then id = gp.id end end
	if not id or id == 0 then return false end
	passCache[player] = passCache[player] or {}
	if passCache[player][key] == nil then
		local ok, res = pcall(MPS.UserOwnsGamePassAsync, MPS, player.UserId, id)
		passCache[player][key] = ok and res or false
	end
	return passCache[player][key]
end

local function incomePerSec(player)
	local d = Data.get(player); if not d then return 0 end
	local total = 0
	for _, f in ipairs(Config.Foods) do if d.foods[f.id] then total += f.income end end
	for _, gp in ipairs(Config.GamePasses) do if gp.mult and ownsPass(player, gp.key) then total *= gp.mult end end
	return math.floor(total)
end

local function push(player)
	local d = Data.get(player)
	if d then Remotes.DataUpdate:FireClient(player, d, incomePerSec(player)) end
end

local function collect(player)
	local d = Data.get(player); if not d or d.pending <= 0 then return end
	d.cash += d.pending; d.total += d.pending; d.pending = 0
	push(player)
end

local function onPlayer(player)
	local d = Data.load(player)
	local _, pad = Plot.assign(player)
	Plot.refresh(player, d.foods)
	push(player)
	-- เหยียบแผ่นเหลืองเพื่อเก็บเงิน
	local last = 0
	pad.Touched:Connect(function(hit)
		local p = Players:GetPlayerFromCharacter(hit.Parent)
		if p == player and os.clock() - last > 0.5 then last = os.clock(); collect(player) end
	end)
	task.spawn(function()
		while player.Parent do
			task.wait(Config.PayoutInterval)
			local dd = Data.get(player); if not dd then break end
			local earned = incomePerSec(player) * Config.PayoutInterval
			if ownsPass(player, "AutoCollect") then dd.cash += earned; dd.total += earned else dd.pending += earned end
			push(player)
		end
	end)
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
Players.PlayerRemoving:Connect(function(p) Plot.release(p); passCache[p] = nil end)

Remotes.GetData.OnServerInvoke = function(player)
	local d = Data.get(player) or Data.load(player)
	return d, incomePerSec(player)
end
Remotes.Collect.OnServerInvoke = function(player) collect(player); return true end
Remotes.BuyFood.OnServerInvoke = function(player, foodId)
	local d = Data.get(player); if not d then return false end
	for _, f in ipairs(Config.Foods) do
		if f.id == foodId then
			if d.foods[foodId] then return false, "owned" end
			if d.cash < f.cost then return false, "notEnough" end
			d.cash -= f.cost; d.foods[foodId] = true
			Plot.refresh(player, d.foods)
			push(player)
			return true
		end
	end
	return false
end
Remotes.PromptPass.OnServerEvent:Connect(function(player, kind, key)
	local list = kind == "pass" and Config.GamePasses or Config.DevProducts
	for _, item in ipairs(list) do
		if item.key == key and item.id ~= 0 then
			if kind == "pass" then MPS:PromptGamePassPurchase(player, item.id) else MPS:PromptProductPurchase(player, item.id) end
		end
	end
end)
MPS.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	for _, p in ipairs(Config.DevProducts) do
		if p.id == receipt.ProductId then
			local d = Data.get(player); if not d then return Enum.ProductPurchaseDecision.NotProcessedYet end
			d.cash += p.cash; Data.save(player); push(player)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
MPS.PromptGamePassPurchaseFinished:Connect(function(player, _, bought)
	if bought then passCache[player] = nil; push(player) end
end)
