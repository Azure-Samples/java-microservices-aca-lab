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

param mysqlSubnetPrefix string

@description('The id of the vNet to which the private endpoint will be connected.')
param subnetName string

@description('The resource ID of the existing virtual network.')
param vnetId string

var vnetTokens = !empty(vnetId) ? split(vnetId, '/') : array('')
var vnetName = vnetTokens[8]

resource mysqlUserAssignedIdentityRW 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mysqluserassignedidentity-rw'
  location: location
}

resource mysqlUserAssignedIdentityAdmin 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mysqluserassignedidentity-admin'
  location: location
}

@description('The Private DNS zone containing the mysql IP')
module privateDnsZone '../network/private-dns-zone.bicep' = {
  name: 'mysqlPrivateDnsZone-${uniqueString(resourceGroup().id)}'
  params: {
    name: '${serverName}.private.mysql.database.azure.com'
    virtualNetworkLinks: [
      {
        vnetName: vnetName
        vnetId: vnetId
        registrationEnabled: false
      }
    ]
    tags: tags
  }
}

resource mysqlSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${subnetName}'
  properties: {
    addressPrefix: mysqlSubnetPrefix
    delegations: [
      {
        name: 'MySQLflexibleServers'
        properties: {
          serviceName: 'Microsoft.DBforMySQL/flexibleServers'
        }
      }
    ]
  }
}

resource server 'Microsoft.DBforMySQL/flexibleServers@2021-12-01-preview' = {
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
      delegatedSubnetResourceId: mysqlSubnet.id
      privateDnsZoneResourceId: privateDnsZone.outputs.privateDnsZonesId
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

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2021-12-01-preview' = {
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
