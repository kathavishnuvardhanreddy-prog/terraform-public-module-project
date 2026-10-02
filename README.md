# Terraform Public Module Project

This project demonstrates how to use a **public Terraform module from the Terraform Registry** to create AWS infrastructure.

## Prerequisites

- AWS Account
- EC2 instance (Amazon Linux)
- IAM Role attached to EC2 with required AWS permissions
- Git
- Terraform
- AWS CLI
- GitHub account

---

## 1. EC2 Setup

Connect to the Amazon Linux EC2 instance.

Update packages:

```bash
sudo dnf update -y
```

Install Git:

```bash
sudo dnf install git -y
```

Install AWS CLI:

```bash
sudo dnf install awscli -y
```

Install Terraform:

```bash
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf -y install terraform
```

Verify:

```bash
git --version
aws --version
terraform --version
```

---

## 2. AWS Authentication

An IAM role was attached to the EC2 instance.

Verify AWS access:

```bash
aws sts get-caller-identity
```

This confirms that the EC2 instance can communicate with AWS without using `aws configure`.

---

## 3. GitHub SSH Setup

Generate an SSH key:

```bash
ssh-keygen -t ed25519 -C "your-github-email"
```

Press Enter to accept the default file location.

This creates:

```text
~/.ssh/id_ed25519       → Private key. Do not share it.
~/.ssh/id_ed25519.pub   → Public key. Add this to GitHub.
```

Copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add it to:

`GitHub → Settings → SSH and GPG keys → New SSH key`

Test the connection:

```bash
ssh -T git@github.com
```

---

## 4. Create GitHub Repository

Create a repository in GitHub:

```text
terraform-public-module-project
```

Clone it:

```bash
git clone git@github.com:<USERNAME>/terraform-public-module-project.git
cd terraform-public-module-project
```

---

## 5. Public Terraform Module

Instead of creating our own local VPC module, we use a **public module from the Terraform Registry**.

Module:

```text
terraform-aws-modules/vpc/aws
```

Version:

```text
6.7.3
```

The module provides reusable Terraform code for creating a complete AWS VPC.

---

## 6. Create main.tf

Create the file:

```bash
cat > main.tf <<'EOF'
provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "Public-Module-VPC"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
EOF
```

---

## 7. Initialize Terraform

```bash
terraform init
```

This downloads the public VPC module and required providers.

---

## 8. Format Terraform

```bash
terraform fmt
```

This formats the Terraform configuration into standard Terraform style.

---

## 9. Validate Configuration

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

## 10. Review the Infrastructure

```bash
terraform plan
```

Terraform showed:

```text
19 to add
0 to change
0 to destroy
```

The plan included the VPC, public/private subnets, route tables, Internet Gateway, NAT Gateway, Elastic IP and related resources.

---

## 11. Create Infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

Terraform created the infrastructure using the public VPC module.

Result:

```text
19 resources added
```

---

## 12. Verify Terraform Resources

```bash
terraform state list
```

This shows all AWS resources currently managed by Terraform.

---

## 13. Add Terraform Output

Create `outputs.tf`:

```bash
cat > outputs.tf <<'EOF'
output "vpc_id" {
  description = "ID of the VPC created by the public Terraform module"
  value       = module.vpc.vpc_id
}
EOF
```

Format:

```bash
terraform fmt
```

Apply the output configuration:

```bash
terraform apply
```

Verify:

```bash
terraform output
```

Example:

```text
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
```

---

## 14. Verify the VPC in AWS

```bash
aws ec2 describe-vpcs \
  --region ap-south-1 \
  --filters "Name=tag:Name,Values=Public-Module-VPC" \
  --query 'Vpcs[*].[VpcId,CidrBlock]' \
  --output table
```

---

## 15. Verify the Subnets

Replace `VPC_ID` with the VPC ID obtained above:

```bash
aws ec2 describe-subnets \
  --region ap-south-1 \
  --filters "Name=vpc-id,Values=VPC_ID" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch]' \
  --output table
```

The VPC contains:

```text
Public Subnets
10.0.1.0/24
10.0.2.0/24

Private Subnets
10.0.11.0/24
10.0.12.0/24
```

---

## 16. Final Terraform Check

```bash
terraform plan
```

Expected:

```text
No changes. Your infrastructure matches the configuration.
```

---

## 17. Git Configuration

Create `.gitignore`:

```bash
cat > .gitignore <<'EOF'
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
EOF
```

Terraform state files should not be pushed to GitHub.

Add the Terraform lock file:

```bash
git add .terraform.lock.hcl
```

---

## 18. Commit Changes

Check status:

```bash
git status
```

Add the project files:

```bash
git add main.tf outputs.tf .gitignore .terraform.lock.hcl
```

Commit:

```bash
git commit -m "Add public Terraform VPC module project"
```

---

## 19. Push to GitHub

Verify the remote:

```bash
git remote -v
```

Push:

```bash
git push -u origin main
```

The Terraform project is now available in GitHub.

---


