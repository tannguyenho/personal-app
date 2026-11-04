> **Mã:** PLN-PRD-G03 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g03-task-lap-lai.md

# PRD Task lặp lại trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: picker lặp (Repeats / On / Every N week / At roughly / Save), toast "Task now repeats", banner series ("This task repeats every weekday. This is the first instance of this series. Edit task series. Previous / Next"), instance Thứ Sáu hiện projection 9:00 và sao chép notes, đổi priority một instance không hỏi phạm vi. Chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Nhiều việc lặp theo nhịp cố định: standup mỗi sáng, dọn hộp thư mỗi ngày làm việc, báo cáo tuần, gửi hoá đơn cuối tháng. Nhóm G03 lo việc biến một task thành series lặp, sinh sẵn các instance trên những ngày tới, sửa từng instance và sửa cả series. Mô hình task (G02), board và projection (G04), timebox (G05), rollover và Archive (G06) dùng chung với instance lặp.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Phải tạo lại tay việc định kỳ mỗi ngày / tuần / tháng | Quên việc, mất thời gian ghi chép lặp đi lặp lại |
| Việc định kỳ không hiện trước trên các ngày tới | Không thấy khối lượng tương lai, Daily planning và plan tuần thiếu việc |
| Sửa một lần lại bị hỏi "chỉ lần này hay tất cả" | Thêm một bước, dễ chọn nhầm và sửa lan sang cả series |
| Ngày 29–31 và 29/2 không có ở mọi tháng / năm | Instance bị mất hoặc nhảy sang tháng sau |
| Bỏ lỡ một lần, instance cũ rollover chồng lên instance mới | Cột hôm nay có hai bản của cùng một việc |

## 1.3 Mục tiêu

- Biến một task có sẵn thành task lặp trong ≤ 10 giây: menu … → Lặp lại → chọn quy tắc → Lưu.
- Instance có sẵn trên board 60 ngày tới để G04 tính khối lượng ngày và tuần.
- Sửa một instance không bao giờ hỏi phạm vi; mọi thao tác trên cả series nằm ở một menu "Sửa series".
- Hệ thống không bao giờ tự đặt hai instance của cùng series vào một ngày.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân (Linh PM) | Standup, dọn email mỗi ngày làm việc, báo cáo tuần tự có trên board |
| Người cần khối thời gian dài (Minh) | Một khối "Deep work" mỗi sáng vào khoảng cùng giờ |
| Freelancer / founder (Hà) | Gửi hoá đơn ngày cuối tháng, gia hạn tên miền hằng năm, không lo tháng ngắn |
| Người dùng thành thạo | Mở cấu hình lặp và sửa series không rời bàn phím |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Bật lặp cho task có sẵn từ menu … → Lặp lại (card và chi tiết task).
- 6 kiểu quy tắc: Daily, Weekdays, Weekly (chọn thứ, mỗi N tuần), Monthly theo ngày, Monthly theo "thứ N", Yearly; khoảng lặp 1–99; giờ "khoảng" (At roughly).
- Sinh instance tự động tới 60 ngày phía trước; instance hiện dạng projection trên board.
- Banner series trong chi tiết instance: mô tả quy tắc, vị trí trong series, Trước / Sau, "Sửa series".
- Menu "Sửa series" 6 thao tác: Dừng lặp, Đổi tần suất, Cập nhật mọi instance chưa xong theo task này, Xoá mọi instance chưa xong và dừng lặp, Đặt giờ bắt đầu, Quản lý mọi task lặp.
- Quy tắc instance bị bỏ lỡ: instance cũ chưa xong không rollover nếu đã có instance hôm nay (G06 thực thi).

## 3.2 Ngoài phạm vi

- Rollover, Archive → G06. Board, projection, sắp xếp → G04.
- Timebox và cài đặt "Lập lịch cứng cho task lặp" → G05 (G03 chỉ lưu giờ "khoảng").
- Ngày kết thúc series / số lần lặp tối đa → chưa đưa vào (xem Câu hỏi mở).
- Lặp theo ngày hoàn thành ("3 ngày sau khi xong") → sau 1.1.
- Gắn objective cho task lặp → G09 (bản 1.1); objective không sao chép sang instance.
- Task lặp giao cho người khác → G12 (bản 1.1).

