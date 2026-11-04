> **Mã:** PLN-PRD-G08 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g08-daily-rituals.md

# PRD Daily planning & Daily shutdown trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: bản Daily plan liệt kê cả task đã xong hôm nay; hoàn tất ritual tạo task "Daily planning" đã xong ở #work, notes chứa bản kế hoạch, có thời gian thực tế; mở task này hiện "Use keyboard shortcut P to enter daily planning". Thứ tự 6 bước Daily planning lấy từ help center Sunsama (luồng thủ công, bản Legacy). **Các bước chi tiết của Daily shutdown trên Sunsama chưa kiểm chứng**; luồng shutdown trong tài liệu này là đề xuất, cần kiểm chứng trước khi chốt thiết kế. Chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Ritual là vòng lặp tạo khác biệt của sản phẩm: mở đầu ngày bằng Daily planning, kết thúc ngày bằng Daily shutdown. Nhóm G08 lo hai ritual ngày theo luồng thủ công và việc chia sẻ kết quả ritual (bản kế hoạch, highlights). Ritual không có dữ liệu riêng về công việc: nó dẫn người dùng qua task (G02), board và khối lượng ngày (G04), lịch và timebox (G05), backlog và rollover (G06), thời gian thực tế (G07). Planning Agent và highlights do AI soạn thuộc G10 (1.2); Weekly planning / Weekly review thuộc G09 (1.1).

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Bắt đầu ngày không có kế hoạch, mở hộp thư và làm theo việc đến | Ngày trôi theo việc gấp, việc quan trọng bị dời |
| Nhận quá nhiều việc cho một ngày so với thời gian trống thật (sau khi trừ họp) | Cuối ngày còn nửa danh sách, việc rollover dồn sang hôm sau |
| Việc chưa xong hôm qua nằm lẫn với việc mới | Không quyết định giữ, dời hay bỏ; danh sách phình mãi |
| Không có điểm kết thúc ngày | Làm quá giờ, không biết hôm nay đã làm được gì |
| Báo kế hoạch / kết quả cho quản lý, khách hàng phải gõ lại ở công cụ khác | Mất 10–15 phút mỗi ngày `[giả định]`, dễ quên |

## 1.3 Mục tiêu

- Hoàn tất Daily planning trong ≤ 10 phút (trung vị) `[giả định]`.
- Sau Daily planning, tổng thời lượng kế hoạch của ngày không vượt ngưỡng khối lượng, hoặc người dùng đã thấy cảnh báo và tự quyết.
- Mỗi task chưa xong từ hôm qua được quyết định rõ trong ritual: giữ, dời, đưa vào backlog hoặc đánh dấu xong.
- Cuối ngày có một điểm dừng rõ: biết đã xong gì, thời gian đi vào channel nào, việc còn lại đã có chỗ.
- Gửi bản kế hoạch / highlights cho người khác trong 1 thao tác, không gõ lại.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh (PM, 6–8 cuộc họp / ngày) | Thấy thời gian trống thật sau khi trừ họp; gửi kế hoạch ngày cho team mỗi sáng |
| Minh (designer / dev) | Chốt 1–2 khối làm việc dài và timebox ngay trong lúc plan |
| Hà (freelancer / founder) | Có điểm kết thúc ngày để không làm quá giờ; gửi highlights cho khách hàng |
| Người dùng thành thạo | Mở ritual bằng phím P / O, đi qua các bước bằng ← / →, ẩn bước không cần |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Daily planning thủ công 6 bước: Xem lại hôm qua → Thêm task cho hôm nay → Kiểm tra khối lượng → Chốt → Daily plan → Chia sẻ.
- Daily shutdown 5 bước (đề xuất, chưa kiểm chứng): Việc đã xong → Xử lý task chưa xong → Highlights (biên tập tay) → Chia sẻ → Hoàn tất.
- Tự kích hoạt Daily planning tối đa 1 lần / ngày; nhắc Daily shutdown theo giờ.
- Lưu tiến độ ritual: thoát giữa chừng, mở lại về đúng bước đang làm.
- Task ghi chép ritual (đã xong) tạo khi hoàn tất: notes chứa nội dung ritual, thời gian thực tế = thời gian làm ritual.
- Chia sẻ kết quả ritual: lưu vào task ghi chép (luôn bật), gửi bản sao cho chính mình, gửi email tới người khác; nhớ đích cho lần sau.
- Cài đặt → Ritual: phần ritual ngày.

## 3.2 Ngoài phạm vi

