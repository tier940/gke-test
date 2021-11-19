output "subnets" {
  value = zipmap(keys(google_compute_subnetwork.other), values(google_compute_subnetwork.other)[*])
}
