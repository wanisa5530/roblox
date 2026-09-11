-- โหมดสร้าง: เลือกเฟอร์นิเจอร์จากแคตตาล็อก → คลิกบนพื้นที่ดินเพื่อวาง (R หมุน)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui"); gui.Name = "LifeBuild"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui"); U.scaleGui(gui)
local panel = U.frame(gui, UDim2.new(0, 260, 0, 440), UDim2.new(1, -270, 0.5, -220), U.C.bg, 12); panel.Visible = false
U.label(panel, "🛋️ " .. T("build"), UDim2.new(1, -50, 0, 30), UDim2.new(0, 10, 0, 6), { textSize = 16, color = U.C.accent })
U.button(panel, "✕", UDim2.new(0, 30, 0, 30), UDim2.new(1, -36, 0, 6), U.C.red, function() panel.Visible = false end)
local hintL = U.label(panel, T("buildMode"), UDim2.new(1, -20, 0, 34), UDim2.new(0, 10, 0, 36), { textSize = 11, color = U.C.dim })
local catF = Instance.new("Frame"); catF.Size = UDim2.new(1, -16, 0, 26); catF.Position = UDim2.new(0, 8, 0, 72); catF.BackgroundTransparency = 1; catF.Parent = panel
local cl = Instance.new("UIListLayout"); cl.FillDirection = Enum.FillDirection.Horizontal; cl.Padding = UDim.new(0, 3); cl.Parent = catF
local list = U.scroll(panel, UDim2.new(1, -16, 1, -110), UDim2.new(0, 8, 0, 102))
local cats = { "bed", "kitchen", "bath", "fun", "skill", "decor", "outdoor", "family", "safety" }
local selected, rot, ghost
local function fillList(cat)
	for _, x in ipairs(list:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
	for _, f in ipairs(Config.Furniture) do
		if f.cat == cat then
			U.card(list, T(f.key), "฿" .. U.fmt(f.price) .. (f.need and (" · " .. T(f.need) .. " +" .. f.rate) or "") .. (f.skill and (" · " .. T(f.skill)) or "") .. (f.env and (" · 🏠+" .. f.env) or ""), T("place"), U.C.green, function()
				selected = f; rot = 0
				if ghost then ghost:Destroy() end
				ghost = Instance.new("Part"); ghost.Anchored = true; ghost.CanCollide = false; ghost.Size = Vector3.new(f.size[1], f.size[2], f.size[3]); ghost.Color = Color3.fromRGB(f.color[1], f.color[2], f.color[3]); ghost.Transparency = 0.5; ghost.Parent = workspace
				hintL.Text = T("place") .. ": " .. T(f.key) .. "  (R = " .. T("rotate") .. ")"
			end)
		end
	end
end
for i, c in ipairs(cats) do local b = U.button(catF, ({ bed = "🛏️", kitchen = "🍳", bath = "🚿", fun = "📺", skill = "📚", decor = "🖼️", outdoor = "🌱", family = "👶", safety = "🚨" })[c], UDim2.new(0, 25, 1, 0), nil, U.C.card, function() fillList(c) end); b.LayoutOrder = i; b.TextSize = 13 end
fillList("bed")
local function myLot()
	local data = Remotes.GetData:InvokeServer(); local c = data and data.char; if not c or not c.lotIndex then return end
	local folder = type(c.lotIndex) == "string" and workspace:FindFirstChild("Apartments") or workspace:FindFirstChild("Lots")
	local name = type(c.lotIndex) == "string" and ("Apt_" .. c.lotIndex:sub(4)) or ("Lot_" .. c.lotIndex)
	return folder and folder:FindFirstChild(name)
end
local lot
player:GetAttributeChangedSignal("BuildMode"):Connect(function() panel.Visible = true; lot = myLot() end)
player:GetAttributeChangedSignal("BuildClose"):Connect(function() panel.Visible = false end)
game:GetService("RunService").RenderStepped:Connect(function()
	if not ghost or not panel.Visible then if ghost then ghost.Transparency = 1 end; return end
	local floor = lot and lot:FindFirstChild("Floor")
	if floor and mouse.Target and mouse.Target:IsDescendantOf(lot) then
		local h = mouse.Hit.Position
		local rel = floor.CFrame:PointToObjectSpace(h)
		local x, z = math.floor(rel.X / 2 + 0.5) * 2, math.floor(rel.Z / 2 + 0.5) * 2
		ghost.Transparency = 0.5
		ghost.CFrame = floor.CFrame * CFrame.new(x, floor.Size.Y / 2 + ghost.Size.Y / 2, z) * CFrame.Angles(0, math.rad(rot), 0)
		ghost:SetAttribute("GX", x); ghost:SetAttribute("GZ", z)
	else ghost.Transparency = 1 end
end)
UIS.InputBegan:Connect(function(i, gp)
	if gp or not panel.Visible or not selected then return end
	if i.KeyCode == Enum.KeyCode.R then rot = (rot + 90) % 360
	elseif i.UserInputType == Enum.UserInputType.MouseButton1 and ghost and ghost.Transparency < 1 then
		Remotes.Build:FireServer("buy", selected.key, ghost:GetAttribute("GX"), ghost:GetAttribute("GZ"), rot)
	end
end)
panel:GetPropertyChangedSignal("Visible"):Connect(function() if not panel.Visible and ghost then ghost:Destroy(); ghost = nil; selected = nil end end)
