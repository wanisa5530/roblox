-- ถนนกรุงเทพฯ ตอนกลางคืน: ตึกแถว ป้ายไฟ รถไฟฟ้าลอยฟ้า เสาไฟสายไฟ ตุ๊กตุ๊ก วินมอไซค์ ร้านสะดวกซื้อ เจดีย์ไกล ๆ
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
Lighting.ClockTime = 19.5; Lighting.Brightness = 1; Lighting.Ambient = Color3.fromRGB(70, 60, 80)
Lighting.OutdoorAmbient = Color3.fromRGB(80, 70, 90); Lighting.FogEnd = 700; Lighting.FogColor = Color3.fromRGB(40, 30, 50)
local deco = Instance.new("Folder"); deco.Name = "Decor"; deco.Parent = workspace
local function part(props, parent)
	local x = Instance.new("Part"); x.Anchored = true; x.TopSurface = Enum.SurfaceType.Smooth; x.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do x[k] = v end
	x.Parent = parent or deco; return x
end
local function neonSign(text, size, cf, color, bg, parent)
	local s = part({ Size = size, CFrame = cf, Color = bg, Material = Enum.Material.SmoothPlastic }, parent)
	local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.LightInfluence = 0; g.Brightness = 2.5; g.Parent = s
	local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundTransparency = 1; t.Text = text; t.TextScaled = true
	t.Font = Enum.Font.FredokaOne; t.TextColor3 = color; t.Parent = g
	local l = Instance.new("PointLight"); l.Color = bg; l.Range = 12; l.Brightness = 0.6; l.Parent = s
	return s
end
local function light(pos, color, range)
	local b = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7), Position = pos, Color = color, Material = Enum.Material.Neon })
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range or 16; l.Brightness = 1; l.Parent = b
end

-- ทางเท้ากระเบื้อง + ขอบถนน
part({ Size = Vector3.new(500, 0.3, 8), Position = Vector3.new(0, 0.15, -21), Color = Color3.fromRGB(170, 160, 150), Material = Enum.Material.Concrete })
part({ Size = Vector3.new(500, 0.3, 8), Position = Vector3.new(0, 0.15, 5), Color = Color3.fromRGB(170, 160, 150), Material = Enum.Material.Concrete })
for x = -250, 250, 6 do part({ Size = Vector3.new(3, 0.22, 1), Position = Vector3.new(x, 0.21, -8), Color = Color3.fromRGB(255, 255, 255) }) end
-- ทางม้าลาย
for k = 0, 6 do part({ Size = Vector3.new(1.5, 0.22, 16), Position = Vector3.new(-6 + k * 2, 0.21, -8), Color = Color3.fromRGB(240, 240, 240) }) end

-- ตึกแถวฝั่งตรงข้ามถนน (หลังทางเท้าด้านลบ z)
local shopNames = { { "ร้านทอง", Color3.fromRGB(255, 200, 40), Color3.fromRGB(180, 30, 30) }, { "24 MART", Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 120, 60) },
	{ "ร้านนวดไทย", Color3.fromRGB(255, 240, 200), Color3.fromRGB(120, 40, 140) }, { "ก๋วยเตี๋ยว", Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 60, 60) },
	{ "ร้านยา", Color3.fromRGB(255, 255, 255), Color3.fromRGB(40, 120, 200) }, { "KARAOKE", Color3.fromRGB(255, 80, 200), Color3.fromRGB(40, 20, 60) },
	{ "โชห่วย", Color3.fromRGB(255, 255, 255), Color3.fromRGB(230, 130, 30) }, { "ร้านซ่อมมือถือ", Color3.fromRGB(255, 255, 255), Color3.fromRGB(30, 30, 30) } }
