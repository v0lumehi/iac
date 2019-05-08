variable "prefix" {
  default = "zaljic"
}

variable "azs" {
  type    = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "dns_zone" {
  description = "iac training dns zone"
  default     = "iac.trainings.jambit.de."
}

variable "host_count" {
  default = 3
}

variable "loadbalancer_count" {
  default = 1
}

variable "ssh_private_key" {
  default = "/Users/zaljic/.ssh/id_rsa"
}

variable "certificate_arn" {
  default = "arn:aws:acm:eu-west-1:287283636362:certificate/313ef381-b7c9-4e81-a6ab-e19ab4ec8106"
}
