# Wakeup Flutter Codegen

Plugin Figma Codegen ([#31](https://github.com/tannguyenho/personal-app/issues/31), [ADR-0008](../../docs/adr/0008-hop-dong-design-code-thay-code-connect.md)): trong **Dev Mode**, chọn một instance → khung **Inspect → Code**, ngôn ngữ **Flutter** hiện snippet Dart khớp đúng lớp hợp đồng mà `packages/ds_tokens` sinh ra.

```dart
// apps/desktop/lib/ds/ds_button.dart
DsButton(
  label: 'Lưu',
  variant: DsButtonVariant.secondary,
)
```

Gói Figma Education chạy được plugin này dạng development (đã thử ngày 08/11/2026), không cần publish.

## Cài vào Figma

1. Figma desktop → **Plugins → Development → Import plugin from manifest…** → chọn `tools/figma-codegen/manifest.json`.
2. Mở file, chuyển sang **Dev Mode**, chọn một instance → **Inspect** → chọn ngôn ngữ **Flutter**.

`dist/code.js` đã build sẵn trong repo, không cần cài Node để dùng. `id` trong `manifest.json` là id tạm cho plugin development; nếu Figma đòi id do nó cấp, tạo plugin mới trong Figma (Plugins → Development → New plugin…) rồi chép id đó vào.

Cài đặt trong khung Inspect (biểu tượng bánh răng cạnh ngôn ngữ):

| Cài đặt | Giá trị |
|---|---|
| Giá trị mặc định | **Ẩn** (mặc định): không in tham số đang bằng mặc định. **Hiện**: in hết |
| Tô màu cú pháp | **Không** (mặc định). **Gần đúng (TypeScript)**: Figma không có Dart, mượn màu TypeScript |

## Plugin hiện gì

| Chọn | Kết quả |
|---|---|
| Instance của DS component | `DsButton(...)`, tham số theo `components.json` |
| Instance của Snowflake | `TaskCard(...)`, theo `snowflakes.json` |
| Instance có instance swap | Snippet lồng: `leading: DsIcon(...)` (tối đa 4 cấp) |
| Element `--...`, snowflake `Base / ...` | Ghi chú "không có widget riêng" |
| Component chưa có trong hợp đồng | Ghi chú cần chạy lại `export_components.js` + `generate.dart` |
| Instance có property mà hợp đồng chưa có | Snippet kèm dòng cảnh báo hợp đồng cũ |
| Node khác có bind Variable màu (fill, stroke) | `fill: DsColors.bgPrimary` |

Quy tắc giống bộ sinh Dart: tham số `required` trước rồi A-Z, property `state` bỏ qua, variant `true` / `false` thành `bool`, `TEXT` luôn in. Dòng đầu là đường dẫn widget lấy từ description component (`(Flutter: apps/…/x.dart)`).

## Cách hoạt động

Plugin đóng gói sẵn `packages/ds_tokens/components.json` và `snowflakes.json` lúc build, tra component theo key (rồi theo tên) để biết DS hay Snowflake và giá trị mặc định. Vì vậy **mỗi lần xuất lại hai file này phải build lại plugin**; CI báo đỏ nếu `dist/code.js` cũ.

| File | Việc |
|---|---|
| `src/naming.ts` | Quy tắc tên, port 1-1 từ `packages/ds_tokens/tool/naming.dart` |
| `src/snippet.ts` | Dựng snippet từ dữ liệu instance (hàm thuần, có test) |
| `src/code.ts` | Đọc instance / Variable từ Figma, gọi `snippet.ts` |
| `test/` | `naming.test.ts` đọc chung `packages/ds_tokens/test/naming_cases.json` với test Dart |

## Phát triển

Cần Node 22.

```bash
cd tools/figma-codegen
npm ci
npm run typecheck
npm test
npm run build      # ghi dist/code.js, commit file này
```

Sửa quy tắc tên: sửa `naming_cases.json` trước, rồi sửa cả `naming.dart` lẫn `naming.ts` cho tới khi test hai phía cùng xanh.

Chưa hỗ trợ: nội dung của property `SLOT` (snippet ghi chú "điền widget con"), token ngoài màu (chưa có lớp Dart tương ứng).
