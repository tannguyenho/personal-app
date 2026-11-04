> **Mã:** PLN-SRS-G06-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g06-backlog-rollover.md

# UC-G06 - Backlog, rollover & lưu trữ trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả backlog (bucket, folder, chuyển vào / ra), rollover tự động và Archive (tự lưu trữ, khôi phục, xoá tất cả). Mô hình task, Thùng rác (G02), quy tắc instance lặp (G03), board, snooze và kéo thả (G04), timebox (G05), nhắc bucket trong ritual (G08, G09) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng gạt việc chưa cần làm vào backlog bằng 1–2 phím; việc dở tự chuyển sang hôm nay; việc bị dời quá lâu hoặc bị bỏ qua được lưu trữ, khôi phục được |
| Actor | Người dùng đã đăng nhập · Hệ thống (job `rollover`) |
| Phạm vi | Trang / panel Backlog (6 bucket, folder, nhóm theo channel), chuyển task vào backlog (Z, Shift+Z, menu, kéo), lấy task ra ngày, rollover, Auto-archive, panel Archive, khôi phục, "Xoá tất cả" |
| Ngoài phạm vi | Snooze 1 ngày / 1 tuần và kéo thả trên board (G04), Thùng rác (G02), sinh instance lặp (G03), gỡ timebox trên lịch ngoài (G05), nhắc bucket trong ritual (G08, G09), backlog nhóm (G12) |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Gạt task sang "Tuần tới", "Tháng tới"… bằng hai phím | Hôm nay chỉ còn việc cần làm |
| US-02 | Người dùng | Đưa task lên đầu backlog không cần chọn | Hoãn nhanh nhất có thể |
| US-03 | Người dùng | Xem backlog theo bucket, folder, channel | Biết việc nào đang chờ, chọn đúng việc khi lên kế hoạch |
| US-04 | Người dùng | Kéo task từ backlog vào một ngày | Lên lịch cho việc đã hoãn |
| US-05 | Người dùng | Việc chưa xong tự chuyển sang hôm nay | Không phải dọn tay mỗi sáng |
| US-06 | Người dùng | Việc bị dời ≥ 4 ngày tự rời khỏi hôm nay | Hôm nay không phình mãi |
| US-07 | Người dùng | Xem và khôi phục task trong Archive, xoá tất cả khi cần | Không mất việc, dọn gọn khi muốn |
| US-08 | Người dùng thành thạo | Làm mọi thao tác trên bằng phím tắt | Không rời bàn phím |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Bucket.** 6 bucket cố định: `next_week` (Tuần tới, phím 1), `next_month` (Tháng tới, 2), `next_quarter` (Quý tới, 3), `next_year` (Năm tới, 4), `someday` (Một ngày nào đó, 5), `never` (Không bao giờ, 0). Không đổi tên, không xoá. Task backlog có `startDate` trống và `backlogBucket` bắt buộc |
| BR-02 | **Chuyển vào backlog.** `startDate` = null, `backlogBucket` = bucket chọn, vào đầu bucket `[giả định]`; giữ channel, thời lượng, subtask, notes, priority; gỡ timebox (G05 xoá sự kiện trên lịch ngoài); `rolloverCount` = 0. Timer đang chạy không dừng (G07) |
| BR-03 | **Shift+Z** đưa task lên đầu bucket `next_week`, không hỏi `[giả định]`; task đã ở backlog → lên đầu bucket hiện tại |
| BR-04 | **Folder.** Tuỳ chọn; tối đa 50 / người dùng, tên 1–50 ký tự, không trùng (không phân biệt hoa thường). Một task thuộc tối đa 1 folder và vẫn có bucket. Xoá folder → task ở lại backlog, `folderId` = null. Giới hạn lấy từ \[AppConfig\] `[giả định]` |
| BR-05 | **Lấy ra ngày.** Đặt `startDate` = D → `backlogBucket` = null, `folderId` = null, `rolloverCount` = 0; vị trí theo cài đặt "Vị trí task mới" (G02) |
| BR-06 | **Điều kiện rollover.** Task chưa xong, chưa xoá, chưa lưu trữ, `startDate` < hôm nay. "Hôm nay" tính theo `day_start_time` (04:00 `[giả định]`) và timezone người dùng |
| BR-07 | **Rollover.** `startDate` = hôm nay; `rolloverCount` + 1; nhiều ngày bị lỡ gộp thành một lần (+1, một dòng nhật ký, EC-05); vị trí theo cài đặt "Vị trí task rollover" (mặc định đầu), giữ thứ tự tương đối giữa các task được chuyển |
| BR-08 | **Priority khi rollover** về Normal, trừ mức có trong cài đặt "Giữ priority khi rollover" (mặc định không giữ mức nào) |
| BR-09 | **Timebox khi rollover.** Timebox có giờ trong quá khứ bị gỡ khỏi task, task về projection (G04); xử lý sự kiện trên lịch ngoài theo G05. Thời gian thực tế (TimeEntry, G07) giữ nguyên ở ngày cũ |
| BR-10 | **Reset bộ đếm.** Đổi ngày bằng tay, chuyển vào backlog, hoàn thành, khôi phục từ Archive → `rolloverCount` = 0 |
| BR-11 | **Instance lặp** (quy tắc G03): series đã có instance `startDate` = hôm nay → instance quá khứ chưa xong không rollover, `archivedAt` = now, `archiveReason = skipped`. Series chưa có instance hôm nay → chỉ instance quá khứ mới nhất rollover; instance cũ hơn → `skipped` (EC-30) |
| BR-12 | **Auto-archive.** Sau BR-07, nếu bật Auto-archive (mặc định bật `[giả định]`) và `rolloverCount` ≥ 4 → `archivedAt` = now, `archiveReason = stale`; gỡ timebox; không tính vào khối lượng ngày |
| BR-13 | **Idempotent.** Mỗi người dùng một bản ghi `rollover_runs(user_id, date)` UNIQUE; đã `XONG` thì bỏ qua. Đổi timezone / `day_start_time` làm mốc dịch chuyển không tạo lượt thứ hai cho cùng ngày (EC-06) |
| BR-14 | **Khôi phục từ Archive.** `archivedAt`, `archiveReason` = null; `startDate` = hôm nay; `rolloverCount` = 0; vào đầu danh sách hôm nay |
| BR-15 | **Xoá tất cả** trong Archive cần xác nhận; xoá mềm mọi task trong Archive (vào Thùng rác 30 ngày, G02); có Hoàn tác |
| BR-16 | Mọi thay đổi ghi \[ActivityLog\] (G02): chuyển vào backlog / bucket, lấy ra ngày (tác nhân `user`); rollover, lưu trữ (tác nhân `system`, "Chuyển từ {ngày}", "Lưu trữ: chuyển ngày {n} ngày liên tiếp" / "bị bỏ qua") |
| BR-17 | Phím Z, Shift+Z, B, S và phím chọn bucket chỉ hoạt động khi không có ô nhập nào đang focus; Z, Shift+Z luôn có toast Hoàn tác |

