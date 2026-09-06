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
	local s = part({ Size = size, CFrame = cf, Color = bg, Material = Enum.Material.Neon }, parent)
	local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.Parent = s
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
			part({ Size = Vector3.new(4, 4, 0.2), Position = Vector3.new(x + w * 7, f * 8 - 4, -30.9), Color = lit and Color3.fromRGB(255, 220, 150) or Color3.fromRGB(40, 50, 70), Material = lit and Enum.Material.Neon or Enum.Material.Glass })
		end
		part({ Size = Vector3.new(23, 0.3, 3), Position = Vector3.new(x, f * 8 - 7, -29.5), Color = Color3.fromRGB(150, 150, 150), Material = Enum.Material.Concrete })
		for w = -10, 10, 2.5 do part({ Size = Vector3.new(0.15, 1.2, 0.15), Position = Vector3.new(x + w, f * 8 - 6.3, -28.2), Color = Color3.fromRGB(90, 90, 90) }) end
	end
	-- กันสาด + ป้ายร้าน + ประตูม้วน
	part({ Size = Vector3.new(23, 0.3, 5), Position = Vector3.new(x, 7.5, -28.5), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal })
	local sn = shopNames[i % #shopNames + 1]
	neonSign(sn[1], Vector3.new(18, 3, 0.3), CFrame.new(x, 10, -30.8), sn[2], sn[3])
	part({ Size = Vector3.new(10, 6.5, 0.3), Position = Vector3.new(x, 3.5, -30.9), Color = Color3.fromRGB(255, 240, 210), Material = Enum.Material.Neon })
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
