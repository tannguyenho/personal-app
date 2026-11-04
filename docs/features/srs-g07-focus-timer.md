> **Mã:** PLN-SRS-G07-WEB · **Trạng thái:** đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g07-focus-timer.md

# UC-G07 - Focus & theo dõi thời gian trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). G07 sở hữu quy tắc **bản ghi thời gian QC-07** trong [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); SRS này hiện thực QC-07 và tham chiếu QC-01 (ngày làm việc), QC-05 (đổi ngày task), QC-08 (đồng bộ), QC-09 (chế độ chỉ đọc, 1.1). Tên kỹ thuật `TimeEntry` trong API / CSDL là bản ghi thời gian. SRS này mô tả timer, thời gian thực tế (bản ghi thời gian), Focus mode và giám sát timer (**1.0**); Pomodoro, màn nghỉ, nhắc nghỉ desktop, phím tắt toàn cục Ctrl+Shift+Space, chế độ chỉ đọc (**1.1**); Focus Bar desktop (**1.2**). Mỗi UC, BR, SCR thuộc 1.1 / 1.2 được ghi rõ phiên bản; không ghi là 1.0. Hoàn thành / xoá task (G02), khối thực tế trên lịch (G05), Daily shutdown (G08), analytics (G09), đổi status Slack / Teams khi bật timer (G11, 1.2), trung tâm thông báo (G12) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng đo thời gian thực tế của task bằng một phím, sửa được khi quên; làm một việc một lúc trong Focus mode; timer quên tắt được phát hiện và xử lý |
| Actor | Người dùng đã đăng nhập · Hệ thống (job `timer.watchdog`, dịch vụ đồng bộ) · Hệ điều hành Windows (thông báo hệ thống, khay hệ thống — 1.0 `[giả định]`; phím tắt toàn cục 1.1; Focus Bar 1.2) |
| Phạm vi | Timer trên task cha, một timer toàn tài khoản, bản ghi thời gian (QC-07; nguồn `timer` / `manual` / `auto_closed` / `ritual`), nhập tay (E) theo thời lượng hoặc khoảng giờ, Focus mode, âm báo theo kế hoạch, nhắc > 4 giờ, tự đóng > 24 giờ, đồng bộ nhiều thiết bị; Pomodoro, nghỉ (1.1); Focus Bar (1.2) |
| Ngoài phạm vi | Khối thực tế trên lịch (G05), "Tính planned là actual" (G02; chỉ hiển thị, QC-07 mục 4), thời điểm ritual tạo bản ghi (G08), DND Slack / Teams (G11), cộng số liệu theo ngày / tuần và báo cáo thời gian (chỉ G09, QC-07 mục 5), Toggl, chặn website |
| Nền tảng | App Windows (Flutter) ở 1.0 (Q45, ADR-0005). Web, macOS từ 1.1; iOS / Android từ 1.2 dùng cùng đặc tả; Focus Bar chỉ app desktop (Windows, macOS; 1.2). Chạy nền, khay hệ thống, thông báo Windows, phím tắt toàn cục: tech chốt — `docs/tech/` |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Bật / dừng timer của task bằng Space hoặc một lần bấm | Đo thời gian thật mà không rời kế hoạch |
| US-02 | (Bỏ — timer chạy trên task cha, xem QC-07 mục 6 / C20) | | |
| US-03 | Người dùng | Nhập bù, sửa, xoá thời gian đã làm | Số liệu đúng dù quên bật timer |
| US-04 | Người dùng | Vào Focus mode chỉ thấy một task | Tập trung, ít nhiễu |
| US-05 | Người dùng | Nghe báo khi sắp hết thời lượng kế hoạch | Không làm quá giờ dự kiến |
| US-06 | Người dùng (1.1) | Làm theo phiên Pomodoro và nghỉ có đếm ngược | Giữ nhịp làm việc bền |
| US-07 | Người dùng | Được nhắc khi timer chạy quá lâu | Không để số liệu sai cả ngày |
| US-08 | Người dùng (1.2) | Thấy task và đồng hồ đang chạy trên mọi cửa sổ desktop | Không cần quay lại app để biết mình đang làm gì |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Một timer / tài khoản.** Timer đang chạy là một bản ghi thời gian (`TimeEntry`) có `endedAt` trống; khoá duy nhất `UNIQUE(user_id) WHERE ended_at IS NULL`. Bật timer mới → đóng timer cũ với `endedAt` = `startedAt` của timer mới, trong cùng giao dịch, không hỏi |
| BR-02 | **Đích của timer.** Chỉ gắn **task cha** (`taskId`); không gắn subtask (QC-07 mục 6, C20). Task không ở `DA_XOA`, `LUU_TRU`. Task đã xong → được bật, không bỏ hoàn thành `[giả định]` |
| BR-03 | **Task không thuộc hôm nay** (`startDate` ≠ hôm nay theo ngày làm việc QC-01, hoặc backlog) → vẫn chạy, toast MSG-01 (Sunsama "Must focus on today"); không tự đổi ngày task |
| BR-04 | **Dừng timer** → `endedAt` = now (giờ server) hoặc giờ người dùng chọn (UC-06 A6), `source = timer`. Thời lượng < 10 giây → xoá bản ghi `[giả định]`. Thời gian thực tế của task theo QC-07 mục 5 |
| BR-05 | **Nhập tay (E)** — theo QC-07 mục 3 (B11); `source = manual`. (a) **Theo thời lượng** (`entryMode = duration`): `endedAt` = now, `startedAt` = now − thời lượng (chỉ dùng để xác định ngày làm việc); **không** kiểm tra chồng lấn, kể cả với timer đang chạy; không vẽ lên lịch (G05 BR-18). (b) **Theo khoảng giờ** (`entryMode = range`): `endedAt` > `startedAt`; `endedAt` ≤ now; chồng timer đang chạy → từ chối (MSG-18); chồng bản ghi đã đóng → cho lưu, cảnh báo MSG-08; có vẽ lên lịch. Cả hai: mỗi bản ghi 1 phút – 24 giờ (MSG-06). Được nhập cho subtask (`subtaskId`), cộng vào thực tế của task theo QC-07 mục 5 |
| BR-06 | **Hoàn thành / xoá task đang chạy timer** → dừng timer theo BR-04 trước khi G02 xử lý (EC-24, QC-05); áp cả khi task bị hoàn thành / xoá ở thiết bị khác. **Không đường nào khác dừng timer** (Q14, QC-05): phím D, kéo sang ngày khác, rollover, đưa vào backlog, shutdown "Ngày mai" (G08 chỉ nhắc ở bước đầu), AI dời ngày, lưu trữ do trùng series |
| BR-07 | **Âm báo theo kế hoạch.** Còn lại = kế hoạch − thực tế (gồm lượt đang chạy). Chạm mức cài đặt (10 / 5 / 0 phút, mặc định 0) → âm báo (nếu bật) + MSG-10, tối đa một lần / lượt chạy. Task không có kế hoạch → không báo |
| BR-08 | **Nhắc chạy lâu.** Timer chạy liên tục > 4 giờ → một thông báo MSG-11: 1.0 trong app (trung tâm thông báo, G12); từ 1.1 thêm push mobile theo cài đặt Thông báo |
| BR-09 | **Tự đóng.** Timer chạy > 24 giờ → đóng với `endedAt` = `startedAt` + 24 giờ, `source = auto_closed`, `needsReview = true`; lần mở app kế tiếp hiện SCR-06 hỏi giờ dừng thật (EC-23) |
| BR-10 | **Offline nhiều thiết bị** (C20, EC-11). Mỗi lệnh bật / dừng mang `startedAt` / `endedAt` của máy và `clientOpId`. Server xử lý lệnh timer theo **thứ tự nhận** (QC-08): lệnh bật nhận sau cùng là timer đang chạy, timer trước đó đóng theo BR-01. Bản ghi tới server sau mà chồng lên bản ghi `timer` / `auto_closed` đã có thì **bị cắt phần chồng**; bản ghi đã có giữ nguyên `[giả định: bản tới trước giữ, bản tới sau bị cắt]`. Phần còn lại < 10 giây → bỏ. Bị cắt ở giữa (thành hai đoạn) → giữ cả hai đoạn `[giả định]`. Thiết bị có timer bị đóng / bản ghi bị cắt hiện MSG-17 / MSG-22. Không áp cho bản ghi `manual` theo thời lượng (BR-05 a) |
| BR-11 | **Giờ.** Online: `startedAt` / `endedAt` theo giờ server. Offline: giờ máy, server điều chỉnh khi lệch > 2 phút so với giờ server lúc đồng bộ `[giả định]`. Client hiển thị đồng hồ theo `startedAt` + độ lệch server |
| BR-12 | **Focus mode.** Một task; vào bằng F / sidebar Focus / tự vào khi bật timer nếu bật "Vào Focus khi chạy timer" (mặc định tắt). Thoát (Esc) không dừng timer. Không có task chọn → task đầu tiên chưa xong của hôm nay |
| BR-13 | **Pomodoro (1.1).** Phiên 5–90 phút, bước 5, mặc định 25. START = bật timer task (BR-01) + đếm ngược. Hết phiên → dừng timer task, âm báo, gợi ý nghỉ (MSG-12). Trạng thái Pomodoro lưu trên thiết bị, không đồng bộ `[giả định]` |
| BR-14 | **Nghỉ (1.1).** K / "Nghỉ một chút" / hết phiên Pomodoro → dừng timer task; đếm ngược 1–30 phút, mặc định 5; TẠM DỪNG / KẾT THÚC NGHỈ; hết giờ → MSG-13, quay về task; không tự bật lại timer `[giả định]`. Thời gian nghỉ không tạo TimeEntry |
| BR-15 | **Nhắc nghỉ desktop (1.1).** Timer chạy liên tục 25 phút (cài đặt) → thông báo hệ thống MSG-14 gợi ý nghỉ 5 phút; một lần / lượt chạy |
| BR-16 | **Focus Bar (1.2, desktop).** Cài đặt: hiện khi focus / khi đang chạy timer / tắt. Hiển thị tiêu đề task, thực tế / kế hoạch, Dừng, Hoàn thành, Mở app. macOS thêm đồng hồ ở menu bar |
| BR-17 | **Phím tắt.** Space bật / dừng timer task đang chọn; F Focus; K nghỉ (1.1); E nhập tay; Ctrl+Shift+Space toàn cục (desktop, 1.1, C20; không phụ thuộc Focus Bar 1.2). Chỉ hoạt động khi không focus ô nhập; gõ ≥ 4 ký tự / 1 giây → khoá phím tắt 1 giây (EC-25) |
| BR-18 | Nhật ký (\[ActivityLog\], G02): bật / dừng timer, thêm / sửa / xoá bản ghi, tự đóng (tác nhân `system`), timer bị đóng do thiết bị khác |
| BR-19 | **Chế độ chỉ đọc (1.1)** — theo QC-09 (Q8). Lúc workspace vào chỉ đọc: timer đang chạy **tự dừng** với `endedAt` = thời điểm vào chỉ đọc, `source = timer`, nhật ký tác nhân `system`, phát `timer.changed` (lý do `read_only`), MSG-21. Trong chỉ đọc: không bật timer, không thêm / sửa / xoá bản ghi (402, MSG-15). Lệnh offline tạo trước thời điểm vào chỉ đọc được nhận nếu đồng bộ trong 2 giờ; lệnh bật offline được nhận thì đóng tại thời điểm vào chỉ đọc. Bản 1.0 không có chế độ chỉ đọc |
| BR-20 | **Ngày của bản ghi** — theo QC-07 mục 1 (Q13): `workday(startedAt)`, không chia khi vắt qua mốc đầu ngày. Rollover / dời ngày task không đổi ngày của bản ghi đã có |
| BR-21 | **Nguồn `ritual`** — theo QC-07 mục 2. \[TimeEntryCreate\] với `source = ritual` (do G08 gọi) khi người dùng đang có timer chạy → không tạo, trả `skipped: true` (không phải lỗi). Bản ghi `ritual` có giờ thật, không bị cắt theo BR-10 `[giả định]`, sửa / xoá được như bản ghi khác |
| BR-22 | **"Tính planned là actual"** — theo QC-07 mục 4: G07 không tạo bản ghi; thực tế hiển thị trên task theo QC-07 mục 5 dùng cờ `plannedAsActual` G02 lưu lúc hoàn thành. G07 không cộng số liệu theo ngày / tuần (chỉ G09) |

