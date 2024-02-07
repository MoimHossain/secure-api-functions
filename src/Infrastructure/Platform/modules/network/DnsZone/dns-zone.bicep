// param name string = 'privatelink.azurewebsites.net'
// param vnetName string
// param vnetId string

// var linkName = 'link-${name}-${vnetName}'

// resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
//   name: name
//   location: 'global'
// }


// resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
//   parent: privateDnsZone
//   name: linkName
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnetId
//     }
//   }
// }

// output dnsZoneId string = privateDnsZone.id
