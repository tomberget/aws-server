terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.0.0"
}

provider "aws" {
  region = var.region
}
