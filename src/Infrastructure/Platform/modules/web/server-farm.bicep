param name string
param location string = resourceGroup().location

param sku string = 'EP1'
param tier string = 'ElasticPremium'
param size string = 'EP1'
param family string = 'EP'
param capacity int = 1
param kind string = 'elastic'

resource serverfarm 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
    tier: tier
    size: size
    family: family
    capacity: capacity
  }
  kind: kind
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 20
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}


output serverfarmId string = serverfarm.id
