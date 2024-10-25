locals {
  secrets = {
    airflow = {
      namespace = "airflow"
      name      = "airflow-secrets"
      data = {
        fernet_key = ""
        gcp_key    = ""
      }
    }
    servicea = {
      namespace = "servicea"
      name      = "servicea-secrets"
      data = {
        gcp_key = ""
      }
    }
  }
}

resource "kubernetes_secret_v1" "secrets" {
  for_each = local.secrets

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  data = each.value.data

  type = "Opaque"
}
