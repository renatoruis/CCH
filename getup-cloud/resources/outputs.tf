output "name" {
  value = "${var.name}"
}
output "cluster_name" {
  value = "${var.env}.${var.name}"
}
output "name_servers" {
  value = "${aws_route53_zone.public.name_servers}"
}
output "public_zone_id" {
  value = "${aws_route53_zone.public.zone_id}"
}
output "kops-store" {
  value = "s3://${aws_s3_bucket.kops-store.id}"
}
output "availability_zones" {
  value = "${var.availability_zones}"
}
output "instances_master_type" {
  value = "${var.instances_master_type}"
}

output "instances_node_type" {
  value = "${var.instances_node_type}"
}
