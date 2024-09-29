targetScope = 'resourceGroup'

import { roleAssignmentType, builtInRoleNames } from 'containerRegistryRolesDef.bicep'

param name string

param roleAssignments roleAssignmentType

resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: name
}

resource registry_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, index) in (roleAssignments ?? []): {
  name: guid(registry.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    description: roleAssignment.?description
    principalType: roleAssignment.?principalType
    condition: roleAssignment.?condition
    conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
    delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
  }
  scope: registry
}]

output name string = registry.name
output loginServer string = registry.properties.loginServer
