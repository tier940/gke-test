locals {
  gce_name = "${var.tags.stage}-${var.tags.env}-${var.configs.name}-${var.prefix}"
}



###################################
## GCE instances template
###################################
# secret manager
## from root-bastion project
data "google_secret_manager_secret_version" "default" {
  project = "root-bastion"
  secret  = "relightings_${var.tags.stage}_pub"
  version = 1
}

# create instances template
resource "google_compute_instance_template" "instances" {
  depends_on = [data.google_secret_manager_secret_version.default]

  project                 = var.project.name
  name                    = local.gce_name
  machine_type            = var.configs.machine_type
  tags                    = flatten([var.source_fw, "gce-${local.gce_name}"])
  metadata_startup_script = var.startup_script == null ? null : var.startup_script

  metadata = {
    "user-data"              = var.user_data == null ? null : var.user_data
    "serial-port-enable"     = "true"
    "block-project-ssh-keys" = "true"
    "ssh-keys"               = "${var.tags.stage_full}:${data.google_secret_manager_secret_version.default.secret_data}"
  }

  disk {
    disk_type    = var.configs.volume_type
    source_image = var.configs.image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = "${var.tags.stage}-${var.tags.env}"
    subnetwork = var.public_subnets == null ? var.private_subnets.self_link : var.public_subnets.self_link
  }

  service_account {
    email  = var.account
    scopes = ["cloud-platform"]
  }
}

#
resource "google_compute_region_instance_group_manager" "instances" {
  project                   = var.project.name
  name                      = local.gce_name
  base_instance_name        = local.gce_name
  region                    = "asia-northeast1"
  distribution_policy_zones = ["asia-northeast1-a", "asia-northeast1-b", "asia-northeast1-c"]
  target_size               = 1

  version {
    instance_template = google_compute_instance_template.instances.id
  }

  update_policy {
    type                         = "OPPORTUNISTIC"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 3
    max_unavailable_fixed        = 3
    min_ready_sec                = 60
  }
}
