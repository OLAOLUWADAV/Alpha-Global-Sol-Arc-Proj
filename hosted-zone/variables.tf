variable "domain_name" {
  description = "The domain name for the DNS record (e.g., jenkins.3.250.187.135.nip.io)."
  type        = string
}

variable "aws_lb_dns_name" {
  description = "The load balancer DNS name."
  type        = string
}

variable "aws_lb_zone_id" {
  description = "The load balancer hosted zone ID."
  type        = string
}
