import { roleAssignmentType, builtInRoleNames } from 'containerRegistryRolesDef.bicep'

param name string

param groupName string

param subscriptionId string

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
  name: 'acr-new'
  params: {
    name: name
    location: resourceGroup().location
    acrAdminUserEnabled: true
    roleAssignments: roleAssignments
    tags: tags
  }
}

module acrExisting 'acrExisting.bicep' = if (newOrExisting == 'existing') {
  name: 'acr-existing'
  scope: resourceGroup(subscriptionId, groupName)   // on existing, use the sub + group from the source acr
  params: {
    name: name
    roleAssignments: roleAssignments
  }
}

var acrName = (newOrExisting == 'new') ? acrNew.outputs.name : acrExisting.outputs.name
var loginServer = (newOrExisting == 'new') ? acrNew.outputs.loginServer : acrExisting.outputs.loginServer

module improtImage 'importImage.bicep' = {
  name: 'import-image'
  params: {
    acrName: acrName
    source: 'mcr.microsoft.com/azurespringapps/default-banner:distroless-2024022107-66ea1a62-87936983'
    image: 'azurespringapps/default-banner:latest'
    umiAcrContributorId : umiAcrContributor.outputs.id
  }
}

output name string = acrName
output loginServer string = loginServer

output umiAcrPullId string = umiAcrPull.outputs.id
output umiAcrPullPrincipalId string = umiAcrPull.outputs.principalId
output umiAcrPullClientId string = umiAcrPull.outputs.clientId

output umiAcrContributorId string = umiAcrContributor.outputs.id
output umiAcrContributorPrincipalId string = umiAcrContributor.outputs.principalId
output umiAcrContributorClientId string = umiAcrContributor.outputs.clientId
