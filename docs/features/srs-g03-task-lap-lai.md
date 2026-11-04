> **Mã:** PLN-SRS-G03-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g03-task-lap-lai.md

# UC-G03 - Task lặp lại trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả series lặp: bật lặp, sinh instance, sửa instance, sửa / dừng series, ngày ngoại lệ, quy tắc instance trùng series trong một ngày. Mô hình task và thao tác task thường (G02), board và projection (G04), timebox và lập lịch cứng (G05, bản 1.1), rollover và Lưu trữ (G06) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). Quy tắc `QC-xx` ở [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md). G03 sở hữu **QC-06** (instance trùng series trong một ngày); trạng thái instance theo QC-03 (G02); "hôm nay" là ngày làm việc (QC-01).
>
> Cập nhật thêm theo vòng 5–6: nhãn `WEEKDAYS` là "Thứ Hai–Thứ Sáu" và quy tắc lặp không theo lịch làm việc (Q43, BR-01, BR-03); sửa giờ timebox của instance là sửa riêng `customized` (Q44, BR-07, bảng phạm vi); bản 1.0 là app Windows cho một người dùng (Q35, Q45, [ADR-0005](../adr/0005-nen-tang-windows-truoc.md)).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng biến task thành series lặp trong vài giây; instance có sẵn 60 ngày tới; sửa một instance không hỏi phạm vi; thao tác cả series qua một menu; không có hai instance cùng series do hệ thống đặt trong một ngày |
| Actor | Người dùng đã đăng nhập · Hệ thống (job `recurrence.generate`, job `rollover` của G06) |
| Phạm vi | Picker lặp (6 quy tắc, khoảng lặp, giờ "khoảng"), tạo series, sinh instance, ngày ngoại lệ, banner series, Trước / Sau, menu "Sửa series" (6 thao tác) và bảng phạm vi, danh sách series, quy tắc instance trùng series trong một ngày (QC-06) |
| Ngoài phạm vi | Rollover và Lưu trữ (G06), projection (G04), timebox và lập lịch cứng (G05, bản 1.1, Q7), ngày kết thúc series, lặp theo ngày hoàn thành, lặp theo lịch làm việc / khung giờ channel (Q43), objective (G09), giao task (bản sau, Q35), chế độ chỉ đọc (1.1, QC-09) |
| Nền tảng | App **Windows** (Flutter) ở 1.0, một người dùng, dữ liệu trên cloud gắn tài khoản (Q45, ADR-0005). Web, macOS từ 1.1; iOS / Android từ 1.2, dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Đặt task lặp theo ngày, Thứ Hai–Thứ Sáu, tuần, tháng, năm | Không tạo lại việc định kỳ bằng tay |
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
| BR-01 | **Quy tắc lặp.** `DAILY`, `WEEKDAYS` (nhãn hiển thị "Thứ Hai–Thứ Sáu", **không** gọi "Ngày làm việc"; luôn là Thứ Hai đến Thứ Sáu, Q43), `WEEKLY` (1–7 thứ), `MONTHLY_DAY` (ngày 1–31), `MONTHLY_NTH` (thứ 1–4 / cuối cùng `[giả định]` + thứ trong tuần), `YEARLY` (ngày / tháng). Khoảng lặp `interval` 1–99 (trừ `WEEKDAYS`). Giới hạn lấy từ \[AppConfig\] |
| BR-02 | **Bật lặp** (C14). Chỉ cho task `KE_HOACH` hoặc `BACKLOG`; task `HOAN_THANH` → không bật lặp được (409 `TASK_COMPLETED`, MSG-22). Task không có ngày (backlog) → coi ngày dự định là hôm nay `[giả định]`. Tạo Series với `weekStart` (BR-03) và `anchorDate` = ngày khớp quy tắc **đầu tiên** ≥ max(ngày dự định của task, hôm nay). Task trở thành instance đầu: `seriesDate` = `startDate` = `anchorDate`; nếu ngày dự định đã khớp quy tắc thì giữ nguyên ngày, ngược lại task được dời theo đường "chọn ngày" của QC-05 `[giả định]`. Task đã thuộc series `DANG_LAP` → mở "Đổi tần suất" thay vì tạo series mới; lệnh bật lặp tới sau cho cùng task (hai thiết bị offline) → 409 `ALREADY_REPEATING`, MSG-23 (QC-08 mục 4) |
| BR-03 | **Tính ngày.** Ngày khớp quy tắc tính từ `anchorDate`, chỉ theo ngày (không giờ). `MONTHLY_DAY` 29–31 → ngày cuối tháng ở tháng ngắn hơn, tháng sau dùng lại ngày đã chọn. `YEARLY` 29/2 → 28/2 năm không nhuận. **Ngày đầu tuần** lấy từ cài đặt của người dùng (G01) lúc tạo series, lưu cố định trên series (`weekStart`); đổi cài đặt sau này không đổi lịch của series đã có (C14). "Mỗi N tuần" đếm tuần theo `weekStart` tính từ tuần chứa `anchorDate`. **Không theo lịch làm việc** (Q43): ngày khớp quy tắc chỉ phụ thuộc quy tắc, không đọc lịch làm việc chung (G01) hay khung giờ channel (G02 BR-22); ví dụ lịch làm việc có Thứ Bảy thì `WEEKDAYS` vẫn không sinh Thứ Bảy, lịch làm việc bỏ Thứ Tư thì `DAILY` vẫn sinh Thứ Tư. Lịch làm việc của task (QC-02 mục 6) chỉ áp cho instance như task thường: projection, sức chứa (G04), số ngày bị hoãn (QC-04), "ngày làm việc kế tiếp" khi dời |
| BR-04 | **Sinh instance.** Job `recurrence.generate` sinh mọi ngày khớp quy tắc trong khoảng (max(`generatedUntil`, hôm qua), hôm nay + 60 ngày]; `generatedUntil` khởi tạo = `anchorDate`. **Không sinh**: ngày < hôm nay (C14); ngày thuộc danh sách ngày ngoại lệ (BR-15); ngày gốc đã có instance còn gắn series. Khoá duy nhất `(series_id, series_date)` chỉ áp trên instance còn gắn series và chưa bị xoá vĩnh viễn; ngày người dùng đã bỏ được chặn bằng ngày ngoại lệ, không bằng khoá (Q26). Job idempotent. (1.1) Workspace chỉ đọc → dừng sinh; khi thoát chỉ sinh ngày ≥ hôm nay (QC-09) |
| BR-05 | **Trường sao chép.** Instance mới lấy từ mẫu của series: tiêu đề, notes, channel, `plannedMin`, `approxTime`; priority và subtask (chưa xong) `[giả định]`. Không sao chép comment, objective, timebox, thời gian thực tế, nhật ký; ngoại lệ: series đã được "Gắn cho cả series" với một objective thì instance sinh ra có ngày dự định trong tuần của objective đó được chép `objectiveId` (G09 BR-25). Mẫu = ảnh chụp task lúc bật lặp, chỉ đổi qua BR-08 (c) và khi channel của mẫu bị xoá (G02 BR-14, C10) |
| BR-06 | **Giờ.** Instance không cố định giờ, hiện projection (G04). `approxTime` chỉ hiện trên card. **Bản 1.0 không tạo timebox cho instance.** Lập lịch cứng cho task lặp (cửa sổ 7 ngày `[giả định]`) do G05 sở hữu, phát hành bản 1.1 (Q7), đặc tả ở G05 BR-23 / UC-09; G03 chỉ lưu `approxTime` làm đầu vào |
| BR-07 | **Sửa một instance** chỉ đổi instance đó, không hỏi phạm vi, không đổi mẫu. Dời ngày instance giữ ngày gốc (`seriesDate`); mọi đường đổi ngày áp QC-06 (BR-16). Hoàn thành / xoá instance theo G02; hoàn thành giữ nguyên ngày dự định (G02 BR-08 d, Q12); xoá → ngày gốc thành ngày ngoại lệ (BR-15). Không ảnh hưởng instance khác. Xoá instance đầu không dừng series. Sửa riêng một trường thuộc BR-05 (trừ tích / bỏ tích subtask) đặt cờ `customized = true` `[giả định]`. **Sửa giờ timebox** của instance (đổi giờ bắt đầu / kết thúc hoặc thời lượng của timebox, kể cả kéo trên lịch; đổi giờ sự kiện ở lịch ngoài được đồng bộ về theo G05 cũng tính `[giả định]`) đặt `customized = true` (Q44), ở 1.0 với timebox người dùng tự tạo và từ 1.1 với timebox lập lịch cứng (G05 BR-23 e). Đặt mới hoặc gỡ timebox cũng đặt cờ này `[giả định]`. Cờ chỉ bật, không tự tắt. Dời ngày được nhận biết qua `startDate` ≠ `seriesDate`. Hệ quả với bảng phạm vi: instance `customized` (kể cả chỉ vì sửa giờ timebox) nằm ở cột "đã dời / sửa riêng" |
| BR-08 | **Sửa series** (menu "Sửa series"), phạm vi từng thao tác theo **bảng phạm vi** dưới đây (C12). (a) **Dừng lặp**: `stoppedAt` = now, không sinh thêm. (b) **Đổi tần suất**: cập nhật quy tắc, so khớp theo **ngày gốc** (Q26), rồi chạy UC-02 sinh ngày mới. (c) **Cập nhật mọi instance chưa xong theo task này**: chép trường BR-05 của instance đang mở vào mẫu và các instance trong phạm vi; subtask gộp theo tiêu đề để giữ tiến độ (C12). (d) **Xoá mọi instance chưa xong và dừng lặp**: xoá mềm các instance trong phạm vi, dừng series; cần xác nhận `[giả định]`. (e) **Đặt giờ bắt đầu**: đặt / xoá `approxTime` cho mẫu và các instance trong phạm vi. (f) **Quản lý mọi task lặp**: mở SCR-05. Mọi thao tác (a)–(e) không đụng instance `LUU_TRU`, `DA_XOA` (C12) và áp BR-17 cho instance có timer hoặc thời gian thực tế (C13) |
| BR-09 | Mọi thao tác BR-08 (a)–(e) có Hoàn tác trong toast ≥ 5 giây; Hoàn tác trả quy tắc, mẫu và các instance bị ảnh hưởng về như trước: instance bị xoá hẳn được tạo lại, instance bị tách được gắn lại series, liên kết timebox và sự kiện ngoài khôi phục theo QC-05. Hoàn tác **không** chạy lại timer đã bị dừng (BR-17) |
| BR-10 | **Instance bị bỏ lỡ**: theo QC-06 (BR-16), G06 thực thi trong rollover. Series đã có instance hôm nay (QC-06 mục 1, B5) → instance quá khứ chưa xong chuyển `LUU_TRU`, `archiveReason = skipped`, chỉ ghi nhật ký (EC-30). Series chưa có instance hôm nay → chỉ instance quá khứ mới nhất (ngày gốc lớn nhất) rollover, các instance cũ hơn → `skipped` `[giả định]`. Instance được rollover tính số ngày bị hoãn như task thường (QC-04) |
| BR-11 | "Hôm nay" là ngày làm việc theo QC-01. Đổi timezone không đổi ngày dự định và ngày gốc đã sinh (QC-01 mục 4) |
| BR-12 | Tối đa 200 series `DANG_LAP` / người dùng `[giả định]`. Series đã dừng không bật lại; bật Lặp lại trên một instance của series đã dừng → tạo series mới từ instance đó |
| BR-13 | Nhật ký (\[ActivityLog\], G02): bật lặp, đổi quy tắc, áp mẫu, dừng ghi trên instance thực hiện; instance do job sinh ghi tác nhân `system` "Tạo từ series {tiêu đề}"; instance bị tách ghi "Tách khỏi series do đổi tần suất"; thêm ngày ngoại lệ ghi trên series |
| BR-14 | Series thuộc người dùng tạo; chỉ người đó xem và sửa. Bản 1 chỉ một người dùng; workspace nhiều thành viên và giao task để bản sau (Q35, G12) |
| BR-15 | **Ngày ngoại lệ** (Q26). Series lưu danh sách `exceptionDates`. Người dùng xoá một instance (G02 UC-04, BR-08 d) → ngày gốc của instance đó thêm vào danh sách, **vĩnh viễn**: khôi phục instance từ Thùng rác, Hoàn tác, hay Thùng rác xoá vĩnh viễn sau 30 ngày đều không gỡ ngày ngoại lệ. Instance do hệ thống xoá hẳn khi đổi quy tắc (BR-08 b) không tạo ngày ngoại lệ. Job không bao giờ sinh instance cho ngày ngoại lệ (BR-04). Instance đã tách khỏi series bị xoá không tạo ngày ngoại lệ |
| BR-16 | **Instance trùng series trong một ngày**: G03 sở hữu quy tắc **QC-06**. "Ngày đã có instance" theo QC-06 mục 1 (B5). Đường tự động / hàng loạt (rollover G06, phím D G04, shutdown "Ngày mai" G08) → instance được đưa vào chuyển `LUU_TRU` lý do `skipped`, toast Hoàn tác (rollover chỉ ghi nhật ký). Đường thủ công từng task (kéo thả, chọn ngày G04; khôi phục G02, G06) → cho phép, cảnh báo "Ngày này đã có {tên series}" — thông báo gốc là G03 MSG-21; G02 MSG-24, G04 MSG-23, G06 MSG-21 dùng lại nội dung này. Nhóm sở hữu từng đường thực thi, G03 không tự chặn |
| BR-17 | **Timer và thời gian thực tế khi đổi hoặc dừng series** (C13). Instance trong phạm vi BR-08 (a), (b), (d) đang chạy timer → dừng timer (G07) trước khi áp thao tác. Instance có bản ghi thời gian (kể cả vừa dừng timer) → **không xoá**: giữ lại; với (b) nếu ngày gốc không khớp quy tắc mới thì tách khỏi series như instance đã dời / sửa riêng. Toast nêu số instance được giữ (MSG-24) |

