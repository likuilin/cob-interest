#!/bin/bash

# crontab: */10 * * * * /path/to/cob-interest/update.sh

set -euo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

curl -s 'https://api.capitalone.com/deposits/products/~/search' \
  -H 'Accept: application/json;v=4' \
  -H 'Content-Type: application/json' \
  --data-raw '{"include":["RATES"],"isRenewableRate":true}' | jq 'del(.lastCachedAt)' > current.json

! cat current.json | grep "Internal Server Error"

git add current.json &&
  GIT_AUTHOR_NAME="auto" \
  GIT_AUTHOR_EMAIL="" \
  GIT_COMMITTER_NAME="auto" \
  GIT_COMMITTER_EMAIL="" \
  git commit -m "Auto-update $(date -u)" --no-gpg-sign && git push > /dev/null
