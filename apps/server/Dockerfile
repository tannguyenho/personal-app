# Build từ thư mục gốc repo: docker build -f apps/server/Dockerfile .
FROM dart:3.13 AS build
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
COPY packages/core packages/core
COPY apps/server apps/server
# Workspace còn khai báo các package Flutter (desktop, widgetbook, ds_tokens);
# image server chỉ cần core + server nên giữ đúng hai mục đó trong danh sách
# workspace trước khi pub get (thêm thành viên mới không làm hỏng image).
RUN sed -i '/^  - /{/packages\/core$\|apps\/server$/!d}' pubspec.yaml \
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
