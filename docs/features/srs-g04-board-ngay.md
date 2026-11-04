> **Mã:** PLN-SRS-G04-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g04-board-ngay.md

# UC-G04 - Board ngày, projection, khối lượng, tìm kiếm & phím tắt trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả cách hiển thị và di chuyển task trên board: chế độ xem, điều hướng ngày, kéo thả và sắp xếp, projection, cảnh báo khối lượng, bộ lọc channel, tìm kiếm, command menu và phím tắt. Nội dung task (G02), lặp lại (G03), timebox và lịch (G05), backlog / rollover / lưu trữ (G06), timer và Focus (G07), Daily planning / shutdown (G08), objective (G09), tích hợp (G11) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng thấy task theo ngày, biết giờ dự kiến làm từng task và ngày nào quá tải; di chuyển, sắp xếp, lọc, tìm task và gọi mọi lệnh bằng bàn phím |
| Actor | Người dùng đã đăng nhập · Hệ thống (tính projection / khối lượng) · Dịch vụ lịch (G05, cung cấp sự kiện bận) · Dịch vụ tìm kiếm |
| Phạm vi | Home board, Today view, 6 chế độ xem, điều hướng ngày, kéo thả, phím di chuyển, sắp xếp lại, projection, cảnh báo khối lượng, bộ lọc channel, tìm kiếm, command menu, bảng phím tắt, khung panel phải |
| Ngoài phạm vi | Tạo / sửa task, timebox và đồng bộ lịch, nội dung panel Backlog / Archive / Objectives / tích hợp, timer, ritual, chọn nhiều task (sau 1.1) |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Thấy hôm nay và các ngày tới dạng cột, mỗi cột có tổng thời lượng | Biết việc đang dồn vào ngày nào |
| US-02 | Người dùng | Đổi giữa Board, Calendar và Month | Xem kế hoạch theo góc phù hợp |
| US-03 | Người dùng | Nhảy nhanh tới hôm nay / ngày sau / ngày bất kỳ | Không cuộn tay qua nhiều ngày |
| US-04 | Người dùng | Kéo task sang ngày khác hoặc đổi thứ tự trong ngày | Sắp lại kế hoạch không cần mở task |
| US-05 | Người dùng | Thấy mỗi task dự kiến làm lúc mấy giờ | Biết khi nào xong việc cuối |
| US-06 | Người dùng | Được cảnh báo khi tổng việc vượt thời gian trống | Bớt việc trước khi bắt đầu ngày |
| US-07 | Người dùng | Lọc theo channel và tìm task theo từ khoá không dấu | Thấy đúng nhóm việc, tìm lại task cũ |
| US-08 | Người dùng thành thạo | Gọi mọi lệnh bằng Ctrl/Cmd+K và phím tắt, không bị kích hoạt nhầm khi gõ | Không rời bàn phím, không gây tai nạn |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Ngày làm việc.** "Hôm nay" là ngày lịch chứa thời điểm hiện tại trừ day_start_time, theo timezone người dùng. day_start_time mặc định 04:00 `[giả định — chờ PO chốt 04:00 hay 00:00]`. Mọi tính toán ngày dùng mốc này |
| BR-02 | **Tổng thời lượng ngày D** = Σ `plannedMin` của task có `startDate = D`, không ở `DA_XOA` / `LUU_TRU`, gồm cả task đã xong; không cộng riêng planned của subtask; task chưa có thời lượng tính 0 `[giả định]`. Hiển thị H:MM |
| BR-03 | **Thanh tiến độ** = Σ planned task xong / tổng thời lượng (BR-02). Tổng = 0 → tính theo số task xong / số task `[giả định]` |
| BR-04 | **Sức chứa ngày D** = min(ngưỡng khối lượng, thời gian trống). Thời gian trống = độ dài giờ làm việc của D (cài đặt "Lịch làm việc", mặc định 09:00–17:00) − hợp các khoảng sự kiện bận nằm trong giờ làm việc. Không trừ: sự kiện free, sự kiện cả ngày (EC-17), sự kiện do app tạo (timebox, có `appTaskId`), sự kiện ở lịch đang ẩn. Không trừ phần giờ đã trôi qua của hôm nay `[giả định]`. Ghi đè giờ làm việc theo channel không áp cho sức chứa ngày `[giả định]` |
| BR-05 | **Quá tải.** Tổng thời lượng > sức chứa → ngày `QUA_TAI`. Cộng dồn planned theo thứ tự hiển thị; task làm tổng cộng dồn vượt sức chứa và mọi task chưa xong sau nó có cờ `VUOT_NGUONG`, tooltip MSG-03 với X = sức chứa |
| BR-06 | **Projection.** Áp cho hôm nay và ngày tương lai, khi bật "Hiện projection". Lấy task chưa xong, chưa timebox, có planned, theo thứ tự hiển thị; đặt liên tiếp từ điểm bắt đầu (giờ bắt đầu làm việc; với hôm nay = max(giờ bắt đầu làm việc, hiện tại làm tròn lên 5 phút) `[giả định]`); gặp sự kiện bận hoặc timebox thì nhảy qua; giữa hai task cộng khoảng đệm (mặc định 0). Task không có planned: không có giờ dự kiến, không chiếm khe `[giả định]`. Projection chỉ hiển thị (mờ), không ghi ra lịch ngoài |
| BR-07 | **Tự sắp** (khi bật): task đã timebox theo giờ bắt đầu → priority (1→4) → vị trí tuỳ chỉnh; task xong xuống cuối. Tắt → chỉ theo vị trí tuỳ chỉnh, task xong vẫn xuống cuối |
| BR-08 | **Đổi ngày bằng kéo thả / phím.** `startDate = D` mới, vị trí theo `afterId` / `beforeId`; `rolloverCount = 0` (G06); nhật ký ghi "đặt ngày bắt đầu thành {ngày}" (BR-13 G02). Task chưa xong không được chuyển vào ngày < hôm nay `[giả định]`. Ngày đích trong ± 5 năm so với hôm nay |
| BR-09 | **Task đã timebox đổi ngày trên board:** giữ khung giờ, dời block sang cùng giờ ở ngày mới; G05 cập nhật sự kiện ngoài `[giả định]` |
| BR-10 | **Phím di chuyển.** D: `startDate + 1` ngày (task backlog: hôm nay + 1). "Hoãn 1 tuần": `startDate + 7`. S: về hôm nay. Ctrl+↑/↓: đổi chỗ với task kề trên / dưới. Ctrl+Shift+↑/↓: lên đầu / xuống cuối nhóm chưa xong. Lệnh áp cho task đang chọn, không có thì task đang hover |
| BR-11 | **Sắp xếp lại** một ngày theo 1 trong 7 tiêu chí: giờ bắt đầu (timebox, rồi projection), priority, ngắn nhất, dài nhất, mới nhất (`createdAt`), cũ nhất, channel (theo tên A→Z). Ghi lại vị trí tuỳ chỉnh của task chưa xong trong ngày; task xong không đổi. Khi bật tự sắp, BR-07 vẫn áp lên trên kết quả |
| BR-12 | Mọi thao tác ở BR-08, BR-10, BR-11 có Hoàn tác (toast hoặc Ctrl+Z) trả `startDate`, vị trí, `rolloverCount` về như trước |
| BR-13 | **Chế độ xem**: Board, Calendar 1 ngày, 3 ngày, Weekdays, Week, Month; Tab xoay vòng theo thứ tự này. View và bộ lọc cuối cùng lưu trên thiết bị `[giả định]` |
| BR-14 | **Điều hướng ngày.** Shift+Space về hôm nay; Shift+→/← sang khoảng kế tiếp / trước của view (Board, 1 ngày: 1 ngày; 3 ngày: 3; Weekdays, Week: 1 tuần; Month: 1 tháng) `[giả định]` |
| BR-15 | **Bộ lọc channel**: Tất cả / một context / tập channel. Chỉ ẩn card; tổng, tiến độ, cảnh báo vẫn tính trên toàn bộ task `[giả định]` |
| BR-16 | **Tìm kiếm.** Phạm vi: tiêu đề, notes, tiêu đề subtask của task người dùng, gồm task xong, backlog, lưu trữ; không gồm Thùng rác, comment `[giả định]`. Truy vấn ≥ 2 ký tự, debounce 250 ms `[giả định]`. So khớp không phân biệt hoa thường và dấu (bỏ dấu, đ→d). Lọc Ngày: Mọi lúc / Tuần trước (7 ngày qua) / Tháng trước (30 ngày qua) theo `startDate`, task backlog theo `updatedAt` `[giả định]`. Sắp theo độ khớp rồi mới nhất; 50 kết quả / trang. Task mới / sửa vào chỉ mục ≤ 5 giây |
| BR-17 | **Phím tắt.** Phím một ký tự chỉ chạy khi không có ô nhập focus và cài đặt "Phím tắt" bật. Gõ ≥ 4 ký tự trong 1 giây ngoài ô nhập → khoá phím một ký tự 1 giây (EC-25). Ctrl/Cmd+K, Ctrl+F luôn chạy |
| BR-18 | **Command menu.** Gồm mọi lệnh có phím tắt và lệnh không có phím (ví dụ "Hoãn 1 tuần"). Lọc theo tên lệnh, không phân biệt dấu. Lệnh cần task chỉ hiện khi có task đang chọn / hover. Lệnh thuộc phiên bản sau (Objectives, tích hợp) ẩn ở 1.0 |
| BR-19 | **Ngày nhiều task** (EC-40): cột > 100 task dùng danh sách ảo hoá; projection và tổng vẫn tính trên toàn bộ task |
| BR-20 | Người dùng chỉ thấy task của chính mình (G12 mở rộng ở 1.1). Workspace chỉ đọc (G12): xem, lọc, tìm được; mọi thao tác di chuyển / sắp xếp bị chặn |

