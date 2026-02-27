
# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest

# https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-firenet
# # bootscript - fwadmin2 / Aviatrix#1234  (azure module default fwadmin/Aviatrix#1234)

# Check C:\Users\attil\OneDrive - Aviatrix Systems, Inc\Avtx\avtxGuides\Security-Firenet-Seg-DCF\Firenet   for 'Route table' info

module "mc-aztransit184" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.6.0"
  cloud = "azure"        
  cidr = var.cidr
  region = var.region
  account = var.account
  local_as_number = var.localasn
  insane_mode = "false"
  ha_gw = "false"
  name = "aztransit184-uks"
  enable_transit_firenet = "true"       
  #instance_size = "Standard_D3_v2"          # Default Standard_D3_v2 when fnet/insane
  enable_segmentation    = "true"
  tags  =  var.tags
}




module "firenet_1" {
  source         = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version        = "v1.6.0"
  transit_module = module.mc-aztransit184
  custom_fw_names = var.custom_fw_names
  #custom_fw_names = ["az184fw1"] # example of custom firewall name, should be unique in the Aviatrix Controller --- IGNORE ---
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  bootstrap_storage_name_1 = var.bootstrap_storage_name_1             # should exist   ; 
  file_share_folder_1 = var.file_share_folder_1                   
  storage_access_key_1 = var.storage_access_key_1
  #inspection_enabled = ""         # default =true
  #keep_alive_via_lan_interface_enabled = "true"            # see readme.txt
  egress_enabled = "true"
  tags = {
    applicationname = "SAP_EUR_ECC"
    auid = "SE-00546"
    zone = "eur"
    ProjectName        = "EUR Aviatrix"
    Department         = "Finance"
    CostCenter         = "5921BE98"
    Criticality        = "Critical Impact"
    BusinessOwnerEmail = "thomas.bennett@ab-inbev.com"
    DevOwnerEmail      = "phani.narasimhachar@ab-inbev.com"
    MaintenanceWindow  = null
    environment = "prod"
    }
}


# Vendor integration for PA NEEDed for Azure *****
# added delay to allow fw interfaces to be ready for vendor integration

resource "time_sleep" "wait_90_seconds" {
  create_duration = "90s"
  depends_on = [ module.firenet_1 ]
}


# data integration
data "aviatrix_firenet_vendor_integration" "fw1" {
  vpc_id        = module.mc-aztransit184.transit_gateway.vpc_id
  instance_id   = module.firenet_1.aviatrix_firewall_instance[0].instance_id
  vendor_type   = "Palo Alto Networks VM-Series"  # "Generic", "Palo Alto Networks VM-Series", "Aviatrix FQDN Gateway" and "Fortinet FortiGate"
  public_ip     = module.firenet_1.aviatrix_firewall_instance[0].public_ip
  username      = var.fwuser                      # REST_API user or admin for PA
  password      = var.fwpasswd
  firewall_name = module.firenet_1.aviatrix_firewall_instance[0].firewall_name
  save          = true
  #synchronize   = true # "save" and "synchronize" cannot be invoked at the same time
  depends_on = [ time_sleep.wait_90_seconds ]
}


/*
#fw2
data "aviatrix_firenet_vendor_integration" "fw2" {
  vpc_id        = module.mc-aztransit184.transit_gateway.vpc_id
  instance_id   = module.firenet_1.aviatrix_firewall_instance[1].instance_id
  vendor_type   = "Palo Alto Networks VM-Series"         # "Generic", "Palo Alto Networks VM-Series", "Aviatrix FQDN Gateway" and "Fortinet FortiGate"
  public_ip     = module.firenet_1.aviatrix_firewall_instance[1].public_ip
  username      = var.fwuser                            # REST_API user or admin for PA
  password      = var.fwpasswd
  firewall_name = module.firenet_1.aviatrix_firewall_instance[1].firewall_name
  save          = true
  #synchronize   = true # "save" and "synchronize" cannot be invoked at the same time
  depends_on = [ time_sleep.wait_90_seconds ]
}
*/




#1  adding spokes

module "spokes" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.7.1"
  for_each = local.spokes

  account = each.value.account
  cloud   = each.value.cloud
  name    = each.key
  region  = each.value.region
  cidr    = each.value.cidr
  ha_gw   = try(each.value.ha_gw, true) #Contrary to the mc-transit module, mc-spoke module does not accept null, as the input variable does not yet have "nullable = false" as property.
  insane_mode = each.value.insane_mode
  instance_size = each.value.instance_size
  transit_gw = each.value.transit_gw
  # network_domain = each.value.network_domain      # added to implement segmentation association
  subnet_pairs = each.value.subnet_pairs
  depends_on = [ module.mc-aztransit184 ]
}


# VMs for spoke1
# Create test instance, can add to TF registry
module "azure-linuxvm-spoke1-sub1" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  count = 1
  region = module.spokes["azspoke1"].vpc.region
  resource_group_name = module.spokes["azspoke1"].vpc.resource_group
  subnet_id = module.spokes["azspoke1"].vpc.subnets[1].subnet_id
  vm_name = "${module.spokes["azspoke1"].vpc.name}-sub1-vm${count.index}"
}

output "spoke1-vm_0-1" {
  value = module.azure-linuxvm-spoke1-sub1
}



# 2nd subnet
module "azure-linuxvm-spoke1-sub2" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  region = module.spokes["azspoke1"].vpc.region
  resource_group_name = module.spokes["azspoke1"].vpc.resource_group
  subnet_id = module.spokes["azspoke1"].vpc.subnets[2].subnet_id
  vm_name = "${module.spokes["azspoke1"].vpc.name}-sub2-vm"
}

output "spoke1-vm2" {
  value = module.azure-linuxvm-spoke1-sub2
}



/*
# VMs for spoke2
# Create test instance, can add to TF registry
module "azure-linuxvm-spoke2-sub1" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  count = 1
  region = module.spokes["azspoke2"].vpc.region
  resource_group_name = module.spokes["azspoke2"].vpc.resource_group
  subnet_id = module.spokes["azspoke2"].vpc.subnets[1].subnet_id
  vm_name = "${module.spokes["azspoke2"].vpc.name}-sub1-vm${count.index}"
}

output "spoke2-vms_0-1" {
  value = module.azure-linuxvm-spoke2-sub1
}
*/


/*
# 2nd subnet
module "azure-linuxvm-spoke2-sub2" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  region = module.spokes["azspoke2"].vpc.region
  resource_group_name = module.spokes["azspoke2"].vpc.resource_group
  subnet_id = module.spokes["azspoke2"].vpc.subnets[2].subnet_id
  vm_name = "${module.spokes["azspoke2"].vpc.name}-sub2-vm"
}

output "spoke2-vm2" {
  value = module.azure-linuxvm-spoke2-sub2
}
*/



