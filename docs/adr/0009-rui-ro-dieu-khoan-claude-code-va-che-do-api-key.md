---
status: accepted, 05/11/2026; khớp với quyết định PO ở ADR-0004 (ticket #25)
---

# Phương án dự phòng cho rủi ro điều khoản Anthropic: chỉ bật AI khi Claude Code đăng nhập bằng API key

Trang [Legal and compliance](https://code.claude.com/docs/en/legal-and-compliance) cấm bên thứ ba "route requests through Free, Pro, Max, or Ultra plan credentials on behalf of their users". App gọi Claude Code CLI do chính người dùng cài và đăng nhập bằng gói của họ (ADR-0004) vì vậy có rủi ro. PO đã **chấp nhận rủi ro** và không chờ xác nhận pháp lý trước khi làm tiếp (ADR-0004, ticket #25). ADR này chỉ chốt phương án dự phòng, để nếu Anthropic chặn thì app vẫn còn đường chạy hợp lệ mà không phải viết lại G10.

**Phương án dự phòng:** app chỉ bật AI khi Claude Code đăng nhập bằng **API key của người dùng** (Anthropic Console). Người dùng tự cấu hình key trong Claude Code (biến môi trường `ANTHROPIC_API_KEY` hoặc đăng nhập Console qua `claude`); app chỉ hướng dẫn, **không nhận, không đọc, không lưu key hay token** (quy tắc giữ ở ADR-0004). Đường người dùng tự mở Claude Code trong terminal để điều khiển app qua MCP vẫn giữ nguyên.

## Considered Options

- Không chuẩn bị gì: nếu bị chặn thì G10 mất đường chạy.
- App tự nhận và lưu API key rồi truyền cho CLI: trái quy tắc "app không xử lý đăng nhập Claude" ở ADR-0004.
- Đổi ngay sang AI phía server bằng API key của app: app gánh chi phí AI, trái lý do chọn ADR-0004.

## Consequences

- Cần một cách phát hiện Claude Code đang đăng nhập bằng gói hay bằng API key, để bật phương án dự phòng khi cần (`[cần kiểm chứng]` khi làm G10).
- Phiên do app mở chỉ cho công cụ `mcp__wakeup__*`, tắt Bash, file và web, bất kể nguồn xác thực.
- Không dùng tên hoặc logo Claude Code / Anthropic làm tên sản phẩm, tính năng hay nút (ADR-0004).
