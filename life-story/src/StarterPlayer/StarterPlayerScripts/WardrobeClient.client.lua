-- ระบบแต่งตัว: ค้นหาไอเท็มจาก Roblox catalog (ผม/หมวก/เสื้อ/กางเกง/หน้า/แว่น) + สีผิว แล้วส่งให้เซิร์ฟเวอร์ใส่ให้
local Players = game:GetService("Players")
local AES = game:GetService("AvatarEditorService")
local RS = game.ReplicatedStorage
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local gui = Instance.new("ScreenGui"); gui.Name = "LifeWardrobe"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui"); U.scaleGui(gui)
local win = U.frame(gui, UDim2.new(0, 560, 0, 520), UDim2.new(0, 16, 0.5, -300), U.C.bg, 16, U.C.teal); win.Visible = false
U.label(win, "👗 " .. T("wardrobe"), UDim2.new(0.6, 0, 0, 30), UDim2.new(0, 14, 0, 8), { textSize = 20, color = U.C.accent })
local closeB = U.button(win, "✕", UDim2.new(0, 34, 0, 34), UDim2.new(1, -44, 0, 8), U.C.red, function() win.Visible = false end)
local CATS = {
	{ key = "hair", label = "wHair", types = { Enum.AvatarAssetType.HairAccessory } },
	{ key = "hat", label = "wHat", types = { Enum.AvatarAssetType.Hat } },
	{ key = "shirt", label = "wShirt", types = { Enum.AvatarAssetType.Shirt } },
	{ key = "pants", label = "wPants", types = { Enum.AvatarAssetType.Pants } },
	{ key = "face", label = "wFace", types = { Enum.AvatarAssetType.Face } },
	{ key = "glasses", label = "wGlasses", types = { Enum.AvatarAssetType.FaceAccessory } },
	{ key = "skin", label = "wSkin" },
}
local tabs = Instance.new("Frame"); tabs.Size = UDim2.new(1, -20, 0, 36); tabs.Position = UDim2.new(0, 10, 0, 46); tabs.BackgroundTransparency = 1; tabs.Parent = win
local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 6); tl.Parent = tabs
local search = Instance.new("TextBox"); search.Size = UDim2.new(1, -140, 0, 34); search.Position = UDim2.new(0, 10, 0, 88); search.PlaceholderText = T("wSearch"); search.Text = ""; search.TextSize = 15; search.Font = Enum.Font.Gotham; search.BackgroundColor3 = U.C.card; search.TextColor3 = U.C.text; search.ClearTextOnFocus = false; search.Parent = win
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 8)
local randB = U.button(win, "🎲 " .. T("wRandom"), UDim2.new(0, 60, 0, 34), UDim2.new(1, -130, 0, 88), U.C.accent, nil)
local noneB = U.button(win, T("wNone"), UDim2.new(0, 56, 0, 34), UDim2.new(1, -66, 0, 88), U.C.card, nil)
local status = U.label(win, "", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 124), { textSize = 12, color = U.C.dim })
local grid = U.scroll(win, UDim2.new(1, -20, 1, -156), UDim2.new(0, 10, 0, 146))
local gl = Instance.new("UIGridLayout"); gl.CellSize = UDim2.new(0, 96, 0, 112); gl.CellPadding = UDim2.new(0, 6, 0, 6); gl.Parent = grid
local currentCat = CATS[1]
local tabBtns = {}
local function clear() for _, x in ipairs(grid:GetChildren()) do if x:IsA("GuiObject") then x:Destroy() end end end
local function item(id, name, cb)
	local b = Instance.new("ImageButton"); b.BackgroundColor3 = U.C.card; b.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"; b.ScaleType = Enum.ScaleType.Fit; b.Parent = grid
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 0, 18); l.Position = UDim2.new(0, 0, 1, -18); l.BackgroundColor3 = U.C.bg; l.BackgroundTransparency = 0.3; l.Text = name; l.TextSize = 10; l.Font = Enum.Font.Gotham; l.TextColor3 = U.C.text; l.TextTruncate = Enum.TextTruncate.AtEnd; l.Parent = b
	b.MouseButton1Click:Connect(cb)
	return b
end
local SKINS = { { 255, 224, 196 }, { 240, 200, 170 }, { 224, 172, 130 }, { 198, 134, 90 }, { 160, 100, 60 }, { 120, 75, 45 }, { 90, 55, 35 }, { 60, 38, 25 } }
local lastItems = {}
local function load()
	clear(); lastItems = {}
	if currentCat.key == "skin" then
		status.Text = ""
		for _, c in ipairs(SKINS) do
			local b = Instance.new("TextButton"); b.BackgroundColor3 = Color3.fromRGB(unpack(c)); b.Text = ""; b.Parent = grid; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
			b.MouseButton1Click:Connect(function() Remotes.Action:FireServer("outfit", "skin", c) end)
		end
		return
	end
	status.Text = T("wLoading")
	local params = CatalogSearchParams.new()
	params.AssetTypes = currentCat.types
	params.SearchKeyword = search.Text
	params.SortType = Enum.CatalogSortType.MostFavorited
	local myCat = currentCat
	task.spawn(function()
		local ok, pages = pcall(function() return AES:SearchCatalog(params) end)
		if myCat ~= currentCat then return end
		if not ok or not pages then status.Text = "⚠ " .. tostring(pages); return end
		local n = 0
		for _, pg in ipairs({ 1, 2 }) do
			local page = pages:GetCurrentPage()
			for _, it in ipairs(page) do
				if it.Id then n += 1; lastItems[#lastItems + 1] = it.Id; item(it.Id, it.Name or "", function() Remotes.Action:FireServer("outfit", myCat.key, it.Id) end) end
			end
			if pages.IsFinished then break end
			local ok2 = pcall(function() pages:AdvanceToNextPageAsync() end); if not ok2 then break end
		end
		status.Text = n .. " items"
	end)
end
for i, cat in ipairs(CATS) do
	local b = U.button(tabs, T(cat.label), UDim2.new(0, 68, 0, 32), nil, i == 1 and U.C.accent or U.C.card, function()
		currentCat = cat; for k, x in pairs(tabBtns) do x.BackgroundColor3 = k == cat.key and U.C.accent or U.C.card end; load()
	end)
	b.LayoutOrder = i; tabBtns[cat.key] = b
end
search.FocusLost:Connect(function(enter) if enter then load() end end)
randB.MouseButton1Click:Connect(function() if currentCat.key == "skin" then Remotes.Action:FireServer("outfit", "skin", SKINS[math.random(#SKINS)]) elseif #lastItems > 0 then Remotes.Action:FireServer("outfit", currentCat.key, lastItems[math.random(#lastItems)]) end end)
noneB.MouseButton1Click:Connect(function() if currentCat.key ~= "skin" then Remotes.Action:FireServer("outfit", currentCat.key, 0) end end)
player:GetAttributeChangedSignal("WardrobeToggle"):Connect(function() win.Visible = not win.Visible; if win.Visible then load() end end)
closeB.Text = "✕"
