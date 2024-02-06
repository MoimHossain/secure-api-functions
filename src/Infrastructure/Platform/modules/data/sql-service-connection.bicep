
// Some how this didn't work (mostly because of incompatible Azure CLI version) - something to investigate later

param location string = resourceGroup().location
param sqlAdminUserAssignedIdentityName string
param sqlDatabaseId string
param appServiceId string
param clientUAMIName string

resource uamiSqlAdmin 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: sqlAdminUserAssignedIdentityName  
}

resource clientUAMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: clientUAMIName  
}

resource createServiceConnection 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createServiceConnection'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiSqlAdmin.id}': {}
    }
  }
  properties: {
    forceUpdateTag: '1'
    azCliVersion: '2.54.0'
    environmentVariables: [
      {
        name: 'FunctionAppResourceId'
        value: appServiceId
      }
      {
        name: 'SqlDatabaseResourceId'
        value: sqlDatabaseId
      }
      {
        name: 'UserAssignedMIClientId'
        value: clientUAMI.properties.clientId
      }
      {
        name: 'SubscriptionId'
        value: '7f2413b7-93b1-4560-a932-220c34c9db29'
      }
    ]
    scriptContent: loadTextContent('create-service-connection.sh')
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
