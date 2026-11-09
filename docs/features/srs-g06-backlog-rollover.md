> **Mã:** PLN-SRS-G06 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g06-backlog-rollover.md

# UC-G06 - Backlog, rollover & lưu trữ trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả backlog (bucket, folder, chuyển vào / ra), rollover tự động, API đảm bảo rollover và Lưu trữ (tự lưu trữ, khôi phục, xoá tất cả). Mô hình task, Thùng rác (G02), quy tắc instance lặp (G03), board, phím D và kéo thả (G04), timebox (G05), nhắc bucket trong ritual (G08, G09) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> **Quy tắc dùng chung** ([`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md)): ngày làm việc QC-01, lịch làm việc và khung giờ channel QC-02, trạng thái task và khôi phục QC-03, số ngày bị hoãn QC-04, đổi ngày task QC-05, instance trùng series QC-06, bản ghi thời gian QC-07, đồng bộ QC-08, chế độ chỉ đọc QC-09. **G06 sở hữu QC-04 và QC-05**: mọi thay đổi hai quy tắc này sửa ở `docs/01`, không sửa trong SRS này. Thuật ngữ theo [`CONTEXT.md`](../../CONTEXT.md). Chốt theo [quyết định 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md), gồm vòng 7: số ngày bị hoãn theo lịch hiện tại của task (D4 — BR-10); "Hoãn 1 tuần" = max(ngày dự định, hôm nay) + 7 ngày, rơi vào ngày nghỉ thì giữ nguyên (D5 — QC-05, mục 3.1); lưu trữ `skipped` xử lý timebox như "Đưa vào backlog" (D6 — BR-11).
>
> Cập nhật theo [câu hỏi chốt 09/11/2026](../review/cau-hoi-chot-flow-2026-11-09.md): B06–B13, C06–C09; quy tắc chung A1, A2, A9, A10 theo **QC-13** (QC-MSG-01 lỗi lưu, QC-MSG-02 lỗi tải, kéo thả và Hoàn tác, Hoàn tác về đúng trạng thái trước, phần của bản sau).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng gạt việc chưa cần làm vào backlog bằng 1–2 phím; việc dở tự chuyển sang hôm nay; việc bị hoãn quá lâu hoặc bị bỏ qua được lưu trữ, khôi phục được |
| Actor | Người dùng đã đăng nhập · Hệ thống (job `rollover`, API đảm bảo rollover) · G08 (gọi API đảm bảo rollover) |
| Phạm vi | Trang / panel Backlog (6 bucket, folder, nhóm theo channel), chuyển task vào backlog (Z, Shift+Z, menu, kéo), lấy task ra ngày, rollover, đảm bảo rollover khi mở app, Tự lưu trữ, panel Lưu trữ, khôi phục, "Xoá tất cả"; sở hữu QC-04, QC-05 |
| Ngoài phạm vi | Phím D, hoãn 1 tuần và kéo thả trên board (G04), Thùng rác (G02), sinh instance lặp và quy tắc QC-06 (G03), đồng bộ sự kiện trên lịch ngoài (G05), nhắc bucket trong ritual (G08, G09), backlog nhóm và task được giao (bản sau, 1.2 trở đi, Q35, Q36, Q47 — BR-23), lưu trữ thủ công `manual` (bản sau, Q34), mức ưu tiên riêng của Backlog (không có ở 1.0; task giữ priority của chính nó theo G02, chốt 09/11/2026, B13), chỉnh ngưỡng Tự lưu trữ trên giao diện (không có ở 1.0, B10), chế độ chỉ đọc (G12, 1.1) |
| Nền tảng | App Windows (Flutter) ở 1.0 (Q45, ADR-0005). Web, macOS từ 1.1; iOS / Android từ 1.2 dùng cùng đặc tả. Job rollover chạy phía server; lưu trên máy, hạ tầng job: tech chốt — `docs/tech/` |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Gạt task sang "Tuần tới", "Tháng tới"… bằng hai phím | Hôm nay chỉ còn việc cần làm |
| US-02 | Người dùng | Đưa task lên đầu backlog không cần chọn | Hoãn nhanh nhất có thể |
| US-03 | Người dùng | Xem backlog theo bucket, folder, channel | Biết việc nào đang chờ, chọn đúng việc khi lên kế hoạch |
| US-04 | Người dùng | Kéo task từ backlog vào một ngày | Lên lịch cho việc đã hoãn |
| US-05 | Người dùng | Việc chưa xong tự chuyển sang hôm nay | Không phải dọn tay mỗi sáng |
| US-06 | Người dùng | Việc bị hoãn ≥ 4 ngày làm việc (theo lịch của task) tự rời khỏi hôm nay | Hôm nay không phình mãi |
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
| BR-06 | **Điều kiện rollover.** Task `KE_HOACH` (QC-03) có `startDate` < hôm nay. "Hôm nay" là ngày làm việc tính bằng `workday(t)` (QC-01). Rollover chạy **mọi ngày**, kể cả ngày không có trong lịch chung hay lịch của task (QC-04 mục 1, Q32); lịch làm việc chỉ ảnh hưởng số ngày bị hoãn (BR-10) |
| BR-07 | **Rollover.** `startDate` = hôm nay; `firstPlannedDate` giữ nguyên nên số ngày bị hoãn tiếp tục đếm (QC-04 mục 2). Nhiều ngày bị lỡ gộp thành một lần chuyển, một dòng nhật ký (EC-05); số ngày bị hoãn vẫn đúng số ngày có trong lịch của task từ `firstPlannedDate` (BR-10), không chỉ +1. Thứ tự: task được chuyển xếp theo ngày dự định cũ tăng dần, rồi vị trí cũ; cả khối đặt ở đầu hoặc cuối danh sách hôm nay theo cài đặt "Vị trí task rollover" (mặc định đầu), nhưng luôn sau các instance lặp của hôm nay (C16). Mỗi task bị đổi tăng `version` như thao tác người dùng (QC-08 mục 1) |
| BR-08 | **Priority khi rollover** về Normal, trừ các mức có trong tập "Giữ priority khi rollover" (cấu hình theo tập mức, C16; mặc định tập rỗng) |
| BR-09 | **Timebox khi rollover:** theo dòng "Rollover" của QC-05. Timebox quá khứ (`endsAt` ≤ thời điểm rollover) bị gỡ liên kết khỏi task, sự kiện trên lịch ngoài **giữ lại** làm lịch sử (G05 không xoá); task về projection (G04). Timebox tương lai giữ nguyên. Timer đang chạy không dừng. Bản ghi thời gian giữ ở ngày làm việc của `startedAt` (QC-07) |
| BR-10 | **Số ngày bị hoãn** (thay `rolloverCount` trong toàn bộ SRS này): định nghĩa, các đường giữ hoặc reset theo QC-04. G06 lưu `firstPlannedDate` trong cụm vị trí (QC-03 mục 2); số ngày bị hoãn là giá trị suy ra (`postponedDays`), không lưu bộ đếm riêng. `postponedDays` = số ngày D có `firstPlannedDate` < D ≤ hôm nay và D có trong **lịch của task** (khung giờ channel của task nếu có, ngược lại lịch chung — QC-02 mục 6, QC-04 mục 1, Q32). Tính theo lịch **hiện tại** của task (D4, QC-04 mục 1): đổi lịch chung, khung channel hoặc channel của task thì n tính lại ngay trên toàn bộ khoảng từ `firstPlannedDate`, có thể tăng hoặc giảm. Ví dụ ở mục 3.1 |
| BR-11 | **Instance lặp khi rollover** (đường tự động của QC-06, G03 định nghĩa): series đã có instance trong hôm nay (định nghĩa QC-06 mục 1) → instance quá khứ chưa xong không rollover mà chuyển `LUU_TRU`, `archiveReason = skipped`; không có toast, chỉ ghi nhật ký. Timebox, sự kiện ngoài, timer của instance `skipped` theo dòng "lưu trữ do trùng series (`skipped`)" của QC-05, tức như "Đưa vào backlog" (D6): timebox tương lai bị gỡ và sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ; timer không dừng; timebox liên kết sự kiện theo ngoại lệ của QC-05. Áp như nhau cho mọi đường lưu trữ `skipped` (rollover ở đây; phím D — G04, shutdown "Ngày mai" — G08). Series chưa có instance hôm nay → instance quá khứ mới nhất (ngày gốc lớn nhất) rollover trước và trở thành instance đã có của hôm nay; các instance cũ hơn là instance được đưa vào ngày đã có instance nên chuyển `skipped` (QC-06 mục 2, G03 BR-10, EC-30). Không trường hợp nào instance đã có ở hôm nay bị lưu trữ. **Ngoại lệ** (chốt 09/11/2026, B08): instance quá khứ chưa xong đã sửa riêng (`customized`, G03 BR-07) hoặc đã có thời gian thực tế (bản ghi thời gian, QC-07 mục 5) **không** chuyển `skipped`; instance đó rollover như task thường (BR-07 → BR-10, BR-12), kể cả khi hôm nay đã có instance của series |
| BR-12 | **Tự lưu trữ.** Sau BR-07, nếu bật Tự lưu trữ (mặc định bật `[giả định]`) và số ngày bị hoãn ≥ 4 `[giả định]` (QC-04 mục 5) → `LUU_TRU`, `archiveReason = stale`. Ngưỡng cố định theo cấu hình hệ thống, không chỉnh trên giao diện ở 1.0 (chốt 09/11/2026, B10). **Task có hoạt động không bị tự lưu trữ** (B11): task có ít nhất một subtask đã tích hoặc đã có thời gian thực tế (bản ghi thời gian, QC-07 mục 5) ở lại `KE_HOACH` hôm nay, nhãn "Dời {n} ngày" vẫn hiện. Timebox, sự kiện ngoài, timer theo dòng "Tự lưu trữ (`stale`)" của QC-05, tức như "Đưa vào backlog" (Q42): timebox tương lai bị gỡ và sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ; timer không dừng; timebox liên kết sự kiện theo ngoại lệ của QC-05. Không có Hoàn tác (Q41); khôi phục qua UC-06 không tạo lại timebox. Không tính vào khối lượng ngày |
| BR-13 | **Idempotent.** Mỗi người dùng một bản ghi `rollover_runs(user_id, date)` UNIQUE; đã `XONG` thì bỏ qua (EC-06) |
| BR-14 | **Khôi phục từ Lưu trữ.** Hai lựa chọn (chốt 09/11/2026, B12): **"Khôi phục vào hôm nay"** (mặc định) và **"Khôi phục vào Backlog"**. Cả hai: `archivedAt`, `archiveReason` = null; số ngày bị hoãn reset (QC-04 mục 3). Vào hôm nay: `startDate` = hôm nay, vào đầu danh sách hôm nay. Kéo vào ngày D: D ≥ hôm nay (QC-05). Instance lặp vào ngày đã có instance cùng series: cho phép, cảnh báo MSG-21 (QC-06 mục 3). Vào Backlog: theo BR-02, bucket `next_week`, đầu bucket `[giả định]` (như Shift+Z, BR-03). Hoàn tác trả task về Lưu trữ với `archivedAt`, `archiveReason` cũ (QC-13 mục 5, A10) |
| BR-15 | **Xoá tất cả** trong Lưu trữ cần xác nhận; xoá mềm mọi task trong Lưu trữ (vào Thùng rác 30 ngày, G02, Q28); có Hoàn tác, đưa mọi task về lại Lưu trữ với `archivedAt`, `archiveReason` cũ (QC-13 mục 5, A10). Instance lặp bị xoá theo đường này là người dùng xoá: ngày gốc của instance thành ngày ngoại lệ vĩnh viễn của series (G03 BR-15, Q26); Hoàn tác hay khôi phục không gỡ ngày ngoại lệ. Khôi phục từ Thùng rác đưa task về lại Lưu trữ với lý do cũ (QC-03 mục 3) |
| BR-16 | Mọi thay đổi ghi \[ActivityLog\] (G02): chuyển vào backlog / bucket, lấy ra ngày (tác nhân `user`); rollover, lưu trữ (tác nhân `system`, "Chuyển từ {ngày}", "Lưu trữ: bị hoãn {n} ngày" / "bị bỏ qua"). Rollover và tự lưu trữ **không có Hoàn tác** (Q41, QC-05): không cấp `undoToken`, nhật ký là dấu vết duy nhất |
| BR-17 | Phím Z, Shift+Z, B, S và phím chọn bucket chỉ hoạt động khi không có ô nhập nào đang focus; Z, Shift+Z luôn có toast Hoàn tác; kéo task vào Backlog, kéo sang bucket khác, kéo từ Backlog hoặc Lưu trữ ra ngày cũng có toast Hoàn tác như khi làm bằng phím hay menu; kéo đổi thứ tự trong cùng bucket không có toast, Ctrl+Z hoàn tác (QC-13 mục 2, chốt 09/11/2026, A2). Hoàn tác (chỉ cho đường do người dùng / AI làm, không cho rollover, tự lưu trữ — Q41) khôi phục cả cụm vị trí và liên kết timebox; sự kiện ngoài đã bị xoá thì được tạo lại với giờ cũ (QC-05) |
| BR-18 | **Lease và thất bại** (B6). Lượt nhận `DANG_CHAY` kèm `leaseUntil` = now + 5 phút; quá hạn mà chưa `XONG` coi như chưa chạy, lượt kế tiếp được nhận lại. Lỗi giao dịch → `LOI`, thử lại ở lượt job kế tiếp; sau 3 lần lỗi liên tiếp → `THAT_BAI`, job định kỳ ngừng thử, chờ chạy bù qua \[RolloverEnsure\] khi người dùng mở app (BR-19) |
| BR-19 | **Đảm bảo rollover** (B6, dùng chung với G08). \[RolloverEnsure\] idempotent theo người dùng + ngày: `XONG` → trả kết quả đã có; `CHO`, `LOI`, `THAT_BAI` hoặc `DANG_CHAY` hết lease → chạy UC-04 bước 2–7 ngay trong request; `DANG_CHAY` còn lease → chờ tối đa 10 giây `[giả định]` rồi trả trạng thái hiện tại; `CHO_SHUTDOWN` → không ép chạy, trả trạng thái kèm `waitUntil` (BR-20). Client gọi khi mở app lần đầu trong ngày làm việc (G04) và trước khi tải bước "Xem lại hôm qua" (G08) |
| BR-20 | **Chờ phiên shutdown** (Q18, G08 BR-21). Người dùng có phiên Daily shutdown của ngày cũ đang làm, mở trước mốc đầu ngày (G08) → lượt rollover ở `CHO_SHUTDOWN`; chạy khi phiên hoàn tất, bị bỏ dở, hoặc tới mốc đầu ngày + 2 giờ, tuỳ điều nào tới trước. "Bỏ dở" theo định nghĩa của G08 BR-21. G06 nhận sự kiện `ritual.shutdown.closed` của G08 (phiên hoàn tất / bị bỏ dở) để chạy lượt đang `CHO_SHUTDOWN` ngay |
| BR-21 | **Chế độ chỉ đọc (bản 1.1, QC-09).** Workspace chỉ đọc → không chạy rollover, không tạo lượt. Khi thoát chỉ đọc: rollover chạy bù một lần; các ngày làm việc bị đóng băng không tính vào số ngày bị hoãn (QC-04 mục 6). Bản 1.0 không có chế độ chỉ đọc |
| BR-22 | **Đổi mốc đầu ngày hoặc timezone** (Q3, QC-01 mục 3): có hiệu lực từ ngày làm việc kế tiếp; ngày hiện tại kết thúc và rollover theo cài đặt cũ; không chạy lại rollover cho ngày đã có lượt `XONG` (EC-06) |
| BR-23 | **Task được giao (bản sau** — Q35, Q36, `docs/02-tinh-nang-ban-sau.md`). Task người khác giao cho người dùng vào `BACKLOG`, bucket `next_week` ("Tuần tới"; Q36 gọi là "Tuần sau"), đặt lên đầu bucket. Không có ở 1.0 (bản 1 chỉ cho một người dùng) |
| BR-24 | **Hiển thị khi rollover chưa xong** (F2, dùng chung cho G04, G08). (a) **Đang chờ** (`DANG_CHAY` còn lease, `CHO_SHUTDOWN`): không báo lỗi; board hiện rollover tạm trên máy (`DANG_CHAY`) hoặc để task ngày cũ ở yên cột ngày cũ (`CHO_SHUTDOWN`); bước "Xem lại hôm qua" của Daily planning hiện G08 MSG-32 và tự tải lại khi rollover xong (realtime). (b) **Thất bại** (`ROLLOVER_FAILED`, hoặc `THAT_BAI`): ở mọi nơi chỉ một cách hiển thị: banner **MSG-25** có "Thử lại" (gọi lại \[RolloverEnsure\]), theo hàng chờ banner của G04 SCR-01 #5 (IA-17). Board giữ rollover tạm; bước "Xem lại hôm qua" vẫn tải danh sách hiện có, không hiện MSG-32. G04 MSG-27 dùng đúng nội dung MSG-25 |

