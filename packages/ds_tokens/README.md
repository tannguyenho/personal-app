# wakeup_ds_tokens

Token design system và hợp đồng component của Wakeup, sinh 1-1 từ Figma ([ADR-0008](../../docs/adr/0008-hop-dong-design-code-thay-code-connect.md)).

## Quy trình

1. **Xuất từ Figma** bằng Plugin API (Figma MCP `use_figma` hoặc plugin riêng), trên file design system:
   - `figma/export_variables.js` → lưu kết quả vào `tokens.json`.
   - `figma/export_components.js` → lưu kết quả vào `components.json`.
   - `figma/export_components.js` chạy trên file [❄️ [Snowflake] Wakeup](https://www.figma.com/design/gIBgLQIAiWUjZ1wHb04tZb) → lưu vào `snowflakes.json`.
2. **Sinh code:** `dart run tool/generate.dart` → `lib/src/ds_colors.g.dart`, `lib/src/ds_components.g.dart`, `lib/src/snowflake_components.g.dart`.
3. **Kiểm tra:** `flutter test` báo đỏ nếu một trong ba file JSON đổi mà chưa sinh lại code. CI chạy bước này.

`tokens.json` và `components.json` hiện là dữ liệu mẫu lấy từ file sandbox [Wakeup – Code Connect pilot](https://www.figma.com/design/zWidv5HFfFRIR9IrrFFObb). Thay bằng bản xuất từ file design system thật khi có. `snowflakes.json` đang rỗng: Figma MCP chưa có quyền chạy script trên file Snowflake, cần xuất từ tài khoản có quyền edit.

## Token

Bỏ tên collection, các đoạn còn lại nối camelCase: `color/bg/primary` → `DsColors.bgPrimary`. Mỗi mode (light / dark) là một hằng `DsColors`. Alias trong Figma giữ là tham chiếu tới token gốc trong code.

## Component

Mỗi component Figma sinh ra:

- một enum cho mỗi variant property, kèm `figmaValue` là giá trị gốc trong Figma;
- lớp `Ds<Tên>Base extends StatelessWidget` chứa tên tham số, kiểu và giá trị mặc định.

Widget thật `extends` lớp Base và chỉ viết `build`:

```dart
class DsButton extends DsButtonBase {
  const DsButton({
    super.key,
    required super.label,
    super.disabled,
    super.size,
    super.variant,
  });

  @override
  Widget build(BuildContext context) => ...;
}
```

Đổi tên hoặc xoá property trong Figma thì `super.<tên cũ>` không còn, code biên dịch lỗi. Thêm property mới thì snippet của plugin Codegen ([#31](https://github.com/tannguyenho/personal-app/issues/31)) có tham số mà widget chưa nhận, cũng lỗi khi biên dịch. Widget cần state thì lớp `Ds<Tên>` (stateless) bọc một `StatefulWidget` nội bộ.

### Quy tắc map

Tên Figma theo quy ước của skill `uxf-component-manager`: component Title Case, property lowerCamelCase, giá trị variant kebab-case, boolean `true` / `false`.

| Figma | Dart |
|---|---|
| DS component `Button`, `List Item`, `Sheet / Bottom / Inset` | `DsButton`, `DsListItem`, `DsSheetBottomInset` |
| Snowflake `TaskCard`, `Rollover Badge` | `TaskCard`, `RolloverBadge` (giữ tên Figma, không tiền tố) |
| Element `--card / Price Label`, component `.x` / `_x`, snowflake `Base / TaskRow` | Không sinh |
| Property `label#1:0` | Tham số `label` (bỏ hậu tố id của Figma) |
| `VARIANT` `size = sm \| md` | `enum DsButtonSize { sm, md }`, mặc định lấy từ Figma |
| `VARIANT` chỉ có `true` / `false` | `bool` |
| `VARIANT` tên `state` (default / hover / pressed…) | Chỉ sinh enum (cho Widgetbook, golden test); không thành tham số vì Flutter tự quản lý trạng thái tương tác |
| `BOOLEAN` | `bool`, mặc định lấy từ Figma |
| `TEXT` | `required String` (chữ mẫu trong Figma không đưa vào code) |
| `INSTANCE_SWAP`, `SLOT` | `Widget?` |
| Giá trị variant `primary-solid`, `2xl`, `default` | `primarySolid`, `v2xl`, `defaultValue` (trùng từ khoá Dart thì thêm `Value`) |

Bộ sinh báo lỗi (không sinh code) khi: hai component ra cùng tên widget, hai property ra cùng tên tham số, tên property trùng từ khoá Dart hoặc thành viên của `Widget` (`key`, `build`…), giá trị mặc định không có trong danh sách variant, kiểu property chưa hỗ trợ.

### Ca chuẩn dùng chung

`test/naming_cases.json` là nguồn sự thật cho quy tắc tên. Test Dart (`test/components_test.dart`) và test của plugin Codegen cùng đọc file này, để snippet trong Dev Mode luôn khớp code đã sinh. Sửa quy tắc tên thì sửa file này trước.

### Snowflake

Chốt ngày 08/11/2026: widget snowflake giữ đúng tên Figma, không tiền tố (`TaskCard` ↔ `TaskCard`, lớp hợp đồng `TaskCardBase`, enum `TaskCardState`). Tiền tố `Ds` chỉ dành cho DS component. Các quy tắc map khác giống DS component.

Vì không có tiền tố, tên snowflake có thể trùng widget của Flutter (`Badge`, `Chip`, `Card`…). Snowflake mang thuật ngữ nghiệp vụ nên ít khi trùng; nếu trùng thì đổi tên trong Figma, đừng `hide` khi import.
