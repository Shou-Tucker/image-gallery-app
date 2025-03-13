import type { GetServerSideProps, NextPage } from 'next';
import ImageCard from '../components/ImageCard';
import prisma from '../lib/prisma';
import { Image } from '@prisma/client';

type HomeProps = {
  images: Image[];
  title: string;
};

const Home: NextPage<HomeProps> = ({ images }) => {
  return (
    <div>
      {images.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-xl text-gray-600">まだ画像がアップロードされていません。</p>
          <a href="/upload" className="btn btn-primary mt-4">
            最初の画像をアップロード
          </a>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {images.map((image) => (
            <ImageCard key={image.id} image={image} />
          ))}
        </div>
      )}
    </div>
  );
};

export const getServerSideProps: GetServerSideProps = async () => {
  // データベースから画像一覧を取得
  const images = await prisma.image.findMany({
    orderBy: {
      createdAt: 'desc',
    },
  });

  // Date型をシリアライズ可能な形式に変換
  const serializedImages = images.map((image) => ({
    ...image,
    createdAt: image.createdAt.toISOString(),
    updatedAt: image.updatedAt.toISOString(),
  }));

  return {
    props: {
      images: serializedImages,
      title: '画像ギャラリー',
    },
  };
};

export default Home;
