variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "my_IP" {
  description = "Path to SSH public key"
  type        = string
}