# wakeup_widgetbook

[Widgetbook](https://www.widgetbook.io) cho thư viện widget design system ở `apps/desktop/lib/ds/` ([ADR-0008](../../docs/adr/0008-hop-dong-design-code-thay-code-connect.md), `docs/tech/01` mục 8 bước 6).

```
flutter run -d chrome
```

Thanh bên phải có: theme Sáng / Tối, phóng chữ (DS-08: không vỡ ở 150%), canh lề. Mỗi use case có link sang component trong Figma.

| Component | Use case |
|---|---|
| `DsButton` | **Playground**: chỉnh `label`, `variant`, `size`, `disabled` (trùng tên property Figma). **Tất cả biến thể**: bảng variant × size, nhãn tiếng Việt có dấu chồng, trạng thái vô hiệu |

## Golden test

`test/` chụp đúng các use case trên và so với ảnh trong `test/goldens/`:

- Bảng biến thể ở theme sáng và tối.
- Hover, nhấn, focus bằng bàn phím của từng variant.
- Kích thước khớp Figma (md 91×39, sm 69×29 với nhãn "Button").

Font Inter thật được nạp trong `test/flutter_test_config.dart`. Golden chỉ chạy trên **Linux** (`@TestOn('linux')`) vì mỗi hệ điều hành render chữ hơi khác; CI (ubuntu) là nguồn chuẩn. Khi CI đỏ, ảnh lệch nằm trong artifact `golden-failures`.

Đổi giao diện có chủ đích thì cập nhật ảnh trên Linux rồi commit:

```
flutter test --update-goldens
```

## Thêm component

1. Widget ở `apps/desktop/lib/ds/ds_<tên>.dart`, `extends Ds<Tên>Base` sinh từ `components.json`.
2. Use case ở `lib/use_cases/`, knob trùng tên property Figma; thêm vào `lib/main.dart`.
3. Golden test chụp use case "Tất cả biến thể".
