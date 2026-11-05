# Build từ thư mục gốc repo: docker build -f apps/server/Dockerfile .
FROM dart:3.13 AS build
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
COPY packages/core packages/core
COPY apps/server apps/server
# Workspace khai báo cả app desktop và ds_tokens (Flutter); image server chỉ
# cần core + server nên thu gọn danh sách workspace trước khi pub get.
RUN sed -i '/packages\/ds_tokens/d; /apps\/desktop/d' pubspec.yaml \
 && dart pub get \
 && dart compile exe apps/server/bin/server.dart -o /src/server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/server /app/server
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
EXPOSE 8080
USER nobody
CMD ["/app/server"]
