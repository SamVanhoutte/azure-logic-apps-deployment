param location string = resourceGroup().location
param apiManagementName string
param applicationInsightsResourceId string
param applicationInsightsInstrumentationKey string
param applicationInsightsName string
param sku object = {
  name: 'Developer'
  capacity: 1
}
param environmentAcronym string
param developerPortalHostName string
param developerPortalCertKeyVaultId string
param apiProxyHostName string
param apiProxyCertKeyVaultId string

// Define the default host name configuration
var defaultHostNameConfig = [
  {
    type: 'Proxy'
    hostName: '${apiManagementName}.azure-api.net'
    negotiateClientCertificate: false
    defaultSslBinding: true
    certificateSource: 'BuiltIn'
  }
]

// Add custom host names if passed in params
var hostNameConfigs = concat(defaultHostNameConfig, (empty(apiProxyHostName) || apiProxyHostName == '') ? [] : [
  // remark: the APIM instance requires secret get and list permissions on the keyvault in order to add the hostname configuration below !!
  {
    type: 'Proxy'
    hostName: apiProxyHostName
    keyVaultId: apiProxyCertKeyVaultId 
    negotiateClientCertificate: false
    defaultSslBinding: true
    certificateSource: 'KeyVault'
  }
  {
    type: 'DeveloperPortal'
    hostName: developerPortalHostName
    keyVaultId: developerPortalCertKeyVaultId
    negotiateClientCertificate: false
    defaultSslBinding: false
    certificateSource: 'KeyVault'
  }
])


resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apiManagementName
  location: location
  sku: sku
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'sam.vanhoutte@samvh.com'
    publisherName: 'Sam Vanhoutte (${environmentAcronym})'
    notificationSenderEmail: 'apimgmt-noreply@samvh.com'
    hostnameConfigurations: hostNameConfigs
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'true'
    }
    virtualNetworkType: 'None'
    disableGateway: false
    apiVersionConstraint: {}
    publicNetworkAccess: 'Enabled'
  }
}

resource apiManagementDiagnostics 'Microsoft.ApiManagement/service/diagnostics@2021-08-01' = {
  parent: apiManagement
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    logClientIp: true
    loggerId: apiManagementLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        dataMasking: {
          queryParams: [
            {
              value: '*'
              mode: 'Hide'
            }
          ]
        }
      }
    }
    backend: {
      request: {
        dataMasking: {
          queryParams: [
            {
              value: '*'
              mode: 'Hide'
            }
          ]
        }
      }
    }
  }
}

resource apiManagementLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apiManagement
  name: applicationInsightsName
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: '{{appinsights-key}}'
    }
    isBuffered: true
    resourceId: applicationInsightsResourceId
  }
  dependsOn:[
    apiManagementNamedValueAppInsightsKey
  ]
}

resource apiManagementNamedValueAppInsightsKey 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagement
  name: 'appinsights-key'
  properties: {
    displayName: 'appinsights-key'
    value: applicationInsightsInstrumentationKey
    secret: false
  }
}

resource apiManagementDiagnosticsLoggers 'Microsoft.ApiManagement/service/diagnostics/loggers@2018-01-01' = {
  parent: apiManagementDiagnostics
  name: applicationInsightsName
}

output principalId string = apiManagement.identity.principalId
output tenantId string = apiManagement.identity.tenantId
output name string = apiManagement.name
