targetScope = 'resourceGroup'

param location string = resourceGroup().location

var sqlAdminUAMIName = 'SQLAdminUAMITSL0'
var functionIdentityName = 'FuncIdentityTSL0'
var sqlServerName = 'nebulaSrvrxTSL0'
var sqlDatabaseName = 'nebulasDbTSL0'
var serverFarmName = 'nebulaServerFarmTSL0'
var functionAppName = 'nebulaFuncAppx00TSL0'
var vnetName = 'nebulavnetTSL0'
var sqlPrivateEndpointName = 'nebulaSqlPrivateEndpointTSL0'

var allowClientIp = true
var clientIpValue = '84.87.237.145'



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

// until here works










// module dnsZone 'modules/network/DnsZone/dns-zone.bicep' = {
//   name: dnsZoneName
//   params: {
//     name: dnsZoneName
//     vnetName: vnetName
//     vnetId: virtualNetwork.outputs.vnetId
//   }
// }





// module privateEndpoint 'modules/network/private-endpoints/endpoint.bicep' = {
//   name: endpointName
//   params: {
//     dnsZoneId: dnsZone.outputs.dnsZoneId
//     funcAppId: functionApp.outputs.functionAppId
//     name: endpointName
//     subnetId: virtualNetwork.outputs.defaultSubnetId
//     location: location
//   }
// }



// module apimService 'modules/api-management/apim.bicep' = {
//   name: apimServiceName
//   params: {
//     apimServiceName: apimServiceName
//     location: location
//     sku: sku
//     skuCount: skuCount
//     publisherEmail: publisherEmail
//     publisherName: publisherName
//     publicIpAddressName: publicIpAddressName
//     subnetName: virtualNetwork.outputs.apimSubnetName
//     virtualNetworkName: virtualNetwork.name
//   }
// }