## 4. Trạng thái

### 4.1. Trạng thái task (phạm vi G06)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `BACKLOG` | `startDate` trống, có `backlogBucket`, chưa xong, chưa xoá | Trong bucket (và folder nếu có) trên trang Backlog |
| `KE_HOACH` | Có `startDate`, chưa xong, chưa lưu trữ, `rolloverCount` = 0 | Card trên cột ngày |
| `DA_CHUYEN_NGAY` | Như `KE_HOACH` nhưng `rolloverCount` ≥ 1 | Card trên cột hôm nay, dấu chuyển ngày + số ngày (SCR-07) |
| `LUU_TRU` | `archivedAt` có giá trị, `archiveReason = stale` | Chỉ trong Archive, nhãn "Chuyển ngày {n} ngày liên tiếp" |
| `BI_BO_QUA` | `archivedAt` có giá trị, `archiveReason = skipped` | Chỉ trong Archive, nhãn "Bị bỏ qua" |
| `HOAN_THANH` / `DA_XOA` | Theo G02 | Theo G02 |

Chuyển trạng thái: `KE_HOACH` / `DA_CHUYEN_NGAY` → `BACKLOG` (UC-01) · `BACKLOG` → `KE_HOACH` (UC-03) · `KE_HOACH` → `DA_CHUYEN_NGAY` → `DA_CHUYEN_NGAY` (UC-04) · `DA_CHUYEN_NGAY` → `LUU_TRU` (UC-05) · `KE_HOACH` / `DA_CHUYEN_NGAY` → `BI_BO_QUA` (UC-04, BR-11) · `LUU_TRU` / `BI_BO_QUA` → `KE_HOACH` (UC-06) · `LUU_TRU` / `BI_BO_QUA` → `DA_XOA` (UC-06). `DA_CHUYEN_NGAY` → `KE_HOACH` khi đổi ngày bằng tay (BR-10).

