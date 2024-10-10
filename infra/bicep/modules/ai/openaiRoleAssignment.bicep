targetScope = 'resourceGroup'

param accountName string

param appPrincipalId string

param roleDefinitionId string

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: accountName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // The role assignment ID must be a GUID.
  name: guid(resourceGroup().id, appPrincipalId, roleDefinitionId)
  scope: account
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: appPrincipalId
  }
}

output endpoint string = account.properties.endpoint
