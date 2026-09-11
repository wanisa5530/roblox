-- จำลองชีวิตด้วยผู้เล่นปลอม: สร้างตัวละคร ความต้องการ เฟอร์นิเจอร์ ทักษะ งาน เรียน สังคม แต่งงาน ลูก ป่วย ตาย มรดก ธุรกิจ
local SSS = game:GetService("ServerScriptService")
local Config = require(game.ReplicatedStorage.Config)
local fails = {}
local function check(name, ok) print((ok and "PASS " or "FAIL ") .. name); if not ok then table.insert(fails, name) end end
local G = require(SSS.GameService).init()
local Data, Core, Home, Sim, Career, Social, Biz, Map = G.Data, G.Core, G.Home, G.Sim, G.Career, G.Social, G.Biz, G.Map
local function fake(id, name)
	local attrs = {}
	return { UserId = id, Name = name, DisplayName = name, Parent = workspace, SetAttribute = function(_, k, v) attrs[k] = v end, GetAttribute = function(_, k) return attrs[k] end, FindFirstChild = function() return nil end, Kick = function() end, Character = nil, CharacterAdded = { Connect = function() end } }
end
local p = fake(1, "Tester")
local d = Data.load(p)
check("map built", workspace:FindFirstChild("City") ~= nil and #Map.buildings > 0 or Map.buildings.Hospital ~= nil)
check("lots built", Map.lots[1] ~= nil and Map.lots.apt1 ~= nil)
-- สร้างตัวละคร
d.char = Data.newCharacter("Tester", { "Active", "Genius", "Frugal" }, "Wealth", 1)
local c = d.char
Home.assign(p); Sim.ensureQuests(p)
check("apartment assigned", c.lotIndex ~= nil and Map.lots[c.lotIndex].owner == p)
check("quests 3", c.quests and #c.quests == 3)
-- ความต้องการลด
c.needs.hunger = 50; Sim.tick(p, 60)
check("hunger decays", c.needs.hunger < 50)
-- ซื้อเฟอร์นิเจอร์และใช้
d.cash = 20000
check("buy bed", Home.buy(p, "BedCheap", 0, 0, 0))
check("buy fridge", Home.buy(p, "Fridge", 4, 0, 0))
check("buy stove", Home.buy(p, "Stove", 8, 0, 0))
check("buy toilet", Home.buy(p, "Toilet", -4, 0, 0))
check("furniture placed", #c.furniture == 4 + #Home.Starter.Apartment and #Map.lots[c.lotIndex].model.Furniture:GetChildren() == #c.furniture)
check("env updated", (c.envBase or 0) > 30)
check("lot full check", (function() for i = 1, 20 do Home.buy(p, "Plant", i, 2, 0) end; return #c.furniture <= 20 end)())
check("starter furnished", #Home.Starter.Apartment >= 10)
c.needs.energy = 10; Home.startAction(p, "BedCheap", 1, "sleep", Map.lots[c.lotIndex].model.Furniture:FindFirstChild("BedCheap"))
check("sleep active", Home.active[p] ~= nil)
Sim.tick(p, 30)
check("sleep restores energy", c.needs.energy > 10)
Home.stopAction(p)
-- ทักษะ
Sim.addXp(p, "cooking", 500)
check("skill up", (c.skills.cooking or 0) >= 1)
-- อารมณ์
c.needs.hunger = 5; Sim.tick(p, 1); check("mood angry when starving", c.mood == "Angry")
c.needs.hunger = 90; Sim.addMoodlet(p, "Inspired", 50, 60); Sim.tick(p, 1); check("moodlet inspired", c.mood == "Inspired")
-- อาชีพ + กะงาน
check("apply chef", Career.apply(p, "Chef"))
Career.shift[p] = { kind = "work", round = 0, score = 0, cc = Core.career("Chef") }
Career.nextRound(p); Career.onResult(p, 1); Career.onResult(p, 1); Career.onResult(p, 1)
check("shift paid", c.shifts == 1 and d.cash > 0 and c.perf > 0)
c.perf = 200; Career.shift[p] = { kind = "work", round = 0, score = 0, cc = Core.career("Chef") }; Career.nextRound(p); Career.onResult(p, 1); Career.onResult(p, 1); Career.onResult(p, 1)
check("promoted", c.careerLevel == 2)
-- มหาวิทยาลัย
d.cash = 20000
check("enroll", Career.enroll(p, "Engineering"))
for i = 1, Config.University.days do Career.shift[p] = { kind = "uni", round = 0, score = 0 }; Career.nextRound(p); Career.onResult(p, 1); Career.onResult(p, 1); Career.onResult(p, 1) end
check("graduated", c.degree == "Engineering")
-- โรงเรียน (วัยรุ่น)
c.stage = 4; Career.shift[p] = { kind = "school", round = 0, score = 0 }; Career.nextRound(p); Career.onResult(p, 1); Career.onResult(p, 1); Career.onResult(p, 1)
check("school grade up", c.school.grade >= 4)
c.stage = 5
-- สังคม + แต่งงาน + ลูก
for i = 1, 12 do Social.interact(p, "Pim", "Chat") end
check("friend", Social.status(c, "Pim") == "friend" or Social.status(c, "Pim") == "bestFriend")
c.rel.Pim.r = 95; d.cash = 10000
local okM = Social.interact(p, "Pim", "Propose")
check("married or refused", okM ~= nil)
if not c.married then c.rel.Pim.r = 95; for i = 1, 5 do if not c.married then Social.interact(p, "Pim", "Propose") end end end
check("married", c.married == true and c.spouse == "Pim")
check("try baby", Social.tryBaby(p) and c.pregnantUntil ~= nil)
d.dayCount = c.pregnantUntil; Sim.newDay(p)
check("baby born", #c.kids == 1)
check("adopt pet", Social.adoptPet(p, "Cat") and c.pet ~= nil)
-- โรค + รักษา
c.illness = nil; Sim.makeSick(p, "Flu"); check("sick", c.illness and c.illness.key == "Flu")
d.cash = 5000; check("treat", Sim.treat(p) and c.illness == nil)
-- ไฟไหม้: กดดับ
c.fire = nil; local stove = Map.lots[c.lotIndex].model.Furniture:FindFirstChild("Stove")
Home.startFire(p, stove); check("fire started", c.fire == true)
Home.putOutFire(p, stove); check("fire out", c.fire == nil)
-- บิล + วันใหม่ + อายุ
local cashBefore = d.cash; Home.dailyBills(p); check("bills paid", d.cash < cashBefore)
c.ageDays = Config.Stages[5].days; Sim.newDay(p); check("aged to Adult", c.stage == 6)
-- ความฝัน
d.cash = 60000; Sim.checkAspiration(p); check("aspiration progressed", c.aspStep >= 3)
-- ธุรกิจ
d.cash = 60000; check("buy cafe", Biz.buy(p) and c.business ~= nil)
Biz.spawnCustomer(); task.wait(0.5); local before = d.cash; Biz.serve(p); check("cafe serve pays", d.cash > before and c.bizServed == 1)
local p2 = fake(2, "Helper"); Data.load(p2); Data.get(p2).char = Data.newCharacter("Helper", {}, "Wealth", 1)
check("employee join", Biz.workHere(p2))
Biz.spawnCustomer(); task.wait(0.5); local b2 = Data.get(p2).cash; Biz.serve(p2); check("employee share", Data.get(p2).cash > b2)
-- ตาย + มรดก
Sim.die(p, "deathOld"); check("dead", c.dead == true and #d.legacy == 1)
check("heir", Sim.chooseHeir(p, 1) and d.char.generation == 2 and d.char ~= c)
check("heir keeps home", d.char.lotIndex == c.lotIndex and #d.char.furniture == #c.furniture)
-- เหตุการณ์สุ่ม / เทศกาล ไม่พัง
for i = 1, 5 do Sim.randomEvent(p) end; check("random events ok", true)
check("time", G.Time.now().hour >= 0 and G.Time.now().season ~= nil)
check("daily claim", (Sim.claimDaily(p)))
print(#fails == 0 and "ALL PASS" or ("FAILED: " .. table.concat(fails, ", ")))
return #fails == 0, fails