## 4. Trạng thái

### 4.1. Trạng thái ngày (cột ngày)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `TRONG` | Không có task nào (sau khi trừ `DA_XOA`, `LUU_TRU`) | Header tổng "0:00"; thân cột chỉ có "Thêm task" |
| `BINH_THUONG` | Ngày ≥ hôm nay, có task chưa xong, tổng ≤ sức chứa (BR-04, BR-05) | Tổng màu thường; card có giờ dự kiến |
| `QUA_TAI` | Ngày ≥ hôm nay, tổng > sức chứa | Tổng màu đỏ, tooltip MSG-04; task vượt có chấm cảnh báo MSG-03 |
| `XONG_HET` | Có task, mọi task đã xong | Thanh tiến độ đầy; không hiện cảnh báo |
| `DA_QUA` | Ngày < hôm nay | Không tính projection, không cảnh báo; card hiện "actual / planned" |
| `CHUA_TINH_LICH` | Lịch chưa kết nối hoặc kết nối lỗi (G05) | Sức chứa = ngưỡng; tooltip tổng thêm dòng MSG-18 |

Chuyển trạng thái do hệ thống tính lại (UC-05) mỗi khi task của ngày, sự kiện lịch, cài đặt giờ làm việc / ngưỡng hoặc mốc "hôm nay" thay đổi. `CHUA_TINH_LICH` là cờ phụ, đi kèm `BINH_THUONG` hoặc `QUA_TAI`.

