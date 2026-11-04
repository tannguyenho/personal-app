> **Mã:** PLN-SRS-G06-WEB · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g06-backlog-rollover.md

# UC-G06 - Backlog, rollover & lưu trữ trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả backlog (bucket, folder, chuyển vào / ra), rollover tự động, API đảm bảo rollover và Lưu trữ (tự lưu trữ, khôi phục, xoá tất cả). Mô hình task, Thùng rác (G02), quy tắc instance lặp (G03), board, phím D và kéo thả (G04), timebox (G05), nhắc bucket trong ritual (G08, G09) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> **Quy tắc dùng chung** ([`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md)): ngày làm việc QC-01, lịch làm việc QC-02, trạng thái task và khôi phục QC-03, số ngày bị hoãn QC-04, đổi ngày task QC-05, instance trùng series QC-06, bản ghi thời gian QC-07, đồng bộ QC-08, chế độ chỉ đọc QC-09. **G06 sở hữu QC-04 và QC-05**: mọi thay đổi hai quy tắc này sửa ở `docs/01`, không sửa trong SRS này. Thuật ngữ theo [`CONTEXT.md`](../../CONTEXT.md). Chốt theo [quyết định 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng gạt việc chưa cần làm vào backlog bằng 1–2 phím; việc dở tự chuyển sang hôm nay; việc bị hoãn quá lâu hoặc bị bỏ qua được lưu trữ, khôi phục được |
| Actor | Người dùng đã đăng nhập · Hệ thống (job `rollover`, API đảm bảo rollover) · G08 (gọi API đảm bảo rollover) |
| Phạm vi | Trang / panel Backlog (6 bucket, folder, nhóm theo channel), chuyển task vào backlog (Z, Shift+Z, menu, kéo), lấy task ra ngày, rollover, đảm bảo rollover khi mở app, Auto-archive, panel Lưu trữ, khôi phục, "Xoá tất cả"; sở hữu QC-04, QC-05 |
| Ngoài phạm vi | Phím D, hoãn 1 tuần và kéo thả trên board (G04), Thùng rác (G02), sinh instance lặp và quy tắc QC-06 (G03), đồng bộ sự kiện trên lịch ngoài (G05), nhắc bucket trong ritual (G08, G09), backlog nhóm (G12, 1.1), chế độ chỉ đọc (G12, 1.1) |
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
| US-06 | Người dùng | Việc bị hoãn ≥ 4 ngày làm việc tự rời khỏi hôm nay | Hôm nay không phình mãi |
| US-07 | Người dùng | Xem và khôi phục task trong Lưu trữ, xoá tất cả khi cần | Không mất việc, dọn gọn khi muốn |
| US-08 | Người dùng thành thạo | Làm mọi thao tác trên bằng phím tắt | Không rời bàn phím |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Bucket.** 6 bucket cố định: `next_week` (Tuần tới, phím 1), `next_month` (Tháng tới, 2), `next_quarter` (Quý tới, 3), `next_year` (Năm tới, 4), `someday` (Một ngày nào đó, 5), `never` (Không bao giờ, 0). Không đổi tên, không xoá. Task `BACKLOG` có `startDate` trống và `backlogBucket` bắt buộc (bất biến cụm vị trí, QC-03 mục 2) |
| BR-02 | **Chuyển vào backlog.** `startDate` = null, `backlogBucket` = bucket chọn, vào đầu bucket `[giả định]`; giữ channel, thời lượng, subtask, notes, priority. Timebox, sự kiện trên lịch ngoài, timer: theo dòng "Đưa vào backlog" của QC-05 (timebox tương lai bị gỡ và sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết; timer không dừng). Số ngày bị hoãn reset (QC-04 mục 3). Cả cụm vị trí ghi cùng nhau (QC-08 mục 2) |
| BR-03 | **Shift+Z** đưa task lên đầu bucket `next_week`, không hỏi `[giả định]`; task đã ở backlog → lên đầu bucket hiện tại |
| BR-04 | **Folder.** Tuỳ chọn; tối đa 50 / người dùng, tên 1–50 ký tự, không trùng (không phân biệt hoa thường). Một task thuộc tối đa 1 folder và vẫn có bucket. Xoá folder → task ở lại backlog, `folderId` = null. Giới hạn lấy từ \[AppConfig\] `[giả định]` |
| BR-05 | **Lấy ra ngày.** Đặt `startDate` = D → `backlogBucket` = null, `folderId` = null; số ngày bị hoãn reset (`firstPlannedDate` = D, QC-04 mục 3); vị trí theo cài đặt "Vị trí task mới" (G02). D ≥ hôm nay; server từ chối D < hôm nay (QC-05, `PAST_DATE`). Instance lặp vào ngày đã có instance cùng series: cho phép, kèm cảnh báo MSG-21 (đường thủ công, QC-06 mục 3) |
| BR-06 | **Điều kiện rollover.** Task `KE_HOACH` (QC-03) có `startDate` < hôm nay. "Hôm nay" là ngày làm việc tính bằng `workday(t)` (QC-01) |
| BR-07 | **Rollover.** `startDate` = hôm nay; `firstPlannedDate` giữ nguyên nên số ngày bị hoãn tiếp tục đếm (QC-04 mục 2). Nhiều ngày bị lỡ gộp thành một lần chuyển, một dòng nhật ký (EC-05); số ngày bị hoãn vẫn đúng số ngày làm việc từ `firstPlannedDate`, không chỉ +1. Thứ tự: task được chuyển xếp theo ngày dự định cũ tăng dần, rồi vị trí cũ; cả khối đặt ở đầu hoặc cuối danh sách hôm nay theo cài đặt "Vị trí task rollover" (mặc định đầu), nhưng luôn sau các instance lặp của hôm nay (C16). Mỗi task bị đổi tăng `version` như thao tác người dùng (QC-08 mục 1) |
| BR-08 | **Priority khi rollover** về Normal, trừ các mức có trong tập "Giữ priority khi rollover" (cấu hình theo tập mức, C16; mặc định tập rỗng) |
| BR-09 | **Timebox khi rollover:** theo dòng "Rollover" của QC-05. Timebox quá khứ (`endsAt` ≤ thời điểm rollover) bị gỡ liên kết khỏi task, sự kiện trên lịch ngoài **giữ lại** làm lịch sử (G05 không xoá); task về projection (G04). Timebox tương lai giữ nguyên. Timer đang chạy không dừng. Bản ghi thời gian giữ ở ngày làm việc của `startedAt` (QC-07) |
| BR-10 | **Số ngày bị hoãn** (thay `rolloverCount` trong toàn bộ SRS này): định nghĩa, các đường giữ hoặc reset theo QC-04. G06 lưu `firstPlannedDate` trong cụm vị trí (QC-03 mục 2); số ngày bị hoãn là giá trị suy ra (`postponedDays`), không lưu bộ đếm riêng |
| BR-11 | **Instance lặp khi rollover** (đường tự động của QC-06, G03 định nghĩa): series đã có instance trong hôm nay (định nghĩa QC-06 mục 1) → instance quá khứ chưa xong không rollover mà chuyển `LUU_TRU`, `archiveReason = skipped`; không có toast, chỉ ghi nhật ký. Series chưa có instance hôm nay → chỉ instance quá khứ mới nhất rollover; instance cũ hơn → `skipped` (EC-30) |
| BR-12 | **Auto-archive.** Sau BR-07, nếu bật Auto-archive (mặc định bật `[giả định]`) và số ngày bị hoãn ≥ 4 `[giả định]` (QC-04 mục 5) → `LUU_TRU`, `archiveReason = stale`; timebox quá khứ gỡ liên kết theo BR-09, timebox tương lai xử lý như dòng "Đưa vào backlog" của QC-05 `[giả định — QC-05 chưa có dòng cho lưu trữ]`; không tính vào khối lượng ngày |
| BR-13 | **Idempotent.** Mỗi người dùng một bản ghi `rollover_runs(user_id, date)` UNIQUE; đã `XONG` thì bỏ qua (EC-06) |
| BR-14 | **Khôi phục từ Lưu trữ.** `archivedAt`, `archiveReason` = null; `startDate` = hôm nay; số ngày bị hoãn reset (QC-04 mục 3); vào đầu danh sách hôm nay. Kéo vào ngày D: D ≥ hôm nay (QC-05). Instance lặp vào ngày đã có instance cùng series: cho phép, cảnh báo MSG-21 (QC-06 mục 3) |
| BR-15 | **Xoá tất cả** trong Lưu trữ cần xác nhận; xoá mềm mọi task trong Lưu trữ (vào Thùng rác 30 ngày, G02, Q28); có Hoàn tác. Khôi phục từ Thùng rác đưa task về lại Lưu trữ với lý do cũ (QC-03 mục 3) |
| BR-16 | Mọi thay đổi ghi \[ActivityLog\] (G02): chuyển vào backlog / bucket, lấy ra ngày (tác nhân `user`); rollover, lưu trữ (tác nhân `system`, "Chuyển từ {ngày}", "Lưu trữ: bị hoãn {n} ngày" / "bị bỏ qua") |
| BR-17 | Phím Z, Shift+Z, B, S và phím chọn bucket chỉ hoạt động khi không có ô nhập nào đang focus; Z, Shift+Z luôn có toast Hoàn tác. Hoàn tác khôi phục cả cụm vị trí và liên kết timebox; sự kiện ngoài đã bị xoá thì được tạo lại với giờ cũ (QC-05) |
| BR-18 | **Lease và thất bại** (B6). Lượt nhận `DANG_CHAY` kèm `leaseUntil` = now + 5 phút; quá hạn mà chưa `XONG` coi như chưa chạy, lượt kế tiếp được nhận lại. Lỗi giao dịch → `LOI`, thử lại ở lượt job kế tiếp; sau 3 lần lỗi liên tiếp → `THAT_BAI`, job định kỳ ngừng thử, chờ chạy bù qua \[RolloverEnsure\] khi người dùng mở app (BR-19) |
| BR-19 | **Đảm bảo rollover** (B6, dùng chung với G08). \[RolloverEnsure\] idempotent theo người dùng + ngày: `XONG` → trả kết quả đã có; `CHO`, `LOI`, `THAT_BAI` hoặc `DANG_CHAY` hết lease → chạy UC-04 bước 2–7 ngay trong request; `DANG_CHAY` còn lease → chờ tối đa 10 giây `[giả định]` rồi trả trạng thái hiện tại; `CHO_SHUTDOWN` → không ép chạy, trả trạng thái kèm `waitUntil` (BR-20). Client gọi khi mở app lần đầu trong ngày làm việc (G04) và trước khi tải bước "Xem lại hôm qua" (G08) |
| BR-20 | **Chờ phiên shutdown** (Q18). Người dùng có phiên Daily shutdown của ngày cũ đang làm, mở trước mốc đầu ngày (G08) → lượt rollover ở `CHO_SHUTDOWN`; chạy khi phiên hoàn tất, bị bỏ dở, hoặc tới mốc đầu ngày + 2 giờ, tuỳ điều nào tới trước |
| BR-21 | **Chế độ chỉ đọc (bản 1.1, QC-09).** Workspace chỉ đọc → không chạy rollover, không tạo lượt. Khi thoát chỉ đọc: rollover chạy bù một lần; các ngày làm việc bị đóng băng không tính vào số ngày bị hoãn (QC-04 mục 6). Bản 1.0 không có chế độ chỉ đọc |
| BR-22 | **Đổi mốc đầu ngày hoặc timezone** (Q3, QC-01 mục 3): có hiệu lực từ ngày làm việc kế tiếp; ngày hiện tại kết thúc và rollover theo cài đặt cũ; không chạy lại rollover cho ngày đã có lượt `XONG` (EC-06) |