**Bảng phạm vi sửa series** (BR-08; C12, C13, Q26). "Gắn series" = instance còn `seriesId` của series này. "Hôm nay", "tương lai" so theo ngày dự định của instance.

| **Thao tác** | **`KE_HOACH` tương lai, chưa dời, chưa sửa riêng (kể cả chưa sửa giờ timebox), không có thời gian thực tế** | **`KE_HOACH` tương lai đã dời / sửa riêng (gồm sửa giờ timebox, Q44) / có thời gian thực tế** | **`KE_HOACH` hôm nay** | **`KE_HOACH` quá khứ (chưa rollover)** | **`HOAN_THANH`** | **`LUU_TRU`, `DA_XOA`** | **Mẫu** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| (a) Dừng lặp | Xoá mềm `[giả định]` | Đã dời / sửa riêng: xoá mềm `[giả định]`. Có thời gian thực tế: giữ (BR-17) | Giữ | Giữ | Giữ | Không đụng | Giữ, series `DA_DUNG` |
| (b) Đổi tần suất | Ngày gốc khớp quy tắc mới → giữ; không khớp → **xoá hẳn**, không tạo ngày ngoại lệ (BR-15) | Ngày gốc khớp → giữ; không khớp → giữ và **tách khỏi series** (Q26, BR-17), banner MSG-25 | Giữ (EC-29) | Giữ (EC-29) | Giữ | Không đụng | Quy tắc mới |
| (c) Cập nhật theo task này | Chép trường BR-05; subtask gộp theo tiêu đề | Như cột trước (ghi đè cả phần sửa riêng); timebox giữ nguyên vì không thuộc BR-05; cờ `customized` giữ | Như cột trước | Giữ | Giữ | Không đụng | Chép trường BR-05 |
| (d) Xoá mọi instance chưa xong và dừng | Xoá mềm, tạo ngày ngoại lệ (BR-15) | Xoá mềm; có thời gian thực tế → giữ (BR-17) | Như cột trước | Như cột trước | Giữ | Không đụng | Giữ, series `DA_DUNG` |
| (e) Đặt giờ bắt đầu | Đặt / xoá `approxTime` | Như cột trước; instance có timebox giữ nguyên timebox, không dời theo `approxTime` | Như cột trước | Giữ | Giữ | Không đụng | Đặt / xoá `approxTime` |