### 3.1. Ví dụ kiểm thử số ngày bị hoãn (QC-04, Q32)

Giả thiết: lịch chung Thứ Hai–Thứ Sáu; `#Cá nhân` có khung Thứ Hai–Chủ Nhật; `#Công ty` không đặt khung (dùng lịch chung); Tự lưu trữ bật, ngưỡng 4. Ngày 2026: Thứ Sáu 06/11, Thứ Bảy 07/11, Chủ Nhật 08/11, Thứ Hai 09/11 … Thứ Năm 12/11.

| # | Tình huống | Kết quả mong đợi |
| --- | --- | --- |
| 1 | Task `#Công ty`, `firstPlannedDate` Thứ Sáu 06/11, chưa xong | Rollover Thứ Bảy 07/11, Chủ Nhật 08/11: task sang hôm nay, n = 0, không có nhãn "Dời". Thứ Hai 09/11: n = 1. Thứ Năm 12/11: n = 4 → tự lưu trữ `stale` |
| 2 | Task `#Cá nhân`, `firstPlannedDate` Thứ Sáu 06/11, chưa xong | Thứ Bảy n = 1, Chủ Nhật n = 2, Thứ Hai n = 3; Thứ Ba 10/11 n = 4 → tự lưu trữ |
| 3 | Như 1, Thứ Hai 09/11 người dùng nhấn D (sang Thứ Ba 10/11) | `firstPlannedDate` giữ 06/11; Thứ Ba n = 2 |
| 4 | Như 1, Thứ Hai 09/11 người dùng chọn "Hoãn 1 tuần" (task sang 16/11) hoặc nhấn S (task về hôm nay) | n = 0; `firstPlannedDate` = ngày dự định mới (Q40) |
| 5 | Như 1, Thứ Hai 09/11 người dùng đổi channel của task sang `#Cá nhân` | n tính lại theo khung `#Cá nhân`: n = 3 (BR-10, D4) |
| 6 | Lượt rollover Thứ Bảy 07/11 thất bại, task cũ được chuyển lần đầu vào Chủ Nhật 08/11 | Một lần chuyển (EC-05); task `#Công ty` n = 0, task `#Cá nhân` n = 2; n không phụ thuộc số lượt rollover |
| 7 | Như 1, Thứ Bảy 07/11 (task đã rollover sang 07/11) người dùng chọn "Hoãn 1 tuần" | Ngày dự định = max(07/11, 07/11) + 7 = Thứ Bảy 14/11; Thứ Bảy không có trong lịch của task nhưng **giữ nguyên** 14/11, không lùi sang Thứ Hai 16/11 (D5); n = 0 |
| 8 | Task `#Công ty` dự định Thứ Tư 18/11 (tương lai), hôm nay Thứ Hai 09/11, chọn "Hoãn 1 tuần" | Ngày dự định = max(18/11, 09/11) + 7 = Thứ Tư 25/11 (D5); n = 0 |
| 9 | Hôm nay 10:00, instance lặp của series S có timebox 15:00–16:00 hôm nay; người dùng nhấn D, ngày làm việc kế tiếp đã có instance của S | Instance chuyển `LUU_TRU` `skipped` (QC-06 mục 2); timebox tương lai bị gỡ, sự kiện ngoài bị xoá, như "Đưa vào backlog" (D6, QC-05); Hoàn tác trên toast khôi phục cả timebox và tạo lại sự kiện. Instance `skipped` do rollover có timebox quá khứ: chỉ gỡ liên kết, sự kiện giữ |

