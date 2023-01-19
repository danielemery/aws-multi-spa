# AWS Multiple SPA

Example deploying multiple SPAs on the same domain in S3 buckets behind cloudfront.

# Includes
- terraform config to create the buckets, cloudfront, dns entries etc
- example vite spa app to deploy multiple copies of

# Usage

## Terraform

1. Initialise terraform
   ```sh
   terraform init
   ```
2. Create the secrets file (the service token can be retrieved from the `home-lab` doppler project project where it has been provisioned by the [home-lab-access-tokens](https://github.com/danielemery/home-lab-access-tokens) terraform project)
   ```
   # ./secrets.tfvars
   doppler_service_token = "service_token"
   ```
3. Apply!
   ```sh
   terraform apply -var-file="secrets.tfvars"
   ```