## 4. Trạng thái

### 4.1. Trạng thái timer (theo tài khoản)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `KHONG_CHAY` | Không có bản ghi thời gian `endedAt` trống | Nút ▶ "Bắt đầu timer · Space"; thực tế dạng H:MM |
| `DANG_CHAY` | Có bản ghi thời gian `endedAt` trống, chạy ≤ 4 giờ | Nút dừng "Dừng timer · Space"; thực tế đếm giây màu xanh; badge ở mục Focus; Focus Bar (1.2) |
| `CHAY_LAU` | `DANG_CHAY` và chạy > 4 giờ | Như `DANG_CHAY` + MSG-11 đã gửi; đồng hồ màu cảnh báo |
| `CHO_XAC_NHAN` | Bản ghi `auto_closed`, `needsReview = true` | SCR-06 khi mở app; bản ghi có nhãn "Tự dừng" |

Chuyển trạng thái: `KHONG_CHAY` → `DANG_CHAY` (UC-01) · `DANG_CHAY` → `DANG_CHAY` khi bật task khác (BR-01) · `DANG_CHAY` / `CHAY_LAU` → `KHONG_CHAY` (UC-02, BR-06, BR-14; vào chỉ đọc BR-19, 1.1) · `DANG_CHAY` → `CHAY_LAU` → `CHO_XAC_NHAN` (UC-06) · `CHO_XAC_NHAN` → `KHONG_CHAY` khi người dùng xác nhận giờ dừng.

