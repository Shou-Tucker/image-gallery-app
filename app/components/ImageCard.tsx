import React from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { Image as ImageType } from '@prisma/client';

type ImageCardProps = {
  image: ImageType;
};

const ImageCard = ({ image }: ImageCardProps) => {
  return (
    <div className="card transition-transform hover:scale-105">
      <Link href={`/images/${image.id}`}>
        <div className="relative h-48 w-full">
          <Image
            src={image.url}
            alt={image.title}
            fill
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
            style={{ objectFit: 'cover' }}
            className="rounded-t-lg"
          />
        </div>
        <div className="p-4">
          <h3 className="font-bold text-lg line-clamp-1">{image.title}</h3>
          {image.description && (
            <p className="text-gray-600 text-sm mt-1 line-clamp-2">{image.description}</p>
          )}
          <p className="text-gray-500 text-xs mt-2">
            {new Date(image.createdAt).toLocaleDateString('ja-JP')}
          </p>
        </div>
      </Link>
    </div>
  );
};

export default ImageCard;
