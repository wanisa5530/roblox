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
local gui = Instance.new("ScreenGui"); gui.Name = "LifeHud"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Parent = player:WaitForChild("PlayerGui")
local data
-- ===== แถบบน =====
local top = U.frame(gui, UDim2.new(0, 420, 0, 74), UDim2.new(0.5, -210, 0, 8), U.C.bg, 12)
local cashL = U.label(top, "฿0", UDim2.new(0.5, 0, 0, 34), UDim2.new(0, 14, 0, 6), { textSize = 26, color = U.C.accent })
local nameL = U.label(top, "", UDim2.new(0.5, -14, 0, 20), UDim2.new(0.5, 0, 0, 8), { textSize = 13, color = U.C.dim, align = Enum.TextXAlignment.Right })
local clockL = U.label(top, "", UDim2.new(0.5, -14, 0, 20), UDim2.new(0.5, 0, 0, 30), { textSize = 13, color = U.C.dim, align = Enum.TextXAlignment.Right })
local moodL = U.label(top, "", UDim2.new(1, -28, 0, 20), UDim2.new(0, 14, 0, 46), { textSize = 13, color = U.C.green })
-- ===== ความต้องการ (ล่างซ้าย) =====
local needsF = U.frame(gui, UDim2.new(0, 230, 0, 8 + #Config.Needs * 22), UDim2.new(0, 10, 1, -(20 + #Config.Needs * 22) - 70), U.C.bg, 10)
local needBars = {}
for i, n in ipairs(Config.Needs) do
	U.label(needsF, n.emoji .. " " .. T(n.key), UDim2.new(0, 110, 0, 20), UDim2.new(0, 8, 0, 4 + (i - 1) * 22), { textSize = 12 })
	local _, fill = U.bar(needsF, UDim2.new(0, 100, 0, 12), UDim2.new(0, 120, 0, 8 + (i - 1) * 22))
	needBars[n.key] = fill
end
-- ===== ปุ่มล่าง =====
local menuBtn = U.button(gui, "☰ " .. T("menu"), UDim2.new(0, 130, 0, 44), UDim2.new(0, 10, 1, -56), U.C.accent)
local _homeBtn = U.button(gui, "🏠", UDim2.new(0, 50, 0, 44), UDim2.new(0, 148, 1, -56), U.C.blue, function() Remotes.Action:FireServer("goHome") end)
local stopBtn = U.button(gui, "■ " .. T("stop"), UDim2.new(0, 110, 0, 44), UDim2.new(0, 206, 1, -56), U.C.red, function() Remotes.Action:FireServer("stop") end); stopBtn.Visible = false
local _langBtn = U.button(gui, "🌐 " .. lang, UDim2.new(0, 70, 0, 44), UDim2.new(0, 324, 1, -56), U.C.card, function()
	local i = table.find(Config.Languages, lang) or 1; lang = Config.Languages[i % #Config.Languages + 1]
	player:SetAttribute("Lang", lang); Remotes.Action:FireServer("lang", lang); player:SetAttribute("LangTick", os.clock())
end)
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
		nameL.Text = c.name .. " · " .. T(Config.Stages[c.stage].key) .. " · " .. T("generation", c.generation)
		moodL.Text = T("mood") .. ": " .. T(c.mood or "Happy") .. (c.illness and ("  🤒 " .. T(c.illness.key)) or "") .. (c.career and ("  💼 " .. T(c.career) .. " L" .. c.careerLevel) or "")
		for k, f in pairs(needBars) do local v = (c.needs[k] or 0) / 100; f.Size = UDim2.new(v, 0, 1, 0); f.BackgroundColor3 = v < 0.25 and U.C.red or (v < 0.5 and U.C.accent or U.C.green) end
	end
end
Remotes.DataUpdate.OnClientEvent:Connect(function(d) data = d; refresh(); player:SetAttribute("HasChar", d.char ~= nil) end)
player:GetAttributeChangedSignal("Action"):Connect(function() stopBtn.Visible = player:GetAttribute("Action") ~= nil end)
task.spawn(function()
	while true do
		local h = Lighting:GetAttribute("Hour") or 12; local season = Lighting:GetAttribute("Season") or "Summer"
		clockL.Text = string.format("%02d:%02d · %s · %s", math.floor(h), math.floor((h % 1) * 60), T(season), T("day", data and data.dayCount or 0))
		task.wait(2)
	end
end)
-- ===== สร้างตัวละคร =====
local function showCreate()
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
if data and not data.char then showCreate() end
player:SetAttribute("HasChar", data and data.char ~= nil)
-- ปุ่มเมนูส่งสัญญาณให้ MenuClient
menuBtn.MouseButton1Click:Connect(function() player:SetAttribute("MenuToggle", os.clock()) end)
-- ปรับข้อความ prompt ตามภาษา
local function localizePrompt(pp)
	local act = pp:GetAttribute("Action"); if not act then return end
	local map = { work = "goWork", school = "goSchool", uni = "University", hospital = "Hospital", shop = "Shop", cityhall = "buyLot", talk = "npcTalk", serve = "serve", cafe = "business", extinguish = "extinguish", harvest = "harvest" }
	pp.ActionText = T(map[act] or act)
end
for _, pp in ipairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then localizePrompt(pp) end end
workspace.DescendantAdded:Connect(function(x) if x:IsA("ProximityPrompt") then task.defer(localizePrompt, x) end end)
player:GetAttributeChangedSignal("LangTick"):Connect(function() for _, pp in ipairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then localizePrompt(pp) end end end)
