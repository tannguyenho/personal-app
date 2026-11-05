# Câu hỏi tech stack & API — chờ grill riêng

Trạng thái: **chưa chốt**. Tài liệu này gom các quyết định kỹ thuật cần chốt trong một buổi grill riêng với tech (Q45). Phần "API", "mã lỗi", "job" trong các SRS hiện chỉ là **hợp đồng nghiệp vụ tham khảo**; khi tech chốt, kết quả ghi vào thư mục này và ADR, SRS tham chiếu sang.

Đã chốt ở phía sản phẩm (đầu vào cho buổi grill):
- 1.0 là app Windows viết bằng Flutter; 1.1 web + macOS; 1.2 iOS / Android (ADR-0005).
- Có tài khoản và dữ liệu trên cloud từ 1.0; máy chủ khu vực châu Á (Q29).
- Trợ lý AI chạy bằng Claude Code CLI của người dùng, app mở MCP local (ADR-0004, QC-12).
- Giao diện theo design system Figma riêng.
- Các quy tắc nghiệp vụ dùng chung: `docs/01-quy-tac-dung-chung.md` (đặc biệt QC-01 ngày làm việc, QC-03 cụm vị trí, QC-08 đồng bộ).

## Câu hỏi theo nhánh

### 1. Client (Flutter)
- Quản lý state, kiến trúc thư mục, cách dùng design system Figma (token, component, Code Connect).
- Lưu trữ offline trên máy (SQLite / Drift / Isar…) và hàng đợi đồng bộ (QC-08).
- Đóng gói và cập nhật trên Windows (MSIX, installer, auto-update), ký số.
- Thông báo hệ thống Windows, phím tắt toàn cục, chạy nền / khay hệ thống.
- Chia sẻ code với web (1.1) và di động (1.2).
- Đóng cửa sổ khi đang có timer: thu về khay hệ thống hay thoát hẳn; tính projection / sức chứa ở nền.
- Phiên bản Windows tối thiểu.

### 2. Backend & dữ liệu
- Ngôn ngữ / framework, hosting và vùng (châu Á), môi trường.
- Cơ sở dữ liệu, mô hình dữ liệu (task, series, ngày ngoại lệ, timebox, bản ghi thời gian, cụm vị trí có phiên bản).
- Realtime và đồng bộ nhiều thiết bị: thứ tự theo server, phiên bản cụm vị trí, xử lý xung đột (QC-08).
- Job nền: rollover theo múi giờ từng người, lease, chạy bù ([RolloverEnsure]), sinh instance lặp, đồng bộ lịch.
- Sao lưu, xoá dữ liệu theo yêu cầu, lưu giữ log / chứng từ (C5).

### 3. Xác thực & tích hợp
- Đăng nhập trên app desktop: email + mật khẩu, Google / Microsoft OAuth (luồng loopback / PKCE), lưu token an toàn trên Windows, thời gian chờ đăng nhập qua trình duyệt.
- Bản 1.0 chưa có web: link trong email (xác minh, đặt lại mật khẩu, "Không phải tôi", tải bản xuất, huỷ đăng ký email, checkout 1.1) mở ở đâu — trang web tối giản hay deep link vào app.
- OAuth lịch Google / Outlook: webhook / push vs poll, xác minh ứng dụng Google (rủi ro chặn ngày ra mắt).
- Tích hợp Gmail / Jira / Notion (1.1): webhook, scope tối thiểu (C29).

### 4. AI: Claude Code CLI & MCP local
- Cách phát hiện CLI, kiểm tra phiên bản và trạng thái đăng nhập.
- Cách app gọi CLI (chế độ không tương tác, streaming đầu ra) cho chat, Planning Agent, highlights, gợi ý.
- Cách cài đặt MCP server local (stdio hay HTTP cục bộ), đăng ký với Claude Code, xác thực để chỉ tiến trình hợp lệ trên máy kết nối được.
- Danh sách công cụ MCP và schema; cách gắn chip AI, Hoàn tác theo lượt, chế độ chờ duyệt khi có dữ liệu tích hợp (QC-12).
- Cách cung cấp AI trên web / di động ở các bản sau.
- Phiên bản Claude Code tối thiểu; có cho chọn model không. (Điều khoản của Anthropic: PO chấp nhận rủi ro, chốt 05/11/2026, xem ADR-0004.)
- Bản ghi phiên do Claude Code tự lưu trên máy nằm ngoài phạm vi xoá dữ liệu của app (C30) — cách thông báo cho người dùng.

### 5. API
- Kiểu API (REST / GraphQL / RPC), quy ước đặt tên, phiên bản hoá.
- Danh mục mã lỗi chung (ví dụ `PAST_DATE`, `VERSION_CONFLICT`, `TASK_DELETED`) và cách client hiển thị MSG.
- Phân trang, idempotency key, rate limit.
- Tài liệu API (OpenAPI…) và cách giữ đồng bộ với SRS.

### 6. Vận hành & chất lượng
- CI/CD, kiểm thử (đơn vị, tích hợp, end-to-end trên Windows), bộ đánh giá AI (ca chuẩn QC-01).
- Giám sát, log, cảnh báo (mục tiêu rollover 95% ≤ 15 phút).
- Tracking sản phẩm và quyền riêng tư (NĐ 13/2023).
