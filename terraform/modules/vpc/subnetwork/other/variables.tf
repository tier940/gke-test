variable "project_id" { type = string }
variable "network_id" { type = string }
variable "prefix" { type = string }
variable "region" { type = string }
variable "tags" { type = map(string) }
variable "subnet_cidr_block" {
  type = map(object({
    az   = string
    cidr = string
  }))
}
