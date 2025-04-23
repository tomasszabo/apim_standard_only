
@description('Azure location where resources should be deployed (e.g., westeurope)')
param location string = 'westeurope'

param prefix string = 'apimst2o'

// Shared parameters
param logAnalyticsWorkspaceName string = '${prefix}-loganalytics-${uniqueString(resourceGroup().id)}'
param appInsightsName string = '${prefix}-appinsights-${uniqueString(resourceGroup().id)}'

// Network parameters
param apimIpAddressName string = '${prefix}-public-ip-apim-${uniqueString(resourceGroup().id)}'
param vnetName string = '${prefix}-vnet-${uniqueString(resourceGroup().id)}'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetApimName string = 'apim'
param subnetApimPrefix string = '10.0.1.0/26'
param subnetPrivateEndpointsName string = 'private-endpoints'
param subnetPrivateEndpointsPrefix string = '10.0.2.0/24'
param nsgApimName string = '${prefix}-nsg-apim-${uniqueString(resourceGroup().id)}'

// API Management parameters
param apimName string = '${prefix}-apim-${uniqueString(resourceGroup().id)}'
param skuName string = 'StandardV2'
param capacity int = 1
param publisherEmail string = 'apim@contoso.com'
param publisherName string = 'Contoso'

// Private Endpoints parameters
param apimPrivateEndpointName string = '${prefix}-apim-private-endpoint'
param apimPrivateLinkName string = '${prefix}-apim-private-link'

module sharedModule './shared.bicep' = {
  name: 'sharedModule'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
  }
}

module networkModule './network.bicep' = {
  name: 'networkModule'
  dependsOn: [
    sharedModule
  ]
  params: {
    location: location
    apimIpAddressName: apimIpAddressName
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetApimName: subnetApimName
    subnetApimPrefix: subnetApimPrefix
    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix
    nsgApimName: nsgApimName
  }
}

module apimModule './apim.bicep' = {
  name: 'apimModule'
  params: {
    location: location
    subnetApimId: networkModule.outputs.subnetApimId
    publicIpAddressId: networkModule.outputs.apimIpAddressId
    appInsightsName: sharedModule.outputs.appInsightsName
    appInsightsId: sharedModule.outputs.appInsightsId
    appInsightsInstrumentationKey: sharedModule.outputs.appInsightsInstrumentationKey
    apimName: apimName
    skuName: skuName
    capacity: capacity
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

module privateEndpointsModule './private-endpoints.bicep' = {
  name: 'privateEndpointsModule'
  params: {
    location: location
    vnetId: networkModule.outputs.vnetId
    subnetPrivateEndpointsId: networkModule.outputs.subnetPrivateEndpointsId
    endpoints: [
      {
        privateEndpoint: apimPrivateEndpointName
        privateLink: apimPrivateLinkName
        dnsZoneName: 'privatelink.azure-api.net'
        groupIds: ['Gateway']
        serviceId: apimModule.outputs.apimId
      }
    ]
  }
}
