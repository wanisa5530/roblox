-- Life Story: ค่าคงที่ทั้งหมดของเกม (แก้ตัวเลขที่นี่ที่เดียว)
local C = {}
C.Version = "0.1.0"
C.StartingCash = 2000
C.MinutesPerDay = 24            -- 1 วันในเกม = 24 นาทีจริง (1 ชม.เกม = 60 วิ)
C.DaysPerSeason = 7
C.Seasons = { "Summer", "Rainy", "Winter", "Spring" }
C.Languages = { "en", "th", "ja", "zh", "id" }

-- ความต้องการ 8 อย่าง: decay = ลดต่อวินาทีจริง (100 → 0 ใน ~1 วันเกม), crit = ระดับที่เริ่มมีผลเสีย
C.Needs = {
	{ key = "hunger",  decay = 0.08, crit = 20, emoji = "🍽️" },
	{ key = "energy",  decay = 0.06, crit = 15, emoji = "😴" },
	{ key = "bladder", decay = 0.10, crit = 10, emoji = "🚽" },
	{ key = "hygiene", decay = 0.05, crit = 20, emoji = "🚿" },
	{ key = "fun",     decay = 0.07, crit = 20, emoji = "🎉" },
	{ key = "social",  decay = 0.05, crit = 20, emoji = "💬" },
	{ key = "environment", decay = 0.02, crit = 25, emoji = "🏠" },
	{ key = "health",  decay = 0.00, crit = 30, emoji = "❤️" },
}
C.NeedMax = 100

-- ช่วงชีวิต: days = จำนวนวันเกมในช่วงนั้น
C.Stages = {
	{ key = "Baby",    days = 1,  scale = 0.45 },
	{ key = "Toddler", days = 1,  scale = 0.55 },
	{ key = "Child",   days = 2,  scale = 0.7 },
	{ key = "Teen",    days = 2,  scale = 0.9 },
	{ key = "YoungAdult", days = 5, scale = 1 },
	{ key = "Adult",   days = 6,  scale = 1 },
	{ key = "Elder",   days = 3,  scale = 0.95 },
}
C.ElderDeathChancePerDay = 0.35   -- โอกาสตายจากชราต่อวันเมื่อพ้นอายุขัย

-- นิสัย: effect = ตัวคูณ decay ของความต้องการ / โบนัสทักษะ
C.Traits = {
	{ key = "Lazy",      need = "energy", mult = 1.4 },
	{ key = "Active",    need = "energy", mult = 0.7, skill = "fitness" },
	{ key = "Outgoing",  need = "social", mult = 1.3 },
	{ key = "Loner",     need = "social", mult = 0.6 },
	{ key = "Glutton",   need = "hunger", mult = 1.4, skill = "cooking" },
	{ key = "Neat",      need = "hygiene", mult = 1.3, envBonus = 10 },
	{ key = "Genius",    skill = "logic" },
	{ key = "Creative",  skill = "painting" },
	{ key = "Romantic",  romanceBonus = 1.5 },
	{ key = "Cheerful",  moodBonus = 5 },
	{ key = "HotHeaded", angerMult = 1.5 },
	{ key = "Frugal",    billDiscount = 0.15 },
	{ key = "Foodie",    skill = "cooking" },
	{ key = "Bookworm",  skill = "logic" },
	{ key = "Jokester",  skill = "charisma" },
	{ key = "Athlete",   skill = "fitness" },
	{ key = "Handy",     skill = "handiness" },
	{ key = "GreenThumb", skill = "gardening" },
	{ key = "NightOwl",  need = "energy", mult = 0.85 },
	{ key = "Clumsy",    accidentMult = 1.5 },
}
C.TraitCount = 3

