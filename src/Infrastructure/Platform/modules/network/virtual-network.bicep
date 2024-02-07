
param location string = resourceGroup().location
param vnetName string
param addressPrefix string = '10.0.0.0/16'

param dataSubnetName string = 'data-subnet'
param dataSubnetAddressPrefix string = '10.0.0.0/28'

param gatewaySubnetName string = 'gateway-subnet'
param gatewaySubnetAddressPrefix string = '10.0.1.0/28'

param backendSubnetName string = 'backend-subnet'
param backendAddressPrefix string = '10.0.2.0/28'

var gatewayNsgName = 'nsg-${vnetName}-${gatewaySubnetName}'

module nsgApim 'NetworkSecurityGroups/apim-subnet-nsg.bicep' = {
  name: gatewayNsgName
  params: {
    location: location
    nsgName: gatewayNsgName
  }
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: dataSubnetName
        properties: {
          addressPrefixes: [
            dataSubnetAddressPrefix
          ]          
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefixes: [
            gatewaySubnetAddressPrefix
          ]
          networkSecurityGroup: {
            id: nsgApim.outputs.nsgId
          }
        }
      }
      {
        name: backendSubnetName
        properties: {
          addressPrefixes: [
            backendAddressPrefix
          ]
          delegations: [
            {
              name: 'delegation'              
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
              type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
            }
          ]
        }
      }      
    ]
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' existing = {
  name: virtualNetwork.name
}

resource dataSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  parent: vnet
  name: dataSubnetName
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  parent: vnet
  name: gatewaySubnetName
}

resource backendSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  parent: vnet
  name: backendSubnetName
}

output vnetId string = vnet.id

output dataSubnetName string = dataSubnet.name
output dataSubnetId string = dataSubnet.id

output apimSubnetName string = gatewaySubnet.name
output apimSubnetId string = gatewaySubnet.id

output backendSubnetName string = backendSubnet.name
output backendSubnetId string = backendSubnet.id
