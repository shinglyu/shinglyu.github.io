#!/usr/bin/env bash
set -euo pipefail

# Checks that any changed draft/post markdown files have the editorial review
# front matter flags (grammar_checked, fact_checked) set to true. Changed
# drafts must also be available in the publish workflow chooser.
#
# If no _drafts/ or _posts/ markdown files were changed, this script exits 0
# without performing any checks, so unrelated PRs are not blocked.
#
# Usage: check_editorial_review.sh <base-ref> <head-ref>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

BASE_REF="${1:-}"
HEAD_REF="${2:-HEAD}"

if [ -z "${BASE_REF}" ]; then
  echo "Usage: $0 <base-ref> [head-ref]"
  exit 1
fi

cd "${REPO_ROOT}"

MERGE_BASE="$(git merge-base "${BASE_REF}" "${HEAD_REF}")"

mapfile -t CHANGED_FILES < <(git diff --name-only --diff-filter=ACMR "${MERGE_BASE}" "${HEAD_REF}" -- '_drafts/*.md' '_posts/*.md')

if [ "${#CHANGED_FILES[@]}" -eq 0 ]; then
  echo "No draft or post markdown files changed. Skipping editorial review check."
  exit 0
fi

FAILED=0

for FILE in "${CHANGED_FILES[@]}"; do
  if [ ! -f "${FILE}" ]; then
    # File was deleted/renamed away; nothing to check.
    continue
  fi

  if ! python3 - "${FILE}" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
expected_value = "true"

front_matter_match = re.match(r"^---\r?\n(.*?\r?\n)---(?:\r?\n|$)", text, re.DOTALL)
if not front_matter_match:
    print(f"Error: {path} is missing or has incomplete YAML front matter")
    raise SystemExit(1)

front_matter = front_matter_match.group(1)
values = {}
for line in front_matter.splitlines():
    match = re.match(r"^(grammar_checked|fact_checked):\s*(.+?)\s*$", line)
    if match:
        values[match.group(1)] = match.group(2).strip().strip("'\"").lower()

missing = [key for key in ("grammar_checked", "fact_checked") if values.get(key) != expected_value]
if missing:
    print(f"Error: {path} has not completed editorial review. Set these flags to true: {', '.join(missing)}")
    raise SystemExit(1)

if path.parts[0] == "_drafts":
    publish_workflow = Path(".github/workflows/publish.yml")
    workflow = publish_workflow.read_text(encoding="utf-8")
    chooser = re.search(
        r"file_name:\s*\n[\s\S]*?^\s+options:\s*\n([\s\S]*?)(?=^\s+\w+:)",
        workflow,
        re.MULTILINE,
    )
    if not chooser:
        print(f"Error: could not read file_name options from {publish_workflow}")
        raise SystemExit(1)
    options = chooser.group(1)
    filenames = {
        match.group(1)
        for match in re.finditer(r'^\s+-\s+["\']?([^"\'\s]+)["\']?\s*$', options, re.MULTILINE)
    }
    if path.name not in filenames:
        print(f"Error: {path} is missing from the publish workflow chooser")
        raise SystemExit(1)
PY
  then
    FAILED=1
  fi
done

if [ "${FAILED}" -ne 0 ]; then
  echo ""
  echo "Editorial review check failed. Set grammar_checked and fact_checked to true in the front matter before merging."
  exit 1
fi

echo "Editorial review check passed."
