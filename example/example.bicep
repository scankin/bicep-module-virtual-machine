//INFO: Parameter definitions
@maxLength(3)
@description('Three character service code for resource naming convention.')
param service string
@allowed([
  'development'
  'staging'
  'production'
])
@description('The environment being deployed to, allowed "development", "staging" or "production"')
param environment string
@allowed([
  'uksouth'
  'ukwest'
])
@description('The location to be deployed to, allowed "uksouth" and "ukwest"')
param location string = 'uksouth'
param vnetCIDR string = '10.0.0.0/24'
param subnetConfiguration array = [
  {
    name: 'subnet-1'
    addressPrefix: '10.0.0.0/25'
  }
]
param virtualMachines array = [
  {
    privateIpAddress: '10.0.0.4'
    vmSize: 'Standard_B2ts_v2'
    imageReference: { 
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
    }
    osDisk: {
      caching: 'None'
      storageAccountType: 'Standard_LRS'
    }
    dataDisks: [
      {
        sku: 'Standard_LRS'
        diskSizeGB: '128'
      } 
    ]
  }
]
param adminUsername string
@secure()
param adminPassword string

//INFO: Variable Declarations
var regionShortcode object = {
  uksouth: 'uks'
  ukwest: 'ukw'
}

var environmentShortcode object = {
  development: 'dev'
  staging: 'stg'
  UAT: 'uat'
}

var tags object = {
  environment: environmentShortcode[environment]
  location: location
  service: service
}

var virtualNetworkName = '${service}-vm-vnet-${regionShortcode[location]}-${environmentShortcode[environment]}'
var virtualMachineName = '${service}-vm-vnet-${regionShortcode[location]}-${environmentShortcode[environment]}-__key__'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetCIDR]
    }
  }
  tags: tags
}

resource subnetResource 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = [
  for (subnet, i) in subnetConfiguration: {
    parent: virtualNetwork
    name: subnet.name
    properties: {
      addressPrefix: subnet.addressPrefix
    }
  }
]

module virtualMachine '../main.bicep' = [
  for (virtualMachine, i) in virtualMachines: {
    params: {
      virtualMachineName: replace(virtualMachineName, '__key__', '0${i}')
      location: location
      privateIpAddress: virtualMachine.privateIpAddress
      vmSize: virtualMachine.vmSize
      adminUsername: adminUsername
      adminPassword: adminPassword
      imageReference: virtualMachine.imageReference
      osDisk: virtualMachine.osDisk
      dataDisks: virtualMachine.dataDisks
      subnetId: subnetResource[i].id
    }
  }
]
