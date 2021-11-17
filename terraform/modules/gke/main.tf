locals {
  gke_name = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-${var.configs.name}-${var.prefix}"
  cluster  = { for key, value in var.configs.clusters : key => value if contains(var.configs.create_key, key) }
  node     = { for key, value in var.configs.nodes : key => value if contains(var.configs.create_key, key) }
  kubename = "gke_${var.project_id}"
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
  for_each = local.cluster
  #provider = google-beta

  project        = var.project_id
  location       = var.region
  version_prefix = each.value.version
}

# create clusters
resource "google_container_cluster" "clusters" {
  depends_on = [
    data.google_container_engine_versions.default,
    random_string.master_password
  ]
  for_each = local.cluster
  #provider   = google-beta

  project                  = var.project_id
  name                     = "${local.gke_name}-${each.key}"
  location                 = var.region
  node_locations           = each.value.zone
  node_version             = data.google_container_engine_versions.default[each.key].latest_node_version
  min_master_version       = data.google_container_engine_versions.default[each.key].latest_master_version
  remove_default_node_pool = true
  initial_node_count       = 1
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  network                  = var.vpc_id
  subnetwork               = var.subnets.self_link

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
  master_auth {
    username = "admin"
    password = random_string.master_password[each.key].result

    client_certificate_config {
      issue_client_certificate = true
    }
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
  depends_on = [google_container_cluster.clusters]
  for_each   = local.node
  #provider = google-beta

  project            = var.project_id
  name               = "${local.gke_name}-${each.key}"
  initial_node_count = each.value.size.init
  location           = google_container_cluster.clusters[each.key].location
  node_locations     = google_container_cluster.clusters[each.key].node_locations
  cluster            = google_container_cluster.clusters[each.key].name

  autoscaling {
    min_node_count = each.value.size.min
    max_node_count = each.value.size.max
  }
  management {
    auto_repair  = true
    auto_upgrade = false
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



###################################
## Output gke cluster configs
###################################
# client key
resource "local_file" "k8sconfig_client_key" {
  depends_on = [google_container_cluster.clusters]
  for_each   = local.cluster

  filename = "${path.cwd}/k8s/.configs/k8sconfig-client-key-${google_container_cluster.clusters[each.key].name}.key"
  content  = base64decode(google_container_cluster.clusters[each.key].master_auth[0].client_key)
}

# client certificate
resource "local_file" "k8sconfig_client_certificate" {
  depends_on = [google_container_cluster.clusters]
  for_each   = local.cluster

  filename = "${path.cwd}/k8s/.configs/k8sconfig-client-certificate-${google_container_cluster.clusters[each.key].name}.pem"
  content  = base64decode(google_container_cluster.clusters[each.key].master_auth[0].client_certificate)
}

# cluster ca certificate
resource "local_file" "k8sconfig_cluster_ca_certificate" {
  depends_on = [google_container_cluster.clusters]
  for_each   = local.cluster

  filename = "${path.cwd}/k8s/.configs/k8sconfig-cluster-ca-certificate-${google_container_cluster.clusters[each.key].name}.pem"
  content  = base64decode(google_container_cluster.clusters[each.key].master_auth[0].cluster_ca_certificate)
}

# kubeconfig
resource "local_file" "k8sconfig" {
  depends_on = [google_container_cluster.clusters]
  for_each   = local.cluster

  filename = "./k8s/.configs/k8sconfig-${local.gke_name}"
  content  = <<KUBECONFIG
apiVersion: v1
clusters:
%{for key in var.configs.create_key~}
- cluster:
    certificate-authority-data: ${google_container_cluster.clusters[each.key].master_auth[0].cluster_ca_certificate}
    server: https://${google_container_cluster.clusters[each.key].endpoint}
  name: ${local.kubename}_${var.region}_${google_container_cluster.clusters[each.key].name}
%{endfor~}
contexts:
%{for key in var.configs.create_key~}
- context:
    cluster: ${local.kubename}_${var.region}_${google_container_cluster.clusters[each.key].name}
    user: ${local.kubename}_${var.region}_${google_container_cluster.clusters[each.key].name}
  name: ${key}
%{endfor~}
current-context:
kind: Config
preferences: {}
users:
%{for key in var.configs.create_key~}
- name: ${local.kubename}_${var.region}_${google_container_cluster.clusters[each.key].name}
  user:
    client-certificate: ${path.cwd}/k8s/.configs/k8sconfig-client-certificate-${google_container_cluster.clusters[each.key].name}.pem
    client-key: ${path.cwd}/k8s/.configs/k8sconfig-client-key-${google_container_cluster.clusters[each.key].name}.key
    password: ${random_string.master_password[each.key].result}
    username: ${google_container_cluster.clusters[each.key].master_auth[0].username}
%{endfor~}
KUBECONFIG
}
