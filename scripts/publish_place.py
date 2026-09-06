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
        print("published version:", json.loads(r.read()).get("versionNumber"))
except urllib.error.HTTPError as e:
    print("HTTP", e.code, e.read().decode()[:500]); sys.exit(1)
