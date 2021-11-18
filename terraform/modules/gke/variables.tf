variable "tags" { type = map(string) }
variable "project" { type = map(string) }
variable "vpc_id" { type = string }
variable "prefix" { type = string }
variable "region" { type = string }
variable "account" { type = string }
variable "subnets" { type = any }
variable "source_fw" { type = list(string) }
variable "configs" {
  type = object({
    name       = string
    create_key = list(string)
    online_key = list(string)
    clusters = map(object({
      version         = string
      zone            = list(string)
      addons          = map(bool)
      authorized_cidr = map(string)
    }))
    nodes = map(object({
      image_type   = string
      machine_type = string
      root_volume  = number
      size         = map(number)
      upgrade      = map(number)
      management   = map(bool)
    }))
  })
}
