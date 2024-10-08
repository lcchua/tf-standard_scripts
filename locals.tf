# Uncomment as needed including the availability_zones attribute in the locals block below

# This data block generates a dynamic list of availability zones per the region specified in aws provider.tf
data "aws_availability_zones" "available" { // Best to name this according to the 'state' filter
  state = "available"
}
output "azs-list" {
  description = "stw availability zones in region"
  value       = data.aws_availability_zones.available.names[*]
}

# Adjust based on your region
locals {
  #availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  availability_zones = data.aws_availability_zones.available.names[*]
}
