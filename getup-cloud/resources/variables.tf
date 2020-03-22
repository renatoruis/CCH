variable "name" {
  default = "bardodevops.com.br"
}
variable "region" {
  default = "us-east-1"
}
variable "instances_master_type" {
  default = "t2.micro"
}
variable "instances_node_type" {
  default = "t2.micro"
}
variable "env" {
  default = "prod"
}
variable "availability_zones" {
  type = "list"
  default = ["us-east-1a", "us-east-1c", "us-east-1d"]
}