**Gộp subtask theo tiêu đề** ở (c) (C12): subtask trên instance có cùng tiêu đề với subtask của mẫu mới → giữ trạng thái xong và thời gian thực tế, cập nhật thời lượng và thứ tự; subtask mới trong mẫu → thêm ở `CHUA_XONG`; subtask không còn trong mẫu → gỡ nếu chưa xong và chưa có thời gian thực tế, ngược lại giữ `[giả định]`.

Instance bị xoá mềm, xoá hẳn hay tách có timebox → xử lý timebox theo QC-05 dòng "Xoá" (tách: giữ timebox như task thường).

**Hệ quả của Q44 (sửa giờ timebox = sửa riêng).** Instance chỉ khác mẫu ở giờ timebox vẫn thuộc cột "đã dời / sửa riêng": (a) Dừng lặp → xoá mềm `[giả định]`, timebox theo QC-05 dòng "Xoá"; (b) Đổi tần suất, ngày gốc không khớp → **không** bị xoá hẳn mà được giữ, tách khỏi series cùng timebox (MSG-24, MSG-25); (c) Cập nhật theo task này → nội dung bị ghi đè, timebox giữ; (d) Xoá mọi instance chưa xong → xoá mềm, timebox theo QC-05 dòng "Xoá"; (e) Đặt giờ bắt đầu → chỉ đổi `approxTime`. Từ bản 1.1, lập lịch cứng (G05 BR-23) không ghi đè timebox của instance `customized`.

