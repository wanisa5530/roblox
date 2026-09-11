-- โหลด/บันทึกข้อมูลผู้เล่น
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Config)
local okStore, store = pcall(DSS.GetDataStore, DSS, "LifeStory_v1")
if not okStore then store = nil end
local D = { cache = {} }
function D.newCharacter(name, traits, aspiration, generation)
	local needs = {}
	for _, n in ipairs(Config.Needs) do needs[n.key] = 80 end
	needs.health = 100
	return {
		name = name or "Sim", traits = traits or {}, aspiration = aspiration or "Wealth", aspStep = 1, generation = generation or 1,
		stage = 5, ageDays = 0, needs = needs, mood = "Happy", moodlets = {}, skills = {}, career = nil, careerLevel = 0, perf = 0, shifts = 0, missed = 0,
		school = { grade = 3, homework = 0 }, degree = nil, uni = nil, illness = nil, insuranceUntil = 0,
		spouse = nil, kids = {}, pet = nil, rel = {}, pregnantUntil = nil, married = false,
		lot = "Apartment", furniture = {}, unpaid = 0, business = nil, bizServed = 0,
		friendsCount = 0, socialToday = 0, questProgress = {}, quests = nil, questDay = 0,
	}
end
local function default()
	return { cash = Config.StartingCash, char = nil, legacy = {}, lastClaim = 0, streak = 0, dayCount = 0, lastDay = 0, weekKey = "", weekEarned = 0, total = 0, created = os.time() }
end
function D.load(p)
	local ok, data = false, nil
	if store then ok, data = pcall(store.GetAsync, store, "p_" .. p.UserId) end
	local d = (ok and type(data) == "table") and data or default()
	for k, v in pairs(default()) do if d[k] == nil then d[k] = v end end
	if d.char then for _, n in ipairs(Config.Needs) do d.char.needs[n.key] = d.char.needs[n.key] or 50 end; d.char.rel = d.char.rel or {}; d.char.kids = d.char.kids or {}; d.char.skills = d.char.skills or {}; d.char.furniture = d.char.furniture or {}; d.char.moodlets = {}; d.char.questProgress = d.char.questProgress or {} end
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
