-- โหลดโมเดลฟรีจาก Creator Store (InsertService) ลบสคริปต์ทั้งหมดเพื่อความปลอดภัย ย่อ/ขยายให้พอดีขนาดที่ต้องการ
local InsertService = game:GetService("InsertService")
local A = { cache = {}, failed = {} }
-- รายการโมเดล (คัดจาก Creator Store: ฟรี คะแนนสูง ส่วนใหญ่ไม่มีสคริปต์)
A.IDS = {
	Hospital = { 5201630514 }, Police = { 13441086000 }, School = { 76558120171446 }, Cafe = { 5365756549 }, Restaurant = { 1157548091 },
	TechOffice = { 2109282230, 5245274732 }, Shop = { 2109231816 }, University = { 12423243620 }, CityHall = { 5245274732 }, Gallery = { 11491736899 },
	tower = { 4645622383, 2680353246, 2109282230, 2109231816, 5245274732, 12423243620, 7963873283, 14243660153, 11060633677 },
	house = { 984809285, 17383957280, 10651759353, 4981073436 },
	thaiHouse = { 4515416053, 2491399554 }, temple = { 12892761072, 5164587027 }, chedi = { 13392924494 },
	tree = { 580221169, 6020696518, 3755594081 }, palm = { 10562894034, 4586726395 },
	bench = { 741384218 }, lamp = { 15472204631, 14212653287 }, fountain = { 2101548957, 2332885124 }, boat = { 9617142471 }, stall = { 10970560969 },
	car = { 14215126016 },
}
local function sanitize(m)
	for _, x in ipairs(m:GetDescendants()) do
		if x:IsA("BaseScript") or x:IsA("ModuleScript") or x:IsA("RemoteEvent") or x:IsA("RemoteFunction") or x:IsA("BindableEvent") then x:Destroy()
		elseif x:IsA("SpawnLocation") then x:Destroy()
		elseif x:IsA("BasePart") then
			x.Anchored = true; x.Massless = true
			-- ตัด "พื้นฐาน/baseplate" ที่ติดมากับโมเดล (แผ่นกว้างแบน) ออก
			local n = x.Name:lower()
			if (x.Size.X * x.Size.Z > 1600 and x.Size.Y <= 4) or n:find("baseplate") or n == "base" or n == "ground" or n:find("floorplate") then x:Destroy() end
		elseif x:IsA("Sound") then x:Destroy() end
	end
end
function A.load(id)
	if A.cache[id] then return A.cache[id]:Clone() end
	if A.failed[id] then return nil end
	local ok, res = pcall(InsertService.LoadAsset, InsertService, id)
	if not ok or not res then A.failed[id] = true; return nil end
	local m = res:FindFirstChildOfClass("Model") or res
	if #m:GetChildren() == 1 and m:GetChildren()[1]:IsA("Model") then m = m:GetChildren()[1] end
	m.Parent = nil
	sanitize(m)
	if m:IsA("Model") and #m:GetDescendants() == 0 then A.failed[id] = true; return nil end
	A.cache[id] = m
	return m:Clone()
end
function A.pick(kind, i)
	local list = A.IDS[kind]; if not list then return nil end
	for k = 0, #list - 1 do
		local id = list[((i or 1) - 1 + k) % #list + 1]
		local m = A.load(id); if m then return m, id end
	end
	return nil
end
-- วางโมเดล: pos = จุดกึ่งกลางฐาน, yaw = องศา, target = ความกว้างเป้าหมาย (ปรับสเกลให้ด้านกว้างสุดในแนวราบ = target) ; คืน model, size
function A.place(kind, i, pos, yaw, target, parent)
	local m, id = A.pick(kind, i); if not m then return nil end
	local ok, size = pcall(function() return m:GetExtentsSize() end)
	if not ok or size.Magnitude < 1 then m:Destroy(); return nil end
	if target then
		local widest = math.max(size.X, size.Z)
		local sc = target / widest
		if sc < 0.05 or sc > 40 then m:Destroy(); return nil end
		pcall(function() m:ScaleTo(m:GetScale() * sc) end)
		size = m:GetExtentsSize()
	end
	local bbCf = m:GetBoundingBox()
	-- ให้ฐานอยู่ที่ y = pos.Y และกึ่งกลาง XZ = pos ; หมุนตาม yaw
	local pivotCf = m:GetPivot()
	local delta = pivotCf.Position - bbCf.Position
	local targetCf = CFrame.new(pos + Vector3.new(0, size.Y / 2, 0)) * CFrame.Angles(0, math.rad(yaw or 0), 0) * CFrame.new(delta)
	m:PivotTo(targetCf)
	m.Name = kind .. "_" .. tostring(id); m.Parent = parent
	m:SetAttribute("AssetId", id)
	return m, size
end
return A
