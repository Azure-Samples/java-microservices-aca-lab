#!/usr/bin/env bash

azd env set AZURE_RESOURCE_GROUP $resourceGroupName

azd env set AZURE_CONTAINER_REGISTRY_ENDPOINT $acrLoginServer

azd env set AZD_PROVISION_TIMESTAMP $azdProvisionTimestamp

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo ""
echo -e "${GREEN}INFO:${NC} Updating container apps connection ..."

# refresh service connection, via customers-service
az containerapp connection create mysql-flexible --subscription $subscriptionId -g $resourceGroupName \
  --connection $sqlConnectName --source-id $customersServiceId --target-id $sqlDatabaseId --client-type springBoot \
  --user-identity client-id=$appUserIdentityClientId subs-id=$subscriptionId mysql-identity-id=$sqlAdminIdentityId \
  -c $customersServiceName -y > /dev/null

echo ""
echo -e "${GREEN}INFO:${NC} Deploy finish succeed!"

echo -e "${GREEN}INFO:${NC} Api Gateway App url: https://$gatewayFqdn"

echo -e "${GREEN}INFO:${NC} Spring Boot Admin url: https://$springbootAdminFqdn"

domain=$(az account show -o tsv --query tenantDefaultDomain)
echo -e "${GREEN}INFO:${NC} Resource Group: $environmentPortal/#@$domain/resource$resourceGroupId"
