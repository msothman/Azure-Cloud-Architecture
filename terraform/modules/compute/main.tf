# Compute Module - Main Configuration
# Provides Virtual Machines with availability and scaling capabilities

# Availability Set for Web VMs
resource "azurerm_availability_set" "web" {
  name                         = "avset-web-${var.environment}-${var.location_short}-001"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true

  tags = var.tags
}

# Network Interface for Web VMs
resource "azurerm_network_interface" "web" {
  count               = var.web_vm_count
  name                = "nic-web-${var.environment}-${var.location_short}-${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Associate NICs with Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = var.web_vm_count
  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.lb_backend_pool_id
}

# Web Virtual Machines
resource "azurerm_linux_virtual_machine" "web" {
  count               = var.web_vm_count
  name                = "vm-web-${var.environment}-${var.location_short}-${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.web_vm_size
  availability_set_id = azurerm_availability_set.web.id
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.web[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-web-${var.environment}-${var.location_short}-${format("%03d", count.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Web Server ${count.index + 1} - ${var.environment}</h1>" > /var/www/html/index.html
    echo "<p>Hostname: $(hostname)</p>" >> /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )

  tags = var.tags
}

# Network Interface for Application VM
resource "azurerm_network_interface" "app" {
  name                = "nic-app-${var.environment}-${var.location_short}-001"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Application Virtual Machine
resource "azurerm_linux_virtual_machine" "app" {
  name                = "vm-app-${var.environment}-${var.location_short}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.app_vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.app.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-app-${var.environment}-${var.location_short}-001"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip
    echo "Application server initialized - ${var.environment}" > /home/${var.admin_username}/init.log
  EOF
  )

  tags = var.tags
}
