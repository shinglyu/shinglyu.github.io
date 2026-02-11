#!/bin/bash
set -e

git fetch private main
git checkout main
git merge private/main

echo "=== Commits to be pushed ==="
git log origin/main..HEAD --oneline

read -p "Push to origin/main? (y/N): " confirm
[[ $confirm == [yY] ]] && git push origin main

echo "Published. Wait for 1 minute before opening"
sleep 1m
sensible-browser https://shinglyu.com/
