param connections_azurequeues_name string = 'azurequeues'
param serverfarms_WestUS2Plan_name string = 'WestUS2Plan'
param sites_poc_azure_devops_automation_name string = 'poc-azure-devops-automation'
param sites_poc_azure_devops_automation_logic_name string = 'poc-azure-devops-automation-logic'
param staticSites_poc_azure_devops_automation_name string = 'poc-azure-devops-automation'
param storageAccounts_azuredevopsautomation_name string = 'azuredevopsautomation'
param components_poc_azure_devops_automation_name string = 'poc-azure-devops-automation'
param storageAccounts_pocazuredevopsautomation_name string = 'pocazuredevopsautomation'
param serverfarms_poc_azure_devops_automation_logic_name string = 'poc-azure-devops-automation-logic'
param smartdetectoralertrules_failure_anomalies_poc_azure_devops_automation_name string = 'failure anomalies - poc-azure-devops-automation'
param actiongroups_application_insights_smart_detection_externalid string = '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/rg-work-sync/providers/microsoft.insights/actiongroups/application insights smart detection'
param workspaces_DefaultWorkspace_83e40e54_5652_45ac_b526_202136f6cfd1_WUS2_externalid string = '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-83e40e54-5652-45ac-b526-202136f6cfd1-WUS2'
param location string = resourceGroup().location

resource components_poc_azure_devops_automation_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_poc_azure_devops_automation_name
  location: 'westus2'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_DefaultWorkspace_83e40e54_5652_45ac_b526_202136f6cfd1_WUS2_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource storageAccounts_azuredevopsautomation_name_resource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccounts_azuredevopsautomation_name
  location: 'westus3'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
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

resource storageAccounts_pocazuredevopsautomation_name_resource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccounts_pocazuredevopsautomation_name
  location: 'westus2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
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

