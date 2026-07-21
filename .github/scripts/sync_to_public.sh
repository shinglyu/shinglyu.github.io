#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PUBLIC_REPO_OWNER="${PUBLIC_REPO_OWNER:-shinglyu}"
PUBLIC_REPO_NAME="${PUBLIC_REPO_NAME:-shinglyu.github.io}"

cd "${REPO_ROOT}"

if [ -z "${PUBLIC_REPO_TOKEN:-}" ]; then
  echo "Error: PUBLIC_REPO_TOKEN is required to sync to the public repository"
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: sync_to_public.sh requires a clean working tree"
  exit 1
fi

git remote remove public 2>/dev/null || true

# actions/checkout injects GitHub auth headers for the current repository.
# Clear them so the dedicated public-repo token is used for the cross-repo push.
git config --local --unset-all http.https://github.com/.extraheader || true

git remote add public "https://x-access-token:${PUBLIC_REPO_TOKEN}@github.com/${PUBLIC_REPO_OWNER}/${PUBLIC_REPO_NAME}.git"

if ! git fetch public main; then
  echo "Error: failed to fetch the public repository. Check PUBLIC_REPO_TOKEN and network access."
  exit 1
fi

if ! git merge-base HEAD public/main >/dev/null 2>&1; then
  echo "Error: HEAD and public/main do not share a common ancestor."
  exit 1
fi

# Count commits that exist on the public main branch but not on the current private checkout.
AHEAD_COUNT="$(git rev-list --count HEAD..public/main)"
if [ "${AHEAD_COUNT}" -gt 0 ]; then
  echo "Error: The public repo has ${AHEAD_COUNT} commit(s) not present in this repo."
  echo "Resolve the divergence before publishing."
  exit 1
fi

COMMIT_SHA="$(git rev-parse HEAD)"
if [ -n "${GITHUB_ENV:-}" ]; then
  echo "COMMIT_SHA=${COMMIT_SHA}" >> "${GITHUB_ENV}"
fi

if ! git push public HEAD:main; then
  echo "Error: failed to push to the public repository. Check PUBLIC_REPO_TOKEN and public repo permissions."
  exit 1
fi
