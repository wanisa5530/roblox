-- ผู้คน: NPC ชาวเมือง ปฏิสัมพันธ์ ความสัมพันธ์ แต่งงาน ลูก สัตว์เลี้ยง
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Sim = require(script.Parent.SimService)
local Map = require(script.Parent.MapService)
local So = { npcs = {} }
local function icfg(key) for _, i in ipairs(Config.Interactions) do if i.key == key then return i end end end
function So.relOf(c, id)
	c.rel[id] = c.rel[id] or { f = 0, r = 0, day = 0 }
	return c.rel[id]
end
function So.status(c, id)
	local r = c.rel[id]; if not r then return "stranger" end
	if c.spouse == id then return "spouse" end
	if r.ex then return "ex" end
	if r.f <= -30 then return "enemy" end
	if r.r >= 60 then return "lover" end
	if r.f >= Config.BestFriendAt then return "bestFriend" end
	if r.f >= Config.FriendAt then return "friend" end
	if r.f >= 10 then return "acquaintance" end
	return "stranger"
end
-- ปฏิสัมพันธ์กับ NPC (id = ชื่อ) หรือผู้เล่น (id = "u"..UserId)
function So.interact(p, targetId, key)
	local c, d = Core.char(p); if not c then return false end
	local ic = icfg(key); if not ic then return false end
	if c.stage < 3 then return false end
	local r = So.relOf(c, targetId)
	if ic.minFriend and r.f < ic.minFriend then return false, "needFriend" end
	if ic.minRomance and r.r < ic.minRomance then return false, "needRomance" end
	if (ic.romance > 0) and c.stage < 4 then return false end
	local charm = (c.skills.charisma or 0) / 10
	local ok = true
	if key == "Joke" or key == "Flirt" then ok = math.random() < 0.6 + charm * 0.4 + (Core.trait(c, "Romantic") and key == "Flirt" and 0.2 or 0) end
	local moodMult = (c.mood == "Playful" or c.mood == "Flirty" or c.mood == "Happy") and 1.3 or 1
	if ok then
		r.f = math.clamp(r.f + ic.friend * moodMult, -100, 100); r.r = math.clamp(r.r + ic.romance * moodMult * (Core.trait(c, "Romantic") and 1.5 or 1), 0, 100)
		if ic.romance > 0 then Sim.addMoodlet(p, "Flirty", 20, 400) end
	else
		r.f = math.clamp(r.f - 5, -100, 100); Sim.addMoodlet(p, "Embarrassed", 20, 300)
	end
	r.day = d.dayCount
	c.needs.social = math.min(100, c.needs.social + ic.social)
	if r.day ~= c.socialLastDay or not c.socialIds or not c.socialIds[targetId] then c.socialIds = c.socialIds or {}; if not c.socialIds[targetId] then c.socialIds[targetId] = true; Sim.progress(p, "social", 1) end end
	Sim.addXp(p, "charisma", 6)
	if ic.marry then
		if c.married then return false, "married" end
		if r.r >= 90 and math.random() < 0.8 then
			if not Core.spend(p, Config.WeddingCost) then return false end
			c.married = true; c.spouse = targetId; c.spouseName = So.nameOf(targetId)
			Core.notify(p, "married", "green", c.spouseName); Sim.addMoodlet(p, "Happy", 60, 1800)
			-- คู่สมรสเป็นผู้เล่น: ตั้งค่าฝั่งนั้นด้วย
			local other = So.playerOf(targetId)
			if other then local oc = Core.char(other); if oc and not oc.married then oc.married = true; oc.spouse = "u" .. p.UserId; oc.spouseName = c.name; Core.notify(other, "married", "green", c.name); Core.push(other) end end
			Sim.checkAspiration(p)
		else Core.notify(p, "proposeNo", "red", So.nameOf(targetId)); r.r = math.max(0, r.r - 20) end
	end
	-- ฝั่งผู้เล่นอีกคน (ถ้าเป็นผู้เล่น) ก็เพิ่มความสัมพันธ์
	local other = So.playerOf(targetId)
	if other and other ~= p then local oc = Core.char(other); if oc then local orr = So.relOf(oc, "u" .. p.UserId); orr.f = math.clamp(orr.f + ic.friend * 0.8, -100, 100); orr.r = math.clamp(orr.r + ic.romance * 0.8, 0, 100); oc.needs.social = math.min(100, oc.needs.social + ic.social * 0.5); Core.push(other) end end
	Sim.checkAspiration(p); Core.push(p)
	return ok, So.status(c, targetId)
