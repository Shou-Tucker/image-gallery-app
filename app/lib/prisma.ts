import { PrismaClient } from '@prisma/client';

// PrismaClientのグローバルインスタンスを作成
let prisma: PrismaClient;

if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient();
} else {
  // 開発環境では一つのインスタンスを再利用
  if (!global.prisma) {
    global.prisma = new PrismaClient();
  }
  prisma = global.prisma;
}

export default prisma;
