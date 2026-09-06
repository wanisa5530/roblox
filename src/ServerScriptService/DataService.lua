-- โหลด/บันทึกข้อมูลผู้เล่น (DataStore ใช้ได้เฉพาะเกมที่ publish แล้ว)
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Config)
local okStore, store = pcall(DSS.GetDataStore, DSS, "StreetFoodTycoon_v2")
if not okStore then warn("DataStore unavailable:", store); store = nil end
local D = { cache = {} }
local function default() return { cash = Config.StartingCash, foods = { MooPing = true }, total = 0, rep = 0, served = 0, lastClaim = 0, streak = 0, staff = {}, upg = {}, quests = nil, level = 1, decor = { owned = {}, tent = "TentRed", chairs = "ChairPlastic", sign = "SignClassic" }, prestige = 0, branch = 1, recipes = {}, gold = {}, goldStreak = 0, weekKey = "", weekEarned = 0, expansions = 0 } end
function D.load(p)
	local ok, data = false, nil
	if store then ok, data = pcall(store.GetAsync, store, "p_" .. p.UserId) end
	local d = (ok and type(data) == "table") and data or default()
	d.total = d.total or 0; d.rep = d.rep or 0; d.served = d.served or 0; d.pending = nil; d._staffNext = nil; d.staff = d.staff or {}; d.upg = d.upg or {}; d.level = d.level or 1; d.prestige = d.prestige or 0; d.branch = d.branch or 1; d.recipes = d.recipes or {}; d.gold = d.gold or {}; d.goldStreak = d.goldStreak or 0; d.expansions = d.expansions or 0; d.decor = d.decor or { owned = {}, tent = "TentRed", chairs = "ChairPlastic", sign = "SignClassic" }; d.lastClaim = d.lastClaim or 0; d.streak = d.streak or 0
	D.cache[p.UserId] = d
	return d
end
function D.save(p)
	local d = D.cache[p.UserId]
	if d and store then pcall(store.SetAsync, store, "p_" .. p.UserId, d) end
end
function D.get(p) return D.cache[p.UserId] end
Players.PlayerRemoving:Connect(function(p) D.save(p); D.cache[p.UserId] = nil end)
game:BindToClose(function() for _, p in ipairs(Players:GetPlayers()) do D.save(p) end end)
task.spawn(function() while true do task.wait(60); for _, p in ipairs(Players:GetPlayers()) do D.save(p) end end end)
return D
