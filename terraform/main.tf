#entry point for AWS provider
#entry point for AWS provider

provider "aws" {
    region = "us-east-1" 
}

#create an S3 bucket to store data`
resource "aws_s3_bucket" "healthcare_cms_data_bucket" {
    bucket = "cms-healthcare-data-bucket-2026"
}
