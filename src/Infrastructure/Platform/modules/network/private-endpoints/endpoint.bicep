// param name string
// param location string = resourceGroup().location
// param subnetId string
// param funcAppId string
// param dnsZoneId string

// var networkIterfaceCardName = '${name}-nic'

// resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = {
//   name: name
//   location: location
//   properties: {
//     subnet: {
//       id: subnetId
//     }
//     customNetworkInterfaceName: networkIterfaceCardName
//     privateLinkServiceConnections: [
//       {
//         name: name        
//         properties: {
//           privateLinkServiceId: funcAppId
//           groupIds: [
//             'sites'
//           ]
//         }
//       }
//     ]
//   }
// }


// resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
//   parent: privateEndpoint
//   name: 'default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'privatelink-azurewebsites-net'
//         properties: {
//           privateDnsZoneId: dnsZoneId
//         }
//       }
//     ]
//   }
// }

