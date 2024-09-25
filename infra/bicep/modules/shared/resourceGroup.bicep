targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string

param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: tags
}

output name string = rg.name
