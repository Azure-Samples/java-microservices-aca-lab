#!/bin/bash
#
# Before deploying applications to the Azure Container Apps environment, an Azure Container Registry instance is needed that allows to build and save application container images. 
# Allow the Container Apps environment to pull images from this new container registry.
#
# This script creates an Azure Container Registry (ACR) and a user managed identity for the Azure Container Apps environment.
# The script also assigns the user managed identity to the ACR and grants it the necessary permissions to pull images from the registry.
# The script uses the Azure CLI to create the ACR and user managed identity, and to assign the identity to the ACR.
# The script also checks if the ACR and user managed identity already exist, and skips their creation if they do.
# The script also exports the ACR and user managed identity names and IDs as environment variables, and appends them to the Azure configuration file.
# The script also checks if the Azure Container Apps environment name exists, and exits with an error message if it does not.
# The script also disables path conversion for MSYS (Git Bash) to avoid issues with file paths.


AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

# Check if a container registry containing the string $APPNAME already exists
MYACR=$(az acr list --resource-group $RESOURCE_GROUP --query "[?contains(name, '$APPNAME')].{Name:name}[0]" -o tsv)

CR_UNIQUEID=$(openssl rand -hex 3)
if [ -n "$MYACR" ]; then
    echo "Container registry [$MYACR] already exists. Skipping creation."
else    
    MYACR=acr$APPNAME$CR_UNIQUEID
    echo "Creating new container registry [$MYACR]..."
    az acr create \
        -n $MYACR \
        -g $RESOURCE_GROUP \
        --sku Basic \
        --admin-enabled true
fi

# Check if ACA environment name containing string "acalab-env" exists
if [ -z "$ACA_ENVIRONMENT" ]; then
    echo "Error: ACA environment [$ACA_ENVIRONMENT] not found."
    exit 1
fi

# Disable path conversion for MSYS (Git Bash)
export MSYS_NO_PATHCONV=1

# Create the identity that the container apps will use.
export APPS_IDENTITY=uid-petclinic-$CR_UNIQUEID
az identity create --resource-group $RESOURCE_GROUP --name $APPS_IDENTITY --output json

APPS_IDENTITY_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $APPS_IDENTITY --query id --output tsv)
APPS_IDENTITY_SP_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $APPS_IDENTITY --query principalId --output tsv)

echo "Assign the user identity to your Azure Container Apps environment."
az containerapp env identity assign -g $RESOURCE_GROUP -n $ACA_ENVIRONMENT --user-assigned $APPS_IDENTITY_ID

# Grant the identity with the necessary privileges to pull images from the container registry.
export ACR_ID=$(az acr show -n $MYACR -g $RESOURCE_GROUP --query id -o tsv)
az role assignment create --assignee $APPS_IDENTITY_SP_ID --scope $ACR_ID --role acrpull

# Export the variables
export MYACR
export APPS_IDENTITY
export APPS_IDENTITY_ID
export APPS_IDENTITY_SP_ID

# Append the variables to the AZURE_CONFIG_FILE
{
    echo "MYACR=$MYACR"
    echo "APPS_IDENTITY=$APPS_IDENTITY"
    echo "APPS_IDENTITY_ID=$APPS_IDENTITY_ID"
    echo "APPS_IDENTITY_SP_ID=$APPS_IDENTITY_SP_ID"
    echo "ACR_ID=$ACR_ID"
} >> $AZURE_CONFIG_FILE