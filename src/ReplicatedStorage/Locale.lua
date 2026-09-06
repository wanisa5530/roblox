-- ข้อความ UI หลายภาษา
local L = {}
L.Supported = { "en", "th", "ja", "zh", "id" }
L.Names = { en="English", th="ไทย", ja="日本語", zh="中文", id="Indonesia" }
L.Strings = {
	en = { pack="Pack", clean="Clean table", takeaway="Takeaway", needBag="Pack it in a bag first!", tableDirty="Dirty table!", portions="portions", noTable="No free table", cook="Cook", serve="Serve", holding="Holding", rep="Reputation", served="Served", wrongDish="Wrong dish!", noDish="Cook the order first", left="Customer left", tip="Tip", burnt="Burnt!", mgTiming="Press SPACE in the green zone!", mgMash="Click fast!", mgFlip="Wait... then press SPACE before it burns!", perfect="Perfect!", good="Good", ok="Okay", AutoChef="Auto Chef", customer="Customer", daily="Daily Reward", day="Day %d", claim="Claim", claimed="Come back tomorrow!", top="Top Tycoons", you="You", title="Street Food Tycoon", cash="Cash", perSec="/sec", collect="Collect", owned="OWNED", buy="Buy", menu="Menu", passes="Passes", robux="Robux", notEnough="Not enough cash!", bought="Opened: %s",
		DoubleIncome="2x Income", VIP="VIP (+50%)", Cash1="+5,000 Cash", Cash2="+50,000 Cash", Cash3="+500,000 Cash", lang="Language" },
	th = { pack="ใส่ถุง", clean="เก็บโต๊ะ", takeaway="ซื้อกลับ", needBag="ใส่ถุงก่อน!", tableDirty="โต๊ะสกปรก!", portions="ที่", noTable="โต๊ะเต็ม", cook="ทำอาหาร", serve="เสิร์ฟ", holding="ถืออยู่", rep="ชื่อเสียง", served="เสิร์ฟแล้ว", wrongDish="ผิดเมนู!", noDish="ทำอาหารตามออเดอร์ก่อน", left="ลูกค้าเดินหนี", tip="ทิป", burnt="ไหม้!", mgTiming="กด SPACE ตอนเข็มอยู่โซนเขียว!", mgMash="คลิกรัว ๆ!", mgFlip="รอ... แล้วกด SPACE ก่อนไหม้!", perfect="สุดยอด!", good="ดี", ok="พอใช้", AutoChef="พ่อครัวอัตโนมัติ", customer="ลูกค้า", daily="รางวัลรายวัน", day="วันที่ %d", claim="รับรางวัล", claimed="พรุ่งนี้มาใหม่นะ!", top="เศรษฐีอันดับต้น", you="คุณ", title="สตรีทฟู้ดไทคูน", cash="เงิน", perSec="/วิ", collect="เก็บเงิน", owned="มีแล้ว", buy="ซื้อ", menu="เมนู", passes="แพ็กเกจ", robux="Robux", notEnough="เงินไม่พอ!", bought="เปิดร้าน: %s",
		DoubleIncome="รายได้ x2", VIP="VIP (+50%)", Cash1="+5,000 เงิน", Cash2="+50,000 เงิน", Cash3="+500,000 เงิน", lang="ภาษา" },
	ja = { pack="袋詰め", clean="片付け", takeaway="持ち帰り", needBag="先に袋に入れて！", tableDirty="テーブルが汚れている！", portions="人前", noTable="満席", cook="調理", serve="提供", holding="所持", rep="評判", served="提供数", wrongDish="違う料理！", noDish="先に注文を調理", left="客が帰った", tip="チップ", burnt="焦げた！", mgTiming="緑ゾーンでSPACE！", mgMash="連打！", mgFlip="待って…焦げる前にSPACE！", perfect="完璧！", good="良い", ok="まあまあ", AutoChef="自動シェフ", customer="客", daily="デイリー報酬", day="%d日目", claim="受け取る", claimed="また明日！", top="トップ長者", you="あなた", title="屋台タイクーン", cash="所持金", perSec="/秒", collect="回収", owned="所有済み", buy="購入", menu="メニュー", passes="パス", robux="Robux", notEnough="お金が足りません！", bought="開店: %s",
		DoubleIncome="収入2倍", VIP="VIP (+50%)", Cash1="+5,000", Cash2="+50,000", Cash3="+500,000", lang="言語" },
	zh = { pack="打包", clean="收拾桌子", takeaway="外带", needBag="先打包！", tableDirty="桌子脏了！", portions="份", noTable="没有空桌", cook="烹饪", serve="上菜", holding="手持", rep="声誉", served="已上菜", wrongDish="菜错了！", noDish="先做订单的菜", left="顾客走了", tip="小费", burnt="糊了！", mgTiming="绿区按SPACE！", mgMash="快速点击！", mgFlip="等待…糊之前按SPACE！", perfect="完美！", good="不错", ok="一般", AutoChef="自动厨师", customer="顾客", daily="每日奖励", day="第 %d 天", claim="领取", claimed="明天再来！", top="富豪榜", you="你", title="街头小吃大亨", cash="现金", perSec="/秒", collect="收取", owned="已拥有", buy="购买", menu="菜单", passes="通行证", robux="Robux", notEnough="现金不足！", bought="开张: %s",
		DoubleIncome="双倍收入", VIP="VIP (+50%)", Cash1="+5,000 现金", Cash2="+50,000 现金", Cash3="+500,000 现金", lang="语言" },
	id = { pack="Bungkus", clean="Bersihkan meja", takeaway="Bawa pulang", needBag="Bungkus dulu!", tableDirty="Meja kotor!", portions="porsi", noTable="Meja penuh", cook="Masak", serve="Sajikan", holding="Dipegang", rep="Reputasi", served="Tersaji", wrongDish="Salah menu!", noDish="Masak pesanan dulu", left="Pelanggan pergi", tip="Tip", burnt="Gosong!", mgTiming="Tekan SPACE di zona hijau!", mgMash="Klik cepat!", mgFlip="Tunggu... tekan SPACE sebelum gosong!", perfect="Sempurna!", good="Bagus", ok="Lumayan", AutoChef="Koki Otomatis", customer="Pelanggan", daily="Hadiah Harian", day="Hari %d", claim="Ambil", claimed="Kembali besok!", top="Taipan Teratas", you="Kamu", title="Street Food Tycoon", cash="Uang", perSec="/dtk", collect="Ambil", owned="DIMILIKI", buy="Beli", menu="Menu", passes="Pass", robux="Robux", notEnough="Uang tidak cukup!", bought="Dibuka: %s",
		DoubleIncome="Pendapatan 2x", VIP="VIP (+50%)", Cash1="+5.000 Uang", Cash2="+50.000 Uang", Cash3="+500.000 Uang", lang="Bahasa" },
}
function L.detect(localeId)
	local p = string.sub(localeId or "en", 1, 2)
	for _, s in ipairs(L.Supported) do if s == p then return s end end
	return "en"
end
function L.get(lang, key) return (L.Strings[lang] or L.Strings.en)[key] or L.Strings.en[key] or key end
function L.food(lang, id)
	local n = require(script.Parent.Config).FoodNames[id]
	return n and (n[lang] or n.en) or id
end
function L.fmt(n)
	n = math.floor(n)
	if n >= 1e9 then return string.format("%.2fB", n/1e9) end
	if n >= 1e6 then return string.format("%.2fM", n/1e6) end
	if n >= 1e4 then return string.format("%.1fK", n/1e3) end
	return tostring(n)
end
return L
