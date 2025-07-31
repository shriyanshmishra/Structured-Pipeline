#!/bin/bash
set -e

# Fetch the latest state of the 'qa' branch for diff comparison
git fetch origin qa

# Get list of changed files compared to origin/qa
git diff --name-only origin/qa...HEAD > changed_files.txt

# Filter only Salesforce metadata files inside force-app/main/default/
grep '^force-app/main/default/' changed_files.txt > filtered_changed_files.txt || true

# Early exit if there are no changed metadata files to deploy
if [ ! -s filtered_changed_files.txt ]; then
  echo "No metadata changes detected. Skipping deployment."
  exit 0
fi

# Create manifest directory if not exists, then generate package.xml for changed metadata
mkdir -p manifest
node scripts/generate-package-xml.js filtered_changed_files.txt manifest/package.xml

echo "===== Generated package.xml content ====="
cat manifest/package.xml
echo "========================================="

# Deploy the changed metadata using sf CLI
sf project deploy start \
  --manifest manifest/package.xml \
  --target-org myqaorg \
  --test-level RunLocalTests \
  --wait 40
