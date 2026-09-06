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
