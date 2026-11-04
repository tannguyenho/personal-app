> **Mã:** PLN-SRS-G02-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g02-quan-ly-task.md

# UC-G02 - Quản lý task trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả vòng đời task (tạo, sửa chi tiết, hoàn thành, nhân bản, xoá / khôi phục) và context / channel. Lặp lại (G03), board và kéo thả (G04), timebox (G05), backlog và rollover (G06), timer (G07) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng ghi task trong vài giây, bổ sung chi tiết khi cần, hoàn thành, nhân bản, xoá và khôi phục mà không mất dữ liệu; phân loại task theo channel |
| Actor | Người dùng đã đăng nhập · Hệ thống · Dịch vụ gợi ý (AI) · Dịch vụ đọc tiêu đề URL |
| Phạm vi | Tạo task (ô soạn, phím A, dán URL), gợi ý thời lượng / channel, chi tiết task, subtask, priority, due, notes, comment, nhật ký, hoàn thành, nhân bản, xoá mềm, Thùng rác, context & channel |
| Ngoài phạm vi | Lặp lại, kéo thả và sắp xếp board, timebox, backlog và rollover, timer, đính kèm file (1.1), giao task / follow (1.1), gộp task |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Gõ tiêu đề rồi Enter là có task trong ngày | Ghi việc nhanh, không mất mạch |
| US-02 | Người dùng | Dán link để tạo task có sẵn tiêu đề | Không phải gõ lại |
| US-03 | Người dùng | Được gợi ý thời lượng và channel | Không phải ước lượng và phân loại thủ công mỗi lần |
| US-04 | Người dùng | Chia task thành subtask, thêm notes, priority, hạn chót | Có đủ thông tin khi làm |
| US-05 | Người dùng | Đánh dấu xong một lần cho cả task và subtask | Đỡ thao tác |
| US-06 | Người dùng | Hoàn tác khi lỡ xoá / lỡ đánh dấu xong, khôi phục từ Thùng rác | Không mất dữ liệu |
| US-07 | Người dùng | Nhân bản task tương tự | Không tạo lại từ đầu |
| US-08 | Người dùng | Tạo và quản lý context / channel | Biết thời gian dành cho từng mảng |
| US-09 | Người dùng thành thạo | Làm mọi thao tác trên bằng phím tắt | Không rời bàn phím |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Thuộc tính và giới hạn.** Tiêu đề 1–500 ký tự (cắt khoảng trắng hai đầu); thời lượng 1 phút – 24 giờ; subtask ≤ 100 / task; notes ≤ 50.000 ký tự; comment 1–5.000 ký tự. Giới hạn lấy từ \[AppConfig\], không hard-code `[giả định]` |
| BR-02 | Task tạo từ cột ngày D có `startDate = D`. Không có ngày → task thuộc backlog (G06) |
| BR-03 | Vị trí task mới: đầu hoặc cuối danh sách ngày theo cài đặt "Vị trí task mới" (mặc định đầu) |
| BR-04 | **Gợi ý.** Thời lượng và channel do \[TaskSuggest\] trả về được đánh dấu nguồn `ai`; người dùng sửa → nguồn `user`; hệ thống không bao giờ ghi đè giá trị nguồn `user`. Tắt gợi ý trong cài đặt → không gọi \[TaskSuggest\] |
| BR-05 | Mỗi task thuộc đúng một channel. Không có gợi ý và người dùng không chọn → channel mặc định của người dùng `[giả định: uncategorized]` |
| BR-06 | Priority: 1 Urgent, 2 Priority, 3 Normal (mặc định), 4 Low |
| BR-07 | Due độc lập với ngày bắt đầu. Due < ngày bắt đầu: cho lưu, hiện cảnh báo MSG-06 |
| BR-08 | **Hoàn thành task.** (a) Dừng timer của task nếu đang chạy; (b) mọi subtask chưa xong chuyển xong; (c) chưa có thời gian thực tế và bật "Tính planned là actual" → actual = planned; (d) `startDate` = ngày hoàn thành theo timezone người dùng |
| BR-09 | **Bỏ hoàn thành.** Xoá `completedAt` của task; subtask giữ nguyên; `startDate` không đổi lại |
| BR-10 | **Nhân bản.** Giữ tiêu đề, channel, thời lượng, due, notes, subtask (tiêu đề + thời lượng); `startDate` = hôm nay; xoá trạng thái xong, thời gian thực tế, timebox, comment |
| BR-11 | **Xoá** là xoá mềm (`deletedAt`), không hỏi xác nhận, luôn có Hoàn tác. Task đang chạy timer → dừng và lưu thời gian trước khi xoá. Giữ trong Thùng rác 30 ngày `[giả định]`, sau đó xoá vĩnh viễn |
| BR-12 | **Khôi phục** từ Thùng rác: `startDate` cũ ≥ hôm nay → giữ; < hôm nay → hôm nay; task backlog → về đúng bucket cũ |
| BR-13 | Mọi thay đổi ghi \[ActivityLog\]: tác nhân (`user` / `ai` / `integration` / `system`), trường, giá trị cũ, giá trị mới, thời điểm |
| BR-14 | **Channel.** Tên 1–50 ký tự, không chứa "#", không trùng trong cùng context (không phân biệt hoa thường). Xoá channel phải chọn channel nhận task (mặc định `uncategorized`); không xoá task. Không xoá được channel `uncategorized` |
| BR-15 | Người dùng chỉ thấy và sửa task của chính mình (đến khi có workspace nhiều thành viên, G12) |
| BR-16 | Phím tắt một ký tự chỉ hoạt động khi không có ô nhập nào đang focus; lệnh có tác dụng phụ (C, Ctrl+Backspace) luôn có toast Hoàn tác |

