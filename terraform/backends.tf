terraform {
  backend "gcs" {
    credentials = "../credentials/gcs_service_account.json"
    bucket      = "test-gke-331312"
  }
}
