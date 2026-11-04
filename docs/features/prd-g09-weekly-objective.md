> **Mã:** PLN-PRD-G09 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g09-weekly-objective.md

# PRD Weekly planning, Weekly review, objective & analytics trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: các màn Weekly review ("What got done" với biểu đồ Daily productivity và donut "How you spent your time"; "Finished this week" và "Review your key objectives"; Share / Wrap up; footer Automate, Refresh, Skip this step in the future), Weekly planning (Weekly objectives → Weekly plan "Planned for this week" + "Finished last week" → Share / Done), panel Weekly objectives (Shift+R), menu "Align with objective", trang Analytics. Phần analytics mở rộng và recap tuần qua email là đề xuất. Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> Đã sửa theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). Quy tắc dùng chung (`QC-xx`) xem [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md): ngày làm việc (QC-01), lịch làm việc (QC-02), bản ghi thời gian (QC-07), chế độ chỉ đọc (QC-09). Thuật ngữ xem [`CONTEXT.md`](../../CONTEXT.md).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Ritual ngày (G08) giúp làm đúng việc trong ngày; G09 thêm vòng tuần ở bản 1.1: đầu tuần đặt objective và xếp việc vào các ngày (Weekly planning, Thứ Hai 08:00), cuối tuần nhìn lại (Weekly review, Thứ Sáu 15:00). Objective nối task hằng ngày với mục tiêu tuần. Analytics và recap tuần qua email biến thời gian thực tế (G07) và khối lượng (G04) thành số liệu tuần. G09 dùng lại khung wizard, task ghi chép ritual và cơ chế chia sẻ của G08.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Làm từng ngày nhưng không có mục tiêu tuần | Bận cả tuần mà không tiến gần việc quan trọng |
| Không nhìn lại tuần đã qua | Lặp lại lỗi ước lượng, không biết thời gian đi vào đâu |
| Bucket backlog "Tuần tới" phình nhưng không ai xếp vào ngày | Việc hoãn mãi |
| Không có số liệu thời gian theo ngày và channel | Khó trả lời "tuần này làm được gì", khó báo giờ cho khách hàng |
| Báo cáo tuần cho quản lý / khách hàng gõ tay | Mất 20–30 phút mỗi tuần `[giả định]` |

## 1.3 Mục tiêu

- Weekly planning ≤ 15 phút, Weekly review ≤ 10 phút (trung vị) `[giả định]`.
- Mỗi objective thấy được tiến độ theo thời lượng và theo số task đã xong, không phải tự đánh giá.
- Bucket "Tuần tới" được xếp vào ngày cụ thể ngay trong Weekly planning.
- Analytics trả lời 3 câu hỏi: tuần này làm bao nhiêu giờ, vào channel nào, kế hoạch có sát thực tế không.
- Recap tuần tới hộp thư ngay sau ngày làm việc cuối tuần (theo lịch làm việc) mà không cần thao tác.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh (PM) | Đặt 3–5 objective tuần, gửi kế hoạch tuần và review tuần cho quản lý |
| Minh (designer / dev) | Gắn task vào objective để thấy tiến độ dự án theo giờ làm |
| Hà (freelancer / founder) | Xem giờ theo channel (khách hàng), tải CSV để đối chiếu khi xuất hoá đơn |
| Thành viên nhóm (1.1) | Recap tuần gửi cho trưởng nhóm, không phải viết báo cáo |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.1)

