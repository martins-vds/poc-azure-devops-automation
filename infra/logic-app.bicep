param name string
param location string
param app_insights_id string
param app_insights_instrumentation_key string

var sp_name = '${name}-logic-sp'
var storage_name = '${name}logicstg'
var logic_app_name = '${name}-logic'

resource sp 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: sp_name
  location: location
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    size: 'WS1'
    family: 'WS'
    capacity: 1
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 20
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storage_name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource logic_app 'Microsoft.Web/sites@2023-01-01' = {
  name: logic_app_name
  location: location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    'hidden-link: /app-insights-resource-id': app_insights_id
    'hidden-link: /app-insights-instrumentation-key': app_insights_instrumentation_key
  }
  properties: {
    serverFarmId: sp.id
    siteConfig: {
      functionsRuntimeScaleMonitoringEnabled: false         
    }
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

output name string = logic_app.name
output principal_id string = logic_app.identity.principalId
