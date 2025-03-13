#!/bin/sh
set -e

echo "🔄 Waiting for database..."
# データベースが起動するまで待機
until npx prisma db push --skip-generate; do
  echo "⏳ Database is not ready yet. Waiting..."
  sleep 2
done

echo "🔨 Generating Prisma Client..."
npx prisma generate

echo "📦 Installing dependencies if needed..."
npm install

echo "🚀 Starting Next.js development server..."
exec npm run dev
