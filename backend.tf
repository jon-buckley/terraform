terraform {
  backend "azure" {
    storage_account_name = "terraformstatefinalta"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "Xf3GfBHWohb9/DZISkDu7kh/3rEav4NA88s82PyyVYITRDgd6hRdTBUQPLFdl3TOJqdwKEH9rhJqYtCT+M9smQ=="
  }
}
