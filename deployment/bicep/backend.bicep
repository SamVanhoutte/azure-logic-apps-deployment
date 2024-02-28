targetScope = 'subscription'

param location string = deployment().location
@minLength(3)
@maxLength(3)
param locationAcronym string
@allowed(['dev', 'tst', 'prd'])
param environmentAcronym string

// resource groups are create by the foundation resource deployment template to ensure that all resource groups are available for further deployment steps
resource dataResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${locationAcronym}-${environmentAcronym}-logapp-rg-backend'
  location: location
}
