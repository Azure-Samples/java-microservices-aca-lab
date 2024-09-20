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
param miClientId string
param miPrincipalId string
param apiGatewayImage string
param customersServiceImage string
param vetsServiceImage string
param visitsServiceImage string
param adminServerImage string
param chatAgentImage string

param logAnalyticsName string = ''
param applicationInsightsName string = ''

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

@description('Azure Application Insights, the workload\' log & metric sink and APM tool')
module applicationInsights 'modules/shared/applicationInsights.bicep' = {
  name: 'application-insights'
  scope: rg
  params: {
    name: !empty(applicationInsightsName) ? applicationInsightsName : 'ai-${environmentName}'
    location: location
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWsId
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
  }
}

module openai 'modules/ai/openai.bicep' = {
  name: 'openai'
  scope: rg
  params: {
    accountName: 'openai-${environmentName}'
    location: location
    appPrincipalId: miPrincipalId
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
    customersServiceImage: customersServiceImage
    vetsServiceImage: vetsServiceImage
    visitsServiceImage: visitsServiceImage
    adminServerImage: adminServerImage
    chatAgentImage: chatAgentImage
    targetPort: 8080
    applicationInsightsConnString: applicationInsights.outputs.connectionString
    azureOpenAiEndpoint: openai.outputs.endpoint
    openAiClientId: acrIdentityId
  }
}

output gatewayFqdn string = applications.outputs.gatewayFqdn
output adminFqdn string = applications.outputs.adminFqdn
output eurekaId string = javaComponents.outputs.eurekaId
output configServerId string = javaComponents.outputs.configServerId
output databaseId string = mysql.outputs.databaseId
output userAssignedIdentityClientId string = mysql.outputs.userAssignedIdentityClientId
