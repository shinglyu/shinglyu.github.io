#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PUBLIC_REPO_OWNER="${PUBLIC_REPO_OWNER:-shinglyu}"
PUBLIC_REPO_NAME="${PUBLIC_REPO_NAME:-shinglyu.github.io}"

cd "${REPO_ROOT}"

BRANCH_NAME="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"
if [ "${BRANCH_NAME}" = "HEAD" ] || [ -z "${BRANCH_NAME}" ]; then
  BRANCH_NAME="main"
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: sync_to_public.sh requires a clean working tree"
  exit 1
fi

git fetch origin "${BRANCH_NAME}"
if ! git rev-parse --verify --quiet "origin/${BRANCH_NAME}" >/dev/null; then
  echo "Error: remote branch origin/${BRANCH_NAME} does not exist"
  exit 1
fi
LOCAL_AHEAD_COUNT="$(git rev-list --count "origin/${BRANCH_NAME}..HEAD")"
if [ "${LOCAL_AHEAD_COUNT}" -gt 0 ]; then
  echo "Error: local branch is ahead of origin/${BRANCH_NAME}; push or discard local commits before syncing"
  exit 1
fi
# Reset to the fetched private-repo tip so the public push always mirrors the latest committed state.
git reset --hard "origin/${BRANCH_NAME}"

git remote remove public 2>/dev/null || true
if [ -n "${PUBLIC_REPO_URL:-}" ]; then
  git remote add public "${PUBLIC_REPO_URL}"
else
  if [ -z "${PUBLIC_REPO_TOKEN:-}" ]; then
    echo "Error: PUBLIC_REPO_TOKEN is required when PUBLIC_REPO_URL is not set"
    exit 1
  fi
  git remote add public "https://x-access-token:${PUBLIC_REPO_TOKEN}@github.com/${PUBLIC_REPO_OWNER}/${PUBLIC_REPO_NAME}.git"
fi
git push public HEAD:main
