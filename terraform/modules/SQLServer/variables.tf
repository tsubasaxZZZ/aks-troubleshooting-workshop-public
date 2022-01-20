variable "server_name" {
  type        = string
  description = ""
}

variable "resource_group_name" {
  type        = string
  description = ""
}

variable "location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "database_name" {
  type        = string
  default     = "demo_DB"
  description = ""
}

variable "requested_service_objective_name" {
  type        = string
  default     = "GP_Gen5_2"
  description = ""
}