## 4. Trạng thái

### 4.1. Trạng thái task (phạm vi G06)

Bộ trạng thái và điều kiện theo QC-03 (G02 sở hữu). G06 không thêm trạng thái riêng. Bảng dưới chỉ ghi cách G06 hiển thị.

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `BACKLOG` | Theo QC-03 | Trong bucket (và folder nếu có) trên trang Backlog |
| `KE_HOACH` | Theo QC-03 | Card trên cột ngày; số ngày bị hoãn ≥ 1 thì có nhãn "Dời {n} ngày" (SCR-07). "Đã dời" là thuộc tính suy ra, không phải trạng thái |
| `DA_CHUYEN_NGAY` | (Bỏ — xem QC-03, QC-04: thay bằng `KE_HOACH` có số ngày bị hoãn ≥ 1) | – |
| `LUU_TRU` | Theo QC-03; `archiveReason` ∈ {`stale`, `skipped`} (lưu trữ thủ công `manual` bỏ ở 1.0 — Q34, bản sau) | Chỉ trong Lưu trữ, nhãn theo lý do: `stale` MSG-12, `skipped` MSG-13 "Đã bỏ qua" (instance `skipped` luôn hiện trong Lưu trữ, chốt 09/11/2026, B09) |
| `BI_BO_QUA` | (Bỏ — xem QC-03: là `LUU_TRU` với `archiveReason = skipped`) | – |
| `HOAN_THANH` / `DA_XOA` | Theo QC-03 (G02) | Theo G02 |

