-- HUD: เงิน เวลา ความต้องการ อารมณ์ แจ้งเตือน ปุ่มเมนู + สร้างตัวละคร + จอผี/ทายาท
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalizationService = game:GetService("LocalizationService")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Locale = require(RS.Locale)
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
game:GetService("ScriptContext").Error:Connect(function(msg, trace) pcall(function() Remotes.Action:FireServer("clientError", msg .. " | " .. trace:sub(1, 80)) end) end)
local lang = Locale.detect(LocalizationService.RobloxLocaleId)
player:SetAttribute("Lang", lang); Remotes.Action:FireServer("lang", lang)
local T = U.T
local gui = Instance.new("ScreenGui"); gui.Name = "LifeHud"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Parent = player:WaitForChild("PlayerGui"); U.scaleGui(gui)
local data
-- ===== แถบล่างสไตล์ The Sims: ซ้าย=ตัวละคร/อารมณ์/ปุ่ม กลาง=ความต้องการ ขวา=เงิน/เวลา/โหมด =====
local BAR_H = 118
local bar = U.frame(gui, UDim2.new(1, 0, 0, BAR_H), UDim2.new(0, 0, 1, -BAR_H), U.C.navy, 0); bar.BackgroundTransparency = 0.12
local edge = U.frame(bar, UDim2.new(1, 0, 0, 3), UDim2.new(0, 0, 0, 0), U.C.teal, 0); edge.BackgroundTransparency = 0.2
local grad = Instance.new("UIGradient"); grad.Color = ColorSequence.new(Color3.fromRGB(28, 44, 60), Color3.fromRGB(14, 22, 30)); grad.Rotation = 90; grad.Parent = bar
-- ซ้าย: รูปตัวละคร (thumbnail จริง) + ชื่อ + ช่วงชีวิต + อารมณ์
local portraitBg = U.frame(bar, UDim2.new(0, 84, 0, 84), UDim2.new(0, 14, 0, 16), U.C.card, 42, U.C.teal)
local portrait = Instance.new("ImageLabel"); portrait.Size = UDim2.new(1, -6, 1, -6); portrait.Position = UDim2.new(0, 3, 0, 3); portrait.BackgroundTransparency = 1; portrait.Parent = portraitBg
local pr = Instance.new("UICorner"); pr.CornerRadius = UDim.new(1, 0); pr.Parent = portrait
pcall(function() portrait.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
local plumbob = U.label(bar, "◆", UDim2.new(0, 20, 0, 20), UDim2.new(0, 46, 0, 0), { textSize = 18, color = U.C.green, align = Enum.TextXAlignment.Center })
local nameL = U.label(bar, "", UDim2.new(0, 220, 0, 22), UDim2.new(0, 108, 0, 14), { textSize = 16 })
local stageL = U.label(bar, "", UDim2.new(0, 220, 0, 16), UDim2.new(0, 108, 0, 36), { textSize = 11, color = U.C.dim, font = Enum.Font.Gotham })
local moodL = U.label(bar, "", UDim2.new(0, 220, 0, 18), UDim2.new(0, 108, 0, 54), { textSize = 13, color = U.C.green })
-- ปุ่มวงกลม: เมนู บ้าน หยุด ภาษา
local btnRow = Instance.new("Frame"); btnRow.Size = UDim2.new(0, 240, 0, 50); btnRow.Position = UDim2.new(0, 106, 0, 72); btnRow.BackgroundTransparency = 1; btnRow.Parent = bar
local bl = Instance.new("UIListLayout"); bl.FillDirection = Enum.FillDirection.Horizontal; bl.Padding = UDim.new(0, 10); bl.Parent = btnRow
local menuBtn = U.iconButton(btnRow, "☰", T("menu"), 34, nil, U.C.accent)
U.iconButton(btnRow, "🏠", T("home"), 34, nil, U.C.card, function() Remotes.Action:FireServer("goHome") end)
U.iconButton(btnRow, "🚗", T("drive"), 34, nil, U.C.card, function() Remotes.Action:FireServer("callCar") end)
local _stopBtn, stopHolder = U.iconButton(btnRow, "■", T("stop"), 34, nil, U.C.red, function() Remotes.Action:FireServer("stop") end); stopHolder.Visible = false
local langBtn = U.iconButton(btnRow, "🌐", lang, 34, nil, U.C.card, function()
	local i = table.find(Config.Languages, lang) or 1; lang = Config.Languages[i % #Config.Languages + 1]
	player:SetAttribute("Lang", lang); Remotes.Action:FireServer("lang", lang); player:SetAttribute("LangTick", os.clock())
end)
-- กลาง: ความต้องการ 8 อย่าง 2 คอลัมน์
local needsF = Instance.new("Frame"); needsF.Size = UDim2.new(0, 520, 0, 100); needsF.Position = UDim2.new(0.5, -260, 0, 10); needsF.BackgroundTransparency = 1; needsF.Parent = bar
local needBars, needLabels = {}, {}
for i, n in ipairs(Config.Needs) do
	local col = (i - 1) % 2; local row = (i - 1) // 2
	local x, y = col * 262, row * 24
	needLabels[n.key] = U.label(needsF, n.emoji .. " " .. T(n.key), UDim2.new(0, 96, 0, 20), UDim2.new(0, x, 0, y), { textSize = 12 })
	local bg, fill = U.bar(needsF, UDim2.new(0, 150, 0, 12), UDim2.new(0, x + 100, 0, y + 4))
	bg.BackgroundColor3 = Color3.fromRGB(10, 16, 22)
	needBars[n.key] = fill
end
-- ขวา: เงิน เวลา วัน ฤดู + โหมด Live/Build/Buy
local right = Instance.new("Frame"); right.Size = UDim2.new(0, 300, 1, 0); right.Position = UDim2.new(1, -310, 0, 0); right.BackgroundTransparency = 1; right.Parent = bar
local cashL = U.label(right, "฿0", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 10), { textSize = 28, color = U.C.green, align = Enum.TextXAlignment.Right })
local clockL = U.label(right, "", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 44), { textSize = 13, color = U.C.text, align = Enum.TextXAlignment.Right })
local modeRow = Instance.new("Frame"); modeRow.Size = UDim2.new(0, 190, 0, 50); modeRow.Position = UDim2.new(1, -190, 0, 66); modeRow.BackgroundTransparency = 1; modeRow.Parent = right
local ml = Instance.new("UIListLayout"); ml.FillDirection = Enum.FillDirection.Horizontal; ml.Padding = UDim.new(0, 10); ml.HorizontalAlignment = Enum.HorizontalAlignment.Right; ml.Parent = modeRow
U.iconButton(modeRow, "▶", "Live", 34, nil, U.C.green, function() player:SetAttribute("BuildClose", os.clock()) end)
U.iconButton(modeRow, "🔨", T("build"), 34, nil, U.C.accent, function() player:SetAttribute("BuildMode", os.clock()) end)
U.iconButton(modeRow, "🛒", T("shop"), 34, nil, U.C.blue, function() player:SetAttribute("BuildMode", os.clock()) end)
U.iconButton(modeRow, "🎯", T("quests"), 34, nil, U.C.card, function() player:SetAttribute("MenuTab", "quests"); player:SetAttribute("MenuToggle", os.clock()) end)
-- ===== แจ้งเตือน =====
local notifF = Instance.new("Frame"); notifF.Size = UDim2.new(0, 380, 0, 200); notifF.Position = UDim2.new(0.5, -190, 0, 90); notifF.BackgroundTransparency = 1; notifF.Parent = gui
U.list(notifF, 4)
local colors = { green = U.C.green, red = U.C.red, yellow = U.C.accent, white = U.C.text }
Remotes.Notify.OnClientEvent:Connect(function(key, color, ...)
	local args = { ... }
	for i, a in ipairs(args) do if type(a) == "number" then args[i] = U.fmt(a) end end
	local l = U.label(notifF, T(key, table.unpack(args)), UDim2.new(1, 0, 0, 26), nil, { textSize = 15, color = colors[color] or U.C.text, align = Enum.TextXAlignment.Center })
	l.BackgroundTransparency = 0.3; l.BackgroundColor3 = U.C.bg
	local r = Instance.new("UICorner"); r.Parent = l
	task.delay(4, function() l:Destroy() end)
end)
-- ===== อัปเดตข้อมูล =====
local function refresh()
	if not data then return end
	cashL.Text = "฿" .. U.fmt(data.cash)
	local c = data.char
	if c then
		nameL.Text = c.name
		stageL.Text = T(Config.Stages[c.stage].key) .. " · " .. T("generation", c.generation) .. (c.career and ("  💼 " .. T(c.career) .. " " .. T("level", c.careerLevel)) or "")
		local moodColor = ({ Happy = U.C.green, Confident = U.C.green, Inspired = U.C.accent, Focused = U.C.accent, Playful = U.C.yellow, Flirty = Color3.fromRGB(240, 120, 170), Sad = U.C.blue, Bored = U.C.dim, Angry = U.C.red, Stressed = U.C.red, Embarrassed = U.C.yellow, Scared = U.C.red, Sick = Color3.fromRGB(160, 220, 120) })[c.mood or "Happy"] or U.C.text
		moodL.Text = "● " .. T(c.mood or "Happy") .. (c.illness and ("  🤒 " .. T(c.illness.key)) or ""); moodL.TextColor3 = moodColor; plumbob.TextColor3 = moodColor
		for k, f in pairs(needBars) do local v = (c.needs[k] or 0) / 100; f.Size = UDim2.new(v, 0, 1, 0); f.BackgroundColor3 = U.needColor(v) end
	end
