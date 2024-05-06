param name string
param location string
param app_insights_name string

var sp_name = '${name}-sp'
var web_app_name = name

resource app_insights 'microsoft.insights/components@2020-02-02' existing = {
  name: app_insights_name
}

resource sp 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: sp_name
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource web_app 'Microsoft.Web/sites@2023-01-01' = {
  name: web_app_name
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: sp.id
    reserved: true
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'NODE|18-lts'
      use32BitWorkerProcess: true
      netFrameworkVersion: 'v4.0'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: app_insights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: app_insights.properties.ConnectionString
        }
      ]
      appCommandLine: 'pm2 serve /home/site/wwwroot --no-daemon'
    }
    httpsOnly: true
    publicNetworkAccess: 'Enabled'    
  }
}

output name string = web_app.name
output host_names array = web_app.properties.hostNames
