resource "aws_instance" "name" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
    Project = var.project_name
    Environment = var.environment
    Owner = var.owner
  }
}