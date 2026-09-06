-- ลูกค้า NPC: เดินมาต่อคิว สั่งอาหาร รอ แล้วเดินออก
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Locale = require(RS.Locale)
local Plot = require(script.Parent.PlotService)
local C = { queues = {}, onServed = nil, onLeft = nil }
local folder = Instance.new("Folder"); folder.Name = "Customers"; folder.Parent = workspace

local NAMES = { "Somchai", "Nid", "Ploy", "Ken", "Yuki", "Mei", "Budi", "Anna", "Tom", "Fah" }
local SHIRTS = { Color3.fromRGB(230, 80, 80), Color3.fromRGB(80, 140, 230), Color3.fromRGB(90, 190, 110), Color3.fromRGB(240, 190, 60), Color3.fromRGB(180, 100, 220) }

local function makeNpc(pos)
	local desc = Instance.new("HumanoidDescription")
	desc.HeadColor = Color3.fromRGB(240, 200, 170); desc.TorsoColor = SHIRTS[math.random(#SHIRTS)]
	desc.LeftArmColor = desc.HeadColor; desc.RightArmColor = desc.HeadColor
	desc.LeftLegColor = Color3.fromRGB(60, 60, 80); desc.RightLegColor = desc.LeftLegColor
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, desc, Enum.HumanoidRigType.R15)
	if not ok then -- สำรอง: กล่องเดินได้
		model = Instance.new("Model")
		local p = Instance.new("Part"); p.Name = "HumanoidRootPart"; p.Size = Vector3.new(2, 5, 1); p.Color = SHIRTS[math.random(#SHIRTS)]; p.Anchored = true; p.Parent = model
		model.PrimaryPart = p
		local h = Instance.new("Humanoid"); h.Parent = model
	end
	model.Name = NAMES[math.random(#NAMES)]
	model:PivotTo(CFrame.new(pos))
	model.Parent = folder
	return model
end
local function walkTo(model, target)
	local h = model:FindFirstChildOfClass("Humanoid")
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
	if h and root and not root.Anchored then
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

-- ลูกค้าเดินเข้ามาสั่ง; คืน entry ที่ให้ระบบเสิร์ฟใช้
function C.spawn(player, foods)
	local q = C.queue(player)
	if #q >= Config.MaxQueue then return end
	local owned = {}
	for _, f in ipairs(Config.Foods) do if foods[f.id] then owned[#owned + 1] = f end end
	if #owned == 0 then return end
	local food = owned[math.random(#owned)]
	local pts = Plot.points(player:GetAttribute("PlotIndex"))
	local npc = makeNpc(pts.spawn)
	local entry = { npc = npc, food = food, player = player, alive = true, t0 = os.clock() }
	table.insert(q, entry)
	local slot = #q
	task.spawn(function()
		walkTo(npc, pts.queue(slot))
		if not entry.alive then return end
		npc:SetAttribute("OrderFood", food.id); npc:SetAttribute("Patience", 1)
		entry.bubble = true
		entry.orderAt = os.clock()
		-- ปุ่มเสิร์ฟ
		local pp = Instance.new("ProximityPrompt"); pp.ActionText = "Serve"; pp.ObjectText = npc.Name; pp.KeyboardKeyCode = Enum.KeyCode.E
		pp.HoldDuration = 0; pp.MaxActivationDistance = 7; pp.RequiresLineOfSight = false; pp.Parent = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
		pp.Triggered:Connect(function(who) if who == player and entry.alive and C.onServed then C.onServed(entry) end end)
		-- แถบความอดทน
		while entry.alive and npc.Parent do
			local left = 1 - (os.clock() - entry.orderAt) / Config.Patience
			if left <= 0 then break end
			npc:SetAttribute("Patience", left)
			task.wait(0.25)
		end
		if entry.alive then entry.alive = false; if C.onLeft then C.onLeft(entry) end; C.leave(entry, "😠") end
	end)
	return entry
end

function C.patienceLeft(entry)
	if not entry.orderAt then return 1 end
	return math.clamp(1 - (os.clock() - entry.orderAt) / Config.Patience, 0, 1)
end

function C.leave(entry, mood)
	entry.alive = false
	local q = C.queues[entry.player]
	if q then
		local i = table.find(q, entry); if i then table.remove(q, i) end
		-- เลื่อนคิว
		local pts = Plot.points(entry.player:GetAttribute("PlotIndex"))
		for n, e in ipairs(q) do if e.orderAt then task.spawn(walkTo, e.npc, pts.queue(n)) end end
	end
	task.spawn(function()
		entry.npc:SetAttribute("Mood", mood)
		local pts = Plot.points(entry.player:GetAttribute("PlotIndex"))
		walkTo(entry.npc, pts.spawn)
		entry.npc:Destroy()
	end)
end

function C.clear(player)
	for _, e in ipairs(C.queues[player] or {}) do e.alive = false; e.npc:Destroy() end
	C.queues[player] = nil
end
return C
