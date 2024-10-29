// ------------------
//    PARAMETERS
// ------------------

@description('Required. Name of your Azure Container Apps Environment. ')
param name string

@description('Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional, default value is false. Sets if the environment will use availability zones. Your Container App Environment and the apps in it will be zone redundant. This requieres vNet integration.')
param zoneRedundant bool = false

@description('Optional, the workload profiles required by the end user. The default is "Consumption", and is automatically added whether workload profiles are specified or not.')
param workloadProfiles array = []
// Example of a workload profile below:
// [ {
//     workloadProfileType: 'D4'  // available types can be found here: https://learn.microsoft.com/en-us/azure/container-apps/workload-profiles-overview#profile-types
//     name: '<name of the workload profile>'
//     minimumCount: 1
//     maximumCount: 3
//   }
// ]

@description('Bool value to indicate if vnet inject required. Default: false')
param isVnet bool = false

@description('If true, the endpoint is an internal load balancer. If false the hosted apps are exposed on an internet-accessible IP address. Default: false')
param vnetEndpointInternal bool = false

@description('Custome vnet configuration for the nevironment. The subnet associated with a Container App Environment requires a CIDR prefix of /23 or larger')
param vnetSubnetId string = ''

@description('optional, default is empty. Resource group for the infrastructure resources (e.g. load balancer, public IP, etc.)')
param infrastructureResourceGroupName string = ''

@description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticEventHubName string = ''

@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.')
@allowed([
  'allLogs'
  'ContainerAppConsoleLogs'
  'ContainerAppSystemLogs'
  'AppEnvSpringAppConsoleLogs'
])
param diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".')
param diagnosticSettingsName string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}


// ------------------
// VARIABLES
// ------------------

var diagnosticsLogsSpecified = [for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs'): {
  category: category
  enabled: true
}]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs') ? [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
] : diagnosticsLogsSpecified

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

var defaultWorkloadProfile = [
  {
    workloadProfileType: 'Consumption'
    name: 'Consumption'
  }
]

var effectiveWorkloadProfiles = workloadProfiles != [] ? concat(defaultWorkloadProfile, workloadProfiles) : defaultWorkloadProfile

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

// ------------------
// RESOURCES
// ------------------

resource acaEnvironment 'Microsoft.App/managedEnvironments@2024-02-02-preview' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    zoneRedundant: zoneRedundant
    vnetConfiguration: isVnet ? {
      internal: vnetEndpointInternal
      infrastructureSubnetId: vnetSubnetId
    } : null
    workloadProfiles: effectiveWorkloadProfiles
    appLogsConfiguration: {
        destination: 'azure-monitor'
      }
    infrastructureResourceGroup: empty(infrastructureResourceGroupName) ? take('ME_${resourceGroup().name}_${name}', 63) : infrastructureResourceGroupName
  }
}

resource acaEnvironment_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: !empty(diagnosticSettingsName) ? diagnosticSettingsName : '${name}-diagnosticSettings'
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: acaEnvironment
}


// ------------------
// OUTPUTS
// ------------------

@description('The Name of the Azure container app environment.')
output containerAppsEnvironmentName string = acaEnvironment.name

@description('The resource ID of the Azure container app environment.')
output containerAppsEnvironmentNameId string = acaEnvironment.id

@description('The default domain of the Azure container app environment.')
output containerAppsEnvironmentDefaultDomain string = acaEnvironment.properties.defaultDomain

@description('The Azure container app environment\'s Load Balancer IP.')
output containerAppsEnvironmentLoadBalancerIP string = acaEnvironment.properties.staticIp
