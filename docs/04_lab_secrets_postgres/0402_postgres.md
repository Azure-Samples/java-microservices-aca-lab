---
title: '2. Create service connections'
layout: default
nav_order: 2
parent: 'Lab 4: Connect to Database securely using identity [PostgreSQL]'
---

# Create service connections from the microservices to the database server

The apps deployed as the Spring Petclinic microservices will now connect using a service connector to the PostgreSQL Flexible server. A service connector will set up the needed environment variables the service needs to make the connection. You can use the following guidance to create a service connector:

- [Connect an Azure Database for PostgreSQL instance to your application in Azure Container Apps](https://learn.microsoft.com/azure/service-connector/quickstart-portal-container-apps?tabs=SMI).

The following three apps of your application use the database hosted by the Azure Database for PostgreSQL Flexible Server instance, so they will need to be assigned a service connector:

- `customers-service`
- `vets-service`
- `visits-service`

Since each of these apps already has a user assigned managed identity assigned to them, you will make use of this same identity to get access to the database.

## Step by step guidance

1. For creating a service connector you will need to add the `serviceconnector-passwordless` extension:

   ```bash
   az extension add --name serviceconnector-passwordless --upgrade
   ```

1. You will also need your subscription ID for creating the service connections:

   ```bash
   SUBID=$(az account show --query id -o tsv)
   ```

1. You will also need resource ID of the apps:

   ```bash
   CUSTOMERS_ID=$(az containerapp show \
                    --resource-group $RESOURCE_GROUP \
                    --name customers-service \
                    --query id \
                    -o tsv)
   
   VISITS_ID=$(az containerapp show \
                   --resource-group $RESOURCE_GROUP \
                   --name visits-service \
                   --query id \
                   -o tsv)
   
   VETS_ID=$(az containerapp show \
                 --resource-group $RESOURCE_GROUP \
                 --name vets-service \
                 --query id \
                 -o tsv)
   ```

1. Create now the service connections for the `customers-service`. For this you also need the client ID of the identity you created earlier.

   ```bash
   CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $ACA_IDENTITY --query 'clientId' --output tsv)
   echo $CLIENT_ID
   az containerapp connection create postgres-flexible \
      --connection postgres_conn \
      --source-id $CUSTOMERS_ID \
      --target-id $DB_ID \
      --client-type SpringBoot \
      --user-identity client-id=$CLIENT_ID  subs-id=$SUBID \
      -c customers-service
   ```

1. You can test the validity of this new connection with the `validate` command: 

   ```bash
    CUSTOMERS_CONN_ID=$(az containerapp connection list \
                   --resource-group $RESOURCE_GROUP \
                   --name customers-service \
                   --query [].id -o tsv)
   
    az containerapp connection validate \
       --id $CUSTOMERS_CONN_ID
   ```

   The output of this command should show that the connection was made successful.

1. In the same way create the service connections for the `vets-service` and `visits-service`:

   ```bash
   az containerapp connection create postgres-flexible \
      --connection postgres_conn \
      --source-id $VETS_ID \
      --target-id $DB_ID \
      --client-type SpringBoot \
      --user-identity client-id=$CLIENT_ID  subs-id=$SUBID \
      -c vets-service

   az containerapp connection create postgres-flexible \
      --connection postgres_conn \
      --source-id $VISITS_ID \
      --target-id $DB_ID \
      --client-type SpringBoot \
      --user-identity client-id=$CLIENT_ID  subs-id=$SUBID  \
      -c visits-service
   ```

1. You can test the validity of this new connection with the `validate` command: 

   ```bash
    VETS_CONN_ID=$(az containerapp connection list \
                   --resource-group $RESOURCE_GROUP \
                   --name vets-service \
                   --query [].id -o tsv)
   
   az containerapp connection validate \
       --id $VETS_CONN_ID

   VISITS_CONN_ID=$(az containerapp connection list \
                   --resource-group $RESOURCE_GROUP \
                   --name visits-service \
                   --query [].id -o tsv)
   
   az containerapp connection validate \
       --id $VISITS_CONN_ID
   ```

1. In the Azure Portal, navigate to your `customers-service` container app. In the `customers-service` app, select the `Service Connector` menu item. Notice in this screen you can see the details of your service connector. Notice that the service connector has all the config values set like `spring.datasource.url`, `spring.datasource.username`, but for instance no `spring.datasource.password`. These values get turned into environment variables at runtime for your app. Instead of `spring.datasource.password` it has a `spring.cloud.azure.credential.client-id`, which is the client ID of your managed identity. It also defines 2 additional variables `spring.datasource.azure.passwordless-enabled` and `spring.cloud.azure.credential.managed-identity-enabled` for enabling the passwordless connectivity.