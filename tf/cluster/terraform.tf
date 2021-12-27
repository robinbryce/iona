terraform {
  required_version = "~> 1.1.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.5.0"
    }
    google-beta = {
      source  = "hashicorp/google"
      version = "~> 4.5.0"
    }
  }

  backend "remote" {
    organization = "robinbryce"
    workspaces {
      name = "iona-cluster"
    }
  }
}
