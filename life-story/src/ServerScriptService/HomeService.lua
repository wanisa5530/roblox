-- บ้าน: จัดสรรที่ดิน วางเฟอร์นิเจอร์ ปฏิสัมพันธ์ (กิน นอน อาบน้ำ ฯลฯ) บิล
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Map = require(script.Parent.MapService)
local H = { owner = {}, active = {}, onAction = nil }  -- active[player] = {item, t0}
local function fcfg(key) for _, f in ipairs(Config.Furniture) do if f.key == key then return f end end end
H.fcfg = fcfg
local function lotOf(p)
	local c = Core.char(p); if not c then return nil end
	return Map.lots[c.lotIndex]
end
H.lotOf = lotOf
local function prompt(parent, action, obj, cb)
	local pp = Instance.new("ProximityPrompt"); pp.ActionText = action; pp.ObjectText = obj or ""; pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false
	pp.Parent = parent; pp.Triggered:Connect(cb); return pp
end
local ACTION = { bed = "sleep", kitchen = "eat", bath = "useToilet", fun = "watch", skill = "practice", outdoor = "garden", family = "play", decor = nil, safety = nil }
-- สร้างโมเดลเฟอร์นิเจอร์จาก Part
local function buildItem(cfg, cf, parent, id)
	local m = Instance.new("Model"); m.Name = cfg.key; m:SetAttribute("Key", cfg.key); m:SetAttribute("Id", id)
	local s = Vector3.new(cfg.size[1], cfg.size[2], cfg.size[3])
	local body = Instance.new("Part"); body.Anchored = true; body.Size = s; body.CFrame = cf * CFrame.new(0, s.Y / 2, 0); body.Color = Color3.fromRGB(cfg.color[1], cfg.color[2], cfg.color[3]); body.Material = Enum.Material.SmoothPlastic; body.Name = "Body"; body.Parent = m
	m.PrimaryPart = body
	if cfg.cat == "bed" then local pil = body:Clone(); pil.Size = Vector3.new(s.X - 1, 0.8, 2); pil.CFrame = body.CFrame * CFrame.new(0, s.Y / 2 + 0.4, -s.Z / 2 + 1.5); pil.Color = Color3.new(1, 1, 1); pil.Parent = m end
	if cfg.cat == "fun" and cfg.key:sub(1, 2) == "TV" then local scr = body:Clone(); scr.Size = Vector3.new(s.X - 0.6, s.Y - 0.6, 0.2); scr.CFrame = body.CFrame * CFrame.new(0, 0, -s.Z / 2 - 0.1); scr.Color = Color3.fromRGB(80, 160, 255); scr.Material = Enum.Material.Neon; scr.Parent = m end
	if cfg.light then local l = Instance.new("PointLight"); l.Range = 14; l.Brightness = 1.2; l.Color = Color3.fromRGB(255, 230, 170); l.Parent = body end
	if cfg.cat == "outdoor" then local plant = body:Clone(); plant.Size = Vector3.new(s.X - 1, 1.5, s.Z - 1); plant.CFrame = body.CFrame * CFrame.new(0, 1.2, 0); plant.Color = Color3.fromRGB(60, 160, 60); plant.Material = Enum.Material.Grass; plant.Name = "Plant"; plant.Parent = m end
	m.Parent = parent
	return m
