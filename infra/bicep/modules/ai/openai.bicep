targetScope = 'resourceGroup'

@description('Required. Name of your Azure OpenAI service account. ')
param accountName string

@description('Required. Location for all resources.')
param location string

@description('Optional. model name for the TextEmbeddingAda002 language model. ')
param modelTextEmbeddingAda002 string = 'text-embedding-ada-002'

@description('Optional. model name for the gpt-4 language model. ')
param modelGpt4 string = 'gpt-4o'

@description('Optional. model format for the language models. ')
param modelFormat string = 'OpenAI'

@description('Required. The principal ID of the MI for the chate agent application. ')
param appPrincipalId string

@description('Optional. The role definition ID for the Cognitive Services OpenAI User role. ')
// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Determines whether or not new ApplicationInsights should be provisioned.')
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (newOrExisting == 'new') {
  name: accountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  tags: tags
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: true
  }
}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (newOrExisting == 'new') {
  name: guid(resourceGroup().id, appPrincipalId, roleDefinitionId)
  scope: account
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: appPrincipalId
  }
}

resource modelDeploymentTextEmbeddingAda002 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (newOrExisting == 'new') {
  name: modelTextEmbeddingAda002
  dependsOn: [ roleAssignment ]
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

resource modelDeploymentGpt4 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (newOrExisting == 'new') {
  name: modelGpt4
  dependsOn: [ modelDeploymentTextEmbeddingAda002 ]
  parent: account
  properties: {
    model: {
      name: modelGpt4
      version: '2024-05-13'
      format: modelFormat
    }
  }
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
}

resource accountExist 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = if (newOrExisting == 'existing') {
  name: accountName
}

resource roleAssignmentExist 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (newOrExisting == 'existing') {
  name: guid(resourceGroup().id, appPrincipalId, roleDefinitionId)
  scope: accountExist
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: appPrincipalId
  }
}

@description('Endpoint of the Azure OpenAI service account.')
output endpoint string = (newOrExisting == 'new') ? account.properties.endpoint : accountExist.properties.endpoint

@description('Resource Id of the Azure OpenAI service account.')
output resourceId string = (newOrExisting == 'new') ? account.id : accountExist.id
