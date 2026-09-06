-- UI หลัก: แถบเงินด้านบน, ร้านค้าแบบแท็บ, สลับภาษา, แจ้งเตือน
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS:WaitForChild("Config"))
local Locale = require(RS:WaitForChild("Locale"))
local Remotes = require(RS:WaitForChild("Remotes"))
local player = Players.LocalPlayer
local lang = Locale.detect(player.LocaleId)
player:SetAttribute("Lang", lang)
local T = function(k) return Locale.get(lang, k) end
local state = { data = nil, holding = nil, tab = "menu" }

local C = { bg = Color3.fromRGB(28, 24, 22), panel = Color3.fromRGB(42, 36, 32), card = Color3.fromRGB(58, 50, 44),
	accent = Color3.fromRGB(255, 170, 40), green = Color3.fromRGB(90, 200, 110), red = Color3.fromRGB(220, 80, 70),
	text = Color3.fromRGB(250, 245, 235), muted = Color3.fromRGB(180, 170, 160) }
local FONT = Enum.Font.FredokaOne

local function corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = o end
local function pad(o, p) local u = Instance.new("UIPadding"); u.PaddingTop = UDim.new(0, p); u.PaddingBottom = UDim.new(0, p); u.PaddingLeft = UDim.new(0, p); u.PaddingRight = UDim.new(0, p); u.Parent = o end
local function frame(parent, size, pos, color)
	local f = Instance.new("Frame"); f.Size = size; f.Position = pos; f.BackgroundColor3 = color or C.panel; f.BorderSizePixel = 0; f.Parent = parent; return f
end
local function label(parent, text, size, pos, textSize, color, xalign)
	local l = Instance.new("TextLabel"); l.Size = size; l.Position = pos; l.BackgroundTransparency = 1; l.Text = text
	l.Font = FONT; l.TextSize = textSize or 18; l.TextColor3 = color or C.text; l.TextXAlignment = xalign or Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd; l.Parent = parent; return l
end
local function button(parent, text, size, pos, color, cb)
	local b = Instance.new("TextButton"); b.Size = size; b.Position = pos; b.BackgroundColor3 = color or C.accent; b.Text = text
	b.Font = FONT; b.TextSize = 18; b.TextColor3 = C.text; b.AutoButtonColor = false; b.BorderSizePixel = 0; b.Parent = parent
	corner(b, 8)
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = color and color:Lerp(Color3.new(1,1,1), 0.15) or C.accent:Lerp(Color3.new(1,1,1), 0.15) }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = color or C.accent }):Play() end)
	if cb then b.MouseButton1Click:Connect(cb) end
	return b
end

local gui = Instance.new("ScreenGui"); gui.Name = "TycoonUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Parent = player.PlayerGui

-- แถบด้านบน
local top = frame(gui, UDim2.new(0, 520, 0, 64), UDim2.new(0.5, -260, 0, 12), C.bg); corner(top, 14); pad(top, 8)
local cashLbl = label(top, "฿ 0", UDim2.new(0, 220, 0, 30), UDim2.new(0, 8, 0, 0), 28, C.accent)
local incLbl = label(top, "", UDim2.new(0, 220, 0, 18), UDim2.new(0, 8, 0, 30), 15, C.green)
local holdLbl = label(top, "", UDim2.new(0, 200, 0, 44), UDim2.new(1, -210, 0, 2), 16, C.text, Enum.TextXAlignment.Right)
holdLbl.TextWrapped = true
local titleLbl = label(top, T("title"), UDim2.new(0, 130, 0, 48), UDim2.new(0, 230, 0, 0), 14, C.muted, Enum.TextXAlignment.Center)
titleLbl.TextWrapped = true

-- ปุ่มเปิดร้าน + ภาษา (ซ้ายล่าง)
local shopOpen = false
local shopBtn = button(gui, "🛒 " .. T("menu"), UDim2.new(0, 150, 0, 44), UDim2.new(0, 16, 1, -64), C.accent)
local langBtn = button(gui, "🌐 " .. Locale.Names[lang], UDim2.new(0, 130, 0, 44), UDim2.new(0, 176, 1, -64), C.card)

