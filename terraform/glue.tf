# This file defines the AWS Glue resources for the healthcare data pipeline.

#creating a database in AWS Glue Catalog to store the metadata of the tables created by the crawler
resource "aws_glue_catalog_database" "cms_db" {
    name = "cms_raw_db" 
}

#creating a crawler that will crawl the raw data in the S3 bucket and create tables in the Glue Catalog database
resource "aws_glue_crawler" "healthcare_crawler" {
  name         = "healthcare-crawler"
  role         = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.cms_db.name
  s3_target {
      path = "s3://cms-healthcare-data-bucket-2026/raw_data/"
  }
}

#creating an IAM role for the Glue crawler to allow it to access the S3 bucket and create tables in the Glue Catalog database
resource "aws_iam_role" "glue_role" {
    name = "glue_crawler_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "glue.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role" "glue_job_role" {
    name = "glue-job-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "glue.amazonaws.com"
            }
        }]
    })
  
}

#to allow the GLUE to run the and create tables
resource "aws_iam_role_policy_attachment" "glue_crawler_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

#to allow the GLUE to read data from S3
resource "aws_iam_role_policy_attachment" "s3_access_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  
}

#creating glue job to transform the raw data and load it into silver table
resource "aws_glue_job" "cms-raw-to-silver" {
  name     = "cms-raw-to-silver-job"
  role_arn = aws_iam_role.glue_job_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://cms-healthcare-data-bucket-2026/scripts/glue_job_script.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language"        = "python"
    "--TempDir"             = "${aws_s3_bucket.healthcare_cms_data_bucket.bucket}/temp/"
    "--enable-metrics"      = "true"
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}

#upload script to S3 bucket for the glue job
resource "aws_s3_object" "glue_job_script" {
    bucket = aws_s3_bucket.healthcare_cms_data_bucket.bucket
    key    = "scripts/glue_job_script.py"
    source = "../scripts/glue_job_script.py"

    etag = filemd5("../scripts/glue_job_script.py") # This ensures the script is only re-uploaded if it changes
}