## 4. Trạng thái

### 4.1. Trạng thái task

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `BACKLOG` | `startDate` trống, chưa xong, chưa xoá | Trong panel Backlog (G06) |
| `KE_HOACH` | Có `startDate`, chưa xong, chưa lưu trữ, chưa xoá | Card trên cột ngày; ✓ rỗng |
| `HOAN_THANH` | `completedAt` có giá trị | Card mờ, ✓ xanh, hiện "actual / planned" |
| `LUU_TRU` | `archivedAt` có giá trị (do G06) | Chỉ hiện trong panel Lưu trữ |
| `DA_XOA` | `deletedAt` có giá trị | Chỉ hiện trong Thùng rác, kèm ngày xoá |

Chuyển trạng thái trong phạm vi G02: `KE_HOACH` ⇄ `HOAN_THANH` (UC-03) · `KE_HOACH` / `BACKLOG` / `HOAN_THANH` → `DA_XOA` (UC-04) · `DA_XOA` → trạng thái trước khi xoá (UC-04, BR-12). Chuyển `KE_HOACH` ⇄ `BACKLOG` và → `LUU_TRU` thuộc G06. Timer đang chạy (G07) là cờ phụ, không phải trạng thái.

### 4.2. Trạng thái subtask

`CHUA_XONG` ⇄ `XONG`. Task chuyển `HOAN_THANH` → mọi subtask `XONG` (BR-08). Task bỏ hoàn thành → subtask giữ nguyên (BR-09).

## 5. Use Case