### 4.2. Trạng thái lượt rollover (`rollover_runs`)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHO` | Người dùng đã qua `day_start_time`, chưa có bản ghi cho ngày đó | – |
| `DANG_CHAY` | Job đã nhận lượt, khoá theo người dùng | – |
| `XONG` | Giao dịch commit; lưu `rolledCount`, `archivedCount`, `skippedCount` | Toast MSG-11 lần mở app kế tiếp (nếu `archivedCount` > 0) |
| `LOI` | Giao dịch lỗi | Lượt 15 phút sau thử lại; quá 3 lần ghi cảnh báo giám sát |

## 5. Use Case

### UC-01 Chuyển task vào backlog

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task ở `KE_HOACH`, `DA_CHUYEN_NGAY` hoặc `BACKLOG` (đổi bucket); workspace không chỉ đọc (G12) |
| Hậu điều kiện thành công | Task ở `BACKLOG`, đúng bucket (BR-02); rời cột ngày; tổng thời lượng ngày cập nhật |
| Hậu điều kiện thất bại | Task giữ ngày / bucket cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Nhấn Z khi task đang chọn / hover (BR-17), hoặc menu Ngày bắt đầu → "Chuyển vào backlog (Z)" |
| 2 | Hệ thống | Mở **SCR-02** gần task, bucket hiện tại (nếu có) được đánh dấu |
| 3 | Người dùng | Bấm một bucket hoặc phím 1, 2, 3, 4, 5, 0 |
| 4 | Hệ thống | Gọi \[TaskMove\] `{backlogBucket}`; ẩn task khỏi cột ngay (cập nhật lạc quan) |
| 5 | Hệ thống | Server áp BR-02; G05 gỡ timebox nếu có |
| 6 | Hệ thống | Toast MSG-01 "… · Mở task · Đóng" ≥ 5 giây; Ctrl+Z hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Shift+Z hoặc menu "Lên đầu backlog (Shift+Z)" | Bỏ qua bước 2–3; \[TaskMove\] `{backlogBucket: next_week, position: top}` (BR-03); toast MSG-02 có Hoàn tác |
| A2 | Kéo task vào trang / panel Backlog | Thả vào bucket hoặc folder nào thì chuyển vào đó |
| A3 | Bấm "Mở task" trong toast | Mở chi tiết task (G02) |
| A4 | Bấm Hoàn tác / Ctrl+Z | \[TaskMove\] trả `startDate`, vị trí, `rolloverCount` cũ; timebox không tự tạo lại, task về projection |
| A5 | Esc khi SCR-02 đang mở | Đóng menu, không đổi |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Áp trên máy, xếp hàng đợi, đồng bộ sau với cùng idempotency key |
| E2 | Task đã bị xoá ở thiết bị khác | 404 → MSG-20, gỡ khỏi màn hình |
| E3 | \[TaskMove\] lỗi 5xx / timeout | Trả task về cột cũ, MSG-17 |
| E4 | Workspace chỉ đọc | MSG-18, không chuyển |

