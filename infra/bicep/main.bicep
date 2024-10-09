targetScope = 'subscription'

@minLength(2)
@maxLength(32)
@description('Name of the the azd environment.')
param environmentName string

@minLength(2)
@description('Primary location for all resources.')
param location string

@description('Name of the the resource group. Default: rg-{environmentName}')
param resourceGroupName string = ''

@description('Name of the the new containerapp environment. Default: aca-env-{environmentName}')
param managedEnvironmentsName string = ''

@description('Boolean indicating the aca environment only has an internal load balancer. ')
param vnetEndpointInternal bool = false

@description('Name of the the sql server. Default: sql-{environmentName}')
param sqlServerName string = ''

@description('Name of the the sql admin.')
param sqlAdmin string

@description('The the sql admin password.')
@secure()
param sqlAdminPassword string

@description('Repo url of the configure server.')
param configGitRepo string = 'https://github.com/Azure-Samples/java-microservices-aca-lab'

@description('Repo branch of the configure server.')
param configGitBranch string = 'main'

@description('Repo path of the configure server.')
param configGitPath string = 'config'

@description('Name of the azure container registry.')
param acrName string = ''
@description('Resource group of the azure container registry.')
param acrGroupName string = ''
@description('Subscription of the azure container registry.')
param acrSubscription string = ''

@description('Enable OpenAI components')
param enableOpenAi bool = true
@description('Name of the Open AI name, Default: openai-{environmentName}')
param openAiName string = ''
@description('Resource group of the Open AI, Default: the resourceGroup above')
param openAiResourceGroup string = ''
@description('Location of the Open AI, Default: the location above')
param openAiLocation string = ''
@description('Subscription of the Open AI, Default: your current subscription')
param openAiSubscription string = ''

@description('Name of the log analytics server. Default la-{environmentName}')
param logAnalyticsName string = ''

@description('Name of the log analytics server. Default app-insights-{environmentName}')
param applicationInsightsName string = ''

@description('Images for petclinic services, will replaced by new images on step `azd deploy`')
param apiGatewayImage string = ''
param customersServiceImage string = ''
param vetsServiceImage string = ''
param visitsServiceImage string = ''
param adminServerImage string = ''
param chatAgentImage string = ''

@description('Name of the virtual network. Default vnet-{environmentName}')
param vnetName string = ''

var vnetPrefix = '10.1.0.0/16'
var infraSubnetPrefix = '10.1.0.0/24'
var infraSubnetName = '${abbrs.networkVirtualNetworksSubnets}infra'

var placeholderImage = 'azurespringapps/default-banner:latest'

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

@description('Organize resources in a resource group')
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module umiApps 'modules/shared/userAssignedIdentity.bicep' = {
  name: 'umi-apps'
  scope: rg
  params: {
    name: 'umi-apps-${environmentName}'
  }
}

