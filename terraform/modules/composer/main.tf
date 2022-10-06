resource "google_composer_environment" "default" {
  project = var.project.id
  name    = "${var.tags.stage}-${var.tags.env}-${var.prefix}"
  region  = var.region
  config {
    software_config {
      image_version = var.config.version
      # airflow_config_overrides = var.config.software_config.airflow_config
      # pypi_packages            = var.config.software_config.pypi_packages
      # env_variables            = var.config.software_config.env_variables
    }

    workloads_config {
      scheduler {
        cpu        = var.config.workloads_config.scheduler.cpu
        memory_gb  = var.config.workloads_config.scheduler.memory_gb
        storage_gb = var.config.workloads_config.scheduler.storage_gb
        count      = var.config.workloads_config.scheduler.count
      }
      web_server {
        cpu        = var.config.workloads_config.web_server.cpu
        memory_gb  = var.config.workloads_config.web_server.memory_gb
        storage_gb = var.config.workloads_config.web_server.storage_gb
      }
      worker {
        cpu        = var.config.workloads_config.worker.cpu
        memory_gb  = var.config.workloads_config.worker.memory_gb
        storage_gb = var.config.workloads_config.worker.storage_gb
        min_count  = var.config.workloads_config.worker.min_count
        max_count  = var.config.workloads_config.worker.max_count
      }
    }
    environment_size = var.config.environment_size

    node_config {
      network         = var.network
      subnetwork      = var.subnetwork.self_link
      service_account = var.account
    }
  }
}
