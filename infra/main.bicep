@minLength(4)
param poc_name string
param location string = resourceGroup().location
@secure()
param azure_devops_pat string = ''

var poc_name_sanitized = take(toLower(replace(replace(poc_name, '-', ''), ' ', '')), 10)

module telemetry 'telemetry.bicep' = {
  name: 'telemetry'
  params: {
    name: poc_name_sanitized
    location: location
  }
}

module logic_app 'logic-app.bicep' = {
  name: 'logic_app'
  params: {
    location: location
    name: poc_name_sanitized
    app_insights_name: telemetry.outputs.name
  }
}

module request_storage 'request-storage.bicep' = {
  name: 'request_storage'
  params: {
    location: location
    name: poc_name_sanitized
    logic_app_principal_id: logic_app.outputs.principal_id
  }
}

module web_app 'web-app.bicep' = {
  name: 'web_app'
  params: {
    location: location
    name: poc_name_sanitized
    app_insights_name: telemetry.outputs.name
  }
}

module function_app 'functions.bicep' = {
  name: 'api'
  params: {
    location: location
    name: poc_name_sanitized
    app_insights_name: telemetry.outputs.name
    azure_devops_pat: azure_devops_pat
    requests_storage_name: request_storage.outputs.name
    cors: web_app.outputs.host_names
  }
}

output function_app_name string = function_app.outputs.name
output function_app_url string = function_app.outputs.url
output logic_app_name string = logic_app.outputs.name
output web_app_name string = web_app.outputs.name
