data "azurerm_network_interface" "fw_nic" {
  name                = "${var.custom_fw_names[0]}-egress-eth1"
  resource_group_name = module.mc-aztransit184.vpc.resource_group
}


resource "azurerm_lb_rule" "firenet_rule_8080" {
  name                           = "firenet-rule-8080"
  loadbalancer_id                = azurerm_lb.firenet_nlb.id
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firenet_pool.id]
  probe_id                       = azurerm_lb_probe.firenet_probe.id
  floating_ip_enabled            = false
}

resource "azurerm_lb_rule" "firenet_rule_8081" {
  name                           = "firenet-rule-8081"
  loadbalancer_id                = azurerm_lb.firenet_nlb.id
  protocol                       = "Tcp"
  frontend_port                  = 8081
  backend_port                   = 8081
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firenet_pool.id]
  probe_id                       = azurerm_lb_probe.firenet_probe.id
  floating_ip_enabled            = false
}
resource "azurerm_public_ip" "firenet_nlb" {
  name                = "firenet-nlb-pip"
  location            = module.mc-aztransit184.vpc.region
  resource_group_name = module.mc-aztransit184.vpc.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "firenet_nlb" {
  name                = "firenet-nlb"
  location            = module.mc-aztransit184.vpc.region
  resource_group_name = module.mc-aztransit184.vpc.resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.firenet_nlb.id
  }
}

resource "azurerm_lb_backend_address_pool" "firenet_pool" {
  name                = "firenet-backend-pool"
  loadbalancer_id     = azurerm_lb.firenet_nlb.id
}

resource "azurerm_lb_rule" "firenet_rule_443" {
  name                           = "firenet-rule-443"
  loadbalancer_id                = azurerm_lb.firenet_nlb.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firenet_pool.id]
  probe_id                       = azurerm_lb_probe.firenet_probe.id
  floating_ip_enabled            = false # <--- DISABLE FLOATING VIP
}

resource "azurerm_lb_rule" "firenet_rule_2222" {
  name                           = "firenet-rule-2222"
  loadbalancer_id                = azurerm_lb.firenet_nlb.id
  protocol                       = "Tcp"
  frontend_port                  = 2222
  backend_port                   = 2222
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firenet_pool.id]
  probe_id                       = azurerm_lb_probe.firenet_probe.id
  floating_ip_enabled            = false
}

resource "azurerm_lb_rule" "firenet_rule_2223" {
  name                           = "firenet-rule-2223"
  loadbalancer_id                = azurerm_lb.firenet_nlb.id
  protocol                       = "Tcp"
  frontend_port                  = 2223
  backend_port                   = 2223
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firenet_pool.id]
  probe_id                       = azurerm_lb_probe.firenet_probe.id
  floating_ip_enabled            = false
}

resource "azurerm_lb_probe" "firenet_probe" {
  name                = "firenet-probe"
  loadbalancer_id     = azurerm_lb.firenet_nlb.id
  protocol            = "Tcp"
  port                = 443
}

resource "azurerm_network_interface_backend_address_pool_association" "fw_nic_assoc" {
  network_interface_id    = data.azurerm_network_interface.fw_nic.id
  ip_configuration_name   = data.azurerm_network_interface.fw_nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.firenet_pool.id
}
