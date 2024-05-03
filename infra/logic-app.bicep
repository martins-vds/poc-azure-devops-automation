param poc_name string
param location string = resourceGroup().location

var poc_name_sanitized = take(toLower(replace(replace(poc_name, '-', ''), ' ', '')), 10)
var logic_app_storage_name = '${poc_name_sanitized}logicstg'
var function_app_storage_name = '${poc_name_sanitized}funcstg'
var project_request_queue_connection_name = 'azurequeues'

resource function_app 'Microsoft.Web/sites@2023-01-01' existing = {
  name: '${poc_name}-func'
}

resource logic_app_sp 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${poc_name}-logic-sp'
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

resource logic_app_storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: logic_app_storage_name
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
  name: '${poc_name}-logic'
  location: location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: logic_app_sp.id
    siteConfig: {
      functionsRuntimeScaleMonitoringEnabled: false
    }          
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource project_request_queue 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
    name: function_app_storage_name
}

resource project_request_queue_connection 'Microsoft.Web/connections@2016-06-01' = {
  name: project_request_queue_connection_name
  location: location
  properties: {
    displayName: project_request_queue_connection_name
    api: {
      name: project_request_queue_connection_name
      displayName: 'Azure Queues'
      description: 'Azure Queue storage provides cloud messaging between application components. Queue storage also supports managing asynchronous tasks and building process work flows.'
      brandColor: '#0072C6'
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azurequeues')
      type: 'Microsoft.Web/locations/managedApis'      
    }
    nonSecretParameterValues: {
      storageaccount: project_request_queue.properties.primaryEndpoints.queue
    }
    testLinks: [
      {
        requestUri: uri(
          environment().resourceManager,
          '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${project_request_queue_connection_name}/extensions/proxy/testConnection?api-version=2016-06-01'
        )
        method: 'get'
      }
    ]
  }
}

resource logic_app_settings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: logic_app
  name: 'appsettings'
  properties: {
    function_url: function_app.properties.defaultHostName
    function_key: listkeys('${function_app.id}/host/default', function_app.apiVersion).functionKeys.default
    'azurequeues-connectionId': project_request_queue_connection.id
    'azurequeues-apiConnection': '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${project_request_queue_connection_name}'
  }
}

output la_name string = logic_app.name
