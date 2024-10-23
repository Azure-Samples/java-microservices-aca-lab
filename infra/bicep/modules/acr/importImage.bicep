targetScope = 'resourceGroup'

param acrName string

param images array

param umiAcrContributorId string

resource importImage 'Microsoft.Resources/deploymentScripts@2023-08-01' = [ for img in images: {
  name: 'acr-import-image'
  location: resourceGroup().location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umiAcrContributorId}': {}
    }
  }
  properties: {
    azCliVersion: '2.63.0'
    timeout: 'PT10M'
    environmentVariables: [
      {
        name: 'acrName'
        value: acrName
      }
      {
        name: 'source'
        value: img.source
      }
      {
        name: 'image'
        value: img.name
      }
    ]
    scriptContent: 'az acr import --name "$acrName" --source "$source" --image "$image" --force'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}]