## 4. Trạng thái

### 4.1. Trạng thái task (phạm vi G06)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
Bộ trạng thái và điều kiện theo QC-03 (G02 sở hữu). G06 không thêm trạng thái riêng. Bảng dưới chỉ ghi cách G06 hiển thị.

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `BACKLOG` | Theo QC-03 | Trong bucket (và folder nếu có) trên trang Backlog |
| `KE_HOACH` | Theo QC-03 | Card trên cột ngày; số ngày bị hoãn ≥ 1 thì có nhãn "Dời {n} ngày" (SCR-07). "Đã dời" là thuộc tính suy ra, không phải trạng thái |
| `DA_CHUYEN_NGAY` | (Bỏ — xem QC-03, QC-04: thay bằng `KE_HOACH` có số ngày bị hoãn ≥ 1) | – |
| `LUU_TRU` | Theo QC-03; `archiveReason` ∈ {`stale`, `skipped`, `manual`} | Chỉ trong Lưu trữ, nhãn theo lý do: `stale` MSG-12, `skipped` MSG-13, `manual` MSG-22 |
| `BI_BO_QUA` | (Bỏ — xem QC-03: là `LUU_TRU` với `archiveReason = skipped`) | – |
| `HOAN_THANH` / `DA_XOA` | Theo QC-03 (G02) | Theo G02 |

