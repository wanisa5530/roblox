-- ตัวช่วยสร้าง UI ใช้ร่วมกันทุก client (ModuleScript)
local Players = game:GetService("Players")
local Locale = require(game.ReplicatedStorage.Locale)
local player = Players.LocalPlayer
local U = { C = { bg = Color3.fromRGB(22, 34, 46), card = Color3.fromRGB(36, 54, 70), accent = Color3.fromRGB(31, 181, 201), green = Color3.fromRGB(64, 212, 116), red = Color3.fromRGB(232, 78, 86), yellow = Color3.fromRGB(250, 200, 70), text = Color3.fromRGB(246, 250, 252), dim = Color3.fromRGB(160, 184, 200), blue = Color3.fromRGB(70, 140, 230), teal = Color3.fromRGB(31, 181, 201), navy = Color3.fromRGB(16, 26, 36) } }
function U.T(key, ...) return Locale.get(player:GetAttribute("Lang") or "en", key, ...) end
function U.frame(parent, size, pos, color, radius, stroke)
	local f = Instance.new("Frame"); f.Size = size; f.Position = pos or UDim2.new(); f.BackgroundColor3 = color or U.C.card; f.BorderSizePixel = 0; f.Parent = parent
	local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0, radius or 10); r.Parent = f
	if stroke then local st = Instance.new("UIStroke"); st.Color = stroke; st.Thickness = 1.5; st.Transparency = 0.3; st.Parent = f end
	return f
end
-- ปุ่มไอคอนกลม สไตล์ Sims (วงกลม + ไอคอน + คำอธิบายเล็กใต้)
function U.iconButton(parent, icon, label, size, pos, color, cb)
	local holder = Instance.new("Frame"); holder.Size = UDim2.new(0, size, 0, size + 14); holder.Position = pos or UDim2.new(); holder.BackgroundTransparency = 1; holder.Parent = parent
	local b = Instance.new("TextButton"); b.Size = UDim2.new(0, size, 0, size); b.BackgroundColor3 = color or U.C.card; b.Text = icon; b.TextSize = math.floor(size * 0.5); b.Font = Enum.Font.GothamBold; b.TextColor3 = U.C.text; b.AutoButtonColor = true; b.BorderSizePixel = 0; b.Parent = holder
	local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(1, 0); r.Parent = b
	local st = Instance.new("UIStroke"); st.Color = U.C.teal; st.Thickness = 2; st.Transparency = 0.4; st.Parent = b
	if label then U.label(holder, label, UDim2.new(1, 20, 0, 14), UDim2.new(0, -10, 0, size), { textSize = 10, color = U.C.dim, align = Enum.TextXAlignment.Center }) end
	if cb then b.MouseButton1Click:Connect(cb) end
	return b, holder
end
-- แถบความต้องการสไตล์ Sims: ไล่สีเขียว→เหลือง→แดง ตามค่า
-- ขยาย UI ตามขนาดจอ (จอใหญ่ = ตัวหนังสือ/ไอคอนใหญ่ขึ้น) และปรับเมื่อขนาดจอเปลี่ยน
function U.scaleGui(gui, base)
	local sc = Instance.new("UIScale"); sc.Parent = gui
	local cam = workspace.CurrentCamera
	local function apply()
		local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
		sc.Scale = math.clamp(math.min(v.Y / (base or 720), v.X / 1280), 1, 1.9)
	end
	apply()
	if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(apply) end
	return sc
end
function U.needColor(v) if v < 0.25 then return U.C.red elseif v < 0.5 then return U.C.yellow end return U.C.green end
function U.label(parent, text, size, pos, opts)
	opts = opts or {}
	local l = Instance.new("TextLabel"); l.Size = size; l.Position = pos or UDim2.new(); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = opts.color or U.C.text; l.Font = opts.font or Enum.Font.GothamBold; l.TextSize = opts.textSize or 16; l.TextScaled = opts.scaled or false; l.TextXAlignment = opts.align or Enum.TextXAlignment.Left; l.TextWrapped = true; l.RichText = true; l.Parent = parent
	return l
end
function U.button(parent, text, size, pos, color, cb)
	local b = Instance.new("TextButton"); b.Size = size; b.Position = pos or UDim2.new(); b.BackgroundColor3 = color or U.C.accent; b.Text = text; b.TextColor3 = U.C.text; b.Font = Enum.Font.GothamBold; b.TextSize = 15; b.TextWrapped = true; b.AutoButtonColor = true; b.BorderSizePixel = 0; b.Parent = parent
	local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0, 8); r.Parent = b
	if cb then b.MouseButton1Click:Connect(cb) end
	return b
end
function U.list(parent, pad)
	local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, pad or 6); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = parent; return l
end
function U.scroll(parent, size, pos)
	local s = Instance.new("ScrollingFrame"); s.Size = size; s.Position = pos or UDim2.new(); s.BackgroundTransparency = 1; s.BorderSizePixel = 0; s.ScrollBarThickness = 6; s.AutomaticCanvasSize = Enum.AutomaticSize.Y; s.CanvasSize = UDim2.new(); s.Parent = parent
	U.list(s, 6)
	local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 6); p.PaddingRight = UDim.new(0, 10); p.PaddingTop = UDim.new(0, 6); p.Parent = s
	return s
end
-- การ์ดในลิสต์: ชื่อ, คำอธิบาย, ปุ่ม
function U.card(parent, title, desc, btnText, btnColor, cb, order)
	local c = U.frame(parent, UDim2.new(1, 0, 0, 62), nil, U.C.card, 8); c.LayoutOrder = order or 0
	U.label(c, title, UDim2.new(0.62, 0, 0, 26), UDim2.new(0, 10, 0, 6), { textSize = 16 })
	U.label(c, desc or "", UDim2.new(0.62, 0, 0, 28), UDim2.new(0, 10, 0, 30), { textSize = 12, color = U.C.dim, font = Enum.Font.Gotham })
	if btnText then U.button(c, btnText, UDim2.new(0.3, 0, 0, 38), UDim2.new(0.67, 0, 0.5, -19), btnColor, cb) end
	return c
end
function U.bar(parent, size, pos, color)
	local bg = U.frame(parent, size, pos, Color3.fromRGB(20, 20, 26), 6)
	local fill = U.frame(bg, UDim2.new(0.5, 0, 1, 0), nil, color or U.C.green, 6); fill.Name = "Fill"
	return bg, fill
end
function U.fmt(n) return Locale.fmt(n) end
return U
