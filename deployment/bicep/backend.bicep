targetScope = 'subscription'

param location string = deployment().location
@minLength(3)
@maxLength(3)
param locationAcronym string
@allowed(['dev', 'tst', 'prd'])
param environmentAcronym string
var companyName = 'savanh'

// resource groups are create by the foundation resource deployment template to ensure that all resource groups are available for further deployment steps
resource backendResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: '${locationAcronym}-${environmentAcronym}-rg-backend'
}
