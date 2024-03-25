param location string = resourceGroup().location
param workspaceResourceId string
param applicationInsightsName string
param dailyCapInGB string = '1'


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: {}
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: workspaceResourceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsightsPricingPlan 'microsoft.insights/components/pricingPlans@2017-10-01' = {
  name: 'current'
  parent: applicationInsights
  properties: {
    cap: json(dailyCapInGB)
    planType: 'Basic'
    stopSendNotificationWhenHitCap: false
    stopSendNotificationWhenHitThreshold: false
    warningThreshold: 1
  }
}

output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output connectionString string = applicationInsights.properties.ConnectionString
output resourceId string = applicationInsights.id
output name string = applicationInsights.name
