
# Example delpoyment of API Management Standard v2 only

This example Bicep script will deploy API managemnt Standard V2 with VNET integration and private endpoint.

Run deployment from Azure CLI from `bicep` directory with following command:

```bash
az deployment group create \
	--resource-group <your-resource-group> \
	--template-file main.bicep \
	--parameters location=<location>
```
