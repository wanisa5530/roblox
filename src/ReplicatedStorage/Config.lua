-- คอนฟิกกลาง: เมนูอาหาร, ราคา, Game Pass, Dev Product
local Config = {}
Config.StartingCash = 50
Config.PayoutInterval = 1 -- วินาที
Config.MaxPlots = 8
Config.DefaultLocale = "en"
-- รางวัลล็อกอินรายวัน ตามจำนวนวันติดต่อกัน (วนซ้ำหลังวันที่ 7)
Config.DailyRewards = { 200, 400, 700, 1000, 1500, 2500, 5000 }

-- เมนูอาหารข้างทางไทย เรียงจากถูกไปแพง (cost = ราคาซื้อ, income = รายได้/วินาที)
Config.Foods = {
	{ id="MooPing",     emoji="🍢", cost=0,       income=1,    color={0.80,0.45,0.20} },
	{ id="KhanomKrok",  emoji="🥥", cost=60,      income=2,    color={0.95,0.90,0.75} },
	{ id="PadThai",     emoji="🍜", cost=200,     income=5,    color={0.95,0.65,0.25} },
	{ id="SomTam",      emoji="🥗", cost=600,     income=12,   color={0.55,0.80,0.35} },
	{ id="KaiJeow",     emoji="🍳", cost=1500,    income=25,   color={0.98,0.85,0.30} },
	{ id="Roti",        emoji="🥞", cost=3500,    income=50,   color={0.90,0.75,0.45} },
	{ id="Satay",       emoji="🍡", cost=8000,    income=100,  color={0.75,0.50,0.25} },
	{ id="BoatNoodle",  emoji="🍲", cost=18000,   income=200,  color={0.50,0.25,0.15} },
	{ id="KhaoManGai",  emoji="🍗", cost=40000,   income=400,  color={0.95,0.85,0.60} },
	{ id="PadKrapao",   emoji="🌶️", cost=90000,   income=800,  color={0.85,0.25,0.20} },
	{ id="TomYum",      emoji="🦐", cost=200000,  income=1600, color={0.95,0.45,0.30} },
	{ id="HoiTod",      emoji="🦪", cost=450000,  income=3200, color={0.85,0.70,0.40} },
	{ id="MangoRice",   emoji="🥭", cost=1000000, income=6500, color={1.00,0.75,0.20} },
	{ id="ThaiTea",     emoji="🧋", cost=2200000, income=13000,color={0.90,0.50,0.20} },
	{ id="DurianCart",  emoji="🍈", cost=5000000, income=30000,color={0.75,0.80,0.35} },
}

-- ชื่อเมนูหลายภาษา
Config.FoodNames = {
	MooPing    = { en="Moo Ping (Grilled Pork)",  th="หมูปิ้ง",           ja="ムーピン（豚串焼き）",   zh="烤猪肉串",     id="Sate Babi Thailand" },
	KhanomKrok = { en="Khanom Krok",              th="ขนมครก",           ja="カノムクロック",       zh="椰香小煎饼",   id="Khanom Krok" },
	PadThai    = { en="Pad Thai",                 th="ผัดไทย",            ja="パッタイ",             zh="泰式炒河粉",   id="Pad Thai" },
	SomTam     = { en="Som Tam (Papaya Salad)",   th="ส้มตำ",             ja="ソムタム",             zh="青木瓜沙拉",   id="Som Tam" },
	KaiJeow    = { en="Kai Jeow (Thai Omelette)", th="ไข่เจียว",           ja="カイチアオ（卵焼き）",  zh="泰式煎蛋",     id="Telur Dadar Thailand" },
	Roti       = { en="Roti Banana",              th="โรตีกล้วย",          ja="ロティ",               zh="香蕉煎饼",     id="Roti Pisang" },
	Satay      = { en="Chicken Satay",            th="สะเต๊ะไก่",          ja="サテ",                 zh="沙嗲鸡肉串",   id="Sate Ayam" },
	BoatNoodle = { en="Boat Noodles",             th="ก๋วยเตี๋ยวเรือ",       ja="ボートヌードル",       zh="船面",         id="Mi Perahu" },
	KhaoManGai = { en="Khao Man Gai",             th="ข้าวมันไก่",          ja="カオマンガイ",         zh="海南鸡饭",     id="Nasi Ayam Hainan" },
	PadKrapao  = { en="Pad Krapao",               th="ผัดกะเพรา",          ja="ガパオライス",         zh="打抛猪肉饭",   id="Pad Krapao" },
	TomYum     = { en="Tom Yum Goong",            th="ต้มยำกุ้ง",           ja="トムヤムクン",         zh="冬阴功汤",     id="Tom Yum Udang" },
	HoiTod     = { en="Hoi Tod (Mussel Pancake)", th="หอยทอด",            ja="ホイトード",           zh="蚵仔煎",       id="Hoi Tod" },
	MangoRice  = { en="Mango Sticky Rice",        th="ข้าวเหนียวมะม่วง",     ja="マンゴースティッキーライス", zh="芒果糯米饭", id="Ketan Mangga" },
	ThaiTea    = { en="Thai Iced Tea",            th="ชาไทย",             ja="タイティー",           zh="泰式奶茶",     id="Teh Thailand" },
	DurianCart = { en="Durian Cart",              th="รถเข็นทุเรียน",        ja="ドリアン屋台",         zh="榴莲车",       id="Gerobak Durian" },
}

-- Game Pass (ใส่ไอดีจริงแทน 0)
Config.GamePasses = {
	{ key="DoubleIncome", id=0, mult=2 },
	{ key="AutoCollect",  id=0 },
	{ key="VIP",          id=0, mult=1.5 },
}
-- Dev Product
Config.DevProducts = {
	{ key="Cash1",  id=0, cash=5000 },
	{ key="Cash2",  id=0, cash=50000 },
	{ key="Cash3",  id=0, cash=500000 },
}
return Config
