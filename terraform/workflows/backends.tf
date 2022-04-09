terraform {
  backend "gcs" {
    bucket = "sandbox-346202"
    prefix = "test-gke"
  }
}
