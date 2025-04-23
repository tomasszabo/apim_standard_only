
param location string

param subnetApimId string
param publicIpAddressId string
param appInsightsName string
param appInsightsId string
param appInsightsInstrumentationKey string

param apimName string
param skuName string
param capacity int
param publisherEmail string
param publisherName string

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apimName
  location: location
  sku:{
    capacity: capacity
    name: skuName
  }
  identity:{
    type: 'SystemAssigned'
  }
  properties:{
    virtualNetworkType: 'External'
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicIpAddressId: publicIpAddressId
    virtualNetworkConfiguration: {
      subnetResourceId: subnetApimId
    }
    privateEndpointConnections: [
      {
        name: 'apimPrivateEndpoint'
        properties: {
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Approved by Bicep template'
          }
        }
      }
    ]
  }
}

resource apimAppInsightsLogger 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = {
  parent: apim
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource apimNameAppInsights 'Microsoft.ApiManagement/service/diagnostics@2023-03-01-preview' = {
  parent: apim
  name: 'applicationinsights'
  properties: {
    loggerId: apimAppInsightsLogger.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
  }
}

output apimName string = apimName
output apimId string = apim.id
output apimFQDN string = replace(apim.properties.gatewayUrl, 'https://', '')
