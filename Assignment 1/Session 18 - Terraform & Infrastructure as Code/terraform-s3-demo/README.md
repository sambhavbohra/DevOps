# Session 18: Task 1 - Terraform AWS S3 Bucket Project

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Project Overview

This project provisions a secure, production-compliant Amazon S3 bucket using HashiCorp Terraform. The configuration implements AWS security best practices including object versioning, server-side AES256 encryption, public access blocking, and cost-saving lifecycle expiration rules.

---

## Terraform Project Structure

```
terraform-s3-demo/
├── main.tf             # S3 bucket, versioning, encryption, public block, and lifecycle rules
├── variables.tf        # Parameter definitions with types and defaults
├── outputs.tf          # Exported bucket ARN, ID, and region
├── provider.tf         # AWS provider configuration and global resource tagging
├── terraform.tfvars    # Environment-specific parameter values
└── README.md           # Step-by-step workflow documentation
```

---

## Complete Terraform Workflow & Execution

### 1. Initialize Terraform Working Directory
Downloads the AWS provider plugin (`hashicorp/aws ~> 5.0`) and prepares the state backend:
```bash
terraform init
```
**Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

### 2. Format Configuration Code
Standardizes formatting across all `.tf` files:
```bash
terraform fmt
```

### 3. Validate Syntax & References
Verifies manifest syntax, variable types, and resource schemas:
```bash
terraform validate
```
**Output:**
```
Success! The configuration is valid.
```

### 4. Generate Execution Plan
Inspects declared infrastructure against the current state file:
```bash
terraform plan
```
**Output:**
```
Terraform will perform the following actions:

  # aws_s3_bucket.demo_bucket will be created
  + resource "aws_s3_bucket" "demo_bucket" {
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_prefix               = "scaler-devops-24bcs10090-dev-"
      + force_destroy               = true
      + id                          = (known after apply)
      + region                      = (known after apply)
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Owner"       = "Sambhav D Bohra"
          + "Project"     = "DevOps-Assignment"
          + "RegNumber"   = "24bcs10090"
        }
    }

  # aws_s3_bucket_lifecycle_configuration.lifecycle_policy will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" { ... }

  # aws_s3_bucket_public_access_block.public_block will be created
  + resource "aws_s3_bucket_public_access_block" "public_block" { ... }

  # aws_s3_bucket_server_side_encryption_configuration.sse_config will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" { ... }

  # aws_s3_bucket_versioning.versioning_config will be created
  + resource "aws_s3_bucket_versioning" "versioning_config" { ... }

Plan: 5 to add, 0 to change, 0 to destroy.
```

### 5. Apply Infrastructure Changes
Provisions resources in AWS:
```bash
terraform apply -auto-approve
```
**Output:**
```
aws_s3_bucket.demo_bucket: Creating...
aws_s3_bucket.demo_bucket: Creation complete after 3s [id=scaler-devops-24bcs10090-dev-20261007080512]
aws_s3_bucket_versioning.versioning_config: Creating...
aws_s3_bucket_server_side_encryption_configuration.sse_config: Creating...
aws_s3_bucket_public_access_block.public_block: Creating...
aws_s3_bucket_lifecycle_configuration.lifecycle_policy: Creating...
aws_s3_bucket_versioning.versioning_config: Creation complete after 1s
aws_s3_bucket_server_side_encryption_configuration.sse_config: Creation complete after 1s
aws_s3_bucket_public_access_block.public_block: Creation complete after 1s
aws_s3_bucket_lifecycle_configuration.lifecycle_policy: Creation complete after 1s

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

### 6. Show Current State
Displays active state details managed by Terraform:
```bash
terraform show
```

### 7. View Exported Outputs
Retrieves structured output values:
```bash
terraform output
```
**Output:**
```
s3_bucket_arn = "arn:aws:s3:::scaler-devops-24bcs10090-dev-20261007080512"
s3_bucket_id = "scaler-devops-24bcs10090-dev-20261007080512"
s3_bucket_region = "us-east-1"
versioning_status = "Enabled"
```

### 8. Destroy Infrastructure
Cleans up and removes all provisioned cloud resources:
```bash
terraform destroy -auto-approve
```
**Output:**
```
aws_s3_bucket_lifecycle_configuration.lifecycle_policy: Destroying...
aws_s3_bucket_public_access_block.public_block: Destroying...
aws_s3_bucket_server_side_encryption_configuration.sse_config: Destroying...
aws_s3_bucket_versioning.versioning_config: Destroying...
aws_s3_bucket.demo_bucket: Destroying...
aws_s3_bucket.demo_bucket: Destruction complete after 2s

Destroy complete! Resources: 5 destroyed.
```
