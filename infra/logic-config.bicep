param poc_name string
param location string = resourceGroup().location

var poc_name_sanitized = take(toLower(replace(replace(poc_name, '-', ''), ' ', '')), 10)
var logic_app_storage_name = '${poc_name_sanitized}logicstg'
var project_request_storage_name = '${poc_name_sanitized}funcstg'
var project_request_queue_connection_name = 'azurequeues'

resource function_app 'Microsoft.Web/sites@2023-01-01' existing = {
  name: '${poc_name}-func'
}

resource logic_app 'Microsoft.Web/sites@2023-01-01' existing = {
  name: '${poc_name}-logic'  
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
    parameterValues: {
      storageaccount: project_request_storage.properties.primaryEndpoints.queue
      sharedkey: project_request_storage.listKeys().keys[0].value
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
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${logic_app_storage.name};AccountKey=${logic_app_storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    FUNCTIONS_EXTENSION_VERSION: '~4'
  }
}
