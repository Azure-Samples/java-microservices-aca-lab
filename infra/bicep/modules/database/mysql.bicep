targetScope = 'resourceGroup'

@description('Required. Name of your MySQL server.')
param serverName string

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

@description('Optional. The version of MySQL.')
param version string = '8.0.21'

resource mysqlUserAssignedIdentityRW 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mysqluserassignedidentity-rw'
  location: location
}

resource mysqlUserAssignedIdentityAdmin 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mysqluserassignedidentity-admin'
  location: location
}

// new
resource serverNew 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = if (newOrExisting == 'new') {
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
      '${mysqlUserAssignedIdentityRW.id}': {}
    }
  }
  properties: {
    createMode: 'Default'
    version: version
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

resource SQLAllConnectionsAllowed 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-06-30' = if (newOrExisting == 'new') {
  name: 'AllConnectionsAllowed'
  parent: serverNew
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource databaseNew 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = if (newOrExisting == 'new') {
  parent: serverNew
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

// existing
resource serverExisting 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' existing = if (newOrExisting == 'existing') {
  name: serverName
}

// the 'parent' property only permit direct references to resources
resource databaseExisting 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = if (newOrExisting == 'existing') {
  parent: serverExisting
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

@description('The resource id of the database.')
output databaseId string = ((newOrExisting == 'new') ? databaseNew.id : databaseExisting.id)

@description('The client id of the user assigned identity with r/w permission.')
output userAssignedIdentityClientId string = mysqlUserAssignedIdentityRW.properties.clientId

@description('The resource id of the user assigned identity with r/w permission.')
output userAssignedIdentity string = mysqlUserAssignedIdentityRW.id
