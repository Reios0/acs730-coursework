provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Course      = "ACS730"
      Assignment  = "assignment1"
      Environment = "prod"
      Owner       = "kliu106"
    }
  }
}

data "aws_ssm_parameter" "db_password" {
  name            = "/acs730/assignment1/prod/db_password"
  with_decryption = true
}

module "app" {
  source      = "../modules"
  environment = "prod"
  owner       = "kliu106"
  vpc_cidr    = "10.30.0.0/16"
  public_subnets = {
    a = { cidr_block = "10.30.1.0/24", availability_zone = "us-east-1a" }
    b = { cidr_block = "10.30.2.0/24", availability_zone = "us-east-1b" }
  }
  instance_type = "t3.small"
  db_password   = data.aws_ssm_parameter.db_password.value
}
