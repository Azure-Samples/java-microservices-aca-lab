targetScope = 'resourceGroup'

param acrName string

param images array

param umiAcrContributorId string

resource importImage 'Microsoft.Resources/deploymentScripts@2023-08-01' = [ for image in images: {
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
        value: image.source
      }
      {
        name: 'image'
        value: image.name
      }
    ]
    scriptContent: 'az acr import --name "$acrName" --source "$source" --image "$image" --force'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}]
