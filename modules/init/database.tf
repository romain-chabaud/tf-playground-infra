data "google_sql_database_instance" "database_instance" {
  name = var.database_configuration.instance_name
}

resource "random_password" "random_database_password" {
  length = var.database_configuration.desired_password_length >= local.min_database_password_length ? var.database_configuration.desired_password_length : local.min_database_password_length
}

resource "google_sql_database" "database" {
  name     = var.database_configuration.database_name
  instance = data.google_sql_database_instance.database_instance.name
}

resource "google_sql_user" "user" {
  name     = var.database_configuration.user_name
  instance = data.google_sql_database_instance.database_instance.name
  password = random_password.random_database_password.result
}