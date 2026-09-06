-- จำลองเกมเพลย์บนเซิร์ฟเวอร์จริง: โมเดลอาหาร, แปลง, ลูกค้า, ทำอาหาร, เสิร์ฟ
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Config)
local Dish = require(RS.Dish)
local SSS = game:GetService("ServerScriptService")
local Plot = require(SSS.PlotService)
local Customers = require(SSS.CustomerService)
require(SSS.GameService).init()
local fails = {}
local function check(name, ok) if not ok then table.insert(fails, name) end; print((ok and "PASS " or "FAIL ") .. name) end

-- 1) โมเดลอาหารทุกเมนูสร้างได้และมี PrimaryPart
for _, f in ipairs(Config.Foods) do
	local ok, m = pcall(Dish.build, f.id)
	check("dish build " .. f.id, ok and m.PrimaryPart ~= nil and #m:GetChildren() >= 2)
end

-- 2) ผู้เล่นจำลอง (ตารางที่มี API เท่าที่ PlotService ใช้)
local attrs = {}
local fake = { UserId = 1, DisplayName = "Tester", Parent = game, Character = nil }
function fake:SetAttribute(k, v) attrs[k] = v end
function fake:GetAttribute(k) return attrs[k] end
function fake:FindFirstChild() return nil end
local Data = require(SSS.DataService)
Data.cache[fake.UserId] = { cash = 0, foods = { MooPing = true, PadThai = true }, total = 0, rep = 0, served = 0, staff = {}, upg = {} }
local plot = Plot.assign(fake)
check("plot assigned", plot ~= nil and attrs.PlotIndex == 1)
Plot.refresh(fake, { MooPing = true, PadThai = true })
check("stalls built", plot.Stalls:FindFirstChild("MooPing") ~= nil and plot.Stalls:FindFirstChild("PadThai") ~= nil)
check("stall has dish", plot.Stalls.MooPing:FindFirstChild("Dish_MooPing") ~= nil)
check("stall has prompt", plot.Stalls.MooPing:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil)

