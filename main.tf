resource "aws_cloudfront_origin_access_identity" "aws_multi_spa" {
  comment = "aws_multi_spa"
}

locals {
  s3_origin_id = "aws-multi-spa-origin"
  all_buckets  = merge(aws_s3_bucket.applications, { "application_fallback" = aws_s3_bucket.application_fallback })
}

data "aws_iam_policy_document" "read_aws_multi_spa_bucket" {
  for_each = aws_s3_bucket.applications

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${each.value.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.aws_multi_spa.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [each.value.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.aws_multi_spa.iam_arn]
    }
  }
}

data "aws_iam_policy_document" "read_aws_multi_spa_bucket_fallback" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.application_fallback.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.aws_multi_spa.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.application_fallback.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.aws_multi_spa.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "read_aws_multi_spa_bucket" {
  bucket = aws_s3_bucket.application_fallback.id
  policy = data.aws_iam_policy_document.read_aws_multi_spa_bucket_fallback.json
}

# resource "aws_iam_policy" "read_aws_multi_spa_bucket" {
#   for_each = data.aws_iam_policy_document.read_aws_multi_spa_bucket
#   name = "${each.key}-read_aws_multi_spa_bucket"
#   path = "/"
#   policy = each.value.json
# }

resource "aws_s3_bucket" "applications" {
  for_each = {
    application-one = "app-one"
    application-two = "app-two"
  }
  bucket = each.key
  tags = {
    "index_folder" = each.value
  }
}

resource "aws_s3_bucket" "application_fallback" {
  bucket = "application-fallback"
  tags = {
    "index_folder" = "fallback"
  }
}
# resource "aws_s3_bucket_policy" "public" {
#   for_each = local.all_buckets

#   bucket = each.value.id
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "PublicReadGetObject",
#         "Effect" : "Allow",
#         "Principal" : "*",
#         "Action" : "s3:GetObject",
#         "Resource" : "${each.value.arn}/*",
#       }
#     ]
#   })
# }

resource "aws_cloudfront_distribution" "s3_distribution_fallback" {

  aliases = ["multi-spa.hermanns.pro"]
  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:880809221583:certificate/5b9acdcb-a338-49a3-9e82-57c31fbfee13"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  origin {
    domain_name = aws_s3_bucket.application_fallback.bucket_domain_name
    origin_id   = aws_s3_bucket.application_fallback.bucket_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.aws_multi_spa.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["DE"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.application_fallback.bucket_domain_name

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

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/${aws_s3_bucket.application_fallback.tags_all.index_folder}/index.html"
  }
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  for_each = aws_s3_bucket.applications

  aliases = ["multi-spa.hermanns.pro"]
  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:880809221583:certificate/5b9acdcb-a338-49a3-9e82-57c31fbfee13"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  origin {
    domain_name = each.value.bucket_domain_name
    origin_id   = each.key
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.aws_multi_spa.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["DE"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = each.key

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

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/${each.value.tags_all.index_folder}/index.html"
  }
}

data "cloudflare_zone" "website_zone" {
  name = "hermanns.pro"
}

resource "cloudflare_record" "website_record" {
  zone_id = data.cloudflare_zone.website_zone.id
  name    = "multi_spa"
  value   = aws_cloudfront_distribution.s3_distribution_fallback.domain_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "website_flexible_ssl" {
  zone_id = data.cloudflare_zone.website_zone.id
  target  = "multi_spa.hermanns.pro/*"
  actions {
    ssl = "flexible"
  }
}