- Nền tảng: Web, App iOS / Android, desktop.
- Weekly review 3 bước: What got done → Weekly review (Finished this week + rà soát objective) → Chia sẻ / Wrap up.
- Weekly planning 4 bước: Weekly objectives → Xếp việc vào tuần (backlog "Tuần tới" → ngày) → Weekly plan → Chia sẻ / Done. Tuỳ chọn gộp review vào planning: các bước review chèn trước bước 1, một bước Chia sẻ, một email.
- Tự kích hoạt ritual tuần (1 lần / tuần / loại), task ghi chép ritual tuần, chia sẻ (dùng cơ chế G08).
- Objective tuần: tạo, sửa, sắp xếp, đánh dấu đạt, chuyển sang tuần sau, xoá; gắn task; tiến độ theo thời lượng.
- Analytics theo tuần: số liệu đã kiểm chứng trên Sunsama + chỉ số mở rộng; xuất CSV.
- Recap tuần qua email (Beta).
- Cài đặt → Ritual: phần ritual tuần.

## 3.2 Ngoài phạm vi

- Daily planning, Daily shutdown, khung wizard và chia sẻ → G08.
- Highlights / tóm tắt tuần do AI soạn → G10 (1.2).
- Analytics nâng cao (khoảng thời gian tuỳ chọn, so sánh nhiều tuần, analytics cả nhóm) → sau 1.2.
- Objective theo tháng / quý, objective chung của nhóm → chưa lên kế hoạch.
- Kênh gửi Slack / Teams → G11 (1.2). Cấu hình kênh thông báo, huỷ đăng ký → G12.

# 4. Nguyên tắc sản phẩm

## 4.1 Tuần là đơn vị, ngày là nơi làm

Objective thuộc một tuần; việc thực hiện vẫn là task trên ngày. Không có "task của tuần" lơ lửng: Weekly planning luôn kết thúc bằng việc xếp task vào ngày cụ thể.

## 4.2 Tiến độ đo bằng việc đã xong

Tiến độ objective hiện cả hai số: % giờ (thời lượng kế hoạch của task đã xong / tổng thời lượng kế hoạch task gắn) và x/y task. Task chưa ước lượng vẫn hiện trong x/y, nên một task nhỏ đã xong không làm objective trông như xong 100%. Khi objective đóng (đạt, chưa đạt, chuyển tuần), tiến độ được cố định. Người dùng không phải tự kéo thanh phần trăm.

## 4.3 Số liệu trung thực

Analytics hiển thị đúng dữ liệu có; ít dữ liệu thì nói rõ và chỉ cách bổ sung (nhấn E để nhập thời gian), không ngoại suy.

## 4.4 Không bắt làm bù

Bỏ lỡ ritual tuần thì chỉ nhắc tuần hiện tại (giống EC-27 của G08). Mở xem không hoàn tất không tạo task ghi chép (EC-26).

# 5. Quy tắc objective, ritual tuần và analytics

| **Cấu hình** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Giờ Weekly planning | Ngày trong tuần + giờ, bước 5 phút | Thứ Hai 08:00 | Ngày đầu tuần Thứ Hai (G01) |
| Giờ Weekly review | Ngày trong tuần + giờ | Thứ Sáu 15:00 | |
| Gộp review vào planning | Bật / tắt | Tắt | Bật: các bước review tuần trước chạy trước bước 1 của Weekly planning; một bước Chia sẻ, một email (đã chốt, C25) |
| Ngày hiển thị trong tuần | Lịch làm việc (G01) | Thứ Hai–Thứ Sáu | Đã chốt (QC-02): cột ngày lấy từ lịch làm việc, không hard-code |
| Gồm ngày nghỉ trong review | Bật / tắt | Tắt | Bật: hiện đủ 7 ngày, gồm ngày không thuộc lịch làm việc |
| Objective | 1–200 ký tự; tối đa 20 / tuần | — | Channel tuỳ chọn |
| Tuần tạo được objective | Tuần hiện tại đến 12 tuần tới | Tuần đang xem | Tuần đã qua chỉ xem |
| Task gắn objective | Tối đa 1 objective / task | Không gắn | Instance lặp mới không sao chép (G03), trừ khi chọn "Gắn cho cả series" (đã chốt, C26) |
| Tiến độ objective | % giờ = planned task xong / tổng planned task gắn; kèm x/y task | — | Đã chốt (C26). Cố định khi objective đóng |
| Objective chưa xử lý của tuần trước | Chuyển "Chưa đạt" khi Weekly planning tuần mới hoàn tất, hoặc hết ngày làm việc đầu tuần mới | — | Đã chốt (B13) |
| Mốc đầu ngày | 00:00–06:00 | 04:00 | Đã chốt (QC-01). Xác định ranh giới ngày và tuần |
| Cập nhật analytics | ≤ 15 phút | — | Tuần hiện tại |
| Ngưỡng "ít dữ liệu" | < 3 task xong có thời gian thực tế trong tuần, không tính task ghi chép ritual | — | Hiện cảnh báo, vẫn hiện số |
| Recap tuần qua email (Beta) | Mốc đầu ngày của ngày sau ngày làm việc cuối tuần (lịch T2–T6 → Thứ Bảy 04:00) | Bật cho chính người dùng | Giờ gửi đã chốt (Q19). Thêm tối đa 5 người nhận |

