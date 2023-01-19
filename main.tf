data "cloudflare_zone" "demery" {
  name = "demery.net"
}

resource "cloudflare_record" "aws_multi_spa" {
  zone_id = data.cloudflare_zone.demery.id
  name    = "aws-multi-spa"
  value   = aws_cloudfront_distribution.s3_distribution.domain_name
  type    = "CNAME"
}

locals {
  s3_origin_id = "aws-multi-spa-origin"
}

resource "aws_s3_bucket" "application_one" {
  bucket = "application-one"
}

resource "aws_s3_bucket" "application_two" {
  bucket = "application-two"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.application_one.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
