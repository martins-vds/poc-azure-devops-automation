@minLength(4)
param poc_name string
param project_request_queue_name string = 'new-requests-queue'
param project_request_table_name string = 'AzureDevOpsProjectRequests'
param repositoryUrl string

param location string = resourceGroup().location

@secure()
param azure_devops_pat string = ''

var poc_name_sanitized = take(toLower(replace(replace(poc_name, '-', ''), ' ', '')), 10)
var function_app_storage_name = '${poc_name_sanitized}funcstg'
var logic_app_storage_name = '${poc_name_sanitized}logicstg'

resource la_workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: poc_name
  location: location
}

resource app_insights 'microsoft.insights/components@2020-02-02' = {
  name: poc_name
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

resource function_app_storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: function_app_storage_name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    defaultToOAuthAuthentication: true
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
      resourceAccessRules: [
        {
          resourceId: logic_app.id
          tenantId: tenant().tenantId
        }
      ]
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
  }
}

resource storage_queue_data_contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}

resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: function_app_storage
  name: guid(storage_queue_data_contributor.id)
  properties: {
    roleDefinitionId: storage_queue_data_contributor.id
    principalId: logic_app.identity.principalId
  }
}

resource function_app_sp 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${poc_name}-func-sp'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource swa 'Microsoft.Web/staticSites@2023-01-01' = {
  name: poc_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    repositoryUrl: repositoryUrl
    branch: 'main'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'GitHub'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

resource function_app 'Microsoft.Web/sites@2023-01-01' = {
  name: '${poc_name}-func'
  location: location
  kind: 'functionapp'
  properties: {
    enabled: true
    serverFarmId: function_app_sp.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'AZURE_DEVOPS_PAT'
          value: azure_devops_pat
        }
        {
          name: 'TableConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${function_app_storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${function_app_storage.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: app_insights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: app_insights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${function_app_storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${function_app_storage.listKeys().keys[0].value}'
        }
        {
          name: 'AzureWebJobsFeatureFlags'
          value: 'EnableWorkerIndexing'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource project_request_queue_services 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: function_app_storage
  name: 'default'
}

resource project_request_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  parent: project_request_queue_services
  name: project_request_queue_name
}

resource project_request_table_services 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: function_app_storage
  name: 'default'
}

resource project_requests_table 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: project_request_table_services
  name: project_request_table_name
}

resource swa_backend 'Microsoft.Web/staticSites/linkedBackends@2023-01-01' = {
  parent: swa
  name: 'backend'
  properties: {
    backendResourceId: function_app.id
    region: location
  }
}

resource swa_func_app_backend 'Microsoft.Web/staticSites/userProvidedFunctionApps@2023-01-01' = {
  parent: swa
  name: 'backend'
  properties: {
    functionAppResourceId: function_app.id
    functionAppRegion: location
  }
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

output function_app_name string = function_app.name
output swa_name string = swa.name
output logic_app_name string = logic_app.name
