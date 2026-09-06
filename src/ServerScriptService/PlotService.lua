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
	local s = part({ Size = size, Position = pos, Color = bg or Color3.new(1, 0.95, 0.6), Material = Enum.Material.SmoothPlastic }, parent)
	local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.LightInfluence = 0; g.Brightness = 2; g.Parent = s
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
	local b = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.5, 0.5, 0.5), Position = pos, Color = color, Material = Enum.Material.Neon }, parent)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = 12; l.Brightness = 0.8; l.Parent = b
end

-- ผู้ช่วย: คนอื่นที่กดช่วยร้านนี้ (attribute Helping = UserId เจ้าของ)
function P.canAct(who, owner) return who == owner or who:GetAttribute("Helping") == owner.UserId end
P.onHelp = nil

function P.origin(i)
	local row, col = math.floor((i - 1) / 4), (i - 1) % 4
	return Vector3.new(-90 + col * 60, 0, 30 + row * 80)
end
function P.points(i)
	local o = P.origin(i)
	return {
		origin = o,
		spawn = o + Vector3.new(31, 3, 4), -- ทางเดินด้านข้างร้าน (ไม่ผ่านครัว)
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
		local seat = Instance.new("Seat"); seat.Name = "Chair"; seat.Size = Vector3.new(1.6, 0.3, 1.6); seat.Anchored = true; seat.Color = colors[k]; seat.Material = Enum.Material.SmoothPlastic
		seat.CFrame = CFrame.new(pos + off + Vector3.new(0, 1.5, 0), pos + Vector3.new(0, 1.5, 0)); seat.Parent = g
		for _, l in ipairs({ Vector3.new(0.6, 0, 0.6), Vector3.new(-0.6, 0, 0.6), Vector3.new(0.6, 0, -0.6), Vector3.new(-0.6, 0, -0.6) }) do
			part({ Size = Vector3.new(0.15, 1.4, 0.15), Position = pos + off + l + Vector3.new(0, 0.7, 0), Color = colors[k] }, g).Name = "ChairLeg"
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
	local cleanPrompt = prompt(g:FindFirstChildWhichIsA("Part"), "Clean", "Table " .. idx, "clean", function(who) if P.canAct(who, player) and t.dirty and P.onClean then P.onClean(who, t) end end)
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
			local tentColors = { Color3.fromRGB(230, 50, 50), Color3.fromRGB(40, 90, 200), Color3.fromRGB(250, 200, 40), Color3.fromRGB(50, 170, 90), Color3.fromRGB(240, 120, 40), Color3.fromRGB(150, 60, 180) }
			local tc = tentColors[(i - 1) % #tentColors + 1]
			local roof = part({ Size = Vector3.new(18, 0.3, 6), Position = o + Vector3.new(0, 6, -15), Color = tc, Material = Enum.Material.Fabric }, m); roof.Name = "Roof"
			for k = 0, 3 do
				local w = Instance.new("WedgePart"); w.Name = "Roof"; w.Anchored = true; w.Size = Vector3.new(k % 2 == 0 and 18 or 6, 2.2, (k % 2 == 0 and 6 or 18) / 2); w.Color = tc; w.Material = Enum.Material.Fabric
				w.CFrame = CFrame.new(o + Vector3.new(0, 7.2, -15)) * CFrame.Angles(0, math.rad(90 * k), 0) * CFrame.new(0, 0, (k % 2 == 0 and 6 or 18) / 4)
				w.Parent = m
			end
			for _, dx in ipairs({ -8, 8 }) do part({ Size = Vector3.new(0.3, 6, 0.3), Position = o + Vector3.new(dx, 3, -12.5), Color = Color3.fromRGB(60, 60, 60) }, m) end
			local ns = sign(m, "🍜 " .. player.DisplayName, Vector3.new(16, 1.4, 0.2), o + Vector3.new(0, 7, -12.4), Color3.fromRGB(60, 20, 10), Color3.fromRGB(255, 200, 60)); ns.Name = "NameSign"
			local hp = prompt(ns, "Help", player.DisplayName, "help", function(who) if who ~= player and P.onHelp then P.onHelp(who, player) end end)
			hp.MaxActivationDistance = 14
			for k = -6, 6, 4 do light(m, o + Vector3.new(k, 5.6, -11.8), Color3.fromRGB(255, 210, 120)) end
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
			prompt(pack, "Pack", "🥡", "pack", function(who) if P.canAct(who, player) and P.onPack then P.onPack(who) end end)
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
			local wp = prompt(sink, "Wash", "🧼", "wash", function(who) if P.canAct(who, player) and P.onWash then P.onWash(who) end end)
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
			prompt(kb, "Cook", "🍳", "kitchen", function(who) if P.canAct(who, player) and P.onKitchen then P.onKitchen(who, player) end end)
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
	prompt(d.PrimaryPart, "Pick up", Locale.food("en", foodId), "pickup", function(who) if P.canAct(who, player) and P.onPickup then P.onPickup(who, d) end end)
	return true
end
function P.takeFromCounter(player, foodId)
	local m = root:FindFirstChild("Plot_" .. player.UserId); local ready = m and m:FindFirstChild("Ready")
	if not ready then return end
	for _, c in ipairs(ready:GetChildren()) do
		if not foodId or c:GetAttribute("FoodId") == foodId then c:Destroy(); return c end
	end
end

-- ใช้ของตกแต่งกับแปลง
function P.applyDecor(player, decor)
	local m = root:FindFirstChild("Plot_" .. player.UserId); if not m then return end
	local o = P.origin(player:GetAttribute("PlotIndex"))
	local function item(key) for _, d in ipairs(Config.Decor) do if d.key == key then return d end end end
	-- เต็นท์
	local tent = item(decor.tent)
	if tent and tent.color then
		local c = Color3.new(tent.color[1], tent.color[2], tent.color[3])
		for _, x in ipairs(m:GetChildren()) do if x.Name == "Roof" then x.Color = c; x.Material = tent.premium and Enum.Material.Metal or Enum.Material.Fabric end end
	end
	-- เก้าอี้
	local chairMat, chairColors = Enum.Material.SmoothPlastic, nil
	if decor.chairs == "ChairWood" then chairMat = Enum.Material.Wood; chairColors = { Color3.fromRGB(150, 100, 60) }
	elseif decor.chairs == "ChairNeon" then chairMat = Enum.Material.Neon; chairColors = { Color3.fromRGB(80, 220, 255), Color3.fromRGB(255, 90, 200) } end
	for _, tb in ipairs(P.tables[player] or {}) do
		for i, x in ipairs(tb.model:GetDescendants()) do
			if x.Name == "Chair" or x.Name == "ChairLeg" then
				x.Material = chairMat
				if chairColors then x.Color = chairColors[i % #chairColors + 1] elseif x.Name == "Chair" then x.Color = (i % 2 == 0) and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(40, 80, 200) end
			end
		end
	end
	-- ป้าย
	local ns = m:FindFirstChild("NameSign")
	if ns then
		local tl = ns.SurfaceGui.TextLabel
		if decor.sign == "SignNeon" then ns.Color = Color3.fromRGB(20, 20, 30); ns.Material = Enum.Material.SmoothPlastic; tl.TextColor3 = Color3.fromRGB(255, 80, 200)
		elseif decor.sign == "SignGold" then ns.Color = Color3.fromRGB(255, 215, 80); ns.Material = Enum.Material.Metal; tl.TextColor3 = Color3.fromRGB(120, 40, 20)
		else ns.Color = Color3.fromRGB(255, 200, 60); ns.Material = Enum.Material.SmoothPlastic; tl.TextColor3 = Color3.fromRGB(60, 20, 10) end
	end
	-- ของประดับ
	local df = m:FindFirstChild("DecorProps") or Instance.new("Folder"); df.Name = "DecorProps"; df:ClearAllChildren(); df.Parent = m
	if decor.owned.Lanterns then
		for k = 0, 7 do
			local c = ({ Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 200, 60), Color3.fromRGB(80, 200, 120), Color3.fromRGB(120, 150, 255) })[k % 4 + 1]
			local lp = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, 1, 1), Color = c, Material = Enum.Material.Neon }, df)
			lp.CFrame = CFrame.new(o + Vector3.new(-14 + k * 4, 9.5, -12)) * CFrame.Angles(0, 0, math.rad(90))
			local l = Instance.new("PointLight"); l.Color = c; l.Range = 8; l.Parent = lp
		end
	end
	if decor.owned.Plants then
		for _, c in ipairs({ Vector3.new(-9, 0, -16.5), Vector3.new(9, 0, -16.5), Vector3.new(-23, 0, 2), Vector3.new(23, 0, 2) }) do
			part({ Size = Vector3.new(1.4, 1.2, 1.4), Position = o + c + Vector3.new(0, 0.6, 0), Color = Color3.fromRGB(180, 90, 60), Material = Enum.Material.Slate }, df)
			part({ Shape = Enum.PartType.Ball, Size = Vector3.new(2.2, 2.2, 2.2), Position = o + c + Vector3.new(0, 2.1, 0), Color = Color3.fromRGB(50, 150, 70), Material = Enum.Material.Grass }, df)
		end
	end
	if decor.owned.Fan then
		part({ Size = Vector3.new(0.3, 5, 0.3), Position = o + Vector3.new(-12, 2.5, -10), Color = Color3.fromRGB(200, 200, 200), Material = Enum.Material.Metal }, df)
		local fan = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 3, 3), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Metal }, df)
		fan.CFrame = CFrame.new(o + Vector3.new(-12, 5, -9.7)) * CFrame.Angles(0, math.rad(90), 0)
	end
	if decor.owned.TV then
		-- ทีวีบนเสาข้างโซนโต๊ะ หันหน้าเข้าหาลูกค้า
		part({ Size = Vector3.new(0.4, 8, 0.4), Position = o + Vector3.new(-23, 4, 5), Color = Color3.fromRGB(60, 60, 60), Material = Enum.Material.Metal }, df)
		local tv = part({ Size = Vector3.new(6, 3.4, 0.3), CFrame = CFrame.new(o + Vector3.new(-22.6, 7.5, 5)) * CFrame.Angles(0, math.rad(-90), 0), Color = Color3.fromRGB(20, 20, 20), Material = Enum.Material.SmoothPlastic }, df)
		local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.LightInfluence = 0; g.Brightness = 2; g.Parent = tv
		local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundColor3 = Color3.fromRGB(30, 60, 120); t.Text = "📺 มวยไทย LIVE"; t.TextScaled = true; t.Font = Enum.Font.FredokaOne; t.TextColor3 = Color3.new(1, 1, 1); t.Parent = g
	end
	if decor.owned.Flag then
		part({ Size = Vector3.new(0.2, 9, 0.2), Position = o + Vector3.new(-13, 4.5, -12.5), Color = Color3.fromRGB(220, 220, 220), Material = Enum.Material.Metal }, df)
		for k, c in ipairs({ Color3.fromRGB(200, 30, 40), Color3.fromRGB(245, 245, 245), Color3.fromRGB(30, 50, 130), Color3.fromRGB(245, 245, 245), Color3.fromRGB(200, 30, 40) }) do
			part({ Size = Vector3.new(0.05, k == 3 and 0.8 or 0.4, 3), Position = o + Vector3.new(-12.9, 8.9 - ({ 0.2, 0.6, 1.2, 1.8, 2.2 })[k], -11), Color = c, Material = Enum.Material.Fabric }, df)
		end
	end
	if decor.owned.LuckyCat then
		local cat = part({ Size = Vector3.new(1.6, 2, 1.4), Position = o + Vector3.new(7.5, 4.3, -14), Color = Color3.fromRGB(255, 215, 80), Material = Enum.Material.Metal }, df)
		part({ Shape = Enum.PartType.Ball, Size = Vector3.new(1.5, 1.5, 1.5), Position = o + Vector3.new(7.5, 5.8, -14), Color = Color3.fromRGB(255, 215, 80), Material = Enum.Material.Metal }, df)
		part({ Size = Vector3.new(0.4, 1.2, 0.4), CFrame = CFrame.new(o + Vector3.new(8.3, 6, -14)) * CFrame.Angles(0, 0, math.rad(-20)), Color = Color3.fromRGB(255, 215, 80), Material = Enum.Material.Metal }, df)
		local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 220, 120); l.Range = 8; l.Parent = cat
	end
