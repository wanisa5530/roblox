# Street Food Tycoon (Roblox)

เกม Tycoon ร้านอาหารข้างทางไทย เริ่มจากรถเข็นผัดไท ขยายเมนูเพื่อเพิ่มรายได้

## โครงสร้าง
- `src/ReplicatedStorage/Config.lua` เมนู ราคา ไอดี Game Pass / Dev Product
- `src/ReplicatedStorage/Remotes.lua` Remote สำหรับ client-server
- `src/ServerScriptService/DataService.lua` DataStore บันทึกอัตโนมัติ
- `src/ServerScriptService/TycoonServer.server.lua` รายได้ ซื้อเมนู Game Pass Dev Product
- `src/StarterPlayer/StarterPlayerScripts/ShopClient.client.lua` UI ชั่วคราว

## วิธีใช้
1. ติดตั้ง [Rojo](https://rojo.space) แล้วรัน `rojo serve` และเชื่อมกับ Roblox Studio
   หรือคัดลอกไฟล์ไปวางใน Studio ตามชื่อโฟลเดอร์ (`.server.lua` = Script, `.client.lua` = LocalScript, อื่น ๆ = ModuleScript)
2. เปิด API Services ใน Game Settings > Security เพื่อให้ DataStore ทำงาน
3. สร้าง Game Pass และ Developer Product ใน Creator Hub แล้วใส่ไอดีใน `Config.lua`

## การหารายได้
- Game Pass: รายได้ x2, ลูกจ้างอัตโนมัติ, ร้านที่ 2
- Dev Product: ซื้อเงินในเกม 1k / 10k / 50k
- Premium Payouts: เกมเล่นวนได้ยาว
