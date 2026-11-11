# Changelog

Mọi thay đổi đáng kể của Wakeup ghi ở đây, mới nhất trên cùng. Cách ghi theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/). Chưa có bản phát hành nên ghi theo ngày merge vào `main`. Khi phát hành 1.0, các mục dưới "Chưa phát hành" chuyển thành mục `[1.0.0]`.

Mỗi dòng gồm: phạm vi (nhóm G0x, `ds`, `server`…), thay đổi, rồi link PR / issue. Nhóm mục: **Thêm** (cái mới), **Đổi** (sửa cái có sẵn, gồm quyết định PO), **Sửa** (lỗi), **Bỏ**.

## [Chưa phát hành]

### 11/11/2026

#### Thêm
- `CHANGELOG.md` và `CLAUDE.md`, kèm quy ước ghi changelog cho mọi thay đổi.

### 10/11/2026

#### Thêm
- Brief thiết kế G03 Task lặp lại: 9 màn hình, 71 trạng thái, F-01 … F-17, CASE-01 … CASE-52 ([#37](https://github.com/tannguyenho/personal-app/pull/37), #12).
- Brief thiết kế G02 Quản lý task: 9 màn hình, 76 trạng thái, F-01 … F-17, CASE-01 … CASE-37 ([#36](https://github.com/tannguyenho/personal-app/pull/36), #11).
- QC-13 (lỗi lưu / tải, kéo thả và Hoàn tác, toast gộp, không dùng ký hiệu trong chữ) và QC-08 mục 7 (offline) ([#35](https://github.com/tannguyenho/personal-app/pull/35)).

#### Đổi
- G03: PO chốt O-01 … O-21 theo đề xuất brief. SRS thêm SCR-09 và MSG-29 … MSG-35. Lần đầu khi bật lặp là ngày khớp đầu tiên tính từ hôm nay. Giao diện dùng chữ "lần" thay "instance". Cài đặt có nhóm "Task lặp lại" ([#37](https://github.com/tannguyenho/personal-app/pull/37)).
- G02: PO chốt O-01 … O-20 và mọi đề xuất còn lại của brief. SRS thêm SCR-08 Ô thêm nhanh toàn cục, SCR-09 Popover chọn channel, MSG-29 … MSG-40 và nhánh mất mạng. Ô soạn giữ mở sau khi tạo task ([#36](https://github.com/tannguyenho/personal-app/pull/36)).
- QC-07: xoá subtask thì trừ thời gian của subtask đó khỏi "Thực tế". G10: hai công tắc gợi ý độc lập. DS: `Button` có `variant=danger` ([#36](https://github.com/tannguyenho/personal-app/pull/36)).
- Áp các quyết định PO chốt ngày 09/11 (A1–A10, B01–B48, C01–C52) và ngày 10/11 (D01–D09) vào SRS, PRD, flow của G01 … G12, cùng QC và IA ([#35](https://github.com/tannguyenho/personal-app/pull/35)).

### 09/11/2026

#### Thêm
- `ds`: `DsButton` theo component Figma `Button`, Widgetbook và golden test (ADR-0008 bước 6). Font Inter đóng gói trong `wakeup_ds_tokens` ([#34](https://github.com/tannguyenho/personal-app/pull/34)).

#### Sửa
- `server`: image Docker chỉ giữ `packages/core` và `apps/server` trong danh sách workspace, để `dart pub get` không lỗi khi thêm `apps/widgetbook` ([#34](https://github.com/tannguyenho/personal-app/pull/34)).

### 08/11/2026

#### Thêm
- `tools/figma-codegen`: plugin Figma Codegen hiện snippet Flutter trong Dev Mode, khớp lớp hợp đồng sinh từ `components.json` / `snowflakes.json` ([#33](https://github.com/tannguyenho/personal-app/pull/33), #31).
- `ds_tokens`: bộ sinh hợp đồng component từ `components.json` và hợp đồng Snowflake; Snowflake giữ tên Figma, không thêm tiền tố ([#32](https://github.com/tannguyenho/personal-app/pull/32), #31).

#### Đổi
- ADR-0008: chốt gói Figma Education chạy được plugin Codegen ([#32](https://github.com/tannguyenho/personal-app/pull/32)).

### 06/11/2026

#### Thêm
- User flow Mermaid cho các nhóm bản 1.0: G01, G03 … G08, G10, G12 ([#29](https://github.com/tannguyenho/personal-app/pull/29), #10).
- Khung monorepo Wakeup (pub workspaces): `packages/core`, `packages/ds_tokens`, `apps/server`, `apps/desktop` ([#28](https://github.com/tannguyenho/personal-app/pull/28)).
- Knowledge base design system cho agent (DS component / Snowflake), khuôn brief thiết kế ([#28](https://github.com/tannguyenho/personal-app/pull/28), #9).

#### Đổi
- Áp quyết định PO ngày 06/11 (F1–F6): phím S, rollover thất bại, Daily planning có hướng dẫn, bỏ công tắc AI hoàn thành / xoá task, bỏ nhãn "Lệch ngày", toast khi cửa sổ ẩn ([#30](https://github.com/tannguyenho/personal-app/pull/30)).
- ADR-0004 và ADR-0009: PO chấp nhận rủi ro điều khoản Anthropic ([#28](https://github.com/tannguyenho/personal-app/pull/28)).

### 05/11/2026

#### Đổi
- Chốt tech stack và API; đổi tên dự án thành Wakeup ([#27](https://github.com/tannguyenho/personal-app/pull/27)).

### 04/11/2026

#### Thêm
- PRD / SRS cho 12 nhóm tính năng G01 … G12 và README.

#### Đổi
- Áp quyết định các vòng 5–7 vào QC, ADR-0002 và PRD / SRS. Viết lại trợ lý AI (G10, G11) theo Claude Code CLI + MCP chạy trên máy ([#1](https://github.com/tannguyenho/personal-app/pull/1)).
