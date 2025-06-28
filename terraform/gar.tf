resource "google_artifact_registry_repository" "this" {
  location      = var.region
  repository_id = "${var.stack_prefix}-docker-repo-${var.env}"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "this" {
  project    = google_artifact_registry_repository.this.project
  location   = google_artifact_registry_repository.this.location
  repository = google_artifact_registry_repository.this.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke.email}"
}
