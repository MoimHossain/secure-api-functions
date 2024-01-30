targetScope = 'resourceGroup'

param location string = resourceGroup().location
param serverFarmName string 
param vnetName string
param functionAppName string

param apimServiceName string
param publicIpAddressName string
param publisherEmail string
param publisherName string
param sku string
param skuCount int

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
    subnetName: virtualNetwork.outputs.apimSubnetName
    virtualNetworkName: virtualNetwork.name
  }
}

