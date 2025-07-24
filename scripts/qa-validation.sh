#!/bin/bash
set -e

# Fetch latest state of qa branch for diff
git fetch origin qa

# Get list of changed files compared to origin/qa
git diff --name-only origin/qa...HEAD > changed_files.txt

# Filter only metadata files in force-app/main/default/
grep '^force-app/main/default/' changed_files.txt > filtered_changed_files.txt || true

# Create manifest directory and generate package.xml for changed metadata
mkdir -p manifest
node scripts/generate-package-xml.js filtered_changed_files.txt manifest/package.xml

# Validate deployment (check-only) using sfdx CLI style with short flag -c
# Note: Using sfdx CLI syntax; if you use sf CLI exclusively, update accordingly.

sf project deploy start \
  --manifest manifest/package.xml \
  --target-org myqaorg \
  -c \
  --test-level RunLocalTests \
  --wait 40
