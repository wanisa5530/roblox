-- คอนฟิกกลาง: เมนูอาหาร, ราคา, Game Pass, Dev Product
local Config = {}
Config.StartingCash = 50
-- ลูกค้า
Config.CustomerInterval = { min = 14, max = 22 } -- วินาทีระหว่างลูกค้าแต่ละคน
Config.Patience = 90           -- วินาทีที่ลูกค้ารอได้
Config.PatiencePerExtra = 20   -- เพิ่มต่อคนหรือต่อออเดอร์ที่มากกว่า 1
Config.MaxQueue = 6
Config.MaxGroups = 3 -- กลุ่มที่อยู่ในร้านพร้อมกันสูงสุด (รวมที่นั่งโต๊ะ)
Config.TablesPerPlot = 4
Config.DineInChance = 0.6   -- โอกาสลูกค้านั่งทานที่ร้าน
Config.EatTime = 12         -- วินาทีที่นั่งกิน
Config.GroupSize = { 1, 3 } -- จำนวนคนต่อกลุ่ม
Config.SecondOrderChance = 0.35 -- โอกาสที่ลูกค้า 1 คนสั่ง 2 เมนู
Config.TipMax = 0.5            -- ทิปสูงสุด 50% ของราคา
-- มินิเกม: timing = กดเมื่อเข็มอยู่โซนเขียว, mash = คลิกรัว, flip = รอให้แถบเต็มแล้วกดก่อนไหม้
Config.MaxPlots = 8
Config.DefaultLocale = "en"
-- รางวัลล็อกอินรายวัน ตามจำนวนวันติดต่อกัน (วนซ้ำหลังวันที่ 7)
Config.DailyRewards = { 200, 400, 700, 1000, 1500, 2500, 5000 }

-- เมนูอาหารข้างทางไทย (cost = ราคาปลดล็อกโต๊ะครัว, price = ราคาขายต่อจาน, income ใช้กับพนักงานอัตโนมัติ)
Config.Foods = {
	{ id="MooPing",     emoji="🍢", game="flip", cookTime=3, price=12, batch=1, cost=0,       income=1,    color={0.80,0.45,0.20} },
	{ id="KhanomKrok",  emoji="🥥", game="flip", cookTime=3, price=18, batch=1, cost=60,      income=2,    color={0.95,0.90,0.75} },
	{ id="PadThai",     emoji="🍜", game="timing", cookTime=3, price=30, batch=1, cost=200,     income=5,    color={0.95,0.65,0.25} },
	{ id="SomTam",      emoji="🥗", spicy=true, game="mash", cookTime=3, price=45, batch=1, cost=600,     income=12,   color={0.55,0.80,0.35} },
	{ id="KaiJeow",     emoji="🍳", game="timing", cookTime=2.5, price=60, batch=1, cost=1500,    income=25,   color={0.98,0.85,0.30} },
	{ id="Roti",        emoji="🥞", game="mash", cookTime=3, price=85, batch=1, cost=3500,    income=50,   color={0.90,0.75,0.45} },
	{ id="Satay",       emoji="🍡", game="flip", cookTime=3.5, price=120, batch=1, cost=8000,    income=100,  color={0.75,0.50,0.25} },
	{ id="BoatNoodle",  emoji="🍲", spicy=true, game="timing", cookTime=3, price=170, batch=1, cost=18000,   income=200,  color={0.50,0.25,0.15} },
	{ id="KhaoManGai",  emoji="🍗", game="timing", steps={"flip","timing"}, cookTime=3, price=240, batch=1, cost=40000,   income=400,  color={0.95,0.85,0.60} },
	{ id="PadKrapao",   emoji="🌶️", spicy=true, game="timing", steps={"mash","timing"}, cookTime=2.5, price=320, batch=1, cost=90000,   income=800,  color={0.85,0.25,0.20} },
	{ id="TomYum",      emoji="🦐", spicy=true, game="mash", steps={"mash","flip"}, cookTime=4, price=450, batch=1, cost=200000,  income=1600, color={0.95,0.45,0.30} },
	{ id="HoiTod",      emoji="🦪", game="timing", steps={"timing","flip"}, cookTime=3, price=600, batch=1, cost=450000,  income=3200, color={0.85,0.70,0.40} },
	{ id="MangoRice",   emoji="🥭", game="flip", steps={"mash","timing","flip"}, cookTime=4, price=800, batch=1, cost=1000000, income=6500, color={1.00,0.75,0.20} },
	{ id="ThaiTea",     emoji="🥤", game="mash", steps={"mash","timing"}, cookTime=3, price=1000, batch=1, cost=2200000, income=13000,color={0.90,0.50,0.20} },
	{ id="DurianCart",  emoji="🍈", game="flip", steps={"mash","timing","flip"}, cookTime=5, price=1500, batch=1, cost=5000000, income=30000,color={0.75,0.80,0.35} },
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
	Dimsum     = { en="Chinatown Dim Sum",       th="ติ่มซำเยาวราช",       ja="ヤワラート点心",         zh="唐人街点心",   id="Dimsum Chinatown" },
	Scorpion   = { en="Fried Scorpion Skewer",   th="แมงป่องทอดข้าวสาร",   ja="サソリの串揚げ",         zh="炸蝎子串",     id="Sate Kalajengking" },
	KanomJeen  = { en="Floating Market Kanom Jeen", th="ขนมจีนตลาดน้ำ",     ja="水上市場カノムチーン",   zh="水上市场米线", id="Kanom Jeen Pasar Apung" },
	KhanomKeng = { en="Khanom Keng (CNY cake)",  th="ขนมเข่งตรุษจีน",     ja="旧正月の餅菓子",   zh="年糕",       id="Kue Keranjang" },
	KhaoChae   = { en="Khao Chae (Songkran)",    th="ข้าวแช่สงกรานต์",    ja="カオチェー",       zh="宋干节冰水饭", id="Khao Chae" },
	KhanomChan = { en="Khanom Chan (Loy Krathong)", th="ขนมชั้นลอยกระทง", ja="カノムチャン",     zh="水灯节千层糕", id="Kue Lapis Thailand" },
	KhaoTom    = { en="New Year Khao Tom",       th="ข้าวต้มปีใหม่",       ja="新年のお粥",       zh="新年泰式粥",   id="Bubur Tahun Baru" },
	DurianCart = { en="Durian Cart",              th="รถเข็นทุเรียน",        ja="ドリアン屋台",         zh="榴莲车",       id="Gerobak Durian" },
}

