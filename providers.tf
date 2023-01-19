terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16.0"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.1.1"
    }
  }
  cloud {
    organization = "danielremery"
    workspaces {
      name = "aws-multi-spa"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
  access_key = data.doppler_secrets.this.map.AWS_ACCESS_KEY_ID
  secret_key = data.doppler_secrets.this.map.AWS_SECRET_ACCESS_KEY
}


provider "doppler" {
  doppler_token = var.doppler_service_token
}
data "doppler_secrets" "this" {}