- Planning Agent ("Agentic Daily Planning") và highlights do AI soạn → G10 (1.2).
- Weekly planning, Weekly review, objective tuần → G09 (1.1). Ở 1.0, nguồn "Objective tuần" trong bước Thêm task bị ẩn.
- Đích chia sẻ Slack / Microsoft Teams → G11 (1.2). Kéo item từ công cụ tích hợp vào ngày → G11 (1.1).
- Câu hỏi "Bạn theo dõi công việc ở đâu?" (Sunsama: "Where do you keep track of your work?") để lấy hoạt động từ công cụ nguồn cho highlights → G10 / G11 (1.2).
- Rollover và backlog → G06; timebox → G05; projection và cảnh báo khối lượng → G04; timer → G07. G08 chỉ gọi lại các hành vi này bên trong ritual.

# 4. Nguyên tắc sản phẩm

## 4.1 Dẫn dắt, không ép buộc

Mọi bước có ← / → và bỏ qua được; "Bỏ qua bước này từ lần sau" ẩn bước cho các lần sau, bật lại trong Cài đặt. Thoát giữa chừng không mất gì đã làm.

## 4.2 Nhắc một lần là đủ

Daily planning tự mở tối đa 1 lần / ngày. Vắng nhiều ngày chỉ nhắc ngày hiện tại, không bắt làm bù ngày cũ (EC-27).

## 4.3 Chỉ ghi khi hoàn tất

Task ghi chép ritual chỉ được tạo khi người dùng bấm hoàn tất. Mở xem rồi thoát không để lại task nào trên board (Sunsama có tạo task khi chỉ mở xem; khác có chủ đích, EC-26).

## 4.4 Không gửi gì khi chưa bấm

Bản kế hoạch / highlights chỉ gửi đi khi bấm "Bắt đầu ngày" hoặc "Hoàn tất". Người dùng xem trước đúng nội dung sẽ gửi và chọn nội dung nào được đưa vào.

# 5. Quy tắc và cấu hình ritual ngày

