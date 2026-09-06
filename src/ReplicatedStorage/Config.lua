-- ค่าคอนฟิกกลางของเกม แก้ไอดี Game Pass / Dev Product ที่นี่หลังสร้างใน Creator Hub
local Config = {}

Config.StartingCash = 100
Config.PayoutInterval = 2 -- วินาทีต่อรอบขายอาหาร

-- เมนูอาหาร: ราคาซื้อ, รายได้ต่อรอบ
Config.Foods = {
	{ id = "PadThai",   name = "ผัดไท",   cost = 0,     income = 5 },
	{ id = "SomTam",    name = "ส้มตำ",   cost = 250,   income = 15 },
	{ id = "MooPing",   name = "หมูปิ้ง", cost = 1000,  income = 45 },
	{ id = "TomYum",    name = "ต้มยำ",   cost = 5000,  income = 180 },
	{ id = "MangoRice", name = "ข้าวเหนียวมะม่วง", cost = 25000, income = 800 },
}

-- Game Pass (ซื้อครั้งเดียว) ใส่ไอดีจริงแทน 0
Config.GamePasses = {
	DoubleIncome = { id = 0, name = "รายได้ x2" },
	AutoWorker   = { id = 0, name = "ลูกจ้างอัตโนมัติ" },
	SecondStall  = { id = 0, name = "ร้านที่ 2" },
}

-- Dev Product (ซื้อซ้ำได้)
Config.DevProducts = {
	Cash1k  = { id = 0, cash = 1000 },
	Cash10k = { id = 0, cash = 10000 },
	Cash50k = { id = 0, cash = 50000 },
}

return Config
