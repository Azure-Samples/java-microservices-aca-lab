---
title: '3.2 PostgreSQL database [OPTIONAL]'
layout: default
nav_order: 3
parent: 'Lab 2: Migrate to Azure Container Apps'
---

# Create an Azure PostgreSQL Database service

You now have the compute service that will host your applications and the config server that will be used by your migrated application. Before you start deploying individual microservices as Azure Container Apps, you need to first create an Azure Database for PostgreSQL Flexible Server-hosted database for them. To accomplish this, you can use the following guidance:

- [Quickstart: Create an Azure Database for PostgreSQL Flexible Server using Azure CLI](https://learn.microsoft.com/azure/PostgreSQL/flexible-server/quickstart-create-server-cli).

You will also need to update the config for your applications to use the newly provisioned PostgreSQL Server. This will involve updating the application.yml config file in your private git config repo with the values provided in the PostgreSQL Server connection string.

Your PostgreSQL database will also have a firewall enabled. This firewall will by default block all incoming calls. You will need to open this firewall in case you want to connect to it from your microservices running in the ACA environment.

## Step by step guidance

1. Run the following commands to create an instance of PostgreSQL Flexible server. Note that the name of the server must be globally unique, so adjust it accordingly in case the randomly generated name is already in use. Keep in mind that the name can contain only lowercase letters, numbers and hyphens. In addition, replace the `<sqladmin-password>` placeholder with a complex password and record its value.
   {: .note }
   > Here we use PostgreSQL admin password for apps to connect to sql server, this is for demo/test/learn purpose,  not recommand in production environment. Please refer to [Lab 04: Connect to Database securely using identity](https://azure-samples.github.io/java-microservices-aca-lab/docs/04_lab_secrets/04_openlab_secrets_aca.html) for the secured managed identity solution.

   ```bash
   POSTGRES_SERVER_NAME=postgres-$APPNAME-$UNIQUEID
   POSTGRES_ADMIN_USERNAME=sqladmin
   POSTGRES_ADMIN_PASSWORD="<sqladmin-password>"
   DATABASE_NAME=petclinic
      
   az postgres flexible-server create \
       --admin-user myadmin \
       --admin-password "$POSTGRES_ADMIN_PASSWORD" \
       --name "$POSTGRES_SERVER_NAME" \
       --resource-group "$RESOURCE_GROUP"
   ```

   {: .note }
   > During the creation you will be asked whether access for your IP address should be added and whether access for all IP's should be added. Answer `n` for no on both questions.

   {: .note }
   > In case this statement fails with the message `ERROR: Unable to prompt for confirmation as no tty available`, add the `--yes` flag to the above statement. This will auto-install any missing resource providers. 
   
   {: .note }
   > Wait for the provisioning to complete. This might take about 3 minutes.

1. Once the Azure Database for PostgreSQL Flexible Server instance gets created, it will output details about its settings. In the output, you will find the server connection string. Record its value since you will need it later in this exercise.

1. Run the following commands to create a database in the Azure Database for PostgreSQL Flexible Server instance.

   ```bash
    az postgres flexible-server db create \
        --server-name $POSTGRES_SERVER_NAME \
        --resource-group $RESOURCE_GROUP \
        -d $DATABASE_NAME
   ```

1. You will also need to allow connections to the server from your ACA environment. For now, to accomplish this, you will create a server firewall rule to allow inbound traffic from all Azure Services.

   Check the status of your sql server
   ![SQL Server Networking](../../images/sql-server-manage-firewall.png)

   Checking `Allow Azure services and resources to access this server` adds an IP based firewall rule with start and end IP address of `0.0.0.0`, See [Connections from inside Azure](https://learn.microsoft.com/en-us/azure/azure-sql/database/firewall-configure?view=azuresql#connections-from-inside-azure).

   This way your apps running in Azure Container Apps will be able to reach the PostgreSQL database. In one of the upcoming exercises, you will restrict this connectivity to limit it exclusively to the apps hosted by your ACA.

   ```bash
    az postgres flexible-server firewall-rule create \
        --rule-name allAzureIPs \
        --name $POSTGRES_SERVER_NAME \
        --resource-group $RESOURCE_GROUP \
        --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
   ```

   Check the sql server firewall rules with command
   ```bash
    az postgres flexible-server firewall-rule list \
       --name $POSTGRES_SERVER_NAME \
       --resource-group $RESOURCE_GROUP \
   ```

1. From the Git Bash window, in the config repository you cloned locally, use your favorite text editor to open the _application.yml_ file. Replace the full contents of the _application.yml_ file with the contents of [this application.yml](0203_postgres_application.yaml) file. The updated _application.yml_ file includes the following changes:

   * It removes the default `0` value for the `server.port` on line 5.
   * It changes the default `spring.sql.init` values to use `PostgreSQL` configuration on lines 15 to 19.
   * It adds a `spring.datasource` property for your PostgreSQL database on lines 10 to 14.
   * It adds extra `eureka` config on lines 61 to 66.
   * It removes the `chaos-monkey` and `PostgreSQL` profiles.

1. In the part you pasted, update the values of the target datasource endpoint on line 6, the corresponding admin user account on line 7, and its password on line 8 to match your configuration. Set these values by using the information in the Azure Database for PostgreSQL Flexible Server connection string you recorded earlier in this task.

1. Save the changes and push the updates you made to the _application.yml_ file to your private GitHub repo by running the following commands from the Git Bash prompt:

   ```bash
   git add .
   git commit -m 'azure postgres info'
   git push
   ```

   {: .note }
   > At this point, the admin account user name and password are stored in clear text in the application.yml config file. In one of upcoming exercises, you will remediate this potential vulnerability by removing clear text credentials from your configuration.
 