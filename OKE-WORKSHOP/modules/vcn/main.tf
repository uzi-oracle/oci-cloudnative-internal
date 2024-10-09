# modules/vcn/main.tf

variable "compartment_id" {
  description = "The OCID of the compartment to create the VCN in"
  type        = string
}

variable "vcn_display_name" {
  description = "The display name of the VCN"
  type        = string
}

variable "vcn_dns_label" {
  description = "The DNS label of the VCN"
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block of the VCN"
  type        = string
}

variable "service_cidr" {
  description = "The Service CIDR for the region"
  type        = string
}

variable "lb_subnet_cidr" {
  description = "CIDR for the load balancer subnet"
  type        = string
}

variable "node_subnet_cidr" {
  description = "CIDR for the node subnet"
  type        = string
}

variable "api_endpoint_subnet_cidr" {
  description = "CIDR for the Kubernetes API endpoint subnet"
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  display_name   = "${var.vcn_display_name}-ig"
  vcn_id         = oci_core_vcn.vcn.id
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_id
  display_name   = "${var.vcn_display_name}-nat"
  vcn_id         = oci_core_vcn.vcn.id
  freeform_tags  = var.freeform_tags
}

resource "oci_core_service_gateway" "sg" {
  compartment_id = var.compartment_id
  display_name   = "${var.vcn_display_name}-sg"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
  vcn_id        = oci_core_vcn.vcn.id
  freeform_tags = var.freeform_tags
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-private-route-table"
  freeform_tags  = var.freeform_tags

  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

  route_rules {
    description       = "traffic to OCI services"
    destination       = var.service_cidr
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sg.id
  }
}

resource "oci_core_default_route_table" "public_route_table" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  display_name               = "${var.vcn_display_name}-public-route-table"
  freeform_tags              = var.freeform_tags

  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
}

resource "oci_core_subnet" "service_lb_subnet" {
  cidr_block        = var.lb_subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "${var.vcn_display_name}-lb-subnet"
  dns_label         = "lbsubnet"
  route_table_id    = oci_core_default_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.service_lb_sec_list.id]
  freeform_tags     = var.freeform_tags
}

resource "oci_core_subnet" "node_subnet" {
  cidr_block                 = var.node_subnet_cidr
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = "${var.vcn_display_name}-node-subnet"
  dns_label                  = "nodesubnet"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.node_sec_list.id]
  freeform_tags              = var.freeform_tags
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
  cidr_block        = var.api_endpoint_subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "${var.vcn_display_name}-k8s-api-endpoint-subnet"
  dns_label         = "k8sapi"
  route_table_id    = oci_core_default_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.kubernetes_api_endpoint_sec_list.id]
  freeform_tags     = var.freeform_tags
}

resource "oci_core_security_list" "service_lb_sec_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-lb-security-list"
  freeform_tags  = var.freeform_tags

  # Add ingress and egress rules as needed
}

resource "oci_core_security_list" "node_sec_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-node-security-list"
  freeform_tags  = var.freeform_tags

  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = var.node_subnet_cidr
    protocol         = "all"
    stateless        = false
    destination_type = "CIDR_BLOCK"
  }
egress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	egress_security_rules {
		description = "Access to Kubernetes API Endpoint"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Kubernetes worker to control plane communication"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
		destination = "all-fra-services-in-oracle-services-network"
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "ICMP Access from Kubernetes Control Plane"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Worker Nodes access to Internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		protocol = "all"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.0.0/28"
		stateless = "false"
	}
	ingress_security_rules {
		description = "TCP access from Kubernetes Control Plane"
		protocol = "6"
		source = "10.0.0.0/28"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Inbound SSH traffic to worker nodes"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}

}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-k8s-api-endpoint-security-list"
  freeform_tags  = var.freeform_tags
	egress_security_rules {
		description = "Allow Kubernetes Control Plane to communicate with OKE"
		destination = "all-fra-services-in-oracle-services-network"
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "All traffic to worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to Kubernetes API endpoint communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to control plane communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.10.0/24"
		stateless = "false"
	}

}

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.vcn.id
}

output "service_lb_subnet_id" {
  description = "OCID of the service load balancer subnet"
  value       = oci_core_subnet.service_lb_subnet.id
}

output "node_subnet_id" {
  description = "OCID of the node subnet"
  value       = oci_core_subnet.node_subnet.id
}

output "kubernetes_api_endpoint_subnet_id" {
  description = "OCID of the Kubernetes API endpoint subnet"
  value       = oci_core_subnet.kubernetes_api_endpoint_subnet.id
}
