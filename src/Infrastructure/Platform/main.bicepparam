using 'main.bicep'

var appname = readEnvironmentVariable('APP_NAME')
var appEnv = readEnvironmentVariable('APP_ENV')

param vnetName = '${appname}-vnet-${appEnv}'
param serverFarmName = '${appname}-serverfarm-${appEnv}'
param functionAppName= '${appname}-funcapp-${appEnv}'
