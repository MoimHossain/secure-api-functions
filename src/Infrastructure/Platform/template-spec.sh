

export RESOURCE_GROUP="Template-Specs"
export LOCATION="westeurope"
export VERSION="1.0"

az bicep build --file main.bicep

az ts create \
    --name "Sec-SQL-Func-APIM" \
    --version $VERSION \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --template-file "main.json" \
    --yes --query 'id' -o json