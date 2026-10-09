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
  default     = "t2.micro"
}


variable "cpu" {
    description = "la valeur du cpu"
    default     = 256
}

variable "memory" {
    description = "la memoire"
    default     = 512

}

variable "ami_bastion" {
  description = "le type d'image"
  type        = string
  default     = "dev"
}

variable "mail" {
    description = "l'adresse mail pour les alertes"
}
