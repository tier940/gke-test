locals {
  stages = {
    # 開発環境にのみ作成する場合
    dev = var.tags.stage == "dev"

    # 開発環境以外に作成する場合
    not_dev = var.tags.stage != "dev"

    # 検証環境にのみ作成する場合
    stg = var.tags.stage == "stg"

    # 検証環境以外に作成する場合
    not_stg = var.tags.stage != "stg"

    # 本番環境にのみ作成する場合
    prd = var.tags.stage == "prd"

    # 本番環境以外に作成する場合
    not_prd = var.tags.stage != "prd"
  }

  network = {
    id        = google_compute_network.default.id
    self_link = google_compute_network.default.self_link
  }
}



###################################
## API有効化
###################################
# boot
resource "google_project_service" "boot" {
  for_each = toset(var.gcp_services.boot)

  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = var.gcp_services.destroy
  disable_dependent_services = var.gcp_services.dependent
}

# default
resource "google_project_service" "default" {
  depends_on = [google_project_service.boot]
  for_each   = toset(var.gcp_services.list)

  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = var.gcp_services.destroy
  disable_dependent_services = var.gcp_services.dependent
}



###################################
## VPC
###################################
resource "google_compute_network" "default" {
  depends_on = [google_project_service.default]

  project                 = var.project_id
  name                    = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}"
  description             = "pj:${var.tags.pj}, stage:${var.tags.stage}, env:${var.tags.env}"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}



###################################
## Subnetwork
###################################
# main
module "subnetwork_main" {
  depends_on = [google_compute_network.default]
  source     = "./modules/vpc/subnetwork/main"
  for_each   = var.region_list

  project_id        = var.project_id
  network_id        = local.network.id
  prefix            = each.key
  region            = each.value
  tags              = var.tags
  subnet_cidr_block = var.subnet_cidr_block_main[each.key]
}

# other
module "subnetwork_other" {
  depends_on = [google_compute_network.default]
  source     = "./modules/vpc/subnetwork/other"
  for_each   = var.region_list

  project_id        = var.project_id
  network_id        = local.network.id
  prefix            = each.key
  region            = each.value
  tags              = var.tags
  subnet_cidr_block = var.subnet_cidr_block_other[each.key]
}



###################################
## Default firewall
###################################
resource "google_compute_firewall" "default" {
  depends_on = [google_compute_network.default]

  project     = var.project_id
  direction   = "EGRESS"
  name        = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-default"
  network     = local.network.self_link
  description = "Default firewall(pj:${var.tags.pj}, stage:${var.tags.stage}, env:${var.tags.env})"
  allow { protocol = "all" }
}



###################################
## Default global address
###################################
resource "google_compute_global_address" "default" {
  depends_on = [google_compute_network.default]

  project       = var.project_id
  name          = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-default"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = local.network.id
}
resource "google_service_networking_connection" "default" {
  depends_on = [google_compute_global_address.default]

  network                 = local.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
}



###################################
## GKE
###################################
# service account
module "gke_sa" {
  source   = "./modules/account"
  for_each = var.region_list

  project_id  = var.project_id
  account_id  = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-${var.gke_config[each.key].name}-${each.key}"
  description = "Service Account for gke node(${var.gke_config[each.key].name} on pj:${var.tags.pj}, stage:${var.tags.stage}, env:${var.tags.env})"
  roles       = ["roles/container.admin", "roles/iam.serviceAccountUser", "roles/storage.admin"]
}

# gke
module "gke" {
  depends_on = [
    module.gke_sa,
    module.subnetwork_other,
    google_compute_network.default
  ]
  source   = "./modules/gke"
  for_each = var.region_list

  tags       = var.tags
  project_id = var.project_id
  vpc_id     = local.network.id
  prefix     = each.key
  region     = each.value
  account    = module.gke_sa[each.key].email
  subnets    = module.subnetwork_other[each.key].subnets["gke"]
  source_fw  = [google_compute_firewall.default.name]
  configs    = var.gke_config[each.key]
}



###################################
## Cloud SQL
###################################
module "sql_instance" {
  depends_on = [google_compute_network.default]
  source     = "./modules/sql"
  for_each   = var.region_list

  tags       = var.tags
  project_id = var.project_id
  network    = local.network.self_link
  prefix     = each.key
  region     = each.value
  configs    = var.sql_config[each.key]
}



###################################
## Cloud DNS
###################################
# Record cloud sql
module "dns_record_sql" {
  depends_on = [module.dns_zone, module.sql_instance]
  source     = "./modules/dns/record"
  for_each   = var.region_list

  project_id = var.project_id
  zone       = module.dns_zone[each.key].private["internal"]
  name       = "sql"
  rrdatas    = [values(module.sql_instance[each.key].instances.private_ip)]
  type       = "A"
}
