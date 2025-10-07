import sys
import json

# naive semver bump; integrate with ci/semver/rules.json if desired
ver = sys.argv[1]
part = sys.argv[2] if len(sys.argv) > 2 else "patch"
major, minor, patch = map(int, ver.split("."))
if part == "major":
    major += 1; minor = 0; patch = 0
elif part == "minor":
    minor += 1; patch = 0
else:
    patch += 1
print(f"{major}.{minor}.{patch}")