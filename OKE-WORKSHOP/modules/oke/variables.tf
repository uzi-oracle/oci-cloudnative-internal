# modules/oke/variables.tf

variable "compartment_id" {
  description = "The OCID of the compartment in which to create resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the OKE cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the OKE cluster"
  type        = string
}

variable "vcn_id" {
  description = "The OCID of the VCN in which to create the OKE cluster"
  type        = string
}

variable "is_api_endpoint_public" {
  description = "Whether the Kubernetes API endpoint should have a public IP"
  type        = bool
  default     = true
}

variable "api_endpoint_subnet_id" {
  description = "The OCID of the subnet to use for the Kubernetes API endpoint"
  type        = string
}

variable "enable_kubernetes_dashboard" {
  description = "Whether to enable the Kubernetes dashboard"
  type        = bool
  default     = false
}

variable "enable_tiller" {
  description = "Whether to enable Tiller (Helm v2)"
  type        = bool
  default     = false
}

variable "enable_pod_security_policy" {
  description = "Whether to enable pod security policies"
  type        = bool
  default     = false
}

variable "pods_cidr" {
  description = "The CIDR block for Kubernetes pods"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "The CIDR block for Kubernetes services"
  type        = string
  default     = "10.96.0.0/16"
}

variable "lb_subnet_id" {
  description = "The OCID of the subnet to use for Kubernetes load balancers"
  type        = string
}

variable "node_pool_name" {
  description = "The name of the node pool"
  type        = string
}

variable "node_pool_shape" {
  description = "The shape of the nodes in the node pool"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain in which to place nodes"
  type        = string
}

variable "node_subnet_id" {
  description = "The OCID of the subnet to use for worker nodes"
  type        = string
}

variable "node_pool_size" {
  description = "The number of nodes in the node pool"
  type        = number
}

variable "node_pool_node_memory_in_gbs" {
  description = "The amount of memory to allocate to each node in the node pool, in gigabytes"
  type        = number
}

variable "node_pool_node_ocpus" {
  description = "The number of OCPUs to allocate to each node in the node pool"
  type        = number
}

variable "node_pool_image_id" {
  description = "The OCID of the image to use for nodes in the node pool"
  type        = string
}

