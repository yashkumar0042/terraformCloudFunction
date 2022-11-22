variable "project_id" {
  type        = string
  description = "The Google Cloud Project Id"
}

variable "region" {
  type    = string
  default = "us-central1"
}
variable "version_id" {
  default = "1.0"
}