end
local createShown = false
local function showCreate() end  -- กำหนดจริงด้านล่าง
Remotes.DataUpdate.OnClientEvent:Connect(function(d) data = d; refresh(); player:SetAttribute("HasChar", d.char ~= nil); if not d.char and not createShown then createShown = true; showCreate() end end)
player:GetAttributeChangedSignal("Action"):Connect(function() stopHolder.Visible = player:GetAttribute("Action") ~= nil end)
task.spawn(function()
	while true do
		local h = Lighting:GetAttribute("Hour") or 12; local season = Lighting:GetAttribute("Season") or "Summer"
		local icon = (h >= 6 and h < 18) and "☀️" or "🌙"
		clockL.Text = string.format("%s %02d:%02d  ·  %s  ·  %s", icon, math.floor(h), math.floor((h % 1) * 60), T(season), T("day", data and data.dayCount or 0))
		task.wait(2)
	end
end)
-- ===== สร้างตัวละคร =====
showCreate = function()
	local ov = U.frame(gui, UDim2.new(0, 560, 0, 520), UDim2.new(0.5, -280, 0.5, -260), U.C.bg, 14)
	U.label(ov, T("welcome"), UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 8), { textSize = 18, color = U.C.accent })
	U.label(ov, T("yourName"), UDim2.new(0, 120, 0, 30), UDim2.new(0, 10, 0, 44), { textSize = 14 })
	local nameBox = Instance.new("TextBox"); nameBox.Size = UDim2.new(0, 220, 0, 30); nameBox.Position = UDim2.new(0, 130, 0, 44); nameBox.Text = player.DisplayName; nameBox.BackgroundColor3 = U.C.card; nameBox.TextColor3 = U.C.text; nameBox.Font = Enum.Font.Gotham; nameBox.TextSize = 14; nameBox.Parent = ov
	Instance.new("UICorner").Parent = nameBox
	U.label(ov, T("chooseTraits"), UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, 82), { textSize = 14 })
	local chosen = {}
	local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, -20, 0, 190); tf.Position = UDim2.new(0, 10, 0, 108); tf.BackgroundTransparency = 1; tf.Parent = ov
	local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.new(0, 128, 0, 30); grid.CellPadding = UDim2.new(0, 6, 0, 6); grid.Parent = tf
	local tbtns = {}
	for _, t in ipairs(Config.Traits) do
		local b = U.button(tf, T(t.key), UDim2.new(), nil, U.C.card, nil); tbtns[t.key] = b
		b.MouseButton1Click:Connect(function()
			if chosen[t.key] then chosen[t.key] = nil; b.BackgroundColor3 = U.C.card
			else local n = 0; for _ in pairs(chosen) do n += 1 end; if n < Config.TraitCount then chosen[t.key] = true; b.BackgroundColor3 = U.C.green end end
		end)
	end
	U.label(ov, T("chooseAspiration"), UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, 304), { textSize = 14 })
	local asp = Config.Aspirations[1].key
	local af = Instance.new("Frame"); af.Size = UDim2.new(1, -20, 0, 74); af.Position = UDim2.new(0, 10, 0, 330); af.BackgroundTransparency = 1; af.Parent = ov
	local g2 = Instance.new("UIGridLayout"); g2.CellSize = UDim2.new(0, 128, 0, 32); g2.CellPadding = UDim2.new(0, 6, 0, 6); g2.Parent = af
	local abtns = {}
	for _, a in ipairs(Config.Aspirations) do
		local b = U.button(af, T(a.key), UDim2.new(), nil, a.key == asp and U.C.green or U.C.card, nil); abtns[a.key] = b
		b.MouseButton1Click:Connect(function() asp = a.key; for k, x in pairs(abtns) do x.BackgroundColor3 = k == asp and U.C.green or U.C.card end end)
	end
	U.button(ov, "▶ " .. T("start"), UDim2.new(0, 220, 0, 46), UDim2.new(0.5, -110, 1, -60), U.C.accent, function()
		local list = {}; for k in pairs(chosen) do list[#list + 1] = k end
		if #list < Config.TraitCount then return end
		local ok = Remotes.CreateCharacter:InvokeServer(nameBox.Text, list, asp)
		if ok then ov:Destroy() end
	end)
end
-- ===== ตาย → เลือกทายาท =====
Remotes.Family.OnClientEvent:Connect(function(kind, kids, cause)
	if kind ~= "died" then return end
	local ov = U.frame(gui, UDim2.new(0, 420, 0, 320), UDim2.new(0.5, -210, 0.5, -160), U.C.bg, 14)
	U.label(ov, "💀 " .. T("died", data and data.char and data.char.name or "", T(cause)), UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 8), { textSize = 16, color = U.C.red })
	U.label(ov, T("ghost"), UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 50), { textSize = 14 })
	local s = U.scroll(ov, UDim2.new(1, -20, 0, 200), UDim2.new(0, 10, 0, 86))
	for i, k in ipairs(kids or {}) do U.card(s, "👶 " .. k.name, T(Config.Stages[k.stage or 1].key), T("start"), U.C.green, function() if Remotes.Heir:InvokeServer(i) then ov:Destroy() end end, i) end
	U.card(s, "🌱 " .. T("newLife", "?", 1), "", T("start"), U.C.accent, function() if Remotes.Heir:InvokeServer(0) then ov:Destroy() end end, 99)
