> **Mã:** PLN-PRD-G08 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g08-daily-rituals.md

# PRD Daily planning & Daily shutdown (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: bản Daily plan liệt kê cả task đã xong hôm nay; hoàn tất ritual tạo task "Daily planning" đã xong ở #work, notes chứa bản kế hoạch, có thời gian thực tế; mở task này hiện "Use keyboard shortcut P to enter daily planning". Help center Sunsama mô tả Daily planning thủ công (bản Legacy) có **5 chặng**: Reflect on yesterday → Add tasks → Check predicted workload → Finalize → Share your plan / Daily plan. Ta tách chặng cuối thành hai bước "Daily plan" và "Chia sẻ" (màn Chia sẻ dùng chung cho hai ritual), nên có 6 bước; đây là lựa chọn của ta, không phải của Sunsama (C35, [research](../research/sunsama-daily-rituals.md)). **Các bước chi tiết của Daily shutdown trên Sunsama chưa kiểm chứng**; luồng shutdown trong tài liệu này là đề xuất, cần kiểm chứng trước khi chốt thiết kế. Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> Đã sửa theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md) và [câu hỏi chốt 09/11/2026](../review/cau-hoi-chot-flow-2026-11-09.md) (A3, A5, B28–B35, C31–C35). Quy tắc dùng chung (`QC-xx`) xem [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md): ngày làm việc (QC-01), lịch làm việc và khung giờ channel (QC-02), số ngày bị hoãn (QC-04), đổi ngày task (QC-05), instance trùng series (QC-06), bản ghi thời gian (QC-07), chế độ chỉ đọc (QC-09, bản 1.1), trợ lý AI qua Claude Code CLI (QC-12). Thuật ngữ xem [`CONTEXT.md`](../../CONTEXT.md).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Ritual là vòng lặp tạo khác biệt của sản phẩm: mở đầu ngày bằng Daily planning, kết thúc ngày bằng Daily shutdown. Nhóm G08 lo hai ritual ngày theo luồng thủ công và việc chia sẻ kết quả ritual (bản kế hoạch, highlights). Ritual không có dữ liệu riêng về công việc: nó dẫn người dùng qua task (G02), board và khối lượng ngày (G04), lịch và timebox (G05), backlog và rollover (G06), thời gian thực tế (G07). Planning Agent và highlights do AI soạn thuộc G10, có từ **1.0** qua Claude Code CLI khi người dùng bật trợ lý AI (QC-12, Q46); Weekly planning / Weekly review thuộc G09 (1.1).

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
- Sau Daily planning, ngày không quá tải theo sức chứa của G04 (QC-02 mục 7, Q48), hoặc người dùng đã thấy cảnh báo và tự quyết.
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

- Nền tảng (Q45, ADR-0005): bản 1.0 là app Windows; web và macOS từ 1.1; iOS / Android từ 1.2, dùng cùng đặc tả. Nhắc ritual ở 1.0 bằng thông báo Windows và thông báo trong app (kênh theo G12, D12).
- Daily planning thủ công 6 bước: Xem lại hôm qua → Thêm task cho hôm nay → Kiểm tra khối lượng → Chốt → Daily plan → Chia sẻ.
- Daily shutdown 5 bước (đề xuất, chưa kiểm chứng): Việc đã xong → Xử lý task chưa xong (có "Để tự chuyển sang mai" để bỏ qua cả bước) → Highlights (biên tập tay; khi trợ lý AI bật thì điền sẵn nháp AI do G10 soạn) và ô ghi chú riêng → Chia sẻ → Hoàn tất.
- Tự kích hoạt Daily planning tối đa 1 lần / ngày; nhắc Daily shutdown theo giờ; chỉ vào ngày làm việc theo **lịch chung** (QC-02 mục 8). Khung giờ channel không làm ritual mở thêm vào ngày nghỉ của lịch chung.
- Nút "Hoàn tác kế hoạch AI" ở bước Daily plan (1.0, chỉ hiện khi trợ lý AI bật và Planning Agent đã áp dụng kế hoạch cho ngày đó).
- Lưu tiến độ ritual: thoát giữa chừng, mở lại về đúng bước đang làm. Ritual vắt qua mốc đầu ngày được hoàn tất cho ngày cũ trong 2 giờ.
- Task ghi chép ritual (đã xong) tạo khi hoàn tất: notes chứa nội dung ritual, thời gian thực tế = thời gian làm ritual (chỉ khi không có timer đang chạy, QC-07).
- Lưu ảnh chụp kế hoạch khi hoàn tất Daily planning (task, planned, quá tải, thời gian trống) để G09 tính analytics từ dữ liệu bản 1.0.
- Chia sẻ kết quả ritual: lưu vào task ghi chép (luôn bật), gửi bản sao cho chính mình, gửi email tới người khác; nhớ đích cho lần sau.
- Cài đặt → Ritual: phần ritual ngày.

## 3.2 Ngoài phạm vi

