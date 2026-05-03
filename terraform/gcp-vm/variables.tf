# ============================================================
# Variables
# ============================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast2"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-southeast2-a"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vm_name" {
  description = "VM instance name prefix"
  type        = string
  default     = "app-server"
}

variable "machine_type_dev" {
  description = "Machine type for dev environment"
  type        = string
  default     = "e2-medium"
}

variable "machine_type_prod" {
  description = "Machine type for production environment"
  type        = string
  default     = "n2-standard-4"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 50
}

variable "boot_disk_type" {
  description = "Boot disk type (pd-ssd, pd-standard, pd-balanced)"
  type        = string
  default     = "pd-ssd"
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
  default     = "custom-vpc"
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.20.0.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR ranges allowed for SSH (use 35.235.235.0/24 for IAP)"
  type        = list(string)
  default     = ["35.235.235.0/24"]  # Google IAP CIDR
}

variable "allowed_http_cidrs" {
  description = "CIDR ranges allowed for HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ops_agent_config_path" {
  description = "Path to Ops Agent config file (local)"
  type        = string
  default     = "ops-agent-config.yaml"
}

variable "tags" {
  description = "Additional tags/labels for resources"
  type        = map(string)
  default     = {}
}
