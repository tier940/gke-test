variable "project" { type = map(string) }
variable "prefix" { type = string }
variable "tags" { type = map(string) }
variable "private" {
  type    = any
  default = {}
}
variable "public" {
  type    = any
  default = {}
}