### UC-01 Tạo task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; workspace không ở chế độ chỉ đọc (G12) |
| Hậu điều kiện thành công | Task lưu ở trạng thái `KE_HOACH` (hoặc `BACKLOG`); hiện trên cột ngày; tổng thời lượng ngày cập nhật; nhật ký ghi "tạo task" |
| Hậu điều kiện thất bại | Không có task mới; nội dung đã gõ còn trong ô soạn |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Thêm task" trên cột ngày D (hoặc phím A khi cột D đang chọn) |
| 2 | Hệ thống | Mở **SCR-01**, focus vào ô tiêu đề; ngày = D |
| 3 | Người dùng | Gõ tiêu đề |
| 4 | Hệ thống | Sau 400 ms ngừng gõ `[giả định]`, gọi \[TaskSuggest\]; điền thời lượng và channel có biểu tượng ✨ (BR-04) |
| 5 | Người dùng | Tuỳ chọn sửa ngày, thời lượng, channel, priority, vị trí; nhấn Enter |
| 6 | Hệ thống | Kiểm tra BR-01; gọi \[TaskCreate\] (idempotency key do client sinh); hiện task ngay theo BR-03 (cập nhật lạc quan) |
| 7 | Hệ thống | Đóng ô soạn hoặc giữ mở để gõ task kế tiếp `[giả định: giữ mở]` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng dán URL ở bước 3 | Gọi \[TaskFromUrl\]; tiêu đề = tiêu đề trang, không đọc được → dùng URL; task giữ link nguồn |
| A2 | Người dùng xoá ngày ở bước 5 | Task tạo vào backlog (BR-02), toast MSG-07 có link mở Backlog |
| A3 | Người dùng nhấn Esc khi đã gõ | Đóng ô soạn, giữ bản nháp trên máy; mở lại ô soạn của cùng ngày thấy nội dung cũ |
| A4 | \[TaskSuggest\] lỗi / chậm > 2s / tắt gợi ý | Bỏ qua gợi ý, thời lượng trống, channel mặc định (BR-05) |
| A5 | Gõ "#" trong tiêu đề | Mở danh sách channel có ô tìm; chọn → gán channel, xoá "#..." khỏi tiêu đề |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tiêu đề trống sau khi cắt khoảng trắng | Enter không làm gì; nút tạo disabled |
| E2 | Tiêu đề > 500 ký tự | MSG-01 dưới ô, chặn tạo |
| E3 | Mất mạng | Lưu vào hàng đợi trên máy, card có biểu tượng "chờ đồng bộ"; có mạng gửi lại với cùng idempotency key (không tạo trùng) |
| E4 | \[TaskCreate\] lỗi 5xx | Card chuyển trạng thái lỗi, MSG-10 có nút "Thử lại" |
| E5 | Workspace chỉ đọc (hết trial, G12) | MSG-11, không tạo |

### UC-02 Xem và sửa chi tiết task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task tồn tại, không ở `DA_XOA` |
| Hậu điều kiện thành công | Trường đã sửa được lưu; nhật ký ghi thay đổi (BR-13) |
| Hậu điều kiện thất bại | Trường giữ giá trị cũ; hiện lỗi tại trường |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm tiêu đề task hoặc Ctrl+Enter |
| 2 | Hệ thống | Gọi \[TaskDetail\]; mở **SCR-03** |
| 3 | Người dùng | Sửa một trường (tiêu đề, channel, priority, ngày, due, thời lượng, notes) |
| 4 | Hệ thống | Kiểm tra BR-01, BR-07; gọi \[TaskUpdate\] chỉ với trường đã đổi; cập nhật card và tổng ngày |
| 5 | Người dùng | Đóng bằng Esc hoặc nút × |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Thêm subtask | Nút "+ Subtask" hoặc phím V → dòng mới; Enter lưu (\[SubtaskCreate\]) và mở dòng kế tiếp; Esc trên dòng trống đóng |
| A2 | Đánh dấu subtask xong | ✓ trên dòng subtask → \[SubtaskUpdate\]; tooltip "Hoàn thành lúc {giờ}" |
| A3 | Đổi thứ tự subtask | Kéo thả hoặc Ctrl+↑/↓ trên dòng subtask |
| A4 | Thêm comment | Gõ vào ô comment, Enter gửi (\[CommentCreate\]); Shift+Enter xuống dòng |
| A5 | Xem nhật ký | Cuối SCR-03 hiện \[ActivityLog\] mới nhất trước, 20 dòng đầu, "Xem thêm" |
| A6 | Đặt due < ngày bắt đầu | Lưu, hiện MSG-06 |
| A7 | Task đang có thay đổi từ thiết bị khác | Trường nhận giá trị mới qua realtime; trường đang gõ dở không bị thay, hiện MSG-12 khi người dùng rời trường |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Vi phạm BR-01 | Lỗi tại trường (MSG-01 / MSG-02 / MSG-03), không gửi |
| E2 | Subtask thứ 101 | MSG-04, chặn thêm |
| E3 | Task bị xoá ở thiết bị khác khi đang mở | Đóng SCR-03, MSG-09 kèm "Hoàn tác" |
| E4 | \[TaskUpdate\] lỗi | Trả trường về giá trị cũ, MSG-10 |

