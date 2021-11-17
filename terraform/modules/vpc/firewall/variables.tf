variable "project_id" { type = string }
variable "target_tags" { type = list(string) }
variable "target_tag_default" { type = string }
variable "network" { type = string }
variable "ingress" {
  type    = any
  default = {}
}
variable "egress" {
  type    = any
  default = {}
}
