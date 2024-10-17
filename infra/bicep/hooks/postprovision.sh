#!/usr/bin/env bash

set -x

azd env set AZURE_RESOURCE_GROUP $resourceGroupName

azd env set AZURE_CONTAINER_REGISTRY_ENDPOINT $acrLoginServer

azd env set AZD_PROVISION_TIMESTAMP $azdProvisionTimestamp

# refresh service connection, via customers-service
az containerapp connection create mysql-flexible --subscription $subscriptionId -g $resourceGroupName \
  --connection $sqlConnectName --source-id $customersServiceId --target-id $sqlDatabaseId --client-type springBoot \
  --user-identity client-id=$appUserIdentityClientId subs-id=$subscriptionId mysql-identity-id=$sqlAdminIdentityId \
  -c $customersServiceName