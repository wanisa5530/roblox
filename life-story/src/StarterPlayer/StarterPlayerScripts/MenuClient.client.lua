-- เมนูหลัก: ฉัน / ทักษะ / อาชีพ / เรียน / ผู้คน / ครอบครัว / บ้าน / ธุรกิจ / ร้านค้า / แพ็กเกจ / เป้าหมาย
local Players = game:GetService("Players")
local RS = game.ReplicatedStorage
local Config = require(RS.Config)
local Remotes = require(RS.Remotes)
local U = require(script.Parent:WaitForChild("UI"))
local player = Players.LocalPlayer
local T = U.T
local gui = Instance.new("ScreenGui"); gui.Name = "LifeMenu"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")
local data = Remotes.GetData:InvokeServer()
Remotes.DataUpdate.OnClientEvent:Connect(function(d) data = d end)
local win = U.frame(gui, UDim2.new(0, 680, 0, 470), UDim2.new(0.5, -340, 0.5, -290), U.C.bg, 16, U.C.teal); win.Visible = false; win.BackgroundTransparency = 0.05
local header = U.frame(win, UDim2.new(1, 0, 0, 66), UDim2.new(), U.C.navy, 16)
local hg = Instance.new("UIGradient"); hg.Color = ColorSequence.new(Color3.fromRGB(30, 80, 100), Color3.fromRGB(16, 26, 36)); hg.Parent = header
U.button(win, "✕", UDim2.new(0, 30, 0, 30), UDim2.new(1, -38, 0, 8), U.C.red, function() win.Visible = false end)
local tabsF = Instance.new("Frame"); tabsF.Size = UDim2.new(1, -60, 0, 56); tabsF.Position = UDim2.new(0, 10, 0, 5); tabsF.BackgroundTransparency = 1; tabsF.Parent = header
local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 4); tl.VerticalAlignment = Enum.VerticalAlignment.Center; tl.Parent = tabsF
local content = U.scroll(win, UDim2.new(1, -20, 1, -110), UDim2.new(0, 10, 0, 100))
local title = U.label(win, "", UDim2.new(0.8, 0, 0, 26), UDim2.new(0, 14, 0, 70), { textSize = 17, color = U.C.accent })
local TABS = { "character", "skills", "career", "school", "relationships", "family", "home", "business", "shop", "quests", "passes" }
local current = "character"
local render = {}
local function clear() for _, x in ipairs(content:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end end
local function c() return data and data.char end
render.character = function()
	local ch = c(); if not ch then return end
	U.card(content, ch.name, T("stage") .. ": " .. T(Config.Stages[ch.stage].key) .. " · " .. T("generation", ch.generation) .. " · " .. T("mood") .. ": " .. T(ch.mood or "Happy"))
	local tr = {}; for _, t in ipairs(ch.traits) do tr[#tr + 1] = T(t) end
	U.card(content, T("traits"), table.concat(tr, ", "))
	local asp; for _, a in ipairs(Config.Aspirations) do if a.key == ch.aspiration then asp = a end end
	if asp then
		local m = asp.milestones[ch.aspStep]
		local desc = m and (m[1] .. " " .. tostring(m[2]) .. (m[3] and (" " .. m[3]) or "")) or T("aspirationDone")
		U.card(content, "🌟 " .. T("aspiration") .. ": " .. T(asp.key), (ch.aspStep) .. "/" .. #asp.milestones .. " · " .. desc)
	end
	U.card(content, "❤️ " .. T("health"), ch.illness and (T(ch.illness.key) .. " · " .. T("treat", "?")) or T("healthy"), ch.illness and T("treat", "…") or nil, U.C.red, function() Remotes.Action:FireServer("treat") end)
	U.card(content, "🛡️ " .. T("insurance"), (data.dayCount < (ch.insuranceUntil or 0)) and "✓" or "-", T("buyInsurance", U.fmt(Config.Insurance.cost)), U.C.blue, function() Remotes.Action:FireServer("insurance") end)
	local ok, amt = Remotes.ClaimDaily:InvokeServer()
	U.card(content, "🎁 " .. T("daily"), ok and ("+฿" .. U.fmt(amt)) or T("claimed"))
	U.card(content, "🧹 " .. T("clean"), T("environment"), T("clean"), U.C.green, function() Remotes.Action:FireServer("clean") end)
	local lb = Remotes.Leaderboard:InvokeServer()
	local s = {}; for i, e in ipairs(lb) do s[#s + 1] = i .. ". " .. e.name .. " ฿" .. U.fmt(e.value) end
	U.card(content, "🏆 " .. T("topPlayers"), table.concat(s, "  "))
end
render.skills = function()
	local ch = c(); if not ch then return end
	for _, s in ipairs(Config.Skills) do
		local lvl = ch.skills[s] or 0
		local card = U.card(content, T(s), T("level", lvl) .. " / " .. Config.SkillMax)
		local _, fill = U.bar(card, UDim2.new(0.3, 0, 0, 10), UDim2.new(0.67, 0, 0.5, -5)); fill.Size = UDim2.new(lvl / Config.SkillMax, 0, 1, 0)
	end
end
render.career = function()
	local ch = c(); if not ch then return end
	if ch.career then
		local cc; for _, x in ipairs(Config.Careers) do if x.key == ch.career then cc = x end end; cc = cc or Config.PartTime
		U.card(content, "💼 " .. T(ch.career), T("level", ch.careerLevel) .. " · ฿" .. U.fmt(cc.pay[math.clamp(ch.careerLevel, 1, #cc.pay)]) .. "/shift · " .. cc.hours[1] .. ":00-" .. cc.hours[2] .. ":00 · " .. T(cc.building), T("quit"), U.C.red, function() Remotes.Career:FireServer("quit") end)
		U.card(content, T("performance"), ch.perf .. " / " .. Config.PromotePerf .. " → " .. T("nextPromo"))
		U.card(content, "🚕 " .. T("taxi") .. " " .. T(cc.building), "฿20", T("goWork"), U.C.blue, function() Remotes.Action:FireServer("goTo", cc.building) end)
	else
		for _, cc in ipairs(Config.Careers) do
			U.card(content, T(cc.key), "฿" .. cc.pay[1] .. "→฿" .. cc.pay[10] .. " · " .. T(cc.skill) .. (cc.degreeAt > 0 and (" · " .. T("needDegree", cc.degreeAt)) or ""), T("applyJob"), U.C.green, function() Remotes.Career:FireServer("apply", cc.key) end)
		end
		if ch.stage == 4 then U.card(content, T("Barista"), "฿40/shift", T("applyJob"), U.C.green, function() Remotes.Career:FireServer("apply", "Barista") end) end
	end
	for _, b in ipairs({ "Hospital", "School", "University", "Shop", "Park", "Cafe", "CityHall" }) do
		U.card(content, "🚕 " .. T(b), "฿20", T("taxi"), U.C.card, function() Remotes.Action:FireServer("goTo", b) end)
	end
end
render.school = function()
	local ch = c(); if not ch then return end
	if ch.stage >= 3 and ch.stage <= 4 then
		U.card(content, "🏫 " .. T("School"), "Grade: " .. Config.Grades[ch.school.grade] .. " · " .. Config.SchoolHours[1] .. ":00-" .. Config.SchoolHours[2] .. ":00", T("homework"), U.C.green, function() Remotes.Action:FireServer("homework") end)
	end
	U.card(content, "🎓 " .. T("degree"), ch.degree and T(ch.degree) or T("noDegree"))
	if ch.uni then U.card(content, T(ch.uni.faculty), ch.uni.days .. "/" .. Config.University.days .. " " .. T("exam"))
	elseif not ch.degree and ch.stage >= 4 then
		for _, f in ipairs(Config.University.faculties) do U.card(content, T(f.key), T("tuition") .. " ฿" .. U.fmt(Config.University.tuition), T("enroll", U.fmt(Config.University.tuition)), U.C.accent, function() Remotes.Career:FireServer("enroll", f.key) end) end
	end
end
render.relationships = function()
	local ch = c(); if not ch then return end
	local any = false
	for id, r in pairs(ch.rel) do
		any = true
		local st = (ch.spouse == id and "spouse") or (r.ex and "ex") or (r.f <= -30 and "enemy") or (r.r >= 60 and "lover") or (r.f >= Config.BestFriendAt and "bestFriend") or (r.f >= Config.FriendAt and "friend") or (r.f >= 10 and "acquaintance") or "stranger"
		U.card(content, (id:sub(1, 1) == "u" and "👤 " or "🧑 ") .. id, T(st) .. " · " .. T("friendship") .. " " .. math.floor(r.f) .. " · " .. T("romance") .. " " .. math.floor(r.r))
	end
	if not any then U.card(content, T("Park"), T("npcTalk"), T("taxi"), U.C.blue, function() Remotes.Action:FireServer("goTo", "Park") end) end
end
render.family = function()
	local ch = c(); if not ch then return end
	U.card(content, "💍 " .. T("spouse"), ch.married and (ch.spouseName or ch.spouse) or "-", ch.married and T("divorce") or nil, U.C.red, function() Remotes.Family:FireServer("divorce") end)
	U.card(content, "👶 " .. T("tryBaby"), ch.pregnantUntil and "…" or (#ch.kids .. "/" .. Config.MaxKids), T("tryBaby"), U.C.green, function() Remotes.Family:FireServer("tryBaby") end)
	U.card(content, T("adopt", "3,000"), "", T("adopt", "3,000"), U.C.accent, function() Remotes.Family:FireServer("adopt") end)
	for i, k in ipairs(ch.kids) do U.card(content, "🧒 " .. k.name, T(Config.Stages[k.stage or 1].key) .. " · ❤ " .. (k.bond or 0), T("playWithKid", k.name), U.C.green, function() Remotes.Family:FireServer("playKid", i) end) end
	if ch.pet then U.card(content, "🐾 " .. T(ch.pet.key), ch.pet.name)
	else for _, p in ipairs(Config.Pets) do U.card(content, "🐾 " .. T(p.key), "฿" .. U.fmt(p.price), T("adoptPet"), U.C.accent, function() Remotes.Family:FireServer("pet", p.key) end) end end
end
render.home = function()
	local ch = c(); if not ch then return end
	U.card(content, "🏠 " .. T(ch.lot), #ch.furniture .. " items · " .. T("environment") .. " " .. math.floor(ch.needs.environment), T("build"), U.C.accent, function() player:SetAttribute("BuildMode", os.clock()); win.Visible = false end)
	for _, l in ipairs(Config.Lots) do
		if l.key ~= ch.lot and l.key ~= "Apartment" then
			U.card(content, T(l.key), (l.pass and T("MansionPass") or ("฿" .. U.fmt(l.price))) .. " · " .. T("tax") .. " ฿" .. (l.tax or 0) .. "/day · " .. l.size .. " items", T("buyLot"), U.C.green, function() Remotes.Build:FireServer("lot", l.key) end)
		end
	end
	for i, it in ipairs(ch.furniture) do U.card(content, T(it.key), it.x .. "," .. it.z, T("sell"), U.C.red, function() Remotes.Build:FireServer("sell", i) end) end
end
render.business = function()
	local ch = c(); if not ch then return end
	if ch.business then
		U.card(content, "☕ " .. T("Cafe"), T("bizLevel", ch.business.level) .. " · " .. T("customers") .. " " .. (ch.bizServed or 0) .. " · " .. T("revenue") .. " ฿" .. U.fmt(ch.business.revenue), Config.Business.upgradeCost[ch.business.level] and (T("bizUpgrade") .. " ฿" .. U.fmt(Config.Business.upgradeCost[ch.business.level])) or nil, U.C.accent, function() Remotes.Business:FireServer("upgrade") end)
		U.card(content, "🚕 " .. T("Cafe"), "฿20", T("taxi"), U.C.blue, function() Remotes.Action:FireServer("goTo", "Cafe") end)
	else
		U.card(content, "☕ " .. T("Cafe"), "฿" .. U.fmt(Config.Business.price), T("buyBusiness", U.fmt(Config.Business.price)), U.C.green, function() Remotes.Business:FireServer("buy") end)
		U.card(content, T("workHere"), T("employee") .. " " .. math.floor(Config.Business.employeeShare * 100) .. "%", T("workHere"), U.C.blue, function() Remotes.Business:FireServer("work") end)
	end
end
render.shop = function()
	U.card(content, T("Shop"), T("buildMode"), T("build"), U.C.accent, function() player:SetAttribute("BuildMode", os.clock()); win.Visible = false end)
end
render.quests = function()
	local ch = c(); if not ch or not ch.quests then return end
	for _, q in ipairs(ch.quests) do U.card(content, (q.done and "✅ " or "⬜ ") .. T("q" .. q.t, q.n), math.floor(q.prog) .. "/" .. q.n .. " · +฿" .. q.reward) end
end
render.passes = function()
	for _, gp in ipairs(Config.GamePasses) do
		local owned = player:GetAttribute("Pass_" .. gp.key)
		U.card(content, "⭐ " .. T(gp.key == "Mansion" and "MansionPass" or gp.key), T(gp.key:sub(1, 1):lower() .. gp.key:sub(2) .. "Desc"), owned and T("owned") or (gp.robux .. " R$"), owned and U.C.card or U.C.accent, function() if not owned then Remotes.PromptPass:FireServer("pass", gp.key) end end)
	end
	for _, dp in ipairs(Config.DevProducts) do U.card(content, "💎 " .. T(dp.key), dp.cash and ("+฿" .. U.fmt(dp.cash)) or T((dp.key:sub(1, 1):lower() .. dp.key:sub(2)) .. "Desc"), dp.robux .. " R$", U.C.green, function() Remotes.PromptPass:FireServer("product", dp.key) end) end
end
local tabBtns = {}
local function show(tab)
	current = tab; clear(); title.Text = T(tab)
	for k, b in pairs(tabBtns) do b.BackgroundColor3 = k == tab and U.C.accent or U.C.card end
	if render[tab] then render[tab]() end
end
local ICONS = { character = "🙂", skills = "📚", career = "💼", school = "🎓", relationships = "💬", family = "👨‍👩‍👧", home = "🏠", business = "☕", shop = "🛒", quests = "🎯", passes = "⭐" }
for i, t in ipairs(TABS) do local b = U.iconButton(tabsF, ICONS[t], T(t), 40, nil, U.C.card, function() show(t) end); b.Parent.LayoutOrder = i; tabBtns[t] = b end
player:GetAttributeChangedSignal("MenuToggle"):Connect(function()
	local want = player:GetAttribute("MenuTab")
	if want then player:SetAttribute("MenuTab", nil); win.Visible = true; show(want); return end
	win.Visible = not win.Visible; if win.Visible then show(current) end
end)
player:GetAttributeChangedSignal("LangTick"):Connect(function() if win.Visible then show(current) end end)
Remotes.DataUpdate.OnClientEvent:Connect(function() if win.Visible and current ~= "character" then show(current) end end)
-- หน้าต่างจากอาคาร: สมัครงาน / มหาวิทยาลัย / โรงพยาบาล
Remotes.Career.OnClientEvent:Connect(function(kind, key)
	win.Visible = true
	if kind == "openJob" then show("career") elseif kind == "openUni" then show("school") elseif kind == "openHospital" then show("character") end
end)
Remotes.Build.OnClientEvent:Connect(function(kind) if kind == "openLots" then win.Visible = true; show("home") elseif kind == "openShop" then player:SetAttribute("BuildMode", os.clock()) end end)
Remotes.Business.OnClientEvent:Connect(function(kind) if kind == "open" then win.Visible = true; show("business") end end)
