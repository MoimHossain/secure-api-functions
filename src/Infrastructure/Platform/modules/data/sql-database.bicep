param location string = resourceGroup().location
param serverName string
param databaseName string
param zoneRedundant bool = false

var collation = 'SQL_Latin1_General_CP1_CI_AS'
var maxSizeBytes = 34359738368
var sampleName = 'AdventureWorksLT'
var licenseType = ''
var readScaleOut = ''
var numberOfReplicas = 0

var autoPauseDelay = 60
var requestedBackupStorageRedundancy = 'Local'
var enableSqlLedger = false
var availabilityZone = ''
var useFreeLimit = false
var freeLimitExhaustionBehavior = 'AutoPause'
var skuName = 'GP_S_Gen5_2'
var tier = 'GeneralPurpose'

resource server 'Microsoft.Sql/servers@2021-05-01-preview' existing = { 
  name: serverName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  location: location  
  parent: server
  name: databaseName
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    sampleName: sampleName
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    readScale: readScaleOut
    highAvailabilityReplicaCount: numberOfReplicas
    autoPauseDelay: autoPauseDelay
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    isLedgerOn: enableSqlLedger
    availabilityZone: availabilityZone
    useFreeLimit: useFreeLimit
    freeLimitExhaustionBehavior: freeLimitExhaustionBehavior
  }
  sku: {
    name: skuName
    tier: tier
  }
}


output databaseId string = sqlDatabase.id
