# Trợ lý AI chạy bằng Claude Code CLI của người dùng, điều khiển app qua MCP local

Mọi tính năng AI (chat, Planning Agent, highlights, gợi ý task) dùng Claude Code CLI do người dùng tự cài và đăng nhập trên máy, thay vì app tự gọi một LLM phía server. App mở một MCP server local để Claude Code đọc và điều khiển app; người dùng cũng có thể dùng Claude Code trong terminal riêng để điều khiển app. Nhờ vậy app không gánh chi phí AI, không cần hạn mức AI theo gói, và AI có mặt ngay từ bản 1.0 trên Windows. Đổi lại, AI chỉ có trên máy đã cài Claude Code; khi lên web và di động cần một cách khác (để tech chốt).

## Consequences

- AI chuyển từ bản 1.2 lên 1.0. Bỏ các hạn mức AI trong QC-10.
- Thay đổi một phần [ADR-0003](0003-gioi-han-quyen-cua-tro-ly-ai.md): AI vẫn mặc định không hoàn thành / xoá task, nhưng người dùng bật được công tắc cho phép (trừ task có liên kết tích hợp).
- Quy tắc chung nằm ở QC-12.
