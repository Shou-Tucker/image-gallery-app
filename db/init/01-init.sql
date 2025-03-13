-- データベースの初期化スクリプト

-- タグテーブル作成
CREATE TABLE IF NOT EXISTS "Tag" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" TEXT NOT NULL UNIQUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 画像テーブル作成
CREATE TABLE IF NOT EXISTS "Image" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "title" TEXT NOT NULL,
  "description" TEXT,
  "url" TEXT NOT NULL,
  "key" TEXT NOT NULL UNIQUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 画像とタグの関連テーブル作成
CREATE TABLE IF NOT EXISTS "_ImageToTag" (
  "A" UUID NOT NULL,
  "B" UUID NOT NULL,
  FOREIGN KEY ("A") REFERENCES "Image"("id") ON DELETE CASCADE,
  FOREIGN KEY ("B") REFERENCES "Tag"("id") ON DELETE CASCADE
);

-- インデックス作成
CREATE UNIQUE INDEX IF NOT EXISTS "_ImageToTag_AB_unique" ON "_ImageToTag"("A", "B");
CREATE INDEX IF NOT EXISTS "_ImageToTag_B_index" ON "_ImageToTag"("B");

-- updatedAtを自動更新するトリガー関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Image テーブルの更新時にトリガーを実行
CREATE TRIGGER update_image_updated_at
BEFORE UPDATE ON "Image"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- Tag テーブルの更新時にトリガーを実行
CREATE TRIGGER update_tag_updated_at
BEFORE UPDATE ON "Tag"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();