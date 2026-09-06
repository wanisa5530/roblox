-- Leaderboard: leaderstats ในเกม + อันดับรวมทุกเซิร์ฟเวอร์ (OrderedDataStore) + ป้ายในแมพ
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Remotes = require(game.ReplicatedStorage.Remotes)
local ok, ods = pcall(DSS.GetOrderedDataStore, DSS, "TotalEarned_v1")
if not ok then ods = nil end
local function weekStore() local okw, w = pcall(DSS.GetOrderedDataStore, DSS, "Weekly_" .. ("W" .. math.floor(os.time() / 604800))); return okw and w or nil end
local LB = { top = {} }

function LB.setup(player, d)
	local ls = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = player
	local cash = Instance.new("NumberValue"); cash.Name = "Cash"; cash.Parent = ls
	local inc = Instance.new("NumberValue"); inc.Name = "Served"; inc.Parent = ls
end
function LB.update(player, d, income)
	local ls = player:FindFirstChild("leaderstats"); if not ls then return end
	ls.Cash.Value = math.floor(d.cash); ls.Served.Value = income
end
function LB.submit(player, d)
	if ods then pcall(ods.SetAsync, ods, tostring(player.UserId), math.floor(d.total)) end
	local w = weekStore(); if w and d.weekKey == ("W" .. math.floor(os.time() / 604800)) then pcall(w.SetAsync, w, tostring(player.UserId), math.floor(d.weekEarned or 0)) end
end
-- มงกุฎให้แชมป์สัปดาห์ที่อยู่ในเซิร์ฟเวอร์
LB.weekTop = nil
local function crown(player, on)
	local char = player.Character; if not char then return end
	local old = char:FindFirstChild("WeeklyCrown"); if old then old:Destroy() end
	if not on then return end
	local head = char:FindFirstChild("Head"); if not head then return end
	local c = Instance.new("Part"); c.Name = "WeeklyCrown"; c.Size = Vector3.new(1.4, 0.7, 1.4); c.Color = Color3.fromRGB(255, 215, 60); c.Material = Enum.Material.Neon; c.CanCollide = false; c.Massless = true
	local w = Instance.new("Weld"); w.Part0 = head; w.Part1 = c; w.C0 = CFrame.new(0, 0.9, 0); w.Parent = c
	local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 220, 120); l.Range = 6; l.Parent = c
	c.Parent = char
end
function LB.applyCrown(player)
	crown(player, LB.weekTop ~= nil and LB.weekTop == player.UserId)
end

-- ป้ายอันดับในแมพ
local board = Instance.new("Part"); board.Name = "LeaderboardSign"; board.Anchored = true
board.Size = Vector3.new(18, 12, 0.5); board.Position = Vector3.new(30, 7, -30); board.Color = Color3.fromRGB(30, 26, 24)
board.Material = Enum.Material.SmoothPlastic; board.Parent = workspace
local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.Parent = board
local tl = Instance.new("TextLabel"); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1
tl.TextColor3 = Color3.fromRGB(255, 220, 120); tl.Font = Enum.Font.FredokaOne; tl.TextScaled = true
tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = "🏆 Top Tycoons"; tl.Parent = sg
local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0.05, 0); pad.PaddingTop = UDim.new(0.03, 0); pad.Parent = tl

local function fmt(n) if n >= 1e6 then return string.format("%.1fM", n/1e6) elseif n >= 1e3 then return string.format("%.1fK", n/1e3) end return tostring(n) end
function LB.refresh()
	if not ods then return end
	local okp, pages = pcall(ods.GetSortedAsync, ods, false, 10)
	if not okp then return end
	local rows, lines = {}, { "🏆 Top Tycoons" }
	for i, e in ipairs(pages:GetCurrentPage()) do
		local okn, name = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(e.key))
		name = okn and name or "?"
		rows[#rows + 1] = { name = name, value = e.value }
		lines[#lines + 1] = string.format("%d. %s  ฿%s", i, name, fmt(e.value))
	end
	LB.top = rows
	local wrows = {}
	local w = weekStore()
	if w then
		local okw, wp = pcall(w.GetSortedAsync, w, false, 5)
		if okw then
			for i, e in ipairs(wp:GetCurrentPage()) do
				local okn, name = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(e.key))
				wrows[#wrows + 1] = { name = okn and name or "?", value = e.value }
				if i == 1 then LB.weekTop = tonumber(e.key) end
			end
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do LB.applyCrown(p) end
	tl.Text = table.concat(lines, "\n")
	Remotes.Leaderboard:FireAllClients(rows, wrows)
end
task.spawn(function() while true do LB.refresh(); task.wait(60) end end)
return LB
