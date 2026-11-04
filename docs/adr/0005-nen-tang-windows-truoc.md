# Bản 1.0 là app Windows viết bằng Flutter, dữ liệu trên cloud gắn tài khoản

Bản 1.0 phát hành dưới dạng app Windows (Flutter), theo design system riêng trên Figma. Bản 1.1 thêm web và macOS, bản 1.2 thêm iOS / Android. Dù chỉ có một nền tảng, 1.0 vẫn có tài khoản và lưu dữ liệu trên cloud, vì kết nối Google / Outlook cần OAuth và để lên web, di động sau này không phải chuyển đổi dữ liệu. App Windows cũng là điều kiện để chạy Claude Code CLI và MCP local (ADR-0004). Kiến trúc cụ thể do tech chốt riêng.

## Considered Options

- Web trước (như bản nháp ban đầu): không chạy được Claude Code CLI trên máy người dùng.
- Dữ liệu chỉ nằm trên máy ở 1.0: đơn giản hơn, nhưng phải chuyển đổi dữ liệu khi lên web / di động và khó làm OAuth lịch.
