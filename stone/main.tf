provider "aws" {
  region     = var.aws-region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

module "eks-vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${var.cluster-name}-eks-vpc"
  cidr = var.vpc-cidr
  azs             = var.availability_zones[var.aws-region]
  private_subnets = var.vpc-private-cidrs
  public_subnets  = var.vpc-public-cidrs

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform                                   = "True"
    Name                                        = "${var.cluster-name}-eks-vpc"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }

}


module "eks-cluster" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v12.1.0"
  cluster_name = var.cluster-name
  vpc_id       = module.eks-vpc.vpc_id
  subnets      = module.eks-vpc.private_subnets

  node_groups = {
    eks_nodes = {
      desired_capacity = var.asg-desired
      max_capacity     = var.asg-max
      min_capaicty     = var.asg-min

      instance_type = var.instance-type
    }
  }

  manage_aws_auth = false
}


resource "kubernetes_namespace" "namespace-monitoramento" {
  metadata {
    annotations = {
      name = var.namespace_monitoramento
    }
    name = var.namespace_monitoramento
  }
}

resource "kubernetes_secret" "prometheus-datasource" {
  depends_on = [
    kubernetes_namespace.namespace-monitoramento,
    module.eks-cluster
  ]
  metadata {
    name      = "prometheus-datasource"
    namespace = var.namespace_monitoramento
  }

  data = {
    "datasource.yaml" = "${file("${path.module}/files/prometheus-datasource.yaml")}"
  }

}

resource "kubernetes_config_map" "dashboard-goldpinger" {
  depends_on = [
    kubernetes_namespace.namespace-monitoramento,
    module.eks-cluster
  ]
  metadata {
    name      = "dashboard-goldpinger"
    namespace = var.namespace_monitoramento
  }

  data = {
    "goldpinger-dashboard.json" = "${file("${path.module}/files/goldpinger-dasboard.json")}"
  }

}

resource "kubernetes_config_map" "dashboard-k8s" {
  depends_on = [
    kubernetes_namespace.namespace-monitoramento,
    module.eks-cluster
  ]
  metadata {
    name      = "dashboard-k8s"
    namespace = var.namespace_monitoramento
  }

  data = {
    "dashboard-k8s.json" = "${file("${path.module}/files/dashboard-k8s.json")}"
  }

}

resource "helm_release" "goldpinger" {
  depends_on = [
    kubernetes_namespace.namespace-monitoramento,
    module.eks-cluster
  ]
  name       = "goldpinger"
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "goldpinger"
  version    = "2.0.2"
  namespace  = var.namespace_monitoramento

}

resource "helm_release" "ping-exporter" {
  depends_on = [
    kubernetes_namespace.namespace-monitoramento,
    module.eks-cluster
  ]
  name       = "ping-exporter"
  repository = "https://renatoruis.github.io/helm-charts/"
  chart      = "ping-exporter"

  # set {
  #   name  = "namespace"
  #   value = var.namespace_monitoramento
  # }
}

resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_namespace.namespace-monitoramento,
    module.eks-cluster,
    helm_release.ping-exporter
  ]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = var.namespace_monitoramento

  # set {
  #   name  = "nodeExporter.extraArgs"
  #   value = "collector.textfile.directory: /tmp/ping-metrics"
  # }

  values = [
    "${file("${path.module}/files/prometheus-values.yaml")}"
  ]
}

resource "helm_release" "grafana" {
  depends_on = [
    module.eks-cluster,
    helm_release.prometheus,
    kubernetes_namespace.namespace-monitoramento,
    kubernetes_config_map.dashboard-goldpinger,
    kubernetes_secret.prometheus-datasource
  ]
  name       = "grafana"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "grafana"
  namespace  = var.namespace_monitoramento

  set {
    name  = "dashboardsProvider.enabled"
    value = "true"
  }

  set {
    name  = "datasources.secretName"
    value = kubernetes_secret.prometheus-datasource.metadata[0].name
  }

  set {
    name  = "dashboardsConfigMaps[0].configMapName"
    value = "dashboard-goldpinger"
  }

  set {
    name  = "dashboardsConfigMaps[0].fileName"
    value = "goldpinger-dashboard.json"
  }

  set {
    name  = "dashboardsConfigMaps[1].configMapName"
    value = "dashboard-k8s"
  }

  set {
    name  = "dashboardsConfigMaps[1].fileName"
    value = "dashboard-k8s.json"
  }
}