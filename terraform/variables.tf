#Configurable parameters for terraform

variable "redshift_password" {
	description = "Redshift admin password (set via TF_VAR_redshift_password environment variable)"
	type        = string
	sensitive   = true
}