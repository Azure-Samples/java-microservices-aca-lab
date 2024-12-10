try {
    $subscription = (az account show --query id -o tsv)

    Write-Host "INFO: " -ForegroundColor Green -NoNewline;
    Write-Host "Using Subscription: $subscription"
} catch {
    Write-Host "INFO: " -ForegroundColor Red -NoNewline;
    Write-Host "Failed to retrieve the current subscription, please run 'az login' and try again."
    exit 1
}

# Check input AAD User Id
Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Checking AAD_USER_ID: '$env:AAD_USER_ID'"
if ($env:AAD_USER_ID -match '^[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}$') {
    Write-Host "INFO: " -ForegroundColor Green -NoNewline;
    Write-Host "Using AAD_USER_ID from input: '$env:AAD_USER_ID'"
    azd env set AAD_USER_ID $env:AAD_USER_ID
    exit 0
}

if ($env:AAD_USER_ID) {
    Write-Host "INFO: " -ForegroundColor Green -NoNewline;
    Write-Host "Invalid input AAD_USER_ID: '$env:AAD_USER_ID'"
}

Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Retrieving the current user's object id..."
$AAD_USER_ID = (az ad signed-in-user show --query id --output tsv)
if ($AAD_USER_ID -match '^[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}$') {
    Write-Host "INFO: " -ForegroundColor Green -NoNewline;
    Write-Host "Using AAD_USER_ID: '$AAD_USER_ID'"
    azd env set AAD_USER_ID $AAD_USER_ID
    exit 0
}

Write-Host "INFO: " -ForegroundColor Red -NoNewline;
Write-Host "Failed to retrieve the current user object id, please follow the guide below and try again:"
Write-Host "    1. Run 'az ad signed-in-user show --query id --output tsv' in a managed environment to get the user object id"
Write-Host "    2. Run `$env:AAD_USER_ID='<aad-user-id>' in this environment"
exit 1
