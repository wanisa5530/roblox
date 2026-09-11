-- หัวใจของชีวิต: ความต้องการ อารมณ์ ทักษะ อายุ โรค ความตาย มรดก ความฝัน เป้าหมายรายวัน เหตุการณ์สุ่ม
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Home = require(script.Parent.HomeService)
local Time = require(script.Parent.TimeService)
local S = {}
local FIRST = { "Anong", "Beam", "Chai", "Dao", "Earn", "Fon", "Gift", "Ice", "June", "Kwan", "Mint", "Nam", "Oat", "Pond", "Tan", "View", "Yim" }
function S.randomName() return FIRST[math.random(#FIRST)] end

-- ===== ทักษะ =====
function S.addXp(p, skill, xp)
	local c = Core.char(p); if not c then return end
	if c.stage < 3 then return end
	c.skillXp = c.skillXp or {}
	local lvl = c.skills[skill] or 0
	if lvl >= Config.SkillMax then return end
	c.skillXp[skill] = (c.skillXp[skill] or 0) + xp
	if c.skillXp[skill] >= Config.SkillXpPerLevel * (1 + lvl * 0.3) then
		c.skillXp[skill] = 0; c.skills[skill] = lvl + 1
		Core.notify(p, "skillUp", "green", Core.T(p, skill), lvl + 1)
		S.progress(p, "skill", 1); S.checkAspiration(p); Core.push(p)
	end
end
Home.onSkillXp = S.addXp

-- ===== อารมณ์ =====
function S.addMoodlet(p, emotion, strength, seconds)
	local c = Core.char(p); if not c then return end
	table.insert(c.moodlets, { e = emotion, s = strength, until_ = os.clock() + seconds })
end
local function computeMood(c)
	local score = {}
	local now = os.clock()
	for i = #c.moodlets, 1, -1 do local m = c.moodlets[i]; if m.until_ < now then table.remove(c.moodlets, i) else score[m.e] = (score[m.e] or 0) + m.s end end
	for _, n in ipairs(Config.Needs) do
		local v = c.needs[n.key]
		if v < n.crit then
			local e = ({ hunger = "Angry", energy = "Stressed", bladder = "Stressed", hygiene = "Embarrassed", fun = "Bored", social = "Sad", environment = "Stressed", health = "Sick" })[n.key]
			score[e] = (score[e] or 0) + (n.crit - v)
		end
	end
	if c.illness then score.Sick = (score.Sick or 0) + 30 end
	local base = Core.trait(c, "Cheerful") and 8 or 3
	local best, bestV = "Happy", base
	local avg = 0; for _, n in ipairs(Config.Needs) do avg += c.needs[n.key] end; avg /= #Config.Needs
	if avg > 75 then bestV = base + 15 end
	for e, v in pairs(score) do if v > bestV then best, bestV = e, v end end
	return best
end

-- ===== tick ทุกวินาที =====
function S.tick(p, dt)
	local c = Core.char(p); if not c then return end
	local a = Home.active[p]
	local season = Time.now().season
	for _, n in ipairs(Config.Needs) do
		local decay = n.decay * dt
		for _, t in ipairs(c.traits) do local tc = Core.traitCfg(t); if tc and tc.need == n.key then decay *= tc.mult end end
		if season == "Summer" and n.key == "energy" then decay *= 1.2 end
		if season == "Rainy" and n.key == "fun" then decay *= 1.3 end
		if c.stage <= 2 then decay *= 0.5 end
		if a and a.cfg.need == n.key then decay = 0 end
		if a and a.act == "sleep" then decay *= 0.4 end
		if n.key == "environment" then c.needs.environment = math.max(0, math.min(c.envBase or 50, c.needs.environment - decay * 0.5 + (a and a.act == "clean" and 5 * dt or 0)))
		elseif n.key ~= "health" then c.needs[n.key] = math.max(0, c.needs[n.key] - decay) end
	end
	-- ผลเสียจากความต้องการต่ำ
	if c.needs.hunger <= 0 then c.needs.health = math.max(0, c.needs.health - 0.15 * dt); if math.random() < 0.01 then Core.notify(p, "starving", "red") end end
	if c.needs.energy <= 0 and not (a and a.act == "sleep") then Core.notify(p, "collapsed", "red"); c.needs.energy = 30; c.needs.health = math.max(0, c.needs.health - 5); S.addMoodlet(p, "Stressed", 20, 300) end
	if c.needs.bladder <= 0 then c.needs.bladder = 60; c.needs.hygiene = 0; Core.notify(p, "wetSelf", "red"); S.addMoodlet(p, "Embarrassed", 40, 400) end
	if c.needs.hygiene < 10 and math.random() < 0.003 then Core.notify(p, "stinky", "yellow") end
	if c.needs.social < 10 and math.random() < 0.003 then Core.notify(p, "lonely", "yellow") end
	-- โรค: กัดสุขภาพ
	if c.illness then
		local ic; for _, i in ipairs(Config.Illnesses) do if i.key == c.illness.key then ic = i end end
		if ic then c.needs.health = math.max(0, c.needs.health - ic.healthHit / 1440 * dt * (c.illness.days > ic.days and 3 or 1)) end
	else
		c.needs.health = math.min(100, c.needs.health + 0.01 * dt)
	end
	if c.needs.health <= 0 then S.die(p, "deathIllness"); return end
	if c.needs.health < 25 and math.random() < 0.003 then Core.notify(p, "dying", "red") end
	Home.tick(p, c, dt)
	c.mood = computeMood(c)
	if Core.isReal(p) then p:SetAttribute("Mood", c.mood) end
	-- เป้าหมาย "รักษาความต้องการ"
	local allOk = true; for _, n in ipairs(Config.Needs) do if c.needs[n.key] < 50 then allOk = false end end
	c.needsOkTime = allOk and (c.needsOkTime or 0) + dt or 0
	if c.needsOkTime > Config.MinutesPerDay * 60 then S.progress(p, "needs", 1); c.needsOkTime = 0 end
end

-- ===== วันใหม่ =====
function S.newDay(p)
	local c, d = Core.char(p); if not c then return end
	c.ageDays += 1
	local st = Core.stage(c)
	if c.ageDays >= st.days then
		if c.stage < #Config.Stages then
			c.stage += 1; c.ageDays = 0
			Core.notify(p, "grewUp", "green", c.name, Core.T(p, Config.Stages[c.stage].key))
			if c.stage == 7 and math.random() < 0.5 then S.makeSick(p, "Chronic") end
			S.applyScale(p)
		elseif math.random() < Config.ElderDeathChancePerDay then S.die(p, "deathOld"); return end
	end
	-- ลูกโตขึ้น
	for _, k in ipairs(c.kids) do
		k.ageDays = (k.ageDays or 0) + 1
		local ks = Config.Stages[k.stage or 1]
		if k.ageDays >= ks.days and (k.stage or 1) < 5 then k.stage = (k.stage or 1) + 1; k.ageDays = 0; Core.notify(p, "grewUp", "green", k.name, Core.T(p, Config.Stages[k.stage].key)) end
	end
	if c.pregnantUntil and d.dayCount >= c.pregnantUntil then S.birth(p) end
	-- โรค: นับวัน / ติดโรคใหม่
	if c.illness then
		c.illness.days += 1
		local ic; for _, i in ipairs(Config.Illnesses) do if i.key == c.illness.key then ic = i end end
		if ic and ic.key ~= "Chronic" and c.illness.days > ic.days and c.needs.energy > 60 then c.illness = nil; Core.notify(p, "cured", "green") end
	else
		local season = Time.now().season
		for _, ic in ipairs(Config.Illnesses) do
			local ch = ic.chance
			if season == "Rainy" or season == "Winter" then ch *= 2 end
			if c.needs.hygiene < 30 then ch *= 1.5 end
			if c.needs.health < 50 then ch *= 1.5 end
			if ch > 0 and math.random() < ch then S.makeSick(p, ic.key); break end
		end
		if c.mood == "Stressed" and math.random() < 0.15 then S.makeSick(p, "Burnout") end
	end
	-- ความสัมพันธ์ลดถ้าไม่คุย
	for id, r in pairs(c.rel) do if r.day ~= d.dayCount then r.f = math.max(0, r.f - Config.NpcDailyDecay) end end
	Home.dailyBills(p)
	S.randomEvent(p)
	if Core.ownsPass(p, "VIP") then Core.addCash(p, Config.VIPDaily) end
	local fest = Time.festival()
	if fest and d.lastFestival ~= fest.key .. d.dayCount // fest.len then d.lastFestival = fest.key .. d.dayCount // fest.len; Core.addCash(p, fest.gift); Core.notify(p, "festival", "green", Core.T(p, fest.key), fest.gift) end
	c.socialToday = 0
	S.ensureQuests(p, true)
	Core.push(p)
end
function S.applyScale(p)
	local c = Core.char(p); if not c or not Core.isReal(p) then return end
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	if hum then local s = Config.Stages[c.stage].scale; for _, n in ipairs({ "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }) do local v = hum:FindFirstChild(n); if v then v.Value = s end end end
	p:SetAttribute("Stage", Config.Stages[c.stage].key)
end
-- ===== โรค =====
function S.makeSick(p, key)
	local c = Core.char(p); if not c or c.illness then return end
	c.illness = { key = key, days = 0 }
	Core.notify(p, "sick", "red", Core.T(p, key)); S.addMoodlet(p, "Sick", 30, 600); Core.push(p)
end
Home.onSick = S.makeSick
function S.treat(p)
	local c, d = Core.char(p); if not c or not c.illness then return false end
	local ic; for _, i in ipairs(Config.Illnesses) do if i.key == c.illness.key then ic = i end end
	local cost = ic.cure; if d.dayCount < (c.insuranceUntil or 0) then cost = math.floor(cost * Config.Insurance.discount) end
	if not Core.spend(p, cost) then return false end
	c.illness = nil; c.needs.health = math.min(100, c.needs.health + 30); Core.notify(p, "cured", "green"); Core.push(p); return true
end
function S.buyInsurance(p)
	local c, d = Core.char(p); if not c then return false end
	if not Core.spend(p, Config.Insurance.cost) then return false end
	c.insuranceUntil = d.dayCount + 7; Core.push(p); return true
end
Home.onFireDamage = function(p, hasAlarm)
	local c = Core.char(p); if not c then return end
	if hasAlarm then c.needs.health = math.max(0, c.needs.health - 20); S.addMoodlet(p, "Scared", 30, 600)
	else
		if #c.furniture > 0 then table.remove(c.furniture, math.random(#c.furniture)) end
		Home.rebuild(p)
		if math.random() < 0.3 then S.die(p, "deathFire") else c.needs.health = math.max(1, c.needs.health - 50); S.addMoodlet(p, "Scared", 50, 900) end
	end
end
-- ===== ความตาย & มรดก =====
function S.die(p, cause)
	local c, d = Core.char(p); if not c or c.dead then return end
	c.dead = true; c.deathCause = cause
	Home.stopAction(p)
	Core.notify(p, "died", "red", c.name, Core.T(p, cause))
	table.insert(d.legacy, { name = c.name, generation = c.generation, cause = cause, career = c.career, level = c.careerLevel, money = d.cash })
	if Core.isReal(p) then p:SetAttribute("Ghost", true); Remotes.Family:FireClient(p, "died", c.kids, cause) end
	if S.onDeath then S.onDeath(p) end
	Core.push(p)
end
-- เลือกทายาท (ลูกคนใด) หรือเริ่มตระกูลใหม่
function S.chooseHeir(p, kidIndex)
	local c, d = Core.char(p); if not c or not c.dead then return false end
	local kid = c.kids[kidIndex]
	local inherit = math.floor(d.cash * 0.7)
	local newC = Data.newCharacter(kid and kid.name or S.randomName(), kid and kid.traits or c.traits, c.aspiration, kid and (c.generation + 1) or 1)
	if kid then
		newC.stage = math.max(kid.stage or 3, 3); newC.furniture = c.furniture; newC.lot = c.lot; newC.lotIndex = c.lotIndex; newC.business = c.business; newC.degree = nil
		d.cash = inherit; Core.notify(p, "inherit", "green", inherit)
	else
		newC.furniture = {}; newC.lot = "Apartment"; d.cash = Config.StartingCash
		Home.release(p)
	end
	d.char = newC
	if not kid then Home.assign(p) else Home.rebuild(p) end
	Core.notify(p, "newLife", "green", newC.name, newC.generation)
	if Core.isReal(p) then p:SetAttribute("Ghost", nil) end
	S.applyScale(p); S.checkAspiration(p); Core.push(p)
	return true
end
-- ===== ครอบครัว: คลอด =====
function S.birth(p)
	local c = Core.char(p); if not c then return end
	c.pregnantUntil = nil
	if #c.kids >= Config.MaxKids then return end
	local traits = {}
	for i = 1, 2 do local t = c.traits[math.random(#c.traits)]; if t then traits[#traits + 1] = t end end
	local kid = { name = S.randomName(), stage = 1, ageDays = 0, traits = traits }
	table.insert(c.kids, kid)
	Core.notify(p, "babyBorn", "green", kid.name); S.addMoodlet(p, "Happy", 40, 900)
	S.checkAspiration(p); Core.push(p)
end
-- ===== ความฝัน =====
function S.checkAspiration(p)
	local c, d = Core.char(p); if not c then return end
	local asp; for _, a in ipairs(Config.Aspirations) do if a.key == c.aspiration then asp = a end end
	if not asp or c.aspStep > #asp.milestones then return end
	local m = asp.milestones[c.aspStep]
	local t = m[1]; local ok = false
	if t == "money" then ok = d.cash >= m[2]
	elseif t == "married" then ok = c.married
	elseif t == "kids" then ok = #c.kids >= m[2]
	elseif t == "skill" then ok = (c.skills[m[2]] or 0) >= m[3]
	elseif t == "career" then ok = c.career == m[2] and c.careerLevel >= m[3]
	elseif t == "degree" then ok = c.degree ~= nil
	elseif t == "business" then ok = c.business ~= nil
	elseif t == "bizServed" then ok = (c.bizServed or 0) >= m[2]
	elseif t == "grade" then ok = c.school and Config.Grades[c.school.grade] == m[2]
	elseif t == "friends" then local n = 0; for _, r in pairs(c.rel) do if r.f >= Config.FriendAt then n += 1 end end; ok = n >= m[2]
	elseif t == "bestFriends" then local n = 0; for _, r in pairs(c.rel) do if r.f >= Config.BestFriendAt then n += 1 end end; ok = n >= m[2]
	elseif t == "generation" then ok = c.generation >= m[2] end
	if ok then
		c.aspStep += 1
		Core.addCash(p, asp.reward); Core.notify(p, "milestone", "green", asp.reward)
		if c.aspStep > #asp.milestones then Core.notify(p, "aspirationDone", "green"); Core.addCash(p, asp.reward * 3) end
		S.checkAspiration(p)
	end
end
-- ===== เป้าหมายรายวัน =====
local QUESTS = { { t = "skill", n = 2, reward = 400 }, { t = "social", n = 3, reward = 300 }, { t = "work", n = 1, reward = 500 }, { t = "needs", n = 1, reward = 600 }, { t = "money", n = 800, reward = 400 } }
function S.ensureQuests(p, reset)
	local c = Core.char(p); if not c then return end
	if c.quests and not reset then return end
	c.quests = {}
	local pool = table.clone(QUESTS)
	for i = 1, 3 do local q = table.remove(pool, math.random(#pool)); table.insert(c.quests, { t = q.t, n = q.n, reward = q.reward, prog = 0, done = false }) end
end
function S.progress(p, t, n)
	local c = Core.char(p); if not c or not c.quests then return end
	for _, q in ipairs(c.quests) do
		if q.t == t and not q.done then
			q.prog += n
			if q.prog >= q.n then q.done = true; Core.addCash(p, q.reward); Core.notify(p, "questDone", "green", q.reward) end
		end
	end
end
-- ===== เหตุการณ์สุ่ม =====
function S.randomEvent(p)
	local c, d = Core.char(p); if not c then return end
	for _, ev in ipairs(Config.RandomEvents) do
		if math.random() < ev.chance then
			if ev.needsJob and not c.career then continue end
			if ev.needsAlarm then local has = false; for _, it in ipairs(c.furniture) do if it.key == "SmokeAlarm" then has = true end end; if has then continue end end
			if ev.deadly then Core.notify(p, "eventMeteor", "red"); S.die(p, "deathMeteor"); return end
			if ev.money > 0 then Core.addCash(p, ev.money) else d.cash = math.max(0, d.cash + ev.money) end
			Core.notify(p, "event" .. ev.key, ev.money > 0 and "green" or "red", math.abs(ev.money))
			return
		end
	end
end
-- ===== รางวัลรายวัน =====
function S.claimDaily(p)
	local d = Data.get(p); if not d then return false end
	local today = math.floor(os.time() / 86400)
	if d.lastClaim == today then return false, "claimed" end
	d.streak = (d.lastClaim == today - 1) and math.min(d.streak + 1, #Config.DailyReward) or 1
	d.lastClaim = today
	local amt = Config.DailyReward[d.streak]; Core.addCash(p, amt); Core.push(p)
	return true, amt, d.streak
end
return S
