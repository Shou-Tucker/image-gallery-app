import type { NextPage, GetStaticProps } from 'next';
import UploadForm from '../components/UploadForm';

type UploadPageProps = {
  title: string;
};

const UploadPage: NextPage<UploadPageProps> = () => {
  return (
    <div>
      <UploadForm />
    </div>
  );
};

export const getStaticProps: GetStaticProps = async () => {
  return {
    props: {
      title: '画像アップロード',
    },
  };
};

export default UploadPage;