### UC-03 Hoàn thành / bỏ hoàn thành task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task ở `KE_HOACH` hoặc `BACKLOG` (hoàn thành) / `HOAN_THANH` (bỏ hoàn thành) |
| Hậu điều kiện thành công | Áp BR-08 hoặc BR-09; thanh tiến độ ngày cập nhật; nhật ký ghi |
| Hậu điều kiện thất bại | Trạng thái không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm ✓ trên card / SCR-03, hoặc phím C khi task đang chọn |
| 2 | Hệ thống | Gọi \[TaskComplete\]; server áp BR-08 (a)–(d) trong một giao dịch |
| 3 | Hệ thống | Card chuyển `HOAN_THANH`, chuyển sang cột ngày hoàn thành nếu khác ngày cũ; hiện "actual / planned"; hiệu ứng chúc mừng nếu bật |
| 4 | Hệ thống | Toast MSG-08 có "Hoàn tác" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm ✓ trên task đã xong | Gọi \[TaskUncomplete\], áp BR-09 |
| A2 | Bấm Hoàn tác trong toast | Gọi \[TaskUncomplete\] và trả `startDate`, trạng thái subtask, thời gian thực tế về như trước bước 2 |
| A3 | Hoàn thành task đang chạy timer ở thiết bị khác | Server dừng timer (BR-08a), phát sự kiện `timer.changed` tới mọi thiết bị |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Áp ngay trên máy, xếp hàng đợi, đồng bộ sau (E3 UC-01) |
| E2 | \[TaskComplete\] lỗi | Trả card về trạng thái cũ, MSG-10 |

### UC-04 Xoá, hoàn tác và khôi phục task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task không ở `DA_XOA` (xoá) / ở `DA_XOA` (khôi phục) |
| Hậu điều kiện thành công | Xoá: task `DA_XOA`, biến khỏi board và lịch, timebox trên lịch ngoài bị xoá (G05). Khôi phục: task về trạng thái trước khi xoá theo BR-12 |
| Hậu điều kiện thất bại | Trạng thái không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … → "Xoá" (**SCR-04**) hoặc Ctrl+Backspace khi task đang chọn |
| 2 | Hệ thống | Dừng timer nếu đang chạy (BR-11); gọi \[TaskDelete\]; ẩn task ngay |
| 3 | Hệ thống | Toast MSG-09 "Đã xoá · Hoàn tác (Ctrl+Z)" trong ≥ 5 giây |
| 4 | Người dùng | (Tuỳ chọn) Bấm Hoàn tác / Ctrl+Z → \[TaskRestore\]; task về đúng vị trí cũ |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Khôi phục sau khi toast đã tắt | Người dùng mở **SCR-05** Thùng rác (panel phải hoặc lệnh "Task đã xoá gần đây") → "Khôi phục" → \[TaskRestore\] áp BR-12, toast MSG-13 |
| A2 | Task có timebox | Xoá: G05 xoá sự kiện trên lịch ngoài. Khôi phục: không tự tạo lại timebox, task về projection |
| A3 | Task do AI tạo, người dùng bấm Hoàn tác trong khung chat (G10) | Task vào Thùng rác như xoá thường |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Khôi phục task đã quá 30 ngày (đã xoá vĩnh viễn) | MSG-14, gỡ khỏi danh sách |
| E2 | Channel của task đã bị xoá | Khôi phục vào channel mặc định (BR-05), ghi nhật ký |
| E3 | \[TaskDelete\] / \[TaskRestore\] lỗi | Trả về trạng thái trước, MSG-10 |

### UC-05 Nhân bản task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task không ở `DA_XOA` |
| Hậu điều kiện thành công | Có task mới theo BR-10 ở đầu danh sách hôm nay; SCR-03 mở task mới |
| Hậu điều kiện thất bại | Không có task mới |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … → "Nhân bản" hoặc Ctrl+D |
| 2 | Hệ thống | Gọi \[TaskDuplicate\]; tạo bản sao theo BR-10 |
| 3 | Hệ thống | Mở **SCR-03** của bản sao; nhật ký bản sao ghi "nhân bản từ {tiêu đề}" |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[TaskDuplicate\] lỗi | MSG-10, không mở bản sao |

