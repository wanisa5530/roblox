-- เมือง: ถนน อาคาร ที่ดินบ้าน สวน — สร้างจาก Part ล้วน ให้ทดสอบบนคลาวด์ได้
local Config = require(game.ReplicatedStorage.Config)
local Assets = require(script.Parent.Assets)
local M = { buildings = {}, lots = {}, assetsUsed = 0 }
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
-- อาคาร (ผังกรุงเทพฯ ย่อส่วน): key, pos, size, color, icon, yaw(องศา หันหน้าออกถนน), label
local BUILDINGS = {
	-- รัตนโกสินทร์ / ข้าวสาร
	{ key = "CityHall",   pos = Vector3.new(150, 0, -250), size = Vector3.new(40, 18, 28), color = { 235, 235, 240 }, icon = "🏛️", yaw = 180, label = "City Hall" },
	{ key = "Cafe",       pos = Vector3.new(60, 0, -330),  size = Vector3.new(26, 10, 20), color = { 150, 100, 60 },  icon = "☕", yaw = 180, label = "Khao San Cafe" },
	-- เยาวราช
	{ key = "Restaurant", pos = Vector3.new(90, 0, -120),  size = Vector3.new(30, 14, 24), color = { 180, 40, 40 },   icon = "🍜", yaw = 200, label = "Yaowarat Restaurant" },
	-- สยาม / ปทุมวัน
	{ key = "Shop",       pos = Vector3.new(200, 0, -60),  size = Vector3.new(70, 22, 40), color = { 240, 240, 245 }, icon = "🛍️", yaw = 180, label = "Siam Mall · Furniture" },
	{ key = "University", pos = Vector3.new(110, 0, 50),   size = Vector3.new(56, 20, 34), color = { 240, 170, 190 }, icon = "🎓", yaw = 180, label = "Chula University" },
	-- สีลม / สาทร
	{ key = "TechOffice", pos = Vector3.new(60, 0, 200),   size = Vector3.new(34, 70, 34), color = { 120, 180, 230 }, icon = "💻", yaw = 0,   label = "Silom Tower · Tech" },
	{ key = "Hospital",   pos = Vector3.new(160, 0, 230),  size = Vector3.new(46, 26, 32), color = { 240, 245, 250 }, icon = "🏥", yaw = 0,   label = "Sathorn Hospital" },
	{ key = "Police",     pos = Vector3.new(250, 0, 200),  size = Vector3.new(30, 14, 26), color = { 60, 80, 160 },   icon = "🚔", yaw = 0,   label = "Police Station" },
	-- สุขุมวิท / ทองหล่อ
	{ key = "School",     pos = Vector3.new(340, 0, 70),   size = Vector3.new(50, 16, 30), color = { 250, 220, 160 }, icon = "🏫", yaw = 90,  label = "Sukhumvit School" },
	{ key = "Gallery",    pos = Vector3.new(340, 0, -160), size = Vector3.new(30, 14, 24), color = { 230, 230, 230 }, icon = "🎨", yaw = 90,  label = "Thonglor Gallery" },
}
-- ถนน: เส้นตรงระหว่างจุด (หมุนตามทิศ) + ทางเท้า + เส้นกลางถนน
local function road(parent, p1, p2, width, name)
	local d = p2 - p1; local len = d.Magnitude; local mid = (p1 + p2) / 2
	local cf = CFrame.lookAt(mid, p2) * CFrame.new(0, 0.15, 0)
	part({ Size = Vector3.new(width, 0.3, len), CFrame = cf, Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Asphalt, Name = name or "Road" }, parent)
	for _, sd in ipairs({ -1, 1 }) do part({ Size = Vector3.new(3, 0.4, len), CFrame = cf * CFrame.new(sd * (width / 2 + 1.5), 0.05, 0), Color = Color3.fromRGB(175, 175, 180), Material = Enum.Material.Concrete }, parent) end
	for z = -len / 2 + 4, len / 2 - 4, 8 do part({ Size = Vector3.new(0.4, 0.05, 3), CFrame = cf * CFrame.new(0, 0.18, z), Color = Color3.fromRGB(240, 220, 120), CanCollide = false }, parent) end
	return cf, len
