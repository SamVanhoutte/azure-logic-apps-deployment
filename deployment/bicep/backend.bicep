targetScope = 'subscription'

param location string = deployment().location
@minLength(3)
@maxLength(3)
param locationAcronym string
@allowed(['dev', 'tst', 'prd'])
param environmentAcronym string
param appServiceClientId string
param companyName string = 'samvhintx'

// resource groups are create by the foundation resource deployment template to ensure that all resource groups are available for further deployment steps
resource backendResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${locationAcronym}-${environmentAcronym}-logapp-rg-backend'
  location: location
}

// set up Log Analytics workspace
module defaultLogAnalyticsWorkspace 'modules/log-analytics-workspace.bicep' = {
  name: 'defaultLogAnalyticsWorkspace'
  scope: backendResourceGroup
  params: {
    logAnalyticsWorkspaceName: '${locationAcronym}-${environmentAcronym}-${companyName}-law-default'
    location: location
  }
}

var defaultApplicationInsightsName = '${locationAcronym}-${environmentAcronym}-${companyName}-ain-default'

// set up application insights for monitoring
module defaultApplicationInsights 'modules/application-insights.bicep' = {
  name: 'defaultApplicationInsights'
  scope: backendResourceGroup
  params: {
    applicationInsightsName: defaultApplicationInsightsName
    location: location
    workspaceResourceId: defaultLogAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
}

// apim instance deployment
module apiManagement 'modules/api-management.bicep' = {
  name: 'apiManagement'
  scope: backendResourceGroup
  params: {
    apiManagementName: '${locationAcronym}-${environmentAcronym}-${companyName}-apim'
    location: location 
    applicationInsightsResourceId: defaultApplicationInsights.outputs.resourceId
    applicationInsightsInstrumentationKey: defaultApplicationInsights.outputs.instrumentationKey
    applicationInsightsName: defaultApplicationInsights.outputs.name
    sku: {
      name: 'BasicV2'
      capacity: 1
    }
    environmentAcronym: environmentAcronym
    apiProxyHostName: ''
    apiProxyCertKeyVaultId: ''
    developerPortalHostName: ''
    developerPortalCertKeyVaultId: ''
  } 
}

// Deploy actual API
var apiManagementName = '${locationAcronym}-${environmentAcronym}-${companyName}-apim'

// deploy APIs to the API management instance
var backend_api_policy = '''
<policies>
    <inbound>
        <authentication-managed-identity resource="{0}" />
        <base />
    </inbound>
</policies>
'''

module backendApi 'modules/api-management-api.bicep' = {
  name: 'backendApi'
  scope: backendResourceGroup
  params: {
    locationAcronym: locationAcronym
    environmentAcronym: environmentAcronym
    apiManagementName: apiManagementName
    apiSpec: string(loadJsonContent('../api/backend-openapi.json'))
    format: 'openapi+json'
    path: 'backend/api/v1'
    // The following should typically be taken from output of the actual bicep module for App Service
    // But this sample is focusing on the API Management side of things
    serviceUrl: 'https://weu-dev-samvhintx-app-backend-api.azurewebsites.net/'
    displayName: 'SVH IntX API (${environmentAcronym})'
    description: 'The API that provides all required functionality on the ${environmentAcronym} environment.'
    name: '${environmentAcronym}-api-backend'
    policy: format(backend_api_policy, appServiceClientId)
    namedValues: [ ]
  }
}

// module publicApi 'modules/api-management-api.bicep' = {
//   name: 'publicApi'
//   scope: backendResourceGroup
//   params: {
//     locationAcronym: locationAcronym
//     environmentAcronym: environmentAcronym
//     apiManagementName: apiManagementName
//     apiSpec: string(loadJsonContent('../api/backend-public-openapi.json'))
//     format: 'openapi+json'
//     path: 'public/api/v1'
//     // The following should typically be taken from output of the actual bicep module for App Service
//     // But this sample is focusing on the API Management side of things
//     serviceUrl: 'https://weu-dev-samvhintx-app-backend-api.azurewebsites.net/'
//     displayName: 'SVH IntX Public API (${environmentAcronym})'
//     description: 'The API that provides all required functionality on the ${environmentAcronym} environment.'
//     name: '${environmentAcronym}-api-public'
//     policy: format(backend_api_policy, appServiceClientId)
//     namedValues: [ ]
//   }
// }
