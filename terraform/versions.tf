terraform {
  required_version = "1.3.7"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.66.0"
    }
  }
}
