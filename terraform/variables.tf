variable "tags" { type = map(string) }
variable "project" { type = map(string) }
variable "gcp_services" {
  type = object({
    destroy   = bool
    dependent = bool
    boot      = list(string)
    list      = list(string)
  })
}
variable "region_list" { type = map(string) }

variable "subnet_cidr_block_main" { type = map(map(map(map(string)))) }
variable "subnet_cidr_block_other" { type = map(map(map(string))) }

variable "gce_config" {
  type = map(map(object({
    name             = string
    dns_name         = string
    machine_type     = string
    root_volume      = number
    volume_type      = string
    image            = string
    static_public_ip = bool
    zone             = map(string)
    instance_ips     = map(string)
  })))
}
variable "cloud_init" { type = string }

variable "gke_config" { type = any }

variable "sql_config" {
  type = map(object({
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
    flags = map(object({
      name  = string
      value = string
    }))
    maintenance_window = object({
      day  = number
      hour = number
    })
  }))
}
