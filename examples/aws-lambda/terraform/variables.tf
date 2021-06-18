variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "image_tag" {
  type        = string
  description = "The version tag to the container image"
  default     = "latest"
}

variable "secret" {
  type        = string
  description = "Secret String"
  default     = "nihao"
}

### KMS

variable "encrypted_password" {
  type        = string
  description = "KMS Encrypted Password"
}

### NOTES: kms > environment variable > terraform decrypt and pass it as a new environment variable
