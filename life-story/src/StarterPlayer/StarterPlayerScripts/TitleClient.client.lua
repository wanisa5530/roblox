-- หน้าไตเติล: กล้องหมุนรอบสวน + โลโก้ + ข้อความเบต้า + ปุ่มเล่น (ซ่อน HUD จนกว่าจะกดเล่น)
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local pg = player:WaitForChild("PlayerGui")
local playing = false
local function applyVis(g) if g:IsA("ScreenGui") and g.Name:sub(1, 4) == "Life" and g.Name ~= "LifeTitle" and g.Name ~= "LifeLoading" then g.Enabled = playing end end
for _, g in ipairs(pg:GetChildren()) do applyVis(g) end
local conn = pg.ChildAdded:Connect(function(g) task.defer(applyVis, g) end)
local gui = Instance.new("ScreenGui"); gui.Name = "LifeTitle"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 500; gui.ResetOnSpawn = false; gui.Parent = pg; U.scaleGui(gui)
local logo = Instance.new("TextLabel"); logo.Size = UDim2.new(1, 0, 0, 100); logo.Position = UDim2.new(0, 0, 0, 40); logo.BackgroundTransparency = 1; logo.Text = "Life Story"; logo.TextSize = 86; logo.Font = Enum.Font.FredokaOne; logo.TextColor3 = Color3.fromRGB(90, 180, 255); logo.Parent = gui
local st = Instance.new("UIStroke"); st.Thickness = 5; st.Color = Color3.fromRGB(255, 255, 255); st.Parent = logo
local grad = Instance.new("UIGradient"); grad.Rotation = 90; grad.Color = ColorSequence.new(Color3.fromRGB(150, 215, 255), Color3.fromRGB(40, 120, 230)); grad.Parent = logo
local sub = Instance.new("TextLabel"); sub.Size = UDim2.new(1, 0, 0, 30); sub.Position = UDim2.new(0, 0, 0, 132); sub.BackgroundTransparency = 1; sub.Text = "🏠 " .. T("tagline"); sub.TextSize = 20; sub.Font = Enum.Font.GothamBold; sub.TextColor3 = Color3.fromRGB(255, 255, 255); sub.TextStrokeTransparency = 0.4; sub.Parent = gui
local beta = Instance.new("TextLabel"); beta.Size = UDim2.new(1, 0, 0, 60); beta.Position = UDim2.new(0, 0, 0, 200); beta.BackgroundTransparency = 1; beta.Text = T("betaNote"); beta.TextSize = 18; beta.Font = Enum.Font.GothamBold; beta.TextColor3 = Color3.fromRGB(255, 255, 255); beta.TextStrokeTransparency = 0.3; beta.TextWrapped = true; beta.Parent = gui
local play = Instance.new("TextButton"); play.Size = UDim2.new(0, 380, 0, 84); play.Position = UDim2.new(0.5, -190, 1, -130); play.BackgroundColor3 = Color3.fromRGB(60, 190, 80); play.Text = T("playBtn"); play.TextSize = 40; play.Font = Enum.Font.GothamBold; play.TextColor3 = Color3.fromRGB(255, 255, 255); play.AutoButtonColor = true; play.Parent = gui
Instance.new("UICorner", play).CornerRadius = UDim.new(0, 18)
local ps = Instance.new("UIStroke"); ps.Thickness = 3; ps.Color = Color3.fromRGB(40, 140, 60); ps.Parent = play
-- กล้องหมุนรอบน้ำพุในสวน (ถ้ายังไม่มีสวน ใช้ตำแหน่งกลางเมือง)
local cam = workspace.CurrentCamera
local center = Vector3.new(245, 4, 80)
task.spawn(function()
	local city = workspace:WaitForChild("City", 10); local park = city and city:WaitForChild("Park", 10)
	local pond = park and park:FindFirstChild("Pond"); if pond then center = pond.Position + Vector3.new(0, 3, 0) end
end)
cam.CameraType = Enum.CameraType.Scriptable
local t0 = os.clock()
local orbit = RunService.RenderStepped:Connect(function()
	local a = (os.clock() - t0) * 0.12
	cam.CFrame = CFrame.lookAt(center + Vector3.new(math.cos(a) * 52, 14, math.sin(a) * 52), center)
end)
local function startGame()
	if playing then return end
	playing = true; orbit:Disconnect(); conn:Disconnect()
	cam.CameraType = Enum.CameraType.Custom
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then cam.CameraSubject = hum end
	for _, g in ipairs(pg:GetChildren()) do applyVis(g) end
	player:SetAttribute("Playing", true)
	TS:Create(play, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
	task.wait(0.3); gui:Destroy()
end
play.MouseButton1Click:Connect(startGame)
-- กันค้าง: ถ้ากล้องไม่มีอะไรให้ดูภายใน 40 วิ ก็ยังกดเล่นได้ตามปกติ (ไม่บังคับ)
