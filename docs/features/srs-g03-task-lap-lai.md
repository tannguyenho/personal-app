> **Mã:** PLN-SRS-G03-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g03-task-lap-lai.md

# UC-G03 - Task lặp lại trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả series lặp: bật lặp, sinh instance, sửa instance, sửa / dừng series, quy tắc instance bị bỏ lỡ. Mô hình task và thao tác task thường (G02), board và projection (G04), timebox và lập lịch cứng (G05), rollover và Archive (G06) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng biến task thành series lặp trong vài giây; instance có sẵn 60 ngày tới; sửa một instance không hỏi phạm vi; thao tác cả series qua một menu; không có hai instance cùng series do hệ thống đặt trong một ngày |
| Actor | Người dùng đã đăng nhập · Hệ thống (job `recurrence.generate`, job `rollover` của G06) |
| Phạm vi | Picker lặp (6 quy tắc, khoảng lặp, giờ "khoảng"), tạo series, sinh instance, banner series, Trước / Sau, menu "Sửa series" (6 thao tác), danh sách series, quy tắc instance bị bỏ qua |
| Ngoài phạm vi | Rollover và Archive (G06), projection (G04), timebox và lập lịch cứng (G05), ngày kết thúc series, lặp theo ngày hoàn thành, objective (G09), giao task (G12) |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Đặt task lặp theo ngày, ngày làm việc, tuần, tháng, năm | Không tạo lại việc định kỳ bằng tay |
| US-02 | Người dùng | Thấy instance trên các ngày tới | Plan ngày / tuần đủ việc, thấy khối lượng |
| US-03 | Người dùng | Sửa riêng một lần mà không bị hỏi | Thao tác nhanh, không làm hỏng các lần khác |
| US-04 | Người dùng | Đổi tần suất, đặt giờ cho cả series | Điều chỉnh khi nhịp làm việc thay đổi |
| US-05 | Người dùng | Áp nội dung một lần cho mọi lần chưa xong | Cập nhật checklist, notes một lần cho tất cả |
| US-06 | Người dùng | Dừng lặp hoặc xoá mọi lần chưa xong | Kết thúc việc định kỳ gọn gàng |
| US-07 | Người dùng | Không thấy hai bản cùng một việc hôm nay | Danh sách hôm nay đúng thực tế |
| US-08 | Người dùng thành thạo | Xem và quản lý mọi task lặp ở một chỗ | Dọn series cũ nhanh |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Quy tắc lặp.** `DAILY`, `WEEKDAYS`, `WEEKLY` (1–7 thứ), `MONTHLY_DAY` (ngày 1–31), `MONTHLY_NTH` (thứ 1–4 / cuối cùng `[giả định]` + thứ trong tuần), `YEARLY` (ngày / tháng). Khoảng lặp `interval` 1–99 (trừ `WEEKDAYS`). Giới hạn lấy từ \[AppConfig\] |
| BR-02 | **Bật lặp.** Tạo Series với `anchorDate` = `startDate` của task; task trở thành instance đầu (`seriesDate = anchorDate`), giữ nguyên ngày. Task không có ngày (backlog) → `startDate` = hôm nay `[giả định]`. Task đã thuộc series đang lặp → mở "Đổi tần suất" thay vì tạo series mới |
| BR-03 | **Tính ngày.** Ngày khớp quy tắc tính từ `anchorDate` theo lịch của timezone người dùng, chỉ theo ngày (không giờ). `MONTHLY_DAY` 29–31 → ngày cuối tháng ở tháng ngắn hơn, tháng sau dùng lại ngày gốc. `YEARLY` 29/2 → 28/2 năm không nhuận. Tuần bắt đầu Thứ Hai |
| BR-04 | **Sinh instance.** Job `recurrence.generate` sinh mọi ngày khớp quy tắc trong khoảng (`generatedUntil`, hôm nay + 60 ngày]; khoá duy nhất `UNIQUE(series_id, series_date)` tính cả instance đã xoá / lưu trữ; job idempotent. Ngày đã có instance (kể cả đã xoá) không sinh lại |
| BR-05 | **Trường sao chép.** Instance mới lấy từ mẫu của series: tiêu đề, notes, channel, `plannedMin`, `approxTime`; priority và subtask (chưa xong) `[giả định]`. Không sao chép comment, objective, timebox, thời gian thực tế, nhật ký. Mẫu = ảnh chụp task lúc bật lặp, chỉ đổi qua BR-08 (c) |
| BR-06 | **Giờ.** Instance không cố định giờ, hiện projection (G04). `approxTime` hiện trên card. Bật "Lập lịch cứng cho task lặp" (cài đặt Timebox, G05) và series có `approxTime` → G05 tạo timebox tại giờ đó |
| BR-07 | **Sửa một instance** chỉ đổi instance đó, không hỏi phạm vi, không đổi mẫu. Dời ngày instance giữ `seriesDate` gốc. Hoàn thành / xoá instance theo G02, không ảnh hưởng instance khác. Xoá instance đầu không dừng series |
| BR-08 | **Sửa series** (menu "Sửa series"): (a) **Dừng lặp**: `stoppedAt` = now, không sinh thêm; instance chưa xong có `startDate` > hôm nay → xoá mềm `[giả định]`. (b) **Đổi tần suất**: cập nhật quy tắc; instance chưa xong có `startDate` > hôm nay mà không khớp quy tắc mới → xoá mềm, sinh ngày mới; instance hôm nay, quá khứ, đã xong giữ nguyên (EC-29). (c) **Cập nhật mọi instance chưa xong theo task này**: chép trường BR-05 của instance đang mở vào mẫu và mọi instance chưa xong. (d) **Xoá mọi instance chưa xong và dừng lặp**: xoá mềm mọi instance chưa xong (kể cả quá khứ), dừng series; cần xác nhận `[giả định]`. (e) **Đặt giờ bắt đầu**: đặt / xoá `approxTime` cho mẫu và instance chưa xong từ hôm nay. (f) **Quản lý mọi task lặp**: mở SCR-05 |
| BR-09 | Mọi thao tác BR-08 (a)–(e) có Hoàn tác trong toast ≥ 5 giây; Hoàn tác trả quy tắc, mẫu và các instance bị ảnh hưởng về như trước |
| BR-10 | **Instance bị bỏ lỡ** (G06 thực thi khi rollover): instance chưa xong có `startDate` < hôm nay; series đã có instance `startDate` = hôm nay → không rollover, `archivedAt` = now, `archiveReason = skipped` (nhãn "bị bỏ qua", EC-30). Series chưa có instance hôm nay → chỉ instance cũ mới nhất rollover; instance cũ hơn → `skipped` `[giả định]` |
| BR-11 | "Hôm nay" tính theo `day_start_time` (04:00 `[giả định]`) và timezone người dùng. Đổi timezone không đổi `seriesDate` đã sinh |
| BR-12 | Tối đa 200 series `DANG_LAP` / người dùng `[giả định]`. Series đã dừng không bật lại; bật Lặp lại trên một instance của series đã dừng → tạo series mới từ instance đó |
| BR-13 | Nhật ký (\[ActivityLog\], G02): bật lặp, đổi quy tắc, áp mẫu, dừng ghi trên instance thực hiện; instance do job sinh ghi tác nhân `system` "Tạo từ series {tiêu đề}" |
| BR-14 | Series thuộc người dùng tạo; chỉ người đó xem và sửa (đến khi có workspace nhiều thành viên, G12) |

