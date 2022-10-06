resource "google_composer_environment" "default" {
  provider = google-beta
  for_each = var.config

  name   = "${var.tags.stage}-${var.tags.env}-${each.value.name}-${each.key}"
  region = var.region
  config {
    software_config {
      image_version   = each.value.version
      scheduler_count = 2 // only in Composer 1 with Airflow 2, use workloads_config in Composer 2
      # airflow_config_overrides = each.value.airflow_config
      # pypi_packages            = each.value.pypi_packages
      # env_variables            = each.value.env_variables
    }

    workloads_config {
      scheduler {
        cpu        = each.value.workloads_config.scheduler.cpu
        memory_gb  = each.value.workloads_config.scheduler.memory_gb
        storage_gb = each.value.workloads_config.scheduler.storage_gb
        count      = each.value.workloads_config.scheduler.count
      }
      web_server {
        cpu        = each.value.workloads_config.web_server.cpu
        memory_gb  = each.value.workloads_config.web_server.memory_gb
        storage_gb = each.value.workloads_config.web_server.storage_gb
      }
      worker {
        cpu        = each.value.workloads_config.worker.cpu
        memory_gb  = each.value.workloads_config.worker.memory_gb
        storage_gb = each.value.workloads_config.worker.storage_gb
        min_count  = each.value.workloads_config.worker.min_count
        max_count  = each.value.workloads_config.worker.max_count
      }
    }
    environment_size = each.value.environment_size

    node_config {
      network         = var.network
      subnetwork      = var.subnetwork
      service_account = var.account
    }
  }
}
