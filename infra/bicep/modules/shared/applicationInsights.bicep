@description('Required. Name of the Application Insights.')
param name string

@description('Optional. Application type.')
@allowed([
  'web'
  'other'
])
param appInsightsType string = 'web'

@description('Resource ID of the log analytics workspace which the data will be ingested to. If left empty, applicationInsights will create one for us. This property is required to create an application with this API version. Applications from older versions will not have this property.')
param workspaceResourceId string

@description('Optional. The network access type for accessing Application Insights ingestion. - Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. Determines whether or not new ApplicationInsights should be provisioned.')
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

@description('Optional. The network access type for accessing Application Insights query. - Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Optional. Retention period in days.')
@allowed([
  30
  60
  90
  120
  180
  270
  365
  550
  730
])
param retentionInDays int = 90

@description('Optional. Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry.')
@minValue(0)
@maxValue(100)
param samplingPercentage int = 100

@description('Optional. The kind of application that this component refers to, used to customize UI. This value is a freeform string, values should typically be one of the following: web, ios, other, store, java, phone.')
param kind string = ''

@description('Optional. Location for all Resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

resource aiNew 'Microsoft.Insights/components@2020-02-02' = if (newOrExisting == 'new') {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: appInsightsType
    Request_Source: 'rest'
    WorkspaceResourceId: workspaceResourceId
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    RetentionInDays: retentionInDays
    SamplingPercentage: samplingPercentage
  }
}

resource aiExisting 'Microsoft.Insights/components@2020-02-02' existing = if (newOrExisting == 'existing') {
  name: name
}

@description('The name of the application insights component.')
output name string = ((newOrExisting == 'new') ? aiNew.name : aiExisting.name)

@description('The resource ID of the application insights component.')
output resourceId string = ((newOrExisting == 'new') ? aiNew.id : aiExisting.id)

@description('The applicationInsights Instrumentation Key.')
output instrumentationKey string = ((newOrExisting == 'new') ? aiNew.properties.InstrumentationKey : aiExisting.properties.InstrumentationKey)

@description('The applicationInsights Connection String.')
output connectionString string = ((newOrExisting == 'new') ? aiNew.properties.ConnectionString : aiExisting.properties.ConnectionString)
