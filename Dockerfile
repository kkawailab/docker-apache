# Dockerfile.simple
FROM ubuntu:24.04

# ※非対話モードかつタイムゾーンを設定
ENV DEBIAN_FRONTEND="noninteractive" \
    TZ="Asia/Tokyo"

# Apache2 をインストールし、キャッシュをクリーンアップ
RUN apt-get update \
    && apt-get install -y apache2 \
    && rm -rf /var/lib/apt/lists/*

# Web コンテンツをコピー
COPY index.html /var/www/html/

# フォアグラウンドで Apache を起動
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# ポートを公開
EXPOSE 80
