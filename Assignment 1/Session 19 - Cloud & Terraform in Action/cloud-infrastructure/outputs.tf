output "vpc_id" {
  description = "ID of the created custom VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "web_security_group_id" {
  description = "ID of the Web security group"
  value       = aws_security_group.web_sg.id
}

output "web_server_public_ip" {
  description = "Public IP address of the EC2 web server"
  value       = aws_instance.web_server.public_ip
}

output "s3_assets_bucket_name" {
  description = "Name of the created S3 assets bucket"
  value       = aws_s3_bucket.assets_bucket.id
}

output "s3_assets_bucket_arn" {
  description = "ARN of the created S3 assets bucket"
  value       = aws_s3_bucket.assets_bucket.arn
}
