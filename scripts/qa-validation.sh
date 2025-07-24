#!/bin/bash
set -e

git fetch origin qa
git diff --name-only origin/qa...HEAD > changed_files.txt
grep '^force-app/main/default/' changed_files.txt > filtered_changed_files.txt || true

mkdir -p manifest
node scripts/generate-package-xml.js filtered_changed_files.txt manifest/package.xml

sf project deploy start \
  --manifest manifest/package.xml \
  --target-org myqaorg \
  --check-only \
  --test-level RunLocalTests \
  --wait 40