-- ประกอบทุกระบบ + จัดการ Remote ทั้งหมด (G.init เรียกจาก Main และจากเทสต์)
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local Config = require(game.ReplicatedStorage.Config)
local Locale = require(game.ReplicatedStorage.Locale)
local Remotes = require(game.ReplicatedStorage.Remotes)
local Data = require(script.Parent.DataService)
local Core = require(script.Parent.Core)
local Map = require(script.Parent.MapService)
local Time = require(script.Parent.TimeService)
local Home = require(script.Parent.HomeService)
local Sim = require(script.Parent.SimService)
local Career = require(script.Parent.CareerService)
local Social = require(script.Parent.SocialService)
local Biz = require(script.Parent.BusinessService)
local LB = require(script.Parent.LeaderboardService)
local G = { Data = Data, Core = Core, Map = Map, Home = Home, Sim = Sim, Career = Career, Social = Social, Biz = Biz, Time = Time }
local started = false
-- ประตูอาคาร: prompt เข้างาน/เรียน/รักษา/ซื้อของ
local function buildingPrompts()
	local function pp(key, action, label, cb)
		local b = Map.buildings[key]; if not b then return end
		local door = b.model:FindFirstChild("Entrance"); if not door then return end
		local x = Instance.new("ProximityPrompt"); x.ActionText = label; x.ObjectText = key; x.HoldDuration = 0; x.MaxActivationDistance = 10; x.RequiresLineOfSight = false; x.Parent = door
		x:SetAttribute("Action", action); x.Triggered:Connect(cb)
	end
	for _, cc in ipairs(Config.Careers) do
		pp(cc.building, "work", "Work", function(who) local c = Core.char(who); if c and c.career == cc.key then Career.startShift(who, "work") elseif c then Remotes.Career:FireClient(who, "openJob", cc.key) end end)
	end
	pp("Cafe", "work", "Work", function(who) local c = Core.char(who); if c and c.career == "Barista" then Career.startShift(who, "work") end end)
	pp("School", "school", "School", function(who) Career.startShift(who, "school") end)
	pp("University", "uni", "University", function(who) local c = Core.char(who); if c and c.uni then Career.startShift(who, "uni") else Remotes.Career:FireClient(who, "openUni") end end)
	pp("Hospital", "hospital", "Clinic", function(who) Remotes.Career:FireClient(who, "openHospital") end)
	pp("Shop", "shop", "Shop", function(who) Remotes.Build:FireClient(who, "openShop") end)
	pp("CityHall", "cityhall", "Lots", function(who) Remotes.Build:FireClient(who, "openLots") end)
end
local function teleport(p, pos)
	if Core.isReal(p) and p.Character and pos then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end end
