

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
                "ipAddress": "84.87.237.145/32",
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

echo $bodyJson


az resource patch \
        --name cqalx01-funcapp-DV \
        --resource-group APIM-DEVOPS-CASAULRGX \
        --resource-type Microsoft.web/sites \
        --is-full-object \
        --properties "$bodyJson"