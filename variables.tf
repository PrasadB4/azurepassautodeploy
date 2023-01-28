variable "resource_group_name" {
  type    = string
  default = "Terraform_RG"
}

variable "virtual_network_name" {
  type    = string
  default = "Terraform_VNET"
}

variable "subnet_name" {
  type    = string
  default = "Terraform_Subnet"
}

variable "nsg_name" {
  type    = string
  default = "Terraform_NSG"
}

variable "web_app_name" {
  type    = string
  default = "cusdepwebapp"
}

variable "sql_server_name" {
  type    = string
  default = "Terraform_SQL_Server"
}

variable "app_service_plan_name" {
  type    = string
  default = "Terraform_App_Service_Plan"
}

variable "storage_account_name" {
  type    = string
  default = "terstorage925"
}

variable "private_link_name" {
  type    = string
  default = "store_pvt_link"

}

variable "private_endpoint_name" {
  type    = string
  default = "tpvtep"
}

