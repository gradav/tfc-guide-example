# Declare GOOGLE_CREDENTIALS as a variable
variable "GOOGLE_CREDENTIALS" {
  type        = string
  description = "The JSON credentials for the Google Cloud provider."
  sensitive   = true
}

provider "google" {
  project = "terraform-445119"
  region  = "us-central1"
  zone    = "us-central1-a"
  credentials = var.GOOGLE_CREDENTIALS
}
