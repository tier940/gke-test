locals {
  # VPC設定値
  network = {
    id        = google_compute_network.default.id
    self_link = google_compute_network.default.self_link
  }

  # 初期サービスアカウント
  default_sa = {
    gce = "${var.project.name}@appspot.gserviceaccount.com"
  }
}



###################################
## API有効化
###################################
# boot
resource "google_project_service" "boot" {
  for_each = toset(var.gcp_services.boot)

  project                    = var.project.id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

# default
resource "google_project_service" "default" {
  depends_on = [google_project_service.boot]
  for_each   = toset(var.gcp_services.list)

  project                    = var.project.id
  service                    = each.key
  disable_on_destroy         = var.gcp_services.destroy
  disable_dependent_services = var.gcp_services.dependent
}



###################################
## VPC
###################################
resource "google_compute_network" "default" {
  depends_on = [google_project_service.default]

  project                 = var.project.id
  name                    = "${var.tags.stage}-${var.tags.env}"
  description             = "stage:${var.tags.stage}, env:${var.tags.env}"
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

  project           = var.project
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

  project           = var.project
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

  project     = var.project.id
  direction   = "EGRESS"
  name        = "${var.tags.stage}-${var.tags.env}-default"
  network     = local.network.self_link
  description = "Default firewall(stage:${var.tags.stage}, env:${var.tags.env})"
  allow { protocol = "all" }
}



###################################
## Default global address
###################################
resource "google_compute_global_address" "default" {
  depends_on = [google_compute_network.default]

  project       = var.project.id
  name          = "${var.tags.stage}-${var.tags.env}-default"
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
## GCE
###################################
# service account for config
module "gce_config_sa" {
  depends_on = [module.subnetwork_main]
  source     = "./modules/account"
  for_each   = var.region_list

  project     = var.project
  account_id  = "${var.tags.stage}-${var.tags.env}-${var.gce_config[each.key].config.name}-${each.key}"
  description = "Service Account for gce(${var.gce_config[each.key].config.name} on stage:${var.tags.stage}, env:${var.tags.env})"
}

# account role
module "gce_config_role" {
  depends_on = [module.gce_config_sa]
  source     = "./modules/account/role"
  for_each   = var.region_list

  project = var.project
  iam = {
    name  = module.gce_config_sa[each.key].email
    type  = "serviceAccount"
    roles = ["roles/secretmanager.secretAccessor"]
  }
}

# gce config
module "gce_config" {
  depends_on = [module.gce_config_role]
  source     = "./modules/gce/instance"
  for_each   = var.region_list

  tags            = var.tags
  project         = var.project
  vpc_id          = local.network.id
  network         = local.network.self_link
  private_subnets = module.subnetwork_main[each.key].private_subnets
  prefix          = each.key
  region          = each.value
  account         = module.gce_config_sa[each.key].email
  configs         = var.gce_config[each.key].config
  source_fw       = [google_compute_firewall.default.name]
  startup_script  = var.cloud_init
  user_data       = <<-USERDATA
    #cloud-config
    packages:
      - git
      - ansible
    runcmd:
      - echo -e "\tStrictHostKeyChecking no" >> /etc/ssh/ssh_config
  USERDATA
}



###################################
## GKE
###################################
# service account
module "gke_sa" {
  depends_on = [module.subnetwork_other]
  source     = "./modules/account"
  for_each   = var.region_list

  project     = var.project
  account_id  = "${var.tags.stage}-${var.tags.env}-${var.gke_config[each.key].name}-${each.key}"
  description = "Service Account for gke node(${var.gke_config[each.key].name} on stage:${var.tags.stage}, env:${var.tags.env})"
}

# account role
module "gke_sa_role" {
  depends_on = [module.gke_sa]
  source     = "./modules/account/role"
  for_each   = var.region_list

  project = var.project
  iam = {
    name = module.gke_sa[each.key].email
    type = "serviceAccount"
    roles = [
      "roles/container.admin",
      "roles/iam.serviceAccountUser",
      "roles/file.editor"
    ]
  }
}

# cluster
module "gke" {
  depends_on = [module.gke_sa_role]
  source     = "./modules/gke"
  for_each   = var.region_list

  tags      = var.tags
  project   = var.project
  vpc_id    = local.network.id
  prefix    = each.key
  region    = each.value
  account   = module.gke_sa[each.key].email
  subnets   = module.subnetwork_other[each.key].subnets["gke"]
  source_fw = [google_compute_firewall.default.name]
  configs   = var.gke_config[each.key]
}



# ###################################
# ## Cloud SQL
# ###################################
# module "sql_instance" {
#   depends_on = [
#     module.subnetwork_main,
#     google_service_networking_connection.default
#   ]
#   source   = "./modules/sql"
#   for_each = var.region_list

#   tags    = var.tags
#   project = var.project
#   network = local.network.self_link
#   prefix  = each.key
#   region  = each.value
#   configs = var.sql_config[each.key]
# }



###################################
## GCE firewall
###################################
# config
module "gce_config_firewall" {
  depends_on = [module.gce_config]
  source     = "./modules/vpc/firewall"
  for_each   = var.region_list

  project            = var.project
  target_tags        = [module.gce_config[each.key].instances.tag]
  target_tag_default = google_compute_firewall.default.name
  network            = local.network.self_link
  ingress = {
    ssh = { name = "gce-config-${each.key}-ssh", cidrs = ["0.0.0.0/0"], ports = [22], desc = "Allow from core_config" }
  }
}



# ###################################
# ## Cloud DNS
# ###################################
# # zone
# module "dns_zone" {
#   source   = "./modules/dns/zone"
#   for_each = var.region_list

#   tags    = var.tags
#   project = var.project
#   prefix  = each.key
#   private = {
#     internal = { name = "internal", dns_name = "vpc.internal.", network = google_compute_network.default.id }
#   }
# }

# # Record cloud sql
# module "dns_record_sql" {
#   depends_on = [module.dns_zone, module.sql_instance]
#   source     = "./modules/dns/record"
#   for_each   = var.region_list

#   project = var.project
#   zone    = module.dns_zone[each.key].private["internal"]
#   name    = "sql"
#   rrdatas = [values(module.sql_instance[each.key].instances.private_ip)]
#   type    = "A"
# }
