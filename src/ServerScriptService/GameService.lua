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
	local function upgOf(player, _foodId, kind)
		local d = Data.get(player); local u = d and d.upg.kitchen
		return (u and u[kind]) or 1
	end
	local function upgradeStation(player, _foodId, kind)
		local d = Data.get(player)
		if not d or (kind ~= "speed" and kind ~= "tray") then return false end
		local lv = upgOf(player, "kitchen", kind)
		if lv >= Config.UpgradeMax then return false, "maxed" end
		local cost = Config.kitchenUpgradeCost(kind, lv)
		if d.cash < cost then return false, "notEnough" end
		d.cash -= cost; d.upg.kitchen = d.upg.kitchen or {}; d.upg.kitchen[kind] = lv + 1
		push(player); return true
	end
	Remotes.UpgradeStation.OnServerInvoke = upgradeStation
	G.upgradeStation = upgradeStation
	
	-- ถาด: ถือได้หลายจาน (Tray = รายการ {f=เมนู, q=คุณภาพ, s=ความเผ็ด, b=ใส่ถุง}) หรือจานสกปรก
	local HttpService = game:GetService("HttpService")
	local trays = {}
	local function tray(player) trays[player] = trays[player] or {}; return trays[player] end
	local function renderHeld(player)
		local char = player.Character; if not char then return end
		local old = char:FindFirstChild("HeldDish"); if old then old:Destroy() end
		local t = tray(player)
		local dirty = player:GetAttribute("Holding") == "Dirty"
		if #t == 0 and not dirty then return end
		local d = Instance.new("Model"); d.Name = "HeldDish"
		local base = Instance.new("Part"); base.Size = Vector3.new(2.6, 0.12, 1.6); base.Color = Color3.fromRGB(120, 80, 50); base.Material = Enum.Material.Wood
		base.CanCollide = false; base.Massless = true; base.Parent = d; d.PrimaryPart = base
		local function weld(m, off)
			local w = Instance.new("Weld"); w.Part0 = base; w.Part1 = m.PrimaryPart; w.C0 = off; w.Parent = m.PrimaryPart
			for _, x in ipairs(m:GetDescendants()) do if x:IsA("BasePart") then x.CanCollide = false; x.Massless = true end end
			m.Parent = d
		end
		if dirty then
			for k = 1, 3 do
				local pl = Instance.new("Part"); pl.Shape = Enum.PartType.Cylinder; pl.Size = Vector3.new(0.12, 1.3, 1.3); pl.Color = Color3.fromRGB(225, 215, 195)
				pl.CanCollide = false; pl.Massless = true; pl.Parent = d
				local w = Instance.new("Weld"); w.Part0 = base; w.Part1 = pl; w.C0 = CFrame.new(0, 0.1 + k * 0.15, 0) * CFrame.Angles(0, 0, math.rad(90)); w.Parent = pl
			end
		else
			for i, item in ipairs(t) do
				if i > 4 then break end
				local m
				if item.b then
					m = Instance.new("Model"); local bag = Instance.new("Part"); bag.Size = Vector3.new(0.9, 1.1, 0.7); bag.Color = Color3.fromRGB(240, 240, 235); bag.Parent = m; m.PrimaryPart = bag
				else
					m = Dish.build(item.f); m:ScaleTo(0.55)
				end
				weld(m, CFrame.new(-0.9 + ((i - 1) % 2) * 1.2, 0.35, -0.4 + math.floor((i - 1) / 2) * 0.8))
			end
		end
		local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
		if hand then
			local w = Instance.new("Weld"); w.Part0 = hand; w.Part1 = base; w.C0 = CFrame.new(0.2, -0.8, -1.3); w.Parent = base
		end
		d.Parent = char
	end
	local function syncTray(player)
		local t = tray(player)
		player:SetAttribute("Tray", HttpService:JSONEncode(t))
		if player:GetAttribute("Holding") ~= "Dirty" then
			player:SetAttribute("Holding", t[1] and t[1].f or nil); player:SetAttribute("HoldCount", #t > 0 and #t or nil)
			local allBag = #t > 0; for _, it in ipairs(t) do if not it.b then allBag = false end end
			player:SetAttribute("Bagged", allBag or nil)
		end
		if isReal(player) then renderHeld(player) end
		push(player)
	end
	local function addToTray(player, foodId, quality, spice, count)
		local t = tray(player)
		if player:GetAttribute("Holding") == "Dirty" then notify(player, "handsFull", "red"); return false end
		local space = Config.TrayCapacity - #t
		if space <= 0 then notify(player, "trayFull", "red"); return false end
		for _ = 1, math.min(count or 1, space) do table.insert(t, { f = foodId, q = quality or 0.5, s = spice, b = false }) end
		syncTray(player); return true
	end
	local function takeFromTray(player, foodId, needBag)
		local t = tray(player)
		for i, it in ipairs(t) do
			if it.f == foodId and (not needBag or it.b) then table.remove(t, i); syncTray(player); return it end
		end
	end
	local function setDirty(player, on)
		player:SetAttribute("Holding", on and "Dirty" or nil); player:SetAttribute("HoldCount", nil)
		syncTray(player)
	end
	-- ภารกิจรายวันและเลเวลร้าน
	local function today() return os.date("!%Y-%m-%d") end
	local function ensureQuests(d)
		if d.quests and d.quests.date == today() then return end
		local pool = table.clone(Config.QuestPool); local list = {}
		for _ = 1, 3 do local i = math.random(#pool); local q = pool[i]; table.remove(pool, i); list[#list + 1] = { type = q.type, target = q.target, reward = q.reward, progress = 0, claimed = false } end
		d.quests = { date = today(), list = list }
	end
	local function progress(player, qtype, amount)
		local d = Data.get(player); if not d then return end
		ensureQuests(d)
		for _, q in ipairs(d.quests.list) do
			if q.type == qtype and not q.claimed and q.progress < q.target then
				q.progress = math.min(q.progress + (amount or 1), q.target)
				if q.progress >= q.target then notify(player, "questReady", "green") end
			end
		end
	end
	local function checkLevel(player)
		local d = Data.get(player); if not d then return end
		local lv = 1
		for i, L in ipairs(Config.Levels) do if d.total >= L.need then lv = i end end
		if lv ~= d.level then d.level = lv; notify(player, "levelUp", "green", Config.Levels[lv].key) end
		Plot.setLevel(player, lv)
	end
	Remotes.ClaimQuest.OnServerInvoke = function(player, idx)
		local d = Data.get(player); if not d or not d.quests then return false end
		local q = d.quests.list[idx]
		if not q or q.claimed or q.progress < q.target then return false end
		q.claimed = true; d.cash += q.reward; push(player)
		notify(player, "questDone", "green", q.reward)
		return true
	end
	G.progress, G.checkLevel, G.ensureQuests = progress, checkLevel, ensureQuests

	G.tray, G.addToTray = tray, addToTray
	-- ใช้ชื่อเดิมให้โค้ดส่วนอื่น (ผู้เล่นเกิดใหม่)
	local function setHolding(player) syncTray(player) end
	Plot.onPack = function(player)
		local t = tray(player)
		if player:GetAttribute("Holding") == "Dirty" or #t == 0 then notify(player, #t == 0 and "noDish" or "handsFull", "red"); return end
		for _, it in ipairs(t) do it.b = true end
		syncTray(player)
	end
	Plot.onClean = function(player, t)
		if player:GetAttribute("Holding") then notify(player, player:GetAttribute("Holding") == "Dirty" and "handsFull" or "holding", "red"); return end
		t.setDirty(false)
		setDirty(player, true); progress(player, "clean", 1)
	end
	Plot.onWash = function(player)
		if player:GetAttribute("Holding") ~= "Dirty" then return end
		setDirty(player, false)
		local d = Data.get(player); if d then d.rep = math.min(d.rep + 1, 1000); push(player) end
	end
	
	-- ทำอาหาร: กด E ที่ครัว → เลือกเมนู → มินิเกม
	Plot.onKitchen = function(player)
		if player:GetAttribute("Holding") == "Dirty" then notify(player, "handsFull", "red"); return end
		if #tray(player) >= Config.TrayCapacity then notify(player, "trayFull", "red"); return end
		if player:GetAttribute("Event") == "GasOut" and not player:GetAttribute("EventFixed") then notify(player, "noGas", "red"); return end
		Remotes.OpenCook:FireClient(player)
	end
	Remotes.PickCook.OnServerEvent:Connect(function(player, foodId)
		local d = Data.get(player)
		if d and d.foods[foodId] and Plot.onCook then Plot.onCook(player, foodId) end
	end)
	Plot.onCook = function(player, foodId)
		if cooking[player] and os.clock() - cooking[player].t0 < (cooking[player].time or 10) * 3 then return end
		if player:GetAttribute("Holding") == "Dirty" then notify(player, "handsFull", "red"); return end
		if #tray(player) >= Config.TrayCapacity then notify(player, "trayFull", "red"); return end
		if player:GetAttribute("Event") == "GasOut" and not player:GetAttribute("EventFixed") then notify(player, "noGas", "red"); return end
		local f = foodOf(foodId); if not f then return end
		local speed = 1 - 0.15 * (upgOf(player, foodId, "speed") - 1)
		local steps = f.steps or { f.game }
		cooking[player] = { food = f, t0 = os.clock(), time = f.cookTime * speed * #steps }
		Remotes.StartMinigame:FireClient(player, steps, f.cookTime * speed, foodId, f.spicy)
	end
	Remotes.MinigameResult.OnServerEvent:Connect(function(player, score, spice)
		local c = cooking[player]; if not c then return end
		cooking[player] = nil
		score = math.clamp(tonumber(score) or 0, 0, 1)
		if os.clock() - c.t0 < c.time * 0.5 then score = 0 end
		player:SetAttribute("Spice", c.food.spicy and math.clamp(tonumber(spice) or 1, 1, #Config.SpiceLevels) or nil) -- กันโกง ทำเร็วเกินไป
		if score <= 0 then notify(player, "burnt", "red"); return end
		addToTray(player, c.food.id, score, player:GetAttribute("Spice"), upgOf(player, c.food.id, "tray"))
		notify(player, score > 0.85 and "perfect" or (score > 0.5 and "good" or "ok"), "green")
	end)
	
	-- เสิร์ฟ
	local function serveEntry(player, entry, quality)
		local d = Data.get(player); if not d then return end
		local patience = Customers.patienceLeft(entry)
		local base = entry.food.price
		local tip = math.floor(base * Config.TipMax * (quality * 0.6 + patience * 0.4))
		local sp = entry.special and Config.Specials[entry.special]
		if sp and sp.tipMult then tip *= sp.tipMult end
		if sp and sp.payMult then base *= sp.payMult; notify(player, "vipPaid", "green") end
		if sp and sp.repGood then
			local good = quality > 0.85
			d.rep = math.clamp(d.rep + (good and sp.repGood or sp.repBad), 0, 1000)
			notify(player, good and "criticGood" or "criticBad", good and "green" or "red")
		end
		if player:GetAttribute("Event") == "Rush" then base = math.floor(base * 1.5) end
		local earned = math.floor((base + tip) * mult(player))
		d.cash += earned; d.total += earned; d.served += 1
		d.rep = math.min(d.rep + (quality > 0.85 and 2 or 1), 1000)
		Customers.markServed(entry)
		notify(player, "tip", "green", earned, tip)
		progress(player, "serve", 1); progress(player, "earn", earned)
		if quality > 0.85 then progress(player, "perfect", 1) end
		progress(player, entry.group.kind == "takeaway" and "takeaway" or "dine", 1)
		checkLevel(player)
		push(player)
	end
	Customers.pickEntry = function(player, pending)
		for _, e in ipairs(pending) do
			for _, it in ipairs(tray(player)) do if it.f == e.food.id then return e end end
		end
	end
	Customers.onServed = function(entry)
		local player = entry.group.player
		if player:GetAttribute("Holding") == "Dirty" then notify(player, "handsFull", "red"); return false end
		if #tray(player) == 0 then notify(player, "noDish", "red"); return false end
		local needBag = entry.group.kind == "takeaway"
		local item = takeFromTray(player, entry.food.id, needBag)
		if not item then
			local anyMatch = false
			for _, it in ipairs(tray(player)) do if it.f == entry.food.id then anyMatch = true end end
			notify(player, anyMatch and "needBag" or "wrongDish", "red"); return false
		end
		local quality = item.q or 0.5
		if entry.spice and item.s ~= entry.spice then quality = 0; notify(player, "wrongSpice", "red") end
		serveEntry(player, entry, quality)
		return true
	end
	-- หยิบจานจากเคาน์เตอร์ที่พ่อครัวทำไว้
	Plot.onPickup = function(player, dish)
		local id = dish:GetAttribute("FoodId")
		if addToTray(player, id, 0.6, nil, 1) then dish:Destroy() end
	end

	-- เหตุการณ์
	local function startEvent(player, name)
		player:SetAttribute("Event", name); player:SetAttribute("EventFixed", nil); player:SetAttribute("EventEnd", os.time() + Config.EventDuration)
		notify(player, name, "red")
		if name == "Rain" then Customers.patienceMult[player] = 0.5 end
		if name == "Rush" then player:SetAttribute("SpawnMult", 0.3) end
	end
	local function fixEvent(player)
		local ev = player:GetAttribute("Event")
		if not ev or player:GetAttribute("EventFixed") then return false end
		player:SetAttribute("EventFixed", true)
		if ev == "Rain" then Customers.patienceMult[player] = nil end
		return true
	end
	local function endEvent(player)
		if not player:GetAttribute("Event") then return end
		player:SetAttribute("Event", nil); player:SetAttribute("EventFixed", nil); player:SetAttribute("EventEnd", nil); player:SetAttribute("SpawnMult", nil)
		Customers.patienceMult[player] = nil
		notify(player, "eventOver", "green")
	end
	Plot.onFix = fixEvent
	G.startEvent, G.fixEvent, G.endEvent = startEvent, fixEvent, endEvent

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
		ensureQuests(d); checkLevel(player)
		push(player)
		player.CharacterAdded:Connect(function() task.wait(0.5); setHolding(player) end)
		for _, st in ipairs(Config.Staff) do showStaff(player, st.key) end
		task.spawn(function()
			while player.Parent do
				task.wait(math.random(Config.EventEvery[1], Config.EventEvery[2]))
				if not player.Parent then break end
				startEvent(player, Config.Events[math.random(#Config.Events)])
				task.wait(Config.EventDuration); endEvent(player)
			end
		end)
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
		Customers.clear(p); Plot.release(p); passCache[p] = nil; cooking[p] = nil; staffNpcs[p] = nil; trays[p] = nil
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