### 4.2. Trạng thái phiên trên thiết bị (1.1)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `FOCUS` (1.0) | Đang ở Focus mode, tab Focus | SCR-03 |
| `POMODORO` | Tab Pomodoro, đang đếm ngược | SCR-04 "Còn lại 0:24:59" |
| `NGHI` | Màn Break đang đếm ngược | SCR-05 |
| `NGHI_TAM_DUNG` | Bấm TẠM DỪNG trong màn Break | SCR-05, nút TIẾP TỤC |

### 4.3. Trạng thái bản ghi thời gian (`TimeEntry`)

`DANG_MO` (`endedAt` trống) → `DA_DONG` (`source` = `timer` / `manual` / `ritual`) hoặc `TU_DONG` (`auto_closed`, chờ xác nhận) → `DA_DONG` sau SCR-06. Bản ghi `manual` / `ritual` tạo thẳng ở `DA_DONG`. Bản ghi xoá là xoá cứng, có Hoàn tác trong toast. Mỗi bản ghi mang `workday` = `workday(startedAt)` (BR-20) và, với `manual`, `entryMode` (`duration` / `range`, BR-05).

## 5. Use Case

### UC-01 Bật timer

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; task thoả BR-02; workspace không chỉ đọc (1.1) |
| Hậu điều kiện thành công | Timer `DANG_CHAY` trên task; timer cũ (nếu có) đã đóng; mọi thiết bị nhận `timer.changed` |
| Hậu điều kiện thất bại | Timer giữ như trước |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | ▶ trên card (hover) / chi tiết, hoặc Space khi task đang chọn (BR-17) |
| 2 | Hệ thống | Hiện đồng hồ chạy ngay (lạc quan); gọi \[TimerStart\] `{taskId, clientOpId}` |
| 3 | Hệ thống | Server áp BR-01 trong một giao dịch; trả timer mới và timer cũ đã đóng |
| 4 | Hệ thống | Phát `timer.changed`; badge ở mục Focus; nút đổi thành "Dừng timer · Space" |
| 5 | Hệ thống | Có timer cũ ở task khác → toast MSG-02 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Task không thuộc hôm nay | Vẫn chạy; toast MSG-01 (BR-03) |
| A2 | Bật "Vào Focus khi chạy timer" | Sau bước 4 mở SCR-03 |
| A3 | (Bỏ — timer chạy trên task cha, xem QC-07 mục 6 / C20) | |
| A4 | Ctrl+Shift+Space toàn cục (desktop, 1.1) | Bật timer task gần nhất đã chạy, hoặc task đầu tiên chưa xong của hôm nay |
| A5 | Bản ghi `TU_DONG` đang chờ | Hiện SCR-06 trước, rồi mới bật |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Chạy trên máy với `startedAt` giờ máy; xếp hàng đợi; đồng bộ theo UC-07 |
| E2 | Task đã bị xoá / lưu trữ | 404 / 409 → huỷ đồng hồ, MSG-16 |
| E3 | Workspace chỉ đọc (1.1, BR-19) | MSG-15, không bật |
| E4 | \[TimerStart\] lỗi 5xx / timeout sau retry | Huỷ đồng hồ, MSG-09 |

