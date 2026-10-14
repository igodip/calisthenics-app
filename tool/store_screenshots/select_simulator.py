#!/usr/bin/env python3
"""Select an installed simulator in an App Store required screenshot family."""
import json
import re
import subprocess
import sys

family = sys.argv[1]
if family not in ("iphone", "ipad"):
    raise SystemExit("Expected iphone or ipad")
inventory = json.loads(subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "--json"], text=True
))
candidates = []
for runtime, devices in inventory["devices"].items():
    if ".iOS-" not in runtime:
        continue
    runtime_version = tuple(int(v) for v in runtime.split(".iOS-")[1].split("-"))
    for device in devices:
        name = device["name"]
        eligible = (
            re.fullmatch(r"iPhone (14 Pro|15|15 Pro|16|16 Pro|17|17 Pro|18 Pro)", name)
            if family == "iphone"
            else "iPad" in name and ("13-inch" in name or "12.9-inch" in name)
        )
        if eligible and device.get("isAvailable", False):
            candidates.append((runtime_version, name, device["udid"]))
if not candidates:
    raise SystemExit("No supported " + family + " simulator installed. Available: " +
                     json.dumps(inventory["devices"], indent=2))
_, name, udid = sorted(candidates, reverse=True)[0]
print("Selected " + name + " (" + udid + ")", file=sys.stderr)
print(udid)