local wallColors = { Color3.fromRGB(220, 210, 190), Color3.fromRGB(200, 190, 175), Color3.fromRGB(235, 220, 200), Color3.fromRGB(190, 200, 205) }
local i = 0
for x = -230, 230, 24 do
	i += 1
	local floors = 3 + (i % 3)
	local h = floors * 8
	local wall = wallColors[i % #wallColors + 1]
	part({ Size = Vector3.new(23, h, 22), Position = Vector3.new(x, h / 2, -42), Color = wall, Material = Enum.Material.Concrete })
	-- หน้าต่าง + ระเบียง
	for f = 2, floors do
		for w = -1, 1 do
			local lit = math.random() < 0.6
			part({ Size = Vector3.new(4, 4, 0.2), Position = Vector3.new(x + w * 7, f * 8 - 4, -30.9), Color = lit and Color3.fromRGB(255, 225, 170) or Color3.fromRGB(30, 35, 50), Material = Enum.Material.Glass, Transparency = lit and 0.2 or 0.4 })
			if lit then local wl = Instance.new("SurfaceLight"); wl.Face = Enum.NormalId.Front; wl.Range = 6; wl.Brightness = 0.6; wl.Color = Color3.fromRGB(255, 220, 160); wl.Parent = part({ Size = Vector3.new(3.6, 3.6, 0.05), Position = Vector3.new(x + w * 7, f * 8 - 4, -30.78), Color = Color3.fromRGB(255, 225, 170), Material = Enum.Material.Neon, Transparency = 0.5 }) end
		end
		part({ Size = Vector3.new(23, 0.3, 3), Position = Vector3.new(x, f * 8 - 7, -29.5), Color = Color3.fromRGB(150, 150, 150), Material = Enum.Material.Concrete })
		for w = -10, 10, 2.5 do part({ Size = Vector3.new(0.15, 1.2, 0.15), Position = Vector3.new(x + w, f * 8 - 6.3, -28.2), Color = Color3.fromRGB(90, 90, 90) }) end
	end
	-- กันสาด + ป้ายร้าน + ประตูม้วน
	part({ Size = Vector3.new(23, 0.3, 5), Position = Vector3.new(x, 7.5, -28.5), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal })
	local sn = shopNames[i % #shopNames + 1]
	neonSign(sn[1], Vector3.new(18, 3, 0.3), CFrame.new(x, 10, -30.8), sn[2], sn[3])
	part({ Size = Vector3.new(10, 6.5, 0.3), Position = Vector3.new(x, 3.5, -30.9), Color = Color3.fromRGB(255, 240, 210), Material = Enum.Material.Glass, Transparency = 0.3 })
	local sl = Instance.new("SurfaceLight"); sl.Face = Enum.NormalId.Front; sl.Range = 12; sl.Brightness = 1; sl.Color = Color3.fromRGB(255, 235, 200); sl.Parent = part({ Size = Vector3.new(9, 0.2, 0.2), Position = Vector3.new(x, 6.9, -30.7), Color = Color3.fromRGB(255, 255, 240), Material = Enum.Material.Neon })
	-- กันสาดผ้าใบสี
	part({ Size = Vector3.new(23, 0.2, 4), CFrame = CFrame.new(x, 7.6, -28.5) * CFrame.Angles(math.rad(12), 0, 0), Color = ({ Color3.fromRGB(200, 40, 40), Color3.fromRGB(30, 90, 170), Color3.fromRGB(40, 140, 80) })[i % 3 + 1], Material = Enum.Material.Fabric })
	-- แอร์ติดผนัง
	part({ Size = Vector3.new(2.5, 1.5, 1), Position = Vector3.new(x + 9, 12, -30.3), Color = Color3.fromRGB(220, 220, 220), Material = Enum.Material.Metal })
end

-- เสาไฟฟ้าคอนกรีต + สายไฟพันกัน (ริมทางเท้าทั้งสองฝั่ง)
for x = -240, 240, 30 do
	for _, z in ipairs({ -18, 2 }) do
		part({ Size = Vector3.new(0.7, 16, 0.7), Position = Vector3.new(x, 8, z), Color = Color3.fromRGB(150, 150, 150), Material = Enum.Material.Concrete })
		part({ Size = Vector3.new(2.4, 0.3, 0.3), Position = Vector3.new(x, 15, z), Color = Color3.fromRGB(80, 80, 80) })
		for k = 0, 3 do part({ Size = Vector3.new(30, 0.08, 0.08), Position = Vector3.new(x + 15, 14.8 - k * 0.5, z + (k % 2) * 0.4 - 0.2), Color = Color3.fromRGB(20, 20, 20) }) end
		part({ Size = Vector3.new(1.2, 0.4, 3), Position = Vector3.new(x, 13, z + 1.4), Color = Color3.fromRGB(60, 60, 60), Material = Enum.Material.Metal })
		light(Vector3.new(x, 12.7, z + 2.6), Color3.fromRGB(255, 200, 110), 22)
	end
end

-- รถไฟฟ้าลอยฟ้า: เสา + ทางวิ่งข้ามถนนตามแนว z (ด้านข้างแมพ)
for _, bx in ipairs({ -160, 160 }) do
	for z = -80, 140, 40 do part({ Size = Vector3.new(4, 26, 4), Position = Vector3.new(bx, 13, z), Color = Color3.fromRGB(160, 160, 165), Material = Enum.Material.Concrete }) end
	part({ Size = Vector3.new(14, 2, 260), Position = Vector3.new(bx, 27, 30), Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Concrete })
	for _, sx in ipairs({ -6, 6 }) do part({ Size = Vector3.new(0.4, 1.4, 260), Position = Vector3.new(bx + sx, 28.7, 30), Color = Color3.fromRGB(100, 100, 105), Material = Enum.Material.Metal }) end
	-- ขบวนรถไฟ
	local train = Instance.new("Model"); train.Name = "SkyTrain"; train.Parent = deco
	local head = part({ Size = Vector3.new(8, 6, 40), Position = Vector3.new(bx, 31, -120), Color = Color3.fromRGB(30, 100, 60), Material = Enum.Material.Metal }, train)
	local stripe = part({ Size = Vector3.new(8.2, 1.2, 40), Position = Vector3.new(bx, 31, -120), Color = Color3.fromRGB(240, 200, 40), Material = Enum.Material.SmoothPlastic }, train)
	local win = part({ Size = Vector3.new(8.3, 2, 36), Position = Vector3.new(bx, 32.5, -120), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon }, train)
	train.PrimaryPart = head
	for _, p in ipairs({ stripe, win }) do local w = Instance.new("WeldConstraint"); w.Part0 = head; w.Part1 = p; w.Parent = p; p.Anchored = false end
	task.spawn(function()
		while true do
			head.CFrame = CFrame.new(bx, 31, -140)
			local tw = TweenService:Create(head, TweenInfo.new(14, Enum.EasingStyle.Linear), { CFrame = CFrame.new(bx, 31, 200) }); tw:Play(); tw.Completed:Wait()
			task.wait(8)
		end
	end)
end

-- วัด: เจดีย์ทองไกล ๆ หลังตึกแถว
for k = 0, 5 do
	local w = 24 - k * 3.5
	part({ Size = Vector3.new(w, 4, w), Position = Vector3.new(60, 2 + k * 4, -110), Color = Color3.fromRGB(240, 200, 60), Material = Enum.Material.Metal })
end
part({ Size = Vector3.new(1.5, 18, 1.5), Position = Vector3.new(60, 33, -110), Color = Color3.fromRGB(255, 215, 80), Material = Enum.Material.Neon })
part({ Size = Vector3.new(40, 12, 30), Position = Vector3.new(20, 6, -110), Color = Color3.fromRGB(230, 225, 215), Material = Enum.Material.Concrete })
part({ Size = Vector3.new(44, 1, 34), Position = Vector3.new(20, 12.5, -110), Color = Color3.fromRGB(200, 40, 40) })
part({ Size = Vector3.new(30, 6, 20), Position = Vector3.new(20, 16, -110), Color = Color3.fromRGB(220, 50, 40) })
part({ Size = Vector3.new(16, 6, 10), Position = Vector3.new(20, 22, -110), Color = Color3.fromRGB(240, 60, 40) })

-- ยานพาหนะวิ่งวน: ตุ๊กตุ๊ก, วินมอเตอร์ไซค์, รถเมล์
local function vehicle(name, buildFn, lane, speed, delay, dir)
	local m = Instance.new("Model"); m.Name = name; m.Parent = deco
	local root = buildFn(m)
	m.PrimaryPart = root
	for _, p in ipairs(m:GetChildren()) do if p ~= root then local w = Instance.new("WeldConstraint"); w.Part0 = root; w.Part1 = p; w.Parent = p; p.Anchored = false end end
	task.spawn(function()
		task.wait(delay)
		while true do
			local from, to = -240 * dir, 240 * dir
			m:PivotTo(CFrame.new(from, root.Position.Y, lane) * CFrame.Angles(0, dir > 0 and math.rad(-90) or math.rad(90), 0))
			local tw = TweenService:Create(root, TweenInfo.new(480 / speed, Enum.EasingStyle.Linear), { CFrame = CFrame.new(to, root.Position.Y, lane) * CFrame.Angles(0, dir > 0 and math.rad(-90) or math.rad(90), 0) })
			tw:Play(); tw.Completed:Wait(); task.wait(3 + math.random() * 5)
		end
	end)
end
local function tuktuk(m)
	local body = part({ Size = Vector3.new(3, 3, 5), Position = Vector3.new(0, 2.2, 0), Color = Color3.fromRGB(30, 100, 200), Material = Enum.Material.Metal }, m)
	part({ Size = Vector3.new(3.4, 0.3, 5.4), Position = Vector3.new(0, 4, 0), Color = Color3.fromRGB(240, 200, 40) }, m)
	part({ Size = Vector3.new(2, 1.6, 2), Position = Vector3.new(0, 1.5, -3.3), Color = Color3.fromRGB(30, 100, 200), Material = Enum.Material.Metal }, m)
	local hl = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.6, 0.6, 0.6), Position = Vector3.new(0, 2, -4.3), Color = Color3.fromRGB(255, 250, 200), Material = Enum.Material.Neon }, m)
	local l = Instance.new("PointLight"); l.Range = 10; l.Parent = hl
	return body
