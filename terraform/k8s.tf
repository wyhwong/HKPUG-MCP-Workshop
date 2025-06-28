data "kubernetes_namespace_v1" "kube_system" {
  provider = kubernetes
  metadata {
    name = "kube-system"
  }
}

resource "random_pet" "tenant_namespaces" {
  count  = var.tenant_config.max_tenant_num
  length = 2
}

resource "random_password" "tenant_namespaces_vscode" {
  for_each = toset(local.all_tenant_namespaces)
  length   = var.tenant_config.vscode_password_length
  numeric  = true
  lower    = false
  upper    = false
  special  = false
}

resource "kubernetes_namespace_v1" "tenant" {
  for_each = toset(local.all_tenant_namespaces)
  provider = kubernetes
  metadata {
    name = each.value
    labels = {
      role = "tenant"
    }
  }
}

resource "kubernetes_manifest" "storageclass" {
  provider = kubernetes
  manifest = yamldecode(
    <<EOT
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: persistent-storage 
    provisioner: pd.csi.storage.gke.io
    reclaimPolicy: Retain
    volumeBindingMode: Immediate
    EOT
  )
}

resource "random_password" "postgres_admin" {
  length = var.postgres_config.password_length
}

resource "random_password" "tenant_namespaces_postgres" {
  for_each = toset(local.all_tenant_namespaces)
  length   = var.postgres_config.password_length
  numeric  = true
  lower    = false
  upper    = false
  special  = false
}

resource "kubernetes_namespace_v1" "database" {
  provider = kubernetes
  metadata {
    name = var.postgres_config.namespace
  }
}
