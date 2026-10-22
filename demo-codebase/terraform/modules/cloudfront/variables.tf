variable "environment" {
  description = "Friendly name/prefix for the environment."
  type        = string
  default     = "workshop"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to serve as origin."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket to serve as origin."
  type        = string
}
