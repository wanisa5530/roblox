-- ตกแต่งตลาดโต้รุ่ง: กลางคืน ไฟราวตามถนน ตุ๊กตุ๊กวิ่งวน
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
Lighting.ClockTime = 19.5; Lighting.Brightness = 1; Lighting.Ambient = Color3.fromRGB(70, 60, 80)
Lighting.OutdoorAmbient = Color3.fromRGB(80, 70, 90); Lighting.FogEnd = 600
local deco = Instance.new("Folder"); deco.Name = "Decor"; deco.Parent = workspace
local function part(props)
	local x = Instance.new("Part"); x.Anchored = true
	for k, v in pairs(props) do x[k] = v end
	x.Parent = deco; return x
end
-- เสาไฟ + ไฟราวสีเหลืองสองฝั่งถนน
for x = -140, 140, 20 do
	for _, z in ipairs({ -18, 2 }) do
		part({ Size = Vector3.new(0.4, 12, 0.4), Position = Vector3.new(x, 6, z), Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Metal })
		part({ Size = Vector3.new(20, 0.08, 0.08), Position = Vector3.new(x + 10, 11.5, z), Color = Color3.fromRGB(30, 30, 30) })
		for k = 0, 3 do
			local b = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7), Position = Vector3.new(x + 2.5 + k * 5, 11, z), Color = Color3.fromRGB(255, 200, 90), Material = Enum.Material.Neon })
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 200, 120); l.Range = 16; l.Brightness = 1; l.Parent = b
		end
	end
end
-- ตุ๊กตุ๊กวิ่งวนบนถนน
local tuk = Instance.new("Model"); tuk.Name = "TukTuk"; tuk.Parent = deco
local body = part({ Size = Vector3.new(5, 3, 3), Position = Vector3.new(-200, 2.2, -12), Color = Color3.fromRGB(30, 100, 200), Material = Enum.Material.Metal }); body.Parent = tuk
local roof = part({ Size = Vector3.new(5.4, 0.3, 3.4), Position = Vector3.new(-200, 4, -12), Color = Color3.fromRGB(240, 200, 40) }); roof.Parent = tuk
local nose = part({ Size = Vector3.new(2, 1.6, 2), Position = Vector3.new(-203.3, 1.5, -12), Color = Color3.fromRGB(30, 100, 200), Material = Enum.Material.Metal }); nose.Parent = tuk
tuk.PrimaryPart = body
for _, p in ipairs({ roof, nose }) do
	local w = Instance.new("WeldConstraint"); w.Part0 = body; w.Part1 = p; w.Parent = p; p.Anchored = false
end
task.spawn(function()
	while true do
		tuk:PivotTo(CFrame.new(-220, 2.2, -12) * CFrame.Angles(0, math.rad(180), 0))
		local tw = TweenService:Create(body, TweenInfo.new(22, Enum.EasingStyle.Linear), { CFrame = CFrame.new(220, 2.2, -12) * CFrame.Angles(0, math.rad(180), 0) })
		tw:Play(); tw.Completed:Wait()
		task.wait(6)
	end
end)
