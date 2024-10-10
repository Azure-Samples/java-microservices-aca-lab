targetScope = 'resourceGroup'

@description('Resource name to check in current scope (resource group)')
param resourceName string

@description('Resource ID of user managed identity with reader permissions in current scope')
param identityPrincipalId string

param location string = resourceGroup().location
param utcValue string = utcNow()

// used to pass into deployment script
var resourceGroupName = resourceGroup().name

// The script below performs an 'az resource list' command to determine whether a resource exists
resource resource_exists 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'resource-exists'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityPrincipalId}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.63.0'
    timeout: 'PT10M'
    arguments: '\'${resourceGroupName}\' \'${resourceName}\''
    scriptContent: 'result=$(az resource list --resource-group ${resourceGroupName} --name ${resourceName}); echo $result | jq .[].name'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output exists bool = length(resource_exists.properties.outputs.Result) > 0