Chuyển trạng thái trong phạm vi G06: `KE_HOACH` → `BACKLOG` (UC-01) · `BACKLOG` → `KE_HOACH` (UC-03) · `KE_HOACH` → `KE_HOACH` hôm nay (UC-04, số ngày bị hoãn tiếp tục đếm) · `KE_HOACH` → `LUU_TRU` `stale` (UC-05) · `KE_HOACH` → `LUU_TRU` `skipped` (UC-04, BR-11) · `LUU_TRU` → `KE_HOACH` (UC-06) · `LUU_TRU` → `DA_XOA` (UC-06). Mỗi chuyển ghi cả cụm vị trí cùng nhau (QC-03 mục 2).

### 4.2. Trạng thái lượt rollover (`rollover_runs`)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHO` | Người dùng đã qua mốc đầu ngày (QC-01), chưa có bản ghi cho ngày đó | Board hiện rollover tạm trên máy (UC-07 A2) |
| `CHO_SHUTDOWN` | Có phiên Daily shutdown của ngày cũ đang làm, chưa tới mốc đầu ngày + 2 giờ (BR-20) | Task ngày cũ ở yên cột ngày cũ |
| `DANG_CHAY` | Job hoặc \[RolloverEnsure\] đã nhận lượt, khoá theo người dùng, `leaseUntil` = nhận + 5 phút (BR-18) | – |
| `XONG` | Giao dịch commit; lưu `rolledCount`, `archivedCount`, `skippedCount` | Toast MSG-11 lần mở app kế tiếp (nếu `archivedCount` > 0) |
| `LOI` | Giao dịch lỗi, chưa đủ 3 lần | Lượt job kế tiếp thử lại |
| `THAT_BAI` | 3 lần lỗi liên tiếp (BR-18) | Job ngừng thử; chạy bù qua \[RolloverEnsure\] khi người dùng mở app; cảnh báo giám sát |

Chuyển: `CHO` → `CHO_SHUTDOWN` → `CHO` (phiên shutdown hoàn tất / bỏ dở / hết 2 giờ) · `CHO` → `DANG_CHAY` → `XONG` · `DANG_CHAY` → `LOI` → `DANG_CHAY` · `LOI` (lần 3) → `THAT_BAI` → `DANG_CHAY` (chỉ qua \[RolloverEnsure\]) · `DANG_CHAY` hết lease → được nhận lại như `CHO`.