end
-- วางเฟอร์นิเจอร์ทั้งหมดของบ้านใหม่ (เรียกตอนเข้า/ย้าย)
function H.rebuild(p)
	local c = Core.char(p); local lot = lotOf(p); if not c or not lot then return end
	local old = lot.model:FindFirstChild("Furniture"); if old then old:Destroy() end
	local f = Instance.new("Folder"); f.Name = "Furniture"; f.Parent = lot.model
	for i, it in ipairs(c.furniture) do
		local cfg = fcfg(it.key)
		if cfg then
			local cf = CFrame.new(lot.origin + Vector3.new(it.x, 0.25, it.z)) * CFrame.Angles(0, math.rad(it.rot or 0), 0)
			local m = buildItem(cfg, cf, f, i)
			local act = ACTION[cfg.cat]
			if cfg.key == "Toilet" then act = "useToilet" elseif cfg.key == "Shower" then act = "shower" elseif cfg.key == "Bathtub" then act = "bath" elseif cfg.key == "Stove" then act = "cook" elseif cfg.key == "Sofa" then act = "sit" elseif cfg.key == "Bookshelf" then act = "read" elseif cfg.key == "Phone" then act = "call" elseif cfg.key == "Treadmill" then act = "workout" elseif cfg.key == "Workbench" then act = "tinker" elseif cfg.key == "GameConsole" then act = "play" elseif cfg.key == "Crib" then act = nil elseif cfg.key == "PetBed" then act = "feedPet" elseif cfg.key == "DiningTable" then act = "sit" end
			if act then
				local pp = prompt(m.PrimaryPart, Core.T(p, act), Core.T(p, cfg.key), function(who)
					if who == p or (H.owner[who] == p) then H.startAction(who, it.key, i, act, m) end
				end)
				pp:SetAttribute("Action", act)
			end
			if cfg.harvest then
				local hp = prompt(m.PrimaryPart, Core.T(p, "harvest"), "", function(who) if who == p then H.harvest(who, m) end end); hp:SetAttribute("Action", "harvest"); hp.Enabled = false; m:SetAttribute("Planted", os.clock())
			end
		end
	end
	local ns = lot.model:FindFirstChild("NameSign"); if ns then ns.SurfaceGui.TextLabel.Text = "🏠 " .. c.name .. " (" .. (Core.isReal(p) and p.DisplayName or "?") .. ")" end
	H.updateEnvironment(p)
end
function H.updateEnvironment(p)
	local c = Core.char(p); if not c then return end
	local env = 30
	for _, it in ipairs(c.furniture) do local cfg = fcfg(it.key); if cfg and cfg.env then env += cfg.env * 2 end end
	if Core.trait(c, "Neat") then env += 10 end
	c.envBase = math.min(100, env)
end
-- ปฏิสัมพันธ์: เริ่ม action ค้างไว้ จน need เต็มหรือผู้เล่นเดินออก/กด stop
function H.startAction(p, key, id, act, model)
	local c = Core.char(p); if not c then return end
	local cfg = fcfg(key); if not cfg then return end
	if act == "cook" then
		if c.needs.energy < 5 then return end
		local skill = c.skills.cooking or 0
		if math.random() < Config.FireChance * (1 - skill / 12) * (Core.trait(c, "Clumsy") and 1.5 or 1) then H.startFire(p, model); return end
	end
	if act == "feedPet" then if c.pet then c.pet.fed = os.time(); c.needs.fun = math.min(100, c.needs.fun + 10); Core.notify(p, "feedPet", "green") end; return end
	H.active[p] = { key = key, cfg = cfg, act = act, t0 = os.clock(), model = model }
	if Core.isReal(p) then p:SetAttribute("Action", act); p:SetAttribute("ActionItem", cfg.key) end
	if Core.isReal(p) and p.Character and model and model.PrimaryPart then
		local hrp = p.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			if act == "sleep" then hrp.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 1.2, 0) * CFrame.Angles(math.rad(-90), 0, 0)
			elseif act == "sit" or act == "watch" then hrp.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 1.5, 0) end
			local hum = p.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = (act == "sleep") and 0 or 16 end
		end
	end
	if H.onAction then H.onAction(p, act, cfg) end
end
function H.stopAction(p)
	local a = H.active[p]; H.active[p] = nil
	if Core.isReal(p) then p:SetAttribute("Action", nil); p:SetAttribute("ActionItem", nil)
		local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 16 end
		if a and a.act == "sleep" and p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp and a.model and a.model.PrimaryPart then hrp.CFrame = a.model.PrimaryPart.CFrame * CFrame.new(0, 3, 4) end end
	end
