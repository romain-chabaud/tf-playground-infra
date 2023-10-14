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
resource "google_service_account" "petclinic_secret_manager_service_account" {
  account_id = "petclinic-secret-sa"
}

resource "google_secret_manager_secret" "petclinic_db_url_secret" {
  secret_id = "PETCLINIC_DB_URL"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "petclinic_db_url_secret_value" {
  secret      = google_secret_manager_secret.petclinic_db_url_secret.name
  secret_data = "jdbc:postgresql://${google_sql_database_instance.shared_database_instance.public_ip_address}:5432/${google_sql_database.petclinic_database.name}"
}

resource "google_secret_manager_secret_iam_member" "petclinic_db_url_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.petclinic_db_url_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.petclinic_secret_manager_service_account.email}"
}

resource "google_secret_manager_secret" "petclinic_db_user_secret" {
  secret_id = "PETCLINIC_DB_USER"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "petclinic_db_user_secret_value" {
  secret      = google_secret_manager_secret.petclinic_db_user_secret.name
  secret_data = google_sql_user.petclinic_user.name
}

resource "google_secret_manager_secret_iam_member" "petclinic_db_user_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.petclinic_db_user_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.petclinic_secret_manager_service_account.email}"
}

resource "google_secret_manager_secret" "petclinic_db_password_secret" {
  secret_id = "PETCLINIC_DB_PASSWORD"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "petclinic_db_password_secret_value" {
  secret      = google_secret_manager_secret.petclinic_db_password_secret.name
  secret_data = google_sql_user.petclinic_user.password
}

resource "google_secret_manager_secret_iam_member" "petclinic_db_password_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.petclinic_db_password_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.petclinic_secret_manager_service_account.email}"
}