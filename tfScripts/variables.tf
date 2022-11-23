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
variable "updated_time" {
  default = "2022-11-11T00:00:00.000Z"
}
variable "v_id" {
  default=1
}
variable "build_version" {
  default="1.0.0"
  description = "Version id of cloud function"
}

variable "generate_keys" {
  type        = bool
  description = "Generate keys for service accounts."
  default     = false
}

variable "display_name" {
  type        = string
  description = "Display names of the created service accounts (defaults to 'Terraform-managed service account')"
  default     = "Terraform-managed service account"
}

variable "description" {
  type        = string
  description = "Default description of the created service accounts (defaults to no description)"
  default     = ""
}

variable "descriptions" {
  type        = list(string)
  description = "List of descriptions for the created service accounts (elements default to the value of `description`)"
  default     = []
}
