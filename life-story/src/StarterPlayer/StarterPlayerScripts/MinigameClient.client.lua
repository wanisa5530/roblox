-- มินิเกมตอนทำงาน/เรียน: timing / mash / memory → ส่งคุณภาพ 0..1 กลับ
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game.ReplicatedStorage
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local gui = Instance.new("ScreenGui"); gui.Name = "LifeMinigame"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui"); U.scaleGui(gui)
local win = U.frame(gui, UDim2.new(0, 440, 0, 220), UDim2.new(0.5, -220, 0.5, -110), U.C.bg, 14); win.Visible = false
local title = U.label(win, "", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 8), { textSize = 18, color = U.C.accent, align = Enum.TextXAlignment.Center })
local hint = U.label(win, "", UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, 40), { textSize = 13, color = U.C.dim, align = Enum.TextXAlignment.Center })
local area = Instance.new("Frame"); area.Size = UDim2.new(1, -40, 0, 120); area.Position = UDim2.new(0, 20, 0, 80); area.BackgroundTransparency = 1; area.Parent = win
local running = false
local function finish(q)
	running = false; win.Visible = false
	for _, x in ipairs(area:GetChildren()) do x:Destroy() end
	Remotes.MinigameResult:FireServer(q)
end
local function timing(diff)
	hint.Text = T("mgTiming") ~= "mgTiming" and T("mgTiming") or "Press SPACE / tap in the green zone!"
	local bar = U.frame(area, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 40), Color3.fromRGB(60, 60, 70), 6)
	local zoneW = 0.15 + 0.15 * diff; local zoneX = math.random() * (1 - zoneW)
	U.frame(bar, UDim2.new(zoneW, 0, 1, 0), UDim2.new(zoneX, 0, 0, 0), U.C.green, 6)
	local needle = U.frame(bar, UDim2.new(0, 6, 1.4, 0), UDim2.new(0, 0, -0.2, 0), U.C.accent, 3)
	local t0 = os.clock(); local speed = 1.2 + (1 - diff)
	local conn
	local function press()
		if not running then return end
		local x = needle.Position.X.Scale
		local center = zoneX + zoneW / 2
		local q = math.clamp(1 - math.abs(x - center) / (zoneW / 2 + 0.05), 0, 1)
		conn:Disconnect(); finish(q)
	end
	conn = UIS.InputBegan:Connect(function(i, gp) if gp then return end; if i.KeyCode == Enum.KeyCode.Space or i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then press() end end)
	task.spawn(function()
		while running do
			local a = ((os.clock() - t0) * speed) % 2; if a > 1 then a = 2 - a end
			needle.Position = UDim2.new(a, 0, -0.2, 0)
			task.wait()
		end
	end)
	task.delay(8, function() if running and conn.Connected then conn:Disconnect(); finish(0.2) end end)
end
local function mash(diff)
	hint.Text = "Click fast!"
	local count, goal = 0, math.floor(12 + 10 * diff)
	local b = U.button(area, "0 / " .. goal, UDim2.new(0, 160, 0, 60), UDim2.new(0.5, -80, 0, 25), U.C.green, nil)
	b.MouseButton1Click:Connect(function() if not running then return end; count += 1; b.Text = count .. " / " .. goal; if count >= goal then finish(1) end end)
	task.delay(5, function() if running then finish(math.clamp(count / goal, 0, 0.9)) end end)
end
local function memory(diff)
	hint.Text = "Remember the order, then repeat it"
	local n = 3 + math.floor(diff * 3)
	local seq = {}; for i = 1, n do seq[i] = math.random(4) end
	local btns = {}
	local colors = { Color3.fromRGB(230, 80, 80), Color3.fromRGB(80, 200, 110), Color3.fromRGB(80, 150, 240), Color3.fromRGB(250, 200, 60) }
	local input, showing = {}, true
	for i = 1, 4 do
		local b = U.button(area, "", UDim2.new(0, 80, 0, 80), UDim2.new(0, (i - 1) * 95, 0, 15), colors[i], nil); b.BackgroundTransparency = 0.6; btns[i] = b
		b.MouseButton1Click:Connect(function()
			if showing or not running then return end
			input[#input + 1] = i
			if input[#input] ~= seq[#input] then finish(math.clamp((#input - 1) / n, 0, 0.6)); return end
			if #input == n then finish(1) end
		end)
	end
	task.spawn(function()
		task.wait(0.5)
		for _, k in ipairs(seq) do if not running then return end; btns[k].BackgroundTransparency = 0; task.wait(0.45); btns[k].BackgroundTransparency = 0.6; task.wait(0.2) end
		showing = false; hint.Text = "Your turn!"
	end)
	task.delay(15, function() if running then finish(0.3) end end)
end
Remotes.StartMinigame.OnClientEvent:Connect(function(kind, diff, round, total)
	for _, x in ipairs(area:GetChildren()) do x:Destroy() end
	win.Visible = true; running = true
	title.Text = string.format("%s %d/%d", T("performance"), round, total)
	if kind == "timing" then timing(diff) elseif kind == "mash" then mash(diff) else memory(diff) end
end)
