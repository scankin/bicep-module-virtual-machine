# Bicep Module for Azure Virtual Machines
The following documentation assumes knowledge in:
- Azure
- Bicep

An example deployment can be found within the `./example` directory.

## Parameters
| Name | Type | Description | Required |
|------|------|-------------|----------|
| virtualMachineName | `string` | The name of the key vault to be deployed. | Y |
| computerName | `string` | The hostname of the virtual machine to deploy | Y |
| location | `string` | The location to deploy the virtual machine to i.e. uksouth | Y |
| privateIpAddress | `string` | The IPv4 address of the Virtual Machine | Y |
| subnetId | `string` | The Id of the subnet to deploy the virtual machine to | Y |
| vmSize | `string` | The SKU of the virtual machine to deploy, defaults to `Standard_B2ts_v2`, recommended that this is changed. | N | 
| adminUsername | `string` | The admin username for the virtual machine | Y |
| adminPassword | `string` | The admin login password for the Azure Virtual Machine, this is a secure input | Y |
| imageReference | `object` | The details of the image to deploy | N |
| osDisk | `object` | Object containing details for the os disk, i.e. caching and storage account type | N |
| dataDisks | `array` | An array of objects containing the configuration details for the data disks |

## Resources Created
- 1x Azure Virtual Machine
    - 1x Network Interface Card
    - 1x OS Disk
- Nx Data Disks