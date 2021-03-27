#!/usr/bin/env bash
# Usage: ./local_pics.sh blog_assets/<folder>/*
# for FILENAME in $(find "${1}")
for FILENAME in "${@}"
do
  echo "![$(basename $FILENAME)]({{site_url}}/$FILENAME)"
done

