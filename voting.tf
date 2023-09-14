# database
resource "random_password" "voting_random_database_password" {
  length = var.voting_database_desired_password_length >= local.min_database_password_length ? var.voting_database_desired_password_length : local.min_database_password_length
}

resource "google_sql_database" "voting_database" {
  name     = "voting_db"
  instance = google_sql_database_instance.shared_database_instance.name
}

resource "google_sql_user" "voting_user" {
  name     = "voting_user"
  instance = google_sql_database_instance.shared_database_instance.name
  password = random_password.voting_random_database_password.result
}

# secret manager
resource "google_secret_manager_secret" "voting_secret" {
  secret_id = "voting_db_env_config"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "voting_secret_value" {
  secret = google_secret_manager_secret.voting_secret.name
  secret_data = jsonencode({
    INSTANCE_HOST = google_sql_database_instance.shared_database_instance.public_ip_address
    DB_PORT       = 5432
    DB_NAME       = google_sql_database.voting_database.name
    DB_USER       = google_sql_user.voting_user.name
    DB_PASS       = google_sql_user.voting_user.password
  })
}