## 5. Use Case

### UC-01 Chuyển task vào backlog

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task ở `KE_HOACH` hoặc `BACKLOG` (đổi bucket); từ 1.1: workspace không chỉ đọc (QC-09) |
| Hậu điều kiện thành công | Task ở `BACKLOG`, đúng bucket (BR-02); rời cột ngày; tổng thời lượng ngày cập nhật |
| Hậu điều kiện thất bại | Task giữ ngày / bucket cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Nhấn Z khi task đang chọn / hover (BR-17), hoặc menu Ngày dự định → "Chuyển vào backlog (Z)" |
| 2 | Hệ thống | Mở **SCR-02** gần task, bucket hiện tại (nếu có) được đánh dấu |
| 3 | Người dùng | Bấm một bucket hoặc phím 1, 2, 3, 4, 5, 0 |
| 4 | Hệ thống | Gọi \[TaskMove\] `{backlogBucket}`; ẩn task khỏi cột ngay (cập nhật lạc quan) |
| 5 | Hệ thống | Server áp BR-02; G05 xử lý timebox và sự kiện ngoài theo QC-05 |
| 6 | Hệ thống | Toast MSG-01 "… · Mở task · Đóng" ≥ 5 giây; Ctrl+Z hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Shift+Z hoặc menu "Lên đầu backlog (Shift+Z)" | Bỏ qua bước 2–3; \[TaskMove\] `{backlogBucket: next_week, position: top}` (BR-03); toast MSG-02 có Hoàn tác |
| A2 | Kéo task vào trang / panel Backlog | Thả vào bucket hoặc folder nào thì chuyển vào đó |
| A3 | Bấm "Mở task" trong toast | Mở chi tiết task (G02) |
| A4 | Bấm Hoàn tác / Ctrl+Z | \[TaskMove\] `{undoToken}` trả cả cụm vị trí cũ (ngày dự định, vị trí, `firstPlannedDate`) và khôi phục liên kết timebox; sự kiện ngoài đã bị xoá được G05 tạo lại với giờ cũ (QC-05, BR-17) |
| A5 | Esc khi SCR-02 đang mở | Đóng menu, không đổi |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Áp trên máy, xếp hàng đợi, đồng bộ sau với cùng idempotency key (QC-08) |
| E2 | Task đã bị xoá ở thiết bị khác | 404 / `TASK_DELETED` → MSG-20, gỡ khỏi màn hình |
| E3 | \[TaskMove\] lỗi 5xx / timeout | Trả task về cột cũ, MSG-17 |
| E4 | Workspace chỉ đọc (bản 1.1, QC-09) | MSG-18, không chuyển |
| E5 | Lệnh offline sửa cụm vị trí trên phiên bản cũ (ví dụ server đã rollover task trong lúc offline) | Server từ chối `VERSION_CONFLICT` (QC-08 mục 2); vẽ task theo server, MSG-23 |

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
| A2 | Menu Ngày dự định → chọn ngày trên lịch | `startDate` = ngày chọn; ngày < hôm nay disabled; toast MSG-03 |
| A3 | Kéo vào lịch (timebox) | `startDate` = ngày làm việc của ô (QC-01); tạo timebox theo G05 |
| A4 | Ritual đưa task từ bucket tới kỳ vào ngày (G08, G09) | Cùng \[TaskMove\], áp BR-05 |
| A5 | Instance lặp, ngày D đã có instance cùng series (QC-06 mục 1) | Vẫn đặt; toast cảnh báo MSG-21 (BR-05) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[TaskMove\] lỗi | Trả task về bucket cũ, MSG-17 |
| E2 | Workspace chỉ đọc (bản 1.1, QC-09) | MSG-18 |
| E3 | D < hôm nay (server, `PAST_DATE`) | Trả task về bucket cũ, MSG-24 |
| E4 | `VERSION_CONFLICT` (QC-08) | Vẽ theo server, MSG-23 |