-- ความฝัน: milestones = ลำดับเป้าหมาย {type, value}; reward = เงิน
C.Aspirations = {
	{ key = "Wealth",     milestones = { { "money", 10000 }, { "money", 50000 }, { "money", 200000 } }, reward = 5000 },
	{ key = "BigFamily",  milestones = { { "married", 1 }, { "kids", 1 }, { "kids", 3 } }, reward = 5000 },
	{ key = "TopChef",    milestones = { { "skill", "cooking", 3 }, { "career", "Chef", 5 }, { "career", "Chef", 10 } }, reward = 5000 },
	{ key = "Doctor",     milestones = { { "degree", 1 }, { "career", "Doctor", 5 }, { "career", "Doctor", 10 } }, reward = 5000 },
	{ key = "Entrepreneur", milestones = { { "business", 1 }, { "bizServed", 50 }, { "bizServed", 500 } }, reward = 8000 },
	{ key = "Scholar",    milestones = { { "grade", "A" }, { "degree", 1 }, { "skill", "logic", 10 } }, reward = 5000 },
	{ key = "Socialite",  milestones = { { "friends", 3 }, { "friends", 8 }, { "bestFriends", 3 } }, reward = 4000 },
	{ key = "Legacy",     milestones = { { "generation", 2 }, { "generation", 3 }, { "generation", 5 } }, reward = 20000 },
}

C.Skills = { "cooking", "fitness", "charisma", "logic", "handiness", "gardening", "painting", "music", "programming", "writing" }
C.SkillMax = 10
C.SkillXpPerLevel = 100

-- อาชีพ: 10 ระดับ pay = ต่อกะ, degree = ระดับที่ต้องมีปริญญา, skill = ทักษะที่ช่วยผลงาน, hours = ชั่วโมงเข้างาน
C.Careers = {
	{ key = "Doctor",     skill = "logic",       hours = { 9, 17 },  degreeAt = 6, building = "Hospital",  pay = { 120, 150, 190, 240, 300, 380, 470, 580, 720, 900 } },
	{ key = "Police",     skill = "fitness",     hours = { 8, 16 },  degreeAt = 8, building = "Police",    pay = { 100, 130, 160, 200, 250, 310, 380, 460, 560, 700 } },
	{ key = "Chef",       skill = "cooking",     hours = { 14, 22 }, degreeAt = 0, building = "Restaurant", pay = { 90, 115, 145, 180, 230, 290, 360, 450, 560, 700 } },
	{ key = "Programmer", skill = "programming", hours = { 10, 18 }, degreeAt = 6, building = "TechOffice", pay = { 130, 160, 200, 250, 320, 400, 500, 620, 780, 1000 } },
	{ key = "Teacher",    skill = "charisma",    hours = { 8, 15 },  degreeAt = 4, building = "School",    pay = { 90, 110, 140, 170, 210, 260, 320, 390, 480, 600 } },
	{ key = "Artist",     skill = "painting",    hours = { 11, 17 }, degreeAt = 0, building = "Gallery",   pay = { 70, 95, 125, 165, 215, 280, 360, 460, 590, 750 } },
}
C.PartTime = { key = "Barista", skill = "charisma", hours = { 16, 20 }, building = "Cafe", pay = { 40, 50, 60 } }
C.PromotePerf = 100     -- คะแนนผลงานสะสมต่อการเลื่อนขั้น
C.ShiftRounds = 3       -- มินิเกมต่อกะ

-- โรงเรียน / มหาวิทยาลัย
C.SchoolHours = { 8, 15 }
C.Grades = { "F", "D", "C", "B", "A" }
C.University = {
	tuition = 6000, days = 4,
	faculties = { { key = "Medicine", careers = { "Doctor" } }, { key = "Engineering", careers = { "Programmer" } }, { key = "Arts", careers = { "Artist", "Teacher" } }, { key = "Law", careers = { "Police" } } },
}