resource connections_azurequeues_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_azurequeues_name
  location: 'westus3'
  kind: 'V2'
  properties: {
    displayName: 'azurequeue'
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    createdTime: '2024-02-06T19:45:27.7224306Z'
    changedTime: '2024-02-06T19:45:27.7224306Z'
    api: {
      name: connections_azurequeues_name
      displayName: 'Azure Queues'
      description: 'Azure Queue storage provides cloud messaging between application components. Queue storage also supports managing asynchronous tasks and building process work flows.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1666/1.0.1666.3495/${connections_azurequeues_name}/icon.png'
      brandColor: '#0072C6'
      id: '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/providers/Microsoft.Web/locations/westus3/managedApis/${connections_azurequeues_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        requestUri: 'https://management.azure.com:443/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/rg-poc-azure-devops-automation/providers/Microsoft.Web/connections/${connections_azurequeues_name}/extensions/proxy/testConnection?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

resource serverfarms_poc_azure_devops_automation_logic_name_resource 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverfarms_poc_azure_devops_automation_logic_name
  location: 'West US 3'
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

resource serverfarms_WestUS2Plan_name_resource 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverfarms_WestUS2Plan_name
  location: 'West US 2'
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

resource staticSites_poc_azure_devops_automation_name_resource 'Microsoft.Web/staticSites@2023-01-01' = {
  name: staticSites_poc_azure_devops_automation_name
  location: 'West US 2'
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    repositoryUrl: 'https://github.com/martins-vds/${staticSites_poc_azure_devops_automation_name}'
    branch: 'main'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'GitHub'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

resource smartdetectoralertrules_failure_anomalies_poc_azure_devops_automation_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: smartdetectoralertrules_failure_anomalies_poc_azure_devops_automation_name
  location: 'global'
  properties: {
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    state: 'Enabled'
    severity: 'Sev3'
    frequency: 'PT1M'
    detector: {
      id: 'FailureAnomaliesDetector'
    }
    scope: [
      components_poc_azure_devops_automation_name_resource.id
    ]
    actionGroups: {
      groupIds: [
        actiongroups_application_insights_smart_detection_externalid
      ]
    }
  }
}

resource components_poc_azure_devops_automation_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'degradationindependencyduration'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'degradationinserverresponsetime'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'digestMailConfiguration'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'extension_canaryextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'extension_memoryleakextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'extension_securityextensionspackage'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'extension_traceseveritydetector'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'longdependencyduration'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'slowpageloadtime'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_poc_azure_devops_automation_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_poc_azure_devops_automation_name_resource
  name: 'slowserverresponsetime'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource storageAccounts_azuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccounts_azuredevopsautomation_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource storageAccounts_pocazuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccounts_pocazuredevopsautomation_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_azuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccounts_azuredevopsautomation_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_pocazuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccounts_pocazuredevopsautomation_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_azuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: storageAccounts_azuredevopsautomation_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_pocazuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: storageAccounts_pocazuredevopsautomation_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: storageAccounts_azuredevopsautomation_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_pocazuredevopsautomation_name_default 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: storageAccounts_pocazuredevopsautomation_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_poc_azure_devops_automation_name_resource 'Microsoft.Web/sites@2023-01-01' = {
  name: sites_poc_azure_devops_automation_name
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/rg-poc-azure-devops-automation/providers/microsoft.insights/components/poc-azure-devops-automation'
    'hidden-link: /app-insights-instrumentation-key': '01cfc36e-2947-41c3-9190-147e336c5342'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=01cfc36e-2947-41c3-9190-147e336c5342;IngestionEndpoint=https://westus2-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westus2.livediagnostics.monitor.azure.com/'
  }
  kind: 'functionapp'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_poc_azure_devops_automation_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_poc_azure_devops_automation_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_WestUS2Plan_name_resource.id
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
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '91E1C70EAA0F1CFD2A0EB75005C154EEF913BB43261BC575B8BD9BBF6AAC7346'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_poc_azure_devops_automation_logic_name_resource 'Microsoft.Web/sites@2023-01-01' = {
  name: sites_poc_azure_devops_automation_logic_name
  location: 'West US 3'
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_poc_azure_devops_automation_logic_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_poc_azure_devops_automation_logic_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_poc_azure_devops_automation_logic_name_resource.id
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
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '91E1C70EAA0F1CFD2A0EB75005C154EEF913BB43261BC575B8BD9BBF6AAC7346'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_poc_azure_devops_automation_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'ftp'
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/rg-poc-azure-devops-automation/providers/microsoft.insights/components/poc-azure-devops-automation'
    'hidden-link: /app-insights-instrumentation-key': '01cfc36e-2947-41c3-9190-147e336c5342'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=01cfc36e-2947-41c3-9190-147e336c5342;IngestionEndpoint=https://westus2-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westus2.livediagnostics.monitor.azure.com/'
  }
  properties: {
    allow: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'ftp'
  location: 'West US 3'
  properties: {
    allow: false
  }
}

resource sites_poc_azure_devops_automation_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'scm'
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/rg-poc-azure-devops-automation/providers/microsoft.insights/components/poc-azure-devops-automation'
    'hidden-link: /app-insights-instrumentation-key': '01cfc36e-2947-41c3-9190-147e336c5342'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=01cfc36e-2947-41c3-9190-147e336c5342;IngestionEndpoint=https://westus2-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westus2.livediagnostics.monitor.azure.com/'
  }
  properties: {
    allow: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'scm'
  location: 'West US 3'
  properties: {
    allow: false
  }
}

resource sites_poc_azure_devops_automation_name_web 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'web'
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/83e40e54-5652-45ac-b526-202136f6cfd1/resourceGroups/rg-poc-azure-devops-automation/providers/microsoft.insights/components/poc-azure-devops-automation'
    'hidden-link: /app-insights-instrumentation-key': '01cfc36e-2947-41c3-9190-147e336c5342'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=01cfc36e-2947-41c3-9190-147e336c5342;IngestionEndpoint=https://westus2-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westus2.livediagnostics.monitor.azure.com/'
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: true
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 100
    detailedErrorLoggingEnabled: false
    publishingUsername: '$poc-azure-devops-automation'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource sites_poc_azure_devops_automation_logic_name_web 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'web'
  location: 'West US 3'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$poc-azure-devops-automation-logic'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    managedServiceIdentityId: 12496
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 1
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: true
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

resource sites_poc_azure_devops_automation_name_009e6e976082441697402a737e71356e 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '009e6e976082441697402a737e71356e'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"d52ecbeb1f3d28c82c5d4dd430ab385ffcc3c348","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T21:30:10.5139367Z'
    end_time: '2024-02-06T21:30:12.1019728Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_11b0e42179b445e18d95de0a127935a9 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '11b0e42179b445e18d95de0a127935a9'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:18:16.2592886Z'
    end_time: '2024-02-06T20:18:20.384443Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_34bd521fd86847779152e5c4642df2ae 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '34bd521fd86847779152e5c4642df2ae'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"d52ecbeb1f3d28c82c5d4dd430ab385ffcc3c348","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T21:32:28.1588511Z'
    end_time: '2024-02-06T21:32:29.3932226Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_3c84ae0f5b5d4b3da7d1bbb2a06e6315 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '3c84ae0f5b5d4b3da7d1bbb2a06e6315'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:20:42.2002598Z'
    end_time: '2024-02-06T20:20:50.5596273Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_55fe16b58f9041bbabfab98f279d20b5 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '55fe16b58f9041bbabfab98f279d20b5'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T23:40:54.1569531Z'
    end_time: '2024-02-06T23:40:55.9054516Z'
    active: true
  }
}

