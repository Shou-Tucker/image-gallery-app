/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['localhost', 'image-gallery-local.s3.amazonaws.com', 'image-gallery-dev.s3.amazonaws.com', 'image-gallery-prod.s3.amazonaws.com'],
  },
  env: {
    DATABASE_URL: process.env.DATABASE_URL,
    S3_ENDPOINT: process.env.S3_ENDPOINT,
    S3_BUCKET_NAME: process.env.S3_BUCKET_NAME,
    AWS_REGION: process.env.AWS_REGION || 'us-east-1',
    AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID,
    AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY,
  },
}

module.exports = nextConfig