### 4.2. Trạng thái giờ trên card

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DU_KIEN` | Có giờ projection (BR-06) | Giờ mờ "9:45" trên card |
| `DA_TIMEBOX` | Task có timebox (G05) | Badge giờ màu cam, ví dụ "10:55" |
| `KHONG_GIO` | Task không có planned, đã xong, ngày đã qua, hoặc tắt projection | Không hiện giờ |
| `VUOT_NGUONG` | Cờ phụ theo BR-05 | Chấm cảnh báo cạnh giờ, tooltip MSG-03 |

## 5. Use Case

### UC-01 Xem board và chuyển chế độ xem

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Board / view được hiển thị với tổng, tiến độ, giờ dự kiến, trạng thái ngày đúng; view được lưu (BR-13) |
| Hậu điều kiện thất bại | Hiện dữ liệu lần cuối trên máy (nếu có) kèm MSG-15 |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Mở app hoặc phím H → Home (**SCR-01**) |
| 2 | Hệ thống | Xác định hôm nay theo BR-01; gọi \[DayList\] cho 7 ngày từ hôm nay và \[CalendarEvents\] (G05) cùng khoảng |
| 3 | Hệ thống | Vẽ cột ngày (**SCR-02**): header, card theo BR-07; tính tổng, tiến độ, sức chứa, projection (BR-02 → BR-06) |
| 4 | Người dùng | Cuộn ngang |
| 5 | Hệ thống | Gần mép còn 2 cột thì tải thêm 7 ngày (\[DayList\]); giữ ± 3 tuần trong bộ nhớ `[giả định]` |
| 6 | Người dùng | Nhấn Tab hoặc chọn view trên thanh công cụ (**SCR-03**) |
| 7 | Hệ thống | Đổi view theo BR-13, giữ ngày đang xem; lưu view trên thiết bị |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phím T / sidebar "Today" | Mở Today view: danh sách task ngày đang xem + lịch ngày (G05) |
| A2 | Hover header cột hôm nay / tương lai | Hiện nút "Plan" → mở Daily planning ngày đó (G08). Ngày đã qua: không hiện |
| A3 | Calendar views | Hiện sự kiện (G05), timebox, projection mờ hơn sự kiện thật (cài đặt "Projection mờ hơn sự kiện thật") |
| A4 | Month view | Mỗi ngày tối đa 3 task, "+n" mở popover danh sách `[giả định]` |
| A5 | Bật "Ẩn task đã xong" | Card xong ẩn; tổng, tiến độ vẫn tính (BR-02, BR-03) |
| A6 | Ngày có > 100 task (EC-40) | Danh sách ảo hoá (BR-19); cuộn trong cột giữ ≥ 50 fps `[giả định]` |
| A7 | Qua mốc day_start_time khi đang mở app | "Hôm nay" chuyển sang ngày mới; cột cũ thành `DA_QUA`; nhận kết quả rollover qua realtime (G06) |
| A8 | Timezone thiết bị khác timezone người dùng (EC-02) | Hiện MSG-16 "Dùng múi giờ mới / Giữ múi giờ cũ". Chọn mới → tính lại hôm nay; task giữ `startDate`; timebox giữ thời điểm tuyệt đối, hiển thị theo giờ mới (G05) |
| A9 | Mobile web (< 768 px) | Board hiện 1 cột, vuốt ngang đổi ngày `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Hiện dữ liệu IndexedDB (4 tuần + backlog); banner "Đang offline"; tính projection trên máy |
| E2 | \[DayList\] lỗi / timeout | Giữ dữ liệu đã có, MSG-15 có "Thử lại" |
| E3 | \[CalendarEvents\] lỗi hoặc chưa kết nối lịch | Ngày gắn cờ `CHUA_TINH_LICH`, sức chứa = ngưỡng |

