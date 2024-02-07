targetScope = 'resourceGroup'

param location string = resourceGroup().location

param apimServiceName string
param publisherEmail string
param publisherName string
@allowed([
  'Premium'
  'Standard'
  'Developer'
  'Basic'
  'Consumption'])
param sku string 
param skuCount int
param publicIpAddressName string
param publicIpDnsLabel string
param sqlAdminUAMIName string
param functionIdentityName string
param sqlServerName string
param sqlDatabaseName string
param serverFarmName string
param functionAppName string
param vnetName string


var sqlPrivateEndpointName = '${sqlServerName}-private-endpoint'
//var funcPrivateEndpointName = '${functionAppName}-private-endpoint'

// var allowClientIp = true
// var clientIpValue = '84.87.237.145'

var database = 'database'
var host = 'windows.net'
var sqlZoneName = 'privatelink.${database}.${host}'
var sqlZoneGroupName = 'privatelink-database-windows-net'

// var funcZoneName = 'privatelink.azurewebsites.net'
// var funcZoneGroupName = 'privatelink-azurewebsites-net'

module sqlAdminUAMI 'modules/shared/identity.bicep' = {
  name: sqlAdminUAMIName
  params: {
    uamiName: sqlAdminUAMIName
    location: location
  }
}
module functionIdentity 'modules/shared/identity.bicep' = {
  name: functionIdentityName
  params: {
    uamiName: functionIdentityName
    location: location
  }
}
module virtualNetwork 'modules/network/virtual-network.bicep' = {
  name: vnetName
  params: {
    vnetName: vnetName
    location: location    
  }
}

module sqlServer 'modules/data/sql-server.bicep' = {
  name: sqlServerName
  params: {
    serverName: sqlServerName
    location: location
    
    sqlAdminUserAssignedIdentityName: sqlAdminUAMI.name
    azureADOnlyAuthentication: false
    publicNetworkAccess: 'Disabled'

    // For local testing    
    // allowClientIp: allowClientIp
    // clientIpValue: clientIpValue
    // allowAzureIps: true
  }
  dependsOn: [
    sqlAdminUAMI  
  ]
}

module sqlDatabase 'modules/data/sql-database.bicep' = {
  name: sqlDatabaseName
  params: {
    databaseName: sqlDatabaseName
    location: location
    serverName: sqlServer.outputs.sqlServerName
  }
}



module sqlPrivateEndpoint 'modules/network/private-endpoints/private-endpoint.bicep' = {
  name: sqlPrivateEndpointName
  params: {
    location: location
    vnetId: virtualNetwork.outputs.vnetId
    createPrivateDns: true
    zoneFqdn: sqlZoneName
    zoneGroupName: sqlZoneGroupName
    privateEndpointName: sqlPrivateEndpointName
    privateLinkServiceId: sqlServer.outputs.sqlServerResourceId
    subnetId: virtualNetwork.outputs.dataSubnetId
    targetSubResource: 'sqlServer' 
  }
}

module serverFarm 'modules/web/server-farm.bicep' = {
  name: serverFarmName
  params: {
    location: location
    name: serverFarmName
  }
}

module functionApp 'modules/web/function-app.bicep' = {
  name: functionAppName
  params: {
    location: location
    name: functionAppName
    delegatedSubnetResourceId: virtualNetwork.outputs.backendSubnetId
    functionUAMIName: functionIdentity.name
    serverFarmId: serverFarm.outputs.serverfarmId    
  }
}

// module functionPrivateEndpoint 'modules/network/private-endpoints/private-endpoint.bicep' = {
//   name: funcPrivateEndpointName
//   params: {
//     location: location
//     vnetId: virtualNetwork.outputs.vnetId
//     createPrivateDns: true
//     zoneFqdn: funcZoneName
//     zoneGroupName: funcZoneGroupName
//     privateEndpointName: funcPrivateEndpointName
//     privateLinkServiceId: functionApp.outputs.functionAppId
//     subnetId: virtualNetwork.outputs.backendSubnetId
//     targetSubResource: 'sites' 
//   }
// }

module apimService 'modules/api-management/apim.bicep' = {
  name: apimServiceName
  params: {
    apimServiceName: apimServiceName
    location: location
    sku: sku
    skuCount: skuCount
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicIpAddressName: publicIpAddressName
    publicIpDnsLabel: publicIpDnsLabel
    subnetName: virtualNetwork.outputs.apimSubnetName
    virtualNetworkName: virtualNetwork.name
  }
}

