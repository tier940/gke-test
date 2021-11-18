output "clusters" {
  value = {
    name           = { for key, value in google_container_cluster.clusters : key => value.name }
    location       = { for key, value in google_container_cluster.clusters : key => value.location }
    node_locations = { for key, value in google_container_cluster.clusters : key => value.node_locations }
    endpoint       = { for key, value in google_container_cluster.clusters : key => "https://${value.endpoint}" }
  }
}

output "nodes" {
  value = {
    name = { for key, value in google_container_node_pool.nodes : key => value.name }
    tag  = "gke-node-${local.gke_name}"
  }
}
