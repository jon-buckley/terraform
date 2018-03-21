module "linux_compute" {
  source         = "Azure/compute/azurerm"
  location       = "westeurope"
  vm_os_simple   = "UbuntuServer"
  public_ip_dns  = ["linsimplevmips"]                  // change to a unique name per datacenter region
  vnet_subnet_id = "${module.network.vnet_subnets[0]}"
}

module "windows_compute" {
  source         = "Azure/compute/azurerm"
  location       = "westeurope"
  vm_hostname    = "mywinvm"                           // line can be removed if only one VM module per resource group
  admin_password = "ComplxP@ssw0rd!"
  vm_os_simple   = "WindowsServer"
  public_ip_dns  = ["winsimplevmips"]                  // change to a unique name per datacenter region
  vnet_subnet_id = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "~> 1.1.1"
  location            = "westeurope"
  allow_rdp_traffic   = "true"
  allow_ssh_traffic   = "true"
  resource_group_name = "terraform-compute"
}

# This has to be unique as well, the output names.
output "linux_compute_vm_public_name" {
  value = "${module.linux_compute.public_ip_dns_name}"
}

output "windows_compute_vm_public_name" {
  value = "${module.windows_compute.public_ip_dns_name}"
}