### UC-06 Quản lý context và channel

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Context / channel được tạo, sửa, ẩn hoặc xoá; task của channel bị xoá đã chuyển sang channel nhận |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → "Context & channel" hoặc "Quản lý channel" trong bộ lọc → **SCR-06** |
| 2 | Người dùng | "Tạo context" hoặc "Tạo channel trong {context}"; nhập tên, chọn màu, bật / tắt riêng tư |
| 3 | Hệ thống | Kiểm tra BR-14; gọi \[ChannelCreate\]; channel hiện ngay trong ô soạn, bộ lọc |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Đổi tên / màu / riêng tư | Sửa tại dòng channel → \[ChannelUpdate\] |
| A2 | Ẩn channel | Tắt "Bật" → không hiện trong ô soạn và bộ lọc; task giữ nguyên |
| A3 | Xoá channel | Mở **SCR-07** chọn channel nhận task → \[ChannelDelete\] với `moveTasksTo` |
| A4 | Xoá context | Chỉ cho xoá context rỗng; còn channel → MSG-16 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tên trùng trong context | MSG-15 |
| E2 | Tên chứa "#" hoặc > 50 ký tự | MSG-17 |
| E3 | Xoá channel `uncategorized` | Nút xoá ẩn (BR-14) |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Nút "Thêm task" trên cột ngày | ✓ | ✓ | Ngày = cột đó |
| Phím A / command menu "Thêm task" | ✓ | – | Cột ngày đang chọn, mặc định hôm nay |
| Phím tắt toàn cục Ctrl+Shift+A | – | ✓ (desktop) | Ngày = hôm nay |
| Dán URL vào ô soạn | ✓ | ✓ | A1 UC-01 |
| Bấm tiêu đề card / Ctrl+Enter | ✓ | ✓ | Mở SCR-03 |
| Panel phải → Thùng rác / lệnh "Task đã xoá gần đây" | ✓ | ✓ | Mở SCR-05 |
| Cài đặt → Context & channel / bộ lọc → "Quản lý channel" | ✓ | ✓ | Mở SCR-06 |

## 7. Mô tả màn hình

### SCR-01 Ô soạn task

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tiêu đề | Text nhiều dòng | Có | 1–500 ký tự; dán URL → A1; gõ "#" → danh sách channel (A5); quá 500 → MSG-01 |
| 2 | Gợi ý "Dán URL" | Hint | – | Hiện khi ô trống |
| 3 | Ngày bắt đầu | Date picker | Không | Mặc định ngày của cột; có lựa chọn "Không ngày (backlog)" |
| 4 | Thời lượng | Picker | Không | Ô giờ + ô phút, preset 5–45 phút, 1 giờ; giá trị gợi ý có ✨ |
| 5 | Channel | Dropdown có tìm | Không | Giá trị gợi ý có ✨; danh sách nhóm theo context |
| 6 | Objective | Dropdown | Không | Ẩn ở 1.0 (G09) |
| 7 | Priority | Menu cờ | Không | 4 mức, phím 1–4 khi menu mở |
| 8 | Vị trí | Toggle | Không | Đầu / cuối danh sách |
| 9 | Enter / nút tạo | Action | – | Disabled khi tiêu đề trống |

### SCR-02 Task card (trên cột ngày)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Giờ | Text | Giờ projection (G04) hoặc badge giờ timebox (G05) |
| 2 | Tiêu đề | Text | Bấm mở SCR-03; quá 2 dòng thì cắt "…" |
| 3 | Thời lượng | Badge | "planned" hoặc "actual / planned" khi đã có thời gian thực tế |
| 4 | Subtask | List | Hiện tối đa 5 subtask, ✓ bấm được trực tiếp |
| 5 | Priority, due | Chip | Hiện khi khác Normal / có due; due quá hạn màu cảnh báo |
| 6 | Channel | Nhãn "#tên" | Màu theo channel |
| 7 | Hover actions | Icon | ✓ hoàn thành, notes, thời lượng, priority |
| 8 | Biểu tượng đồng bộ | Icon | "Chờ đồng bộ" / "Lỗi, thử lại" (UC-01 E3, E4) |

