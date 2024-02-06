param name string
param location string
param scriptManagedIdentityName string

param serverName string
param dbName string
param adObjectName string
param dbRoleNames string 
param currentTime string = utcNow()

resource deploymentScriptRunIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: scriptManagedIdentityName
}

var sqlServerHostname = environment().suffixes.sqlServerHostname
var instance = '${serverName}${sqlServerHostname}'
var tokenResourceUrl = 'https://${substring(sqlServerHostname, 1)}'

resource deploymentScriptServerGroupAssignment 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ADObject2Ssql${name}${adObjectName}'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${deploymentScriptRunIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    arguments: '-instance "${instance}" -tokenResourceUrl "${tokenResourceUrl}" -dbName "${dbName}" -adObjectName "${adObjectName}" -dbRoleNames "${dbRoleNames}"'
    scriptContent: '''
      param(
        [string] $instance,
        [string] $tokenResourceUrl,
        [string] $dbName,
        [string] $adObjectName,
        [string] $dbRoleNames
      )
      
      Install-Module -Name SqlServer -Force
      Import-Module -Name SqlServer

      $token = (Get-AzAccessToken -ResourceUrl $tokenResourceUrl).Token
      $roles = $dbRoleNames.Split("--")
      $sqlStatements = @()
      $sqlStatements += "CREATE USER `"$adObjectName`" FROM external provider"
      foreach($role in $roles){
        $sqlStatements += "ALTER ROLE $role ADD MEMBER `"$adObjectName`""
      }
      $query = $sqlStatements -join ";"

      Invoke-Sqlcmd -ServerInstance $instance -Database $dbName -AccessToken "$token" -Query $query
    '''
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: currentTime // ensures script will run every time
  }
}
