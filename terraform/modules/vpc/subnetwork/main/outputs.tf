output "public_subnets" {
  value = zipmap(keys(google_compute_subnetwork.public), values(google_compute_subnetwork.public)[*])
}

output "private_subnets" {
  value = zipmap(keys(google_compute_subnetwork.private), values(google_compute_subnetwork.private)[*])
}
