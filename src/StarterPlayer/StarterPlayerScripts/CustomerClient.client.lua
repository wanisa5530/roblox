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
		local spKey = npc:GetAttribute("Special"); local spTag = spKey and (Config.Specials[spKey].emoji .. " ") or ""
		if id then
			local lines = {}
			for item in string.gmatch(id, "[^|]+") do
				local fid, sp = item:match("^(%w+):?(%d*)$")
				local food = fid and foodOf(fid)
				if food then lines[#lines + 1] = food.emoji .. " " .. Locale.food(lang(), fid) .. (sp ~= "" and (" " .. Config.SpiceLevels[tonumber(sp)]) or "") end
			end
			t.Text = spTag .. (npc:GetAttribute("Takeaway") and "🥡 " or "") .. table.concat(lines, "\n")
			bg.Size = UDim2.new(0, 190, 0, 50 + #lines * 24); t.Size = UDim2.new(1, -10, 0, #lines * 24 + 4); t.TextScaled = false; t.TextSize = 20
		end
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
		local kind = pp:GetAttribute("Kind")
		if kind == "cook" then pp.ActionText = Locale.get(L, "cook"); pp.ObjectText = Locale.food(L, pp:GetAttribute("FoodId"))
		elseif kind == "serve" then pp.ActionText = Locale.get(L, "serve")
		elseif kind == "pack" then pp.ActionText = Locale.get(L, "pack"); pp.ObjectText = Locale.get(L, "takeaway")
		elseif kind == "clean" then pp.ActionText = Locale.get(L, "clean"); pp.ObjectText = ""
		elseif kind == "wash" then pp.ActionText = Locale.get(L, "wash"); pp.ObjectText = ""
		elseif kind == "pickup" then pp.ActionText = Locale.get(L, "pickup")
		elseif kind == "umbrella" then pp.ActionText = Locale.get(L, "umbrella")
		elseif kind == "gas" then pp.ActionText = Locale.get(L, "gas")
		elseif kind == "kitchen" then pp.ActionText = Locale.get(L, "cook"); pp.ObjectText = Locale.get(L, "kitchen") end
	end
	local function gate()
		local kind = pp:GetAttribute("Kind"); local ev = player:GetAttribute("Event")
		if kind == "umbrella" then pp.Enabled = ev == "Rain" and not player:GetAttribute("EventFixed")
		elseif kind == "gas" then pp.Enabled = ev == "GasOut" and not player:GetAttribute("EventFixed") end
	end
	apply(); gate(); player:GetAttributeChangedSignal("Lang"):Connect(apply)
	player:GetAttributeChangedSignal("Event"):Connect(gate); player:GetAttributeChangedSignal("EventFixed"):Connect(gate)
end
for _, pp in ipairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then localizePrompt(pp) end end
workspace.DescendantAdded:Connect(function(pp) if pp:IsA("ProximityPrompt") then task.defer(localizePrompt, pp) end end)

-- ป้ายเหนือโต๊ะ: กี่คน สั่งอะไรบ้าง
local function attachTable(tbl)
	local top = tbl:FindFirstChildWhichIsA("Part"); if not top then return end
	local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 200, 0, 90); bg.StudsOffset = Vector3.new(0, 9, 0); bg.AlwaysOnTop = true; bg.Enabled = false; bg.Parent = top
	local f = Instance.new("Frame"); f.Size = UDim2.fromScale(1, 1); f.BackgroundColor3 = Color3.fromRGB(28, 24, 22); f.BackgroundTransparency = 0.15; f.Parent = bg
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -12, 1, -8); t.Position = UDim2.new(0, 6, 0, 4); t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne; t.TextSize = 16; t.TextColor3 = Color3.fromRGB(255, 240, 210); t.TextWrapped = true; t.TextYAlignment = Enum.TextYAlignment.Top; t.Parent = f
	local function render()
		local orders = tbl:GetAttribute("Orders")
		bg.Enabled = orders ~= nil
		if not orders then return end
		local L = lang(); local counts, order = {}, {}
		for item in string.gmatch(orders, "[^,]+") do
			if not counts[item] then counts[item] = 0; order[#order + 1] = item end
			counts[item] += 1
		end
		local n = tbl:GetAttribute("Guests") or #order
		local lines = { "👥 " .. string.format(Locale.get(L, "people"), n) }
		for _, item in ipairs(order) do
			local id, sp = item:match("^(%w+):?(%d*)$")
			local food = foodOf(id)
			lines[#lines + 1] = (food and food.emoji or "") .. " " .. Locale.food(L, id) .. (sp ~= "" and (" " .. Config.SpiceLevels[tonumber(sp)]) or "") .. (counts[item] > 1 and (" x" .. counts[item]) or "")
		end
		t.Text = table.concat(lines, "\n")
	end
	tbl:GetAttributeChangedSignal("Orders"):Connect(render); player:GetAttributeChangedSignal("Lang"):Connect(render); render()
end
local plots = workspace:WaitForChild("Plots")
local function scanPlot(plot)
	for _, c in ipairs(plot:GetChildren()) do if c.Name:match("^Table%d") then attachTable(c) end end
	plot.ChildAdded:Connect(function(c) if c.Name:match("^Table%d") then task.defer(attachTable, c) end end)
end
for _, p in ipairs(plots:GetChildren()) do scanPlot(p) end
plots.ChildAdded:Connect(scanPlot)

-- แบนเนอร์เหตุการณ์
local banner = Instance.new("TextLabel"); banner.Size = UDim2.new(0, 520, 0, 34); banner.Position = UDim2.new(0.5, -260, 0, 84)
banner.BackgroundColor3 = Color3.fromRGB(200, 60, 50); banner.TextColor3 = Color3.new(1, 1, 1); banner.Font = Enum.Font.FredokaOne; banner.TextSize = 18
banner.Visible = false; banner.Parent = player:WaitForChild("PlayerGui"):WaitForChild("TycoonUI")
Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	local ev = player:GetAttribute("Event")
	banner.Visible = ev ~= nil
	if ev then
		local left = math.max((player:GetAttribute("EventEnd") or 0) - os.time(), 0)
		local icon = ev == "Rain" and "🌧️" or (ev == "GasOut" and "⛽" or "🔥")
		banner.Text = icon .. " " .. Locale.get(lang(), ev) .. (player:GetAttribute("EventFixed") and " ✅" or "") .. "  " .. left .. "s"
		banner.BackgroundColor3 = ev == "Rush" and Color3.fromRGB(230, 130, 30) or (player:GetAttribute("EventFixed") and Color3.fromRGB(60, 150, 90) or Color3.fromRGB(200, 60, 50))
	end
end)
