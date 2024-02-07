using 'main.bicep'

var appname = readEnvironmentVariable('APP_NAME')
var appEnv = readEnvironmentVariable('APP_ENV')


param apimServiceName = '${appname}apim${appEnv}'
param publisherEmail = 'moim.hossain@microsoft.com'
param publisherName = 'Neptune Inc.'
param sku = 'Premium' // (Premium | Standard | Developer | Basic | Consumption)
param skuCount = 1
param publicIpAddressName = '${appname}-publicip-${appEnv}'

param sqlAdminUAMIName = '${appname}-SQLUAMI-${appEnv}'
param functionIdentityName = '${appname}-FuncUAMI-${appEnv}'
param sqlServerName = '${appname}-sqlserver-${appEnv}'
param sqlDatabaseName = '${appname}-sqldb-${appEnv}'
param serverFarmName = '${appname}-serverfarm-${appEnv}'
param functionAppName = '${appname}-funcapp-${appEnv}'
param vnetName = '${appname}-vnet-${appEnv}'
