> **Mã:** PLN-SRS-G09-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g09-weekly-objective.md

# UC-G09 - Weekly planning, Weekly review, objective & analytics trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả Weekly review, Weekly planning, objective tuần, gắn task với objective, Analytics và recap tuần qua email (bản 1.1). Khung wizard, task ghi chép ritual, chia sẻ kết quả và job nhắc ritual dùng lại của G08; task (G02), task lặp (G03), board và khối lượng (G04), backlog (G06), thời gian thực tế (G07), tóm tắt AI (G10), Slack / Teams (G11), kênh thông báo, huỷ nhận và chế độ chỉ đọc (G12) đặc tả ở SRS riêng. API objective, analytics, recap chưa có trong tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0" (thuộc 1.1); đường dẫn dưới đây là đề xuất `[giả định]`.

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng đặt objective tuần, xếp việc vào các ngày, nhìn lại tuần bằng số liệu thời gian thật và nhận recap tuần mà không phải tự viết báo cáo |
| Actor | Người dùng đã đăng nhập · Hệ thống · Job \[ritual.prompt\] (G08), \[analytics.aggregate\], \[weekly.recap.send\] · Dịch vụ gửi email · Người nhận email |
| Phạm vi | Weekly review 3 bước, Weekly planning 4 bước, gộp review vào planning, tự kích hoạt ritual tuần, objective (tạo, sửa, đạt, chuyển tuần, xoá), gắn task, Analytics tuần + CSV, recap tuần qua email (Beta), Cài đặt → Ritual (phần tuần) |
| Ngoài phạm vi | Daily planning / shutdown và chia sẻ (G08); tóm tắt tuần bằng AI (G10, 1.2); analytics nâng cao, analytics nhóm (sau 1.2); objective tháng / quý |
| Nền tảng | Web, App iOS / Android, desktop (bản 1.1) |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Đầu tuần đặt 3–5 objective | Việc hằng ngày hướng về mục tiêu tuần |
| US-02 | Người dùng | Kéo task từ backlog "Tuần tới" vào từng ngày | Việc hoãn có ngày làm cụ thể |
| US-03 | Người dùng | Gắn task với objective và thấy tiến độ theo giờ | Biết objective đang tới đâu |
| US-04 | Người dùng | Cuối tuần xem giờ theo ngày, theo channel và việc đã xong | Biết thời gian đã đi đâu |
| US-05 | Người dùng | Đánh dấu đạt hoặc chuyển objective sang tuần sau | Không bỏ sót mục tiêu dở |
| US-06 | Người dùng | Xem analytics tuần và tải CSV | Đối chiếu giờ làm, báo khách hàng |
| US-07 | Người dùng | Nhận recap tuần qua email, gửi kèm cho quản lý | Không phải viết báo cáo tuần |
| US-08 | Người dùng thành thạo | Mở panel objective bằng Shift+R, gắn task bằng R / $ | Không rời bàn phím |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Tuần** bắt đầu ngày đầu tuần trong cài đặt (mặc định Thứ Hai, G01), theo timezone người dùng và day_start_time 04:00 `[giả định — chờ PO chốt]`. Mã tuần `weekStart` = ngày đầu tuần |
| BR-02 | **Phiên ritual tuần** dùng bảng `ritual_sessions` của G08 với `type` = `weekly_planning` / `weekly_review`, `date = weekStart`; UNIQUE(user, type, date). Lưu tiến độ, thoát / mở lại, ẩn bước, Hoàn tác như G08 |
| BR-03 | **Tự kích hoạt** mỗi loại tối đa 1 lần / tuần: Weekly planning khi ≥ ngày giờ planning (mặc định Thứ Hai 08:00), Weekly review khi ≥ ngày giờ review (mặc định Thứ Sáu 15:00); phiên tuần đó `CHUA_BAT_DAU`, `autoPromptedAt` trống. Bỏ lỡ nhiều tuần → chỉ xét tuần hiện tại (như EC-27). Bật "Gộp review vào planning" → không nhắc Weekly review riêng `[giả định]` |
| BR-04 | **Trùng Daily planning.** Ngày Weekly planning tự mở mà Daily planning hôm nay chưa `HOAN_TAT` → Weekly planning chạy trước; Done → mở Daily planning (G08) ngay; Daily planning không tự mở thêm lần nữa trong ngày |
| BR-05 | **Cửa sổ review.** Weekly review tuần W mở được từ ngày đầu tuần W đến hết ngày cuối tuần W; sau đó `QUA_HAN`. Gộp bật và review W−1 chưa `HOAN_TAT` → 3 bước review W−1 chạy đầu Weekly planning W, ghi vào phiên `weekly_review` W−1 |
| BR-06 | **What got done** dùng định nghĩa BR-17: cột giờ thực tế theo ngày T2–T6 (T2–CN khi bật "Tính cuối tuần trong review"); donut phân bổ theo channel, tối đa 6 lát + "Khác" `[giả định]` |
| BR-07 | **Đã xong tuần này / Đã xong tuần trước**: sinh sẵn danh sách task xong trong tuần (trừ task ghi chép ritual), mỗi dòng "- {tiêu đề}", nhóm theo channel; sửa tay; 0–10.000 ký tự `[giả định]`. "Làm mới" khi đã sửa → hỏi MSG-23 |
| BR-08 | **Rà soát objective** (review): mỗi objective `DANG_MO` của tuần W có 3 thao tác: Đạt → `DAT`; Chuyển sang tuần sau (BR-16); Để lại (không đổi, hết tuần → `KHONG_DAT`). Áp ngay, có Hoàn tác |
| BR-09 | **Xếp việc vào tuần** (planning): trái = bucket backlog "Tuần tới" (G06); phải = cột ngày của tuần, mặc định T2–T6, cuối tuần thu gọn mở được `[giả định]`. Kéo vào cột → `startDate` (G06 \[TaskMove\]); chỉ thả vào ngày ≥ hôm nay. Mỗi cột hiện tổng planned, quá tải theo G04 → MSG-24 |
| BR-10 | **Kế hoạch tuần này**: objective của W theo thứ tự, dưới mỗi objective là task gắn có `startDate` trong W ("{tiêu đề} ({planned})"); task không gắn ở nhóm "Việc khác"; kèm "Đã xong tuần trước" (BR-07 cho W−1). Sửa tay; giới hạn như BR-07 |
| BR-11 | **Hoàn tất ritual tuần** theo BR-11 – BR-14 của G08: task ghi chép "Weekly planning" / "Weekly review" đã xong, `startDate` = ngày hoàn tất `[giả định]`, channel cho task ritual, notes = nội dung chốt, thời gian ritual ≤ 120 phút; chia sẻ theo G08. Không hoàn tất không tạo task (EC-26) |
| BR-12 | **Objective**: mô tả 1–200 ký tự (cắt khoảng trắng hai đầu); `weekStart` từ tuần hiện tại đến 12 tuần tới `[giả định]`; channel tuỳ chọn; tối đa 20 objective `DANG_MO` + `DAT` / tuần / người dùng; `position` kéo đổi được. Tuần đã qua chỉ xem |
| BR-13 | **Gắn task**: mỗi task gắn tối đa 1 objective (`objectiveId`). Danh sách chọn = objective của tuần chứa `startDate`; task backlog → tuần hiện tại. Task dời sang tuần khác giữ liên kết, hiện nhãn "Ngoài tuần" `[giả định]`. Instance lặp mới không sao chép objective (G03). Task xoá → không tính vào tiến độ |
| BR-14 | **Tiến độ objective** = Σ planned task xong gắn / Σ planned task gắn (task không có planned không tính). Σ planned = 0 → hiện "{x}/{n} task" theo số lượng `[giả định]`. Hiện tổng planned dạng "h:mm" (kiểm chứng "1:00"). Tiến độ 100% không tự chuyển `DAT` |
| BR-15 | **Biến task thành objective**: tạo objective mô tả = tiêu đề task (cắt 200 ký tự), tuần của task (BR-13), channel của task; gắn task vào objective mới |
| BR-16 | **Chuyển sang tuần sau**: tạo objective mới ở W+1 (`carriedFromId`), objective cũ → `DA_CHUYEN`; task chưa xong gắn chuyển sang objective mới, task xong ở lại `[giả định]`. W+1 đã đủ 20 → MSG-04 |
| BR-17 | **Định nghĩa analytics** (dùng chung trang Analytics, What got done, recap). (a) Giờ thực tế ngày d = Σ TimeEntry bắt đầu trong d + planned của task xong ngày d không có TimeEntry khi bật "Tính planned là actual". (b) Phân bổ channel = (a) theo channel; lọc context = channel thuộc context đó. (c) Tỉ lệ hoàn thành task đã lên kế hoạch = task trong snapshot ngày d xong trong d / task trong snapshot; snapshot = task chưa xong của d lúc Daily planning d hoàn tất (G08), không có Daily planning → lúc 12:00 `[giả định]`. (d) Độ lệch = (Σ actual − Σ planned) / Σ planned trên task xong có cả hai, %. (e) Ngày vượt ngưỡng = ngày `overloaded` (G04) tại snapshot. (f) Chuỗi = số ngày làm việc liên tiếp có Daily planning `HOAN_TAT` tính tới cuối tuần đang xem `[giả định]`. Task ghi chép ritual tính vào (a), (b); không tính vào (c) |
| BR-18 | **Ít dữ liệu**: tuần có < 3 task xong có TimeEntry `[giả định]` → MSG-09; vẫn hiện số |
| BR-19 | **Cập nhật** số liệu tuần hiện tại ≤ 15 phút (job \[analytics.aggregate\] tổng hợp theo ngày, chỉ tính lại ngày có thay đổi). Sửa TimeEntry / task của tuần cũ → tính lại tuần đó. Hiện "Cập nhật lúc" (MSG-10) |
| BR-20 | **CSV**: tuần và bộ lọc đang xem; UTF-8 có BOM; mỗi dòng (ngày, channel): ngày, channel, context, giờ thực tế, giờ planned, task xong, task trong snapshot, task snapshot đã xong, vượt ngưỡng (có / không), Daily planning hoàn tất (có / không) |
| BR-21 | **Recap tuần (Beta)**: gửi Thứ Bảy 00:00 giờ người dùng cho tuần vừa xong; nội dung: tổng giờ, giờ theo ngày, top 5 channel, objective + tiến độ, số task xong, 10 task xong đầu tiên. Người nhận: chính người dùng (bật mặc định `[giả định]`) + tối đa 5 email. Tuần không có task xong và không có TimeEntry → không gửi. Idempotent theo (user, weekStart, người nhận) |
| BR-22 | **Riêng tư**: analytics chỉ dữ liệu của chính người dùng. Bản recap / chia sẻ gửi người khác không chứa task ở channel private; tên task riêng tư chỉ có trong bản gửi chính người dùng |
| BR-23 | **Chỉ đọc (G12)**: vẫn xem analytics, tải CSV; không tạo / sửa objective, không mở phiên ritual mới; phiên đang `DANG_LAM` được hoàn tất (EC-34); recap vẫn gửi |

