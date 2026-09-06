local RS = game:GetService("ReplicatedStorage")
local isServer = game:GetService("RunService"):IsServer()
local names = { BuyFood="RemoteFunction", GetData="RemoteFunction", Collect="RemoteFunction",
	DataUpdate="RemoteEvent", PromptPass="RemoteEvent", ClaimDaily="RemoteFunction", Leaderboard="RemoteEvent",
	StartMinigame="RemoteEvent", MinigameResult="RemoteEvent", Notify="RemoteEvent", HireStaff="RemoteFunction" }
local folder
if isServer then
	folder = Instance.new("Folder"); folder.Name = "RemoteFolder"; folder.Parent = RS
	for name, class in pairs(names) do local r = Instance.new(class); r.Name = name; r.Parent = folder end
else
	folder = RS:WaitForChild("RemoteFolder")
end
local R = {}
for name in pairs(names) do R[name] = folder:WaitForChild(name) end
return R
