param location string = resourceGroup().location
@minLength(3)
@maxLength(3)
param environmentAcronym string
@minLength(3)
@maxLength(3)
param locationAcronym string
@minLength(3)
@maxLength(6)
param name string
param workflowParameters object 
param workflowDefinition object 

var logicAppName = '${locationAcronym}-${environmentAcronym}-la-${name}'

resource LogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: workflowDefinition
    parameters: workflowParameters
  }
}
output LogicAppMSI string = LogicApp.identity.principalId
