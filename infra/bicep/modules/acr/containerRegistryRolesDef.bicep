@export()
type roleAssignmentType = {
  @description('Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device' | null)?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?

@export()
var builtInRoleNames = {
  // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#general
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

  // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#containers
  AcrDelete: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'c2f4ef07-c644-48eb-af81-4b1b4947fb11')
  AcrImageSigner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '6cef56e8-d556-48e5-a04f-b8e64114680f')
  AcrPull: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  AcrPush: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')
  AcrQuarantineReader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'cdda3590-29a3-44f6-95f2-9f980659eb04')
  AcrQuarantineWriter: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'c8d4ff99-41c3-41a8-9f60-21dfdad59608')
  'Azure Arc Enabled Kubernetes Cluster User Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00493d72-78f6-4148-b6c5-d3ce8e4799dd')
  'Azure Arc Kubernetes Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'dffb1e0c-446f-4dde-a09f-99eb5cc68b96')
  'Azure Arc Kubernetes Cluster Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8393591c-06b9-48a2-a542-1bd6b377f6a2')
  'Azure Arc Kubernetes Viewer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '63f0a09d-1495-4db4-a681-037d84835eb4')
  'Azure Arc Kubernetes Writer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5b999177-9696-4545-85c7-50de3797e5a1')
  'Azure Container Storage Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '95dd08a6-00bd-4661-84bf-f6726f83a4d0')
  'Azure Container Storage Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '08d4c71a-cc63-4ce4-a9c8-5dd251b4d619')
  'Azure Container Storage Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '95de85bd-744d-4664-9dde-11430bc34793')
  'Azure Kubernetes Fleet Manager Contributor Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '63bb64ad-9799-4770-b5c3-24ed299a07bf')
  'Azure Kubernetes Fleet Manager RBAC Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '434fb43a-c01c-447e-9f67-c3ad923cfaba')
  'Azure Kubernetes Fleet Manager RBAC Cluster Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18ab4d3d-a1bf-4477-8ad9-8359bc988f69')
  'Azure Kubernetes Fleet Manager RBAC Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '30b27cfc-9c84-438e-b0ce-70e35255df80')
  'Azure Kubernetes Fleet Manager RBAC Writer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5af6afb3-c06c-4fa4-8848-71a8aee05683')
  'Azure Kubernetes Service Cluster Admin Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')
  'Azure Kubernetes Service Cluster Monitoring User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1afdec4b-e479-420e-99e7-f82237c7c5e6')
  'Azure Kubernetes Service Cluster User Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4abbcc35-e782-43d8-92c5-2d3f1bd2253f')
  'Azure Kubernetes Service Contributor Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8')
  'Azure Kubernetes Service RBAC Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3498e952-d568-435e-9b2c-8d77e338d7f7')
  'Azure Kubernetes Service RBAC Cluster Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b')
  'Azure Kubernetes Service RBAC Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f6c6a51-bcf8-42ba-9220-52d62157d7db')
  'Azure Kubernetes Service RBAC Writer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a7ffa36f-339b-4b5c-8bdf-e2c188b2c0eb')
  'Kubernetes Agentless Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'd5a2ae44-610b-4500-93be-660a0c5f5ca6')
  'Kubernetes Cluster - Azure Arc Onboarding': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '34e09817-6cbe-4d01-b1a2-e0eac5743d41')
  'Kubernetes Extension Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '85cb6faf-e071-4c9b-8136-154b5a04f717')
}
