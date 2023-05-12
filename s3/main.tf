resource "aws_cloudfront_origin_access_identity" "cloudfront_oai" {
  comment = "${var.bucket_name}_resources_access"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket_data.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oai.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.bucket_data.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "bucket_data" {
  bucket = var.bucket_name
  acl    = var.bucket_acl == null ? "private" : var.bucket_acl
  versioning {
    enabled = var.bucket_versioning == null ? true : var.bucket_versioning
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = var.default_tags

}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_blocking" {
  bucket = aws_s3_bucket.bucket_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_data_policy" {
  bucket = aws_s3_bucket.bucket_data.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}


locals {
  s3_bucket_origin = var.bucket_name
}

resource "aws_cloudfront_distribution" "cf_s3_distribution" {
  count = var.enable_cf_distribution == true ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.bucket_data.bucket_regional_domain_name
    origin_id   = local.s3_bucket_origin

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = var.is_enable_ipv6 == null ? false : var.is_enable_ipv6
  comment             = var.cf_distribution_comment
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_bucket_origin

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

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_bucket_origin

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_page_response
    content {
      error_code            = custom_error_response.value["error_code"]
      response_code         = custom_error_response.value["response_code"]
      error_caching_min_ttl = custom_error_response.value["error_caching_min_ttl"]
      response_page_path    = custom_error_response.value["response_page_path"]
    }
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_bucket_origin

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_All"

  viewer_certificate {
    cloudfront_default_certificate = lookup(var.cf_certificate_config, "default_certificate", null)
    acm_certificate_arn            = lookup(var.cf_certificate_config, "acm_certificate_arn", null)
    minimum_protocol_version       = lookup(var.cf_certificate_config, "minimum_protocol_version", null)
    ssl_support_method             = lookup(var.cf_certificate_config, "ssl_support_method", null)
  }

  aliases = var.cf_aliases

  tags = var.default_tags
}
