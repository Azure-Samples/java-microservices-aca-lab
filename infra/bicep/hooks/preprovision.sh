#!/usr/bin/env bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

subscription=$(az account show --query id -o tsv)
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}INFO:${NC} Using Subscription: $subscription"
else
    echo -e "${GREEN}INFO:${NC} Failed to retrieve the current subscription, please run 'az login' and try again."
    exit 1
fi

# Check input AAD User Id
echo -e "${GREEN}INFO:${NC} Checking AAD_USER_ID: '$AAD_USER_ID'"
if [[ $AAD_USER_ID =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
    echo -e "${GREEN}INFO:${NC} Using AAD_USER_ID from input: $AAD_USER_ID"

    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
fi

echo -e "${GREEN}INFO:${NC} Invalid input AAD_USER_ID: '$AAD_USER_ID'"

echo -e "${GREEN}INFO:${NC} Retrieving the current user's object id..."
AAD_USER_ID=$(az ad signed-in-user show --query id --output tsv)
if [[ $AAD_USER_ID =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
    echo -e "${GREEN}INFO:${NC} Using AAD_USER_ID: $AAD_USER_ID"

    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
fi

echo ""
echo -e "${GREEN}INFO:${NC} Failed to retrieve the current user object id, please follow the guide below and try again:"
echo -e "${GREEN}    1.${NC} Run 'az ad signed-in-user show --query id --output tsv' in a managed environment to get the user object id"
echo -e "${GREEN}    2.${NC} Run 'export AAD_USER_ID=<user-object-id>' in this environment"

exit 1