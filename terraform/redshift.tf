#creating a data warehouse in AWS Redshift using Terraform

# 1. CREATE THE ROLE
resource "aws_iam_role" "redshift_s3_role" {
  name = "redshift_s3_read_role"

  # This tells AWS: "Only Redshift is allowed to use this role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { 
        Service = "redshift.amazonaws.com" 
      }
    }]
  })
}

# 2. ATTACH S3 PERMISSION
resource "aws_iam_role_policy_attachment" "redshift_s3_attach" {
  role       = aws_iam_role.redshift_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# 3. ATTACH GLUE PERMISSION (This fixes the "awsdatacatalog" error!)
resource "aws_iam_role_policy_attachment" "redshift_glue_attach" {
  role       = aws_iam_role.redshift_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

#namespace for redshift serverless - This resource manages the data-related aspects like the database name, admin credentials, and KMS key.
resource "aws_redshiftserverless_namespace" "rsdw_cms_inpatient_by_provider_and_service" {
    namespace_name = "rsdw-cms-inpatient-by-provider-and-service"
    db_name        = "cms_raw_db"
    admin_username = "adminuser"
    admin_user_password = var.redshift_password

    iam_roles = [aws_iam_role.redshift_s3_role.arn]
}

#workgroup for redshift serverless - This resource manages the compute-related aspects, such as the workgroup name, namespace association, and VPC configuration.
resource "aws_redshiftserverless_workgroup" "rsdw_cms_compute" {
    workgroup_name = "rsdw-cms-compute"
    namespace_name = aws_redshiftserverless_namespace.rsdw_cms_inpatient_by_provider_and_service.namespace_name
    base_capacity  = 8
    publicly_accessible = true
}