end

-- ตกแต่งเทศกาลรอบร้าน: โคมสีเทศกาล + ป้าย + ของประจำเทศกาล
function P.festivalDecor(player, fest)
	local m = root:FindFirstChild("Plot_" .. player.UserId); if not m then return end
	local o = P.origin(player:GetAttribute("PlotIndex"))
	local f = m:FindFirstChild("FestivalDecor") or Instance.new("Folder"); f.Name = "FestivalDecor"; f:ClearAllChildren(); f.Parent = m
	local c = Color3.new(fest.color[1], fest.color[2], fest.color[3])
	for k = 0, 9 do
		local lp = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.4, 1.1, 1.1), Color = c, Material = Enum.Material.Neon }, f)
		lp.CFrame = CFrame.new(o + Vector3.new(-22.5 + k * 5, 11, 18)) * CFrame.Angles(0, 0, math.rad(90))
		local l = Instance.new("PointLight"); l.Color = c; l.Range = 10; l.Parent = lp
	end
	sign(f, Locale.get("th", fest.key) .. " " .. Locale.get("en", fest.key), Vector3.new(14, 1.4, 0.2), o + Vector3.new(0, 9.6, -12.4), Color3.new(1, 1, 1), c)
	if fest.key == "Songkran" then
		for _, x in ipairs({ -20, 20 }) do part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.5, 2.2, 2.2), CFrame = CFrame.new(o + Vector3.new(x, 1.25, 22)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(80, 160, 230), Material = Enum.Material.Plastic }, f) end
	elseif fest.key == "LoyKrathong" then
		-- บ่อน้ำหน้าร้าน กระทงลอยวน โคมลอยขึ้นฟ้า
		local pond = part({ Size = Vector3.new(34, 0.6, 9), Position = o + Vector3.new(0, 0.5, 21), Color = Color3.fromRGB(40, 90, 140), Material = Enum.Material.Glass, Transparency = 0.25 }, f)
		part({ Size = Vector3.new(36, 1, 11), Position = o + Vector3.new(0, 0.3, 21), Color = Color3.fromRGB(120, 110, 100), Material = Enum.Material.Cobblestone }, f)
		pond.Parent = f
		for k = 0, 7 do
			local kr = Instance.new("Model"); kr.Parent = f
			local base = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 2.2, 2.2), Color = Color3.fromRGB(70, 150, 70), Material = Enum.Material.Grass }, kr)
			base.CFrame = CFrame.new(o + Vector3.new(-14 + k * 4, 1.1, 21)) * CFrame.Angles(0, 0, math.rad(90)); kr.PrimaryPart = base
			for _, ang in ipairs({ 0, 90, 180, 270 }) do
				local petal = part({ Size = Vector3.new(0.9, 0.5, 0.5), Color = ({ Color3.fromRGB(255, 120, 160), Color3.fromRGB(255, 200, 60) })[k % 2 + 1], Material = Enum.Material.SmoothPlastic }, kr)
				petal.CFrame = base.CFrame * CFrame.Angles(0, 0, math.rad(-90)) * CFrame.Angles(0, math.rad(ang), 0) * CFrame.new(0.9, 0.5, 0)
			end
			local fl = part({ Size = Vector3.new(0.25, 0.8, 0.25), Position = base.Position + Vector3.new(0, 0.9, 0), Color = Color3.fromRGB(255, 210, 90), Material = Enum.Material.Neon }, kr)
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 190, 90); l.Range = 7; l.Parent = fl
			for _, x in ipairs(kr:GetChildren()) do if x ~= base then local w = Instance.new("WeldConstraint"); w.Part0 = base; w.Part1 = x; w.Parent = x; x.Anchored = false end end
			task.spawn(function()
				local t0 = os.clock() + k
				while kr.Parent do base.CFrame = CFrame.new(o + Vector3.new(-14 + k * 4 + math.sin(os.clock() - t0) * 1.2, 1.1 + math.sin((os.clock() - t0) * 2) * 0.08, 21 + math.cos(os.clock() - t0) * 1.2)) * CFrame.Angles(0, (os.clock() - t0) * 0.3, math.rad(90)); task.wait(0.05) end
			end)
		end
		for k = 0, 5 do
			local lan = part({ Size = Vector3.new(1.6, 2.2, 1.6), Position = o + Vector3.new(-18 + k * 7, 12, 10), Color = Color3.fromRGB(255, 220, 150), Material = Enum.Material.Neon, Transparency = 0.2 }, f)
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 200, 120); l.Range = 14; l.Parent = lan
			task.spawn(function()
				local y0 = 12 + k * 6
				while lan.Parent do lan.Position = Vector3.new(lan.Position.X, y0 + (os.clock() * 1.5 + k * 9) % 60, lan.Position.Z); task.wait(0.1) end
			end)
		end
	elseif fest.key == "ChineseNY" then
		for _, x in ipairs({ -8, 8 }) do sign(f, "福", Vector3.new(2, 2, 0.15), o + Vector3.new(x, 4.6, -12.3), Color3.fromRGB(255, 220, 80), Color3.fromRGB(200, 30, 30)) end
	elseif fest.key == "NewYear" then
		for k = 0, 4 do local s2 = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.8, 0.8, 0.8), Position = o + Vector3.new(-16 + k * 8, 14 + (k % 2) * 2, 20), Color = ({ Color3.fromRGB(255, 80, 80), Color3.fromRGB(80, 200, 255), Color3.fromRGB(255, 230, 80) })[k % 3 + 1], Material = Enum.Material.Neon }, f); local l = Instance.new("PointLight"); l.Range = 12; l.Color = s2.Color; l.Parent = s2 end
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

function P.refresh(player, foods, gold)
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
		local g = stalls:FindFirstChild(f.id)
		if g and gold and gold[f.id] and not g:GetAttribute("Gold") then
			g:SetAttribute("Gold", true)
			for _, x in ipairs(g:GetDescendants()) do if x:IsA("BasePart") then x.Color = Color3.fromRGB(255, 215, 80); x.Material = Enum.Material.Metal end end
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 220, 120); l.Range = 6; l.Parent = g:FindFirstChildWhichIsA("BasePart", true)
		end
	end
end
return P
