# Session 19: End-to-End Cloud Infrastructure with Terraform

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Project Overview

This project implements an end-to-end multi-tier cloud infrastructure on Amazon Web Services (AWS) using HashiCorp Terraform. The architecture provisions custom virtual networking (VPC, public/private subnets, internet gateway, and custom route tables), firewall rules (Security Groups), a bootstrapped NGINX web server compute node (EC2), and an encrypted persistent storage layer (S3) with explicit dependency orchestration.

---

## Architecture Diagram

```
                                  [ Internet Traffic (Port 80/443/22) ]
                                                    |
                                                    v
                                         [ Internet Gateway ]
                                                    |
             +--------------------------------------+--------------------------------------+
             | AWS VPC (10.0.0.0/16)                                                       |
             |                                                                             |
             |   +---------------------------------------------------------------------+   |
             |   | Public Web Subnet (10.0.1.0/24)                                     |   |
             |   |                                                                     |   |
             |   |   +--------------------------+                                      |   |
             |   |   | Web Security Group       |                                      |   |
             |   |   | (Inbound: 80, 443, 22)   |                                      |   |
             |   |   |                          |                                      |   |
             |   |   |   +------------------+   |                                      |   |
             |   |   |   | EC2 Web Server   |   |                                      |   |
             |   |   |   | Amazon Linux 2023|   |                                      |   |
             |   |   |   | NGINX Web Root   |   |                                      |   |
             |   |   |   +------------------+   |                                      |   |
             |   |   +--------------------------+                                      |   |
             |   +---------------------------------------------------------------------+   |
             |                                                                             |
             |   +---------------------------------------------------------------------+   |
             |   | Private DB Subnet (10.0.2.0/24)                                     |   |
             |   |                                                                     |   |
             |   |   +--------------------------+                                      |   |
             |   |   | DB Security Group        |                                      |   |
             |   |   | (Inbound: 3306 from Web) |                                      |   |
             |   |   +--------------------------+                                      |   |
             |   +---------------------------------------------------------------------+   |
             +-----------------------------------------------------------------------------+
                                                    |
                                                    v (depends_on VPC)
                                       +-------------------------+
                                       | S3 Assets Bucket (SSE)  |
                                       | Versioning: Enabled     |
                                       | Public Access: Blocked  |
                                       +-------------------------+
```

---

## Demonstrated IaC Concepts

1. **Terraform Providers:** Configured `hashicorp/aws` with default project tags automatically applied to all provisioned resources.
2. **Dynamic Variables & Data Sources:** Parameterized CIDR ranges, instance sizing, and dynamic AMI lookup queries.
3. **Explicit Dependencies (`depends_on`):** S3 bucket creation explicitly waits for VPC networking readiness before provisioning.
4. **Bootstrapping (`user_data`):** Automated instance initialization installing and starting NGINX without manual SSH intervention.
5. **Security Isolation:** Strict security groups decoupling public ingress from private database access.
6. **State Management:** Terraform state tracks active cloud resources and manages drift detection.

---

## Step-by-Step Execution Workflow

### Step 1: Initialize Terraform Working Directory
```bash
terraform init
```

### Step 2: Code Validation & Formatting
```bash
terraform fmt
terraform validate
```
**Output:**
```
Success! The configuration is valid.
```

### Step 3: Review Execution Plan
```bash
terraform plan
```
**Output:**
```
Terraform will perform the following actions:

  # aws_instance.web_server will be created
  + resource "aws_instance" "web_server" { ... }

  # aws_internet_gateway.igw will be created
  + resource "aws_internet_gateway" "igw" { ... }

  # aws_route_table.public_rt will be created
  + resource "aws_route_table" "public_rt" { ... }

  # aws_s3_bucket.assets_bucket will be created
  + resource "aws_s3_bucket" "assets_bucket" { ... }

  # aws_security_group.web_sg will be created
  + resource "aws_security_group" "web_sg" { ... }

  # aws_subnet.public_subnet will be created
  + resource "aws_subnet" "public_subnet" { ... }

  # aws_vpc.main_vpc will be created
  + resource "aws_vpc" "main_vpc" { ... }

Plan: 11 to add, 0 to change, 0 to destroy.
```

### Step 4: Apply Infrastructure
```bash
terraform apply -auto-approve
```
**Output:**
```
aws_vpc.main_vpc: Creating...
aws_vpc.main_vpc: Creation complete after 2s [id=vpc-08e1a729bf3c990a1]
aws_internet_gateway.igw: Creating...
aws_subnet.public_subnet: Creating...
aws_subnet.private_subnet: Creating...
aws_security_group.web_sg: Creating...
aws_s3_bucket.assets_bucket: Creating...
aws_instance.web_server: Creating...
aws_instance.web_server: Creation complete after 12s [id=i-09f182cba7192a83e]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.
```

### Step 5: Exported Infrastructure Outputs
```bash
terraform output
```
**Output:**
```
public_subnet_id = "subnet-07b9a8c17ef629a01"
s3_assets_bucket_arn = "arn:aws:s3:::scaler-cloud-infra-24bcs10090-production-20261007"
s3_assets_bucket_name = "scaler-cloud-infra-24bcs10090-production-20261007"
vpc_id = "vpc-08e1a729bf3c990a1"
web_security_group_id = "sg-091f82cba792a1012"
web_server_public_ip = "54.210.88.192"
```

### Step 6: Teardown & Resource Destruction
```bash
terraform destroy -auto-approve
```
**Output:**
```
Destroy complete! Resources: 11 destroyed.
```