-- แจ้งเตือน
local toast = label(gui, "", UDim2.new(0, 400, 0, 36), UDim2.new(0.5, -200, 0, 90), 18, C.text, Enum.TextXAlignment.Center)
toast.BackgroundTransparency = 0.2; toast.BackgroundColor3 = C.bg; toast.Visible = false; corner(toast, 8)
local function notify(msg, color)
	toast.Text = msg; toast.TextColor3 = color or C.text; toast.Visible = true
	task.delay(2, function() if toast.Text == msg then toast.Visible = false end end)
end

-- รางวัลรายวัน
local daily = frame(gui, UDim2.new(0, 320, 0, 200), UDim2.new(0.5, -160, 0.5, -100), C.bg); corner(daily, 16); daily.Visible = false
local dailyTitle = label(daily, "", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 12), 26, C.accent, Enum.TextXAlignment.Center)
local dailyDay = label(daily, "", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 56), 20, C.muted, Enum.TextXAlignment.Center)
local dailyAmt = label(daily, "", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 88), 32, C.green, Enum.TextXAlignment.Center)
local dailyBtn = button(daily, "", UDim2.new(0, 180, 0, 44), UDim2.new(0.5, -90, 1, -56), C.green)
local function showDaily(day, amt)
	dailyTitle.Text = "🎁 " .. T("daily"); dailyDay.Text = string.format(T("day"), day); dailyAmt.Text = "฿ " .. Locale.fmt(amt); dailyBtn.Text = T("claim")
	daily.Visible = true
end
dailyBtn.MouseButton1Click:Connect(function()
	local okc = Remotes.ClaimDaily:InvokeServer(false)
	daily.Visible = false
	notify(okc and (dailyAmt.Text) or T("claimed"), C.green)
end)

-- Leaderboard ด้านขวา
local lbFrame = frame(gui, UDim2.new(0, 220, 0, 260), UDim2.new(1, -236, 0, 90), C.bg); corner(lbFrame, 12); pad(lbFrame, 10)
lbFrame.BackgroundTransparency = 0.15
local lbTitle = label(lbFrame, "🏆 " .. T("top"), UDim2.new(1, 0, 0, 26), UDim2.new(), 18, C.accent)
local lbBody = label(lbFrame, "...", UDim2.new(1, 0, 1, -30), UDim2.new(0, 0, 0, 30), 14, C.text)
lbBody.TextYAlignment = Enum.TextYAlignment.Top; lbBody.TextWrapped = true
Remotes.Leaderboard.OnClientEvent:Connect(function(rows)
	local lines = {}
	for i, r in ipairs(rows) do lines[#lines + 1] = string.format("%d. %s  ฿%s", i, r.name, Locale.fmt(r.value)) end
	lbBody.Text = #lines > 0 and table.concat(lines, "\n") or "-"
end)

Remotes.Notify.OnClientEvent:Connect(function(key, color, a, b)
	local msg = T(key)
	if key == "tip" then msg = "+฿" .. Locale.fmt(a) .. (b and b > 0 and ("  (" .. T("tip") .. " ฿" .. Locale.fmt(b) .. ")") or "") end
	notify(msg, color == "red" and C.red or C.green)
end)

-- หน้าต่างร้านค้า
local shop = frame(gui, UDim2.new(0, 460, 0, 520), UDim2.new(0.5, -230, 0.5, -230), C.bg); corner(shop, 16); shop.Visible = false
local closeBtn = button(shop, "✕", UDim2.new(0, 36, 0, 36), UDim2.new(1, -44, 0, 8), C.red)
local tabs = {}
local tabNames = { "menu", "passes", "robux" }
for i, name in ipairs(tabNames) do
	tabs[name] = button(shop, T(name), UDim2.new(0, 120, 0, 36), UDim2.new(0, 12 + (i - 1) * 126, 0, 8), C.card)
end
local list = Instance.new("ScrollingFrame"); list.Size = UDim2.new(1, -24, 1, -64); list.Position = UDim2.new(0, 12, 0, 54)
list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.ScrollBarThickness = 6; list.CanvasSize = UDim2.new(); list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.Parent = shop
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 8); layout.Parent = list

