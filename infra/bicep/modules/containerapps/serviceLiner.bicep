targetScope = 'resourceGroup'

@description('Name of the container apps')
param appName string

@description('Name of the container apps')
param containerName string

@description('Name of the connection')
param connectionName string

@description('Client id of the user managed identity')
param appClientId string

@description('Resource Id of the target connected resource')
param resourceId string

var resourceTokens = !empty(resourceId) ? split(resourceId, '/') : array('')
var resourceSubscriptionId = length(resourceTokens) > 2 ? resourceTokens[2] : ''

resource connection 'Microsoft.ServiceLinker/linkers@2023-04-01-preview' = {
  name: connectionName
  scope: containerApps
  properties: {
    scope: containerName
    clientType: 'springBoot'
    authInfo: {
      authType: 'userAssignedIdentity'
      clientId: appClientId
      subscriptionId: resourceSubscriptionId
      userName: 'aad_${connectionName}'
    }
    targetService: {
      type: 'AzureResource'
      id: resourceId
    }
  }
}

resource containerApps 'Microsoft.App/containerApps@2024-02-02-preview' existing = {
  scope: resourceGroup()
  name: appName
}
