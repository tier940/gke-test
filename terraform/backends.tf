terraform {
  backend "gcs" {
    credentials = "../credentials/terraform-gcs.json"
    bucket      = "test-gke-331312"
  }
}
