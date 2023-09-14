# database
resource "random_password" "petclinic_random_database_password" {
  length = var.petclinic_database_desired_password_length >= local.min_database_password_length ? var.petclinic_database_desired_password_length : local.min_database_password_length
}

resource "google_sql_database" "petclinic_database" {
  name     = "petclinic"
  instance = google_sql_database_instance.shared_database_instance.name
}

resource "google_sql_user" "petclinic_user" {
  name     = "petclinic_user"
  instance = google_sql_database_instance.shared_database_instance.name
  password = random_password.petclinic_random_database_password.result
}

# secret manager
resource "google_secret_manager_secret" "petclinic_secret" {
  secret_id = "petclinic_db_env_config"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "petclinic_secret_value" {
  secret = google_secret_manager_secret.petclinic_secret.name
  secret_data = jsonencode({
    SPRING_PROFILES_ACTIVE = "postgres"
    POSTGRES_URL           = "jdbc:postgresql://${google_sql_database_instance.shared_database_instance.public_ip_address}:5432/${google_sql_database.petclinic_database.name}"
    POSTGRES_USER          = google_sql_user.petclinic_user.name
    POSTGRES_PASS          = google_sql_user.petclinic_user.password
  })
}