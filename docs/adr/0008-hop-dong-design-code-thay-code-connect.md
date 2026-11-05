---
status: accepted, 05/11/2026
---

# Mapping 1-1 Figma ↔ Flutter bằng lớp hợp đồng sinh code, không dùng Code Connect

Design system trên Figma phải map 1-1 với code Flutter: token và component. Figma Code Connect làm được về kỹ thuật (template `.figma.ts` với `label: Flutter`, `language: dart` parse đúng khi chạy thử ngày 05/11/2026), nhưng mọi lệnh Code Connect bị từ chối trên gói Education hiện tại: *"You need a Dev or Full seat on an Organization or Enterprise plan to use Code Connect"*. REST API Variables cũng chỉ có ở Enterprise. Vì vậy dùng lớp hợp đồng: script Plugin API xuất `tokens.json` và `components.json`, bộ sinh code tạo token, enum và kiểu tham số Dart; CI báo đỏ khi Figma và code lệch; lint cấm giá trị cứng. Snippet Dart trong Dev Mode do một plugin Codegen riêng đảm nhận; description component ghi tên widget và đường dẫn file cho AI đọc qua MCP; Widgetbook và golden test so hình.

## Considered Options

- Nâng gói Figma Organization để dùng Code Connect: có snippet Dart trong Dev Mode và MCP, nhưng chỉ hiển thị mapping, không chặn được lệch giữa design và code; phí theo ghế.
- Bỏ Figma, thiết kế trong Widgetbook: mất công cụ thiết kế mà chủ dự án đang dùng.

## Consequences

- Lớp hợp đồng vẫn giữ lại nếu sau này nâng gói và bật Code Connect.
- Cần xác minh gói Education có cho chạy plugin Codegen trong Dev Mode không; nếu không thì nâng gói Organization.
- Quy ước tên Figma trở thành ràng buộc kỹ thuật: đổi tên variant trong Figma là thay đổi API của widget.
- File sandbox: https://www.figma.com/design/zWidv5HFfFRIR9IrrFFObb
- Lần chạy thử làm trên team "1. Test Init" (gói Education). File thật của Wakeup nằm ở team `0.1 [App] Multiverse` ([`docs/design-system/`](../design-system/00-knowledge-base-components-snowflakes.md)). Cần chạy thử lại ở team đó; nếu team thuộc gói Organization và Code Connect chạy được thì xem lại ADR này (vẫn giữ lớp hợp đồng sinh code).
