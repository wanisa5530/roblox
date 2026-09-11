-- เมือง: ถนน อาคาร ที่ดินบ้าน สวน — สร้างจาก Part ล้วน ให้ทดสอบบนคลาวด์ได้
local Config = require(game.ReplicatedStorage.Config)
local M = { buildings = {}, lots = {} }
local function part(props, parent)
	local p = Instance.new("Part"); p.Anchored = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent or workspace; return p
end
local function sign(parent, text, cf, size)
	local s = part({ Size = size or Vector3.new(14, 3, 0.5), CFrame = cf, Color = Color3.fromRGB(30, 30, 40), Material = Enum.Material.SmoothPlastic, Name = "Sign" }, parent)
	local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.CanvasSize = Vector2.new(800, 160); g.Parent = s
	local l = Instance.new("TextLabel"); l.Size = UDim2.fromScale(1, 1); l.BackgroundTransparency = 1; l.TextScaled = true; l.Font = Enum.Font.GothamBold; l.TextColor3 = Color3.fromRGB(255, 240, 120); l.Text = text; l.Parent = g
	return s
end
-- อาคาร: ชื่อ, ตำแหน่ง, ขนาด, สี ; ประตูหน้าเป็นจุด "Entrance"
local BUILDINGS = {
	{ key = "Hospital",   pos = Vector3.new(-90, 0, -90), size = Vector3.new(40, 24, 30), color = { 240, 240, 250 }, icon = "🏥" },
	{ key = "School",     pos = Vector3.new(-30, 0, -90), size = Vector3.new(44, 16, 30), color = { 250, 220, 160 }, icon = "🏫" },
	{ key = "University", pos = Vector3.new(40, 0, -90),  size = Vector3.new(50, 20, 30), color = { 200, 60, 60 },  icon = "🎓" },
	{ key = "Police",     pos = Vector3.new(100, 0, -90), size = Vector3.new(30, 14, 26), color = { 60, 80, 160 },  icon = "🚔" },
	{ key = "TechOffice", pos = Vector3.new(-90, 0, -30), size = Vector3.new(30, 40, 30), color = { 120, 180, 230 }, icon = "💻" },
	{ key = "Restaurant", pos = Vector3.new(-40, 0, -30), size = Vector3.new(28, 12, 24), color = { 220, 120, 60 }, icon = "🍽️" },
	{ key = "Cafe",       pos = Vector3.new(0, 0, -30),   size = Vector3.new(24, 10, 20), color = { 150, 100, 60 }, icon = "☕" },
	{ key = "Gallery",    pos = Vector3.new(40, 0, -30),  size = Vector3.new(28, 14, 24), color = { 230, 230, 230 }, icon = "🎨" },
	{ key = "Shop",       pos = Vector3.new(85, 0, -30),  size = Vector3.new(34, 12, 26), color = { 250, 200, 80 }, icon = "🛋️" },
	{ key = "CityHall",   pos = Vector3.new(130, 0, -30), size = Vector3.new(30, 18, 26), color = { 200, 200, 210 }, icon = "🏛️" },
	{ key = "Apartments", pos = Vector3.new(-100, 0, 60), size = Vector3.new(36, 50, 30), color = { 180, 160, 150 }, icon = "🏢" },
}
function M.build()
	if workspace:FindFirstChild("City") then return end
	local city = Instance.new("Folder"); city.Name = "City"; city.Parent = workspace
	part({ Size = Vector3.new(600, 2, 600), Position = Vector3.new(20, -1, 20), Color = Color3.fromRGB(90, 150, 80), Material = Enum.Material.Grass, Name = "Ground" }, city)
	-- ถนน
	for _, z in ipairs({ -60, 0, 30, 100 }) do part({ Size = Vector3.new(320, 0.3, 12), Position = Vector3.new(20, 0.15, z), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Asphalt }, city) end
	for _, x in ipairs({ -130, -60, 20, 70, 160 }) do part({ Size = Vector3.new(12, 0.3, 240), Position = Vector3.new(x, 0.15, 20), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Asphalt }, city) end
	-- อาคาร
	for _, b in ipairs(BUILDINGS) do
		local m = Instance.new("Model"); m.Name = b.key; m.Parent = city
		part({ Size = b.size, Position = b.pos + Vector3.new(0, b.size.Y / 2, 0), Color = Color3.fromRGB(unpack(b.color)), Material = Enum.Material.Concrete, Name = "Body" }, m)
		for i = 1, math.floor(b.size.Y / 6) do
			for j = 1, math.floor(b.size.X / 8) do
				part({ Size = Vector3.new(4, 3, 0.3), Position = b.pos + Vector3.new(-b.size.X / 2 + j * 8 - 4, i * 6 - 2, b.size.Z / 2 + 0.2), Color = Color3.fromRGB(150, 210, 240), Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false }, m)
			end
		end
		local door = part({ Size = Vector3.new(6, 8, 1), Position = b.pos + Vector3.new(0, 4, b.size.Z / 2 + 0.5), Color = Color3.fromRGB(80, 50, 30), Material = Enum.Material.Wood, Name = "Entrance", CanCollide = false }, m)
		sign(m, b.icon .. " " .. b.key, CFrame.new(b.pos + Vector3.new(0, b.size.Y + 2, b.size.Z / 2)), Vector3.new(math.min(b.size.X, 28), 4, 0.5))
		local a = Instance.new("Attachment"); a.Parent = door
		M.buildings[b.key] = { model = m, pos = b.pos, door = door.Position + Vector3.new(0, 0, 4), size = b.size }
	end
	-- สวนสาธารณะ (NPC เดินเล่น)
	local park = Instance.new("Model"); park.Name = "Park"; park.Parent = city
	part({ Size = Vector3.new(60, 0.4, 50), Position = Vector3.new(20, 0.2, 65), Color = Color3.fromRGB(70, 160, 70), Material = Enum.Material.Grass, Name = "ParkGround" }, park)
	part({ Size = Vector3.new(16, 0.6, 16), Position = Vector3.new(20, 0.5, 65), Color = Color3.fromRGB(80, 160, 220), Material = Enum.Material.Glass, Transparency = 0.3, Name = "Pond" }, park)
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		local tp = Vector3.new(20 + math.cos(a) * 24, 0, 65 + math.sin(a) * 20)
		part({ Size = Vector3.new(1.5, 6, 1.5), Position = tp + Vector3.new(0, 3, 0), Color = Color3.fromRGB(100, 70, 40), Material = Enum.Material.Wood }, park)
		part({ Shape = Enum.PartType.Ball, Size = Vector3.new(8, 8, 8), Position = tp + Vector3.new(0, 8, 0), Color = Color3.fromRGB(40, 130, 50), Material = Enum.Material.Grass }, park)
	end
	for i = 1, 4 do part({ Size = Vector3.new(6, 1, 2), Position = Vector3.new(0 + i * 10, 1.5, 45), Color = Color3.fromRGB(140, 100, 60), Material = Enum.Material.Wood, Name = "Bench" }, park) end
	sign(park, "🌳 Park", CFrame.new(20, 6, 40), Vector3.new(14, 3, 0.5))
	M.buildings.Park = { model = park, pos = Vector3.new(20, 0, 65), door = Vector3.new(20, 0, 42) }
	-- ที่ดินบ้าน 12 แปลง (2 แถว) ผู้เล่นละ 1 แปลง
	local lots = Instance.new("Folder"); lots.Name = "Lots"; lots.Parent = workspace
	for i = 1, 12 do
		local row = (i - 1) // 6; local col = (i - 1) % 6
		local origin = Vector3.new(-120 + col * 52, 0, 130 + row * 60)
		local f = Instance.new("Model"); f.Name = "Lot_" .. i; f.Parent = lots
		local ground = part({ Size = Vector3.new(44, 0.5, 44), Position = origin + Vector3.new(0, 0.25, 0), Color = Color3.fromRGB(190, 175, 150), Material = Enum.Material.Concrete, Name = "Floor" }, f)
		ground:SetAttribute("LotIndex", i)
		local ns = sign(f, "For sale", CFrame.new(origin + Vector3.new(0, 5, -23)), Vector3.new(12, 2.5, 0.5)); ns.Name = "NameSign"
		M.lots[i] = { index = i, origin = origin, model = f, owner = nil }
	end
	-- ห้องอพาร์ตเมนต์ 12 ห้อง (ในตึก) ใช้เป็นบ้านเริ่มต้น
	local apts = Instance.new("Folder"); apts.Name = "Apartments"; apts.Parent = workspace
	for i = 1, 12 do
		local floor = (i - 1) // 4; local col = (i - 1) % 4
		local origin = Vector3.new(-200 + col * 30, 4 + floor * 12, 60)
		local f = Instance.new("Model"); f.Name = "Apt_" .. i; f.Parent = apts
		part({ Size = Vector3.new(26, 0.5, 26), Position = origin, Color = Color3.fromRGB(200, 190, 170), Material = Enum.Material.WoodPlanks, Name = "Floor" }, f)
		part({ Size = Vector3.new(26, 0.5, 26), Position = origin + Vector3.new(0, 11, 0), Color = Color3.fromRGB(230, 230, 230), Name = "Ceiling" }, f)
		for _, w in ipairs({ { Vector3.new(26, 11, 0.5), Vector3.new(0, 5.5, -13) }, { Vector3.new(0.5, 11, 26), Vector3.new(-13, 5.5, 0) }, { Vector3.new(0.5, 11, 26), Vector3.new(13, 5.5, 0) }, { Vector3.new(10, 11, 0.5), Vector3.new(-8, 5.5, 13) }, { Vector3.new(10, 11, 0.5), Vector3.new(8, 5.5, 13) } }) do
			part({ Size = w[1], Position = origin + w[2], Color = Color3.fromRGB(235, 225, 200), Material = Enum.Material.SmoothPlastic, Name = "Wall" }, f)
		end
		local ns = sign(f, "Apt " .. i, CFrame.new(origin + Vector3.new(0, 9, 13)), Vector3.new(8, 2, 0.5)); ns.Name = "NameSign"
		M.lots["apt" .. i] = { index = "apt" .. i, origin = origin + Vector3.new(0, 0.25, 0), model = f, owner = nil, apartment = true }
	end
	-- ทางเดิน/บันไดขึ้นอพาร์ตเมนต์แบบง่าย (ramp)
	for floor = 0, 2 do part({ Size = Vector3.new(6, 0.5, 40), CFrame = CFrame.new(-235, 4 + floor * 12 - 6 + 6, 60) * CFrame.Angles(math.rad(-17), 0, 0), Color = Color3.fromRGB(120, 120, 120), Name = "Ramp" }, apts) end
	part({ Size = Vector3.new(6, 0.5, 130), Position = Vector3.new(-235, 0.3, 40), Color = Color3.fromRGB(120, 120, 120) }, apts)
	-- สปอน
	local spawn = Instance.new("SpawnLocation"); spawn.Size = Vector3.new(10, 1, 10); spawn.Position = Vector3.new(20, 0.8, 10); spawn.Anchored = true; spawn.Neutral = true; spawn.Parent = city
	-- แสงบรรยากาศ
	local L = game:GetService("Lighting"); L.Brightness = 2; L.Ambient = Color3.fromRGB(110, 110, 120); L.OutdoorAmbient = Color3.fromRGB(130, 130, 140)
	if not L:FindFirstChildOfClass("Atmosphere") then local at = Instance.new("Atmosphere"); at.Density = 0.3; at.Parent = L end
	if not L:FindFirstChildOfClass("BloomEffect") then local bl = Instance.new("BloomEffect"); bl.Intensity = 0.4; bl.Parent = L end
end
function M.door(key) local b = M.buildings[key]; return b and b.door end
return M
