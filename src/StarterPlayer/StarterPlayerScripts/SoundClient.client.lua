-- เล่นเสียงตามเหตุการณ์ในเกม
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")
local Sounds = require(RS:WaitForChild("Sounds"))
local Remotes = require(RS:WaitForChild("Remotes"))
local player = Players.LocalPlayer

local S = {}
for name, cfg in pairs(Sounds) do
	if cfg.id ~= "" then
		local snd = Instance.new("Sound"); snd.Name = name; snd.SoundId = cfg.id; snd.Volume = cfg.volume or 0.5; snd.Looped = cfg.loop or false
		snd.Parent = SoundService; S[name] = snd
	end
end
local function play(name) local snd = S[name]; if snd then if snd.Looped then snd:Play() else snd:Stop(); snd:Play() end end end
local function stop(name) local snd = S[name]; if snd then snd:Stop() end end
if S.music then S.music:Play() end

-- แจ้งเตือนจากเซิร์ฟเวอร์
local map = { tip = "cash", perfect = "perfect", good = "cash", ok = "cash", burnt = "fail", wrongDish = "fail", wrongSpice = "fail",
	left = "fail", needBag = "fail", noDish = "fail", handsFull = "fail", notEnough = "fail", staffQuit = "fail" }
Remotes.Notify.OnClientEvent:Connect(function(key)
	if map[key] then play(map[key]) end
	if key == "tip" or key == "perfect" or key == "good" or key == "ok" or key == "burnt" then stop("cook") end
end)
Remotes.StartMinigame.OnClientEvent:Connect(function() play("cook") end)

-- ลูกค้าสั่ง (attribute OrderFood ถูกตั้งบน NPC ในร้านเรา)
local folder = workspace:WaitForChild("Customers")
local function watch(npc)
	npc:GetAttributeChangedSignal("OrderFood"):Connect(function() if npc:GetAttribute("OrderFood") then play("order") end end)
end
for _, n in ipairs(folder:GetChildren()) do watch(n) end
folder.ChildAdded:Connect(watch)

-- ถือของเปลี่ยน = เสิร์ฟ/หยิบ/ล้าง
player:GetAttributeChangedSignal("Holding"):Connect(function()
	local h = player:GetAttribute("Holding")
	if h == nil then play("serve") elseif h == "Dirty" then play("wash") else play("serve") end
end)

-- คลิกในมินิเกมและเปิดเมนู
local gui = player:WaitForChild("PlayerGui")
local function hook(name, snd)
	local sg = gui:WaitForChild(name, 10); if not sg then return end
	for _, b in ipairs(sg:GetDescendants()) do if b:IsA("TextButton") then b.MouseButton1Click:Connect(function() play(snd) end) end end
	sg.DescendantAdded:Connect(function(b) if b:IsA("TextButton") then b.MouseButton1Click:Connect(function() play(snd) end) end end)
end
hook("MinigameUI", "click"); hook("TycoonUI", "ui")

-- ฝนตก: อนุภาคฝนติดตามผู้เล่น
player:GetAttributeChangedSignal("Event"):Connect(function()
	local char = player.Character; if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local old = root:FindFirstChild("RainFX"); if old then old:Destroy() end
	if player:GetAttribute("Event") == "Rain" then
		local a = Instance.new("Attachment"); a.Name = "RainFX"; a.Position = Vector3.new(0, 30, 0); a.Parent = root
		local pe = Instance.new("ParticleEmitter"); pe.Rate = 400; pe.Lifetime = NumberRange.new(1.2); pe.Speed = NumberRange.new(40)
		pe.Size = NumberSequence.new(0.15); pe.Transparency = NumberSequence.new(0.4); pe.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
		pe.EmissionDirection = Enum.NormalId.Bottom; pe.SpreadAngle = Vector2.new(60, 60); pe.Parent = a
	end
end)
