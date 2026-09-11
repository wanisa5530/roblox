-- บ้าน: จัดสรรที่ดิน วางเฟอร์นิเจอร์ ปฏิสัมพันธ์ (กิน นอน อาบน้ำ ฯลฯ) บิล
local Config = require(game.ReplicatedStorage.Config)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Map = require(script.Parent.MapService)
local H = { owner = {}, active = {}, onAction = nil }  -- active[player] = {item, t0}
local function fcfg(key) for _, f in ipairs(Config.Furniture) do if f.key == key then return f end end end
H.fcfg = fcfg
local function lotOf(p)
	local c = Core.char(p); if not c then return nil end
	return Map.lots[c.lotIndex]
end
H.lotOf = lotOf
local function prompt(parent, action, obj, cb)
	local pp = Instance.new("ProximityPrompt"); pp.ActionText = action; pp.ObjectText = obj or ""; pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false
	pp.Parent = parent; pp.Triggered:Connect(cb); return pp
end
local ACTION = { bed = "sleep", kitchen = "eat", bath = "useToilet", fun = "watch", skill = "practice", outdoor = "garden", family = "play", decor = nil, safety = nil }
-- สร้างโมเดลเฟอร์นิเจอร์จาก Part
-- โมเดลเฟอร์นิเจอร์แบบละเอียด (ประกอบจากหลาย Part) ให้ดูเหมือนของจริง
local function sub(m, size, cf, color, material, shape)
	local q = Instance.new("Part"); q.Anchored = true; q.CanCollide = false; q.Size = size; q.CFrame = cf; q.Color = color; q.Material = material or Enum.Material.SmoothPlastic
	if shape then q.Shape = shape end
	q.Parent = m; return q