## 4. Trạng thái

### 4.1. Trạng thái series

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_LAP` | `stoppedAt` trống | Banner "Task này lặp lại {quy tắc}"; biểu tượng lặp trên card; job sinh instance |
| `DA_DUNG` | `stoppedAt` có giá trị | Banner "Series đã dừng lặp" trên instance còn lại; trong SCR-05 ở bộ lọc "Đã dừng"; job bỏ qua |

Chuyển trạng thái: `DANG_LAP` → `DA_DUNG` (UC-05, BR-08 a, d). `DA_DUNG` → `DANG_LAP` chỉ qua Hoàn tác trong toast; sau đó không bật lại (BR-12). Đổi tần suất, áp mẫu, đặt giờ không đổi trạng thái series.

### 4.2. Trạng thái instance

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `KE_HOACH` | Chưa xong, chưa lưu trữ, chưa xoá | Card trên cột `startDate`, giờ projection hoặc `approxTime`, biểu tượng lặp |
| `HOAN_THANH` | `completedAt` có giá trị | Như task xong (G02); không bị BR-08 thay đổi |
| `BI_BO_QUA` | `archivedAt` có giá trị, `archiveReason = skipped` | Chỉ trong Archive (G06), nhãn "bị bỏ qua" |
| `DA_XOA` | `deletedAt` có giá trị | Thùng rác (G02); `seriesDate` vẫn chiếm chỗ, không sinh lại |

Instance dùng chung vòng đời task của G02; `BI_BO_QUA` là `LUU_TRU` của G02 / G06 với lý do `skipped`.

## 5. Use Case

### UC-01 Bật lặp cho task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; task không ở `DA_XOA`; task chưa thuộc series `DANG_LAP`; workspace không chỉ đọc (G12) |
| Hậu điều kiện thành công | Series `DANG_LAP` được tạo; task là instance đầu; instance 60 ngày tới đã sinh (UC-02) |
| Hậu điều kiện thất bại | Không có series; task không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … của task (card / chi tiết, SCR-04 của G02) → "Lặp lại" |
| 2 | Hệ thống | Mở **SCR-01**, điền mặc định từ `startDate` (BR-03): thứ, ngày trong tháng, "thứ N" |
| 3 | Người dùng | Chọn quy tắc, thứ, khoảng lặp, (tuỳ chọn) giờ "khoảng"; bấm "Lưu" |
| 4 | Hệ thống | Kiểm tra BR-01; gọi \[SeriesCreate\] (idempotency key) |
| 5 | Hệ thống | Server tạo series (BR-02), gọi sinh instance đồng bộ cho 14 ngày đầu `[giả định]`, phần còn lại do job (UC-02) |
| 6 | Hệ thống | Đóng SCR-01; toast MSG-01; card task có biểu tượng lặp; instance mới hiện trên board qua realtime |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Task trong backlog | Instance đầu đặt hôm nay (BR-02); MSG-01 nêu ngày |
| A2 | Chọn `MONTHLY_DAY` 29–31 hoặc `YEARLY` 29/2 | Hiện ghi chú MSG-04 / MSG-05 dưới ô ngày, vẫn cho lưu |
| A3 | Task đã thuộc series `DANG_LAP` | Mục "Lặp lại" mở SCR-01 ở chế độ "Đổi tần suất" (UC-04) |
| A4 | Task thuộc series `DA_DUNG` | Tạo series mới từ task này (BR-12) |
| A5 | Bấm ra ngoài / Esc | Đóng SCR-01, không lưu |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | `interval` ngoài 1–99 | MSG-02 tại ô, nút Lưu disabled |
| E2 | `WEEKLY` không chọn thứ nào | MSG-03, nút Lưu disabled |
| E3 | Đã có 200 series đang lặp | MSG-14 có link "Quản lý mọi task lặp" |
| E4 | Mất mạng | Lưu vào hàng đợi; card có biểu tượng "chờ đồng bộ"; instance chỉ hiện khi server sinh xong |
| E5 | \[SeriesCreate\] lỗi 5xx / timeout | MSG-12 có "Thử lại"; task không đổi |
| E6 | Workspace chỉ đọc | MSG-13, không tạo |

### UC-02 Sinh instance (job `recurrence.generate`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có series `DANG_LAP` với `generatedUntil` < hôm nay + 60 ngày |
| Hậu điều kiện thành công | Mọi ngày khớp quy tắc tới hôm nay + 60 ngày có đúng một instance; `generatedUntil` cập nhật |
| Hậu điều kiện thất bại | Series giữ `generatedUntil` cũ; lần chạy sau sinh bù |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job chạy mỗi giờ `[giả định]`, chọn series `DANG_LAP` của người dùng vừa qua `day_start_time` hoặc có `generatedUntil` < hôm nay + 60 ngày; cũng chạy ngay sau UC-01, UC-04 |
| 2 | Hệ thống | Tính danh sách ngày khớp quy tắc trong (`generatedUntil`, hôm nay + 60] theo BR-03 |
| 3 | Hệ thống | Với mỗi ngày: chèn instance theo mẫu (BR-05), `startDate = seriesDate`, không timebox; xung đột khoá duy nhất → bỏ qua (BR-04) |
| 4 | Hệ thống | Cập nhật `generatedUntil`; ghi nhật ký `system` (BR-13) |
| 5 | Hệ thống | Phát `task.upserted` cho từng instance và `day.recomputed` cho các ngày bị ảnh hưởng (G04) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bật lập lịch cứng và có `approxTime` | Sau bước 3, gửi yêu cầu tạo timebox cho G05 (BR-06) |
| A2 | Job không chạy nhiều ngày (sự cố) | Lần chạy sau sinh bù toàn bộ khoảng còn thiếu; ngày trong quá khứ không sinh `[giả định]` |
| A3 | `YEARLY` / interval lớn, không có ngày nào trong khoảng | Chỉ cập nhật `generatedUntil` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi CSDL giữa chừng | Mỗi series một giao dịch; rollback series đó, thử lại 3 lần backoff 1–5–15 phút `[giả định]`; quá 3 lần ghi log cảnh báo |
| E2 | Channel trong mẫu đã bị xoá | Dùng channel mặc định (G02 BR-05), cập nhật mẫu, ghi nhật ký |

### UC-03 Xem và sửa một instance

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Instance tồn tại, không ở `DA_XOA` |
| Hậu điều kiện thành công | Trường đã sửa chỉ thay đổi trên instance này (BR-07) |
| Hậu điều kiện thất bại | Trường giữ giá trị cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Mở chi tiết instance (G02 UC-02) |
| 2 | Hệ thống | \[TaskDetail\] trả kèm `series` (quy tắc, vị trí, `prevTaskId`, `nextTaskId`, `nextDate`); hiện **SCR-02** đầu chi tiết |
| 3 | Người dùng | Sửa trường bất kỳ, hoàn thành hoặc xoá |
| 4 | Hệ thống | Gọi API của G02 cho riêng instance; không hỏi phạm vi; mẫu series không đổi |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Trước" / "Sau" | Mở chi tiết instance liền kề; instance đầu → "Trước" disabled |
| A2 | Lần kế tiếp chưa được sinh (ngoài 60 ngày) | "Sau" disabled, tooltip MSG-20 |
| A3 | Bấm "Sửa series" | Mở **SCR-03** (UC-04, UC-05) |
| A4 | Dời instance sang ngày khác | Theo G04; giữ `seriesDate` (BR-07) |
| A5 | Series `DA_DUNG` | Banner MSG-15; không có Trước / Sau tới instance đã xoá |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi khi lưu | Như G02 UC-02 E4 (MSG-12) |
| E2 | Instance liền kề đã bị xoá khi bấm Trước / Sau | Bỏ qua, mở instance kế tiếp còn tồn tại |

### UC-04 Sửa series: đổi tần suất, đặt giờ, áp nội dung

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Series `DANG_LAP`; người dùng đang mở một instance |
| Hậu điều kiện thành công | Quy tắc / giờ / mẫu cập nhật; instance chưa xong bị ảnh hưởng cập nhật theo BR-08 (b), (c), (e) |
| Hậu điều kiện thất bại | Series và instance không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Banner → "Sửa series" → **SCR-03** → "Đổi tần suất" |
| 2 | Hệ thống | Mở SCR-01 với quy tắc hiện tại |
| 3 | Người dùng | Đổi quy tắc, bấm "Lưu" |
| 4 | Hệ thống | Gọi \[SeriesUpdate\] với `If-Match` version; server áp BR-08 (b) trong một giao dịch, rồi chạy UC-02 |
| 5 | Hệ thống | Toast MSG-07 với số instance thay đổi, có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Cập nhật mọi instance chưa xong theo task này" | Gọi \[SeriesApplyFrom\] với id instance đang mở; áp BR-08 (c); toast MSG-08 |
| A2 | "Đặt giờ bắt đầu" | Mở chọn giờ (bước 15 phút) + "Xoá giờ"; \[SeriesUpdate\] `approxTime`; áp BR-08 (e); toast MSG-18 |
| A3 | Bấm Hoàn tác | Gọi \[SeriesUpdate\] / \[SeriesApplyFrom\] với `undoToken`; khôi phục theo BR-09 |
| A4 | Quy tắc mới giống quy tắc cũ | Đóng SCR-01, không gọi API |
| A5 | Có instance quá khứ đã xong (EC-29) | Giữ nguyên; chỉ instance chưa xong sau hôm nay bị ảnh hưởng |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Version lệch (series vừa sửa ở thiết bị khác) | 412 → tải lại series, MSG-16, giữ SCR-01 mở với quy tắc mới nhất |
| E2 | Vi phạm BR-01 | MSG-02 / MSG-03 |
| E3 | Lỗi 5xx / timeout | MSG-12; series không đổi |

### UC-05 Dừng lặp / xoá mọi instance chưa xong

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Series `DANG_LAP` |
| Hậu điều kiện thành công | Series `DA_DUNG`; instance chưa xong bị xoá mềm theo BR-08 (a) hoặc (d) |
| Hậu điều kiện thất bại | Series `DANG_LAP`, instance không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-03 → "Dừng lặp" |
| 2 | Hệ thống | Gọi \[SeriesStop\]; server đặt `stoppedAt`, xoá mềm instance chưa xong có `startDate` > hôm nay |
| 3 | Hệ thống | Gỡ instance khỏi board; G05 xoá timebox của instance bị xoá; toast MSG-09 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Xoá mọi instance chưa xong và dừng lặp" | Mở **SCR-04** (MSG-10, số instance) → "Xoá và dừng" → \[SeriesStop\] `deleteIncomplete=true`; toast MSG-11 có Hoàn tác |
| A2 | Instance đang chạy timer bị xoá | Dừng timer, lưu thời gian trước khi xoá (G07) |
| A3 | Bấm Hoàn tác | Khôi phục các instance và đặt lại series `DANG_LAP` (BR-09) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Series đã dừng ở thiết bị khác | 409 `SERIES_STOPPED` → MSG-15, làm mới |
| E2 | Lỗi 5xx / timeout | MSG-12; không xoá instance nào |

### UC-06 Xử lý instance bị bỏ lỡ (trong job `rollover`, G06)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng vừa qua `day_start_time`; có instance chưa xong với `startDate` < hôm nay |
| Hậu điều kiện thành công | Mỗi series có tối đa một instance chưa xong trên ngày hôm nay do hệ thống đặt; instance thừa ở `BI_BO_QUA` |
| Hậu điều kiện thất bại | Instance giữ nguyên; lần chạy sau xử lý lại (idempotent, G06) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job `rollover` (G06) nhóm instance chưa xong quá khứ theo `seriesId` |
| 2 | Hệ thống | Series đã có instance `startDate` = hôm nay → mọi instance quá khứ: `archivedAt`, `archiveReason = skipped` (BR-10) |
| 3 | Hệ thống | Ghi nhật ký `system` "Bị bỏ qua vì đã có lần lặp hôm nay"; phát `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Series chưa có instance hôm nay | Instance quá khứ mới nhất rollover theo G06; instance cũ hơn → `skipped` |
| A2 | Series `DA_DUNG` | Không áp BR-10; instance rollover như task thường (G06) |
| A3 | Người dùng khôi phục instance `skipped` từ Archive | Theo G06; được phép có hai instance cùng ngày vì người dùng chủ động |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi giữa chừng | Rollback theo người dùng; G06 thử lại ở lượt 15 phút sau |

