variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}