end
local function moto(m)
	local body = part({ Size = Vector3.new(0.8, 1, 3.2), Position = Vector3.new(0, 1.4, 0), Color = Color3.fromRGB(200, 40, 40), Material = Enum.Material.Metal }, m)
	part({ Size = Vector3.new(1, 1.6, 0.8), Position = Vector3.new(0, 2.6, 0.2), Color = Color3.fromRGB(255, 140, 0) }, m) -- เสื้อวิน
	part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.8, 0.8, 0.8), Position = Vector3.new(0, 3.7, 0.2), Color = Color3.fromRGB(240, 200, 170) }, m)
	for _, z in ipairs({ -1.3, 1.3 }) do local w = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 1.2, 1.2), Color = Color3.fromRGB(30, 30, 30) }, m); w.CFrame = CFrame.new(0, 0.6, z) * CFrame.Angles(0, 0, math.rad(90)) end
	return body
end
local function bus(m)
	local body = part({ Size = Vector3.new(4, 5, 16), Position = Vector3.new(0, 3.2, 0), Color = Color3.fromRGB(230, 120, 40), Material = Enum.Material.Metal }, m)
	part({ Size = Vector3.new(4.2, 1.8, 14), Position = Vector3.new(0, 4.2, 0), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon }, m)
	part({ Size = Vector3.new(4.2, 0.6, 16), Position = Vector3.new(0, 2, 0), Color = Color3.fromRGB(230, 230, 230) }, m)
	return body