### UC-02 Dừng timer

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Timer `DANG_CHAY` hoặc `CHAY_LAU` |
| Hậu điều kiện thành công | Bản ghi thời gian đóng (BR-04); thực tế cộng dồn; block thực tế hiện trên lịch (G05) |
| Hậu điều kiện thất bại | Timer vẫn chạy |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Space / nút dừng trên card, chi tiết, Focus mode hoặc Focus Bar (1.2) |
| 2 | Hệ thống | Dừng đồng hồ ngay; gọi \[TimerStop\] |
| 3 | Hệ thống | Server đặt `endedAt`; bỏ bản ghi < 10 giây (BR-04); tính lại thực tế |
| 4 | Hệ thống | Phát `timer.changed`, `task.upserted`; thực tế hiện H:MM; G05 vẽ block thực tế |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Hoàn thành / xoá task đang chạy (G02) | Server dừng timer trước trong cùng giao dịch (BR-06, QC-05) |
| A2 | Vào nghỉ (1.1) / hết phiên Pomodoro (1.1) | Dừng như bước 2–4 (BR-13, BR-14) |
| A3 | Dừng ở thiết bị khác | Thiết bị này nhận `timer.changed`, dừng đồng hồ, toast MSG-07 |
| A4 | Task đang chạy bị dời ngày (D, kéo, rollover, backlog, shutdown "Ngày mai", AI) | Không dừng timer (BR-06, Q14); đồng hồ chạy tiếp |
| A5 | Workspace vào chỉ đọc (1.1) | Server tự dừng, `endedAt` = thời điểm vào chỉ đọc (BR-19); mọi thiết bị nhận `timer.changed`, MSG-21 |
| A6 | Lượt chạy vắt qua mốc đầu ngày | Bản ghi thuộc `workday(startedAt)`, không chia (BR-20) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Ghi `endedAt` giờ máy vào hàng đợi; gửi \[TimerStop\] `{endedAt}` khi có mạng |
| E2 | Timer đã bị đóng ở nơi khác | 409 `TIMER_NOT_RUNNING` → tải lại \[TimerGet\], MSG-07 |
| E3 | Lỗi 5xx / timeout | Giữ trạng thái dừng trên máy, xếp hàng đợi, thử lại; MSG-09 nếu quá 3 lần |