# 4. Nguyên tắc sản phẩm

## 4.1 Sửa một là một

Sửa một instance chỉ đổi instance đó, không hỏi phạm vi (giống Sunsama). Muốn đổi cả series thì vào "Sửa series".

## 4.2 Thấy trước tương lai

Instance có mặt sẵn trên các ngày tới ở dạng projection, không cố định giờ, để người dùng thấy khối lượng khi plan ngày và tuần.

## 4.3 Một series, một ngày, một instance

Hệ thống không tự đặt hai instance cùng series vào một ngày. Instance cũ bị bỏ lỡ khi đã có instance hôm nay được đưa vào Archive với nhãn "bị bỏ qua".

## 4.4 Quá khứ không đổi

Sửa quy tắc hay nội dung series chỉ áp cho instance chưa xong ở hiện tại và tương lai. Instance đã xong giữ nguyên làm lịch sử.

# 5. Quy tắc lặp

| **Quy tắc** | **Tham số / giới hạn** | **Mặc định khi mở picker** | **Ghi chú** |
|---|---|---|---|
| Daily | Mỗi N ngày, N = 1–99 | N = 1 | — |
| Weekdays | Thứ Hai – Thứ Sáu | — | Không có khoảng lặp |
| Weekly | Chọn 1–7 thứ; mỗi N tuần, N = 1–99 | Thứ của ngày bắt đầu task; N = 1 | Tuần bắt đầu Thứ Hai (cài đặt chung) |
| Monthly theo ngày | Ngày D = 1–31; mỗi N tháng | D = ngày của ngày bắt đầu | D = 29–31 → ngày cuối tháng ở tháng ngắn hơn |
| Monthly theo "thứ N" | Thứ nhất / hai / ba / tư / cuối cùng `[giả định]` + thứ trong tuần; mỗi N tháng | Suy từ ngày bắt đầu (ví dụ "Thứ Tư đầu tiên") | Ngày là lần thứ 5 trong tháng → đề xuất "cuối cùng" |
| Yearly | Ngày / tháng; mỗi N năm | Ngày / tháng của ngày bắt đầu | 29/2 → 28/2 ở năm không nhuận |
| Giờ "khoảng" | Bước 15 phút `[giả định]`; trống được | Trống | Hiện trên card; chỉ thành timebox khi bật lập lịch cứng (G05) |
| Khoảng sinh trước | 60 ngày | — | Job sinh instance chạy hằng ngày |
| Số series đang lặp | Tối đa 200 / người dùng `[giả định]` | — | Chặn tạo thêm, gợi ý dừng series cũ |

| **Trường của instance mới** | **Sao chép từ series?** |
|---|---|
| Tiêu đề, notes, channel, thời lượng kế hoạch, giờ "khoảng" | Có |
| Priority, subtask (tiêu đề + thời lượng, trạng thái chưa xong) | Có `[giả định]` |
| Comment, objective, timebox, thời gian thực tế, nhật ký | Không |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Instance đầu tiên chính là task gốc, giữ ngày bắt đầu hiện tại; các instance sau sinh theo quy tắc tính từ ngày đó.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Bật lặp | Menu … → Lặp lại, chọn quy tắc, (tuỳ chọn) giờ "khoảng", Lưu | Toast "Task giờ sẽ lặp lại"; task gốc là instance đầu |
| 2 | Sinh instance | Hệ thống sinh instance trên các ngày khớp quy tắc trong 60 ngày tới | Instance hiện projection trên cột ngày, có biểu tượng lặp |
| 3 | Làm từng lần | Mở instance: banner series, Trước / Sau; hoàn thành, sửa riêng lần này | Instance xong; series không đổi |
| 4 | Bỏ lỡ | Instance chưa xong qua ngày: rollover hoặc vào Archive "bị bỏ qua" (G06) | Hôm nay chỉ có một instance của series |
| 5 | Sửa series | "Sửa series": đổi tần suất, đặt giờ, áp nội dung instance này cho mọi instance chưa xong | Instance tương lai chưa xong cập nhật |
| 6 | Kết thúc | Dừng lặp, hoặc xoá mọi instance chưa xong và dừng lặp | Không sinh thêm instance |