- Các giá trị là **cấu hình hệ thống / cài đặt người dùng**, không hard-code.
- Định nghĩa chỉ số analytics ở SRS BR-17; dùng chung cho trang Analytics, bước "What got done" và recap email. Giờ thực tế cộng theo QC-07: planned chỉ tính thay actual cho task không có bản ghi thời gian nào, không cộng hai lần.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Đặt objective | Thứ Hai 08:00 Weekly planning tự mở; thêm 3–5 objective | Objective tuần |
| 2 | Xếp việc vào tuần | Kéo task từ backlog "Tuần tới" vào các ngày; gắn task với objective | Ngày trong tuần có task |
| 3 | Kế hoạch tuần & chia sẻ | Đọc "Planned for this week" + "Finished last week", gửi | Task ghi chép "Weekly planning" |
| 4 | Làm việc hằng ngày | Daily planning / shutdown (G08), timer (G07) | Task xong, thời gian thực tế |
| 5 | Theo dõi | Panel objective (Shift+R), Analytics bất cứ lúc nào | Biết tiến độ giữa tuần |
| 6 | Weekly review | Thứ Sáu 15:00: xem giờ theo ngày / channel, việc đã xong, rà objective, chia sẻ | Task ghi chép "Weekly review", objective đạt / chuyển |
| 7 | Recap | Mốc đầu ngày sau ngày làm việc cuối tuần (mặc định Thứ Bảy 04:00), email tổng kết tuần | Email recap |

Bước 4 thuộc G08 / G07, chỉ nêu để thấy vị trí của G09.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Weekly review

### US1.1 Xem tuần đã làm được gì

User Story: Là Hà, tôi muốn thấy giờ làm theo từng ngày và theo từng khách hàng của tuần, để biết thời gian đã đi đâu.

AC01: Mở bằng sidebar "Weekly review", command menu, lời nhắc Thứ Sáu 15:00 hoặc tự mở (1 lần / tuần).

AC02: Bước "What got done": biểu đồ cột giờ thực tế cho từng ngày làm việc trong tuần theo lịch làm việc (đủ 7 ngày nếu bật "Gồm ngày nghỉ") và donut phân bổ theo channel. Người làm Thứ Hai–Thứ Bảy thấy cột Thứ Bảy mà không cần bật gì.

AC03: Số liệu dùng cùng định nghĩa với Analytics.

### US1.2 Tổng kết và rà soát objective

AC01: "Đã xong tuần này" (Sunsama: "Finished this week") sinh sẵn danh sách task đã xong dạng gạch đầu dòng, sửa tay được.

AC02: Cột phải "Rà soát objective" (Sunsama: "Review your key objectives"): mỗi objective có tiến độ và 3 thao tác: Đánh dấu đạt, Chuyển sang tuần sau, Để lại. "Để lại" giữ objective mở tới khi Weekly planning tuần sau hoàn tất hoặc hết ngày làm việc đầu tuần sau, rồi mới thành "Chưa đạt".

