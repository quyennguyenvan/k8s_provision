
output "aws_eks_cluster" {
  value = module.eks.cluster_id
}
output "aws_eks_cluster_auth" {
  value = module.eks.cluster_id
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "certificate_authority" {
  value = module.eks.cluster_certificate_authority_data.0.data
}

