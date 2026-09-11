-- สร้าง RemoteEvent/Function ฝั่งเซิร์ฟเวอร์ ฝั่งไคลเอนต์แค่รอ
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local names = {
	events = { "DataUpdate", "Notify", "StartMinigame", "MinigameResult", "Action", "Social", "Build", "Career", "Family", "Business", "Shop", "PromptPass", "NpcState" },
	functions = { "GetData", "CreateCharacter", "ClaimDaily", "Leaderboard", "BuyLot", "Enroll", "Heir" },
}
local folder
if RunService:IsServer() then
	folder = Instance.new("Folder"); folder.Name = "Remotes"; folder.Parent = RS
	for _, n in ipairs(names.events) do local e = Instance.new("RemoteEvent"); e.Name = n; e.Parent = folder end
	for _, n in ipairs(names.functions) do local f = Instance.new("RemoteFunction"); f.Name = n; f.Parent = folder end
else
	folder = RS:WaitForChild("Remotes")
end
local R = {}
for _, n in ipairs(names.events) do R[n] = folder:WaitForChild(n) end
for _, n in ipairs(names.functions) do R[n] = folder:WaitForChild(n) end
return R