Bước 4 do G06 thực thi theo quy tắc của G03. PRD này tập trung bước 1, 2, 3, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Bật lặp cho task

### US1.1 Đặt quy tắc lặp

User Story: Là người dùng, tôi muốn đặt một task lặp theo ngày, ngày làm việc, tuần, tháng hoặc năm, để không phải tạo lại việc định kỳ.

AC01: Menu … của task (card hoặc chi tiết) có mục "Lặp lại"; mở picker với các ô Lặp (6 quy tắc), Vào (thứ, khi Weekly), Mỗi N tuần / tháng / năm, Vào khoảng (giờ), Lưu.

AC02: Giá trị mặc định suy từ ngày bắt đầu của task (thứ, ngày trong tháng, "thứ N").

AC03: Lưu → task gốc thành instance đầu, giữ ngày bắt đầu hiện tại; toast "Task giờ sẽ lặp lại" (Sunsama "Task now repeats").

AC04: Khoảng lặp ngoài 1–99 hoặc Weekly không chọn thứ nào → nút Lưu disabled, hiện lỗi tại ô.

AC05: Task trong backlog (không có ngày) bật lặp → instance đầu đặt vào hôm nay `[giả định]`, toast nói rõ ngày.

### US1.2 Ngày không tồn tại ở mọi tháng / năm

AC01: Monthly ngày 31 → tháng 30 ngày sinh vào ngày 30, tháng 2 sinh vào 28 (hoặc 29 năm nhuận); tháng sau quay lại ngày 31.

AC02: Yearly 29/2 → năm không nhuận sinh vào 28/2.

AC03: Picker hiện ghi chú khi chọn ngày 29–31 hoặc 29/2 để người dùng biết trước.

## UC2. Xem và làm từng instance

### US2.1 Instance có sẵn trên board

AC01: Sau khi bật lặp, instance của 60 ngày tới hiện trên cột ngày tương ứng trong ≤ 5 giây.

AC02: Instance không có giờ cố định: hiện giờ projection (G04). Kiểm chứng: instance Thứ Sáu của task lặp Weekdays hiện 9:00 theo projection, notes được sao chép.

AC03: Card instance có biểu tượng lặp; có giờ "khoảng" thì hiện giờ đó.

### US2.2 Banner series và điều hướng

AC01: Chi tiết instance có banner: "Task này lặp lại {mô tả quy tắc}. Đây là lần {thứ n} của series." + "Sửa series" + Trước / Sau.

AC02: Trước / Sau mở instance liền kề theo ngày; instance đầu thì Trước disabled; chưa sinh tới thì Sau hiện ngày lần kế tiếp.

### US2.3 Sửa một instance

User Story: Là người dùng, tôi muốn sửa riêng lần hôm nay mà không bị hỏi, để thao tác nhanh và không làm hỏng các lần sau.

AC01: Sửa bất kỳ trường nào của instance (tiêu đề, priority, thời lượng, notes, ngày…) chỉ đổi instance đó, không có hộp hỏi phạm vi (kiểm chứng: đổi priority instance Thứ Sáu).

AC02: Hoàn thành, xoá, dời ngày một instance không ảnh hưởng instance khác; ngày đã xoá không bị sinh lại.

## UC3. Sửa series

### US3.1 Đổi tần suất

AC01: "Sửa series" → "Đổi tần suất" mở lại picker với quy tắc hiện tại.

AC02: Lưu → chỉ instance chưa xong có ngày sau hôm nay được sinh lại theo quy tắc mới; instance hôm nay, instance quá khứ và instance đã xong giữ nguyên (EC-29).

AC03: Toast nêu số instance thay đổi, có Hoàn tác.

### US3.2 Cập nhật mọi instance chưa xong theo task này

AC01: Tiêu đề, notes, channel, thời lượng, priority, subtask của instance đang mở được chép sang series và mọi instance chưa xong khác.

AC02: Instance đã xong không đổi; toast nêu số instance, có Hoàn tác.

### US3.3 Đặt giờ bắt đầu

AC01: Đặt hoặc xoá giờ "khoảng" cho series; áp cho mọi instance chưa xong từ hôm nay.

AC02: Không tạo timebox trừ khi bật "Lập lịch cứng cho task lặp" (G05).

## UC4. Dừng lặp và xoá

### US4.1 Dừng lặp

