resource "google_compute_subnetwork" "other" {
  for_each = var.subnet_cidr_block

  project                  = var.project_id
  name                     = "${each.key}-${var.prefix}-${each.value.az}"
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  network                  = var.network_id
  private_ip_google_access = false
}