end
local WOOD, DARK, WHITE, METAL = Color3.fromRGB(150, 105, 60), Color3.fromRGB(40, 40, 45), Color3.fromRGB(245, 245, 245), Color3.fromRGB(190, 190, 195)
local DETAIL = {
	bed = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.6, s.Z); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 1.1, 0); body.Color = WOOD; body.Material = Enum.Material.Wood   -- โครงเตียง
		for _, o in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do sub(m, Vector3.new(0.4, 0.8, 0.4), body.CFrame * CFrame.new(o[1] * (s.X / 2 - 0.3), -0.7, o[2] * (s.Z / 2 - 0.3)), WOOD, Enum.Material.Wood) end
		sub(m, Vector3.new(s.X - 0.4, 0.9, s.Z - 0.4), body.CFrame * CFrame.new(0, 0.75, 0), Color3.fromRGB(240, 240, 235), Enum.Material.Fabric)           -- ที่นอน
		sub(m, Vector3.new(s.X - 0.4, 0.5, s.Z * 0.62), body.CFrame * CFrame.new(0, 1.35, s.Z * 0.17), col, Enum.Material.Fabric)                              -- ผ้าห่ม
		sub(m, Vector3.new(s.X / 2 - 0.6, 0.5, 1.6), body.CFrame * CFrame.new(-s.X / 4 + 0.1, 1.45, -s.Z / 2 + 1.3), WHITE, Enum.Material.Fabric)             -- หมอน 2 ใบ
		sub(m, Vector3.new(s.X / 2 - 0.6, 0.5, 1.6), body.CFrame * CFrame.new(s.X / 4 - 0.1, 1.45, -s.Z / 2 + 1.3), WHITE, Enum.Material.Fabric)
		sub(m, Vector3.new(s.X, 2.6, 0.4), body.CFrame * CFrame.new(0, 1.2, -s.Z / 2 - 0.1), WOOD, Enum.Material.Wood)                                        -- หัวเตียง
	end,
	Fridge = function(m, body, s, col)
		body.Material = Enum.Material.Metal; body.Reflectance = 0.1
		sub(m, Vector3.new(s.X + 0.05, 0.1, s.Z + 0.05), body.CFrame * CFrame.new(0, s.Y * 0.15, 0), DARK)                       -- เส้นแบ่งประตู
		sub(m, Vector3.new(0.25, 1.6, 0.25), body.CFrame * CFrame.new(s.X / 2 - 0.5, s.Y * 0.35, s.Z / 2 + 0.15), METAL, Enum.Material.Metal)  -- มือจับบน
		sub(m, Vector3.new(0.25, 1.0, 0.25), body.CFrame * CFrame.new(s.X / 2 - 0.5, -s.Y * 0.15, s.Z / 2 + 0.15), METAL, Enum.Material.Metal) -- มือจับล่าง
	end,
	Stove = function(m, body, s, col)
		body.Color = Color3.fromRGB(220, 220, 225); body.Material = Enum.Material.Metal
		sub(m, Vector3.new(s.X, 0.15, s.Z), body.CFrame * CFrame.new(0, s.Y / 2 + 0.05, 0), DARK)                                 -- เตาด้านบน
		for _, o in ipairs({ { -0.7, -0.7 }, { 0.7, -0.7 }, { -0.7, 0.7 }, { 0.7, 0.7 } }) do sub(m, Vector3.new(0.1, 0.9, 0.9), body.CFrame * CFrame.new(o[1], s.Y / 2 + 0.16, o[2]) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 60, 60), Enum.Material.Metal, Enum.PartType.Cylinder) end
		sub(m, Vector3.new(s.X - 0.4, s.Y * 0.5, 0.1), body.CFrame * CFrame.new(0, -s.Y * 0.15, s.Z / 2 + 0.05), Color3.fromRGB(30, 30, 35), Enum.Material.Glass)  -- ประตูเตาอบ
		sub(m, Vector3.new(s.X - 0.6, 0.15, 0.15), body.CFrame * CFrame.new(0, s.Y * 0.2, s.Z / 2 + 0.1), METAL, Enum.Material.Metal)
		sub(m, Vector3.new(s.X, 1.2, 1.6), body.CFrame * CFrame.new(0, s.Y / 2 + 4, -s.Z / 2 + 0.8), METAL, Enum.Material.Metal)     -- เครื่องดูดควัน
	end,
	Toilet = function(m, body, s, col)
		body.Size = Vector3.new(1.6, 1.4, 2.2); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 0.7, 0.3); body.Color = WHITE   -- โถ
		sub(m, Vector3.new(1.8, 0.2, 2.4), body.CFrame * CFrame.new(0, 0.8, 0), WHITE)                                                -- ฝารองนั่ง
		sub(m, Vector3.new(1.6, 1.8, 0.8), body.CFrame * CFrame.new(0, 1.2, -1.2), WHITE)                                             -- แท็งก์น้ำ
		sub(m, Vector3.new(0.5, 0.15, 0.3), body.CFrame * CFrame.new(0.4, 2.15, -1.2), METAL, Enum.Material.Metal)
	end,
	Shower = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.3, s.Z); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 0.15, 0); body.Color = WHITE      -- ถาดรอง
		sub(m, Vector3.new(s.X, s.Y - 0.3, 0.15), body.CFrame * CFrame.new(0, s.Y / 2, -s.Z / 2), Color3.fromRGB(200, 230, 240), Enum.Material.Glass).Transparency = 0.5
		sub(m, Vector3.new(0.15, s.Y - 0.3, s.Z), body.CFrame * CFrame.new(-s.X / 2, s.Y / 2, 0), Color3.fromRGB(200, 230, 240), Enum.Material.Glass).Transparency = 0.5
		sub(m, Vector3.new(0.2, s.Y - 1, 0.2), body.CFrame * CFrame.new(0, s.Y / 2, -s.Z / 2 + 0.3), METAL, Enum.Material.Metal)    -- ท่อ
		sub(m, Vector3.new(0.3, 1.2, 1.2), body.CFrame * CFrame.new(0, s.Y - 0.6, -s.Z / 2 + 0.9) * CFrame.Angles(0, 0, math.rad(90)), METAL, Enum.Material.Metal, Enum.PartType.Cylinder)  -- ฝักบัว
	end,
	Bathtub = function(m, body, s, col)
		body.Color = WHITE; body.Material = Enum.Material.SmoothPlastic
		sub(m, Vector3.new(s.X - 0.6, 0.3, s.Z - 0.6), body.CFrame * CFrame.new(0, s.Y / 2 - 0.2, 0), Color3.fromRGB(120, 190, 230), Enum.Material.Glass).Transparency = 0.3
		sub(m, Vector3.new(0.3, 0.8, 0.3), body.CFrame * CFrame.new(0, s.Y / 2 + 0.4, -s.Z / 2 + 0.5), METAL, Enum.Material.Metal)
	end,
	TV = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.6, 1.6); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 0.3, 0); body.Color = DARK           -- ตู้วางทีวี
		sub(m, Vector3.new(s.X, 1.2, 1.6), body.CFrame * CFrame.new(0, -0.9, 0), WOOD, Enum.Material.Wood)
		sub(m, Vector3.new(0.6, 0.6, 0.6), body.CFrame * CFrame.new(0, 0.6, 0), DARK)                                                        -- ขาตั้ง
		sub(m, Vector3.new(s.X, s.Y - 0.4, 0.2), body.CFrame * CFrame.new(0, s.Y / 2 + 0.7, 0), DARK)                                        -- กรอบจอ
		local scr = sub(m, Vector3.new(s.X - 0.3, s.Y - 0.7, 0.05), body.CFrame * CFrame.new(0, s.Y / 2 + 0.7, -0.13), Color3.fromRGB(80, 160, 255), Enum.Material.Neon)
		local sl = Instance.new("PointLight"); sl.Color = Color3.fromRGB(120, 180, 255); sl.Range = 8; sl.Brightness = 0.6; sl.Parent = scr
	end,
	Sofa = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.9, s.Z); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 0.75, 0); body.Material = Enum.Material.Fabric   -- เบาะนั่ง
		sub(m, Vector3.new(s.X, 1.5, 0.7), body.CFrame * CFrame.new(0, 0.9, -s.Z / 2 + 0.35), col, Enum.Material.Fabric)       -- พนักพิง
		sub(m, Vector3.new(0.6, 1.0, s.Z), body.CFrame * CFrame.new(-s.X / 2 + 0.3, 0.5, 0), col, Enum.Material.Fabric)        -- ที่วางแขน
		sub(m, Vector3.new(0.6, 1.0, s.Z), body.CFrame * CFrame.new(s.X / 2 - 0.3, 0.5, 0), col, Enum.Material.Fabric)
		for i = 1, 2 do sub(m, Vector3.new(1.2, 1.2, 0.5), body.CFrame * CFrame.new((i - 1.5) * 3, 1.0, -s.Z / 2 + 0.8) * CFrame.Angles(math.rad(-10), 0, 0), Color3.fromRGB(245, 230, 200), Enum.Material.Fabric) end  -- หมอนอิง
		for _, o in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do sub(m, Vector3.new(0.3, 0.6, 0.3), body.CFrame * CFrame.new(o[1] * (s.X / 2 - 0.4), -0.7, o[2] * (s.Z / 2 - 0.4)), DARK) end
	end,
	DiningTable = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.25, s.Z); body.CFrame = body.CFrame * CFrame.new(0, s.Y / 2 - 0.5, 0); body.Material = Enum.Material.Wood   -- หน้าโต๊ะ
		for _, o in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do sub(m, Vector3.new(0.3, s.Y - 0.5, 0.3), body.CFrame * CFrame.new(o[1] * (s.X / 2 - 0.4), -(s.Y - 0.5) / 2, o[2] * (s.Z / 2 - 0.4)), WOOD, Enum.Material.Wood) end
		for _, cx in ipairs({ -1.6, 1.6 }) do for _, cz in ipairs({ -1, 1 }) do
			local ccf = body.CFrame * CFrame.new(cx, -1.2, cz * (s.Z / 2 + 1.2))
			sub(m, Vector3.new(1.6, 0.25, 1.6), ccf, WOOD, Enum.Material.Wood)
			sub(m, Vector3.new(1.6, 1.8, 0.25), ccf * CFrame.new(0, 1.0, cz * 0.7), WOOD, Enum.Material.Wood)
			for _, o in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do sub(m, Vector3.new(0.2, 1.4, 0.2), ccf * CFrame.new(o[1] * 0.65, -0.8, o[2] * 0.65), WOOD, Enum.Material.Wood) end
		end end
		sub(m, Vector3.new(0.8, 0.9, 0.8), body.CFrame * CFrame.new(0, 0.55, 0), Color3.fromRGB(220, 240, 250), Enum.Material.Glass, Enum.PartType.Cylinder).CFrame = body.CFrame * CFrame.new(0, 0.55, 0) * CFrame.Angles(0, 0, math.rad(90))  -- แจกัน
	end,
	Bookshelf = function(m, body, s, col)
		body.Material = Enum.Material.Wood
		for i = 1, 3 do
			sub(m, Vector3.new(s.X - 0.3, 0.15, s.Z + 0.3), body.CFrame * CFrame.new(0, -s.Y / 2 + i * (s.Y / 4), 0), WOOD, Enum.Material.Wood)
			for j = 1, 6 do sub(m, Vector3.new(0.4, 1.1, 0.8), body.CFrame * CFrame.new(-s.X / 2 + 0.5 + j * 0.5, -s.Y / 2 + i * (s.Y / 4) + 0.65, 0), Color3.fromHSV((i * 7 + j * 13) % 10 / 10, 0.6, 0.85)) end
		end
	end,
	Computer = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.2, s.Z); body.CFrame = body.CFrame * CFrame.new(0, 0, 0); body.Material = Enum.Material.Wood; body.Color = WOOD   -- โต๊ะ
		for _, o in ipairs({ -1, 1 }) do sub(m, Vector3.new(0.2, s.Y, s.Z), body.CFrame * CFrame.new(o * (s.X / 2 - 0.1), -s.Y / 2, 0), WOOD, Enum.Material.Wood) end
		sub(m, Vector3.new(1.8, 1.2, 0.1), body.CFrame * CFrame.new(0, 0.9, -0.4), DARK)
		sub(m, Vector3.new(1.6, 1.0, 0.05), body.CFrame * CFrame.new(0, 0.9, -0.34), Color3.fromRGB(100, 200, 255), Enum.Material.Neon)
		sub(m, Vector3.new(1.4, 0.1, 0.5), body.CFrame * CFrame.new(0, 0.15, 0.4), Color3.fromRGB(60, 60, 65))
	end,
	Lamp = function(m, body, s, col)
		body.Size = Vector3.new(0.15, s.Y - 1.2, 0.15); body.CFrame = body.CFrame * CFrame.new(0, -0.5, 0); body.Color = METAL; body.Material = Enum.Material.Metal
		sub(m, Vector3.new(1, 0.15, 1), body.CFrame * CFrame.new(0, -(s.Y - 1.2) / 2, 0), DARK)
		sub(m, Vector3.new(1.4, 1.2, 1.4), body.CFrame * CFrame.new(0, (s.Y - 1.2) / 2 + 0.6, 0), Color3.fromRGB(255, 235, 190), Enum.Material.SmoothPlastic)
	end,
	Plant = function(m, body, s, col)
		body.Size = Vector3.new(1.2, 1.2, 1.2); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 0.6, 0); body.Color = Color3.fromRGB(190, 110, 70)   -- กระถาง
		sub(m, Vector3.new(0.2, 1.5, 0.2), body.CFrame * CFrame.new(0, 1.2, 0), Color3.fromRGB(80, 60, 40))
		sub(m, Vector3.new(1.8, 1.6, 1.8), body.CFrame * CFrame.new(0, 2.2, 0), col, Enum.Material.Grass, Enum.PartType.Ball)
	end,
	Painting = function(m, body, s, col)
		body.Color = Color3.fromRGB(60, 40, 30); body.Material = Enum.Material.Wood
		sub(m, Vector3.new(s.X - 0.4, s.Y - 0.4, 0.05), body.CFrame * CFrame.new(0, 0, -0.18), col)
		sub(m, Vector3.new(s.X * 0.4, s.Y * 0.4, 0.02), body.CFrame * CFrame.new(-0.3, 0.2, -0.22), Color3.fromRGB(250, 220, 90))
	end,
	Rug = function(m, body, s, col) body.Material = Enum.Material.Fabric; sub(m, Vector3.new(s.X - 1, 0.05, s.Z - 1), body.CFrame * CFrame.new(0, 0.12, 0), col:Lerp(Color3.new(1, 1, 1), 0.3), Enum.Material.Fabric) end,
	Aquarium = function(m, body, s, col)
		body.Material = Enum.Material.Glass; body.Transparency = 0.4; body.Color = Color3.fromRGB(90, 190, 230)
		sub(m, Vector3.new(s.X, 0.5, s.Z), body.CFrame * CFrame.new(0, -s.Y / 2 + 0.25, 0), DARK)
		sub(m, Vector3.new(s.X - 0.4, 0.4, s.Z - 0.4), body.CFrame * CFrame.new(0, -s.Y / 2 + 0.7, 0), Color3.fromRGB(230, 200, 140), Enum.Material.Sand)
		for i = 1, 3 do sub(m, Vector3.new(0.5, 0.3, 0.2), body.CFrame * CFrame.new(-1 + i * 0.7, -0.2 + (i % 2) * 0.6, 0), Color3.fromRGB(255, 140, 40)) end
		local al = Instance.new("PointLight"); al.Color = Color3.fromRGB(120, 200, 255); al.Range = 8; al.Parent = body
	end,
	Crib = function(m, body, s, col)
		body.Size = Vector3.new(s.X, 0.8, s.Z); body.CFrame = body.CFrame * CFrame.new(0, -s.Y / 2 + 1.0, 0); body.Material = Enum.Material.Fabric
		for i = 0, 6 do for _, o in ipairs({ -1, 1 }) do sub(m, Vector3.new(0.15, s.Y, 0.15), body.CFrame * CFrame.new(-s.X / 2 + i * (s.X / 6), s.Y / 2 - 1.0, o * s.Z / 2), WHITE) end end
		sub(m, Vector3.new(s.X, 0.2, 0.2), body.CFrame * CFrame.new(0, s.Y - 1.0, -s.Z / 2), WHITE); sub(m, Vector3.new(s.X, 0.2, 0.2), body.CFrame * CFrame.new(0, s.Y - 1.0, s.Z / 2), WHITE)
	end,
	Piano = function(m, body, s, col)
		body.Material = Enum.Material.SmoothPlastic; body.Reflectance = 0.2
		sub(m, Vector3.new(s.X - 0.6, 0.3, 1.2), body.CFrame * CFrame.new(0, s.Y / 2 - 1.2, s.Z / 2 + 0.6), WHITE)
		for i = 1, 12 do sub(m, Vector3.new(0.25, 0.2, 0.7), body.CFrame * CFrame.new(-s.X / 2 + 0.6 + i * (s.X - 1.2) / 12, s.Y / 2 - 1.0, s.Z / 2 + 0.4), DARK) end
		sub(m, Vector3.new(2, 0.3, 1.4), body.CFrame * CFrame.new(0, -s.Y / 2 + 1.6, s.Z / 2 + 2), DARK)
	end,
}
local function buildItem(cfg, cf, parent, id)
	local m = Instance.new("Model"); m.Name = cfg.key; m:SetAttribute("Key", cfg.key); m:SetAttribute("Id", id)
	local s = Vector3.new(cfg.size[1], cfg.size[2], cfg.size[3])
	local col = Color3.fromRGB(cfg.color[1], cfg.color[2], cfg.color[3])
	local body = Instance.new("Part"); body.Anchored = true; body.Size = s; body.CFrame = cf * CFrame.new(0, s.Y / 2, 0); body.Color = col; body.Material = Enum.Material.SmoothPlastic; body.Name = "Body"; body.Parent = m
	m.PrimaryPart = body
	local d = DETAIL[cfg.key] or (cfg.cat == "bed" and DETAIL.bed) or (cfg.key:sub(1, 2) == "TV" and DETAIL.TV)
	if d then pcall(d, m, body, s, col) end
	if cfg.light and not DETAIL[cfg.key] then local l = Instance.new("PointLight"); l.Range = 14; l.Brightness = 1.2; l.Color = Color3.fromRGB(255, 230, 170); l.Parent = body end
	if cfg.key == "Lamp" then local l = Instance.new("PointLight"); l.Range = 12; l.Brightness = 0.6; l.Color = Color3.fromRGB(255, 230, 170); l.Parent = body end
	if cfg.cat == "outdoor" then local plant = body:Clone(); plant.Size = Vector3.new(s.X - 1, 1.5, s.Z - 1); plant.CFrame = body.CFrame * CFrame.new(0, 1.2, 0); plant.Color = Color3.fromRGB(60, 160, 60); plant.Material = Enum.Material.Grass; plant.Name = "Plant"; plant.Parent = m end
	m.Parent = parent
	return m
