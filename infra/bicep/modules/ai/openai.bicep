targetScope = 'resourceGroup'

@description('Required. Name of your Azure OpenAI service account. ')
param accountName string

@description('')
param location string = resourceGroup().location

@description('Optional. model name for the TextEmbeddingAda002 language model. ')
param modelTextEmbeddingAda002 string = 'text-embedding-ada-002'

@description('Optional. model name for the gpt-4 language model. ')
param modelGpt4 string = 'gpt-4o'

@description('Optional. model format for the language models. ')
param modelFormat string = 'OpenAI'

@description('Required. The principal ID of the MI for the chate agent application. ')
param appPrincipalId string

@description('Optional. The role definition ID for the Cognitive Services OpenAI role. Default: User role')
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

module roleAssignment 'openaiRoleAssignment.bicep' = {
  name: 'openai-role-assignment-${accountName}'
  params: {
    accountName: account.name // add dependency
    appPrincipalId: appPrincipalId
    roleDefinitionId: roleDefinitionId
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
      version: '2024-08-06'
      format: modelFormat
    }
  }
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
}

@description('Endpoint of the Azure OpenAI service account.')
output endpoint string = roleAssignment.outputs.endpoint
