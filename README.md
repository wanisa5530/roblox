# Street Food Tycoon (Roblox)

เกม Tycoon ร้านอาหารข้างทางไทย เริ่มจากรถเข็นผัดไท ขยายเมนูเพื่อเพิ่มรายได้

## โครงสร้าง






## วิธีใช้
1. ติดตั้ง [Rojo](https://rojo.space) แล้วรัน `rojo serve` และเชื่อมกับ Roblox Studio
   หรือคัดลอกไฟล์ไปวางใน Studio ตามชื่อโฟลเดอร์ (`.server.lua` = Script, `.client.lua` = LocalScript, อื่น ๆ = ModuleScript)
2. เปิด API Services ใน Game Settings > Security เพื่อให้ DataStore ทำงาน
3. สร้าง Game Pass และ Developer Product ใน Creator Hub แล้วใส่ไอดีใน `Config.lua`

## การหารายได้
- Game Pass: รายได้ x2, ลูกจ้างอัตโนมัติ, ร้านที่ 2
- Dev Product: ซื้อเงินในเกม 1k / 10k / 50k
- Premium Payouts: เกมเล่นวนได้ยาว

## เวอร์ชัน 2
- เมนูอาหารข้างทางไทย 15 อย่าง (หมูปิ้ง ถึง รถเข็นทุเรียน)
- 5 ภาษา: ไทย อังกฤษ ญี่ปุ่น จีน อินโดนีเซีย (`src/ReplicatedStorage/Locale.lua`) ตรวจจากภาษาเครื่องผู้เล่น สลับได้ด้วยปุ่ม 🌐
- แปลงร้านส่วนตัวสูงสุด 8 คน แผงอาหารโผล่ตามเมนูที่ซื้อ (`src/ServerScriptService/PlotService.lua`)
- เก็บเงินได้ 2 ทาง: ปุ่มบน UI หรือเดินเหยียบแผ่นเหลืองหน้าร้าน
- Leaderboard: leaderstats ในเกม + อันดับรวมทุกเซิร์ฟเวอร์ (OrderedDataStore) + ป้ายในแมพ (`LeaderboardService.lua`)
- ล็อกอินรายวัน สตรีค 7 วัน รางวัลใน `Config.DailyRewards`

## ทดสอบบนเซิร์ฟเวอร์ (ไม่มี Studio)
```
/tmp/luau/luau-analyze src/**/*.lua   # ตรวจไวยากรณ์และ lint
rojo build -o StreetFoodTycoon.rbxlx  # สร้างไฟล์เกม
```

## ทดสอบอัตโนมัติ (GitHub Actions)
ตั้ง Secrets ใน GitHub: `ROBLOX_API_KEY`, `ROBLOX_UNIVERSE_ID`, `ROBLOX_PLACE_ID`
- ทุก push: lint + build ไฟล์เกม (ดาวน์โหลดได้จากแท็บ Actions > Artifacts)
- push ไป main หรือกด Run workflow: รัน `tests/smoke.luau` บนเกมที่ publish ผ่าน Open Cloud
