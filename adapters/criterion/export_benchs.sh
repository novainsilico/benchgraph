#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

COMMIT_TIMESTAMP="$(git show -s --format=%ct HEAD)"
COMMIT_REV="$(git rev-parse HEAD)"

scriptPath=${0%/*}
JQ_SCRIPT=$scriptPath/export_benchs.jq

for INPUT_FILE in "$@"; do
  cat $INPUT_FILE | \
    jq -cM -f $JQ_SCRIPT \
      --argjson timestamp "$COMMIT_TIMESTAMP" \
      --argjson commit_rev "\"$COMMIT_REV\""
done
