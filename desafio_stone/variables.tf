# Variables Configuration

variable "aws-region" {
  default     = "us-east-2"
  type        = string
  description = "The AWS Region to deploy EKS"
}

variable "namespace_monitoramento" {
  default     = "monitoramento"
  type        = string
  description = "Namespace para monitoramento"
}

variable "cluster-name" {
  default     = "eks-demo"
  type        = string
  description = "The name of your EKS Cluster"
}



variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "The VPC CIDR"
}

variable "vpc-public-cidrs" {
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  type        = list
  description = "The VPC public-subnet CIDR"
}

variable "vpc-private-cidrs" {
  default     = ["10.0.10.0/23", "10.0.12.0/23", "10.0.14.0/23"]
  type        = list
  description = "The VPC private-subnet CIDR"
}

variable "instance-type" {
  default     = "t2.small"
  type        = string
  description = "Worker Node EC2 instance type"
}

variable "asg-desired" {
  default     = 3
  type        = number
  description = "Autoscaling Desired node capacity"
}

variable "asg-max" {
  default     = 5
  type        = number
  description = "Autoscaling maximum node capacity"
}

variable "asg-min" {
  default     = 1
  type        = number
  description = "Autoscaling Minimum node capacity"
}

variable "availability_zones" {
  type = map

  default = {
    us-east-1      = ["us-east-1a", "us-east-1b", "us-east-1c"]
    us-east-2      = ["us-east-2a", "us-east-2b", "us-east-2c"]
    us-west-1      = ["us-west-1a", "us-west-1c"]
    us-west-2      = ["us-west-2a", "us-west-2b", "us-west-2c"]
    ca-central-1   = ["ca-central-1a", "ca-central-1b"]
    eu-west-1      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    eu-west-2      = ["eu-west-2a", "eu-west-2b"]
    eu-central-1   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    ap-south-1     = ["ap-south-1a", "ap-south-1b"]
    sa-east-1      = ["sa-east-1a", "sa-east-1c"]
    ap-northeast-1 = ["ap-northeast-1a", "ap-northeast-1c"]
    ap-southeast-1 = ["ap-southeast-1a", "ap-southeast-1b"]
    ap-southeast-2 = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    ap-northeast-1 = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
    ap-northeast-2 = ["ap-northeast-2a", "ap-northeast-2c"]
  }
}

