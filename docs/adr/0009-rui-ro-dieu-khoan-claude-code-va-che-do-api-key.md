---
status: accepted, 05/11/2026
---

# Giữ ADR-0004 cho Beta, thêm chế độ "dùng API key của bạn" để dự phòng rủi ro điều khoản

Anthropic không cho bên thứ ba dùng đăng nhập claude.ai hay hạn mức gói Pro / Max của người dùng cho sản phẩm của họ khi chưa được duyệt. App gọi Claude Code CLI do chính người dùng cài và đăng nhập (ADR-0004) là vùng xám. Beta vẫn làm theo ADR-0004, đồng thời hỗ trợ chế độ người dùng nhập `ANTHROPIC_API_KEY` để CLI dùng (lưu trong Windows Credential Manager, truyền qua biến môi trường). Nếu cách dùng gói claude.ai bị cấm, app vẫn còn đường chạy hợp lệ mà không phải viết lại G10.

## Considered Options

- Chỉ ghi rủi ro, không làm gì thêm: nếu bị cấm thì G10 mất đường chạy.
- Đổi ngay sang AI phía server bằng API key của app: app gánh chi phí AI, trái với lý do chọn ADR-0004.

## Consequences

- Cần pháp chế hoặc Anthropic xác nhận trước khi phát hành rộng bản 1.0.
- Màn Cài đặt → Trợ lý AI thêm lựa chọn nguồn xác thực (tài khoản Claude / API key).
- Phiên do app mở chỉ cho công cụ `mcp__wakeup__*`, tắt Bash, file và web, để giảm rủi ro an toàn bất kể nguồn xác thực.
