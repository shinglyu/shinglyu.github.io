#!/bin/bash

# Check if the input parameter is provided and is a valid file
if [ -z "$1" ]; then
  echo "Usage: $0 <draft_file>"
  exit 1
elif [ ! -f "$1" ]; then
  echo "File $1 does not exist"
  exit 2
fi

# Get the current time and date in the desired format
TIME=$(date +"%Y-%m-%d %H:%M:%S %:z")
DATE=$(date +"%Y-%m-%d-")

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

# If the user confirms, add the output file to git and remove the input file
read -p "Enter y or n: " answer
if [ "$answer" = "y" ]; then
  git add "${OUTPUT}"
  echo "Removing ${1}"
  rm "${1}"
  git add -A "${1}"
else
  echo "Aborting"
fi
