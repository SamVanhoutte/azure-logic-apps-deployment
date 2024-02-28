**`modules/logic-app.bicep`**

In this file, we are defining the resource that will be used to deploy our Logic App to.  The naming convention is important, where we keep place for the location (`weu` is West-Europe) and the environment (`dev`, `prd`...)

```yaml
param location string = resourceGroup().location
param environmentAcronym string
param locationAcronym string
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
```