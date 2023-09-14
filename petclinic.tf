module "petclinic_infra" {
  source = "./modules/init"
  database_configuration = {
    instance_name           = google_sql_database_instance.shared_database_instance.name
    database_name           = "petclinic"
    user_name               = "petclinic_user"
    desired_password_length = var.petclinic_database_desired_password_length
  }
  secret_configuration = {
    name     = "petclinic_database_configuration"
    location = var.region
  }

  depends_on = [google_sql_database_instance.shared_database_instance]
}