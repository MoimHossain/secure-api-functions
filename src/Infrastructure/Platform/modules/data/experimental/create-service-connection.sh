


az extension add --name serviceconnector-passwordless --upgrade
az webapp connection create sql --connection sql_1e8d2 --source-id $FunctionAppResourceId --target-id $SqlDatabaseResourceId --client-type dotnet --user-identity client-id=$UserAssignedMIClientId subs-id=$SubscriptionId