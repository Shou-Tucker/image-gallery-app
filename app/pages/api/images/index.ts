import type { NextApiRequest, NextApiResponse } from 'next';
import formidable from 'formidable';
import fs from 'fs';
import prisma from '../../../lib/prisma';
import { uploadImage } from '../../../lib/s3';

// formidableでファイルアップロード時にNext.jsのボディパースを無効化
export const config = {
  api: {
    bodyParser: false,
  },
};

// APIハンドラ
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  // HTTPメソッドで処理を分岐
  switch (req.method) {
    case 'GET':
      return getImages(req, res);
    case 'POST':
      return createImage(req, res);
    default:
      return res.status(405).json({ message: 'Method not allowed' });
  }
}

// 画像一覧取得
async function getImages(req: NextApiRequest, res: NextApiResponse) {
  try {
    const images = await prisma.image.findMany({
      orderBy: { createdAt: 'desc' },
    });

    return res.status(200).json(images);
  } catch (error) {
    console.error('Error fetching images:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

// 画像アップロード・作成
async function createImage(req: NextApiRequest, res: NextApiResponse) {
  return new Promise<void>((resolve, reject) => {
    // formidableでリクエストを解析
    const form = new formidable.IncomingForm({
      keepExtensions: true,
      maxFileSize: 10 * 1024 * 1024, // 10MB上限
    });

    form.parse(req, async (err, fields, files) => {
      if (err) {
        console.error('Form parse error:', err);
        res.status(500).json({ message: 'Error processing form data' });
        return resolve();
      }

      try {
        // フォームからのデータを取得
        const title = Array.isArray(fields.title) ? fields.title[0] : fields.title;
        const description = Array.isArray(fields.description) ? fields.description[0] : fields.description;
        const file = Array.isArray(files.file) ? files.file[0] : files.file;

        if (!file || !title) {
          res.status(400).json({ message: 'Missing required fields' });
          return resolve();
        }

        // ファイルをバッファに読み込み
        const fileBuffer = fs.readFileSync(file.filepath);
        
        // S3にアップロード
        const { key, url } = await uploadImage(fileBuffer, file.mimetype || 'image/jpeg');

        // データベースに画像情報を保存
        const image = await prisma.image.create({
          data: {
            title,
            description: description || null,
            url,
            key,
          },
        });

        res.status(201).json(image);
        return resolve();
      } catch (error) {
        console.error('Error processing image:', error);
        res.status(500).json({ message: 'Internal server error' });
        return resolve();
      }
    });
  });
}
