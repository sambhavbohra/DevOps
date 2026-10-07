data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "k8s_worker_node" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_node_sg.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.environment}-k8s-node"
    Role = "Kubernetes-Worker"
  }
}
---
# S3 Bucket
resource "aws_s3_bucket" "platform_storage" {
  bucket_prefix = "scaler-devops-platform-24bcs10090-"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.platform_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_encryption" {
  bucket = aws_s3_bucket.platform_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage_block" {
  bucket = aws_s3_bucket.platform_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
---
# Outputs
output "vpc_id" {
  value = aws_vpc.platform_vpc.id
}

output "worker_node_private_ip" {
  value = aws_instance.k8s_worker_node.private_ip
}

output "s3_storage_bucket" {
  value = aws_s3_bucket.platform_storage.id
}
