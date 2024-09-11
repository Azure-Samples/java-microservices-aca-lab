targetScope = 'subscription'

@minLength(2)
@maxLength(32)
@description('Name of the the environment.')
param environmentName string

@minLength(2)
@description('Primary location for all resources.')
param location string

param resourceGroupName string = ''
param managedEnvironmentsName string = ''

param vnetEndpointInternal bool = false

// mysql
param sqlServerName string = ''
param sqlAdmin string
@secure()
param sqlAdminPassword string

param configGitRepo string
param configGitBranch string = 'main'
param configGitPath string

param acrRegistry string
param acrIdentityId string
param apiGatewayImage string
param customerServiceImage string
param vetsServiceImage string
param visitsServiceImage string
param adminServerImage string

param logAnalyticsName string = ''

param applicationInsightsConnString string

var vnetPrefix = '10.1.0.0/16'
var infraSubnetPrefix = '10.1.0.0/24'
var infraSubnetName = '${abbrs.networkVirtualNetworksSubnets}infra'

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

@description('Organize resources in a resource group')
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module vnet './modules/network/vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    name: '${abbrs.networkVirtualNetworks}${environmentName}'
    location: location
    vnetAddressPrefixes: [vnetPrefix]
    subnets: [
      {
        name: infraSubnetName
        properties: {
          addressPrefix: infraSubnetPrefix
          delegations: [
            {
              name: 'ContainerAppsEnvInfra'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
    tags: tags
  }
}

module logAnalytics 'modules/shared/logAnalyticsWorkspace.bicep' = {
  name: 'log-analytics'
  scope: rg
  params: {
    name: !empty(logAnalyticsName) ? logAnalyticsName : 'la-${environmentName}'
    tags: tags
  }
}

module managedEnvironment 'modules/containerapps/aca-environment.bicep' = {
  name: 'managedEnvironment'
  scope: rg
  params: {
    name: !empty(managedEnvironmentsName) ? managedEnvironmentsName : 'aca-env-${environmentName}'
    location: location
    vnetEndpointInternal: vnetEndpointInternal
    diagnosticWorkspaceId: logAnalytics.outputs.logAnalyticsWsId
    subnetId: first(filter(vnet.outputs.vnetSubnets, x => x.name == infraSubnetName)).id
    tags: tags
  }
}

module javaComponents 'modules/containerapps/containerapp-java-components.bicep' = {
  name: 'javaComponents'
  scope: rg
  params: {
    managedEnvironmentsName: managedEnvironment.outputs.containerAppsEnvironmentName
    configServerGitRepo: configGitRepo
    configServerGitBranch: configGitBranch
    configServerGitPath: configGitPath
  }
}

module mysql 'modules/database/mysql.bicep' = {
  name: 'mysql'
  scope: rg
  params: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlAdminPassword
    serverName: !empty(sqlServerName) ? sqlServerName : '${abbrs.sqlServers}${environmentName}'
    databaseName: 'petclinic'
    version: '8.0.21'
  }
}

module applications 'modules/app/petclinic.bicep' = {
  name: 'petclinic-microservices'
  scope: rg
  params: {
    managedEnvironmentsName: managedEnvironment.outputs.containerAppsEnvironmentName
    eurekaId: javaComponents.outputs.eurekaId
    configServerId: javaComponents.outputs.configServerId
    mysqlDBId: mysql.outputs.databaseId
    mysqlUserAssignedIdentityClientId: mysql.outputs.userAssignedIdentityClientId
    acrRegistry: acrRegistry
    acrIdentityId: acrIdentityId
    apiGatewayImage: apiGatewayImage
    customerServiceImage: customerServiceImage
    vetsServiceImage: vetsServiceImage
    visitsServiceImage: visitsServiceImage
    adminServerImage: adminServerImage
    targetPort: 8080
    applicationInsightsConnString: applicationInsightsConnString
  }
}

output gatewayFqdn string = applications.outputs.gatewayFqdn
output adminFqdn string = applications.outputs.adminFqdn
output eurekaId string = javaComponents.outputs.eurekaId
output configServerId string = javaComponents.outputs.configServerId
output databaseId string = mysql.outputs.databaseId
output userAssignedIdentityClientId string = mysql.outputs.userAssignedIdentityClientId