### UC-04 Rollover hằng ngày (job `rollover`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng vừa qua mốc đầu ngày (QC-01); chưa có `rollover_runs` `XONG` cho ngày đó; không ở `CHO_SHUTDOWN` (BR-20); từ 1.1: workspace không chỉ đọc (BR-21) |
| Hậu điều kiện thành công | Mọi task thoả BR-06 ở hôm nay hoặc ở Lưu trữ (BR-11, BR-12); `rollover_runs` = `XONG` |
| Hậu điều kiện thất bại | Không task nào thay đổi (rollback); `rollover_runs` = `LOI` (lượt sau thử lại) hoặc `THAT_BAI` sau 3 lần (BR-18) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job chạy mỗi 15 phút `[giả định]`, chọn người dùng đã qua mốc đầu ngày theo timezone, chưa có lượt `XONG` (BR-13), không ở `THAT_BAI`, không có lượt `DANG_CHAY` còn lease |
| 2 | Hệ thống | Kiểm BR-20: có phiên shutdown ngày cũ đang làm và chưa tới mốc + 2 giờ → `CHO_SHUTDOWN`, dừng. Ngược lại tạo / khoá `rollover_runs(user, date)` = `DANG_CHAY`, `leaseUntil` = now + 5 phút (BR-18) |
| 3 | Hệ thống | Lấy task thoả BR-06; nhóm instance lặp theo series, áp BR-11 trước |
| 4 | Hệ thống | Với task còn lại: áp BR-07, BR-08, BR-09 trong một giao dịch; tăng `version` từng task |
| 5 | Hệ thống | Áp BR-12 cho task có số ngày bị hoãn ≥ ngưỡng (UC-05) |
| 6 | Hệ thống | Ghi nhật ký `system` (BR-16); `rollover_runs` = `XONG` với số liệu |
| 7 | Hệ thống | Phát `task.upserted` cho task bị đổi, `day.recomputed` cho hôm nay; gửi G05 yêu cầu gỡ liên kết timebox quá khứ (bất đồng bộ, không xoá sự kiện ngoài) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Job lỡ nhiều mốc hoặc task có `startDate` cách hôm nay > 1 ngày | Chuyển một lần về hôm nay; số ngày bị hoãn tính từ `firstPlannedDate` nên phản ánh đủ số ngày làm việc đã lỡ (BR-07, EC-05) |
| A2 | Người dùng đổi timezone / mốc đầu ngày trong ngày | Cài đặt mới có hiệu lực từ ngày làm việc kế tiếp; ngày hiện tại kết thúc và rollover theo cài đặt cũ; đã có lượt `XONG` thì không chạy lại (BR-22, Q3, EC-06) |
| A3 | Người dùng đang mở board / chi tiết task | Card chuyển cột qua realtime; chi tiết đang mở không đóng, ngày hiển thị cập nhật |
| A4 | Client offline qua mốc | Khi mở app hiển thị rollover tạm trên máy theo BR-06, BR-07, chỉ để hiển thị, không vào hàng đợi đồng bộ (QC-08 mục 5); có mạng thì gọi \[RolloverEnsure\] và lấy kết quả server làm chuẩn |
| A5 | Task đang chạy timer | Rollover bình thường; timer không dừng (QC-05) |
| A6 | Không có task thoả BR-06 | Ghi lượt `XONG` với số liệu 0 |
| A7 | Phiên Daily shutdown của ngày cũ đang làm (Q18, BR-20) | `CHO_SHUTDOWN`; job các lượt sau kiểm lại; G08 báo phiên hoàn tất / bỏ dở thì chạy ngay; tới mốc + 2 giờ thì chạy dù phiên còn mở |
| A8 | Workspace chỉ đọc (bản 1.1, BR-21) | Không chạy. Khi thoát chỉ đọc: chạy bù một lần cho hôm nay; không tính các ngày bị đóng băng vào số ngày bị hoãn |
| A9 | Lượt `DANG_CHAY` hết lease (worker chết) | Lượt job kế tiếp hoặc \[RolloverEnsure\] nhận lại, chạy từ bước 2 (BR-18) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi CSDL giữa chừng | Rollback toàn bộ lượt của người dùng; `LOI`; lượt job kế tiếp thử lại; lần lỗi thứ 3 → `THAT_BAI`, cảnh báo giám sát (BR-18) |
| E2 | Gỡ liên kết timebox ở G05 lỗi | Không chặn rollover; G05 thử lại theo cơ chế `timebox.push` |
| E3 | `THAT_BAI` | Job định kỳ không thử nữa; lần mở app kế tiếp client gọi \[RolloverEnsure\] (UC-07) |

### UC-05 Tự lưu trữ (trong job `rollover`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Sau UC-04 bước 4, task có số ngày bị hoãn ≥ 4 `[giả định]` (QC-04 mục 5); Auto-archive bật |
| Hậu điều kiện thành công | Task ở `LUU_TRU`; không còn trên hôm nay; không tính khối lượng ngày |
| Hậu điều kiện thất bại | Như UC-04 (rollback cả lượt) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | `LUU_TRU`: `archivedAt` = now, `archiveReason = stale` (BR-12) |
| 2 | Hệ thống | Xử lý timebox theo BR-12; ghi nhật ký "Lưu trữ: bị hoãn {n} ngày" |
| 3 | Hệ thống | Cộng `archivedCount` vào `rollover_runs` |
| 4 | Hệ thống | Lần mở app kế tiếp: toast MSG-11 có link "Xem Lưu trữ" `[giả định]` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Auto-archive tắt | Bỏ qua UC-05; task ở `KE_HOACH` hôm nay, nhãn "Dời {n} ngày" |
| A2 | Task đang chạy timer | Không lưu trữ ở lượt này `[giả định]`; xét lại ở lượt ngày sau |