### SCR-03 Chi tiết task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Header thuộc tính | Toolbar | Channel · Priority · Ngày bắt đầu · Due · "+ Subtask" · menu … (SCR-04) · mở rộng · đóng |
| 2 | ✓ và tiêu đề | Checkbox + text | Sửa tiêu đề tại chỗ; ✓ → UC-03 |
| 3 | Thời gian | Hiển thị | "Thực tế" và "Kế hoạch"; bấm Kế hoạch mở picker ô giờ / ô phút + preset + "Xoá thời lượng" |
| 4 | Danh sách subtask | List | Mỗi dòng: ✓, tiêu đề, thực tế, kế hoạch; kéo đổi thứ tự; dòng "Thêm subtask" |
| 5 | Notes | Rich text | Lưu khi gõ (debounce 1s `[giả định]`) |
| 6 | Timebox | Thông tin | Ngày, giờ bắt đầu – kết thúc, thời lượng (G05); ẩn khi không có |
| 7 | Comment | Input + list | Avatar, tên, giờ, nội dung |
| 8 | Nhật ký | List | "{tác nhân} {hành động} · {thời gian tương đối}" |

### SCR-04 Menu "Khác" của task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Lặp lại | Menu item | Mở cấu hình lặp (G03) |
| 2 | Gắn objective | Menu item | Ẩn ở 1.0 (G09) |
| 3 | Nhân bản | Menu item | Ctrl+D → UC-05 |
| 4 | Xoá | Menu item | Ctrl+Backspace → UC-04 |
| 5 | Sao chép link | Menu item | Copy link task, toast MSG-18 |

### SCR-05 Thùng rác

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề + mô tả | Header | "Thùng rác · Task đã xoá trong 30 ngày qua" |
| 2 | Danh sách task | List | Mới xoá nhất trước; mỗi dòng: tiêu đề, channel, thời lượng, ngày xoá |
| 3 | "Khôi phục" | Button (theo dòng) | → UC-04 A1 |
| 4 | Trạng thái rỗng | Empty state | "Không có task nào bị xoá" |

### SCR-06 Context & channel

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Tạo context", "Tạo channel" | Button | – | Mở dòng nhập mới |
| 2 | Tên context / channel | Text | Có | BR-14; trùng → MSG-15; sai định dạng → MSG-17 |
| 3 | Màu | Color picker | Có | 12 màu cố định `[giả định]` |
| 4 | Riêng tư | Toggle | Không | Ảnh hưởng hiển thị lịch (G05) và chia sẻ (G12) |
| 5 | Bật / ẩn | Toggle | – | A2 UC-06 |
| 6 | Xoá | Icon | – | Mở SCR-07; ẩn với `uncategorized` |

