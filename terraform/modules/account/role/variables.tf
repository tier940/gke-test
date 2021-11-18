variable "project" { type = map(string) }
variable "iam" {
  type = object({
    name  = string
    type  = string
    roles = list(string)
  })
}
