"""อัปโหลดไฟล์ .rbxlx ขึ้น Roblox ผ่าน Open Cloud (Place Publishing API)
ใช้: ROBLOX_API_KEY ROBLOX_UNIVERSE_ID ROBLOX_PLACE_ID python scripts/publish_place.py StreetFoodTycoon.rbxlx
"""
import os, sys, json, urllib.request, urllib.error
KEY, UNI, PLACE = (os.environ.get(k) for k in ("ROBLOX_API_KEY", "ROBLOX_UNIVERSE_ID", "ROBLOX_PLACE_ID"))
url = f"https://apis.roblox.com/universes/v1/{UNI}/places/{PLACE}/versions?versionType=Published"
data = open(sys.argv[1], "rb").read()
req = urllib.request.Request(url, method="POST", data=data, headers={"x-api-key": KEY, "Content-Type": "application/xml"})
try:
    with urllib.request.urlopen(req, timeout=120) as r:
        ver = json.loads(r.read()).get("versionNumber")
        print("published version:", ver)
        # บันทึกเวอร์ชันลง DataStore "Meta" เพื่อให้เซิร์ฟเวอร์เก่ารู้ว่ามีอัปเดตแล้วเตะผู้เล่นออกให้เข้าใหม่
        ds = f"https://apis.roblox.com/datastores/v1/universes/{UNI}/standard-datastores/datastore/entries/entry?datastoreName=Meta&entryKey=version"
        rq = urllib.request.Request(ds, method="POST", data=json.dumps(ver).encode(), headers={"x-api-key": KEY, "Content-Type": "application/json"})
        try:
            urllib.request.urlopen(rq, timeout=30); print("meta version set:", ver)
        except urllib.error.HTTPError as e2: print("meta set failed", e2.code, e2.read().decode()[:200])
except urllib.error.HTTPError as e:
    print("HTTP", e.code, e.read().decode()[:500]); sys.exit(1)
