param name string
param location string

resource la_workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
}

resource app_insights 'microsoft.insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: la_workspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output name string = app_insights.name
output id string = app_insights.id
output instrumentation_key string = app_insights.properties.InstrumentationKey
output connection_string string = app_insights.properties.ConnectionString
