import json
import pathlib
import re
import sys


source = (pathlib.Path(__file__).parents[1] / "Sources" / "ContentBlocker.swift").read_text(encoding="utf-8")
match = re.search(r'private static let rules = #"""\s*(\[.*?\])\s*"""#', source, re.S)
if not match:
    print("FAIL: could not find embedded blocker rules")
    sys.exit(1)

try:
    rules = json.loads(match.group(1))
except json.JSONDecodeError as error:
    print(f"FAIL: invalid JSON: {error}")
    sys.exit(1)

failures = []
for index, rule in enumerate(rules, start=1):
    pattern = rule.get("trigger", {}).get("url-filter", "")
    if "|" in pattern:
        failures.append(f"rule {index} uses unsupported alternation '|': {pattern}")

if failures:
    for failure in failures:
        print(f"FAIL: {failure}")
    sys.exit(1)

print(f"PASS: {len(rules)} blocker rules are valid JSON and avoid unsupported alternation")
