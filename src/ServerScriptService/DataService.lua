-- โหลด/บันทึกข้อมูลผู้เล่นด้วย DataStore
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Config)

local store = DSS:GetDataStore("StreetFoodTycoon_v1")
local DataService = { cache = {} }

local function default()
	return { cash = Config.StartingCash, foods = { PadThai = true }, pending = 0 }
end

function DataService.load(player)
	local ok, data = pcall(store.GetAsync, store, "p_" .. player.UserId)
	DataService.cache[player.UserId] = (ok and data) or default()
	return DataService.cache[player.UserId]
end

function DataService.save(player)
	local data = DataService.cache[player.UserId]
	if not data then return end
	pcall(store.SetAsync, store, "p_" .. player.UserId, data)
end

function DataService.get(player)
	return DataService.cache[player.UserId]
end

Players.PlayerRemoving:Connect(function(p)
	DataService.save(p)
	DataService.cache[p.UserId] = nil
end)

game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do DataService.save(p) end
end)

-- บันทึกอัตโนมัติทุก 60 วิ
task.spawn(function()
	while true do
		task.wait(60)
		for _, p in ipairs(Players:GetPlayers()) do DataService.save(p) end
	end
end)

return DataService
