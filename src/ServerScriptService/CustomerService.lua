-- ลูกค้าเป็นกลุ่ม: นั่งทานที่ร้าน (ต้องมีโต๊ะว่างและสะอาด) หรือซื้อกลับ (ต่อคิวหน้าเคาน์เตอร์ ต้องใส่ถุง)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Plot = require(script.Parent.PlotService)
local C = { queues = {}, groups = {}, onServed = nil, onLeft = nil, onGroupDone = nil }
local folder = Instance.new("Folder"); folder.Name = "Customers"; folder.Parent = workspace

local NAMES = { "Somchai", "Nid", "Ploy", "Ken", "Yuki", "Mei", "Budi", "Anna", "Tom", "Fah", "Bee", "Pim" }
local SHIRTS = { Color3.fromRGB(230, 80, 80), Color3.fromRGB(80, 140, 230), Color3.fromRGB(90, 190, 110), Color3.fromRGB(240, 190, 60), Color3.fromRGB(180, 100, 220) }

local function makeNpc(pos)
	local desc = Instance.new("HumanoidDescription")
	desc.HeadColor = Color3.fromRGB(240, 200, 170); desc.TorsoColor = SHIRTS[math.random(#SHIRTS)]
	desc.LeftArmColor = desc.HeadColor; desc.RightArmColor = desc.HeadColor
	desc.LeftLegColor = Color3.fromRGB(60, 60, 80); desc.RightLegColor = desc.LeftLegColor
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, desc, Enum.HumanoidRigType.R15)
	if not ok then
		model = Instance.new("Model")
		local p = Instance.new("Part"); p.Name = "HumanoidRootPart"; p.Size = Vector3.new(2, 5, 1); p.Color = SHIRTS[math.random(#SHIRTS)]; p.Anchored = true; p.Parent = model
		model.PrimaryPart = p
		Instance.new("Humanoid").Parent = model
	end
	model.Name = NAMES[math.random(#NAMES)]
	model:PivotTo(CFrame.new(pos))
	model.Parent = folder
	return model
end
local function walkTo(model, target)
	local h = model:FindFirstChildOfClass("Humanoid")
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if h and not root.Anchored then
		h:MoveTo(target)
		local done = false
		local conn; conn = h.MoveToFinished:Connect(function() done = true; conn:Disconnect() end)
		local t0 = os.clock()
		while not done and os.clock() - t0 < 12 and model.Parent do task.wait(0.1) end
	else
		local dist = (target - model:GetPivot().Position).Magnitude
		local tw = TweenService:Create(root, TweenInfo.new(dist / 8, Enum.EasingStyle.Linear), { CFrame = CFrame.new(target) })
		tw:Play(); tw.Completed:Wait()
	end
end

function C.queue(player) C.queues[player] = C.queues[player] or {}; return C.queues[player] end
function C.patienceLeft(entry)
	local g = entry.group
	if not g.orderAt then return 1 end
	return math.clamp(1 - (os.clock() - g.orderAt) / Config.Patience, 0, 1)
end

local function pickFood(foods)
	local owned = {}
	for _, f in ipairs(Config.Foods) do if foods[f.id] then owned[#owned + 1] = f end end
	return owned[math.random(#owned)]
end

local function addPrompt(entry)
	local npc = entry.npc
	local pp = Instance.new("ProximityPrompt"); pp.ActionText = "Serve"; pp.ObjectText = npc.Name; pp.KeyboardKeyCode = Enum.KeyCode.E
	pp.HoldDuration = 0; pp.MaxActivationDistance = 7; pp.RequiresLineOfSight = false; pp:SetAttribute("Kind", "serve")
	pp.Parent = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
	pp.Triggered:Connect(function(who) if who == entry.group.player and entry.group.alive and not entry.served and C.onServed then C.onServed(entry) end end)
end

-- สร้างกลุ่มลูกค้า
function C.spawn(player, foods)
	local anyFood = next(foods) ~= nil
	if not anyFood then return end
	local pts = Plot.points(player:GetAttribute("PlotIndex"))
	local tbl = (math.random() < Config.DineInChance) and Plot.freeTable(player) or nil
	local q = C.queue(player)
	if not tbl and #q >= Config.MaxQueue then return end
	local size = tbl and math.random(Config.GroupSize[1], Config.GroupSize[2]) or 1
	local g = { player = player, members = {}, table = tbl, kind = tbl and "dine" or "takeaway", alive = true, t0 = os.clock() }
	if tbl then tbl.group = g end
	C.groups[player] = C.groups[player] or {}
	table.insert(C.groups[player], g)
	for k = 1, size do
		local npc = makeNpc(pts.spawn + Vector3.new((k - 1) * 2.5, 0, 0))
		local e = { npc = npc, food = pickFood(foods), group = g, served = false }
		g.members[k] = e
		npc:SetAttribute("Takeaway", g.kind == "takeaway")
	end
	local slot
	if g.kind == "takeaway" then table.insert(q, g); slot = #q end
	task.spawn(function()
		for k, e in ipairs(g.members) do
			task.spawn(function()
				if tbl then
					local seat = tbl.seats[k]
					walkTo(e.npc, seat.Position + Vector3.new(0, 2, 0))
					local h = e.npc:FindFirstChildOfClass("Humanoid")
					if h and e.npc.Parent and g.alive then pcall(function() seat:Sit(h) end) end
				else
					walkTo(e.npc, pts.queue(slot))
				end
			end)
		end
		task.wait(tbl and 4 or 3)
		if not g.alive then return end
		g.orderAt = os.clock()
		for _, e in ipairs(g.members) do
			e.npc:SetAttribute("OrderFood", e.food.id); e.npc:SetAttribute("Patience", 1)
			addPrompt(e)
		end
		while g.alive do
			local left = 1 - (os.clock() - g.orderAt) / Config.Patience
			if left <= 0 then break end
			for _, e in ipairs(g.members) do if not e.served then e.npc:SetAttribute("Patience", left) end end
			task.wait(0.25)
		end
		if g.alive then C.leave(g, "😠"); if C.onLeft then C.onLeft(g) end end
	end)
	return g
end

-- เสิร์ฟครบทั้งกลุ่มแล้ว: นั่งกิน แล้วออกไป โต๊ะสกปรก
function C.markServed(entry)
	entry.served = true
	entry.npc:SetAttribute("OrderFood", nil); entry.npc:SetAttribute("Mood", "😋")
	local pp = entry.npc:FindFirstChildWhichIsA("ProximityPrompt", true); if pp then pp:Destroy() end
	local g = entry.group
	for _, e in ipairs(g.members) do if not e.served then return false end end
	g.alive = false -- หยุดนับความอดทน
	task.spawn(function()
		if g.kind == "dine" then task.wait(Config.EatTime) end
		C.leave(g, "😊", true)
		if C.onGroupDone then C.onGroupDone(g) end
	end)
	return true
end

function C.leave(g, mood, done)
	g.alive = false
	local player = g.player
	local q = C.queues[player]
	if q then local i = table.find(q, g); if i then table.remove(q, i) end end
	local gs = C.groups[player]
	if gs then local i = table.find(gs, g); if i then table.remove(gs, i) end end
	local pts = Plot.points(player:GetAttribute("PlotIndex"))
	if q then for n, og in ipairs(q) do if og.orderAt then task.spawn(walkTo, og.members[1].npc, pts.queue(n)) end end end
	if g.table then g.table.group = nil; if done then g.table.setDirty(true) end end
	for _, e in ipairs(g.members) do
		task.spawn(function()
			e.npc:SetAttribute("OrderFood", nil); e.npc:SetAttribute("Mood", mood)
			local h = e.npc:FindFirstChildOfClass("Humanoid"); if h then h.Sit = false; task.wait(0.3); h.Jump = true end
			walkTo(e.npc, pts.spawn)
			e.npc:Destroy()
		end)
	end
end

function C.clear(player)
	for _, g in ipairs(C.groups[player] or {}) do g.alive = false; for _, e in ipairs(g.members) do e.npc:Destroy() end end
	C.groups[player] = nil; C.queues[player] = nil
end
return C
