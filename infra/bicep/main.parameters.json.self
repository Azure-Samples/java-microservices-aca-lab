{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vnetEndpointInternal": {
            "value": false
        },
        "sqlAdmin": {
            "value": "azureuser"
        },
        "sqlAdminPassword": {
            "value": "Password#123"
        },
        "configGitRepo": {
            "value": "https://github.com/sonwan2020/java-microservices-aca-lab"
        },
        "configGitPath": {
            "value": "config"
        },
        "acrRegistry": {
            "value": "sonwanacr.azurecr.io"
        },
        "acrIdentityId": {
            "value": "/subscriptions/d0822b01-62ea-4eb9-885b-95c60e4250b4/resourcegroups/capps-sonwan-dev-rg/providers/microsoft.managedidentity/userassignedidentities/umi-sonwanacr"
        },
        "apiGatewayImage": {
            "value": "java-microservices-aca-lab/spring-petclinic-api-gateway:passwordless"
        },
        "customerServiceImage": {
            "value": "java-microservices-aca-lab/spring-petclinic-customers-service:passwordless"
        },
        "vetsServiceImage": {
            "value": "java-microservices-aca-lab/spring-petclinic-vets-service:passwordless"
        },
        "visitsServiceImage": {
            "value": "java-microservices-aca-lab/spring-petclinic-visits-service:passwordless"
        },
        "adminServerImage": {
            "value": "java-microservices-aca-lab/spring-petclinic-admin-server:passwordless"
        },
        "applicationInsightsConnString": {
            "value": "InstrumentationKey=28ceb383-eaf8-484d-ae55-fdcff27cf4b0;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/;ApplicationId=aae093f1-4b3d-46ec-80e1-3ab4c684ea75"
        }
    }
}
