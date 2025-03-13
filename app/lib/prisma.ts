import { PrismaClient } from '@prisma/client';

// PrismaClientのグローバルインスタンスを作成
let prisma: PrismaClient;

if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient();
} else {
  // 開発環境では一つのインスタンスを再利用
  if (!(global as any).prisma) {
    (global as any).prisma = new PrismaClient();
  }
  prisma = (global as any).prisma;
}

export default prisma;