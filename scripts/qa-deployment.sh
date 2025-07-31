#!/bin/bash
set -e

# Assumes filtered_changed_files.txt was downloaded by the workflow step before executing this script

# Early exit if no validated changes to deploy
if [ ! -s filtered_changed_files.txt ]; then
  echo "No validated metadata changes to deploy. Skipping deployment."
  exit 0
fi

# Generate package.xml for deployment using the validated files
mkdir -p manifest
node scripts/generate-package-xml.js filtered_changed_files.txt manifest/package.xml

echo "===== Generated package.xml content ====="
cat manifest/package.xml
echo "========================================="

# Check if package.xml has any metadata types to deploy
if ! grep -q "<types>" manifest/package.xml; then
  echo "No metadata type changes detected in package.xml. Skipping deployment."
  exit 0
fi

# Deploy validated changes to Salesforce
sf project deploy start \
  --manifest manifest/package.xml \
  --target-org myqaorg \
  --test-level RunLocalTests \
  --wait 40
echo "Deployment completed successfully."