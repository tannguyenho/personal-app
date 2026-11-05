---
status: accepted, 05/11/2026
---

# Hạ tầng Beta: một VPS Ubuntu ở Singapore, Docker Compose, không dùng dịch vụ quản lý

Beta 1.0 (khoảng 20 người dùng) chạy trên VPS Ubuntu 2 CPU / 2 GB RAM có sẵn, đặt ở Singapore, đáp ứng yêu cầu máy chủ khu vực châu Á (Q29). Backend, PostgreSQL và Caddy chạy bằng Docker Compose; prod và staging là hai stack trên cùng máy. Job nền chạy ngay trong tiến trình backend với lease bằng Postgres, không dùng Redis. Sao lưu `pg_dump` mỗi đêm lên R2 / B2, giữ 30 ngày. Domain: `wakeup.tannguyenho.tech` (web tối giản) và `api.wakeup.tannguyenho.tech` (API, webhook).

## Considered Options

- Postgres có người quản lý (Neon, Supabase): bớt việc vận hành nhưng thêm một bên xử lý dữ liệu ở nước ngoài và thêm chi phí; chưa cần ở quy mô 20 người.
- Kubernetes hoặc PaaS: thừa cho một người vận hành.

## Consequences

- Một máy là một điểm lỗi duy nhất; chấp nhận cho Beta, cần thử khôi phục bản sao lưu trước khi mở Beta.
- Phải thêm swap và giới hạn RAM cho Postgres.
- Khi tăng quy mô: tách Postgres trước, sau đó mới tách job khỏi tiến trình API.
- VPS, Sentry, Resend, R2 đều ở ngoài Việt Nam: đưa vào hồ sơ đánh giá chuyển dữ liệu ra nước ngoài (Nghị định 13/2023).
