-- ตัวช่วยกลาง: notify, push, สิทธิ์, บันทึกวินิจฉัย
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local DSS = game:GetService("DataStoreService")
local Config = require(game.ReplicatedStorage.Config)
local Locale = require(game.ReplicatedStorage.Locale)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = { hooks = {} }
function Core.isReal(p) return typeof(p) == "Instance" and p:IsA("Player") end
function Core.lang(p) return (Core.isReal(p) and p:GetAttribute("Lang")) or "en" end
function Core.T(p, key, ...) return Locale.get(Core.lang(p), key, ...) end
Core.log = {}
function Core.notify(p, key, color, ...)
	table.insert(Core.log, key)
	if #Core.log > 50 then table.remove(Core.log, 1) end
	if Core.isReal(p) then Remotes.Notify:FireClient(p, key, color or "white", ...) end
end
function Core.push(p)
	local d = Data.get(p)
	if d and Core.isReal(p) then Remotes.DataUpdate:FireClient(p, d) end
end
function Core.char(p) local d = Data.get(p); return d and d.char, d end
local passCache = {}
function Core.ownsPass(p, key)
	local id; for _, gp in ipairs(Config.GamePasses) do if gp.key == key then id = gp.id end end
	if not id or id == 0 then return false end
	passCache[p] = passCache[p] or {}
	if passCache[p][key] == nil then
		local ok, res = pcall(MPS.UserOwnsGamePassAsync, MPS, p.UserId, id)
		passCache[p][key] = ok and res or false
		if Core.isReal(p) then p:SetAttribute("Pass_" .. key, passCache[p][key] or nil) end
	end
	return passCache[p][key]
end
function Core.clearPass(p) passCache[p] = nil end
local diagLast = {}
function Core.diag(msg)
	if diagLast[msg] and os.clock() - diagLast[msg] < 60 then return end
	diagLast[msg] = os.clock()
	task.spawn(function() pcall(function() DSS:GetDataStore("LifeDiag"):SetAsync(msg:sub(1, 48), os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg) end) end)
end
function Core.addCash(p, amount)
	local d = Data.get(p); if not d then return end
	if amount > 0 and Core.ownsPass(p, "VIP") then amount = math.floor(amount * 1.1) end
	d.cash = math.max(0, d.cash + amount)
	if amount > 0 then d.total += amount; d.weekEarned = (d.weekEarned or 0) + amount end
end
function Core.spend(p, amount)
	local d = Data.get(p); if not d then return false end
	if d.cash < amount then Core.notify(p, "notEnough", "red"); return false end
	d.cash -= amount; return true
