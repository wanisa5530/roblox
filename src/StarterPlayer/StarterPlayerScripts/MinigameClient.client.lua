-- มินิเกมทำอาหาร 3 แบบ: timing / mash / flip ส่งคะแนน 0-1 กลับเซิร์ฟเวอร์
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Locale = require(RS:WaitForChild("Locale"))
local Remotes = require(RS:WaitForChild("Remotes"))
local player = Players.LocalPlayer
local lang = Locale.detect(player.LocaleId)

local gui = Instance.new("ScreenGui"); gui.Name = "MinigameUI"; gui.ResetOnSpawn = false; gui.Parent = player.PlayerGui
local box = Instance.new("Frame"); box.Size = UDim2.new(0, 420, 0, 150); box.Position = UDim2.new(0.5, -210, 0.7, 0)
box.BackgroundColor3 = Color3.fromRGB(28, 24, 22); box.Visible = false; box.Parent = gui
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -20, 0, 34); title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1; title.Font = Enum.Font.FredokaOne; title.TextSize = 20; title.TextColor3 = Color3.fromRGB(255, 170, 40); title.TextWrapped = true; title.Parent = box
local hint = Instance.new("TextLabel"); hint.Size = UDim2.new(1, -20, 0, 24); hint.Position = UDim2.new(0, 10, 0, 42)
hint.BackgroundTransparency = 1; hint.Font = Enum.Font.FredokaOne; hint.TextSize = 16; hint.TextColor3 = Color3.fromRGB(230, 225, 215); hint.TextWrapped = true; hint.Parent = box
local track = Instance.new("Frame"); track.Size = UDim2.new(1, -40, 0, 26); track.Position = UDim2.new(0, 20, 0, 80); track.BackgroundColor3 = Color3.fromRGB(60, 52, 46); track.BorderSizePixel = 0; track.Parent = box
Instance.new("UICorner", track).CornerRadius = UDim.new(0, 8)
local zone = Instance.new("Frame"); zone.BackgroundColor3 = Color3.fromRGB(90, 200, 110); zone.BorderSizePixel = 0; zone.Parent = track
local fill = Instance.new("Frame"); fill.BackgroundColor3 = Color3.fromRGB(255, 170, 40); fill.BorderSizePixel = 0; fill.Size = UDim2.fromScale(0, 1); fill.Parent = track
local marker = Instance.new("Frame"); marker.Size = UDim2.new(0, 6, 1.4, 0); marker.Position = UDim2.new(0, 0, -0.2, 0); marker.BackgroundColor3 = Color3.new(1, 1, 1); marker.BorderSizePixel = 0; marker.Parent = track
local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -40, 0, 30); btn.Position = UDim2.new(0, 20, 0, 112); btn.Text = "SPACE / TAP"
btn.Font = Enum.Font.FredokaOne; btn.TextSize = 18; btn.TextColor3 = Color3.new(1, 1, 1); btn.BackgroundColor3 = Color3.fromRGB(255, 170, 40); btn.Parent = box
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local active = nil
local function pressed()
	if active then active() end
end
btn.MouseButton1Click:Connect(pressed)
UIS.InputBegan:Connect(function(input, gp)
	if gp or not box.Visible then return end
	if input.KeyCode == Enum.KeyCode.Space then pressed() end
end)

local function finish(score)
	active = nil; box.Visible = false
	Remotes.MinigameResult:FireServer(score)
end

Remotes.StartMinigame.OnClientEvent:Connect(function(kind, duration, foodId)
	title.Text = "🍳 " .. Locale.food(lang, foodId)
	box.Visible = true; fill.Size = UDim2.fromScale(0, 1); marker.Visible = false; zone.Visible = false
	local t0 = os.clock()
	if kind == "timing" then
		hint.Text = Locale.get(lang, "mgTiming")
		marker.Visible = true; zone.Visible = true
		local zc = 0.35 + math.random() * 0.4
		zone.Size = UDim2.fromScale(0.14, 1); zone.Position = UDim2.fromScale(zc - 0.07, 0)
		local pos, conn = 0, nil
		conn = RunService.RenderStepped:Connect(function()
			local t = (os.clock() - t0) / duration
			pos = (math.sin(t * math.pi * 3) + 1) / 2 -- แกว่งไปมา
			marker.Position = UDim2.new(pos, -3, -0.2, 0)
			if t > 2.5 then conn:Disconnect(); if active then finish(0) end end -- ช้าเกิน = ไหม้
		end)
		active = function()
			conn:Disconnect()
			local dist = math.abs(pos - zc)
			finish(dist < 0.07 and 1 or (dist < 0.15 and 0.6 or (dist < 0.25 and 0.3 or 0)))
		end
	elseif kind == "mash" then
		hint.Text = Locale.get(lang, "mgMash")
		local need, count = math.floor(duration * 6), 0
		active = function()
			count += 1; fill.Size = UDim2.fromScale(math.min(count / need, 1), 1)
			if count >= need then
				local el = os.clock() - t0
				finish(el < duration and 1 or (el < duration * 1.6 and 0.6 or 0.3))
			end
		end
		task.delay(duration * 2.5, function() if active then finish(count / need * 0.3) end end)
	else -- flip
		hint.Text = Locale.get(lang, "mgFlip")
		zone.Visible = true; zone.Size = UDim2.fromScale(0.2, 1); zone.Position = UDim2.fromScale(0.7, 0)
		local prog, conn = 0, nil
		conn = RunService.RenderStepped:Connect(function()
			prog = (os.clock() - t0) / duration
			fill.Size = UDim2.fromScale(math.min(prog, 1), 1)
			fill.BackgroundColor3 = prog > 0.9 and Color3.fromRGB(220, 80, 70) or Color3.fromRGB(255, 170, 40)
			if prog >= 1 then conn:Disconnect(); if active then finish(0) end end
		end)
		active = function()
			conn:Disconnect()
			finish(prog >= 0.7 and 1 or (prog >= 0.55 and 0.6 or (prog >= 0.4 and 0.3 or 0)))
		end
	end
end)
