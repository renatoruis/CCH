resource "null_resource" "update" {
  depends_on = [
    module.eks-cluster
  ]
  provisioner "local-exec" {
    command = "AWS_DEFAULT_REGION=${var.aws-region} aws eks update-kubeconfig --name ${var.cluster-name} --kubeconfig kubeconfig-stone.yaml"
  }
}