resource sites_poc_azure_devops_automation_logic_name_5687a1e03edb4c708d4ffeedfe674ca5 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '5687a1e03edb4c708d4ffeedfe674ca5'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"1727e4a3f30d33f64718f39ad794c356d66027c7","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T20:08:24.1614793Z'
    end_time: '2024-02-06T20:08:25.6302278Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_56c370cedb0d4425ab1fec798e39eaa0 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '56c370cedb0d4425ab1fec798e39eaa0'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:18:30.145264Z'
    end_time: '2024-02-06T20:18:34.0897609Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_59d353e754b74fe6824d8853f4bb8f48 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '59d353e754b74fe6824d8853f4bb8f48'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T22:59:32.7245016Z'
    end_time: '2024-02-06T22:59:34.521379Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_7086f9cf9b08429fa5abae58ac75895e 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '7086f9cf9b08429fa5abae58ac75895e'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:06:21.5991652Z'
    end_time: '2024-02-06T20:06:24.8118606Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_796f38c8d65a4765bed66d679b8cb1eb 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '796f38c8d65a4765bed66d679b8cb1eb'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"0b59352602f5b0f5f58c789a3df2f80e1f0ada97","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T23:40:28.6592311Z'
    end_time: '2024-02-06T23:40:29.97173Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_7b5d36ec759f40549ed1fb9f9a44fb70 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '7b5d36ec759f40549ed1fb9f9a44fb70'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"0b59352602f5b0f5f58c789a3df2f80e1f0ada97","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T23:38:39.8407571Z'
    end_time: '2024-02-06T23:38:41.1376372Z'
    active: true
  }
}

