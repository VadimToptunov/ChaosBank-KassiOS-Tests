"""Builds mutants.json for kassios-mutants from the suite itself: every test whose doc
comment says "Catches `defectId`" (one or more ids) must turn red under that defect.

Usage: python3 tools/gen_mutants.py > mutants.json
The xcodebuild arguments are the ones CI uses; override the destination with
KASS_DEST (e.g. KASS_DEST='id=<udid>').
"""
import json
import os
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
TARGET = "ChaosBankKassiOSUITests"

mutants = {}
for path in sorted((ROOT / "UITests" / "Tests").glob("*.swift")):
    text = path.read_text()
    test_class = None
    doc = []
    for line in text.splitlines():
        stripped = line.strip()
        m = re.match(r"(final )?class (\w+)\s*:", stripped)
        if m:
            test_class = m.group(2)
            doc = []
            continue
        if stripped.startswith("///"):
            doc.append(stripped[3:])
            continue
        m = re.match(r"func (test\w+)\(", stripped)
        if m and test_class:
            joined = " ".join(doc)
            for block in re.findall(r"[Cc]atches(.*?)(?:\.\s|$)", joined):
                for defect in re.findall(r"`(\w+)`", block):
                    mutants.setdefault(defect, []).append(f"{TARGET}/{test_class}/{m.group(1)}")
            doc = []
            continue
        if stripped and not stripped.startswith("@"):
            doc = []

dest = os.environ.get("KASS_DEST", "platform=iOS Simulator,name=iPhone 17")
manifest = {
    "action": "test-without-building",
    "xcodebuild": ["-project", "ChaosBankKassiOS.xcodeproj", "-scheme", TARGET, "-destination", dest,
                   "-derivedDataPath", "DerivedData", "CODE_SIGNING_ALLOWED=NO"],
    "inject": "TEST_RUNNER_CB_INJECT_DEFECTS",
    "mutants": {k: sorted(set(v)) for k, v in sorted(mutants.items())},
}
print(json.dumps(manifest, indent=2))