-- โรค: chance = โอกาสต่อวัน, days = หายเองใน, needs = ผลต่อ decay, cure = ค่ารักษา
C.Illnesses = {
	{ key = "Cold",        chance = 0.10, days = 2, healthHit = 10, cure = 200,  contagious = true },
	{ key = "Flu",         chance = 0.05, days = 3, healthHit = 25, cure = 500,  contagious = true },
	{ key = "FoodPoison",  chance = 0.00, days = 1, healthHit = 20, cure = 300 },   -- จากอาหารเน่า
	{ key = "BrokenBone",  chance = 0.00, days = 4, healthHit = 30, cure = 1500 },  -- จากอุบัติเหตุ
	{ key = "Burnout",     chance = 0.00, days = 2, healthHit = 15, cure = 400 },   -- เครียดสะสม
	{ key = "Chronic",     chance = 0.00, days = 99, healthHit = 5, cure = 3000 },  -- สูงอายุ
}
C.UntreatedDeathDays = 5   -- ป่วยไม่รักษาเกินนี้ สุขภาพลดจนตายได้
C.Insurance = { cost = 300, discount = 0.5 }  -- ต่อ 7 วัน

-- อารมณ์
C.Emotions = { "Happy", "Sad", "Angry", "Stressed", "Embarrassed", "Inspired", "Confident", "Focused", "Playful", "Flirty", "Bored", "Scared", "Sick" }

-- บ้าน: lots = ที่ดิน
C.Lots = {
	{ key = "Apartment", price = 0,     rent = 150, size = 12, tables = 0 },
	{ key = "Starter",   price = 12000, rent = 0,   size = 20, tax = 80 },
	{ key = "Family",    price = 45000, rent = 0,   size = 28, tax = 200 },
	{ key = "Mansion",   price = 0,     rent = 0,   size = 36, tax = 400, pass = "Mansion" },
}
C.Bills = { power = 40, water = 20 }   -- ต่อวัน + ภาษี

