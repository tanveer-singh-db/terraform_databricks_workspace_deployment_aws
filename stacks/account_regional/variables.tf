variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "workspace" {
  type    = string
  default = ""
}

variable "config_root" {
  type    = string
  default = "../../configs"
}
