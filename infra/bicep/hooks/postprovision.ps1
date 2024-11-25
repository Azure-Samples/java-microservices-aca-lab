#!/usr/bin/env pwsh

azd env set AZURE_RESOURCE_GROUP $env:resourceGroupName

azd env set AZURE_CONTAINER_REGISTRY_ENDPOINT $env:acrLoginServer

azd env set AZD_PROVISION_TIMESTAMP $env:azdProvisionTimestamp

Write-Host ""
Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Updating container apps connection ..."

# refresh service connection, via customers-service
az containerapp connection create mysql-flexible --subscription $env:subscriptionId -g $env:resourceGroupName `
  --connection $env:sqlConnectName --source-id $env:customersServiceId --target-id $env:sqlDatabaseId --client-type springBoot `
  --user-identity client-id=$env:appUserIdentityClientId subs-id=$env:subscriptionId mysql-identity-id=$env:sqlAdminIdentityId `
    user-object-id=$env:AAD_USER_ID `
  -c $env:customersServiceName -y | Out-Null

# Allow user to visit Spring Boot Admin dashboard
az role assignment create --role "Container Apps ManagedEnvironments Contributor" `
  --scope $containerAppsEnvironmentId `
  --assignee-principal-type User `
  --assignee-object-id $env:AAD_USER_ID `
  --description "allow user to visit Spring Boot Admin dashboard"

Write-Host ""
Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Deploy finish succeed!"

Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Api Gateway App url: https://$env:gatewayFqdn"

Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Spring Boot Admin url: https://$env:springbootAdminFqdn"

$domain = (az account show -o tsv --query tenantDefaultDomain)
Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Resource Group: $env:environmentPortal/#@$domain/resource$env:resourceGroupId"
