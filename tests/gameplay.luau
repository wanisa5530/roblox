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
Data.cache[fake.UserId] = { cash = 0, foods = { MooPing = true, PadThai = true }, total = 0, rep = 0, served = 0 }
local plot = Plot.assign(fake)
check("plot assigned", plot ~= nil and attrs.PlotIndex == 1)
Plot.refresh(fake, { MooPing = true, PadThai = true })
check("stalls built", plot.Stalls:FindFirstChild("MooPing") ~= nil and plot.Stalls:FindFirstChild("PadThai") ~= nil)
check("stall has dish", plot.Stalls.MooPing:FindFirstChild("Dish_MooPing") ~= nil)
check("stall has prompt", plot.Stalls.MooPing:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil)

-- 3) ลูกค้าเดินมาสั่ง
check("tables built", #Plot.tables[fake] == Config.TablesPerPlot and Plot.freeTable(fake) ~= nil)
local g = Customers.spawn(fake, { MooPing = true, PadThai = true })
check("group spawned", g ~= nil and #g.members >= 1 and g.members[1].npc:FindFirstChildOfClass("Humanoid") ~= nil)
local t0 = os.clock()
while g and not g.orderAt and os.clock() - t0 < 20 do task.wait(0.2) end
check("group ordered", g ~= nil and g.orderAt ~= nil)
check("order attribute set", g ~= nil and g.members[1].npc:GetAttribute("OrderFood") ~= nil)
check("patience full", g ~= nil and Customers.patienceLeft(g.members[1]) > 0.7)
print("group kind:", g and g.kind, "size:", g and #g.members)

-- 4) เสิร์ฟทุกคนในกลุ่ม แล้วกลุ่มออก โต๊ะสกปรกถ้านั่งทาน
local doneCalled = false
Customers.onGroupDone = function() doneCalled = true end
check("onServed wired", type(Customers.onServed) == "function")
local allServed = false
for _, e in ipairs(g.members) do
	attrs.Holding = e.food.id; attrs.HoldCount = 1; attrs.Bagged = (g.kind == "takeaway")
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

-- 5) พนักงาน: จ้าง พ่อครัววางจาน พนักงานเสิร์ฟ เด็กล้างจาน
local GS = require(SSS.GameService)
local dd = Data.cache[fake.UserId]; dd.cash = 10000
for _, st in ipairs(Config.Staff) do dd.staff[st.key] = true end
local g2 = Customers.spawn(fake, { MooPing = true })
t0 = os.clock(); while g2 and not g2.orderAt and os.clock() - t0 < 20 do task.wait(0.2) end
check("group2 ordered", g2 and g2.orderAt ~= nil)
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

-- 6) คิวซื้อกลับไม่เกิน MaxQueue
for _ = 1, Config.MaxQueue + 6 do Customers.spawn(fake, { MooPing = true }) end
check("queue capped", #Customers.queue(fake) <= Config.MaxQueue)
Customers.clear(fake); Plot.release(fake); Data.cache[fake.UserId] = nil

print(#fails == 0 and "ALL PASS" or ("FAILED: " .. table.concat(fails, ", ")))
return #fails == 0, fails
