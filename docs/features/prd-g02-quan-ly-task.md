> **Mã:** PLN-PRD-G02 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g02-quan-ly-task.md

# PRD Quản lý task trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026; chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Task là đơn vị trung tâm của sản phẩm: board theo ngày, lịch, timebox, backlog, ritual và AI đều đọc / ghi task. Nhóm G02 lo vòng đời của một task: tạo, bổ sung chi tiết, hoàn thành, nhân bản, xoá và khôi phục, cùng channel để phân loại. Lặp lại (G03), xếp lên board (G04), timebox (G05), backlog (G06) và timer (G07) nằm ở nhóm riêng nhưng dùng chung mô hình task này.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Ghi một việc mới mất nhiều thao tác (mở form, chọn ngày, chọn loại, ước lượng) | Người dùng ngại ghi, việc nằm trong đầu hoặc rải rác ở chỗ khác |
| Không ước lượng thời lượng cho task | Không biết ngày có quá tải không, không timebox được |
| Chi tiết của việc (bước nhỏ, ghi chú, link) nằm ngoài task | Phải mở nhiều công cụ khi làm việc |
| Xoá hoặc đánh dấu xong nhầm không lấy lại được | Mất dữ liệu, mất niềm tin vào công cụ |
| Không phân loại được thời gian dành cho việc gì | Weekly review và analytics không có dữ liệu theo channel |

## 1.3 Mục tiêu

- Ghi một task trong ≤ 5 giây, chỉ cần gõ tiêu đề và Enter; phần còn lại có giá trị gợi ý sẵn.
- Mọi task đều có thời lượng kế hoạch (người dùng nhập hoặc AI gợi ý) để các nhóm G04, G05 tính được khối lượng ngày.
- Mọi thao tác phá huỷ đều hoàn tác được.
- Mọi task thuộc một channel để thống kê thời gian theo channel.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân (dùng chuột là chính) | Gõ nhanh một việc vào ngày, bổ sung bước nhỏ, đánh dấu xong |
| Người dùng thành thạo | Làm mọi thao tác bằng phím tắt, không rời bàn phím |
| Người hay đổi ý / thao tác nhầm | Hoàn tác được ngay khi lỡ xoá hoặc lỡ đánh dấu xong |
| Người làm nhiều vai (công việc, cá nhân, khách hàng) | Phân loại task theo channel và context để xem thời gian dành cho từng mảng |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Tạo task: từ ô soạn trên cột ngày, phím A, dán URL.
- Gợi ý thời lượng và channel từ lịch sử của chính người dùng.
- Chi tiết task: channel, priority, ngày bắt đầu, hạn chót (due), thời lượng kế hoạch, subtask, notes, comment, nhật ký hoạt động.
- Hoàn thành / bỏ hoàn thành task và subtask.
- Nhân bản, xoá mềm, hoàn tác, Thùng rác, khôi phục.
- Context và channel: tạo, sửa, ẩn, xoá (chuyển task sang channel khác).

## 3.2 Ngoài phạm vi

- Lặp lại task → G03.
- Kéo thả trên board, sắp xếp, projection → G04.
- Timebox lên lịch → G05. Backlog, rollover, lưu trữ tự động → G06. Timer, Focus → G07.
- Đính kèm file → bản 1.1.
- Giao task cho người khác, follow task → G12 (bản 1.1).
- Gộp task (giữ Alt khi kéo) → sau 1.1.

# 4. Nguyên tắc sản phẩm

## 4.1 Gõ là xong

Chỉ tiêu đề là bắt buộc. Ngày lấy theo cột đang đứng, thời lượng và channel lấy từ gợi ý; người dùng sửa sau nếu muốn.

## 4.2 Gợi ý phải nhìn ra được

Giá trị do AI gợi ý có biểu tượng ✨ riêng. Người dùng sửa thì biểu tượng mất. Không bao giờ ghi đè giá trị người dùng đã nhập.

## 4.3 Không có thao tác mất trắng

Xoá, hoàn thành, đổi ngày đều có toast **Hoàn tác** và ghi nhật ký. Task xoá vào Thùng rác, khôi phục được trong 30 ngày `[giả định]` (Sunsama giữ 7 ngày; chọn dài hơn có chủ đích).

## 4.4 Lưu ngay, không có nút Lưu

Sửa trường nào lưu trường đó ngay; mất mạng thì giữ ở máy và đồng bộ lại khi có mạng.

# 5. Quy tắc thuộc tính task

