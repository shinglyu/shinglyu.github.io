#!/bin/bash
# Creates a new blog draft with the current date/time in Amsterdam timezone.
# Usage: ./bin/create_draft.sh "<title>"
# Or run without arguments to be prompted for a title.

if [ -n "$1" ]; then
  TITLE="$*"
else
  echo "Please input the title:"
  read -r TITLE
fi

SLUGIFIED="$(echo -n "${TITLE}" | sed -e 's/[^[:alnum:]]/-/g' \
  | tr -s '-' | tr A-Z a-z)"

# Use Amsterdam timezone so the post date is always in the past and renders correctly
TIME=$(TZ="Europe/Amsterdam" date +"%Y-%m-%d %H:%M:%S %:z")

OUTFILE="_drafts/${SLUGIFIED}.md"

cp _drafts/template.md "${OUTFILE}"
sed -i "s/title: TODO/title: ${TITLE}/g" "${OUTFILE}"
sed -i "s/date: 2010-01-01 00:00:00 +08:00/date: ${TIME}/g" "${OUTFILE}"

echo "File generated: ${OUTFILE}"
cat "${OUTFILE}"
