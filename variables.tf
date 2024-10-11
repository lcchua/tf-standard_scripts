# FIRST STEP - TO CHANGE THE APPROPRIATE TF CONFIGURATION PARAMETERS BELOW

variable "stack_name" {
  type    = string
  default = "lcchua-stw"
}

variable "key_name" {
  description = "Name of EC2 Key Pair"
  type        = string
  default     = "lcchua-temp-user-08082024"
}

variable "region" {
  description = "Name of aws region"
  type        = string
  default     = "us-east-1"
}

variable "subnets_count" {
  description = "Number of public & private subnets"
  type        = map(number)
  default = {
    public  = 3,
    private = 3
  }
}

variable "settings" {
  description = "Configuration settings for EC2 and RDS instances"
  type        = map(any)
  default = {
    "database" = {                      // rename the var name according to use
      allocate_storage = 10             // storage in GB
      engine           = "mysql"        // engine type
      engine_version   = "8.0"          // engine_version
      instance_class   = "db.t4g.micro" // rds instance type
      #db_name             = "eom2_tutorial"  // database name if need be
      db_username         = "admin" // database admin username
      skip_final_snapshot = true
    },
    "web_app" = {                // rename the var name according to use
      count         = 1          // number of ec2 instances
      instance_type = "t2.micro" // ec2 instance type
    }
  }
}

variable "env" {
  description = "Environment of the build"
  type        = string
}

variable "rnd_id" {
  description = "Suffix random identifier of the build resource"
  type        = string
}

# Uncomment this block as needed if the "settings" variable is not being used instead.
/*
# This varaible to hold your IP address for setting up the 
# EC2 security group SSH rule which is stored in a secrets
# file (eg. secrets.tfvars).
#     - for example as <my_ip = "116.86.159.189"> in this file
variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
}
# This variable to hold the database master username which
# will be stored in a secrets file (eg. secrets.tfvars).
#     - for example as <db_username = "admin"> in this file
variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}
# This variable to hold the database master password which 
# will be stored in a secrets file (eg. secrets.tfvars).
#     - for example as <db_password = "password"> in this file
variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}
*/

# Uncomment as needed if the "settings" variable is not being used instead.
/*
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
*/
