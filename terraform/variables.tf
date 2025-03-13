variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "データベースのマスターパスワード"
  type        = string
  sensitive   = true
}

variable "app_domain" {
  description = "アプリケーションのドメイン名（設定する場合）"
  type        = string
  default     = ""
}
