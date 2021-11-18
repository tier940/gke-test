# ingress
resource "google_compute_firewall" "ingress" {
  for_each = var.ingress

  project       = var.project.name
  direction     = "INGRESS"
  name          = each.value.name
  target_tags   = lookup(each.value, "target_tags", [var.target_tag_default])
  network       = var.network
  description   = lookup(each.value, "desc", null)
  source_ranges = lookup(each.value, "cidrs", null)
  source_tags   = lookup(each.value, "src_tags", null)
  allow {
    protocol = lookup(each.value, "protocol", "tcp")
    ports    = lookup(each.value, "ports", null)
  }
}

# egress
resource "google_compute_firewall" "egress" {
  for_each = var.egress

  project       = var.project.name
  direction     = "EGRESS"
  name          = each.value.name
  target_tags   = lookup(each.value, "target_tags", [var.target_tag_default])
  network       = var.network
  description   = lookup(each.value, "desc", null)
  source_ranges = lookup(each.value, "cidrs", null)
  source_tags   = lookup(each.value, "src_tags", null)
  allow {
    protocol = lookup(each.value, "protocol", "tcp")
    ports    = lookup(each.value, "ports", null)
  }
}
