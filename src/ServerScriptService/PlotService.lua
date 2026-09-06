-- แปลงร้านสไตล์ตลาดโต้รุ่ง: เคาน์เตอร์ โต๊ะครัว โต๊ะนั่งกับเก้าอี้พลาสติก ร่ม จุดใส่ถุง
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Locale = require(RS.Locale)
local Dish = require(RS.Dish)
local P = { owners = {}, tables = {}, onCook = nil, onPack = nil, onClean = nil, onWash = nil, onPickup = nil, onFix = nil, onKitchen = nil }
local root = Instance.new("Folder"); root.Name = "Plots"; root.Parent = workspace

local function part(props, parent)
	local x = Instance.new("Part")
	x.Anchored = true; x.TopSurface = Enum.SurfaceType.Smooth; x.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do x[k] = v end
	x.Parent = parent
	return x
end
local function sign(parent, text, size, pos, color, bg)
	local s = part({ Size = size, Position = pos, Color = bg or Color3.new(1, 0.95, 0.6), Material = Enum.Material.Neon }, parent)
	local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.Parent = s
	local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundTransparency = 1
	t.Text = text; t.TextScaled = true; t.Font = Enum.Font.FredokaOne; t.TextColor3 = color or Color3.new(0.15, 0.1, 0.05); t.Parent = g
	return s
end
local function prompt(parent, action, obj, key, cb)
	local pp = Instance.new("ProximityPrompt"); pp.ActionText = action; pp.ObjectText = obj or ""
	pp.KeyboardKeyCode = Enum.KeyCode.E; pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false
	if key then pp:SetAttribute("Kind", key) end
	pp.Parent = parent; pp.Triggered:Connect(cb)
	return pp
end
local function light(parent, pos, color)
	local b = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.6, 0.6, 0.6), Position = pos, Color = color, Material = Enum.Material.Neon }, parent)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = 14; l.Brightness = 1.2; l.Parent = b
end

function P.origin(i)
	local row, col = math.floor((i - 1) / 4), (i - 1) % 4
	return Vector3.new(-90 + col * 60, 0, 30 + row * 80)
end
function P.points(i)
	local o = P.origin(i)
	return {
		origin = o,
		spawn = Vector3.new(o.X, 3, 2),
		queue = function(n) return o + Vector3.new(4, 3, -10 + (n - 1) * 3) end,
		counterSlot = function(n) return o + Vector3.new(-5 + (n - 1) * 3.5, 3.6, -14) end,
		staff = { Cook = o + Vector3.new(0, 3, -24), Waiter = o + Vector3.new(-3, 3, -16.5), Washer = o + Vector3.new(-11, 3, -20.5) },
	}
end