### SCR-07 Xoá channel

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "Channel {tên} có {n} task. Chuyển các task này sang:" |
| 2 | Channel nhận | Dropdown | Mặc định `uncategorized`, không chứa channel đang xoá |
| 3 | "Xoá channel" | Button (nguy hiểm) | Gọi \[ChannelDelete\]; toast MSG-19 |
| 4 | "Huỷ" | Button | Đóng |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[TaskSuggest\] | title, startDate | plannedMin, channelId, confidence | 2s / không retry (bỏ qua gợi ý) |
| \[TaskCreate\] `POST /tasks` | title, startDate, plannedMin, plannedSource, channelId, priority, position, Idempotency-Key | Task | 5s / retry 3 lần cùng key |
| \[TaskFromUrl\] `POST /tasks/from-url` | url, startDate | Task (title, externalRef) | 5s (đọc trang 3s) / 1 lần |
| \[TaskDetail\] `GET /tasks/{id}` | id | Task + subtasks + timebox + actualMin | 5s / 1 lần |
| \[TaskUpdate\] `PATCH /tasks/{id}` | Trường thay đổi, If-Match (tuỳ chọn) | Task, version | 5s / 2 lần |
| \[TaskComplete\] / \[TaskUncomplete\] | id | Task, timer (nếu bị dừng) | 5s / 2 lần |
| \[TaskDuplicate\] `POST /tasks/{id}/duplicate` | id, Idempotency-Key | Task mới | 5s / 2 lần cùng key |
| \[TaskDelete\] `DELETE /tasks/{id}` | id | deletedAt | 5s / 2 lần |
| \[TaskRestore\] `POST /tasks/{id}/restore` | id | Task | 5s / 2 lần |
| \[TrashList\] `GET /tasks/trash` | cursor, limit | Task[], nextCursor | 5s / 1 lần |
| \[SubtaskCreate\] / \[SubtaskUpdate\] / \[SubtaskDelete\] | taskId, title, plannedMin, position, completedAt | Subtask | 5s / 2 lần |
| \[CommentCreate\] / \[CommentList\] | taskId, body | Comment | 5s / 1 lần |
| \[ActivityLog\] `GET /tasks/{id}/activity` | id, cursor | Entry[] | 5s / 1 lần |
| \[ChannelCreate\] / \[ChannelUpdate\] / \[ChannelDelete\] | name, color, contextId, isPrivate, isHidden, moveTasksTo | Channel | 5s / 1 lần |
| \[AppConfig\] | – | Giới hạn BR-01 | Cache 1h |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field title · TOO_LONG | MSG-01 |
| `VALIDATION_FAILED` · field plannedMin | MSG-02 |
| `VALIDATION_FAILED` · field notes / comment | MSG-03 |
| `LIMIT_SUBTASKS` | MSG-04 |
| `CHANNEL_NAME_TAKEN` | MSG-15 |
| `CONTEXT_NOT_EMPTY` | MSG-16 |
| `NOT_FOUND` (task đã xoá vĩnh viễn) | MSG-14 |
| `WORKSPACE_READ_ONLY` (402) | MSG-11 |
| 5xx / timeout | MSG-10 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Inline | Tên task tối đa 500 ký tự |
| MSG-02 | Inline | Thời lượng từ 1 phút đến 24 giờ |
| MSG-03 | Inline | Nội dung quá dài |
| MSG-04 | Inline | Mỗi task tối đa 100 subtask |
| MSG-05 | – | (dự phòng) |
| MSG-06 | Inline dưới due | Hạn chót sớm hơn ngày bắt đầu |
| MSG-07 | Toast | Đã thêm vào Backlog · Mở Backlog |
| MSG-08 | Toast | Đã hoàn thành "{tiêu đề}" · Hoàn tác |
| MSG-09 | Toast | Đã xoá · Hoàn tác (Ctrl+Z) |
| MSG-10 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-11 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-12 | Inline | Task vừa được cập nhật trên thiết bị khác |
| MSG-13 | Toast | Đã khôi phục "{tiêu đề}" về {ngày} |
| MSG-14 | Toast | Task này đã bị xoá vĩnh viễn |
| MSG-15 | Inline | Channel này đã tồn tại trong {context} |
| MSG-16 | Inline | Hãy chuyển hoặc xoá các channel trong context trước |
| MSG-17 | Inline | Tên channel 1–50 ký tự, không chứa "#" |
| MSG-18 | Toast | Đã sao chép link task |
| MSG-19 | Toast | Đã xoá channel {tên}, {n} task chuyển sang {channel nhận} |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Task hiện trên cột ≤ 100 ms sau Enter (cập nhật lạc quan); \[TaskCreate\] p95 ≤ 300 ms; SCR-03 mở ≤ 500 ms |
| Offline | Tạo, sửa, hoàn thành, xoá chạy được khi mất mạng; đồng bộ lại không tạo trùng (idempotency key) |
| Đồng bộ | Thay đổi hiện trên thiết bị khác ≤ 5 giây qua realtime |
| Bảo mật | Chỉ chủ task đọc / sửa được (BR-15); lấy tiêu đề URL chặn IP nội bộ, timeout 3s; notes lọc HTML chống XSS |
| Log / audit | \[ActivityLog\] cho mọi thay đổi (BR-13); log hệ thống không chứa tiêu đề / notes |
| Tracking | Sự kiện: mở ô soạn, tạo task (nguồn: nút / phím / URL), giữ / sửa gợi ý, mở chi tiết, thêm subtask, hoàn thành, hoàn tác, xoá, khôi phục, nhân bản, tạo / xoá channel |
| Accessibility | Mọi thao tác có phím tắt tương đương; ✓ và nút icon có nhãn đọc màn hình; tương phản đạt WCAG 2.1 AA ở cả giao diện sáng / tối |
