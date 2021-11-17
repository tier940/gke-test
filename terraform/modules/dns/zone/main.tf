# private
resource "google_dns_managed_zone" "private" {
  for_each = var.private

  project    = var.project_id
  name       = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-${each.value.name}-${var.prefix}"
  dns_name   = each.value.dns_name
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = each.value.network
    }
  }
}

# public
resource "google_dns_managed_zone" "public" {
  for_each = var.public

  project    = var.project_id
  name       = "${var.tags.pj}-${var.tags.stage}-${var.tags.env}-${each.value.name}-${var.prefix}"
  dns_name   = each.value.dns_name
  visibility = "public"
}