Chuyển trạng thái trong phạm vi G06: `KE_HOACH` → `BACKLOG` (UC-01) · `BACKLOG` → `KE_HOACH` (UC-03) · `KE_HOACH` → `KE_HOACH` hôm nay (UC-04, số ngày bị hoãn tiếp tục đếm) · `KE_HOACH` → `LUU_TRU` `stale` (UC-05) · `KE_HOACH` → `LUU_TRU` `skipped` (UC-04, BR-11) · `LUU_TRU` → `KE_HOACH` (UC-06) · `LUU_TRU` → `BACKLOG` (UC-06 A8, B12) · `LUU_TRU` → `DA_XOA` (UC-06). Mỗi chuyển ghi cả cụm vị trí cùng nhau (QC-03 mục 2).

### 4.2. Trạng thái lượt rollover (`rollover_runs`)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHO` | Người dùng đã qua mốc đầu ngày (QC-01), chưa có bản ghi cho ngày đó | Board hiện rollover tạm trên máy (UC-07 A2) |
| `CHO_SHUTDOWN` | Có phiên Daily shutdown của ngày cũ đang làm, chưa tới mốc đầu ngày + 2 giờ (BR-20) | Task ngày cũ ở yên cột ngày cũ |
| `DANG_CHAY` | Job hoặc \[RolloverEnsure\] đã nhận lượt, khoá theo người dùng, `leaseUntil` = nhận + 5 phút (BR-18) | – |
| `XONG` | Giao dịch commit; lưu `rolledCount`, `archivedCount`, `skippedCount` | Toast MSG-11 nếu `archivedCount` > 0: ngay khi lượt xong nếu lượt chạy lúc mở app (UC-07), ngược lại lần mở app kế tiếp (B07) |
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
| 6 | Hệ thống | Toast MSG-01 "… · Hoàn tác · Mở task · Đóng" ≥ 5 giây; Ctrl+Z hoàn tác (chốt 09/11/2026, B06) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Shift+Z hoặc menu "Lên đầu backlog (Shift+Z)" | Bỏ qua bước 2–3; \[TaskMove\] `{backlogBucket: next_week, position: top}` (BR-03); toast MSG-02 có Hoàn tác |
| A2 | Kéo task vào trang Backlog (SCR-01) / panel Backlog (SCR-09) | Thả vào bucket hoặc folder nào thì chuyển vào đó; toast MSG-01 có Hoàn tác như phím Z (QC-13 mục 2, A2) |
| A3 | Bấm "Mở task" trong toast | Mở chi tiết task (G02) |
| A4 | Bấm Hoàn tác trên MSG-01 / MSG-02 hoặc Ctrl+Z | \[TaskMove\] `{undoToken}` trả cả cụm vị trí cũ (ngày dự định, vị trí, `firstPlannedDate`) và khôi phục liên kết timebox; sự kiện ngoài đã bị xoá được G05 tạo lại với giờ cũ (QC-05, BR-17) |
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
| A6 | Kéo task giữa bucket / folder / thứ tự | \[TaskMove\] `{backlogBucket, folderId, afterId / beforeId}`. Sang bucket khác: toast MSG-01 có Hoàn tác; đổi thứ tự trong cùng bucket: không toast, Ctrl+Z hoàn tác (QC-13 mục 2, A2) |
| A7 | Bấm nút biểu đồ | Hiện tổng thời lượng theo bucket và channel `[giả định]` |
| A8 | Bucket rỗng | Empty state MSG-04 |
| A9 | Shift+B hoặc panel phải → Backlog | Mở **SCR-09** panel Backlog gọn ở panel phải (\[BacklogList\]): cùng 6 bucket với SCR-01, không có phần lọc; kéo task ra board (UC-03) hoặc từ board vào (UC-01 A2) (chốt 09/11/2026, C09) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tên folder rỗng / > 50 ký tự | MSG-05 |
| E2 | Tên folder trùng | MSG-06 |
| E3 | Folder thứ 51 | MSG-07 |
| E4 | \[BacklogList\] lỗi | Dữ liệu lưu trên máy + QC-MSG-02 "Chưa tải được. Thử lại" tại chỗ trong SCR-01 / SCR-09 (QC-13 mục 1, chốt 09/11/2026, C07) |

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
| 4 | Hệ thống | Toast MSG-03 có Hoàn tác, như phím S / menu (QC-13 mục 2, chốt 09/11/2026, A2) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phím S trên task backlog | `startDate` = hôm nay; toast MSG-03 |
| A2 | Menu Ngày dự định → chọn ngày trên lịch | `startDate` = ngày chọn; ngày < hôm nay disabled; toast MSG-03 |
| A3 | Kéo vào lịch (timebox) | `startDate` = ngày làm việc của ô (QC-01); tạo timebox theo G05 |
| A4 | Ritual đưa task từ bucket tới kỳ vào ngày (G08; G09 Weekly planning (1.1)) | Cùng \[TaskMove\], áp BR-05 |
| A5 | Instance lặp, ngày D đã có instance cùng series (QC-06 mục 1) | Vẫn đặt; toast cảnh báo MSG-21 (BR-05) |
| A6 | Bấm Hoàn tác trên MSG-03 hoặc Ctrl+Z | \[TaskMove\] `{undoToken}`: task về đúng bucket, folder và vị trí cũ trong Backlog, `startDate` = null (QC-13 mục 5, chốt 09/11/2026, A10) |

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
| 7 | Hệ thống | Phát `task.upserted` cho task bị đổi, `day.recomputed` cho hôm nay; gửi G05 yêu cầu gỡ liên kết timebox quá khứ (bất đồng bộ, không xoá sự kiện ngoài); task vừa lưu trữ (`stale`, `skipped`) xử lý timebox như "Đưa vào backlog" (BR-11, BR-12; Q42, D6) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Job lỡ nhiều mốc hoặc task có `startDate` cách hôm nay > 1 ngày | Chuyển một lần về hôm nay; số ngày bị hoãn tính từ `firstPlannedDate` nên phản ánh đủ số ngày làm việc đã lỡ (BR-07, EC-05) |
| A2 | Người dùng đổi timezone / mốc đầu ngày trong ngày | Cài đặt mới có hiệu lực từ ngày làm việc kế tiếp; ngày hiện tại kết thúc và rollover theo cài đặt cũ; đã có lượt `XONG` thì không chạy lại (BR-22, Q3, EC-06) |
| A3 | Người dùng đang mở board / chi tiết task | Card chuyển cột qua realtime; chi tiết đang mở không đóng, ngày hiển thị cập nhật |
| A4 | Client offline qua mốc | Khi mở app hiển thị rollover tạm trên máy theo BR-06, BR-07, chỉ để hiển thị, không vào hàng đợi đồng bộ (QC-08 mục 5); có mạng thì gọi \[RolloverEnsure\] và lấy kết quả server làm chuẩn |
| A5 | Task đang chạy timer | Rollover bình thường; timer không dừng (QC-05) |
| A6 | Không có task thoả BR-06 | Ghi lượt `XONG` với số liệu 0 |
| A7 | Phiên Daily shutdown của ngày cũ đang làm (Q18, BR-20, G08 BR-21) | `CHO_SHUTDOWN`; job các lượt sau kiểm lại; nhận sự kiện `ritual.shutdown.closed` (phiên hoàn tất / bỏ dở theo G08 BR-21) thì chạy ngay; tới mốc + 2 giờ thì chạy dù phiên còn mở |
| A8 | Workspace chỉ đọc (bản 1.1, BR-21) | Không chạy. Khi thoát chỉ đọc: chạy bù một lần cho hôm nay; không tính các ngày bị đóng băng vào số ngày bị hoãn |
| A9 | Lượt `DANG_CHAY` hết lease (worker chết) | Lượt job kế tiếp hoặc \[RolloverEnsure\] nhận lại, chạy từ bước 2 (BR-18) |
| A10 | Hôm nay không có trong lịch chung hoặc lịch của task (ví dụ Thứ Bảy) | Vẫn chạy như luồng chính (BR-06, Q32); số ngày bị hoãn của task không tăng nếu hôm nay không có trong lịch của task (BR-10); tự lưu trữ xét theo n như thường (BR-12) |
| A11 | Người dùng muốn trả lại kết quả rollover | Không có Hoàn tác (Q41, BR-16); người dùng kéo / chọn ngày (G04) hoặc đưa vào backlog (UC-01) |
| A12 | Instance lặp quá khứ chưa xong đã sửa riêng (`customized`) hoặc đã có thời gian thực tế | Không chuyển `skipped`; rollover như task thường ở bước 4–5, kể cả khi hôm nay đã có instance của series (BR-11, chốt 09/11/2026, B08) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi CSDL giữa chừng | Rollback toàn bộ lượt của người dùng; `LOI`; lượt job kế tiếp thử lại; lần lỗi thứ 3 → `THAT_BAI`, cảnh báo giám sát (BR-18) |
| E2 | Gỡ liên kết timebox ở G05 lỗi | Không chặn rollover; G05 thử lại theo cơ chế `timebox.push` |
| E3 | `THAT_BAI` | Job định kỳ không thử nữa; lần mở app kế tiếp client gọi \[RolloverEnsure\] (UC-07) |

