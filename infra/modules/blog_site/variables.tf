variable "zone_name" {
  type        = string
  description = "Route 53 hosted zone name (must end with a dot), e.g. harry-sivasambu.com."
}

variable "domain_name" {
  type        = string
  description = "Fully-qualified domain name for the blog, e.g. blog.harry-sivasambu.com"
}

variable "bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name for the blog site"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
