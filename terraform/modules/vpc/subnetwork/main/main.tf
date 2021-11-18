# public
resource "google_compute_subnetwork" "public" {
  for_each = var.subnet_cidr_block.public

  project                  = var.project.id
  name                     = "public-${var.prefix}-${each.value.az}"
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  network                  = var.network_id
  private_ip_google_access = false
}

# private
resource "google_compute_subnetwork" "private" {
  for_each = var.subnet_cidr_block.private

  project                  = var.project.id
  name                     = "private-${var.prefix}-${each.value.az}"
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  network                  = var.network_id
  private_ip_google_access = true
}
