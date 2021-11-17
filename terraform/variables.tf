variable "tags" { type = map(string) }
variable "cloudflare_config" {
  type = object({
    zone_id = string
    email   = string
    api_key = string
  })
}
variable "gcp_services" {
  type = object({
    destroy   = bool
    dependent = bool
    boot      = list(string)
    list      = list(string)
  })
}
variable "region_list" { type = map(string) }
variable "project_id" { type = string }

variable "subnet_cidr_block_main" {
  type = map(object({
    public  = map(map(string))
    private = map(map(string))
  }))
}
variable "subnet_cidr_block_other" {
  type = map(object({
    gke = map(string)
  }))
}

variable "gce_config" {
  type = any
}
variable "cloud_init" {
  type = string
}

variable "gke_config" {
  type = any
}

variable "sql_config" {
  type = map(object({
    name                = string
    disk_size           = number
    disk_autoresize     = bool
    deletion_protection = bool
    instances = map(object({
      type    = string
      version = string
      vaccess = string
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
