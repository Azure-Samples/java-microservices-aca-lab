#!/bin/bash

AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

WORKSPACE=la-$APPNAME-$UNIQUEID
az monitor log-analytics workspace create \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $WORKSPACE

WORKSPACE_ID=$(az monitor log-analytics workspace show -n $WORKSPACE -g $RESOURCE_GROUP --query id -o tsv)
WORKSPACE_CUSTOMER_ID=$(az monitor log-analytics workspace show -n $WORKSPACE -g $RESOURCE_GROUP --query customerId -o tsv)
WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys -n $WORKSPACE -g $RESOURCE_GROUP --query primarySharedKey -o tsv)

az containerapp env update \
    --name $ACA_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --logs-destination log-analytics \
    --logs-workspace-id $WORKSPACE_CUSTOMER_ID \
    --logs-workspace-key $WORKSPACE_KEY

{
    echo "WORKSPACE_ID=$WORKSPACE_ID"
    echo "WORKSPACE_CUSTOMER_ID=$WORKSPACE_CUSTOMER_ID"
    echo "WORKSPACE_KEY='$WORKSPACE_KEY'"
} >> $AZURE_CONFIG_FILE