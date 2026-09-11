-- คู่มือเริ่มต้น: แผงซ้ายบน แสดงขั้นตอนถัดไป ติ๊กอัตโนมัติจากข้อมูลผู้เล่น
local Players = game:GetService("Players")
local RS = game.ReplicatedStorage
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local gui = Instance.new("ScreenGui"); gui.Name = "LifeGuide"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui"); U.scaleGui(gui)
local panel = U.frame(gui, UDim2.new(0, 330, 0, 250), UDim2.new(0, 12, 0, 70), U.C.navy, 14, U.C.teal); panel.BackgroundTransparency = 0.15; panel.Visible = false
U.label(panel, "📘 " .. T("guide"), UDim2.new(1, -60, 0, 26), UDim2.new(0, 12, 0, 8), { textSize = 17, color = U.C.accent })
local hideBtn = U.button(panel, "—", UDim2.new(0, 26, 0, 26), UDim2.new(1, -34, 0, 8), U.C.card, nil)
local list = Instance.new("Frame"); list.Size = UDim2.new(1, -20, 1, -44); list.Position = UDim2.new(0, 10, 0, 40); list.BackgroundTransparency = 1; list.Parent = panel
U.list(list, 4)
local STEPS = {
	{ key = "g1", done = function(d) return player:GetAttribute("AtHome") == true end },
	{ key = "g2", done = function(d) return d.char and (d.char.slept or 0) > 0 end },
	{ key = "g3", done = function(d) return d.char and (d.char.ate or 0) > 0 end },
	{ key = "g4", done = function(d) return d.char and d.char.career ~= nil end },
	{ key = "g5", done = function(d) return d.char and (d.char.shifts or 0) > 0 end },
	{ key = "g6", done = function(d) return d.char and next(d.char.rel or {}) ~= nil end },
	{ key = "g7", done = function(d) return d.char and (d.char.bought or 0) > 0 end },
	{ key = "g8", done = function(d) return d.char and d.char.car ~= nil end },
}
local rows = {}
for i, st in ipairs(STEPS) do
	local r = U.label(list, "", UDim2.new(1, 0, 0, 22), nil, { textSize = 12, font = Enum.Font.Gotham }); r.LayoutOrder = i; rows[i] = r
end
local collapsed = false
local function render(d)
	if not d or not d.char then panel.Visible = false; return end
	panel.Visible = true
	local allDone, firstOpen = true, nil
	for i, st in ipairs(STEPS) do
		local ok = st.done(d)
		if not ok and not firstOpen then firstOpen = i end
		rows[i].Text = (ok and "✅ " or (firstOpen == i and "👉 " or "⬜ ")) .. T(st.key)
		rows[i].TextColor3 = ok and U.C.dim or (firstOpen == i and U.C.text or U.C.dim)
		rows[i].Visible = not collapsed or firstOpen == i
		if not ok then allDone = false end
	end
	if allDone then rows[1].Text = "🌟 " .. T("guideDone"); rows[1].Visible = true; rows[1].TextColor3 = U.C.green end
	panel.Size = collapsed and UDim2.new(0, 330, 0, 76) or UDim2.new(0, 330, 0, 250)
end
local last
Remotes.DataUpdate.OnClientEvent:Connect(function(d) last = d; render(d) end)
hideBtn.MouseButton1Click:Connect(function() collapsed = not collapsed; hideBtn.Text = collapsed and "+" or "—"; render(last) end)
player:GetAttributeChangedSignal("AtHome"):Connect(function() render(last) end)
player:GetAttributeChangedSignal("LangTick"):Connect(function() render(last) end)
task.delay(2, function() local d = Remotes.GetData:InvokeServer(); if d then last = d; render(d) end end)