resource sites_poc_azure_devops_automation_name_9b218278e1b14e638e6c4ff3ef7f3c42 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '9b218278e1b14e638e6c4ff3ef7f3c42'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:18:03.6775112Z'
    end_time: '2024-02-06T20:18:07.1243222Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_9efa56401b7248be9d5f798aa97423cc 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '9efa56401b7248be9d5f798aa97423cc'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"af8677035cc0690495624d1333dbfff0af00fbd5","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T22:57:04.6597015Z'
    end_time: '2024-02-06T22:57:06.2066017Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_b14548134e9b4dc88aed94403c34401e 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'b14548134e9b4dc88aed94403c34401e'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"af8677035cc0690495624d1333dbfff0af00fbd5","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T22:59:04.0797815Z'
    end_time: '2024-02-06T22:59:05.3611699Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_b41a9f44094643b7813884faaa547f07 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'b41a9f44094643b7813884faaa547f07'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:18:42.9350228Z'
    end_time: '2024-02-06T20:18:46.7291511Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_d43baade1e9a40309923c40687f1ea79 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'd43baade1e9a40309923c40687f1ea79'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'az_cli_functions'
    message: 'Created via a push deployment'
    start_time: '2024-02-06T20:17:45.6099864Z'
    end_time: '2024-02-06T20:17:49.8620822Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_ebef08c12a02437db029027860a4d422 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'ebef08c12a02437db029027860a4d422'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T21:32:56.5315845Z'
    end_time: '2024-02-06T21:32:58.3479688Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_ece7ad2c57af4bb783f906e28e5e5e91 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'ece7ad2c57af4bb783f906e28e5e5e91'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:08:57.6808577Z'
    end_time: '2024-02-06T20:08:59.4464649Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_logic_name_f8b3d6bf9441474ba34167622f33a9b4 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: 'f8b3d6bf9441474ba34167622f33a9b4'
  location: 'West US 3'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY_FUNCTIONS_V1'
    message: '{"type":"deployment","sha":"fc170bca7c1ecce4b50e0ea9cc40ad3389e35748","repoName":"martins-vds/poc-azure-devops-automation","actor":"martins-vds","slotName":"production"}'
    start_time: '2024-02-06T20:20:16.6840007Z'
    end_time: '2024-02-06T20:20:17.9969986Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_fe8dbc07548742c59d8eb850227f1a15 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'fe8dbc07548742c59d8eb850227f1a15'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'OneDeploy'
    message: 'OneDeploy'
    start_time: '2024-02-06T20:06:07.7504736Z'
    end_time: '2024-02-06T20:06:10.7470603Z'
    active: false
  }
}

resource sites_poc_azure_devops_automation_name_newProject 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'newProject'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/newProject.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/newProject'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/organizations/{organization}/projects'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_organizations 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'organizations'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/organizations.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/organizations'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/organizations'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_processes 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'processes'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/processes.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/processes'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/organizations/{organization}/processes'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_projectRequests 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'projectRequests'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/projectRequests.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/projectRequests'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/project-requests'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_removePermissions 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'removePermissions'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/removePermissions.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/removePermissions'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/organizations/{organization}/projects/{project}/permissions'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_requestProject 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'requestProject'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/requestProject.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/requestProject'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/project-requests'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_updateRequestProject 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: 'updateRequestProject'
  location: 'West US 2'
  properties: {
    script_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/site/wwwroot/devops.js'
    test_data_href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/vfs/data/Functions/sampledata/updateRequestProject.dat'
    href: 'https://poc-azure-devops-automation.azurewebsites.net/admin/functions/updateRequestProject'
    config: {}
    invoke_url_template: 'https://poc-azure-devops-automation.azurewebsites.net/api/project-requests/{requestid}'
    language: 'node'
    isDisabled: false
  }
}

resource sites_poc_azure_devops_automation_name_sites_poc_azure_devops_automation_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_name_resource
  name: '${sites_poc_azure_devops_automation_name}.azurewebsites.net'
  location: 'West US 2'
  properties: {
    siteName: 'poc-azure-devops-automation'
    hostNameType: 'Verified'
  }
}

resource sites_poc_azure_devops_automation_logic_name_sites_poc_azure_devops_automation_logic_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  parent: sites_poc_azure_devops_automation_logic_name_resource
  name: '${sites_poc_azure_devops_automation_logic_name}.azurewebsites.net'
  location: 'West US 3'
  properties: {
    siteName: 'poc-azure-devops-automation-logic'
    hostNameType: 'Verified'
  }
}

