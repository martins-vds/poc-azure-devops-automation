param name string
param location string
@secure()
param logic_app_principal_id string

var project_request_queue_name = 'new-requests-queue'
var project_request_table_name = 'AzureDevOpsProjectRequests'

var storage_name = '${name}requeststg'

resource storage_queue_data_contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
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

resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage_queue_data_contributor.id)
  properties: {
    roleDefinitionId: storage_queue_data_contributor.id
    principalId: logic_app_principal_id
  }
}

resource project_request_queue_services 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

resource project_request_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  parent: project_request_queue_services
  name: project_request_queue_name
}

resource project_request_table_services 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

resource project_requests_table 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: project_request_table_services
  name: project_request_table_name
}

output name string = storage.name
