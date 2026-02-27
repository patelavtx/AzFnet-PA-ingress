# AzFnet-PA-ingress


## Example of TFVARS

```
controller_ip = ""
ctrl_password = ""
account       = "AZ-proj"
cloud         = "azure"
cidr          = "10.184.28.0/23"
region        = "UK South"
localasn      = "65184"
tags = {
  ProjectName        = "Test SubnetGroups"
  BusinessOwnerEmail = ""
}

storage_access_key_1 = "<storage key for bootstrap files>"
file_share_folder_1 = "bootstrap"
bootstrap_storage_name_1 = "panstorage"
```