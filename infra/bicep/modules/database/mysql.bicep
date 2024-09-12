targetScope = 'resourceGroup'

@description('The location where the resources will be created.')
param location string = resourceGroup().location

param administratorLogin string
@secure()
param administratorLoginPassword string

param serverName string
param databaseName string
param version string
param tags object = {}

resource mysqlUserAssignedIdentityRW 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mysqluserassignedidentity-rw'
  location: location
}

resource mysqlUserAssignedIdentityAdmin 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mysqluserassignedidentity-admin'
  location: location
}

resource server 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = {
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

resource SQLAllConnectionsAllowed 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-06-30' = {
  name: 'AllConnectionsAllowed'
  parent: server
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = {
  parent: server
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

output databaseId string = database.id
output userAssignedIdentityClientId string = mysqlUserAssignedIdentityRW.properties.clientId
output userAssignedIdentity string = mysqlUserAssignedIdentityRW.id
