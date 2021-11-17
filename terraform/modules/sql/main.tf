locals {
  db_name = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-${var.configs.name}-${var.prefix}"
}


###################################
## Cloud SQL instance random string
###################################
# password
resource "random_string" "root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# db name suffix
resource "random_id" "db_name_suffix" {
  byte_length = 4
}


###################################
## Cloud SQL instances
###################################
resource "google_sql_database_instance" "instances" {
  for_each = var.configs.instances

  project = var.project_id
  name    = var.tags.stage == "prd" ? local.db_name : "${local.db_name}-${random_id.db_name_suffix.hex}"
  //name                = "${local.db_name}-${random_id.db_name_suffix.hex}"
  region              = var.region
  database_version    = each.value.version
  deletion_protection = var.configs.deletion_protection
  root_password       = random_string.root_password.result

  settings {
    tier            = each.value.type
    disk_size       = var.configs.disk_size
    disk_autoresize = var.configs.disk_autoresize

    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = "false"
      private_network = var.network
    }

    backup_configuration {
      enabled = false
    }

    maintenance_window {
      day  = var.configs.maintenance_window.day
      hour = var.configs.maintenance_window.hour
    }

    dynamic "database_flags" {
      for_each = var.configs.flags
      content {
        name  = database_flags.value["name"]
        value = database_flags.value["value"]
      }
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].backup_configuration[0].location
    ]
  }
}


###################################
## Cloud SQL users
###################################
# cloud proxy
resource "google_sql_user" "proxy" {
  depends_on = [google_sql_database_instance.instances]
  for_each   = var.configs.users

  project  = var.project_id
  host     = "cloudsqlproxy~%"
  name     = "proxyuser"
  instance = google_sql_database_instance.instances[each.key].name
}

# other user
resource "google_sql_user" "users" {
  depends_on = [google_sql_database_instance.instances]
  for_each   = var.configs.users

  project  = var.project_id
  host     = each.value.host
  name     = each.value.name
  password = each.value.pass
  instance = google_sql_database_instance.instances[each.key].name
}


###################################
## Cloud SQL databases
###################################
resource "google_sql_database" "databases" {
  depends_on = [google_sql_user.users]
  for_each   = var.configs.databases

  project   = var.project_id
  name      = each.value.name
  charset   = each.value.charset
  collation = each.value.collation
  instance  = google_sql_database_instance.instances[each.key].name
}
