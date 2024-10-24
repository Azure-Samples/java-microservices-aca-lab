targetScope = 'resourceGroup'

param acrName string

param images array

param umiAcrContributorId string

resource importImage 'Microsoft.Resources/deploymentScripts@2023-08-01' = [ for image in images: {
  name: 'acr-import-image-${image.name}'
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
        name: 'target'
        value: image.target
      }
    ]
    scriptContent: '''
      az acr import --name $acrName --source $source --image $target --force
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}]

output results array = [ for i in range(0, length(images)): {
  name: importImage[i].name
  errorCode: importImage[i].properties.status.?error.code
  errorMessage: importImage[i].properties.status.?error.message
}]
