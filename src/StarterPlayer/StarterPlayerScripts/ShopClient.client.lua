-- UI ฝั่งผู้เล่น: แสดงเงิน ปุ่มเก็บเงิน ซื้อเมนู และปุ่มซื้อ Robux
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS:WaitForChild("Config"))
local Remotes = require(RS:WaitForChild("Remotes"))

local gui = Instance.new("ScreenGui"); gui.Name = "TycoonUI"; gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function btn(text, y, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 200, 0, 28); b.Position = UDim2.new(1, -210, 0, y)
	b.Text = text; b.TextScaled = true; b.Parent = gui
	b.MouseButton1Click:Connect(cb)
	return b
end

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(0, 200, 0, 36); cashLabel.Position = UDim2.new(1, -210, 0, 10)
cashLabel.BackgroundColor3 = Color3.fromRGB(255, 220, 80); cashLabel.Text = "เงิน: ..."
cashLabel.TextScaled = true; cashLabel.Parent = gui

local collect = btn("เก็บเงิน (0)", 60, function() Remotes.Collect:InvokeServer() end)

local y = 110
local foodButtons = {}
for _, f in ipairs(Config.Foods) do
	foodButtons[f.id] = btn(f.name .. " - " .. f.cost, y, function()
		local ok, err = Remotes.BuyFood:InvokeServer(f.id)
		if not ok and err then warn(err) end
	end)
	y += 32
end

y += 10
for key, p in pairs(Config.GamePasses) do
	btn("[Pass] " .. p.name, y, function() Remotes.PromptPass:FireServer("pass", key) end); y += 32
end
for key, p in pairs(Config.DevProducts) do
	btn("[Robux] +" .. p.cash .. " เงิน", y, function() Remotes.PromptPass:FireServer("product", key) end); y += 32
end

local function render(d)
	cashLabel.Text = "เงิน: " .. d.cash
	collect.Text = "เก็บเงิน (" .. d.pending .. ")"
	for id, b in pairs(foodButtons) do
		if d.foods[id] then b.Text = b.Text:gsub(" %- %d+$", "") .. " ✓"; b.Active = false end
	end
end

Remotes.DataUpdate.OnClientEvent:Connect(render)
local ok, d = pcall(function() return Remotes.GetData:InvokeServer() end)
if ok and d then render(d) else cashLabel.Text = "ERR: " .. tostring(d) end