- Planning Agent ("Agentic Daily Planning") và highlights do AI soạn → G10, có từ 1.0 qua Claude Code CLI (QC-12). Thay đổi AI áp dụng ngay, gắn chip "AI", có Hoàn tác (QC-12 mục 5); G08 chỉ đặt nút "Hoàn tác kế hoạch AI" ở bước Daily plan và chỗ nhận nháp highlights ở bước Highlights. Máy chưa có Claude Code hoặc trợ lý AI tắt → ritual chạy đủ luồng thủ công (QC-12 mục 2).
- Weekly planning, Weekly review, objective tuần → G09 (1.1). Ở 1.0, nguồn "Objective tuần" trong bước Thêm task bị ẩn. G08 khai báo trước điểm mở rộng cho G09 (SRS BR-25).
- Đích chia sẻ Slack / Microsoft Teams → G11 (1.2). Tab Tích hợp trong bước Thêm task và kéo item vào Backlog → G11 đặc tả (1.1).
- Chế độ chỉ đọc → bản 1.1 (QC-09). Bản 1.0 miễn phí, gắn nhãn Beta.
- Câu hỏi "Bạn theo dõi công việc ở đâu?" (Sunsama: "Where do you keep track of your work?") để lấy hoạt động từ công cụ nguồn cho highlights → G10 / G11 (cần tích hợp của G11, từ 1.1; dữ liệu tích hợp chỉ vào ngữ cảnh AI khi bật công tắc riêng, QC-12 mục 6).
- Rollover và backlog → G06; timebox → G05; projection và cảnh báo khối lượng → G04; timer → G07. G08 chỉ gọi lại các hành vi này bên trong ritual.

# 4. Nguyên tắc sản phẩm

## 4.1 Dẫn dắt, không ép buộc

Mọi bước có ← / → và bỏ qua được; "Bỏ qua bước này từ lần sau" ẩn bước cho các lần sau, bật lại trong Cài đặt, trừ bước Chia sẻ và Hoàn tất. Thoát giữa chừng không mất gì đã làm.

## 4.2 Nhắc một lần là đủ

Daily planning tự mở tối đa 1 lần / ngày. Vắng nhiều ngày chỉ nhắc ngày hiện tại, không bắt làm bù ngày cũ (EC-27). Không nhắc, không tự mở vào ngày nghỉ theo lịch chung (QC-02 mục 8), sau giờ shutdown, hoặc khi shutdown hôm nay đã hoàn tất.

## 4.3 Chỉ ghi khi hoàn tất

Task ghi chép ritual chỉ được tạo khi người dùng bấm hoàn tất. Mở xem rồi thoát không để lại task nào trên board (Sunsama có tạo task khi chỉ mở xem; khác có chủ đích, EC-26).

## 4.4 Không gửi gì khi chưa bấm

Bản kế hoạch / highlights chỉ gửi đi khi bấm "Bắt đầu ngày" hoặc "Hoàn tất". Người dùng xem trước đúng nội dung sẽ gửi và chọn nội dung nào được đưa vào.

# 5. Quy tắc và cấu hình ritual ngày

