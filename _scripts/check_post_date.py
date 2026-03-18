#!/usr/bin/env python3
"""
check_post_date.py - Verify that a Jekyll post's front matter date matches today's date.

Usage:
    python3 _scripts/check_post_date.py _posts/YYYY-MM-DD-my-post.md

Exits with code 0 if the date is today, 1 otherwise.
This script is used in the publishing workflow to enforce that the `date`
field is always set to the actual publication date.
"""

import sys
import re
import datetime


def check_post_date(filepath):
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"ERROR: File not found: {filepath}")
        return False

    # Extract the date portion (YYYY-MM-DD) from the front matter date field.
    # Note: the full field may include time and timezone (e.g. "2026-03-18 21:57:22 +0000"),
    # but only the date portion is checked here. The time component is not validated.
    match = re.search(r"^date:\s*(\d{4}-\d{2}-\d{2})", content, re.MULTILINE)
    if not match:
        print(f"ERROR: No 'date' field found in front matter of {filepath}")
        return False

    post_date_str = match.group(1)
    today_str = datetime.date.today().strftime("%Y-%m-%d")

    if post_date_str == today_str:
        print(f"OK: Post date {post_date_str} matches today ({today_str}).")
        return True
    else:
        print(
            f"ERROR: Post date {post_date_str} does NOT match today ({today_str}).\n"
            f"  Please update the 'date' field in {filepath} to today's date and time."
        )
        return False


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 _scripts/check_post_date.py <post_file>")
        sys.exit(1)

    success = check_post_date(sys.argv[1])
    sys.exit(0 if success else 1)