### US1.3 Chia sẻ và kết thúc

AC01: Chia sẻ dùng cơ chế G08: lưu vào task ritual, gửi bản sao cho chính mình, email người khác.

AC02: "Wrap up" tạo task ghi chép "Weekly review" đã xong; mở xem không hoàn tất không tạo task (EC-26).

AC03: Footer có "Tự động hoá" (Automate), "Làm mới", "Bỏ qua bước này từ lần sau". "Tự động hoá" mở cài đặt lịch ritual tuần `[giả định — hành vi trên Sunsama chưa rõ]`.

## UC2. Weekly planning

### US2.1 Đặt objective tuần

User Story: Là Linh, tôi muốn đầu tuần ghi ra 3–5 mục tiêu, để mọi việc trong tuần đều hướng về chúng.

AC01: Tự mở Thứ Hai 08:00 (1 lần / tuần); nếu Daily planning cùng chưa làm, Weekly planning chạy trước rồi mời sang Daily planning (G08).

AC02: Bước 1 liệt kê objective tuần này, nút "Thêm objective"; objective chuyển từ tuần trước hiện sẵn. Objective tuần trước còn mở hiện ở nhóm "Từ tuần trước" với Chuyển sang tuần này / Đạt / Để lại; bấm "Done" thì objective còn lại của tuần trước thành "Chưa đạt".

### US2.2 Xếp việc vào tuần

AC01: Bên trái bucket backlog "Tuần tới" (G06); bên phải một cột cho mỗi ngày làm việc trong tuần theo lịch làm việc (G01), kèm tổng thời lượng mỗi ngày.

AC02: Kéo task vào ngày → task có ngày bắt đầu; ngày quá tải hiện đỏ (G04).

AC03: Gắn task với objective ngay trên card (phím R / $).

### US2.3 Kế hoạch tuần

AC01: "Kế hoạch tuần này" (Sunsama: "Planned for this week"): objective và task theo objective; "Đã xong tuần trước" (Sunsama: "Finished last week").

AC02: Sửa tay; chia sẻ như G08; "Done" tạo task ghi chép "Weekly planning".

### US2.4 Gộp review vào planning

AC01: Bật "Gộp review vào planning" → Weekly planning chạy các bước review của tuần trước trước bước 1; chỉ có một bước Chia sẻ ở cuối và gửi một email gồm cả review lẫn kế hoạch; hoàn tất ghi cả hai task ghi chép.

## UC3. Objective tuần

### US3.1 Quản lý objective

AC01: Panel phải "Weekly objectives {ngày đầu} – {ngày cuối}" (Shift+R) với ‹ › đổi tuần.

AC02: "Thêm objective": mô tả 1–200 ký tự, tuần, channel tuỳ chọn; tối đa 20 / tuần.

AC03: Mỗi objective hiện task gắn, tổng thời lượng (ví dụ "1:00"), thanh tiến độ kèm "{p}% giờ · {x}/{y} task".

AC04: Kéo đổi thứ tự; sửa tại chỗ; xoá có Hoàn tác, task gắn trở về "Không gắn".

AC05: Chuyển sang tuần sau: tạo objective ở tuần sau, task chưa xong đi theo.

AC06: Objective đóng (đạt, chưa đạt, đã chuyển) giữ nguyên tiến độ tại lúc đóng; task gắn xong muộn hoặc bị dời sau đó không làm đổi báo cáo tuần cũ.

AC07: Objective chưa xử lý của tuần trước chuyển "Chưa đạt" khi Weekly planning tuần mới hoàn tất, hoặc hết ngày làm việc đầu tuần mới, tuỳ cái nào tới trước.

## UC4. Gắn task với objective

### US4.1 Gắn task

