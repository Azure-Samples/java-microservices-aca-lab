---
title: '1. Create db admin account'
layout: default
nav_order: 1
parent: 'Lab 4: Connect to Database securely using identity [PostgreSQL]'
---

# Create a database administrator account

You are already using a managed Identity to connect to the Azure Container Registry. You can use this same identity to also connect to the database. This will allow you to remove the username and password from the config repository.

- [Configure passwordless database connections for Java apps](https://learn.microsoft.com/azure/developer/java/ee/how-to-configure-passwordless-datasource?toc=%2Fazure%2Fdeveloper%2Fintro%2Ftoc.json&bc=%2Fazure%2Fdeveloper%2Fintro%2Fbreadcrumb%2Ftoc.json&tabs=postgresql-passwordless-flexible-server)

## Step by step guidance

1. Before creating the administrator account, you need to enable Microsoft Entra Authentication from the portal.

1. In the Azure Portal, navigate to your PostgreSQL server page.

1. On your PostgreSQL page, select Authentication (1) from left menu under security, check PostgreSQL and Microsoft Entra authentication (2) option and save it using the Save (3) option from top menu.

  ![](/images/postgres-enable.png)

1. You will need to allow the user assigned managed identity access to the database. To configure this, you will need to first make your current logged in user account database administrator. For this to work on a PostgreSQL database you first need an additional managed identity.

   ```bash
   DB_ADMIN_USER_ASSIGNED_IDENTITY_NAME=uid-dbadmin-$APPNAME-$UNIQUEID
   
   ADMIN_IDENTITY_RESOURCE_ID=$(az identity create \
      --name $DB_ADMIN_USER_ASSIGNED_IDENTITY_NAME \
      --resource-group $RESOURCE_GROUP \
      --query id \
      --output tsv)
   ```

1. This identity needs to be assigned to your PostgreSQL server.

   ```bash
   az postgres flexible-server identity assign \
       --resource-group $RESOURCE_GROUP \
       --server-name $POSTGRES_SERVER_NAME \
       --identity $DB_ADMIN_USER_ASSIGNED_IDENTITY_NAME


   az postgres flexible-server identity list \
       --resource-group $RESOURCE_GROUP \
       --server-name $POSTGRES_SERVER_NAME 
   ```

1. Get the current logged in user and object ID. This will give you the info of the user account you are currently logged in with in the Azure CLI.

   ```bash
   CURRENT_USER=$(az account show --query user.name --output tsv)
   echo $CURRENT_USER
   CURRENT_USER_OBJECTID=$(az ad signed-in-user show --query id --output tsv)
   echo $CURRENT_USER_OBJECTID
   ```

1. Next you create a database administrator based on your current user account.

   ```bash
   az postgres flexible-server ad-admin create \
       --resource-group $RESOURCE_GROUP \
       --server-name $POSTGRES_SERVER_NAME \
       --object-id $CURRENT_USER_OBJECTID \
       --display-name $CURRENT_USER \

   DB_ID=$(az postgres flexible-server db show \
        --server-name $POSTGRES_SERVER_NAME \
        --resource-group $RESOURCE_GROUP \
        -d $DATABASE_NAME \
        --query id \
        -o tsv)
   ```