TIME=$(date +"%Y-%m-%d %H:%M:%S %:z")
DATE=$(date +"%Y-%m-%d-")
POST=$(basename "${1}")
OUTPUT="_posts/${DATE}${POST}"

echo "Copying ${1} to ${OUTPUT}"
cp "${1}" "${OUTPUT}"
echo "Setting the time to ${TIME}"
sed -i "s/^date: .*$/date: ${TIME}/g" "${OUTPUT}"

echo "Is this OK?"
echo "========================="
head "${OUTPUT}"
echo "========================="

git add "${OUTPUT}"

mv "${1}" "${1}_PUBLISHED"

git add -A "${1}" "${1}_PUBLISHED"
