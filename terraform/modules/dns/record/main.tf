resource "google_dns_record_set" "record" {
  project      = var.project_id
  name         = "${var.name}.${var.zone.dns_name}"
  managed_zone = var.zone.name
  type         = var.type
  ttl          = 300
  rrdatas      = flatten([var.rrdatas])
}
