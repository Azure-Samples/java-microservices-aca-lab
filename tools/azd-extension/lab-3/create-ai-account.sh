#!/bin/bash
AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

AI_LOCATION=$LOCATION

OPEN_AI_SERVICE_NAME=open-ai-account-$UNIQUEID

# Create a new Azure Cognitive Services account
az cognitiveservices account create \
   --resource-group $RESOURCE_GROUP \
   --name $OPEN_AI_SERVICE_NAME \
   --location $AI_LOCATION \
   --kind OpenAI \
   --sku s0 \
   --custom-domain $OPEN_AI_SERVICE_NAME

az cognitiveservices account deployment create \
   --resource-group $RESOURCE_GROUP \
   --name $OPEN_AI_SERVICE_NAME \
   --deployment-name gpt-4o \
   --model-name gpt-4o \
   --model-version 2024-08-06 \
   --model-format OpenAI \
   --sku-name "GlobalStandard" \
   --sku-capacity 10

# Query the Azure OpenAI endpoint
AZURE_OPENAI_ENDPOINT=$(az cognitiveservices account show \
   --resource-group $RESOURCE_GROUP \
   --name $OPEN_AI_SERVICE_NAME \
   --query "properties.endpoint" \
   --output tsv)

# Query the Azure OpenAI API key
AZURE_OPENAI_API_KEY=$(az cognitiveservices account keys list \
   --resource-group $RESOURCE_GROUP \
   --name $OPEN_AI_SERVICE_NAME \
   --query "key1" \
   --output tsv)

# Export the endpoint and API key as environment variables
export AZURE_OPENAI_ENDPOINT
export AZURE_OPENAI_API_KEY
{
    echo "AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT"
    echo "AZURE_OPENAI_API_KEY=$AZURE_OPENAI_API_KEY"
} >> $AZURE_CONFIG_FILE

