targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

output name string = rg.name
