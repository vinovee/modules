resource "google_container_cluster" "primary" {
  provider = google-beta

  name                = var.name
  description         = var.description
  project             = var.project
  resource_labels     = var.resource_labels
  deletion_protection = var.deletion_protection

  enable_autopilot = var.autopilot

  # TODO select available zones if node_locations is null
  location       = var.location
  node_locations = var.node_locations

  network           = var.network
  subnetwork        = var.subnetwork
  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  networking_mode   = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_allocation_policy.clusterSecondaryRangeName
    services_secondary_range_name = var.ip_allocation_policy.servicesSecondaryRangeName
    dynamic "additional_pod_ranges_config" {
      for_each = try([var.ip_allocation_policy.additionIpRangePods], [])
      content {
        pod_range_names = var.ip_allocation_policy.additionalIPRangePods
      }
    }
    stack_type = var.ip_allocation_policy.stackType
  }

  dynamic "private_cluster_config" {
    for_each = try([var.private_cluster_config], [])

    content {
      enable_private_endpoint     = try(private_cluster_config.value.enablePrivateEndpoint, false)
      enable_private_nodes        = try(private_cluster_config.value.enablePrivateNodes, false)
      master_ipv4_cidr_block      = try(private_cluster_config.value.masterIpv4CidrBlock, null)
      private_endpoint_subnetwork = try(private_cluster_config.value.privateEndpointSubnetwork, null)
      dynamic "master_global_access_config" {
        for_each = try([private_cluster_config.value.masterGlobalAccessConfig], [])
        content {
          enabled = try(private_cluster_config.value.masterGlobalAccessConfig.enabled, false)
        }
      }
    }
  }

  dynamic "release_channel" {
    for_each = try([var.release_channel], [])

    content {
      channel = release_channel.value
    }
  }

  min_master_version = var.kubernetes_version

  addons_config {
    http_load_balancing {
      disabled = try(var.addons_config.httpLoadBalancing.disabled, false)
    }
    horizontal_pod_autoscaling {
      disabled = try(var.addons_config.horizontalPodAutoscaling.disabled, false)
    }
  }

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account   = try(var.cluster_autoscaling.autoprovisioningNodePoolDefaults.serviceAccount, null)
      boot_disk_kms_key = try(var.cluster_autoscaling.autoprovisioningNodePoolDefaults.bootDiskKmsKey, null)
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption

    content {
      key_name = database_encryption.value.keyName
      state    = database_encryption.value.state
    }
  }

  maintenance_policy {
    # dynamic "recurring_window" {
    #   for_each = local.cluster_maintenance_window_is_recurring
    #   content {
    #     start_time = var.maintenance_start_time
    #     end_time   = var.maintenance_end_time
    #     recurrence = var.maintenance_recurrence
    #   }
    # }

    daily_maintenance_window {
      #   for_each = try([var.maintenance_policy.window.dailyMaintenanceWindow], [])
      #   content {

      start_time = var.maintenance_policy.window.dailyMaintenanceWindow.startTime
      #   }
    }

    # dynamic "maintenance_exclusion" {
    #   for_each = var.maintenance_exclusions
    #   content {
    #     exclusion_name = maintenance_exclusion.value.name
    #     start_time     = maintenance_exclusion.value.start_time
    #     end_time       = maintenance_exclusion.value.end_time

    #     dynamic "exclusion_options" {
    #       for_each = maintenance_exclusion.value.exclusion_scope == null ? [] : [maintenance_exclusion.value.exclusion_scope]
    #       content {
    #         scope = exclusion_options.value
    #       }
    #     }
    #   }
    # }
  }


  timeouts {
    create = try(var.timeouts.create, "45m")
    update = try(var.timeouts.update, "45m")
    delete = try(var.timeouts.delete, "45m")
  }

  /*
  enable_fqdn_network_policy = var.enable_fqdn_network_policy
  dynamic "gateway_api_config" {
    for_each = local.gateway_api_config

    content {
      channel = gateway_api_config.value.channel
    }
  }

  dynamic "cost_management_config" {
    for_each = var.enable_cost_allocation ? [1] : []
    content {
      enabled = var.enable_cost_allocation
    }
  }

  dynamic "confidential_nodes" {
    for_each = local.confidential_node_config
    content {
      enabled = confidential_nodes.value.enabled
    }
  }


  default_snat_status {
    disabled = var.disable_default_snat
  }


  dynamic "node_pool_auto_config" {
    for_each = length(var.network_tags) > 0 ? [1] : []
    content {
      network_tags {
        tags = var.network_tags
      }
    }
  }


  master_auth {
    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  dynamic "service_external_ips_config" {
    for_each = var.service_external_ips ? [1] : []
    content {
      enabled = var.service_external_ips
    }
  }

  allow_net_admin = var.allow_net_admin

  protect_config {
    workload_config {
      audit_mode = var.workload_config_audit_mode
    }
    workload_vulnerability_mode = var.workload_vulnerability_mode
  }

  security_posture_config {
    mode               = var.security_posture_mode
    vulnerability_mode = var.security_posture_vulnerability_mode
  }

  dynamic "fleet" {
    for_each = var.fleet_project != null ? [1] : []
    content {
      project = var.fleet_project
    }
  }

  dynamic "resource_usage_export_config" {
    for_each = var.resource_usage_export_dataset_id != "" ? [{
      enable_network_egress_metering       = var.enable_network_egress_export
      enable_resource_consumption_metering = var.enable_resource_consumption_export
      dataset_id                           = var.resource_usage_export_dataset_id
    }] : []

    content {
      enable_network_egress_metering       = resource_usage_export_config.value.enable_network_egress_metering
      enable_resource_consumption_metering = resource_usage_export_config.value.enable_resource_consumption_metering
      bigquery_destination {
        dataset_id = resource_usage_export_config.value.dataset_id
      }
    }
  }




  dynamic "authenticator_groups_config" {
    for_each = local.cluster_authenticator_security_group
    content {
      security_group = authenticator_groups_config.value.security_group
    }
  }

  notification_config {
    pubsub {
      enabled = var.notification_config_topic != "" ? true : false
      topic   = var.notification_config_topic
    }
  }
*/
}
