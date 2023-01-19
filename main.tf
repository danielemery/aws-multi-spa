resource "aws_cloudfront_origin_access_identity" "aws_multi_spa" {
  comment = "aws_multi_spa"
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

locals {
  s3_origin_id = "aws-multi-spa-origin"
}

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
  for_each = {
    application-fallback = "application-fallback"
  }
  bucket = each.key
  tags = {
    "index_folder" = "fallback"
  }
}

resource "aws_s3_bucket_policy" "public" {
  for_each = merge(aws_s3_bucket.applications, aws_s3_bucket.application_fallback)

  bucket = each.value.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${each.value.arn}/*",
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "website_bucket_configuration" {
  for_each = merge(aws_s3_bucket.applications, aws_s3_bucket.application_fallback)

  bucket = each.value.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "${each.value.tags_all.index_folder}/index.html"
  }
}


resource "aws_cloudfront_distribution" "s3_distribution" {

  dynamic "origin" {
    for_each = aws_s3_bucket_website_configuration.website_bucket_configuration
    content {
      domain_name = origin.value.website_endpoint
      origin_id   = origin.key

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3"]
      }
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

  dynamic "ordered_cache_behavior" {
    for_each = aws_s3_bucket.applications
    content {
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = ordered_cache_behavior.key
      path_pattern           = "/${ordered_cache_behavior.value.tags_all.index_folder}*"
      viewer_protocol_policy = "allow-all"

      forwarded_values {
        query_string = false

        cookies {
          forward = "none"
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "application-fallback"

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
