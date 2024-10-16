compartment_id = "ocid1.compartment.oc1..aaaaaaaaancwtscymcqte5ejuwjta64jdkedgv7rh3gvulu5csumeh6upfpq"
region         = "eu-frankfurt-1"

# VCN variables
vcn_display_name = "oke-vcn-quick-oke-workshop"
vcn_dns_label    = "okeworkshop"
vcn_cidr         = "10.0.0.0/16"
service_cidr     = "all-fra-services-in-oracle-services-network"

# Subnet variables
lb_subnet_cidr           = "10.0.20.0/24"
node_subnet_cidr         = "10.0.10.0/24"
api_endpoint_subnet_cidr = "10.0.0.0/28"

# OKE variables
cluster_name       = "oke-workshop"
kubernetes_version = "v1.30.1"
node_pool_name     = "pool1"
node_pool_size     = 3
node_pool_shape    = "VM.Standard.E5.Flex"
node_pool_ocpus    = 1
node_pool_memory   = 12

# Tags
freeform_tags = {
  "OKEclusterName" = "oke-workshop"
}

# Availability Domains
availability_domains = ["EcFq:EU-FRANKFURT-1-AD-1", "EcFq:EU-FRANKFURT-1-AD-2", "EcFq:EU-FRANKFURT-1-AD-3"]

oci_cli_profile = "DEFAULT"
node_pool_image_id = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaacpou4dba57cb53wflerkiut2wvauixc2tkdg6utoyhzzbtkahrsa"
availability_domain = "EcFq:EU-FRANKFURT-1-AD-1"                                                                                                               