end
-- ชุดเฟอร์นิเจอร์เริ่มต้น (บ้านมีของครบเหมือนย้ายเข้าจริง) : key, x, z, rot
H.Starter = {
	Apartment = { { "BedCheap", -8, -7, 0 }, { "Toilet", 10, -10, 90 }, { "Shower", 10, -4, 90 }, { "Fridge", 11, 5, -90 }, { "Stove", 11, 9, -90 }, { "Sofa", -6, 5, 0 }, { "TV", -6, 10, 180 }, { "DiningTable", 3, 8, 0 }, { "Lamp", -12, -3, 0 }, { "Rug", -6, 8, 0 }, { "Plant", 12, -1, 0 }, { "Painting", -8, -12, 0 } },
	House = { { "BedComfy", -10, -8, 0 }, { "Lamp", -14, -3, 0 }, { "Toilet", 13, -11, 90 }, { "Shower", 9, -11, 0 }, { "Fridge", 13, 10, -90 }, { "Stove", 13, 6, -90 }, { "DiningTable", 5, 9, 0 }, { "Sofa", -8, 7, 0 }, { "TV", -8, 12, 180 }, { "Rug", -8, 9, 0 }, { "Plant", 14, -3, 0 }, { "Bookshelf", -14, 4, 90 }, { "Painting", 0, -13, 0 }, { "Computer", -13, -12, 90 } },
}
function H.furnishStarter(p)
	local c = Core.char(p); if not c then return end
	local set = (c.lot == "Apartment") and H.Starter.Apartment or H.Starter.House
	c.furniture = {}
	for _, it in ipairs(set) do table.insert(c.furniture, { key = it[1], x = it[2], z = it[3], rot = it[4] }) end