end
-- tick ต่อวินาที: เติม need ตาม rate; ฝึกทักษะ; หยุดเมื่อเต็ม
function H.tick(p, c, dt)
	local a = H.active[p]; if not a then return end
	local cfg = a.cfg
	if cfg.need then
		local rate = cfg.rate * dt
		if a.act == "eat" then rate = rate * 2.5 elseif a.act == "cook" then rate = rate * (1 + (c.skills.cooking or 0) / 5) end
		c.needs[cfg.need] = math.min(100, c.needs[cfg.need] + rate)
		if a.act == "sleep" then c.needs.health = math.min(100, c.needs.health + 0.05 * dt) end
		if c.needs[cfg.need] >= 100 then
			if a.act == "eat" and math.random() < Config.FoodSpoilChance and H.onSick then H.onSick(p, "FoodPoison") end
			H.stopAction(p)
			return
		end
	end
	if cfg.skill and a.act ~= "sleep" then
		local mult = 1
		for _, t in ipairs(c.traits) do local tc = Core.traitCfg(t); if tc and tc.skill == cfg.skill then mult = 1.5 end end
		if c.mood == "Inspired" or c.mood == "Focused" then mult *= 1.3 elseif c.mood == "Sad" or c.mood == "Angry" then mult *= 0.6 end
		if H.onSkillXp then H.onSkillXp(p, cfg.skill, 4 * dt * mult) end
	end
	if a.act == "cook" or a.act == "eat" then if H.onSkillXp and cfg.key == "Stove" then H.onSkillXp(p, "cooking", 3 * dt) end end
	if os.clock() - a.t0 > 600 then H.stopAction(p) end
end
-- ไฟไหม้ครัว
function H.startFire(p, model)
	local c = Core.char(p); if not c or c.fire then return end
	c.fire = true; Core.notify(p, "fire", "red")
	local fire = Instance.new("Fire"); fire.Size = 8; fire.Heat = 12; fire.Parent = model.PrimaryPart
	local pp = prompt(model.PrimaryPart, Core.T(p, "extinguish"), "", function(who) if who == p or H.owner[who] == p then H.putOutFire(p, model) end end); pp.Name = "FirePrompt"; pp:SetAttribute("Action", "extinguish")
	local hasAlarm = false; for _, it in ipairs(c.furniture) do if it.key == "SmokeAlarm" then hasAlarm = true end end
	task.delay(hasAlarm and 45 or 25, function()
		if c.fire then
			c.fire = nil; fire:Destroy(); pp:Destroy()
			if H.onFireDamage then H.onFireDamage(p, hasAlarm) end
		end
	end)
end
function H.putOutFire(p, model)
	local c = Core.char(p); if not c or not c.fire then return end
	c.fire = nil
	for _, x in ipairs(model.PrimaryPart:GetChildren()) do if x:IsA("Fire") or x.Name == "FirePrompt" then x:Destroy() end end
	c.needs.health = math.max(0, c.needs.health - 5); Core.notify(p, "fireOut", "green")
	if H.onSkillXp then H.onSkillXp(p, "handiness", 20) end
end
function H.harvest(p, model)
	local c = Core.char(p); if not c then return end
	local planted = model:GetAttribute("Planted") or 0
	if os.clock() - planted < 60 then return end
	model:SetAttribute("Planted", os.clock())
	for _, x in ipairs(model.PrimaryPart:GetChildren()) do if x:IsA("ProximityPrompt") and x:GetAttribute("Action") == "harvest" then x.Enabled = false end end
	local lvl = c.skills.gardening or 0
	Core.addCash(p, 30 + lvl * 15); c.needs.hunger = math.min(100, c.needs.hunger + 20)
	if H.onSkillXp then H.onSkillXp(p, "gardening", 25) end
	Core.push(p)
