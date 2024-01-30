targetScope = 'resourceGroup'

param location string = resourceGroup().location
param serverFarmName string 
param vnetName string
param functionAppName string


var dnsZoneName = 'privatelink.azurewebsites.net'
var endpointName = '${functionAppName}-private-endpoint'

module virtualNetwork 'modules/network/virtual-network.bicep' = {
  name: vnetName
  params: {
    vnetName: vnetName
    location: location    
  }
}

module dnsZone 'modules/network/DnsZone/dns-zone.bicep' = {
  name: dnsZoneName
  params: {
    name: dnsZoneName
    vnetName: vnetName
    vnetId: virtualNetwork.outputs.vnetId
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
    serverFarmId: serverFarm.outputs.serverfarmId    
  }
}


module privateEndpoint 'modules/network/private-endpoints/endpoint.bicep' = {
  name: endpointName
  params: {
    dnsZoneId: dnsZone.outputs.dnsZoneId
    funcAppId: functionApp.outputs.functionAppId
    name: endpointName
    subnetId: virtualNetwork.outputs.defaultSubnetId
    location: location
  }
}