end
-- วางเฟอร์นิเจอร์ทั้งหมดของบ้านใหม่ (เรียกตอนเข้า/ย้าย)
function H.rebuild(p)
	local c = Core.char(p); local lot = lotOf(p); if not c or not lot then return end
	local old = lot.model:FindFirstChild("Furniture"); if old then old:Destroy() end
	local f = Instance.new("Folder"); f.Name = "Furniture"; f.Parent = lot.model
	for i, it in ipairs(c.furniture) do
		local cfg = fcfg(it.key)
		if cfg then
			local cf = CFrame.new(lot.origin + Vector3.new(it.x, 0.25, it.z)) * CFrame.Angles(0, math.rad(it.rot or 0), 0)
			local m = buildItem(cfg, cf, f, i)
			local act = ACTION[cfg.cat]
			if cfg.key == "Toilet" then act = "useToilet" elseif cfg.key == "Shower" then act = "shower" elseif cfg.key == "Bathtub" then act = "bath" elseif cfg.key == "Stove" then act = "cook" elseif cfg.key == "Sofa" then act = "sit" elseif cfg.key == "Bookshelf" then act = "read" elseif cfg.key == "Phone" then act = "call" elseif cfg.key == "Treadmill" then act = "workout" elseif cfg.key == "Workbench" then act = "tinker" elseif cfg.key == "GameConsole" then act = "play" elseif cfg.key == "Crib" then act = nil elseif cfg.key == "PetBed" then act = "feedPet" elseif cfg.key == "DiningTable" then act = "sit" end
			if act then
				local pp = prompt(m.PrimaryPart, Core.T(p, act), Core.T(p, cfg.key), function(who)
					if who == p or (H.owner[who] == p) then H.startAction(who, it.key, i, act, m) end
				end)
				pp:SetAttribute("Action", act)
			end
			if cfg.harvest then
				local hp = prompt(m.PrimaryPart, Core.T(p, "harvest"), "", function(who) if who == p then H.harvest(who, m) end end); hp:SetAttribute("Action", "harvest"); hp.Enabled = false; m:SetAttribute("Planted", os.clock())
			end
		end
	end
	local ns = lot.model:FindFirstChild("NameSign"); if ns then ns.SurfaceGui.TextLabel.Text = "🏠 " .. c.name .. " (" .. (Core.isReal(p) and p.DisplayName or "?") .. ")" end
	H.updateEnvironment(p)