### UC-06 Xem Lưu trữ, khôi phục và xoá tất cả

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Khôi phục: task về `KE_HOACH` hôm nay, số ngày bị hoãn = 0 (BR-14). Xoá tất cả: mọi task Lưu trữ ở `DA_XOA` (BR-15). Toggle: cài đặt Auto-archive lưu |
| Hậu điều kiện thất bại | Lưu trữ không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Panel phải → Lưu trữ (Shift+A, G04) |
| 2 | Hệ thống | Gọi \[ArchiveList\]; mở **SCR-05**, mới lưu trữ nhất trước |
| 3 | Người dùng | Bấm "Khôi phục" trên một dòng |
| 4 | Hệ thống | Gọi \[TaskRestore\] `{from: archive}`; áp BR-14; task hiện đầu hôm nay; toast MSG-14 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Xoá tất cả" | Mở **SCR-06** (MSG-15) → xác nhận → \[ArchiveDeleteAll\]; toast MSG-16 có Hoàn tác |
| A2 | Bật / tắt "Auto-archive" | \[SettingsUpdate\] `autoArchive` (G01); áp từ lượt rollover kế tiếp |
| A3 | Kéo task từ Lưu trữ vào cột ngày D | \[TaskRestore\] `{from: archive, startDate: D}`; D ≥ hôm nay (BR-14) |
| A4 | Lưu trữ rỗng | Empty state MSG-19 |
| A5 | Cuộn hết trang | Tải tiếp theo cursor, 50 dòng / lần |
| A6 | Khôi phục instance lặp vào ngày đã có instance cùng series | Vẫn khôi phục; toast cảnh báo MSG-21 (QC-06 mục 3) |
| A7 | Mở task lưu trữ từ kết quả tìm kiếm (G04) | Mở chi tiết ở chế độ xem, có nút "Khôi phục" → bước 4 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Task đã bị xoá ở thiết bị khác | MSG-20, gỡ dòng |
| E2 | \[TaskRestore\] / \[ArchiveDeleteAll\] lỗi | Lưu trữ giữ nguyên, MSG-17 |
| E3 | Workspace chỉ đọc (bản 1.1, QC-09) | Chỉ xem; "Khôi phục", "Xoá tất cả" disabled, MSG-18 |
| E4 | D < hôm nay (server, `PAST_DATE`) | Task ở lại Lưu trữ, MSG-24 |

### UC-07 Đảm bảo rollover theo yêu cầu (\[RolloverEnsure\])

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; client mở app lần đầu trong ngày làm việc (G04), hoặc G08 chuẩn bị tải bước "Xem lại hôm qua" |
| Hậu điều kiện thành công | Trả trạng thái lượt rollover của hôm nay; nếu lượt chạy được thì `XONG` và board nhận kết quả |
| Hậu điều kiện thất bại | Trả trạng thái lỗi; dữ liệu task không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Client / G08 | Gọi \[RolloverEnsure\] (không cần tham số ngày; server tính hôm nay theo QC-01) |
| 2 | Hệ thống | Đọc `rollover_runs(user, hôm nay)` |
| 3 | Hệ thống | `XONG` → trả kết quả ngay |
| 4 | Hệ thống | `CHO`, `LOI`, `THAT_BAI`, chưa có bản ghi, hoặc `DANG_CHAY` hết lease → chạy UC-04 bước 2–7 trong request |
| 5 | Hệ thống | Trả `{date, status, rolledCount, archivedCount, skippedCount}`; client lấy kết quả server làm chuẩn |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | `DANG_CHAY` còn lease (job đang chạy) | Chờ tối đa 10 giây `[giả định]`; xong thì trả kết quả, chưa xong thì trả `DANG_CHAY`; client nhận kết quả sau qua realtime |
| A2 | Trong lúc chờ phản hồi hoặc khi trả `DANG_CHAY` | Board hiện rollover tạm trên máy, chỉ để hiển thị (QC-08 mục 5) `[giả định]` |
| A3 | `CHO_SHUTDOWN` (BR-20) | Không ép chạy; trả `status = CHO_SHUTDOWN`, `waitUntil` = mốc đầu ngày + 2 giờ; task ngày cũ hiển thị ở cột ngày cũ |
| A4 | Workspace chỉ đọc (bản 1.1) | Không chạy; trả `status = DONG_BANG` (BR-21) |
| A5 | Gọi lặp nhiều lần (nhiều tab, G04 và G08 cùng gọi) | Idempotent theo người dùng + ngày (BR-13); chỉ một request chạy, các request khác đi theo A1 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Chạy trong request lỗi | Rollback; tăng số lần lỗi theo BR-18 (đã `THAT_BAI` thì giữ `THAT_BAI`); trả `ROLLOVER_FAILED` → MSG-25 có "Thử lại" |
| E2 | Timeout / mất mạng | Giữ rollover tạm trên máy; gọi lại khi có mạng |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Sidebar "Backlog" / phím B | ✓ | ✓ | Mở SCR-01 |
| Phím Z / Shift+Z trên task | ✓ | – | UC-01 |
| Menu Ngày dự định → "Chuyển vào backlog", "Lên đầu backlog" | ✓ | ✓ | SCR-03 |
| Kéo task vào panel Backlog (panel phải) | ✓ | – | UC-01 A2 |
| Panel phải → Lưu trữ / Shift+A | ✓ | ✓ | Mở SCR-05 |
| Toast MSG-11 → "Xem Lưu trữ" | ✓ | ✓ | Mở SCR-05 |
| Command menu Ctrl/Cmd+K | ✓ | – | "Chuyển vào backlog", "Mở Backlog", "Mở Lưu trữ" |
| Mở app lần đầu trong ngày làm việc (G04) / bước "Xem lại hôm qua" (G08) | ✓ | ✓ | UC-07, không có giao diện riêng |

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