end)
data = Remotes.GetData:InvokeServer()
refresh()
if data and not data.char and not createShown then createShown = true; showCreate() end
player:SetAttribute("HasChar", data and data.char ~= nil)
-- กดเดิน/กระโดดระหว่างทำกิจกรรม (นอน นั่ง) = หยุดกิจกรรมและลุก
game:GetService("UserInputService").InputBegan:Connect(function(i, gp)
	if gp then return end
	if player:GetAttribute("Action") and (i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.S or i.KeyCode == Enum.KeyCode.D or i.KeyCode == Enum.KeyCode.Space) then Remotes.Action:FireServer("stop") end
end)
-- ปุ่มเมนูส่งสัญญาณให้ MenuClient
menuBtn.MouseButton1Click:Connect(function() player:SetAttribute("MenuToggle", os.clock()) end)
player:GetAttributeChangedSignal("LangTick"):Connect(function() langBtn.Text = "🌐"; for _, n in ipairs(Config.Needs) do needLabels[n.key].Text = n.emoji .. " " .. T(n.key) end end)
-- ปรับข้อความ prompt ตามภาษา
local function localizePrompt(pp)
	local act = pp:GetAttribute("Action"); if not act then return end
	local map = { work = "goWork", school = "goSchool", uni = "University", hospital = "Hospital", shop = "Shop", cityhall = "buyLot", talk = "npcTalk", serve = "serve", cafe = "business", extinguish = "extinguish", harvest = "harvest" }
	pp.ActionText = T(map[act] or act)
end
for _, pp in ipairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then localizePrompt(pp) end end
workspace.DescendantAdded:Connect(function(x) if x:IsA("ProximityPrompt") then task.defer(localizePrompt, x) end end)
player:GetAttributeChangedSignal("LangTick"):Connect(function() for _, pp in ipairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then localizePrompt(pp) end end end)
