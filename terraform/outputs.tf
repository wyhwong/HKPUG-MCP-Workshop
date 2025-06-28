output "tenant_infos" {
  value = jsonencode([
    for tenant in local.all_tenant_namespaces : {
      namespace         = tenant
      vscode_password   = nonsensitive(random_password.tenant_namespaces_vscode[tenant].result)
      postgres_password = nonsensitive(random_password.tenant_namespaces_postgres[tenant].result)
    }
  ])
}

output "postgres_admin_info" {
  value = {
    username = "admin"
    password = nonsensitive(random_password.postgres_admin.result)
    dbname   = "postgres"
  }
}

output "dns_authorization" {
  value = google_certificate_manager_dns_authorization.wildcard.dns_resource_record
}