| **Thuộc tính** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Tiêu đề | 1–500 ký tự, cắt khoảng trắng hai đầu | — | Bắt buộc |
| Ngày bắt đầu | Ngày, trong khoảng ± 5 năm | Ngày của cột đang soạn; trống = backlog (G06) | Hoàn thành → đổi thành ngày hoàn thành |
| Hạn chót (due) | Ngày, độc lập với ngày bắt đầu | Trống | Due < ngày bắt đầu: cho phép, có cảnh báo |
| Thời lượng kế hoạch | 1 phút – 24 giờ; preset 5, 10, 15, 20, 25, 30, 45 phút, 1 giờ | Gợi ý AI; không có gợi ý thì trống | Cộng vào tổng ngày |
| Priority | Urgent (1), Priority (2), Normal (3), Low (4) | Normal | Reset khi rollover theo cài đặt (G06) |
| Channel | Một channel thuộc một context | Gợi ý AI, không có thì channel mặc định của người dùng | Mỗi task đúng một channel |
| Subtask | Tối đa 100 / task, tiêu đề 1–500 ký tự | — | Có thời lượng và thời gian thực tế riêng |
| Notes | Rich text, tối đa 50.000 ký tự | Trống | Đậm, nghiêng, danh sách, checklist, link |
| Comment | 1–5.000 ký tự | — | Hiện tác giả, giờ |
| Vị trí task mới | Đầu / cuối danh sách | Đầu | Cài đặt người dùng (G01) |
| Giữ trong Thùng rác | 30 ngày | — | Sau đó xoá vĩnh viễn |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Context mặc định khi tạo tài khoản: `work`, `personal`, `uncategorized`.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Ghi nhận | Bấm "Thêm task" trên cột ngày (hoặc phím A), gõ tiêu đề, Enter | Task trên cột ngày, có thời lượng và channel gợi ý |
| 2 | Bổ sung chi tiết | Mở task: thêm subtask, notes, priority, due, sửa channel / thời lượng | Task đủ thông tin để làm |
| 3 | Sắp xếp, lên lịch | Kéo sang ngày khác, timebox, đưa vào backlog (G04–G06) | Task ở đúng ngày / giờ |
| 4 | Thực hiện | Bật timer, đánh dấu subtask xong dần (G07) | Thời gian thực tế |
| 5 | Hoàn thành | Bấm ✓ hoặc phím C | Task xong, subtask xong, thời gian thực tế / kế hoạch |
| 6 | Dọn dẹp | Nhân bản việc tương tự; xoá việc không cần; lấy lại từ Thùng rác khi cần | Danh sách gọn, không mất dữ liệu |

Bước 3–4 thuộc nhóm khác, chỉ nêu để thấy vị trí của G02. PRD này tập trung bước 1, 2, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Tạo task

### US1.1 Ghi nhanh một task vào ngày

User Story: Là người dùng, tôi muốn gõ tiêu đề rồi Enter là có task trong ngày, để ghi lại việc mà không mất mạch.

AC01: Ô soạn mở từ nút "Thêm task" trên cột ngày hoặc phím A; con trỏ nằm sẵn trong ô.

AC02: Enter tạo task với ngày bắt đầu = ngày của cột; task hiện ở đầu (hoặc cuối, theo cài đặt) danh sách ngày đó.

AC03: Tiêu đề trống → Enter không tạo task.

AC04: Esc khi đã gõ nội dung → giữ bản nháp, mở lại ô soạn thấy nội dung cũ (Sunsama bỏ luôn bản nháp; khác có chủ đích).

AC05: Ô soạn có sẵn các tuỳ chọn: ngày, thời lượng, channel, objective (1.1), priority, vị trí.

### US1.2 Tạo task từ link

AC01: Dán URL vào ô soạn → tiêu đề task lấy từ tiêu đề trang; không đọc được thì dùng chính URL.

AC02: Task giữ link nguồn; phím G mở link.

### US1.3 Có gợi ý thời lượng và channel

AC01: Sau khi gõ tiêu đề, thời lượng và channel được gợi ý theo lịch sử của chính người dùng, có biểu tượng ✨.

AC02: Người dùng sửa giá trị → biểu tượng ✨ mất, giá trị người dùng không bị ghi đè lại.

AC03: Người dùng tắt gợi ý trong cài đặt → không gợi ý.

## UC2. Xem và sửa chi tiết task

### US2.1 Mở và sửa task

AC01: Bấm tiêu đề task hoặc Ctrl+Enter mở chi tiết; Esc hoặc nút × đóng.

AC02: Sửa trường nào lưu ngay trường đó, không có nút Lưu.

AC03: Mọi thay đổi ghi vào nhật ký: ai (người / AI / tích hợp / hệ thống), sửa gì, lúc nào.

### US2.2 Chia nhỏ việc bằng subtask

AC01: Thêm subtask bằng nút "+ Subtask" hoặc phím V; Enter tạo subtask kế tiếp.

AC02: Mỗi subtask có thời lượng, thời gian thực tế và ô ✓ riêng; hover hiện "Hoàn thành lúc {giờ}".

AC03: Kéo để đổi thứ tự subtask.

### US2.3 Đặt priority và hạn chót

AC01: Priority chọn trong 4 mức hoặc phím 1–4 khi mở menu priority; task priority cao lên đầu danh sách ngày (khi bật tự sắp xếp).

AC02: Priority khác Normal hiện chip trên card.

AC03: Hạn chót hiện chip trên card; quá hạn đổi màu cảnh báo.

### US2.4 Ghi chú và bình luận

AC01: Notes hỗ trợ đậm, nghiêng, danh sách, checklist, link; lưu ngay khi gõ.

AC02: Comment hiện tác giả và giờ; Enter gửi, Shift+Enter xuống dòng.

