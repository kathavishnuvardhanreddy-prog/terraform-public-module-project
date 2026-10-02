output "vpc_id" {
  description = "ID of the VPC created by the public Terraform module"
  value       = module.vpc.vpc_id
}
