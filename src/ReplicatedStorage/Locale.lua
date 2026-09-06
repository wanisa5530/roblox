-- ข้อความ UI หลายภาษา
local L = {}
L.Supported = { "en", "th", "ja", "zh", "id" }
L.Names = { en="English", th="ไทย", ja="日本語", zh="中文", id="Indonesia" }
L.Strings = {
	en = { title="Street Food Tycoon", cash="Cash", perSec="/sec", collect="Collect", owned="OWNED", buy="Buy", menu="Menu", passes="Passes", robux="Robux", notEnough="Not enough cash!", bought="Opened: %s",
		DoubleIncome="2x Income", AutoCollect="Auto Collect", VIP="VIP (+50%)", Cash1="+5,000 Cash", Cash2="+50,000 Cash", Cash3="+500,000 Cash", lang="Language" },
	th = { title="สตรีทฟู้ดไทคูน", cash="เงิน", perSec="/วิ", collect="เก็บเงิน", owned="มีแล้ว", buy="ซื้อ", menu="เมนู", passes="แพ็กเกจ", robux="Robux", notEnough="เงินไม่พอ!", bought="เปิดร้าน: %s",
		DoubleIncome="รายได้ x2", AutoCollect="เก็บเงินอัตโนมัติ", VIP="VIP (+50%)", Cash1="+5,000 เงิน", Cash2="+50,000 เงิน", Cash3="+500,000 เงิน", lang="ภาษา" },
	ja = { title="屋台タイクーン", cash="所持金", perSec="/秒", collect="回収", owned="所有済み", buy="購入", menu="メニュー", passes="パス", robux="Robux", notEnough="お金が足りません！", bought="開店: %s",
		DoubleIncome="収入2倍", AutoCollect="自動回収", VIP="VIP (+50%)", Cash1="+5,000", Cash2="+50,000", Cash3="+500,000", lang="言語" },
	zh = { title="街头小吃大亨", cash="现金", perSec="/秒", collect="收取", owned="已拥有", buy="购买", menu="菜单", passes="通行证", robux="Robux", notEnough="现金不足！", bought="开张: %s",
		DoubleIncome="双倍收入", AutoCollect="自动收取", VIP="VIP (+50%)", Cash1="+5,000 现金", Cash2="+50,000 现金", Cash3="+500,000 现金", lang="语言" },
	id = { title="Street Food Tycoon", cash="Uang", perSec="/dtk", collect="Ambil", owned="DIMILIKI", buy="Beli", menu="Menu", passes="Pass", robux="Robux", notEnough="Uang tidak cukup!", bought="Dibuka: %s",
		DoubleIncome="Pendapatan 2x", AutoCollect="Ambil Otomatis", VIP="VIP (+50%)", Cash1="+5.000 Uang", Cash2="+50.000 Uang", Cash3="+500.000 Uang", lang="Bahasa" },
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