end
function H.updateEnvironment(p)
	local c = Core.char(p); if not c then return end
	local env = 30
	for _, it in ipairs(c.furniture) do local cfg = fcfg(it.key); if cfg and cfg.env then env += cfg.env * 2 end end
	if Core.trait(c, "Neat") then env += 10 end
	c.envBase = math.min(100, env)
end
-- ปฏิสัมพันธ์: เริ่ม action ค้างไว้ จน need เต็มหรือผู้เล่นเดินออก/กด stop
function H.startAction(p, key, id, act, model)
	local c = Core.char(p); if not c then return end
	local cfg = fcfg(key); if not cfg then return end
	if act == "cook" then
		if c.needs.energy < 5 then return end
		local skill = c.skills.cooking or 0
		if math.random() < Config.FireChance * (1 - skill / 12) * (Core.trait(c, "Clumsy") and 1.5 or 1) then H.startFire(p, model); return end
	end
	if act == "feedPet" then if c.pet then c.pet.fed = os.time(); c.needs.fun = math.min(100, c.needs.fun + 10); Core.notify(p, "feedPet", "green") end; return end
	H.active[p] = { key = key, cfg = cfg, act = act, t0 = os.clock(), model = model }
	if act == "sleep" then c.slept = (c.slept or 0) + 1 elseif act == "eat" or act == "cook" then c.ate = (c.ate or 0) + 1 end
	Core.push(p)
	if Core.isReal(p) then p:SetAttribute("Action", act); p:SetAttribute("ActionItem", cfg.key) end
	if Core.isReal(p) and p.Character and model and model.PrimaryPart then
		local hrp = p.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if act == "sleep" then
				-- นอนบนที่นอน: หัวหันไปทางหัวเตียง ล็อกตัวละครไว้ (ปุ่ม ■ หรือกดเดิน = ลุก)
				local frame = model.PrimaryPart
				if hum then hum.PlatformStand = true end
				hrp.Anchored = true
				-- นอนหงายบนที่นอน: ที่นอนสูงจากกลางโครง ~1.2 ตัวละครหนา ~1 → HRP สูง 1.9 จากโครง หัวไปทางหัวเตียง (−Z ของเตียง)
				hrp.CFrame = frame.CFrame * CFrame.new(0, 1.9, 0.6) * CFrame.Angles(math.rad(-90), 0, 0)
			elseif act == "sit" or act == "watch" then hrp.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 1.5, 0) end
		end
	end
	if H.onAction then H.onAction(p, act, cfg) end
