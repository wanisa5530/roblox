-- Remote ให้ client-server คุยกัน: เซิร์ฟเวอร์สร้าง ฝั่งผู้เล่นรอ
local RS = game:GetService("ReplicatedStorage")
local isServer = game:GetService("RunService"):IsServer()
local names = { BuyFood="RemoteFunction", GetData="RemoteFunction", Collect="RemoteFunction",
	DataUpdate="RemoteEvent", PromptPass="RemoteEvent" }

local folder
if isServer then
	folder = Instance.new("Folder"); folder.Name = "RemoteFolder"; folder.Parent = RS
	for name, class in pairs(names) do
		local r = Instance.new(class); r.Name = name; r.Parent = folder
	end
else
	folder = RS:WaitForChild("RemoteFolder")
end

local Remotes = {}
for name in pairs(names) do Remotes[name] = folder:WaitForChild(name) end
return Remotes
