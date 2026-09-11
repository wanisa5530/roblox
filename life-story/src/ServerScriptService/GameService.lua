-- ประกอบทุกระบบ + จัดการ Remote ทั้งหมด (G.init เรียกจาก Main และจากเทสต์)
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local Config = require(game.ReplicatedStorage.Config)
local Locale = require(game.ReplicatedStorage.Locale)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Map = require(script.Parent.MapService)
local Time = require(script.Parent.TimeService)
local Home = require(script.Parent.HomeService)
local Sim = require(script.Parent.SimService)
local Career = require(script.Parent.CareerService)
local Social = require(script.Parent.SocialService)
local Biz = require(script.Parent.BusinessService)
local LB = require(script.Parent.LeaderboardService)
local Vehicle = require(script.Parent.VehicleService)
local Work = require(script.Parent.Workplaces)
local G = { Vehicle = Vehicle, Data = Data, Core = Core, Map = Map, Home = Home, Sim = Sim, Career = Career, Social = Social, Biz = Biz, Time = Time }
local started = false
-- ประตูอาคาร: prompt เข้างาน/เรียน/รักษา/ซื้อของ
local function buildingPrompts()
	local function pp(key, action, label, cb)
		local b = Map.buildings[key]; if not b then return end
		local door = b.model:FindFirstChild("Entrance"); if not door then return end
		local x = Instance.new("ProximityPrompt"); x.ActionText = label; x.ObjectText = key; x.HoldDuration = 0; x.MaxActivationDistance = 14; x.RequiresLineOfSight = false; x.Parent = door
		x:SetAttribute("Action", action); x.Triggered:Connect(cb)
		-- ป้ายลอยหน้าประตูให้เห็นจุดเข้าชัด ๆ
		local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 160, 0, 44); bb.StudsOffset = Vector3.new(0, 7, 0); bb.AlwaysOnTop = false; bb.MaxDistance = 90; bb.Parent = door
		local tl = Instance.new("TextLabel"); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundColor3 = Color3.fromRGB(16, 26, 36); tl.BackgroundTransparency = 0.25; tl.TextColor3 = Color3.fromRGB(255, 225, 90); tl.Font = Enum.Font.GothamBold; tl.TextScaled = true; tl.Text = "🚪 " .. key; tl.Parent = bb
		local uc = Instance.new("UICorner"); uc.Parent = tl
	end
	for _, cc in ipairs(Config.Careers) do
		pp(cc.building, "work", "Work", function(who)
			local c = Core.char(who); if not c then return end
			if c.career == cc.key then
				local ok, why = Career.startShift(who, "work")
				if not ok then if why == "notTime" then Core.notify(who, "workHours", "yellow", cc.hours[1], cc.hours[2]) elseif why == "done" then Core.notify(who, "shiftDoneToday", "yellow") end end
			elseif cc.building == "Hospital" then Remotes.Career:FireClient(who, "openHospital")  -- คนทั่วไปมาโรงพยาบาลเพื่อรักษา
			else Remotes.Career:FireClient(who, "openJob", cc.key) end
		end)
	end
	pp("Cafe", "work", "Work", function(who) local c = Core.char(who); if c and c.career == "Barista" then Career.startShift(who, "work") end end)
	pp("School", "school", "School", function(who) local ok, why = Career.startShift(who, "school"); if not ok and why == "notTime" then Core.notify(who, "workHours", "yellow", Config.SchoolHours[1], Config.SchoolHours[2]) elseif not ok and why == "done" then Core.notify(who, "shiftDoneToday", "yellow") end end)
	pp("University", "uni", "University", function(who) local c = Core.char(who); if c and c.uni then Career.startShift(who, "uni") else Remotes.Career:FireClient(who, "openUni") end end)
	pp("Shop", "shop", "Shop", function(who) Remotes.Build:FireClient(who, "openShop") end)
	pp("CityHall", "cityhall", "Lots", function(who) Remotes.Build:FireClient(who, "openLots") end)