end
function H.stopAction(p)
	local a = H.active[p]; H.active[p] = nil
	if Core.isReal(p) then p:SetAttribute("Action", nil); p:SetAttribute("ActionItem", nil)
		local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 16; hum.PlatformStand = false end
		if a and a.act == "sleep" and p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored = false; if a.model and a.model.PrimaryPart then local bbCf, bbSize = a.model:GetBoundingBox(); hrp.CFrame = CFrame.new(bbCf.Position + Vector3.new(0, 3, 0)) * CFrame.Angles(0, select(2, a.model.PrimaryPart.CFrame:ToOrientation()), 0) * CFrame.new(bbSize.X / 2 + 2, 0, 0) end end end
	end
end
-- tick ต่อวินาที: เติม need ตาม rate; ฝึกทักษะ; หยุดเมื่อเต็ม
function H.tick(p, c, dt)
	local a = H.active[p]; if not a then return end
	local cfg = a.cfg
	if cfg.need then
		local rate = cfg.rate * dt
		if a.act == "eat" then rate = rate * 2.5 elseif a.act == "cook" then rate = rate * (1 + (c.skills.cooking or 0) / 5) end
		c.needs[cfg.need] = math.min(100, c.needs[cfg.need] + rate)
		if a.act == "sleep" then c.needs.health = math.min(100, c.needs.health + 0.05 * dt) end
		if c.needs[cfg.need] >= 100 then
			if a.act == "eat" and math.random() < Config.FoodSpoilChance and H.onSick then H.onSick(p, "FoodPoison") end
			H.stopAction(p)
			return
		end
	end
	if cfg.skill and a.act ~= "sleep" then
		local mult = 1
		for _, t in ipairs(c.traits) do local tc = Core.traitCfg(t); if tc and tc.skill == cfg.skill then mult = 1.5 end end
		if c.mood == "Inspired" or c.mood == "Focused" then mult *= 1.3 elseif c.mood == "Sad" or c.mood == "Angry" then mult *= 0.6 end
		if H.onSkillXp then H.onSkillXp(p, cfg.skill, 4 * dt * mult) end
	end
	if a.act == "cook" or a.act == "eat" then if H.onSkillXp and cfg.key == "Stove" then H.onSkillXp(p, "cooking", 3 * dt) end end
	if os.clock() - a.t0 > 600 then H.stopAction(p) end
