#if ! gsutil ls | grep gs://$TF_STATE_BUCKET_NAME ;then gsutil mb -p $GCP_PROJECT_ID -l $RUN_REGION -b on gs://$TF_STATE_BUCKET_NAME;fi
#below block is used for the providers and storage for storing the state of the terraform
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.82.0"
    }
  }
 backend "gcs" {
   prefix  = "terraform/state"
 }
}

#This block will generate the zip file name with any random value
locals {
  cf_zip_archive_name = "cf-v${var.v_id}-${data.archive_file.zipfiles.output_sha}.zip"
  
  
}

#This block will zip all the code from the source directory
data "archive_file" "zipfiles" {
  type        = "zip"
  output_path = "$../zipfiles.zip"
  source_dir = "../cloudFuntion/"
}

#This will create the new bucket where all the 
resource "google_storage_bucket" "bucket" {
  name     = "zippedcode-bucket5878"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = local.cf_zip_archive_name
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.zipfiles.output_path
  #lifecycle {
  # prevent_destroy = true
  #}

}

resource "google_cloudfunctions_function" "function" {
  name        = "new-function2"
  description = "My function"
  runtime     = "python310"
  entry_point = "hello_world"

  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
 
  depends_on            = [
        google_storage_bucket.bucket,  # declared in `storage.tf`
        google_storage_bucket_object.archive
    ]

}
resource "google_firestore_document" "fireVersionDoc" {
  project = "${var.project_id}"
  collection  = "${var.v_id}"
  document_id = "cloudVersion-document"
  fields      = "{\"CFVersion\":{\"mapValue\":{\"fields\":{\"CloudBuildVersion\":{\"stringValue\":\"${var.v_id}\"}}}}}"
}
# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
