import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import axios from 'axios';
import { toast } from 'react-toastify';
import { useRouter } from 'next/router';
import Image from 'next/image';

const UploadForm = () => {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // ファイルドロップ処理
  const onDrop = useCallback((acceptedFiles: File[]) => {
    const selectedFile = acceptedFiles[0];
    if (selectedFile) {
      setFile(selectedFile);
      
      // プレビュー表示用のURL作成
      const previewUrl = URL.createObjectURL(selectedFile);
      setPreview(previewUrl);
    }
  }, []);

  // Dropzoneフック設定
  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.gif', '.webp']
    },
    maxFiles: 1,
    multiple: false
  });

  // フォーム送信処理
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!file) {
      toast.error('画像を選択してください');
      return;
    }

    if (!title.trim()) {
      toast.error('タイトルを入力してください');
      return;
    }

    try {
      setLoading(true);
      
      // FormDataの作成
      const formData = new FormData();
      formData.append('file', file);
      formData.append('title', title);
      if (description) {
        formData.append('description', description);
      }

      // APIにアップロード
      const response = await axios.post('/api/images', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      toast.success('画像のアップロードが完了しました');
      
      // 作成した画像の詳細ページに遷移
      router.push(`/images/${response.data.id}`);
    } catch (error) {
      console.error('Upload error:', error);
      toast.error('アップロードに失敗しました。もう一度お試しください。');
    } finally {
      setLoading(false);
    }
  };

  // リセット処理
  const handleReset = () => {
    setTitle('');
    setDescription('');
    setFile(null);
    setPreview(null);
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-2xl mx-auto">
      <div className="mb-6">
        <label htmlFor="title" className="label">
          タイトル *
        </label>
        <input
          type="text"
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="input"
          placeholder="画像のタイトルを入力"
          required
        />
      </div>

      <div className="mb-6">
        <label htmlFor="description" className="label">
          説明
        </label>
        <textarea
          id="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="input min-h-[100px]"
          placeholder="画像の説明を入力（任意）"
        />
      </div>

      <div className="mb-6">
        <div
          {...getRootProps()}
          className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
            isDragActive ? 'border-primary-500 bg-primary-50' : 'border-gray-300 hover:border-primary-400'
          }`}
        >
          <input {...getInputProps()} />
          {preview ? (
            <div className="relative h-64 mx-auto max-w-md">
              <Image
                src={preview}
                alt="プレビュー"
                fill
                style={{ objectFit: 'contain' }}
                className="mx-auto"
              />
            </div>
          ) : (
            <div className="py-8">
              <p className="text-lg mb-2">ここに画像をドラッグ＆ドロップ</p>
              <p className="text-gray-500">または</p>
              <button
                type="button"
                className="btn btn-primary mt-4"
                onClick={(e) => {
                  e.stopPropagation();
                  const input = document.querySelector('input[type="file"]');
                  if (input) (input as HTMLInputElement).click();
                }}
              >
                ファイルを選択
              </button>
            </div>
          )}
        </div>
        {file && (
          <p className="mt-2 text-sm text-gray-500">
            ファイル: {file.name} ({(file.size / 1024 / 1024).toFixed(2)} MB)
          </p>
        )}
      </div>

      <div className="flex space-x-4 justify-end">
        <button
          type="button"
          onClick={handleReset}
          className="btn btn-secondary"
          disabled={loading}
        >
          リセット
        </button>
        <button
          type="submit"
          className="btn btn-primary"
          disabled={loading || !file}
        >
          {loading ? 'アップロード中...' : 'アップロード'}
        </button>
      </div>
    </form>
  );
};

export default UploadForm;
