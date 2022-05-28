terraform {
  required_version = "1.0.11"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.2.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.20.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.17.0"
    }
  }
}