### UC-07 Quản lý mọi task lặp

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Danh sách series hiển thị; thao tác chọn được thực hiện qua UC-04 / UC-05 |
| Hậu điều kiện thất bại | Hiện lỗi tải, giữ dữ liệu lần cuối |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-03 → "Quản lý mọi task lặp" hoặc Cài đặt → "Task lặp lại" |
| 2 | Hệ thống | Gọi \[SeriesList\] (`status=active` mặc định); mở **SCR-05** |
| 3 | Người dùng | Chọn một dòng: "Mở lần kế tiếp", "Đổi tần suất" hoặc "Dừng lặp" |
| 4 | Hệ thống | Chuyển sang UC-03 / UC-04 / UC-05 tương ứng |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Lọc "Đã dừng" | \[SeriesList\] `status=stopped`; chỉ có "Mở instance cuối" |
| A2 | Không có series | Empty state MSG-19 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[SeriesList\] lỗi | MSG-12 có "Thử lại" |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Menu … của task → "Lặp lại" | ✓ | ✓ | Mở SCR-01 (UC-01, hoặc UC-04 nếu đã lặp) |
| Command menu Ctrl/Cmd+K → "Lặp lại" | ✓ | – | Task đang chọn / hover |
| Banner series → "Sửa series" | ✓ | ✓ | Mở SCR-03 |
| Banner series → Trước / Sau | ✓ | ✓ | UC-03 A1 |
| Cài đặt → "Task lặp lại" | ✓ | ✓ | Mở SCR-05 |

