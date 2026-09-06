-- รายการเสียง: ค่าเริ่มต้นใช้เสียงในตัว Roblox (rbxasset) แทนด้วย "rbxassetid://<id>" จาก Creator Store ได้ทุกตัว
-- music = 0 คือปิด ใส่ไอดีเพลงจาก Creator Store เพื่อเปิด
return {
	music     = { id = "", volume = 0.25, loop = true },
	order     = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.6 }, -- ลูกค้าสั่ง
	cash      = { id = "rbxasset://sounds/snap.mp3", volume = 0.7 },               -- ได้เงิน
	perfect   = { id = "rbxasset://sounds/action_get_up.mp3", volume = 0.6 },      -- ทำสุดยอด
	fail      = { id = "rbxasset://sounds/uuhhh.mp3", volume = 0.6 },              -- ไหม้/ผิด/ลูกค้าหนี
	click     = { id = "rbxasset://sounds/button.wav", volume = 0.4 },             -- คลิกในมินิเกม
	cook      = { id = "rbxasset://sounds/impact_water.mp3", volume = 0.5, loop = true }, -- เสียงผัด/ย่างระหว่างทำ
	serve     = { id = "rbxasset://sounds/swoosh.wav", volume = 0.5 },             -- เสิร์ฟ/หยิบ
	wash      = { id = "rbxasset://sounds/impact_water.mp3", volume = 0.4 },       -- ล้างจาน
	ui        = { id = "rbxasset://sounds/clickfast.wav", volume = 0.3 },          -- เปิดเมนู
}
