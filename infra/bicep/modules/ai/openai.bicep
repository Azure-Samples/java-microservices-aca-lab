targetScope = 'resourceGroup'

@description('Required. Name of your Azure OpenAI service account. ')
param accountName string

@description('Required. Location for all resources.')
param location string

@description('Optional. model name for the TextEmbeddingAda002 language model. ')
param modelTextEmbeddingAda002 string = 'text-embedding-ada-002'

@description('Optional. model name for the gpt-4 language model. ')
param modelGpt4 string = 'gpt-4'

@description('Optional. model format for the language models. ')
param modelFormat string = 'OpenAI'

@description('Required. The principal ID of the MI for the chate agent application. ')
param appPrincipalId string

@description('Optional. The role definition ID for the Cognitive Services OpenAI User role. ')
// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

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
  dependsOn: [ modelDeploymentTextEmbeddingAda002 ]
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
  scope: account
  dependsOn: [
    modelDeploymentGpt4
    modelDeploymentTextEmbeddingAda002
  ]
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: appPrincipalId
  }
}

output endpoint string = account.properties.endpoint
output resourceId string = account.id
