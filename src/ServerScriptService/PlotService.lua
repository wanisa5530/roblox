-- แปลงร้านของผู้เล่นแต่ละคน: สร้างรถเข็น + แผงอาหารตามเมนูที่ซื้อ
local Config = require(game.ReplicatedStorage.Config)
local Locale = require(game.ReplicatedStorage.Locale)
local P = { owners = {} }
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
	return Vector3.new(-90 + col * 60, 0, 30 + row * 70)
end

function P.assign(player)
	for i = 1, Config.MaxPlots do
		if not P.owners[i] then
			P.owners[i] = player
			local o = P.origin(i)
			local m = Instance.new("Model"); m.Name = "Plot_" .. player.UserId; m.Parent = root
			part({ Size = Vector3.new(50, 0.4, 50), Position = o + Vector3.new(0, 0.2, 0), Color = Color3.fromRGB(190, 170, 140), Material = Enum.Material.Cobblestone }, m)
			-- รถเข็นหลัก
			part({ Size = Vector3.new(8, 3, 4), Position = o + Vector3.new(0, 1.9, -18), Color = Color3.fromRGB(200, 110, 50), Material = Enum.Material.Wood }, m)
			part({ Size = Vector3.new(9, 0.3, 5), Position = o + Vector3.new(0, 5.4, -18), Color = Color3.fromRGB(210, 50, 50), Material = Enum.Material.Fabric }, m)
			for _, dx in ipairs({ -4, 4 }) do part({ Size = Vector3.new(0.3, 5, 0.3), Position = o + Vector3.new(dx, 2.9, -16), Color = Color3.fromRGB(60, 60, 60) }, m) end
			sign(m, player.DisplayName .. "'s Stall", Vector3.new(9, 1.2, 0.2), o + Vector3.new(0, 6.3, -16))
			-- จุดยืนเก็บเงิน
			local pad = part({ Size = Vector3.new(6, 0.3, 6), Position = o + Vector3.new(0, 0.55, -10), Color = Color3.fromRGB(255, 215, 60), Material = Enum.Material.Neon }, m)
			pad.Name = "CollectPad"
			local stalls = Instance.new("Folder"); stalls.Name = "Stalls"; stalls.Parent = m
			player:SetAttribute("PlotIndex", i)
			return m, pad
		end
	end
end

function P.release(player)
	for i, o in pairs(P.owners) do if o == player then P.owners[i] = nil end end
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	if m then m:Destroy() end
end

-- วางแผงอาหารตามเมนูที่มี
function P.refresh(player, foods)
	local m = root:FindFirstChild("Plot_" .. player.UserId)
	if not m then return end
	local o = P.origin(player:GetAttribute("PlotIndex"))
	local stalls = m.Stalls
	for idx, f in ipairs(Config.Foods) do
		if foods[f.id] and not stalls:FindFirstChild(f.id) then
			local g = Instance.new("Model"); g.Name = f.id; g.Parent = stalls
			local k = idx - 1
			local pos = o + Vector3.new(-21 + (k % 5) * 10.5, 0, -2 + math.floor(k / 5) * 9)
			part({ Size = Vector3.new(6, 2.4, 3), Position = pos + Vector3.new(0, 1.6, 0), Color = Color3.new(f.color[1], f.color[2], f.color[3]), Material = Enum.Material.Wood }, g)
			part({ Size = Vector3.new(7, 0.25, 4), Position = pos + Vector3.new(0, 4.4, 0), Color = Color3.fromRGB(240, 240, 230), Material = Enum.Material.Fabric }, g)
			sign(g, f.emoji .. " " .. Locale.food("en", f.id), Vector3.new(6, 0.9, 0.15), pos + Vector3.new(0, 3.2, 1.6))
		end
	end
end
return P
