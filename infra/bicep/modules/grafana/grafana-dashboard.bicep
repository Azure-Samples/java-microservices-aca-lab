targetScope = 'subscription'

@description('Required. Resource group name of your Azure Managed Grafana resource.')
param resourceGroupName string

@description('Required. Name of your Azure Managed Grafana resource.')
param grafanaName string

@description('Optional. Tags of the resource.')
param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

module azureManagedGrafana 'azure-managed-grafana.bicep' = {
  name: grafanaName
  scope: rg
  params: {
    grafanaName: grafanaName
    tags: tags
  }
}

module grafanaRoleAssignment 'grafana-role-assignment.bicep' = {
  name: 'role-assignment-${grafanaName}'
  scope: subscription()
  params: {
    grafanaPrincipalId: azureManagedGrafana.outputs.grafanaPrincipalId
  }
}

output grafanaDashboardEndpoint string = azureManagedGrafana.outputs.grafanaDashboardEndpoint