### SCR-03 Menu Ngày dự định (phần G06)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Hoãn 1 ngày (D), Hoãn 1 tuần | Menu item | G04 |
| 2 | Chuyển vào backlog (Z) | Menu item | Mở SCR-02 |
| 3 | Lên đầu backlog (Shift+Z) | Menu item | UC-01 A1 |
| 4 | Lịch chọn ngày | Calendar | UC-03 A2; ngày < hôm nay disabled với task chưa xong (QC-05) |

### SCR-04 Tạo / sửa folder

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tên folder | Text | Có | 1–50 ký tự → MSG-05; trùng → MSG-06; quá 50 folder → MSG-07 |
| 2 | "Lưu" / Enter | Action | – | \[BacklogFolderCreate\] / \[BacklogFolderUpdate\] |
| 3 | "Xoá folder" | Button (nguy hiểm) | – | Hộp MSG-08 → \[BacklogFolderDelete\] |

### SCR-05 Panel Lưu trữ

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề + mô tả | Header | "Lưu trữ" · mô tả MSG-12 |
| 2 | "Auto-archive" | Toggle | UC-06 A2 |
| 3 | "Xoá tất cả" | Button (nguy hiểm) | Mở SCR-06; disabled khi rỗng |
| 4 | Danh sách task | List | Mỗi dòng: tiêu đề, #channel, thời lượng, ngày lưu trữ, nhãn lý do theo `archiveReason` (MSG-12 / MSG-13 / MSG-22) |
| 5 | "Khôi phục" | Button (theo dòng) | UC-06 bước 3 |
| 6 | Trạng thái rỗng | Empty state | MSG-19 |

### SCR-06 Xác nhận "Xoá tất cả"

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-15 |
| 2 | "Xoá tất cả" | Button (nguy hiểm) | \[ArchiveDeleteAll\] |
| 3 | "Huỷ" | Button | Đóng |

