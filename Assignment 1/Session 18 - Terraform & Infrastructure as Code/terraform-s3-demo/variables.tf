variable "aws_region" {
  description = "Target AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Unique naming prefix for the S3 bucket"
  type        = string
  default     = "scaler-devops-24bcs10090"
}

variable "environment" {
  description = "Deployment target environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_versioning" {
  description = "Enable S3 object versioning"
  type        = bool
  default     = true
}

variable "lifecycle_expiration_days" {
  description = "Number of days before temporary objects transition to Glacier or expire"
  type        = number
  default     = 90
}
