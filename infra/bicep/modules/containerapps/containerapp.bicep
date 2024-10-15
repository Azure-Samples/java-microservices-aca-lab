param location string
param managedEnvironmentId string
param registry string
param image string
param appName string
param eurekaId string
param configServerId string
param external bool = false
param acrIdentityId string
param umiAppsIdentityId string
param umiAppsClientId string = ''
param env array = []
param targetPort int
param sqlConnectionName string = ''
param mysqlDatabaseId string = ''
param readinessProbeInitialDelaySeconds int = 10
param livenessProbeInitialDelaySeconds int = 30

resource app 'Microsoft.App/containerApps@2024-02-02-preview' = {
  name: appName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${acrIdentityId}': {}
      '${umiAppsIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      ingress: {
        external: external
        targetPort: targetPort
      }
      registries: empty(acrIdentityId) ? null : [
        {
          server: registry
          identity: acrIdentityId
        }
      ]
      runtime: {
        java: {
          enableMetrics: true
        }
      }
    }
    template: {
      terminationGracePeriodSeconds: 60
      containers: [
        {
          image: '${registry}/${image}'
          imageType: 'ContainerImage'
          name: appName
          env: concat(env, [
            {
              name: 'SPRING_PROFILES_ACTIVE'
              value: 'passwordless'
            }
          ])
          resources: {
            cpu: 1
            memory: '2Gi'
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
        minReplicas: 1
        maxReplicas: 3
      }
      serviceBinds: [
        {
          serviceId: eurekaId
          name: 'eureka'
        }
        {
          serviceId: configServerId
          name: 'configserver'
        }
      ]
    }
  }
}

var mysqlToken = !empty(mysqlDatabaseId) ? split(mysqlDatabaseId, '/') : array('')
var mysqlSubscriptionId = length(mysqlToken) > 2 ? mysqlToken[2] : ''

resource connectDB 'Microsoft.ServiceLinker/linkers@2023-04-01-preview' = if (!empty(sqlConnectionName)) {
  name: sqlConnectionName
  scope: app
  properties: {
    scope: appName
    clientType: 'springBoot'
    authInfo: {
      authType: 'userAssignedIdentity'
      clientId: umiAppsClientId
      subscriptionId: mysqlSubscriptionId
      userName: 'aad_${sqlConnectionName}'
    }
    targetService: {
      type: 'AzureResource'
      id: mysqlDatabaseId
    }
  }
}

output appName string = app.name
output appId string = app.id
output appFqdn string = app.properties.configuration.ingress != null ? app.properties.configuration.ingress.fqdn : ''