end
local function lampAt(parent, pos)
	local am = Assets.place("lamp", 1, pos, 0, nil, parent)
	if am then local sz = am:GetExtentsSize(); if sz.Y < 8 or sz.Y > 30 then am:Destroy() else local l = Instance.new("PointLight"); l.Range = 24; l.Brightness = 0.9; l.Color = Color3.fromRGB(255, 230, 180); local top = am:FindFirstChildWhichIsA("BasePart"); if top then l.Parent = top end; return am end end
	part({ Size = Vector3.new(0.5, 12, 0.5), Position = pos + Vector3.new(0, 6, 0), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, parent)
	local head = part({ Size = Vector3.new(2, 0.5, 1), Position = pos + Vector3.new(0, 12, 0), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon }, parent)
	local l = Instance.new("PointLight"); l.Range = 22; l.Brightness = 0.9; l.Color = Color3.fromRGB(255, 230, 180); l.Parent = head
end
local function tree(parent, tp, sc)
	sc = sc or 1
	local am = Assets.place("tree", math.random(1, 3), tp, math.random(0, 359), 14 * sc, parent)
	if am then return am end
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(7 * sc, 1.4 * sc, 1.4 * sc), CFrame = CFrame.new(tp + Vector3.new(0, 3.5 * sc, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(95, 65, 40), Material = Enum.Material.Wood }, parent)
	for _, o in ipairs({ { 0, 9, 0, 9 }, { 2.5, 11, 1.5, 6.5 }, { -2.5, 11.5, -1.5, 6 } }) do part({ Shape = Enum.PartType.Ball, Size = Vector3.new(o[4] * sc, o[4] * sc, o[4] * sc), Position = tp + Vector3.new(o[1] * sc, o[2] * sc, o[3] * sc), Color = Color3.fromRGB(45 + math.random(0, 20), 130 + math.random(0, 30), 50), Material = Enum.Material.Grass, CanCollide = false }, parent) end
end
local function goldRoof(parent, pos, w, d, h, tiers)  -- หลังคาทรงไทยซ้อนชั้น สีทอง/แดง
	for t = 0, tiers - 1 do
		local scale = 1 - t * 0.28
		for _, sx in ipairs({ -1, 1 }) do
			local wp = Instance.new("WedgePart"); wp.Anchored = true; wp.Size = Vector3.new(d * scale + 2, h, w * scale / 2); wp.CFrame = CFrame.new(pos + Vector3.new(sx * w * scale / 4, t * h * 0.9 + h / 2, 0)) * CFrame.Angles(0, sx > 0 and math.rad(-90) or math.rad(90), 0); wp.Color = t % 2 == 0 and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(230, 170, 40); wp.Material = Enum.Material.Slate; wp.Parent = parent
		end
		part({ Size = Vector3.new(0.6, 3, d * scale + 2), Position = pos + Vector3.new(0, t * h * 0.9 + h + 1, 0), Color = Color3.fromRGB(240, 200, 60), Material = Enum.Material.Metal, Reflectance = 0.4 }, parent)
	end
	part({ Size = Vector3.new(0.8, 6, 0.8), Position = pos + Vector3.new(0, tiers * h * 0.9 + h + 3, d / 2), Color = Color3.fromRGB(240, 200, 60), Material = Enum.Material.Metal, Reflectance = 0.5 }, parent)  -- ช่อฟ้า
end
local function chedi(parent, pos, r, h, color)  -- เจดีย์
	for i = 0, 5 do local rr = r * (1 - i * 0.14); part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(h * 0.12, rr * 2, rr * 2), CFrame = CFrame.new(pos + Vector3.new(0, h * 0.12 * (i + 0.5), 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = color, Material = Enum.Material.Metal, Reflectance = 0.3 }, parent) end
	part({ Shape = Enum.PartType.Ball, Size = Vector3.new(r * 1.1, r * 1.1, r * 1.1), Position = pos + Vector3.new(0, h * 0.72 + r * 0.4, 0), Color = color, Material = Enum.Material.Metal, Reflectance = 0.3 }, parent)
	for i = 1, 6 do part({ Size = Vector3.new(r * 0.5 / i + 0.3, h * 0.05, r * 0.5 / i + 0.3), Position = pos + Vector3.new(0, h * 0.72 + r * 0.9 + i * h * 0.05, 0), Color = color, Material = Enum.Material.Metal, Reflectance = 0.4 }, parent) end
end
function M.build()
	if workspace:FindFirstChild("City") then return end
	local city = Instance.new("Folder"); city.Name = "City"; city.Parent = workspace
	-- พื้นดินเป็น Terrain หญ้าจริง (มีเนินเล็กน้อยรอบเมือง) + น้ำจริงในแม่น้ำ
	local Terrain = workspace.Terrain
	pcall(function()
		Terrain:Clear(); Terrain.Decoration = false
		Terrain:FillBlock(CFrame.new(40, -6, 0), Vector3.new(1400, 12, 1400), Enum.Material.Grass)
		Terrain:FillBlock(CFrame.new(40, -30, 0), Vector3.new(1400, 40, 1400), Enum.Material.Ground)
		for i = 1, 14 do  -- เนินรอบขอบเมือง
			local a = i / 14 * math.pi * 2; local hp = Vector3.new(40 + math.cos(a) * 600, 0, math.sin(a) * 600)
			Terrain:FillBall(hp + Vector3.new(0, -10, 0), 60 + (i % 3) * 20, Enum.Material.Grass)
		end
	end)
	part({ Size = Vector3.new(1000, 0.2, 1000), Position = Vector3.new(40, -0.2, 0), Color = Color3.fromRGB(90, 150, 80), Material = Enum.Material.Grass, Name = "Ground", Transparency = 1 }, city)
	-- ===== แม่น้ำเจ้าพระยา (โค้ง) + ตลิ่ง + ท่าเรือ =====
	local RIVER = { Vector3.new(-120, 0, -480), Vector3.new(-90, 0, -260), Vector3.new(-40, 0, -90), Vector3.new(-60, 0, 80), Vector3.new(-120, 0, 260), Vector3.new(-100, 0, 480) }
	M.river = RIVER
	for i = 1, #RIVER - 1 do
		local p1, p2 = RIVER[i], RIVER[i + 1]; local mid = (p1 + p2) / 2; local len = (p2 - p1).Magnitude + 30
		local cf = CFrame.lookAt(mid, p2)
		pcall(function()
			Terrain:FillBlock(cf * CFrame.new(0, -6, 0), Vector3.new(84, 14, len), Enum.Material.Air)
			Terrain:FillBlock(cf * CFrame.new(0, -9, 0), Vector3.new(84, 6, len), Enum.Material.Mud)
			Terrain:FillBlock(cf * CFrame.new(0, -3.5, 0), Vector3.new(80, 6, len), Enum.Material.Water)
		end)
		for _, sd in ipairs({ -1, 1 }) do
			part({ Size = Vector3.new(8, 1.6, len), CFrame = cf * CFrame.new(sd * 44, 0.3, 0), Color = Color3.fromRGB(170, 165, 150), Material = Enum.Material.Concrete, Name = "Bank" }, city)
			for k = -len / 2 + 15, len / 2 - 15, 30 do part({ Size = Vector3.new(0.3, 2.2, 0.3), CFrame = cf * CFrame.new(sd * 41, 2.1, k), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal }, city) end
			part({ Size = Vector3.new(0.2, 0.2, len - 20), CFrame = cf * CFrame.new(sd * 41, 3.1, 0), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal }, city)
		end
	end
	-- ท่าเรือ 2 แห่ง (ท่าช้าง ฝั่งพระนคร / ท่าวัดอรุณ ฝั่งธน)
	for _, pr in ipairs({ Vector3.new(-5, 0, -100), Vector3.new(-100, 0, -30) }) do
		part({ Size = Vector3.new(10, 0.6, 22), Position = pr + Vector3.new(0, 1.2, 0), Color = Color3.fromRGB(130, 90, 50), Material = Enum.Material.WoodPlanks, Name = "Pier" }, city)
		for i = 1, 4 do part({ Size = Vector3.new(0.8, 4, 0.8), Position = pr + Vector3.new((i % 2 == 0) and 4.6 or -4.6, 0.5, (i <= 2) and 9 or -9), Color = Color3.fromRGB(90, 60, 35), Material = Enum.Material.Wood }, city) end
		part({ Size = Vector3.new(10, 0.4, 8), Position = pr + Vector3.new(0, 6, -6), Color = Color3.fromRGB(200, 60, 50), Material = Enum.Material.Metal }, city)
	end
	-- ===== ถนนสายหลัก (ตามผังจริงย่อส่วน) =====
	road(city, Vector3.new(-10, 0, -300), Vector3.new(230, 0, -300), 22, "Ratchadamnoen")
	road(city, Vector3.new(0, 0, -390), Vector3.new(10, 0, -160), 14, "CharoenKrung")
	road(city, Vector3.new(10, 0, -160), Vector3.new(0, 0, 10), 14, "CharoenKrung")
	road(city, Vector3.new(0, 0, 10), Vector3.new(-10, 0, 160), 14, "CharoenKrung")
	road(city, Vector3.new(-10, 0, 160), Vector3.new(-40, 0, 320), 14, "CharoenKrung")
	road(city, Vector3.new(10, 0, -160), Vector3.new(200, 0, -90), 14, "Yaowarat")
	road(city, Vector3.new(0, 0, 0), Vector3.new(420, 0, 0), 18, "RamaI_Sukhumvit")
	road(city, Vector3.new(0, 0, 130), Vector3.new(200, 0, 230), 14, "Silom")
	road(city, Vector3.new(0, 0, 160), Vector3.new(300, 0, 160), 16, "Sathorn")
	road(city, Vector3.new(190, 0, -390), Vector3.new(190, 0, 260), 14, "PhayaThai")
	road(city, Vector3.new(300, 0, -390), Vector3.new(300, 0, 260), 14, "Asok")
	road(city, Vector3.new(60, 0, -390), Vector3.new(60, 0, -240), 12, "KhaoSan")
	-- ฝั่งธน: ถนนอรุณอมรินทร์ + ซอยบ้าน
	road(city, Vector3.new(-200, 0, -390), Vector3.new(-200, 0, 480), 14, "ArunAmarin")
	for _, z in ipairs({ 90, 210, 330, 450 }) do road(city, Vector3.new(-380, 0, z), Vector3.new(-200, 0, z), 10, "Soi") end
	-- สะพานข้ามแม่น้ำ: สะพานพุทธ (z -140) และสะพานตากสิน (z 150)
	for _, bz in ipairs({ -140, 150 }) do
		local bp1, bp2 = Vector3.new(-200, 0, bz), Vector3.new(10, 0, bz)
		local d = bp2 - bp1; local mid = (bp1 + bp2) / 2; local cf = CFrame.lookAt(mid, bp2)
		part({ Size = Vector3.new(16, 1.2, d.Magnitude), CFrame = cf * CFrame.new(0, 5, 0), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Concrete, Name = "Bridge" }, city)
		for _, sd in ipairs({ -1, 1 }) do part({ Size = Vector3.new(0.5, 2.5, d.Magnitude), CFrame = cf * CFrame.new(sd * 8, 6.8, 0), Color = Color3.fromRGB(40, 90, 60), Material = Enum.Material.Metal }, city) end
		for z = -60, 60, 40 do for _, sd in ipairs({ -1, 1 }) do part({ Size = Vector3.new(2, 14, 2), CFrame = cf * CFrame.new(sd * 8, 12, z), Color = Color3.fromRGB(40, 90, 60), Material = Enum.Material.Metal }, city) end end
		for _, e in ipairs({ -1, 1 }) do local wp = Instance.new("WedgePart"); wp.Anchored = true; wp.Size = Vector3.new(16, 5.6, 30); wp.CFrame = cf * CFrame.new(0, 2.8, e * (d.Magnitude / 2 + 15)) * CFrame.Angles(0, e > 0 and math.pi or 0, 0); wp.Color = Color3.fromRGB(80, 80, 85); wp.Material = Enum.Material.Concrete; wp.Parent = city end
	end
	-- ===== อาคาร =====
	local MATS = { Enum.Material.Brick, Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Marble }
	for bi, b in ipairs(BUILDINGS) do
		-- ลองใช้โมเดลจริงจาก Creator Store ก่อน ถ้าโหลดไม่ได้ค่อยสร้างจากกล่อง
		local am, asz = Assets.place(b.key, 1, b.pos, b.yaw or 0, math.max(b.size.X, 34), city)
		if am then
			M.assetsUsed += 1
			local rot = CFrame.new(b.pos) * CFrame.Angles(0, math.rad(b.yaw or 0), 0)
			local front = rot.LookVector * -1
			local doorPos = b.pos + front * (asz.Z / 2 + 4) + Vector3.new(0, 4, 0)
			local door = part({ Size = Vector3.new(8, 8, 1), CFrame = CFrame.lookAt(doorPos, doorPos + front), Transparency = 1, CanCollide = false, Name = "Entrance" }, am)
			sign(am, b.icon .. " " .. (b.label or b.key), CFrame.lookAt(b.pos + front * (asz.Z / 2 + 1) + Vector3.new(0, math.min(asz.Y + 3, 40), 0), b.pos + front * (asz.Z / 2 + 10) + Vector3.new(0, math.min(asz.Y + 3, 40), 0)) * CFrame.Angles(0, math.pi, 0), Vector3.new(30, 3.2, 0.5))
			part({ Size = Vector3.new(14, 0.3, 10), Position = b.pos + front * (asz.Z / 2 + 5) + Vector3.new(0, 0.15, 0), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Concrete }, am)
			M.buildings[b.key] = { model = am, pos = b.pos, door = door.Position + front * 4 - Vector3.new(0, 4, 0), front = front, right = rot.RightVector, size = asz }
			continue
		end
		local m = Instance.new("Model"); m.Name = b.key; m.Parent = city
		local col = Color3.fromRGB(unpack(b.color))
		local base = Vector3.new(0, 0, 0)
		part({ Size = b.size, Position = base + Vector3.new(0, b.size.Y / 2, 0), Color = col, Material = MATS[(bi - 1) % #MATS + 1], Name = "Body" }, m)
		part({ Size = Vector3.new(b.size.X + 1, 1, b.size.Z + 1), Position = base + Vector3.new(0, 0.5, 0), Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Concrete }, m)
		for i = 1, math.floor(b.size.Y / 8) do part({ Size = Vector3.new(b.size.X + 0.6, 0.4, b.size.Z + 0.6), Position = base + Vector3.new(0, i * 8, 0), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.SmoothPlastic }, m) end
		part({ Size = Vector3.new(b.size.X + 1.2, 0.8, b.size.Z + 1.2), Position = base + Vector3.new(0, b.size.Y + 0.4, 0), Color = Color3.fromRGB(70, 70, 75), Material = Enum.Material.Concrete }, m)
		part({ Size = Vector3.new(3, 3, 3), Position = base + Vector3.new(b.size.X / 3, b.size.Y + 2.3, 0), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal }, m)
		local floors = math.max(1, math.floor(b.size.Y / 6))
		for i = 1, floors do
			local y = i * 6 - 2
			for j = 1, math.floor(b.size.X / 6) do
				local x = -b.size.X / 2 + j * 6 - 3
				if not (i == 1 and math.abs(x) < 5) then
					for _, zs in ipairs({ 1, -1 }) do
						part({ Size = Vector3.new(3.6, 3, 0.3), Position = base + Vector3.new(x, y, zs * (b.size.Z / 2 + 0.15)), Color = Color3.fromRGB(120, 180, 220), Material = Enum.Material.Glass, Transparency = 0.25, CanCollide = false, Reflectance = 0.3 }, m)
						part({ Size = Vector3.new(4.2, 3.6, 0.2), Position = base + Vector3.new(x, y, zs * (b.size.Z / 2 + 0.05)), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.SmoothPlastic, CanCollide = false }, m)
					end
				end
			end
			for j = 1, math.floor(b.size.Z / 6) do
				local z = -b.size.Z / 2 + j * 6 - 3
				for _, xs in ipairs({ 1, -1 }) do part({ Size = Vector3.new(0.3, 3, 3.6), Position = base + Vector3.new(xs * (b.size.X / 2 + 0.15), y, z), Color = Color3.fromRGB(120, 180, 220), Material = Enum.Material.Glass, Transparency = 0.25, CanCollide = false, Reflectance = 0.3 }, m) end
			end
		end
		local dz = b.size.Z / 2
		part({ Size = Vector3.new(8, 8.6, 0.6), Position = base + Vector3.new(0, 4.3, dz + 0.1), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Metal, CanCollide = false }, m)
		local door = part({ Size = Vector3.new(6.6, 8, 0.4), Position = base + Vector3.new(0, 4, dz + 0.35), Color = Color3.fromRGB(150, 200, 230), Material = Enum.Material.Glass, Transparency = 0.4, Name = "Entrance", CanCollide = false }, m)
		part({ Size = Vector3.new(0.3, 7.5, 0.5), Position = base + Vector3.new(0, 4, dz + 0.4), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Metal, CanCollide = false }, m)
		part({ Size = Vector3.new(12, 0.5, 5), Position = base + Vector3.new(0, 9, dz + 2.5), Color = col:Lerp(Color3.new(0, 0, 0), 0.5), Material = Enum.Material.Metal, CanCollide = false }, m)
		for _, xs in ipairs({ -5, 5 }) do part({ Size = Vector3.new(0.5, 9, 0.5), Position = base + Vector3.new(xs, 4.5, dz + 4.5), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, m) end
		part({ Size = Vector3.new(14, 0.3, 8), Position = base + Vector3.new(0, 0.15, dz + 4), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Concrete }, m)
		local lamp = part({ Size = Vector3.new(1, 0.4, 1), Position = base + Vector3.new(0, 8.6, dz + 2.5), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon, CanCollide = false }, m)
		local pl = Instance.new("PointLight"); pl.Range = 16; pl.Brightness = 1; pl.Color = Color3.fromRGB(255, 235, 190); pl.Parent = lamp
		sign(m, b.icon .. " " .. (b.label or b.key), CFrame.new(base + Vector3.new(0, 12.5, dz + 0.6)) * CFrame.Angles(0, math.pi, 0), Vector3.new(math.min(b.size.X - 2, 34), 3.2, 0.5))
		-- หมุนทั้งอาคารให้หันหน้าออกถนน
		local rot = CFrame.new(b.pos) * CFrame.Angles(0, math.rad(b.yaw or 0), 0)
		local pivot = Instance.new("Part"); pivot.Anchored = true; pivot.Transparency = 1; pivot.CanCollide = false; pivot.Size = Vector3.new(1, 1, 1); pivot.CFrame = CFrame.new(base); pivot.Name = "Pivot"; pivot.Parent = m
		m.PrimaryPart = pivot; m:PivotTo(rot)
		local front = rot.LookVector * -1  -- ประตูอยู่ด้าน +Z ของโมเดล = ทิศตรงข้าม LookVector
		M.buildings[b.key] = { model = m, pos = b.pos, door = door.Position + front * 5, front = front, right = rot.RightVector, size = b.size }
	end
	-- ===== แลนด์มาร์ก: พระบรมมหาราชวัง (สนามหลวงหน้าวัง) =====
	do
		local gp = Vector3.new(60, 0, -430); local palace = Instance.new("Model"); palace.Name = "GrandPalace"; palace.Parent = city
		part({ Size = Vector3.new(170, 6, 90), Position = gp + Vector3.new(0, 3, 0), Color = Color3.fromRGB(245, 245, 240), Material = Enum.Material.Marble, Transparency = 1, CanCollide = false }, palace)
		for _, e in ipairs({ { Vector3.new(170, 5, 1.2), Vector3.new(0, 2.5, 45) }, { Vector3.new(170, 5, 1.2), Vector3.new(0, 2.5, -45) }, { Vector3.new(1.2, 5, 90), Vector3.new(85, 2.5, 0) }, { Vector3.new(1.2, 5, 90), Vector3.new(-85, 2.5, 0) } }) do part({ Size = e[1], Position = gp + e[2], Color = Color3.fromRGB(250, 250, 245), Material = Enum.Material.Concrete }, palace) end
		part({ Size = Vector3.new(60, 14, 30), Position = gp + Vector3.new(0, 7, 0), Color = Color3.fromRGB(250, 248, 240), Material = Enum.Material.Marble }, palace)
		goldRoof(palace, gp + Vector3.new(0, 14, 0), 60, 30, 5, 3)
		for _, cx in ipairs({ -55, 55 }) do part({ Size = Vector3.new(30, 12, 24), Position = gp + Vector3.new(cx, 6, 10), Color = Color3.fromRGB(250, 248, 240), Material = Enum.Material.Marble }, palace); goldRoof(palace, gp + Vector3.new(cx, 12, 10), 30, 24, 4, 2) end
		chedi(palace, gp + Vector3.new(-70, 0, -25), 8, 40, Color3.fromRGB(240, 200, 60))
		for i = 0, 3 do for _, sx in ipairs({ -1, 1 }) do part({ Size = Vector3.new(2, 10, 2), Position = gp + Vector3.new(sx * (10 + i * 12), 5, 16), Color = Color3.fromRGB(240, 200, 60), Material = Enum.Material.Metal, Reflectance = 0.3 }, palace) end end
		sign(palace, "🏯 Grand Palace", CFrame.new(gp + Vector3.new(0, 8, 46)) * CFrame.Angles(0, math.pi, 0), Vector3.new(30, 3.5, 0.5))
		part({ Size = Vector3.new(170, 0.4, 70), Position = gp + Vector3.new(0, 0.2, 85), Color = Color3.fromRGB(80, 165, 80), Material = Enum.Material.Grass, Name = "SanamLuang" }, city)
		part({ Size = Vector3.new(0.6, 30, 0.6), Position = gp + Vector3.new(0, 15, 85), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Metal }, city)
		for _, c in ipairs({ { 200, 40, 40, 26 }, { 245, 245, 245, 24 }, { 40, 60, 160, 22 }, { 245, 245, 245, 20 }, { 200, 40, 40, 18 } }) do part({ Size = Vector3.new(8, 1.2, 0.2), Position = gp + Vector3.new(4.3, c[4], 85), Color = Color3.fromRGB(c[1], c[2], c[3]), Material = Enum.Material.Fabric, CanCollide = false }, city) end
		M.buildings.GrandPalace = { model = palace, pos = gp, door = gp + Vector3.new(0, 0, 52) }
	end
	-- ===== วัดอรุณ (ฝั่งธน ริมน้ำ) : พระปรางค์ =====
	do
		local wp = Vector3.new(-150, 0, -40); local wat = Instance.new("Model"); wat.Name = "WatArun"; wat.Parent = city
		part({ Size = Vector3.new(60, 4, 60), Position = wp + Vector3.new(0, 2, 0), Color = Color3.fromRGB(240, 236, 225), Material = Enum.Material.Concrete }, wat)
		part({ Size = Vector3.new(40, 4, 40), Position = wp + Vector3.new(0, 6, 0), Color = Color3.fromRGB(240, 236, 225), Material = Enum.Material.Concrete }, wat)
		for i = 0, 9 do local w = 22 - i * 2; part({ Size = Vector3.new(w, 6, w), Position = wp + Vector3.new(0, 11 + i * 6, 0), Color = i % 2 == 0 and Color3.fromRGB(235, 230, 215) or Color3.fromRGB(215, 205, 190), Material = Enum.Material.Cobblestone }, wat) end
		part({ Size = Vector3.new(1.2, 10, 1.2), Position = wp + Vector3.new(0, 76, 0), Color = Color3.fromRGB(240, 200, 60), Material = Enum.Material.Metal, Reflectance = 0.5 }, wat)
		for _, o in ipairs({ { -22, -22 }, { 22, -22 }, { -22, 22 }, { 22, 22 } }) do for i = 0, 4 do local w = 8 - i * 1.4; part({ Size = Vector3.new(w, 4, w), Position = wp + Vector3.new(o[1], 6 + i * 4, o[2]), Color = Color3.fromRGB(230, 225, 210), Material = Enum.Material.Cobblestone }, wat) end end
		for i = 1, 24 do local a = i / 24 * math.pi * 2; part({ Size = Vector3.new(1.2, 3, 1.2), Position = wp + Vector3.new(math.cos(a) * 32, 5.5, math.sin(a) * 32), Color = Color3.fromRGB(250, 250, 250), Material = Enum.Material.Marble }, wat) end
		sign(wat, "🛕 Wat Arun", CFrame.new(wp + Vector3.new(0, 10, 32)) * CFrame.Angles(0, math.pi, 0), Vector3.new(22, 3, 0.5))
		M.buildings.WatArun = { model = wat, pos = wp, door = wp + Vector3.new(0, 0, 36) }
	end
	-- ===== รถไฟฟ้า BTS ยกระดับ ตามถนนพระราม 1/สุขุมวิท + สถานีสยาม/อโศก + ขบวนรถวิ่ง =====
	do
		local bts = Instance.new("Model"); bts.Name = "BTS"; bts.Parent = city
		local y, z0 = 22, 16
		for x = 0, 420, 40 do part({ Size = Vector3.new(3, y, 3), Position = Vector3.new(x, y / 2, z0), Color = Color3.fromRGB(170, 170, 175), Material = Enum.Material.Concrete }, bts) end
		part({ Size = Vector3.new(440, 2, 12), Position = Vector3.new(210, y, z0), Color = Color3.fromRGB(150, 150, 155), Material = Enum.Material.Concrete }, bts)
		for _, sd in ipairs({ -3, 3 }) do part({ Size = Vector3.new(440, 0.4, 0.5), Position = Vector3.new(210, y + 1.2, z0 + sd), Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Metal }, bts) end
		for _, sx in ipairs({ 190, 300 }) do
			part({ Size = Vector3.new(40, 0.8, 20), Position = Vector3.new(sx, y + 1.4, z0), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Concrete }, bts)
			part({ Size = Vector3.new(40, 1, 22), Position = Vector3.new(sx, y + 12, z0), Color = Color3.fromRGB(60, 140, 120), Material = Enum.Material.Metal }, bts)
			for _, o in ipairs({ { -18, -9 }, { 18, -9 }, { -18, 9 }, { 18, 9 } }) do part({ Size = Vector3.new(1, 11, 1), Position = Vector3.new(sx + o[1], y + 7, z0 + o[2]), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Metal }, bts) end
			sign(bts, "🚈 BTS " .. (sx == 190 and "Siam" or "Asok"), CFrame.new(Vector3.new(sx, y + 14.5, z0 + 11)) * CFrame.Angles(0, math.pi, 0), Vector3.new(22, 3, 0.5))
			local st = part({ Size = Vector3.new(4, 0.5, 28), CFrame = CFrame.new(sx - 22, y / 2 + 0.7, z0 + 24) * CFrame.Angles(math.rad(-38), 0, 0), Color = Color3.fromRGB(170, 170, 175), Material = Enum.Material.Concrete, Name = "Stairs" }, bts)
			st.Name = "Stairs"
		end
		local train = Instance.new("Model"); train.Name = "Train"; train.Parent = bts
		for c = 0, 2 do
			local body = part({ Size = Vector3.new(24, 6, 6), Position = Vector3.new(c * 26, y + 4.5, z0), Color = Color3.fromRGB(240, 240, 245), Material = Enum.Material.Metal, Reflectance = 0.2, CanCollide = false }, train)
			part({ Size = Vector3.new(24, 2, 0.3), Position = body.Position + Vector3.new(0, 0.5, 3.1), Color = Color3.fromRGB(60, 80, 120), Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false }, train)
			part({ Size = Vector3.new(24, 2, 0.3), Position = body.Position + Vector3.new(0, 0.5, -3.1), Color = Color3.fromRGB(60, 80, 120), Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false }, train)
			part({ Size = Vector3.new(24, 0.6, 6.4), Position = body.Position + Vector3.new(0, -3, 0), Color = Color3.fromRGB(40, 150, 110), Material = Enum.Material.Metal, CanCollide = false }, train)
			if c == 0 then train.PrimaryPart = body end
		end
		task.spawn(function()
			while train.Parent do
				for _, xs in ipairs({ { 30, 400 }, { 400, 30 } }) do
					train:PivotTo(CFrame.new(xs[1], y + 4.5, z0))
					local t0 = os.clock(); local dur = 18
					while os.clock() - t0 < dur do local a = (os.clock() - t0) / dur; a = a * a * (3 - 2 * a); train:PivotTo(CFrame.new(xs[1] + (xs[2] - xs[1]) * a, y + 4.5, z0)); task.wait() end
					task.wait(4)
				end
			end
		end)
	end
	-- ===== ตึกเติมเมือง: คอนโด/ออฟฟิศสูงย่านสีลม-สาทร-สุขุมวิท + ตึกแถวเยาวราช/เจริญกรุง =====
	local function tower(pos, w, d, h, style)
		local am = Assets.place("tower", style + 1, pos, (style * 90) % 360, math.max(w, 26), city)
		if am then M.assetsUsed += 1; return am end
		local m = Instance.new("Model"); m.Name = "Tower"; m.Parent = city
		local base = { Color3.fromRGB(200, 205, 215), Color3.fromRGB(230, 225, 215), Color3.fromRGB(160, 170, 185), Color3.fromRGB(120, 140, 170) }
		local col = base[style % #base + 1]
		part({ Size = Vector3.new(w, h, d), Position = pos + Vector3.new(0, h / 2, 0), Color = col, Material = style % 2 == 0 and Enum.Material.Concrete or Enum.Material.Metal, Name = "Body" }, m)
		local floors = math.floor(h / 8)
		for i = 1, floors do
			local lit = math.random() < 0.55
			for _, f in ipairs({ { Vector3.new(w + 0.3, 3.2, 0.3), Vector3.new(0, i * 8 - 3, d / 2 + 0.1) }, { Vector3.new(w + 0.3, 3.2, 0.3), Vector3.new(0, i * 8 - 3, -d / 2 - 0.1) }, { Vector3.new(0.3, 3.2, d + 0.3), Vector3.new(w / 2 + 0.1, i * 8 - 3, 0) }, { Vector3.new(0.3, 3.2, d + 0.3), Vector3.new(-w / 2 - 0.1, i * 8 - 3, 0) } }) do
				part({ Size = f[1], Position = pos + f[2], Color = lit and Color3.fromRGB(255, 235, 170) or Color3.fromRGB(90, 150, 200), Material = lit and Enum.Material.Neon or Enum.Material.Glass, Transparency = lit and 0.25 or 0.2, Reflectance = 0.3, CanCollide = false }, m)
			end
		end
		part({ Size = Vector3.new(w + 1, 1, d + 1), Position = pos + Vector3.new(0, h + 0.5, 0), Color = Color3.fromRGB(70, 70, 75), Material = Enum.Material.Concrete }, m)
		if h > 60 then local sp = part({ Size = Vector3.new(0.8, 12, 0.8), Position = pos + Vector3.new(0, h + 7, 0), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal }, m); local bl = part({ Size = Vector3.new(1, 1, 1), Position = pos + Vector3.new(0, h + 13.5, 0), Color = Color3.fromRGB(255, 60, 60), Material = Enum.Material.Neon }, m); local pl = Instance.new("PointLight"); pl.Color = Color3.fromRGB(255, 60, 60); pl.Range = 30; pl.Parent = bl; sp.Name = "Spire" end
		return m
	end
	local function shophouse(pos, yaw, n, neon)  -- ตึกแถว n คูหา 3 ชั้น
		local m = Instance.new("Model"); m.Name = "Shophouse"; m.Parent = city
		local cf = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
		local cols = { Color3.fromRGB(240, 225, 200), Color3.fromRGB(230, 200, 170), Color3.fromRGB(215, 225, 235), Color3.fromRGB(245, 235, 225), Color3.fromRGB(200, 215, 200) }
		for i = 0, n - 1 do
			local x = (i - (n - 1) / 2) * 12
			part({ Size = Vector3.new(12, 24, 16), CFrame = cf * CFrame.new(x, 12, 0), Color = cols[(i % #cols) + 1], Material = Enum.Material.Concrete }, m)
			part({ Size = Vector3.new(10, 7, 0.4), CFrame = cf * CFrame.new(x, 3.6, 8.2), Color = Color3.fromRGB(80, 60, 50), Material = Enum.Material.Metal }, m)                         -- ประตูม้วน
			part({ Size = Vector3.new(11, 0.4, 4), CFrame = cf * CFrame.new(x, 8, 10), Color = Color3.fromRGB(180, 40, 40), Material = Enum.Material.Metal }, m)                             -- กันสาด
			for fl = 1, 2 do part({ Size = Vector3.new(6, 4, 0.3), CFrame = cf * CFrame.new(x, 8 + fl * 7, 8.2), Color = Color3.fromRGB(120, 180, 220), Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false }, m); part({ Size = Vector3.new(8, 0.3, 2), CFrame = cf * CFrame.new(x, 6 + fl * 7, 9), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Concrete }, m) end
			if neon then
				local c = ({ Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 200, 40), Color3.fromRGB(60, 220, 120), Color3.fromRGB(255, 80, 200) })[(i % 4) + 1]
				local np = part({ Size = Vector3.new(2, 7, 0.4), CFrame = cf * CFrame.new(x + 5, 15, 9.5), Color = c, Material = Enum.Material.Neon }, m)
				local l = Instance.new("PointLight"); l.Color = c; l.Range = 18; l.Brightness = 1; l.Parent = np
				local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.CanvasSize = Vector2.new(100, 350); g.Parent = np
				local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundTransparency = 1; t.TextScaled = true; t.Font = Enum.Font.GothamBlack; t.TextColor3 = Color3.new(1, 1, 1); t.Text = ({ "金", "福", "龍", "茶" })[(i % 4) + 1]; t.Parent = g
			end
		end
		part({ Size = Vector3.new(n * 12 + 1, 1, 17), CFrame = cf * CFrame.new(0, 24.5, 0), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Concrete }, m)
		return m
	end
	local function palm(pos)
		local am = Assets.place("palm", math.random(1, 2), pos, math.random(0, 359), 12, city)
		if am then return am end
		part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(14, 1, 1), CFrame = CFrame.new(pos + Vector3.new(0, 7, 0)) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(0, 0, math.rad(4)), Color = Color3.fromRGB(120, 90, 60), Material = Enum.Material.Wood }, city)
		for i = 1, 6 do local a = i / 6 * math.pi * 2; local leaf = Instance.new("WedgePart"); leaf.Anchored = true; leaf.CanCollide = false; leaf.Size = Vector3.new(1.6, 0.4, 7); leaf.CFrame = CFrame.new(pos + Vector3.new(0, 14, 0)) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -3.5) * CFrame.Angles(math.rad(-25), 0, 0); leaf.Color = Color3.fromRGB(50, 150, 60); leaf.Material = Enum.Material.Grass; leaf.Parent = city end
	end
	math.randomseed(7)
	-- สีลม/สาทร: ตึกสูง
	for _, t in ipairs({ { 20, 260, 26, 26, 90, 1 }, { 110, 270, 30, 24, 120, 0 }, { 230, 260, 24, 24, 80, 2 }, { 300, 230, 22, 22, 70, 3 }, { 120, 140, 20, 20, 60, 1 }, { 30, 110, 22, 20, 50, 2 }, { 260, 120, 24, 22, 66, 0 } }) do tower(Vector3.new(t[1], 0, t[2]), t[3], t[4], t[5], t[6]) end
	-- สุขุมวิท/อโศก: คอนโด
	for _, t in ipairs({ { 400, -240, 24, 30, 70, 3 }, { 400, -120, 28, 28, 90, 0 }, { 400, 40, 26, 26, 60, 1 }, { 400, 140, 24, 24, 76, 2 }, { 250, -240, 26, 26, 56, 1 }, { 250, -150, 22, 22, 44, 3 }, { 120, -30, 24, 24, 48, 2 }, { 20, -60, 22, 22, 40, 0 } }) do tower(Vector3.new(t[1], 0, t[2]), t[3], t[4], t[5], t[6]) end
	-- เยาวราช: ตึกแถว + ป้ายนีออนจีน สองฝั่งถนน
	local yA, yB = Vector3.new(10, 0, -160), Vector3.new(200, 0, -90); local ydir = (yB - yA).Unit; local yaw = math.atan2(-ydir.X, -ydir.Z)
	for _, sd in ipairs({ -1, 1 }) do for k = 0.18, 0.85, 0.3 do local c = yA + (yB - yA) * k; local nrm = Vector3.new(-ydir.Z, 0, ydir.X) * sd * 22; shophouse(c + nrm, yaw + (sd > 0 and math.pi / 2 or -math.pi / 2), 4, true) end end
	-- เจริญกรุง/ท่าช้าง: ตึกแถวริมน้ำ + ราชดำเนิน: ตึกแถวสไตล์เก่า
	for _, z in ipairs({ -320, -240, 60, 120 }) do shophouse(Vector3.new(30, 0, z), math.rad(-90), 4, false) end
	for _, x in ipairs({ 40, 110, 190 }) do shophouse(Vector3.new(x, 0, -270), 0, 5, false); shophouse(Vector3.new(x, 0, -330), math.pi, 5, false) end
	-- ต้นปาล์ม/ต้นไม้ริมน้ำ ริมถนน สวน
	for _, pt in ipairs(RIVER) do palm(pt + Vector3.new(50, 0, 10)); palm(pt + Vector3.new(-50, 0, -10)) end
	for x = 20, 400, 45 do palm(Vector3.new(x, 0, -30)) end
	for i = 1, 30 do tree(city, Vector3.new(math.random(-380, -230), 0, math.random(-380, 20)), 0.8 + math.random() * 0.6) end
	for i = 1, 20 do tree(city, Vector3.new(math.random(20, 420), 0, math.random(260, 440)), 0.8 + math.random() * 0.6) end
	-- คลอง (ฝั่งธน) + สะพานไม้
	pcall(function()
		local k1, k2 = Vector3.new(-380, 0, 0), Vector3.new(-200, 0, -20)
		local cfk = CFrame.lookAt((k1 + k2) / 2, k2)
		Terrain:FillBlock(cfk * CFrame.new(0, -3, 0), Vector3.new(14, 6, (k2 - k1).Magnitude), Enum.Material.Air)
		Terrain:FillBlock(cfk * CFrame.new(0, -2.5, 0), Vector3.new(12, 4, (k2 - k1).Magnitude), Enum.Material.Water)
		part({ Size = Vector3.new(4, 0.4, 18), CFrame = cfk * CFrame.new(0, 1.2, 0) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.fromRGB(130, 90, 50), Material = Enum.Material.WoodPlanks }, city)
	end)
	-- เรือด่วนเจ้าพระยา / เรือหางยาว วิ่งตามแม่น้ำ
	for bi = 1, 3 do
		local boat = Instance.new("Model"); boat.Name = "Boat"; boat.Parent = city
		local long = bi == 3
		local hull = part({ Size = long and Vector3.new(4, 2, 22) or Vector3.new(8, 3, 26), Position = Vector3.new(0, 0, 0), Color = long and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(240, 240, 240), Material = Enum.Material.Wood, CanCollide = false }, boat)
		boat.PrimaryPart = hull
		part({ Size = long and Vector3.new(3.6, 2, 12) or Vector3.new(7, 3, 16), Position = Vector3.new(0, 2.4, -2), Color = long and Color3.fromRGB(40, 90, 200) or Color3.fromRGB(230, 120, 40), Material = Enum.Material.Fabric, CanCollide = false }, boat)
		local bow = Instance.new("WedgePart"); bow.Anchored = true; bow.CanCollide = false; bow.Size = long and Vector3.new(4, 2, 6) or Vector3.new(8, 3, 8); bow.CFrame = hull.CFrame * CFrame.new(0, 0, long and -14 or -17) * CFrame.Angles(0, math.pi, 0); bow.Color = hull.Color; bow.Material = Enum.Material.Wood; bow.Parent = boat
		task.spawn(function()
			local idx = bi; local dir = 1
			while boat.Parent do
				local p1 = RIVER[idx]; local p2 = RIVER[idx + dir]
				if not p2 then dir = -dir; p2 = RIVER[idx + dir] end
				local off = Vector3.new(bi * 10 - 20, 0, 0)
				local dist = (p2 - p1).Magnitude; local dur = dist / (long and 16 or 10)
				local t0 = os.clock()
				while os.clock() - t0 < dur and boat.Parent do local a = (os.clock() - t0) / dur; boat:PivotTo(CFrame.lookAt(p1:Lerp(p2, a) + off + Vector3.new(0, 0.3, 0), p2 + off) * CFrame.new(0, math.sin(os.clock() * 2) * 0.15, 0)); task.wait() end
				idx += dir
				if idx >= #RIVER or idx <= 1 then dir = -dir end
			end
		end)
	end
	-- ===== ตลาดนัดจตุจักร (เหนือสุขุมวิท) : แผงลอยหลังคาสี =====
	do
		local jj = Vector3.new(330, 0, -300); local mk = Instance.new("Model"); mk.Name = "Chatuchak"; mk.Parent = city
		part({ Size = Vector3.new(120, 0.4, 80), Position = jj + Vector3.new(0, 0.2, 0), Color = Color3.fromRGB(180, 170, 150), Material = Enum.Material.Concrete }, mk)
		for r = 0, 3 do for c = 0, 7 do
			local sp = jj + Vector3.new(-52 + c * 15, 0, -30 + r * 20)
			part({ Size = Vector3.new(10, 3, 5), Position = sp + Vector3.new(0, 1.9, 0), Color = Color3.fromRGB(150, 110, 70), Material = Enum.Material.Wood }, mk)
			for _, o in ipairs({ -4.5, 4.5 }) do part({ Size = Vector3.new(0.4, 8, 0.4), Position = sp + Vector3.new(o, 4.4, -2), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Metal }, mk) end
			part({ Size = Vector3.new(11, 0.4, 8), Position = sp + Vector3.new(0, 8.5, 0), Color = Color3.fromHSV(((r * 8 + c) % 7) / 7, 0.7, 0.9), Material = Enum.Material.Fabric }, mk)
			for k = 1, 3 do part({ Size = Vector3.new(1.5, 1.5, 1.5), Position = sp + Vector3.new(-3 + k * 1.8, 4.2, 0), Color = Color3.fromHSV(math.random(), 0.6, 0.95), Material = Enum.Material.SmoothPlastic, CanCollide = false }, mk) end
		end end
		sign(mk, "🛍️ Chatuchak Market", CFrame.new(jj + Vector3.new(0, 8, 42)) * CFrame.Angles(0, math.pi, 0), Vector3.new(30, 3.5, 0.5))
		M.buildings.Chatuchak = { model = mk, pos = jj, door = jj + Vector3.new(0, 0, 46) }
	end
	-- ===== เสาไฟ ต้นไม้ริมถนน แท็กซี่/ตุ๊กตุ๊ก =====
	for x = -20, 420, 60 do lampAt(city, Vector3.new(x, 0, 12)); lampAt(city, Vector3.new(x, 0, -12)); if x % 120 == 40 then tree(city, Vector3.new(x + 30, 0, 14)) end end
	for x = 0, 220, 55 do lampAt(city, Vector3.new(x, 0, -312)); tree(city, Vector3.new(x + 20, 0, -316), 1.1); tree(city, Vector3.new(x + 20, 0, -284), 1.1) end
	for z = -380, 460, 60 do lampAt(city, Vector3.new(-208, 0, z)); if z % 120 == 40 then tree(city, Vector3.new(-192, 0, z)) end end
	for z = -380, 240, 80 do lampAt(city, Vector3.new(198, 0, z)); lampAt(city, Vector3.new(308, 0, z)) end
	local TAXI = { { 240, 80, 160 }, { 40, 180, 90 }, { 250, 210, 40 }, { 240, 80, 160 }, { 60, 90, 200 }, { 235, 235, 235 } }
	for i, spot in ipairs({ { 40, 5, 0 }, { 120, -5, 180 }, { 260, 5, 0 }, { 380, -5, 180 }, { 195, -130, 90 }, { 185, 100, 270 } }) do
		M.car(Vector3.new(spot[1], 0.4, spot[2]), Color3.fromRGB(unpack(TAXI[i])), city, math.rad(spot[3]))
	end
	for _, spot in ipairs({ Vector3.new(70, 0, -280), Vector3.new(30, 0, -120), Vector3.new(220, 0, -30) }) do M.tuktuk(spot, city) end
	-- ===== สวนลุมพินี =====
	local park = Instance.new("Model"); park.Name = "Park"; park.Parent = city
	local PC = Vector3.new(230, 0, 80)
	-- รั้วเตี้ย + ทางเข้า
	for _, e in ipairs({ { Vector3.new(70, 1.2, 0.4), Vector3.new(0, 0.9, 28) }, { Vector3.new(0.4, 1.2, 56), Vector3.new(-35, 0.9, 0) }, { Vector3.new(0.4, 1.2, 56), Vector3.new(35, 0.9, 0) }, { Vector3.new(28, 1.2, 0.4), Vector3.new(-21, 0.9, -28) }, { Vector3.new(28, 1.2, 0.4), Vector3.new(21, 0.9, -28) } }) do
		part({ Size = e[1], Position = PC + e[2], Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal }, park)
	end
	-- ทางเดินหินจากทางเข้าไปน้ำพุ + วงแหวนรอบน้ำพุ
	part({ Size = Vector3.new(8, 0.3, 22), Position = PC + Vector3.new(0, 0.4, -17), Color = Color3.fromRGB(190, 180, 165), Material = Enum.Material.Cobblestone }, park)
	for i = 0, 23 do
		local a1 = i / 24 * math.pi * 2
		part({ Size = Vector3.new(5, 0.3, 4.5), CFrame = CFrame.new(PC + Vector3.new(math.cos(a1) * 15, 0.4, math.sin(a1) * 15)) * CFrame.Angles(0, -a1, 0), Color = Color3.fromRGB(190, 180, 165), Material = Enum.Material.Cobblestone }, park)
	end
	-- น้ำพุ 3 ชั้น
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, 20, 20), CFrame = CFrame.new(PC + Vector3.new(0, 0.9, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Marble }, park)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 18, 18), CFrame = CFrame.new(PC + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(70, 170, 230), Material = Enum.Material.Glass, Transparency = 0.35, Reflectance = 0.3, Name = "Pond" }, park)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 2, 2), CFrame = CFrame.new(PC + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Marble }, park)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.8, 9, 9), CFrame = CFrame.new(PC + Vector3.new(0, 5.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Marble }, park)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 8, 8), CFrame = CFrame.new(PC + Vector3.new(0, 5.7, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(70, 170, 230), Material = Enum.Material.Glass, Transparency = 0.35 }, park)
	local jet = part({ Size = Vector3.new(0.6, 6, 0.6), Position = PC + Vector3.new(0, 8.5, 0), Color = Color3.fromRGB(200, 230, 255), Material = Enum.Material.Neon, Transparency = 0.4, CanCollide = false }, park)
	local pe = Instance.new("ParticleEmitter"); pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"; pe.Rate = 40; pe.Speed = NumberRange.new(6, 9); pe.Lifetime = NumberRange.new(0.8, 1.4); pe.Color = ColorSequence.new(Color3.fromRGB(200, 235, 255)); pe.Size = NumberSequence.new(0.6); pe.Acceleration = Vector3.new(0, -14, 0); pe.SpreadAngle = Vector2.new(25, 25); pe.Parent = jet
	local fl = Instance.new("PointLight"); fl.Color = Color3.fromRGB(150, 200, 255); fl.Range = 18; fl.Brightness = 1.5; fl.Parent = jet
	-- แปลงดอกไม้ 4 มุม
	for _, q in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
		local fp = PC + Vector3.new(q[1] * 26, 0, q[2] * 20)
		part({ Size = Vector3.new(10, 0.8, 8), Position = fp + Vector3.new(0, 0.6, 0), Color = Color3.fromRGB(110, 75, 45), Material = Enum.Material.Ground }, park)
		for i = 1, 14 do part({ Shape = Enum.PartType.Ball, Size = Vector3.new(1.1, 1.1, 1.1), Position = fp + Vector3.new(math.random(-4, 4), 1.4, math.random(-3, 3)), Color = ({ Color3.fromRGB(255, 80, 120), Color3.fromRGB(255, 210, 60), Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 90, 230) })[math.random(4)], Material = Enum.Material.Grass, CanCollide = false }, park) end
	end
	-- ต้นไม้ (ลำต้น + พุ่ม 3 ลูกซ้อน) รอบสวน
	for i = 1, 10 do
		local a1 = i / 10 * math.pi * 2
		local tp = PC + Vector3.new(math.cos(a1) * 30, 0, math.sin(a1) * 23)
		part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(7, 1.4, 1.4), CFrame = CFrame.new(tp + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(95, 65, 40), Material = Enum.Material.Wood }, park)
		for _, o in ipairs({ { 0, 9, 0, 9 }, { 2.5, 11, 1.5, 6.5 }, { -2.5, 11.5, -1.5, 6 } }) do part({ Shape = Enum.PartType.Ball, Size = Vector3.new(o[4], o[4], o[4]), Position = tp + Vector3.new(o[1], o[2], o[3]), Color = Color3.fromRGB(40 + i * 3, 130 + (i % 3) * 12, 50), Material = Enum.Material.Grass, CanCollide = false }, park) end
	end
	-- ม้านั่งมีพนัก + ถังขยะ + โคมไฟสวน
	for i = 0, 7 do
		local a1 = i / 8 * math.pi * 2 + math.pi / 8
		local bp = PC + Vector3.new(math.cos(a1) * 19, 0, math.sin(a1) * 19)
		local look = CFrame.lookAt(bp, PC)
		part({ Size = Vector3.new(5, 0.4, 1.6), CFrame = look * CFrame.new(0, 1.6, 0), Color = Color3.fromRGB(150, 105, 60), Material = Enum.Material.Wood, Name = "Bench" }, park)
		part({ Size = Vector3.new(5, 1.6, 0.3), CFrame = look * CFrame.new(0, 2.4, 0.75) * CFrame.Angles(math.rad(-10), 0, 0), Color = Color3.fromRGB(150, 105, 60), Material = Enum.Material.Wood }, park)
		for _, sx in ipairs({ -2.2, 2.2 }) do part({ Size = Vector3.new(0.3, 1.4, 1.6), CFrame = look * CFrame.new(sx, 0.9, 0), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal }, park) end
		if i % 2 == 0 then
			part({ Size = Vector3.new(0.4, 9, 0.4), CFrame = look * CFrame.new(3.5, 4.5, 0), Color = Color3.fromRGB(30, 30, 35), Material = Enum.Material.Metal }, park)
			local lamp = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(1.6, 1.6, 1.6), CFrame = look * CFrame.new(3.5, 9.5, 0), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon }, park)
			local l = Instance.new("PointLight"); l.Range = 20; l.Brightness = 0.8; l.Color = Color3.fromRGB(255, 225, 170); l.Parent = lamp
		else
			part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.6, 1.6, 1.6), CFrame = look * CFrame.new(3.5, 1.3, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(60, 110, 70), Material = Enum.Material.Metal }, park)
		end
	end
	-- สนามเด็กเล่น (สไลเดอร์ + ชิงช้า) มุมขวาบน
	local pg = PC + Vector3.new(24, 0, 0)
	part({ Size = Vector3.new(16, 0.3, 14), Position = pg + Vector3.new(0, 0.45, 0), Color = Color3.fromRGB(230, 170, 110), Material = Enum.Material.Sand }, park)
	part({ Size = Vector3.new(3, 6, 3), Position = pg + Vector3.new(-5, 3.5, -3), Color = Color3.fromRGB(240, 90, 90), Material = Enum.Material.SmoothPlastic }, park)
	local slide = Instance.new("WedgePart"); slide.Anchored = true; slide.Size = Vector3.new(3, 6, 9); slide.CFrame = CFrame.new(pg + Vector3.new(-5, 3.5, 3)); slide.Color = Color3.fromRGB(250, 200, 60); slide.Material = Enum.Material.SmoothPlastic; slide.Parent = park
	for _, sx in ipairs({ -3, 3 }) do part({ Size = Vector3.new(0.4, 8, 0.4), Position = pg + Vector3.new(4 + sx, 4.5, -3), Color = Color3.fromRGB(60, 120, 200), Material = Enum.Material.Metal }, park) end
	part({ Size = Vector3.new(7, 0.4, 0.4), Position = pg + Vector3.new(4, 8.5, -3), Color = Color3.fromRGB(60, 120, 200), Material = Enum.Material.Metal }, park)
	for _, sx in ipairs({ -1.2, 1.2 }) do
		part({ Size = Vector3.new(0.15, 5, 0.15), Position = pg + Vector3.new(4 + sx, 6, -3), Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Metal, CanCollide = false }, park)
	end
	part({ Size = Vector3.new(2.6, 0.3, 1), Position = pg + Vector3.new(4, 3.4, -3), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Rubber }, park)
	-- ศาลาแปดเหลี่ยม มุมซ้าย
	local gz = PC + Vector3.new(-24, 0, 0)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 14, 14), CFrame = CFrame.new(gz + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(190, 180, 165), Material = Enum.Material.Cobblestone }, park)
	for i = 0, 7 do local a1 = i / 8 * math.pi * 2; part({ Size = Vector3.new(0.6, 9, 0.6), Position = gz + Vector3.new(math.cos(a1) * 6, 5, math.sin(a1) * 6), Color = Color3.fromRGB(245, 245, 245), Material = Enum.Material.Wood }, park) end
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5, 15, 15), CFrame = CFrame.new(gz + Vector3.new(0, 9.7, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(120, 60, 50), Material = Enum.Material.Slate }, park)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.5, 10, 10), CFrame = CFrame.new(gz + Vector3.new(0, 11.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(120, 60, 50), Material = Enum.Material.Slate }, park)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 5, 5), CFrame = CFrame.new(gz + Vector3.new(0, 13.4, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(120, 60, 50), Material = Enum.Material.Slate }, park)
	local gs = sign(park, "🌳 Central Park", CFrame.new(PC + Vector3.new(0, 4.5, -30)) * CFrame.Angles(0, math.pi, 0), Vector3.new(14, 2.4, 0.5)); gs.Position = PC + Vector3.new(0, 4.5, -30)
	for _, sx in ipairs({ -6.5, 6.5 }) do part({ Size = Vector3.new(1, 5.5, 1), Position = PC + Vector3.new(sx, 2.75, -30), Color = Color3.fromRGB(190, 180, 165), Material = Enum.Material.Cobblestone }, park) end
	M.buildings.Park = { model = park, pos = PC, door = PC + Vector3.new(0, 0, -32) }
	-- ที่ดินบ้าน 12 แปลง (2 แถว) ผู้เล่นละ 1 แปลง
	local lots = Instance.new("Folder"); lots.Name = "Lots"; lots.Parent = workspace
	for i = 1, 12 do
		local row = (i - 1) // 3; local col = (i - 1) % 3
		local origin = Vector3.new(-350 + col * 54, 0, 55 + row * 120)
		local f = Instance.new("Model"); f.Name = "Lot_" .. i; f.Parent = lots
		local ground = part({ Size = Vector3.new(44, 0.5, 44), Position = origin + Vector3.new(0, 0.25, 0), Color = Color3.fromRGB(190, 175, 150), Material = Enum.Material.Concrete, Name = "Floor" }, f)
		ground:SetAttribute("LotIndex", i)
		local ns = sign(f, "For sale", CFrame.new(origin + Vector3.new(0, 5, -23)) * CFrame.Angles(0, math.pi, 0), Vector3.new(12, 2.5, 0.5)); ns.Name = "NameSign"
		for _, side in ipairs({ -1, 1 }) do part({ Size = Vector3.new(0.4, 2.5, 44), Position = origin + Vector3.new(side * 22, 1.5, 0), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.Wood }, f) end
		part({ Size = Vector3.new(16, 2.5, 0.4), Position = origin + Vector3.new(-14, 1.5, 22), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.Wood }, f)
		part({ Size = Vector3.new(10, 2.5, 0.4), Position = origin + Vector3.new(17, 1.5, 22), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.Wood }, f)
		part({ Size = Vector3.new(10, 0.3, 14), Position = origin + Vector3.new(14, 0.55, -18), Color = Color3.fromRGB(160, 160, 165), Material = Enum.Material.Concrete, Name = "Driveway" }, f)
		part({ Size = Vector3.new(1, 3, 1), Position = origin + Vector3.new(-16, 1.5, -22), Color = Color3.fromRGB(60, 60, 60), Material = Enum.Material.Metal }, f)
		part({ Size = Vector3.new(1.4, 1, 2), Position = origin + Vector3.new(-16, 3.3, -22), Color = Color3.fromRGB(60, 90, 180), Material = Enum.Material.Metal, Name = "Mailbox" }, f)
		part({ Size = Vector3.new(44, 0.4, 44), Position = origin + Vector3.new(0, 0.25, 0), Color = Color3.fromRGB(80, 160, 80), Material = Enum.Material.Grass, CanCollide = false, Transparency = 1 }, f)
		M.lots[i] = { index = i, origin = origin, model = f, owner = nil }
		M.houseShell(f, origin, i)
	end
	-- อพาร์ตเมนต์: ตึก 3 ชั้น ×4 ห้อง มีผนังนอก หน้าต่าง ระเบียง ทางเดินหน้าห้อง บันได หลังคา ป้าย
	local apts = Instance.new("Folder"); apts.Name = "Apartments"; apts.Parent = workspace
	local AX, AZ = 340, -60            -- กึ่งกลางตึก (สุขุมวิท)
	local RW, RD, FH = 28, 26, 12      -- กว้างห้อง ลึกห้อง สูงชั้น
	local BW = RW * 4 + 2              -- กว้างตึก
	local facade = Color3.fromRGB(225, 215, 195)
	-- ฐาน + ทางเดินหน้าตึก
	part({ Size = Vector3.new(BW + 16, 0.6, RD + 26), Position = Vector3.new(AX, 0.3, AZ + 4), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Concrete }, apts)
	for i = 1, 12 do
		local floor = (i - 1) // 4; local col = (i - 1) % 4
		local origin = Vector3.new(AX - BW / 2 + 1 + RW / 2 + col * RW, 0.6 + floor * FH, AZ)
		local f = Instance.new("Model"); f.Name = "Apt_" .. i; f.Parent = apts
		part({ Size = Vector3.new(RW, 0.5, RD), Position = origin, Color = Color3.fromRGB(205, 185, 150), Material = Enum.Material.WoodPlanks, Name = "Floor" }, f)
		part({ Size = Vector3.new(RW, 0.4, RD), Position = origin + Vector3.new(0, FH - 0.2, 0), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.SmoothPlastic, Name = "Ceiling" }, f)
		-- ผนัง: หลัง ซ้าย ขวา (ผนังภายในสีอ่อน) หน้า = ประตู + หน้าต่าง
		part({ Size = Vector3.new(RW, FH, 0.6), Position = origin + Vector3.new(0, FH / 2, -RD / 2), Color = facade, Material = Enum.Material.Concrete, Name = "Wall" }, f)
		part({ Size = Vector3.new(0.5, FH, RD), Position = origin + Vector3.new(-RW / 2, FH / 2, 0), Color = Color3.fromRGB(245, 240, 230), Material = Enum.Material.SmoothPlastic, Name = "Wall" }, f)
		part({ Size = Vector3.new(0.5, FH, RD), Position = origin + Vector3.new(RW / 2, FH / 2, 0), Color = Color3.fromRGB(245, 240, 230), Material = Enum.Material.SmoothPlastic, Name = "Wall" }, f)
		part({ Size = Vector3.new(RW / 2 - 3, FH, 0.6), Position = origin + Vector3.new(-RW / 4 - 1.5, FH / 2, RD / 2), Color = facade, Material = Enum.Material.Concrete, Name = "Wall" }, f)
		part({ Size = Vector3.new(RW / 2 - 3, FH, 0.6), Position = origin + Vector3.new(RW / 4 + 1.5, FH / 2, RD / 2), Color = facade, Material = Enum.Material.Concrete, Name = "Wall" }, f)
		part({ Size = Vector3.new(6, FH - 8, 0.6), Position = origin + Vector3.new(0, FH - 2, RD / 2), Color = facade, Material = Enum.Material.Concrete, Name = "Wall" }, f)
		-- ประตูไม้ (เปิดค้าง = ช่องว่าง) + กรอบ + หน้าต่างหน้า/หลัง
		part({ Size = Vector3.new(6.4, 8.4, 0.3), Position = origin + Vector3.new(0, 4.2, RD / 2 + 0.3), Color = Color3.fromRGB(90, 60, 40), Material = Enum.Material.Wood, CanCollide = false, Transparency = 0.999 }, f)
		part({ Size = Vector3.new(0.4, 8.4, 0.9), Position = origin + Vector3.new(-3.2, 4.2, RD / 2), Color = Color3.fromRGB(120, 80, 50), Material = Enum.Material.Wood }, f)
		part({ Size = Vector3.new(0.4, 8.4, 0.9), Position = origin + Vector3.new(3.2, 4.2, RD / 2), Color = Color3.fromRGB(120, 80, 50), Material = Enum.Material.Wood }, f)
		for _, wx in ipairs({ -RW / 4 - 1.5, RW / 4 + 1.5 }) do
			part({ Size = Vector3.new(6, 4, 0.3), Position = origin + Vector3.new(wx, 6.5, RD / 2 + 0.2), Color = Color3.fromRGB(140, 200, 235), Material = Enum.Material.Glass, Transparency = 0.3, Reflectance = 0.2, CanCollide = false }, f)
			part({ Size = Vector3.new(6, 4, 0.3), Position = origin + Vector3.new(wx, 6.5, -RD / 2 - 0.2), Color = Color3.fromRGB(140, 200, 235), Material = Enum.Material.Glass, Transparency = 0.3, Reflectance = 0.2, CanCollide = false }, f)
		end
		-- ผนังกั้นห้องน้ำ (ขวาหลัง) + เคาน์เตอร์ครัว (ขวาหน้า)
		part({ Size = Vector3.new(0.3, FH, 8), Position = origin + Vector3.new(6, FH / 2, -9), Color = Color3.fromRGB(245, 240, 232), Material = Enum.Material.SmoothPlastic, Name = "Wall" }, f)
		part({ Size = Vector3.new(5, FH, 0.3), Position = origin + Vector3.new(11.5, FH / 2, -5), Color = Color3.fromRGB(245, 240, 232), Material = Enum.Material.SmoothPlastic, Name = "Wall" }, f)
		part({ Size = Vector3.new(8, 0.15, 8), Position = origin + Vector3.new(10, 0.33, -9), Color = Color3.fromRGB(225, 230, 235), Material = Enum.Material.Marble, CanCollide = false }, f)
		part({ Size = Vector3.new(2, 3, 6), Position = origin + Vector3.new(13, 1.75, 2), Color = Color3.fromRGB(235, 235, 235), Material = Enum.Material.SmoothPlastic, Name = "Counter" }, f)
		part({ Size = Vector3.new(2.2, 0.15, 6.2), Position = origin + Vector3.new(13, 3.3, 2), Color = Color3.fromRGB(70, 70, 75), Material = Enum.Material.Granite }, f)
		part({ Size = Vector3.new(1.4, 0.3, 1.8), Position = origin + Vector3.new(13, 3.25, 0.5), Color = Color3.fromRGB(190, 190, 195), Material = Enum.Material.Metal }, f)
		part({ Size = Vector3.new(1.2, 2.2, 6), Position = origin + Vector3.new(13.4, 7.5, 2), Color = Color3.fromRGB(235, 235, 235), Material = Enum.Material.SmoothPlastic }, f)
		-- โคมไฟเพดาน
		local lamp = part({ Size = Vector3.new(2, 0.3, 2), Position = origin + Vector3.new(0, FH - 0.6, 0), Color = Color3.fromRGB(255, 245, 220), Material = Enum.Material.SmoothPlastic, CanCollide = false }, f)
		local l = Instance.new("PointLight"); l.Range = 18; l.Brightness = 0.45; l.Shadows = true; l.Color = Color3.fromRGB(255, 240, 210); l.Parent = lamp
		local ns = sign(f, "Apt " .. i, CFrame.new(origin + Vector3.new(0, FH - 1.5, RD / 2 + 0.5)) * CFrame.Angles(0, math.pi, 0), Vector3.new(8, 1.6, 0.4)); ns.Name = "NameSign"
		M.lots["apt" .. i] = { index = "apt" .. i, origin = origin + Vector3.new(0, 0.25, 0), model = f, owner = nil, apartment = true }
	end
	-- ทางเดินหน้าห้อง (ระเบียงยาว) + ราวกันตก แต่ละชั้น
	for floor = 0, 2 do
		local y = 0.6 + floor * FH
		part({ Size = Vector3.new(BW + 4, 0.6, 8), Position = Vector3.new(AX, y - 0.3, AZ + RD / 2 + 4), Color = Color3.fromRGB(190, 190, 195), Material = Enum.Material.Concrete }, apts)
		if floor > 0 then
			part({ Size = Vector3.new(BW + 4, 0.2, 0.2), Position = Vector3.new(AX, y + 3.5, AZ + RD / 2 + 8), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal }, apts)
			for x = -BW / 2, BW / 2, 4 do part({ Size = Vector3.new(0.2, 3.6, 0.2), Position = Vector3.new(AX + x, y + 1.8, AZ + RD / 2 + 8), Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal }, apts) end
		end
	end
	-- บันไดข้างตึก (ทางลาดขึ้นแต่ละชั้น) + หลังคา + ป้ายชื่อตึก
	for floor = 0, 2 do
		local ramp = part({ Size = Vector3.new(6, 0.5, 34), CFrame = CFrame.new(AX + BW / 2 + 6, 0.6 + floor * FH + FH / 2, AZ + RD / 2 + 4 + (floor % 2 == 0 and 0 or 0)) * CFrame.Angles(math.rad(floor % 2 == 0 and -20 or 20), 0, 0), Color = Color3.fromRGB(170, 170, 175), Material = Enum.Material.Concrete, Name = "Stairs" }, apts)
		ramp.CFrame = CFrame.new(AX + BW / 2 + 6, 0.6 + floor * FH + FH / 2 + 0.3, AZ + RD / 2 + 4) * CFrame.Angles(math.rad(floor % 2 == 0 and -21 or 21), 0, 0)
		part({ Size = Vector3.new(8, 0.6, 10), Position = Vector3.new(AX + BW / 2 + 6, 0.6 + (floor + 1) * FH - 0.3, AZ + RD / 2 + 4 + (floor % 2 == 0 and 17 or -17)), Color = Color3.fromRGB(190, 190, 195), Material = Enum.Material.Concrete }, apts)
	end
	part({ Size = Vector3.new(BW + 6, 1, RD + 12), Position = Vector3.new(AX, 0.6 + 3 * FH + 0.5, AZ + 3), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Concrete }, apts)
	part({ Size = Vector3.new(BW + 6, 1.5, 0.5), Position = Vector3.new(AX, 0.6 + 3 * FH + 1.7, AZ - RD / 2 - 3), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Concrete }, apts)
	sign(apts, "🏢 Sukhumvit Apartments", CFrame.new(Vector3.new(AX, 0.6 + 3 * FH + 4, AZ + RD / 2 + 8)) * CFrame.Angles(0, math.pi, 0), Vector3.new(40, 4, 0.5))
	M.buildings.Apartments = { model = apts, pos = Vector3.new(AX, 0, AZ), door = Vector3.new(AX, 0, AZ + RD / 2 + 14) }
	-- สปอน
	local spawn = Instance.new("SpawnLocation"); spawn.Size = Vector3.new(10, 0.4, 10); spawn.Position = Vector3.new(160, 0.35, -30); spawn.Anchored = true; spawn.Neutral = true; spawn.Transparency = 1; spawn.CanCollide = false; spawn.Parent = city
	local dec = spawn:FindFirstChildOfClass("Decal"); if dec then dec:Destroy() end
	-- แสงบรรยากาศ
	local L = game:GetService("Lighting"); L.Brightness = 1.6; L.Ambient = Color3.fromRGB(120, 125, 140); L.OutdoorAmbient = Color3.fromRGB(140, 145, 160); L.EnvironmentDiffuseScale = 0.4; L.EnvironmentSpecularScale = 0.4; L.ExposureCompensation = -0.15; L.GlobalShadows = true; L.FogEnd = 1200; L.FogColor = Color3.fromRGB(200, 210, 230)
	if not L:FindFirstChildOfClass("SunRaysEffect") then local sr = Instance.new("SunRaysEffect"); sr.Intensity = 0.08; sr.Parent = L end
	if not L:FindFirstChildOfClass("ColorCorrectionEffect") then local cc = Instance.new("ColorCorrectionEffect"); cc.Saturation = 0.1; cc.Contrast = 0.03; cc.Parent = L end
	if not L:FindFirstChildOfClass("Sky") then local sky = Instance.new("Sky"); sky.SkyboxBk = "rbxassetid://591058823"; sky.SkyboxDn = "rbxassetid://591059876"; sky.SkyboxFt = "rbxassetid://591058104"; sky.SkyboxLf = "rbxassetid://591057861"; sky.SkyboxRt = "rbxassetid://591057625"; sky.SkyboxUp = "rbxassetid://591059642"; sky.Parent = L end
	if not L:FindFirstChildOfClass("Atmosphere") then local at = Instance.new("Atmosphere"); at.Density = 0.3; at.Parent = L end
	if not L:FindFirstChildOfClass("BloomEffect") then local bl = Instance.new("BloomEffect"); bl.Intensity = 0.12; bl.Size = 20; bl.Threshold = 1.6; bl.Parent = L end
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
-- ตัวบ้านบนที่ดิน: ผนัง หลังคาจั่ว ประตู หน้าต่าง ปล่องไฟ (ภายในโล่งสำหรับวางเฟอร์นิเจอร์ ±14)
local HOUSE_COLORS = { { 245, 235, 215 }, { 215, 230, 245 }, { 250, 225, 200 }, { 225, 240, 220 }, { 240, 220, 225 }, { 235, 235, 235 } }
local ROOF_COLORS = { { 160, 60, 50 }, { 60, 80, 120 }, { 90, 90, 95 }, { 120, 80, 60 } }
function M.houseShell(f, origin, i)
	local W, D, H = 32, 28, 10
	local wallC = Color3.fromRGB(unpack(HOUSE_COLORS[(i - 1) % #HOUSE_COLORS + 1]))
	local roofC = Color3.fromRGB(unpack(ROOF_COLORS[(i - 1) % #ROOF_COLORS + 1]))
	local o = origin + Vector3.new(0, 0.5, 2)
	local function wall(size, off) part({ Size = size, Position = o + off, Color = wallC, Material = Enum.Material.Brick, Name = "HouseWall" }, f) end
	wall(Vector3.new(W, H, 0.6), Vector3.new(0, H / 2, -D / 2))                    -- หลัง
	wall(Vector3.new(0.6, H, D), Vector3.new(-W / 2, H / 2, 0))                    -- ซ้าย
	wall(Vector3.new(0.6, H, D), Vector3.new(W / 2, H / 2, 0))                     -- ขวา
	wall(Vector3.new(W / 2 - 3.5, H, 0.6), Vector3.new(-W / 4 - 1.75, H / 2, D / 2)) -- หน้าซ้าย
	wall(Vector3.new(W / 2 - 3.5, H, 0.6), Vector3.new(W / 4 + 1.75, H / 2, D / 2))  -- หน้าขวา
	wall(Vector3.new(7, H - 8, 0.6), Vector3.new(0, H - (H - 8) / 2, D / 2))         -- เหนือประตู
	-- กรอบประตู + หน้าต่าง 6 บาน
	for _, sx in ipairs({ -3.6, 3.6 }) do part({ Size = Vector3.new(0.5, 8, 1), Position = o + Vector3.new(sx, 4, D / 2), Color = Color3.fromRGB(250, 250, 250), Material = Enum.Material.SmoothPlastic }, f) end
	local wins = { { -W / 4 - 1.75, D / 2, false }, { W / 4 + 1.75, D / 2, false }, { -W / 4, -D / 2, false }, { W / 4, -D / 2, false }, { -W / 2, -6, true }, { W / 2, 6, true } }
	for _, wv in ipairs(wins) do
		local size = wv[3] and Vector3.new(0.3, 4.5, 6) or Vector3.new(6, 4.5, 0.3)
		local fsize = wv[3] and Vector3.new(0.2, 5.2, 6.8) or Vector3.new(6.8, 5.2, 0.2)
		local pos = wv[3] and o + Vector3.new(wv[1], 5.5, wv[2]) or o + Vector3.new(wv[1], 5.5, wv[2])
		part({ Size = fsize, Position = pos, Color = Color3.fromRGB(250, 250, 250), Material = Enum.Material.SmoothPlastic, CanCollide = false }, f)
		part({ Size = size, Position = pos, Color = Color3.fromRGB(140, 200, 235), Material = Enum.Material.Glass, Transparency = 0.35, Reflectance = 0.25, CanCollide = false }, f)
	end
	-- หลังคาจั่ว (wedge 2 ฝั่ง) + ชายคา + ปล่องไฟ
	for _, sx in ipairs({ -1, 1 }) do
		local wp = Instance.new("WedgePart"); wp.Anchored = true; wp.Size = Vector3.new(D + 4, 6, W / 2 + 2); wp.CFrame = CFrame.new(o + Vector3.new(sx * (W / 4 + 1), H + 3, 0)) * CFrame.Angles(0, sx > 0 and math.rad(-90) or math.rad(90), 0); wp.Color = roofC; wp.Material = Enum.Material.Slate; wp.Name = "Roof"; wp.Parent = f
	end
	part({ Size = Vector3.new(W + 4, 0.6, D + 4), Position = o + Vector3.new(0, H + 0.3, 0), Color = roofC, Material = Enum.Material.Slate, Name = "Roof" }, f)
	part({ Size = Vector3.new(2.5, 6, 2.5), Position = o + Vector3.new(W / 3, H + 5, -D / 4), Color = Color3.fromRGB(120, 70, 55), Material = Enum.Material.Brick }, f)
	-- ห้องภายใน: ผนังกั้นห้องนอน (ซ้ายหลัง) ห้องน้ำ (ขวาหลัง) ครัว (ขวาหน้า) + เคาน์เตอร์ครัว ตู้แขวน อ่างล้างจาน
	local inner = Color3.fromRGB(245, 240, 232)
	part({ Size = Vector3.new(11, H, 0.4), Position = o + Vector3.new(-10.5, H / 2, -2), Color = inner, Material = Enum.Material.SmoothPlastic, Name = "HouseWall" }, f)   -- ผนังห้องนอน (ประตูช่วง x -5..-2)
	part({ Size = Vector3.new(0.4, H, 5), Position = o + Vector3.new(-2, H / 2, -11.5), Color = inner, Material = Enum.Material.SmoothPlastic, Name = "HouseWall" }, f)
	part({ Size = Vector3.new(0.4, H, 8), Position = o + Vector3.new(6, H / 2, -10), Color = inner, Material = Enum.Material.SmoothPlastic, Name = "HouseWall" }, f)         -- ห้องน้ำ x 6..16 z -14..-6
	part({ Size = Vector3.new(7, H, 0.4), Position = o + Vector3.new(12.5, H / 2, -6), Color = inner, Material = Enum.Material.SmoothPlastic, Name = "HouseWall" }, f)
	part({ Size = Vector3.new(0.4, H - 7.5, 3.5), Position = o + Vector3.new(6, H - (H - 7.5) / 2, -4.25), Color = inner, Material = Enum.Material.SmoothPlastic, Name = "HouseWall" }, f)
	part({ Size = Vector3.new(0.4, 0.05, 10), Position = o + Vector3.new(6, 0.2, -9), Color = Color3.fromRGB(230, 230, 235), Material = Enum.Material.Marble, CanCollide = false }, f)
	part({ Size = Vector3.new(9.6, 0.15, 7.6), Position = o + Vector3.new(11.2, 0.22, -10.2), Color = Color3.fromRGB(225, 230, 235), Material = Enum.Material.Marble, CanCollide = false, Name = "BathFloor" }, f)
	part({ Size = Vector3.new(2, 3, 8), Position = o + Vector3.new(15, 1.5, 3), Color = Color3.fromRGB(235, 235, 235), Material = Enum.Material.SmoothPlastic, Name = "Counter" }, f)    -- เคาน์เตอร์ครัว
	part({ Size = Vector3.new(2.2, 0.15, 8.2), Position = o + Vector3.new(15, 3.05, 3), Color = Color3.fromRGB(70, 70, 75), Material = Enum.Material.Granite }, f)
	part({ Size = Vector3.new(1.4, 0.3, 2), Position = o + Vector3.new(15, 3.0, 1), Color = Color3.fromRGB(190, 190, 195), Material = Enum.Material.Metal }, f)                  -- อ่างล้างจาน
	part({ Size = Vector3.new(0.15, 1.0, 0.15), Position = o + Vector3.new(15.6, 3.6, 1), Color = Color3.fromRGB(190, 190, 195), Material = Enum.Material.Metal }, f)
	part({ Size = Vector3.new(1.4, 2.4, 8), Position = o + Vector3.new(15.3, 7.5, 3), Color = Color3.fromRGB(235, 235, 235), Material = Enum.Material.SmoothPlastic }, f)                   -- ตู้แขวน
	for i = 0, 3 do part({ Size = Vector3.new(0.1, 0.5, 0.1), Position = o + Vector3.new(14.5, 7.5, i * 2), Color = Color3.fromRGB(190, 190, 195), Material = Enum.Material.Metal }, f) end
	-- ขอบบัวพื้น + ผ้าม่านหน้าต่างหน้า
	for _, wx in ipairs({ -W / 4 - 1.75, W / 4 + 1.75 }) do part({ Size = Vector3.new(7.6, 5.8, 0.2), Position = o + Vector3.new(wx, 5.5, D / 2 - 0.5), Color = Color3.fromRGB(200, 170, 140), Material = Enum.Material.Fabric, CanCollide = false, Transparency = 0.35 }, f) end
	-- พื้นภายในไม้ + ไฟเพดาน + ทางเดินหน้าบ้าน
	part({ Size = Vector3.new(W - 1, 0.3, D - 1), Position = o + Vector3.new(0, 0.15, 0), Color = Color3.fromRGB(205, 175, 130), Material = Enum.Material.WoodPlanks, CanCollide = false, Name = "InnerFloor" }, f)
	local lamp = part({ Size = Vector3.new(2, 0.3, 2), Position = o + Vector3.new(0, H - 0.5, 0), Color = Color3.fromRGB(255, 245, 220), Material = Enum.Material.SmoothPlastic, CanCollide = false }, f)
	local l = Instance.new("PointLight"); l.Range = 20; l.Brightness = 0.45; l.Shadows = true; l.Parent = lamp
	part({ Size = Vector3.new(6, 0.3, 8), Position = origin + Vector3.new(0, 0.55, D / 2 + 6), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Concrete }, f)
end
-- ตุ๊กตุ๊ก 3 ล้อ
function M.tuktuk(pos, parent)
	local m = Instance.new("Model"); m.Name = "TukTuk"; m.Parent = parent
	local cf = CFrame.new(pos + Vector3.new(0, 1, 0))
	part({ Size = Vector3.new(3.4, 1.2, 6), CFrame = cf * CFrame.new(0, 0.6, 0), Color = Color3.fromRGB(40, 100, 200), Material = Enum.Material.Metal }, m)
	part({ Size = Vector3.new(3.4, 3, 0.2), CFrame = cf * CFrame.new(0, 2.6, 0.5), Color = Color3.fromRGB(240, 200, 40), Material = Enum.Material.Metal }, m)
	part({ Size = Vector3.new(3.8, 0.3, 6.5), CFrame = cf * CFrame.new(0, 4.2, 0), Color = Color3.fromRGB(240, 200, 40), Material = Enum.Material.Metal }, m)
	for _, o in ipairs({ { -1.6, -1 }, { 1.6, -1 }, { -1.6, 2.6 }, { 1.6, 2.6 } }) do part({ Size = Vector3.new(0.3, 3, 0.3), CFrame = cf * CFrame.new(o[1], 2.6, o[2]), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, m) end
	part({ Size = Vector3.new(2.6, 0.8, 1.6), CFrame = cf * CFrame.new(0, 1.5, 1.6), Color = Color3.fromRGB(120, 60, 40), Material = Enum.Material.Fabric }, m)
	part({ Size = Vector3.new(1.4, 0.6, 1), CFrame = cf * CFrame.new(0, 1.5, -1.2), Color = Color3.fromRGB(120, 60, 40), Material = Enum.Material.Fabric }, m)
	part({ Size = Vector3.new(1, 0.15, 1), CFrame = cf * CFrame.new(0, 2.2, -1.8) * CFrame.Angles(math.rad(20), 0, 0), Color = Color3.fromRGB(30, 30, 30), Material = Enum.Material.Metal }, m)
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5, 1.8, 1.8), CFrame = cf * CFrame.new(0, -0.1, -2.8) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(25, 25, 25), Material = Enum.Material.Rubber }, m)
	for _, sx in ipairs({ -1.6, 1.6 }) do part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 1.8, 1.8), CFrame = cf * CFrame.new(sx, -0.1, 2) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(25, 25, 25), Material = Enum.Material.Rubber }, m) end
	return m
end
function M.door(key) local b = M.buildings[key]; return b and b.door end
return M
