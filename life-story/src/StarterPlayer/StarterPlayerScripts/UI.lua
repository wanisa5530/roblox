-- ตัวช่วยสร้าง UI ใช้ร่วมกันทุก client (ModuleScript)
local Players = game:GetService("Players")
local Locale = require(game.ReplicatedStorage.Locale)
local player = Players.LocalPlayer
local U = { C = { bg = Color3.fromRGB(28, 28, 36), card = Color3.fromRGB(42, 42, 54), accent = Color3.fromRGB(255, 170, 40), green = Color3.fromRGB(70, 200, 110), red = Color3.fromRGB(230, 80, 80), text = Color3.fromRGB(245, 245, 245), dim = Color3.fromRGB(170, 170, 185), blue = Color3.fromRGB(80, 150, 240) } }
function U.T(key, ...) return Locale.get(player:GetAttribute("Lang") or "en", key, ...) end
function U.frame(parent, size, pos, color, radius)
	local f = Instance.new("Frame"); f.Size = size; f.Position = pos or UDim2.new(); f.BackgroundColor3 = color or U.C.card; f.BorderSizePixel = 0; f.Parent = parent
	local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0, radius or 10); r.Parent = f
	return f
end
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
