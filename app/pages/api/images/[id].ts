import type { NextApiRequest, NextApiResponse } from 'next';
import prisma from '../../../lib/prisma';
import { deleteImage } from '../../../lib/s3';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const id = req.query.id as string;

  // 指定されたIDの画像が存在するか確認
  const image = await prisma.image.findUnique({
    where: { id },
  });

  if (!image) {
    return res.status(404).json({ message: 'Image not found' });
  }

  switch (req.method) {
    case 'GET':
      return getImage(image, res);
    case 'DELETE':
      return removeImage(image, res);
    default:
      return res.status(405).json({ message: 'Method not allowed' });
  }
}

// 特定の画像の詳細取得
async function getImage(image: any, res: NextApiResponse) {
  return res.status(200).json(image);
}

// 画像の削除
async function removeImage(image: any, res: NextApiResponse) {
  try {
    // S3から画像ファイルを削除
    await deleteImage(image.key);
    
    // データベースから画像情報を削除
    await prisma.image.delete({
      where: { id: image.id },
    });

    return res.status(200).json({ message: 'Image deleted successfully' });
  } catch (error) {
    console.error('Error deleting image:', error);
    return res.status(500).json({ message: 'Failed to delete image' });
  }
}
