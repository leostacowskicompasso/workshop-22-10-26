variable "environment" {
  description = "Friendly name/prefix for the environment."
  type        = string
  default     = "workshop"
}

variable "bucket_name" {
  description = "Name of the S3 bucket. A globally-unique name is auto-generated when empty."
  type        = string
  default     = ""
}

variable "bucket_prefix" {
  description = "Prefix used when auto-generating the bucket name."
  type        = string
  default     = "workshop"
}
