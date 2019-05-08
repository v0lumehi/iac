
variable "prefix" {
  default = "zaljic"
}
variable "azs" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "dns_zone" {
  description = "iac training dns zone"
  default = "iac.trainings.jambit.de."
}

variable "host_count" {
  default = 1
}

variable "ssh_private_key" {
  default = "/Users/zaljic/.ssh/id_rsa"
}