-- โต๊ะนั่ง: โต๊ะสแตนเลส + เก้าอี้พลาสติก 4 ตัว (Seat) + ร่ม
local function makeTable(m, pos, idx, player)
	local g = Instance.new("Model"); g.Name = "Table" .. idx; g.Parent = m
	part({ Size = Vector3.new(4, 0.2, 4), Position = pos + Vector3.new(0, 2.5, 0), Color = Color3.fromRGB(200, 205, 210), Material = Enum.Material.Metal }, g)
	part({ Size = Vector3.new(0.3, 2.4, 0.3), Position = pos + Vector3.new(0, 1.2, 0), Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Metal }, g)
	-- ร่ม
	part({ Size = Vector3.new(0.25, 8, 0.25), Position = pos + Vector3.new(0, 6, 0), Color = Color3.fromRGB(230, 230, 230) }, g)
	local top = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5, 6.5, 6.5), Color = idx % 2 == 0 and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(50, 90, 200), Material = Enum.Material.Fabric }, g)
	top.CFrame = CFrame.new(pos + Vector3.new(0, 8.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	light(g, pos + Vector3.new(0, 7.4, 0), Color3.fromRGB(255, 220, 150))
	local seats = {}
	local colors = { Color3.fromRGB(220, 50, 50), Color3.fromRGB(40, 80, 200), Color3.fromRGB(220, 50, 50), Color3.fromRGB(40, 80, 200) }
	for k, off in ipairs({ Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0), Vector3.new(0, 0, 3), Vector3.new(0, 0, -3) }) do
		local seat = Instance.new("Seat"); seat.Size = Vector3.new(1.6, 0.3, 1.6); seat.Anchored = true; seat.Color = colors[k]; seat.Material = Enum.Material.SmoothPlastic
		seat.CFrame = CFrame.new(pos + off + Vector3.new(0, 1.5, 0), pos + Vector3.new(0, 1.5, 0)); seat.Parent = g
		for _, l in ipairs({ Vector3.new(0.6, 0, 0.6), Vector3.new(-0.6, 0, 0.6), Vector3.new(0.6, 0, -0.6), Vector3.new(-0.6, 0, -0.6) }) do
			part({ Size = Vector3.new(0.15, 1.4, 0.15), Position = pos + off + l + Vector3.new(0, 0.7, 0), Color = colors[k] }, g)
		end
		seats[k] = seat
	end
	local t = { model = g, seats = seats, pos = pos, dirty = false, group = nil, idx = idx }
	-- จานสกปรก + ปุ่มเก็บโต๊ะ
	local plates = Instance.new("Model"); plates.Name = "Dirty"; plates.Parent = g
	for k = 1, 3 do
		local d = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, 1.4, 1.4), Color = Color3.fromRGB(235, 225, 210), Transparency = 1 }, plates)
		d.CFrame = CFrame.new(pos + Vector3.new(-1 + k * 0.7, 2.66 + k * 0.05, (k % 2) * 0.8 - 0.4)) * CFrame.Angles(0, 0, math.rad(90))
	end
	local cleanPrompt = prompt(g:FindFirstChildWhichIsA("Part"), "Clean", "Table " .. idx, "clean", function(who) if who == player and t.dirty and P.onClean then P.onClean(player, t) end end)
	cleanPrompt.Enabled = false
	function t.setDirty(dirty)
		t.dirty = dirty; cleanPrompt.Enabled = dirty
		for _, d in ipairs(plates:GetChildren()) do d.Transparency = dirty and 0 or 1 end
	end
	return t
end

