-- ตรรกะหลัก: ลูกค้า ทำอาหาร เสิร์ฟ เงิน ชื่อเสียง ร้านค้า Game Pass Dev Product
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local _Locale = require(RS.Locale)
local Dish = require(RS.Dish)
local Remotes = require(RS.Remotes)
local Data = require(script.Parent.DataService)
local Plot = require(script.Parent.PlotService)
local Customers = require(script.Parent.CustomerService)
local LB = require(script.Parent.LeaderboardService)

local passCache, cooking = {}, {}
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
local function mult(player)
	local m = 1
	for _, gp in ipairs(Config.GamePasses) do if gp.mult and ownsPass(player, gp.key) then m *= gp.mult end end
	return m
end
local function push(player)
	local d = Data.get(player)
	if d then LB.update(player, d, d.served); Remotes.DataUpdate:FireClient(player, d, player:GetAttribute("Holding")) end
end
local function notify(player, key, color, ...)
	Remotes.Notify:FireClient(player, key, color, ...)
end
local function foodOf(id) for _, f in ipairs(Config.Foods) do if f.id == id then return f end end end

-- ถือจาน
local function setHolding(player, foodId)
	local char = player.Character
	if char then
		local old = char:FindFirstChild("HeldDish"); if old then old:Destroy() end
		if foodId then
			local d = Dish.build(foodId); d.Name = "HeldDish"
			local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
			if hand then
				d:PivotTo(hand.CFrame * CFrame.new(0, -0.6, -1.2))
				local w = Instance.new("Weld"); w.Part0 = hand; w.Part1 = d.PrimaryPart; w.C0 = CFrame.new(0, -0.6, -1.2); w.Parent = d.PrimaryPart
			end
			d.Parent = char
		end
	end
	player:SetAttribute("Holding", foodId)
	push(player)
end

-- ทำอาหาร: เริ่มมินิเกมที่ client แล้วรอผล
Plot.onCook = function(player, foodId)
	if cooking[player] then return end
	local f = foodOf(foodId); if not f then return end
	cooking[player] = { food = f, t0 = os.clock() }
	Remotes.StartMinigame:FireClient(player, f.game, f.cookTime, foodId)
end
Remotes.MinigameResult.OnServerEvent:Connect(function(player, score)
	local c = cooking[player]; if not c then return end
	cooking[player] = nil
	score = math.clamp(tonumber(score) or 0, 0, 1)
	if os.clock() - c.t0 < c.food.cookTime * 0.5 then score = 0 end -- กันโกง ทำเร็วเกินไป
	if score <= 0 then notify(player, "burnt", "red"); return end
	player:SetAttribute("Quality", score)
	setHolding(player, c.food.id)
	notify(player, score > 0.85 and "perfect" or (score > 0.5 and "good" or "ok"), "green")
end)

-- เสิร์ฟ
Customers.onServed = function(entry)
	local player = entry.player
	local holding = player:GetAttribute("Holding")
	if not holding then notify(player, "noDish", "red"); return end
	if holding ~= entry.food.id then notify(player, "wrongDish", "red"); return end
	local d = Data.get(player); if not d then return end
	local quality = player:GetAttribute("Quality") or 0.5
	local patience = Customers.patienceLeft(entry)
	local base = entry.food.price
	local tip = math.floor(base * Config.TipMax * (quality * 0.6 + patience * 0.4))
	local earned = math.floor((base + tip) * mult(player))
	d.cash += earned; d.total += earned; d.served += 1
	d.rep = math.min(d.rep + (quality > 0.85 and 2 or 1), 1000)
	setHolding(player, nil)
	Customers.leave(entry, quality > 0.85 and "😍" or "😊")
	notify(player, "tip", "green", earned, tip)
	push(player)
end
Customers.onLeft = function(entry)
	local d = Data.get(entry.player)
	if d then d.rep = math.max(d.rep - 2, 0); notify(entry.player, "left", "red"); push(entry.player) end
end

local function onPlayer(player)
	local d = Data.load(player)
	LB.setup(player, d)
	Plot.assign(player)
	Plot.refresh(player, d.foods)
	push(player)
	player.CharacterAdded:Connect(function() task.wait(0.5); if player:GetAttribute("Holding") then setHolding(player, player:GetAttribute("Holding")) end end)
	-- ลูกค้าเดินเข้ามาเรื่อย ๆ ชื่อเสียงสูงมาถี่ขึ้น
	task.spawn(function()
		task.wait(4)
		while player.Parent do
			local dd = Data.get(player); if not dd then break end
			Customers.spawn(player, dd.foods)
			local repBonus = math.min(dd.rep / 1000, 0.5)
			task.wait(math.random(Config.CustomerInterval.min, Config.CustomerInterval.max) * (1 - repBonus))
		end
	end)
	-- พ่อครัวอัตโนมัติ (Game Pass): เสิร์ฟให้เองช้า ๆ
	task.spawn(function()
		while player.Parent do
			task.wait(10)
			if ownsPass(player, "AutoChef") then
				local q = Customers.queue(player)
				local e = q[1]
				if e and e.alive and e.orderAt then
					local dd = Data.get(player)
					if dd then dd.cash += e.food.price; dd.total += e.food.price; dd.served += 1; Customers.leave(e, "🤖"); push(player) end
				end
			end
		end
	end)
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
Players.PlayerRemoving:Connect(function(p)
	local d = Data.get(p); if d then LB.submit(p, d) end
	Customers.clear(p); Plot.release(p); passCache[p] = nil; cooking[p] = nil
end)
task.spawn(function() while true do task.wait(120); for _, p in ipairs(Players:GetPlayers()) do local d = Data.get(p); if d then LB.submit(p, d) end end end end)

Remotes.GetData.OnServerInvoke = function(player)
	return Data.get(player) or Data.load(player), player:GetAttribute("Holding")
end
Remotes.BuyFood.OnServerInvoke = function(player, foodId)
	local d = Data.get(player); if not d then return false end
	local f = foodOf(foodId); if not f then return false end
	if d.foods[foodId] then return false, "owned" end
	if d.cash < f.cost then return false, "notEnough" end
	d.cash -= f.cost; d.foods[foodId] = true
	Plot.refresh(player, d.foods)
	push(player)
	return true
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
MPS.PromptGamePassPurchaseFinished:Connect(function(player, _, bought) if bought then passCache[player] = nil; push(player) end end)

-- ล็อกอินรายวัน
local DAY = 86400
local function dailyInfo(d)
	local since = os.time() - (d.lastClaim or 0)
	local streak = (since < DAY * 2) and (d.streak or 0) or 0
	local nextDay = math.min(streak + 1, #Config.DailyRewards)
	return since >= DAY, nextDay, Config.DailyRewards[nextDay]
end
Remotes.ClaimDaily.OnServerInvoke = function(player, justAsk)
	local d = Data.get(player); if not d then return false end
	local can, day, reward = dailyInfo(d)
	if justAsk or not can then return can, day, reward end
	d.cash += reward; d.total += reward; d.streak = day; d.lastClaim = os.time()
	Data.save(player); push(player)
	return true, day, reward
end
