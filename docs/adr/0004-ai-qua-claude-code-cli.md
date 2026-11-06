# Trợ lý AI chạy bằng Claude Code CLI của người dùng, điều khiển app qua MCP local

Mọi tính năng AI (chat, Planning Agent, highlights, gợi ý task) dùng Claude Code CLI do người dùng tự cài và đăng nhập trên máy, thay vì app tự gọi một LLM phía server. App mở một MCP server local để Claude Code đọc và điều khiển app; người dùng cũng có thể dùng Claude Code trong terminal riêng để điều khiển app. Nhờ vậy app không gánh chi phí AI, không cần hạn mức AI theo gói, và AI có mặt ngay từ bản 1.0 trên Windows. Đổi lại, AI chỉ có trên máy đã cài Claude Code; khi lên web và di động cần một cách khác (để tech chốt).

## Consequences

- AI chuyển từ bản 1.2 lên 1.0. Bỏ các hạn mức AI trong QC-10.
- Thay đổi một phần [ADR-0003](0003-gioi-han-quyen-cua-tro-ly-ai.md): AI vẫn mặc định không hoàn thành / xoá task, nhưng người dùng bật được công tắc cho phép (trừ task có liên kết tích hợp).
- Quy tắc chung nằm ở QC-12.
- **Cập nhật 06/11/2026 (F4):** bỏ công tắc cho phép ở ý trên. Khi trợ lý bật và người dùng đã đồng ý, AI luôn được hoàn thành và xoá task / subtask (xoá vào Thùng rác, có Hoàn tác); task có liên kết tích hợp vẫn không bao giờ được AI hoàn thành hay xoá. Xem [quyết định 06/11](../review/quyet-dinh-chot-2026-11-06.md).
- Cách gọi CLI, MCP local và chế độ API key dự phòng: [`docs/tech/01`](../tech/01-quyet-dinh-tech-stack-va-api.md) mục 4, [ADR-0009](0009-rui-ro-dieu-khoan-claude-code-va-che-do-api-key.md).

## Điều khoản của Anthropic (chốt 05/11/2026, ticket #25)

PO giữ nguyên mô hình này và **chấp nhận rủi ro điều khoản**; không chờ xác nhận pháp lý từ Anthropic trước khi làm tiếp. Lý do PO nêu: đã có nhiều sản phẩm tích hợp Claude Code làm một phần của sản phẩm.

Bối cảnh để người đọc sau biết: trang [Legal and compliance](https://code.claude.com/docs/en/legal-and-compliance) (đọc lại ngày 05/11/2026) vừa cho phép người dùng tự đăng nhập Claude Code bản gốc bằng gói của họ, vừa cấm bên thứ ba "route requests through Free, Pro, Max, or Ultra plan credentials on behalf of their users", và khuyên nhà phát triển sản phẩm dùng API key. Extension Claude Code cho VS Code là sản phẩm do chính Anthropic phát hành, nên không phải tiền lệ cho app bên thứ ba. Nếu Anthropic thay đổi hoặc làm rõ theo hướng chặn, phương án dự phòng là chỉ bật AI trong app khi Claude Code đăng nhập bằng API key của người dùng, và giữ đường người dùng tự dùng Claude Code trong terminal.

Hai quy tắc vẫn giữ vì trang ghi rõ, không phụ thuộc rủi ro trên:
- App không xử lý đăng nhập Claude: không nhúng trang đăng nhập, không đọc hay lưu token; chỉ hướng dẫn người dùng tự chạy lệnh đăng nhập.
- Không dùng tên hoặc logo Claude Code / Anthropic làm tên sản phẩm, tính năng hay nút; chỉ được ghi chữ thường "chạy bằng Claude Code". Tên trợ lý (D16) không chứa "Claude".