function P.assign(player)
	for i = 1, Config.MaxPlots do
		if not P.owners[i] then
			P.owners[i] = player
			local o = P.origin(i)
			local m = Instance.new("Model"); m.Name = "Plot_" .. player.UserId; m.Parent = root
			part({ Size = Vector3.new(50, 0.4, 56), Position = o + Vector3.new(0, 0.2, -3), Color = Color3.fromRGB(150, 140, 130), Material = Enum.Material.Concrete }, m)
			-- เคาน์เตอร์ + หลังคาผ้าใบ + ไฟราว
			part({ Size = Vector3.new(16, 3, 2), Position = o + Vector3.new(0, 1.9, -14), Color = Color3.fromRGB(200, 110, 50), Material = Enum.Material.Wood }, m)
			part({ Size = Vector3.new(18, 0.3, 6), Position = o + Vector3.new(0, 6, -15), Color = Color3.fromRGB(210, 50, 50), Material = Enum.Material.Fabric }, m)
			for _, dx in ipairs({ -8, 8 }) do part({ Size = Vector3.new(0.3, 6, 0.3), Position = o + Vector3.new(dx, 3, -12.5), Color = Color3.fromRGB(60, 60, 60) }, m) end
			sign(m, "🍜 " .. player.DisplayName, Vector3.new(16, 1.4, 0.2), o + Vector3.new(0, 7, -12.4), Color3.fromRGB(60, 20, 10), Color3.fromRGB(255, 200, 60))
			for k = -7, 7, 2 do light(m, o + Vector3.new(k, 5.6, -11.8), Color3.fromRGB(255, 210, 120)) end
			-- ตกแต่ง: กระถางต้นไม้และโคมไฟกระดาษ
			for _, c in ipairs({ Vector3.new(-23, 0, 22), Vector3.new(23, 0, 22), Vector3.new(-23, 0, -29), Vector3.new(23, 0, -29) }) do
				part({ Size = Vector3.new(2, 1.6, 2), Position = o + c + Vector3.new(0, 0.8, 0), Color = Color3.fromRGB(150, 80, 50), Material = Enum.Material.Slate }, m)
				part({ Shape = Enum.PartType.Ball, Size = Vector3.new(3, 3, 3), Position = o + c + Vector3.new(0, 2.8, 0), Color = Color3.fromRGB(60, 140, 60), Material = Enum.Material.Grass }, m)
			end
			local lanternColors = { Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 200, 60), Color3.fromRGB(80, 200, 120), Color3.fromRGB(120, 150, 255) }
			part({ Size = Vector3.new(50, 0.06, 0.06), Position = o + Vector3.new(0, 10, 5), Color = Color3.fromRGB(30, 30, 30) }, m)
			for k = 0, 9 do
				local lp = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.4, 1.1, 1.1), Color = lanternColors[k % 4 + 1], Material = Enum.Material.Neon }, m)
				lp.CFrame = CFrame.new(o + Vector3.new(-22.5 + k * 5, 9.2, 5)) * CFrame.Angles(0, 0, math.rad(90))
				local l = Instance.new("PointLight"); l.Color = lanternColors[k % 4 + 1]; l.Range = 10; l.Brightness = 0.8; l.Parent = lp
			end
			-- จุดใส่ถุง (ซื้อกลับ)
			local pack = part({ Size = Vector3.new(3, 2.8, 2), Position = o + Vector3.new(11, 1.8, -14), Color = Color3.fromRGB(240, 235, 220), Material = Enum.Material.Plastic }, m)
			sign(m, "🥡", Vector3.new(2.5, 1, 0.1), o + Vector3.new(11, 4, -13), nil, Color3.fromRGB(255, 240, 200))
			prompt(pack, "Pack", "🥡", "pack", function(who) if who == player and P.onPack then P.onPack(player) end end)
			-- ร่มใหญ่หน้าเคาน์เตอร์ (กางตอนฝนตก) และถังแก๊ส (เปลี่ยนตอนแก๊สหมด)
			local umb = part({ Size = Vector3.new(1, 3, 1), Position = o + Vector3.new(9, 1.5, -11), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Fabric }, m)
			prompt(umb, "Umbrella", "☂️", "umbrella", function(who) if who == player and P.onFix and who:GetAttribute("Event") == "Rain" then P.onFix(who) end end).HoldDuration = 1
			local gas = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(3, 1.6, 1.6), Color = Color3.fromRGB(80, 160, 90), Material = Enum.Material.Metal }, m)
			gas.CFrame = CFrame.new(o + Vector3.new(-18, 1.5, -24)) * CFrame.Angles(0, 0, math.rad(90))
			prompt(gas, "Gas", "⛽", "gas", function(who) if who == player and P.onFix and who:GetAttribute("Event") == "GasOut" then P.onFix(who) end end).HoldDuration = 2
			-- อ่างล้างจาน
			local sink = part({ Size = Vector3.new(4, 2.6, 2.5), Position = o + Vector3.new(-11, 1.6, -18), Color = Color3.fromRGB(190, 195, 200), Material = Enum.Material.Metal }, m)
			part({ Size = Vector3.new(3, 0.3, 1.8), Position = o + Vector3.new(-11, 2.9, -18), Color = Color3.fromRGB(120, 180, 230), Material = Enum.Material.Glass }, m)
			sign(m, "🧼 " .. Locale.get("th", "wash"), Vector3.new(4, 0.9, 0.1), o + Vector3.new(-11, 4, -16.7), nil, Color3.fromRGB(200, 230, 255))
			local wp = prompt(sink, "Wash", "🧼", "wash", function(who) if who == player and P.onWash then P.onWash(player) end end)
			wp.HoldDuration = 1.5
			-- โต๊ะนั่ง
			P.tables[player] = {}
			local spots = { Vector3.new(-16, 0, -2), Vector3.new(16, 0, -2), Vector3.new(-16, 0, 12), Vector3.new(16, 0, 12) }
			for k = 1, Config.TablesPerPlot do P.tables[player][k] = makeTable(m, o + spots[k], k, player) end
			-- ครัวเดียว: เคาน์เตอร์ครัว เตา กระทะ หม้อ + ชั้นโชว์เมนู
			local k = Instance.new("Model"); k.Name = "Kitchen"; k.Parent = m
			local kb = part({ Size = Vector3.new(16, 2.6, 4), Position = o + Vector3.new(0, 1.7, -22), Color = Color3.fromRGB(190, 195, 200), Material = Enum.Material.Metal }, k)
			part({ Size = Vector3.new(16.4, 0.2, 4.4), Position = o + Vector3.new(0, 3.1, -22), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal }, k)
			for _, dx in ipairs({ -5, 0, 5 }) do
				part({ Size = Vector3.new(2.6, 0.3, 2.6), Position = o + Vector3.new(dx, 3.35, -22), Color = Color3.fromRGB(30, 30, 30), Material = Enum.Material.Metal }, k)
				local fire = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 1.8, 1.8), Color = Color3.fromRGB(80, 160, 255), Material = Enum.Material.Neon }, k)
				fire.CFrame = CFrame.new(o + Vector3.new(dx, 3.55, -22)) * CFrame.Angles(0, 0, math.rad(90))
			end
			local wok = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, 1.2, 2.4), Position = o + Vector3.new(-5, 3.9, -22), Color = Color3.fromRGB(40, 40, 40), Material = Enum.Material.Metal }, k)
			wok.Name = "Wok"
			part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.6, 2.2, 2.2), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal }, k).CFrame = CFrame.new(o + Vector3.new(0, 4.3, -22)) * CFrame.Angles(0, 0, math.rad(90))
			part({ Size = Vector3.new(2.4, 0.4, 2.4), Position = o + Vector3.new(5, 3.7, -22), Color = Color3.fromRGB(50, 50, 50), Material = Enum.Material.Metal }, k)
			part({ Size = Vector3.new(17, 0.25, 6), Position = o + Vector3.new(0, 6.2, -22), Color = Color3.fromRGB(240, 240, 230), Material = Enum.Material.Fabric }, k)
			sign(k, "🍳 " .. Locale.get("th", "kitchen") .. " / " .. Locale.get("en", "kitchen"), Vector3.new(8, 1.2, 0.15), o + Vector3.new(0, 5.2, -19.8), Color3.fromRGB(255, 245, 220), Color3.fromRGB(140, 30, 30))
			light(k, o + Vector3.new(-6, 5.8, -19.8), Color3.fromRGB(255, 120, 80)); light(k, o + Vector3.new(6, 5.8, -19.8), Color3.fromRGB(255, 120, 80))
			prompt(kb, "Cook", "🍳", "kitchen", function(who) if who == player and P.onKitchen then P.onKitchen(player) end end)
			-- ชั้นโชว์เมนูหลังครัว
			part({ Size = Vector3.new(20, 0.3, 2), Position = o + Vector3.new(0, 4.5, -27), Color = Color3.fromRGB(150, 100, 60), Material = Enum.Material.Wood }, m)
			part({ Size = Vector3.new(20, 0.3, 2), Position = o + Vector3.new(0, 2.2, -27), Color = Color3.fromRGB(150, 100, 60), Material = Enum.Material.Wood }, m)
			local stalls = Instance.new("Folder"); stalls.Name = "Stalls"; stalls.Parent = m
			player:SetAttribute("PlotIndex", i)
			return m
		end
	end