### UC-05 Tự lưu trữ (trong job `rollover`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Sau UC-04 bước 4, task có số ngày bị hoãn ≥ 4 `[giả định]` (QC-04 mục 5, ngưỡng cố định B10); Tự lưu trữ bật; task không có hoạt động (BR-12, B11) |
| Hậu điều kiện thành công | Task ở `LUU_TRU`; không còn trên hôm nay; không tính khối lượng ngày |
| Hậu điều kiện thất bại | Như UC-04 (rollback cả lượt) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | `LUU_TRU`: `archivedAt` = now, `archiveReason = stale` (BR-12) |
| 2 | Hệ thống | Xử lý timebox theo BR-12; ghi nhật ký "Lưu trữ: bị hoãn {n} ngày" |
| 3 | Hệ thống | Cộng `archivedCount` vào `rollover_runs` |
| 4 | Hệ thống | Toast MSG-11 có link "Xem Lưu trữ": lượt chạy ngay lúc mở app (\[RolloverEnsure\], UC-07) → hiện ngay khi lượt chạy xong; lượt do job chạy trước đó → hiện lần mở app kế tiếp (chốt 09/11/2026, B07) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tự lưu trữ tắt | Bỏ qua UC-05; task ở `KE_HOACH` hôm nay, nhãn "Dời {n} ngày" |
| A2 | Task đang chạy timer | Không lưu trữ ở lượt này `[giả định]`; xét lại ở lượt ngày sau |
| A3 | Người dùng muốn trả lại task vừa tự lưu trữ | Không có Hoàn tác (Q41); khôi phục từ Lưu trữ (UC-06). Timebox tương lai đã gỡ, sự kiện ngoài đã xoá ở bước 2 không được tạo lại (BR-12) |
| A4 | Task có subtask đã tích hoặc đã có thời gian thực tế | Không lưu trữ; task ở `KE_HOACH` hôm nay, nhãn "Dời {n} ngày" (BR-12, chốt 09/11/2026, B11) |

