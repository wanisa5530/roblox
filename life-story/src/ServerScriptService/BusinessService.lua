-- ธุรกิจ: คาเฟ่ของผู้เล่น ลูกค้า NPC เดินมา เจ้าของ/พนักงานกด Serve
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Sim = require(script.Parent.SimService)
local Map = require(script.Parent.MapService)
local B = { owner = nil, queue = {}, employees = {} }  -- MVP: คาเฟ่กลาง 1 แห่ง เจ้าของคนแรกที่ซื้อในเซิร์ฟเวอร์นี้ (ข้อมูลเจ้าของเก็บใน char.business)
local counterPrompt
function B.setup()
	local cafe = Map.buildings.Cafe; if not cafe then return end
	local counter = Instance.new("Part"); counter.Anchored = true; counter.Size = Vector3.new(10, 3, 2); counter.CFrame = CFrame.lookAt(cafe.door + cafe.front * 8 + Vector3.new(0, 1.5, 0), cafe.door + cafe.front * 8 + Vector3.new(0, 1.5, 0) + cafe.front); counter.Color = Color3.fromRGB(120, 80, 50); counter.Material = Enum.Material.Wood; counter.Name = "CafeCounter"; counter.Parent = cafe.model
	counterPrompt = Instance.new("ProximityPrompt"); counterPrompt.ActionText = "Serve"; counterPrompt.ObjectText = "Cafe"; counterPrompt.HoldDuration = 0; counterPrompt.MaxActivationDistance = 10; counterPrompt.RequiresLineOfSight = false; counterPrompt.Parent = counter
	counterPrompt:SetAttribute("Action", "serve")
	counterPrompt.Triggered:Connect(function(who) B.serve(who) end)
	local hirePart = Instance.new("Part"); hirePart.Anchored = true; hirePart.Size = Vector3.new(2, 4, 2); hirePart.Position = cafe.door + cafe.front * 8 + cafe.right * 8 + Vector3.new(0, 2, 0); hirePart.Color = Color3.fromRGB(240, 200, 80); hirePart.Name = "CafeBoard"; hirePart.Parent = cafe.model
	local hp = Instance.new("ProximityPrompt"); hp.ActionText = "Cafe"; hp.ObjectText = "Business"; hp.HoldDuration = 0; hp.MaxActivationDistance = 10; hp.RequiresLineOfSight = false; hp.Parent = hirePart
	hp:SetAttribute("Action", "cafe")
	hp.Triggered:Connect(function(who) Remotes.Business:FireClient(who, "open", B.owner and B.owner.Name or nil, B.level()) end)
	task.spawn(function()
		while true do
			task.wait(math.random(Config.Business.customerEvery[1], Config.Business.customerEvery[2]))
			if B.owner and #B.queue < 5 then B.spawnCustomer() end
		end
	end)
end
function B.level() local c = B.owner and Core.char(B.owner); return c and c.business and c.business.level or 0 end
function B.buy(p)
	local c = Core.char(p); if not c then return false end
	if B.owner and B.owner ~= p then return false, "taken" end
	if c.business then B.owner = p; return true end
	if not Core.spend(p, Config.Business.price) then return false end
	c.business = { key = "Cafe", level = 1, revenue = 0 }; B.owner = p
	Core.notify(p, "bought", "green", Core.T(p, "Cafe")); Sim.checkAspiration(p); Core.push(p); return true
end
function B.upgrade(p)
	local c = Core.char(p); if not c or not c.business then return false end
	local cost = Config.Business.upgradeCost[c.business.level]; if not cost then return false end
	if not Core.spend(p, cost) then return false end
	c.business.level += 1; Core.notify(p, "bizLevel", "green", c.business.level); Core.push(p); return true
end
function B.workHere(p)
	if not B.owner or B.owner == p then return false end
	B.employees[p] = true; return true
end
function B.spawnCustomer()
	local cafe = Map.buildings.Cafe
	local npc = Core.spawnNpc(math.random(1, 30), "☕ Customer")
	if not npc then return end
	npc:PivotTo(CFrame.new(cafe.door + cafe.front * 14 - cafe.right * 14 + Vector3.new(0, 3, 0))); npc.Parent = cafe.model
	local hum = npc:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayName = "☕ Customer" end
	table.insert(B.queue, npc)
	local slot = #B.queue
	if hum then hum:MoveTo(cafe.door + cafe.front * 12 + cafe.right * (-4 + slot * 2.5)) end
	task.delay(60, function() if npc.Parent then for i, n in ipairs(B.queue) do if n == npc then table.remove(B.queue, i) end end; npc:Destroy() end end)
end
function B.serve(who)
	if not B.owner then return end
	if who ~= B.owner and not B.employees[who] then return end
	local npc = table.remove(B.queue, 1); if not npc then return end
	npc:Destroy()
	local oc = Core.char(B.owner); if not oc or not oc.business then return end
	local price = Config.Business.pricePerCustomer[math.clamp(oc.business.level, 1, #Config.Business.pricePerCustomer)]
	oc.business.revenue += price; oc.bizServed = (oc.bizServed or 0) + 1
	if who == B.owner then Core.addCash(who, price); Core.notify(who, "bizEarn", "green", price); Sim.addXp(who, "charisma", 8)
	else
		local share = math.floor(price * Config.Business.employeeShare)
		Core.addCash(B.owner, price - share); Core.addCash(who, share); Core.notify(who, "earnedShare", "green", share); Core.notify(B.owner, "bizEarn", "green", price - share); Sim.addXp(who, "charisma", 8); Core.push(B.owner)
	end
	Sim.progress(who, "money", price); Sim.checkAspiration(B.owner); Core.push(who)
end
function B.onLeave(p) if B.owner == p then B.owner = nil end; B.employees[p] = nil end
function B.restore(p) local c = Core.char(p); if c and c.business and not B.owner then B.owner = p end end
return B
