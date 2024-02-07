param privateEndpointName string
param location string = resourceGroup().location
param vnetId string
param subnetId string
param privateLinkServiceId string
@allowed([
  'sqlServer'
  'sites'
])
param targetSubResource string
param createPrivateDns bool = true

var database = 'database'
var host = 'windows.net'
var zoneName = 'privatelink.${database}.${host}'
var linkName = 'link-${privateEndpointName}-${guid(privateEndpointName)}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: '${privateEndpointName}-nic'
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            targetSubResource
          ]
        }
      }
    ]
  }
}

resource privateSqlDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = if(createPrivateDns) {
  name: zoneName
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateSqlDnsZone
  name: linkName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: privateEndpoint
  name: 'default'  
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: privateSqlDnsZone.id
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneId string = privateSqlDnsZone.id
output vnetLinkId string = vnetLink.id
output privateEndpointNameId string = privateDnsZoneGroups.id

