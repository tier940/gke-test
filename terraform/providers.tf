provider "google" {
  credentials = "../credentials/terraform-deploy.json"
  project     = "test-gke-331312"
  region      = "us-central1"
}
