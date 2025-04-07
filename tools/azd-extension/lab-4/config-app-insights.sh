#!/bin/bash

AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE
export MSYS_NO_PATHCONV=1

APP_INSIGHTS_NAME=app-insights-$APPNAME-$UNIQUEID
az monitor app-insights component create \
    --resource-group $RESOURCE_GROUP \
    --app $APP_INSIGHTS_NAME \
    --location $LOCATION \
    --kind web \
    --workspace $WORKSPACE_ID

export APP_INSIGHTS_CONN=$(az monitor app-insights component show --app $APP_INSIGHTS_NAME -g $RESOURCE_GROUP --query connectionString --output tsv)

"APP_INSIGHTS_CONN='$APP_INSIGHTS_CONN'" >> $AZURE_CONFIG_FILE

APP_NAME="api-gateway"
az containerapp update \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars JAVA_TOOL_OPTIONS='-javaagent:/applicationinsights-agent.jar' APPLICATIONINSIGHTS_CONNECTION_STRING="$APP_INSIGHTS_CONN" APPLICATIONINSIGHTS_CONFIGURATION_CONTENT='{"role": {"name": "'$APP_NAME'"}}'

export RESOURCE_GROUP APP_INSIGHTS_CONN
bash ../../update-apps-appinsights.sh