end
function So.playerOf(id) if type(id) == "string" and id:sub(1, 1) == "u" then return Players:GetPlayerByUserId(tonumber(id:sub(2))) end end
function So.nameOf(id) local pl = So.playerOf(id); if pl then local c = Core.char(pl); return c and c.name or pl.DisplayName end; return id end
function So.tryBaby(p)
	local c, d = Core.char(p); if not c then return false end
	if not c.married then Core.notify(p, "noSpouse", "red"); return false end
	if c.pregnantUntil or #c.kids >= Config.MaxKids or c.stage > 6 then return false end
	c.pregnantUntil = d.dayCount + Config.BabyDays; Core.push(p); return true
end
function So.adopt(p)
	local c = Core.char(p); if not c or #c.kids >= Config.MaxKids then return false end
	if not Core.spend(p, 3000) then return false end
	table.insert(c.kids, { name = Sim.randomName(), stage = 3, ageDays = 0, traits = { Config.Traits[math.random(#Config.Traits)].key } })
	Core.notify(p, "babyBorn", "green", c.kids[#c.kids].name); Sim.checkAspiration(p); Core.push(p); return true
end
function So.adoptPet(p, key)
	local c = Core.char(p); if not c or c.pet then return false end
	local pc; for _, x in ipairs(Config.Pets) do if x.key == key then pc = x end end
	if not pc then return false end
	if not Core.spend(p, pc.price) then return false end
	c.pet = { key = key, name = key, fed = os.time() }; Sim.addMoodlet(p, "Happy", 30, 900); Core.push(p); return true
end
function So.divorce(p)
	local c = Core.char(p); if not c or not c.married then return false end
	local r = So.relOf(c, c.spouse); r.ex = true; r.r = 0; r.f = math.max(-50, r.f - 40)
	local other = So.playerOf(c.spouse)
	c.married = false; c.spouse = nil; Core.notify(p, "divorced", "red"); Sim.addMoodlet(p, "Sad", 50, 1800)
	if other then local oc = Core.char(other); if oc then oc.married = false; oc.spouse = nil; Core.notify(other, "divorced", "red"); Core.push(other) end end
	Core.push(p); return true
end
function So.playWithKid(p, i)
	local c = Core.char(p); local k = c and c.kids[i]; if not k then return end
	c.needs.fun = math.min(100, c.needs.fun + 15); c.needs.social = math.min(100, c.needs.social + 15); k.bond = (k.bond or 0) + 5
	Sim.addMoodlet(p, "Happy", 15, 400); Core.push(p)
end
-- ===== NPC ชาวเมืองในสวน =====
function So.spawnNpcs()
	if not Map.buildings.Park then return end
	local folder = Instance.new("Folder"); folder.Name = "Citizens"; folder.Parent = workspace
	for i, name in ipairs(Config.Npcs) do
		local npc = Core.spawnNpc(i, name)
		if npc then
			local a = (i / #Config.Npcs) * math.pi * 2
			local home = Map.buildings.Park.pos + Vector3.new(math.cos(a) * 14, 3, math.sin(a) * 12)
			npc:PivotTo(CFrame.new(home)); npc.Parent = folder
			local hum = npc:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayName = name; hum.WalkSpeed = 6 end
			local pp = Instance.new("ProximityPrompt"); pp.ActionText = "Talk"; pp.ObjectText = name; pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false; pp.Parent = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
			pp:SetAttribute("Action", "talk")
			pp.Triggered:Connect(function(who) Remotes.Social:FireClient(who, "open", name, So.status(Core.char(who) or { rel = {} }, name)) end)
			So.npcs[name] = npc
			task.spawn(function()
				while npc.Parent do
					task.wait(math.random(5, 12))
					local h = npc:FindFirstChildOfClass("Humanoid")
					if h and h.Health > 0 then h:MoveTo(home + Vector3.new(math.random(-10, 10), 0, math.random(-8, 8))) end
				end
			end)
		end
	end
end
-- ให้ผู้เล่นคุยกับผู้เล่นด้วยกัน: prompt บนตัวละคร
function So.attachPlayerPrompt(p)
	if not Core.isReal(p) then return end
	p.CharacterAdded:Connect(function(ch)
		local hrp = ch:WaitForChild("HumanoidRootPart", 10); if not hrp then return end
		local pp = Instance.new("ProximityPrompt"); pp.ActionText = "Talk"; pp.ObjectText = p.DisplayName; pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false; pp.Parent = hrp
		pp:SetAttribute("Action", "talk")
		pp.Triggered:Connect(function(who) if who ~= p then Remotes.Social:FireClient(who, "open", "u" .. p.UserId, So.status(Core.char(who) or { rel = {} }, "u" .. p.UserId), p.DisplayName) end end)
	end)
end
return So
