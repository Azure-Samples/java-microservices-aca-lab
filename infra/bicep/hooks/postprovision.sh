#!/usr/bin/env bash

azd env set AZURE_RESOURCE_GROUP $resourceGroupName

azd env set AZURE_CONTAINER_REGISTRY_ENDPOINT $acrLoginServer

azd env set AZD_PROVISION_TIMESTAMP $azdProvisionTimestamp

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo ""

# Skip AAD_USER_ID related operations in pipeline environment (CREATE_ROLE_FOR_USER == false)
if [[ "$CREATE_ROLE_FOR_USER" == false ]]; then

  echo -e "${GREEN}INFO:${NC} CREATE_ROLE_FOR_USER = false, missed AAD_USER_ID"
  echo -e "${GREEN}INFO:${NC} Should create service connection manually"

else

  echo -e "${GREEN}INFO:${NC} Updating container apps connection ..."

  # refresh service connection, via customers-service
  az containerapp connection create mysql-flexible --subscription $subscriptionId -g $resourceGroupName \
    --connection $sqlConnectName --source-id $customersServiceId --target-id $sqlDatabaseId --client-type springBoot \
    --user-identity client-id=$appUserIdentityClientId subs-id=$subscriptionId mysql-identity-id=$sqlAdminIdentityId \
      user-object-id=$AAD_USER_ID \
    -c $customersServiceName -y > /dev/null

  # Allow user to visit Spring Boot Admin dashboard
  az role assignment create --role "Container Apps ManagedEnvironments Contributor" \
    --scope $containerAppsEnvironmentId \
    --assignee $AAD_USER_ID \
    --description "allow user to visit Spring Boot Admin dashboard" > /dev/null
fi

echo ""
echo -e "${GREEN}INFO:${NC} Deploy finish succeed!"

echo -e "${GREEN}INFO:${NC} Api Gateway App url: https://$gatewayFqdn"

echo -e "${GREEN}INFO:${NC} Spring Boot Admin url: https://$springbootAdminFqdn"

domain=$(az account show -o tsv --query tenantDefaultDomain)
echo -e "${GREEN}INFO:${NC} Resource Group: $environmentPortal/#@$domain/resource$resourceGroupId"
