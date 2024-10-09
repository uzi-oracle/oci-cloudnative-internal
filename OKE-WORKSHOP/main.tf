module "vcn" {
  source                   = "./modules/vcn"
  compartment_id           = var.compartment_id
  vcn_display_name         = var.vcn_display_name
  vcn_dns_label            = var.vcn_dns_label
  vcn_cidr                 = var.vcn_cidr
  service_cidr             = var.service_cidr
  lb_subnet_cidr           = var.lb_subnet_cidr
  node_subnet_cidr         = var.node_subnet_cidr
  api_endpoint_subnet_cidr = var.api_endpoint_subnet_cidr
  freeform_tags            = var.freeform_tags
}

module "oke" {
  source = "./modules/oke"

  compartment_id              = var.compartment_id
  cluster_name                = var.cluster_name
  kubernetes_version          = var.kubernetes_version
  vcn_id                      = module.vcn.vcn_id
  api_endpoint_subnet_id      = module.vcn.kubernetes_api_endpoint_subnet_id
  lb_subnet_id                = module.vcn.service_lb_subnet_id
  node_subnet_id              = module.vcn.node_subnet_id
  node_pool_name              = var.node_pool_name
  node_pool_shape             = var.node_pool_shape
  availability_domain         = var.availability_domain
  node_pool_size              = var.node_pool_size
  node_pool_node_memory_in_gbs = var.node_pool_node_memory_in_gbs
  node_pool_node_ocpus        = var.node_pool_node_ocpus
  node_pool_image_id          = var.node_pool_image_id

  # You can override defaults here if needed
  # is_api_endpoint_public     = true
  # enable_kubernetes_dashboard = false
  # enable_tiller              = false
  # enable_pod_security_policy = false
  # pods_cidr                  = "10.244.0.0/16"
  # services_cidr              = "10.96.0.0/16"
}