end
-- ===== ระบบแต่งตัว: ใส่ไอเท็มจาก catalog ผ่าน HumanoidDescription (บันทึกใน c.outfit) =====
local OUTFIT_SLOTS = { hair = "HairAccessory", hat = "HatAccessory", shirt = "Shirt", pants = "Pants", face = "Face", tshirt = "GraphicTShirt", glasses = "FaceAccessory", back = "BackAccessory" }
function G.applyOutfit(p)
	local c = Core.char(p); if not c or not c.outfit or not Core.isReal(p) then return end
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
	local ok, desc = pcall(function() return hum:GetAppliedDescription() end); if not ok or not desc then return end
	for slot, prop in pairs(OUTFIT_SLOTS) do
		local v = c.outfit[slot]
		if v ~= nil then
			if slot == "hair" or slot == "hat" or slot == "glasses" or slot == "back" then desc[prop] = v == 0 and "" or tostring(v) else desc[prop] = v end
		end
	end
	if c.outfit.skin then local col = Color3.fromRGB(unpack(c.outfit.skin)); for _, k in ipairs({ "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" }) do desc[k] = col end end
	pcall(function() hum:ApplyDescription(desc) end)
	task.delay(0.3, function() Sim.applyScale(p) end)
end
function G.setOutfit(p, slot, value)
	local c = Core.char(p); if not c or type(slot) ~= "string" then return end
	c.outfit = c.outfit or {}
	if slot == "skin" then
		if type(value) ~= "table" or #value ~= 3 then return end
		c.outfit.skin = { math.clamp(tonumber(value[1]) or 0, 0, 255), math.clamp(tonumber(value[2]) or 0, 0, 255), math.clamp(tonumber(value[3]) or 0, 0, 255) }
	elseif OUTFIT_SLOTS[slot] then
		local id = tonumber(value); if not id or id < 0 or id > 1e12 then return end
		c.outfit[slot] = math.floor(id)
	else return end
	G.applyOutfit(p); Core.push(p)
end
local function teleport(p, pos)
	if Core.isReal(p) and p.Character and pos then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end end
