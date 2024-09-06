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

// mysql
param sqlServerName string = ''
param sqlAdmin string
@secure()
param sqlAdminPassword string

param configGitRepo string
param configGitBranch string = 'main'

param acrIdentityId string
param acrRegistry string
param simpleHelloImage string
param imageTag string

param vnetPrefix string = '10.1.0.0/16'
param infraSubnetPrefix string = '10.1.0.0/24'
param sqlSubnetPrefix string = '10.1.2.64/28'

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

var infraSubnetName = '${abbrs.networkVirtualNetworksSubnets}infra'

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

module managedEnvironment 'modules/containerapps/aca-environment.bicep' = {
  name: 'managedEnvironment'
  scope: rg
  params: {
    name: !empty(managedEnvironmentsName) ? managedEnvironmentsName : 'aca-env-${environmentName}'
    location: location
    vnetEndpointInternal: false
    tags: tags
    subnetId: first(filter(vnet.outputs.vnetSubnets, x => x.name == infraSubnetName)).id
  }
}

module javaComponents 'modules/containerapps/containerapp-java-components.bicep' = {
  name: 'javaComponents'
  scope: rg
  params: {
    managedEnvironmentsName: managedEnvironment.outputs.containerAppsEnvironmentName
    configServerGitRepo: configGitRepo
    configServerGitBranch: configGitBranch
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
    vnetId: vnet.outputs.vnetId
    subnetName: '${abbrs.networkVirtualNetworksSubnets}sql'
    mysqlSubnetPrefix: sqlSubnetPrefix
  }
}

module applications 'modules/app/petclinic.bicep' = {
  name: 'petclinic-microservices'
  scope: rg
  params: {
    managedEnvironmentsName: managedEnvironmentsName
    eurekaId: javaComponents.outputs.eurekaId
    configServerId: javaComponents.outputs.configServerId
    mysqlDBId: mysql.outputs.databaseId
    mysqlUserAssignedIdentityClientId: mysql.outputs.userAssignedIdentityClientId
    acrRegistry: acrRegistry
    acrIdentityId: acrIdentityId
    imageTag: !empty(imageTag) ? imageTag : 'latest'
    apiGatewayImage: simpleHelloImage
    customerServiceImage: simpleHelloImage
    vetsServiceImage: simpleHelloImage
    visitsServiceImage: simpleHelloImage
    adminServerImage: simpleHelloImage
    targetPort: 8080
  }
}

// output fqdn string = applications.outputs.fqdn
// output eurekaId string = javaComponents.outputs.eurekaId
// output configServerId string = javaComponents.outputs.configServerId
// output databaseId string = mysql.outputs.databaseId
// output userAssignedIdentityClientId string = mysql.outputs.userAssignedIdentityClientId
