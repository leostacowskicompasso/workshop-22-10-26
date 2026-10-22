terraform {
  #backend "s3" {
  #  # Persist state in an S3 bucket. Update these values to point to your own bucket.
  #  bucket         = "your-terraform-state-bucket"
  #  key            = "aws_workshops/terraform.tfstate"
  #  region         = "us-east-1"
  #  dynamodb_table = "terraform-locks" # optional, for state locking
  #}
  backend "local" {}
}