-- ตรรกะหลักของเกม (โมดูล) ให้ TycoonServer และเทสต์เรียก G.init() เหมือนกัน
local G = {}
function G.init()
if G.started then return end; G.started = true
	-- ลูกค้า ทำอาหาร เสิร์ฟ เงิน ชื่อเสียง ร้านค้า Game Pass Dev Product
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
	local function isReal(p) return typeof(p) == "Instance" end -- เทสต์ใช้ผู้เล่นจำลอง
	local function push(player)
		local d = Data.get(player)
		if d and isReal(player) then LB.update(player, d, d.served); Remotes.DataUpdate:FireClient(player, d, player:GetAttribute("Holding"), player:GetAttribute("HoldCount"), player:GetAttribute("Bagged")) end
	end
	local function notify(player, key, color, ...)
		if not isReal(player) then print("notify:", key, ...); return end
		Remotes.Notify:FireClient(player, key, color, ...)
	end
	local function foodOf(id) for _, f in ipairs(Config.Foods) do if f.id == id then return f end end end
	
	-- ถือจาน
	local function setHolding(player, foodId, count, bagged)
		local char = player.Character
		if char then
			local old = char:FindFirstChild("HeldDish"); if old then old:Destroy() end
			if foodId then
				local d
				if foodId == "Dirty" then
					d = Instance.new("Model"); d.Name = "HeldDish"
					for k = 1, 3 do
						local pl = Instance.new("Part"); pl.Shape = Enum.PartType.Cylinder; pl.Size = Vector3.new(0.12, 1.3, 1.3); pl.Color = Color3.fromRGB(225, 215, 195)
						pl.CanCollide = false; pl.Massless = true; pl.CFrame = CFrame.new(0, k * 0.15, 0) * CFrame.Angles(0, 0, math.rad(90)); pl.Parent = d
						if k == 1 then d.PrimaryPart = pl else local w = Instance.new("Weld"); w.Part0 = d.PrimaryPart; w.Part1 = pl; w.C0 = CFrame.new(0, (k - 1) * 0.15, 0); w.Parent = pl end
					end
				elseif bagged then
					d = Instance.new("Model"); d.Name = "HeldDish"
					local bag = Instance.new("Part"); bag.Size = Vector3.new(1.4, 1.6, 1); bag.Color = Color3.fromRGB(240, 240, 235); bag.Material = Enum.Material.Plastic
					bag.CanCollide = false; bag.Massless = true; bag.Parent = d; d.PrimaryPart = bag
				else
					d = Dish.build(foodId); d.Name = "HeldDish"
				end
				local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
				if hand then
					d:PivotTo(hand.CFrame * CFrame.new(0, -0.6, -1.2))
					local w = Instance.new("Weld"); w.Part0 = hand; w.Part1 = d.PrimaryPart; w.C0 = CFrame.new(0, -0.6, -1.2); w.Parent = d.PrimaryPart
				end
				d.Parent = char
			end
		end
		player:SetAttribute("Holding", foodId); player:SetAttribute("HoldCount", foodId and (count or 1) or nil); player:SetAttribute("Bagged", bagged or nil)
		push(player)
	end
	Plot.onPack = function(player)
		local id = player:GetAttribute("Holding")
		if not id or id == "Dirty" then notify(player, id and "handsFull" or "noDish", "red"); return end
		setHolding(player, id, player:GetAttribute("HoldCount") or 1, true)
	end
	Plot.onClean = function(player, t)
		if player:GetAttribute("Holding") then notify(player, player:GetAttribute("Holding") == "Dirty" and "handsFull" or "holding", "red"); return end
		t.setDirty(false)
		setHolding(player, "Dirty", 1, false)
	end
	Plot.onWash = function(player)
		if player:GetAttribute("Holding") ~= "Dirty" then return end
		setHolding(player, nil)
		local d = Data.get(player); if d then d.rep = math.min(d.rep + 1, 1000); push(player) end
	end
	
	-- ทำอาหาร: เริ่มมินิเกมที่ client แล้วรอผล
	Plot.onCook = function(player, foodId)
		if cooking[player] then return end
		if player:GetAttribute("Holding") == "Dirty" then notify(player, "handsFull", "red"); return end
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
		setHolding(player, c.food.id, c.food.batch or 1, false)
		notify(player, score > 0.85 and "perfect" or (score > 0.5 and "good" or "ok"), "green")
	end)
	
	-- เสิร์ฟ
	local function serveEntry(player, entry, quality)
		local d = Data.get(player); if not d then return end
		local patience = Customers.patienceLeft(entry)
		local base = entry.food.price
		local tip = math.floor(base * Config.TipMax * (quality * 0.6 + patience * 0.4))
		local earned = math.floor((base + tip) * mult(player))
		d.cash += earned; d.total += earned; d.served += 1
		d.rep = math.min(d.rep + (quality > 0.85 and 2 or 1), 1000)
		Customers.markServed(entry)
		notify(player, "tip", "green", earned, tip)
		push(player)
	end
	Customers.onServed = function(entry)
		local player = entry.group.player
		local holding = player:GetAttribute("Holding")
		if not holding or holding == "Dirty" then notify(player, holding and "handsFull" or "noDish", "red"); return end
		if holding ~= entry.food.id then notify(player, "wrongDish", "red"); return end
		if entry.group.kind == "takeaway" and not player:GetAttribute("Bagged") then notify(player, "needBag", "red"); return end
		local left = (player:GetAttribute("HoldCount") or 1) - 1
		if left > 0 then setHolding(player, holding, left, player:GetAttribute("Bagged")) else setHolding(player, nil) end
		serveEntry(player, entry, player:GetAttribute("Quality") or 0.5)
	end
	-- หยิบจานจากเคาน์เตอร์ที่พ่อครัวทำไว้
	Plot.onPickup = function(player, dish)
		if player:GetAttribute("Holding") then notify(player, "handsFull", "red"); return end
		local id = dish:GetAttribute("FoodId"); dish:Destroy()
		player:SetAttribute("Quality", 0.6)
		setHolding(player, id, 1, false)
	end

	-- พนักงาน
	local staffNpcs = {}
	local function staffCfg(key) for _, st in ipairs(Config.Staff) do if st.key == key then return st end end end
	local function showStaff(player, key)
		local d = Data.get(player); if not d then return end
		staffNpcs[player] = staffNpcs[player] or {}
		local existing = staffNpcs[player][key]
		if d.staff[key] and not existing and isReal(player) then
			local pts = Plot.points(player:GetAttribute("PlotIndex"))
			local desc = Instance.new("HumanoidDescription"); desc.TorsoColor = Color3.fromRGB(250, 250, 250); desc.HeadColor = Color3.fromRGB(240, 200, 170)
			local ok, npc = pcall(Players.CreateHumanoidModelFromDescription, Players, desc, Enum.HumanoidRigType.R15)
			if ok then
				npc.Name = staffCfg(key).emoji .. " " .. key; npc:PivotTo(CFrame.new(pts.staff[key], pts.staff[key] + Vector3.new(0, 0, 10)))
				npc.Parent = workspace.Plots:FindFirstChild("Plot_" .. player.UserId)
				local h = npc:FindFirstChildOfClass("Humanoid"); if h then h.DisplayName = npc.Name end
				staffNpcs[player][key] = npc
			end
		elseif not d.staff[key] and existing then existing:Destroy(); staffNpcs[player][key] = nil end
	end
	local function staffTick(player)
		local d = Data.get(player); if not d then return end
		local t = os.clock()
		d._staffNext = d._staffNext or {}
		for _, st in ipairs(Config.Staff) do
			if d.staff[st.key] and (d._staffNext[st.key] or 0) <= t then
				d._staffNext[st.key] = t + st.interval
				if st.key == "Cook" then
					for _, g in ipairs(Customers.groups[player] or {}) do
						if g.alive and g.orderAt then
							for _, e in ipairs(g.members) do
								if not e.served and not e.cooking then e.cooking = true; Plot.putOnCounter(player, e.food.id); break end
							end
						end
					end
				elseif st.key == "Waiter" then
					for _, g in ipairs(Customers.groups[player] or {}) do
						if g.alive and g.orderAt then
							for _, e in ipairs(g.members) do
								if not e.served and Plot.takeFromCounter(player, e.food.id) then serveEntry(player, e, 0.6); return end
							end
						end
					end
				elseif st.key == "Washer" then
					for _, tb in ipairs(Plot.tables[player] or {}) do if tb.dirty then tb.setDirty(false); break end end
				end
			end
		end
	end
	local function payWages(player)
		local d = Data.get(player); if not d then return end
		for _, st in ipairs(Config.Staff) do
			if d.staff[st.key] then
				if d.cash >= st.wage then d.cash -= st.wage else d.staff[st.key] = nil; notify(player, "staffQuit", "red", st.key); showStaff(player, st.key) end
			end
		end
		push(player)
	end
	Remotes.HireStaff.OnServerInvoke = function(player, key)
		local d = Data.get(player); local st = staffCfg(key)
		if not d or not st then return false end
		if d.staff[key] then return false, "owned" end
		if d.cash < st.cost then return false, "notEnough" end
		d.cash -= st.cost; d.staff[key] = true
		showStaff(player, key); push(player)
		return true
	end
	G.staffTick, G.payWages = staffTick, payWages
	Customers.onLeft = function(g)
		local d = Data.get(g.player)
		if d then d.rep = math.max(d.rep - 2 * #g.members, 0); notify(g.player, "left", "red"); push(g.player) end
	end
	
	local function onPlayer(player)
		local d = Data.load(player)
		LB.setup(player, d)
		Plot.assign(player)
		Plot.refresh(player, d.foods)
		push(player)
		player.CharacterAdded:Connect(function() task.wait(0.5); if player:GetAttribute("Holding") then setHolding(player, player:GetAttribute("Holding"), player:GetAttribute("HoldCount"), player:GetAttribute("Bagged")) end end)
		for _, st in ipairs(Config.Staff) do showStaff(player, st.key) end
		task.spawn(function()
			local lastWage = os.clock()
			while player.Parent do
				task.wait(1); staffTick(player)
				if os.clock() - lastWage >= Config.WagePeriod then lastWage = os.clock(); payWages(player) end
			end
		end)
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
					for _, g in ipairs(Customers.groups[player] or {}) do
						if g.alive and g.orderAt then
							for _, e in ipairs(g.members) do
								if not e.served then
									local dd = Data.get(player)
									if dd then dd.cash += e.food.price; dd.total += e.food.price; dd.served += 1; Customers.markServed(e); push(player) end
									break
								end
							end
							break
						end
					end
				end
			end
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
	Players.PlayerRemoving:Connect(function(p)
		local d = Data.get(p); if d then LB.submit(p, d) end
		Customers.clear(p); Plot.release(p); passCache[p] = nil; cooking[p] = nil; staffNpcs[p] = nil
	end)
	task.spawn(function() while true do task.wait(120); for _, p in ipairs(Players:GetPlayers()) do local d = Data.get(p); if d then LB.submit(p, d) end end end end)
	
	Remotes.GetData.OnServerInvoke = function(player)
		return Data.get(player) or Data.load(player), player:GetAttribute("Holding"), player:GetAttribute("HoldCount"), player:GetAttribute("Bagged")
	end
	Remotes.BuyFood.OnServerInvoke = function(player, foodId)
		local d = Data.get(player); if not d then return false end
		local f = foodOf(foodId); if not f then return false end
		if d.foods[foodId] then return false, "owned" end
		if d.cash < f.cost then return false, "notEnough" end
		d.cash -= f.cost; d.foods[foodId] = true
		Plot.refresh(player, d.foods); Plot.menuBoard(player, d.foods)
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
end
return G
