resource "kubernetes_manifest" "vscode_statefulset" {
  for_each = toset(local.tenant_namespaces)
  provider = kubernetes
  manifest = yamldecode(
    <<EOT
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: vscode 
      namespace: ${kubernetes_namespace_v1.tenant[each.key].metadata[0].name}
    spec:
      serviceName: vscode
      replicas: 1
      selector:
        matchLabels:
          app: vscode
      template:
        metadata:
          labels:
            app: vscode
        spec:
          serviceAccountName: ${kubernetes_manifest.vscode_sa[each.key].object.metadata.name}
          shareProcessNamespace: true
          initContainers:
          - name: fix-permissions
            image: busybox:latest
            command: ["sh", "-c", "chmod -R 777 /home/coder"]
            volumeMounts:
              - name: vscode-storage
                mountPath: /home/coder
          containers:
            - name: vscode
              image: asia-east2-docker.pkg.dev/hket-cloud-team-experiment/hkpug-workshop-docker-repo-prod/vscode@sha256:e34bdf27d37af6c70669c3a0062a388130baafa5e563a7d63a66bd205e7843b9
              imagePullPolicy: Always
              volumeMounts:
                - name: vscode-storage
                  mountPath: /home/coder
              ports:
                - containerPort: 8000
                  name: vscode
                - containerPort: 8080
                  name: user-http
              env:
                - name: POSTGRES_HOST
                  value: ${kubernetes_manifest.postgres_service.object.metadata.name}.${kubernetes_namespace_v1.database.metadata[0].name}.svc.cluster.local
                - name: POSTGRES_PORT
                  value: "5432"
                - name: POSTGRES_USERNAME
                  value: ${each.key}
                - name: POSTGRES_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: ${kubernetes_secret.tenant_postgres_password[each.key].metadata[0].name}
                      key: "password"
                - name: POSTGRES_DATABASE
                  value: ${each.key}
                - name: MCP_FS_PORT
                  value: 3001
                - name: MCP_PG_PORT
                  value: 3002
              resources:
                requests:
                  cpu: 1200m
                  memory: 5Gi
                limits:
                  memory: 5Gi
            - name: nginx-auth-proxy
              image: nginx:alpine
              ports:
                - containerPort: 80
                  name: http
              volumeMounts:
                - name: nginx-config
                  mountPath: /etc/nginx/conf.d
                - name: basic-auth-credentials
                  mountPath: /etc/nginx/.htpasswd
                  subPath: auth
              resources:
                requests:
                  cpu: 100m
                  memory: 128Mi
                limits:
                  memory: 128Mi
          volumes:
            - name: nginx-config
              configMap:
                name: ${kubernetes_config_map_v1.nginx_config[each.key].metadata[0].name} 
            - name: basic-auth-credentials
              secret:
                secretName: ${kubernetes_secret.basic_auth_credentials[each.key].metadata[0].name}
      volumeClaimTemplates:
        - metadata:
            name: vscode-storage
          spec:
            accessModes: [ "ReadWriteOnce" ]
            resources:
              requests:
                storage: ${var.tenant_config.storage}
            storageClassName: persistent-storage 
    EOT
  )
}

resource "kubernetes_secret" "tenant_postgres_password" {
  for_each = toset(local.tenant_namespaces)
  metadata {
    name      = "tenant-postgres-password-${each.key}"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
  }

  data = {
    password = random_password.tenant_namespaces_postgres[each.key].result
  }
}

resource "kubernetes_config_map_v1" "nginx_config" {
  for_each = toset(local.tenant_namespaces)
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
  }

  data = {
    "default.conf" = <<-EOF
      server {
        listen 80;
        
        # Authentication for VS Code access
        auth_basic "VS Code Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        # VS Code web interface
        location / {
          proxy_pass http://localhost:8000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
        }
      }
    EOF
  }
}

data "external" "htpasswd_hash" {
  for_each = toset(local.tenant_namespaces)

  program = ["bash", "-c", <<EOT
    PASSWORD="${random_password.tenant_namespaces_vscode[each.key].result}"
    USERNAME="${each.key}"
    HASH=$(docker run --rm httpd:2.4-alpine htpasswd -nbB "$USERNAME" "$PASSWORD" | cut -d ":" -f 2)
    echo "{\"hash\": \"$HASH\"}"
  EOT
  ]
}

resource "kubernetes_secret" "basic_auth_credentials" {
  for_each = toset(local.tenant_namespaces)

  metadata {
    name      = "basic-auth-credentials"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
  }

  data = {
    auth = "${each.key}:${data.external.htpasswd_hash[each.key].result.hash}"
  }

}

# 1. Create a ConfigMap to hold your initialization script.
resource "kubernetes_config_map_v1" "postgres_init_script" {
  metadata {
    name      = "postgres-init-script"
    namespace = kubernetes_namespace_v1.database.metadata[0].name
  }

  data = {
    # The key here will be the filename inside the container.
    "init-db.sh" = <<-EOT
      #!/bin/bash
      set -e
      # This script will be executed by the postgres entrypoint.
      # The admin user is already created via environment variables.
      
      # Use psql to run the generated SQL for all tenants.
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
      ${local.postgres_tenants_init_sql}
      EOSQL
    EOT
  }
}

resource "kubernetes_manifest" "postgres_service" {
  provider = kubernetes
  manifest = yamldecode(
    <<EOT
    apiVersion: v1
    kind: Service
    metadata:
      name: postgres 
      namespace: ${kubernetes_namespace_v1.database.metadata[0].name}
    spec:
      type: ClusterIP
      clusterIP: None
      ports:
      - port: 5432
        targetPort: 5432
      selector:
        app: postgres 
    EOT
  )
}

resource "kubernetes_manifest" "postgres_statefulset" {
  provider = kubernetes
  manifest = yamldecode(<<-EOT
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: postgres
      namespace: ${kubernetes_namespace_v1.database.metadata[0].name}
    spec:
      serviceName: ${kubernetes_manifest.postgres_service.object.metadata.name}
      replicas: 1
      selector:
        matchLabels:
          app: postgres
      template:
        metadata:
          labels:
            app: postgres
        spec:
          containers:
            - name: postgres
              image: "postgres:16-alpine"
              env:
                - name: POSTGRES_DB
                  value: ${var.postgres_config.admin.database}
                - name: POSTGRES_USER
                  value: ${var.postgres_config.admin.username}
                - name: POSTGRES_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: ${kubernetes_secret.postgres_admin_password.metadata[0].name}
                      key: "password"
                - name: PGDATA
                  value: /var/lib/postgresql/data/pgdata
              ports:
                - containerPort: 5432
              volumeMounts:
                - name: postgres-storage
                  mountPath: "/var/lib/postgresql/data"
                - name: postgres-init-script
                  mountPath: "/docker-entrypoint-initdb.d"
          nodeSelector:
            usage: database
          tolerations:
            - key: "usage"
              operator: "Equal"
              value: "database"
              effect: "NoSchedule"
          volumes:
            - name: postgres-init-script
              configMap:
                name: ${kubernetes_config_map_v1.postgres_init_script.metadata[0].name}
      volumeClaimTemplates:
        - metadata:
            name: postgres-storage
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: ${var.postgres_config.storage}
            storageClassName: "persistent-storage"
  EOT
  )
}

resource "kubernetes_secret" "postgres_admin_password" {
  metadata {
    name      = "postgres-admin-password"
    namespace = kubernetes_namespace_v1.database.metadata[0].name
  }

  data = {
    password = random_password.postgres_admin.result
  }
}