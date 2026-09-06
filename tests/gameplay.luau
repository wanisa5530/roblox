-- จำลองเกมเพลย์บนเซิร์ฟเวอร์จริง: โมเดลอาหาร, แปลง, ลูกค้า, ทำอาหาร, เสิร์ฟ
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Config)
local Dish = require(RS.Dish)
local SSS = game:GetService("ServerScriptService")
local Plot = require(SSS.PlotService)
local Customers = require(SSS.CustomerService)
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
local plot = Plot.assign(fake)
check("plot assigned", plot ~= nil and attrs.PlotIndex == 1)
Plot.refresh(fake, { MooPing = true, PadThai = true })
check("stalls built", plot.Stalls:FindFirstChild("MooPing") ~= nil and plot.Stalls:FindFirstChild("PadThai") ~= nil)
check("stall has dish", plot.Stalls.MooPing:FindFirstChild("Dish_MooPing") ~= nil)
check("stall has prompt", plot.Stalls.MooPing:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil)

-- 3) ลูกค้าเดินมาสั่ง
local entry = Customers.spawn(fake, { MooPing = true, PadThai = true })
check("customer spawned", entry ~= nil and entry.npc ~= nil and entry.npc:FindFirstChildOfClass("Humanoid") ~= nil)
local t0 = os.clock()
while entry and not entry.orderAt and os.clock() - t0 < 15 do task.wait(0.2) end
check("customer reached queue and ordered", entry ~= nil and entry.orderAt ~= nil)
check("order bubble shown", entry ~= nil and entry.bubble ~= nil)
check("patience full", entry ~= nil and Customers.patienceLeft(entry) > 0.8)

-- 4) เสิร์ฟผ่าน callback แล้วลูกค้าออกจากคิว
local served = false
Customers.onServed = function(e) served = true; Customers.leave(e, "😊") end
if entry then Customers.onServed(entry) end
check("served callback", served)
check("queue cleared", #Customers.queue(fake) == 0)

-- 5) คิวเต็มไม่เกิน MaxQueue
for _ = 1, Config.MaxQueue + 2 do Customers.spawn(fake, { MooPing = true }) end
check("queue capped", #Customers.queue(fake) <= Config.MaxQueue)
Customers.clear(fake); Plot.release(fake)

print(#fails == 0 and "ALL PASS" or ("FAILED: " .. table.concat(fails, ", ")))
return #fails == 0, fails