module vnet './modules/network/vnet.bicep' = {
  name: 'vnet-${environmentName}'
  scope: rg
  params: {
    name: !empty(vnetName) ? vnetName : '${abbrs.networkVirtualNetworks}${environmentName}'
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

var acrExisting = !empty(acrName) && !empty(acrGroupName) && !empty(acrSubscription)
var acrGroup = !empty(acrGroupName) ? acrGroupName : rg.name
var acrSub = !empty(acrSubscription) ? acrSubscription : subscription().subscriptionId

module acr 'modules/acr/acr.bicep' = {
  name: 'acr-${environmentName}'
  scope: resourceGroup(acrSub, acrGroup)
  params: {
    name: !empty(acrGroupName) ? acrName : '${abbrs.containerRegistryRegistries}${uniqueString(rg.id)}'
    groupName: acrGroup
    subscriptionId : acrSub
    tags: tags
    newOrExisting: acrExisting ? 'existing' : 'new'
  }
}

var acrLoginServer = acr.outputs.loginServer

module mysql 'modules/database/mysql.bicep' = {
  name: 'mysql-${environmentName}'
  scope: rg
  params: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlAdminPassword
    serverName: !empty(sqlServerName) ? sqlServerName : '${abbrs.sqlServers}${environmentName}'
    databaseName: 'petclinic'
    tags: tags
  }
}

module logAnalytics 'modules/shared/logAnalyticsWorkspace.bicep' = {
  name: 'log-analytics-${environmentName}'
  scope: rg
  params: {
    name: !empty(logAnalyticsName) ? logAnalyticsName : 'la-${environmentName}'
    tags: tags
  }
}

@description('Azure Application Insights, the workload\' log & metric sink and APM tool')
module applicationInsights 'modules/shared/applicationInsights.bicep' = {
  name: 'application-insights-${environmentName}'
  scope: rg
  params: {
    name: !empty(applicationInsightsName) ? applicationInsightsName : 'app-insights-${environmentName}'
    location: location
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWsId
    tags: tags
  }
}

module managedEnvironment 'modules/containerapps/aca-environment.bicep' = {
  name: 'managedEnvironment-${environmentName}'
  scope: rg
  params: {
    name: !empty(managedEnvironmentsName) ? managedEnvironmentsName : 'aca-env-${environmentName}'
    location: location
    vnetEndpointInternal: vnetEndpointInternal
    userAssignedIdentities: {
      '${acr.outputs.umiAcrPullId}': {}
      '${umiApps.outputs.id}': {}
    }
    diagnosticWorkspaceId: logAnalytics.outputs.logAnalyticsWsId
    subnetId: first(filter(vnet.outputs.vnetSubnets, x => x.name == infraSubnetName)).id
    tags: tags
  }
}

module javaComponents 'modules/containerapps/containerapp-java-components.bicep' = {
  name: 'javaComponents-${environmentName}'
  scope: rg
  params: {
    managedEnvironmentsName: managedEnvironment.outputs.containerAppsEnvironmentName
    configServerGitRepo: configGitRepo
    configServerGitBranch: configGitBranch
    configServerGitPath: configGitPath
  }
}

var aiSub = !empty(openAiSubscription) ? openAiSubscription : subscription().subscriptionId
var aiGroup = !empty(openAiResourceGroup) ? openAiResourceGroup : rg.name
var aiLoc = !empty(openAiLocation) ? openAiLocation : location

// You must use modules to deploy resources to a different scope.
module rgOpenAi 'modules/shared/resourceGroup.bicep' = if (enableOpenAi) {
  name: 'rg-openai-${environmentName}'
  scope: subscription(aiSub)
  params: {
    resourceGroupName: aiGroup
    resourceGroupLocation: aiLoc
    tags: tags
  }
}

module openai 'modules/ai/openai.bicep' = if (enableOpenAi) {
  name: 'openai-${environmentName}'
  dependsOn: [
    rgOpenAi
  ]
  scope: resourceGroup(aiSub, aiGroup)
  params: {
    accountName: !empty(openAiName) ? openAiName : 'openai-${environmentName}'
    location: aiLoc
    appPrincipalId: umiApps.outputs.principalId
    tags: tags
  }
}

module applications 'modules/app/petclinic.bicep' = {
  name: 'petclinic-${environmentName}'
  scope: rg
  params: {
    managedEnvironmentsName: managedEnvironment.outputs.containerAppsEnvironmentName
    eurekaId: javaComponents.outputs.eurekaId
    configServerId: javaComponents.outputs.configServerId
    mysqlDatabaseId: mysql.outputs.databaseId
    umiAppsClientId: umiApps.outputs.clientId
    umiAppsIdentityId: umiApps.outputs.id
    acrRegistry: acrLoginServer
    acrIdentityId: acr.outputs.umiAcrPullId
    apiGatewayImage: !empty(apiGatewayImage) ? apiGatewayImage : placeholderImage
    customersServiceImage: !empty(customersServiceImage) ? customersServiceImage : placeholderImage
    vetsServiceImage: !empty(vetsServiceImage) ? vetsServiceImage : placeholderImage
    visitsServiceImage: !empty(visitsServiceImage) ? visitsServiceImage : placeholderImage
    adminServerImage: !empty(adminServerImage) ? adminServerImage : placeholderImage
    chatAgentImage: !empty(chatAgentImage) ? chatAgentImage : placeholderImage
    targetPort: 8080
    applicationInsightsConnString: applicationInsights.outputs.connectionString
    enableOpenAi: enableOpenAi
    openAiEndpoint: openai.outputs.endpoint
    openAiClientId: umiApps.outputs.clientId
  }
}

output subscriptionId string = subscription().subscriptionId
output resourceGroupName string = rg.name

output acrLoginServer string = acrLoginServer

output springbootAdminFqdn string = javaComponents.outputs.springbootAdminFqdn
output gatewayFqdn string = applications.outputs.gatewayFqdn
output adminFqdn string = applications.outputs.adminFqdn

output sqlDatabaseId string = mysql.outputs.databaseId
output sqlAdminIdentityClientId string = mysql.outputs.adminIdentityClientId
output sqlAdminIdentityId string = mysql.outputs.adminIdentityId
output sqlConnectName string = applications.outputs.connectionName

output appUserIdentityClientId string = umiApps.outputs.clientId
output appUserIdentityId string = umiApps.outputs.id

output customersServiceName string = applications.outputs.customersServiceName
output customersServiceId string = applications.outputs.customersServiceId
output vetsServiceName string = applications.outputs.vetsServiceName
output vetsServiceId string = applications.outputs.vetsServiceId
output visitsServiceName string = applications.outputs.visitsServiceName
output visitsServiceId string = applications.outputs.visitsServiceId