| **Cấu hình** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Giờ Daily planning | 00:00–23:55, bước 5 phút | 09:00 | Theo timezone người dùng |
| Tự kích hoạt Daily planning | Bật / tắt | Bật | Tối đa 1 lần / ngày, chỉ ngày làm việc, trước giờ shutdown và khi shutdown chưa hoàn tất; vắng nhiều ngày chỉ nhắc hôm nay (EC-27) |
| Sau khi plan đi tới | Home / Today | Home | |
| Tự nhắc Daily shutdown | Bật / tắt | Bật | Chỉ thông báo, không tự mở `[giả định]` |
| Giờ Daily shutdown | 00:00–23:55, bước 5 phút | Giờ kết thúc làm việc của ngày theo lịch chung (17:00) `[giả định]` | Cũng là "giờ kết thúc ngày" mặc định ở bước Chốt. Không đọc khung giờ channel (QC-02 mục 8) |
| Thông điệp cuối ngày | 0–280 ký tự | "Hôm nay vậy là đủ. Hẹn gặp lại ngày mai." `[giả định]` | Hiện ở màn Hoàn tất shutdown |
| Channel cho task ritual | Một channel của người dùng | `work` (theo kiểm chứng #work) | Channel bị xoá → về channel mặc định (G02) |
| Ngưỡng khối lượng | 1–24 giờ | 8 giờ | Dùng chung với G04; chỉ là giới hạn riêng của lịch chung, áp cho task không có khung channel; không lấy min với sức chứa (QC-02 mục 7, Q48) |
| Mẹo khối lượng | Văn bản | Khoảng 5,5 giờ cho ngày 9–5 có nghỉ trưa | Chỉ gợi ý, không chặn |
| Bước ẩn ("Bỏ qua bước này từ lần sau") | Theo từng bước, trừ bước Chia sẻ (mọi ritual) và Hoàn tất (shutdown) | Không ẩn bước nào | Đã chốt (C24) |
| Nội dung bản kế hoạch ("Tuỳ chỉnh") | 5 tuỳ chọn | Phân bổ thời gian: bật; subtask, task riêng tư, channel, task xong hôm trước: tắt `[giả định]` | Chọn nội dung, không phải chọn bước |
| Ô "Trở ngại" / Highlights / Ghi chú riêng | 0–5.000 ký tự | Trống / sinh sẵn / trống | Ghi chú riêng chỉ mình người dùng thấy, không bao giờ gửi đi (B34) |
| Đích chia sẻ | Tối đa 10 / người dùng; 20 email chia sẻ / ngày | Không có | Email ở 1.0; Slack / Teams 1.2 |
| Thời gian ritual tính vào actual | Tối đa 120 phút / lần | | Bỏ khoảng không tương tác > 5 phút; chỉ ghi khi không có timer đang chạy (QC-07, đã chốt) |
| Mốc đầu ngày | 00:00–06:00 | 04:00 | Đã chốt (QC-01). Xác định "hôm nay", "hôm qua" của ritual |
| Ngày có ritual | Lịch chung (G01) | Thứ Hai–Thứ Sáu | Đã chốt (QC-02 mục 8). Ngày nghỉ của lịch chung không nhắc, không tự mở, kể cả khi có khung giờ channel vào ngày đó. "Ngày mai" của từng task = ngày làm việc kế tiếp **theo lịch của task** (khung giờ channel nếu có, ngược lại lịch chung; QC-02 mục 6) |
| Ân hạn ritual vắt qua mốc đầu ngày | 2 giờ sau mốc | — | Đã chốt (Q18). Rollover chờ phiên shutdown trong khoảng này |

- Các giá trị là **cấu hình hệ thống / cài đặt người dùng**, không hard-code.
- Cài đặt ritual tuần (Thứ Hai 08:00, Thứ Sáu 15:00) → G09. Nháp highlights AI → G10: soạn vào các ngày trong lịch làm việc, tại giờ kết thúc của lịch chung; app không mở lúc đó thì soạn khi mở app lần kế tiếp trong ngày (Q39, D7, QC-12), chỉ khi trợ lý AI bật.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Nhắc | Ngày làm việc: lần đầu mở app sau 09:00 (hoặc tới 09:00 khi app đang mở), Daily planning tự mở; hoặc phím P | Ritual hôm nay đang làm |
| 2 | Xem lại hôm qua | Quyết định từng task chưa xong: giữ, dời, backlog, xong | Không còn việc "lơ lửng" |
| 3 | Thêm task | Kéo từ lịch, backlog vào hôm nay; gõ task mới | Danh sách hôm nay đủ việc |
| 4 | Kiểm tra khối lượng | So tổng thời lượng với thời gian trống; dời bớt nếu đỏ | Ngày vừa sức |
| 5 | Chốt | Sắp thứ tự, timebox, đặt giờ kết thúc ngày; xem giờ dự kiến xong | Kế hoạch có giờ |
| 6 | Daily plan & chia sẻ | Đọc / sửa bản kế hoạch, ghi trở ngại, chọn nơi gửi, "Bắt đầu ngày" | Task ghi chép "Daily planning", ảnh chụp kế hoạch, email đã gửi |
| 7 | Làm việc | Focus, timer, hoàn thành task (G04–G07) | Thời gian thực tế |
| 8 | Daily shutdown | 17:00 có nhắc; xem việc đã xong, xử lý việc còn lại, viết highlights, chia sẻ | Task ghi chép "Daily shutdown", thông điệp cuối ngày |

Bước 7 thuộc nhóm khác, chỉ nêu để thấy vị trí của G08. PRD này tập trung bước 1–6 và 8.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Daily planning

### US1.1 Mở Daily planning

AC01: Mở được bằng phím P, mục "Daily planning" ở sidebar, nút "Plan" khi hover cột ngày (G04), hoặc từ lời nhắc.

AC02: Tự mở lần đầu người dùng mở app sau giờ Daily planning (hoặc khi tới giờ mà app đang mở), tối đa 1 lần / ngày. Vắng nhiều ngày chỉ mở cho hôm nay (EC-27). Không tự mở khi: hôm nay là ngày nghỉ theo lịch chung (QC-02 mục 8); đã qua giờ Daily shutdown; Daily shutdown hôm nay đã hoàn tất.

AC03: Ritual đang làm dở → mở lại đúng bước đang làm, giữ dữ liệu đã nhập.

AC04: Ritual hôm nay đã hoàn tất → mở bản kế hoạch đã chốt ở chế độ xem, có nút "Lên kế hoạch lại". Lên kế hoạch lại rồi bỏ dở tới hết ngày → ritual vẫn là "đã hoàn tất" với nội dung cũ; chuỗi ngày và analytics không bị ảnh hưởng.

AC05: Mở cho ngày tương lai qua nút "Plan" trên cột ngày được, tối đa tới hôm nay + 7 ngày; cột xa hơn không có nút "Plan" (B29). Ngày đã qua chỉ xem bản đã có.

AC06: Ritual mở trước mốc đầu ngày (ví dụ 03:55) được hoàn tất cho ngày cũ tới tối đa 2 giờ sau mốc; trong lúc đó có banner nhắc thời gian còn lại.

AC07: Phiên Daily planning đầu tiên, mở ngay sau onboarding (G01 US2.2), ở **chế độ có hướng dẫn**: đầu mỗi bước có một dòng lời dẫn ngắn, khái niệm lần đầu gặp có tooltip (G01 US2.3), không có "Bỏ qua bước này"; task vừa tạo ở onboarding đã có trong danh sách. Các lần sau là Daily planning thường (F3, 06/11/2026).

AC08: Không có chế độ buổi tối ở 1.0: phím P, sidebar và tự mở luôn mở ngày hôm nay; muốn lên kế hoạch ngày mai thì bấm "Plan" trên cột ngày mai (B31).

AC09: Bản 1.0, trợ lý AI bật: đầu bước 1 có nút "Plan my day" (Planning Agent, G10). Chạy xong thì nhảy thẳng tới bước Daily plan; lỗi hoặc bấm Dừng thì về lại bước 1 (B28).

### US1.2 Xem lại hôm qua

User Story: Là người dùng, tôi muốn quyết định nhanh từng việc chưa xong từ hôm qua, để danh sách hôm nay không phình vì việc cũ.

AC01: Liệt kê task chưa xong của ngày đang plan có số ngày bị hoãn ≥ 1 (QC-04), kèm nhãn "Dời {n} ngày". Trước khi tải, hệ thống bảo đảm rollover của người dùng đã chạy xong (API "đảm bảo rollover" của G06). Task được người dùng dời bằng "Ngày mai" ở shutdown hôm trước vẫn hiện ở đây.

AC02: Mỗi task có 4 thao tác: Giữ hôm nay (mặc định), Dời (phím D / "Ngày mai" = ngày làm việc kế tiếp theo lịch của task — khung giờ channel nếu có, ngược lại lịch chung (QC-02 mục 6) — không reset số ngày bị hoãn; hoặc chọn ngày, có reset), Đưa vào backlog (chọn bucket, phím Z), Đánh dấu xong (phím C; ngày hoàn thành là hôm nay theo ngày làm việc). Timebox, timer, sự kiện lịch ngoài xử lý theo QC-05.

AC03: Thao tác áp dụng ngay, có toast Hoàn tác. Instance lặp bị dời vào ngày đã có instance cùng series → QC-06.

AC04: Không có task nào → "Không còn việc nào từ hôm qua", nút Tiếp.

AC05: Daily shutdown của ngày làm việc trước đó đã hoàn tất → bỏ qua bước này, mở thẳng bước Thêm task, vì việc xem lại đã làm lúc shutdown; thanh bước vẫn cho bấm vào xem (B32).

### US1.3 Thêm task cho hôm nay

AC01: Bên trái là danh sách hôm nay; bên phải là nguồn: Lịch (sự kiện của ngày), Backlog (bucket "Tuần tới" ở đầu `[giả định]`), ô tạo task mới (G02).

AC02: Kéo vào danh sách hôm nay hoặc bấm "+ Hôm nay" trên item; kéo từ sự kiện lịch tạo task có timebox liên kết sự kiện (G05): không tạo sự kiện mới, giờ đi theo sự kiện gốc, không tính xung đột, thời lượng không bị trừ hai lần khỏi thời gian trống.

AC03: Nguồn Tích hợp (G11 đặc tả, 1.1) và Objective tuần (G09, 1.1) ẩn ở 1.0.

### US1.4 Kiểm tra khối lượng

User Story: Là Linh, tôi muốn thấy ngay ngày hôm nay còn bao nhiêu giờ trống sau khi trừ họp, để không nhận quá nhiều việc.

AC01: Hiện tổng thời lượng của task chưa xong và thời gian trống **còn lại** trong ngày theo sức chứa của G04 (hợp của lịch chung và các khung giờ channel trong ngày, QC-02 mục 7; đã trừ sự kiện bận; plan giữa ngày chỉ tính từ thời điểm hiện tại). Sức chứa không lấy min với ngưỡng khối lượng (Q48).

AC02: Quá tải theo định nghĩa của G04 (planned của task chưa xong > sức chứa còn lại) → tổng màu đỏ, task vượt có chấm cảnh báo "Chỉ còn X giờ trống" (giống G04).

AC03: Có mẹo: một ngày 9–5 có nghỉ trưa thường chỉ đủ khoảng 5,5 giờ việc.

AC04: Quá tải không chặn bước sau; người dùng dời bớt task (D, Z) ngay tại bước này.

### US1.5 Chốt kế hoạch

AC01: Sắp thứ tự task bằng kéo thả hoặc Ctrl+↑ / ↓.

AC02: Kéo task vào lịch ngày bên phải để timebox (G05).

AC03: Đặt giờ kết thúc ngày; mặc định = giờ Daily shutdown.

AC04: Hệ thống hiện "Dự kiến xong lúc {giờ}" (từ projection và timebox); muộn hơn giờ kết thúc ngày → cảnh báo, không chặn.

### US1.6 Daily plan

AC01: Tự sinh "Kế hoạch hôm nay" (Sunsama: "Planned for today"): mỗi dòng tên task + thời lượng, theo thứ tự trên board, gồm cả task đã xong hôm nay (trừ task ghi chép ritual).

AC02: Ô "Trở ngại" (Sunsama: "Obstacles in my way") ngay dưới bản kế hoạch.

AC03: "Tuỳ chỉnh" chọn nội dung bản kế hoạch: phân bổ thời gian (bật), subtask, task riêng tư, channel, task đã xong hôm trước. Không phải chọn bước.

AC04: Sửa tay được; "Làm mới" sinh lại, hỏi trước nếu đã sửa tay.

AC05: "Đây là gì?" giải thích ngắn về bước; "Bỏ qua bước này từ lần sau" ẩn bước.

AC06: Bản 1.0 (Q46, QC-12): trợ lý AI đang bật và Planning Agent (G10) đã áp dụng kế hoạch cho ngày này → bước có nút "Hoàn tác kế hoạch AI"; bấm sẽ trả các thay đổi của agent về như trước, giữ sửa đổi của người dùng, rồi sinh lại bản kế hoạch (hỏi trước nếu đã sửa tay). Trợ lý AI tắt hoặc máy chưa có Claude Code → không hiện nút.

### US1.7 Ảnh chụp kế hoạch

User Story: Là người dùng, tôi muốn analytics tuần sau này biết tôi đã định làm gì mỗi sáng, để tỉ lệ hoàn thành phản ánh đúng kế hoạch, kể cả những tuần dùng bản 1.0.

AC01: Bấm "Bắt đầu ngày" lưu ảnh chụp kế hoạch: danh sách task chưa xong của ngày, planned từng task, tổng planned, thời gian trống còn lại, ngày có quá tải hay không.

AC02: Lên kế hoạch lại lưu thêm bản mới; analytics dùng bản lần đầu `[giả định]`.

AC03: Mở xem rồi thoát không lưu ảnh chụp (EC-26).

## UC2. Chia sẻ kết quả ritual

### US2.1 Chọn nơi gửi và gửi

User Story: Là Linh, tôi muốn kế hoạch ngày tự gửi tới team khi tôi bấm bắt đầu, để không phải gõ lại trên công cụ khác.

AC01: Ba nhóm đích: "Lưu vào task ritual" (luôn bật, không tắt được), "Gửi bản sao cho chính tôi" (bật / tắt), "Thêm nơi nhận" (email ở 1.0; Slack / Teams ở 1.2, G11).

AC02: Xem trước đúng nội dung sẽ gửi, theo tuỳ chọn "Tuỳ chỉnh".

AC03: Chỉ gửi khi bấm "Bắt đầu ngày" (Daily planning) hoặc "Hoàn tất" (Daily shutdown); thoát trước đó không gửi gì.

AC04: Lựa chọn đích được nhớ cho lần sau, riêng cho từng loại ritual.

AC05: Gửi lỗi không chặn hoàn tất ritual; thông báo trong app có nút "Thử lại".

AC06: "Gửi bản sao cho chính tôi" tính là một đích email (B30). Có ít nhất một đích email thì toast hoàn tất gộp hai dòng: dòng 1 "Đã lưu vào task…", dòng 2 "Đang gửi tới {n} nơi nhận" (QC-13 mục 3, A3).

## UC3. Daily shutdown

### US3.1 Mở Daily shutdown

AC01: Mở bằng phím O, mục "Daily shutdown" ở sidebar hoặc lời nhắc.

AC02: Tới giờ shutdown của ngày làm việc → thông báo Windows và thông báo trong app (bản 1.0; kênh theo G12), 1 lần / ngày; không tự mở `[giả định]`. Ngày nghỉ theo lịch chung không nhắc (QC-02 mục 8).

AC03: Lời nhắc có "Bỏ qua hôm nay"; chọn thì không nhắc lại trong ngày, vẫn mở tay được.

### US3.2 Xem việc đã xong

User Story: Là Hà, tôi muốn thấy hôm nay đã xong gì và thời gian đi vào khách hàng nào, để dừng làm với cảm giác đủ.

AC01: Liệt kê task xong hôm nay kèm "actual / planned"; tổng thời gian thực tế; phân bổ theo channel.

AC02: Timer đang chạy → bước đầu tiên nhắc tên task và nút "Dừng timer" (G07). Shutdown không tự dừng timer.

### US3.3 Xử lý task chưa xong

AC01: Mỗi task chưa xong của hôm nay: Ngày mai (mặc định `[giả định]`), Đưa vào backlog, Đánh dấu xong. "Ngày mai" là ngày làm việc kế tiếp **theo lịch của task** (QC-02 mục 6): ví dụ shutdown Thứ Sáu, task `#Công ty` (khung T2–T6) sang Thứ Hai, task `#Cá nhân` (khung T2–CN) sang Thứ Bảy; task ở channel không có khung theo lịch chung. Mỗi dòng hiện ngày đích cụ thể.

AC02: Áp dụng ngay, có toast Hoàn tác. Task để "Ngày mai" **không** bị đặt lại số ngày bị hoãn (QC-04), nên vẫn hiện nhãn "Dời n ngày" và vẫn tự lưu trữ khi bị hoãn quá lâu. Timebox giữ giờ, dời sang ngày mới; timer không dừng (QC-05). Instance lặp trùng series ở ngày đích → QC-06.

AC03: Nút "Để tự chuyển sang mai" bỏ qua cả bước: task chưa chọn giữ nguyên, rollover (G06) chuyển sang hôm sau như mọi ngày (B33).

AC04: Không còn task nào dở → "Không còn việc nào dở", nút Tiếp (C33).

### US3.4 Highlights

AC01: Trợ lý AI tắt (hoặc máy chưa có Claude Code): sinh sẵn danh sách task đã xong dạng gạch đầu dòng, người dùng sửa tay.

AC02: Từ 1.0, trợ lý AI bật (Q39, Q46, QC-12): G10 soạn nháp highlights qua Claude Code CLI vào các ngày trong lịch làm việc, tại giờ kết thúc của lịch chung (app không mở lúc đó thì soạn khi mở app lần kế tiếp trong ngày, D7), từ task xong (và hoạt động ở công cụ kết nối khi có tích hợp từ 1.1 và người dùng bật công tắc dữ liệu tích hợp, QC-12 mục 6). Bước Highlights điền sẵn nháp này, gắn nhãn "Nháp AI"; người dùng sửa và duyệt trước khi lưu, bản chia sẻ chỉ gửi khi bấm "Hoàn tất". Chưa có nháp (shutdown mở sớm hơn giờ soạn, AI lỗi hoặc chậm) → dùng danh sách sinh sẵn của AC01.

AC03: Highlights và ghi chú suy ngẫm riêng là hai ô tách nhau (B34). Highlights chia sẻ được; ghi chú riêng chỉ mình người dùng thấy, không có trong bản xem trước, email, Slack / Teams hay notes của task ghi chép.

### US3.5 Hoàn tất

AC01: Bấm "Hoàn tất" → tạo task ghi chép "Daily shutdown", gửi chia sẻ (UC2), hiện thông điệp cuối ngày theo cài đặt.

AC02: Sau hoàn tất, người dùng vẫn dùng app bình thường; mở lại phím O thấy bản đã chốt và nút "Làm lại". Làm lại rồi bỏ dở tới hết ngày → giữ bản đã chốt cũ.

### US3.6 Shutdown vắt qua mốc đầu ngày

User Story: Là Hà, tôi làm shutdown lúc 03:50 và muốn danh sách việc còn lại không bị đổi ngay dưới tay khi tới 04:00.

AC01: Phiên shutdown mở trước mốc đầu ngày được hoàn tất cho ngày cũ tới tối đa 2 giờ sau mốc; có banner thời gian còn lại.

AC02: Rollover của người dùng chờ tới khi shutdown hoàn tất, bị bỏ dở (đóng wizard sau mốc) hoặc hết 2 giờ, rồi mới chạy.

AC03: Hết 2 giờ chưa hoàn tất → ritual ngày cũ coi như bỏ lỡ, không tạo task ghi chép; task còn lại được rollover như thường.

## UC4. Ghi chép ritual

### US4.1 Task ghi chép ritual

AC01: Hoàn tất ritual tạo 1 task "Daily planning" hoặc "Daily shutdown" đã xong, ngày = ngày của ritual, channel = channel cho task ritual.

AC02: Notes chứa nội dung đã chốt (bản kế hoạch + trở ngại, hoặc việc đã xong + highlights; không có ghi chú riêng).

AC03: Thời gian thực tế = thời gian làm ritual, tối đa 120 phút `[giả định]`; chỉ ghi khi người dùng không có timer đang chạy, để không đếm cùng một khoảng thời gian hai lần (QC-07); không ảnh hưởng timer đang chạy.

AC04: Mở task hiện gợi ý "Dùng phím P để vào Daily planning" (O với shutdown).

AC05: Mở xem, chuyển bước rồi thoát, hoặc bỏ qua ritual → không tạo task (EC-26).

AC06: Lên kế hoạch lại / làm lại trong cùng ngày → mở lại nội dung lần trước để sửa; hoàn tất thì ghi đè nội dung cũ trong task ghi chép, không tạo task thứ hai, không nối thêm; thời gian cộng dồn (B35).

AC07: Task ghi chép ritual không tính vào mọi phép đếm số task (số task xong, ngưỡng "ít dữ liệu" và tỉ lệ hoàn thành của G09); thời gian của nó vẫn tính vào giờ thực tế.

## UC5. Cấu hình ritual ngày

### US5.1 Đổi cài đặt ritual

AC01: Cài đặt → Ritual có: giờ Daily planning, tự kích hoạt, sau khi plan đi tới, tự nhắc shutdown, giờ shutdown, thông điệp cuối ngày, channel cho task ritual, danh sách bước đã ẩn.

AC02: Lưu ngay, áp dụng ngay; đổi giờ plan sau khi hôm nay đã tự mở thì không mở lại trong ngày.

AC03: Bật lại bước đã ẩn từ danh sách bước đã ẩn.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ ngày có Daily planning | Ngày làm việc có Daily planning hoàn tất / ngày làm việc người dùng hoạt động | ≥ 50% |
| Thời gian Daily planning | Từ mở đến "Bắt đầu ngày" | ≤ 10 phút (trung vị) |
| Tỉ lệ bỏ dở | Ritual mở nhưng hết ngày chưa hoàn tất / ritual đã mở | ≤ 30% |
| Tỉ lệ đóng ngay khi tự mở | Tự mở rồi thoát trong 10 giây / số lần tự mở | Theo dõi (cao = nhắc gây phiền) |
| Tỉ lệ ngày quá tải sau planning | Ngày còn đỏ sau "Bắt đầu ngày" / ngày có planning | Theo dõi, giảm dần |
| Tỉ lệ ngày có Daily shutdown | Ngày có shutdown hoàn tất / ngày hoạt động | ≥ 30% |
| Tỉ lệ có chia sẻ | Ritual hoàn tất có ≥ 1 đích ngoài "Lưu vào task" / ritual hoàn tất | Theo dõi |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Rollover (G06) | Job rollover chạy mỗi 15 phút; người dùng mở app ngay sau mốc đầu ngày có thể chưa được rollover | Trước khi tải bước 1, gọi API "đảm bảo rollover" của G06 (chạy bù nếu lượt trước lỗi). Rollover chờ phiên shutdown vắt qua mốc (tối đa 2 giờ) |
| Lịch chưa kết nối (G05) | Thời gian trống chỉ tính theo giờ làm việc, bỏ sót họp | Bước Kiểm tra khối lượng nhắc kết nối lịch; không chặn |
| Shutdown chưa kiểm chứng | Luồng shutdown là đề xuất, có thể lệch hành vi người dùng đã quen trên Sunsama | Kiểm chứng trên Sunsama trước khi chốt thiết kế; thử nghiệm với 5 người dùng |
| Email chia sẻ ra ngoài | Rơi vào spam, bị lạm dụng gửi thư rác | SPF / DKIM / DMARC; reply-to = email người dùng; tối đa 20 email / ngày; link huỷ nhận |
| Tự mở gây phiền | Người dùng đóng ngay, tắt tính năng | 1 lần / ngày; không tự mở khi đang gõ hoặc đang Focus; theo dõi tỉ lệ đóng ngay |
| Mốc đầu ngày | "Hôm nay", "hôm qua" của ritual phụ thuộc mốc này | Đã chốt 04:00, chỉnh 00:00–06:00 (QC-01) |
| Hết trial giữa ritual (G12, bản 1.1) | Ritual đang làm bị chặn ghi | Theo QC-09: phiên đang làm được hoàn tất, kể cả thao tác task bên trong, trong 2 giờ (EC-34) |
| G09 cần dữ liệu từ 1.0 | Analytics 1.1 cần kế hoạch từng ngày | Lưu ảnh chụp kế hoạch ngay từ 1.0 (US1.7) |
| Planning Agent áp dụng ngay (G10, 1.0 qua Claude Code CLI, QC-12) | Kế hoạch bị AI đổi mà người dùng không duyệt trước | Nút "Hoàn tác kế hoạch AI" ở bước Daily plan (chỉ khi trợ lý AI bật); phiên AI đã bật đọc dữ liệu tích hợp thì mọi thay đổi trong phiên đó chờ duyệt (QC-12 mục 6) |
| Không có Claude Code trên máy (QC-12 mục 2) | Một phần người dùng không có nháp highlights, Planning Agent | Ritual luôn chạy đủ luồng thủ công; tính năng AI ẩn, thay bằng hướng dẫn cài Claude Code |

# 10. Câu hỏi mở

- Đã chốt 04/11/2026: mốc đầu ngày mặc định 04:00, chỉnh trong 00:00–06:00; mọi "ngày" của ritual là ngày làm việc (Q2, QC-01).
- Các bước Daily shutdown của Sunsama thực tế là gì (chưa kiểm chứng)? Luồng 5 bước đề xuất có cần chỉnh không?
- Giờ Daily shutdown mặc định = giờ kết thúc làm việc (17:00) hay một cài đặt riêng?
- Shutdown có tự mở như Daily planning không, hay chỉ nhắc?
- Đã chốt 04/11/2026: đánh dấu xong ở bước "Xem lại hôm qua" ghi ngày hoàn thành theo ngày làm việc của thời điểm bấm, tức hôm nay (Q2, QC-01, QC-05).
- Đã chốt 04/11/2026: ritual chỉ tạo bản ghi thời gian khi không có timer đang chạy (Q13, QC-07).
- Gửi email tới địa chỉ ngoài workspace có cần người nhận xác nhận lần đầu không?
- Đã chốt 04/11/2026: task tạo từ sự kiện lịch dùng timebox liên kết sự kiện, không trừ thời gian trống hai lần (B8).
- Bucket backlog nào được coi là "tới kỳ" để hiện ở bước Thêm task (G06)?
- Đã chốt 04/11/2026: shutdown "Ngày mai" = ngày làm việc kế tiếp, không reset số ngày bị hoãn, không dừng timer, timebox giữ giờ (Q5, Q14, Q19; QC-02, QC-04, QC-05). "Ngày làm việc kế tiếp" tính theo lịch của task: khung giờ channel nếu có, ngược lại lịch chung (Q38a, QC-02 mục 6).
- Đã chốt 04/11/2026: ritual ngày (tự mở, nhắc, giờ shutdown mặc định) theo lịch chung, không theo khung giờ channel (Q38a, QC-02 mục 8).
- Đã chốt 04/11/2026: trợ lý AI có từ 1.0 qua Claude Code CLI; nút "Hoàn tác kế hoạch AI" ở bước Daily plan thuộc 1.0, chỉ hiện khi trợ lý AI bật; highlights do AI soạn tại giờ kết thúc làm việc (Q39, Q46, QC-12).
- Đã chốt 04/11/2026: highlights AI soạn tại giờ kết thúc của lịch chung, không theo giờ Daily shutdown người dùng đã đổi; app không mở lúc đó thì soạn khi mở app lần kế tiếp trong ngày (D7).
- Đã chốt 04/11/2026: ritual vắt qua mốc đầu ngày được hoàn tất cho ngày cũ trong 2 giờ; rollover chờ phiên shutdown; lên kế hoạch lại bỏ dở thì giữ bản cũ (Q18).
- Đã chốt 04/11/2026: không cho ẩn bước Chia sẻ; shutdown có "Bỏ qua hôm nay"; G08 khai báo điểm mở rộng cho G09 (C24).
- Lên kế hoạch lại rồi hoàn tất: analytics G09 dùng ảnh chụp lần đầu hay lần cuối? (Đề xuất: lần đầu `[giả định]`.)
- "Bỏ dở" phiên shutdown sau mốc đầu ngày có bao gồm việc đóng wizard (×) không, hay chỉ "Bỏ qua hôm nay"? (Đề xuất: có, `[giả định]`.) **Chốt 09/11/2026 (C31):** Esc không thoát wizard, chỉ ×; phần còn lại vẫn mở.
- Timer bắt đầu hoặc dừng giữa lúc làm ritual: bản ghi `ritual` có bị cắt phần chồng không, hay chỉ xét lúc hoàn tất? (Hiện chỉ xét lúc hoàn tất.)
- **Chốt 09/11/2026 (B28):** nút "Plan my day" nằm ở đầu bước 1 của wizard Daily planning; chạy xong nhảy thẳng tới bước Daily plan; lỗi hoặc bấm Dừng thì về bước 1.
- **Chốt 09/11/2026 (B29):** Daily planning chỉ cho ngày từ hôm nay tới hôm nay + 7; cột xa hơn không có nút "Plan"; API từ chối thì báo câu lỗi riêng.
- **Chốt 09/11/2026 (B30):** "Gửi bản sao cho chính tôi" tính là đích email, có dòng "Đang gửi tới {n} nơi nhận".
- Có "chế độ buổi tối" (mở Daily planning sau 15:00 thì mặc định lên kế hoạch cho ngày mai) không? **Chốt 09/11/2026 (B31):** không ở 1.0; lên kế hoạch ngày mai bằng nút "Plan" trên cột ngày mai.
- **Chốt 09/11/2026 (B32):** bước "Xem lại hôm qua" bị bỏ qua khi hôm qua đã hoàn tất Daily shutdown.
- **Chốt 09/11/2026 (B33):** Daily shutdown giữ bước xử lý từng task chưa xong, thêm nút "Để tự chuyển sang mai" để bỏ qua cả bước, task còn lại để rollover xử lý.
- **Chốt 09/11/2026 (B34):** tách hai ô: highlights (chia sẻ được) và ghi chú suy ngẫm riêng (chỉ mình thấy, không bao giờ gửi đi).
- **Chốt 09/11/2026 (B35):** làm lại ritual trong cùng ngày mở lại ghi chú lần trước để sửa, hoàn tất thì ghi đè.
