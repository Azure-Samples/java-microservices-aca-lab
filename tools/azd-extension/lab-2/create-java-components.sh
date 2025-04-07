#!/bin/bash
#
# Configure the config, discovery, and admin applications. These are available as built-in components of Azure Container Apps.

AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

# Check if ACA environment name exists
if [ -z "$ACA_ENVIRONMENT" ]; then
    echo "Error: ACA environment not found."
    exit 1
fi

JAVA_CONFIG_COMP_NAME=configserver
az containerapp env java-component config-server-for-spring create \
    --environment $ACA_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --name $JAVA_CONFIG_COMP_NAME \
    --set-configuration spring.cloud.config.server.git.uri=$GIT_URI spring.cloud.config.server.git.search-paths=$SEARCH_PATH spring.cloud.config.server.git.default-label=$LABEL

# Check the Spring Cloud Config Server Java component to confirm that it was successfully created.
CONFIG_SERVER_EXISTS=$(az containerapp env java-component config-server-for-spring show \
    --environment $ACA_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --name $JAVA_CONFIG_COMP_NAME --query "name" -o tsv)

if [ -z "$CONFIG_SERVER_EXISTS" ]; then
    echo "Error: Config server was not successfully created."
    exit 1
fi

# Create the Spring Cloud Eureka Server Java component. This will create a standard Eureka endpoint within 
# the Container Apps environment. The Spring Petclinic workload will use this for discovery services.
JAVA_EUREKA_COMP_NAME=eureka
az containerapp env java-component eureka-server-for-spring create \
    --environment $ACA_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --name $JAVA_EUREKA_COMP_NAME \
    --set-configuration eureka.server.response-cache-update-interval-ms=10000

# Create a new Spring Boot Admin application and bind it to the Eureka Server 
JAVA_SBA_COMP_NAME=springbootadmin
az containerapp env java-component admin-for-spring create \
    --environment $ACA_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --name $JAVA_SBA_COMP_NAME \
    --bind $JAVA_EUREKA_COMP_NAME \
    --min-replicas 1 \
    --max-replicas 1

# Append the JAVA_EUREKA_COMP_NAME and JAVA_SBA_COMP_NAME to the AZURE_CONFIG_FILE
{
    echo "JAVA_EUREKA_COMP_NAME=$JAVA_EUREKA_COMP_NAME"
    echo "JAVA_SBA_COMP_NAME=$JAVA_SBA_COMP_NAME"
} >> $AZURE_CONFIG_FILE

# Verify that the variables are appended to the azure-resource.profile file
if grep -q "JAVA_EUREKA_COMP_NAME" $AZURE_CONFIG_FILE && grep -q "JAVA_SBA_COMP_NAME" $AZURE_CONFIG_FILE; then
    echo "Variables appended to azure-resource.profile file successfully."
else
    echo "Error: Variables JAVA_EUREKA_COMP_NAME JAVA_SBA_COMP_NAME not appended to azure-resource.profile file."
    exit 1
fi