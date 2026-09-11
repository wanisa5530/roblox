-- เมนูปฏิสัมพันธ์เมื่อคุยกับ NPC/ผู้เล่น
local Players = game:GetService("Players")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local gui = Instance.new("ScreenGui"); gui.Name = "LifeSocial"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")
local win = U.frame(gui, UDim2.new(0, 300, 0, 400), UDim2.new(1, -320, 0.5, -200), U.C.bg, 12); win.Visible = false
local head = U.label(win, "", UDim2.new(1, -50, 0, 30), UDim2.new(0, 10, 0, 6), { textSize = 16, color = U.C.accent })
local sub = U.label(win, "", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 34), { textSize = 12, color = U.C.dim })
U.button(win, "✕", UDim2.new(0, 30, 0, 30), UDim2.new(1, -36, 0, 6), U.C.red, function() win.Visible = false end)
local list = U.scroll(win, UDim2.new(1, -16, 1, -66), UDim2.new(0, 8, 0, 58))
local target
Remotes.Social.OnClientEvent:Connect(function(kind, id, a, b, rel)
	local status, displayName = a, b
	if kind == "result" then status, displayName = b, a end
	if kind == "open" then
		target = id; win.Visible = true
		head.Text = "🧑 " .. (displayName or id); sub.Text = T(status)
		for _, x in ipairs(list:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
		for i, ic in ipairs(Config.Interactions) do
			local btn = U.button(list, T(ic.key), UDim2.new(1, 0, 0, 32), nil, ic.romance > 0 and Color3.fromRGB(200, 80, 130) or (ic.friend < 0 and U.C.red or U.C.card), function() Remotes.Social:FireServer("interact", target, ic.key) end)
			btn.LayoutOrder = i
		end
	elseif kind == "result" then
		if id == target then sub.Text = T(status) .. (rel and ("  ❤ " .. math.floor(rel.f) .. " / 💕 " .. math.floor(rel.r)) or "") .. (displayName == false and "  ✗" or "  ✓") end
	end
end)