## 4. Trạng thái

### 4.1. Trạng thái series

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_LAP` | `stoppedAt` trống | Banner "Task này lặp lại {quy tắc}"; biểu tượng lặp trên card; job sinh instance |
| `DA_DUNG` | `stoppedAt` có giá trị | Banner "Series đã dừng lặp" trên instance còn lại; trong SCR-05 ở bộ lọc "Đã dừng"; job bỏ qua |

Chuyển trạng thái: `DANG_LAP` → `DA_DUNG` (UC-05, BR-08 a, d). `DA_DUNG` → `DANG_LAP` chỉ qua Hoàn tác trong toast; sau đó không bật lại (BR-12). Đổi tần suất, áp mẫu, đặt giờ không đổi trạng thái series.

### 4.2. Trạng thái instance

Instance dùng đúng bộ trạng thái task của **QC-03** (G02), không có trạng thái riêng. Bảng dưới chỉ ghi điểm riêng của instance.

| **Trạng thái** (QC-03) | **Điểm riêng của instance** | **Hiển thị** |
| --- | --- | --- |
| `KE_HOACH` | Có ngày gốc (`seriesDate`) không đổi khi dời | Card trên cột ngày dự định, giờ projection hoặc `approxTime`, biểu tượng lặp |
| `BACKLOG` | Instance bị đưa vào backlog vẫn giữ ngày gốc | Panel Backlog (G06), biểu tượng lặp |
| `HOAN_THANH` | Hoàn thành giữ nguyên ngày dự định (G02 BR-08 d) | Như task xong (G02); không bị BR-08 thay đổi |
| `LUU_TRU` | Lý do `skipped` khi áp QC-06 đường tự động (BR-16); `stale` khi bị hoãn lâu (QC-04) | Chỉ trong Lưu trữ (G06), nhãn lý do theo G06: `skipped` G06 MSG-13, `stale` G06 MSG-12; BR-08 không đụng |
| `DA_XOA` | Ngày gốc đã thành ngày ngoại lệ nếu do người dùng xoá (BR-15) | Thùng rác (G02); BR-08 không đụng |

Thuộc tính, không phải trạng thái: **tách khỏi series** (`seriesId` = null, giữ `detachedFromSeriesId` để tra cứu, BR-08 b), `customized` (BR-07).

## 5. Use Case

### UC-01 Bật lặp cho task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; task ở `KE_HOACH` hoặc `BACKLOG` (không `HOAN_THANH`, `LUU_TRU`, `DA_XOA`); task chưa thuộc series `DANG_LAP`; (từ 1.1) workspace không chỉ đọc (QC-09) |
| Hậu điều kiện thành công | Series `DANG_LAP` được tạo; task là instance đầu; instance 60 ngày tới đã sinh (UC-02) |
| Hậu điều kiện thất bại | Không có series; task không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … của task (card / chi tiết, SCR-04 của G02) → "Lặp lại" |
| 2 | Hệ thống | Mở **SCR-01**, điền mặc định từ `startDate` (BR-03): thứ, ngày trong tháng, "thứ N" |
| 3 | Người dùng | Chọn quy tắc, thứ, khoảng lặp, (tuỳ chọn) giờ "khoảng"; bấm "Lưu" |
| 4 | Hệ thống | Kiểm tra BR-01; gọi \[SeriesCreate\] (idempotency key) |
| 5 | Hệ thống | Server tạo series (BR-02: `weekStart`, `anchorDate`, instance đầu), gọi sinh instance đồng bộ cho 14 ngày đầu `[giả định]`, phần còn lại do job (UC-02) |
| 6 | Hệ thống | Đóng SCR-01; toast MSG-01; card task có biểu tượng lặp; instance mới hiện trên board qua realtime |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Task trong backlog | Instance đầu đặt hôm nay (BR-02); MSG-01 nêu ngày |
| A2 | Chọn `MONTHLY_DAY` 29–31 hoặc `YEARLY` 29/2 | Hiện ghi chú MSG-04 / MSG-05 dưới ô ngày, vẫn cho lưu |
| A3 | Task đã thuộc series `DANG_LAP` | Mục "Lặp lại" mở SCR-01 ở chế độ "Đổi tần suất" (UC-04) |
| A4 | Task thuộc series `DA_DUNG` | Tạo series mới từ task này (BR-12) |
| A5 | Bấm ra ngoài / Esc | Đóng SCR-01, không lưu |
| A6 | Ngày dự định của task không khớp quy tắc (ví dụ task Thứ Ba, quy tắc Hằng tuần Thứ Hai) | Instance đầu = ngày khớp đầu tiên sau đó (Thứ Hai kế tiếp); task dời sang ngày đó (BR-02); MSG-01 nêu ngày |
| A7 | Chọn "Hằng tuần" với N ≥ 2 | SCR-01 hiện ngày đầu tuần sẽ cố định cho series (BR-03) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | `interval` ngoài 1–99 | MSG-02 tại ô, nút Lưu disabled |
| E2 | `WEEKLY` không chọn thứ nào | MSG-03, nút Lưu disabled |
| E3 | Đã có 200 series đang lặp | MSG-14 có link "Quản lý mọi task lặp" |
| E4 | Mất mạng | Lưu vào hàng đợi (QC-08); card có biểu tượng "chờ đồng bộ"; instance chỉ hiện khi server sinh xong |
| E5 | \[SeriesCreate\] lỗi 5xx / timeout | MSG-12 có "Thử lại"; task không đổi |
| E6 | (1.1) Workspace chỉ đọc (QC-09) | MSG-13, không tạo |
| E7 | Task đã `HOAN_THANH` | Mục "Lặp lại" disabled, tooltip MSG-22; API trả 409 `TASK_COMPLETED` (BR-02, C14) |
| E8 | Task đã được bật lặp trên thiết bị khác (lệnh offline tới sau) | 409 `ALREADY_REPEATING`; bỏ lệnh khỏi hàng đợi, tải lại task và series, MSG-23 (QC-08 mục 4) |

### UC-02 Sinh instance (job `recurrence.generate`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có series `DANG_LAP` với `generatedUntil` < hôm nay + 60 ngày |
| Hậu điều kiện thành công | Mọi ngày khớp quy tắc từ hôm nay tới hôm nay + 60 ngày, trừ ngày ngoại lệ, có đúng một instance gắn series; `generatedUntil` cập nhật |
| Hậu điều kiện thất bại | Series giữ `generatedUntil` cũ; lần chạy sau sinh bù |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job chạy mỗi giờ `[giả định]`, chọn series `DANG_LAP` của người dùng vừa qua mốc đầu ngày (QC-01) hoặc có `generatedUntil` < hôm nay + 60 ngày; cũng chạy ngay sau UC-01, UC-04 |
| 2 | Hệ thống | Tính danh sách ngày khớp quy tắc trong (max(`generatedUntil`, hôm qua), hôm nay + 60] theo BR-03; loại ngày ngoại lệ (BR-15) |
| 3 | Hệ thống | Với mỗi ngày: chèn instance theo mẫu (BR-05), `startDate = seriesDate`, không timebox; ngày gốc đã có instance gắn series → bỏ qua (BR-04) |
| 4 | Hệ thống | Cập nhật `generatedUntil`; ghi nhật ký `system` (BR-13) |
| 5 | Hệ thống | Phát `task.upserted` cho từng instance và `day.recomputed` cho các ngày bị ảnh hưởng (G04) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | (Bỏ ở 1.0 — lập lịch cứng do G05 sở hữu, bản 1.1, Q7; xem BR-06, G05 BR-23 / UC-09) | – |
| A2 | Job không chạy nhiều ngày (sự cố) | Lần chạy sau sinh bù khoảng còn thiếu từ hôm nay; ngày trong quá khứ không sinh (C14) |
| A3 | `YEARLY` / interval lớn, không có ngày nào trong khoảng | Chỉ cập nhật `generatedUntil` |
| A4 | (1.1) Workspace chỉ đọc | Bỏ qua series của workspace đó; khi thoát chỉ đọc sinh bù từ hôm nay (QC-09) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi CSDL giữa chừng | Mỗi series một giao dịch; rollback series đó, thử lại 3 lần backoff 1–5–15 phút `[giả định]`; quá 3 lần ghi log cảnh báo |
| E2 | (Bỏ — xoá channel đã chuyển cả mẫu series sang channel nhận, G02 BR-14, C10) | – |

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
| A4 | Dời instance sang ngày khác | Theo G04 và QC-05; giữ ngày gốc (BR-07). Ngày đích đã có instance của cùng series → áp QC-06 (BR-16): kéo thả / chọn ngày cho phép kèm MSG-21; phím D → instance chuyển `LUU_TRU` lý do `skipped`, toast Hoàn tác |
| A5 | Series `DA_DUNG` | Banner MSG-15; không có Trước / Sau tới instance đã xoá |
| A6 | Hoàn thành instance ở ngày tương lai | Giữ nguyên ngày dự định (G02 BR-08 d, Q12) |
| A7 | Xoá instance | Theo G02 UC-04 A4; ngày gốc thành ngày ngoại lệ (BR-15) |
| A8 | Instance đã tách khỏi series | Banner MSG-25 thay SCR-02; không có "Sửa series", Trước / Sau |
| A9 | Đổi giờ / thời lượng timebox của instance (G05: kéo trên lịch, sửa giờ) | Áp theo G05; instance đặt `customized = true` (BR-07, Q44); không hỏi phạm vi, mẫu series không đổi. Đặt mới / gỡ timebox: cũng đặt cờ `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi khi lưu | Như G02 UC-02 E4: trả trường về giá trị cũ, hiện MSG-10 của G02 |
| E2 | Instance liền kề đã bị xoá khi bấm Trước / Sau | Bỏ qua, mở instance kế tiếp còn tồn tại |

