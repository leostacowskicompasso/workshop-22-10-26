# AWS Workshops — Terraform

Infrastructure-as-Code for a basic AWS setup in `us-east-1`:

- **CloudFront** distribution serving the S3 bucket over HTTPS on `*.cloudfront.net` (no custom domain)
- **S3** bucket (private, versioned, all public access blocked) for static assets, read by CloudFront through **Origin Access Control (OAC)**
- **VPC** `10.0.0.0/16` with one public subnet `10.0.1.0/24` (routed to an Internet Gateway) and one private subnet `10.0.2.0/24` (local routing only)

## Architecture

```
Users ──HTTPS──► CloudFront (*.cloudfront.net) ──OAC──► S3 bucket (private)

VPC 10.0.0.0/16
├── Public subnet  10.0.1.0/24  (0.0.0.0/0 → Internet Gateway)
└── Private subnet 10.0.2.0/24  (local routes only, no NAT)
```

## Layout

```
terraform/
├── main.tf          # Provider, module wiring, S3 bucket policy for OAC
├── variables.tf     # Root input variables
├── outputs.tf       # Root outputs
├── versions.tf      # Required Terraform/provider versions
├── backend.tf       # State backend (local; S3 example commented out)
└── modules/
    ├── vpc/         # VPC, subnets, IGW, route tables
    ├── s3/          # Bucket, versioning, public access block
    └── cloudfront/  # OAC + distribution (S3 origin)
```

## Prerequisites

- AWS CLI profile `AdministratorAccess` use AccessKey + SecretKey or configured (IAM Identity Center/SSO).
  Log in with `aws sso login --profile AdministratorAccess` in case of SSO and check with
  `aws sts get-caller-identity --profile AdministratorAccess`.
  Override with `-var aws_profile=<name>` if needed.
- Terraform >= 1.5.0
- Optionally switch `backend.tf` to the S3 backend for shared state

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
terraform output
terraform destroy
```

## Notes

- **Security**: the S3 bucket blocks all public access. The bucket policy allows
  `s3:GetObject` only to the `cloudfront.amazonaws.com` service principal, scoped to
  this distribution's ARN (`AWS:SourceArn`).
- **HTTPS**: viewers are redirected to HTTPS using CloudFront's default certificate.
- **Bucket name**: auto-generated as `<bucket_prefix>-<random hex>` unless `bucket_name`
  is set on the `s3` module.
- **Custom domains**: not configured by design. Add `aliases` plus an ACM certificate
  (in `us-east-1`) to enable one later.
