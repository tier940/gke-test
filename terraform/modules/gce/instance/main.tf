locals {
  gce_name = "${var.tags.stage}-${var.tags.env}-${var.configs.name}-${var.prefix}"
}



###################################
## GCE instances
###################################
# secret manager
## from root-bastion project
data "google_secret_manager_secret_version" "default" {
  project = "root-bastion"
  secret  = "relightings_${var.tags.stage}_pub"
  version = 1
}

# create instances
resource "google_compute_instance" "instances" {
  depends_on = [
    data.google_secret_manager_secret_version.default,
    google_compute_address.static_public_ip
  ]
  for_each = var.configs.instance_ips

  project                   = var.project.id
  name                      = "${local.gce_name}-${each.key}"
  machine_type              = var.configs.machine_type
  zone                      = var.configs.zone[each.key]
  tags                      = flatten([var.source_fw, "gce-${local.gce_name}"])
  metadata_startup_script   = var.startup_script == null ? null : var.startup_script
  allow_stopping_for_update = true

  metadata = {
    "user-data"              = var.user_data == null ? null : var.user_data
    "serial-port-enable"     = "true"
    "block-project-ssh-keys" = "true"
    "ssh-keys"               = "${var.tags.stage_full}:${data.google_secret_manager_secret_version.default.secret_data}"
  }

  boot_disk {
    initialize_params {
      type  = var.configs.volume_type
      size  = var.configs.root_volume
      image = var.configs.image
    }
  }

  network_interface {
    network_ip = each.value
    subnetwork = var.public_subnets == null ? var.private_subnets[each.key].self_link : var.public_subnets[each.key].self_link

    dynamic "access_config" {
      for_each = google_compute_address.static_public_ip
      content {
        nat_ip       = access_config.value["address"]
        network_tier = "STANDARD"
      }
    }
  }

  scheduling {
    automatic_restart = false
  }

  service_account {
    email  = var.account
    scopes = ["cloud-platform"]
  }
}


###################################
## GCE instances static public ip
###################################
resource "google_compute_address" "static_public_ip" {
  for_each = var.configs.static_public_ip ? var.configs.instance_ips : {}

  project      = var.project.id
  name         = "static-${local.gce_name}-${each.key}"
  description  = "Static PublicIP for gce(${var.configs.name} on env:${var.tags.env}, stage:${var.tags.stage}-${each.key})"
  region       = var.public_subnets == null ? var.private_subnets[each.key].region : var.public_subnets[each.key].region
  network_tier = "STANDARD"
}
