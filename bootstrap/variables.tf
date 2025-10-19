variable "aws_region"        { type = string  default = "sa-east-1" }
variable "gh_owner"          { type = string  description = "GitHub org/user" }
variable "gh_repo"           { type = string  description = "GitHub repository name" }
variable "state_bucket_name" { type = string  default = "tfstate-7t-demo" }
variable "lock_table_name"   { type = string  default = "tf-locks-7t-demo" }