### UC-06 Xem Lưu trữ, khôi phục và xoá tất cả

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Khôi phục: task về `KE_HOACH` hôm nay hoặc về `BACKLOG` (B12), số ngày bị hoãn = 0 (BR-14). Xoá tất cả: mọi task Lưu trữ ở `DA_XOA` (BR-15). Toggle: cài đặt Tự lưu trữ lưu |
| Hậu điều kiện thất bại | Lưu trữ không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Panel phải → Lưu trữ (Shift+A, G04) |
| 2 | Hệ thống | Gọi \[ArchiveList\]; mở **SCR-05**, mới lưu trữ nhất trước |
| 3 | Người dùng | Bấm "Khôi phục" trên một dòng → chọn "Khôi phục vào hôm nay" (BR-14, B12) |
| 4 | Hệ thống | Gọi \[TaskRestore\] `{from: archive}`; áp BR-14; task hiện đầu hôm nay; toast MSG-14 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Xoá tất cả" | Mở **SCR-06** (MSG-15) → xác nhận → \[ArchiveDeleteAll\]; toast MSG-16 có Hoàn tác |
| A2 | Bật / tắt "Tự lưu trữ" | \[SettingsUpdate\] `autoArchive` (G01); áp từ lượt rollover kế tiếp |
| A3 | Kéo task từ Lưu trữ vào cột ngày D | \[TaskRestore\] `{from: archive, startDate: D}`; D ≥ hôm nay (BR-14); toast MSG-14 có Hoàn tác (QC-13 mục 2, A2) |
| A4 | Lưu trữ rỗng | Empty state MSG-19 |
| A5 | Cuộn hết trang | Tải tiếp theo cursor, 50 dòng / lần |
| A6 | Khôi phục instance lặp vào ngày đã có instance cùng series | Vẫn khôi phục; toast cảnh báo MSG-21 (QC-06 mục 3) |
| A7 | Mở task lưu trữ từ kết quả tìm kiếm (G04) | Mở **SCR-08** chi tiết task chỉ xem (chốt 09/11/2026, C08), có nút "Khôi phục" với hai lựa chọn như SCR-05 → bước 4 hoặc A8 |
| A8 | Chọn "Khôi phục vào Backlog" | \[TaskRestore\] `{from: archive, backlogBucket: next_week}`; áp BR-14; task vào đầu bucket "Tuần tới" `[giả định]`; toast MSG-26 có Hoàn tác (chốt 09/11/2026, B12) |
| A9 | Bấm Hoàn tác trên MSG-14 / MSG-26 / MSG-16 hoặc Ctrl+Z | \[TaskMove\] `{undoToken}` (MSG-16: `undoToken` của \[ArchiveDeleteAll\]): mọi task về lại Lưu trữ với `archivedAt`, `archiveReason` cũ (QC-13 mục 5, A10); không tạo lại timebox; ngày ngoại lệ của instance lặp vẫn giữ (BR-15) |

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
| 5 | Hệ thống | Trả `{date, status, rolledCount, archivedCount, skippedCount}`; client lấy kết quả server làm chuẩn; lượt vừa chạy có `archivedCount` > 0 → hiện MSG-11 ngay (UC-05 bước 4, B07) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | `DANG_CHAY` còn lease (job đang chạy) | Chờ tối đa 10 giây `[giả định]`; xong thì trả kết quả, chưa xong thì trả `DANG_CHAY`; client nhận kết quả sau qua realtime |
| A2 | Trong lúc chờ phản hồi hoặc khi trả `DANG_CHAY` | Board hiện rollover tạm trên máy, chỉ để hiển thị (QC-08 mục 5) `[giả định]` |
| A3 | `CHO_SHUTDOWN` (BR-20) | Không ép chạy; trả `status = CHO_SHUTDOWN`, `waitUntil` = mốc đầu ngày + 2 giờ; task ngày cũ hiển thị ở cột ngày cũ |
| A4 | Workspace chỉ đọc (bản 1.1) | Không chạy; trả `status = DONG_BANG` (BR-21) |
| A5 | Gọi lặp nhiều lần (nhiều thiết bị, G04 và G08 cùng gọi) | Idempotent theo người dùng + ngày (BR-13); chỉ một request chạy, các request khác đi theo A1 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Chạy trong request lỗi | Rollback; tăng số lần lỗi theo BR-18 (đã `THAT_BAI` thì giữ `THAT_BAI`); trả `ROLLOVER_FAILED` → MSG-25 có "Thử lại" |
| E2 | Timeout / mất mạng | Giữ rollover tạm trên máy; gọi lại khi có mạng |

## 6. Điểm vào

