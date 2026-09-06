-- แปลงร้าน: รถเข็น, โต๊ะครัวของแต่ละเมนูพร้อมโมเดลอาหารและปุ่มทำอาหาร, จุดคิวลูกค้า
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Locale = require(RS.Locale)
local Dish = require(RS.Dish)
local P = { owners = {}, onCook = nil }
local root = Instance.new("Folder"); root.Name = "Plots"; root.Parent = workspace

local function part(props, parent)
	local x = Instance.new("Part")
	x.Anchored = true; x.TopSurface = Enum.SurfaceType.Smooth; x.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do x[k] = v end
	x.Parent = parent
	return x
end
local function sign(parent, text, size, pos, color)
	local s = part({ Size = size, Position = pos, Color = Color3.new(1, 0.95, 0.6), Material = Enum.Material.SmoothPlastic }, parent)
	local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Front; g.Parent = s
	local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundTransparency = 1
	t.Text = text; t.TextScaled = true; t.Font = Enum.Font.FredokaOne; t.TextColor3 = color or Color3.new(0.15, 0.1, 0.05); t.Parent = g
	return s
end

function P.origin(i)
	local row, col = math.floor((i - 1) / 4), (i - 1) % 4
	return Vector3.new(-90 + col * 60, 0, 30 + row * 80)
end
-- ตำแหน่งสำคัญของแปลง
function P.points(i)
	local o = P.origin(i)
	return {
		origin = o,
		spawn = Vector3.new(o.X, 3, 2),             -- ริมถนน
		counter = o + Vector3.new(0, 3, -12),      -- หน้าเคาน์เตอร์
		queue = function(n) return o + Vector3.new(-6 + (n - 1) * 4, 3, -8) end,
	}
end

function P.assign(player)
	for i = 1, Config.MaxPlots do
		if not P.owners[i] then
			P.owners[i] = player
			local o = P.origin(i)
			local m = Instance.new("Model"); m.Name = "Plot_" .. player.UserId; m.Parent = root
			part({ Size = Vector3.new(50, 0.4, 56), Position = o + Vector3.new(0, 0.2, -3), Color = Color3.fromRGB(190, 170, 140), Material = Enum.Material.Cobblestone }, m)
			-- เคาน์เตอร์ขาย (ลูกค้ายืนฝั่งถนน ผู้เล่นยืนฝั่งใน)
			part({ Size = Vector3.new(16, 3, 2), Position = o + Vector3.new(0, 1.9, -14), Color = Color3.fromRGB(200, 110, 50), Material = Enum.Material.Wood }, m)
			part({ Size = Vector3.new(18, 0.3, 6), Position = o + Vector3.new(0, 6, -15), Color = Color3.fromRGB(210, 50, 50), Material = Enum.Material.Fabric }, m)
			for _, dx in ipairs({ -8, 8 }) do part({ Size = Vector3.new(0.3, 6, 0.3), Position = o + Vector3.new(dx, 3, -12.5), Color = Color3.fromRGB(60, 60, 60) }, m) end
			sign(m, player.DisplayName .. "'s Street Food", Vector3.new(16, 1.4, 0.2), o + Vector3.new(0, 7, -12.4))
			local stalls = Instance.new("Folder"); stalls.Name = "Stalls"; stalls.Parent = m
			player:SetAttribute("PlotIndex", i)
			return m
		end
	end
end

function P.release(player)
	for i, o in pairs(P.owners) do if o == player then P.owners[i] = nil end end
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	if m then m:Destroy() end
end

-- โต๊ะครัวของเมนูที่ปลดล็อก
function P.refresh(player, foods)
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	if not m then return end
	local o = P.origin(player:GetAttribute("PlotIndex"))
	local stalls = m.Stalls
	for idx, f in ipairs(Config.Foods) do
		if foods[f.id] and not stalls:FindFirstChild(f.id) then
			local g = Instance.new("Model"); g.Name = f.id; g.Parent = stalls
			local k = idx - 1
			local pos = o + Vector3.new(-20 + (k % 5) * 10, 0, -20 - math.floor(k / 5) * 9)
			local body = part({ Size = Vector3.new(6, 2.6, 3), Position = pos + Vector3.new(0, 1.7, 0), Color = Color3.new(f.color[1], f.color[2], f.color[3]), Material = Enum.Material.Wood }, g)
			part({ Size = Vector3.new(6.4, 0.2, 3.4), Position = pos + Vector3.new(0, 3.1, 0), Color = Color3.fromRGB(70, 70, 70), Material = Enum.Material.Metal }, g)
			part({ Size = Vector3.new(7, 0.25, 4), Position = pos + Vector3.new(0, 5.4, 0), Color = Color3.fromRGB(240, 240, 230), Material = Enum.Material.Fabric }, g)
			sign(g, f.emoji .. " " .. Locale.food("en", f.id), Vector3.new(6, 0.8, 0.15), pos + Vector3.new(0, 4.4, 1.6))
			-- อาหารโชว์บนโต๊ะ
			local d = Dish.build(f.id); d.Parent = g
			d:PivotTo(CFrame.new(pos + Vector3.new(0, 3.3, 0)))
			for _, x in ipairs(d:GetDescendants()) do if x:IsA("BasePart") then x.Anchored = true end end
			-- ปุ่มทำอาหาร
			local pp = Instance.new("ProximityPrompt"); pp.ActionText = "Cook"; pp.ObjectText = Locale.food("en", f.id)
			pp.KeyboardKeyCode = Enum.KeyCode.E; pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false; pp.Parent = body
			pp.Triggered:Connect(function(who) if who == player and P.onCook then P.onCook(player, f.id) end end)
		end
	end
end
return P
