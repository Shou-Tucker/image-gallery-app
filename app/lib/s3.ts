import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { v4 as uuidv4 } from 'uuid';

// S3クライアントの設定
const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.S3_ENDPOINT,
  forcePathStyle: true, // LocalStackで必要
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test',
  },
});

// バケット名の取得
const bucketName = process.env.S3_BUCKET_NAME || 'image-gallery-local';

/**
 * 画像をS3にアップロードする
 * @param file 画像ファイルのバッファ
 * @param mimetype ファイルのMIMEタイプ
 * @returns アップロードされたファイルのキーとURL
 */
export const uploadImage = async (file: Buffer, mimetype: string): Promise<{ key: string; url: string }> => {
  // ユニークなキーの生成（ファイル名）
  const key = `images/${uuidv4()}-${Date.now()}`;
  
  // S3へアップロードするためのコマンド作成
  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    Body: file,
    ContentType: mimetype,
    ACL: 'public-read', // 公開アクセス権の設定
  });

  // アップロード実行
  await s3Client.send(command);

  // S3のURLを構築
  let url = '';
  if (process.env.S3_ENDPOINT && process.env.S3_ENDPOINT.includes('localstack')) {
    // ローカル環境の場合
    url = `${process.env.S3_ENDPOINT}/${bucketName}/${key}`;
  } else {
    // AWS環境の場合
    url = `https://${bucketName}.s3.${process.env.AWS_REGION || 'us-east-1'}.amazonaws.com/${key}`;
  }

  return { key, url };
};

/**
 * S3から画像を削除する
 * @param key 削除対象のファイルキー
 */
export const deleteImage = async (key: string): Promise<void> => {
  const command = new DeleteObjectCommand({
    Bucket: bucketName,
    Key: key,
  });

  await s3Client.send(command);
};
