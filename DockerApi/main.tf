terraform {
  required_providers {
    azurerm = {
      version = "~> 2.13.0"
    }
  }

  # Storage account required for tf state file
  backend "azurerm" {
    resource_group_name   = "tf_rg_blobstore"
    storage_account_name  = "tfstoragenks33"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}
provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "tf_rg" {
  name                  = "docker-demo-rg"
  location              = "Australia East"
}

variable "ImageBuild" {
  type        = string
  description = "Latest docker image build number"
}

resource "azurerm_container_group" "tf_container_grp" {
  name                  = "docker-demo-container-grp"
  location              = azurerm_resource_group.tf_rg.location
  resource_group_name   = azurerm_resource_group.tf_rg.name
  ip_address_type       = "public"
  dns_name_label        = "dockerdemo"
  os_type               = "Linux"
  container {
    name                = "dockerdemoapi"
    image               = "nks33/dockerapi:${var.imageBuild}"
    cpu                 = "1"
    memory              = "1"
    ports{
        port            = 80
        protocol        = "TCP" 
    }
  }
}