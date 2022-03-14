terraform {
  required_version = "1.0.11"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.11.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.13.0"
    }
  }
}
