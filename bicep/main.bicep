
@description('Azure location where resources should be deployed (e.g., westeurope)')
param location string = 'westeurope'

param prefix string = 'apimanagement'
param suffix string = '02'

// Shared parameters
param logAnalyticsWorkspaceName string = 'la-${prefix}-${suffix}'
param appInsightsName string = 'appinsights-${prefix}-${suffix}'

// Network parameters
param apimIpAddressName string = 'pip-${prefix}-${suffix}'
param vnetName string = 'vnet-${prefix}-${suffix}'
param vnetAddressPrefix string = '10.224.100.0/24'
param subnetApimName string = 'apim'
param subnetApimPrefix string = '10.224.100.0/26'
param subnetPrivateEndpointsName string = 'private-endpoints'
param subnetPrivateEndpointsPrefix string = '10.224.100.64/26'
param nsgApimName string = 'nsg-apim-${prefix}-${suffix}'

// API Management parameters
param apimName string = 'apim-${prefix}-${suffix}'
param skuName string = 'StandardV2'
param capacity int = 1
param publisherEmail string = 'apim@contoso.com'
param publisherName string = 'Contoso'

// Private Endpoints parameters
param apimPrivateEndpointName string = 'apim-pe-${prefix}-${suffix}'
param apimPrivateLinkName string = 'apim-pl-${prefix}-${suffix}'

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
