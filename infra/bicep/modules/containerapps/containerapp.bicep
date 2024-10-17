metadata description = 'Creates a container app in an Azure Container App environment.'

param name string
param location string = resourceGroup().location
param tags object = {}

@description('ActiveRevisionsMode controls how active revisions are handled for the Container app')
@allowed([
  'Multiple'
  'Single'
])
param revisionMode string = 'Single'

@description('Specifies if Ingress is enabled for the container app')
param ingressEnabled bool = true

@description('The target port for the container')
param targetPort int = 80

@description('Bool indicating if app exposes an external http endpoint. Default: false')
param external bool = false

@description('Allowed origins')
param allowedOrigins array = []

@description('Name of the environment for container apps')
param containerAppsEnvironmentName string

@description('CPU cores allocated to a single container instance, e.g., 0.5')
param containerCpuCoreCount string = '0.5'

@description('Memory allocated to a single container instance, e.g., 1Gi')
param containerMemory string = '1.0Gi'

@description('The minimum number of replicas to run. Must be at least 1.')
param containerMinReplicas int = 1

@description('The maximum number of replicas to run. Must be at least 1.')
@minValue(1)
param containerMaxReplicas int = 5

@description('The name of the container. Default: the app name')
param containerName string = ''

@description('Whether this is a Java app. Java app will have Java language stack enabled.')
param isJava bool = false

@description('The service binds associated with the container')
param serviceBinds array = []

@description('The name of the container registry')
param acrName string

@description('The id of the user managed identity to pull image from the ACR')
param acrIdentityId string

@description('The name of the container image')
param imageName string

@description('The environment variables for the container')
param env array = []

@description('The id of the user managed identity assigned to this app')
param umiAppsIdentityId string = ''

param readinessProbeInitialDelaySeconds int = 10
param livenessProbeInitialDelaySeconds int = 30

var userIdentities = union({
    '${acrIdentityId}': {}
  },
  empty(umiAppsIdentityId) ? {} : {
    '${umiAppsIdentityId}': {}
  })

var cntName = !empty(containerName) ? containerName : name

resource app 'Microsoft.App/containerApps@2024-02-02-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: userIdentities
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: revisionMode
      ingress: ingressEnabled ? {
        external: external
        targetPort: targetPort
        transport: 'auto'
        corsPolicy: {
          allowedOrigins: union([ 'https://portal.azure.com', 'https://ms.portal.azure.com' ], allowedOrigins)
        }
      } : null
      registries: empty(acrIdentityId) ? null : [
        {
          server: acrName
          identity: acrIdentityId
        }
      ]
      runtime: isJava ? {
        java: {
          enableMetrics: true
        }
      } : null
    }
    template: {
      serviceBinds: !empty(serviceBinds) ? serviceBinds : null
      terminationGracePeriodSeconds: 60
      containers: [
        {
          image: '${acrName}/${imageName}'
          imageType: 'ContainerImage'
          name: cntName
          env: env
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemory
          }
          probes: [
            {
              type: 'Liveness'
              failureThreshold: 3
              httpGet: {
                path: '/actuator/health/liveness'
                port: 8080
                scheme: 'HTTP'
              }
              initialDelaySeconds: livenessProbeInitialDelaySeconds
              periodSeconds: 5
              successThreshold: 1
              timeoutSeconds: 3
            }
            {
              type: 'Readiness'
              failureThreshold: 5
              httpGet: {
                path: '/actuator/health/readiness'
                port: 8080
                scheme: 'HTTP'
              }
              initialDelaySeconds: readinessProbeInitialDelaySeconds
              periodSeconds: 3
              successThreshold: 1
              timeoutSeconds: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: containerMinReplicas
        maxReplicas: containerMaxReplicas
      }
    }
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppsEnvironmentName
}

output appId string = app.id
output appName string = app.name
output appContainerName string = cntName
output appFqdn string = app.properties.configuration.ingress != null ? app.properties.configuration.ingress.fqdn : ''
