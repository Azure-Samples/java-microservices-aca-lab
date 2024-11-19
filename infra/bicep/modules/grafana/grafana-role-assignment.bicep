targetScope = 'subscription'

@description('Required. The subscription ID where the role assignment will be created.')
param subscriptionId string = subscription().id

@description('Required. The principal ID of the Managed Identity for the Grafana resource.')
param grafanaPrincipalId string

@description('Optional. The role definition ID for the Monitoring Reader role. Default: Monitoring Reader role.')
param grafanaRoleDefinitionId string = 'b0d8363b-8ddd-447d-831f-62ca05bff136' // Monitoring Reader role

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, grafanaPrincipalId, grafanaRoleDefinitionId)
  properties: {
    roleDefinitionId: grafanaRoleDefinitionId
    principalId: grafanaPrincipalId
    principalType: 'ServicePrincipal'
    scope: subscriptionId
  }
}
