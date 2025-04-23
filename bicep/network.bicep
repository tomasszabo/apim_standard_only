
param location string
param apimIpAddressName string
param vnetName string
param vnetAddressPrefix string
param subnetApimName string
param subnetApimPrefix string
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string
param nsgApimName string

resource apimIpAddress 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: apimIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: apimIpAddressName    
    }
  }
}

resource nsgApim 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: nsgApimName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowInternetInbound'
        properties: {
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          protocol: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAPIMInbound'
        properties: {
          sourceAddressPrefix: 'ApiManagement'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
          protocol: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '6390'
          protocol: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowStorageOutbound'
        properties: {
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
          destinationPortRange: '443'
          protocol: '*'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowSqlOutbound'
        properties: {
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Sql'
          destinationPortRange: '1433'
          protocol: '*'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowKeyVaultOutbound'
        properties: {
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
          destinationPortRange: '443'
          protocol: '*'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetApimName
        properties: {
          addressPrefix: subnetApimPrefix
          networkSecurityGroup: {
            id: nsgApim.id
          }
          delegations: [
            {
              name: 'apimDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: subnetPrivateEndpointsName
        properties: {
          addressPrefix: subnetPrivateEndpointsPrefix
        }
      }
    ]
  }
}

output vnetName string = vnetName
output vnetId string = vnet.id
output apimIpAddressId string = apimIpAddress.id
output subnetApimId string = vnet.properties.subnets[0].id
output subnetPrivateEndpointsId string = vnet.properties.subnets[1].id
