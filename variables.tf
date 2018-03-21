variable "prefix" {
  description = "Default prefix to use with your resource names."
  default     = "finalta-dev"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "westeurope"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["finalta-public", "finalta-private"]
}

variable "tags" {
  type = "map"

  default = {
    tag1 = "finalta-dev"
    tag2 = "tech-ops"
  }
}