end
-- ไฟไหม้ครัว
function H.startFire(p, model)
	local c = Core.char(p); if not c or c.fire then return end
	c.fire = true; Core.notify(p, "fire", "red")
	local fire = Instance.new("Fire"); fire.Size = 8; fire.Heat = 12; fire.Parent = model.PrimaryPart
	local pp = prompt(model.PrimaryPart, Core.T(p, "extinguish"), "", function(who) if who == p or H.owner[who] == p then H.putOutFire(p, model) end end); pp.Name = "FirePrompt"; pp:SetAttribute("Action", "extinguish")
	local hasAlarm = false; for _, it in ipairs(c.furniture) do if it.key == "SmokeAlarm" then hasAlarm = true end end
	task.delay(hasAlarm and 45 or 25, function()
		if c.fire then
			c.fire = nil; fire:Destroy(); pp:Destroy()
			if H.onFireDamage then H.onFireDamage(p, hasAlarm) end
		end
	end)
end
function H.putOutFire(p, model)
	local c = Core.char(p); if not c or not c.fire then return end
	c.fire = nil
	for _, x in ipairs(model.PrimaryPart:GetChildren()) do if x:IsA("Fire") or x.Name == "FirePrompt" then x:Destroy() end end
	c.needs.health = math.max(0, c.needs.health - 5); Core.notify(p, "fireOut", "green")
	if H.onSkillXp then H.onSkillXp(p, "handiness", 20) end
end
function H.harvest(p, model)
	local c = Core.char(p); if not c then return end
	local planted = model:GetAttribute("Planted") or 0
	if os.clock() - planted < 60 then return end
	model:SetAttribute("Planted", os.clock())
	for _, x in ipairs(model.PrimaryPart:GetChildren()) do if x:IsA("ProximityPrompt") and x:GetAttribute("Action") == "harvest" then x.Enabled = false end end
	local lvl = c.skills.gardening or 0
	Core.addCash(p, 30 + lvl * 15); c.needs.hunger = math.min(100, c.needs.hunger + 20)
	if H.onSkillXp then H.onSkillXp(p, "gardening", 25) end
	Core.push(p)
