
param name string
param serverFarmId string
param functionUAMIName string
param location string = resourceGroup().location

resource functionUAMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: functionUAMIName
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${functionUAMI.id}': {} }
  }   
  properties: {
    enabled: true   
    serverFarmId: serverFarmId
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: true
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
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'    
    storageAccountRequired: false    
  }
}

output functionAppId string = functionApp.id