end
function Core.trait(c, key) for _, t in ipairs(c.traits or {}) do if t == key then return true end end; return false end
function Core.traitCfg(key) for _, t in ipairs(Config.Traits) do if t.key == key then return t end end end
function Core.career(key) for _, c in ipairs(Config.Careers) do if c.key == key then return c end end; if key == "Barista" then return Config.PartTime end end
function Core.stage(c) return Config.Stages[c.stage] end
function Core.isAdult(c) return c.stage >= 5 end
function Core.getPlayerByUserId(id) return Players:GetPlayerByUserId(id) end
-- รูปลักษณ์ NPC: ดึงอวาตาร์จริงของผู้ใช้ Roblox (เสื้อผ้า/ผม/หน้า เหมือนคนจริง) ถ้าดึงไม่ได้ใช้สีพื้น
local descCache = {}
local KNOWN = { 1, 156, 261, 916, 2032622, 21557, 1207, 23415609, 45585262, 1848960 }
function Core.npcDescription(seed)
	seed = seed or math.random(1000)
	if descCache[seed] then return descCache[seed] end
	local ids = { KNOWN[(seed - 1) % #KNOWN + 1], math.random(100000000, 2000000000), math.random(100000000, 2000000000) }
	for _, id in ipairs(ids) do
		local ok, desc = pcall(Players.GetHumanoidDescriptionFromUserId, Players, id)
		-- รับเฉพาะอวาตาร์ที่มีผม + เสื้อผ้า (ดูเหมือนคนจริง)
		if ok and desc and desc.HairAccessory ~= "" and (desc.Shirt ~= 0 or desc.GraphicTShirt ~= 0 or desc.TorsoColor ~= Color3.new(0, 0, 0)) then descCache[seed] = desc; return desc end
	end
	local desc = Instance.new("HumanoidDescription")
	desc.HeadColor = Color3.fromRGB(240, 200, 170); desc.TorsoColor = Color3.fromHSV((seed % 12) / 12, 0.6, 0.9); desc.LeftArmColor = desc.HeadColor; desc.RightArmColor = desc.HeadColor; desc.LeftLegColor = Color3.fromRGB(50, 50, 80); desc.RightLegColor = desc.LeftLegColor
	descCache[seed] = desc
	return desc
end
function Core.spawnNpc(seed, name)
	local ok, npc = pcall(Players.CreateHumanoidModelFromDescription, Players, Core.npcDescription(seed), Enum.HumanoidRigType.R15)
	if not ok then return nil end
	npc.Name = name or "NPC"
	local h = npc:FindFirstChildOfClass("Humanoid"); if h then h.DisplayName = name or "NPC"; h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
	return npc
end
-- ชุดตามอาชีพ: ประกอบจาก Part เชื่อมกับตัวละคร (หมวกเชฟ, เสื้อกาวน์หมอ, หมวกตำรวจ, ผ้ากันเปื้อน)
local function weldPart(model, attachTo, size, offset, color, material, shape)
	local base = model:FindFirstChild(attachTo); if not base then return end
	local p = Instance.new("Part"); p.Size = size; p.Color = color; p.Material = material or Enum.Material.SmoothPlastic; p.CanCollide = false; p.Massless = true; p.Name = "Uniform"
	if shape then p.Shape = shape end
	p.CFrame = base.CFrame * offset; p.Parent = model
	local w = Instance.new("WeldConstraint"); w.Part0 = base; w.Part1 = p; w.Parent = p
	return p
end
local OUTFITS = {
	Chef = function(m) weldPart(m, "Head", Vector3.new(1.3, 1.4, 1.3), CFrame.new(0, 1.1, 0), Color3.new(1, 1, 1), Enum.Material.Fabric, Enum.PartType.Cylinder); local h = m:FindFirstChild("Uniform"); if h then h.CFrame = h.CFrame * CFrame.Angles(0, 0, math.rad(90)) end
		weldPart(m, "UpperTorso", Vector3.new(2.1, 1.2, 1.1), CFrame.new(0, -0.1, 0), Color3.new(1, 1, 1), Enum.Material.Fabric)
		weldPart(m, "LowerTorso", Vector3.new(2.0, 1.2, 0.3), CFrame.new(0, -0.3, -0.5), Color3.fromRGB(30, 30, 30), Enum.Material.Fabric) end,
	Doctor = function(m) weldPart(m, "UpperTorso", Vector3.new(2.15, 1.7, 1.15), CFrame.new(0, -0.3, 0), Color3.new(1, 1, 1), Enum.Material.Fabric)
		weldPart(m, "UpperTorso", Vector3.new(0.6, 0.6, 0.3), CFrame.new(0, 0.3, -0.62), Color3.fromRGB(60, 110, 200), Enum.Material.SmoothPlastic) end,
	Police = function(m) weldPart(m, "Head", Vector3.new(1.4, 0.5, 1.4), CFrame.new(0, 0.7, 0), Color3.fromRGB(30, 50, 120), Enum.Material.Fabric); weldPart(m, "Head", Vector3.new(1.5, 0.15, 0.7), CFrame.new(0, 0.5, -0.75), Color3.fromRGB(20, 20, 30))
		weldPart(m, "UpperTorso", Vector3.new(2.1, 1.5, 1.1), CFrame.new(0, -0.2, 0), Color3.fromRGB(30, 50, 120), Enum.Material.Fabric); weldPart(m, "UpperTorso", Vector3.new(0.4, 0.4, 0.1), CFrame.new(-0.5, 0.3, -0.6), Color3.fromRGB(240, 200, 60), Enum.Material.Metal) end,
	Teacher = function(m) weldPart(m, "UpperTorso", Vector3.new(2.1, 1.5, 1.1), CFrame.new(0, -0.2, 0), Color3.fromRGB(90, 70, 60), Enum.Material.Fabric); weldPart(m, "UpperTorso", Vector3.new(0.3, 1.2, 0.1), CFrame.new(0, -0.2, -0.6), Color3.fromRGB(180, 40, 40)) end,
	Programmer = function(m) weldPart(m, "UpperTorso", Vector3.new(2.1, 1.5, 1.1), CFrame.new(0, -0.2, 0), Color3.fromRGB(50, 60, 90), Enum.Material.Fabric) end,
	Artist = function(m) weldPart(m, "Head", Vector3.new(1.5, 0.3, 1.5), CFrame.new(0.2, 0.75, 0), Color3.fromRGB(40, 40, 40), Enum.Material.Fabric); weldPart(m, "UpperTorso", Vector3.new(2.1, 1.5, 1.1), CFrame.new(0, -0.2, 0), Color3.fromRGB(250, 250, 250), Enum.Material.Fabric) end,
	Barista = function(m) weldPart(m, "UpperTorso", Vector3.new(2.0, 1.4, 0.3), CFrame.new(0, -0.3, -0.5), Color3.fromRGB(60, 120, 60), Enum.Material.Fabric) end,
	Student = function(m) weldPart(m, "UpperTorso", Vector3.new(2.1, 1.5, 1.1), CFrame.new(0, -0.2, 0), Color3.new(1, 1, 1), Enum.Material.Fabric); weldPart(m, "LowerTorso", Vector3.new(2.05, 1.0, 1.05), CFrame.new(0, 0, 0), Color3.fromRGB(30, 40, 80), Enum.Material.Fabric) end,
}
function Core.wearUniform(model, kind)
	if not model then return end
	Core.removeUniform(model)
	local f = OUTFITS[kind]; if f then pcall(f, model) end
end
function Core.removeUniform(model)
	if not model then return end
	for _, x in ipairs(model:GetChildren()) do if x.Name == "Uniform" then x:Destroy() end end
end
return Core
