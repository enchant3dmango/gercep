locals {
  namespaces = var.namespaces
}

resource "kubernetes_namespace_v1" "this" {
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
