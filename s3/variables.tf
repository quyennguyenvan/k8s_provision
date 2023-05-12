variable "bucket_name" {
  type        = string
  description = "the name of bucket, must unique in global"
}

variable "default_tags" {
  type        = map(string)
  description = "The key values of tags"
}

variable "enable_cf_distribution" {
  type        = bool
  description = "enable or disable using distribution for s3 bucket"
}

variable "is_enable_ipv6" {
  type        = bool
  description = "enable ipv6 for cloudfront"
}

variable "cf_distribution_comment" {
  type        = string
  description = "the comment for distribution"
  default     = "no comment for this"
}


variable "bucket_acl" {
  type        = string
  description = "the acl of bucket"
}

variable "bucket_versioning" {
  type        = bool
  description = "the config to bucket versioning"
}

variable "cloudfront_custom_error_page_response" {
  type = list(any)
  default = [
    # {
    #   error_code            = 400
    #   response_code         = 400
    #   error_caching_min_ttl = 10
    #   response_page_path    = "/index.html"
    # },
    # {
    #   error_code            = 401
    #   response_code         = 401
    #   error_caching_min_ttl = 10
    #   response_page_path    = "/index.html"
    # },
    # {
    #   error_code            = 403
    #   response_code         = 403
    #   error_caching_min_ttl = 10
    #   response_page_path    = "/index.html"
    # },
    {
      error_code            = 404
      response_code         = 200
      error_caching_min_ttl = 300
      response_page_path    = "/index.html"
    }
  ]
}

variable "cf_aliases" {
  type    = list(string)
  default = null
}

variable "cf_certificate_config" {
  type    = map(any)
  default = {}
}
