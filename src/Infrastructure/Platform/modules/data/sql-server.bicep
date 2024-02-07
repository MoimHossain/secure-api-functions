

param location string = resourceGroup().location
param serverName string
param azureADOnlyAuthentication bool = false
param sqlAdminUserAssignedIdentityName string 

param minimalTlsVersion string = '1.2'
param publicNetworkAccess string = 'Enabled'

param primaryUserAssignedIdentityId string = ''
param federatedClientId string = ''
param allowAzureIps bool = true

param allowClientIp bool = false
param clientIpValue string = ''


param identity object = {
  type: 'SystemAssigned'
}

var sqlAdminLoginName = 'sqladmin'
var sqlAdminCode = guid(serverName)

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: sqlAdminUserAssignedIdentityName  
}


resource server 'Microsoft.Sql/servers@2022-05-01-preview' = {
  location: location  
  name: serverName
  properties: {
    version: '12.0'
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
    
    // administratorLoginPassword: required for server creation - just set to dummy value, will be disabled by deploying '/azureADOnlyAuthentications' later.
    // NOTE: The following only require for the initial server creation. If you are updating an existing server, you can ignore these properties.
    administratorLogin: sqlAdminLoginName
    administratorLoginPassword: sqlAdminCode

    // administrators: The Azure Active Directory administrator of the server. This can only be used at server create time. If used for server update, it will be ignored or it will result in an error. For updates individual APIs will need to be used. 
    administrators: {}
    primaryUserAssignedIdentityId: primaryUserAssignedIdentityId
    federatedClientId: federatedClientId    
  }
  identity: identity
}


// https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/administrators?pivots=deployment-language-bicep
resource sqlAdminsResource 'Microsoft.Sql/servers/administrators@2022-05-01-preview' = {
  parent: server
  name: 'ActiveDirectory'
  properties: {
        administratorType: 'ActiveDirectory'
        login: uami.name
        sid: uami.properties.principalId
        tenantId: uami.properties.tenantId
    }
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/azureadonlyauthentications?pivots=deployment-language-bicep
resource sqlAzureAdOnly 'Microsoft.Sql/servers/azureADOnlyAuthentications@2022-05-01-preview' = if (azureADOnlyAuthentication){
  name: 'Default'
  parent: server
  properties: {
    azureADOnlyAuthentication: true
  }
  dependsOn:[sqlAdminsResource]
}

resource serverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallrules@2021-11-01' = if (allowAzureIps) {  
  name: 'AllowAllWindowsAzureIps'
  parent: server
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}


resource serverName_clientIpRule 'Microsoft.Sql/servers/firewallrules@2021-11-01' = if (allowClientIp) {
  parent: server
  name: 'clientIpRuleName'
  properties: {
    endIpAddress: clientIpValue
    startIpAddress: clientIpValue
  }
}

output sqlServerName string = server.name
output sqlServerResourceId string = server.id
output sqlAdmninUserLogin string = sqlAdminLoginName
output sqlAdminPassKey string = sqlAdminCode

