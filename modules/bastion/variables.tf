variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}


variable "public_subnet_ids" {
  description = "List of public subnet IDs for EKS"
  type        = list(string)
}

variable "bastion" {
  description = "Configuration for bastion host"
  type = object({
    instance_type       = string
    bastion_volume_size = string
    bastion_volume_type = string
  })
}
variable "pem_key" {
  type = string
}

variable "eks_security_group_id" {
  description = "EKS Cluster Security Group ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}