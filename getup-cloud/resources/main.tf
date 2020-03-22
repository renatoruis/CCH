provider "aws" {
  region = "${var.region}"
}

resource "aws_route53_zone" "public" {
  name          = "${var.name}"
  force_destroy = true

  tags {
    Name        = "${var.name}-${var.env}-zone-public"
    Environment = "${var.env}"
    Terraformed = "true"
  }
}

resource "aws_s3_bucket" "kops-store" {
  bucket        = "${var.name}-kops-store"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags {
    Name        = "${var.name}-${var.env}-kops-store"
    Environment = "${var.env}"
    Terraformed = "true"
  }
}
