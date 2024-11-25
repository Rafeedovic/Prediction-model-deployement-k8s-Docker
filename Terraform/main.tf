resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region
  deletion_protection = false
  initial_node_count = 2
  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
  node_config {
    machine_type = "e2-micro"
    disk_size_gb = 20
  }
}

resource "google_container_node_pool" "node_pool" {
  name       = "node-pool"
  cluster    = google_container_cluster.cluster.name
  location   = var.region
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    disk_size_gb = 20
  }
}
