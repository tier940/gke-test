resource "google_network_management_connectivity_test" "instance-test" {
  name = "conn-test-instances"
  source {
    instance = google_compute_instance.source.id
  }

  destination {
    instance = google_compute_instance.destination.id
  }

  protocol = "TCP"
}
