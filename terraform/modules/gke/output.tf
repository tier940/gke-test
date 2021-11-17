output "clusters" {
  value = {
    name           = { for key, value in google_container_cluster.clusters : key => value.name }
    location       = { for key, value in google_container_cluster.clusters : key => value.location }
    node_locations = { for key, value in google_container_cluster.clusters : key => value.node_locations }
    endpoint       = { for key, value in google_container_cluster.clusters : key => "https://${value.endpoint}" }
    auth = {
      client_key             = { for key, value in google_container_cluster.clusters : key => base64decode(value.master_auth[0].client_key) }
      client_certificate     = { for key, value in google_container_cluster.clusters : key => base64decode(value.master_auth[0].client_certificate) }
      cluster_ca_certificate = { for key, value in google_container_cluster.clusters : key => value.master_auth[0].cluster_ca_certificate }
      username               = { for key, value in google_container_cluster.clusters : key => value.master_auth[0].username }
      password               = { for key, value in random_string.master_password : key => value.result }
    }
  }
}

output "nodes" {
  value = {
    name = { for key, value in google_container_node_pool.nodes : key => value.name }
    tag  = "gke-node-${local.gke_name}"
  }
}
