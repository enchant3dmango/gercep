output "network_name" {
  description = "The name of the VPC being created"
  value       = module.vpc.network_name
}

output "subnet_names" {
  description = "The names of the subnets being created"
  value       = module.vpc.subnets_names
}

output "subnets_secondary_ranges" {
  description = "The secondary ranges associated with these subnets"
  value       = module.vpc.subnets_secondary_ranges
}

output "ip_range_pods" {
  description = "The IP range pods associated with the default subnet"
  value       = module.vpc.subnets_secondary_ranges[0].*.range_name[0]
}

output "ip_range_services" {
  description = "The IP range services associated with the default subnet"
  value       = module.vpc.subnets_secondary_ranges[0].*.range_name[1]
}
