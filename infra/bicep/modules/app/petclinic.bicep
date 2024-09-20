targetScope = 'resourceGroup'

param managedEnvironmentsName string
param eurekaId string
param configServerId string

param mysqlDBId string
param mysqlUserAssignedIdentityClientId string

param acrRegistry string
param acrIdentityId string

param apiGatewayImage string
param customersServiceImage string
param vetsServiceImage string
param visitsServiceImage string
param adminServerImage string

param applicationInsightsConnString string = ''

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
    containerRegistryUserAssignedIdentityId: acrIdentityId
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
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    createSqlConnection: true
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
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
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    createSqlConnection: true
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
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
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    createSqlConnection: true
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
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
    containerRegistryUserAssignedIdentityId: acrIdentityId
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