local function card(title, sub, btnText, btnColor, cb, emoji)
	local c = frame(list, UDim2.new(1, -8, 0, 64), UDim2.new(), C.card); corner(c, 10)
	label(c, emoji or "", UDim2.new(0, 44, 1, 0), UDim2.new(0, 8, 0, 0), 30, nil, Enum.TextXAlignment.Center)
	label(c, title, UDim2.new(1, -200, 0, 30), UDim2.new(0, 56, 0, 6), 18)
	label(c, sub, UDim2.new(1, -200, 0, 20), UDim2.new(0, 56, 0, 34), 14, C.muted)
	local b = button(c, btnText, UDim2.new(0, 120, 0, 40), UDim2.new(1, -130, 0, 12), btnColor, cb)
	return c, b
end

local function renderShop()
	for _, ch in ipairs(list:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
	for name, b in pairs(tabs) do b.BackgroundColor3 = name == state.tab and C.accent or C.card; b.Text = T(name) end
	local d = state.data; if not d then return end
	if state.tab == "menu" then
		for _, f in ipairs(Config.Foods) do
			local owned = d.foods[f.id]
			local can = d.cash >= f.cost
			local _, b = card(Locale.food(lang, f.id), "฿ " .. Locale.fmt(f.price) .. " / " .. f.emoji,
				owned and T("owned") or ("฿ " .. Locale.fmt(f.cost)), owned and C.card or (can and C.green or C.red),
				function()
					if owned then return end
					local ok, err = Remotes.BuyFood:InvokeServer(f.id)
					if ok then notify(string.format(T("bought"), Locale.food(lang, f.id)), C.green) elseif err then notify(T(err), C.red) end
				end, f.emoji)
			if owned then b.AutoButtonColor = false end
		end
	elseif state.tab == "passes" then
		for _, gp in ipairs(Config.GamePasses) do
			card(T(gp.key), "Game Pass", "Robux", C.accent, function() Remotes.PromptPass:FireServer("pass", gp.key) end, "⭐")
		end
	else
		for _, dp in ipairs(Config.DevProducts) do
			card(T(dp.key), "฿ " .. Locale.fmt(dp.cash), "Robux", C.accent, function() Remotes.PromptPass:FireServer("product", dp.key) end, "💰")
		end
	end
end

local function renderTop()
	local d = state.data; if not d then return end
	cashLbl.Text = "฿ " .. Locale.fmt(d.cash)
	local stars = math.clamp(math.floor((d.rep or 0) / 200) + 1, 1, 5)
	incLbl.Text = string.rep("⭐", stars) .. "  " .. T("served") .. ": " .. (d.served or 0)
	holdLbl.Text = state.holding and ("🍽️ " .. T("holding") .. ": " .. Locale.food(lang, state.holding)) or ""
end

local function applyLang()
	lbTitle.Text = "🏆 " .. T("top")
	titleLbl.Text = T("title"); shopBtn.Text = "🛒 " .. T("menu"); langBtn.Text = "🌐 " .. Locale.Names[lang]
	renderTop(); renderShop()
end

for name, b in pairs(tabs) do b.MouseButton1Click:Connect(function() state.tab = name; renderShop() end) end
shopBtn.MouseButton1Click:Connect(function() shopOpen = not shopOpen; shop.Visible = shopOpen; if shopOpen then renderShop() end end)
closeBtn.MouseButton1Click:Connect(function() shopOpen = false; shop.Visible = false end)
langBtn.MouseButton1Click:Connect(function()
	local i = table.find(Locale.Supported, lang) or 1
	lang = Locale.Supported[i % #Locale.Supported + 1]; player:SetAttribute("Lang", lang); applyLang()
end)

local lastCash
Remotes.DataUpdate.OnClientEvent:Connect(function(d, holding)
	state.data, state.holding = d, holding
	renderTop()
	if shopOpen and d.cash ~= lastCash then renderShop() end
	lastCash = d.cash
end)
local ok, d, holding = pcall(function() return Remotes.GetData:InvokeServer() end)
if ok and d then state.data, state.holding = d, holding; applyLang() else cashLbl.Text = "ERR: " .. tostring(d) end
task.delay(1, function()
	local okd, can, day, amt = pcall(function() return Remotes.ClaimDaily:InvokeServer(true) end)
	if okd and can then showDaily(day, amt) end
end)