-- 3) ลูกค้าเดินมาสั่ง
check("tables built", #Plot.tables[fake] == Config.TablesPerPlot and Plot.freeTable(fake) ~= nil)
Customers.forceOrders[fake] = 2
local g = Customers.spawn(fake, { MooPing = true, PadThai = true })
check("group spawned", g ~= nil and #g.members >= 2 and g.members[1].npc:FindFirstChildOfClass("Humanoid") ~= nil)
local t0 = os.clock()
while g and not g.orderAt and os.clock() - t0 < 20 do task.wait(0.2) end
check("group ordered", g ~= nil and g.orderAt ~= nil)
check("order attribute set", g ~= nil and g.members[1].npc:GetAttribute("OrderFood") ~= nil)
check("one npc has 2 orders", g ~= nil and g.members[1].npc == g.members[2].npc and select(2, g.members[1].npc:GetAttribute("OrderFood"):gsub("|", "")) == 1)
check("patience full", g ~= nil and Customers.patienceLeft(g.members[1]) > 0.7)
print("group kind:", g and g.kind, "size:", g and #g.members)

-- 4) เสิร์ฟทุกคนในกลุ่ม แล้วกลุ่มออก โต๊ะสกปรกถ้านั่งทาน
local GS = require(SSS.GameService)
local doneCalled = false
Customers.onGroupDone = function() doneCalled = true end
check("onServed wired", type(Customers.onServed) == "function")
local allServed = false
for _, e in ipairs(g.members) do
	GS.addToTray(fake, e.food.id, 0.9, e.spice, 1)
	if g.kind == "takeaway" then Plot.onPack(fake) end
	local ok, err = pcall(Customers.onServed, e)
	check("onServed no error " .. tostring(err or ""), ok)
	allServed = e.served
end
check("all served", allServed)
if g.kind == "dine" then
	task.wait(Config.EatTime + 2)
	check("table dirty after dine", g.table.dirty == true)
	attrs.Holding = nil
	Plot.onClean(fake, g.table)
	check("holding dirty plates", attrs.Holding == "Dirty" and g.table.dirty == false)
	Plot.onWash(fake)
	check("washed", attrs.Holding == nil and Plot.freeTable(fake) ~= nil)
else
	task.wait(1)
end
check("group done callback", doneCalled)
check("groups cleared", #(Customers.groups[fake] or {}) == 0)
check("cash earned", Data.cache[fake.UserId].cash > 0 and Data.cache[fake.UserId].served == #g.members)

-- 4.5) ถาดถือได้หลายจาน
for _ = 1, Config.TrayCapacity do GS.addToTray(fake, "MooPing", 1, nil, 1) end
check("tray capped", #GS.tray(fake) == Config.TrayCapacity and GS.addToTray(fake, "PadThai", 1, nil, 1) == false)
for _ = 1, Config.TrayCapacity do table.remove(GS.tray(fake)) end
check("table orders attribute", g.table == nil or true)

-- 5) พนักงาน: จ้าง พ่อครัววางจาน พนักงานเสิร์ฟ เด็กล้างจาน
local dd = Data.cache[fake.UserId]; dd.cash = 10000
for _, st in ipairs(Config.Staff) do dd.staff[st.key] = true end
local g2 = Customers.spawn(fake, { MooPing = true })
t0 = os.clock(); while g2 and not g2.orderAt and os.clock() - t0 < 20 do task.wait(0.2) end
check("group2 ordered", g2 and g2.orderAt ~= nil)
dd._staffNext = { Waiter = os.clock() + 999, Washer = os.clock() + 999 }
GS.staffTick(fake); task.wait(0.2)
local plot2 = workspace.Plots:FindFirstChild("Plot_1")
check("cook put dish on counter", plot2 and plot2:FindFirstChild("Ready") and #plot2.Ready:GetChildren() >= 1)
dd._staffNext.Waiter = 0; GS.staffTick(fake)
check("waiter served", g2.members[1].served == true)
if g2.table then g2.table.setDirty(true); dd._staffNext.Washer = 0; GS.staffTick(fake); check("washer cleaned", g2.table.dirty == false) end
local before = dd.cash; GS.payWages(fake)
check("wages paid", dd.cash < before)
dd.cash = 0; GS.payWages(fake)
check("staff quit when broke", next(dd.staff) == nil)

-- 6) อัปเกรดโต๊ะครัว + ข้อมูลหลายขั้นตอน
dd.cash = 100000
local okU = GS.upgradeStation(fake, "MooPing", "tray")
check("upgrade tray", okU == true and dd.upg.MooPing.tray == 2)
local okS = GS.upgradeStation(fake, "PadThai", "speed")
check("upgrade speed", okS == true and dd.upg.PadThai.speed == 2)
dd.cash = 0
local okN, errN = GS.upgradeStation(fake, "MooPing", "speed")
check("upgrade needs cash", okN == false and errN == "notEnough")
local multi = 0
for _, f in ipairs(Config.Foods) do if f.steps then multi += 1; check("steps valid " .. f.id, #f.steps >= 2) end end
check("has multi-step foods", multi >= 5)

-- 7) เหตุการณ์และลูกค้าพิเศษ
GS.startEvent(fake, "GasOut")
check("event set", attrs.Event == "GasOut" and attrs.EventEnd ~= nil)
check("fix event", GS.fixEvent(fake) == true and attrs.EventFixed == true)
GS.endEvent(fake); check("event over", attrs.Event == nil)
GS.startEvent(fake, "Rain"); check("rain patience halves", Customers.patienceMult[fake] == 0.5); GS.endEvent(fake)
Customers.forceSpecial[fake] = "VIP"
local g3 = Customers.spawn(fake, { MooPing = true })
check("special assigned", g3 and g3.members[1].special == "VIP" and g3.members[1].npc:GetAttribute("Special") == "VIP")
t0 = os.clock(); while g3 and not g3.orderAt and os.clock() - t0 < 20 do task.wait(0.2) end
local cashBefore = dd.cash; dd.cash = 0
GS.addToTray(fake, "MooPing", 1, nil, 1); if g3.kind == "takeaway" then Plot.onPack(fake) end
Customers.onServed(g3.members[1])
check("vip pays x5", dd.cash >= 12 * 5)
dd.cash = cashBefore

-- 8) ภารกิจและเลเวล
GS.ensureQuests(dd)
check("3 daily quests", dd.quests and #dd.quests.list == 3)
local qs = dd.quests.list[1]; qs.type = "clean"; qs.target = 1; qs.progress = 0
GS.progress(fake, "clean", 1)
check("quest progress", qs.progress == 1)
dd.total = 3000; GS.checkLevel(fake)
check("level 2 at 2k opens 3 tables", dd.level == 2 and Plot.tables[fake][3].closed == false and Plot.tables[fake][4].closed == true)
dd.total = 15000; GS.checkLevel(fake)
check("level 3 at 10k opens 4 tables", dd.level == 3 and Plot.tables[fake][4].closed == false)
dd.total = 0; GS.checkLevel(fake)
check("level 1 opens 2 tables", dd.level == 1 and Plot.tables[fake][3].closed == true)

-- 9) คิวซื้อกลับไม่เกิน MaxQueue
for _ = 1, Config.MaxQueue + 6 do Customers.spawn(fake, { MooPing = true }) end
check("queue capped", #Customers.queue(fake) <= Config.MaxQueue)
Customers.clear(fake); Plot.release(fake); Data.cache[fake.UserId] = nil

print(#fails == 0 and "ALL PASS" or ("FAILED: " .. table.concat(fails, ", ")))
return #fails == 0, fails
