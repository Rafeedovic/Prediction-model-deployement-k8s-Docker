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

resource "google_storage_bucket" "bucket" {
  name                        = var.bucket_name
  location                    = var.location
  storage_class               = "STANDARD"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

resource "google_bigquery_dataset" "dataset_cars" {
    project = var.project
    dataset_id = var.dataset_id 
    location   = var.location  
}

resource "google_bigquery_table" "audi_csv_external" {
  dataset_id = google_bigquery_dataset.dataset_cars.dataset_id
  table_id   = "audi_csv_external"

  external_data_configuration {
    source_uris = ["gs://tvapy-bucket/audi.csv"]
    autodetect = true 
    source_format = "CSV"
    csv_options {
        quote = "\""
        skip_leading_rows = 1 
      }
  }
}

# resource "google_bigquery_table" "table_cars_audi" {
#   dataset_id = google_bigquery_dataset.dataset_cars.dataset_id
#   table_id   = "cars_audi"  
#   deletion_protection=false
#   schema = jsonencode([
#     {
#       "name": "model",
#       "type": "STRING",
#       "mode": "REQUIRED"
#     },
#     {
#       "name": "year",
#       "type": "INTEGER",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "price",
#       "type": "FLOAT",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "transmission",
#       "type": "STRING",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "mileage",
#       "type": "INTEGER",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "fuelType",
#       "type": "STRING",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "tax",
#       "type": "FLOAT",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "mpg",
#       "type": "FLOAT",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "engineSize",
#       "type": "FLOAT",
#       "mode": "NULLABLE"
#     },
#     {
#       "name": "created_at",
#       "type": "TIMESTAMP",
#       "mode": "REQUIRED"
#     }
#   ])
# }