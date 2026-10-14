#!/usr/bin/env python3
"""Validate native captures and export opaque, full-resolution store JPEGs."""
import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageStat

parser = argparse.ArgumentParser()
parser.add_argument("directory", type=Path)
parser.add_argument("--device", required=True, choices=("iphone", "ipad"))
parser.add_argument("--commit", required=True)
args = parser.parse_args()
allowed = {
    "iphone": {(1179, 2556), (1206, 2622)},
    "ipad": {(2064, 2752), (2048, 2732)},
}[args.device]
names = ("01-home", "02-training-plan", "03-progress",
         "04-exercise-guides", "05-coach-feedback")
expected = {locale + "/" + name + ".png"
            for locale in ("it", "en") for name in names}
actual = {p.relative_to(args.directory / "raw").as_posix()
          for p in (args.directory / "raw").rglob("*.png")}
if actual != expected:
    raise SystemExit("Capture set mismatch. Missing: " + str(expected - actual) +
                     "; unexpected: " + str(actual - expected))
manifest = {"source_commit": args.commit, "device": args.device,
            "data": "Synthetic fixtures; no production backend", "screenshots": []}
for relative in sorted(expected):
    source = args.directory / "raw" / relative
    with Image.open(source) as image:
        image.load()
        if image.size not in allowed:
            raise SystemExit(str(source) + ": unsupported dimensions " + str(image.size))
        if "A" in image.getbands() and image.getchannel("A").getextrema() != (255, 255):
            raise SystemExit(str(source) + ": capture contains transparency")
        rgb = image.convert("RGB")
        if max(ImageStat.Stat(rgb).stddev) < 8:
            raise SystemExit(str(source) + ": appears blank or screenshot-protected")
        destination = args.directory / "ready" / Path(relative).with_suffix(".jpg")
        destination.parent.mkdir(parents=True, exist_ok=True)
        rgb.save(destination, quality=95, subsampling=0)
        manifest["screenshots"].append({
            "file": destination.relative_to(args.directory).as_posix(),
            "width": rgb.width, "height": rgb.height,
            "sha256": hashlib.sha256(destination.read_bytes()).hexdigest(),
        })
(args.directory / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print("Validated and prepared " + str(len(expected)) + " screenshots.")
