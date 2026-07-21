#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DRAFTS_DIR="${REPO_ROOT}/_drafts"
POSTS_DIR="${REPO_ROOT}/_posts"
WORKFLOW_FILE="${REPO_ROOT}/.github/workflows/publish.yml"

usage() {
  echo "Usage: $0 <draft-file-name>"
  exit 1
}

[ "${1:-}" != "" ] || usage

FILE_NAME="$(basename "$1")"
SOURCE_FILE="${DRAFTS_DIR}/${FILE_NAME}"
PLACEHOLDER_FILE="placeholder-use-this-if-sync-only.md"

if [ "${FILE_NAME}" = "${PLACEHOLDER_FILE}" ]; then
  echo "Error: Select a real draft file instead of the placeholder option"
  exit 1
fi

if [ ! -f "${SOURCE_FILE}" ]; then
  echo "Error: Draft file not found: ${SOURCE_FILE}"
  exit 1
fi

python3 - "${SOURCE_FILE}" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
expected_value = "true"

if not text.startswith("---\n"):
    print(f"Error: {path} is missing YAML front matter")
    raise SystemExit(1)

parts = text.split("---\n", 2)
if len(parts) < 3:
    print(f"Error: {path} has incomplete YAML front matter")
    raise SystemExit(1)

front_matter = parts[1]
values = {}
for line in front_matter.splitlines():
    match = re.match(r"^(grammar_checked|fact_checked):\s*(.+?)\s*$", line)
    if match:
        values[match.group(1)] = match.group(2).strip().strip("'\"").lower()

missing = [key for key in ("grammar_checked", "fact_checked") if values.get(key) != expected_value]
if missing:
    print(f"Error: {path.name} is not ready to publish. Set these flags to true: {', '.join(missing)}")
    raise SystemExit(1)
PY

TODAY="$(date -u +%F)"
# Publishing normalizes the front matter timestamp to midnight UTC for the current UTC date.
PUBLISHED_AT="${TODAY}T00:00:00Z"
DESTINATION_FILE="${POSTS_DIR}/${TODAY}-${FILE_NAME}"

if [ -e "${DESTINATION_FILE}" ]; then
  echo "Error: Published post already exists: ${DESTINATION_FILE}"
  exit 1
fi

mv "${SOURCE_FILE}" "${DESTINATION_FILE}"

python3 - "${DESTINATION_FILE}" "${WORKFLOW_FILE}" "${FILE_NAME}" "${PUBLISHED_AT}" <<'PY'
import re
import sys
from pathlib import Path

post_path = Path(sys.argv[1])
workflow_path = Path(sys.argv[2])
file_name = sys.argv[3]
published_at = sys.argv[4]

post_text = post_path.read_text(encoding="utf-8")
parts = post_text.split("---\n", 2)
if len(parts) < 3:
    print(f"Error: {post_path} is missing YAML front matter")
    raise SystemExit(1)

front_matter = parts[1]
body = parts[2]
date_pattern = r"^date:\s*.*$"
if re.search(date_pattern, front_matter, flags=re.MULTILINE):
    front_matter = re.sub(date_pattern, f"date: {published_at}", front_matter, count=1, flags=re.MULTILINE)
else:
    front_matter = f"date: {published_at}\n{front_matter}"
post_text = f"---\n{front_matter}---\n{body}"
post_path.write_text(post_text, encoding="utf-8")

lines = workflow_path.read_text(encoding="utf-8").splitlines()
updated_lines = []
in_file_name = False
in_options = False
file_indent = None
options_indent = None

for line in lines:
    stripped = line.lstrip()
    indent = len(line) - len(stripped)

    if in_options and stripped and indent <= options_indent:
        in_options = False
    if in_file_name and stripped and indent <= file_indent and not stripped.startswith("file_name:"):
        in_file_name = False

    if stripped.startswith("file_name:"):
        in_file_name = True
        file_indent = indent
        updated_lines.append(line)
        continue

    if in_file_name and stripped.startswith("options:"):
        in_options = True
        options_indent = indent
        updated_lines.append(line)
        continue

    if in_options:
        normalized = stripped.removeprefix("-").strip().strip("'\"")
        if normalized == file_name:
            continue

    updated_lines.append(line)

workflow_path.write_text("\n".join(updated_lines) + "\n", encoding="utf-8")
PY

cd "${REPO_ROOT}"
git config user.name "${GIT_AUTHOR_NAME:-github-actions[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-github-actions[bot]@users.noreply.github.com}"
git add "${DESTINATION_FILE}" "${WORKFLOW_FILE}"
git rm --quiet --ignore-unmatch "${SOURCE_FILE}"
git commit -m "Publish ${FILE_NAME}"

BRANCH_NAME="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"
if [ "${BRANCH_NAME}" = "HEAD" ] || [ -z "${BRANCH_NAME}" ]; then
  BRANCH_NAME="main"
fi

git push origin "HEAD:${BRANCH_NAME}"
