#/usr/bin/env bash

# Usage:
# Write your link in the following format:
# [Mozilla Offical Site][mozofficial]
# // [mozofficial]: https://www.mozilla.org

get_links() {
  grep -oP "\[[^\]]*\]\[[^\]]*\]" "${1}" |\
    cut -d "[" -f 3 |\
    sed "s/]$//g" 
}

get_links_text() {
  grep -oP "\[[^\]]*\]\[[^\]]*\]" "${1}" |\
    cut -d "[" -f 2 |\
    sed "s/]$//g"
}

echo "Links"
echo "-----------------"

get_links_text "${1}" |\
  sed -E "s/ /+/g" |\
  sed -E "s/\`//g" |\
  sed "s/^/https:\/\/www.google.com\/search\?q\=/g" |\
  sort |\
  uniq

echo "-----------------"

get_links "${1}" |\
  sed "s/^/[/g" |\
  sed "s/$/]: /g" |\
  sort |\
  uniq
#grep -oP "\[[^\]]*\]\[[^\]*]\]" "$1" |\
  #sed -E "s/\[|\]|\`//g" |\
  #sed -E "s/ /+/g" |\
  #sed "s/^/https:\/\/www.google.com\/search\?q\=/g"

echo ""
echo "Images"
echo "-----------------"
grep -oP "!\[[^\]]*\]()" "$1" |\
  sed -E "s/!|\[|\]|\`//g" |\
  sed -E "s/ /+/g" |\
  sed "s/^/https:\/\/www.google.com\/images\?q\=/g" |\
  sort |\
  uniq

