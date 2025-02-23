variable "name" {
  description = "The name of the cluster"
  type        = string
}

variable "project" {
  description = "The project for the cluster"
  type        = string
}

variable "autopilot" {
  description = "Enable autopilot"
  type        = bool
  default     = true
}

variable "network" {
  description = "The network for the cluster"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork for the nodes"
  type        = string
}

variable "ip_allocation_policy" {
  description = "The allocation policy for the ip ranges"
  type = object({
    clusterSecondaryRangeName  = string
    servicesSecondaryRangeName = string
    stackType : string
    useIpAliases : bool
    clusterIpv4Cidr : optional(string)
    clusterIpv4CidrBlock : optional(string)
    podCidrOverprovisionConfig : optional(map(any), null)
    servicesIpv4Cidr : optional(string)
    servicesIpv4CidrBlock : optional(string)
  })
}

variable "location" {
  description = "The location of the cluster for regional clusters"
  type        = string
  default     = null
}

# TODO if null, use all available zones in the region?
variable "node_locations" {
  description = "The zones for the nodes or single zone for a zonal cluster"
  type        = list(string)
  default     = null
}

variable "private_cluster_config" {

}

variable "release_channel" {
  description = "The release channel for the cluster"
  type        = string
  default     = "REGULAR"
}

variable "addons_config" {
  description = "Specifies the addons configuration"
  type        = object({})
  default     = null
}

variable "cluster_autoscaling" {

}

variable "enable_vertical_pod_autoscaling" {
  description = "Vertical Pod Autoscaling"
  type        = bool
  default     = true
}

variable "master_authorized_networks_config" {
  description = "The master authorized networks configuration"
  type        = object({})
  default     = null
}

variable "database_encryption" {
  description = "The database encryption configuration"
  type        = object({})
  default     = null
}

variable "kubernetes_version" {
  description = "The minimum master version"
  type        = string
  default     = null # Uses latest if null
}

variable "cluster_ipv4_cidr" {
  description = "The cidr range for the control plane in private endpoint clusters"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Prevents the cluster being deleted"
  type        = bool
  default     = false
}

variable "description" {
  description = "The description of the cluster"
  type        = string
  default     = null
}

variable "resource_labels" {
  description = "The resource labels for the cluster"
  type        = map(string)
  default     = null
}

variable "maintenance_policy" {
  description = "The maintenance policy for the cluster"
  type = object({
    window = object({
      dailyMaintenanceWindow = object({
        startTime = string
      })
    })
  })
  default = {
    window = {
      dailyMaintenanceWindow = {
        startTime = "05:00"
      }
    }
  }
}

variable "timeouts" {
  description = "Terraform timeout values"
  type        = object({})
  default     = null
}

