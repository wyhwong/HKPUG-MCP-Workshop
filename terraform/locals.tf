locals {
  all_tenant_namespaces = [for tenant in slice(random_pet.tenant_namespaces, 0, var.tenant_config.max_tenant_num) : "tenant-${tenant.id}-${var.env}"]
  tenant_namespaces = [for tenant in slice(random_pet.tenant_namespaces, 0, var.tenant_config.curr_tenant_num) : "tenant-${tenant.id}-${var.env}"]
  postgres_tenants = [
    for tenant in local.all_tenant_namespaces : {
      username = tenant
      password = nonsensitive(random_password.tenant_namespaces_postgres[tenant].result)
      dbname   = tenant
    }
  ]
  _unindented_tenant_init_sql = join("\n\n", [
    for tenant in local.postgres_tenants : <<-EOT
      -- Script for tenant: ${tenant.username}
      CREATE USER "${tenant.username}" WITH PASSWORD '${tenant.password}';
      CREATE DATABASE "${tenant.dbname}" OWNER "${tenant.username}";
    EOT
  ])

  _unindented_tenant_permission_sql = join("\n", [
    for tenant in local.postgres_tenants : <<-EOT
      \c ${tenant.dbname};
      ALTER SCHEMA public OWNER TO "${tenant.username}";
      GRANT ALL ON SCHEMA public TO "${tenant.username}";
    EOT
  ])

  postgres_tenants_init_sql = indent(6, "${local._unindented_tenant_init_sql}\n\n${local._unindented_tenant_permission_sql}")
}