AC01: Menu "Gắn với objective" (Sunsama: "Align with objective") mở bằng phím R hoặc $ trên task: Không gắn · danh sách objective của tuần chứa task · "Biến task này thành objective" · "Quản lý objective".

AC02: Task gắn có icon objective trên card; tiến độ objective cập nhật ngay.

AC03: "Biến task này thành objective" tạo objective mô tả = tiêu đề task và gắn task đó vào.

AC04: Task là instance lặp: có tuỳ chọn "Gắn cho cả series"; các instance của series trong tuần của objective, kể cả instance sinh sau, cùng được gắn.

## UC5. Analytics

### US5.1 Xem số liệu tuần

User Story: Là Hà, tôi muốn xem và tải số giờ theo ngày và channel của một tuần, để đối chiếu khi xuất hoá đơn.

AC01: Menu workspace → Analytics; mặc định tuần trước (Sunsama "Last week Oct 26–30"), ‹ › đổi tuần.

AC02: Công tắc "Gồm ngày nghỉ" (Sunsama: "Weekends"; mặc định chỉ ngày trong lịch làm việc); lọc "Tổng / personal / work" theo context.

AC03: Tổng tuần (Weekly Totals), giờ theo ngày (Daily Breakdown), phân bổ channel, tỉ lệ hoàn thành task đã lên kế hoạch, độ lệch planned / actual, số ngày vượt ngưỡng, chuỗi ngày làm Daily planning.

AC04: Ít dữ liệu → cảnh báo "Ít dữ liệu. Thêm thời gian thực tế cho task đã xong (di chuột lên task và nhấn E)".

AC05: "Tải xuống" xuất CSV theo tuần và bộ lọc đang xem; số liệu cập nhật ≤ 15 phút, hiện thời điểm cập nhật.

## UC6. Recap tuần qua email

### US6.1 Nhận recap

AC01: Beta; gửi tại mốc đầu ngày của ngày sau ngày làm việc cuối tuần theo lịch làm việc (lịch T2–T6, mốc 04:00 → Thứ Bảy 04:00; lịch T2–T7 → Chủ Nhật 04:00), email tổng kết tuần vừa xong: tổng giờ, giờ theo ngày, top channel, objective và tiến độ, số task xong.

AC02: Thêm tối đa 5 người nhận; bản gửi người khác không chứa task riêng tư `[giả định]`.

AC03: Tuần không có dữ liệu → không gửi. Có nút "Gửi thử cho tôi".

AC04: Email có link huỷ nhận 1 chạm (G12).

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu 1.1** |
|---|---|---|
| Tỉ lệ tuần có Weekly planning | Tuần có Weekly planning hoàn tất / tuần người dùng hoạt động | ≥ 35% |
| Tỉ lệ tuần có Weekly review | Tuần có Weekly review hoàn tất / tuần hoạt động | ≥ 25% |
| Người dùng có objective | Người dùng có ≥ 1 objective trong tuần / người dùng hoạt động | ≥ 40% |
| Tỉ lệ task gắn objective | Task gắn / task có ngày trong tuần, ở người dùng có objective | ≥ 30% |
| Tỉ lệ objective đạt | Objective đạt / objective của tuần | Theo dõi |
| Mở Analytics | Người dùng mở Analytics ≥ 1 lần / tuần | Theo dõi |
| Recap email | Tỉ lệ mở; tỉ lệ huỷ nhận | Mở ≥ 40%; huỷ ≤ 5% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Thời gian thực tế (G07) | Người dùng không chạy timer, analytics rỗng | "Tính planned là actual" (bật mặc định; giá trị chốt trên task lúc hoàn thành, QC-07); cảnh báo ít dữ liệu chỉ cách nhập E |
| Khung wizard, chia sẻ (G08) | G09 dùng lại; G08 thay đổi kéo theo G09 | Một component dùng chung, kiểm thử hồi quy cả hai nhóm; G08 khai báo điểm mở rộng (G08 SRS BR-25) |
| Ảnh chụp kế hoạch (G08) | Tỉ lệ hoàn thành cần kế hoạch từng ngày, kể cả các tuần chạy 1.0 | Đã chốt: G08 lưu ảnh chụp lúc hoàn tất Daily planning từ bản 1.0 (B12) |
| Hiệu năng analytics | Tính lại tuần cho người dùng nhiều task | Bảng tổng hợp theo ngày, job mỗi 15 phút; chỉ tính lại ngày có thay đổi |
| Email recap | Gửi hàng loạt tại mốc đầu ngày ở nhiều timezone; rơi vào spam | Hàng đợi theo timezone, giới hạn tốc độ; SPF / DKIM / DMARC; link huỷ nhận |
| Lộ dữ liệu qua email | Recap / chia sẻ gửi người ngoài | Loại task riêng tư; người dùng thấy xem trước |
| Gói và quyền theo gói (G12) | Chưa rõ analytics, recap thuộc gói nào | Câu hỏi mở |

