variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "authorized_networks" {
  type    = string
  default = "0.0.0.0/0"
}

variable "voting_database_desired_password_length" {
  type = number
}

variable "petclinic_database_desired_password_length" {
  type = number
}