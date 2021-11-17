output "ingress" {
  value = google_compute_firewall.ingress
}

output "egress" {
  value = google_compute_firewall.egress
}
