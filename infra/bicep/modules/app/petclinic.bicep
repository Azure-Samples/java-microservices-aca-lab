targetScope = 'resourceGroup'

param managedEnvironmentsName string
param eurekaId string
param configServerId string

param mysqlDatabaseId string
param mysqlConnectionName string = 'conn_${uniqueString(resourceGroup().id)}'

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

param targetPort int = 8080

param enableOpenAi bool
param openAiEndpoint string

param applicationInsightsConnString string = ''

param tags object = {}

var env = concat([
    {
      name: 'SPRING_PROFILES_ACTIVE'
      value: 'passwordless'
    }],
    empty(applicationInsightsConnString) ? [] : [
    {
      name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
      value: applicationInsightsConnString
    }
  ])

var serviceBindings = [
    {
      serviceId: eurekaId
      name: 'eureka'
    }
    {
      serviceId: configServerId
      name: 'configserver'
    }
  ]

module apiGateway '../containerapps/containerapp.bicep' = {
  name: 'api-gateway'
  params: {
    containerAppsEnvironmentName: managedEnvironmentsName
    name: 'api-gateway'
    acrName: acrRegistry
    acrIdentityId: acrIdentityId
    image: apiGatewayImage
    external: true
    targetPort: targetPort
    isJava: true
    serviceBinds: serviceBindings
    tags: tags
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
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
    containerAppsEnvironmentName: managedEnvironmentsName
    name: 'customers-service'
    acrName: acrRegistry
    acrIdentityId: acrIdentityId
    image: customersServiceImage
    external: false
    targetPort: targetPort
    isJava: true
    umiAppsIdentityId: umiAppsIdentityId
    readinessProbeInitialDelaySeconds: 20
    livenessProbeInitialDelaySeconds: 40
    serviceBinds: serviceBindings
    tags: tags
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "customers-service"}}'
      }
    ])
  }
}

module customersServiceConnection '../containerapps/serviceLiner.bicep' = {
  name: 'customers-service-sql-connection'
  params: {
    appName: customersService.outputs.appName
    containerName: customersService.outputs.appContainerName
    appClientId: umiAppsClientId
    connectionName: mysqlConnectionName
    resourceId: mysqlDatabaseId
  }
}

module vetsService '../containerapps/containerapp.bicep' = {
  name: 'vets-service'
  params: {
    containerAppsEnvironmentName: managedEnvironmentsName
    name: 'vets-service'
    acrName: acrRegistry
    acrIdentityId: acrIdentityId
    image: vetsServiceImage
    external: false
    targetPort: targetPort
    isJava: true
    umiAppsIdentityId: umiAppsIdentityId
    serviceBinds: serviceBindings
    tags: tags
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "vets-service"}}'
      }
    ])
  }
}

module vetsServiceConnection '../containerapps/serviceLiner.bicep' = {
  name: 'vets-service-sql-connection'
  params: {
    appName: vetsService.outputs.appName
    containerName: vetsService.outputs.appContainerName
    appClientId: umiAppsClientId
    connectionName: mysqlConnectionName
    resourceId: mysqlDatabaseId
  }
}

module visitsService '../containerapps/containerapp.bicep' = {
  name: 'visits-service'
  params: {
    containerAppsEnvironmentName: managedEnvironmentsName
    name: 'visits-service'
    acrName: acrRegistry
    acrIdentityId: acrIdentityId
    image: visitsServiceImage
    external: false
    targetPort: targetPort
    isJava: true
    umiAppsIdentityId: umiAppsIdentityId
    serviceBinds: serviceBindings
    tags: tags
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "visits-service"}}'
      }
    ])
  }
}

module visitsServiceConnection '../containerapps/serviceLiner.bicep' = {
  name: 'visits-service-sql-connection'
  params: {
    appName: visitsService.outputs.appName
    containerName: visitsService.outputs.appContainerName
    appClientId: umiAppsClientId
    connectionName: mysqlConnectionName
    resourceId: mysqlDatabaseId
  }
}

// always create this app, conditional azd deploy is not supported yet
// see https://github.com/Azure/azure-dev/issues/3397
module chatAgent '../containerapps/containerapp.bicep' = {
  name: 'chat-agent'
  params: {
    containerAppsEnvironmentName: managedEnvironmentsName
    name: 'chat-agent'
    acrName: acrRegistry
    acrIdentityId: acrIdentityId
    image: chatAgentImage
    umiAppsIdentityId: umiAppsIdentityId
    external: false
    targetPort: targetPort
    isJava: true
    serviceBinds: serviceBindings
    tags: tags
    env: concat(env,
      empty(applicationInsightsConnString) ? [] : [
      {
        name: 'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
        value: '{"role": {"name": "chat-agent"}}'
      }
    ], !enableOpenAi ? [] : [
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
    containerAppsEnvironmentName: managedEnvironmentsName
    name: 'admin-server'
    acrName: acrRegistry
    acrIdentityId: acrIdentityId
    image: adminServerImage
    external: true
    targetPort: targetPort
    isJava: true
    serviceBinds: serviceBindings
    tags: tags
    env: concat(env, empty(applicationInsightsConnString) ? [] : [
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

output connectionName string = mysqlConnectionName
