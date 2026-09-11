-- อาชีพ โรงเรียน มหาวิทยาลัย: กะงาน = มินิเกม 3 รอบ ในอาคาร
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Map = require(script.Parent.MapService)
local Sim = require(script.Parent.SimService)
local Time = require(script.Parent.TimeService)
local Cr = { shift = {} }   -- shift[player] = {kind, round, score, career}
function Cr.apply(p, key)
	local c = Core.char(p); if not c then return false end
	if not Core.isAdult(c) and key ~= "Barista" then return false end
	if c.stage < 4 then return false end
	local cc = Core.career(key); if not cc then return false end
	c.career = key; c.careerLevel = 1; c.perf = 0; Core.notify(p, "applyJob", "green"); Core.push(p); return true
end
function Cr.quit(p) local c = Core.char(p); if c then c.career = nil; c.careerLevel = 0; c.perf = 0; Core.push(p) end end
local function inHours(cc, hour) return hour >= cc.hours[1] and hour < cc.hours[2] end
-- ผู้เล่นกดที่ประตูอาคาร: เริ่มกะ
function Cr.startShift(p, kind)
	local c = Core.char(p); if not c or Cr.shift[p] then return false end
	local hour = Time.now().hour
	if kind == "work" then
		local cc = Core.career(c.career); if not cc then return false end
		if not inHours(cc, hour) then return false, "notTime" end
		if c.shiftDay == Data.get(p).dayCount then return false, "done" end
		Cr.shift[p] = { kind = "work", round = 0, score = 0, cc = cc }
	elseif kind == "school" then
		if c.stage < 3 or c.stage > 4 then return false end
		if not (hour >= Config.SchoolHours[1] and hour < Config.SchoolHours[2]) then return false, "notTime" end
		if c.shiftDay == Data.get(p).dayCount then return false, "done" end
		Cr.shift[p] = { kind = "school", round = 0, score = 0 }
	elseif kind == "uni" then
		if not c.uni then return false end
		Cr.shift[p] = { kind = "uni", round = 0, score = 0 }
	else return false end
	if Core.isReal(p) and p.Character then Core.wearUniform(p.Character, kind == "work" and c.career or "Student") end
	Cr.nextRound(p)
	return true
end
function Cr.nextRound(p)
	local s = Cr.shift[p]; if not s then return end
	s.round += 1
	if s.round > Config.ShiftRounds then Cr.finishShift(p); return end
	local c = Core.char(p)
	local games = { "timing", "mash", "memory" }
	local g = games[(s.round - 1) % 3 + 1]
	local skillLvl = s.cc and (c.skills[s.cc.skill] or 0) or (c.skills.logic or 0)
	local diff = math.max(0.4, 1 - skillLvl * 0.05)
	if Core.isReal(p) then Remotes.StartMinigame:FireClient(p, g, diff, s.round, Config.ShiftRounds) end
end
function Cr.onResult(p, quality)  -- quality 0..1
	local s = Cr.shift[p]; if not s then return end
	s.score += math.clamp(tonumber(quality) or 0, 0, 1)
	Cr.nextRound(p)
