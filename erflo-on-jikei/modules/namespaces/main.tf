locals {
  namespaces = [
    "airflow",
    "servicea",
    # Add more namespaces here as needed
  ]
}

resource "kubernetes_namespace_v1" "namespaces" {
  for_each = toset(local.namespaces)

  metadata {
    annotations = {
      name = each.key
    }

    labels = {
      mylabel = each.key
    }

    name = each.key
  }
}
