variable "profile" {
  description = "Profile from credentials"
  default     = "default"
}

variable "tag_name" {}
variable "tag_application" {}
variable "tag_team" {}
variable "tag_environment" {}
variable "tag_contact_email" {}

variable "region" {
  description = "Region"
}

variable "availability_zone" {
  description = "which availabity zone to run the master on"  
}

variable "cluster_id" {}
variable "db_name" {}
variable "master_username" {}
variable "master_password" {}

variable "encrypted" {
  description = "whether or not to encrypt the database"
}

variable "skip_final_snapshot" {
  description = "whether or not to skip final snapshot when destroying"
}
variable "number_of_nodes" {
  description = "usually 3"
}

variable "cluster_type" {
  description = "usually multi-node"
}

variable "node_type" {
  description = "usually dc1.large"
}