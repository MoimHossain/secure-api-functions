
# Function code


For deploying the function code, we can open the network temporarily to allow the function code to be downloaded from the internet. We can then close the network after the function code has been downloaded.

```bash
# Open the network
az resource update --resource-group APIM-DEVOPS-CASAULRGX --name cqalx01-funcapp-DV --resource-type "Microsoft.Web/sites" --set properties.publicNetworkAccess=Enabled

# Deploy the function code
# func azure functionapp publish <function-app-name>

```