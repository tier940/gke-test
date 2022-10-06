variable "tags" { type = map(string) }
variable "project" { type = map(string) }
variable "prefix" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = any }
variable "account" { type = string }
variable "config" { type = any }
