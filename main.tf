resource "google_sql_database_instance" "shared_database_instance" {
  name             = "shared-database-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"

    ip_configuration {
      authorized_networks {
        value = var.authorized_networks
      }
    }
  }
}