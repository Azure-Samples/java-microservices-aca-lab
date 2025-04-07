#!/bin/bash

AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

SPRING_PETCLINIC_MICROSERIVCES="../../../spring-petclinic-microservices"

# Check if the spring-petclinic-microservices directory exists
if [ ! -d "$SPRING_PETCLINIC_MICROSERIVCES" ]; then
    echo "Error: $SPRING_PETCLINIC_MICROSERIVCES directory does not exist."
    # create the directory
    mkdir -p $SPRING_PETCLINIC_MICROSERIVCES
fi

# Get the application code from public upstream repo, and then build the applications.
cd ../../../spring-petclinic-microservices
git submodule update --init
mvn clean package -DskipTests

# Build the Docker image using the Dockerfile
DOCKERFILE="../tools/Dockerfile"
if [ ! -f $DOCKERFILE ]; then
    echo "$DOCKERFILE not found "
    exit 1
fi

# if ACA environment does not exist, exit
if [ -z "$ACA_ENVIRONMENT" ]; then
    echo "Error: ACA environment [$ACA_ENVIRONMENT] not found."
    exit 1
fi

APP_NAME="api-gateway"
cp -f ../tools/Dockerfile ./spring-petclinic-$APP_NAME/Dockerfile

# Disable path conversion for MSYS (Git Bash)
export MSYS_NO_PATHCONV=1

echo "az containerapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ACA_ENVIRONMENT \
    --source ./spring-petclinic-$APP_NAME \
    --registry-server $MYACR.azurecr.io \
    --registry-identity $APPS_IDENTITY_ID \
    --ingress external \
    --target-port 8080 \
    --min-replicas 1 \
    --bind $JAVA_CONFIG_COMP_NAME $JAVA_EUREKA_COMP_NAME \
    --runtime java"

az containerapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ACA_ENVIRONMENT \
    --source ./spring-petclinic-$APP_NAME \
    --registry-server $MYACR.azurecr.io \
    --registry-identity $APPS_IDENTITY_ID \
    --ingress external \
    --target-port 8080 \
    --min-replicas 1 \
    --bind $JAVA_CONFIG_COMP_NAME $JAVA_EUREKA_COMP_NAME \
    --runtime java