### UC-02 Điều hướng ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đang ở Home, Today view hoặc Calendar views |
| Hậu điều kiện thành công | Ngày / khoảng đang xem đổi đúng; chip ngày cập nhật |
| Hậu điều kiện thất bại | Ngày đang xem không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm chip ngày trên thanh công cụ → popover (**SCR-04**) |
| 2 | Người dùng | Chọn Hôm nay / Ngày sau / Ngày trước hoặc một ngày trên lịch tháng |
| 3 | Hệ thống | Cuộn / chuyển tới ngày chọn (tải \[DayList\] nếu chưa có); đóng popover |
| 4 | Hệ thống | Ngày đang xem ≠ hôm nay → chip hiện ngày đó kèm × |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Shift+Space / Shift+→ / Shift+← | Như bước 3 theo BR-14, không mở popover |
| A2 | Bấm × trên chip | Về hôm nay |
| A3 | Đang ở Calendar views | Dịch theo khoảng của view (BR-14) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Ngày ngoài ± 5 năm | Ngày trên lịch tháng disabled; phím không đi tiếp, MSG-19 |
| E2 | \[DayList\] lỗi | Hiện khung cột rỗng có MSG-15 "Thử lại" |

### UC-03 Di chuyển task giữa các ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task không ở `DA_XOA`; workspace không chỉ đọc |
| Hậu điều kiện thành công | `startDate`, vị trí đổi theo BR-08 / BR-10; hai ngày liên quan được tính lại; nhật ký ghi; có Hoàn tác |
| Hậu điều kiện thất bại | Task về vị trí cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Kéo card từ cột ngày A, thả vào cột ngày B giữa hai task |
| 2 | Hệ thống | Trong lúc kéo hiện vạch vị trí thả; cột đích ngoài khung nhìn thì cuộn tự động khi kéo tới mép |
| 3 | Hệ thống | Kiểm tra BR-08; chuyển card ngay (lạc quan); gọi \[TaskMove\] với `startDate = B`, `afterId` / `beforeId`, `version` |
| 4 | Hệ thống | Tính lại ngày A và B (UC-05); toast MSG-01 có "Hoàn tác" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phím D / lệnh "Hoãn 1 tuần" / phím S | \[TaskMove\] với `snooze: day` / `snooze: week` / `startDate = hôm nay` (BR-10); toast MSG-05 / MSG-06 / MSG-07 |
| A2 | Task đã timebox | Áp BR-09; G05 cập nhật sự kiện ngoài |
| A3 | Thả vào panel Backlog | \[TaskMove\] với `backlogBucket` (G06) |
| A4 | Task lặp (G03) | Chỉ đổi instance đó, không hỏi phạm vi |
| A5 | Bấm Hoàn tác / Ctrl+Z | \[TaskMove\] trả `startDate`, vị trí, `rolloverCount` cũ (BR-12) |
| A6 | Kéo bằng bàn phím (accessibility) | Chọn task → Space "nhấc" → ←/→ đổi cột, ↑/↓ đổi vị trí → Space thả, Esc huỷ `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Task chưa xong thả vào ngày < hôm nay | Không cho thả (cột đích mờ); MSG-09 |
| E2 | Ngày đích ngoài ± 5 năm | MSG-19, task về chỗ cũ |
| E3 | `VERSION_CONFLICT` (task đổi ở thiết bị khác) | Tải lại task, vẽ theo server, MSG-17 |
| E4 | Task đã bị xoá ở thiết bị khác | Gỡ card, MSG-14 |
| E5 | Mất mạng | Áp trên máy, xếp hàng đợi, đồng bộ sau qua \[SyncBatch\] |
| E6 | Workspace chỉ đọc | Không cho kéo; MSG-20 |
| E7 | \[TaskMove\] lỗi 5xx | Trả card về chỗ cũ, MSG-15 |

### UC-04 Sắp xếp task trong ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Ngày có ≥ 2 task chưa xong; workspace không chỉ đọc |
| Hậu điều kiện thành công | Vị trí tuỳ chỉnh lưu; projection tính lại; có Hoàn tác |
| Hậu điều kiện thất bại | Thứ tự không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … trên header cột → "Sắp xếp lại" (**SCR-05**), hoặc lệnh trong command menu |
| 2 | Người dùng | Chọn tiêu chí (BR-11) |
| 3 | Hệ thống | Gọi \[DayReorder\] với `criterion`; vẽ lại theo BR-11 rồi BR-07 |
| 4 | Hệ thống | Toast MSG-08 có "Hoàn tác"; tính lại projection |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Kéo trong cột | \[TaskMove\] cùng `startDate`, đổi `afterId` / `beforeId` |
| A2 | Ctrl+↑/↓ / Ctrl+Shift+↑/↓ | Như A1 theo BR-10 |
| A3 | Tự sắp đang bật, vị trí thả / kết quả trái BR-07 (ví dụ Normal lên trên Urgent) | Card về đúng nhóm theo BR-07; hiện MSG-10 một lần / phiên `[giả định]` |
| A4 | Hoàn tác | \[DayReorder\] với `positions` cũ |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[DayReorder\] lỗi | Trả thứ tự cũ, MSG-15 |
| E2 | `VERSION_CONFLICT` | Tải lại ngày, MSG-17 |

### UC-05 Tính projection và khối lượng ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Ngày ≥ hôm nay (projection, cảnh báo); mọi ngày (tổng, tiến độ) |
| Hậu điều kiện thành công | Ngày có tổng, tiến độ, sức chứa, trạng thái (4.1), giờ trên card (4.2) đúng; thiết bị khác nhận `day.recomputed` ≤ 5 giây |
| Hậu điều kiện thất bại | Giữ kết quả lần trước |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Nhận thay đổi: task tạo / sửa planned / di chuyển / xong / xoá; sự kiện lịch đổi (`calendar.changed`, G05); đổi cài đặt giờ làm việc, ngưỡng, khoảng đệm; qua mốc phút làm tròn |
| 2 | Hệ thống (client) | Tính ngay trên máy cho ngày bị ảnh hưởng: BR-02 → BR-06; vẽ lại ≤ 200 ms với ngày 50 task |
| 3 | Hệ thống (server) | Tính lại cùng công thức, phát `day.recomputed {date, totalPlannedMin, availableMin, overloaded, projections[]}` |
| 4 | Hệ thống (client) | Kết quả server khác máy → vẽ theo server |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Sự kiện free hoặc cả ngày (EC-17) | Không trừ thời gian trống, không chặn projection |
| A2 | Projection vượt giờ kết thúc làm việc | Vẫn xếp tiếp sau giờ kết thúc; task đó có cờ `VUOT_NGUONG` nếu tổng vượt sức chứa |
| A3 | Không còn thời gian trống (họp kín giờ làm việc, EC-18) | Sức chứa = 0; mọi task chưa xong có planned đều `VUOT_NGUONG`, MSG-03 "Chỉ còn 0:00 trống" |
| A4 | Timebox qua nửa đêm (EC-04) | Toàn bộ thời lượng tính cho ngày bắt đầu của block; phần sau nửa đêm chặn projection ngày hôm sau |
| A5 | Ngày chuyển giờ mùa hè / đông (EC-03) | Giờ làm việc theo giờ địa phương; thời gian trống tính bằng phút thực (ngày 23 hoặc 25 giờ); giờ projection rơi vào giờ không tồn tại → nhảy tới giờ hợp lệ kế tiếp |
| A6 | Sự kiện lịch bị dời / xoá ở lịch ngoài (EC-13, EC-14, G05) | Nhận `calendar.changed`, tính lại ngày cũ và ngày mới |
| A7 | Tắt "Hiện projection" | Bỏ bước projection; tổng và cảnh báo vẫn tính |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Không lấy được sự kiện lịch (E3 UC-01) | Cờ `CHUA_TINH_LICH`; sức chứa = ngưỡng |
| E2 | Tính toán > 200 ms (ngày rất nhiều task, EC-40) | Chạy trong web worker; giữ kết quả cũ tới khi xong |

### UC-06 Lọc theo channel

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đang ở Home / Today / Calendar views |
| Hậu điều kiện thành công | Chỉ card thuộc bộ lọc hiển thị; bộ lọc lưu trên thiết bị |
| Hậu điều kiện thất bại | Bộ lọc không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm nút lọc trên thanh công cụ hoặc Shift+F → **SCR-06** |
| 2 | Người dùng | Chọn Tất cả, một context, hoặc tích từng channel |
| 3 | Hệ thống | Ẩn card ngoài bộ lọc (BR-15); thanh công cụ hiện MSG-12 "Đang lọc: {n} channel · Bỏ lọc" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Quản lý channel" | Mở trang Context & channel (G02) |
| A2 | Bấm "Bỏ lọc" | Về Tất cả |
| A3 | Tạo task khi đang lọc một channel | Channel mặc định của ô soạn = channel đang lọc `[giả định]` |
| A4 | Channel trong bộ lọc bị xoá / ẩn (G02) | Bỏ channel đó khỏi bộ lọc; còn rỗng → Tất cả |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Không tải được danh sách channel (mất mạng / lỗi) | Dùng danh sách trên máy; lọc vẫn chạy trên dữ liệu đã tải |

### UC-07 Tìm kiếm task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Danh sách kết quả hiện; bấm kết quả mở chi tiết task |
| Hậu điều kiện thất bại | Giữ kết quả cũ, hiện lỗi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Ctrl+F hoặc biểu tượng Search ở panel phải → **SCR-07**, focus ô tìm |
| 2 | Người dùng | Gõ từ khoá; tuỳ chọn lọc Ngày, Channel |
| 3 | Hệ thống | Sau 250 ms ngừng gõ, gọi \[TaskSearch\] (BR-16) |
| 4 | Hệ thống | Hiện kết quả: tiêu đề tô sáng từ khoá, ngày, channel, trạng thái xong |
| 5 | Người dùng | Bấm kết quả hoặc ↑/↓ + Enter |
| 6 | Hệ thống | Mở chi tiết task (G02); cuộn board tới ngày của task (task backlog → mở panel Backlog, G06) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Truy vấn < 2 ký tự | Không gọi API; hiện MSG-11 |
| A2 | Cuộn tới cuối danh sách | Tải trang kế (cursor) |
| A3 | Mất mạng | Tìm trên dữ liệu IndexedDB (4 tuần + backlog); ghi chú "Kết quả trên máy" |
| A4 | Kết quả là task lưu trữ | Mở chi tiết ở chế độ xem, có nút khôi phục (G06) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Không có kết quả | MSG-02 |
| E2 | 429 | MSG-13, tự thử lại sau 2 giây |
| E3 | \[TaskSearch\] lỗi 5xx / timeout | MSG-15 |

### UC-08 Command menu và phím tắt

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Ứng dụng đang focus; với phím một ký tự: không có ô nhập focus, cài đặt "Phím tắt" bật (BR-17) |
| Hậu điều kiện thành công | Lệnh chạy đúng ngữ cảnh; lệnh có tác dụng phụ có Hoàn tác |
| Hậu điều kiện thất bại | Không có lệnh nào chạy |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Ctrl/Cmd+K → **SCR-08** |
| 2 | Hệ thống | Hiện lệnh theo nhóm (BR-18); có task đang chọn / hover → nhóm Thao tác task lên đầu, tiêu đề menu ghi tên task |
| 3 | Người dùng | Gõ để lọc, ↑/↓ chọn, Enter |
| 4 | Hệ thống | Chạy lệnh; đóng menu; lệnh có tác dụng phụ hiện toast Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Gõ thẳng phím tắt (H, T, P, O, B, Tab, D, S, F, K, Shift+F, Shift+C/T/B/A, <, >, Shift+L…) | Chạy lệnh như bước 4, không mở menu |
| A2 | Lần đầu dùng phím tắt | Toast MSG-21 (một lần / tài khoản) |
| A3 | Phím ? | Mở bảng phím tắt **SCR-09** |
| A4 | Gõ ≥ 4 ký tự trong 1 giây ngoài ô nhập (EC-25) | Khoá phím một ký tự 1 giây; ký tự gõ trong lúc khoá bị bỏ qua, không chạy lệnh |
| A5 | Lệnh thuộc nhóm khác (P, O → G08; F, K, Space → G07; Shift+R → G09 bản 1.1) | Chuyển cho nhóm sở hữu; lệnh chưa có ở 1.0 không hiện |
| A6 | Phím trùng trình duyệt (Ctrl+F, Tab) khi đang trong ô nhập | Giữ hành vi chuẩn của trình duyệt |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Không có lệnh khớp | MSG-22 trong menu |
| E2 | Lệnh cần task nhưng không có task chọn / hover | Lệnh không hiện; phím tắt không làm gì |
| E3 | Workspace chỉ đọc, lệnh ghi | Lệnh disabled, MSG-20 |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Mở app / phím H / sidebar "Home" | ✓ | ✓ | SCR-01 |
| Phím T / sidebar "Today" | ✓ | ✓ | Today view |
| Phím Tab / bộ chọn view | ✓ | – | Đổi view (BR-13); app dùng bộ chọn |
| Chip ngày / Shift+Space / Shift+→ / Shift+← | ✓ | ✓ (vuốt) | SCR-04 |
| Kéo thả card / phím D, S, Ctrl+↑/↓ | ✓ | ✓ (nhấn giữ để kéo) | UC-03, UC-04 |
| Menu … header cột → "Sắp xếp lại" | ✓ | ✓ | SCR-05 |
| Nút lọc / Shift+F | ✓ | ✓ | SCR-06 |
| Ctrl+F / Search ở panel phải | ✓ | ✓ | SCR-07 |
| Ctrl/Cmd+K | ✓ | ✓ (desktop) | SCR-08 |
| Phím ? | ✓ | ✓ (desktop) | SCR-09 |

## 7. Mô tả màn hình

### SCR-01 Home board

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Sidebar trái | Nav | Home, Today, Focus (G07), Backlog (G06), Daily planning / shutdown (G08) |
| 2 | Thanh công cụ | Toolbar | SCR-03 |
| 3 | Vùng cột ngày | Scroll ngang | Cột SCR-02; tải thêm 7 ngày khi còn 2 cột tới mép; cột hôm nay có nền nhấn |
| 4 | Panel phải | Panel | Biểu tượng Calendar (Shift+C), Tasks (Shift+T), Backlog (Shift+B), Archive (Shift+A), Search, Latest updates, tích hợp (G11), nút +; < / > ẩn hiện panel |
| 5 | Banner trạng thái | Banner | Offline, workspace chỉ đọc (MSG-20), timezone đổi (MSG-16) |

### SCR-02 Cột ngày

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Thứ, ngày | Text | "Thứ Năm" + "5 tháng 11"; hôm nay ghi "Hôm nay" |
| 2 | Thanh tiến độ | Progress | BR-03 |
| 3 | Tổng thời lượng | Text H:MM | BR-02; đỏ khi `QUA_TAI`; tooltip "Tổng: thời lượng kế hoạch" + MSG-04 / MSG-18 khi có |
| 4 | Nút "Plan" | Button | Hiện khi hover header ngày ≥ hôm nay → Daily planning (G08) |
| 5 | Menu … | Menu | "Sắp xếp lại" (SCR-05) |
| 6 | "Thêm task" | Button | Mở ô soạn (G02) |
| 7 | Danh sách card | List | Card G02; giờ theo 4.2; ảo hoá khi > 100 task |
| 8 | Vạch thả | Indicator | Hiện khi kéo; cột không thả được (E1 UC-03) mờ đi |

### SCR-03 Thanh công cụ

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Chip ngày đang xem | Button + × | Mở SCR-04; × về hôm nay; ẩn × khi đang ở hôm nay |
| 2 | ‹ › | Icon button | Ngày / khoảng trước, sau (BR-14) |
| 3 | Bộ chọn view | Segmented | 6 view (BR-13); tooltip "Tab" |
| 4 | Nút lọc | Button | Mở SCR-06; đang lọc hiện số channel + MSG-12 |
| 5 | Zoom lịch | Icon button | Chỉ ở Calendar views (G05) |

### SCR-04 Popover chọn ngày

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Hôm nay | Menu item | Shift+Space |
| 2 | Ngày sau | Menu item | Shift+→ |
| 3 | Ngày trước | Menu item | Shift+← |
| 4 | Lịch tháng | Date picker | Bắt đầu tuần Thứ Hai; ngày ngoài ± 5 năm disabled; ngày có task có chấm |

### SCR-05 Menu "Sắp xếp lại"

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Giờ bắt đầu | Menu item | BR-11 |
| 2 | Priority | Menu item | Urgent → Low |
| 3 | Ngắn nhất / Dài nhất | Menu item | Theo planned; không có planned xuống cuối |
| 4 | Mới nhất / Cũ nhất | Menu item | Theo `createdAt` |
| 5 | Channel | Menu item | Theo tên channel A→Z |

### SCR-06 Bộ lọc channel

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tất cả | Radio | – | Mặc định |
| 2 | Context (work, personal, …) | Radio | – | Chọn mọi channel của context |
| 3 | Danh sách channel | Checkbox list | – | Nhóm theo context, màu channel; channel ẩn không hiện |
| 4 | "Quản lý channel" | Link | – | Mở Context & channel (G02) |

### SCR-07 Panel Search

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ô tìm | Text | Có | ≥ 2 ký tự (MSG-11); tối đa 200 ký tự `[giả định]`; Esc xoá / đóng |
| 2 | Lọc Ngày | Dropdown | Không | Mọi lúc (mặc định), Tuần trước, Tháng trước |
| 3 | Lọc Channel | Dropdown có tìm | Không | Mặc định tất cả |
| 4 | Kết quả | List | – | Tiêu đề tô sáng, ngày, #channel, ✓ nếu xong; ↑/↓ + Enter |
| 5 | Trạng thái rỗng | Empty state | – | MSG-02 |

### SCR-08 Command menu

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Ô lệnh | Text | Placeholder "Gõ lệnh hoặc tìm…"; lọc không dấu |
| 2 | Ngữ cảnh | Header | Tên task đang chọn / hover (nếu có) |
| 3 | Nhóm Thao tác task | List | Hoàn thành, xoá, nhân bản… (G02); timer (G07) |
| 4 | Nhóm Lên lịch task | List | Hoãn 1 ngày (D), Hoãn 1 tuần, Về hôm nay (S), Đưa vào backlog (Z, G06), timebox (G05) |
| 5 | Nhóm Thứ tự task | List | Ctrl+↑/↓, Ctrl+Shift+↑/↓, Sắp xếp lại theo… |
| 6 | Nhóm Điều hướng task | List | ↑/↓ task kề, Shift+↑/↓ task đầu / cuối ngày `[giả định]`, →/← sang ngày kề |
| 7 | Nhóm Focus | List | F Focus, K nghỉ (G07) |
| 8 | Nhóm Điều hướng ngày | List | Shift+Space, Shift+→, Shift+← |
| 9 | Nhóm Điều hướng trang | List | H, T, P, O, B, Tab, Shift+C/T/B/A, < >, Shift+L chế độ tối |
| 10 | Nhóm Chung | List | ? bảng phím tắt, Ctrl+F tìm kiếm, Shift+F lọc |

### SCR-09 Bảng phím tắt

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Danh sách theo nhóm | List | Cùng nhóm với SCR-08; hiện Ctrl hoặc ⌘ theo hệ điều hành |
| 2 | Ghi chú | Text | "Phím một ký tự không chạy khi đang gõ" |
| 3 | Link cài đặt | Link | Mở Cài đặt → Phím tắt (G01) |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[DayList\] `GET /days?from&to` | from, to (≤ 42 ngày), X-Client-Timezone | Day[] {date, tasks[], totalPlannedMin, availableMin, overloaded, projections[]} | 5s / 2 lần |
| \[TaskMove\] `POST /tasks/{id}/move` | `{startDate, afterId?, beforeId?}` \| `{backlogBucket}` \| `{snooze: day\|week}`, version, Idempotency-Key | Task, ngày bị ảnh hưởng | 5s / 2 lần cùng key |
| \[DayReorder\] `POST /days/{date}/reorder` | `criterion` hoặc `positions[] {taskId, position}`, Idempotency-Key | Task[] (id, position) | 5s / 2 lần cùng key |
| \[TaskSearch\] `GET /tasks/search?q&from&channelId` | q, from, to, channelId, cursor, limit ≤ 50 | Task[] + `highlights`, nextCursor | 3s / 1 lần |
| \[CalendarEvents\] `GET /calendar/events?from&to` | from, to | Event[] (busy / free, allDay, appTaskId) — G05 | 5s / 1 lần |
| \[SyncBatch\] `POST /sync/batch` | Hàng đợi thao tác offline | Kết quả từng thao tác | 10s / backoff |
| \[SettingsUpdate\] `PATCH /me/settings` | Ngưỡng, giờ làm việc, tự sắp, hiện projection… (G01) | Settings | 5s / 2 lần |
| Realtime `day.recomputed` | – | {date, totalPlannedMin, availableMin, overloaded, projections[]} | Tự kết nối lại; mất > 30s → gọi \[DayList\] |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field startDate · PAST_DATE | MSG-09 |
| `VALIDATION_FAILED` · field startDate · OUT_OF_RANGE | MSG-19 |
| `VALIDATION_FAILED` · field q · TOO_SHORT | MSG-11 |
| `VERSION_CONFLICT` (409 / 412) | MSG-17 |
| `NOT_FOUND` (task đã xoá) | MSG-14 |
| `WORKSPACE_READ_ONLY` (402) | MSG-20 |
| `RATE_LIMITED` (429) | MSG-13 |
| 5xx / timeout | MSG-15 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | Đã chuyển "{tiêu đề}" sang {thứ, ngày} · Hoàn tác |
| MSG-02 | Panel Search | Không tìm thấy kết quả. Thử diễn đạt khác. |
| MSG-03 | Tooltip chấm cảnh báo | Chỉ còn {X} trống |
| MSG-04 | Tooltip tổng | Vượt {Y} so với thời gian trống ({X}) |
| MSG-05 | Toast | Đã hoãn sang ngày mai · Hoàn tác |
| MSG-06 | Toast | Đã hoãn 1 tuần, sang {thứ, ngày} · Hoàn tác |
| MSG-07 | Toast | Đã chuyển về hôm nay · Hoàn tác |
| MSG-08 | Toast | Đã sắp xếp theo {tiêu chí} · Hoàn tác |
| MSG-09 | Toast | Không thể chuyển task chưa xong về ngày đã qua |
| MSG-10 | Toast | Đang bật tự sắp: task theo giờ và priority được xếp trước. Tắt trong Cài đặt |
| MSG-11 | Inline | Nhập ít nhất 2 ký tự |
| MSG-12 | Thanh công cụ | Đang lọc: {n} channel · Bỏ lọc |
| MSG-13 | Panel Search | Đang tìm chậm hơn bình thường, thử lại sau giây lát |
| MSG-14 | Toast | Task này đã bị xoá |
| MSG-15 | Toast | Chưa tải / lưu được thay đổi. Thử lại |
| MSG-16 | Banner | Múi giờ của thiết bị đã đổi sang {timezone}. Dùng múi giờ mới · Giữ {timezone cũ} |
| MSG-17 | Toast | Task vừa được thay đổi trên thiết bị khác, đã cập nhật lại |
| MSG-18 | Tooltip tổng | Chưa tính lịch: chưa kết nối hoặc lịch đang lỗi |
| MSG-19 | Toast | Chỉ chọn được ngày trong vòng 5 năm tính từ hôm nay |
| MSG-20 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục sắp xếp task |
| MSG-21 | Toast | Phím tắt đầu tiên của bạn! Nhấn ? để xem tất cả |
| MSG-22 | Command menu | Không có lệnh phù hợp |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | \[DayList\] 1 tuần p95 ≤ 500 ms; Home ≤ 2,5 s trên 4G; kéo thả phản hồi ≤ 100 ms (lạc quan); projection tính lại ≤ 200 ms cho ngày 50 task; ngày 500 task (EC-40) cuộn ≥ 50 fps nhờ ảo hoá; tìm kiếm p95 ≤ 300 ms |
| Offline | Xem board 4 tuần + backlog, kéo thả, sắp xếp, tìm kiếm trên máy khi mất mạng; đồng bộ qua \[SyncBatch\], xung đột theo trường, bản sau thắng |
| Đồng bộ | `day.recomputed`, `task.upserted` tới thiết bị khác ≤ 5 giây; chỉ mục tìm kiếm cập nhật ≤ 5 giây |
| Bảo mật | Chỉ trả task của người dùng (BR-20); truy vấn tìm kiếm không ghi vào log hệ thống |
| Log / audit | Đổi ngày ghi \[ActivityLog\] (G02 BR-13); sắp xếp lại không ghi nhật ký từng task, chỉ ghi sự kiện tracking |
| Tracking | Sự kiện: `board_viewed` (view), `view_switched`, `date_navigated` (cách: phím / popover / chip), `task_moved` (cách: kéo / phím / menu, số ngày dịch), `day_reordered` (tiêu chí), `day_overloaded_shown`, `overload_resolved`, `channel_filter_applied`, `search_performed` (độ dài, số kết quả), `search_result_opened`, `command_menu_opened`, `shortcut_used` (phím), `shortcut_blocked_fast_typing`, `undo_after_shortcut` |
| Accessibility | WCAG 2.1 AA; mọi kéo thả có cách bàn phím (A6 UC-03) và menu; trạng thái quá tải không chỉ dùng màu (có biểu tượng + nhãn đọc màn hình "Quá tải, vượt {Y}"); command menu và panel Search điều khiển hoàn toàn bằng bàn phím, focus trả về chỗ cũ khi đóng |
