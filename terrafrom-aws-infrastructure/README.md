# Terraform AWS EC2 Infrastructure

## Overview

This repository contains **Terraform Infrastructure as Code (IaC)** used to provision **AWS EC2 instances** using a **modular Terraform architecture**.

The project is designed to support **multiple environments (dev, stage, prod)** and uses:

* **Terraform modules** for reusable infrastructure code
* **S3 backend** for storing Terraform state
* **DynamoDB table** for state locking
* **Environment-specific tfvars files**
* **Terraform workspaces** for environment separation

This approach follows **industry best practices for Infrastructure as Code**.

---

# Architecture

The infrastructure follows this architecture:

```
Terraform Root Configuration
        │
        │
        ▼
Terraform Module (modules/ec2_instance)
        │
        │
        ▼
AWS EC2 Instance
```

The root configuration calls a **Terraform module**, which creates the EC2 instance using parameters defined in **tfvars files**.

---

# Repository Structure

```
.
├── backend.tf
├── main.tf
├── variables.tf
├── terraform-dev.tfvars
├── terraform-stage.tfvars
├── terraform-prod.tfvars
├── .terraform.lock.hcl
│
├── modules
│   └── ec2_instance
│       ├── main.tf
│       └── variables.tf
│
└── terraform.tfstate.d
    ├── dev
    ├── stage
    └── prod
```

---

# Explanation of Each File

---

# 1. modules/ec2_instance/main.tf

This file defines the **actual AWS EC2 instance resource**.

```
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
```

### Explanation

This resource tells Terraform to create an **EC2 instance**.

| Argument      | Purpose                            |
| ------------- | ---------------------------------- |
| ami           | AMI ID used to launch the instance |
| instance_type | EC2 instance size                  |
| tags          | Metadata attached to the instance  |

Tags help in:

* Cost allocation
* Resource tracking
* Environment identification

Example AWS output:

```
Name: DevInstance
Project: TalentCogentProject
Environment: dev
Owner: Faishal
```

---

# 2. modules/ec2_instance/variables.tf

This file defines **input variables** for the module.

Terraform modules should **not hardcode values**, instead they accept variables.

Example:

```
variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}
```

Variables defined:

| Variable      | Description     |
| ------------- | --------------- |
| ami_id        | EC2 image ID    |
| instance_type | Instance size   |
| instance_name | Name tag        |
| project_name  | Project tag     |
| environment   | Environment tag |
| owner         | Owner tag       |

These variables make the module **reusable**.

---

# 3. backend.tf

```
terraform {
  backend "s3" {
    bucket         = "faishal-bucket-1234567890"
    key            = "faishal/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
```

This file configures **Terraform remote state storage**.

Instead of storing state locally, Terraform stores it in:

### S3 Bucket

```
faishal-bucket-1234567890
```

State file location:

```
faishal/terraform.tfstate
```

### DynamoDB Table

```
terraform-lock
```

Used for **state locking**.

State locking prevents multiple users from running Terraform at the same time.

Example scenario prevented:

```
User A running terraform apply
User B running terraform apply
```

Without locking → infrastructure corruption.

---

# 4. main.tf (Root Module)

```
provider aws {
  region = "us-east-1"
}
```

Defines the **AWS provider configuration**.

---

### Calling the EC2 Module

```
module ec2_instance {
  source        = "./modules/ec2_instance"
  ami_id        = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace)
  instance_name = var.instance_name
  project_name  = var.project_name
  environment   = var.environment
  owner         = var.owner
}
```

This tells Terraform:

```
Use the module located in ./modules/ec2_instance
```

and pass variables to it.

---

# Terraform Workspace Logic

```
lookup(var.instance_type, terraform.workspace)
```

Terraform workspace determines the environment.

Example:

| Workspace | Instance Type |
| --------- | ------------- |
| dev       | t3.micro      |
| stage     | t3.small      |
| prod      | t3.medium     |

This allows environment-specific infrastructure.

---

# 5. terraform-dev.tfvars

Example:

```
ami_id        = "ami-0ecb62995f68bb549"
instance_name = "DevInstance"
project_name  = "TalentCogentProject"
environment   = "dev"
owner         = "Faishal"
```

This file stores **environment-specific values**.

Instead of editing Terraform code, we pass variables using tfvars.

Example environments:

```
terraform-dev.tfvars
terraform-stage.tfvars
terraform-prod.tfvars
```

