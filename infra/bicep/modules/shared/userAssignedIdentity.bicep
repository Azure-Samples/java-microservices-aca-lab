targetScope = 'resourceGroup'

@description('Required. Name of your user managed identity.')
param name string

resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: resourceGroup().location
}

output id string = umi.id

output principalId string = umi.properties.principalId
