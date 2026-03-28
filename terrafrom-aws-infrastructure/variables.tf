variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}

# variable "instance_type" {
#   description = "The type of instance to create"
#   type        = string
# }

variable "instance_type" {
  description = "The type of instance to create"
  type        = map(string)

  default = {
    "dev" = "t3.micro"
    "stage" = "t3.small"
    "prod" = "t3.medium"
  }
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
}

variable "project_name" {
  description = "The project name for tagging"
  type        = string
  default     = "TalentCogentProject"
}

variable "environment" {
  description = "The environment for tagging"
  type        = string
}

variable "owner" {
  description = "The owner for tagging"
  type        = string
}