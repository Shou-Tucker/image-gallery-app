output "app_public_ip" {
  description = "アプリケーションサーバーのパブリックIP"
  value       = aws_lightsail_static_ip.app.ip_address
}

output "app_url" {
  description = "アプリケーションのURL"
  value       = "http://${aws_lightsail_static_ip.app.ip_address}"
}

output "database_endpoint" {
  description = "データベースのエンドポイント"
  value       = aws_lightsail_database.db.master_endpoint_address
  sensitive   = true
}

output "s3_bucket_name" {
  description = "画像保存用のS3バケット名"
  value       = aws_s3_bucket.images.bucket
}

output "s3_bucket_url" {
  description = "S3バケットのURL"
  value       = "https://${aws_s3_bucket.images.bucket_domain_name}"
}