end
function G.init()
	if started then return G end
	started = true
	Map.build(); Work.build(); Time.start(); buildingPrompts(); Biz.setup(); Social.spawnNpcs(); Social.spawnStaff()
	-- ===== Remotes =====
	Remotes.GetData.OnServerInvoke = function(p) return Data.get(p) end
	Remotes.CreateCharacter.OnServerInvoke = function(p, name, traits, aspiration)
		local d = Data.get(p); if not d or d.char then return false end
		if type(name) ~= "string" or #name < 1 or #name > 16 then name = p.DisplayName end
		local tr = {}
		for _, t in ipairs(type(traits) == "table" and traits or {}) do if Core.traitCfg(t) and #tr < Config.TraitCount then tr[#tr + 1] = t end end
		local aspOk = false; for _, a in ipairs(Config.Aspirations) do if a.key == aspiration then aspOk = true end end
		d.char = Data.newCharacter(name, tr, aspOk and aspiration or "Wealth", 1)
		Home.assign(p); Sim.ensureQuests(p); Sim.applyScale(p); Core.push(p)
		teleport(p, Home.homePos(p)); p:SetAttribute("AtHome", true)
		task.delay(1, function() Core.notify(p, "welcome2", "green") end)
		return true
	end
	Remotes.Action.OnServerEvent:Connect(function(p, kind, a, b, c2)
		if kind == "clientError" then Core.diag("client:" .. tostring(a):sub(1, 300)); return end
		local c = Core.char(p); if not c then return end
		if kind == "stop" then Home.stopAction(p)
		elseif kind == "clean" then Home.active[p] = { key = "clean", cfg = { need = nil }, act = "clean", t0 = os.clock() }; p:SetAttribute("Action", "clean"); task.delay(15, function() if Home.active[p] and Home.active[p].act == "clean" then Home.stopAction(p); c.needs.environment = math.min(c.envBase or 60, c.needs.environment + 40) end end)
		elseif kind == "goHome" then teleport(p, Home.homePos(p)); p:SetAttribute("AtHome", true)
		elseif kind == "outfit" then G.setOutfit(p, a, b)
		elseif kind == "goTo" then local d = Map.door(a); if d then if Core.ownsPass(p, "SportsCar") or Core.spend(p, 20) then teleport(p, d) end end
		elseif kind == "buyCar" then Vehicle.buy(p, a)
		elseif kind == "callCar" then Vehicle.callCar(p)
		elseif kind == "treat" then Sim.treat(p)
		elseif kind == "insurance" then Sim.buyInsurance(p)
		elseif kind == "homework" then if c.stage >= 3 and c.stage <= 4 then c.school.homework = (c.school.homework or 0) + 1; Sim.addXp(p, "logic", 15); c.needs.fun = math.max(0, c.needs.fun - 10); Core.push(p) end
		elseif kind == "clientError" then Core.diag("client:" .. tostring(a):sub(1, 60))
		elseif kind == "lang" then if type(a) == "string" and Locale.strings[a] then p:SetAttribute("Lang", a); Home.rebuild(p) end
		end
	end)
	Remotes.MinigameResult.OnServerEvent:Connect(function(p, q) Career.onResult(p, q) end)
	Remotes.Career.OnServerEvent:Connect(function(p, kind, key)
		if kind == "apply" then Career.apply(p, key) elseif kind == "quit" then Career.quit(p) elseif kind == "enroll" then Career.enroll(p, key) end
	end)
	Remotes.Enroll.OnServerInvoke = function(p, f) return Career.enroll(p, f) end
	Remotes.Social.OnServerEvent:Connect(function(p, kind, target, key)
		if kind == "interact" then local ok, st = Social.interact(p, target, key); Remotes.Social:FireClient(p, "result", target, ok, st, Core.char(p) and Core.char(p).rel[target]) end
	end)
	Remotes.Family.OnServerEvent:Connect(function(p, kind, a)
		if kind == "tryBaby" then Social.tryBaby(p) elseif kind == "adopt" then Social.adopt(p) elseif kind == "pet" then Social.adoptPet(p, a) elseif kind == "divorce" then Social.divorce(p) elseif kind == "playKid" then Social.playWithKid(p, tonumber(a)) end
	end)
	Remotes.Heir.OnServerInvoke = function(p, i) return Sim.chooseHeir(p, tonumber(i)) end
	Remotes.Build.OnServerEvent:Connect(function(p, kind, key, x, z, rot)
		if kind == "buy" then Home.buy(p, key, tonumber(x) or 0, tonumber(z) or 0, tonumber(rot) or 0)
		elseif kind == "sell" then Home.sell(p, tonumber(key))
		elseif kind == "move" then Home.move(p, tonumber(key), tonumber(x) or 0, tonumber(z) or 0, tonumber(rot))
		elseif kind == "lot" then Home.buyLot(p, key) end
	end)
	Remotes.BuyLot.OnServerInvoke = function(p, key) return Home.buyLot(p, key) end
	Remotes.Business.OnServerEvent:Connect(function(p, kind)
		if kind == "buy" then Biz.buy(p) elseif kind == "upgrade" then Biz.upgrade(p) elseif kind == "work" then Biz.workHere(p) end
	end)
	Remotes.ClaimDaily.OnServerInvoke = function(p) return Sim.claimDaily(p) end
	Remotes.Leaderboard.OnServerInvoke = function() return LB.top() end
	Remotes.PromptPass.OnServerEvent:Connect(function(p, kind, key)
		if kind == "pass" then for _, gp in ipairs(Config.GamePasses) do if gp.key == key and gp.id > 0 then MPS:PromptGamePassPurchase(p, gp.id) end end
		elseif kind == "product" then for _, dp in ipairs(Config.DevProducts) do if dp.key == key and dp.id > 0 then MPS:PromptProductPurchase(p, dp.id) end end end
	end)
	MPS.PromptGamePassPurchaseFinished:Connect(function(p, id, ok) if ok then Core.clearPass(p); for _, gp in ipairs(Config.GamePasses) do Core.ownsPass(p, gp.key) end; Core.push(p) end end)
	MPS.ProcessReceipt = function(info)
		local p = Players:GetPlayerByUserId(info.PlayerId); if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
		for _, dp in ipairs(Config.DevProducts) do
			if dp.id == info.ProductId then
				local c = Core.char(p)
				if dp.cash then Core.addCash(p, dp.cash)
				elseif dp.key == "Elixir" and c then c.stage = math.max(5, c.stage - 1); c.ageDays = 0; Sim.applyScale(p)
				elseif dp.key == "Rename" and c then p:SetAttribute("CanRename", true) end
				Core.push(p); return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- ===== ผู้เล่นเข้า/ออก =====
	local function onPlayer(p)
		local d = Data.load(p)
		Core.diag("join " .. tostring(p.Name) .. " v" .. tostring(game.PlaceVersion))
		LB.setup(p, d)
		for _, gp in ipairs(Config.GamePasses) do Core.ownsPass(p, gp.key) end
		if d.char then Home.assign(p); Biz.restore(p); Sim.ensureQuests(p); Sim.applyScale(p) end
		-- อยู่ที่บ้านไหม (ใช้กับคู่มือ/โหมดสร้าง)
		task.spawn(function()
			while p.Parent do
				task.wait(2)
				local hp = Home.homePos(p); local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if hp and hrp then p:SetAttribute("AtHome", (hrp.Position - hp).Magnitude < 40 or nil) end
				-- จุดหมายสำหรับลูกศรนำทาง (บ้าน / ที่ทำงาน / สวน)
				if hp then p:SetAttribute("HomePos", hp) end
				local c = Core.char(p)
				if c and c.career then for _, cc in ipairs(Config.Careers) do if cc.key == c.career then local b = Map.buildings[cc.building]; if b then p:SetAttribute("WorkDoor", b.door) end end end else p:SetAttribute("WorkDoor", nil) end
				if Map.buildings.Park then p:SetAttribute("ParkPos", Map.buildings.Park.door) end
			end
		end)
		Social.attachPlayerPrompt(p)
		if Core.isReal(p) then p.CharacterAdded:Connect(function() task.wait(0.5); Sim.applyScale(p); G.applyOutfit(p); if d.char then teleport(p, Home.homePos(p)) end end) end
		task.delay(1, function() G.applyOutfit(p) end)
		Core.push(p)
		task.spawn(function()
			local last = os.clock()
			while p.Parent do
				task.wait(1)
				local now = os.clock(); local dt = math.min(now - last, 5); last = now
				local ok, err = pcall(function()
					local c = Core.char(p); if not c or c.dead then return end
					Sim.tick(p, dt)
					local t = Time.now()
					if d.lastDay ~= t.day then d.lastDay = t.day; d.dayCount += 1; Sim.newDay(p) end
					Career.remind(p); Career.checkMissed(p)
					if math.floor(now) % 5 == 0 then Core.push(p) end
				end)
				if not ok then warn("tick", err); Core.diag("tick:" .. tostring(err)) end
			end
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
	Players.PlayerRemoving:Connect(function(p) Home.release(p); Biz.onLeave(p); Vehicle.onLeave(p); Home.active[p] = nil; Career.shift[p] = nil end)
	-- เตะออกเมื่อมีเวอร์ชันใหม่
	task.spawn(function()
		local DSS = game:GetService("DataStoreService")
		while true do
			task.wait(30)
			local ok, v = pcall(function() return DSS:GetDataStore("LifeMeta"):GetAsync("version") end)
			if ok and type(v) == "number" and game.PlaceVersion > 0 and v > game.PlaceVersion then for _, p in ipairs(Players:GetPlayers()) do p:Kick(Core.T(p, "updateKick")) end end
		end
	end)
	G.onPlayer = onPlayer
	-- ตรวจเนื้อหาแพ็กโมเดลใหม่ (ชั่วคราว): บันทึกชื่อชิ้นส่วน/ขนาดลง diag เพื่อวางแผนจัดวาง
	task.spawn(function()
		for _, id in ipairs({ 6418277837, 13168370735, 15264880043, 6853922596, 14800136759, 18888365209, 6850108252, 9432856072 }) do
			task.wait(1)
			local ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
			if not ok or not res then Core.diag("pack " .. id .. " FAIL " .. tostring(res):sub(1, 60))
			else
				local m = res
				for _ = 1, 3 do local ch = m:GetChildren(); if #ch == 1 and (ch[1]:IsA("Model") or ch[1]:IsA("Folder")) then m = ch[1] else break end end
				local kids = {}
				for i, k in ipairs(m:GetChildren()) do
					if i > 40 then break end
					local sz = k:IsA("Model") and k:GetExtentsSize() or (k:IsA("BasePart") and k.Size) or Vector3.new()
					kids[#kids + 1] = k.Name:sub(1, 22) .. "(" .. k.ClassName:sub(1, 5) .. ":" .. math.floor(sz.X) .. "x" .. math.floor(sz.Y) .. "x" .. math.floor(sz.Z) .. ")"
				end
				local ext = m:IsA("Model") and m:GetExtentsSize() or Vector3.new()
				local txt = "pack " .. id .. " n=" .. #m:GetChildren() .. " ext=" .. math.floor(ext.X) .. "x" .. math.floor(ext.Y) .. "x" .. math.floor(ext.Z) .. " | " .. table.concat(kids, ", ")
				for i = 1, math.ceil(#txt / 900) do Core.diag(("pack %d part%d: "):format(id, i) .. txt:sub((i - 1) * 900 + 1, i * 900)) end
				res:Destroy()
			end
		end
	end)
	Core.diag("boot v" .. tostring(game.PlaceVersion) .. " assets=" .. tostring(Map.assetsUsed) .. (Map.terrainErr and (" terrainErr=" .. Map.terrainErr:sub(1, 80)) or ""))
	return G
end
return G
