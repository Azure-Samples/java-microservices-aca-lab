targetScope = 'resourceGroup'

@description('Required. Name of your MySQL server.')
param serverName string

@description('Optional. Resource Group of existing MySQL server.')
param resourceGroupName string

@description('Optional. Subscription of existing MySQL server.')
param subscriptionId string

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The server admin login name.')
param administratorLogin string

@description('The server admin login password.')
@secure()
param administratorLoginPassword string

@description('The name of the database to create.')
param databaseName string

@description('Optional. Determines whether or not new ApplicationInsights should be provisioned.')
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

@description('Optional. Tags of the resource.')
param tags object = {}

resource mysqlUserAssignedIdentityAdmin 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'umi-${serverName}-admin'
  location: location
}

// new
resource dbServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = if (newOrExisting == 'new') {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mysqlUserAssignedIdentityAdmin.id}': {}
    }
  }
  properties: {
    createMode: 'Default'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    network: {
      publicNetworkAccess: 'Enabled'
    }
    storage: {
      storageSizeGB: 20
      iops: 360
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

@description('Create firewall rule to allow inbound traffic from all Azure Services')
resource SQLAllConnectionsAllowed 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-06-30' = if (newOrExisting == 'new') {
  name: 'AllConnectionsAllowed'
  parent: dbServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

var subId = (newOrExisting == 'new') ? subscription().subscriptionId : subscriptionId
var groupName = (newOrExisting == 'new') ? resourceGroup().name : resourceGroupName
var name = (newOrExisting == 'new') ? dbServer.name : serverName // add depends on new server

module database 'database.bicep' = {
  name: 'database-${databaseName}'
  scope: resourceGroup(subId, groupName)
  params: {
    serverName: name
    databaseName: databaseName
  }
}

@description('The resource id of the database.')
output databaseId string = database.outputs.id

@description('The client id of the user assigned identity with admin permission.')
output adminIdentityClientId string = mysqlUserAssignedIdentityAdmin.properties.clientId

@description('The resource id of the user assigned identity with admin permission.')
output adminIdentityId string = mysqlUserAssignedIdentityAdmin.id
