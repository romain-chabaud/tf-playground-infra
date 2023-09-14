module "voting_infra" {
  source = "./modules/init"
  database_configuration = {
    instance_name           = google_sql_database_instance.shared_database_instance.name
    database_name           = "voting_db"
    user_name               = "voting_user"
    desired_password_length = var.voting_database_desired_password_length
  }
  secret_configuration = {
    name     = "voting_database_configuration"
    location = var.region
  }

  depends_on = [google_sql_database_instance.shared_database_instance]
}