### SCR-07 Nhãn "Dời {n} ngày" trên task card

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nhãn "Dời {n} ngày" | Icon + số | Hiện khi số ngày bị hoãn n ≥ 1 (QC-04 mục 4); tooltip MSG-09 |
| 2 | Màu | Trạng thái | n = ngưỡng Auto-archive − 1 đổi màu cảnh báo (lượt sau sẽ lưu trữ nếu bật) `[giả định]` |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[BacklogList\] `GET /tasks/backlog` | bucket, folderId, channelId, cursor, limit ≤ 200 | Task[] (theo bucket), totals {bucket: count, plannedMin}, nextCursor | 5s / 1 lần |
| \[TaskMove\] `POST /tasks/{id}/move` | `{backlogBucket, folderId?, position?: top}` \| `{startDate, afterId?, beforeId?}` \| `{undoToken}`, version, Idempotency-Key | Task (cụm vị trí, `firstPlannedDate`, `postponedDays`), undoToken, `warnings[]` (`SERIES_SAME_DAY`) | 5s / retry 2 lần cùng key |
| \[BacklogFolderList\] `GET /backlog-folders` | – | Folder[] | 5s / 1 lần |
| \[BacklogFolderCreate\] / \[BacklogFolderUpdate\] / \[BacklogFolderDelete\] `POST / PATCH / DELETE /backlog-folders` | name, position | Folder | 5s / 1 lần |
| \[TaskCreate\] `POST /tasks` (G02) | title, backlogBucket, folderId, … | Task | Theo G02 |
| \[ArchiveList\] `GET /tasks/archive` | cursor, limit 50 | Task[] (archivedAt, archiveReason, postponedDays), nextCursor | 5s / 1 lần |
| \[TaskRestore\] `POST /tasks/{id}/restore` | `{from: archive, startDate?}` (mặc định hôm nay; ≥ hôm nay) | Task, `warnings[]` (`SERIES_SAME_DAY`) | 5s / 2 lần |
| \[ArchiveDeleteAll\] `POST /tasks/archive/delete-all` `[giả định — chưa có trong danh sách API]` | Idempotency-Key | deletedCount, undoToken | 10s / 1 lần |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | autoArchive, rolloverPosition, keepPriorityLevels (tập mức, C16) | Settings | 5s / 2 lần |
| \[Rollover\] (job nội bộ) | userId, date | rolledCount, archivedCount, skippedCount | Mỗi người dùng một giao dịch; lease 5 phút; thử lại ở lượt job kế tiếp, 3 lần lỗi → `THAT_BAI` (BR-18) |
| \[RolloverEnsure\] `POST /rollover/ensure` (dùng chung G04, G08) | Không có body; server tính hôm nay theo QC-01 | `{date, status: XONG \| DANG_CHAY \| CHO_SHUTDOWN \| DONG_BANG \| THAT_BAI, rolledCount, archivedCount, skippedCount, waitUntil?}` | 15s `[giả định]` (gồm tối đa 10s chờ lượt đang chạy); idempotent theo người dùng + ngày, client không tự retry khi nhận `THAT_BAI` |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field name (folder) | MSG-05 |
| `FOLDER_NAME_TAKEN` | MSG-06 |
| `LIMIT_FOLDERS` | MSG-07 |
| `NOT_FOUND` / `TASK_DELETED` (task đã xoá) | MSG-20 |
| `WORKSPACE_READ_ONLY` (402, bản 1.1) | MSG-18 |
| `VERSION_CONFLICT` (QC-08) | MSG-23 |
| `VALIDATION_FAILED` · field startDate · PAST_DATE | MSG-24 |
| `ROLLOVER_FAILED` (\[RolloverEnsure\]) | MSG-25 |
| Cảnh báo `SERIES_SAME_DAY` (không phải lỗi) | MSG-21 |
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
| MSG-09 | Tooltip | Dời {n} ngày · dự định từ {ngày dự định đầu tiên} |
| MSG-10 | – | (dự phòng) |
| MSG-11 | Toast | Đã lưu trữ {n} task bị hoãn từ {ngưỡng} ngày trở lên · Xem Lưu trữ |
| MSG-12 | Header / nhãn | Bị hoãn từ {ngưỡng} ngày làm việc trở lên |
| MSG-13 | Nhãn | Bị bỏ qua · đã có lần lặp hôm nay |
| MSG-14 | Toast | Đã khôi phục "{tiêu đề}" về hôm nay · Hoàn tác |
| MSG-15 | Dialog | Xoá tất cả {n} task trong Lưu trữ? Task sẽ nằm trong Thùng rác 30 ngày |
| MSG-16 | Toast | Đã chuyển {n} task vào Thùng rác · Hoàn tác |
| MSG-17 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-18 | Banner | (Bản 1.1) Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-19 | Empty state | Không có task nào được lưu trữ |
| MSG-20 | Toast | Task này không còn tồn tại |
| MSG-21 | Toast cảnh báo | Ngày này đã có {tên series} |
| MSG-22 | Nhãn | Bạn đã lưu trữ |
| MSG-23 | Toast | Task đã thay đổi trên thiết bị khác |
| MSG-24 | Toast | Không thể đặt task chưa xong vào ngày đã qua |
| MSG-25 | Banner | Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Z / Shift+Z ẩn task ≤ 100 ms (lạc quan); \[TaskMove\] p95 ≤ 300 ms; SCR-01 tải ≤ 500 ms với 1.000 task backlog (danh sách ảo hoá) |
| Job rollover | 95% người dùng có lượt `XONG` ≤ 15 phút sau mốc đầu ngày (B6; không tính người dùng ở `CHO_SHUTDOWN`); một người dùng ≤ 500 ms với 200 task; lease 5 phút |
| \[RolloverEnsure\] | p95 ≤ 2 s khi phải chạy lượt trong request `[giả định]` |
| Toàn vẹn | `UNIQUE(user_id, date)` trên `rollover_runs`; một giao dịch / người dùng; chạy lại không chuyển hai lần (BR-13); job tăng `version` của task (QC-08) |
| Offline | Theo QC-08. Backlog lưu trong IndexedDB; chuyển vào / ra backlog chạy được khi mất mạng; cụm vị trí ghi nguyên khối, lệnh trên phiên bản cũ bị từ chối; rollover tạm trên máy chỉ để hiển thị, không vào hàng đợi đồng bộ, server là chuẩn |
| Đồng bộ | Kết quả rollover và thay đổi backlog hiện trên thiết bị khác ≤ 5 giây |
| Bảo mật | Chỉ chủ task xem / sửa backlog, Lưu trữ; job chỉ xử lý task của đúng người dùng trong lượt |
| Log / audit | \[ActivityLog\] theo BR-16; log job: người dùng, ngày, trạng thái lượt, số lần thử, số chuyển / lưu trữ / bỏ qua, thời gian chạy, nguồn (job / ensure); không chứa tiêu đề |
| Giám sát | Cảnh báo khi lượt `LOI` > 0,1% / giờ, khi có lượt `THAT_BAI`, khi lease hết hạn bất thường, hoặc khi tỉ lệ `XONG` ≤ 15 phút sau mốc < 95% |
| Tracking | Sự kiện: `backlog_opened`, `task_moved_to_backlog` (bucket, nguồn: Z / Shift+Z / menu / kéo), `task_moved_from_backlog`, `backlog_folder_created`, `rollover_completed` (rolled, archived, skipped, nguồn: job / ensure, độ trễ sau mốc), `rollover_failed`, `rollover_ensure_called` (trạng thái trả về, nơi gọi: G04 / G08), `archive_opened`, `task_restored_from_archive`, `archive_deleted_all`, `auto_archive_toggled` |
| Accessibility | Mọi kéo thả có cách bằng phím / menu (Z, S, menu Ngày dự định); nhãn "Dời {n} ngày" có nhãn đọc màn hình "Bị hoãn {n} ngày"; tương phản WCAG 2.1 AA ở cả giao diện sáng / tối |
