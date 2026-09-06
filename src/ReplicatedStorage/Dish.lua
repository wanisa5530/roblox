-- สร้างโมเดลอาหารจาก Part (ใช้ทั้งโชว์บนโต๊ะครัวและถือในมือ)
local _Config = require(script.Parent.Config)
local Dish = {}
local function p(parent, shape, size, offset, color, material)
	local x = Instance.new("Part")
	x.Shape = shape or Enum.PartType.Block
	x.Size = size; x.CFrame = CFrame.new(offset); x.Color = color
	x.Material = material or Enum.Material.SmoothPlastic
	x.Anchored = false; x.CanCollide = false; x.Massless = true
	x.TopSurface = Enum.SurfaceType.Smooth; x.BottomSurface = Enum.SurfaceType.Smooth
	x.Parent = parent
	return x
end
-- รายการชิ้นส่วนต่อเมนู: {shape, size, offset, color}
local B, C, S = Enum.PartType.Block, Enum.PartType.Cylinder, Enum.PartType.Ball
local plate = { C, Vector3.new(0.15, 2.2, 2.2), Vector3.new(0, 0.07, 0), Color3.fromRGB(245, 245, 240) }
local bowl = { C, Vector3.new(0.9, 1.8, 1.8), Vector3.new(0, 0.45, 0), Color3.fromRGB(70, 90, 140) }
local stick = function(z) return { B, Vector3.new(0.08, 0.08, 2.4), Vector3.new(0, 0.3, z), Color3.fromRGB(200, 180, 140) } end
Dish.Parts = {
	MooPing = { plate, stick(0), stick(0.4), stick(-0.4),
		{ B, Vector3.new(0.35, 0.3, 1.4), Vector3.new(0, 0.3, 0), Color3.fromRGB(150, 80, 40) },
		{ B, Vector3.new(0.35, 0.3, 1.4), Vector3.new(0, 0.3, 0.4), Color3.fromRGB(160, 85, 45) },
		{ B, Vector3.new(0.35, 0.3, 1.4), Vector3.new(0, 0.3, -0.4), Color3.fromRGB(140, 75, 40) } },
	KhanomKrok = { plate, { S, Vector3.new(0.6, 0.6, 0.6), Vector3.new(0.4, 0.35, 0.4), Color3.fromRGB(250, 240, 210) },
		{ S, Vector3.new(0.6, 0.6, 0.6), Vector3.new(-0.4, 0.35, 0.4), Color3.fromRGB(250, 240, 210) },
		{ S, Vector3.new(0.6, 0.6, 0.6), Vector3.new(0.4, 0.35, -0.4), Color3.fromRGB(250, 240, 210) },
		{ S, Vector3.new(0.6, 0.6, 0.6), Vector3.new(-0.4, 0.35, -0.4), Color3.fromRGB(250, 240, 210) } },
	PadThai = { plate, { C, Vector3.new(0.5, 1.6, 1.6), Vector3.new(0, 0.35, 0), Color3.fromRGB(235, 160, 60) },
		{ S, Vector3.new(0.5, 0.5, 0.5), Vector3.new(0.4, 0.7, 0.2), Color3.fromRGB(255, 220, 120) },
		{ B, Vector3.new(0.3, 0.1, 0.5), Vector3.new(-0.5, 0.65, -0.3), Color3.fromRGB(120, 200, 80) } },
	SomTam = { plate, { C, Vector3.new(0.6, 1.5, 1.5), Vector3.new(0, 0.4, 0), Color3.fromRGB(160, 210, 90) },
		{ S, Vector3.new(0.35, 0.35, 0.35), Vector3.new(0.3, 0.75, 0.3), Color3.fromRGB(220, 50, 50) },
		{ S, Vector3.new(0.35, 0.35, 0.35), Vector3.new(-0.3, 0.75, -0.2), Color3.fromRGB(220, 50, 50) } },
	KaiJeow = { plate, { C, Vector3.new(0.4, 1.7, 1.7), Vector3.new(0, 0.3, 0), Color3.fromRGB(240, 200, 70), Enum.Material.Sand },
		{ B, Vector3.new(1, 0.6, 1), Vector3.new(0.6, 0.35, 0.6), Color3.fromRGB(250, 250, 250) } },
	Roti = { plate, { B, Vector3.new(1.4, 0.2, 1.4), Vector3.new(0, 0.2, 0), Color3.fromRGB(225, 190, 120) },
		{ B, Vector3.new(1.2, 0.15, 1.2), Vector3.new(0, 0.4, 0), Color3.fromRGB(230, 200, 130) },
		{ B, Vector3.new(0.9, 0.05, 0.9), Vector3.new(0, 0.5, 0), Color3.fromRGB(120, 80, 40) } },
	Satay = { plate, stick(0.3), stick(-0.3), { B, Vector3.new(0.3, 0.3, 1.2), Vector3.new(0, 0.3, 0.3), Color3.fromRGB(230, 170, 70) },
		{ B, Vector3.new(0.3, 0.3, 1.2), Vector3.new(0, 0.3, -0.3), Color3.fromRGB(230, 170, 70) },
		{ C, Vector3.new(0.4, 0.7, 0.7), Vector3.new(0.7, 0.3, 0), Color3.fromRGB(190, 120, 50) } },
	BoatNoodle = { bowl, { C, Vector3.new(0.2, 1.5, 1.5), Vector3.new(0, 0.9, 0), Color3.fromRGB(90, 40, 30) },
		{ B, Vector3.new(0.5, 0.2, 0.5), Vector3.new(0.3, 1.05, 0.2), Color3.fromRGB(150, 60, 50) },
		{ B, Vector3.new(0.4, 0.15, 0.4), Vector3.new(-0.3, 1.03, -0.2), Color3.fromRGB(110, 190, 90) } },
	KhaoManGai = { plate, { C, Vector3.new(0.5, 1.4, 1.4), Vector3.new(-0.2, 0.35, 0), Color3.fromRGB(250, 245, 230) },
		{ B, Vector3.new(0.6, 0.3, 1.2), Vector3.new(0.6, 0.45, 0), Color3.fromRGB(240, 220, 170) },
		{ B, Vector3.new(0.3, 0.3, 0.3), Vector3.new(-0.5, 0.75, 0.5), Color3.fromRGB(80, 160, 70) } },
	PadKrapao = { plate, { C, Vector3.new(0.5, 1.4, 1.4), Vector3.new(-0.3, 0.35, 0), Color3.fromRGB(250, 245, 230) },
		{ B, Vector3.new(0.9, 0.35, 1.1), Vector3.new(0.5, 0.45, 0), Color3.fromRGB(120, 60, 40) },
		{ B, Vector3.new(0.7, 0.15, 0.7), Vector3.new(-0.3, 0.7, 0), Color3.fromRGB(255, 200, 80) },
		{ B, Vector3.new(0.15, 0.15, 0.5), Vector3.new(0.6, 0.7, 0.3), Color3.fromRGB(220, 40, 40) } },
	TomYum = { bowl, { C, Vector3.new(0.2, 1.5, 1.5), Vector3.new(0, 0.9, 0), Color3.fromRGB(230, 90, 50) },
		{ B, Vector3.new(0.5, 0.3, 0.3), Vector3.new(0.3, 1.1, 0.2), Color3.fromRGB(255, 150, 120) },
		{ B, Vector3.new(0.5, 0.3, 0.3), Vector3.new(-0.3, 1.1, -0.2), Color3.fromRGB(255, 150, 120) },
		{ B, Vector3.new(0.3, 0.1, 0.3), Vector3.new(0, 1.05, -0.4), Color3.fromRGB(100, 180, 80) } },
	HoiTod = { plate, { C, Vector3.new(0.4, 1.7, 1.7), Vector3.new(0, 0.3, 0), Color3.fromRGB(235, 190, 90), Enum.Material.Sand },
		{ B, Vector3.new(0.5, 0.2, 0.5), Vector3.new(0.4, 0.6, 0.3), Color3.fromRGB(200, 140, 60) },
		{ B, Vector3.new(0.7, 0.1, 0.7), Vector3.new(-0.4, 0.55, -0.3), Color3.fromRGB(170, 220, 120) } },
	MangoRice = { plate, { B, Vector3.new(1, 0.4, 0.8), Vector3.new(-0.5, 0.35, 0), Color3.fromRGB(250, 245, 235) },
		{ B, Vector3.new(0.5, 0.35, 1.3), Vector3.new(0.4, 0.35, 0), Color3.fromRGB(255, 190, 40) },
		{ B, Vector3.new(0.5, 0.35, 1.3), Vector3.new(0.75, 0.35, 0.15), Color3.fromRGB(255, 180, 30) } },
	ThaiTea = { { C, Vector3.new(0.1, 1.2, 1.2), Vector3.new(0, 0.05, 0), Color3.fromRGB(245, 245, 240) },
		{ C, Vector3.new(2, 1, 1), Vector3.new(0, 1.05, 0), Color3.fromRGB(225, 130, 60), Enum.Material.Glass },
		{ B, Vector3.new(0.12, 2.4, 0.12), Vector3.new(0.2, 1.6, 0), Color3.fromRGB(240, 100, 100) } },
	DurianCart = { plate, { S, Vector3.new(1.4, 1.2, 1.6), Vector3.new(0, 0.6, 0), Color3.fromRGB(210, 200, 90) },
		{ B, Vector3.new(0.6, 0.3, 0.8), Vector3.new(0, 1.25, 0), Color3.fromRGB(250, 235, 150) } },
}
-- แก้ให้ Cylinder แนวนอนกลายเป็นแนวตั้ง (Cylinder ใน Roblox หมุนตามแกน X)
function Dish.build(foodId)
	local parts = Dish.Parts[foodId] or Dish.Parts.PadThai
	local m = Instance.new("Model"); m.Name = "Dish_" .. foodId
	local root
	for i, d in ipairs(parts) do
		local x = p(m, d[1], d[2], d[3], d[4], d[5])
		if d[1] == Enum.PartType.Cylinder then x.CFrame = CFrame.new(d[3]) * CFrame.Angles(0, 0, math.rad(90)) end
		if i == 1 then root = x; m.PrimaryPart = x else
			local w = Instance.new("Weld"); w.Part0 = root; w.Part1 = x; w.C0 = root.CFrame:Inverse() * x.CFrame; w.Parent = x
		end
	end
	m:SetAttribute("FoodId", foodId)
	return m
end
return Dish