-- เฟอร์นิเจอร์: need = ความต้องการที่เติม, rate = ต่อวินาที, size (x,y,z), cat
C.Furniture = {
	{ key = "BedCheap",   cat = "bed",     price = 300,  need = "energy",  rate = 1.0, size = { 4, 2, 7 }, color = { 120, 90, 60 }, env = 1 },
	{ key = "BedComfy",   cat = "bed",     price = 1500, need = "energy",  rate = 2.0, size = { 5, 2, 7 }, color = { 60, 90, 160 }, env = 3 },
	{ key = "BedLuxury",  cat = "bed",     price = 6000, need = "energy",  rate = 3.5, size = { 6, 2, 8 }, color = { 200, 170, 60 }, env = 6 },
	{ key = "Fridge",     cat = "kitchen", price = 800,  need = "hunger",  rate = 3.0, size = { 3, 6, 3 }, color = { 230, 230, 230 }, env = 1, skill = "cooking" },
	{ key = "Stove",      cat = "kitchen", price = 1200, need = "hunger",  rate = 5.0, size = { 3, 3, 3 }, color = { 60, 60, 60 }, env = 2, skill = "cooking", fire = true },
	{ key = "Toilet",     cat = "bath",    price = 250,  need = "bladder", rate = 8.0, size = { 2, 3, 3 }, color = { 240, 240, 240 } },
	{ key = "Shower",     cat = "bath",    price = 600,  need = "hygiene", rate = 5.0, size = { 3, 7, 3 }, color = { 180, 220, 240 }, env = 1 },
	{ key = "Bathtub",    cat = "bath",    price = 2000, need = "hygiene", rate = 7.0, size = { 3, 2, 6 }, color = { 250, 250, 250 }, env = 3 },
	{ key = "TV",         cat = "fun",     price = 900,  need = "fun",     rate = 3.0, size = { 5, 3, 1 }, color = { 20, 20, 20 }, env = 2 },
	{ key = "TVBig",      cat = "fun",     price = 4000, need = "fun",     rate = 6.0, size = { 8, 4, 1 }, color = { 10, 10, 10 }, env = 4 },
	{ key = "Sofa",       cat = "fun",     price = 700,  need = "fun",     rate = 1.5, size = { 6, 2, 3 }, color = { 150, 60, 60 }, env = 2 },
	{ key = "GameConsole", cat = "fun",    price = 2500, need = "fun",     rate = 5.0, size = { 2, 1, 2 }, color = { 40, 40, 80 }, env = 2, skill = "logic" },
	{ key = "Bookshelf",  cat = "skill",   price = 600,  need = "fun",     rate = 1.0, size = { 4, 6, 1 }, color = { 110, 80, 50 }, env = 2, skill = "logic" },
	{ key = "Computer",   cat = "skill",   price = 2200, need = "fun",     rate = 2.0, size = { 3, 3, 2 }, color = { 50, 50, 50 }, env = 2, skill = "programming" },
	{ key = "Easel",      cat = "skill",   price = 500,  need = "fun",     rate = 1.5, size = { 2, 5, 2 }, color = { 200, 200, 200 }, env = 2, skill = "painting" },
	{ key = "Guitar",     cat = "skill",   price = 700,  need = "fun",     rate = 2.0, size = { 2, 3, 1 }, color = { 160, 100, 50 }, env = 1, skill = "music" },
	{ key = "Treadmill",  cat = "skill",   price = 1800, need = "fun",     rate = 0.5, size = { 3, 4, 6 }, color = { 70, 70, 70 }, skill = "fitness" },
	{ key = "Workbench",  cat = "skill",   price = 900,  need = "fun",     rate = 0.5, size = { 5, 3, 2 }, color = { 100, 100, 100 }, skill = "handiness" },
	{ key = "GardenBox",  cat = "outdoor", price = 400,  need = "fun",     rate = 1.0, size = { 4, 1, 4 }, color = { 90, 60, 40 }, env = 2, skill = "gardening", harvest = 60 },
	{ key = "DiningTable", cat = "kitchen", price = 500, need = "social",  rate = 1.0, size = { 6, 3, 3 }, color = { 140, 100, 60 }, env = 2 },
	{ key = "Plant",      cat = "decor",   price = 150,  size = { 1, 3, 1 }, color = { 40, 140, 60 }, env = 2 },
	{ key = "Painting",   cat = "decor",   price = 400,  size = { 3, 2, 0.3 }, color = { 220, 120, 80 }, env = 3 },
	{ key = "Lamp",       cat = "decor",   price = 200,  size = { 1, 4, 1 }, color = { 240, 220, 150 }, env = 1, light = true },
	{ key = "Rug",        cat = "decor",   price = 300,  size = { 6, 0.2, 4 }, color = { 180, 60, 90 }, env = 2 },
	{ key = "Aquarium",   cat = "decor",   price = 1500, size = { 4, 3, 2 }, color = { 80, 180, 220 }, env = 5 },
	{ key = "Crib",       cat = "family",  price = 600,  size = { 3, 3, 4 }, color = { 250, 200, 220 }, env = 1, baby = true },
	{ key = "PetBed",     cat = "family",  price = 300,  size = { 3, 1, 3 }, color = { 120, 120, 160 }, env = 1, pet = true },
	{ key = "SmokeAlarm", cat = "safety",  price = 250,  size = { 1, 0.3, 1 }, color = { 250, 250, 250 }, safety = true },
	{ key = "Phone",      cat = "fun",     price = 350,  need = "social",  rate = 2.0, size = { 1, 1, 0.3 }, color = { 30, 30, 30 } },
	{ key = "Piano",      cat = "skill",   price = 5000, need = "fun",     rate = 3.0, size = { 6, 4, 3 }, color = { 15, 15, 15 }, env = 5, skill = "music" },
}
C.FoodSpoilChance = 0.08   -- กินจากตู้เย็นแล้วท้องเสีย
C.FireChance = 0.03        -- ต่อการทำอาหารเมื่อทักษะต่ำ (ลดตามทักษะ)

