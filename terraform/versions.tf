terraform {
  required_version = "1.1.8"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.2"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.16.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.16.0"
    }
  }
}
