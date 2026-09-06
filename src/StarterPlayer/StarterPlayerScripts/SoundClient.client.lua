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
