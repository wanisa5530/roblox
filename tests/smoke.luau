-- เทสต์ระบบหลักบนเซิร์ฟเวอร์จริง: Config, Locale, DataStore
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Config)
local Locale = require(RS.Locale)
local fails = {}
local function check(name, ok) if not ok then table.insert(fails, name) end; print((ok and "PASS " or "FAIL ") .. name) end

check("foods >= 10", #Config.Foods >= 10)
local prev = -1
for _, f in ipairs(Config.Foods) do
	check("food name " .. f.id, Config.FoodNames[f.id] ~= nil and Config.FoodNames[f.id].en ~= nil)
	check("cost ascending " .. f.id, f.cost > prev); prev = f.cost
	check("gameplay fields " .. f.id, f.price and f.cookTime and (f.game == "timing" or f.game == "mash" or f.game == "flip"))
	check("dish model " .. f.id, require(RS.Dish).Parts[f.id] ~= nil)
end
for _, lang in ipairs(Locale.Supported) do
	check("locale " .. lang, Locale.get(lang, "collect") ~= "collect")
end
check("detect th", Locale.detect("th-th") == "th")
check("detect fallback", Locale.detect("xx") == "en")
check("fmt", Locale.fmt(1500000) == "1.50M")

local DSS = game:GetService("DataStoreService")
local store = DSS:GetDataStore("StreetFoodTycoon_v2")
local ok, err = pcall(function()
	store:SetAsync("test_smoke", { cash = 1 })
	local v = store:GetAsync("test_smoke")
	assert(v and v.cash == 1, "datastore roundtrip")
	store:RemoveAsync("test_smoke")
end)
check("datastore " .. tostring(err or ""), ok)

print(#fails == 0 and "ALL PASS" or ("FAILED: " .. table.concat(fails, ", ")))
return #fails == 0, fails
