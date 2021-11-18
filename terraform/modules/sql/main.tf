locals {
  db_name = "${var.tags.stage}-${var.tags.env}-${var.configs.name}-${var.prefix}"
}


###################################
## Cloud SQL instances
###################################
# db name suffix
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# create instances
resource "google_sql_database_instance" "instances" {
  depends_on = [random_id.db_name_suffix]
  for_each   = var.configs.instances

  project             = var.project.name
  name                = var.tags.stage == "stg" || var.tags.stage == "prd" ? local.db_name : "${local.db_name}-${random_id.db_name_suffix.hex}"
  region              = var.region
  database_version    = each.value.version
  deletion_protection = var.configs.deletion_protection
  root_password       = each.value.root_pass

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

# sql users
resource "google_sql_user" "users" {
  depends_on = [google_sql_database_instance.instances]
  for_each   = var.configs.users

  project  = var.project.name
  host     = each.value.host
  name     = each.value.name
  password = each.value.pass
  instance = google_sql_database_instance.instances[each.key].name
}

# sql databases
resource "google_sql_database" "databases" {
  depends_on = [google_sql_user.users]
  for_each   = var.configs.databases

  project   = var.project.name
  name      = each.value.name
  charset   = each.value.charset
  collation = each.value.collation
  instance  = google_sql_database_instance.instances[each.key].name
}
