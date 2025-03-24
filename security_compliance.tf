// Security & Compliance Configuration File for Cloud Infrastructure

// Define variables for custom domain and office IP (update with your actual office IP)
variable "domain_name" {
  description = "Custom domain for Jenkins"
  type        = string
  default     = "jenkins.3.250.187.135.nip.io"
}

variable "office_ip" {
  description = "Your office IP for SSH access"
  type        = string
  default     = "203.0.113.10/32"  // Replace with your actual office IP CIDR
}

// Variables for ALB and ACM (update with your actual ARNs or use output from other modules)
variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
  default     = "arn:aws:elasticloadbalancing:region:account-id:loadbalancer/app/your-alb"  // Placeholder
}

variable "lb_target_group_arn" {
  description = "ARN of the target group for the ALB"
  type        = string
  default     = "arn:aws:elasticloadbalancing:region:account-id:targetgroup/your-target-group"  // Placeholder
}

variable "dev_proj_1_acm_arn" {
  description = "ARN of the ACM certificate for SSL/TLS"
  type        = string
  default     = "arn:aws:acm:region:account-id:certificate/your-certificate-id"  // Placeholder
}

variable "enable_https" {
  description = "Flag to enable HTTPS listener on the ALB"
  type        = bool
  default     = true
}

variable "lb_https_listner_port" {
  description = "Port for HTTPS listener"
  type        = number
  default     = 443
}

variable "lb_https_listner_protocol" {
  description = "Protocol for HTTPS listener"
  type        = string
  default     = "HTTPS"
}

variable "lb_listner_default_action" {
  description = "Default action for the ALB listener"
  type        = string
  default     = "forward"
}

//-----------------------------------------------------------------
// 1. IAM Policies and Roles for RBAC
//-----------------------------------------------------------------

resource "aws_iam_policy" "rbac_policy" {
  name        = "RBACPolicy"
  description = "Policy for role-based access control following least privilege principles."
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "s3:ListBucket"
        ],
        Resource = "*"
      },
      {
        Effect   = "Deny",
        Action   = "iam:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "app_role" {
  name               = "AppServiceRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rbac_policy_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.rbac_policy.arn
}

//-----------------------------------------------------------------
// 2. Network Security Rules and SSL/TLS Encryption
//-----------------------------------------------------------------

// Security Group for EC2 (e.g., Jenkins instance)
// Note: Replace var.vpc_id with your actual VPC ID variable or value.
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH, HTTP, HTTPS traffic"
  vpc_id      = var.vpc_id  // Ensure this variable is defined elsewhere in your project

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.office_ip]
  }
  
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// ACM Certificate for SSL/TLS encryption
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags = {
    Environment = "production"
  }
  lifecycle {
    create_before_destroy = true
  }
}

// ALB HTTPS Listener enforcing SSL/TLS
resource "aws_lb_listener" "https_listener" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = var.alb_arn
  port              = var.lb_https_listner_port
  protocol          = var.lb_https_listner_protocol
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn   = var.dev_proj_1_acm_arn

  default_action {
    type             = var.lb_listner_default_action
    target_group_arn = var.lb_target_group_arn
  }
}

//-----------------------------------------------------------------
// 3. API Security Measures
//-----------------------------------------------------------------

resource "aws_api_gateway_rest_api" "api" {
  name        = "MySecureAPI"
  description = "API protected with IAM and WAF."
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "AWS_IAM"
}

//-----------------------------------------------------------------
// Outputs
//-----------------------------------------------------------------

output "custom_domain" {
  description = "Custom DNS for Jenkins"
  value       = var.domain_name
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = "3.250.187.135"
}
