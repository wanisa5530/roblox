-- Leaderboard: leaderstats ในเกม + อันดับรวมทุกเซิร์ฟเวอร์ (OrderedDataStore) + ป้ายในแมพ
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Remotes = require(game.ReplicatedStorage.Remotes)
local ok, ods = pcall(DSS.GetOrderedDataStore, DSS, "TotalEarned_v1")
if not ok then ods = nil end
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
	tl.Text = table.concat(lines, "\n")
	Remotes.Leaderboard:FireAllClients(rows)
end
task.spawn(function() while true do LB.refresh(); task.wait(60) end end)
return LB
