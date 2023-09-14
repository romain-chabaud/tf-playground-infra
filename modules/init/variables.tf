variable "database_configuration" {
  type = object({
    instance_name           = string
    database_name           = string
    user_name               = string
    desired_password_length = number
  })
}

variable "secret_configuration" {
  type = object({
    name     = string
    location = string
  })
}