variable "azure_r1_location" {
  description = "Region 1 location"
  default     = "East US"
}

variable "azure_r1_location_short" {
  description = "Short name of Region 1"
  default     = "eus"
}

variable "aws_r1_location" {
  description = "Region 1 location"
  default     = "us-east-1"
}

variable "aws_r1_location_short" {
  description = "Short name of Region 1"
  default     = "eus"
}

variable "azure_oai_location" {
  description = "OAI location"
  default     = "Canada East"

}

variable "azure_oai_location_short" {
  description = "OAI location"
  default     = "cea"

}

variable "azure_account" {
  description = "Azure account name"
}

variable "aws_account" {
  description = "CSP account onboarder on the controller"
}

variable "dns_zone_name" {
  description = "DNS Zone Name to publish chat bot A record"
  default     = "dummy"
}

variable "chat_dns_prefix" {
  description = "DNS Prefix for the chat bot"
  default     = "chat"
}

variable "app_dns_prefix" {
  description = "DNS Prefix for the app"
  default     = "app"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
}

variable "ssh_key_name" {
  description = "SSH Key Name"
  default     = "dummy"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "admin_username" {
  description = "Admin username"
  default     = "admin"
}

locals {
  chat_certificate_cn = var.dns_zone_name == "dummy" ? "chat.aviatrix.local" : "${var.chat_dns_prefix}.${var.dns_zone_name}"
  app_certificate_cn  = var.dns_zone_name == "dummy" ? "app.aviatrix.local" : "${var.app_dns_prefix}.${var.dns_zone_name}"
  subnets = {
    avx-gw-subnet = {
      route_table = "avx-gw",
      # cidr              = cidrsubnet(var.gw_subnet, 1, 0)
      cidr              = cidrsubnet(var.gw_subnet, 4, 8)
      availability_zone = "${var.aws_r1_location}a"
    },
    avx-hagw-subnet = {
      route_table = "avx-hagw",
      # cidr              = cidrsubnet(var.gw_subnet, 1, 1)
      cidr              = cidrsubnet(var.gw_subnet, 4, 9)
      availability_zone = "${var.aws_r1_location}c"
    },
    front-a = {
      route_table       = "rt-internal-a",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 0)
      availability_zone = "${var.aws_r1_location}a"
    }
    dmz = {
      route_table       = "dmz",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 4)
      availability_zone = "${var.aws_r1_location}a"
    },
  }
  cloud_init_config = templatefile("${path.module}/script.sh.tpl", {
    dns_server_ip                = azurerm_private_dns_resolver_inbound_endpoint.dns-inbound.ip_configurations[0].private_ip_address
    chat_certificate_cn          = local.chat_certificate_cn
    azure_openai_deployment_name = azurerm_cognitive_deployment.aviatrix.name
    azure_openai_model           = azurerm_cognitive_deployment.aviatrix.model[0].name
    azure_openai_key             = azurerm_cognitive_account.aviatrix-ignite.primary_access_key
    azure_openai_endpoint        = azurerm_cognitive_account.aviatrix-ignite.endpoint
    azure_search_service         = azurerm_search_service.aviatrix-ignite-search.name
    azure_search_index           = "oai-data-index"
    customer_name                = var.customer_name
  })
  cloud_init_config_dmz = templatefile("${path.module}/script-dmz.sh.tpl", {
    dns_server_ip                = azurerm_private_dns_resolver_inbound_endpoint.dns-inbound.ip_configurations[0].private_ip_address
    chat_certificate_cn          = local.chat_certificate_cn
    app_certificate_cn           = local.app_certificate_cn
    azure_openai_deployment_name = azurerm_cognitive_deployment.aviatrix.name
    azure_openai_model           = azurerm_cognitive_deployment.aviatrix.model[0].name
    azure_openai_key             = azurerm_cognitive_account.aviatrix-ignite.primary_access_key
    azure_openai_endpoint        = azurerm_cognitive_account.aviatrix-ignite.endpoint
    azure_search_service         = azurerm_search_service.aviatrix-ignite-search.name
    azure_search_index           = "oai-data-index"
    container_ip_address         = azurerm_container_group.app_container_group.ip_address
    aws_oai_server_ip_address    = module.ec2_instance_linux.private_ip
  })
}

variable "certificate_cn" {
  description = "Common Name for the SSL certificate"
  type        = string
  default     = "dummy"
}

variable "application_1" {
  description = "Application 1 name"
  default     = "myapp1"
}

variable "customer_name" {
  description = "Customer name"
  default     = "contoso"
}

variable "customer_website" {
  description = "Customer website like www.aviatrix.com"
  default     = "www.aviatrix.com"
}
