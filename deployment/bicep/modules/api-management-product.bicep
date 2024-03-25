param name string
param apimName string
param displayName string
param description string
param subscriptionRequired bool = true
param apiNames array


resource product 'Microsoft.ApiManagement/service/products@2021-01-01-preview' = {
  name: '${apimName}/${name}'
  properties: {
    displayName: displayName
    description: description
    subscriptionRequired: subscriptionRequired
    state: 'published'
  }
  resource api 'apis@2021-01-01-preview' = [for apiName in apiNames: {
    name: apiName
  }]
}
