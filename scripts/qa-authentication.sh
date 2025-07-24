#!/bin/bash
set -e

# Authenticate using JWT grant
sf auth:jwt:grant \
  --client-id "$CLIENT_ID" \
  --jwt-key-file ./server.key \
  --username "$SF_USERNAME" \
  --alias myqaorg \
  --instance-url "${SF_INSTANCE_URL:-https://login.salesforce.com}"

sf org display myqaorg
