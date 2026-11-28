output "db_parameter_name" {
  value = data.aws_ssm_parameter.db_password.name
}

output "db_password_length" {
  value = nonsensitive(length(data.aws_ssm_parameter.db_password.value))
}
