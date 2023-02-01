# AWS Multiple SPA

__Failed POC - this project was attempting to achieve it's result without falling back to cloudfront functions or similar. Unfortunately no complete solution was found - the solution documented below was a close as possible (it works but when serving the index at a front-end route will return a 404 status code with it).__

__The project that required this is now using [cloudfront functions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html) to achieve this instead.__

Example deploying multiple SPAs on the same domain in S3 buckets.

It makes use of the error fallback page feature of static website hosting of S3 rather than the "magic-cloudfront-s3" link. This is because each SPA needs to specify it's own index.html as a 404 fallback.

## Includes

- terraform config to create the buckets and cloudfront distribution
- example vite spa app to deploy multiple copies of
- Fallback plain html page when no routes match
- `<FlexLink>` component to allow local routing where applicable

## Doesn't Include

- Bucket suitable for prod (currently public)
- DNS
- SSL

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

## Vite

In order to test multiple spas on one domain we use the same vite app built with different environment variables.

```sh
cd viteapp

pnpm run build-prod

# Manually upload "app-one" folder in the "application-one" bucket
# Manually upload "app-two" folder in the "application-two" bucket
```
