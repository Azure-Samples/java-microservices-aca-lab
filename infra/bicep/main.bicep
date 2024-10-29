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

@description('Name of the the new containerapp environment. Default: acalab-env-{environmentName}')
param managedEnvironmentsName string = ''

@description('Name of the virtual network. Default vnet-{environmentName}')
param vnetName string = ''

@description('Boolean indicating the aca environment only has an internal load balancer. ')
param vnetEndpointInternal bool = false

@description('Images for petclinic services, will replaced by new images on step `azd deploy`')
param useMcrImage bool = false
param apiGatewayImage string = ''
param customersServiceImage string = ''
param vetsServiceImage string = ''
param visitsServiceImage string = ''
param adminServerImage string = ''
param chatAgentImage string = ''

@description('Bool value to indicate reuse existing sql server. Default: false')
param sqlServerExisting bool = false
@description('Name of the the sql server. Default: sql-{environmentName}')
param sqlServerName string = ''
@description('Name of the the sql server, required if sqlServerExisting = true')
param sqlServerResourceGroup string = ''
@description('Name of the the sql server, required if sqlServerExisting = true')
param sqlServerSubscription string = ''

@description('Name of the the sql admin. Default: sqladmin')
param sqlAdmin string = 'sqladmin'
@description('The the sql admin password. Default random')
@secure()
param sqlAdminPassword string = newGuid()

@description('Repo url of the configure server.')
param configGitRepo string = 'https://github.com/Azure-Samples/java-microservices-aca-lab'
@description('Repo branch of the configure server.')
param configGitBranch string = 'main'
@description('Repo path of the configure server.')
param configGitPath string = 'config'

@description('Bool value to indicate reuse existing container registry. Default: false')
param acrExisting bool = false
@description('Name of the azure container registry.')
param acrName string = ''
@description('Resource group of the azure container registry, required if acrExisting = true')
param acrResourceGroup string = ''
@description('Subscription of the azure container registry, required if acrExisting = true')
param acrSubscription string = ''

@description('Enable OpenAI components')
param enableOpenAi bool = true
@description('Bool value to indicate reuse openAI server. Default: false')
param openAiExisting bool = false
@description('Name of the Open AI name, Default: openai-{environmentName}')
param openAiName string = ''
@description('Resource group of the Open AI, required if openAiExisting = true')
param openAiResourceGroup string = ''
@description('Subscription of the Open AI, required if openAiExisting = true')
param openAiSubscription string = ''

@description('Bool value to indicate reuse Log Analytics workspace. Default: false')
param laWorkspaceExisting bool = false
@description('Name of the Log Analytics workspace. Default la-{environmentName}')
param laWorkspaceName string = ''
@description('Resource group of the Log Analytics workspace, required if laWorkspaceExisting = true')
param laWorkspaceResourceGroup string = ''
@description('Subscription of the Log Analytics workspace, required if laWorkspaceExisting = true')
param laWorkspaceSubscription string = ''

@description('Bool value to indicate reuse Application Insights. Default: false')
param appInsightsExisting bool = false
@description('Name of the Application Insights. Default app-insights-{environmentName}')
param appInsightsName string = ''
@description('Resource group of the Log Analytics workspace, required if appInsightsExisting = true')
param appInsightsResourceGroup string = ''
@description('Subscription of the Log Analytics workspace, required if appInsightsExisting = true')
param appInsightsSubscription string = ''

param utcValue string = utcNow()

var vnetPrefix = '10.1.0.0/16'
var infraSubnetPrefix = '10.1.0.0/24'
var infraSubnetName = '${abbrs.networkVirtualNetworksSubnets}infra'

var abbrs = loadJsonContent('./abbreviations.json')
var tags = {
  'azd-env-name': environmentName
  'azure-samples-java-microservices-aca-lab': true
  'utc-time': utcValue
}

@description('Organize resources in a resource group')
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

@description('Prepare Azure Container Registry for the images with UMI for AcrPull & AcrPush')
module acr 'modules/acr/acr.bicep' = {
  name: 'acr-${environmentName}'
  scope: rg
  params: {
    name: !empty(acrName) ? acrName : '${abbrs.containerRegistryRegistries}${uniqueString(rg.id)}'
    resourceGroupName: acrResourceGroup
    subscriptionId: acrSubscription
    tags: tags
    newOrExisting: acrExisting ? 'existing' : 'new'
  }
}

var placeholderImage = 'mcr.microsoft.com/azurespringapps/default-banner:distroless-2024022107-66ea1a62-87936983'

var acrLoginServer = acr.outputs.loginServer

@description('Create user assigned managed identity for petclinic apps')
// apps will use this managed identity to connect MySQL, openAI etc
module umiApps 'modules/shared/userAssignedIdentity.bicep' = {
  name: 'umi-apps'
  scope: rg
  params: {
    name: 'umi-apps-${environmentName}'
  }
}

