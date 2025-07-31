#!/bin/bash
set -e

git fetch origin qa

# Get changed files introduced by the last commit on qa branch
git diff --name-only HEAD^ HEAD > changed_files.txt

grep '^force-app/main/default/' changed_files.txt > filtered_changed_files.txt || true

if [ ! -s filtered_changed_files.txt ]; then
  echo "No metadata changes detected. Skipping deployment."
  exit 0
fi

mkdir -p manifest
node scripts/generate-package-xml.js filtered_changed_files.txt manifest/package.xml

echo "===== Generated package.xml content ====="
cat manifest/package.xml
echo "========================================="

sf project deploy start \
  --manifest manifest/package.xml \
  --target-org myqaorg \
  --test-level RunLocalTests \
  --wait 40