# 10. Câu hỏi mở

- Nút "Automate" trong Weekly review của Sunsama làm gì? Đề xuất hiện tại: mở cài đặt lịch ritual tuần.
- Objective có cần đánh dấu "đạt" thủ công không, hay chỉ hiện tiến độ? Tiến độ 100% có tự đánh dấu đạt không?
- Task gắn objective bị dời sang tuần khác: giữ liên kết (đề xuất) hay tự bỏ gắn? (Đã chốt một phần 04/11/2026: objective đã đóng giữ tiến độ cố định, nên việc dời không làm đổi báo cáo tuần cũ — C26.)
- Đã chốt 04/11/2026: "task đã lên kế hoạch" = ảnh chụp kế hoạch G08 lưu lúc hoàn tất Daily planning, có từ bản 1.0 (B12). Ngày không có Daily planning vẫn dùng ảnh chụp lúc 12:00 `[giả định]`; chưa rõ nhóm nào chạy job này.
- Chuỗi ngày làm ritual tính Daily planning, Daily shutdown hay cả hai?
- Recap email Beta bật mặc định hay người dùng tự bật?
- Weekly review bỏ lỡ: làm bù được tới hết Chủ Nhật (đề xuất) hay tới khi Weekly planning tuần sau?
- Analytics và recap thuộc gói nào (G12, từ 1.1)?
- Đã chốt 04/11/2026: mốc đầu ngày 04:00, chỉnh 00:00–06:00; tuần và recap tính theo ngày làm việc (Q2, QC-01).
- Đã chốt 04/11/2026: cột ngày lấy từ lịch làm việc; recap gửi tại mốc đầu ngày của ngày sau ngày làm việc cuối tuần (Q19, QC-02).
- Đã chốt 04/11/2026: giờ thực tế cộng theo QC-07, planned chỉ thay cho task không có bản ghi, không cộng hai lần; task ghi chép ritual không tính vào phép đếm task (Q13, C21).
- Đã chốt 04/11/2026: objective chỉ chuyển "Chưa đạt" khi Weekly planning tuần mới hoàn tất hoặc hết ngày làm việc đầu tuần (B13).
- Đã chốt 04/11/2026: gộp review vào planning chèn trước bước 1, một bước Chia sẻ, một email (C25).
- Đã chốt 04/11/2026: tiến độ objective hiện cả % giờ và x/y task, cố định khi objective đóng, có tuỳ chọn gắn cho cả series (C26).
- Weekly planning / Weekly review tự mở vào ngày nghỉ (ví dụ đặt giờ review Thứ Bảy với lịch T2–T6): có chặn như ritual ngày (QC-02) không? Ngày Weekly planning mặc định có theo ngày làm việc đầu tuần không?
- "Gắn cho cả series": phạm vi chỉ các instance trong tuần của objective (đề xuất) hay mọi instance tương lai?
