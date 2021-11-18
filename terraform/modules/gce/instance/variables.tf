variable "tags" { type = map(string) }
variable "project" { type = map(string) }
variable "vpc_id" { type = string }
variable "network" { type = string }
variable "prefix" { type = string }
variable "region" { type = string }
variable "account" { type = string }
variable "public_subnets" { default = null }
variable "private_subnets" { default = null }
variable "configs" {
  type = object({
    name             = string
    machine_type     = string
    root_volume      = number
    volume_type      = string
    image            = string
    static_public_ip = bool
    instance_ips     = map(string)
    zone             = map(string)
  })
}
variable "source_fw" { type = list(string) }
variable "startup_script" {
  type    = string
  default = null
}
variable "user_data" {
  type    = string
  default = null
}
