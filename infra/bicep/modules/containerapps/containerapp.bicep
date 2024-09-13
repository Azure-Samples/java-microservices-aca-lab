param location string
param managedEnvironmentId string
param registry string
param image string
param appName string
param eurekaId string
param configServerId string
param external bool = false
param containerRegistryUserAssignedIdentityId string
param env array = []
param targetPort int
param createSqlConnection bool = false
param mysqlDBId string = ''
param mysqlUserAssignedIdentityClientId string = ''
param readinessProbeInitialDelaySeconds int = 10
param livenessProbeInitialDelaySeconds int = 30

resource app 'Microsoft.App/containerApps@2024-02-02-preview' = {
  name: appName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerRegistryUserAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      ingress: {
        external: external
        targetPort: targetPort
      }
      registries: containerRegistryUserAssignedIdentityId == null ? null : [
        {
          server: registry
          identity: containerRegistryUserAssignedIdentityId
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

var mysqlToken = !empty(mysqlDBId) ? split(mysqlDBId, '/') : array('')
var mysqlSubscriptionId = length(mysqlToken) > 2 ? mysqlToken[2] : ''

resource connectDB 'Microsoft.ServiceLinker/linkers@2023-04-01-preview' = if (createSqlConnection) {
  name: 'mysql_conn'
  scope: app
  properties: {
    scope: appName
    clientType: 'springBoot'
    authInfo: {
      authType: 'userAssignedIdentity'
      clientId: mysqlUserAssignedIdentityClientId
      subscriptionId: mysqlSubscriptionId
      userName: 'aad_mysql_conn'
    }
    targetService: {
      type: 'AzureResource'
      id: mysqlDBId
    }
  }
}

output appId string = app.id
output appFqdn string = app.properties.configuration.ingress != null ? app.properties.configuration.ingress.fqdn : ''
