#!/bin/bash

AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

APPLICATION_CONFIG_FILE="../config/application-mysql.yml"

# This script creates an Azure MySQL server and an Azure Container Registry (ACR) in a specified resource group.
MYSQL_SERVER_NAME=mysql-$APPNAME-$UNIQUEID
MYSQL_ADMIN_USERNAME=sqladmin
MYSQL_ADMIN_PASSWORD=$(openssl rand -hex 12)
DATABASE_NAME=petclinic

az mysql flexible-server create \
    --admin-user "$MYSQL_ADMIN_USERNAME" \
    --admin-password "$MYSQL_ADMIN_PASSWORD" \
    --name "$MYSQL_SERVER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --public-access none \
    --yes
az mysql flexible-server db create \
    --server-name $MYSQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    -d $DATABASE_NAME

#
# Allow public access to the MySQL server
#
az mysql flexible-server firewall-rule create \
    --rule-name allAzureIPs \
    --name $MYSQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Set up a configuration repository
# set up the application configuration settings that allow Spring Boot applications to connect with the database.
echo "
spring:
    datasource:
        url: jdbc:mysql://${MYSQL_SERVER_NAME}.mysql.database.azure.com:3306/$DATABASE_NAME?useSSL=true
        username: ${MYSQL_ADMIN_USERNAME}
        password: ${MYSQL_ADMIN_PASSWORD}
    sql:
        init:
            schema-locations: classpath*:db/mysql/schema.sql
            data-locations: classpath*:db/mysql/data.sql
            mode: ALWAYS
" > $APPLICATION_CONFIG_FILE

export GIT_URI="https://github.com/Azure-Samples/java-on-aca.git"
export SEARCH_PATH="config"
export LABEL=main

{
    echo "GIT_URI=https://github.com/Azure-Samples/java-on-aca.git"
    echo "SEARCH_PATH=config"
    echo "LABEL=main"
} >> $AZURE_CONFIG_FILE
