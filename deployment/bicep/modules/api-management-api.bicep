param environmentAcronym string
param locationAcronym string
param apiManagementName string
param serviceUrl string
param apiSpec string
param format string
param displayName string
param description string
param apiRevision string = '1'
param subscriptionRequired bool = true
param path string
param name string
param policy string
param policyFormat string = 'rawxml'
param namedValues array

var apiName = '${locationAcronym}-${environmentAcronym}-api-${name}'

resource apiManagement 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apiManagementName
}

resource apiManagementApi 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apiManagement
  name: apiName
  properties: {
    displayName: displayName
    description: description
    apiRevision: apiRevision
    subscriptionRequired: subscriptionRequired
    serviceUrl: serviceUrl
    path: path
    format: format
    value: apiSpec
    protocols: [
      'https'
    ]
    subscriptionKeyParameterNames: {
      header: 'x-subscription-key'
      query: 'x-subscription-key'
    }
    isCurrent: true
  }
  dependsOn: apiManagementNamedValues
}

resource apiManagementapiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-12-01-preview' = {
  parent: apiManagementApi
  name: 'policy'
  properties: {
    value: policy
    format: policyFormat
  }
}

resource apiManagementNamedValues 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = [for namedValue in namedValues: {
  parent: apiManagement
  name: '${namedValue.name}'
  properties: {
    displayName: namedValue.displayName
    value: namedValue.value
    secret: namedValue.isSecret
  }
}]

output apiName string = apiManagementApi.name
output basePath string = path
