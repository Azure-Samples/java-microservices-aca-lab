targetScope = 'resourceGroup'

param managedEnvironmentsName string
param eurekaId string
param configServerId string

param mysqlDatabaseId string

param acrRegistry string
param acrIdentityId string

param umiAppsClientId string
param umiAppsIdentityId string

param apiGatewayImage string
param customersServiceImage string
param vetsServiceImage string
param visitsServiceImage string
param adminServerImage string
param chatAgentImage string

param applicationInsightsConnString string = ''

param enableOpenAi bool

param openAiEndpoint string

param targetPort int = 8080

var env = []

resource environment 'Microsoft.App/managedEnvironments@2024-02-02-preview' existing = {
  name: managedEnvironmentsName
}

module apiGateway '../containerapps/containerapp.bicep' = {
  name: 'api-gateway'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'api-gateway'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: apiGatewayImage
    acrIdentityId: acrIdentityId
    umiAppsIdentityId: umiAppsIdentityId
    external: true
    targetPort: targetPort
    createSqlConnection: false
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "api-gateway"}}'
      }
    ])
  }
}

module customersService '../containerapps/containerapp.bicep' = {
  name: 'customers-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'customers-service'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: customersServiceImage
    acrIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    createSqlConnection: true
    mysqlDatabaseId: mysqlDatabaseId
    umiAppsClientId: umiAppsClientId
    umiAppsIdentityId: umiAppsIdentityId
    readinessProbeInitialDelaySeconds: 20
    livenessProbeInitialDelaySeconds: 40
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "customers-service"}}'
      }
    ])
  }
}

module vetsService '../containerapps/containerapp.bicep' = {
  name: 'vets-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'vets-service'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: vetsServiceImage
    acrIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    createSqlConnection: true
    mysqlDatabaseId: mysqlDatabaseId
    umiAppsClientId: umiAppsClientId
    umiAppsIdentityId: umiAppsIdentityId
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "vets-service"}}'
      }
    ])
  }
}

module visitsService '../containerapps/containerapp.bicep' = {
  name: 'visits-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'visits-service'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: visitsServiceImage
    acrIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    createSqlConnection: true
    mysqlDatabaseId: mysqlDatabaseId
    umiAppsClientId: umiAppsClientId
    umiAppsIdentityId: umiAppsIdentityId
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "visits-service"}}'
      }
    ])
  }
}

// always create this app, conditional azd deploy is not supported yet
// see https://github.com/Azure/azure-dev/issues/3397
module chatAgent '../containerapps/containerapp.bicep' = {
  name: 'chat-agent'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'chat-agent'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: chatAgentImage
    acrIdentityId: acrIdentityId
    umiAppsIdentityId: umiAppsIdentityId
    external: true
    targetPort: targetPort
    createSqlConnection: false
    env: concat(env,
      empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "chat-agent"}}'
      }
    ],
      !enableOpenAi ? [] : [
      {
        name: 'SPRING_AI_AZURE_OPENAI_ENDPOINT'
        value: openAiEndpoint
      }
      {
        name: 'SPRING_AI_AZURE_OPENAI_CLIENT_ID'
        value: umiAppsClientId
      }
    ])
  }
}

module adminServer '../containerapps/containerapp.bicep' = {
  name: 'admin-server'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'admin-server'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: adminServerImage
    acrIdentityId: acrIdentityId
    umiAppsIdentityId: umiAppsIdentityId
    external: true
    targetPort: targetPort
    createSqlConnection: false
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnString
      }
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "admin-server"}}'
      }
    ])
  }
}

output gatewayFqdn string = apiGateway.outputs.appFqdn
output adminFqdn string = adminServer.outputs.appFqdn

output customersServiceName string = customersService.outputs.appName
output customersServiceId string = customersService.outputs.appId
output vetsServiceName string = vetsService.outputs.appName
output vetsServiceId string = vetsService.outputs.appId
output visitsServiceName string = visitsService.outputs.appName
output visitsServiceId string = visitsService.outputs.appId

output connectionName string = customersService.outputs.connectionName