| **Điểm vào** | **App Windows** (1.0) | **Web, macOS** (1.1) | **iOS / Android** (1.2) | **Ghi chú** |
| --- | --- | --- | --- | --- |
| Sidebar "Backlog" / phím B | ✓ | ✓ | ✓ | Mở SCR-01 |
| Panel phải → Backlog / Shift+B | ✓ | ✓ | – | Mở SCR-09 (UC-02 A9, C09) |
| Phím Z / Shift+Z trên task | ✓ | ✓ | – | UC-01 |
| Menu Ngày dự định → "Chuyển vào backlog", "Lên đầu backlog" | ✓ | ✓ | ✓ | SCR-03 |
| Kéo task vào panel Backlog (panel phải, SCR-09) | ✓ | ✓ | – | UC-01 A2 |
| Kéo item tích hợp vào panel Backlog (bản 1.1) | ✓ (từ 1.1) | ✓ | – | G11 UC-04 A7; SCR-01 #9, SCR-09 |
| Panel phải → Lưu trữ / Shift+A | ✓ | ✓ | ✓ | Mở SCR-05 |
| Toast MSG-11 → "Xem Lưu trữ" | ✓ | ✓ | ✓ | Mở SCR-05 |
| Command menu Ctrl+K (⌘K trên macOS) | ✓ | ✓ | – | "Chuyển vào backlog", "Mở Backlog", "Mở Lưu trữ" |
| Mở app lần đầu trong ngày làm việc (G04) / bước "Xem lại hôm qua" (G08) | ✓ | ✓ | ✓ | UC-07, không có giao diện riêng |

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
| 9 | Đích thả item tích hợp (bản 1.1) | Vùng thả (bucket) | Trang / panel Backlog nhận item kéo từ panel tích hợp; G11 tạo task qua \[TaskFromItem\] ở `BACKLOG` với `backlogBucket` = bucket thả (G11 BR-05, UC-04 A7, C34). Bucket và việc chống trùng theo G11 |

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
| 2 | "Tự lưu trữ" | Toggle | UC-06 A2 |
| 3 | "Xoá tất cả" | Button (nguy hiểm) | Mở SCR-06; disabled khi rỗng |
| 4 | Danh sách task | List | Mỗi dòng: tiêu đề, #channel, thời lượng, ngày lưu trữ, nhãn lý do theo `archiveReason` (MSG-12 / MSG-13; MSG-22 bỏ ở 1.0 — Q34). Gồm cả instance `skipped`, nhãn "Đã bỏ qua" (B09). Bấm dòng → SCR-08 |
| 5 | "Khôi phục" | Button (theo dòng) + menu | Hai lựa chọn: "Khôi phục vào hôm nay" (UC-06 bước 3) · "Khôi phục vào Backlog" (UC-06 A8) (B12) |
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
| 2 | Màu | Trạng thái | n = ngưỡng Tự lưu trữ − 1 đổi màu cảnh báo (lượt sau sẽ lưu trữ nếu bật) `[giả định]` |

### SCR-08 Chi tiết task chỉ xem (mở từ Lưu trữ)

Chốt 09/11/2026, C08. Dialog chi tiết task của G02 (SCR-03) ở chế độ chỉ xem, mở từ SCR-05 hoặc kết quả tìm kiếm (UC-06 A7).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung task | Các trường của G02 SCR-03 | Chỉ xem, không sửa được |
| 2 | Nhãn lý do | Nhãn | MSG-12 / MSG-13 theo `archiveReason` |
| 3 | "Khôi phục" | Button + menu | Như SCR-05 #5: "Khôi phục vào hôm nay" · "Khôi phục vào Backlog"; xong thì đóng dialog |
| 4 | Đóng | Button / Esc | Đóng, focus về nơi mở |

### SCR-09 Panel Backlog gọn (panel phải)

Chốt 09/11/2026, C09. Mục Backlog của panel phải (Shift+B, IA mục 4). Dùng cùng dữ liệu và bucket với SCR-01, bỏ phần lọc.

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Bucket | Section thu gọn được | Như SCR-01 #5 (6 bucket theo BR-01, số task, tổng thời lượng; rỗng → MSG-04) |
| 2 | Task card | Card (G02 SCR-02) | Như SCR-01 #7; kéo ra cột ngày trên board (UC-03), kéo giữa bucket (UC-02 A6) |
| 3 | Đích thả | Vùng thả (bucket) | Nhận task kéo từ board (UC-01 A2); từ 1.1 nhận item tích hợp như SCR-01 #9 |
| 4 | Lỗi tải | Tại chỗ | QC-MSG-02 có "Thử lại" (UC-02 E4) |