end
-- ซื้อ/วาง/ขาย
function H.buy(p, key, x, z, rot)
	local c = Core.char(p); if not c then return false end
	local cfg = fcfg(key); if not cfg then return false end
	local lotCfg; for _, l in ipairs(Config.Lots) do if l.key == c.lot then lotCfg = l end end
	if #c.furniture >= (lotCfg and lotCfg.size or 12) then Core.notify(p, "tooManyItems", "red"); return false end
	local half = 20; if lotCfg and lotCfg.key == "Apartment" then half = 11 end
	x = math.clamp(math.floor(x / 2 + 0.5) * 2, -half + 2, half - 2); z = math.clamp(math.floor(z / 2 + 0.5) * 2, -half + 2, half - 2)
	if not Core.spend(p, cfg.price) then return false end
	table.insert(c.furniture, { key = key, x = x, z = z, rot = rot or 0 })
	H.rebuild(p); Core.notify(p, "bought", "green", Core.T(p, key)); Core.push(p)
	return true
end
function H.sell(p, id)
	local c = Core.char(p); if not c then return end
	local it = c.furniture[id]; if not it then return end
	local cfg = fcfg(it.key); table.remove(c.furniture, id)
	Core.addCash(p, math.floor(cfg.price * 0.5)); H.rebuild(p); Core.push(p)
end
function H.move(p, id, x, z, rot)
	local c = Core.char(p); if not c then return end
	local it = c.furniture[id]; if not it then return end
	it.x = math.floor(x / 2 + 0.5) * 2; it.z = math.floor(z / 2 + 0.5) * 2; it.rot = rot or it.rot
	H.rebuild(p)
end
-- จัดสรรที่ดิน: apartment ตอนเริ่ม, ซื้อบ้าน → ย้ายไป lot ว่าง
function H.assign(p)
	local c = Core.char(p); if not c then return end
	local want = (c.lot == "Apartment") and "apt" or "house"
	for k, lot in pairs(Map.lots) do
		local isApt = lot.apartment == true
		if lot.owner == nil and ((want == "apt") == isApt) then lot.owner = p; c.lotIndex = k; H.rebuild(p); return lot end
	end
end
function H.release(p)
	for _, lot in pairs(Map.lots) do if lot.owner == p then lot.owner = nil; local f = lot.model:FindFirstChild("Furniture"); if f then f:Destroy() end; local ns = lot.model:FindFirstChild("NameSign"); if ns then ns.SurfaceGui.TextLabel.Text = lot.apartment and ("Apt " .. tostring(lot.index):sub(4)) or "For sale" end end end
	H.active[p] = nil
end
function H.buyLot(p, key)
	local c = Core.char(p); if not c then return false end
	local lc; for _, l in ipairs(Config.Lots) do if l.key == key then lc = l end end
	if not lc or lc.key == c.lot then return false end
	if lc.pass and not Core.ownsPass(p, lc.pass) then Remotes.PromptPass:FireClient(p, "pass", lc.pass); return false end
	if lc.price > 0 and not Core.spend(p, lc.price) then return false end
	c.lot = key; c.lotSize = lc.size
	H.release(p); H.assign(p)
	Core.notify(p, "moveIn", "green"); Core.push(p)
	return true
end
function H.homePos(p) local lot = lotOf(p); return lot and lot.origin + Vector3.new(0, 3, 18) end
-- บิลรายวัน
function H.dailyBills(p)
	local c = Core.char(p); if not c then return end
	local lc; for _, l in ipairs(Config.Lots) do if l.key == c.lot then lc = l end end
	local total = Config.Bills.power + Config.Bills.water + (lc and (lc.rent + (lc.tax or 0)) or 0)
	if Core.trait(c, "Frugal") then total = math.floor(total * (1 - Core.traitCfg("Frugal").billDiscount)) end
	local d = Data.get(p)
	if d.cash >= total then d.cash -= total; c.unpaid = 0; Core.notify(p, "bills", "white", total)
	else c.unpaid = (c.unpaid or 0) + 1; Core.notify(p, "billsUnpaid", "red") end
end
return H
