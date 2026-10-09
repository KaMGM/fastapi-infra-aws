variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "instanceType" {
  description = "le type d'instance"
  type        = string
  
}


variable "cpu" {
    description = "la valeur du cpu"
}

variable "memory" {
    description = "la memoire"
}

variable "ami_bastion" {
  description = "le type d'image"
  type        = string
}

variable "mail" {
    description = "l'adresse e-mail pour les alertes"
}