Không có: nút nhóm theo channel, lọc channel, nút biểu đồ, "Thêm folder" và menu folder (SCR-01 #2, #3, #4, #6), panel ngày (SCR-01 #8).

## 8. API

API dưới đây là hợp đồng nghiệp vụ tham khảo; kiểu API, tên, mã lỗi, hạ tầng job: tech chốt — `docs/tech/` (Q45).

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[BacklogList\] `GET /tasks/backlog` | bucket, folderId, channelId, cursor, limit ≤ 200 | Task[] (theo bucket), totals {bucket: count, plannedMin}, nextCursor | 5s / 1 lần |
| \[TaskMove\] `POST /tasks/{id}/move` | `{backlogBucket, folderId?, position?: top}` \| `{startDate, afterId?, beforeId?}` \| `{undoToken}`, version, Idempotency-Key | Task (cụm vị trí, `firstPlannedDate`, `postponedDays`), undoToken, `warnings[]` (`SERIES_SAME_DAY`) | 5s / retry 2 lần cùng key |
| \[BacklogFolderList\] `GET /backlog-folders` | – | Folder[] | 5s / 1 lần |
| \[BacklogFolderCreate\] / \[BacklogFolderUpdate\] / \[BacklogFolderDelete\] `POST / PATCH / DELETE /backlog-folders` | name, position | Folder | 5s / 1 lần |
| \[TaskCreate\] `POST /tasks` (G02) | title, backlogBucket, folderId, … | Task | Theo G02 |
| \[ArchiveList\] `GET /tasks/archive` | cursor, limit 50 | Task[] (archivedAt, archiveReason ∈ {stale, skipped}, postponedDays), nextCursor | 5s / 1 lần |
| \[TaskRestore\] `POST /tasks/{id}/restore` | `{from: archive, startDate?}` (mặc định hôm nay; ≥ hôm nay) \| `{from: archive, backlogBucket}` (B12) | Task, undoToken, `warnings[]` (`SERIES_SAME_DAY`) | 5s / 2 lần |
| \[ArchiveDeleteAll\] `POST /tasks/archive/delete-all` `[giả định — chưa có trong danh sách API]` | Idempotency-Key | deletedCount, undoToken | 10s / 1 lần |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | autoArchive, rolloverPosition, keepPriorityLevels (tập mức, C16) | Settings | 5s / 2 lần |
| \[Rollover\] (job nội bộ) | userId, date | rolledCount, archivedCount, skippedCount (không có `undoToken`, Q41) | Mỗi người dùng một giao dịch; lease 5 phút; thử lại ở lượt job kế tiếp, 3 lần lỗi → `THAT_BAI` (BR-18) |
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
| 5xx / timeout khi lưu | MSG-17 (QC-MSG-01) |
| 5xx / timeout khi tải \[BacklogList\] | QC-MSG-02 (C07) |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | {tiêu đề} đã chuyển vào {bucket} trong Backlog · Hoàn tác · Mở task · Đóng (Hoàn tác: chốt 09/11/2026, B06) |
| MSG-02 | Toast | Đã đưa "{tiêu đề}" lên đầu Backlog · Hoàn tác |
| MSG-03 | Toast | Đã chuyển "{tiêu đề}" sang {ngày} · Hoàn tác |
| MSG-04 | Empty state | Chưa có task nào |
| MSG-05 | Inline | Tên folder từ 1 đến 50 ký tự |
| MSG-06 | Inline | Folder này đã tồn tại |
| MSG-07 | Inline | Bạn đã có tối đa {max} folder |
| MSG-08 | Dialog | Xoá folder "{tên}"? {n} task trong folder vẫn ở lại Backlog |
| MSG-09 | Tooltip | Dời {n} ngày · dự định từ {ngày dự định đầu tiên} |
| MSG-10 | – | (dự phòng) |
| MSG-11 | Toast | Đã lưu trữ {n} task bị hoãn từ {ngưỡng} ngày làm việc trở lên · Xem Lưu trữ (C06) |
| MSG-12 | Header / nhãn | Bị hoãn từ {ngưỡng} ngày làm việc trở lên |
| MSG-13 | Nhãn | Đã bỏ qua (B09) |
| MSG-14 | Toast | Đã khôi phục "{tiêu đề}" về {hôm nay / ngày} · Hoàn tác |
| MSG-15 | Dialog | Xoá tất cả {n} task trong Lưu trữ? Task sẽ nằm trong Thùng rác 30 ngày |
| MSG-16 | Toast | Đã chuyển {n} task vào Thùng rác · Hoàn tác |
| MSG-17 | Toast | Chưa lưu được thay đổi. Thử lại (dùng QC-MSG-01, QC-13 mục 1) |
| MSG-18 | Banner | (Bản 1.1) Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-19 | Empty state | Không có task nào được lưu trữ |
| MSG-20 | Toast | Task này không còn tồn tại |
| MSG-21 | Toast cảnh báo | Ngày này đã có {tên series} (dùng G03 MSG-21, QC-06) |
| MSG-22 | – | (Bỏ ở 1.0 — Q34, bản sau) Bạn đã lưu trữ |
| MSG-23 | Toast | Task đã thay đổi trên thiết bị khác |
| MSG-24 | Toast | Không thể đặt task chưa xong vào ngày đã qua |
| MSG-25 | Banner | Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại (BR-24; G04 MSG-27 dùng nội dung này) |
| MSG-26 | Toast | Đã khôi phục "{tiêu đề}" vào Backlog · Hoàn tác (B12) |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Z / Shift+Z ẩn task ≤ 100 ms (lạc quan); \[TaskMove\] p95 ≤ 300 ms; SCR-01 tải ≤ 500 ms với 1.000 task backlog (danh sách ảo hoá) |
| Job rollover | 95% người dùng có lượt `XONG` ≤ 15 phút sau mốc đầu ngày (B6; không tính người dùng ở `CHO_SHUTDOWN`); một người dùng ≤ 500 ms với 200 task; lease 5 phút |
| \[RolloverEnsure\] | p95 ≤ 2 s khi phải chạy lượt trong request `[giả định]` |
| Toàn vẹn | `UNIQUE(user_id, date)` trên `rollover_runs`; một giao dịch / người dùng; chạy lại không chuyển hai lần (BR-13); job tăng `version` của task (QC-08) |
| Offline | Theo QC-08. Backlog lưu trên máy (cơ chế: tech chốt — `docs/tech/`); chuyển vào / ra backlog chạy được khi mất mạng; cụm vị trí ghi nguyên khối, lệnh trên phiên bản cũ bị từ chối; rollover tạm trên máy chỉ để hiển thị, không vào hàng đợi đồng bộ, server là chuẩn |
| Đồng bộ | Kết quả rollover và thay đổi backlog hiện trên thiết bị khác ≤ 5 giây |
| Bảo mật | Chỉ chủ task xem / sửa backlog, Lưu trữ; job chỉ xử lý task của đúng người dùng trong lượt |
| Log / audit | \[ActivityLog\] theo BR-16; log job: người dùng, ngày, trạng thái lượt, số lần thử, số chuyển / lưu trữ / bỏ qua, thời gian chạy, nguồn (job / ensure); không chứa tiêu đề |
| Giám sát | Cảnh báo khi lượt `LOI` > 0,1% / giờ, khi có lượt `THAT_BAI`, khi lease hết hạn bất thường, hoặc khi tỉ lệ `XONG` ≤ 15 phút sau mốc < 95% |
| Tracking | Sự kiện: `backlog_opened`, `task_moved_to_backlog` (bucket, nguồn: Z / Shift+Z / menu / kéo), `task_moved_from_backlog`, `backlog_folder_created`, `rollover_completed` (rolled, archived, skipped, nguồn: job / ensure, độ trễ sau mốc), `rollover_failed`, `rollover_ensure_called` (trạng thái trả về, nơi gọi: G04 / G08), `archive_opened`, `task_restored_from_archive` (đích: hôm nay / ngày / Backlog), `archive_deleted_all`, `auto_archive_toggled` |
| Accessibility | Mọi kéo thả có cách bằng phím / menu (Z, S, menu Ngày dự định); nhãn "Dời {n} ngày" có nhãn đọc màn hình "Bị hoãn {n} ngày"; tương phản WCAG 2.1 AA ở cả giao diện sáng / tối |