-- อัปเกรดโต๊ะครัว: speed ลดเวลาทำ 15%/ระดับ, tray ทำได้หลายจานต่อครั้ง (สูงสุดระดับ 3)
Config.UpgradeMax = 3
Config.TrayCapacity = 4 -- จำนวนจานที่ถือได้พร้อมกัน
function Config.upgradeCost(food, kind, level) return math.floor(food.cost * 0.4 * level + (kind == "tray" and 400 or 250)) end
function Config.kitchenUpgradeCost(kind, level) return (kind == "tray" and 1500 or 1000) * level * level end
Config.SpiceLevels = { "🌶️", "🌶️🌶️", "🌶️🌶️🌶️" }
-- เลเวลร้าน: need = รายได้สะสม, tables = โต๊ะที่เปิดใช้
Config.Levels = {
	{ key="Cart",   need=0,      tables=2 },
	{ key="Stall",  need=2000,   tables=3 },
	{ key="Shop",   need=10000,  tables=4 },
	{ key="Famous", need=50000,  tables=4 },
	{ key="Legend", need=200000, tables=4 },
}
-- ภารกิจรายวัน: สุ่ม 3 ข้อจากรายการนี้ (type, target, reward)
Config.QuestPool = {
	{ type="serve", target=15, reward=300 }, { type="serve", target=40, reward=900 },
	{ type="earn",  target=800, reward=250 }, { type="earn", target=3000, reward=800 },
	{ type="clean", target=5, reward=200 },   { type="perfect", target=8, reward=500 },
	{ type="takeaway", target=6, reward=300 }, { type="dine", target=6, reward=300 },
}
-- สาขา (Prestige): ถึงเลเวล 5 เปิดสาขาใหม่ เริ่มร้านใหม่ในย่านใหม่ ได้ทิปถาวร +10%/สาขา และเมนูลับของย่าน
Config.Branches = { "Market", "Chinatown", "KhaoSan", "Floating" }
Config.PrestigeTipBonus = 0.10
Config.HelperShare = 0.30 -- ส่วนแบ่งของเพื่อนที่มาช่วยร้าน
-- สมุดสะสม: การ์ดสูตรลับ (ได้จากลูกค้าพิเศษ) แต่ละใบ +1% ทิป, จานทอง (ทำสุดยอดติดกัน 3 ครั้ง มีโอกาส)
Config.Recipes = { "GrandmaSauce", "SecretChili", "MonkTea", "RiverSalt", "TempleHerb", "TukTukSpice", "NightMarketOil", "KingRice", "MonsoonLime", "GoldenGarlic" }
Config.RecipeTipBonus = 0.01
Config.GoldDishChance = 0.25
Config.GoldStreak = 3
-- เทศกาลตามปฏิทิน (UTC+7): ช่วงวัน, เมนูจำกัดเวลา, ทิปคูณ, สีโคม
Config.ForceFestival = "LoyKrathong" -- โหมดทดสอบ: ใส่ key เทศกาลเพื่อบังคับเปิด, nil = ตามปฏิทิน
Config.Festivals = {
	{ key="ChineseNY",  from={1,20}, to={2,15},  food="KhanomKeng",  tipMult=1.2, color={0.9,0.15,0.15} },
	{ key="Songkran",   from={4,10}, to={4,16},  food="KhaoChae",    tipMult=1.3, color={0.3,0.7,1.0} },
	{ key="LoyKrathong",from={11,8}, to={11,20}, food="KhanomChan",  tipMult=1.2, color={1.0,0.8,0.3} },
	{ key="NewYear",    from={12,25},to={1,5},   food="KhaoTom",     tipMult=1.25,color={1.0,1.0,1.0} },
}
-- ลูกค้าพิเศษ: โอกาส (ต่อคน), ตัวคูณ
Config.Specials = {
	Tourist = { chance = 0.10, emoji = "🧳", tipMult = 3,   patience = 0.6 },
	Critic  = { chance = 0.05, emoji = "🕵️", repGood = 20, repBad = -10 },
	VIP     = { chance = 0.02, emoji = "👑", payMult = 5 },
}
-- เหตุการณ์: ทุก 3-5 นาที สุ่ม 1 อย่าง นาน 60 วิ
Config.EventEvery = { 180, 300 }
Config.EventDuration = 60
Config.Events = { "Rain", "GasOut", "Rush" }
-- พนักงาน: cost = ค่าจ้างครั้งแรก, wage = ค่าแรงต่อคาบ, interval = วินาทีต่อการทำงาน 1 ครั้ง
Config.WagePeriod = 300
Config.Staff = {
	{ key="Cook",   emoji="👨‍🍳", cost=1500, wage=120, interval=9 },
	{ key="Waiter", emoji="🧑‍💼", cost=900,  wage=80,  interval=6 },
	{ key="Washer", emoji="🧽", cost=600,  wage=50,  interval=4 },
}
-- ของตกแต่งร้าน: cat = tent/chairs/sign/prop, cost = เงินในเกม, premium = ต้องมี Golden Decor Pack
Config.Decor = {
	{ key="TentRed",    cat="tent",   cost=0,    color={0.90,0.20,0.20} },
	{ key="TentBlue",   cat="tent",   cost=300,  color={0.16,0.35,0.78} },
	{ key="TentYellow", cat="tent",   cost=300,  color={0.98,0.78,0.16} },
	{ key="TentGreen",  cat="tent",   cost=300,  color={0.20,0.67,0.35} },
	{ key="TentPurple", cat="tent",   cost=600,  color={0.59,0.24,0.71} },
	{ key="TentGold",   cat="tent",   cost=0,    color={1.00,0.84,0.30}, premium=true },
	{ key="ChairPlastic", cat="chairs", cost=0 },
	{ key="ChairWood",    cat="chairs", cost=800 },
	{ key="ChairNeon",    cat="chairs", cost=1500 },
	{ key="SignClassic", cat="sign", cost=0 },
	{ key="SignNeon",    cat="sign", cost=1200 },
	{ key="SignGold",    cat="sign", cost=0, premium=true },
	{ key="Lanterns", cat="prop", cost=500 },
	{ key="Plants",   cat="prop", cost=400 },
	{ key="Fan",      cat="prop", cost=600 },
	{ key="TV",       cat="prop", cost=1500 },
	{ key="Flag",     cat="prop", cost=300 },
	{ key="LuckyCat", cat="prop", cost=0, premium=true },
}
Config.DecorPackProduct = 3711592303 -- ไอดี Dev Product "Golden Decor Pack" (ใส่หลังสร้าง)
-- Game Pass (ใส่ไอดีจริงแทน 0)
Config.GamePasses = {
	{ key="DoubleIncome", id=1966256968, mult=2 },
	{ key="AutoChef",  id=1970685049 },
	{ key="VIP",          id=1968813309, mult=1.5 },
}
-- Dev Product
Config.DevProducts = {
	{ key="Cash1",  id=3711589208, cash=5000 },
	{ key="Cash2",  id=3711589251, cash=50000 },
	{ key="Cash3",  id=3711589276, cash=500000 },
}
return Config
