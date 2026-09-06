"""รันสคริปต์ Luau บนเกมที่ publish แล้วผ่าน Roblox Open Cloud (Luau Execution API)
ใช้: ROBLOX_API_KEY ROBLOX_UNIVERSE_ID ROBLOX_PLACE_ID python scripts/run_luau_test.py tests/smoke.luau
"""
import json, os, sys, time, urllib.request

KEY, UNI, PLACE = (os.environ.get(k) for k in ("ROBLOX_API_KEY", "ROBLOX_UNIVERSE_ID", "ROBLOX_PLACE_ID"))
if not all((KEY, UNI, PLACE)):
    sys.exit("missing ROBLOX_API_KEY / ROBLOX_UNIVERSE_ID / ROBLOX_PLACE_ID")
BASE = f"https://apis.roblox.com/cloud/v2/universes/{UNI}/places/{PLACE}"

def call(method, url, body=None):
    req = urllib.request.Request(url, method=method, headers={"x-api-key": KEY, "Content-Type": "application/json"},
                                 data=json.dumps(body).encode() if body else None)
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read() or b"{}")

script = open(sys.argv[1], encoding="utf-8").read()
task = call("POST", f"{BASE}/luau-execution-session-tasks", {"script": script})
path = task["path"]
print("task:", path)
for _ in range(120):
    time.sleep(3)
    task = call("GET", f"https://apis.roblox.com/cloud/v2/{path}")
    if task["state"] in ("COMPLETE", "FAILED", "CANCELLED"):
        break
logs = call("GET", f"https://apis.roblox.com/cloud/v2/{path}/logs")
for page in logs.get("luauExecutionSessionTaskLogs", []):
    for line in page.get("messages", []):
        print("  |", line)
print("state:", task["state"])
if task["state"] != "COMPLETE":
    print(json.dumps(task.get("error"), indent=1, ensure_ascii=False)); sys.exit(1)
results = task.get("output", {}).get("results", [])
print("results:", json.dumps(results, ensure_ascii=False))
if results and results[0] is not True:
    sys.exit(1)
