variable "prefix" {
  description = "jambit username"
  default = "zaljic"
}

variable "dns_zone" {
  description = "iac training dns zone"
  default = "iac.trainings.jambit.de."
}

variable "host_count" {
  default = 3
}