end
function G.init()
	if started then return G end
	started = true
	Map.build(); Time.start(); buildingPrompts(); Biz.setup(); Social.spawnNpcs()
	-- ===== Remotes =====
	Remotes.GetData.OnServerInvoke = function(p) return Data.get(p) end
	Remotes.CreateCharacter.OnServerInvoke = function(p, name, traits, aspiration)
		local d = Data.get(p); if not d or d.char then return false end
		if type(name) ~= "string" or #name < 1 or #name > 16 then name = p.DisplayName end
		local tr = {}
		for _, t in ipairs(type(traits) == "table" and traits or {}) do if Core.traitCfg(t) and #tr < Config.TraitCount then tr[#tr + 1] = t end end
		local aspOk = false; for _, a in ipairs(Config.Aspirations) do if a.key == aspiration then aspOk = true end end
		d.char = Data.newCharacter(name, tr, aspOk and aspiration or "Wealth", 1)
		Home.assign(p); Sim.ensureQuests(p); Sim.applyScale(p); Core.push(p)
		teleport(p, Home.homePos(p))
		return true
	end
	Remotes.Action.OnServerEvent:Connect(function(p, kind, a, b, c2)
		local c = Core.char(p); if not c then return end
		if kind == "stop" then Home.stopAction(p)
		elseif kind == "clean" then Home.active[p] = { key = "clean", cfg = { need = nil }, act = "clean", t0 = os.clock() }; p:SetAttribute("Action", "clean"); task.delay(15, function() if Home.active[p] and Home.active[p].act == "clean" then Home.stopAction(p); c.needs.environment = math.min(c.envBase or 60, c.needs.environment + 40) end end)
		elseif kind == "goHome" then teleport(p, Home.homePos(p))
		elseif kind == "goTo" then local d = Map.door(a); if d then if Core.ownsPass(p, "SportsCar") or Core.spend(p, 20) then teleport(p, d) end end
		elseif kind == "treat" then Sim.treat(p)
		elseif kind == "insurance" then Sim.buyInsurance(p)
		elseif kind == "homework" then if c.stage >= 3 and c.stage <= 4 then c.school.homework = (c.school.homework or 0) + 1; Sim.addXp(p, "logic", 15); c.needs.fun = math.max(0, c.needs.fun - 10); Core.push(p) end
		elseif kind == "lang" then if type(a) == "string" and Locale.strings[a] then p:SetAttribute("Lang", a); Home.rebuild(p) end
		end
	end)
	Remotes.MinigameResult.OnServerEvent:Connect(function(p, q) Career.onResult(p, q) end)
	Remotes.Career.OnServerEvent:Connect(function(p, kind, key)
		if kind == "apply" then Career.apply(p, key) elseif kind == "quit" then Career.quit(p) elseif kind == "enroll" then Career.enroll(p, key) end
	end)
	Remotes.Enroll.OnServerInvoke = function(p, f) return Career.enroll(p, f) end
	Remotes.Social.OnServerEvent:Connect(function(p, kind, target, key)
		if kind == "interact" then local ok, st = Social.interact(p, target, key); Remotes.Social:FireClient(p, "result", target, ok, st, Core.char(p) and Core.char(p).rel[target]) end
	end)
	Remotes.Family.OnServerEvent:Connect(function(p, kind, a)
		if kind == "tryBaby" then Social.tryBaby(p) elseif kind == "adopt" then Social.adopt(p) elseif kind == "pet" then Social.adoptPet(p, a) elseif kind == "divorce" then Social.divorce(p) elseif kind == "playKid" then Social.playWithKid(p, tonumber(a)) end
	end)
	Remotes.Heir.OnServerInvoke = function(p, i) return Sim.chooseHeir(p, tonumber(i)) end
	Remotes.Build.OnServerEvent:Connect(function(p, kind, key, x, z, rot)
		if kind == "buy" then Home.buy(p, key, tonumber(x) or 0, tonumber(z) or 0, tonumber(rot) or 0)
		elseif kind == "sell" then Home.sell(p, tonumber(key))
		elseif kind == "move" then Home.move(p, tonumber(key), tonumber(x) or 0, tonumber(z) or 0, tonumber(rot))
		elseif kind == "lot" then Home.buyLot(p, key) end
	end)
	Remotes.BuyLot.OnServerInvoke = function(p, key) return Home.buyLot(p, key) end
	Remotes.Business.OnServerEvent:Connect(function(p, kind)
		if kind == "buy" then Biz.buy(p) elseif kind == "upgrade" then Biz.upgrade(p) elseif kind == "work" then Biz.workHere(p) end
	end)
	Remotes.ClaimDaily.OnServerInvoke = function(p) return Sim.claimDaily(p) end
	Remotes.Leaderboard.OnServerInvoke = function() return LB.top() end
	Remotes.PromptPass.OnServerEvent:Connect(function(p, kind, key)
		if kind == "pass" then for _, gp in ipairs(Config.GamePasses) do if gp.key == key and gp.id > 0 then MPS:PromptGamePassPurchase(p, gp.id) end end
		elseif kind == "product" then for _, dp in ipairs(Config.DevProducts) do if dp.key == key and dp.id > 0 then MPS:PromptProductPurchase(p, dp.id) end end end
	end)
	MPS.PromptGamePassPurchaseFinished:Connect(function(p, id, ok) if ok then Core.clearPass(p); for _, gp in ipairs(Config.GamePasses) do Core.ownsPass(p, gp.key) end; Core.push(p) end end)
	MPS.ProcessReceipt = function(info)
		local p = Players:GetPlayerByUserId(info.PlayerId); if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
		for _, dp in ipairs(Config.DevProducts) do
			if dp.id == info.ProductId then
				local c = Core.char(p)
				if dp.cash then Core.addCash(p, dp.cash)
				elseif dp.key == "Elixir" and c then c.stage = math.max(5, c.stage - 1); c.ageDays = 0; Sim.applyScale(p)
				elseif dp.key == "Rename" and c then p:SetAttribute("CanRename", true) end
				Core.push(p); return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- ===== ผู้เล่นเข้า/ออก =====
	local function onPlayer(p)
		local d = Data.load(p)
		Core.diag("join " .. tostring(p.Name) .. " v" .. tostring(game.PlaceVersion))
		LB.setup(p, d)
		for _, gp in ipairs(Config.GamePasses) do Core.ownsPass(p, gp.key) end
		if d.char then Home.assign(p); Biz.restore(p); Sim.ensureQuests(p); Sim.applyScale(p) end
		Social.attachPlayerPrompt(p)
		if Core.isReal(p) then p.CharacterAdded:Connect(function() task.wait(0.5); Sim.applyScale(p); if d.char then teleport(p, Home.homePos(p)) end end) end
		Core.push(p)
		task.spawn(function()
			local last = os.clock()
			while p.Parent do
				task.wait(1)
				local now = os.clock(); local dt = math.min(now - last, 5); last = now
				local ok, err = pcall(function()
					local c = Core.char(p); if not c or c.dead then return end
					Sim.tick(p, dt)
					local t = Time.now()
					if d.lastDay ~= t.day then d.lastDay = t.day; d.dayCount += 1; Sim.newDay(p) end
					Career.remind(p); Career.checkMissed(p)
					if math.floor(now) % 5 == 0 then Core.push(p) end
				end)
				if not ok then warn("tick", err); Core.diag("tick:" .. tostring(err)) end
			end
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
	Players.PlayerRemoving:Connect(function(p) Home.release(p); Biz.onLeave(p); Home.active[p] = nil; Career.shift[p] = nil end)
	-- เตะออกเมื่อมีเวอร์ชันใหม่
	task.spawn(function()
		local DSS = game:GetService("DataStoreService")
		while true do
			task.wait(30)
			local ok, v = pcall(function() return DSS:GetDataStore("LifeMeta"):GetAsync("version") end)
			if ok and type(v) == "number" and game.PlaceVersion > 0 and v > game.PlaceVersion then for _, p in ipairs(Players:GetPlayers()) do p:Kick(Core.T(p, "updateKick")) end end
		end
	end)
	G.onPlayer = onPlayer
	Core.diag("boot v" .. tostring(game.PlaceVersion))
	return G
end
return G
