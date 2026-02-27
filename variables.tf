# Custom firewall names for Aviatrix FireNet
variable "custom_fw_names" {
  description = "List of custom firewall names for Aviatrix FireNet module"
  type        = list(string)
  default     = ["az184fw1"]
}
variable "controller_ip" {
  description = "Set controller ip"
  type        = string
}

variable "ctrl_password" {
    type = string
}

variable "account" {
    type = string
}

variable "cloud" {
  description = "Cloud type"
  type        = string

  validation {
    condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.cloud))
    error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  }
}

variable "cidr" {
  description = "Set vpc cidr"
  type        = string
}

variable "region" {
  description = "Set regions"
  type        = string
}

variable "localasn" {
  description = "Set internal BGP ASN"
  type        = string
}

variable "bgp_advertise_cidrs" {
  description = "Define a list of CIDRs that should be advertised via BGP."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to assign to the gateway."
  type        = map(string)
  default     = null
}


# bgplan subnet
variable "az1" {
  type        = string
  description = "Primary AZ"
  default     = "a"
}
variable "az2" {
  type        = string
  description = "Secondary AZ"
  default     = "b"
}


# data integration
variable "fwuser" {
  type        = string
  description = ""
  default     = "fwadmin2"
}
variable "fwpasswd" {
  type        = string
  description = ""
  default     = "Aviatrix#1234"
}


# bootstrap
variable "storage_access_key_1" {
  type        = string
  description = ""
  default     = ""
}

variable "file_share_folder_1" {
  type        = string
  description = ""
  default = "bootstrap"
}

variable "bootstrap_storage_name_1" {
  type        = string
  description = ""
  default = "bootstrap"
}


# spokes
locals {
  spokes = yamldecode(file("spokes.yaml"))
}