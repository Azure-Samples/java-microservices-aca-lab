targetScope = 'resourceGroup'

@description('Required. Name of the Log Analytics Workspace Service. It must be between 4 and 63 characters and can contain only letters, numbers and "-". The "-" should not be the first or the last symbol')
//The workspace name .
//The workspace name can contain only letters, numbers and '-'. The '-' shouldn't be the first or the last symbol.
@minLength(4)
@maxLength(63)
param name string

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

param tags object = {}

@description('Optional. Determines whether or not new Log Analytics Workspace Service should be provisioned.')
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

@description('Optional. Service Tier: PerGB2018, Free, Standalone, PerGB or PerNode.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param serviceTier string = 'PerGB2018'

@description('Optional, default 90. Number of days data will be retained for.')
@minValue(0)
@maxValue(730)
param dataRetention int = 90

@description('Optional. The network access type for accessing Log Analytics ingestion.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. The network access type for accessing Log Analytics query.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Optional. Set to \'true\' to use resource or workspace permissions and \'false\' (or leave empty) to require workspace permissions.')
param useResourcePermissions bool = false

var lawsMaxLength = 63
var lawsNameSantized = replace(replace(name, '_', '-'), '.', '-')
var lawsName = length(lawsNameSantized) > lawsMaxLength ? substring(lawsNameSantized, 0, lawsMaxLength) : lawsNameSantized

resource lawsNew 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (newOrExisting == 'new') {
  location: location
  name: lawsName
  tags: tags
  properties: {
    retentionInDays: dataRetention
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    sku:{
      name:serviceTier
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: useResourcePermissions
    }
  }
}

resource lawsExisting 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (newOrExisting == 'existing') {
  name: name
}

@description('The name of the resource.')
output logAnalyticsWsName string = ((newOrExisting == 'new') ? lawsNew.name : lawsExisting.name)

@description('The resource ID of the resource.')
output logAnalyticsWsId string = ((newOrExisting == 'new') ? lawsNew.id : lawsExisting.id)
