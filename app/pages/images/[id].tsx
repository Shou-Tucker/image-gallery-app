import { GetServerSideProps, NextPage } from 'next';
import Image from 'next/image';
import { useRouter } from 'next/router';
import { Image as ImageType } from '@prisma/client';
import prisma from '../../lib/prisma';
import axios from 'axios';
import { toast } from 'react-toastify';
import { useState } from 'react';

type ImageDetailProps = {
  image: ImageType & { title: string };
};

const ImageDetail: NextPage<ImageDetailProps> = ({ image }) => {
  const router = useRouter();
  const [isDeleting, setIsDeleting] = useState(false);

  // 削除処理
  const handleDelete = async () => {
    if (!confirm('本当にこの画像を削除しますか？この操作は取り消せません。')) {
      return;
    }

    try {
      setIsDeleting(true);
      await axios.delete(`/api/images/${image.id}`);
      toast.success('画像が削除されました');
      router.push('/');
    } catch (error) {
      console.error('Delete error:', error);
      toast.error('削除に失敗しました');
      setIsDeleting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto">
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="relative w-full h-[50vh]">
          <Image
            src={image.url}
            alt={image.title}
            fill
            priority
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 60vw"
            style={{ objectFit: 'contain' }}
            className="bg-gray-100"
          />
        </div>
        
        <div className="p-6">
          <h1 className="text-3xl font-bold">{image.title}</h1>
          
          {image.description && (
            <div className="mt-4 text-gray-700">
              <p>{image.description}</p>
            </div>
          )}
          
          <div className="mt-6 text-sm text-gray-500">
            <p>アップロード日時: {new Date(image.createdAt).toLocaleString('ja-JP')}</p>
          </div>
          
          <div className="mt-8 flex justify-end">
            <button
              onClick={handleDelete}
              disabled={isDeleting}
              className="btn btn-danger"
            >
              {isDeleting ? '削除中...' : '画像を削除'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export const getServerSideProps: GetServerSideProps = async ({ params }) => {
  const id = params?.id as string;

  // 画像データの取得
  const image = await prisma.image.findUnique({
    where: { id },
  });

  // 画像が見つからない場合は404ページへリダイレクト
  if (!image) {
    return {
      notFound: true,
    };
  }

  // Date型をシリアライズ可能な形式に変換
  return {
    props: {
      image: {
        ...image,
        createdAt: image.createdAt.toISOString(),
        updatedAt: image.updatedAt.toISOString(),
      },
      title: image.title,
    },
  };
};

export default ImageDetail;