resource storageAccounts_azuredevopsautomation_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccounts_azuredevopsautomation_name_default
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_pocazuredevopsautomation_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccounts_pocazuredevopsautomation_name_default
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [

    storageAccounts_pocazuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccounts_azuredevopsautomation_name_default
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_pocazuredevopsautomation_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccounts_pocazuredevopsautomation_name_default
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [

    storageAccounts_pocazuredevopsautomation_name_resource
  ]
}

resource storageAccounts_pocazuredevopsautomation_name_default_poc_azure_devops_automation40a575b64f0c 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccounts_pocazuredevopsautomation_name_default
  name: 'poc-azure-devops-automation40a575b64f0c'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
  dependsOn: [

    storageAccounts_pocazuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_poc_azure_devops_automation_logic8d3f55 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccounts_azuredevopsautomation_name_default
  name: 'poc-azure-devops-automation-logic8d3f55'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fjobtriggers00 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fjobtriggers00'
  properties: {
    metadata: {}
  }
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_pocazuredevopsautomation_name_default_new_requests_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_pocazuredevopsautomation_name_default
  name: 'new-requests-queue'
  properties: {
    metadata: {}
  }
  dependsOn: [

    storageAccounts_pocazuredevopsautomation_name_resource
  ]
}

resource storageAccounts_pocazuredevopsautomation_name_default_AzureDevOpsProjectRequests 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_pocazuredevopsautomation_name_default
  name: 'AzureDevOpsProjectRequests'
  properties: {}
  dependsOn: [

    storageAccounts_pocazuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_AzureFunctionsDiagnosticEvents202402 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'AzureFunctionsDiagnosticEvents202402'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_pocazuredevopsautomation_name_default_AzureFunctionsDiagnosticEvents202402 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_pocazuredevopsautomation_name_default
  name: 'AzureFunctionsDiagnosticEvents202402'
  properties: {}
  dependsOn: [

    storageAccounts_pocazuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869f30759062919069d20240206t000000zactions 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869f30759062919069d20240206t000000zactions'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869f30759062919069dflows 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869f30759062919069dflows'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869f30759062919069dhistories 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869f30759062919069dhistories'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869f30759062919069druns 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869f30759062919069druns'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fflowaccesskeys 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fflowaccesskeys'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fflowruntimecontext 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fflowruntimecontext'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fflows 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fflows'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fflowsubscriptions 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fflowsubscriptions'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fflowsubscriptionsummary 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fflowsubscriptionsummary'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource storageAccounts_azuredevopsautomation_name_default_flow81bd0183cd1869fjobdefinitions 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_azuredevopsautomation_name_default
  name: 'flow81bd0183cd1869fjobdefinitions'
  properties: {}
  dependsOn: [

    storageAccounts_azuredevopsautomation_name_resource
  ]
}

resource staticSites_poc_azure_devops_automation_name_backend1 'Microsoft.Web/staticSites/linkedBackends@2023-01-01' = {
  parent: staticSites_poc_azure_devops_automation_name_resource
  name: 'backend1'
  location: 'West US 2'
  properties: {
    backendResourceId: sites_poc_azure_devops_automation_name_resource.id
    region: 'westus2'
  }
}

resource Microsoft_Web_staticSites_userProvidedFunctionApps_staticSites_poc_azure_devops_automation_name_backend1 'Microsoft.Web/staticSites/userProvidedFunctionApps@2023-01-01' = {
  parent: staticSites_poc_azure_devops_automation_name_resource
  name: 'backend1'
  location: 'West US 2'
  properties: {
    functionAppResourceId: sites_poc_azure_devops_automation_name_resource.id
    functionAppRegion: 'westus2'
  }
}
