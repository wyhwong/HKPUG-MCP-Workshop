stack_prefix = "hkpug-workshop"
env          = "prod"
region       = "asia-east2"
enabled_services = [
  "container",
  "certificatemanager",
  "aiplatform"
]
vpc_config = {
  main_cidr = "10.0.0.0/16",
  secondary_ip_ranges = {
    pod = {
      range_name    = "pod-range",
      ip_cidr_range = "10.1.0.0/16"
    }
    service = {
      range_name    = "service-range",
      ip_cidr_range = "10.2.0.0/16"
    }
  }
}
gke_config = {
  cluster = {
    location = "BALANCED"
  }
  node_pools = {
    database = {
      spot         = false
      machine_type = "e2-standard-2"
      node_count = {
        min = 1
        max = 3
      }
      disk_size = 12
      labels    = {}
      node_taints = [
        {
          key    = "usage"
          value  = "database"
          effect = "NO_SCHEDULE"
        }
      ]
    }
    public = {
      spot         = false
      machine_type = "e2-standard-8"
      node_count = {
        min = 1
        max = 10
      }
      disk_size   = 40
      labels      = {}
      node_taints = []
    }
  }
}

gateway_config = {
  namespace = "gateway"
}

domain_config = {
  second_level_domain = "hkpug-workshop.com"
  zone_id             = "786bdf0612800319d22b8bee5e2f0389"
}

postgres_config = {
  namespace       = "database"
  storage         = "10Gi"
  password_length = 16
  admin = {
    username = "admin"
    database = "postgres"
  }
}

tenant_config = {
  max_tenant_num         = 40
  curr_tenant_num        = 40
  vscode_password_length = 6
  storage                = "10Gi"
}
