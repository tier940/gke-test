provider "google" {
  project     = "test-gke-331312"
  region      = "us-central1"
  credentials = "../credentials/terraform-deploy.json"
}