AC01: "Sửa series" → "Dừng lặp": không sinh thêm instance; instance chưa xong sau hôm nay bị xoá mềm; instance hôm nay và trước đó giữ nguyên `[giả định]`.

AC02: Toast có Hoàn tác; banner instance còn lại đổi thành "Series đã dừng lặp".

### US4.2 Xoá mọi instance chưa xong và dừng lặp

AC01: Hiện xác nhận có số instance sẽ xoá (khác Sunsama về mức hỏi; thao tác hàng loạt nên hỏi `[giả định]`).

AC02: Mọi instance chưa xong vào Thùng rác (G02); instance đã xong giữ; series dừng; toast có Hoàn tác.

## UC5. Instance bị bỏ lỡ

### US5.1 Không có hai bản cùng một việc hôm nay

AC01: Instance cũ chưa xong, series đã có instance hôm nay → instance cũ không rollover, vào Archive với nhãn "bị bỏ qua" (EC-30, G06).

AC02: Series chưa có instance hôm nay → chỉ instance cũ mới nhất rollover về hôm nay; các instance cũ hơn vào Archive "bị bỏ qua" `[giả định]`.

AC03: Khôi phục instance "bị bỏ qua" từ Archive được (G06).

## UC6. Quản lý mọi task lặp

### US6.1 Xem tất cả series

AC01: "Sửa series" → "Quản lý mọi task lặp" (hoặc Cài đặt → Task lặp lại) liệt kê series: tiêu đề, quy tắc, giờ "khoảng", channel, lần kế tiếp, trạng thái.

AC02: Từ mỗi dòng: mở instance kế tiếp, đổi tần suất, dừng lặp.

AC03: Lọc "Đang lặp" / "Đã dừng".

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ người dùng có series | Người dùng có ≥ 1 series đang lặp / người dùng hoạt động tuần | ≥ 40% |
| Tỉ lệ hoàn thành instance | Instance xong / instance có ngày ≤ hôm nay | ≥ 60% |
| Tỉ lệ instance bị bỏ qua | Instance vào Archive "bị bỏ qua" / instance có ngày ≤ hôm nay | Theo dõi (cao = quy tắc quá dày) |
| Series dừng sớm | Series dừng trong 14 ngày đầu / series mới | ≤ 30% |
| Thời gian bật lặp | Từ mở picker đến Lưu | ≤ 10 giây (trung vị) |
| Lỗi sinh instance | Lượt job lỗi / tổng lượt | ≤ 0,1% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Job sinh instance | Job lỗi hoặc chạy trùng tạo instance trùng | Khoá duy nhất (series, ngày); job idempotent, chạy lại an toàn |
| Dung lượng | 60 ngày × nhiều series × nhiều người dùng | Giới hạn 200 series / người dùng; instance tương lai là bản ghi nhẹ |
| Timezone, DST | Đổi timezone làm lệch ngày instance | Ngày instance lưu theo ngày (không giờ); đổi timezone không đổi ngày đã sinh |
| Board quá tải | Nhiều series Daily làm cột ngày dài | Hiện tổng thời lượng và cảnh báo khối lượng (G04) |
| Rollover (G06) | Hai nhóm cùng sửa instance quá khứ | G03 định nghĩa quy tắc "bị bỏ qua", G06 là nơi duy nhất thực thi |
| Lịch ngoài (G05) | Lập lịch cứng tạo nhiều sự kiện trên Google / Outlook | Mặc định tắt; chỉ tạo timebox cho instance trong 7 ngày tới `[giả định]` |

# 10. Câu hỏi mở

- Có cần ngày kết thúc series / số lần lặp ở 1.0 không?
- Instance mới có sao chép priority và subtask không (Sunsama chưa kiểm chứng)?
- "Dừng lặp" có xoá instance tương lai đã sinh hay giữ lại?
- Xoá mọi instance chưa xong có cần hộp xác nhận hay chỉ toast Hoàn tác như xoá thường (G02)?
- Monthly theo "thứ N" có lựa chọn "cuối cùng" không?
- day_start_time 04:00 hay 00:00 (ảnh hưởng "hôm nay" khi xét instance bị bỏ qua)?
- Xoá task gốc (instance đầu) có dừng series không? Đề xuất: không.
