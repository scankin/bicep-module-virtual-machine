using 'example.bicep'

param service = 'sja'
param location = 'uksouth'
param environment = 'development'
param adminUsername = 'adminUser'
param adminPassword = 'N0tR3alP@55'
param vnetCIDR = '10.0.0.0/24'
param subnetConfiguration = [
  {
    name: 'subnet-1'
    addressPrefix: '10.0.0.0/25'
  }
]
param virtualMachines = [
  {
    computerName: 'examplevm1'
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