-- ความสัมพันธ์
C.Interactions = {
	{ key = "Chat",      friend = 5,  romance = 0,  social = 15, need = nil },
	{ key = "Joke",      friend = 8,  romance = 0,  social = 20, skill = "charisma" },
	{ key = "Compliment", friend = 6, romance = 4,  social = 10 },
	{ key = "DeepTalk",  friend = 12, romance = 0,  social = 25, minFriend = 30 },
	{ key = "Flirt",     friend = 0,  romance = 10, social = 15, minFriend = 20 },
	{ key = "Kiss",      friend = 0,  romance = 15, social = 20, minRomance = 40 },
	{ key = "AskDate",   friend = 5,  romance = 20, social = 30, minRomance = 60 },
	{ key = "Propose",   friend = 0,  romance = 0,  social = 30, minRomance = 90, marry = true },
	{ key = "Argue",     friend = -15, romance = -10, social = 5 },
	{ key = "Apologize", friend = 10, romance = 5,  social = 10 },
	{ key = "Insult",    friend = -25, romance = -20, social = 0 },
	{ key = "Hug",       friend = 8,  romance = 3,  social = 20, minFriend = 40 },
}
C.FriendAt, C.BestFriendAt = 50, 90
C.Npcs = { "Somchai", "Pim", "Ken", "Yuki", "Mei", "Arun", "Nok", "Dan", "Lisa", "Tom", "Fah", "Boss" }
C.NpcDailyDecay = 2   -- ความสัมพันธ์ลดต่อวันถ้าไม่คุย
C.BabyDays = 1        -- หลัง "ลองมีลูก" กี่วันเกมถึงคลอด
C.MaxKids = 3
C.Pets = { { key = "Dog", price = 1500 }, { key = "Cat", price = 1200 }, { key = "Rabbit", price = 600 } }
C.WeddingCost = 2000

-- ธุรกิจ (คาเฟ่)
C.Business = { key = "Cafe", price = 25000, customerEvery = { 8, 16 }, pricePerCustomer = { 40, 60, 80, 110, 150 }, employeeShare = 0.4, upgradeCost = { 5000, 12000, 25000, 50000 } }

-- เหตุการณ์สุ่มรายวัน
C.RandomEvents = {
	{ key = "Lottery",  chance = 0.03, money = 3000 },
	{ key = "Burglar",  chance = 0.05, money = -800, needsAlarm = true },
	{ key = "FriendGift", chance = 0.08, money = 300 },
	{ key = "Bonus",    chance = 0.05, money = 500, needsJob = true },
	{ key = "CarRepair", chance = 0.05, money = -400 },
	{ key = "Meteor",   chance = 0.002, deadly = true },
}
C.Festivals = {
	{ key = "NewYear",   month = 1,  day = 1,  len = 5,  gift = 500 },
	{ key = "Songkran",  month = 4,  day = 13, len = 3,  gift = 300 },
	{ key = "Halloween", month = 10, day = 25, len = 7,  gift = 300 },
	{ key = "LoyKrathong", month = 11, day = 8, len = 10, gift = 300 },
	{ key = "Christmas", month = 12, day = 20, len = 12, gift = 500 },
}
C.ForceFestival = nil
C.DailyReward = { 200, 300, 400, 500, 700, 900, 1500 }

-- Monetization (ใส่ ID จริงหลังสร้างใน Creator Dashboard)
C.GamePasses = {
	{ key = "VIP",       id = 0, robux = 199 },
	{ key = "Mansion",   id = 0, robux = 399 },
	{ key = "SportsCar", id = 0, robux = 299 },
	{ key = "PetPack",   id = 0, robux = 149 },
	{ key = "SecondLife", id = 0, robux = 249 },
}
C.DevProducts = {
	{ key = "Cash1",   id = 0, cash = 5000,  robux = 49 },
	{ key = "Cash2",   id = 0, cash = 30000, robux = 199 },
	{ key = "Cash3",   id = 0, cash = 150000, robux = 799 },
	{ key = "Elixir",  id = 0, robux = 99 },   -- ย้อนอายุ 1 ช่วงชีวิต
	{ key = "Rename",  id = 0, robux = 25 },
}
C.VIPDaily = 500
return C
