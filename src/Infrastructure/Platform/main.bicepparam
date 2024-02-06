using 'main.bicep'

var appname = readEnvironmentVariable('APP_NAME')
var appEnv = readEnvironmentVariable('APP_ENV')

// param vnetName = '${appname}-vnet-${appEnv}'
// param serverFarmName = '${appname}-serverfarm-${appEnv}'
// param functionAppName= '${appname}-funcapp-${appEnv}'

// param apimServiceName = '${appname}apim${appEnv}'
// param publisherEmail = 'moim.hossain@microsoft.com'
// param publisherName = 'Neptune Inc.'
// param sku = 'Premium' // (Premium | Standard | Developer | Basic | Consumption)
// param skuCount = 1
// param publicIpAddressName = '${appname}-publicip-${appEnv}'
