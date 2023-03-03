output "rds_endpoint" {
  value = aws_db_instance.dentolo-postgres.endpoint
}

output "rds_arn" {
  value = aws_db_instance.dentolo-postgres.arn
}

