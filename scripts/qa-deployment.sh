#!/bin/bash
set -e


node scripts/generate-package-xml.js force-app/main/default manifest/package.xml

echo "Generated package.xml content for full deploy:"
cat manifest/package.xml

sf project deploy start \
    --manifest manifest/package.xml \
    --target-org myqaorg \
    --test-level RunLocalTests \
    --wait 40
