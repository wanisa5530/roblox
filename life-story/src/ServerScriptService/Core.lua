-- ตัวช่วยกลาง: notify, push, สิทธิ์, บันทึกวินิจฉัย
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local DSS = game:GetService("DataStoreService")
local Config = require(game.ReplicatedStorage.Config)
local Locale = require(game.ReplicatedStorage.Locale)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = { hooks = {} }
function Core.isReal(p) return typeof(p) == "Instance" and p:IsA("Player") end
function Core.lang(p) return (Core.isReal(p) and p:GetAttribute("Lang")) or "en" end
function Core.T(p, key, ...) return Locale.get(Core.lang(p), key, ...) end
Core.log = {}
function Core.notify(p, key, color, ...)
	table.insert(Core.log, key)
	if #Core.log > 50 then table.remove(Core.log, 1) end
	if Core.isReal(p) then Remotes.Notify:FireClient(p, key, color or "white", ...) end
end
function Core.push(p)
	local d = Data.get(p)
	if d and Core.isReal(p) then Remotes.DataUpdate:FireClient(p, d) end
end
function Core.char(p) local d = Data.get(p); return d and d.char, d end
local passCache = {}
function Core.ownsPass(p, key)
	local id; for _, gp in ipairs(Config.GamePasses) do if gp.key == key then id = gp.id end end
	if not id or id == 0 then return false end
	passCache[p] = passCache[p] or {}
	if passCache[p][key] == nil then
		local ok, res = pcall(MPS.UserOwnsGamePassAsync, MPS, p.UserId, id)
		passCache[p][key] = ok and res or false
		if Core.isReal(p) then p:SetAttribute("Pass_" .. key, passCache[p][key] or nil) end
	end
	return passCache[p][key]
end
function Core.clearPass(p) passCache[p] = nil end
local diagLast = {}
function Core.diag(msg)
	if diagLast[msg] and os.clock() - diagLast[msg] < 60 then return end
	diagLast[msg] = os.clock()
	task.spawn(function() pcall(function() DSS:GetDataStore("LifeDiag"):SetAsync(msg:sub(1, 40), os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg) end) end)
end
function Core.addCash(p, amount)
	local d = Data.get(p); if not d then return end
	if amount > 0 and Core.ownsPass(p, "VIP") then amount = math.floor(amount * 1.1) end
	d.cash = math.max(0, d.cash + amount)
	if amount > 0 then d.total += amount; d.weekEarned = (d.weekEarned or 0) + amount end
end
function Core.spend(p, amount)
	local d = Data.get(p); if not d then return false end
	if d.cash < amount then Core.notify(p, "notEnough", "red"); return false end
	d.cash -= amount; return true
end
function Core.trait(c, key) for _, t in ipairs(c.traits or {}) do if t == key then return true end end; return false end
function Core.traitCfg(key) for _, t in ipairs(Config.Traits) do if t.key == key then return t end end end
function Core.career(key) for _, c in ipairs(Config.Careers) do if c.key == key then return c end end; if key == "Barista" then return Config.PartTime end end
function Core.stage(c) return Config.Stages[c.stage] end
function Core.isAdult(c) return c.stage >= 5 end
function Core.getPlayerByUserId(id) return Players:GetPlayerByUserId(id) end
return Core
