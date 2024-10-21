#!/usr/bin/env bash

set -x

azd env set AZURE_RESOURCE_GROUP $resourceGroupName

azd env set AZURE_CONTAINER_REGISTRY_ENDPOINT $acrLoginServer

azd env set AZD_PROVISION_TIMESTAMP $azdProvisionTimestamp

az extension add --upgrade -n containerapp --allow-preview true
az extension add --upgrade -n serviceconnector-passwordless

az extension list -o table

azd env list

# refresh service connection, via customers-service
az containerapp connection create mysql-flexible --subscription $subscriptionId -g $resourceGroupName \
  --connection $sqlConnectName --source-id $customersServiceId --target-id $sqlDatabaseId --client-type springBoot \
  --user-identity client-id=$appUserIdentityClientId subs-id=$subscriptionId mysql-identity-id=$sqlAdminIdentityId \
  -c $customersServiceName -y