### UC-04 Sửa series: đổi tần suất, đặt giờ, áp nội dung

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Series `DANG_LAP`; người dùng đang mở một instance |
| Hậu điều kiện thành công | Quy tắc / giờ / mẫu cập nhật; instance bị ảnh hưởng cập nhật theo BR-08 (b), (c), (e) và bảng phạm vi |
| Hậu điều kiện thất bại | Series và instance không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Banner → "Sửa series" → **SCR-03** → "Đổi tần suất" |
| 2 | Hệ thống | Mở SCR-01 với quy tắc hiện tại |
| 3 | Người dùng | Đổi quy tắc, bấm "Lưu" |
| 4 | Hệ thống | Gọi \[SeriesUpdate\] với `If-Match` version; server áp BR-08 (b) theo bảng phạm vi (so khớp ngày gốc) trong một giao dịch, rồi chạy UC-02 |
| 5 | Hệ thống | Toast MSG-07 với số instance thay đổi, có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Cập nhật mọi instance chưa xong theo task này" | Gọi \[SeriesApplyFrom\] với id instance đang mở; áp BR-08 (c) theo bảng phạm vi, subtask gộp theo tiêu đề; toast MSG-08 |
| A2 | "Đặt giờ bắt đầu" | Mở chọn giờ (bước 15 phút) + "Xoá giờ"; \[SeriesUpdate\] `approxTime`; áp BR-08 (e); toast MSG-18 |
| A3 | Bấm Hoàn tác | Gọi \[SeriesUpdate\] / \[SeriesApplyFrom\] với `undoToken`; khôi phục theo BR-09 |
| A4 | Quy tắc mới giống quy tắc cũ | Đóng SCR-01, không gọi API |
| A5 | Có instance quá khứ, hôm nay, đã xong, `LUU_TRU` hoặc `DA_XOA` (EC-29, C12) | Giữ nguyên |
| A6 | Có instance tương lai đã dời, sửa riêng (gồm sửa giờ timebox, Q44), đang chạy timer hoặc có thời gian thực tế mà ngày gốc không khớp quy tắc mới | Dừng timer nếu đang chạy; giữ instance và tách khỏi series (BR-08 b, BR-17); toast MSG-07 kèm MSG-24 |

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
| Hậu điều kiện thành công | Series `DA_DUNG`; instance bị xoá mềm hoặc giữ theo BR-08 (a) hoặc (d) và bảng phạm vi |
| Hậu điều kiện thất bại | Series `DANG_LAP`, instance không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-03 → "Dừng lặp" |
| 2 | Hệ thống | Gọi \[SeriesStop\]; server đặt `stoppedAt`, áp BR-08 (a) theo bảng phạm vi (xoá mềm instance tương lai chưa xong, trừ instance có thời gian thực tế) |
| 3 | Hệ thống | Gỡ instance khỏi board; timebox của instance bị xoá xử lý theo QC-05 dòng "Xoá"; toast MSG-09 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Xoá mọi instance chưa xong và dừng lặp" | Mở **SCR-04** (MSG-10, số instance) → "Xoá và dừng" → \[SeriesStop\] `deleteIncomplete=true`; áp BR-08 (d); toast MSG-11 có Hoàn tác |
| A2 | Instance trong phạm vi đang chạy timer | Dừng timer (G07); instance đã có thời gian thực tế → giữ, không xoá (BR-17, C13); toast kèm MSG-24 |
| A3 | Bấm Hoàn tác | Khôi phục các instance và đặt lại series `DANG_LAP` (BR-09); timer đã dừng không chạy lại |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Series đã dừng ở thiết bị khác | 409 `SERIES_STOPPED` → MSG-15, làm mới |
| E2 | Lỗi 5xx / timeout | MSG-12; không xoá instance nào |