## 4. Trạng thái

### 4.1. Trạng thái phiên ritual tuần (theo loại và `weekStart`)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHUA_BAT_DAU` | Chưa có phiên cho (loại, W), hoặc chưa vào bước nào | Mục sidebar có chấm nhắc sau giờ ritual |
| `DANG_LAM` | Có `startedAt`, chưa `completedAt`, W chưa qua | "Đang dở · bước {n}/{tổng}"; mở lại về `current_step` |
| `HOAN_TAT` | `completedAt` có giá trị | Bản đã chốt chế độ xem + "Làm lại"; task ghi chép trên board |
| `BO_QUA` | Chọn "Bỏ qua tuần này" ở lời nhắc | Không nhắc, không tự mở trong tuần; vẫn mở tay được |
| `QUA_HAN` | W đã qua mà chưa `HOAN_TAT` (review: trừ trường hợp gộp, BR-05) | Không nhắc, không làm bù |

Chuyển trạng thái như G08 mục 4.1, thay "ngày D" bằng "tuần W".

### 4.2. Trạng thái objective

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_MO` | Chưa đạt, chưa chuyển, chưa xoá, W chưa qua | Dòng thường, thanh tiến độ |
| `DAT` | `achievedAt` có giá trị | ✓ xanh, chữ mờ |
| `KHONG_DAT` | W đã qua, vẫn chưa đạt / chuyển | Nhãn "Chưa đạt", chỉ xem |
| `DA_CHUYEN` | Đã chuyển sang tuần sau (BR-16) | Nhãn "Đã chuyển sang tuần {ngày}", chỉ xem |
| `DA_XOA` | `deletedAt` có giá trị | Ẩn; Hoàn tác trong toast |

Chuyển: `DANG_MO` ⇄ `DAT` (UC-03 A3, UC-01 bước 6) · `DANG_MO` → `DA_CHUYEN` (BR-16) · `DANG_MO` → `KHONG_DAT` (hết tuần, job) · `DANG_MO` / `DAT` → `DA_XOA` → trạng thái trước (Hoàn tác).

### 4.3. Trạng thái recap tuần (mỗi người nhận, mỗi tuần)

`CHO_GUI` → `DA_GUI` | `BO_QUA_KHONG_DU_LIEU` (BR-21) | `LOI` (sau 3 lần thử trong 1 giờ `[giả định]`).

## 5. Use Case

### UC-01 Weekly review

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; W trong cửa sổ review (BR-05); workspace không chỉ đọc hoặc phiên đã `DANG_LAM` |
| Hậu điều kiện thành công | Phiên `HOAN_TAT`; objective W đã xử lý; task ghi chép "Weekly review"; chia sẻ xếp hàng |
| Hậu điều kiện thất bại | Phiên giữ `DANG_LAM`; thao tác objective đã áp vẫn giữ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Weekly review" ở sidebar / command menu, lời nhắc MSG-01, hoặc tự mở (UC-07) |
| 2 | Hệ thống | Gọi \[RitualGet\] `weekly_review` W; tạo `DANG_LAM` nếu chưa có; gọi \[AnalyticsWeekly\] W; mở **SCR-01** với **SCR-02** |
| 3 | Người dùng | **Bước 1 – What got done (SCR-02):** xem cột giờ theo ngày và donut theo channel; "Tiếp" |
| 4 | Hệ thống | Hiển thị theo BR-06; ít dữ liệu → MSG-09; không có task xong → MSG-19; \[RitualUpdate\] `current_step = 2` |
| 5 | Người dùng | **Bước 2 – Weekly review (SCR-03):** sửa "Đã xong tuần này"; với từng objective chọn Đạt / Chuyển sang tuần sau / Để lại; "Tiếp" |
| 6 | Hệ thống | Sinh danh sách theo BR-07; áp thao tác objective ngay (BR-08, \[ObjectiveUpdate\] / \[ObjectiveCarryOver\]), toast Hoàn tác; \[RitualUpdate\] `current_step = 3` |
| 7 | Người dùng | **Bước 3 – Chia sẻ / Wrap up (SCR-04):** chọn đích (G08 UC-03); bấm "Wrap up" |
| 8 | Hệ thống | Gọi \[RitualComplete\] (BR-11); toast MSG-17; đóng wizard |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phiên `DANG_LAM` / `HOAN_TAT` | Như G08 UC-01 A1 / A2 |
| A2 | Bật "Tính cuối tuần trong review" | Biểu đồ và danh sách T2–CN (BR-06) |
| A3 | Tuần W không có objective | Cột phải MSG-08, nút "Thêm objective cho tuần sau" → SCR-10 với W+1 |
| A4 | Bấm "Tự động hoá" (Automate) ở footer | Mở SCR-14 `[giả định]` |
| A5 | Esc / × giữa chừng | Lưu tiến độ, không tạo task ghi chép (EC-26) |
| A6 | Gộp review vào planning bật | Các bước 3–6 chạy bên trong UC-02 (A1 UC-02) |
| A7 | "Làm mới" khi đã sửa | MSG-23 |
| A8 | Hoàn tất ở thiết bị khác | MSG-25, mở chế độ xem |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[AnalyticsWeekly\] lỗi | Bước 1 hiện MSG-27 "Thử lại"; vẫn "Tiếp" được |
| E2 | Workspace chỉ đọc khi chưa có phiên | MSG-13, không mở (BR-23) |
| E3 | Mất mạng | Biểu đồ dùng số liệu cache kèm MSG-10; còn lại như G08 UC-01 E3 |
| E4 | "Đã xong tuần này" > 10.000 ký tự | MSG-28, chặn "Tiếp" |
| E5 | \[RitualComplete\] lỗi | Giữ ở bước 3, MSG-12 "Thử lại" (cùng key) |

### UC-02 Weekly planning

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; W là tuần hiện tại hoặc tuần sau `[giả định]`; workspace không chỉ đọc hoặc phiên đã `DANG_LAM` |
| Hậu điều kiện thành công | Objective W đã có; task "Tuần tới" đã có ngày; task ghi chép "Weekly planning"; chuyển sang Daily planning nếu BR-04 |
| Hậu điều kiện thất bại | Phiên giữ `DANG_LAM`; objective, task đã đổi vẫn giữ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Weekly planning" ở sidebar / command menu, lời nhắc MSG-02, hoặc tự mở Thứ Hai 08:00 (UC-07) |
| 2 | Hệ thống | Gọi \[RitualGet\] `weekly_planning` W, \[ObjectiveList\] W và W−1; mở **SCR-01** với **SCR-05** |
| 3 | Người dùng | **Bước 1 – Weekly objectives (SCR-05):** thêm, sửa, sắp xếp objective (UC-03); "Tiếp" |
| 4 | Hệ thống | Lưu objective (\[ObjectiveCreate\] / \[ObjectiveUpdate\]); \[RitualUpdate\] `current_step = 2` |
| 5 | Người dùng | **Bước 2 – Xếp việc vào tuần (SCR-06):** kéo task từ "Tuần tới" vào cột ngày; gắn objective bằng R / $; "Tiếp" |
| 6 | Hệ thống | \[TaskMove\] đặt `startDate` (BR-09); \[TaskAlign\] (UC-04); cập nhật tổng mỗi ngày, quá tải → MSG-24; \[RitualUpdate\] `current_step = 3` |
| 7 | Người dùng | **Bước 3 – Weekly plan (SCR-07):** đọc / sửa "Kế hoạch tuần này" và "Đã xong tuần trước"; "Tiếp" |
| 8 | Hệ thống | Sinh nội dung theo BR-10, lưu nháp; \[RitualUpdate\] `current_step = 4` |
| 9 | Người dùng | **Bước 4 – Chia sẻ / Done (SCR-08):** chọn đích (G08 UC-03); bấm "Done" |
| 10 | Hệ thống | Gọi \[RitualComplete\] (BR-11); toast MSG-18; Daily planning hôm nay chưa `HOAN_TAT` → mở G08 UC-01 (BR-04) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Gộp review bật, review W−1 chưa `HOAN_TAT` | Chạy SCR-02, SCR-03 cho W−1 trước bước 3; hoàn tất ghi cả task "Weekly review" (W−1) và "Weekly planning" (BR-05) |
| A2 | W−1 còn objective `DANG_MO` | SCR-05 hiện nhóm "Từ tuần trước" với Chuyển sang tuần này / Đạt / Để lại (BR-08, BR-16) |
| A3 | Bucket "Tuần tới" trống | SCR-06 hiện MSG-20; vẫn "Tiếp" |
| A4 | Làm Weekly planning giữa tuần | Cột ngày đã qua mờ, không thả được (BR-09) |
| A5 | Phiên `DANG_LAM` / `HOAN_TAT`; Esc giữa chừng | Như G08 UC-01 A1, A2, A5 |
| A6 | "Làm mới" ở bước 3 khi đã sửa | MSG-23 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Objective thứ 21 | MSG-04, không tạo |
| E2 | Workspace chỉ đọc khi chưa có phiên | MSG-13 (BR-23) |
| E3 | Mất mạng | Như G08 UC-01 E3; objective tạo offline xếp hàng cùng Idempotency-Key |
| E4 | \[RitualComplete\] lỗi | Giữ ở bước 4, MSG-12 |

### UC-03 Quản lý objective tuần

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; workspace không chỉ đọc (để ghi) |
| Hậu điều kiện thành công | Objective được tạo / sửa / đạt / chuyển / xoá; thiết bị khác thấy ≤ 5 giây |
| Hậu điều kiện thất bại | Không thay đổi; hiện lỗi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Shift+R hoặc panel phải → Objectives (**SCR-09**), hoặc bước 1 Weekly planning |
| 2 | Hệ thống | Gọi \[ObjectiveList\] W; hiện objective, task gắn, tổng planned, tiến độ (BR-14) |
| 3 | Người dùng | "Thêm objective" → **SCR-10**: nhập mô tả, chọn tuần, channel; Enter |
| 4 | Hệ thống | Kiểm tra BR-12; gọi \[ObjectiveCreate\]; objective hiện cuối danh sách; phát `objective.upserted` `[giả định]` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Sửa mô tả / channel tại chỗ | \[ObjectiveUpdate\] |
| A2 | Kéo đổi thứ tự | \[ObjectiveUpdate\] `position` |
| A3 | Bấm ✓ trên objective | `DANG_MO` ⇄ `DAT` |
| A4 | Menu … → "Chuyển sang tuần sau" | \[ObjectiveCarryOver\] (BR-16); toast MSG-06 |
| A5 | Menu … → "Xoá" | \[ObjectiveDelete\]; task gắn → không gắn; toast MSG-05; Hoàn tác → \[ObjectiveRestore\] |
| A6 | ‹ › đổi tuần | Tải tuần mới; tuần đã qua chỉ xem, nút thêm ẩn (MSG-22) |
| A7 | Bấm task con | Mở chi tiết task (G02) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mô tả trống hoặc > 200 ký tự | MSG-03 |
| E2 | Tuần đã đủ 20 objective | MSG-04 |
| E3 | Tuần đã qua / quá 12 tuần tới | MSG-22 |
| E4 | Objective đã bị xoá ở thiết bị khác | MSG-29, gỡ khỏi danh sách |
| E5 | Lỗi 5xx / timeout | Trả về trạng thái cũ, MSG-12 |

### UC-04 Gắn task với objective

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task tồn tại, không ở `DA_XOA` (G02) |
| Hậu điều kiện thành công | `objectiveId` của task cập nhật; icon trên card; tiến độ objective tính lại |
| Hậu điều kiện thất bại | Liên kết giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Phím R hoặc $ trên task đang chọn / hover; hoặc menu … → "Gắn với objective" (G02 SCR-04), mục Objective trong ô soạn (G02 SCR-01) |
| 2 | Hệ thống | Mở **SCR-11** với objective của tuần chứa task (BR-13) |
| 3 | Người dùng | Gõ để lọc, ↑ / ↓, Enter chọn objective |
| 4 | Hệ thống | Gọi \[TaskAlign\]; card hiện icon objective; tiến độ cập nhật; toast MSG-07 có Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Chọn "Không gắn" | \[TaskAlign\] `objectiveId = null` |
| A2 | Chọn "Biến task này thành objective" | \[ObjectiveCreate\] `fromTaskId` (BR-15) |
| A3 | Chọn "Quản lý objective" | Mở SCR-09 |
| A4 | Tuần chưa có objective | SCR-11 hiện MSG-08; Enter trên chuỗi đang gõ tạo objective mới và gắn task |
| A5 | Task đã gắn bị dời sang tuần khác | Giữ liên kết, card hiện nhãn MSG-21 (BR-13) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tạo objective mới khi tuần đã đủ 20 | MSG-04 |
| E2 | \[TaskAlign\] lỗi | Trả liên kết cũ, MSG-12 |

### UC-05 Xem analytics và tải CSV

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Số liệu tuần hiển thị theo bộ lọc; file CSV tải về |
| Hậu điều kiện thất bại | Hiện lỗi, giữ số liệu đã có |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu workspace → Analytics (**SCR-12**) |
| 2 | Hệ thống | Gọi \[AnalyticsWeekly\] tuần trước, context "Tổng", cuối tuần tắt; hiện MSG-10 |
| 3 | Người dùng | Đổi tuần ‹ ›, bật / tắt "Cuối tuần", chọn context |
| 4 | Hệ thống | Tải lại theo BR-17; ít dữ liệu → MSG-09 (BR-18) |
| 5 | Người dùng | Bấm "Tải xuống" |
| 6 | Hệ thống | Gọi \[AnalyticsExport\] (BR-20); tải file `analytics-{weekStart}.csv`; toast MSG-11 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Xem tuần hiện tại | Số liệu tới lần tổng hợp gần nhất (≤ 15 phút, BR-19) |
| A2 | Di chuột lên cột ngày | Tooltip: giờ thực tế, giờ planned, task xong, vượt ngưỡng |
| A3 | Tuần chưa dùng app | Mọi số = 0, MSG-09 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[AnalyticsWeekly\] lỗi | MSG-27 "Thử lại" |
| E2 | \[AnalyticsExport\] lỗi | MSG-12 |
| E3 | Mất mạng | Hiện bản cache gần nhất kèm MSG-10; "Tải xuống" disabled |

### UC-06 Recap tuần qua email (Beta)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Recap tuần bật (Cài đặt → Thông báo, G12); có ≥ 1 người nhận |
| Hậu điều kiện thành công | Mỗi người nhận có 1 email recap cho tuần vừa xong (`DA_GUI`) |
| Hậu điều kiện thất bại | Người nhận lỗi ở `LOI`; không gửi trùng khi thử lại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job \[weekly.recap.send\] chạy mỗi 15 phút `[giả định]`, chọn người dùng vừa qua Thứ Bảy 00:00 theo timezone |
| 2 | Hệ thống | Kiểm tra BR-21; không có dữ liệu → `BO_QUA_KHONG_DU_LIEU`, dừng |
| 3 | Hệ thống | Dựng email **SCR-13** từ \[AnalyticsWeekly\] tuần vừa xong và objective; bản cho người khác lọc theo BR-22 |
| 4 | Hệ thống | Gửi từng người nhận; thành công → `DA_GUI` |
| 5 | Người nhận | Mở email; bấm "Mở Analytics" (chủ tài khoản) hoặc "Huỷ nhận" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Thêm / gỡ người nhận ở SCR-14 | \[SettingsUpdate\] `weeklyRecap.recipients` |
| A2 | Bấm "Gửi thử cho tôi" | \[RecapTest\] gửi recap tuần gần nhất cho chính người dùng; toast MSG-16 |
| A3 | Người nhận bấm "Huỷ nhận" | Gỡ khỏi danh sách (G12); SCR-14 hiện nhãn "Đã huỷ nhận" |
| A4 | Đổi timezone trong tuần | Dùng timezone tại thời điểm job chạy |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Email người nhận sai định dạng | MSG-14, không lưu |
| E2 | Người nhận thứ 6 | MSG-15 |
| E3 | Gửi lỗi | Thử lại 3 lần trong 1 giờ; vẫn lỗi → `LOI`, ghi log, không báo người dùng `[giả định]` |
| E4 | Job chạy lại cùng tuần | Bỏ qua người nhận đã `DA_GUI` (idempotent) |

### UC-07 Tự kích hoạt và cài đặt ritual tuần

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; cài đặt tự kích hoạt bật (dùng chung G08) |
| Hậu điều kiện thành công | Mỗi ritual tuần được nhắc / tự mở tối đa 1 lần / tuần; cài đặt áp dụng ngay |
| Hậu điều kiện thất bại | Không tự mở; mở tay vẫn được |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job \[ritual.prompt\] (G08) xét thêm `weekly_planning`, `weekly_review` theo BR-03 |
| 2 | Hệ thống | Tạo thông báo MSG-02 / MSG-01; client tự mở như G08 UC-04 (`autoOpen`) |
| 3 | Người dùng | Làm ritual (UC-01 / UC-02) hoặc "Bỏ qua tuần này" → `BO_QUA` |
| 4 | Người dùng | Cài đặt → Ritual, phần tuần (**SCR-14**): đổi ngày / giờ planning, review, gộp, cuối tuần |
| 5 | Hệ thống | Gọi \[SettingsUpdate\]; áp ngay (BR-03 tính lại cho tuần hiện tại nếu chưa nhắc) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bỏ lỡ nhiều tuần | Chỉ tuần hiện tại (như EC-27) |
| A2 | Nhiều thiết bị | Chỉ thiết bị đầu tiên tự mở (G08 UC-04 A1) |
| A3 | Ngày Weekly planning trùng Daily planning | BR-04 |
| A4 | Bật "Gộp review vào planning" | Không nhắc review riêng; review chạy trong UC-02 A1 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[SettingsUpdate\] lỗi | Trả giá trị cũ, MSG-12 |
| E2 | Job lỗi / trễ | Như G08 UC-04 E1 |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** | **Ghi chú** |
| --- | --- | --- | --- |
| Sidebar / command menu "Weekly planning", "Weekly review" | ✓ | ✓ | Tuần hiện tại |
| Tự mở / thông báo ritual tuần | ✓ | ✓ | UC-07 |
| Shift+R, panel phải → Objectives | ✓ | ✓ (desktop) | SCR-09 |
| Phím R / $ trên task, menu … → "Gắn với objective" | ✓ | ✓ | SCR-11 |
| Menu workspace → Analytics | ✓ | ✓ | SCR-12 |
| Email recap → "Mở Analytics" | ✓ | ✓ | Deep link tới tuần của recap |
| Cài đặt → Ritual (tuần) / Thông báo → Recap tuần | ✓ | ✓ | SCR-14 |

## 7. Mô tả màn hình

Ánh xạ bước → màn hình: Weekly review bước 1–3 = SCR-02, SCR-03, SCR-04; Weekly planning bước 1–4 = SCR-05, SCR-06, SCR-07, SCR-08. Mọi bước nằm trong khung SCR-01. Mobile: hai cột của một bước chuyển thành hai tab.

### SCR-01 Khung wizard ritual tuần

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Khung chung | Component | Dùng SCR-01 của G08 (thanh bước, Quay lại / Tiếp, ×, "Đây là gì?", "Làm mới", "Bỏ qua bước này từ lần sau") |
| 2 | Header | Text | "Weekly review · 02/11 – 06/11" / "Weekly planning · 09/11 – 13/11" |
| 3 | "Tự động hoá" | Link (footer, chỉ review) | Mở SCR-14 `[giả định]` |

### SCR-02 Review bước 1 – What got done

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Năng suất theo ngày" | Biểu đồ cột | Giờ thực tế T2–T6 (T2–CN nếu bật); tooltip số giờ |
| 2 | "Thời gian đã dành cho" | Donut | Theo channel, màu channel, ≤ 6 lát + "Khác"; kèm bảng số |
| 3 | Tổng tuần | Số lớn | "h:mm" thực tế · số task xong |
| 4 | Cảnh báo | Banner | MSG-09 / MSG-27 |

### SCR-03 Review bước 2 – Weekly review

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Đã xong tuần này" | Rich text (trái) | – | BR-07; ≤ 10.000 ký tự → MSG-28; rỗng → MSG-19 |
| 2 | "Rà soát objective" | List (phải) | – | Mỗi dòng: mô tả, tiến độ, tổng planned |
| 3 | Thao tác objective | Segmented | – | Đạt · Chuyển sang tuần sau · Để lại (BR-08) |
| 4 | Không có objective | Empty state | – | MSG-08 + "Thêm objective cho tuần sau" |

### SCR-04 Review bước 3 – Chia sẻ / Wrap up

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Chọn đích, xem trước | Component | SCR-07 của G08; nội dung = tổng giờ + "Đã xong tuần này" + objective |
| 2 | "Wrap up" | Button chính | UC-01 bước 8 |

### SCR-05 Planning bước 1 – Weekly objectives

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Danh sách objective W | List kéo thả | – | ✓ đạt, sửa tại chỗ, menu … |
| 2 | "Thêm objective" | Input | Có (khi thêm) | 1–200 ký tự (MSG-03); > 20 → MSG-04 |
| 3 | "Từ tuần trước" | List | – | Objective `DANG_MO` của W−1: Chuyển sang tuần này / Đạt / Để lại (A2 UC-02) |

### SCR-06 Planning bước 2 – Xếp việc vào tuần

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Backlog "Tuần tới" | List (trái) | Task bucket "Tuần tới" (G06); rỗng → MSG-20 |
| 2 | Cột ngày | Board (phải) | T2–T6, cuối tuần thu gọn; tổng planned mỗi cột; ngày đã qua mờ |
| 3 | Kéo thả / menu "Chuyển tới ngày…" | Action | \[TaskMove\]; quá tải → MSG-24 |
| 4 | Icon objective trên card | Icon | R / $ mở SCR-11 |

### SCR-07 Planning bước 3 – Weekly plan

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Kế hoạch tuần này" | Rich text | – | BR-10; sửa tay; ≤ 10.000 ký tự → MSG-28 |
| 2 | "Đã xong tuần trước" | Rich text | – | BR-07 cho W−1 |
| 3 | Chế độ xem (`HOAN_TAT`) | Read-only + button | – | "Làm lại" |

### SCR-08 Planning bước 4 – Chia sẻ / Done

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Chọn đích, xem trước | Component | SCR-07 của G08; nội dung = SCR-07 mục 1, 2 |
| 2 | "Done" | Button chính | UC-02 bước 10 |

### SCR-09 Panel Weekly objectives

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Header | "Weekly objectives {ngày đầu} – {ngày cuối}" + ‹ › |
| 2 | Objective | List | ✓, mô tả, #channel, tổng planned ("1:00"), thanh tiến độ, trạng thái (mục 4.2) |
| 3 | Task gắn | List con | Tiêu đề, planned, ✓; bấm mở chi tiết (G02) |
| 4 | "Thêm objective" | Button | SCR-10; ẩn với tuần đã qua |
| 5 | Trạng thái rỗng | Empty state | MSG-08 |

### SCR-10 Form objective

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Mô tả | Text | Có | 1–200 ký tự; lỗi → MSG-03 |
| 2 | Tuần | Week picker | Có | Mặc định tuần đang xem; tuần hiện tại → 12 tuần tới (MSG-22) |
| 3 | Channel | Dropdown có tìm | Không | Danh sách channel (G02) |
| 4 | Enter / "Thêm" | Action | – | \[ObjectiveCreate\]; đủ 20 → MSG-04 |

### SCR-11 Menu "Gắn với objective"

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Ô tìm | Input | Lọc theo mô tả, không phân biệt dấu |
| 2 | "Không gắn" | Item | A1 UC-04 |
| 3 | Objective của tuần | List | Đang gắn có ✓ |
| 4 | "Biến task này thành objective" | Item | A2 UC-04 |
| 5 | "Quản lý objective" | Item | Mở SCR-09 |

### SCR-12 Analytics

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Chọn tuần | Header + ‹ › | Mặc định "Tuần trước {ngày} – {ngày}" |
| 2 | "Cuối tuần" | Toggle | Mặc định tắt |
| 3 | Bộ lọc context | Segmented | Tổng / personal / work / context khác |
| 4 | Tổng tuần | Thẻ số | Giờ thực tế, giờ planned, task xong, tỉ lệ hoàn thành task đã lên kế hoạch, độ lệch, ngày vượt ngưỡng, chuỗi Daily planning (BR-17) |
| 5 | Giờ theo ngày | Biểu đồ cột | Tooltip A2 UC-05 |
| 6 | Phân bổ channel | Thanh ngang | Kèm bảng số |
| 7 | "Tải xuống" | Button | CSV (BR-20); offline disabled |
| 8 | Cảnh báo / cập nhật | Banner, text | MSG-09, MSG-10, MSG-27 |

### SCR-13 Email recap tuần

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề email | Text | "Tuần {ngày} – {ngày}: {h:mm} làm việc, {n} task xong" |
| 2 | Tổng giờ, giờ theo ngày | Bảng | Ảnh biểu đồ + bảng số thay thế |
| 3 | Top 5 channel | Bảng | Giờ và % |
| 4 | Objective | List | Mô tả, trạng thái, tiến độ |
| 5 | Việc đã xong | List | 10 task đầu (BR-22 lọc với người nhận khác) |
| 6 | "Mở Analytics" | Link | Deep link tuần đó |
| 7 | Footer | Text | MSG-26 + link huỷ nhận 1 chạm (G12) |

### SCR-14 Cài đặt ritual tuần & recap

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Weekly planning | Ngày + giờ | Có | Mặc định Thứ Hai 08:00 |
| 2 | Weekly review | Ngày + giờ | Có | Mặc định Thứ Sáu 15:00 |
| 3 | Gộp review vào planning | Toggle | – | Mặc định tắt |
| 4 | Tính cuối tuần trong review | Toggle | – | Mặc định tắt |
| 5 | Recap tuần qua email (Beta) | Toggle | – | Thuộc Cài đặt → Thông báo (G12), hiện liên kết |
| 6 | Người nhận recap | Email list | Không | ≤ 5 (MSG-15); sai định dạng → MSG-14; nhãn "Đã huỷ nhận" |
| 7 | "Gửi thử cho tôi" | Button | – | A2 UC-06 |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[RitualGet\] / \[RitualUpdate\] / \[RitualComplete\] (G08) `/rituals/{type}/{date}` | type `weekly_planning` / `weekly_review`, date = weekStart | Như G08 | Như G08 |
| \[ObjectiveList\] `GET /objectives?weekStart` | weekStart | Objective[] (id, title, channelId, status, position, plannedMin, donePlannedMin, taskCount, doneCount, tasks[]) | 5s / 1 lần |
| \[ObjectiveCreate\] `POST /objectives` | title, weekStart, channelId, position, fromTaskId, Idempotency-Key | Objective | 5s / 2 lần cùng key |
| \[ObjectiveUpdate\] `PATCH /objectives/{id}` | title, channelId, position, status (`DAT` / `DANG_MO`), If-Match | Objective, version | 5s / 2 lần |
| \[ObjectiveDelete\] / \[ObjectiveRestore\] `DELETE /objectives/{id}`, `POST /objectives/{id}/restore` | id | deletedAt / Objective | 5s / 2 lần |
| \[ObjectiveCarryOver\] `POST /objectives/{id}/carry-over` | id, Idempotency-Key | Objective cũ, Objective mới, movedTaskIds[] | 5s / 2 lần cùng key |
| \[TaskAlign\] `PATCH /tasks/{id}` (G02 \[TaskUpdate\]) | objectiveId \| null | Task | 5s / 2 lần |
| \[TaskMove\] (G04 / G06) | startDate | Task | Như G06 |
| \[AnalyticsWeekly\] `GET /analytics/weekly` | weekStart, contextId, weekends | totals, daily[], channels[], completionRate, varianceRate, overloadedDays, planningStreak, lowData, computedAt | 5s / 1 lần |
| \[AnalyticsExport\] `GET /analytics/weekly/export` | weekStart, contextId, weekends, format=csv | File CSV | 15s / 1 lần |
| \[SettingsGet\] / \[SettingsUpdate\] `/me/settings` (G01) | ritual.weekly*, weeklyRecap {enabled, recipients[]} | Settings | 5s / 2 lần |
| \[RecapTest\] `POST /me/weekly-recap/test` | – | sentTo | 10s / không retry |
| Job \[analytics.aggregate\], \[weekly.recap.send\] | Mỗi 15 phút | Bảng tổng hợp ngày, email | Idempotent theo (user, ngày) / (user, weekStart, người nhận) |
| Realtime `objective.upserted`, `objective.deleted` | – | Objective | Thiết bị khác ≤ 5 giây |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field title | MSG-03 |
| `LIMIT_OBJECTIVES_PER_WEEK` | MSG-04 |
| `OBJECTIVE_WEEK_NOT_ALLOWED` | MSG-22 |
| `VALIDATION_FAILED` · field content · TOO_LONG | MSG-28 |
| `VALIDATION_FAILED` · field recipients | MSG-14 |
| `LIMIT_RECAP_RECIPIENTS` | MSG-15 |
| `NOT_FOUND` (objective đã xoá) | MSG-29 |
| `RITUAL_ALREADY_COMPLETED` (409) / `PRECONDITION_FAILED` (412) | MSG-25 |
| `WORKSPACE_READ_ONLY` (402) | MSG-13 |
| 5xx / timeout khi ghi | MSG-12 |
| 5xx / timeout khi đọc analytics | MSG-27 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Thông báo / banner | Đến giờ Weekly review · Bắt đầu · Bỏ qua tuần này |
| MSG-02 | Thông báo / banner | Đến giờ lên kế hoạch tuần · Bắt đầu · Bỏ qua tuần này |
| MSG-03 | Inline | Objective cần 1–200 ký tự |
| MSG-04 | Inline | Mỗi tuần tối đa 20 objective |
| MSG-05 | Toast | Đã xoá objective "{mô tả}" · {n} task đã bỏ gắn · Hoàn tác |
| MSG-06 | Toast | Đã chuyển "{mô tả}" sang tuần {ngày đầu} – {ngày cuối} |
| MSG-07 | Toast | Đã gắn với "{objective}" · Hoàn tác |
| MSG-08 | Empty state | Chưa có objective cho tuần này · Thêm objective |
| MSG-09 | Banner | Ít dữ liệu. Thêm thời gian thực tế cho task đã xong (di chuột lên task và nhấn E) |
| MSG-10 | Inline | Cập nhật lúc {giờ} |
| MSG-11 | Toast | Đã tải xuống analytics-{tuần}.csv |
| MSG-12 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-13 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục lên kế hoạch tuần |
| MSG-14 | Inline | Email không hợp lệ |
| MSG-15 | Inline | Tối đa 5 người nhận recap |
| MSG-16 | Toast | Đã gửi email thử tới {email} |
| MSG-17 | Toast | Đã lưu vào task "Weekly review" |
| MSG-18 | Toast | Đã lưu vào task "Weekly planning" · Lên kế hoạch hôm nay |
| MSG-19 | Empty state | Tuần này chưa có task nào xong |
| MSG-20 | Empty state | Backlog "Tuần tới" đang trống |
| MSG-21 | Nhãn trên card | Ngoài tuần |
| MSG-22 | Inline | Chỉ tạo objective cho tuần hiện tại đến 12 tuần tới; tuần đã qua chỉ xem được |
| MSG-23 | Dialog | Tạo lại nội dung? Phần bạn đã sửa sẽ bị thay thế · Tạo lại · Huỷ |
| MSG-24 | Inline cột ngày | {Thứ}: đã lên {X} giờ, chỉ còn {Y} giờ trống |
| MSG-25 | Toast | Ritual này vừa được hoàn tất trên thiết bị khác |
| MSG-26 | Footer email | Bạn nhận email này vì {tên} đã thêm bạn vào recap tuần · Huỷ nhận |
| MSG-27 | Inline | Không tải được số liệu · Thử lại |
| MSG-28 | Inline | Nội dung tối đa 10.000 ký tự |
| MSG-29 | Toast | Objective này đã bị xoá |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | \[AnalyticsWeekly\] p95 ≤ 500 ms (đọc bảng tổng hợp); CSV ≤ 5 giây; panel objective mở ≤ 300 ms; tiến độ objective cập nhật ≤ 1 giây sau khi task xong |
| Độ tươi số liệu | Tuần hiện tại ≤ 15 phút (BR-19); tuần cũ tính lại ≤ 15 phút sau khi sửa |
| Offline | Panel objective, gắn task, ritual tuần chạy trên dữ liệu máy, đồng bộ sau; Analytics chỉ xem bản cache, không xuất CSV |
| Đồng bộ | Objective, liên kết task hiện trên thiết bị khác ≤ 5 giây (`objective.upserted`) |
| Email | Recap rải theo timezone, giới hạn tốc độ gửi; SPF / DKIM / DMARC; link huỷ nhận 1 chạm; 95% email gửi trong 30 phút sau 00:00 Thứ Bảy |
| Bảo mật | Chỉ chủ dữ liệu xem analytics / objective (BR-22); CSV tải qua link ký có hạn 5 phút; email lọc task riêng tư với người nhận khác |
| Log / audit | Nhật ký objective: tạo, sửa, đạt, chuyển, xoá (tác nhân `user` / `system`); log gửi recap: người nhận (băm), tuần, kết quả; không log nội dung |
| Tracking | Sự kiện: `weekly_ritual_opened` (type, source), `weekly_ritual_completed` (type, activeSeconds, merged), `objective_created` (source: panel / planning / from_task), `objective_achieved`, `objective_carried_over`, `task_aligned`, `analytics_viewed` (week_offset, context), `analytics_exported`, `weekly_recap_sent`, `weekly_recap_opened`, `weekly_recap_unsubscribed` |
| Accessibility | Biểu đồ có bảng số thay thế và nhãn đọc màn hình; màu channel không là kênh thông tin duy nhất (kèm tên, %); kéo thả có menu "Chuyển tới ngày…"; WCAG 2.1 AA ở giao diện sáng / tối |
