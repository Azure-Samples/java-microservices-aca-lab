metadata description = 'Creates java components in an Azure Container App environment.'

@description('Name of the environment for container apps')
param containerAppsEnvironmentName string

@description('The config server git uri')
param configServerGitRepo string

@description('The config server git label')
param configServerGitLabel string

@description('The config server git search-path')
param configServerGitSearchPath string

resource configServer 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironmentsResource
  name: 'configserver'
  properties: {
    componentType: 'SpringCloudConfig'
    configurations: [
      {
        propertyName: 'spring.cloud.config.server.git.uri'
        value: configServerGitRepo
      }
      {
        propertyName: 'spring.cloud.config.server.git.default-label'
        value: configServerGitLabel
      }
      {
        propertyName: 'spring.cloud.config.server.git.search-paths'
        value: configServerGitSearchPath
      }
      {
        propertyName: 'spring.cloud.config.server.git.refresh-rate'
        value: '60'
      }      
    ]
  }
}

resource eureka 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  dependsOn: [
    configServer
  ]
  parent: managedEnvironmentsResource
  name: 'eureka'
  properties: {
    componentType: 'SpringCloudEureka'
    configurations: [
      {
        propertyName: 'eureka.server.response-cache-update-interval-ms'
        value: '10000'
      }
    ]
  }
}

resource springbootadmin 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironmentsResource
  name: 'springbootadmin'
  properties: {
    componentType: 'SpringBootAdmin'
    serviceBinds: [
      {
        name: eureka.name
        serviceId: eureka.id
      }
    ]
  }
}

resource managedEnvironmentsResource 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppsEnvironmentName
}

output eurekaId string = eureka.id
output configServerId string = configServer.id

output springbootAdminFqdn string = springbootadmin.properties.ingress.fqdn
