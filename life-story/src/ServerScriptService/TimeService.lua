-- นาฬิกาโลก: ใช้ os.time() ให้ทุกเซิร์ฟเวอร์ตรงกัน 1 วันเกม = Config.MinutesPerDay นาทีจริง
local Config = require(game.ReplicatedStorage.Config)
local Lighting = game:GetService("Lighting")
local T = {}
local secPerDay = Config.MinutesPerDay * 60
function T.now()
	local t = os.time()
	local dayIndex = math.floor(t / secPerDay)
	local frac = (t % secPerDay) / secPerDay
	local hour = frac * 24
	local seasonIdx = (math.floor(dayIndex / Config.DaysPerSeason) % #Config.Seasons) + 1
	return { day = dayIndex, hour = hour, h = math.floor(hour), m = math.floor((hour % 1) * 60), season = Config.Seasons[seasonIdx], weekday = dayIndex % 7 }
end
function T.festival()
	if Config.ForceFestival then for _, f in ipairs(Config.Festivals) do if f.key == Config.ForceFestival then return f end end end
	local dt = os.date("!*t", os.time() + 7 * 3600)
	for _, f in ipairs(Config.Festivals) do
		local startDay = os.time({ year = dt.year, month = f.month, day = f.day, hour = 0 })
		local nowDay = os.time({ year = dt.year, month = dt.month, day = dt.day, hour = 0 })
		if nowDay >= startDay and nowDay < startDay + f.len * 86400 then return f end
	end
	return nil
end
function T.start()
	task.spawn(function()
		while true do
			local n = T.now()
			pcall(function()
				Lighting.ClockTime = n.hour
				Lighting:SetAttribute("Day", n.day); Lighting:SetAttribute("Season", n.season); Lighting:SetAttribute("Hour", n.hour)
			end)
			task.wait(5)
		end
	end)
end
return T
