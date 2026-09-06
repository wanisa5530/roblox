-- สร้าง RemoteEvent/Function ให้ client-server คุยกัน
local RS = game:GetService("ReplicatedStorage")
local folder = RS:FindFirstChild("RemoteFolder") or Instance.new("Folder")
folder.Name = "RemoteFolder"
folder.Parent = RS

local function get(name, class)
	local r = folder:FindFirstChild(name)
	if not r then r = Instance.new(class); r.Name = name; r.Parent = folder end
	return r
end

return {
	BuyFood = get("BuyFood", "RemoteFunction"),
	GetData = get("GetData", "RemoteFunction"),      -- client -> server: ขอข้อมูลตอนเริ่ม      -- client -> server: ซื้อเมนู
	Collect = get("Collect", "RemoteFunction"),      -- client -> server: เก็บเงินจากร้าน
	DataUpdate = get("DataUpdate", "RemoteEvent"),   -- server -> client: ส่งข้อมูลล่าสุด
	PromptPass = get("PromptPass", "RemoteEvent"),   -- client -> server: ขอซื้อ pass/product
}
