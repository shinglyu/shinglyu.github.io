#!/bin/bash
# Moves a draft to _posts/ with a properly timestamped filename.
# Usage: ./bin/publish.sh [-y] <draft_file>
#   -y  Skip the confirmation prompt (useful for non-interactive/agent use)
#
# Time rules (Amsterdam timezone):
#   - If the current moment falls within working hours (Mon–Fri 09:00–18:00),
#     the publish timestamp is shifted to 8:30 AM with a small random jitter
#     (±5 min) so the post always appears before the workday starts.
#   - Otherwise the current time is used as-is.

AUTO_CONFIRM=false
if [ "$1" = "-y" ]; then
  AUTO_CONFIRM=true
  shift
fi

# Check if the input parameter is provided and is a valid file
if [ -z "$1" ]; then
  echo "Usage: $0 [-y] <draft_file>"
  exit 1
elif [ ! -f "$1" ]; then
  echo "File $1 does not exist"
  exit 2
fi

# All date/time calculations use Amsterdam timezone
TZ_AMSTERDAM="Europe/Amsterdam"

DAY_OF_WEEK=$(TZ="$TZ_AMSTERDAM" date +%u)   # 1=Mon … 7=Sun
CURRENT_HOUR=$(TZ="$TZ_AMSTERDAM" date +%H)
CURRENT_MIN=$(TZ="$TZ_AMSTERDAM" date +%M)
CURRENT_TOTAL_MIN=$(( 10#$CURRENT_HOUR * 60 + 10#$CURRENT_MIN ))

WORK_START=$(( 9 * 60 ))   # 09:00 = 540 min
WORK_END=$(( 18 * 60 ))    # 18:00 = 1080 min

# Detect working hours on a weekday
DURING_WORK_HOURS=false
if [ "$DAY_OF_WEEK" -ge 1 ] && [ "$DAY_OF_WEEK" -le 5 ]; then
  if [ "$CURRENT_TOTAL_MIN" -ge "$WORK_START" ] && [ "$CURRENT_TOTAL_MIN" -lt "$WORK_END" ]; then
    DURING_WORK_HOURS=true
  fi
fi

if [ "$DURING_WORK_HOURS" = "true" ]; then
  # Base: 08:30, jitter: random value in [-5, +5] minutes
  JITTER=$(( (RANDOM % 11) - 5 ))
  BASE_TOTAL_MIN=$(( 8 * 60 + 30 ))   # 510 minutes
  ADJUSTED_TOTAL_MIN=$(( BASE_TOTAL_MIN + JITTER ))
  # Safety cap: never let the time reach 09:00 or later
  if [ "$ADJUSTED_TOTAL_MIN" -ge "$WORK_START" ]; then
    ADJUSTED_TOTAL_MIN=$(( WORK_START - 1 ))   # 08:59
  fi
  ADJUSTED_HOUR=$(( ADJUSTED_TOTAL_MIN / 60 ))
  ADJUSTED_MIN_PART=$(( ADJUSTED_TOTAL_MIN % 60 ))
  DATE_PART=$(TZ="$TZ_AMSTERDAM" date +"%Y-%m-%d")
  TZ_OFFSET=$(TZ="$TZ_AMSTERDAM" date +"%:z")
  TIME="${DATE_PART} $(printf '%02d:%02d:00' "$ADJUSTED_HOUR" "$ADJUSTED_MIN_PART") ${TZ_OFFSET}"
  echo "Working hours detected: adjusting publish time to $(printf '%02d:%02d' "$ADJUSTED_HOUR" "$ADJUSTED_MIN_PART") Amsterdam time (before work hours)"
else
  TIME=$(TZ="$TZ_AMSTERDAM" date +"%Y-%m-%d %H:%M:%S %:z")
fi

DATE=$(TZ="$TZ_AMSTERDAM" date +"%Y-%m-%d-")

# Get the base name of the input file and construct the output file name
POST=$(basename "${1}")
OUTPUT="_posts/${DATE}${POST}"

# Copy the input file to the output file and update the date field
echo "Copying ${1} to ${OUTPUT}"
cp "${1}" "${OUTPUT}"
echo "Setting the time to ${TIME}"
sed -i "s/^date: .*$/date: ${TIME}/g" "${OUTPUT}"

# Show a preview of the output file and ask for confirmation
echo "Is this OK?"
echo "========================="
head "${OUTPUT}"
echo "========================="

# If the user confirms (or -y flag was passed), add the output file to git and remove the input file
if [ "$AUTO_CONFIRM" = "true" ]; then
  answer="y"
else
  read -p "Enter y or n: " answer
fi
if [ "$answer" = "y" ]; then
  git add "${OUTPUT}"
  echo "Removing ${1}"
  rm "${1}"
  git add -A "${1}"
else
  echo "Aborting"
  rm "${OUTPUT}"
fi