end
vehicle("TukTuk", tuktuk, -12, 22, 0, 1)
vehicle("TukTuk2", tuktuk, -4, 20, 9, -1)
vehicle("Moto1", moto, -13.5, 32, 4, 1)
vehicle("Moto2", moto, -2.5, 30, 12, -1)
vehicle("Moto3", moto, -11, 34, 20, 1)
vehicle("Bus", bus, -4, 14, 15, -1)

-- ===== ตลาดกลางคืนสไตล์ตลาดนัดรถไฟ: เต็นท์หลากสี ตึกสูงเป็นฉากหลัง เสาไฟสูง =====
local TENT = { Color3.fromRGB(230, 50, 50), Color3.fromRGB(40, 90, 200), Color3.fromRGB(250, 200, 40), Color3.fromRGB(50, 170, 90),
	Color3.fromRGB(240, 120, 40), Color3.fromRGB(150, 60, 180), Color3.fromRGB(240, 90, 160), Color3.fromRGB(60, 190, 200) }
local function tent(pos, color, size)
	size = size or 10
	local h = 7
	for _, dx in ipairs({ -size / 2 + 0.5, size / 2 - 0.5 }) do
		for _, dz in ipairs({ -size / 2 + 0.5, size / 2 - 0.5 }) do
			part({ Size = Vector3.new(0.25, h, 0.25), Position = pos + Vector3.new(dx, h / 2, dz), Color = Color3.fromRGB(200, 200, 200), Material = Enum.Material.Metal })
		end
	end
	-- หลังคาทรงปิรามิดจาก WedgePart 4 ชิ้น
	for k = 0, 3 do
		local w = Instance.new("WedgePart"); w.Anchored = true; w.Size = Vector3.new(size, 2.5, size / 2); w.Color = color; w.Material = Enum.Material.Fabric
		w.CFrame = CFrame.new(pos + Vector3.new(0, h + 1.25, 0)) * CFrame.Angles(0, math.rad(90 * k), 0) * CFrame.new(0, 0, size / 4)
		w.Parent = deco
	end
	part({ Size = Vector3.new(size + 0.4, 0.2, size + 0.4), Position = pos + Vector3.new(0, h, 0), Color = color, Material = Enum.Material.Fabric })
	light(pos + Vector3.new(0, h - 0.8, 0), Color3.fromRGB(255, 235, 180), 14)
	-- โต๊ะขายของ + สินค้า
	part({ Size = Vector3.new(size - 3, 2.4, 2.5), Position = pos + Vector3.new(0, 1.2, size / 2 - 2), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Plastic })
	for k = -1, 1 do part({ Size = Vector3.new(1.4, 0.8, 1.4), Position = pos + Vector3.new(k * 2.2, 2.8, size / 2 - 2), Color = TENT[math.random(#TENT)], Material = Enum.Material.SmoothPlastic }) end
end
-- โซนเต็นท์หลังแปลงร้าน (แถว x 2 ชั้น) และสองข้างถนนด้านนอกแปลง
for row = 0, 2 do
	for k = 0, 22 do
		tent(Vector3.new(-132 + k * 12, 0, 175 + row * 16), TENT[(k + row) % #TENT + 1], 10)
	end
end
for _, x in ipairs({ -165, 165 }) do
	for k = 0, 8 do tent(Vector3.new(x, 0, 20 + k * 14), TENT[k % #TENT + 1], 10) end
end
-- ทางเดินระหว่างเต็นท์ + ผู้คนแบบง่าย (กล่องสี)
for k = 0, 40 do
	local px, pz = -130 + math.random() * 260, 168 + math.random() * 46
	part({ Size = Vector3.new(1.2, 3.6, 0.8), Position = Vector3.new(px, 1.8, pz), Color = TENT[math.random(#TENT)] })
	part({ Shape = Enum.PartType.Ball, Size = Vector3.new(1, 1, 1), Position = Vector3.new(px, 4.1, pz), Color = Color3.fromRGB(240, 200, 170) })
end
-- เสาไฟสูงแบบตลาดนัด
for _, p in ipairs({ Vector3.new(-100, 0, 150), Vector3.new(0, 0, 150), Vector3.new(100, 0, 150), Vector3.new(-100, 0, 215), Vector3.new(100, 0, 215) }) do
	part({ Size = Vector3.new(1, 40, 1), Position = p + Vector3.new(0, 20, 0), Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Metal })
	part({ Size = Vector3.new(6, 0.5, 6), Position = p + Vector3.new(0, 40, 0), Color = Color3.fromRGB(80, 80, 80), Material = Enum.Material.Metal })
	local b = part({ Size = Vector3.new(5, 1, 5), Position = p + Vector3.new(0, 39.2, 0), Color = Color3.fromRGB(255, 255, 230), Material = Enum.Material.Neon })
	local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 250, 220); l.Range = 60; l.Brightness = 1.5; l.Parent = b
end
-- ตึกสูงกรุงเทพฯ เป็นฉากหลังไกล ๆ (หลังโซนเต็นท์และหลังตึกแถว)
local function tower(x, z, w, h, tint)
	part({ Size = Vector3.new(w, h, w), Position = Vector3.new(x, h / 2, z), Color = tint, Material = Enum.Material.Glass })
	for f = 1, math.floor(h / 5) do
		for c = -1, 1 do
			if math.random() < 0.45 then
				part({ Size = Vector3.new(2.2, 2.6, w + 0.3), Position = Vector3.new(x + c * (w / 3.2), f * 5 - 2, z), Color = Color3.fromRGB(255, 235, 180), Material = Enum.Material.Neon, Transparency = 0.5 })
				part({ Size = Vector3.new(w + 0.3, 2.6, 2.2), Position = Vector3.new(x, f * 5 - 2, z + c * (w / 3.2)), Color = Color3.fromRGB(255, 235, 180), Material = Enum.Material.Neon, Transparency = 0.5 })
			end
		end
	end
	local top = part({ Size = Vector3.new(1, 6, 1), Position = Vector3.new(x, h + 3, z), Color = Color3.fromRGB(255, 60, 60), Material = Enum.Material.Neon })
	local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 60, 60); l.Range = 20; l.Parent = top
end
local tints = { Color3.fromRGB(40, 60, 90), Color3.fromRGB(60, 70, 80), Color3.fromRGB(50, 80, 110), Color3.fromRGB(70, 60, 70) }
for k = 0, 9 do tower(-200 + k * 45 + math.random(-8, 8), 300 + math.random(0, 40), 18 + math.random(0, 10), 70 + math.random(0, 80), tints[k % #tints + 1]) end
for k = 0, 7 do tower(-180 + k * 50 + math.random(-8, 8), -230 - math.random(0, 40), 16 + math.random(0, 10), 60 + math.random(0, 90), tints[k % #tints + 1]) end


-- ===== รายละเอียดข้างถนน: ต้นไม้ ถังขยะ มอเตอร์ไซค์จอด ป้ายผ้า เสาหลัก บรรยากาศ =====
local function tree(pos)
	part({ Size = Vector3.new(0.8, 7, 0.8), Position = pos + Vector3.new(0, 3.5, 0), Color = Color3.fromRGB(90, 60, 40), Material = Enum.Material.Wood })
	part({ Shape = Enum.PartType.Ball, Size = Vector3.new(7, 6, 7), Position = pos + Vector3.new(0, 8.5, 0), Color = Color3.fromRGB(40, 110, 50), Material = Enum.Material.Grass })
	part({ Shape = Enum.PartType.Ball, Size = Vector3.new(5, 4, 5), Position = pos + Vector3.new(1.5, 11, 1), Color = Color3.fromRGB(50, 130, 60), Material = Enum.Material.Grass })
end
for x = -225, 225, 30 do tree(Vector3.new(x + 8, 0, -20)); tree(Vector3.new(x - 6, 0, 6)) end
for x = -240, 240, 45 do
	-- ถังขยะเขียว + มอเตอร์ไซค์จอด
	part({ Size = Vector3.new(1.4, 2.2, 1.4), Position = Vector3.new(x + 3, 1.1, 4), Color = Color3.fromRGB(40, 130, 60), Material = Enum.Material.Plastic })
	for k = 0, 2 do
		local m = Instance.new("Model"); m.Parent = deco
		local body = part({ Size = Vector3.new(0.8, 1, 3), Position = Vector3.new(x - 6 + k * 1.6, 1.3, -17.5), Color = ({ Color3.fromRGB(200, 40, 40), Color3.fromRGB(30, 30, 30), Color3.fromRGB(230, 230, 230) })[k + 1], Material = Enum.Material.Metal }, m)
		body.Orientation = Vector3.new(0, 20, 0)
		for _, z in ipairs({ -1.2, 1.2 }) do local w = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 1.1, 1.1), Color = Color3.fromRGB(25, 25, 25) }, m); w.CFrame = body.CFrame * CFrame.new(0, -0.7, z) * CFrame.Angles(0, 0, math.rad(90)) end
	end
	-- เสาหลักกันรถ
	for k = 0, 3 do part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.2, 0.5, 0.5), CFrame = CFrame.new(x + 12 + k * 3, 1.1, -17) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(230, 200, 60), Material = Enum.Material.Metal }) end
end
-- ป้ายผ้าโฆษณาขึงระหว่างเสาไฟข้ามถนน
for x = -180, 180, 90 do
	part({ Size = Vector3.new(0.1, 0.1, 22), Position = Vector3.new(x, 13.5, -8), Color = Color3.fromRGB(30, 30, 30) })
	neonSign("🍜 STREET FOOD FESTIVAL 🍢", Vector3.new(0.15, 3, 16), CFrame.new(x, 11.5, -8) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 40, 60))
end
-- บรรยากาศ: หมอกบาง แสงฟุ้ง สีอุ่น
local atm = Instance.new("Atmosphere"); atm.Density = 0.32; atm.Offset = 0.2; atm.Color = Color3.fromRGB(199, 170, 150); atm.Decay = Color3.fromRGB(80, 60, 90); atm.Glare = 0.4; atm.Haze = 1.2; atm.Parent = Lighting
local bloom = Instance.new("BloomEffect"); bloom.Intensity = 0.4; bloom.Size = 24; bloom.Threshold = 1.2; bloom.Parent = Lighting
local cc = Instance.new("ColorCorrectionEffect"); cc.Saturation = 0.15; cc.Contrast = 0.1; cc.TintColor = Color3.fromRGB(255, 245, 235); cc.Parent = Lighting
Lighting.Brightness = 0.8; Lighting.ExposureCompensation = -0.2


-- ===== วงจรกลางวัน-กลางคืน (1 วันเกม = 24 นาทีจริง) เปิด/ปิดไฟอัตโนมัติ =====
local DAY_MINUTES = 24
local lights = {}
task.defer(function()
	for _, x in ipairs(workspace:GetDescendants()) do if x:IsA("PointLight") or x:IsA("SurfaceLight") then lights[#lights + 1] = x end end
	workspace.DescendantAdded:Connect(function(x) if x:IsA("PointLight") or x:IsA("SurfaceLight") then lights[#lights + 1] = x end end)
end)
task.spawn(function()
	while true do
		local t = (os.time() % (DAY_MINUTES * 60)) / (DAY_MINUTES * 60) -- 0..1
		local hour = 6 + t * 24 -- เริ่ม 6 โมงเช้า
		if hour >= 24 then hour -= 24 end
		Lighting.ClockTime = hour
		local night = hour < 6 or hour >= 18.5
		Lighting.Brightness = night and 0.8 or 2.2
		Lighting.Ambient = night and Color3.fromRGB(70, 60, 80) or Color3.fromRGB(150, 150, 150)
		Lighting.OutdoorAmbient = night and Color3.fromRGB(80, 70, 90) or Color3.fromRGB(170, 170, 175)
		atm.Density = night and 0.32 or 0.22; atm.Color = night and Color3.fromRGB(199, 170, 150) or Color3.fromRGB(215, 225, 240)
		for _, l in ipairs(lights) do if l.Parent then l.Enabled = night end end
		task.wait(5)
	end
end)

-- ===== แม่น้ำเจ้าพระยา + เรือหางยาว + พระปรางค์วัดอรุณ (หลังโซนเต็นท์) =====
part({ Size = Vector3.new(700, 1, 90), Position = Vector3.new(0, -0.6, 300), Color = Color3.fromRGB(70, 110, 120), Material = Enum.Material.Glass, Transparency = 0.15 })
part({ Size = Vector3.new(700, 2, 6), Position = Vector3.new(0, 0.5, 252), Color = Color3.fromRGB(160, 150, 140), Material = Enum.Material.Concrete })
for x = -300, 300, 12 do part({ Size = Vector3.new(0.4, 2, 0.4), Position = Vector3.new(x, 2.5, 252), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Metal }) end
part({ Size = Vector3.new(700, 0.15, 0.15), Position = Vector3.new(0, 3.4, 252), Color = Color3.fromRGB(230, 230, 230) })
-- ท่าเรือ
part({ Size = Vector3.new(20, 1, 14), Position = Vector3.new(40, 0.3, 262), Color = Color3.fromRGB(120, 85, 55), Material = Enum.Material.WoodPlanks })
neonSign("🛥️ ท่าเรือ PIER", Vector3.new(8, 1.6, 0.2), CFrame.new(40, 5, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 100, 170))
-- พระปรางค์ (ฝั่งตรงข้ามแม่น้ำ)
for k = 0, 7 do local w = 30 - k * 3.4; part({ Size = Vector3.new(w, 7, w), Position = Vector3.new(-40, 3.5 + k * 7, 380), Color = Color3.fromRGB(225, 215, 200), Material = Enum.Material.Concrete }) end
part({ Size = Vector3.new(2, 14, 2), Position = Vector3.new(-40, 66, 380), Color = Color3.fromRGB(255, 215, 90), Material = Enum.Material.Metal })
for _, dx in ipairs({ -22, 22 }) do for k = 0, 4 do local w = 12 - k * 2; part({ Size = Vector3.new(w, 5, w), Position = Vector3.new(-40 + dx, 2.5 + k * 5, 380), Color = Color3.fromRGB(225, 215, 200), Material = Enum.Material.Concrete }) end end
local pl = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(2, 2, 2), Position = Vector3.new(-40, 74, 380), Color = Color3.fromRGB(255, 230, 150), Material = Enum.Material.Neon }); local pll = Instance.new("PointLight"); pll.Range = 60; pll.Brightness = 2; pll.Color = Color3.fromRGB(255, 220, 140); pll.Parent = pl
-- เรือหางยาววิ่งไปมา
local function longtail(z, dir, delay)
	local m = Instance.new("Model"); m.Parent = deco
	local hull = part({ Size = Vector3.new(3, 1.6, 16), Position = Vector3.new(0, 0.6, z), Color = Color3.fromRGB(150, 90, 50), Material = Enum.Material.Wood }, m)
	part({ Size = Vector3.new(3.2, 0.3, 8), Position = Vector3.new(0, 2.6, z - 1), Color = Color3.fromRGB(200, 50, 50), Material = Enum.Material.Fabric }, m)
	for _, dz in ipairs({ -3.5, 3.5 }) do part({ Size = Vector3.new(0.2, 2, 0.2), Position = Vector3.new(0, 1.6, z - 1 + dz), Color = Color3.fromRGB(200, 200, 200) }, m) end
	part({ Size = Vector3.new(0.3, 0.3, 5), CFrame = CFrame.new(0, 1.2, z + 9) * CFrame.Angles(math.rad(-20), 0, 0), Color = Color3.fromRGB(60, 60, 60), Material = Enum.Material.Metal }, m)
	for _, c in ipairs({ Color3.fromRGB(255, 120, 120), Color3.fromRGB(255, 220, 120), Color3.fromRGB(120, 200, 255) }) do part({ Size = Vector3.new(0.6, 1.2, 0.6), Position = Vector3.new(0, 1.8, z - 6), Color = c, Material = Enum.Material.Fabric }, m) end
	m.PrimaryPart = hull
	for _, p in ipairs(m:GetChildren()) do if p ~= hull then local w = Instance.new("WeldConstraint"); w.Part0 = hull; w.Part1 = p; w.Parent = p; p.Anchored = false end end
	task.spawn(function()
		task.wait(delay)
		while true do
			m:PivotTo(CFrame.new(-330 * dir, 0.6, z) * CFrame.Angles(0, math.rad(dir > 0 and -90 or 90), 0))
			local tw = TweenService:Create(hull, TweenInfo.new(60, Enum.EasingStyle.Linear), { CFrame = CFrame.new(330 * dir, 0.6, z) * CFrame.Angles(0, math.rad(dir > 0 and -90 or 90), 0) })
			tw:Play(); tw.Completed:Wait(); task.wait(5)
		end
	end)
end
longtail(285, 1, 0); longtail(315, -1, 20); longtail(300, 1, 40)
