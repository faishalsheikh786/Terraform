provider aws {
  region = "us-east-1"
}

module ec2_instance {
  source        = "./modules/ec2_instance"
  ami_id        = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace)
  instance_name = var.instance_name
  project_name  = var.project_name
  environment   = var.environment
  owner         = var.owner
}