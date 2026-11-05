# wakeup_ds_tokens

Token design system sinh 1-1 từ Figma Variables ([ADR-0008](../../docs/adr/0008-hop-dong-design-code-thay-code-connect.md)).

1. Xuất Variables: chạy `figma/export_variables.js` bằng Plugin API (Figma MCP `use_figma` hoặc plugin riêng), lưu kết quả vào `tokens.json`.
2. Sinh code: `dart run tool/generate.dart` → `lib/src/ds_colors.g.dart`.
3. `flutter test` báo đỏ nếu `tokens.json` đổi mà chưa sinh lại code.

Quy ước tên: bỏ tên collection, các đoạn còn lại nối camelCase. `color/bg/primary` → `DsColors.bgPrimary`. Alias trong Figma giữ là tham chiếu tới token gốc trong code.

`tokens.json` hiện là dữ liệu mẫu lấy từ file sandbox "Wakeup – Code Connect pilot". Thay bằng bản xuất từ file design system thật khi có.

Chưa có: `components.json` và enum / kiểu tham số cho widget (lớp hợp đồng component của ADR-0008).
