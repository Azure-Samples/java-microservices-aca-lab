#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/azure-resource.profile
source $DIR/funcs.sh

shopt -s expand_aliases
source $DIR/../.devcontainer/funcs.sh

# Resource Group

# Random regions for MySQL server
LOCATION=$(random_element australiaeast brazilsouth eastasia eastus2 japaneast southindia swedencentral westus)

az group create -g $RESOURCE_GROUP -l $LOCATION -o table

az configure --default group=$RESOURCE_GROUP

# MySQL server

# Random regions for MySQL server
SQL_LOCATION=$(random_element australiaeast brazilsouth eastasia eastus2 japaneast southindia swedencentral westus)

SQL_ID=$(az mysql flexible-server show --resource-group $RESOURCE_GROUP --name $MYSQL_SERVER_NAME -o tsv --query id 2>/dev/null)
if [[ -n $SQL_ID ]]; then
    echo -e "${GREEN}INFO:${NC} MySQL server $MYSQL_SERVER_NAME already exists"
else
    echo -e "${YELLOW}INFO:${NC} Creating MySQL server $MYSQL_SERVER_NAME in region $LOCATION ..."

    az mysql flexible-server create \
        --admin-user $MYSQL_ADMIN_USERNAME \
        --admin-password $MYSQL_ADMIN_PASSWORD \
        --name $MYSQL_SERVER_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --public-access none \
        --yes
fi

# Azure Container Registry

ACR_ID=$(az acr show --name $MYACR --resource-group $RESOURCE_GROUP -o tsv --query id 2>/dev/null)
if [[ -n $ACR_ID ]]; then
    echo -e "${GREEN}INFO:${NC} Container Registry $MYACR already exists"
else
    echo -e "${YELLOW}INFO:${NC} Creating Container Registry $MYACR ..."

    az acr create \
        --name $MYACR \
        --resource-group $RESOURCE_GROUP \
        --sku Basic \
        --admin-enabled true \
        --output table
fi

# Azure OpenAI Service

AI_ID=$(az cognitiveservices account show --resource-group $RESOURCE_GROUP --name $OPEN_AI_SERVICE_NAME -o tsv --query id 2>/dev/null)
if [[ -n $ACR_ID ]]; then
    echo -e "${GREEN}INFO:${NC} OpenAI instance $OPEN_AI_SERVICE_NAME already exists"
else
    echo -e "${YELLOW}INFO:${NC} Creating OpenAI instance $OPEN_AI_SERVICE_NAME in region $LOCATION ..."

    az cognitiveservices account create \
    --resource-group $RESOURCE_GROUP \
    --name $OPEN_AI_SERVICE_NAME \
    --location $LOCATION \
    --kind OpenAI \
    --sku s0 \
    --custom-domain $OPEN_AI_SERVICE_NAME \
    --output table

    az cognitiveservices account deployment create \
    --resource-group $RESOURCE_GROUP \
    --name $OPEN_AI_SERVICE_NAME \
    --deployment-name gpt-4o \
    --model-name gpt-4o \
    --model-version 2024-08-06 \
    --model-format OpenAI \
    --sku-name "GlobalStandard" \
    --sku-capacity 10 \
    --output table

fi

if [[ $RUN_OPTIONAL != true ]]; then
    echo ""
    echo -e "${GREEN}INFO:${NC} Resources ready for Java + AI parts"
    exit 0
fi

###############  Optional  ###############

echo -e "${GREEN}INFO:${NC} Start to create resources for optional parts"

# Azure Monitoring

WORKSPACE_ID=$(az monitor log-analytics workspace show -n $WORKSPACE -g $RESOURCE_GROUP --query id -o tsv 2>/dev/null)
if [[ -n $WORKSPACE_ID ]]; then
    echo -e "${GREEN}INFO:${NC} Log Analytics workspace $WORKSPACE already exists"
else
    echo -e "${YELLOW}INFO:${NC} Creating Log Analytics workspace $WORKSPACE ..."

    az monitor log-analytics workspace create \
        --resource-group $RESOURCE_GROUP \
        --workspace-name $WORKSPACE \
        --output table
fi

# Application Insights

WORKSPACE_ID=$(az monitor log-analytics workspace show -n $WORKSPACE -g $RESOURCE_GROUP --query id -o tsv 2>/dev/null)
APP_INSIGHTS_ID=$(az monitor app-insights component show --resource-group $RESOURCE_GROUP --app $APP_INSIGHTS_NAME -o tsv --query id 2>/dev/null)
if [[ -n $APP_INSIGHTS_ID ]]; then
    echo -e "${GREEN}INFO:${NC} Application Insights $APP_INSIGHTS_NAME already exists"
else
    echo -e "${YELLOW}INFO:${NC} Creating Application Insights $APP_INSIGHTS_NAME ..."

    az monitor app-insights component create \
        --resource-group $RESOURCE_GROUP \
        --app $APP_INSIGHTS_NAME \
        --location $LOCATION \
        --kind web \
        --workspace $WORKSPACE_ID \
        --output table
fi

# Azure Managed Grafana

GRAFANA_ID=$(az grafana show --name $GRAFANA_NAME --resource-group $RESOURCE_GROUP -o tsv --query id 2>/dev/null)
if [[ -n $GRAFANA_ID ]]; then
    echo -e "${GREEN}INFO:${NC} Grafana instance $GRAFANA_NAME already exists"
else
    echo -e "${YELLOW}INFO:${NC} Creating Grafana instance $GRAFANA_NAME in region $LOCATION ..."

    az deployment group create \
        --resource-group $RESOURCE_GROUP \
        --template-file $DIR/../infra/bicep/modules/grafana/grafana-dashboard.bicep \
        --parameters grafanaName=$GRAFANA_NAME location=$GRAFANA_LOCATION \
        --output table
fi

# Save environment variables

saveenv
