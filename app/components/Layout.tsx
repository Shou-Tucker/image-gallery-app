import React, { ReactNode } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

type LayoutProps = {
  children: ReactNode;
  title?: string;
};

const Layout = ({ children, title = 'Image Gallery' }: LayoutProps) => {
  return (
    <>
      <Head>
        <title>{title} | Image Gallery App</title>
        <meta name="description" content="画像アップロード・表示アプリケーション" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="min-h-screen flex flex-col">
        <header className="bg-white shadow">
          <div className="container py-4">
            <nav className="flex justify-between items-center">
              <Link href="/" className="text-2xl font-bold text-primary-600">
                Image Gallery
              </Link>
              <div className="flex space-x-4">
                <Link href="/" className="btn btn-secondary">
                  ホーム
                </Link>
                <Link href="/upload" className="btn btn-primary">
                  アップロード
                </Link>
              </div>
            </nav>
          </div>
        </header>

        <main className="flex-grow container py-8">
          {title && <h1 className="text-3xl font-bold mb-8">{title}</h1>}
          {children}
        </main>

        <footer className="bg-gray-100 border-t">
          <div className="container py-6">
            <p className="text-center text-gray-600">
              &copy; {new Date().getFullYear()} Image Gallery App
            </p>
          </div>
        </footer>
      </div>

      <ToastContainer position="bottom-right" />
    </>
  );
};

export default Layout;
