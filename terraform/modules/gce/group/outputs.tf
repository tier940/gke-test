output "instances" {
  value = {
    tag = "gce-${local.gce_name}"
  }
}
