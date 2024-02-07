targetScope = 'resourceGroup'

param location string = resourceGroup().location

var sqlAdminUAMIName = 'SQLAdminUAMI'
var functionIdentityName = 'FuncIdentity'
var sqlServerName = 'nebulaSrvrx002'
var sqlDatabaseName = 'nebulasDb'
var serverFarmName = 'nebulaServerFarm'
var functionAppName = 'nebulaFuncAppx002'
var allowClientIp = true
var clientIpValue = '84.87.237.145'
var vnetName = 'nebulavnet001'
var sqlPrivateEndpointName = 'nebulaSqlPrivateEndpoint'


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
    publicNetworkAccess: 'Disabled'
    sqlAdminUserAssignedIdentityName: sqlAdminUAMI.name
    azureADOnlyAuthentication: false
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

// module serverFarm 'modules/web/server-farm.bicep' = {
//   name: serverFarmName
//   params: {
//     location: location
//     name: serverFarmName
//   }
// }

// module functionApp 'modules/web/function-app.bicep' = {
//   name: functionAppName
//   params: {
//     location: location
//     name: functionAppName
//     functionUAMIName: functionIdentity.name
//     serverFarmId: serverFarm.outputs.serverfarmId    
//   }
// }

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

