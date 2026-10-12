terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "raw" {
  name                        = var.bucket_name
  location                    = "US-CENTRAL1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [encryption]
  }
}

locals {
  capas = toset(["bronze", "silver", "gold"])
}

resource "google_bigquery_dataset" "capas" {
  for_each   = local.capas
  dataset_id = each.key
  location   = var.region

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "pipeline" {
  account_id   = "pipeline-accidentalidad"
  display_name = "pipeline-accidentalidad"
}

locals {
  roles_proyecto = toset(["roles/bigquery.dataEditor", "roles/bigquery.jobUser"])
}

resource "google_project_iam_member" "pipeline_proyecto" {
  for_each = local.roles_proyecto
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_storage_bucket_iam_member" "pipeline_bucket" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline.email}"
}