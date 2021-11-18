output "instances" {
  value = {
    private_ip = zipmap(keys(google_sql_database_instance.instances), values(google_sql_database_instance.instances)[*].private_ip_address)
    public_ip  = zipmap(keys(google_sql_database_instance.instances), values(google_sql_database_instance.instances)[*].public_ip_address)
  }
}
