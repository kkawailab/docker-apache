# Docker Apache Web Server

このプロジェクトは、Dockerを使用してApache Webサーバーを構築・実行するためのシンプルな構成です。

## 目次

- [概要](#概要)
- [前提条件](#前提条件)
- [プロジェクト構成](#プロジェクト構成)
- [セットアップ手順](#セットアップ手順)
- [Dockerイメージのビルド](#dockerイメージのビルド)
- [コンテナの実行](#コンテナの実行)
- [コンテナの管理](#コンテナの管理)
- [カスタマイズ](#カスタマイズ)
- [トラブルシューティング](#トラブルシューティング)

## 概要

このDockerfileは以下の特徴を持つApache Webサーバーコンテナを作成します：

- **ベースイメージ**: Ubuntu 24.04
- **Webサーバー**: Apache2
- **タイムゾーン**: Asia/Tokyo
- **公開ポート**: 80 (HTTP)

Dockerfileの各コマンドの詳細については、[Dockerfileコマンド解説ガイド](./dockerfile-guide.md)を参照してください。また、本プロジェクトのDockerfileの詳細な行ごとの解説は[Dockerfile詳細解説](./dockerfile-detailed-explanation.md)をご覧ください。

## 前提条件

以下のソフトウェアがインストールされている必要があります：

- Docker Desktop (Windows/Mac) または Docker Engine (Linux)
  - バージョン 20.10.0 以上を推奨
- Git (オプション: リポジトリをクローンする場合)

### Dockerのインストール確認

```bash
# Dockerのバージョン確認
docker --version

# Docker Composeのバージョン確認（オプション）
docker compose version
```

## プロジェクト構成

```
docker-apache/
├── Dockerfile                        # Apache用のDockerfile
├── index.html                       # Webコンテンツ（要作成）
├── README.md                        # このファイル
├── CLAUDE.md                        # Claude Code用ガイド
├── dockerfile-guide.md              # Dockerfileコマンド解説
└── dockerfile-detailed-explanation.md # Dockerfile詳細解説
```

## セットアップ手順

### 1. リポジトリのクローン（Gitを使用する場合）

```bash
git clone https://github.com/kkawailab/docker-apache.git
cd docker-apache
```

### 2. index.htmlファイルの作成

Dockerfileは`index.html`ファイルをコピーするように設定されているため、まずこのファイルを作成する必要があります。

```bash
# シンプルなindex.htmlの作成例
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker Apache サンプル</title>
</head>
<body>
    <h1>Docker Apache Web Server</h1>
    <p>Dockerコンテナで動作するApacheサーバーへようこそ！</p>
    <p>現在時刻: <span id="time"></span></p>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString('ja-JP');
    </script>
</body>
</html>
EOF
```

## Dockerイメージのビルド

### 基本的なビルド

```bash
# カレントディレクトリのDockerfileを使用してイメージをビルド
docker build -t apache-simple .
```

### ビルドオプションの詳細

```bash
# タグ名を指定してビルド
docker build -t myapache:1.0 .

# ビルド時の詳細情報を表示
docker build -t apache-simple --progress=plain .

# キャッシュを使用せずにビルド（クリーンビルド）
docker build -t apache-simple --no-cache .

# 別のDockerfileを指定してビルド
docker build -t apache-simple -f Dockerfile.simple .
```

### ビルドの確認

```bash
# 作成されたイメージの一覧を表示
docker images | grep apache-simple

# イメージの詳細情報を確認
docker inspect apache-simple
```

## コンテナの実行

### 基本的な実行

```bash
# バックグラウンドで実行（-d: detached mode）
docker run -d -p 8080:80 --name my-apache apache-simple
```

### 実行オプションの詳細

```bash
# フォアグラウンドで実行（ログを直接確認できる）
docker run -p 8080:80 --name my-apache apache-simple

# 自動削除オプション付きで実行（停止時にコンテナを自動削除）
docker run -d --rm -p 8080:80 --name my-apache apache-simple

# 環境変数を設定して実行
docker run -d -p 8080:80 -e TZ=Asia/Tokyo --name my-apache apache-simple

# ボリュームをマウントして実行（ローカルのHTMLファイルを使用）
docker run -d -p 8080:80 -v $(pwd)/html:/var/www/html --name my-apache apache-simple

# 複数のポートマッピング
docker run -d -p 8080:80 -p 8443:443 --name my-apache apache-simple
```

### アクセス確認

ブラウザで以下のURLにアクセスしてWebサーバーが動作していることを確認：

```
http://localhost:8080
```

またはcurlコマンドで確認：

```bash
curl http://localhost:8080
```

## コンテナの管理

### コンテナの状態確認

```bash
# 実行中のコンテナ一覧
docker ps

# すべてのコンテナ一覧（停止中も含む）
docker ps -a

# 特定のコンテナの詳細情報
docker inspect my-apache
```

### ログの確認

```bash
# コンテナのログを表示
docker logs my-apache

# ログをリアルタイムで追跡
docker logs -f my-apache

# 最新の10行のみ表示
docker logs --tail 10 my-apache
```

### コンテナの操作

```bash
# コンテナの停止
docker stop my-apache

# コンテナの開始
docker start my-apache

# コンテナの再起動
docker restart my-apache

# コンテナの削除（停止してから）
docker stop my-apache
docker rm my-apache

# 強制削除
docker rm -f my-apache
```

### コンテナ内でのコマンド実行

```bash
# コンテナ内でbashシェルを起動
docker exec -it my-apache bash

# Apacheの設定を確認
docker exec my-apache apache2 -V

# コンテナ内のファイルを確認
docker exec my-apache ls -la /var/www/html/
```

## カスタマイズ

### 1. 別のポートでの実行

```bash
# ホストの3000番ポートで公開
docker run -d -p 3000:80 --name my-apache apache-simple
```

### 2. カスタムHTMLの配置

```bash
# htmlディレクトリを作成
mkdir html
echo "<h1>カスタムページ</h1>" > html/index.html

# ボリュームマウントで実行
docker run -d -p 8080:80 -v $(pwd)/html:/var/www/html --name my-apache apache-simple
```

### 3. Apache設定のカスタマイズ

カスタム設定ファイルを使用する場合のDockerfile例：

```dockerfile
# カスタム設定を追加
COPY apache-custom.conf /etc/apache2/sites-available/000-default.conf
```

### 4. HTTPS対応

SSL証明書を含めたHTTPS対応の例：

```dockerfile
# SSL モジュールの有効化
RUN a2enmod ssl
RUN a2ensite default-ssl

# 証明書のコピー
COPY ssl/cert.pem /etc/ssl/certs/
COPY ssl/key.pem /etc/ssl/private/

EXPOSE 443
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. ポートが既に使用されている

```bash
# エラー: bind: address already in use
# 解決方法: 別のポートを使用
docker run -d -p 8081:80 --name my-apache apache-simple
```

#### 2. index.htmlが見つからない

```bash
# エラー: COPY failed: file not found in build context
# 解決方法: index.htmlファイルを作成
echo "<h1>Test Page</h1>" > index.html
```

#### 3. コンテナ名の重複

```bash
# エラー: Conflict. The container name "/my-apache" is already in use
# 解決方法: 既存のコンテナを削除または別名を使用
docker rm my-apache
# または
docker run -d -p 8080:80 --name my-apache2 apache-simple
```

#### 4. イメージのビルドエラー

```bash
# キャッシュをクリアして再ビルド
docker build --no-cache -t apache-simple .

# ビルドコンテキストの確認
docker build -t apache-simple . --progress=plain
```

### デバッグ用コマンド

```bash
# コンテナ内のプロセス確認
docker exec my-apache ps aux

# Apache エラーログの確認
docker exec my-apache tail -f /var/log/apache2/error.log

# ネットワーク設定の確認
docker exec my-apache netstat -tlnp

# ファイルシステムの使用状況
docker exec my-apache df -h
```

## 参考リンク

- [Dockerfileコマンド解説ガイド](./dockerfile-guide.md) - Dockerfileコマンドの一般的な解説
- [Dockerfile詳細解説](./dockerfile-detailed-explanation.md) - 本プロジェクトのDockerfile行ごとの詳細解説
- [Docker公式ドキュメント](https://docs.docker.com/)
- [Apache公式ドキュメント](https://httpd.apache.org/docs/2.4/)
- [Dockerfile リファレンス](https://docs.docker.com/reference/dockerfile/)

## ライセンス

このプロジェクトはサンプルコードとして提供されています。