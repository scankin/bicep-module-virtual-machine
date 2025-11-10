param virtualMachineName string = 'example-virtual-machine'
param location string = 'uksouth'
param privateIpAddress string = '10.0.0.0'
param subnetId string
param vmSize string = 'Standard_B2ts_v2'
param adminUsername string = 'adminUser'
@secure()
param adminPassword string
param imageReference object = { 
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-azure-edition'
}
param osDisk object = {
  caching: 'None'
  storageAccountType: 'Standard_LRS'
}
param dataDisks array = [
  {
    sku: 'Standard_LRS'
    diskSizeGB: '128'
  }
]

var nicName = '${virtualMachineName}-nic-01'

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-10-01' = {
  name: nicName
  location: location
  properties: { 
    ipConfigurations: [
      {
        name: '${nicName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIpAddress
          subnet: { 
            id: subnetId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: virtualMachineName
  location: location
  properties: { 
    hardwareProfile: { 
      vmSize: vmSize
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: { 
      imageReference: {
        publisher: imageReference.publisher
        offer: imageReference.offer
        sku: imageReference.sku
        version: imageReference.version != null ? imageReference.version : 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        caching: osDisk.caching
        managedDisk: {
          storageAccountType: osDisk.storageAccountType
        }
      }
      dataDisks: [for(disk, i) in dataDisks: {
        createOption: 'Attach'
        lun: i
        managedDisk: {
          id: dataDisk[i].id
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        { 
          id: networkInterface.id
        }
      ]
    }
  }
}

resource dataDisk 'Microsoft.Compute/disks@2025-01-02' = [
  for(disk, i) in dataDisks: {
    name: '${virtualMachineName}-datadisk-0${i}'
    location: location
    sku: { 
      name: disk.sku
    }
    properties: { 
      diskSizeGB: disk.diskSizeGB
      creationData: { 
        createOption: 'Empty'
      }
    }
  }
]
