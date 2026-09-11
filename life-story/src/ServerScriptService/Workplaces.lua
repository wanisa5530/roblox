-- ห้องทำงานภายในอาคาร (สร้างลอยบนฟ้าเหนือเมือง ผู้เล่นถูกวาร์ปเข้าไปตอนเข้ากะ และกลับออกมาที่ประตูเมื่อเลิกงาน)
local Config = require(game.ReplicatedStorage.Config)
local W = { rooms = {} }
local Y = 400
local function part(props, parent)
	local p = Instance.new("Part"); p.Anchored = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent; return p
end
local THEMES = {
	Chef = { wall = { 250, 245, 235 }, floor = { 200, 200, 205 }, props = function(m, o)
		for i = 0, 3 do part({ Size = Vector3.new(6, 3, 3), Position = o + Vector3.new(-9 + i * 6, 1.5, -9), Color = Color3.fromRGB(220, 220, 225), Material = Enum.Material.Metal }, m); for k = 0, 1 do for j = 0, 1 do part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 1.4, 1.4), CFrame = CFrame.new(o + Vector3.new(-10.5 + i * 6 + k * 3, 3.1, -9.7 + j * 1.5)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(40, 40, 40) }, m) end end end
		part({ Size = Vector3.new(24, 1.5, 2), Position = o + Vector3.new(0, 5.5, -9), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Metal }, m)
		for i = 0, 2 do part({ Size = Vector3.new(4, 3, 2), Position = o + Vector3.new(-6 + i * 6, 1.5, 4), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Metal }, m); part({ Size = Vector3.new(1.2, 0.6, 1.2), Position = o + Vector3.new(-6 + i * 6, 3.3, 4), Color = Color3.fromRGB(250, 200, 80) }, m) end
		part({ Size = Vector3.new(3, 6, 3), Position = o + Vector3.new(11, 3, 0), Color = Color3.fromRGB(230, 230, 235), Material = Enum.Material.Metal }, m)
	end },
	Doctor = { wall = { 235, 245, 250 }, floor = { 225, 235, 240 }, props = function(m, o)
		for i = 0, 2 do local bx = o + Vector3.new(-8 + i * 8, 0, -7); part({ Size = Vector3.new(4, 1.2, 7), Position = bx + Vector3.new(0, 1.2, 0), Color = Color3.fromRGB(240, 240, 245) }, m); part({ Size = Vector3.new(4, 0.5, 7), Position = bx + Vector3.new(0, 2.1, 0), Color = Color3.fromRGB(120, 200, 230), Material = Enum.Material.Fabric }, m); part({ Size = Vector3.new(4, 2.5, 0.3), Position = bx + Vector3.new(0, 2.5, -3.6), Color = Color3.fromRGB(200, 200, 205) }, m); part({ Size = Vector3.new(0.3, 5, 0.3), Position = bx + Vector3.new(2.6, 2.5, 2), Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Metal }, m); part({ Size = Vector3.new(1, 1.4, 0.6), Position = bx + Vector3.new(2.6, 5.2, 2), Color = Color3.fromRGB(220, 240, 250), Material = Enum.Material.Glass }, m) end
		part({ Size = Vector3.new(6, 3, 2.5), Position = o + Vector3.new(6, 1.5, 6), Color = Color3.fromRGB(250, 250, 250) }, m); part({ Size = Vector3.new(1.6, 1.2, 0.1), Position = o + Vector3.new(6, 3.7, 6), Color = Color3.fromRGB(80, 200, 120), Material = Enum.Material.Neon }, m)
		part({ Size = Vector3.new(2, 1.8, 0.2), Position = o + Vector3.new(0, 7, 11.8), Color = Color3.fromRGB(230, 50, 50) }, m); part({ Size = Vector3.new(1.4, 0.5, 0.25), Position = o + Vector3.new(0, 7, 11.8), Color = Color3.new(1, 1, 1) }, m); part({ Size = Vector3.new(0.5, 1.4, 0.25), Position = o + Vector3.new(0, 7, 11.8), Color = Color3.new(1, 1, 1) }, m)
	end },
	Police = { wall = { 220, 228, 240 }, floor = { 120, 125, 135 }, props = function(m, o)
		for i = 0, 2 do part({ Size = Vector3.new(6, 2.8, 3), Position = o + Vector3.new(-8 + i * 8, 1.4, -6), Color = Color3.fromRGB(90, 70, 50), Material = Enum.Material.Wood }, m); part({ Size = Vector3.new(1.6, 1.2, 0.2), Position = o + Vector3.new(-8 + i * 8, 3.6, -6.5), Color = Color3.fromRGB(60, 120, 220), Material = Enum.Material.Neon }, m) end
		for i = 0, 3 do part({ Size = Vector3.new(0.3, 8, 0.3), Position = o + Vector3.new(6 + i * 2, 4, 8), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, m) end
		part({ Size = Vector3.new(12, 0.3, 0.3), Position = o + Vector3.new(9, 7.8, 8), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, m)
		part({ Size = Vector3.new(4, 4, 0.2), Position = o + Vector3.new(-9, 6, 11.8), Color = Color3.fromRGB(240, 240, 240) }, m); part({ Size = Vector3.new(3, 1, 0.1), Position = o + Vector3.new(-9, 6, 11.7), Color = Color3.fromRGB(230, 60, 60) }, m)
	end },
	Programmer = { wall = { 240, 240, 245 }, floor = { 90, 95, 110 }, props = function(m, o)
		for r = 0, 1 do for i = 0, 2 do local d = o + Vector3.new(-8 + i * 8, 0, -6 + r * 10); part({ Size = Vector3.new(6, 0.3, 3), Position = d + Vector3.new(0, 2.6, 0), Color = Color3.fromRGB(240, 240, 240) }, m); for _, sx in ipairs({ -2.7, 2.7 }) do part({ Size = Vector3.new(0.3, 2.6, 3), Position = d + Vector3.new(sx, 1.3, 0), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal }, m) end; part({ Size = Vector3.new(2.6, 1.6, 0.1), Position = d + Vector3.new(-1.3, 3.7, -1), Color = Color3.fromRGB(40, 60, 90), Material = Enum.Material.Neon }, m); part({ Size = Vector3.new(2.6, 1.6, 0.1), Position = d + Vector3.new(1.5, 3.7, -1), Color = Color3.fromRGB(30, 80, 110), Material = Enum.Material.Neon }, m); part({ Size = Vector3.new(2, 0.1, 0.8), Position = d + Vector3.new(0, 2.8, 0.6), Color = Color3.fromRGB(50, 50, 55) }, m) end end
		part({ Size = Vector3.new(3, 5, 1), Position = o + Vector3.new(11, 2.5, 6), Color = Color3.fromRGB(30, 30, 35), Material = Enum.Material.Metal }, m); for i = 1, 5 do part({ Size = Vector3.new(0.3, 0.3, 0.2), Position = o + Vector3.new(10.2 + (i % 2) * 0.5, 0.8 + i * 0.7, 5.4), Color = i % 2 == 0 and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(60, 140, 255), Material = Enum.Material.Neon }, m) end
	end },
	Teacher = { wall = { 250, 240, 220 }, floor = { 200, 170, 130 }, props = function(m, o)
		part({ Size = Vector3.new(16, 6, 0.3), Position = o + Vector3.new(0, 6, -11.6), Color = Color3.fromRGB(30, 70, 50) }, m); part({ Size = Vector3.new(6, 2.5, 3), Position = o + Vector3.new(0, 1.25, -7), Color = Color3.fromRGB(150, 110, 70), Material = Enum.Material.Wood }, m)
		for r = 0, 2 do for i = 0, 3 do part({ Size = Vector3.new(3, 0.3, 2), Position = o + Vector3.new(-7.5 + i * 5, 2.4, 0 + r * 4), Color = Color3.fromRGB(200, 160, 110), Material = Enum.Material.Wood }, m); part({ Size = Vector3.new(0.3, 2.4, 0.3), Position = o + Vector3.new(-7.5 + i * 5, 1.2, 0.8 + r * 4), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Metal }, m); part({ Size = Vector3.new(2, 0.3, 2), Position = o + Vector3.new(-7.5 + i * 5, 1.6, 2.2 + r * 4), Color = Color3.fromRGB(60, 120, 200) }, m) end end
	end },
	Artist = { wall = { 250, 250, 250 }, floor = { 190, 170, 140 }, props = function(m, o)
		for i = 0, 3 do local e = o + Vector3.new(-9 + i * 6, 0, -5); for _, sx in ipairs({ -0.9, 0.9 }) do part({ Size = Vector3.new(0.2, 6, 0.2), CFrame = CFrame.new(e + Vector3.new(sx, 3, 0)) * CFrame.Angles(math.rad(-12), 0, 0), Color = Color3.fromRGB(150, 110, 70), Material = Enum.Material.Wood }, m) end; part({ Size = Vector3.new(3.4, 4, 0.15), CFrame = CFrame.new(e + Vector3.new(0, 3.6, 0.2)) * CFrame.Angles(math.rad(-12), 0, 0), Color = Color3.fromHSV(i / 4, 0.5, 0.95) }, m) end
		for i = 0, 5 do part({ Size = Vector3.new(3, 2.4, 0.15), Position = o + Vector3.new(-10 + i * 4, 6, 11.7), Color = Color3.fromHSV((i * 0.17) % 1, 0.6, 0.9) }, m); part({ Size = Vector3.new(3.4, 2.8, 0.1), Position = o + Vector3.new(-10 + i * 4, 6, 11.8), Color = Color3.fromRGB(60, 40, 30), Material = Enum.Material.Wood }, m) end
	end },
	Barista = { wall = { 240, 225, 205 }, floor = { 150, 110, 70 }, props = function(m, o)
		part({ Size = Vector3.new(14, 3, 3), Position = o + Vector3.new(0, 1.5, -6), Color = Color3.fromRGB(110, 75, 45), Material = Enum.Material.Wood }, m); part({ Size = Vector3.new(3, 2.2, 2), Position = o + Vector3.new(-4, 4.1, -6), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal }, m); part({ Size = Vector3.new(2, 1.6, 1), Position = o + Vector3.new(2, 3.8, -6), Color = Color3.fromRGB(40, 40, 45) }, m)
		for i = 0, 2 do part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 4, 4), CFrame = CFrame.new(o + Vector3.new(-6 + i * 6, 2.5, 5)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(160, 120, 80), Material = Enum.Material.Wood }, m); part({ Size = Vector3.new(0.4, 2.5, 0.4), Position = o + Vector3.new(-6 + i * 6, 1.25, 5), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, m) end
	end },
	Student = { wall = { 250, 240, 220 }, floor = { 200, 170, 130 }, props = nil },
}
THEMES.Student.props = THEMES.Teacher.props
function W.build()
	local folder = Instance.new("Folder"); folder.Name = "Workplaces"; folder.Parent = workspace
	local i = 0
	for key, th in pairs(THEMES) do
		i += 1
		local o = Vector3.new(-600 + i * 80, Y, -600)
		local m = Instance.new("Model"); m.Name = "Room_" .. key; m.Parent = folder
		part({ Size = Vector3.new(30, 1, 26), Position = o + Vector3.new(0, -0.5, 0), Color = Color3.fromRGB(unpack(th.floor)), Material = Enum.Material.WoodPlanks }, m)
		part({ Size = Vector3.new(30, 0.5, 26), Position = o + Vector3.new(0, 12, 0), Color = Color3.fromRGB(245, 245, 245) }, m)
		local wc = Color3.fromRGB(unpack(th.wall))
		part({ Size = Vector3.new(30, 12, 0.5), Position = o + Vector3.new(0, 6, -13), Color = wc }, m); part({ Size = Vector3.new(30, 12, 0.5), Position = o + Vector3.new(0, 6, 13), Color = wc }, m)
		part({ Size = Vector3.new(0.5, 12, 26), Position = o + Vector3.new(-15, 6, 0), Color = wc }, m); part({ Size = Vector3.new(0.5, 12, 26), Position = o + Vector3.new(15, 6, 0), Color = wc }, m)
		for _, wx in ipairs({ -9, 0, 9 }) do part({ Size = Vector3.new(5, 4, 0.3), Position = o + Vector3.new(wx, 7, 13), Color = Color3.fromRGB(150, 200, 235), Material = Enum.Material.Glass, Transparency = 0.4 }, m) end
		local lamp = part({ Size = Vector3.new(6, 0.2, 1.2), Position = o + Vector3.new(0, 11.7, 0), Color = Color3.fromRGB(255, 250, 240), Material = Enum.Material.Neon }, m)
		local l = Instance.new("PointLight"); l.Range = 30; l.Brightness = 0.7; l.Parent = lamp
		if th.props then pcall(th.props, m, o) end
		W.rooms[key] = o + Vector3.new(0, 3, 9)
	end
end
function W.roomFor(kind, career) return W.rooms[kind == "work" and career or "Student"] or W.rooms.Student end
return W
