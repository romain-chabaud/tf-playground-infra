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
resource "google_service_account" "voting_secret_manager_service_account" {
  account_id = "voting-secret-sa"
}

resource "google_secret_manager_secret" "voting_db_ip_secret" {
  secret_id = "VOTING_DB_IP"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "voting_db_ip_secret_value" {
  secret      = google_secret_manager_secret.voting_db_ip_secret.name
  secret_data = google_sql_database_instance.shared_database_instance.public_ip_address
}

resource "google_secret_manager_secret_iam_member" "voting_db_ip_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.voting_db_ip_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.voting_secret_manager_service_account.email}"
}

resource "google_secret_manager_secret" "voting_db_name_secret" {
  secret_id = "VOTING_DB_NAME"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "voting_db_name_secret_value" {
  secret      = google_secret_manager_secret.voting_db_name_secret.name
  secret_data = google_sql_database.voting_database.name
}

resource "google_secret_manager_secret_iam_member" "voting_db_name_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.voting_db_name_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.voting_secret_manager_service_account.email}"
}

resource "google_secret_manager_secret" "voting_db_user_secret" {
  secret_id = "VOTING_DB_USER"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "voting_db_user_secret_value" {
  secret      = google_secret_manager_secret.voting_db_user_secret.name
  secret_data = google_sql_user.voting_user.name
}

resource "google_secret_manager_secret_iam_member" "voting_db_user_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.voting_db_user_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.voting_secret_manager_service_account.email}"
}

resource "google_secret_manager_secret" "voting_db_password_secret" {
  secret_id = "VOTING_DB_PASSWORD"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "voting_db_password_secret_value" {
  secret      = google_secret_manager_secret.voting_db_password_secret.name
  secret_data = google_sql_user.voting_user.password
}

resource "google_secret_manager_secret_iam_member" "voting_db_password_secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.voting_db_password_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.voting_secret_manager_service_account.email}"
}