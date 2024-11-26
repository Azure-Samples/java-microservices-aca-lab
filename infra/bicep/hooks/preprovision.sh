#!/usr/bin/env bash

set -e

subscription=$(az account show --query id -o tsv)
if [[ $? -eq 0 ]]; then
    echo "Using Subscription: $subscription"
else
    echo "Failed to retrieve the current subscription, please run `az login` and try again."
    exit 1
fi

# Check input AAD User Id
echo "Checking AAD_USER_ID: $AAD_USER_ID"
if [[ $AAD_USER_ID =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
    echo "Using AAD_USER_ID from input: $AAD_USER_ID"
    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
fi

echo "Retrieving the current user's object id..."
AAD_USER_ID=$(az ad signed-in-user show --query id --output tsv)
if [[ $AAD_USER_ID =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
    echo "Using AAD_USER_ID: $AAD_USER_ID"
    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
fi

echo "Failed to retrieve the current user's object id, please get your object id, run `export AAD_USER_ID=<aad-user-id>` and try again."
exit 1