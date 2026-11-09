# Kiến trúc thông tin và điều hướng — app Windows bản 1.0

> **Mã:** PLN-IA · **Trạng thái:** đã duyệt 04/11/2026 · **Ticket:** [#7](https://github.com/tannguyenho/personal-app/issues/7) · **Bản đồ:** [#2](https://github.com/tannguyenho/personal-app/issues/2)
>
> Chốt qua buổi grilling ngày 04/11/2026, gồm 20 quyết định đánh mã **IA-01 … IA-20** (mục 12). Mã IA thay cho số câu hỏi Q1–Q20 của buổi grilling, để không trùng với các mã Q01–Q48 trong [quyết định chốt](../review/quyet-dinh-chot-2026-11-04.md).
>
> Tài liệu này nói **màn nào nằm ở đâu và đi tới bằng cách nào**. Nội dung từng màn nằm ở SRS và brief của từng tính năng. Mọi brief tính năng dựa vào đây; chỗ nào SRS còn ghi khác thì sửa ngược theo mục 13.

## 1. Khung app

Sau khi đăng nhập và qua onboarding, mọi màn nằm trong **khung ba vùng** (IA-01):

```
┌──────────┬───────────────────────────────────────────┬──────────────────┐
│ Sidebar  │ [Banner: tối đa 1]                        │ Panel phải       │
│          ├───────────────────────────────────────────┤ (ẩn / hiện)      │
│ Home     │ Thanh công cụ (ngày · ‹ › · view · lọc)   │                  │
│ Today    ├───────────────────────────────────────────┤ ▸ Calendar       │
│ Backlog  │                                           │ ▸ Tasks          │
│ Focus    │              VÙNG CHÍNH                   │ ▸ Backlog        │
│ ──────── │  Home board / Today / trang Backlog /     │ ▸ Lưu trữ ·      │
│ Planning │  wizard Daily planning, Daily shutdown    │   Thùng rác      │
│ Shutdown │                                           │ ▸ Search         │
│          │                                           │ ▸ Trợ lý         │
│ ✨ 🔔 👤 │                                           │                  │
└──────────┴───────────────────────────────────────────┴──────────────────┘
```

Bốn kiểu bề mặt nằm trên hoặc ngoài khung:

| Bề mặt | Dùng cho | Khung phía sau |
|---|---|---|
| **Dialog / lớp phủ** | Chi tiết task, Cài đặt, đồng ý AI, command menu, bảng phím tắt, các xác nhận | Mờ đi, không thao tác được |
| **Popover** | Chuông thông báo, chọn ngày, lọc, sắp xếp, menu "Khác", picker lặp… | Vẫn thấy rõ; bấm ra ngoài thì đóng |
| **Toàn cửa sổ** | Đăng nhập, onboarding, Focus mode | Không có khung |
| **Cửa sổ riêng** | Ô thêm nhanh toàn cục (Ctrl+Shift+A) | Ngoài app |

## 2. Sidebar

Thứ tự từ trên xuống (IA-14):

| Nhóm | Mục | Phím | Mở |
|---|---|---|---|
| View hằng ngày | Home | H | Home board ở hôm nay, view cuối (G04 SCR-01) |
| | Today | T | Today view: danh sách task và lịch của ngày (G04 SCR-10, G05 SCR-04) |
| | Backlog | B | Trang Backlog đầy đủ (G06 SCR-01) |
| | Focus | F | Focus mode, toàn cửa sổ (G07 SCR-03, IA-03) |
| Ritual (sau đường kẻ) | Daily planning | P | Wizard ở vùng chính (G08 SCR-01 … SCR-07, IA-07) |
| | Daily shutdown | O | Wizard ở vùng chính (G08 SCR-07 … SCR-11) |
| Công cụ (dưới cùng) | ✨ Trợ lý | Ctrl+J | Mục Trợ lý ở panel phải (IA-08) |
| | 🔔 Thông báo | – (Ctrl+K) | Popover trung tâm thông báo (G12 SCR-11, IA-10) |
| | Avatar | – | Menu: Cài đặt (Ctrl+,) · Phím tắt (?) · Đăng xuất · Thoát app |

Mục ritual có chấm nhắc và nhãn "Đang dở" (G08 điểm vào). "Tuần" và "Lịch" **không** phải mục sidebar: chúng là các view Week và Calendar trong Home (IA-02).

## 3. Vùng chính

| Màn | Đi tới bằng | Ghi chú | Nguồn |
|---|---|---|---|
| Home board | Mở app; H; sidebar | 6 view: Board, Calendar 1 ngày, 3 ngày, Weekdays, Week, Month; Tab xoay vòng. Luôn mở ở hôm nay (IA-18) | G04 SCR-01 … SCR-03, BR-13 |
| Today view | T; sidebar | | G04 SCR-10 |
| Trang Backlog | B; sidebar | Khác panel Backlog ở panel phải: trang đầy đủ có folder, bucket | G06 SCR-01 |
| Wizard Daily planning | P; sidebar; nút "Plan" trên header cột từ hôm nay tới hôm nay + 7 ngày (B29); tự mở một lần / ngày; lời nhắc | Sidebar và panel phải vẫn dùng được, để kéo từ Backlog / Lịch vào. Không thoát bằng Esc, chỉ bằng × (IA-16). × lưu tiến độ, về Home | G08 SCR-01 … SCR-07 |
| Wizard Daily shutdown | O; sidebar; lời nhắc | Như trên | G08 SCR-07 … SCR-11 |
| Planning Agent (trong wizard Daily planning) | Nút "Plan my day" | Nhập và chạy, rồi Review Plan, đều nằm trong wizard; không nằm trong chat | G10 SCR-02, SCR-03 |

**Banner** nằm ở đầu vùng chính, **tối đa một** cùng lúc, theo thứ tự ưu tiên (IA-17):
1. Offline (G04 SCR-01 #5, MSG-30) — banner offline duy nhất của app; wizard ritual không có banner offline riêng (chốt 09/11/2026, A5)
2. Lịch cần kết nối lại (G05 SCR-09)
3. Rollover lỗi (G06 MSG-25, G04 MSG-27 cùng nội dung; F2)
4. Lệch timezone (G01 SCR-13)
5. Nhắc ritual (G08 SCR-12) — luôn sau mọi banner lỗi và offline (A5)

Banner thấp hơn chờ tới lượt và đồng thời vào trung tâm thông báo. Banner gói (G12 SCR-01) từ 1.1 thì xếp sau offline.

## 4. Panel phải

Ẩn / hiện bằng nút < > hoặc **Ctrl+\\** (IA-15). App nhớ trên máy panel đang mở hay đóng và đang ở mục nào (IA-18). Esc không đóng panel (IA-16).

| Mục | Phím | Nội dung | Nguồn |
|---|---|---|---|
| Calendar | Shift+C | Lưới lịch một ngày, kéo task vào để timebox | G05 SCR-04 |
| Tasks | Shift+T | Danh sách task của ngày đang xem, để kéo lên lưới lịch. **Chỉ hiện khi vùng chính là Calendar view** (IA-13) | G04 SCR-11 |
| Backlog | Shift+B | Panel Backlog gọn, kéo task ra board | G06 SCR-09 |
| Lưu trữ · Thùng rác | Shift+A (tab Lưu trữ); lệnh "Task đã xoá gần đây" (tab Thùng rác) | Một panel hai tab (IA-09) | G06 SCR-05, G02 SCR-05 |
| Search | Ctrl+F | Tìm task | G04 SCR-07 |
| Trợ lý | Ctrl+J; ✨ ở sidebar; Ctrl+K "Hỏi trợ lý" | Khung chat. Chưa đồng ý → dialog đồng ý (G10 SCR-10). Claude Code chưa sẵn sàng → thẻ hướng dẫn cài (G10 SCR-11) ngay trong mục này (IA-08) | G10 SCR-04, SCR-05, SCR-11 |
| Tích hợp | – | Từ 1.1 | G11 |

**Cửa sổ hẹp** (IA-11; con số `[giả định]`, designer chỉnh):

| Chiều rộng cửa sổ | Sidebar | Panel phải |
|---|---|---|
| ≥ 1280 px | Đầy đủ | Cố định cạnh vùng chính |
| 1024 – 1279 px | Đầy đủ | Lớp trượt đè lên vùng chính khi mở; đóng khi kéo thả xong hoặc bấm ra ngoài |
| < 1024 px | Thu thành cột icon | Lớp trượt |
| Tối thiểu | 800 × 600 | |

Home board tự giảm số cột ngày hiện được khi cửa sổ hẹp lại; cột ngày tối thiểu 200 px, thiếu chỗ thì cuộn ngang. Bản 1.0 không có chế độ 1 cột (chốt 09/11/2026, B01). Cài đặt ở cửa sổ hẹp theo G01 SCR-06 (cột trái thành danh sách, có nút ←).

## 5. Dialog, lớp phủ và popover

| Bề mặt | Kiểu | Đi tới bằng | Ghi chú | Nguồn |
|---|---|---|---|---|
| Chi tiết task | Dialog giữa màn | Bấm tiêu đề card; Ctrl+Enter; chip task trong chat | Nút "mở rộng" cho dialog chiếm hết vùng chính. Esc đóng, focus về card vừa mở (IA-06). Gồm banner series (G03 SCR-02), timebox (G05 SCR-06), timer (G07 SCR-01, SCR-02) | G02 SCR-03 |
| Cài đặt | Lớp phủ gần kín cửa sổ | Avatar → Cài đặt; Ctrl+,; Ctrl+K "Mở cài đặt"; link "mở thẳng nhóm" từ nơi khác | Esc / × về màn trước (IA-04). Gồm mọi nhóm của G01 SCR-06, kể cả Context & channel (G02 SCR-06), Lịch (G05 SCR-01 … 03), Ritual (G08 SCR-13), Trợ lý AI (G10 SCR-09), Hoạt động AI (G10 SCR-12), Task lặp (G03 SCR-05), Thông báo (G12 SCR-10), Workspace (G12 SCR-12) | G01 SCR-06 … SCR-16 |
| Đồng ý dùng AI | Dialog | Lần đầu bấm ✨ / Ctrl+J / "Plan my day" / bật Trợ lý AI trong Cài đặt | | G10 SCR-10 |
| Thiết lập Planning Agent | Dialog `[đề xuất]` | Lần đầu "Plan my day"; Cài đặt → Trợ lý AI | | G10 SCR-01 |
| Command menu | Dialog | Ctrl+K | | G04 SCR-08 |
| Bảng phím tắt | Dialog | ?; avatar → Phím tắt | | G04 SCR-09 |
| Đồng ý Điều khoản mới | Dialog chặn | Mở app khi có phiên bản mới | | G01 SCR-15 |
| Xác nhận | Dialog nhỏ | Theo từng thao tác | Xoá channel (G02 SCR-07), xoá instance (G03 SCR-04), ngắt kết nối lịch (G05 SCR-08), xoá tất cả lưu trữ (G06 SCR-06), giờ dừng timer (G07 SCR-06), xoá tài khoản (G01 SCR-12), xung đột hoàn tác AI (G10 SCR-06), gửi phản hồi AI (G10 SCR-08), folder (G06 SCR-04) | – |
| Trung tâm thông báo | Popover cạnh chuông | 🔔 ở sidebar | Bấm dòng → mở đúng đích (IA-10) | G12 SCR-11 |
| Popover khác | Popover | Theo từng thao tác | Chọn ngày (G04 SCR-04), sắp xếp (G04 SCR-05), lọc (G04 SCR-06), menu "Khác" (G02 SCR-04), chọn bucket (G06 SCR-02), menu ngày dự định (G06 SCR-03), picker lặp (G03 SCR-01), sửa series (G03 SCR-03), xung đột timebox (G05 SCR-07) | – |

## 6. Màn toàn cửa sổ và cửa sổ riêng

| Màn | Khi nào | Ghi chú | Nguồn |
|---|---|---|---|
| Đăng ký, mã xác minh, đăng nhập, quên mật khẩu | Chưa đăng nhập | Toàn cửa sổ, không có sidebar, nội dung đặt giữa (IA-12) | G01 SCR-01 … SCR-04 |
| Onboarding 5 bước | Lần đăng nhập đầu, hoặc onboarding còn dở | Như trên. Bước nhập task trông giống ô soạn thật. Xong thì vào Home hôm nay với Daily planning ở chế độ có hướng dẫn thay vùng chính (IA-12, sửa theo F3 ngày 06/11/2026; G01 US2.2) | G01 SCR-05 |
| Focus mode | F; sidebar Focus | Ẩn sidebar và panel phải. Esc / nút thoát về màn trước, timer vẫn chạy (IA-03) | G07 SCR-03 |
| Ô thêm nhanh toàn cục | Ctrl+Shift+A ở bất kỳ đâu trên Windows | Cửa sổ nổi nhỏ, không viền, ở giữa màn hình đang dùng, luôn ở trên. Click ra ngoài thì đóng, giữ bản nháp. Enter: hiện "Đã thêm vào Hôm nay" ~1 giây rồi đóng, trả focus về app trước. Shift+Enter: thêm và giữ ô mở. Cửa sổ chính đang ở khay thì vẫn ở khay (IA-19) | G02 US1.1 AC07, D11 |

## 7. Cửa sổ, khay hệ thống và khởi động

(IA-05, IA-18)

- **Bấm ×** luôn thu app về khay, có timer hay không. Lần đầu thu về khay, app hiện một thông báo: "App vẫn chạy ở khay hệ thống". Cài đặt Chung có lựa chọn "Bấm × để thoát hẳn" (mặc định tắt).
  - Lý do: phím toàn cục (D11), nhắc ritual bằng thông báo Windows (D12) và MCP local cho Claude Code trong terminal (G10 UC-11) đều cần app đang chạy.
- **Biểu tượng khay** đổi khi có timer đang chạy (D13). Menu chuột phải: Mở app · Thêm task (Ctrl+Shift+A) · "Bật timer: {task kế tiếp hôm nay}" khi chưa có timer, "Dừng timer: {tiêu đề}" khi đang có timer (chốt 09/11/2026, B23, C25) · Thoát.
- **Tự chạy khi Windows khởi động**: bật mặc định, chạy ẩn ở khay; tắt được trong Cài đặt Chung.
- **Thu nhỏ** (nút −): như mọi app Windows, timer vẫn chạy (G07 BR-23).
- **Mở lại cửa sổ**: luôn vào Home ở hôm nay với view cuối; panel phải như lần trước. Có timer đang chạy cũng vào Home, không vào Focus. Wizard ritual tự mở thì thay vùng chính.
- **Bấm thông báo Windows**: đưa cửa sổ lên trước (kể cả từ khay) và mở đúng đích như bấm dòng đó trong trung tâm thông báo (IA-10).
- **Toast khi cửa sổ đang ẩn** (IA-21, F6): Toast phát sinh khi cửa sổ app không hiện (ẩn ở khay hoặc thu nhỏ) không bật lên; nội dung toast vào **trung tâm thông báo** (G12 SCR-11) thành một dòng chưa đọc, chuông tăng badge. Dòng này tạo trên máy, không đồng bộ sang thiết bị khác `[giả định]`. Bấm dòng → mở đúng đích như IA-10. Nút có thời hạn của toast (ví dụ "Hoàn tác" ≥ 5 giây) không mang theo; thao tác còn hoàn tác được ở nơi khác thì làm ở đó (ví dụ G10 SCR-12 Hoạt động AI, Thùng rác G02).

## 8. Phím tắt điều hướng và Esc

Phím một ký tự chỉ chạy khi không có ô nhập nào đang focus (G01 BR-15, EC-25).

| Phím | Làm gì | Nguồn |
|---|---|---|
| H · T · B · F | Home · Today · trang Backlog · Focus | G04, G06, G07 |
| P · O | Daily planning · Daily shutdown | G08 |
| Tab | Xoay vòng 6 view của Home | G04 BR-13 |
| Shift+C · Shift+T · Shift+B · Shift+A | Panel phải: Calendar · Tasks · Backlog · Lưu trữ | G04, G06 |
| Ctrl+\\ | Ẩn / hiện panel phải | **Mới** (IA-15) |
| Ctrl+F | Search ở panel phải | G04 |
| Ctrl+J | Mở / đóng mục Trợ lý | **Chốt** thay `[giả định]` của G10 (IA-15) |
| Ctrl+, | Mở Cài đặt | **Mới** (IA-15) |
| Ctrl+K | Command menu (gồm "Task đã xoá gần đây", "Thông báo") | G04 |
| ? | Bảng phím tắt | G04 |
| Ctrl+Shift+A · Ctrl+Shift+Space | Toàn cục: thêm task · bật / dừng timer | D11 |

**Esc** đóng lớp trên cùng, mỗi lần một lớp (IA-16):
1. Menu / popover (kể cả popover chuông)
2. Ô nhập đang focus: bỏ focus, giữ bản nháp
3. Dialog (chi tiết task, Cài đặt, đồng ý AI…)
4. Focus mode: thoát về màn trước

Wizard ritual và panel phải **không** đóng bằng Esc.

## 9. Cột ngày đã qua

(IA-20) Cột ngày < hôm nay **không** có nút "+ Thêm task" và nút "Plan". Chọn cột đã qua rồi nhấn A → ô soạn mở ở cột **hôm nay**, board cuộn tới cột hôm nay. Việc đánh dấu xong ở ngày đã qua và breadcrumb thuộc brief G04 / G06.

## 10. Danh sách màn cấp cao

Gom theo nơi hiện. Mã SCR là của SRS từng nhóm; `SCR-N` là màn mới chưa có trong SRS.

| Nơi | Màn |
|---|---|
| Toàn cửa sổ | G01 SCR-01 … SCR-05 · G07 SCR-03 |
| Vùng chính | G04 SCR-01 … SCR-03 (Home, 6 view) · G04 SCR-10 (Today view) · G06 SCR-01 · G08 SCR-01 … SCR-11 · G10 SCR-02, SCR-03, SCR-07 (trong wizard) |
| Panel phải | G05 SCR-04 (Calendar) · G04 SCR-11 (Tasks) · Backlog (G06) · G06 SCR-05 + G02 SCR-05 (Lưu trữ · Thùng rác) · G04 SCR-07 · G10 SCR-04, SCR-05, SCR-11 |
| Dialog / lớp phủ | G02 SCR-03 · G01 SCR-06 … SCR-16 (Cài đặt, chứa cả G02 SCR-06, G03 SCR-05, G05 SCR-01 … 03, G08 SCR-13, G10 SCR-09, SCR-12, G12 SCR-10, SCR-12) · G10 SCR-01, SCR-10 · G04 SCR-08, SCR-09 · các xác nhận ở mục 5 |
| Popover | G12 SCR-11 · các popover ở mục 5 |
| Trên card / trong chi tiết | G02 SCR-01, SCR-02 · G03 SCR-02, SCR-06 · G05 SCR-05, SCR-06 · G06 SCR-07 · G07 SCR-01 |
| Banner / toast | G01 SCR-13 · G05 SCR-09 · G08 SCR-12 (lời nhắc) · toast của mọi nhóm |
| Cửa sổ riêng | Ô thêm nhanh toàn cục (SCR-N, G02) |
| Ngoài app | Biểu tượng và menu khay · thông báo Windows (G12, D12) |

## 11. Điểm vào của từng tính năng bản 1.0

Chỉ ghi điểm vào cấp app (từ khung, phím, khay, thông báo). Điểm vào bên trong một màn (ví dụ nút trong chi tiết task) nằm ở SRS của nhóm.

| Nhóm | Điểm vào cấp app |
|---|---|
| G01 Tài khoản, onboarding, cài đặt | Mở app lần đầu → toàn cửa sổ đăng ký / đăng nhập · avatar → Cài đặt · Ctrl+, · banner timezone · ? → Cài đặt phím tắt |
| G02 Quản lý task | "+ Thêm task" trên cột ngày ≥ hôm nay · A · Ctrl+Shift+A (cửa sổ riêng) · khay → Thêm task · bấm card / Ctrl+Enter → dialog chi tiết · panel Lưu trữ · Thùng rác (tab Thùng rác) · Cài đặt → Context & channel |
| G03 Task lặp lại | Chi tiết task → menu "Khác" → Lặp lại · Ctrl+K "Lặp lại" · Cài đặt → Task lặp lại |
| G04 Board ngày | Mở app → Home hôm nay · H · T · Tab · Ctrl+F · Ctrl+K · ? |
| G05 Lịch và timebox | Panel phải → Calendar (Shift+C) · Calendar view trong Home · panel Tasks (Shift+T) khi ở Calendar view · Cài đặt → Lịch · onboarding bước "Kết nối lịch" · banner cần kết nối lại |
| G06 Backlog, rollover, lưu trữ | Sidebar Backlog / B (trang) · panel phải Backlog (Shift+B) · panel Lưu trữ (Shift+A) · toast "Xem Lưu trữ" |
| G07 Focus và timer | Sidebar Focus / F (toàn cửa sổ) · Space trên task · Ctrl+Shift+Space · khay → Bật timer (task kế tiếp hôm nay) / Dừng timer · biểu tượng khay khi có timer · thông báo timer > 4 giờ |
| G08 Daily planning, shutdown | Sidebar / P / O → wizard ở vùng chính · nút "Plan" trên cột ngày ≥ hôm nay · tự mở một lần / ngày · thông báo Windows nhắc ritual · banner nhắc (G08 SCR-12) |
| G10 Trợ lý AI | ✨ ở sidebar / Ctrl+J / Ctrl+K "Hỏi trợ lý" → mục Trợ lý ở panel phải · "Plan my day" trong wizard · Cài đặt → Trợ lý AI, Hoạt động AI · toast khi Claude Code trong terminal đổi app |
| G12 phần 1.0 | 🔔 ở sidebar → popover · thông báo Windows · Cài đặt → Thông báo, Workspace |

## 12. Quyết định

| Mã | Quyết định | Câu grilling |
|---|---|---|
| IA-01 | Khung ba vùng: sidebar trái, vùng chính, panel phải ẩn / hiện được. Sidebar có cụm dưới cùng: ✨ Trợ lý, chuông, avatar. Không có nút ✨ nổi ở góc màn | Q1 |
| IA-02 | Vùng chính có Home (6 view) và Today; "Tuần", "Lịch" là view trong Home; trang Backlog giữ riêng với panel Backlog | Q2 |
| IA-03 | Focus mode chiếm trọn cửa sổ; Esc / thoát về màn trước, timer chạy tiếp | Q3 |
| IA-04 | Cài đặt là lớp phủ gần kín cửa sổ; mở thẳng được từng nhóm | Q4 |
| IA-05 | × luôn thu về khay; "Bấm × để thoát hẳn" trong Cài đặt (mặc định tắt); menu khay 4 mục; tự chạy khi Windows khởi động (mặc định bật) | Q5 |
| IA-06 | Chi tiết task là dialog giữa màn, có "mở rộng" chiếm vùng chính | Q6 |
| IA-07 | Wizard ritual thay vùng chính; sidebar và panel phải vẫn dùng được; × lưu tiến độ, về Home | Q7 |
| IA-08 | Chat trợ lý là mục "Trợ lý" ở panel phải; Review Plan nằm trong wizard | Q8 |
| IA-09 | Lưu trữ và Thùng rác chung một panel, hai tab | Q9 |
| IA-10 | Trung tâm thông báo là popover cạnh chuông; bấm thông báo Windows đưa app lên trước và mở đúng đích | Q10 |
| IA-11 | Mốc cửa sổ hẹp 1280 / 1024 px, tối thiểu 800 × 600 `[giả định]` | Q11 |
| IA-12 | Đăng nhập và onboarding toàn cửa sổ, không có sidebar; xong onboarding vào Home hôm nay, mở Daily planning có hướng dẫn (F3, 06/11/2026) | Q12, F3 |
| IA-13 | Panel Tasks = task của ngày đang xem, chỉ hiện ở Calendar view | Q13 |
| IA-14 | Thứ tự sidebar như mục 2 | Q14 |
| IA-15 | Thêm phím Ctrl+J (Trợ lý), Ctrl+, (Cài đặt), Ctrl+\\ (panel phải) | Q15 |
| IA-16 | Esc đóng lớp trên cùng; wizard ritual và panel phải không đóng bằng Esc | Q16 |
| IA-17 | Tối đa một banner, theo thứ tự ưu tiên; banner chờ vào trung tâm thông báo | Q17 |
| IA-18 | Mở lại app vào Home hôm nay, view cuối; nhớ trạng thái panel phải; timer chạy vẫn vào Home | Q18 |
| IA-19 | Ô thêm nhanh toàn cục như mục 6 | Q19 |
| IA-20 | Cột ngày đã qua không có "+ Thêm task" / "Plan"; A trên cột đã qua mở ô soạn ở hôm nay | Q20 |
| IA-21 | Toast phát sinh khi cửa sổ app đang ẩn ở khay / thu nhỏ không bật lên mà vào trung tâm thông báo (mục 7) | F6 (06/11/2026) |

## 13. Đã sửa ngược vào PRD / SRS

Đã áp ngày 04/11/2026 sau khi PO duyệt.

| Tài liệu | Sửa | Theo |
|---|---|---|
| srs-g04 SCR-01 #1 | Sidebar thêm cụm dưới (✨, chuông, avatar); thứ tự theo IA-14 | IA-01, IA-14 |
| srs-g04 SCR-01 #4 | Panel phải: Lưu trữ thành "Lưu trữ · Thùng rác"; định nghĩa Tasks; thêm mục Trợ lý; Ctrl+\\ | IA-08, IA-09, IA-13, IA-15 |
| srs-g04 SCR-01 #5 | Một banner, thứ tự ưu tiên | IA-17 |
| srs-g04 SCR-02 #4, #6 | Cột đã qua không có "Thêm task", "Plan"; A trên cột đã qua | IA-20 |
| srs-g04 điểm vào, BR-13 | Mở app luôn ở hôm nay; nhớ panel phải | IA-18 |
| srs-g02 SCR-03, SCR-05, điểm vào | Chi tiết task là dialog; Thùng rác là tab trong panel Lưu trữ | IA-06, IA-09 |
| srs-g02 US1.1 AC07 / điểm vào | Hành vi ô thêm nhanh toàn cục | IA-19 |
| srs-g10 điểm vào, SCR-04 | ✨ ở sidebar, không nổi ở góc; chat ở panel phải; Ctrl+J bỏ `[giả định]` | IA-01, IA-08, IA-15 |
| srs-g12 SCR-11 | Chuông ở cụm dưới sidebar, popover | IA-10 |
| srs-g01 SCR-06, SCR-07 | Cài đặt là lớp phủ, Ctrl+,; Cài đặt Chung thêm "Bấm × để thoát hẳn", "Chạy khi Windows khởi động" | IA-04, IA-05, IA-15 |
| srs-g07 BR-23 | × luôn thu về khay, không chỉ khi có timer; menu khay | IA-05 |
| srs-g08 SCR-01 #7 | Esc không thoát wizard | IA-16 |
| prd-g01 / srs-g01 SCR-05 | Onboarding toàn cửa sổ | IA-12 |
