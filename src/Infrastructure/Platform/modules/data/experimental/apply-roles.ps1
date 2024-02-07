
## In order to run this script, the managed identity of SQL server (on-behalf-of which the script is running) should have the following permissions:
## User.Read.All
## GroupMember.Read.All
## Application.Read.All
## Or, alternatively, instead of above 3 granular roles, Directory.Read.All can also do the job.

## -instance "nebulaSrvrx001.database.windows.net" 
## -tokenResourceUrl "https://database.windows.net" 
## -dbName "nebulasDatabase" 
## -adObjectName "FuncIdentity" 
## -dbRoleNames "db_owner"
      param(
        [string] $instance,
        [string] $tokenResourceUrl,
        [string] $dbName,
        [string] $adObjectName,
        [string] $dbRoleNames
      )
      
      Install-Module -Name SqlServer -Force
      Import-Module -Name SqlServer

      #$token = (Get-AzAccessToken -ResourceUrl $tokenResourceUrl).Token
      $token = (az account get-access-token --resource $tokenResourceUrl | ConvertFrom-Json | select -ExpandProperty accessToken)
      $roles = $dbRoleNames.Split("--")
      $sqlStatements = @()
      $sqlStatements += "CREATE USER `"$adObjectName`" FROM external provider"
      foreach($role in $roles){
        $sqlStatements += "ALTER ROLE $role ADD MEMBER `"$adObjectName`""
      }
      $query = $sqlStatements -join ";"

      Invoke-Sqlcmd -ServerInstance $instance -Database $dbName -AccessToken "$token" -Query $query

