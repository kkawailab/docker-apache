# Dockerfile コマンド解説ガイド

このガイドでは、Dockerfileで使用される主要なコマンドについて、実例とともに解説します。

## 目次
1. [FROM - ベースイメージの指定](#from---ベースイメージの指定)
2. [RUN - コマンドの実行](#run---コマンドの実行)
3. [CMD - デフォルトコマンドの設定](#cmd---デフォルトコマンドの設定)
4. [ENTRYPOINT - エントリーポイントの設定](#entrypoint---エントリーポイントの設定)
5. [COPY - ファイルのコピー](#copy---ファイルのコピー)
6. [ADD - ファイルの追加](#add---ファイルの追加)
7. [ENV - 環境変数の設定](#env---環境変数の設定)
8. [ARG - ビルド引数の定義](#arg---ビルド引数の定義)
9. [WORKDIR - 作業ディレクトリの設定](#workdir---作業ディレクトリの設定)
10. [EXPOSE - ポートの公開](#expose---ポートの公開)
11. [USER - ユーザーの設定](#user---ユーザーの設定)
12. [VOLUME - ボリュームの定義](#volume---ボリュームの定義)
13. [LABEL - メタデータの追加](#label---メタデータの追加)

## FROM - ベースイメージの指定

すべてのDockerfileは`FROM`命令から始まります（パーサーディレクティブとARGを除く）。

### 構文
```dockerfile
FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
```

### 実例
```dockerfile
# 基本的な使用例
FROM ubuntu:22.04

# タグを省略した場合（latest が使用される）
FROM nginx

# プラットフォームを指定
FROM --platform=linux/amd64 node:18

# マルチステージビルドで名前を付ける
FROM golang:1.20 AS builder
```

## RUN - コマンドの実行

イメージのビルド時にコマンドを実行し、新しいレイヤーを作成します。

### 構文
```dockerfile
# シェル形式
RUN <command>

# exec形式
RUN ["executable", "param1", "param2"]
```

### 実例
```dockerfile
# パッケージのインストール（シェル形式）
RUN apt-get update && apt-get install -y \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# exec形式の使用
RUN ["apt-get", "update"]

# 複数のコマンドを1つのRUNで実行（レイヤー数の削減）
RUN mkdir -p /app/data \
    && chmod 755 /app/data \
    && echo "Setup complete" > /app/data/setup.log

# ビルドマウントを使用したキャッシュ
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

## CMD - デフォルトコマンドの設定

コンテナ起動時のデフォルトコマンドを設定します。

### 構文
```dockerfile
# exec形式（推奨）
CMD ["executable","param1","param2"]

# ENTRYPOINTのデフォルトパラメータ
CMD ["param1","param2"]

# シェル形式
CMD command param1 param2
```

### 実例
```dockerfile
# Webサーバーの起動
CMD ["nginx", "-g", "daemon off;"]

# Node.jsアプリケーションの起動
CMD ["node", "server.js"]

# シェル形式（変数展開が可能）
CMD echo "Server started at $(date)" && python app.py
```

## ENTRYPOINT - エントリーポイントの設定

コンテナを実行可能ファイルとして設定します。

### 構文
```dockerfile
# exec形式（推奨）
ENTRYPOINT ["executable", "param1", "param2"]

# シェル形式
ENTRYPOINT command param1 param2
```

### 実例
```dockerfile
# 基本的な使用例
ENTRYPOINT ["python"]
CMD ["app.py"]  # デフォルト引数

# Apache の起動
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# シェルスクリプトをエントリーポイントに
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
```

## COPY - ファイルのコピー

ホストからコンテナへファイルやディレクトリをコピーします。

### 構文
```dockerfile
COPY [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
```

### 実例
```dockerfile
# 単一ファイルのコピー
COPY index.html /var/www/html/

# ディレクトリ全体のコピー
COPY ./src /app/src

# 所有者を指定してコピー
COPY --chown=node:node package*.json ./

# パーミッションを指定してコピー
COPY --chmod=755 scripts/*.sh /usr/local/bin/

# マルチステージビルドから別のステージへコピー
COPY --from=builder /app/dist /usr/share/nginx/html
```

## ADD - ファイルの追加

COPYと似ていますが、追加機能があります（URLからのダウンロード、tarの自動展開）。

### 構文
```dockerfile
ADD [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
```

### 実例
```dockerfile
# tarファイルの自動展開
ADD app.tar.gz /app/

# URLからファイルをダウンロード
ADD https://example.com/config.json /app/config.json

# 通常のファイルコピー（COPYを使うべき）
ADD index.html /var/www/html/
```

## ENV - 環境変数の設定

環境変数を設定します。

### 構文
```dockerfile
ENV <key>=<value> ...
```

### 実例
```dockerfile
# 単一の環境変数
ENV NODE_ENV=production

# 複数の環境変数
ENV NODE_ENV=production \
    PORT=3000 \
    API_URL=https://api.example.com

# パスの設定
ENV PATH="/app/bin:${PATH}"

# 後続の命令で使用
ENV APP_HOME=/app
WORKDIR ${APP_HOME}
```

## ARG - ビルド引数の定義

ビルド時に渡せる変数を定義します。

### 構文
```dockerfile
ARG <name>[=<default value>]
```

### 実例
```dockerfile
# デフォルト値なし
ARG VERSION

# デフォルト値あり
ARG NODE_VERSION=18

# FROM命令で使用
ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

# ビルド時に値を渡す
# docker build --build-arg VERSION=1.0.0 .
```

## WORKDIR - 作業ディレクトリの設定

作業ディレクトリを設定します。

### 構文
```dockerfile
WORKDIR /path/to/workdir
```

### 実例
```dockerfile
# 絶対パスの指定
WORKDIR /app

# 相対パスの指定（前のWORKDIRからの相対）
WORKDIR src

# 環境変数の使用
ENV APP_HOME=/usr/src/app
WORKDIR ${APP_HOME}

# ディレクトリが存在しない場合は作成される
WORKDIR /app/data/logs
```

## EXPOSE - ポートの公開

コンテナがリッスンするポートを文書化します。

### 構文
```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

### 実例
```dockerfile
# 単一ポート
EXPOSE 80

# 複数ポート
EXPOSE 80 443

# プロトコルを指定
EXPOSE 80/tcp
EXPOSE 53/udp

# 環境変数の使用
ENV PORT=8080
EXPOSE ${PORT}
```

## USER - ユーザーの設定

以降のコマンドを実行するユーザーを設定します。

### 構文
```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```

### 実例
```dockerfile
# ユーザー名で指定
USER node

# ユーザーとグループを指定
USER node:node

# UIDで指定
USER 1000

# ユーザーの作成と切り替え
RUN useradd -m -u 1001 appuser
USER appuser
```

## VOLUME - ボリュームの定義

ボリュームマウントポイントを作成します。

### 構文
```dockerfile
VOLUME ["/data"]
VOLUME /var/log /var/db
```

### 実例
```dockerfile
# 単一ボリューム
VOLUME /data

# 複数ボリューム（JSON形式）
VOLUME ["/var/log", "/var/cache/app"]

# 実用例：データベース用
VOLUME /var/lib/postgresql/data

# 実用例：ログ用
VOLUME ["/app/logs", "/var/log/nginx"]
```

## LABEL - メタデータの追加

イメージにメタデータを追加します。

### 構文
```dockerfile
LABEL <key>=<value> <key>=<value> ...
```

### 実例
```dockerfile
# 基本的なラベル
LABEL version="1.0"
LABEL description="This is a web application"

# 複数のラベル
LABEL maintainer="user@example.com" \
      version="1.0.0" \
      description="Apache web server"

# OCI標準のラベル
LABEL org.opencontainers.image.created="2024-01-01" \
      org.opencontainers.image.authors="dev@example.com" \
      org.opencontainers.image.url="https://example.com" \
      org.opencontainers.image.version="1.0.0"
```

## 実践的な Dockerfile の例

### Node.js アプリケーション
```dockerfile
# マルチステージビルド
FROM node:18-alpine AS builder

# 作業ディレクトリの設定
WORKDIR /app

# 依存関係のインストール（キャッシュ効率化）
COPY package*.json ./
RUN npm ci --only=production

# アプリケーションコードのコピー
COPY . .

# 本番用イメージ
FROM node:18-alpine

# セキュリティのためnon-rootユーザーで実行
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

WORKDIR /app

# ビルドステージから必要なファイルのみコピー
COPY --from=builder --chown=nodejs:nodejs /app .

USER nodejs

EXPOSE 3000

CMD ["node", "server.js"]
```

### Python Flask アプリケーション
```dockerfile
FROM python:3.11-slim

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 環境変数の設定
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_HOME=/app

WORKDIR ${APP_HOME}

# 依存関係のインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションのコピー
COPY . .

# non-rootユーザーの作成と切り替え
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser ${APP_HOME}
USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

## ベストプラクティス

1. **レイヤーの最小化**: 関連するコマンドは`&&`で連結して1つのRUN命令にまとめる
2. **キャッシュの活用**: 変更頻度の低いものを先にCOPY/ADDする
3. **マルチステージビルド**: 最終イメージのサイズを削減
4. **non-rootユーザー**: セキュリティのため、可能な限りrootユーザーを避ける
5. **.dockerignore**: 不要なファイルをビルドコンテキストから除外
6. **特定のタグ使用**: `latest`タグではなく、特定のバージョンを指定

## 参考リンク
- [Dockerfile reference - Docker Documentation](https://docs.docker.com/reference/dockerfile/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)