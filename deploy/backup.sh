#!/usr/bin/env bash
# Sao lưu Postgres mỗi đêm lên R2 / B2, giữ 30 ngày (ADR-0007).
# Cron trên VPS: 15 3 * * * /opt/wakeup/deploy/backup.sh prod
# Cần: rclone đã cấu hình remote tên "backup" (R2 hoặc B2).
set -euo pipefail

env_name="${1:-prod}"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
file="/tmp/wakeup-${env_name}-${stamp}.sql.gz"

docker compose -p "wakeup-${env_name}" exec -T db \
  pg_dump -U wakeup -d wakeup --no-owner | gzip > "${file}"

rclone copy "${file}" "backup:wakeup-backups/${env_name}/"
rclone delete --min-age 30d "backup:wakeup-backups/${env_name}/"
rm -f "${file}"

if [[ -n "${HEALTHCHECK_BACKUP_URL:-}" ]]; then
  curl -fsS -m 10 "${HEALTHCHECK_BACKUP_URL}" > /dev/null
fi
