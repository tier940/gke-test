variable "project" { type = map(string) }
variable "network" { type = any }
variable "prefix" { type = string }
variable "region" { type = string }
variable "configs" {
  type = object({
    name                = string
    disk_size           = number
    disk_autoresize     = bool
    deletion_protection = bool
    instances = map(object({
      type      = string
      version   = string
      root_pass = string
    }))
    databases = map(object({
      name      = string
      charset   = string
      collation = string
    }))
    users = map(object({
      host = string
      name = string
      pass = string
    }))
    maintenance_window = object({
      day  = number
      hour = number
    })
    flags = map(object({
      name  = string
      value = string
    }))
  })
}
variable "tags" { type = map(string) }
