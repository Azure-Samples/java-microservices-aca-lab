import { roleAssignmentType, builtInRoleNames } from 'containerRegistryRolesDef.bicep'

@description('Required. Name of the Azure Container Registry')
param name string

@description('Optional. Resource Group of the Azure Container Registry')
param resourceGroupName string

@description('Optional. Subscription of the Azure Container Registry')
param subscriptionId string

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Determines whether or not new container registry should be provisioned.')
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

module umiAcrPull '../../modules/shared/userAssignedIdentity.bicep' = {
  name: 'umi-acr-pull'
  params: {
    name: 'umi-${name}-acrpull'
  }
}

// Contributor is needed to import ACR
module umiAcrContributor '../../modules/shared/userAssignedIdentity.bicep' = {
  name: 'umi-acr-contributor'
  params: {
    name: 'umi-${name}-contributor'
  }
}

var roleAssignments = [
    {
      principalId: umiAcrPull.outputs.principalId
      roleDefinitionIdOrName: builtInRoleNames.AcrPull
      principalType: 'ServicePrincipal'
    }
    {
      principalId: umiAcrContributor.outputs.principalId
      roleDefinitionIdOrName: builtInRoleNames.Contributor
      principalType: 'ServicePrincipal'
    }
  ]

module acrNew './containerRegistry.bicep' = if (newOrExisting == 'new') {
  name: 'acr-new-${name}'
  params: {
    name: name
    location: location
    acrAdminUserEnabled: true
    roleAssignments: roleAssignments
    tags: tags
  }
}

module acrExisting 'acrExisting.bicep' = if (newOrExisting == 'existing') {
  name: 'acr-existing-${name}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    name: name
    roleAssignments: roleAssignments
  }
}

var acrName = (newOrExisting == 'new') ? acrNew.outputs.name : acrExisting.outputs.name
var loginServer = (newOrExisting == 'new') ? acrNew.outputs.loginServer : acrExisting.outputs.loginServer

output name string = acrName
output loginServer string = loginServer

output umiAcrPullId string = umiAcrPull.outputs.id
output umiAcrPullPrincipalId string = umiAcrPull.outputs.principalId
output umiAcrPullClientId string = umiAcrPull.outputs.clientId

output umiAcrContributorId string = umiAcrContributor.outputs.id
output umiAcrContributorPrincipalId string = umiAcrContributor.outputs.principalId
output umiAcrContributorClientId string = umiAcrContributor.outputs.clientId
