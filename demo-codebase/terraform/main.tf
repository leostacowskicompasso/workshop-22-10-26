provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# ---------------------------------------------------------------------------
# VPC module: VPC, one public + one private subnet, IGW, route tables
# ---------------------------------------------------------------------------
module "vpc" {
  source              = "./modules/vpc"
  environment         = var.environment
  az                  = var.az
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# ---------------------------------------------------------------------------
# S3 module: private, versioned bucket for static assets
# ---------------------------------------------------------------------------
module "s3" {
  source      = "./modules/s3"
  environment = var.environment
}

# ---------------------------------------------------------------------------
# CloudFront module: serves the S3 bucket over HTTPS via Origin Access Control
# ---------------------------------------------------------------------------
module "cloudfront" {
  source                      = "./modules/cloudfront"
  environment                 = var.environment
  bucket_name                 = module.s3.bucket_name
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
}

# ---------------------------------------------------------------------------
# Bucket policy: allow only this CloudFront distribution (OAC) to read objects.
# Lives here because it needs outputs from both the s3 and cloudfront modules.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "cloudfront_oac" {
  bucket = module.s3.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontServicePrincipalReadOnly"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${module.s3.bucket_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = module.cloudfront.distribution_arn
        }
      }
    }]
  })
}
