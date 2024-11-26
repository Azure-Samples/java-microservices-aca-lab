#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

try {
    $subscription = (az account show --query id -o tsv)
    Write-Output "Using Subscription: $subscription"
} catch {
    Write-Output "Failed to retrieve the current subscription, please run `az login` and try again."
    exit 1
}

# Check input AAD User Id
Write-Output "Checking AAD_USER_ID: $env:AAD_USER_ID"
if ($env:AAD_USER_ID -match '^[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}$') {
    Write-Output "Using AAD_USER_ID from input: $env:AAD_USER_ID"
    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
}

Write-Output "Retrieving the current user's object id..."
$AAD_USER_ID = (az ad signed-in-user show --query id --output tsv)
if ($AAD_USER_ID -match '^[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}$') {
    Write-Output "Using AAD_USER_ID: $AAD_USER_ID"
    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
}

Write-Output "Failed to retrieve the current user's object id, please get your object id, run `\$env:AAD_USER_ID=<aad-user-id>` and try again."
exit 1
