terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.82.0"
    }
  }
 backend "gcs" {
   bucket  = "test-bucket5878"
   prefix  = "terraform/state"
 }
}
provider "google" {
  project = "${var.project_id}"
  region  = "us-central1"
}

data "archive_file" "zipfiles" {
  type        = "zip"
  output_path = "$../zipfiles.zip"
  source_dir = "../cloudFuntion/"
}

resource "google_storage_bucket" "bucket" {
  name     = "test-bucket5878"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.zipfiles.output_path
}

resource "google_cloudfunctions_function" "function" {
  name        = "new-function"
  description = "My function"
  runtime     = "python310"

  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
 
}
# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
