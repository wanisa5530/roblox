-- smoke: config ครบ, locale, โมดูล require ได้, datastore
local RS = game:GetService("ReplicatedStorage")
local fails = {}
local function check(name, ok) print((ok and "PASS " or "FAIL ") .. name); if not ok then table.insert(fails, name) end end
local Config = require(RS.Config); local Locale = require(RS.Locale)
check("needs 8", #Config.Needs == 8); check("stages 7", #Config.Stages == 7); check("traits >= 20", #Config.Traits >= 20); check("careers 6", #Config.Careers == 6); check("furniture >= 30", #Config.Furniture >= 30); check("illnesses 6", #Config.Illnesses == 6)
for _, l in ipairs(Config.Languages) do check("locale " .. l, Locale.strings[l] ~= nil and Locale.get(l, "menu") ~= "menu") end
for _, cc in ipairs(Config.Careers) do check("career pay 10 " .. cc.key, #cc.pay == 10) end
for _, f in ipairs(Config.Furniture) do check("furniture cfg " .. f.key, f.price and f.size and #f.size == 3 and f.color and true or false) end
local SSS = game:GetService("ServerScriptService")
for _, m in ipairs({ "Core", "DataService", "TimeService", "MapService", "HomeService", "SimService", "CareerService", "SocialService", "BusinessService", "LeaderboardService", "GameService" }) do
	local ok, err = pcall(require, SSS[m]); check("require " .. m .. " " .. tostring(ok and "" or err), ok)
end
local ok, err = pcall(function() local s = game:GetService("DataStoreService"):GetDataStore("LifeStory_v1"); s:SetAsync("smoke", { cash = 1 }); assert(s:GetAsync("smoke").cash == 1); s:RemoveAsync("smoke") end)
check("datastore " .. tostring(err or ""), ok)
-- อ่านบันทึกวินิจฉัย (จำกัดเวลา 40 วิ กันค้าง)
do
	local done = false
	task.spawn(function()
		pcall(function()
			local DSS = game:GetService("DataStoreService")
			DSS:GetDataStore("LifeMeta"):SetAsync("version", game.PlaceVersion)
			print("PlaceVersion", game.PlaceVersion)
			for _, x in ipairs(game.StarterPlayer.StarterPlayerScripts:GetChildren()) do print("SPS", x.Name, x.ClassName) end
			local ds = DSS:GetDataStore("LifeDiag")
			local keys = ds:ListKeysAsync(nil, 30):GetCurrentPage()
			for _, k in ipairs(keys) do local ok, v = pcall(ds.GetAsync, ds, k.KeyName); print("DIAG", k.KeyName, ok and v or "?") end
		end)
		done = true
	end)
	local t0 = os.clock(); while not done and os.clock() - t0 < 40 do task.wait(0.5) end
	if not done then print("DIAG timeout") end
end
print(#fails == 0 and "ALL PASS" or ("FAILED: " .. table.concat(fails, ", ")))
return #fails == 0, fails