### UC-03 Nhập, sửa, xoá thời gian thực tế

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task không ở `DA_XOA`; workspace không chỉ đọc (1.1) |
| Hậu điều kiện thành công | Bản ghi được thêm / sửa / xoá; thực tế tính lại; nhật ký ghi (BR-18) |
| Hậu điều kiện thất bại | Bản ghi không đổi; lỗi tại ô |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Phím E trên task đang chọn / hover, hoặc bấm ô "Thực tế" trong chi tiết |
| 2 | Hệ thống | Gọi \[TimeEntryList\]; mở **SCR-02** |
| 3 | Người dùng | Chọn chế độ, nhập thời lượng (giờ + phút) hoặc khoảng giờ; Enter |
| 4 | Hệ thống | Kiểm tra BR-05 theo chế độ; gọi \[TimeEntryCreate\] `{source: manual, entryMode}`; cập nhật thực tế; toast MSG-03 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Sửa giờ một bản ghi | \[TimeEntryUpdate\]; bản ghi `TU_DONG` sửa xong → `needsReview = false` |
| A2 | Xoá bản ghi | \[TimeEntryDelete\]; toast MSG-04 có Hoàn tác (tạo lại bản ghi) |
| A3 | Nhập cho subtask | Chọn subtask trong SCR-02 hoặc E trên dòng subtask |
| A4 | Khoảng giờ chồng lấn bản ghi đã đóng | Lưu, cảnh báo MSG-08 |
| A5 | Nhập theo thời lượng khi đang có timer chạy hoặc trùng giờ bản ghi khác | Lưu, không kiểm tra chồng lấn, không cảnh báo; không vẽ lên lịch (BR-05 a, B11) |
| A6 | Sửa bản ghi `ritual` / `timer` | Như A1; bản ghi chuyển sang có giờ do người dùng đặt, giữ `source` `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Giờ kết thúc ≤ giờ bắt đầu | MSG-05, không lưu |
| E2 | Bản ghi < 1 phút hoặc > 24 giờ | MSG-06 |
| E3 | Chế độ khoảng giờ: giờ kết thúc ở tương lai / chồng timer đang chạy | MSG-18 |
| E4 | Lỗi 5xx / timeout | MSG-09, giữ nội dung đã nhập |
| E5 | Workspace chỉ đọc (1.1) | MSG-15, không lưu |

### UC-04 Focus mode và âm báo

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; hôm nay có ≥ 1 task chưa xong hoặc có task đang chọn |
| Hậu điều kiện thành công | Focus mode hiển thị một task; timer điều khiển được từ Focus |
| Hậu điều kiện thất bại | Ở lại màn hình hiện tại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Phím F hoặc mục "Focus" ở sidebar |
| 2 | Hệ thống | Chọn task theo BR-12; mở **SCR-03** (tab Focus) |
| 3 | Người dùng | START (hoặc Space) → UC-01; làm việc, đánh dấu subtask, ghi notes |
| 4 | Hệ thống | Khi còn lại chạm mức cài đặt → âm báo + MSG-10 (BR-07) |
| 5 | Người dùng | Esc thoát; timer giữ nguyên |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Hoàn thành task trong Focus | G02 UC-03; Focus gợi ý task kế tiếp chưa xong của hôm nay, "Bắt đầu" hoặc "Thoát" |
| A2 | Đổi task trong Focus | Dropdown tiêu đề → chọn task hôm nay khác; timer không tự chuyển |
| A3 | Hôm nay không có task chưa xong, không có task chọn | Empty state MSG-19 |
| A4 | Tắt âm báo trong cài đặt Focus | Chỉ hiện MSG-10, không phát âm |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Task bị xoá khi đang ở Focus | Đóng Focus, MSG-16 |
| E2 | Trình duyệt chặn phát âm thanh | Chỉ hiện MSG-10; lần đầu gợi ý cho phép âm thanh |

### UC-05 Pomodoro và nghỉ (1.1)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đang ở Focus mode (SCR-03) với một task |
| Hậu điều kiện thành công | Phiên Pomodoro tạo bản ghi thời gian cho task; thời gian nghỉ không tạo bản ghi thời gian |
| Hậu điều kiện thất bại | Phiên dừng, bản ghi thời gian đã chạy vẫn được lưu |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Chọn tab "Pomodoro" → **SCR-04**; chỉnh phiên ▲▼ (mặc định 25 phút) |
| 2 | Người dùng | START |
| 3 | Hệ thống | UC-01 cho task; đếm ngược "Còn lại" trên thiết bị (BR-13) |
| 4 | Hệ thống | Hết phiên → UC-02; âm báo; MSG-12 "Nghỉ {n} phút?" |
| 5 | Người dùng | "Nghỉ" → **SCR-05** đếm ngược 0:05:00 |
| 6 | Hệ thống | Hết giờ nghỉ → âm báo, MSG-13; quay về SCR-04 của task, chưa bật timer |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phím K / "Nghỉ một chút" bất kỳ lúc nào | Dừng timer task (UC-02), mở SCR-05 (BR-14) |
| A2 | TẠM DỪNG / TIẾP TỤC trong màn nghỉ | `NGHI` ⇄ `NGHI_TAM_DUNG` |
| A3 | KẾT THÚC NGHỈ sớm | Quay về task ngay |
| A4 | Bỏ qua nghỉ ở bước 5 | Ở lại SCR-04, sẵn sàng START phiên mới |
| A5 | Desktop: chạy liên tục 25 phút ngoài Pomodoro | Thông báo hệ thống MSG-14 (BR-15); bấm → mở SCR-05 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Timer bị dừng ở thiết bị khác giữa phiên | Dừng đếm ngược, MSG-07 |
| E2 | Thiết bị ngủ khi đang đếm | Khi thức dậy tính theo giờ thực; phiên đã hết thì xử lý như bước 4 |

### UC-06 Giám sát timer chạy lâu (job `timer.watchdog`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có bản ghi thời gian `endedAt` trống |
| Hậu điều kiện thành công | Timer > 4 giờ đã được nhắc đúng một lần; timer > 24 giờ đã tự đóng và chờ xác nhận |
| Hậu điều kiện thất bại | Lượt sau xử lý lại (idempotent theo cờ đã nhắc / đã đóng) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job chạy mỗi 5 phút `[giả định]`, quét timer đang chạy |
| 2 | Hệ thống | Chạy > 4 giờ, chưa nhắc → tạo thông báo MSG-11 (G12; 1.1 thêm push mobile), đặt `longRunNotifiedAt` |
| 3 | Hệ thống | Chạy > 24 giờ → đóng theo BR-09 (`auto_closed`, `needsReview`); phát `timer.changed`; ghi nhật ký `system` |
| 4 | Người dùng | Lần mở app kế tiếp: **SCR-06** (MSG-20); chọn giờ dừng thật, "Lưu" |
| 5 | Hệ thống | \[TimeEntryUpdate\] `{endedAt, needsReview: false}`; thực tế tính lại |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng bấm "Dừng" trong MSG-11 | UC-02 với `endedAt` = now |
| A2 | Người dùng bấm "Vẫn đang làm" | Giữ timer; không nhắc lại trong lượt này |
| A3 | Ở SCR-06 bấm "Giữ 24 giờ" | `needsReview = false`, giữ `endedAt` |
| A4 | Ở SCR-06 bấm "Xoá bản ghi" | \[TimeEntryDelete\], toast MSG-04 |
| A5 | Ở SCR-06 không chọn được giờ | Mặc định giờ hoạt động cuối của người dùng trên app `[giả định]` |
| A6 | Người dùng bấm "Dừng lúc…" trong MSG-11 (B11) | Mở bộ chọn giờ (như SCR-06 #2) trong khoảng (`startedAt`, now], mặc định giờ hoạt động cuối trên app; "Lưu" → \[TimerStop\] `{endedAt}`; áp BR-04 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Gửi thông báo lỗi | Thử lại 3 lần; không chặn bước 3 |
| E2 | Lỗi CSDL ở bước 3 | Rollback, lượt 5 phút sau làm lại |

### UC-07 Đồng bộ timer nhiều thiết bị và offline

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng dùng ≥ 2 thiết bị, hoặc một thiết bị vừa có mạng lại sau khi bật / dừng timer offline |
| Hậu điều kiện thành công | Mọi thiết bị hiển thị cùng một timer; dữ liệu thoả BR-01 |
| Hậu điều kiện thất bại | Thiết bị giữ trạng thái cục bộ, thử lại ở lần kết nối sau |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Thiết bị có mạng lại → gửi hàng đợi qua `POST /sync/batch` theo thứ tự `clientOpId` |
| 2 | Hệ thống | Server xử lý các lệnh timer theo thứ tự nhận (QC-08), chỉnh mốc giờ máy theo BR-11; áp BR-01, BR-10 (cắt phần chồng lấn) |
| 3 | Hệ thống | Phát `timer.changed` với timer đang chạy tới mọi thiết bị |
| 4 | Hệ thống | Thiết bị có timer bị đóng hiện MSG-17; có bản ghi bị cắt hiện MSG-22 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Thiết bị online nhận `timer.changed` | Cập nhật ≤ 5 giây, không cần tải lại |
| A2 | WebSocket mất kết nối | Gọi \[TimerGet\] khi kết nối lại và mỗi 60 giây khi app đang mở `[giả định]` |
| A3 | Lệnh dừng offline cho timer đã bị timer khác đóng | Bỏ lệnh dừng; giữ mốc đóng sớm hơn |
| A4 | Bản ghi offline đồng bộ lên chồng với bản ghi `timer` / `auto_closed` đã có | Cắt phần chồng của bản ghi tới sau (BR-10, C20); còn < 10 giây thì bỏ; MSG-22 |
| A5 | Lệnh offline tạo trước thời điểm workspace vào chỉ đọc (1.1) | Nhận nếu tới server trong 2 giờ; timer bật offline đóng tại thời điểm vào chỉ đọc (BR-19, QC-09). Quá 2 giờ → từ chối 402, MSG-15 |
| A6 | Task của lệnh offline đã bị dời ngày | Vẫn áp lệnh; ngày của bản ghi theo `startedAt` (BR-20) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Task của lệnh offline đã bị xoá | Bỏ lệnh, MSG-16 |
| E2 | Giờ máy lệch > 2 phút | Server điều chỉnh mốc (BR-11), ghi nhật ký |

### UC-08 Focus Bar (1.2, desktop)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Desktop app 1.2; cài đặt Focus Bar khác "Tắt" |
| Hậu điều kiện thành công | Thanh nổi hiển thị task và đồng hồ; thao tác từ thanh đồng bộ với app |
| Hậu điều kiện thất bại | Thanh ẩn; app vẫn hoạt động bình thường |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Vào Focus mode hoặc bắt đầu timer (theo cài đặt BR-16) → hiện **SCR-07** trên cùng màn hình |
| 2 | Người dùng | Bấm Dừng / Hoàn thành / Mở app trên thanh |
| 3 | Hệ thống | Gọi UC-02 / G02 UC-03 / đưa cửa sổ app lên trước |
| 4 | Hệ thống | Timer dừng và không còn ở Focus → ẩn thanh (chế độ "khi timing") |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | macOS | Menu bar hiện đồng hồ đang chạy; bấm mở menu Dừng / Hoàn thành / Mở app |
| A2 | Kéo thanh sang vị trí khác | Nhớ vị trí trên máy |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Hệ điều hành không cấp quyền hiển thị trên cùng | Ẩn thanh; gợi ý mở quyền trong cài đặt hệ điều hành |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| ▶ trên card / chi tiết / dòng subtask | ✓ | ✓ | UC-01 |
| Phím Space trên task đang chọn | ✓ | ✓ (desktop) | UC-01, UC-02 |
| Phím tắt toàn cục Ctrl+Shift+Space | – | ✓ (desktop) | UC-01 A4 |
| Phím E / ô "Thực tế" trong chi tiết | ✓ | ✓ | UC-03 |
| Phím F / mục "Focus" ở sidebar | ✓ | ✓ | UC-04 |
| Tab Pomodoro, phím K | – | ✓ (1.1) | UC-05; web cũng có từ 1.1 |
| Thông báo MSG-11 / mở app sau tự đóng | ✓ | ✓ | UC-06 |
| Focus Bar / macOS menu bar | – | ✓ (desktop, 1.2) | UC-08 |

## 7. Mô tả màn hình

### SCR-01 Điều khiển timer (card, chi tiết, subtask)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | ▶ / ■ | Icon button | Tooltip "Bắt đầu timer · Space" / "Dừng timer · Space"; card chỉ hiện khi hover hoặc đang chạy |
| 2 | Thực tế / Kế hoạch | Text | Đang chạy: H:MM:SS màu xanh; dừng: H:MM; `CHAY_LAU` màu cảnh báo |
| 3 | Badge Focus | Badge ở sidebar | Hiện khi có timer chạy; bấm mở SCR-03 của task đang chạy |
| 4 | (Bỏ — timer chạy trên task cha, xem QC-07 mục 6 / C20) | | |

### SCR-02 Thời gian thực tế (phím E)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Đích | Dropdown | Có | Task (mặc định) hoặc một subtask (chỉ nhập tay) |
| 2 | Chế độ | Toggle | Có | "Thời lượng" / "Khoảng giờ"; gợi ý dưới toggle: thời lượng không hiện trên lịch (BR-05) |
| 3 | Thời lượng | Ô giờ + ô phút | Có (chế độ 1) | 1 phút – 24 giờ → MSG-06; không kiểm tra chồng lấn |
| 4 | Bắt đầu – Kết thúc | Date + time picker | Có (chế độ 2) | BR-05; lỗi → MSG-05 / MSG-06 / MSG-18 |
| 5 | "Thêm" / Enter | Action | – | \[TimeEntryCreate\] |
| 6 | Danh sách bản ghi | List | – | Ngày làm việc (BR-20), giờ bắt đầu – kết thúc (bản ghi theo thời lượng chỉ hiện thời lượng), thời lượng, nguồn (Timer / Nhập tay / Tự dừng / Ritual); sửa tại chỗ, xoá |
| 7 | Tổng | Text | – | "Tổng thực tế {H:MM} / Kế hoạch {H:MM}" |

### SCR-03 Focus mode

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tab | Tabs | "Focus" · "Pomodoro" (ẩn ở 1.0) |
| 2 | Tiêu đề task | Text lớn + dropdown | Đổi task (UC-04 A2); ✓ hoàn thành |
| 3 | Thực tế / Kế hoạch | Text lớn | Như SCR-01 #2 |
| 4 | START / STOP | Button | UC-01 / UC-02 |
| 5 | Subtask | List | ✓ từng subtask; không có ▶ (BR-02) |
| 6 | Notes | Rich text | Như G02 SCR-03 |
| 7 | Comment | Input + list | Như G02 SCR-03 |
| 8 | "Nghỉ một chút (K)" | Button | 1.1; mở SCR-05 |
| 9 | Thoát | Icon / Esc | Không dừng timer |

### SCR-04 Tab Pomodoro (1.1)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Còn lại" | Đồng hồ đếm ngược | – | Mặc định 0:25:00 |
| 2 | Phiên | Số + ▲▼ | Có | 5–90 phút, bước 5; khoá khi đang chạy |
| 3 | START / STOP | Button | – | UC-05 bước 2; STOP = UC-02 |

### SCR-05 Màn nghỉ (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Text | "Nghỉ" |
| 2 | Đồng hồ | Đếm ngược + ▲▼ | Mặc định 0:05:00, 1–30 phút |
| 3 | TẠM DỪNG / TIẾP TỤC | Button | UC-05 A2 |
| 4 | KẾT THÚC NGHỈ | Button | UC-05 A3 |

### SCR-06 Xác nhận giờ dừng (timer tự đóng)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-20 |
| 2 | Giờ dừng | Date + time picker | Trong khoảng (`startedAt`, `startedAt` + 24 giờ]; mặc định giờ hoạt động cuối |
| 3 | "Lưu" | Button | UC-06 bước 5 |
| 4 | "Giữ 24 giờ" / "Xoá bản ghi" | Link | UC-06 A3 / A4 |

### SCR-07 Focus Bar (1.2, desktop)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề task | Text (1 dòng) | Cắt "…" khi dài |
| 2 | Thực tế / Kế hoạch | Text | Đếm giây khi chạy |
| 3 | Dừng / Bắt đầu | Icon button | UC-02 / UC-01 |
| 4 | Hoàn thành | Icon button | G02 UC-03 |
| 5 | Mở app | Icon button | Đưa cửa sổ app lên trước |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[TimerStart\] `POST /timer/start` | taskId (task cha, BR-02), startedAt? (chỉ khi offline), clientOpId, Idempotency-Key | Timer {entryId, taskId, startedAt, workday}, stoppedEntry?, trimmedEntries[]? (BR-10) | 5s / retry 3 lần cùng key |
| \[TimerStop\] `POST /timer/stop` | endedAt? (khi offline, hoặc "Dừng lúc…" UC-06 A6; trong (`startedAt`, now]), clientOpId, Idempotency-Key | TimeEntry đã đóng (hoặc `discarded: true` nếu < 10 giây), actualMin, trimmedEntries[]? | 5s / retry 3 lần cùng key |
| \[TimerGet\] `GET /timer` | – | Timer đang chạy hoặc null, pendingReview[] | 3s / 1 lần |
| \[TimeEntryList\] `GET /time-entries?taskId` `[giả định — chưa có trong danh sách API]` | taskId, cursor | TimeEntry[] | 5s / 1 lần |
| \[TimeEntryCreate\] `POST /time-entries` | taskId, subtaskId?, source (`manual` / `ritual`), entryMode (`duration` / `range`, với `manual`), durationMin? (duration), startedAt?, endedAt? (range / ritual), Idempotency-Key | TimeEntry {…, source, entryMode, workday}, actualMin, overlapWarning, skipped (BR-21) | 5s / 2 lần cùng key |
| \[TimeEntryUpdate\] `PATCH /time-entries/{id}` | startedAt?, endedAt?, needsReview? | TimeEntry, actualMin | 5s / 2 lần |
| \[TimeEntryDelete\] `DELETE /time-entries/{id}` | id | actualMin | 5s / 2 lần |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | focusOnTimer, soundEnabled, remainingAlertMin, pomodoroMin, breakMin, breakReminder, focusBarMode | Settings | 5s / 2 lần |
| Realtime `timer.changed` | – | Timer hiện tại hoặc null, lý do (start / stop / replaced / auto_closed / complete / delete / read_only / trimmed) | Thiết bị khác ≤ 5 giây |
| \[TimerWatchdog\] (job nội bộ) | – | notifiedCount, autoClosedCount | Mỗi 5 phút; mỗi timer một giao dịch |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field endedAt · BEFORE_START | MSG-05 |
| `VALIDATION_FAILED` · field endedAt / durationMin · TOO_LONG / TOO_SHORT | MSG-06 |
| `VALIDATION_FAILED` · field endedAt · IN_FUTURE / `OVERLAPS_RUNNING_TIMER` | MSG-18 |
| `TIMER_NOT_RUNNING` (409) | MSG-07 |
| `NOT_FOUND` / `TASK_ARCHIVED` (task không dùng được) | MSG-16 |
| `WORKSPACE_READ_ONLY` (402, 1.1) | MSG-15 |
| 5xx / timeout | MSG-09 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | Task này không thuộc hôm nay, timer vẫn đang chạy |
| MSG-02 | Toast | Đã dừng timer "{task cũ}" và bắt đầu "{task mới}" |
| MSG-03 | Toast | Đã ghi {H:MM} cho "{tiêu đề}" · Hoàn tác |
| MSG-04 | Toast | Đã xoá bản ghi {H:MM} · Hoàn tác |
| MSG-05 | Inline | Giờ kết thúc phải sau giờ bắt đầu |
| MSG-06 | Inline | Mỗi lần ghi từ 1 phút đến 24 giờ |
| MSG-07 | Toast | Timer đã được dừng trên thiết bị khác |
| MSG-08 | Inline (cảnh báo) | Khoảng giờ này trùng với một lần ghi khác |
| MSG-09 | Toast | Chưa lưu được thời gian. Thử lại |
| MSG-10 | Toast + âm báo | Còn {n} phút cho "{tiêu đề}" / Đã hết thời lượng kế hoạch cho "{tiêu đề}" |
| MSG-11 | Thông báo | Timer cho "{tiêu đề}" đã chạy hơn 4 giờ. Bạn vẫn đang làm? · Dừng · Dừng lúc… · Vẫn đang làm |
| MSG-12 | Toast + âm báo (1.1) | Hết phiên Pomodoro. Nghỉ {n} phút? · Nghỉ · Bỏ qua |
| MSG-13 | Toast + âm báo (1.1) | Hết giờ nghỉ. Quay lại "{tiêu đề}" |
| MSG-14 | Thông báo hệ thống (1.1, desktop) | Bạn đã làm {n} phút liên tục. Nghỉ {m} phút nhé? |
| MSG-15 | Banner (1.1) | Gói dùng thử đã hết. Nâng cấp để tiếp tục ghi thời gian |
| MSG-16 | Toast | Task không còn tồn tại hoặc đã lưu trữ, timer đã dừng |
| MSG-17 | Toast | Hai thiết bị cùng bật timer khi mất mạng; giữ timer "{tiêu đề}" bật sau |
| MSG-18 | Inline | Không ghi được thời gian trong tương lai hoặc trùng timer đang chạy |
| MSG-19 | Empty state | Chọn một task của hôm nay để bắt đầu focus |
| MSG-20 | Dialog | Timer cho "{tiêu đề}" chạy hơn 24 giờ nên đã tự dừng. Bạn dừng lúc mấy giờ? |
| MSG-21 | Toast (1.1) | Workspace chuyển sang chỉ đọc nên timer "{tiêu đề}" đã dừng lúc {giờ} |
| MSG-22 | Toast | Đã bỏ {H:MM} trùng với lần ghi khác khi đồng bộ cho "{tiêu đề}" |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Đồng hồ chạy ≤ 100 ms sau Space (lạc quan); \[TimerStart\] / \[TimerStop\] p95 ≤ 300 ms; SCR-03 mở ≤ 500 ms |
| Độ chính xác | Sai số thời gian thực tế ≤ 1 giây / giờ so với giờ server khi online; đồng hồ client tính theo `startedAt` + độ lệch server, không đếm cộng dồn |
| Toàn vẹn | Khoá duy nhất một timer chạy / người dùng (BR-01); start / stop idempotent theo key |
| Offline | Bật / dừng / nhập tay chạy được khi mất mạng; đồng bộ theo UC-07; Pomodoro, nghỉ chạy hoàn toàn trên thiết bị (1.1) |
| Đồng bộ | `timer.changed` tới thiết bị khác ≤ 5 giây |
| Bảo mật | Chỉ chủ task đọc / sửa bản ghi thời gian; kiểm tra `taskId` thuộc người dùng ở mọi API |
| Log / audit | \[ActivityLog\] theo BR-18; log job watchdog: số nhắc, số tự đóng; không chứa tiêu đề |
| Giám sát | Cảnh báo khi số timer tự đóng > 1% / ngày hoặc job watchdog trễ > 15 phút |
| Tracking | Sự kiện: `timer_started` (nguồn: nút / Space / Focus / toàn cục — 1.1), `timer_stopped` (lý do: user / user_picked_time / replaced / complete / delete / auto_closed / read_only), `timer_discarded_short`, `time_entry_trimmed`, `time_entry_added` (chế độ: duration / range; nguồn: manual / ritual) / `_edited` / `_deleted`, `focus_opened`, `remaining_alert_shown`, `long_timer_notified`, `pomodoro_started` (1.1), `break_started` / `break_ended` (1.1), `focus_bar_action` (1.2) |
| Accessibility | ▶ / ■ có nhãn "Bắt đầu / Dừng timer cho {tiêu đề}"; đồng hồ đếm giây không đọc liên tục (aria-live tắt, đọc khi bấm); âm báo luôn kèm thông báo chữ; tương phản WCAG 2.1 AA ở cả giao diện sáng / tối |
