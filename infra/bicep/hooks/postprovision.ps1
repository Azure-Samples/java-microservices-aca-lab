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
  -c $env:customersServiceName -y | Out-Null

Write-Host ""
Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Deploy finish succeed!"

Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Api Gateway App url: https://$env:gatewayFqdn"

Write-Host "INFO: " -ForegroundColor Green -NoNewline;
Write-Host "Spring Boot Admin url: https://$env:springbootAdminFqdn"