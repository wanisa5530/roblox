-- หน้าโหลดของเกม (แทนหน้าโหลดมาตรฐาน): โลโก้ + แถบความคืบหน้า + เคล็ดลับ
local RF = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local player = Players.LocalPlayer
local th = string.sub(tostring(player.LocaleId or "en"), 1, 2) == "th"
RF:RemoveDefaultLoadingScreen()
local gui = Instance.new("ScreenGui"); gui.Name = "LifeLoading"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 1000; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")
local bg = Instance.new("Frame"); bg.Size = UDim2.fromScale(1, 1); bg.BackgroundColor3 = Color3.fromRGB(238, 240, 247); bg.BorderSizePixel = 0; bg.Parent = gui
local function txt(t, size, y, color, font)
	local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 0, size + 10); l.Position = UDim2.new(0, 0, 0.5, y); l.BackgroundTransparency = 1; l.Text = t; l.TextSize = size; l.Font = font or Enum.Font.GothamBold; l.TextColor3 = color; l.Parent = bg; return l
end
local logo = txt("Life Story", 84, -150, Color3.fromRGB(60, 150, 235), Enum.Font.FredokaOne)
local st = Instance.new("UIStroke"); st.Thickness = 5; st.Color = Color3.fromRGB(255, 255, 255); st.Parent = logo
local grad = Instance.new("UIGradient"); grad.Rotation = 90; grad.Color = ColorSequence.new(Color3.fromRGB(120, 200, 255), Color3.fromRGB(40, 110, 220)); grad.Parent = logo
txt("🏠✨", 40, -215, Color3.fromRGB(255, 200, 60))
txt(th and "กำลังโหลดประสบการณ์ของคุณ" or "Loading your experience", 18, -40, Color3.fromRGB(120, 125, 140), Enum.Font.Gotham)
local track = Instance.new("Frame"); track.Size = UDim2.new(0, 360, 0, 8); track.Position = UDim2.new(0.5, -180, 0.5, 0); track.BackgroundColor3 = Color3.fromRGB(215, 220, 232); track.BorderSizePixel = 0; track.Parent = bg
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(80, 190, 240); fill.BorderSizePixel = 0; fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
local pct = txt("0%", 14, 16, Color3.fromRGB(80, 190, 240))
local tips = th and { "เคล็ดลับ: กด E ที่เตียงเพื่อนอน เติมพลังงาน", "เคล็ดลับ: ดูเวลาทำงานของอาชีพที่นาฬิกามุมขวาล่าง", "เคล็ดลับ: คุยกับคนในสวนเพื่อสร้างเพื่อนและครอบครัว", "เคล็ดลับ: ซื้อประกันสุขภาพ ลดค่ารักษาครึ่งหนึ่ง" }
	or { "Tip: press E at a bed to sleep and restore energy", "Tip: check your job's hours on the clock, bottom right", "Tip: talk to people in the park to make friends", "Tip: health insurance halves treatment costs" }
local tip = txt(tips[math.random(#tips)], 13, 0, Color3.fromRGB(150, 155, 170), Enum.Font.Gotham); tip.Position = UDim2.new(0, 0, 1, -40)
local p = 0
local function setP(v) p = math.max(p, v); TS:Create(fill, TweenInfo.new(0.4), { Size = UDim2.new(p, 0, 1, 0) }):Play(); pct.Text = math.floor(p * 100) .. "%" end
task.spawn(function() for i = 1, 6 do task.wait(0.35); setP(i * 0.1) end end)
if not game:IsLoaded() then game.Loaded:Wait() end
setP(0.75)
-- รอให้หน้าไตเติลพร้อม (สูงสุด 15 วิ)
local pg = player:WaitForChild("PlayerGui")
local t0 = os.clock(); while not pg:FindFirstChild("LifeTitle") and os.clock() - t0 < 15 do task.wait(0.2) end
setP(1); task.wait(0.5)
TS:Create(bg, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
for _, d in ipairs(bg:GetDescendants()) do if d:IsA("TextLabel") then TS:Create(d, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play() elseif d:IsA("Frame") then TS:Create(d, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play() elseif d:IsA("UIStroke") then TS:Create(d, TweenInfo.new(0.5), { Transparency = 1 }):Play() end end
task.wait(0.7); gui:Destroy()
