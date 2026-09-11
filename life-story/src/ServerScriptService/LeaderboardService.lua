-- leaderstats + กระดานผู้นำ (เงินรวมของตระกูล)
local DSS = game:GetService("DataStoreService")
local Core = require(script.Parent.Core)
local LB = {}
local okS, store = pcall(DSS.GetOrderedDataStore, DSS, "LifeStory_Wealth")
function LB.setup(p, d)
	if not Core.isReal(p) then return end
	local ls = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = p
	local cash = Instance.new("IntValue"); cash.Name = "Money"; cash.Value = d.cash; cash.Parent = ls
	local gen = Instance.new("IntValue"); gen.Name = "Generation"; gen.Value = d.char and d.char.generation or 1; gen.Parent = ls
	task.spawn(function()
		while p.Parent do
			task.wait(5)
			cash.Value = d.cash; gen.Value = d.char and d.char.generation or 1
			if okS and math.random() < 0.1 then pcall(store.SetAsync, store, tostring(p.UserId), math.floor(d.total or 0)) end
		end
	end)
end
function LB.top()
	if not okS then return {} end
	local out = {}
	local ok, pages = pcall(store.GetSortedAsync, store, false, 10)
	if ok then for _, e in ipairs(pages:GetCurrentPage()) do local okN, name = pcall(game.Players.GetNameFromUserIdAsync, game.Players, tonumber(e.key)); out[#out + 1] = { name = okN and name or "?", value = e.value } end end
	return out
end
return LB
