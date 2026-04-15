#!/usr/bin/env python3
"""Validate JSON files and marketplace.json schema."""

import json
import os
import sys


def find_json_files(root="."):
    """Find all .json files excluding .claude/ directory."""
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if not (dirpath == root and d == ".claude")]
        for f in filenames:
            if f.endswith(".json"):
                files.append(os.path.join(dirpath, f))
    return sorted(files)


def validate_syntax(files):
    """Validate JSON syntax for all files. Returns number of failures."""
    failures = 0
    for path in files:
        try:
            with open(path) as f:
                json.load(f)
            print(f"PASS: {path}")
        except json.JSONDecodeError as e:
            print(f"FAIL: {path} — {e}")
            failures += 1
    return failures


def validate_marketplace(path=".claude-plugin/marketplace.json"):
    """Validate marketplace.json required fields. Returns number of failures."""
    if not os.path.isfile(path):
        print(f"No {path} found, skipping marketplace check")
        return 0

    with open(path) as f:
        data = json.load(f)

    failures = 0

    # Required top-level fields
    for field in ("name", "owner", "plugins"):
        if field in data:
            print(f"PASS: field '{field}' present")
        else:
            print(f"FAIL: missing required field '{field}'")
            failures += 1

    # owner must be an object with name
    owner = data.get("owner")
    if isinstance(owner, dict) and "name" in owner:
        print("PASS: owner.name present")
    else:
        print("FAIL: 'owner' must be an object with a 'name' field")
        failures += 1

    # Each plugin must have name and source
    for i, plugin in enumerate(data.get("plugins", [])):
        for field in ("name", "source"):
            if field in plugin:
                print(f"PASS: plugins[{i}].{field} present")
            else:
                print(f"FAIL: plugins[{i}] missing required field '{field}'")
                failures += 1

    return failures


def main():
    files = find_json_files()
    if not files:
        print("No JSON files found")
        return

    print("=== JSON Syntax ===")
    failures = validate_syntax(files)

    print()
    print("=== Marketplace Schema ===")
    failures += validate_marketplace()

    if failures:
        print(f"\n{failures} check(s) failed")
        sys.exit(1)
    else:
        print("\nAll checks passed")


if __name__ == "__main__":
    main()
