terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # バックエンドとしてS3を使用（状態ファイルの保存）
  backend "s3" {
    bucket         = "terraform-state-image-gallery"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# 設定プロバイダー
provider "aws" {
  region = var.aws_region

  # 開発環境用のタグをすべてのリソースに付与
  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = "image-gallery"
      ManagedBy   = "terraform"
    }
  }
}

# ワークスペースに基づく変数
locals {
  env = terraform.workspace
  is_prod = local.env == "prod"
  
  # 環境ごとの設定
  env_config = {
    dev = {
      lightsail_bundle_id = "nano_3_0"  # 開発環境は小さいインスタンス
      db_bundle_id        = "micro_3_0"
      s3_bucket_name      = "image-gallery-dev"
    }
    prod = {
      lightsail_bundle_id = "small_3_0" # 本番環境はより大きいインスタンス
      db_bundle_id        = "small_3_0"
      s3_bucket_name      = "image-gallery-prod"
    }
  }

  # 現在の環境の設定を取得
  config = local.env_config[local.env]
}

# S3バケット作成
resource "aws_s3_bucket" "images" {
  bucket = local.config.s3_bucket_name

  tags = {
    Name = "${local.env}-image-storage"
  }
}

# S3バケットの設定
resource "aws_s3_bucket_ownership_controls" "images" {
  bucket = aws_s3_bucket.images.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "images" {
  depends_on = [
    aws_s3_bucket_ownership_controls.images,
    aws_s3_bucket_public_access_block.images,
  ]

  bucket = aws_s3_bucket.images.id
  acl    = "public-read"
}

# Lightsail インスタンス (Next.jsアプリケーション用)
resource "aws_lightsail_instance" "app" {
  name              = "image-gallery-app-${local.env}"
  availability_zone = "${var.aws_region}a"
  blueprint_id      = "amazon_linux_2"
  bundle_id         = local.config.lightsail_bundle_id

  user_data = <<-EOF
    #!/bin/bash
    # インスタンスのセットアップスクリプト
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # アプリケーションのセットアップ
    mkdir -p /app
    echo 'DATABASE_URL=${aws_lightsail_database.db.master_endpoint_address}:${aws_lightsail_database.db.master_port}/${aws_lightsail_database.db.master_database_name}' > /app/.env
    echo 'S3_BUCKET_NAME=${local.config.s3_bucket_name}' >> /app/.env
    echo 'AWS_REGION=${var.aws_region}' >> /app/.env
    
    # アプリのデプロイは別途実施
  EOF

  tags = {
    Name = "image-gallery-app-${local.env}"
  }
}

# Lightsail データベース (PostgreSQL)
resource "aws_lightsail_database" "db" {
  name                 = "image-gallery-db-${local.env}"
  availability_zone    = "${var.aws_region}a"
  master_database_name = "image_gallery"
  master_username      = "postgres"
  master_password      = var.db_password
  blueprint_id         = "postgres_14"
  bundle_id            = local.config.db_bundle_id
  skip_final_snapshot  = !local.is_prod  # 本番環境ではfinal snapshotを取得

  tags = {
    Name = "image-gallery-db-${local.env}"
  }
}

# 静的IPの割り当て
resource "aws_lightsail_static_ip" "app" {
  name = "image-gallery-ip-${local.env}"
}

# 静的IPをインスタンスにアタッチ
resource "aws_lightsail_static_ip_attachment" "app" {
  static_ip_name = aws_lightsail_static_ip.app.name
  instance_name  = aws_lightsail_instance.app.name
}