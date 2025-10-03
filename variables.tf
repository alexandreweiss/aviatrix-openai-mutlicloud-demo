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
  default     = "eu-central-1"
}

variable "aws_r1_location_short" {
  description = "Short name of Region 1"
  default     = "fra"
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

variable "dns_prefix" {
  description = "DNS Prefix for the chat bot"
  default     = "chat"
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
  }
  cloud_init_config = templatefile("${path.module}/script.sh.tpl", {
    dns_server_ip                = azurerm_private_dns_resolver_inbound_endpoint.dns-inbound.ip_configurations[0].private_ip_address
    certificate_cn               = var.dns_zone_name == "dummy" ? "chat.aviatrix.local" : "${var.dns_prefix}.${var.dns_zone_name}"
    azure_openai_deployment_name = azurerm_cognitive_deployment.aviatrix.name
    azure_openai_model           = azurerm_cognitive_deployment.aviatrix.model[0].name
    azure_openai_key             = azurerm_cognitive_account.aviatrix-ignite.primary_access_key
    azure_openai_endpoint        = azurerm_cognitive_account.aviatrix-ignite.endpoint
    azure_search_service         = azurerm_search_service.aviatrix-ignite-search.name
    azure_search_index           = "oai-data-index"
  })
}

variable "dns_server_ip" {
  description = "DNS server IP address"
  type        = string
  default     = "10.147.70.116"
}

variable "certificate_cn" {
  description = "Common Name for the SSL certificate"
  type        = string
  default     = "chat.aviatrix.local"
}