## 7. Mô tả màn hình

### SCR-01 Picker lặp lại

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Lặp | Dropdown | Có | Hằng ngày · Ngày làm việc (T2–T6) · Hằng tuần · Hằng tháng vào ngày {D} · Hằng tháng vào {thứ N} {thứ} · Hằng năm vào {ngày/tháng} |
| 2 | Vào (thứ) | Nhóm 7 nút T2…CN | Có khi Hằng tuần | Mặc định thứ của `startDate`; bỏ hết → MSG-03 |
| 3 | Mỗi N | Số + đơn vị | Có (trừ Ngày làm việc) | 1–99; sai → MSG-02 |
| 4 | Vào khoảng | Time picker | Không | Bước 15 phút; có "Không đặt giờ" |
| 5 | Ghi chú ngày đặc biệt | Hint | – | MSG-04 / MSG-05 khi chọn 29–31 hoặc 29/2 |
| 6 | Mô tả quy tắc | Text | – | Câu đọc được, ví dụ "Mỗi 2 tuần vào Thứ Ba, Thứ Năm" |
| 7 | "Lưu" | Button | – | Disabled khi vi phạm BR-01 |

### SCR-02 Banner series (đầu chi tiết instance)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Mô tả | Text | MSG-06; series dừng → MSG-15 |
| 2 | "Sửa series" | Link | Mở SCR-03; ẩn khi series `DA_DUNG` |
| 3 | "Trước" / "Sau" | Button | UC-03 A1, A2 |

