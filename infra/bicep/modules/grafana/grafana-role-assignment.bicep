targetScope = 'resourceGroup'

@description('Required. The principal ID of the Managed Identity for the Grafana resource.')
param grafanaPrincipalId string

@description('Optional. The role definition ID for the Monitoring Reader role. Default: Monitoring Reader role.')
// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/monitor#monitoring-reader
param grafanaRoleDefinitionId string = '43d0d8ad-25c7-4714-9337-8ba259a9fe05' // Monitoring Reader role

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, grafanaPrincipalId, grafanaRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', grafanaRoleDefinitionId)
    principalId: grafanaPrincipalId
    principalType: 'ServicePrincipal'
  }
}
