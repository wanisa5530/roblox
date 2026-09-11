-- ลูกศรนำทาง: วางจุดสีฟ้าตามเส้นทาง (Pathfinding) จากผู้เล่นไปยังเป้าหมายของคู่มือขั้นปัจจุบัน + ป้าย 🎯 ที่ปลายทาง
local Players = game:GetService("Players")
local PFS = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local folder = Instance.new("Folder"); folder.Name = "NavArrows"; folder.Parent = workspace
local beacon = Instance.new("Part"); beacon.Size = Vector3.new(1.5, 20, 1.5); beacon.Anchored = true; beacon.CanCollide = false; beacon.CanQuery = false; beacon.Material = Enum.Material.Neon; beacon.Color = Color3.fromRGB(60, 190, 255); beacon.Transparency = 0.6; beacon.Parent = folder; beacon.Transparency = 1
local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 120, 0, 40); bb.StudsOffset = Vector3.new(0, 8, 0); bb.AlwaysOnTop = true; bb.MaxDistance = 400; bb.Parent = beacon
local bt = Instance.new("TextLabel"); bt.Size = UDim2.fromScale(1, 1); bt.BackgroundTransparency = 1; bt.Text = "🎯"; bt.TextSize = 36; bt.Font = Enum.Font.GothamBold; bt.TextColor3 = Color3.fromRGB(255, 255, 255); bt.TextStrokeTransparency = 0.3; bt.Parent = bb
-- ลูกศรแบน (สามเหลี่ยมจาก WedgePart 2 ชิ้น) วางบนพื้น ชี้ทิศทางเดิน
local N = 30
local arrows = {}
local function mk() local w = Instance.new("WedgePart"); w.Anchored = true; w.CanCollide = false; w.CanQuery = false; w.CastShadow = false; w.Material = Enum.Material.SmoothPlastic; w.Color = Color3.fromRGB(70, 200, 255); w.Transparency = 1; w.Size = Vector3.new(0.2, 1.7, 3.2); w.Parent = folder; return w end
for i = 1, N do arrows[i] = { mk(), mk() } end
local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude
local function ground(pos)
	rp.FilterDescendantsInstances = { folder, player.Character or folder }
	local r = workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -30, 0), rp)
	return r and (r.Position + Vector3.new(0, 0.12, 0)) or pos
end
local function hide() for _, a in ipairs(arrows) do a[1].Transparency = 1; a[2].Transparency = 1 end; beacon.Transparency = 1; bb.Enabled = false end
local function draw(target)
	local ch = player.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart"); if not hrp then hide(); return end
	beacon.Position = ground(target) + Vector3.new(0, 10, 0); beacon.Transparency = 0.85; bb.Enabled = true
	if (hrp.Position - target).Magnitude < 8 then for _, a in ipairs(arrows) do a[1].Transparency = 1; a[2].Transparency = 1 end; return end
	local path = PFS:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4.5 })
	local ok = pcall(function() path:ComputeAsync(hrp.Position, target) end)
	local pts = {}
	if ok and path.Status == Enum.PathStatus.Success then for _, w in ipairs(path:GetWaypoints()) do pts[#pts + 1] = w.Position end
	else local n = math.min(N, math.floor((target - hrp.Position).Magnitude / 4.5)); for i = 1, n do pts[i] = hrp.Position:Lerp(target, i / n) end end
	local k = 0
	for i = 2, #pts do
		if k >= N then break end
		k += 1; local a = arrows[k]
		local dir = pts[math.min(i + 1, #pts)] - pts[i - 1]; dir = Vector3.new(dir.X, 0, dir.Z); if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, -1) end
		local g = ground(pts[i])
		local cf = CFrame.lookAt(g, g + dir)
		a[1].CFrame = cf * CFrame.new(-0.85, 0, 0) * CFrame.Angles(0, 0, math.rad(90)); a[1].Transparency = 0.25
		a[2].CFrame = cf * CFrame.new(0.85, 0, 0) * CFrame.Angles(0, 0, math.rad(-90)); a[2].Transparency = 0.25
	end
	for i = k + 1, N do arrows[i][1].Transparency = 1; arrows[i][2].Transparency = 1 end
end
local last = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - last < 1.2 then return end; last = os.clock()
	local t = player:GetAttribute("NavTarget")
	if typeof(t) ~= "Vector3" then hide(); return end
	draw(t)
end)
