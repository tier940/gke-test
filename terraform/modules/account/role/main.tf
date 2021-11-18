resource "google_project_iam_member" "default" {
  for_each = toset(var.iam.roles)

  project = var.project.id
  role    = each.key
  member  = "${var.iam.type}:${var.iam.name}"
}
