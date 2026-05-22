output "db_endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "The connection endpoint for the RDS database"
}
