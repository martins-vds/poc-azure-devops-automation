param poc_name string
param project_request_queue_name string
param location string = resourceGroup().location

var poc_name_sanitized = take(toLower(replace(replace(poc_name, '-', ''), ' ', '')), 10)
var app_insights_name = poc_name_sanitized
var function_app_name = '${poc_name_sanitized}-func'
var logic_app_name = '${poc_name_sanitized}-logic'
var logic_app_storage_name = '${poc_name_sanitized}logicstg'
var project_request_storage_name = '${poc_name_sanitized}funcstg'
var project_request_queue_connection_name = 'azurequeues'

resource app_insights 'microsoft.insights/components@2020-02-02' existing = {
  name: app_insights_name
}

resource function_app 'Microsoft.Web/sites@2023-01-01' existing = {
  name: function_app_name
}

resource logic_app 'Microsoft.Web/sites@2023-01-01' existing = {
  name: logic_app_name
}

resource project_request_storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: project_request_storage_name
}

resource logic_app_storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: logic_app_storage_name
}

resource project_request_queue_connection 'Microsoft.Web/connections@2016-06-01' = {
  name: project_request_queue_connection_name
  location: location
  kind: 'V2'
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
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {
        token: {}
      }
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

  resource accessPolices 'accessPolicies@2018-07-01-preview' = {
    name: logic_app_name
    location: location
    properties: {
      principal: {
        type: 'ActiveDirectory'
        identity: {
          objectId: logic_app.identity.principalId
          tenantId: subscription().tenantId
        }
      }
    }
  }
}

resource logic_app_settings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: logic_app
  name: 'appsettings'
  properties: {
    function_url: function_app.properties.defaultHostName
    function_key: listkeys('${function_app.id}/host/default', function_app.apiVersion).functionKeys.default
    azurequeues_queueName: project_request_queue_name
    azurequeues_connectionId: project_request_queue_connection.id
    azurequeues_apiId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${project_request_queue_connection_name}'
    azurequeues_connectionKey: project_request_storage.listKeys().keys[0].value  
    azurequeues_endpointUri: project_request_storage.properties.primaryEndpoints.queue
    APPINSIGHTS_INSTRUMENTATIONKEY: app_insights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: app_insights.properties.ConnectionString
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${logic_app_storage.name};AccountKey=${logic_app_storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    FUNCTIONS_EXTENSION_VERSION: '~4'
  }
}
