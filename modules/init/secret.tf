resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret" "secret" {
  secret_id = var.secret_configuration.name
  replication {
    user_managed {
      replicas {
        location = var.secret_configuration.location
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "secret_value" {
  secret = google_secret_manager_secret.secret.name
  secret_data = jsonencode({
    instance_name = data.google_sql_database_instance.database_instance.name
    public_ip     = data.google_sql_database_instance.database_instance.public_ip_address
    port          = 5432
    database_name = google_sql_database.database.name
    username      = google_sql_user.user.name
    password      = google_sql_user.user.password
  })
}