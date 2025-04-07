#!/bin/bash
# This script creates an Azure Container Apps environment with a dedicated plan and a virtual network.
# It also creates a resource group and a virtual network with a subnet for the Azure Container Apps environment.

random_element() {
  local array=("$@")
  echo "${array[RANDOM % ${#array[@]}]}"
}

UNIQUEID=$(openssl rand -hex 3)

export APPNAME=petclinic
export RESOURCE_GROUP=$(az group list --query "[?contains(name, '$APPNAME')].{Name:name}[0]" -o tsv)

if [ -z "$RESOURCE_GROUP" ]; then
    RESOURCE_GROUP=rg-$APPNAME-$UNIQUEID
    LOCATION=westus
    echo "Creating resource group [$RESOURCE_GROUP] in region [$LOCATION]..."
    az group create -g $RESOURCE_GROUP -l $LOCATION
else
    LOCATION=$(az group show --name $RESOURCE_GROUP --query "location" -o tsv)
    echo "Provisioning in resource group [$RESOURCE_GROUP]..."
fi

az configure --default group=$RESOURCE_GROUP

#
# Create VNET for Azure Container Apps Environment
#
VIRTUAL_NETWORK_NAME=vnet-$APPNAME-$UNIQUEID
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VIRTUAL_NETWORK_NAME \
    --location $LOCATION \
    --address-prefix 10.1.0.0/16

ACA_SUBNET_CIDR=10.1.0.0/27
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VIRTUAL_NETWORK_NAME \
    --address-prefixes $ACA_SUBNET_CIDR \
    --name aca-subnet \
    --delegations Microsoft.App/environments

SUBNET_ID="$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VIRTUAL_NETWORK_NAME --name aca-subnet --query "id" -o tsv)"
echo "Subnet ID: [$SUBNET_ID]"

#
# Creating the service on an Azure Container Apps Dedicated plan using the workload profiles option.
# This plan gives you more advanced features than the alternative Azure Container Apps Consumption plan type
#
export ACA_ENVIRONMENT=acalab-env-$APPNAME-$UNIQUEID

# If folder ../config does not exist, create it
if [ ! -d "../config" ]; then
    mkdir -p ../config
fi
AZURE_CONFIG_FILE="../config/azure-resource.profile"

# winty is to accommodate git bash on Windows
# Otherwise, SUBNET_ID will be appended with local drive path
# NO_PATHCOW is for git bash on Windows
export MSYS_NO_PATHCONV=1

az containerapp env create \
    -n $ACA_ENVIRONMENT \
    -g $RESOURCE_GROUP \
    --location $LOCATION \
    --enable-workload-profiles true \
    --infrastructure-subnet-resource-id "$SUBNET_ID" \
    --logs-destination none

export ACA_ENVIRONMENT_ID=$(az containerapp env show -n $ACA_ENVIRONMENT -g $RESOURCE_GROUP --query id -o tsv)

# Write variables to the azure-resource.profile
{
    echo "RESOURCE_GROUP=$RESOURCE_GROUP"
    echo "LOCATION=$LOCATION"
    echo "UNIQUEID=$UNIQUEID"
    echo "APPNAME=$APPNAME"
    echo "ACA_ENVIRONMENT=$ACA_ENVIRONMENT"
    echo "ACA_ENVIRONMENT_ID=$ACA_ENVIRONMENT_ID"
} > $AZURE_CONFIG_FILE

# Verify that the azure-resource.profile file is created properly
if [ -f $AZURE_CONFIG_FILE ]; then
    echo "azure-resource.profile file created successfully."
else
    echo "Error: azure-resource.profile file not created."
    exit 1
fi