end
-- ซื้อ/วาง/ขาย
function H.buy(p, key, x, z, rot)
	local c = Core.char(p); if not c then return false end
	local cfg = fcfg(key); if not cfg then return false end
	local lotCfg; for _, l in ipairs(Config.Lots) do if l.key == c.lot then lotCfg = l end end
	if #c.furniture >= (lotCfg and lotCfg.size or 12) then Core.notify(p, "tooManyItems", "red"); return false end
	local half = 14; if lotCfg and lotCfg.key == "Apartment" then half = 11 end
	x = math.clamp(math.floor(x / 2 + 0.5) * 2, -half + 2, half - 2); z = math.clamp(math.floor(z / 2 + 0.5) * 2, -half + 2, half - 2)
	if not Core.spend(p, cfg.price) then return false end
	table.insert(c.furniture, { key = key, x = x, z = z, rot = rot or 0 }); c.bought = (c.bought or 0) + 1
	H.rebuild(p); Core.notify(p, "bought", "green", Core.T(p, key)); Core.push(p)
	return true
end
function H.sell(p, id)
	local c = Core.char(p); if not c then return end
	local it = c.furniture[id]; if not it then return end
	local cfg = fcfg(it.key); table.remove(c.furniture, id)
	Core.addCash(p, math.floor(cfg.price * 0.5)); H.rebuild(p); Core.push(p)
end
function H.move(p, id, x, z, rot)
	local c = Core.char(p); if not c then return end
	local it = c.furniture[id]; if not it then return end
	it.x = math.floor(x / 2 + 0.5) * 2; it.z = math.floor(z / 2 + 0.5) * 2; it.rot = rot or it.rot
	H.rebuild(p)
end
-- จัดสรรที่ดิน: apartment ตอนเริ่ม, ซื้อบ้าน → ย้ายไป lot ว่าง
function H.assign(p)
	local c = Core.char(p); if not c then return end
	local want = (c.lot == "Apartment") and "apt" or "house"
	for k, lot in pairs(Map.lots) do
		local isApt = lot.apartment == true
		if lot.owner == nil and ((want == "apt") == isApt) then lot.owner = p; c.lotIndex = k; if #c.furniture == 0 then H.furnishStarter(p) end; H.rebuild(p); return lot end
	end
end
function H.release(p)
	for _, lot in pairs(Map.lots) do if lot.owner == p then lot.owner = nil; local f = lot.model:FindFirstChild("Furniture"); if f then f:Destroy() end; local ns = lot.model:FindFirstChild("NameSign"); if ns then ns.SurfaceGui.TextLabel.Text = lot.apartment and ("Apt " .. tostring(lot.index):sub(4)) or "For sale" end end end
	H.active[p] = nil
end
function H.buyLot(p, key)
	local c = Core.char(p); if not c then return false end
	local lc; for _, l in ipairs(Config.Lots) do if l.key == key then lc = l end end
	if not lc or lc.key == c.lot then return false end
	if lc.pass and not Core.ownsPass(p, lc.pass) then Remotes.PromptPass:FireClient(p, "pass", lc.pass); return false end
	if lc.price > 0 and not Core.spend(p, lc.price) then return false end
	c.lot = key; c.lotSize = lc.size
	local extras = {}
	for _, it in ipairs(c.furniture) do local inStarter = false; for _, st in ipairs(H.Starter.House) do if st[1] == it.key then inStarter = true end end; if not inStarter then extras[#extras + 1] = it end end
	c.furniture = {}
	H.release(p); H.assign(p)
	if #c.furniture == 0 then H.furnishStarter(p) end
	for _, it in ipairs(extras) do it.x = math.clamp(it.x, -12, 12); it.z = math.clamp(it.z, -12, 12); table.insert(c.furniture, it) end
	H.rebuild(p)
	Core.notify(p, "moveIn", "green"); Core.push(p)
	return true
end
function H.homePos(p) local lot = lotOf(p); return lot and lot.origin + Vector3.new(0, 3, lot.apartment and 18 or 22) end
-- บิลรายวัน
function H.dailyBills(p)
	local c = Core.char(p); if not c then return end
	local lc; for _, l in ipairs(Config.Lots) do if l.key == c.lot then lc = l end end
	local total = Config.Bills.power + Config.Bills.water + (lc and (lc.rent + (lc.tax or 0)) or 0)
	if Core.trait(c, "Frugal") then total = math.floor(total * (1 - Core.traitCfg("Frugal").billDiscount)) end
	local d = Data.get(p)
	if d.cash >= total then d.cash -= total; c.unpaid = 0; Core.notify(p, "bills", "white", total)
	else c.unpaid = (c.unpaid or 0) + 1; Core.notify(p, "billsUnpaid", "red") end
end
return H
