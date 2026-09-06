-- วาดลูกโป่งคำสั่งของลูกค้าตามภาษาของผู้เล่นแต่ละคน + แปลข้อความปุ่ม E
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS:WaitForChild("Config"))
local Locale = require(RS:WaitForChild("Locale"))
local player = Players.LocalPlayer
local function lang() return player:GetAttribute("Lang") or Locale.detect(player.LocaleId) end
local function foodOf(id) for _, f in ipairs(Config.Foods) do if f.id == id then return f end end end

local function attach(npc)
	local head = npc:WaitForChild("Head", 5) or npc.PrimaryPart
	if not head then return end
	local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 170, 0, 72); bg.StudsOffset = Vector3.new(0, 3, 0); bg.AlwaysOnTop = true; bg.Enabled = false; bg.Parent = head
	local f = Instance.new("Frame"); f.Size = UDim2.fromScale(1, 1); f.BackgroundColor3 = Color3.fromRGB(255, 250, 235); f.Parent = bg
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
	local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -10, 0, 44); t.Position = UDim2.new(0, 5, 0, 2); t.BackgroundTransparency = 1
	t.TextScaled = true; t.Font = Enum.Font.FredokaOne; t.TextColor3 = Color3.fromRGB(40, 30, 20); t.Parent = f
	local barBg = Instance.new("Frame"); barBg.Size = UDim2.new(1, -16, 0, 10); barBg.Position = UDim2.new(0, 8, 1, -16); barBg.BackgroundColor3 = Color3.fromRGB(220, 215, 200); barBg.BorderSizePixel = 0; barBg.Parent = f
	local bar = Instance.new("Frame"); bar.Size = UDim2.fromScale(1, 1); bar.BackgroundColor3 = Color3.fromRGB(90, 200, 110); bar.BorderSizePixel = 0; bar.Parent = barBg
	local function render()
		local id, mood = npc:GetAttribute("OrderFood"), npc:GetAttribute("Mood")
		bg.Enabled = id ~= nil or mood ~= nil
		if mood then t.Text = mood; barBg.Visible = false; return end
		local food = id and foodOf(id)
		if food then t.Text = food.emoji .. " " .. Locale.food(lang(), id) end
		local left = npc:GetAttribute("Patience") or 1
		bar.Size = UDim2.fromScale(left, 1)
		bar.BackgroundColor3 = left > 0.5 and Color3.fromRGB(90, 200, 110) or (left > 0.25 and Color3.fromRGB(240, 190, 60) or Color3.fromRGB(220, 80, 70))
	end
	npc.AttributeChanged:Connect(render); player:GetAttributeChangedSignal("Lang"):Connect(render); render()
end
local folder = workspace:WaitForChild("Customers")
for _, n in ipairs(folder:GetChildren()) do task.spawn(attach, n) end
folder.ChildAdded:Connect(function(n) task.spawn(attach, n) end)

-- แปล ProximityPrompt (Cook / Serve)
local function localizePrompt(pp)
	local function apply()
		local L = lang()
		if pp.ActionText == "Cook" or pp:GetAttribute("FoodId") then
			pp.ActionText = Locale.get(L, "cook"); pp.ObjectText = Locale.food(L, pp:GetAttribute("FoodId"))
		elseif pp.ActionText == "Serve" or pp:GetAttribute("IsCustomer") then
			pp:SetAttribute("IsCustomer", true); pp.ActionText = Locale.get(L, "serve")
		end
	end
	apply(); player:GetAttributeChangedSignal("Lang"):Connect(apply)
end
for _, pp in ipairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then localizePrompt(pp) end end
workspace.DescendantAdded:Connect(function(pp) if pp:IsA("ProximityPrompt") then task.defer(localizePrompt, pp) end end)
