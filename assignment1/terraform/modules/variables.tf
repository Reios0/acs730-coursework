variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "project" {
  type    = string
  default = "acs730-a1"
}

variable "owner" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  validation {
    condition     = length(var.public_subnets) > 0
    error_message = "Need at least one public subnet"
  }
}

variable "instance_type" {
  type = string
  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "Keep the instance sizes small."
  }
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "alarm_cpu_threshold" {
  type    = number
  default = 80
}

variable "db_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "db_password is empty or too short."
  }
}