## UC3. Hoàn thành task

### US3.1 Đánh dấu xong

User Story: Là người dùng, tôi muốn bấm một lần là task và các bước nhỏ đều xong, để không phải tích từng cái.

AC01: Bấm ✓ trên card / chi tiết hoặc phím C → task xong, mọi subtask chưa xong chuyển xong.

AC02: Task đang chạy timer → timer dừng trước khi đánh dấu xong.

AC03: Task không có thời gian thực tế và đang bật "Tính planned là actual" → actual = planned.

AC04: Task có ngày bắt đầu khác hôm nay → chuyển về ngày hoàn thành (hôm nay).

AC05: Card hiện "actual / planned" (ví dụ 0:02 / 1:30); có toast Hoàn tác.

### US3.2 Bỏ hoàn thành

AC01: Bấm lại ✓ → task chưa xong; subtask giữ nguyên trạng thái; nhật ký ghi "đánh dấu chưa xong".

## UC4. Nhân bản, xoá và khôi phục

### US4.1 Nhân bản

AC01: Menu … → Nhân bản (Ctrl+D) tạo bản sao: giữ tiêu đề, channel, thời lượng, due, subtask; ngày bắt đầu = hôm nay; mọi trạng thái xong reset; mở bản sao ngay.

### US4.2 Xoá và hoàn tác

AC01: Menu … → Xoá hoặc Ctrl+Backspace; không hỏi xác nhận; toast "Đã xoá · Hoàn tác (Ctrl+Z)".

AC02: Ctrl+Z hoặc nút Hoàn tác trong toast khôi phục đủ dữ liệu, đúng vị trí cũ.

AC03: Task xoá nằm trong Thùng rác 30 ngày `[giả định]`; quá hạn xoá vĩnh viễn.

AC04: Task đang chạy timer bị xoá → dừng timer, lưu thời gian trước khi xoá.

### US4.3 Khôi phục từ Thùng rác

AC01: Thùng rác (panel phải hoặc lệnh "Task đã xoá gần đây") liệt kê task đã xoá, mới nhất trước.

AC02: Khôi phục → task về ngày cũ nếu ngày đó ≥ hôm nay, ngược lại về hôm nay.

## UC5. Phân loại bằng context và channel

### US5.1 Quản lý channel

AC01: Tạo context; tạo channel trong context: tên, màu, riêng tư.

AC02: Tên channel 1–50 ký tự, không chứa "#", không trùng trong cùng context (không phân biệt hoa thường).

AC03: Ẩn channel → không hiện trong ô soạn và bộ lọc; task cũ giữ nguyên.

AC04: Xoá channel → hỏi chuyển task sang channel nào (mặc định `uncategorized`); không xoá task.

### US5.2 Gán channel cho task

AC01: Gõ "#" trong ô soạn hoặc phím Q / # trên task mở danh sách channel có ô tìm.

AC02: Shift+Q nhận channel gợi ý.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Thời gian ghi task | Từ mở ô soạn đến Enter | ≤ 5 giây (trung vị) |
| Tỉ lệ task có thời lượng | Task có planned / task tạo mới | ≥ 85% |
| Tỉ lệ giữ gợi ý AI | Task giữ nguyên thời lượng gợi ý / task có gợi ý | ≥ 60% |
| Tỉ lệ task có channel khác `uncategorized` | Task có channel thật / tổng task | ≥ 80% |
| Tỉ lệ hoàn tác | Hoàn tác / (xoá + hoàn thành) | Theo dõi (cao bất thường = UI dễ bấm nhầm) |
| Task khôi phục từ Thùng rác | Số lần khôi phục / tuần | Theo dõi |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Gợi ý thời lượng / channel | Người dùng mới chưa có lịch sử, gợi ý kém | Dùng giá trị mặc định theo từ khoá; ẩn gợi ý khi độ tin cậy thấp |
| Đồng bộ nhiều thiết bị | Hai máy sửa cùng task | Ghi theo từng trường, bản sau thắng; notes dùng CRDT (thiết kế kỹ thuật mục 6) |
| Phím tắt một chữ | Gõ khi chưa focus ô nhập kích hoạt lệnh (đã gặp trên Sunsama) | Phím tắt chỉ chạy khi không focus ô nhập; lệnh có tác dụng phụ có toast Hoàn tác |
| Lấy tiêu đề từ URL | Trang chậm, chặn bot, URL nội bộ | Timeout 3 giây, chặn IP nội bộ, fallback dùng URL |
| Thùng rác 30 ngày | Tăng dung lượng lưu trữ | Job xoá vĩnh viễn hằng ngày |

# 10. Câu hỏi mở

- Giữ Thùng rác 30 ngày hay 7 ngày như Sunsama?
- Esc giữ bản nháp hay bỏ luôn như Sunsama?
- Channel mặc định cho task không có gợi ý là `uncategorized` hay `work`?
- Có cho chọn nhiều task để xoá / chuyển channel cùng lúc ở 1.0 không?
- Comment ở 1.0 có cần khi chưa có workspace nhiều thành viên (G12, 1.1) không?
