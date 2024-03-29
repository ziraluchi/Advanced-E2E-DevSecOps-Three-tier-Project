terraform {

  required_providers {

    aws = {

      source = "hashicorp/aws"

      version = "~> 4.18.0"

    }

  }



  backend "s3" {

    bucket = "endtoend-s3"

    key = "state/terraform.tfstate"

    region = "us-west-2"

    encrypt = true

    dynamodb_table = "orders"

  }

}
