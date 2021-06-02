terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "eu-west-3"
    bucket         = "tbobm-teks-keda-tf-state-lock"
    key            = "terraform.tfstate"
    dynamodb_table = "tbobm-teks-keda-tf-state-store-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