---

# Terraform Workflow (Step-by-Step)

Below are the **commands used to run this Terraform project from start to finish**.

---

# Step 1 — Initialize Terraform

```
terraform init
```

### What this command does

* Downloads required **provider plugins**
* Configures the **S3 backend**
* Connects to **DynamoDB state locking**
* Creates the `.terraform` directory
* Prepares Terraform to run infrastructure commands

Example output:

```
Terraform has been successfully initialized!
```

This command should be run **only once when setting up the project or after changes to backend/providers**.

---

# Step 2 — Format Terraform Code

```
terraform fmt
```

### Purpose

Formats Terraform files according to standard style conventions.

Benefits:

* Consistent code formatting
* Easier collaboration
* Cleaner pull requests

Example fixes:

* indentation
* spacing
* consistent alignment

---

# Step 3 — Validate Terraform Configuration

```
terraform validate
```

### Purpose

Checks whether the Terraform configuration files are **syntactically correct**.

Terraform verifies:

* variables are correctly defined
* modules exist
* resource configuration is valid

Example output:

```
Success! The configuration is valid.
```

---

# Step 4 — Create or Select Workspace

Workspaces allow **multiple environments using the same Terraform code**.

### Create a new workspace

```
terraform workspace new dev
```

### Switch to an existing workspace

```
terraform workspace select dev
```

### List all workspaces

```
terraform workspace list
```

Example output:

```
default
* dev
stage
prod
```

`*` indicates the **current active workspace**.

Each workspace maintains its **own Terraform state**.

---

# Step 5 — Plan Infrastructure Changes

```
terraform plan -var-file="terraform-dev.tfvars"
```

### Purpose

Shows what Terraform **will create, modify, or destroy** before making changes.

Terraform compares:

```
Current state vs Desired state
```

Example output:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

This step is important because it allows engineers to **review infrastructure changes safely before applying them**.

---

# Step 6 — Apply Infrastructure

```
terraform apply -var-file="terraform-dev.tfvars"
```

### Purpose

Creates or updates infrastructure in AWS.

Terraform will ask confirmation:

```
Do you want to perform these actions?
```

Type:

```
yes
```

Terraform then provisions the EC2 instance.

Example output:

```
aws_instance.name: Creation complete
```

After completion, the EC2 instance will be visible in the **AWS Console**.

---

# Step 7 — Verify Infrastructure

After running `terraform apply`, verify the instance.

Open:

```
AWS Console → EC2 → Instances
```

Expected tags:

```
Name: DevInstance
Project: TalentCogentProject
Environment: dev
Owner: Faishal
```

---

# Step 8 — Destroy Infrastructure (Optional)

```
terraform destroy -var-file="terraform-dev.tfvars"
```

### Purpose

Deletes all infrastructure created by Terraform.

Terraform will ask confirmation:

```
Do you really want to destroy all resources?
```

Type:

```
yes
```

This removes the EC2 instance and updates the Terraform state.

---

# Terraform Workspaces

Workspaces allow **multiple environments using the same code**.

Example environments:

```
dev
stage
prod
```

Terraform stores state separately for each workspace.

Example directory:

```
terraform.tfstate.d/
   dev/
   stage/
   prod/
```

---

# Tagging Strategy

Each EC2 instance is tagged with:

```
Name
Project
Environment
Owner
```

Benefits:

* Cost tracking
* Resource grouping
* Environment identification

---

# Prerequisites

Before using this repository, install:

### Terraform

```
https://developer.hashicorp.com/terraform/downloads
```

### AWS CLI

```
https://aws.amazon.com/cli/
```

---

# Configure AWS Credentials

Before running Terraform, configure AWS credentials.

```
aws configure
```

Provide:

```
AWS Access Key
AWS Secret Access Key
Region
```

This allows Terraform to authenticate with AWS.

---

# Best Practices Used

This repository follows industry standards:

* Infrastructure as Code
* Modular Terraform architecture
* Remote state storage
* State locking
* Environment separation
* Tagging strategy
* Workspace-based deployments

---

# Future Improvements

Possible enhancements:

* Add **VPC module**
* Add **Security Groups**
* Add **Auto Scaling Groups**
* Add **Load Balancer**
* Add **CI/CD pipeline**
* Add **Terraform Cloud integration**

---

# Author

Faishal
Infrastructure Engineer

---

# License

This project is licensed under the MIT License.
