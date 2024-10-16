# modules/oke/main.tf

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  type               = "ENHANCED_CLUSTER"

  endpoint_config {
    is_public_ip_enabled = var.is_api_endpoint_public
    subnet_id            = var.api_endpoint_subnet_id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.enable_kubernetes_dashboard
      is_tiller_enabled               = var.enable_tiller
    }

    admission_controller_options {
      is_pod_security_policy_enabled = var.enable_pod_security_policy
    }

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    service_lb_subnet_ids = [var.lb_subnet_id]
  }
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.node_pool_name
  node_shape         = var.node_pool_shape

  node_config_details {
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.node_subnet_id
    }
    size = var.node_pool_size
  }

  node_shape_config {
    memory_in_gbs = var.node_pool_node_memory_in_gbs
    ocpus         = var.node_pool_node_ocpus
  }

  node_source_details {
    image_id    = var.node_pool_image_id
    source_type = "IMAGE"
  }

  initial_node_labels {
    key   = "name"
    value = var.cluster_name
  }

}

data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id
}

resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
  filename = "${path.root}/kubeconfig"
}
