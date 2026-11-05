# wakeup_server

Backend Wakeup: Dart `shelf`, PostgreSQL, SQL tay, migration bằng dbmate ([`docs/tech/01`](../../docs/tech/01-quyet-dinh-tech-stack-va-api.md) mục 5–7, [ADR-0006](../../docs/adr/0006-backend-dart-va-dong-bo-theo-lenh.md)).

Chạy trên máy:

```
docker compose -f ../../deploy/compose.dev.yaml up -d
dbmate --url "postgres://wakeup:wakeup@localhost:5432/wakeup?sslmode=disable" -d db/migrations up
DATABASE_URL="postgres://wakeup:wakeup@localhost:5432/wakeup?sslmode=disable" dart run bin/server.dart
```

Endpoint hiện có:

| Endpoint | Trạng thái |
|---|---|
| `GET /healthz` | Báo trạng thái server và DB |
| `GET /v1/app/latest` | Phiên bản app mới nhất, cho tự cập nhật |
| `POST /v1/commands` | Mới kiểm tra hình dạng lô lệnh, trả `NOT_IMPLEMENTED` |
| `GET /v1/changes` | Trả `NOT_IMPLEMENTED` |

Mọi request `/v1` có header `X-App-Version` cũ hơn `MIN_CLIENT_VERSION` nhận `CLIENT_TOO_OLD`.
