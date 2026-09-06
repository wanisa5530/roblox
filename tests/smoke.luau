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

local Sounds = require(RS.Sounds)
local n = 0
for name, cfg in pairs(Sounds) do n += 1; check("sound cfg " .. name, type(cfg.id) == "string" and (cfg.id == "" or cfg.id:match("^rbxasset")) ~= nil) end
check("sounds >= 8", n >= 8)

-- แมพกรุงเทพฯ: MapService เป็น Script จึงไม่รันในโหมดเทสต์ ตรวจว่าไฟล์มีองค์ประกอบครบ
local map = game:GetService("ServerScriptService"):FindFirstChild("MapService")
check("map script exists", map ~= nil)

-- ไอดีขายจริงต้องไม่เป็น 0 และ MarketplaceService ต้องอ่านข้อมูลได้
local MPS = game:GetService("MarketplaceService")
for _, gp in ipairs(Config.GamePasses) do
	check("pass id " .. gp.key, gp.id > 0)
	local ok, info = pcall(MPS.GetProductInfo, MPS, gp.id, Enum.InfoType.GamePass)
	check("pass info " .. gp.key .. " " .. tostring(ok and info.Name or info), ok and info.Name ~= nil)
end
for _, dp in ipairs(Config.DevProducts) do
	check("product id " .. dp.key, dp.id > 0)
	local ok, info = pcall(MPS.GetProductInfo, MPS, dp.id, Enum.InfoType.Product)
	check("product info " .. dp.key .. " " .. tostring(ok and info.Name or info), ok and info.Name ~= nil)
end

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