### SCR-03 Menu "Sửa series"

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Dừng lặp | Menu item | UC-05 |
| 2 | Đổi tần suất | Menu item | UC-04 |
| 3 | Cập nhật mọi instance chưa xong theo task này | Menu item | UC-04 A1 |
| 4 | Xoá mọi instance chưa xong và dừng lặp | Menu item (nguy hiểm) | UC-05 A1, mở SCR-04 |
| 5 | Đặt giờ bắt đầu | Menu item | UC-04 A2 |
| 6 | Quản lý mọi task lặp | Menu item | UC-07 |

### SCR-04 Xác nhận xoá instance chưa xong

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-10 |
| 2 | "Xoá và dừng lặp" | Button (nguy hiểm) | \[SeriesStop\] `deleteIncomplete=true` |
| 3 | "Huỷ" | Button | Đóng, không thay đổi |

### SCR-05 Quản lý mọi task lặp

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Bộ lọc | Tabs | "Đang lặp" (mặc định) / "Đã dừng" |
| 2 | Danh sách series | List | Mỗi dòng: tiêu đề, mô tả quy tắc, giờ "khoảng", #channel, lần kế tiếp; sắp theo lần kế tiếp |
| 3 | Thao tác dòng | Menu | Mở lần kế tiếp · Đổi tần suất · Dừng lặp |
| 4 | Trạng thái rỗng | Empty state | MSG-19 |

