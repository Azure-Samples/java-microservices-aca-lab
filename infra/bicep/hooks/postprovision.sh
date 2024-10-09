#!/usr/bin/env bash

azd env set AZURE_RESOURCE_GROUP $resourceGroupName

azd env set ACR_LOGIN_SERVER $acrLoginServer

# refresh service connection, via customers-service
az containerapp connection create mysql-flexible --subscription $subscriptionId -g $resourceGroupName \
  --connection $sqlConnectName --source-id $customersServiceId --target-id $sqlDatabaseId --client-type springBoot \
  --user-identity client-id=$appUserIdentityClientId subs-id=$subscriptionId mysql-identity-id=$sqlAdminIdentityId \
  -c $customersServiceName -y