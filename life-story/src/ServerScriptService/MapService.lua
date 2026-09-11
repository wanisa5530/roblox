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
	-- อาคาร: ผนังวัสดุจริง หน้าต่างรอบด้าน ประตู กันสาด หลังคา ป้ายหันหน้าออกถนน
	local MATS = { Enum.Material.Brick, Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Marble }
	for bi, b in ipairs(BUILDINGS) do
		local m = Instance.new("Model"); m.Name = b.key; m.Parent = city
		local col = Color3.fromRGB(unpack(b.color))
		part({ Size = b.size, Position = b.pos + Vector3.new(0, b.size.Y / 2, 0), Color = col, Material = MATS[(bi - 1) % #MATS + 1], Name = "Body" }, m)
		-- ฐาน/ขอบชั้น
		part({ Size = Vector3.new(b.size.X + 1, 1, b.size.Z + 1), Position = b.pos + Vector3.new(0, 0.5, 0), Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Concrete }, m)
		for i = 1, math.floor(b.size.Y / 8) do part({ Size = Vector3.new(b.size.X + 0.6, 0.4, b.size.Z + 0.6), Position = b.pos + Vector3.new(0, i * 8, 0), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.SmoothPlastic }, m) end
		-- หลังคา + ขอบดาดฟ้า + แท็งก์น้ำ/แอร์
		part({ Size = Vector3.new(b.size.X + 1.2, 0.8, b.size.Z + 1.2), Position = b.pos + Vector3.new(0, b.size.Y + 0.4, 0), Color = Color3.fromRGB(70, 70, 75), Material = Enum.Material.Concrete }, m)
		part({ Size = Vector3.new(3, 3, 3), Position = b.pos + Vector3.new(b.size.X / 3, b.size.Y + 2.3, 0), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal }, m)
		-- หน้าต่างทั้ง 4 ด้าน
		local floors = math.max(1, math.floor(b.size.Y / 6))
		for i = 1, floors do
			local y = i * 6 - 2
			for j = 1, math.floor(b.size.X / 6) do
				local x = -b.size.X / 2 + j * 6 - 3
				if not (i == 1 and math.abs(x) < 5) then
					for _, zs in ipairs({ 1, -1 }) do
						part({ Size = Vector3.new(3.6, 3, 0.3), Position = b.pos + Vector3.new(x, y, zs * (b.size.Z / 2 + 0.15)), Color = Color3.fromRGB(120, 180, 220), Material = Enum.Material.Glass, Transparency = 0.25, CanCollide = false, Reflectance = 0.3 }, m)
						part({ Size = Vector3.new(4.2, 3.6, 0.2), Position = b.pos + Vector3.new(x, y, zs * (b.size.Z / 2 + 0.05)), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.SmoothPlastic, CanCollide = false }, m)
					end
				end
			end
			for j = 1, math.floor(b.size.Z / 6) do
				local z = -b.size.Z / 2 + j * 6 - 3
				for _, xs in ipairs({ 1, -1 }) do
					part({ Size = Vector3.new(0.3, 3, 3.6), Position = b.pos + Vector3.new(xs * (b.size.X / 2 + 0.15), y, z), Color = Color3.fromRGB(120, 180, 220), Material = Enum.Material.Glass, Transparency = 0.25, CanCollide = false, Reflectance = 0.3 }, m)
				end
			end
		end
		-- ประตูกระจกคู่ + กรอบ + กันสาด + เสา + ไฟ
		local dz = b.size.Z / 2
		part({ Size = Vector3.new(8, 8.6, 0.6), Position = b.pos + Vector3.new(0, 4.3, dz + 0.1), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Metal, CanCollide = false }, m)
		local door = part({ Size = Vector3.new(6.6, 8, 0.4), Position = b.pos + Vector3.new(0, 4, dz + 0.35), Color = Color3.fromRGB(150, 200, 230), Material = Enum.Material.Glass, Transparency = 0.4, Name = "Entrance", CanCollide = false }, m)
		part({ Size = Vector3.new(0.3, 7.5, 0.5), Position = b.pos + Vector3.new(0, 4, dz + 0.4), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Metal, CanCollide = false }, m)
		part({ Size = Vector3.new(12, 0.5, 5), Position = b.pos + Vector3.new(0, 9, dz + 2.5), Color = Color3.fromRGB(unpack(b.color)):Lerp(Color3.new(0, 0, 0), 0.5), Material = Enum.Material.Metal, CanCollide = false }, m)
		for _, xs in ipairs({ -5, 5 }) do part({ Size = Vector3.new(0.5, 9, 0.5), Position = b.pos + Vector3.new(xs, 4.5, dz + 4.5), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, m) end
		part({ Size = Vector3.new(14, 0.3, 8), Position = b.pos + Vector3.new(0, 0.15, dz + 4), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Concrete }, m)
		local lamp = part({ Size = Vector3.new(1, 0.4, 1), Position = b.pos + Vector3.new(0, 8.6, dz + 2.5), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon, CanCollide = false }, m)
		local pl = Instance.new("PointLight"); pl.Range = 16; pl.Brightness = 1; pl.Color = Color3.fromRGB(255, 235, 190); pl.Parent = lamp
		-- ป้ายชื่อหันหน้าออกถนน
		sign(m, b.icon .. " " .. b.key, CFrame.new(b.pos + Vector3.new(0, 12.5, dz + 0.6)) * CFrame.Angles(0, math.pi, 0), Vector3.new(math.min(b.size.X - 2, 26), 3.2, 0.5))
		M.buildings[b.key] = { model = m, pos = b.pos, door = door.Position + Vector3.new(0, 0, 5), size = b.size }
	end
	-- ทางเท้า ขอบถนน เส้นถนน เสาไฟ ต้นไม้ริมถนน รถจอด
	for _, z in ipairs({ -60, 0, 30, 100 }) do
		for _, side in ipairs({ -1, 1 }) do part({ Size = Vector3.new(320, 0.4, 3), Position = Vector3.new(20, 0.2, z + side * 7.5), Color = Color3.fromRGB(175, 175, 180), Material = Enum.Material.Concrete }, city) end
		for x = -130, 170, 8 do part({ Size = Vector3.new(3, 0.05, 0.4), Position = Vector3.new(x, 0.33, z), Color = Color3.fromRGB(240, 220, 120), Material = Enum.Material.SmoothPlastic, CanCollide = false }, city) end
	end
	for _, x in ipairs({ -130, -60, 20, 70, 160 }) do
		for _, side in ipairs({ -1, 1 }) do part({ Size = Vector3.new(3, 0.4, 240), Position = Vector3.new(x + side * 7.5, 0.2, 20), Color = Color3.fromRGB(175, 175, 180), Material = Enum.Material.Concrete }, city) end
	end
	for x = -120, 160, 40 do
		for _, z in ipairs({ -52, 8, 38 }) do
			part({ Size = Vector3.new(0.5, 12, 0.5), Position = Vector3.new(x, 6, z), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, city)
			local head = part({ Size = Vector3.new(2, 0.5, 1), Position = Vector3.new(x, 12, z + (z > 0 and -1 or 1)), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon }, city)
			local l = Instance.new("PointLight"); l.Range = 22; l.Brightness = 0.9; l.Color = Color3.fromRGB(255, 230, 180); l.Parent = head
		end
		local tx = x + 20
		part({ Size = Vector3.new(1.2, 5, 1.2), Position = Vector3.new(tx, 2.5, -52), Color = Color3.fromRGB(100, 70, 40), Material = Enum.Material.Wood }, city)
		part({ Shape = Enum.PartType.Ball, Size = Vector3.new(7, 7, 7), Position = Vector3.new(tx, 7.5, -52), Color = Color3.fromRGB(50, 140, 60), Material = Enum.Material.Grass }, city)
	end
	local CARS = { { 200, 40, 40 }, { 50, 80, 190 }, { 235, 235, 235 }, { 35, 35, 40 }, { 225, 170, 40 } }
	for i, x in ipairs({ -100, -20, 50, 120, 140 }) do M.car(Vector3.new(x, 0, 4.5), Color3.fromRGB(unpack(CARS[i])), city) end
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
		local ns = sign(f, "For sale", CFrame.new(origin + Vector3.new(0, 5, -23)) * CFrame.Angles(0, math.pi, 0), Vector3.new(12, 2.5, 0.5)); ns.Name = "NameSign"
		for _, side in ipairs({ -1, 1 }) do part({ Size = Vector3.new(0.4, 2.5, 44), Position = origin + Vector3.new(side * 22, 1.5, 0), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.Wood }, f) end
		part({ Size = Vector3.new(44, 2.5, 0.4), Position = origin + Vector3.new(0, 1.5, 22), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.Wood }, f)
		part({ Size = Vector3.new(10, 0.3, 14), Position = origin + Vector3.new(14, 0.55, -18), Color = Color3.fromRGB(160, 160, 165), Material = Enum.Material.Concrete, Name = "Driveway" }, f)
		part({ Size = Vector3.new(1, 3, 1), Position = origin + Vector3.new(-16, 1.5, -22), Color = Color3.fromRGB(60, 60, 60), Material = Enum.Material.Metal }, f)
		part({ Size = Vector3.new(1.4, 1, 2), Position = origin + Vector3.new(-16, 3.3, -22), Color = Color3.fromRGB(60, 90, 180), Material = Enum.Material.Metal, Name = "Mailbox" }, f)
		part({ Size = Vector3.new(44, 0.4, 44), Position = origin + Vector3.new(0, 0.25, 0), Color = Color3.fromRGB(80, 160, 80), Material = Enum.Material.Grass, CanCollide = false, Transparency = 1 }, f)
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
	if not L:FindFirstChildOfClass("Sky") then local sky = Instance.new("Sky"); sky.SkyboxBk = "rbxassetid://591058823"; sky.SkyboxDn = "rbxassetid://591059876"; sky.SkyboxFt = "rbxassetid://591058104"; sky.SkyboxLf = "rbxassetid://591057861"; sky.SkyboxRt = "rbxassetid://591057625"; sky.SkyboxUp = "rbxassetid://591059642"; sky.Parent = L end
	if not L:FindFirstChildOfClass("Atmosphere") then local at = Instance.new("Atmosphere"); at.Density = 0.3; at.Parent = L end
	if not L:FindFirstChildOfClass("BloomEffect") then local bl = Instance.new("BloomEffect"); bl.Intensity = 0.4; bl.Parent = L end
end
-- รถยนต์: ตัวถังโค้งด้วย wedge กระจกเอียง ล้อยาง+ดุม ไฟหน้า/ท้าย กันชน ป้ายทะเบียน
function M.car(pos, color, parent, yaw)
	local car = Instance.new("Model"); car.Name = "Car"; car.Parent = parent
	local cf = CFrame.new(pos + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, yaw or 0, 0)
	local function pc(props) local q = part(props, car); return q end
	local metal = Enum.Material.Metal
	pc({ Size = Vector3.new(6, 1.6, 13), CFrame = cf * CFrame.new(0, 0.8, 0), Color = color, Material = metal, Reflectance = 0.15 })            -- ตัวถังล่าง
	pc({ Size = Vector3.new(5.6, 1.5, 6.5), CFrame = cf * CFrame.new(0, 2.3, 0.3), Color = color, Material = metal, Reflectance = 0.15 })      -- หลังคา/ห้องโดยสาร
	local w1 = Instance.new("WedgePart"); w1.Anchored = true; w1.Size = Vector3.new(5.6, 1.5, 2.6); w1.CFrame = cf * CFrame.new(0, 2.3, -4.2) * CFrame.Angles(0, math.pi, 0); w1.Color = Color3.fromRGB(40, 60, 80); w1.Material = Enum.Material.Glass; w1.Transparency = 0.35; w1.Parent = car  -- กระจกหน้า
	local w2 = Instance.new("WedgePart"); w2.Anchored = true; w2.Size = Vector3.new(5.6, 1.5, 2.2); w2.CFrame = cf * CFrame.new(0, 2.3, 4.7); w2.Color = Color3.fromRGB(40, 60, 80); w2.Material = Enum.Material.Glass; w2.Transparency = 0.35; w2.Parent = car  -- กระจกหลัง
	for _, sx in ipairs({ -1, 1 }) do
		pc({ Size = Vector3.new(0.2, 1.1, 5.8), CFrame = cf * CFrame.new(sx * 2.85, 2.3, 0.3), Color = Color3.fromRGB(40, 60, 80), Material = Enum.Material.Glass, Transparency = 0.4 })  -- กระจกข้าง
		pc({ Size = Vector3.new(0.3, 0.3, 0.8), CFrame = cf * CFrame.new(sx * 3.2, 1.9, -2.2), Color = color, Material = metal })  -- กระจกมองข้าง
		for _, z in ipairs({ -4, 4 }) do
			pc({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.9, 2.2, 2.2), CFrame = cf * CFrame.new(sx * 2.8, -0.1, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(25, 25, 25), Material = Enum.Material.Rubber })
			pc({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.95, 1.3, 1.3), CFrame = cf * CFrame.new(sx * 2.85, -0.1, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(200, 200, 205), Material = metal, Reflectance = 0.4 })
		end
		local hl = pc({ Size = Vector3.new(1.2, 0.6, 0.3), CFrame = cf * CFrame.new(sx * 2, 1.1, -6.6), Color = Color3.fromRGB(255, 250, 220), Material = Enum.Material.Neon })
		local l = Instance.new("SpotLight"); l.Range = 20; l.Angle = 60; l.Brightness = 1; l.Face = Enum.NormalId.Front; l.Parent = hl
		pc({ Size = Vector3.new(1.2, 0.5, 0.3), CFrame = cf * CFrame.new(sx * 2, 1.1, 6.6), Color = Color3.fromRGB(230, 40, 40), Material = Enum.Material.Neon })
	end
	pc({ Size = Vector3.new(6.2, 0.6, 0.6), CFrame = cf * CFrame.new(0, 0.3, -6.6), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.SmoothPlastic })   -- กันชนหน้า
	pc({ Size = Vector3.new(6.2, 0.6, 0.6), CFrame = cf * CFrame.new(0, 0.3, 6.6), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.SmoothPlastic })    -- กันชนหลัง
	pc({ Size = Vector3.new(3, 0.8, 0.2), CFrame = cf * CFrame.new(0, 0.9, -6.7), Color = Color3.fromRGB(30, 30, 30), Material = Enum.Material.SmoothPlastic })      -- กระจังหน้า
	pc({ Size = Vector3.new(1.6, 0.5, 0.1), CFrame = cf * CFrame.new(0, 0.7, 6.75), Color = Color3.fromRGB(250, 250, 250), Material = Enum.Material.SmoothPlastic })  -- ป้ายทะเบียน
	return car
end
function M.door(key) local b = M.buildings[key]; return b and b.door end
return M
