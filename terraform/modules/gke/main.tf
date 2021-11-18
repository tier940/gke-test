locals {
  gke_name = "${var.tags.stage}-${var.tags.env}-${var.configs.name}-${var.prefix}"
  cluster  = { for key, value in var.configs.clusters : key => value if contains(var.configs.create_key, key) }
  node     = { for key, value in var.configs.nodes : key => value if contains(var.configs.create_key, key) }
}



###################################
## GKE Clusters
###################################
# master password
resource "random_string" "master_password" {
  for_each = local.cluster

  length  = 16
  special = false
}

# version settings
data "google_container_engine_versions" "default" {
  provider = google-beta
  for_each = local.cluster

  project        = var.project.id
  location       = var.region
  version_prefix = each.value.version
}

# create clusters
resource "google_container_cluster" "clusters" {
  provider = google-beta
  depends_on = [
    data.google_container_engine_versions.default,
    random_string.master_password
  ]
  for_each = local.cluster

  project            = var.project.id
  name               = "${local.gke_name}-${each.key}"
  location           = var.region
  node_locations     = each.value.zone
  node_version       = data.google_container_engine_versions.default[each.key].latest_node_version
  min_master_version = data.google_container_engine_versions.default[each.key].latest_master_version
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  network            = var.vpc_id
  subnetwork         = var.subnets.self_link

  addons_config {
    http_load_balancing {
      disabled = each.value.addons.load_balancing == true ? false : true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = each.value.addons.csi_driver == true ? true : false
    }
    # filestore.csi.storage.gke.io
    # https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/filestore-csi-driver
  }
  workload_identity_config {
    workload_pool = "${var.project.id}.svc.id.goog"
  }
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = each.value.authorized_cidr
      content {
        cidr_block   = cidr_blocks.value
        display_name = cidr_blocks.key
      }
    }
  }

  node_pool {
    node_config {
      service_account = var.account
      metadata = {
        disable-legacy-endpoints = true
      }
    }
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_pool
    ]
  }
}



###################################
## GKE Nodes
###################################
resource "google_container_node_pool" "nodes" {
  provider   = google-beta
  depends_on = [google_container_cluster.clusters]
  for_each   = local.node

  project            = var.project.id
  name               = each.key
  initial_node_count = each.value.size.init
  location           = google_container_cluster.clusters[each.key].location
  node_locations     = google_container_cluster.clusters[each.key].node_locations
  cluster            = google_container_cluster.clusters[each.key].name

  autoscaling {
    min_node_count = each.value.size.min
    max_node_count = each.value.size.max
  }
  management {
    auto_repair  = each.value.management.auto_repair
    auto_upgrade = each.value.management.auto_upgrade
  }
  upgrade_settings {
    max_surge       = each.value.upgrade.surge
    max_unavailable = each.value.upgrade.unavailable
  }
  node_config {
    service_account = var.account
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.root_volume
    image_type      = each.value.image_type
    tags            = flatten([var.source_fw, "gke-node-${local.gke_name}"])
    metadata = {
      disable-legacy-endpoints = true
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}
