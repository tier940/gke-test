variable "project_id" { type = string }
variable "account_id" { type = string }
variable "description" {
  type    = string
  default = null
}
variable "roles" {
  type    = list(string)
  default = []
}