end
function Cr.finishShift(p)
	local s = Cr.shift[p]; Cr.shift[p] = nil; if not s then return end
	local c, d = Core.char(p); if not c then return end
	if Core.isReal(p) and p.Character then task.delay(1, Core.removeUniform, p.Character) end
	local q = s.score / Config.ShiftRounds
	local moodMult = (c.mood == "Happy" or c.mood == "Confident" or c.mood == "Focused") and 1.2 or ((c.mood == "Sad" or c.mood == "Sick" or c.mood == "Stressed") and 0.7 or 1)
	c.shiftDay = d.dayCount
	if s.kind == "work" then
		local pay = math.floor(s.cc.pay[math.clamp(c.careerLevel, 1, #s.cc.pay)] * (0.6 + 0.6 * q) * moodMult)
		Core.addCash(p, pay); c.shifts += 1
		c.perf += math.floor(q * 50 * moodMult) - 10
		Core.notify(p, "shiftDone", "green", pay)
		Sim.addXp(p, s.cc.skill, 30 * q); Sim.progress(p, "work", 1); Sim.progress(p, "money", pay)
		c.needs.energy = math.max(0, c.needs.energy - 20); c.needs.fun = math.max(0, c.needs.fun - 15); c.needs.hunger = math.max(0, c.needs.hunger - 15)
		if c.perf >= Config.PromotePerf then
			local nextLvl = c.careerLevel + 1
			if nextLvl <= #s.cc.pay then
				if s.cc.degreeAt > 0 and nextLvl >= s.cc.degreeAt and not c.degree then Core.notify(p, "needDegree", "yellow", s.cc.degreeAt); c.perf = Config.PromotePerf
				else c.careerLevel = nextLvl; c.perf = 0; Core.notify(p, "promoted", "green", nextLvl); Sim.addMoodlet(p, "Confident", 40, 900) end
			end
		elseif c.perf <= -40 then c.career = nil; c.careerLevel = 0; c.perf = 0; Core.notify(p, "fired", "red"); Sim.addMoodlet(p, "Sad", 40, 900) end
		Sim.checkAspiration(p)
	elseif s.kind == "school" then
		local g = c.school.grade
		if q > 0.7 then g = math.min(#Config.Grades, g + 1) elseif q < 0.35 then g = math.max(1, g - 1) end
		c.school.grade = g
		Core.notify(p, "schoolDone", "green", Config.Grades[g])
		Sim.addXp(p, "logic", 25 * q); Sim.addXp(p, "charisma", 10)
		c.needs.energy = math.max(0, c.needs.energy - 15); c.needs.social = math.min(100, c.needs.social + 20)
		Sim.checkAspiration(p)
	elseif s.kind == "uni" then
		c.uni.days += 1; c.uni.score = (c.uni.score or 0) + q
		Sim.addXp(p, "logic", 30 * q)
		if c.uni.days >= Config.University.days then
			if c.uni.score / Config.University.days >= 0.4 then c.degree = c.uni.faculty; Core.notify(p, "graduated", "green", Core.T(p, c.uni.faculty)); Sim.addMoodlet(p, "Confident", 50, 1200) end
			c.uni = nil; Sim.checkAspiration(p)
		end
	end
	Core.push(p)
end
function Cr.enroll(p, faculty)
	local c = Core.char(p); if not c or c.uni or c.degree or c.stage < 4 then return false end
	local fc; for _, f in ipairs(Config.University.faculties) do if f.key == faculty then fc = f end end
	if not fc then return false end
	if not Core.spend(p, Config.University.tuition) then return false end
	c.uni = { faculty = faculty, days = 0, score = 0 }
	Core.notify(p, "enrolled", "green", Core.T(p, faculty)); Core.push(p); return true
end
-- ขาดงาน: ตรวจตอนเลยเวลาเลิกงานแล้วยังไม่ทำกะ
function Cr.checkMissed(p)
	local c, d = Core.char(p); if not c or not c.career then return end
	local cc = Core.career(c.career); local n = Time.now()
	if n.hour >= cc.hours[2] and c.shiftDay ~= d.dayCount and c.missedDay ~= d.dayCount then
		c.missedDay = d.dayCount; c.perf -= 20; c.missed += 1; Core.notify(p, "late", "red")
		if c.perf <= -40 then c.career = nil; c.careerLevel = 0; c.perf = 0; Core.notify(p, "fired", "red") end
		Core.push(p)
	end
end
-- แจ้งเตือนถึงเวลางาน/เรียน (ครั้งเดียวต่อวัน)
function Cr.remind(p)
	local c, d = Core.char(p); if not c then return end
	local n = Time.now()
	if c.career and c.remindDay ~= d.dayCount then
		local cc = Core.career(c.career)
		if inHours(cc, n.hour) then c.remindDay = d.dayCount; Core.notify(p, "workNow", "yellow", Core.T(p, cc.building)) end
	end
end
return Cr