### UC-02 Xem và tổ chức backlog

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Backlog hiển thị theo bucket; folder / task mới được lưu |
| Hậu điều kiện thất bại | Hiện dữ liệu đã lưu trên máy kèm lỗi tải |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Phím B hoặc mục "Backlog" ở sidebar |
| 2 | Hệ thống | Gọi \[BacklogList\] và \[BacklogFolderList\]; mở **SCR-01**: 6 bucket theo thứ tự BR-01, mỗi bucket có số task, tổng thời lượng |
| 3 | Người dùng | Cuộn, thu gọn / mở bucket, bấm task để mở chi tiết (G02) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm nút nhóm theo channel (#) | Trong mỗi bucket chia nhóm theo channel; nhớ lựa chọn trên máy |
| A2 | Lọc channel | \[BacklogList\] `channelId` |
| A3 | "Thêm task" trên đầu trang | Ô soạn G02 không có ngày; bucket = bucket đang mở (mặc định `next_week`), folder = folder đang mở; \[TaskCreate\] |
| A4 | "Thêm folder" | Mở **SCR-04**; \[BacklogFolderCreate\] |
| A5 | Đổi tên / xoá folder | SCR-04; xoá → hộp MSG-08 → \[BacklogFolderDelete\] (BR-04) |
| A6 | Kéo task giữa bucket / folder / thứ tự | \[TaskMove\] `{backlogBucket, folderId, afterId / beforeId}` |
| A7 | Bấm nút biểu đồ | Hiện tổng thời lượng theo bucket và channel `[giả định]` |
| A8 | Bucket rỗng | Empty state MSG-04 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tên folder rỗng / > 50 ký tự | MSG-05 |
| E2 | Tên folder trùng | MSG-06 |
| E3 | Folder thứ 51 | MSG-07 |
| E4 | \[BacklogList\] lỗi | Dữ liệu offline (IndexedDB) + MSG-17 có "Thử lại" |

### UC-03 Đưa task từ backlog ra ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task ở `BACKLOG` |
| Hậu điều kiện thành công | Task ở `KE_HOACH` trên ngày D (BR-05); tổng thời lượng ngày D cập nhật |
| Hậu điều kiện thất bại | Task ở lại bucket |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Kéo task từ SCR-01 vào cột ngày D ở panel ngày bên phải (hoặc board, G04) |
| 2 | Hệ thống | Gọi \[TaskMove\] `{startDate: D, afterId / beforeId}`; hiện task ở cột D ngay |
| 3 | Hệ thống | Server áp BR-05; phát `day.recomputed` cho ngày D (G04) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phím S trên task backlog | `startDate` = hôm nay; toast MSG-03 |
| A2 | Menu Ngày bắt đầu → chọn ngày trên lịch | `startDate` = ngày chọn; toast MSG-03 |
| A3 | Kéo vào lịch (timebox) | `startDate` = ngày của ô; tạo timebox theo G05 |
| A4 | Ritual đưa task từ bucket tới kỳ vào ngày (G08, G09) | Cùng \[TaskMove\], áp BR-05 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[TaskMove\] lỗi | Trả task về bucket cũ, MSG-17 |
| E2 | Workspace chỉ đọc | MSG-18 |

### UC-04 Rollover hằng ngày (job `rollover`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng vừa qua `day_start_time` theo timezone của họ; chưa có `rollover_runs` `XONG` cho ngày đó |
| Hậu điều kiện thành công | Mọi task thoả BR-06 ở hôm nay hoặc ở Archive (BR-11, BR-12); `rollover_runs` = `XONG` |
| Hậu điều kiện thất bại | Không task nào thay đổi (rollback); `rollover_runs` = `LOI`, lượt sau thử lại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job chạy mỗi 15 phút, chọn người dùng có `day_start_time` đã qua trong ngày theo timezone và chưa có lượt `XONG` (BR-13) |
| 2 | Hệ thống | Tạo / khoá `rollover_runs(user, date)` = `DANG_CHAY` |
| 3 | Hệ thống | Lấy task thoả BR-06; nhóm instance lặp theo series, áp BR-11 trước |
| 4 | Hệ thống | Với task còn lại: áp BR-07, BR-08, BR-09 trong một giao dịch |
| 5 | Hệ thống | Áp BR-12 cho task có `rolloverCount` ≥ 4 (UC-05) |
| 6 | Hệ thống | Ghi nhật ký `system` (BR-16); `rollover_runs` = `XONG` với số liệu |
| 7 | Hệ thống | Phát `task.upserted` cho task bị đổi, `day.recomputed` cho hôm nay; gửi yêu cầu gỡ timebox cho G05 (bất đồng bộ) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Job lỡ nhiều mốc hoặc task có `startDate` cách hôm nay > 1 ngày | Chuyển một lần về hôm nay, `rolloverCount` + 1 (BR-07, EC-05) |
| A2 | Người dùng đổi timezone / `day_start_time` trong ngày | Dùng ngày theo cài đặt mới; đã có lượt `XONG` cho ngày đó thì bỏ qua (EC-06) |
| A3 | Người dùng đang mở board / chi tiết task | Card chuyển cột qua realtime; chi tiết đang mở không đóng, ngày hiển thị cập nhật |
| A4 | Client offline qua mốc | Khi mở app hiển thị rollover tạm trên máy theo BR-06, BR-07; có mạng thì lấy kết quả server làm chuẩn |
| A5 | Task đang chạy timer | Rollover bình thường; timer không dừng (G07) |
| A6 | Không có task thoả BR-06 | Ghi lượt `XONG` với số liệu 0 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi CSDL giữa chừng | Rollback toàn bộ lượt của người dùng; `LOI`; lượt 15 phút sau thử lại; quá 3 lần cảnh báo giám sát |
| E2 | Gỡ timebox trên lịch ngoài lỗi | Không chặn rollover; G05 thử lại theo cơ chế `timebox.push` |

### UC-05 Tự lưu trữ (trong job `rollover`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | UC-04 bước 4 vừa tăng `rolloverCount` của task lên ≥ 4; Auto-archive bật |
| Hậu điều kiện thành công | Task ở `LUU_TRU`; không còn trên hôm nay; không tính khối lượng ngày |
| Hậu điều kiện thất bại | Như UC-04 (rollback cả lượt) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Đặt `archivedAt` = now, `archiveReason = stale` (BR-12) |
| 2 | Hệ thống | Gỡ timebox nếu còn; ghi nhật ký "Lưu trữ: chuyển ngày {n} ngày liên tiếp" |
| 3 | Hệ thống | Cộng `archivedCount` vào `rollover_runs` |
| 4 | Hệ thống | Lần mở app kế tiếp: toast MSG-11 có link "Xem Archive" `[giả định]` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Auto-archive tắt | Bỏ qua UC-05; task tiếp tục `DA_CHUYEN_NGAY` |
| A2 | Task đang chạy timer | Không lưu trữ ở lượt này `[giả định]`; xét lại ở lượt ngày sau |

### UC-06 Xem Archive, khôi phục và xoá tất cả

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Khôi phục: task về `KE_HOACH` hôm nay (BR-14). Xoá tất cả: mọi task Archive ở `DA_XOA` (BR-15). Toggle: cài đặt Auto-archive lưu |
| Hậu điều kiện thất bại | Archive không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Panel phải → Archive (Shift+A, G04) |
| 2 | Hệ thống | Gọi \[ArchiveList\]; mở **SCR-05**, mới lưu trữ nhất trước |
| 3 | Người dùng | Bấm "Khôi phục" trên một dòng |
| 4 | Hệ thống | Gọi \[TaskRestore\] `{from: archive}`; áp BR-14; task hiện đầu hôm nay; toast MSG-14 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Xoá tất cả" | Mở **SCR-06** (MSG-15) → xác nhận → \[ArchiveDeleteAll\]; toast MSG-16 có Hoàn tác |
| A2 | Bật / tắt "Auto-archive" | \[SettingsUpdate\] `autoArchive` (G01); áp từ lượt rollover kế tiếp |
| A3 | Kéo task từ Archive vào cột ngày D | \[TaskRestore\] rồi `startDate` = D |
| A4 | Archive rỗng | Empty state MSG-19 |
| A5 | Cuộn hết trang | Tải tiếp theo cursor, 50 dòng / lần |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Task đã bị xoá ở thiết bị khác | MSG-20, gỡ dòng |
| E2 | \[TaskRestore\] / \[ArchiveDeleteAll\] lỗi | Archive giữ nguyên, MSG-17 |
| E3 | Workspace chỉ đọc | Chỉ xem; "Khôi phục", "Xoá tất cả" disabled, MSG-18 |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Sidebar "Backlog" / phím B | ✓ | ✓ | Mở SCR-01 |
| Phím Z / Shift+Z trên task | ✓ | – | UC-01 |
| Menu Ngày bắt đầu → "Chuyển vào backlog", "Lên đầu backlog" | ✓ | ✓ | SCR-03 |
| Kéo task vào panel Backlog (panel phải) | ✓ | – | UC-01 A2 |
| Panel phải → Archive / Shift+A | ✓ | ✓ | Mở SCR-05 |
| Toast MSG-11 → "Xem Archive" | ✓ | ✓ | Mở SCR-05 |
| Command menu Ctrl/Cmd+K | ✓ | – | "Chuyển vào backlog", "Mở Backlog", "Mở Archive" |

## 7. Mô tả màn hình

### SCR-01 Trang Backlog

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Thêm task" | Button + ô soạn | UC-02 A3 |
| 2 | Nút nhóm theo channel (#) | Toggle | UC-02 A1 |
| 3 | Nút biểu đồ | Icon | UC-02 A7 |
| 4 | "Thêm folder" | Button | Mở SCR-04 |
| 5 | Bucket | Section thu gọn được | Tiêu đề (Tuần tới / Tháng tới / Quý tới / Năm tới / Một ngày nào đó / Không bao giờ), số task, tổng thời lượng; rỗng → MSG-04 |
| 6 | Folder | Nhóm trong danh sách | Tên, số task; menu Đổi tên / Xoá |
| 7 | Task card | Card (G02 SCR-02) | Kéo thả giữa bucket / folder / panel ngày; không có giờ projection |
| 8 | Panel ngày | Cột ngày (G04) | Mặc định hôm nay, ‹ › đổi ngày; thả task → UC-03 |

### SCR-02 Menu chọn bucket (phím Z)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | 6 mục bucket | Menu item | Có phím 1, 2, 3, 4, 5, 0 bên phải; bucket hiện tại có ✓ |
| 2 | Điều hướng | Bàn phím | ↑ ↓ chọn, Enter xác nhận, Esc đóng |

### SCR-03 Menu Ngày bắt đầu (phần G06)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Hoãn 1 ngày (D), Hoãn 1 tuần | Menu item | G04 |
| 2 | Chuyển vào backlog (Z) | Menu item | Mở SCR-02 |
| 3 | Lên đầu backlog (Shift+Z) | Menu item | UC-01 A1 |
| 4 | Lịch chọn ngày | Calendar | UC-03 A2 |

### SCR-04 Tạo / sửa folder

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tên folder | Text | Có | 1–50 ký tự → MSG-05; trùng → MSG-06; quá 50 folder → MSG-07 |
| 2 | "Lưu" / Enter | Action | – | \[BacklogFolderCreate\] / \[BacklogFolderUpdate\] |
| 3 | "Xoá folder" | Button (nguy hiểm) | – | Hộp MSG-08 → \[BacklogFolderDelete\] |

### SCR-05 Panel Archive

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề + mô tả | Header | "Archive" · MSG-12 |
| 2 | "Auto-archive" | Toggle | UC-06 A2 |
| 3 | "Xoá tất cả" | Button (nguy hiểm) | Mở SCR-06; disabled khi rỗng |
| 4 | Danh sách task | List | Mỗi dòng: tiêu đề, #channel, thời lượng, ngày lưu trữ, nhãn lý do (MSG-12 / MSG-13) |
| 5 | "Khôi phục" | Button (theo dòng) | UC-06 bước 3 |
| 6 | Trạng thái rỗng | Empty state | MSG-19 |

### SCR-06 Xác nhận "Xoá tất cả"

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-15 |
| 2 | "Xoá tất cả" | Button (nguy hiểm) | \[ArchiveDeleteAll\] |
| 3 | "Huỷ" | Button | Đóng |

### SCR-07 Dấu chuyển ngày trên task card

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Dấu chuyển ngày | Icon + số | Hiện khi `rolloverCount` ≥ 1; tooltip MSG-09 |
| 2 | Màu | Trạng thái | `rolloverCount` = 3 đổi màu cảnh báo (lượt sau sẽ lưu trữ nếu bật) `[giả định]` |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[BacklogList\] `GET /tasks/backlog` | bucket, folderId, channelId, cursor, limit ≤ 200 | Task[] (theo bucket), totals {bucket: count, plannedMin}, nextCursor | 5s / 1 lần |
| \[TaskMove\] `POST /tasks/{id}/move` | `{backlogBucket, folderId?, position?: top}` \| `{startDate, afterId?, beforeId?}`, Idempotency-Key | Task, undoToken | 5s / retry 2 lần cùng key |
| \[BacklogFolderList\] `GET /backlog-folders` | – | Folder[] | 5s / 1 lần |
| \[BacklogFolderCreate\] / \[BacklogFolderUpdate\] / \[BacklogFolderDelete\] `POST / PATCH / DELETE /backlog-folders` | name, position | Folder | 5s / 1 lần |
| \[TaskCreate\] `POST /tasks` (G02) | title, backlogBucket, folderId, … | Task | Theo G02 |
| \[ArchiveList\] `GET /tasks/archive` | cursor, limit 50 | Task[] (archivedAt, archiveReason, rolloverCount), nextCursor | 5s / 1 lần |
| \[TaskRestore\] `POST /tasks/{id}/restore` | `{from: archive}` | Task | 5s / 2 lần |
| \[ArchiveDeleteAll\] `POST /tasks/archive/delete-all` `[giả định — chưa có trong danh sách API]` | Idempotency-Key | deletedCount, undoToken | 10s / 1 lần |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | autoArchive, rolloverPosition, keepPriorityLevels | Settings | 5s / 2 lần |
| \[Rollover\] (job nội bộ) | userId, date | rolledCount, archivedCount, skippedCount | Mỗi người dùng một giao dịch; thử lại ở lượt 15 phút sau, tối đa 3 lần |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field name (folder) | MSG-05 |
| `FOLDER_NAME_TAKEN` | MSG-06 |
| `LIMIT_FOLDERS` | MSG-07 |
| `NOT_FOUND` (task đã xoá) | MSG-20 |
| `WORKSPACE_READ_ONLY` (402) | MSG-18 |
| 5xx / timeout | MSG-17 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | {tiêu đề} đã chuyển vào {bucket} trong Backlog · Mở task · Đóng |
| MSG-02 | Toast | Đã đưa "{tiêu đề}" lên đầu Backlog · Hoàn tác |
| MSG-03 | Toast | Đã chuyển "{tiêu đề}" sang {ngày} · Hoàn tác |
| MSG-04 | Empty state | Chưa có task nào |
| MSG-05 | Inline | Tên folder từ 1 đến 50 ký tự |
| MSG-06 | Inline | Folder này đã tồn tại |
| MSG-07 | Inline | Bạn đã có tối đa {max} folder |
| MSG-08 | Dialog | Xoá folder "{tên}"? {n} task trong folder vẫn ở lại Backlog |
| MSG-09 | Tooltip | Chuyển từ {ngày} · {n} ngày liên tiếp |
| MSG-10 | – | (dự phòng) |
| MSG-11 | Toast | Đã lưu trữ {n} task bị chuyển ngày từ 4 ngày trở lên · Xem Archive |
| MSG-12 | Header / nhãn | Task đã chuyển ngày ít nhất 4 ngày liên tiếp |
| MSG-13 | Nhãn | Bị bỏ qua · đã có lần lặp hôm nay |
| MSG-14 | Toast | Đã khôi phục "{tiêu đề}" về hôm nay · Hoàn tác |
| MSG-15 | Dialog | Xoá tất cả {n} task trong Archive? Task sẽ nằm trong Thùng rác 30 ngày |
| MSG-16 | Toast | Đã chuyển {n} task vào Thùng rác · Hoàn tác |
| MSG-17 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-18 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-19 | Empty state | Không có task nào được lưu trữ |
| MSG-20 | Toast | Task này không còn tồn tại |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Z / Shift+Z ẩn task ≤ 100 ms (lạc quan); \[TaskMove\] p95 ≤ 300 ms; SCR-01 tải ≤ 500 ms với 1.000 task backlog (danh sách ảo hoá) |
| Job rollover | Task chuyển xong ≤ 15 phút sau `day_start_time` (p95); một người dùng ≤ 500 ms với 200 task |
| Toàn vẹn | `UNIQUE(user_id, date)` trên `rollover_runs`; một giao dịch / người dùng; chạy lại không chuyển hai lần (BR-13) |
| Offline | Backlog lưu trong IndexedDB; chuyển vào / ra backlog chạy được khi mất mạng; rollover tạm trên máy khi offline, server là chuẩn |
| Đồng bộ | Kết quả rollover và thay đổi backlog hiện trên thiết bị khác ≤ 5 giây |
| Bảo mật | Chỉ chủ task xem / sửa backlog, Archive; job chỉ xử lý task của đúng người dùng trong lượt |
| Log / audit | \[ActivityLog\] theo BR-16; log job: người dùng, ngày, số chuyển / lưu trữ / bỏ qua, thời gian chạy; không chứa tiêu đề |
| Giám sát | Cảnh báo khi lượt `LOI` > 0,1% / giờ hoặc có người dùng quá mốc 30 phút chưa `XONG` |
| Tracking | Sự kiện: `backlog_opened`, `task_moved_to_backlog` (bucket, nguồn: Z / Shift+Z / menu / kéo), `task_moved_from_backlog`, `backlog_folder_created`, `rollover_completed` (rolled, archived, skipped), `archive_opened`, `task_restored_from_archive`, `archive_deleted_all`, `auto_archive_toggled` |
| Accessibility | Mọi kéo thả có cách bằng phím / menu (Z, S, menu Ngày bắt đầu); dấu chuyển ngày có nhãn "Đã chuyển ngày {n} lần"; tương phản WCAG 2.1 AA ở cả giao diện sáng / tối |