### UC-06 Xử lý instance trùng series trong một ngày (QC-06; rollover G06, phím D G04, shutdown G08)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng vừa qua mốc đầu ngày (QC-01) và có instance chưa xong với ngày dự định < hôm nay; hoặc một đường đổi ngày đưa instance vào ngày D |
| Hậu điều kiện thành công | Đường tự động / hàng loạt không bao giờ để hai instance của cùng series trong một ngày; instance thừa ở `LUU_TRU` lý do `skipped`. Đường thủ công cho phép, có cảnh báo |
| Hậu điều kiện thất bại | Instance giữ nguyên; lần chạy sau xử lý lại (idempotent, G06) |

**Luồng chính** (rollover)

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job `rollover` (G06) nhóm instance chưa xong quá khứ theo `seriesId` |
| 2 | Hệ thống | Hôm nay đã có instance của series (ngày gốc hoặc ngày dự định = hôm nay, trạng thái `KE_HOACH` hoặc `HOAN_THANH`; QC-06 mục 1, B5) → mọi instance quá khứ: `LUU_TRU`, `archiveReason = skipped` (BR-10) |
| 3 | Hệ thống | Ghi nhật ký `system` "Bị bỏ qua vì đã có lần lặp hôm nay"; không có toast; phát `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Series chưa có instance hôm nay | Instance quá khứ mới nhất rollover theo G06; instance cũ hơn → `skipped` `[giả định]` (BR-10) |
| A2 | Series `DA_DUNG` | Không áp BR-10; instance rollover như task thường (G06) |
| A3 | Người dùng khôi phục instance `skipped` từ Lưu trữ, hoặc instance từ Thùng rác, vào ngày đã có instance | Đường thủ công (QC-06 mục 3): cho phép, cảnh báo MSG-21 (G06 / G02 hiển thị) |
| A4 | Phím D (G04) hoặc shutdown "Ngày mai" (G08, kể cả "Áp dụng cho tất cả") đưa instance vào ngày đã có instance | Đường tự động / hàng loạt (QC-06 mục 2): instance được đưa vào chuyển `LUU_TRU` lý do `skipped`, toast Hoàn tác (G04 / G08 hiển thị) |
| A5 | Kéo thả hoặc chọn ngày (G04) đưa instance vào ngày đã có instance | Đường thủ công: cho phép, cảnh báo MSG-21 |
| A6 | Instance đã tách khỏi series | Không áp QC-06 (không còn thuộc series) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi giữa chừng | Rollback theo người dùng; G06 xử lý thử lại theo G06 BR-18: lượt `LOI` được thử lại ở lượt job kế tiếp (lease 5 phút), 3 lần lỗi → `THAT_BAI`, chạy bù qua \[RolloverEnsure\] khi người dùng mở app (G06 BR-19) |

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

| **Điểm vào** | **App Windows** (1.0) | **Web, macOS** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Menu … của task → "Lặp lại" | ✓ | ✓ | Mở SCR-01 (UC-01, hoặc UC-04 nếu đã lặp) |
| Command menu Ctrl/Cmd+K → "Lặp lại" | ✓ | ✓ | Task đang chọn / hover |
| Banner series → "Sửa series" | ✓ | ✓ | Mở SCR-03 |
| Banner series → Trước / Sau | ✓ | ✓ | UC-03 A1 |
| Cài đặt → "Task lặp lại" | ✓ | ✓ | Mở SCR-05 |

## 7. Mô tả màn hình

### SCR-01 Picker lặp lại

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Lặp | Dropdown | Có | Hằng ngày · Thứ Hai–Thứ Sáu (`WEEKDAYS`; không dùng nhãn "Ngày làm việc", Q43) · Hằng tuần · Hằng tháng vào ngày {D} · Hằng tháng vào {thứ N} {thứ} · Hằng năm vào {ngày/tháng} |
| 2 | Vào (thứ) | Nhóm 7 nút | Có khi Hằng tuần | Thứ tự bắt đầu từ ngày đầu tuần (BR-03); mặc định thứ của `startDate`; bỏ hết → MSG-03 |
| 3 | Mỗi N | Số + đơn vị | Có (trừ Thứ Hai–Thứ Sáu) | 1–99; sai → MSG-02 |
| 4 | Vào khoảng | Time picker | Không | Bước 15 phút; có "Không đặt giờ"; chỉ hiện trên card, không tạo timebox ở 1.0 (BR-06) |
| 5 | Ghi chú ngày đặc biệt | Hint | – | MSG-04 / MSG-05 khi chọn 29–31 hoặc 29/2 |
| 6 | Mô tả quy tắc | Text | – | Câu đọc được, ví dụ "Mỗi 2 tuần vào Thứ Ba, Thứ Năm" |
| 7 | "Lưu" | Button | – | Disabled khi vi phạm BR-01 |
| 8 | Ngày đầu tuần | Hint | – | Hiện khi Hằng tuần, N ≥ 2: MSG-26 (BR-03, UC-01 A7) |
| 9 | Lần đầu | Hint | – | "Lần đầu: {ngày}" = `anchorDate` dự kiến (BR-02) |

### SCR-02 Banner series (đầu chi tiết instance)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Mô tả | Text | MSG-06; series dừng → MSG-15; instance đã tách → MSG-25 (UC-03 A8) |
| 2 | "Sửa series" | Link | Mở SCR-03; ẩn khi series `DA_DUNG` hoặc instance đã tách |
| 3 | "Trước" / "Sau" | Button | UC-03 A1, A2; ẩn khi instance đã tách |

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
| \[SeriesCreate\] `POST /tasks/{id}/repeat` | rule {type, interval, weekdays[], monthDay, nth, weekday, month}, approxTime, Idempotency-Key | Series (`weekStart`, `anchorDate`, `exceptionDates`), Task (instance đầu), instances 14 ngày đầu | 5s / retry 3 lần cùng key |
| \[SeriesUpdate\] `PATCH /series/{id}` | rule và / hoặc approxTime, If-Match | Series, version, affectedCount, deletedCount, detachedCount, keptCount, undoToken | 5s / 2 lần |
| \[SeriesApplyFrom\] `POST /series/{id}/apply-from/{taskId}` | Idempotency-Key | affectedCount, undoToken | 5s / 2 lần cùng key |
| \[SeriesStop\] `POST /series/{id}/stop` | `?deleteIncomplete=true` (tuỳ chọn) | Series (stoppedAt), deletedCount, keptCount, undoToken | 5s / 2 lần |
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
| `TASK_COMPLETED` (409) | MSG-22 |
| `ALREADY_REPEATING` (409) | MSG-23 |
| `WORKSPACE_READ_ONLY` (402, từ 1.1) | MSG-13 |
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
| MSG-10 | Dialog | Xoá {n} lần chưa xong của "{tiêu đề}" và dừng lặp? Các lần đã xong và các lần đã có thời gian thực tế được giữ lại. Task xoá nằm trong Thùng rác 30 ngày |
| MSG-11 | Toast | Đã xoá {n} lần và dừng lặp · Hoàn tác |
| MSG-12 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-13 | Banner | (1.1) Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-14 | Inline | Bạn đã có {n} task lặp đang chạy, tối đa {max}. Dừng bớt trong "Quản lý mọi task lặp" |
| MSG-15 | Banner | Series này đã dừng lặp |
| MSG-16 | Toast | Series vừa được sửa trên thiết bị khác, đã tải lại |
| MSG-17 | Toast | Task hoặc series này không còn tồn tại |
| MSG-18 | Toast | Đã đặt giờ {giờ} cho các lần chưa xong · Hoàn tác |
| MSG-19 | Empty state | Chưa có task lặp lại nào. Mở menu … của một task → "Lặp lại" để bắt đầu |
| MSG-20 | Tooltip | Lần kế tiếp: {ngày} |
| MSG-21 | Toast | Ngày này đã có {tên series} |
| MSG-22 | Tooltip / Toast | Task đã hoàn thành không bật lặp được |
| MSG-23 | Toast | Task này đã được đặt lặp lại trên thiết bị khác, đã tải lại |
| MSG-24 | Toast | {k} lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại |
| MSG-25 | Banner | Lần này đã tách khỏi series "{tiêu đề}" do đổi tần suất |
| MSG-26 | Hint | Tuần tính từ {thứ}; giữ cố định cho task lặp này |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Nền tảng | App Windows (Flutter) ở 1.0 (Q45, ADR-0005); job sinh instance chạy trên server (dữ liệu trên cloud), không phụ thuộc app đang mở. Kiến trúc cụ thể do tech chốt (`docs/tech/`) |
| Hiệu năng | \[SeriesCreate\] p95 ≤ 500 ms (gồm sinh 14 ngày đầu); instance 60 ngày hiện đủ trên board ≤ 5 giây; job sinh ≤ 50 ms / series |
| Toàn vẹn | Khoá duy nhất `(series_id, series_date)` trên instance còn gắn series (BR-04); ngày ngoại lệ lưu trên series, độc lập vòng đời task (BR-15); job idempotent, chạy lại không tạo trùng; thao tác series trong một giao dịch |
| Offline | Bật lặp, sửa instance chạy được khi mất mạng (hàng đợi, QC-08); hai thiết bị cùng bật lặp một task → lệnh tới sau bị từ chối `ALREADY_REPEATING`; thao tác series (BR-08) cần mạng, nút disabled kèm tooltip khi offline |
| Đồng bộ | Instance mới, thay đổi series hiện trên thiết bị khác ≤ 5 giây (`task.upserted`, `day.recomputed`) |
| Bảo mật | Chỉ chủ series đọc / sửa (BR-14); kiểm tra quyền trên cả series và task trong mọi API |
| Log / audit | \[ActivityLog\] theo BR-13; log job: số series, số instance tạo, lỗi; không chứa tiêu đề / notes |
| Giám sát | Cảnh báo khi tỉ lệ lỗi job > 0,1% / ngày hoặc có series `generatedUntil` < hôm nay + 53 ngày |
| Tracking | Sự kiện: `repeat_picker_opened`, `series_created` (rule type), `series_frequency_changed`, `series_applied_from_task`, `series_time_set`, `series_stopped` (deleteIncomplete), `series_instance_skipped` (đường: rollover / phím D / shutdown), `series_same_day_warning`, `series_instance_detached`, `series_instance_customized` (nguồn: trường nội dung / giờ timebox), `series_exception_added`, `series_list_opened` |
| Accessibility | SCR-01 điều khiển hoàn toàn bằng bàn phím; nút thứ có nhãn đọc màn hình đầy đủ ("Thứ Hai"); lựa chọn `WEEKDAYS` đọc là "Thứ Hai đến Thứ Sáu"; biểu tượng lặp có nhãn "Task lặp lại: {quy tắc}" |
