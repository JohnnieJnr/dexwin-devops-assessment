variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "production"
}

variable "public_access" {
  type        = bool
  description = "Whether the service should be reachable from the public internet."
  default     = true
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDR ranges allowed to reach the service."
  default     = ["0.0.0.0/0"]
}
