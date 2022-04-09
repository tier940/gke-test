terraform {
  backend "gcs" {
    credentials = "../credentials/terraform-gcs.json"
    bucket      = "sandbox-346202"
    prefix      = "test-gke"
  }
}
