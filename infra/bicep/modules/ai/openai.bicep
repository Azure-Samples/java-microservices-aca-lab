param accountName string
param location string
param modelTextEmbeddingAda002 string = 'text-embedding-ada-002'
param modelGpt4 string = 'gpt-4'
param modelFormat string = 'OpenAI'
param appPrincipalId string
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User role

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: true
  }
}

resource modelDeploymentTextEmbeddingAda002 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: modelTextEmbeddingAda002
  parent: account
  properties: {
    model: {
      name: modelTextEmbeddingAda002
      version: '2'
      format: modelFormat
    }
  }
  sku: {
    name: 'Standard'
    capacity: 1
  }
}

resource modelDeploymentGpt4 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: modelGpt4
  parent: account
  properties: {
    model: {
      name: modelGpt4
      version: '0613'
      format: modelFormat
    }
  }
  sku: {
    name: 'GlobalBatch'
    capacity: 1
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, appPrincipalId, roleDefinitionId)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: appPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output endpoint string = account.properties.endpoint
output resourceId string = account.id