@description('Create Vnet for Azure Container Apps')
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

@description('Prepare the MySQL flexible server')
module mysql 'modules/database/mysql.bicep' = {
  name: 'mysql-${environmentName}'
  scope: rg
  params: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlAdminPassword
    serverName: !empty(sqlServerName) ? sqlServerName : '${abbrs.sqlServers}${environmentName}'
    resourceGroupName: sqlServerResourceGroup
    subscriptionId: sqlServerSubscription
    databaseName: 'petclinic' // match the name in sql schema
    tags: tags
    newOrExisting: sqlServerExisting? 'existing' : 'new'
  }
}

var laWorkspaceSub = laWorkspaceExisting ? laWorkspaceSubscription : subscription().subscriptionId
var laWorkspaceGroup = laWorkspaceExisting ? laWorkspaceResourceGroup : rg.name

@description('Prepare the Log Analytics Workspace')
module logAnalytics 'modules/shared/logAnalyticsWorkspace.bicep' = {
  name: 'log-analytics-${environmentName}'
  scope: resourceGroup(laWorkspaceSub, laWorkspaceGroup)
  params: {
    name: !empty(laWorkspaceName) ? laWorkspaceName : 'la-${environmentName}'
    tags: tags
    newOrExisting: laWorkspaceExisting ? 'existing' : 'new'
  }
}

// Azure Application Isnights
var appInsightsSub = appInsightsExisting ? appInsightsSubscription : subscription().subscriptionId
var appInsightsGroup = appInsightsExisting ? appInsightsResourceGroup : rg.name

@description('Azure Application Insights, the workload log & metric sink and APM tool')
module applicationInsights 'modules/shared/applicationInsights.bicep' = {
  name: 'application-insights-${environmentName}'
  scope: resourceGroup(appInsightsSub, appInsightsGroup)
  params: {
    name: !empty(appInsightsName) ? appInsightsName : 'app-insights-${environmentName}'
    location: location
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWsId
    tags: tags
    newOrExisting: appInsightsExisting ? 'existing': 'new'
  }
}

var openAiSub = openAiExisting ? openAiSubscription : subscription().subscriptionId
var openAiGroup = openAiExisting ? openAiResourceGroup : rg.name

@description('Prepare Open AI instance')
module openai 'modules/ai/openai.bicep' = if (enableOpenAi) {
  name: 'openai-${environmentName}'
  scope: resourceGroup(openAiSub, openAiGroup)
  params: {
    accountName: !empty(openAiName) ? openAiName : 'openai-${environmentName}'
    appPrincipalId: umiApps.outputs.principalId
    tags: tags
    newOrExisting: openAiExisting ? 'existing' : 'new'
  }
}

@description('Create Azure Container Apps environment')
module managedEnvironment 'modules/containerapps/aca-environment.bicep' = {
  name: 'managedEnvironment-${environmentName}'
  scope: rg
  params: {
    name: !empty(managedEnvironmentsName) ? managedEnvironmentsName : 'aca-env-${environmentName}'
    location: location
    isVnet: true
    vnetEndpointInternal: vnetEndpointInternal
    vnetSubnetId: first(filter(vnet.outputs.vnetSubnets, x => x.name == infraSubnetName)).id
    userAssignedIdentities: {
      '${acr.outputs.umiAcrPullId}': {}
      '${umiApps.outputs.id}': {}
    }
    diagnosticWorkspaceId: logAnalytics.outputs.logAnalyticsWsId
    tags: tags
  }
}

@description('Create Azure Container Apps Java Components')
module javaComponents 'modules/containerapps/containerapp-java-components.bicep' = {
  name: 'javaComponents-${environmentName}'
  scope: rg
  params: {
    containerAppsEnvironmentName: managedEnvironment.outputs.containerAppsEnvironmentName
    configServerGitRepo: configGitRepo
    configServerGitLabel: configGitBranch
    configServerGitSearchPath: configGitPath
  }
}

@description('Create Azure Container Apps for the petclinic solution')
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
    apiGatewayImage: useMcrImage ? apiGatewayImage : placeholderImage
    chatAgentImage: useMcrImage ? chatAgentImage : placeholderImage
    adminServerImage: useMcrImage ? adminServerImage : placeholderImage
    customersServiceImage: useMcrImage ? customersServiceImage : placeholderImage
    vetsServiceImage: useMcrImage ? vetsServiceImage : placeholderImage
    visitsServiceImage: useMcrImage ? visitsServiceImage : placeholderImage
    targetPort: 8080
    applicationInsightsConnString: applicationInsights.outputs.connectionString
    enableOpenAi: enableOpenAi
    openAiEndpoint: enableOpenAi ? openai.outputs.endpoint : ''
    tags: tags
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

output azdProvisionTimestamp string = 'azd-${environmentName}-${utcValue}'
