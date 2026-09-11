"""อัปโหลดไฟล์ .rbxlx ขึ้น Roblox ผ่าน Open Cloud (Place Publishing API)
ใช้: ROBLOX_API_KEY ROBLOX_UNIVERSE_ID ROBLOX_PLACE_ID python scripts/publish_place.py StreetFoodTycoon.rbxlx
"""
import os, sys, json, urllib.request, urllib.error
KEY, UNI, PLACE = (os.environ.get(k) for k in ("ROBLOX_API_KEY", "ROBLOX_UNIVERSE_ID", "ROBLOX_PLACE_ID"))
url = f"https://apis.roblox.com/universes/v1/{UNI}/places/{PLACE}/versions?versionType=Published"
data = open(sys.argv[1], "rb").read()
req = urllib.request.Request(url, method="POST", data=data, headers={"x-api-key": KEY, "Content-Type": "application/xml"})
import time
for attempt in range(5):
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            print("published version:", json.loads(r.read()).get("versionNumber")); break
    except urllib.error.HTTPError as e:
        body = e.read().decode()[:300]; print("HTTP", e.code, body)
        if e.code in (409, 500, 502, 503) and attempt < 4: time.sleep(30 * (attempt + 1)); continue
        sys.exit(1)
