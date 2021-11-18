tags = {
  stage      = "dev"
  stage_full = "development"
  env        = "tier940"
}
project = {
  name = "test-gke"
  id   = "test-gke-331312"
}
gcp_services = {
  destroy   = false
  dependent = false
  boot = [                              # don't touch.
    "serviceusage.googleapis.com",      # Service Usage API
    "servicemanagement.googleapis.com", # Service Management API
    "servicenetworking.googleapis.com", # Service Networking API
    "cloudapis.googleapis.com"          # Google Cloud API
  ]
  list = [
    "clouddebugger.googleapis.com",     # Stackdriver Debugger API
    "cloudtrace.googleapis.com",        # Stackdriver Trace API
    "logging.googleapis.com",           # Stackdriver Logging API
    "monitoring.googleapis.com",        # Stackdriver Monitoring API
    "compute.googleapis.com",           # Compute Engine API
    "osconfig.googleapis.com",          # OS Config API
    "containeranalysis.googleapis.com", # Container Analysis API
    "iam.googleapis.com",               # Identity and Access Management API
    "iamcredentials.googleapis.com",    # IAM Service Account Credentials API
    "sql-component.googleapis.com",     # Cloud SQL
    "sqladmin.googleapis.com",          # Cloud SQL Admin API
    "storage-component.googleapis.com", # Cloud Storage
    "container.googleapis.com",         # Kubernetes Engine API
    "vpcaccess.googleapis.com",         # Serverless VPC Access API
    "dns.googleapis.com",               # Cloud DNS API
    "cloudbuild.googleapis.com",        # Cloud Build API
    "networkmanagement.googleapis.com", # Network Management API
    "secretmanager.googleapis.com"      # Secret Manager API
  ]
}
region_list = {
  "usc1" = "us-central1"
}



###################################
#  Subnet Config
###################################
# main
subnet_cidr_block_main = {
  "usc1" = {
    public = {
      "01" = { az = "a", cidr = "100.1.0.0/22" }
      "02" = { az = "b", cidr = "100.2.0.0/22" }
      "03" = { az = "c", cidr = "100.3.0.0/22" }
    }
    private = {
      "01" = { az = "a", cidr = "200.1.0.0/22" }
      "02" = { az = "b", cidr = "200.2.0.0/22" }
      "03" = { az = "c", cidr = "200.3.0.0/22" }
    }
  }
}
subnet_cidr_block_other = {
  "usc1" = {
    gke = { az = "a", cidr = "150.1.0.0/22", private_access = true }
    cfg = { az = "a", cidr = "50.1.0.0/20", private_access = true }
  }
}



###################################
#  GCE Config
###################################
gce_config = {
  # us-central1
  "usc1" = {
    config = {
      name             = "config"
      dns_name         = "config"
      machine_type     = "e2-small"
      root_volume      = 20
      volume_type      = "pd-standard"
      image            = "centos-cloud/centos-8"
      static_public_ip = true
      zone = {
        "01" = "us-central1-a"
      }
      instance_ips = {
        "01" = "200.1.0.10"
      }
    }
  }
}

# cloud-init
cloud_init = <<-CLOUDINIT
  #!/bin/bash

  if ! type cloud-init > /dev/null 2>&1 ; then
    echo "Ran - Start - `date`" >> /root/startup
    echo "fastestmirror=true" >> /etc/dnf/dnf.conf

    echo "Ran - Start packages install - `date`" >> /root/startup
    dnf install -y epel-release centos-release-stream redhat-lsb-core bash-completion

    echo "Ran - Start cloud-init install - `date`" >> /root/startup
    dnf install -y cloud-init

    if [ $? == 0 ]; then
      echo "Ran - Success - `date`" >> /root/startup
      systemctl enable cloud-init
      systemctl start cloud-init
    else
      echo "Ran - Fail - `date`" >> /root/startup
    fi

    # Reboot either way
    reboot
  fi
CLOUDINIT



###################################
#  GKE Config
###################################
# Cluster and node versions docs.
# https://cloud.google.com/kubernetes-engine/versioning-and-upgrades#versioning_scheme
gke_config = {
  # us-central1
  "usc1" = {
    name       = "default-pool"
    create_key = ["blue"]
    online_key = ["blue"]
    clusters = {
      blue = {
        version = "1.21."
        zone    = ["us-central1-c"]
        addons = {
          load_balancing = true
          csi_driver     = true
        }
        authorized_cidr = {
          allow_all = "0.0.0.0/0"
        }
      }
      green = {
        version = "1.22."
        zone    = ["us-central1-c"]
        addons = {
          load_balancing = true
          csi_driver     = true
        }
        authorized_cidr = {
          allow_all = "0.0.0.0/0"
        }
      }
    }
    nodes = {
      blue = {
        image_type   = "COS_CONTAINERD"
        machine_type = "e2-small"
        root_volume  = 10
        size         = { min = 1, max = 3, init = 1 }
        upgrade      = { surge = 1, unavailable = 1 }
        management   = { auto_repair = true, auto_upgrade = false }
      }
      green = {
        image_type   = "COS_CONTAINERD"
        machine_type = "e2-small"
        root_volume  = 10
        size         = { min = 1, max = 3, init = 1 }
        upgrade      = { surge = 1, unavailable = 1 }
        management   = { auto_repair = true, auto_upgrade = false }
      }
    }
  }
}



###################################
#  Cloud SQL
###################################
# Instance tier list get.
# $ gcloud sql tiers list
sql_config = {
  # us-central1
  "usc1" = {
    name                = "webap"
    disk_size           = 10
    disk_autoresize     = false
    deletion_protection = false
    instances = {
      "01" = { type = "db-f1-micro", version = "MYSQL_8_0", vaccess = "10.1.0.0/28", root_pass = "sql_dev" }
    }
    databases = {
      "01" = { name = "laravel", charset = "utf8mb4", collation = "utf8mb4_bin" }
    }
    users = {
      "01" = { host = "%", name = "laravel", pass = "dev_pass" }
    }
    flags = {
      "01" = { name = "default_authentication_plugin", value = "mysql_native_password" }
      "02" = { name = "character_set_server", value = "utf8mb4" }
    }
    maintenance_window = {
      day  = 5
      hour = 16
    }
  }
}