end

-- ป้ายเมนูหน้าร้าน แสดงเมนูที่ขาย
function P.menuBoard(player, foods)
	local m = root:FindFirstChild("Plot_" .. player.UserId); if not m then return end
	local o = P.origin(player:GetAttribute("PlotIndex"))
	local board = m:FindFirstChild("MenuBoard")
	if not board then
		board = sign(m, "", Vector3.new(6, 7, 0.3), o + Vector3.new(-13, 4, -13), Color3.fromRGB(255, 240, 200), Color3.fromRGB(40, 30, 30))
		board.Name = "MenuBoard"
		local t = board.SurfaceGui.TextLabel; t.TextScaled = false; t.TextSize = 34; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top
		t.TextColor3 = Color3.fromRGB(255, 240, 200); board.SurfaceGui.PixelsPerStud = 60; board.Material = Enum.Material.SmoothPlastic; board.Color = Color3.fromRGB(45, 35, 30)
		local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 20); pad.PaddingTop = UDim.new(0, 20); pad.Parent = t
	end
	local lines = { "📋 MENU" }
	for _, f in ipairs(Config.Foods) do if foods[f.id] then lines[#lines + 1] = f.emoji .. " " .. Locale.food("th", f.id) .. "  ฿" .. f.price end end
	board.SurfaceGui.TextLabel.Text = table.concat(lines, "\n")
end

-- จานที่พ่อครัวทำเสร็จ วางบนเคาน์เตอร์ (สูงสุด 3 ช่อง)
function P.putOnCounter(player, foodId)
	local m = root:FindFirstChild("Plot_" .. player.UserId); if not m then return false end
	local ready = m:FindFirstChild("Ready") or Instance.new("Folder"); ready.Name = "Ready"; ready.Parent = m
	if #ready:GetChildren() >= 3 then return false end
	local pts = P.points(player:GetAttribute("PlotIndex"))
	local used = {}
	for _, c in ipairs(ready:GetChildren()) do used[c:GetAttribute("Slot")] = true end
	local slot = 1; while used[slot] do slot += 1 end
	local d = Dish.build(foodId); d:SetAttribute("Slot", slot); d.Parent = ready
	d:PivotTo(CFrame.new(pts.counterSlot(slot)))
	for _, x in ipairs(d:GetDescendants()) do if x:IsA("BasePart") then x.Anchored = true end end
	prompt(d.PrimaryPart, "Pick up", Locale.food("en", foodId), "pickup", function(who) if who == player and P.onPickup then P.onPickup(player, d) end end)
	return true
end
function P.takeFromCounter(player, foodId)
	local m = root:FindFirstChild("Plot_" .. player.UserId); local ready = m and m:FindFirstChild("Ready")
	if not ready then return end
	for _, c in ipairs(ready:GetChildren()) do
		if not foodId or c:GetAttribute("FoodId") == foodId then c:Destroy(); return c end
	end
end

function P.freeTable(player)
	for _, t in ipairs(P.tables[player] or {}) do if not t.group and not t.dirty and not t.closed then return t end end
end
-- เปิดโต๊ะตามเลเวลร้าน โต๊ะที่ยังไม่เปิดจะซ่อน
function P.setLevel(player, level)
	local lv = Config.Levels[level] or Config.Levels[1]
	for i, t in ipairs(P.tables[player] or {}) do
		local open = i <= lv.tables
		t.closed = not open
		for _, x in ipairs(t.model:GetDescendants()) do
			if x:IsA("BasePart") and x.Parent.Name ~= "Dirty" then x.Transparency = open and 0 or 1 end
			if x:IsA("Seat") then x.Disabled = not open end
			if x:IsA("PointLight") then x.Enabled = open end
		end
	end
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	local sg = m and m:FindFirstChild("LevelSign")
	if m and not sg then
		local o = P.origin(player:GetAttribute("PlotIndex"))
		sg = sign(m, "", Vector3.new(6, 1, 0.2), o + Vector3.new(0, 8.4, -12.4), Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 40, 60)); sg.Name = "LevelSign"
	end
	if sg then sg.SurfaceGui.TextLabel.Text = string.rep("⭐", level) .. " " .. Locale.get("en", lv.key) end
end

function P.release(player)
	for i, o in pairs(P.owners) do if o == player then P.owners[i] = nil end end
	P.tables[player] = nil
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	if m then m:Destroy() end
end

function P.refresh(player, foods)
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	if not m then return end
	local o = P.origin(player:GetAttribute("PlotIndex"))
	local stalls = m.Stalls
	for idx, f in ipairs(Config.Foods) do
		if foods[f.id] and not stalls:FindFirstChild(f.id) then
			local g = Instance.new("Model"); g.Name = f.id; g.Parent = stalls
			local k = idx - 1
			local pos = o + Vector3.new(-8.5 + (k % 8) * 2.4, (k < 8) and 4.75 or 2.45, -27)
			local d = Dish.build(f.id); d:ScaleTo(0.7); d.Parent = g
			d:PivotTo(CFrame.new(pos))
			for _, x in ipairs(d:GetDescendants()) do if x:IsA("BasePart") then x.Anchored = true end end
		end
	end
end
return P
