
## To enable the public network access and add the IP security restrictions to the function app

# Get local machine IP address
localMachineIP=$(curl -s ifconfig.me)
echo "Local Machine IP: $localMachineIP"

bodyJson=$(cat <<EOF
{
  "properties": {
    "publicNetworkAccess": "Enabled",
    "siteConfig": {
        "ipSecurityRestrictionsDefaultAction": "Deny",
        "scmIpSecurityRestrictionsUseMain": false,
        "scmIpSecurityRestrictionsDefaultAction": "Deny",
        "scmIpSecurityRestrictions": [
              {
                "ipAddress": "$localMachineIP/32",
                "action": "Allow",
                "tag": "Default",
                "priority": 100,
                "name": "LOCALMACHINE",
                "description": "LocalmachineIP",
                "vnetSubnetResourceId": null,
                "headers": {},
                "serviceEndpointDisabled": false,
                "id": "5"
              }
            ],
        "ipSecurityRestrictions": []
    }
  }
}   
EOF
)

## To Disable the public network access to the function app
# bodyJson=$(cat <<EOF
# {
#   "properties": {
#     "publicNetworkAccess": "Disabled"
#   }
# }   
# EOF
# )

# Log the bodyJson
echo $bodyJson

# Apply the changes to the function app
az resource patch \
        --name cqalx01-funcapp-DV \
        --resource-group APIM-DEVOPS-CASAULRGX \
        --resource-type Microsoft.web/sites \
        --is-full-object \
        --properties "$bodyJson"