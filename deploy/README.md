# Triển khai

Hạ tầng Beta theo [ADR-0007](../docs/adr/0007-ha-tang-vps-singapore.md): một VPS Ubuntu ở Singapore, Docker Compose.

| File | Dùng cho |
|---|---|
| `compose.yaml` | Stack một môi trường: `api`, `db`, `migrate` (profile) |
| `compose.caddy.yaml` + `Caddyfile` | Caddy dùng chung, TLS tự động, phục vụ `apps/web-mini` |
| `compose.dev.yaml` | Postgres cho máy dev |
| `backup.sh` | `pg_dump` mỗi đêm lên R2 / B2, giữ 30 ngày |
| `.env.example` | Mẫu biến môi trường |

Lần đầu trên VPS:

```
docker network create wakeup-edge
docker compose -f compose.caddy.yaml up -d
docker compose -p wakeup-prod --env-file .env.prod --profile migrate run --rm migrate
docker compose -p wakeup-prod --env-file .env.prod up -d
```

Làm tương tự với `-p wakeup-staging --env-file .env.staging`. Nhớ thêm swap 2 GB cho VPS và thử khôi phục một bản sao lưu trước khi mở Beta.

Chưa có: workflow deploy tự động (build image, SSH vào VPS).