### SCR-06 Dấu lặp trên task card

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Biểu tượng lặp | Icon | Hiện trên card instance; tooltip mô tả quy tắc |
| 2 | Giờ | Text | `approxTime` nếu có, ngược lại giờ projection (G04) |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[SeriesCreate\] `POST /tasks/{id}/repeat` | rule {type, interval, weekdays[], monthDay, nth, weekday, month}, approxTime, Idempotency-Key | Series, Task (instance đầu), instances 14 ngày đầu | 5s / retry 3 lần cùng key |
| \[SeriesUpdate\] `PATCH /series/{id}` | rule và / hoặc approxTime, If-Match | Series, version, affectedCount, undoToken | 5s / 2 lần |
| \[SeriesApplyFrom\] `POST /series/{id}/apply-from/{taskId}` | Idempotency-Key | affectedCount, undoToken | 5s / 2 lần cùng key |
| \[SeriesStop\] `POST /series/{id}/stop` | `?deleteIncomplete=true` (tuỳ chọn) | Series (stoppedAt), deletedCount, undoToken | 5s / 2 lần |
| \[SeriesList\] `GET /series` | status, cursor, limit ≤ 200 | Series[] (rule, approxTime, channel, nextDate), nextCursor | 5s / 1 lần |
| \[TaskDetail\] `GET /tasks/{id}` (G02) | id | Task + `series` {id, ruleText, index, prevTaskId, nextTaskId, nextDate, status} | 5s / 1 lần |
| \[RecurrenceGenerate\] (job nội bộ) | seriesId[] hoặc userId | createdCount, generatedUntil | Mỗi series một giao dịch; 3 lần backoff 1–5–15 phút |
| \[AppConfig\] | – | Giới hạn BR-01, BR-12, khoảng sinh 60 ngày | Cache 1h |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field interval | MSG-02 |
| `VALIDATION_FAILED` · field weekdays · EMPTY | MSG-03 |
| `LIMIT_SERIES` | MSG-14 |
| `SERIES_STOPPED` (409) | MSG-15 |
| `VERSION_CONFLICT` (412) | MSG-16 |
| `NOT_FOUND` (task / series đã xoá) | MSG-17 |
| `WORKSPACE_READ_ONLY` (402) | MSG-13 |
| 5xx / timeout | MSG-12 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | Task giờ sẽ lặp lại {mô tả quy tắc}, bắt đầu từ {ngày} |
| MSG-02 | Inline | Khoảng lặp từ 1 đến 99 |
| MSG-03 | Inline | Chọn ít nhất một thứ trong tuần |
| MSG-04 | Hint | Tháng không có ngày {D} sẽ dùng ngày cuối tháng |
| MSG-05 | Hint | Năm không nhuận sẽ dùng ngày 28/2 |
| MSG-06 | Banner | Task này lặp lại {mô tả quy tắc}. Đây là lần {thứ n} của series |
| MSG-07 | Toast | Đã đổi tần suất, {n} lần sắp tới được cập nhật · Hoàn tác |
| MSG-08 | Toast | Đã cập nhật {n} lần chưa xong theo task này · Hoàn tác |
| MSG-09 | Toast | Đã dừng lặp "{tiêu đề}" · Hoàn tác |
| MSG-10 | Dialog | Xoá {n} lần chưa xong của "{tiêu đề}" và dừng lặp? Các lần đã xong được giữ lại. Task xoá nằm trong Thùng rác 30 ngày |
| MSG-11 | Toast | Đã xoá {n} lần và dừng lặp · Hoàn tác |
| MSG-12 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-13 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-14 | Inline | Bạn đã có {n} task lặp đang chạy, tối đa {max}. Dừng bớt trong "Quản lý mọi task lặp" |
| MSG-15 | Banner | Series này đã dừng lặp |
| MSG-16 | Toast | Series vừa được sửa trên thiết bị khác, đã tải lại |
| MSG-17 | Toast | Task hoặc series này không còn tồn tại |
| MSG-18 | Toast | Đã đặt giờ {giờ} cho các lần chưa xong · Hoàn tác |
| MSG-19 | Empty state | Chưa có task lặp lại nào. Mở menu … của một task → "Lặp lại" để bắt đầu |
| MSG-20 | Tooltip | Lần kế tiếp: {ngày} |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | \[SeriesCreate\] p95 ≤ 500 ms (gồm sinh 14 ngày đầu); instance 60 ngày hiện đủ trên board ≤ 5 giây; job sinh ≤ 50 ms / series |
| Toàn vẹn | `UNIQUE(series_id, series_date)`; job idempotent, chạy lại không tạo trùng; thao tác series trong một giao dịch |
| Offline | Bật lặp, sửa instance chạy được khi mất mạng (hàng đợi); thao tác series (BR-08) cần mạng, nút disabled kèm tooltip khi offline |
| Đồng bộ | Instance mới, thay đổi series hiện trên thiết bị khác ≤ 5 giây (`task.upserted`, `day.recomputed`) |
| Bảo mật | Chỉ chủ series đọc / sửa (BR-14); kiểm tra quyền trên cả series và task trong mọi API |
| Log / audit | \[ActivityLog\] theo BR-13; log job: số series, số instance tạo, lỗi; không chứa tiêu đề / notes |
| Giám sát | Cảnh báo khi tỉ lệ lỗi job > 0,1% / ngày hoặc có series `generatedUntil` < hôm nay + 53 ngày |
| Tracking | Sự kiện: `repeat_picker_opened`, `series_created` (rule type), `series_frequency_changed`, `series_applied_from_task`, `series_time_set`, `series_stopped` (deleteIncomplete), `series_instance_skipped`, `series_list_opened` |
| Accessibility | SCR-01 điều khiển hoàn toàn bằng bàn phím; nút thứ có nhãn đọc màn hình đầy đủ ("Thứ Hai"); biểu tượng lặp có nhãn "Task lặp lại: {quy tắc}" |
