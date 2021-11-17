resource "google_service_account" "default" {
  project     = var.project_id
  account_id  = var.account_id
  description = var.description
}

resource "google_project_iam_member" "default" {
  for_each = var.roles != [null] ? toset(var.roles) : []

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.default.email}"
}
