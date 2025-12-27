terraform {
  backend "s3" {
    bucket         = "harry-crc-tfstate-2025"
    key            = "crc/prod/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "harry-crc-tflock-2025"
    encrypt        = true
  }
}
