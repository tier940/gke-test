output "instances" {
  value = {
    id         = zipmap(keys(google_compute_instance.instances), values(google_compute_instance.instances)[*].instance_id)
    name       = zipmap(keys(google_compute_instance.instances), values(google_compute_instance.instances)[*].name)
    private_ip = zipmap(keys(google_compute_instance.instances), values(google_compute_instance.instances)[*].network_interface[0].network_ip)
    public_ip  = length(google_compute_address.static_public_ip) > 0 ? zipmap(keys(google_compute_address.static_public_ip), values(google_compute_address.static_public_ip)[*].address) : null
    zone       = zipmap(keys(google_compute_instance.instances), values(google_compute_instance.instances)[*].zone)
    tag        = "gce-${local.gce_name}"
  }
}
