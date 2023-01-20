# AWS Multiple SPA

Example deploying multiple SPAs on the same domain in S3 buckets.

It makes use of the error fallback page feature of static website hosting of S3 rather than the "magic-cloudfront-s3" link. This is because each SPA needs to specify it's own index.html as a 404 fallback.

Currently hosted at http://d2jydt75pcq64z.cloudfront.net (subject to change or remove).

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