| **Cấu hình** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Giờ Daily planning | 00:00–23:55, bước 5 phút | 09:00 | Theo timezone người dùng |
| Tự kích hoạt Daily planning | Bật / tắt | Bật | Tối đa 1 lần / ngày; vắng nhiều ngày chỉ nhắc hôm nay (EC-27) |
| Sau khi plan đi tới | Home / Today | Home | |
| Tự nhắc Daily shutdown | Bật / tắt | Bật | Chỉ thông báo, không tự mở `[giả định]` |
| Giờ Daily shutdown | 00:00–23:55, bước 5 phút | Giờ kết thúc làm việc (17:00) `[giả định]` | Cũng là "giờ kết thúc ngày" mặc định ở bước Chốt |
| Thông điệp cuối ngày | 0–280 ký tự | "Hôm nay vậy là đủ. Hẹn gặp lại ngày mai." `[giả định]` | Hiện ở màn Hoàn tất shutdown |
| Channel cho task ritual | Một channel của người dùng | `work` (theo kiểm chứng #work) | Channel bị xoá → về channel mặc định (G02) |
| Ngưỡng khối lượng | 1–24 giờ | 8 giờ | Dùng chung với G04 |
| Mẹo khối lượng | Văn bản | Khoảng 5,5 giờ cho ngày 9–5 có nghỉ trưa | Chỉ gợi ý, không chặn |
| Bước ẩn ("Bỏ qua bước này từ lần sau") | Theo từng bước, trừ bước Chia sẻ / Hoàn tất | Không ẩn bước nào | |
| Nội dung bản kế hoạch ("Tuỳ chỉnh") | 5 tuỳ chọn | Phân bổ thời gian: bật; subtask, task riêng tư, channel, task xong hôm trước: tắt `[giả định]` | Chọn nội dung, không phải chọn bước |
| Ô "Trở ngại" / Highlights | 0–5.000 ký tự | Trống / sinh sẵn | |
| Đích chia sẻ | Tối đa 10 / người dùng; 20 email chia sẻ / ngày | Không có | Email ở 1.0; Slack / Teams 1.2 |
| Thời gian ritual tính vào actual | Tối đa 120 phút / lần | | Bỏ khoảng không tương tác > 5 phút |
| Mốc bắt đầu ngày làm việc | day_start_time | 04:00 `[giả định — chờ PO chốt 04:00 hay 00:00]` | Xác định "hôm nay", "hôm qua" của ritual |

- Các giá trị là **cấu hình hệ thống / cài đặt người dùng**, không hard-code.
- Cài đặt ritual tuần (Thứ Hai 08:00, Thứ Sáu 15:00) → G09. Giờ nháp highlights AI (T2–T6 17:00) → G10.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Nhắc | Lần đầu mở app sau 09:00 (hoặc tới 09:00 khi app đang mở), Daily planning tự mở; hoặc phím P | Ritual hôm nay đang làm |
| 2 | Xem lại hôm qua | Quyết định từng task chưa xong: giữ, dời, backlog, xong | Không còn việc "lơ lửng" |
| 3 | Thêm task | Kéo từ lịch, backlog vào hôm nay; gõ task mới | Danh sách hôm nay đủ việc |
| 4 | Kiểm tra khối lượng | So tổng thời lượng với thời gian trống; dời bớt nếu đỏ | Ngày vừa sức |
| 5 | Chốt | Sắp thứ tự, timebox, đặt giờ kết thúc ngày; xem giờ dự kiến xong | Kế hoạch có giờ |
| 6 | Daily plan & chia sẻ | Đọc / sửa bản kế hoạch, ghi trở ngại, chọn nơi gửi, "Bắt đầu ngày" | Task ghi chép "Daily planning", email đã gửi |
| 7 | Làm việc | Focus, timer, hoàn thành task (G04–G07) | Thời gian thực tế |
| 8 | Daily shutdown | 17:00 có nhắc; xem việc đã xong, xử lý việc còn lại, viết highlights, chia sẻ | Task ghi chép "Daily shutdown", thông điệp cuối ngày |

Bước 7 thuộc nhóm khác, chỉ nêu để thấy vị trí của G08. PRD này tập trung bước 1–6 và 8.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Daily planning

### US1.1 Mở Daily planning

AC01: Mở được bằng phím P, mục "Daily planning" ở sidebar, nút "Plan" khi hover cột ngày (G04), hoặc từ lời nhắc.

AC02: Tự mở lần đầu người dùng mở app sau giờ Daily planning (hoặc khi tới giờ mà app đang mở), tối đa 1 lần / ngày. Vắng nhiều ngày chỉ mở cho hôm nay (EC-27).

AC03: Ritual đang làm dở → mở lại đúng bước đang làm, giữ dữ liệu đã nhập.

AC04: Ritual hôm nay đã hoàn tất → mở bản kế hoạch đã chốt ở chế độ xem, có nút "Lên kế hoạch lại".

AC05: Mở cho ngày tương lai qua nút "Plan" trên cột ngày được; ngày đã qua chỉ xem bản đã có.

### US1.2 Xem lại hôm qua

User Story: Là người dùng, tôi muốn quyết định nhanh từng việc chưa xong từ hôm qua, để danh sách hôm nay không phình vì việc cũ.

AC01: Liệt kê task chưa xong đã rollover vào ngày đang plan (G06), kèm số ngày đã rollover.

AC02: Mỗi task có 4 thao tác: Giữ hôm nay (mặc định), Dời (ngày mai hoặc chọn ngày, phím D), Đưa vào backlog (chọn bucket, phím Z), Đánh dấu xong (phím C).

AC03: Thao tác áp dụng ngay, có toast Hoàn tác.

AC04: Không có task nào → "Không còn việc nào từ hôm qua", nút Tiếp.

### US1.3 Thêm task cho hôm nay

AC01: Bên trái là danh sách hôm nay; bên phải là nguồn: Lịch (sự kiện của ngày), Backlog (bucket "Tuần tới" ở đầu `[giả định]`), ô tạo task mới (G02).

AC02: Kéo vào danh sách hôm nay hoặc bấm "+ Hôm nay" trên item; kéo từ sự kiện lịch tạo task gắn sự kiện đó, không tạo sự kiện mới `[giả định]`.

AC03: Nguồn Tích hợp (G11, 1.1) và Objective tuần (G09, 1.1) ẩn ở 1.0.

### US1.4 Kiểm tra khối lượng

User Story: Là Linh, tôi muốn thấy ngay ngày hôm nay còn bao nhiêu giờ trống sau khi trừ họp, để không nhận quá nhiều việc.

AC01: Hiện tổng thời lượng kế hoạch và thời gian trống trong giờ làm việc (đã trừ sự kiện bận).

AC02: Tổng > min(ngưỡng 8 giờ, thời gian trống) → tổng màu đỏ, task vượt có chấm cảnh báo "Chỉ còn X giờ trống" (giống G04).

AC03: Có mẹo: một ngày 9–5 có nghỉ trưa thường chỉ đủ khoảng 5,5 giờ việc.

AC04: Quá tải không chặn bước sau; người dùng dời bớt task (D, Z) ngay tại bước này.

### US1.5 Chốt kế hoạch

AC01: Sắp thứ tự task bằng kéo thả hoặc Ctrl+↑ / ↓.

AC02: Kéo task vào lịch ngày bên phải để timebox (G05).

AC03: Đặt giờ kết thúc ngày; mặc định = giờ Daily shutdown.

AC04: Hệ thống hiện "Dự kiến xong lúc {giờ}" (từ projection và timebox); muộn hơn giờ kết thúc ngày → cảnh báo, không chặn.

### US1.6 Daily plan

AC01: Tự sinh "Kế hoạch hôm nay" (Sunsama: "Planned for today"): mỗi dòng tên task + thời lượng, theo thứ tự trên board, gồm cả task đã xong hôm nay.

AC02: Ô "Trở ngại" (Sunsama: "Obstacles in my way") ngay dưới bản kế hoạch.

AC03: "Tuỳ chỉnh" chọn nội dung bản kế hoạch: phân bổ thời gian (bật), subtask, task riêng tư, channel, task đã xong hôm trước. Không phải chọn bước.

AC04: Sửa tay được; "Làm mới" sinh lại, hỏi trước nếu đã sửa tay.

AC05: "Đây là gì?" giải thích ngắn về bước; "Bỏ qua bước này từ lần sau" ẩn bước.

## UC2. Chia sẻ kết quả ritual

### US2.1 Chọn nơi gửi và gửi

User Story: Là Linh, tôi muốn kế hoạch ngày tự gửi tới team khi tôi bấm bắt đầu, để không phải gõ lại trên công cụ khác.

AC01: Ba nhóm đích: "Lưu vào task ritual" (luôn bật, không tắt được), "Gửi bản sao cho chính tôi" (bật / tắt), "Thêm nơi nhận" (email ở 1.0; Slack / Teams ở 1.2, G11).

AC02: Xem trước đúng nội dung sẽ gửi, theo tuỳ chọn "Tuỳ chỉnh".

AC03: Chỉ gửi khi bấm "Bắt đầu ngày" (Daily planning) hoặc "Hoàn tất" (Daily shutdown); thoát trước đó không gửi gì.

AC04: Lựa chọn đích được nhớ cho lần sau, riêng cho từng loại ritual.

AC05: Gửi lỗi không chặn hoàn tất ritual; thông báo trong app có nút "Thử lại".

## UC3. Daily shutdown

### US3.1 Mở Daily shutdown

AC01: Mở bằng phím O, mục "Daily shutdown" ở sidebar hoặc lời nhắc.

AC02: Tới giờ shutdown → thông báo trong app (desktop 1.1: thông báo hệ thống), 1 lần / ngày; không tự mở `[giả định]`.

### US3.2 Xem việc đã xong

User Story: Là Hà, tôi muốn thấy hôm nay đã xong gì và thời gian đi vào khách hàng nào, để dừng làm với cảm giác đủ.

AC01: Liệt kê task xong hôm nay kèm "actual / planned"; tổng thời gian thực tế; phân bổ theo channel.

AC02: Timer đang chạy → hiện tên task và nút "Dừng timer" (G07) `[giả định]`.

### US3.3 Xử lý task chưa xong

AC01: Mỗi task chưa xong của hôm nay: Ngày mai (mặc định `[giả định]`), Đưa vào backlog, Đánh dấu xong.

AC02: Áp dụng ngay, có toast Hoàn tác. Task để ngày mai được đặt lại số ngày rollover (đổi ngày tay, G06).

### US3.4 Highlights

AC01: 1.0: sinh sẵn danh sách task đã xong dạng gạch đầu dòng, người dùng sửa tay.

AC02: 1.2: AI soạn nháp từ task xong và hoạt động ở công cụ kết nối (G10).

### US3.5 Hoàn tất

AC01: Bấm "Hoàn tất" → tạo task ghi chép "Daily shutdown", gửi chia sẻ (UC2), hiện thông điệp cuối ngày theo cài đặt.

AC02: Sau hoàn tất, người dùng vẫn dùng app bình thường; mở lại phím O thấy bản đã chốt và nút "Làm lại".

## UC4. Ghi chép ritual

### US4.1 Task ghi chép ritual

AC01: Hoàn tất ritual tạo 1 task "Daily planning" hoặc "Daily shutdown" đã xong, ngày = ngày của ritual, channel = channel cho task ritual.

AC02: Notes chứa nội dung đã chốt (bản kế hoạch + trở ngại, hoặc việc đã xong + highlights).

AC03: Thời gian thực tế = thời gian làm ritual, tối đa 120 phút `[giả định]`; không ảnh hưởng timer đang chạy.

AC04: Mở task hiện gợi ý "Dùng phím P để vào Daily planning" (O với shutdown).

AC05: Mở xem, chuyển bước rồi thoát, hoặc bỏ qua ritual → không tạo task (EC-26).

AC06: Lên kế hoạch lại trong cùng ngày → cập nhật task ghi chép cũ, không tạo task thứ hai; thời gian cộng dồn.

## UC5. Cấu hình ritual ngày

### US5.1 Đổi cài đặt ritual

AC01: Cài đặt → Ritual có: giờ Daily planning, tự kích hoạt, sau khi plan đi tới, tự nhắc shutdown, giờ shutdown, thông điệp cuối ngày, channel cho task ritual, danh sách bước đã ẩn.

AC02: Lưu ngay, áp dụng ngay; đổi giờ plan sau khi hôm nay đã tự mở thì không mở lại trong ngày.

AC03: Bật lại bước đã ẩn từ danh sách bước đã ẩn.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ ngày có Daily planning | Ngày có Daily planning hoàn tất / ngày người dùng hoạt động | ≥ 50% |
| Thời gian Daily planning | Từ mở đến "Bắt đầu ngày" | ≤ 10 phút (trung vị) |
| Tỉ lệ bỏ dở | Ritual mở nhưng hết ngày chưa hoàn tất / ritual đã mở | ≤ 30% |
| Tỉ lệ đóng ngay khi tự mở | Tự mở rồi thoát trong 10 giây / số lần tự mở | Theo dõi (cao = nhắc gây phiền) |
| Tỉ lệ ngày quá tải sau planning | Ngày còn đỏ sau "Bắt đầu ngày" / ngày có planning | Theo dõi, giảm dần |
| Tỉ lệ ngày có Daily shutdown | Ngày có shutdown hoàn tất / ngày hoạt động | ≥ 30% |
| Tỉ lệ có chia sẻ | Ritual hoàn tất có ≥ 1 đích ngoài "Lưu vào task" / ritual hoàn tất | Theo dõi |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Rollover (G06) | Job rollover chạy mỗi 15 phút; người dùng mở app ngay sau day_start_time có thể chưa được rollover | Trước khi tải bước 1, gọi rollover cho người dùng đó nếu chưa chạy (idempotent) |
| Lịch chưa kết nối (G05) | Thời gian trống chỉ tính theo giờ làm việc, bỏ sót họp | Bước Kiểm tra khối lượng nhắc kết nối lịch; không chặn |
| Shutdown chưa kiểm chứng | Luồng shutdown là đề xuất, có thể lệch hành vi người dùng đã quen trên Sunsama | Kiểm chứng trên Sunsama trước khi chốt thiết kế; thử nghiệm với 5 người dùng |
| Email chia sẻ ra ngoài | Rơi vào spam, bị lạm dụng gửi thư rác | SPF / DKIM / DMARC; reply-to = email người dùng; tối đa 20 email / ngày; link huỷ nhận |
| Tự mở gây phiền | Người dùng đóng ngay, tắt tính năng | 1 lần / ngày; không tự mở khi đang gõ hoặc đang Focus; theo dõi tỉ lệ đóng ngay |
| day_start_time chưa chốt | "Hôm nay", "hôm qua" của ritual phụ thuộc mốc này | Cấu hình; chờ PO chốt |
| Hết trial giữa ritual (G12) | Ritual đang làm bị chặn ghi | Cho hoàn tất ritual đang làm rồi mới chuyển chỉ đọc (EC-34) |

# 10. Câu hỏi mở

- day_start_time là 04:00 hay 00:00?
- Các bước Daily shutdown của Sunsama thực tế là gì (chưa kiểm chứng)? Luồng 5 bước đề xuất có cần chỉnh không?
- Giờ Daily shutdown mặc định = giờ kết thúc làm việc (17:00) hay một cài đặt riêng?
- Shutdown có tự mở như Daily planning không, hay chỉ nhắc?
- Đánh dấu xong ở bước "Xem lại hôm qua" ghi ngày hoàn thành là hôm nay (theo quy tắc chung) hay hôm qua?
- Thời gian ritual có được trừ khi người dùng đang chạy timer task khác cùng lúc không?
- Gửi email tới địa chỉ ngoài workspace có cần người nhận xác nhận lần đầu không?
- Kéo sự kiện lịch vào hôm nay: tạo task gắn sự kiện có tính trùng thời lượng vào khối lượng ngày không?
- Bucket backlog nào được coi là "tới kỳ" để hiện ở bước Thêm task (G06)?
