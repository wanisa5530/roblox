-- ลูกศรนำทาง: วางจุดสีฟ้าตามเส้นทาง (Pathfinding) จากผู้เล่นไปยังเป้าหมายของคู่มือขั้นปัจจุบัน + ป้าย 🎯 ที่ปลายทาง
local Players = game:GetService("Players")
local PFS = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local folder = Instance.new("Folder"); folder.Name = "NavArrows"; folder.Parent = workspace
local beacon = Instance.new("Part"); beacon.Size = Vector3.new(3, 60, 3); beacon.Anchored = true; beacon.CanCollide = false; beacon.CanQuery = false; beacon.Material = Enum.Material.Neon; beacon.Color = Color3.fromRGB(60, 190, 255); beacon.Transparency = 0.6; beacon.Parent = folder; beacon.Transparency = 1
local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 120, 0, 40); bb.StudsOffset = Vector3.new(0, 8, 0); bb.AlwaysOnTop = true; bb.MaxDistance = 400; bb.Parent = beacon
local bt = Instance.new("TextLabel"); bt.Size = UDim2.fromScale(1, 1); bt.BackgroundTransparency = 1; bt.Text = "🎯"; bt.TextSize = 36; bt.Font = Enum.Font.GothamBold; bt.TextColor3 = Color3.fromRGB(255, 255, 255); bt.TextStrokeTransparency = 0.3; bt.Parent = bb
local dots = {}
for i = 1, 40 do
	local d = Instance.new("Part"); d.Shape = Enum.PartType.Cylinder; d.Size = Vector3.new(0.25, 2.6, 2.6); d.Anchored = true; d.CanCollide = false; d.CanQuery = false; d.Material = Enum.Material.Neon; d.Color = Color3.fromRGB(60, 190, 255); d.Transparency = 1; d.Parent = folder; dots[i] = d
end
local function hide() for _, d in ipairs(dots) do d.Transparency = 1 end; beacon.Transparency = 1; bb.Enabled = false end
local function draw(target)
	local ch = player.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart"); if not hrp then hide(); return end
	beacon.Position = target + Vector3.new(0, 30, 0); beacon.Transparency = 0.7; bb.Enabled = true
	if (hrp.Position - target).Magnitude < 8 then for _, d in ipairs(dots) do d.Transparency = 1 end; return end
	local path = PFS:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 5 })
	local ok = pcall(function() path:ComputeAsync(hrp.Position, target) end)
	local pts = {}
	if ok and path.Status == Enum.PathStatus.Success then for _, w in ipairs(path:GetWaypoints()) do pts[#pts + 1] = w.Position end
	else -- เส้นตรงถ้าหาทางไม่ได้
		local n = math.min(40, math.floor((target - hrp.Position).Magnitude / 5)); for i = 1, n do pts[i] = hrp.Position:Lerp(target, i / n) end
	end
	local k = 0
	for i = 2, #pts do
		if k >= #dots then break end
		k += 1; local d = dots[k]
		local dir = (pts[i] - pts[i - 1]); if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
		d.CFrame = CFrame.lookAt(pts[i] + Vector3.new(0, 0.4, 0), pts[i] + dir) * CFrame.Angles(0, math.rad(90), 0)
		d.Transparency = 0.15
	end
	for i = k + 1, #dots do dots[i].Transparency = 1 end
end
local last = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - last < 1.2 then return end; last = os.clock()
	local t = player:GetAttribute("NavTarget")
	if typeof(t) ~= "Vector3" then hide(); return end
	draw(t)
end)
