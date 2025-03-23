variable "lb_name" {
  description = "Name for the load balancer"
  type        = string
}
variable "lb_type" {
  description = "Type of load balancer (application, network, etc.)"
  type        = string
}
variable "is_external" {
  description = "Whether the load balancer is internal or external"
  type        = bool
  default     = true  // For public access, set to true.
}
variable "sg_enable_ssh_https" {
  description = "Security Group ID to allow SSH, HTTP, HTTPS traffic"
  type        = string
}
variable "subnet_ids" {
  description = "List of subnet IDs to deploy the LB in"
  type        = list(string)
}
variable "tag_name" {
  description = "Tag for the load balancer"
  type        = string
}
variable "lb_target_group_arn" {
  description = "ARN of the target group"
  type        = string
}
variable "ec2_instance_id" {
  description = "ID of the EC2 instance to attach as a target"
  type        = string
}
variable "lb_listner_port" {
  description = "Port for the LB listener (HTTP)"
  type        = number
}
variable "lb_listner_protocol" {
  description = "Protocol for the LB listener (HTTP)"
  type        = string
}
variable "lb_listner_default_action" {
  description = "Default action for the LB listener (e.g., forward)"
  type        = string
}
variable "lb_https_listner_port" {
  description = "Port for the HTTPS LB listener"
  type        = number
}
variable "lb_https_listner_protocol" {
  description = "Protocol for the HTTPS LB listener (HTTPS)"
  type        = string
}
variable "dev_proj_1_acm_arn" {
  description = "ACM certificate ARN for HTTPS (if available)"
  type        = string
}
variable "lb_target_group_attachment_port" {
  description = "Port to use for target group attachment"
  type        = number
}

output "aws_lb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.dev_proj_1_lb.dns_name
}

output "aws_lb_zone_id" {
  description = "Hosted zone ID of the ALB"
  value       = aws_lb.dev_proj_1_lb.zone_id
}

resource "aws_lb" "dev_proj_1_lb" {
  name               = var.lb_name
  internal           = !var.is_external   # internal = false means external
  load_balancer_type = var.lb_type
  security_groups    = [var.sg_enable_ssh_https]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = var.tag_name
  }
}

resource "aws_lb_target_group_attachment" "dev_proj_1_lb_target_group_attachment" {
  target_group_arn = var.lb_target_group_arn
  target_id        = var.ec2_instance_id
  port             = var.lb_target_group_attachment_port
}

resource "aws_lb_listener" "dev_proj_1_lb_listner" {
  load_balancer_arn = aws_lb.dev_proj_1_lb.arn
  port              = var.lb_listner_port
  protocol          = var.lb_listner_protocol

  default_action {
    type             = var.lb_listner_default_action
    target_group_arn = var.lb_target_group_arn
  }
}

# -------------------------------------------------------------------
# Option: HTTPS Listener (Enable only if using a valid certificate)
# -------------------------------------------------------------------
# For now, because we are using a free dynamic nip.io domain, ACM certificates 
# typically will not be issued. For immediate testing, keep HTTPS disabled.
#
# Uncomment the block below when you have a valid certificate for a domain you own.
#
# resource "aws_lb_listener" "dev_proj_1_lb_https_listner" {
#   load_balancer_arn = aws_lb.dev_proj_1_lb.arn
#   port              = var.lb_https_listner_port
#   protocol          = var.lb_https_listner_protocol
#   ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
#   certificate_arn   = var.dev_proj_1_acm_arn
#
#   default_action {
#     type             = var.lb_listner_default_action
#     target_group_arn = var.lb_target_group_arn
#   }
# }
