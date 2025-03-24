# AWS E-Commerce Jenkins Infrastructure

This repository contains modular and reusable Terraform code to deploy a high-availability, scalable, and secure Jenkins infrastructure on AWS. The architecture leverages multiple AWS services and best practices, including VPC networking, security groups, EC2 instances, load balancers, DNS management, and certificate provisioning.

## Overview

- **Compute:** Jenkins is deployed on an EC2 instance using Ubuntu Linux.
- **Networking:** A custom VPC with public and private subnets; an Application Load Balancer (ALB) handles traffic routing.
- **Security:** Security groups manage access (SSH, HTTP, HTTPS, and Jenkins port 8080). AWS Certificate Manager provides SSL/TLS for secure communication.
- **DNS & Certificates:** A dynamic custom domain is generated using nip.io, with DNS hosted via Route 53 and SSL managed by AWS Certificate Manager.
- **State Management:** Terraform backend uses S3 for state storage with DynamoDB for state locking.

## Project Structure

. ├── main.tf # Main Terraform configuration including backend setup ├── variables.tf # Variables definitions ├── outputs.tf # Outputs for the project ├── modules/ │ ├── networking/ # VPC, Subnets, and related networking resources │ ├── security-groups/ # Security groups definitions │ ├── jenkins/ # EC2 instance for Jenkins │ ├── load-balancer/ # Application Load Balancer configuration │ ├── load-balancer-target-group/ # Target group for ALB │ ├── hosted-zone/ # Route 53 hosted zone resources │ └── certificate-manager/ # AWS Certificate Manager resources └── jenkins-runner-script/ └── jenkins-installer.sh # User-data script to install and configure Jenkins


## Prerequisites

- **Terraform:** Version 0.12 or higher.
- **AWS CLI:** Configured with credentials and proper permissions.
- **SSH Key:** A public/private SSH key pair for accessing the EC2 instance.
- **S3 Bucket & DynamoDB Table:** Create these manually or via a separate Terraform script for remote state storage.

## Step-by-Step Guide

1. **Clone the Repository:**
   ```bash
   git clone (https://github.com/OLAOLUWADAV/Alpha-Global-Sol-Arc-Proj.git)
   cd "Alpha-Global-Sol-Arc-Proj"
   terraform init
   terraform plan
   terraform apply
   ssh -i ~/.ssh/aws_ec2_terraform ubuntu@<3.250.187.135:8080>
   "jenkins.3.250.187.135.nip.io"

---

This README provides a comprehensive overview and step-by-step instructions for deploying and managing the AWS Jenkins infrastructure using Terraform.
# Alpha-Global-project
# Alpha-Global-project
