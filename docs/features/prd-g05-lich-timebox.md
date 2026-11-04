> **Mã:** PLN-PRD-G05 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g05-lich-timebox.md

# PRD Lịch & timebox trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (badge giờ timebox màu cam "10:55" trên card; chi tiết task "Thursday, Nov 5 · 10:55–11:55 · 1 hr" kèm icon lịch; kéo block sang ngày khác đổi ngày bắt đầu; block thời gian thực tế "2:01 – 2:02" trên lịch; panel "Calendars", nút zoom 1x); chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Lịch là nơi thời gian thật của người dùng được quyết định: cuộc họp, lịch hẹn, khối làm việc. Nhóm G05 nối app với Google Calendar và Outlook (Microsoft 365): đọc sự kiện để biết giờ bận, cho người dùng timebox task (đặt task vào một khung giờ cụ thể), ghi timebox ra lịch ngoài thành sự kiện và nhận lại thay đổi từ lịch ngoài. Board và các chế độ xem lịch (G04) hiển thị dữ liệu của G05; projection và cảnh báo khối lượng (G04) dùng sự kiện bận từ G05. Apple Calendar / CalDAV thuộc bản 1.1.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Danh sách việc và lịch nằm ở hai công cụ | Người dùng không biết việc nào làm vào giờ nào, giữa hai cuộc họp còn trống bao lâu |
| Khối làm việc chỉ có trong app, đồng nghiệp không thấy | Bị đặt họp chồng vào giờ làm việc sâu (persona Minh) |
| Đặt giờ cho từng việc bằng tay tốn thời gian | Người dùng bỏ timebox, quay lại danh sách không giờ |
| Sửa / xoá sự kiện ở lịch ngoài không phản ánh về app | Task "ma" có giờ sai, sự kiện trùng lặp sau khi kết nối lại |
| Lộ nội dung việc riêng tư lên lịch công ty | Mất niềm tin, người dùng không dám bật ghi lịch |

## 1.3 Mục tiêu

- Kết nối Google hoặc Outlook trong ≤ 3 bước, sự kiện hiện trong app ≤ 30 giây sau khi kết nối `[giả định]`.
- Timebox tạo trong app xuất hiện trên lịch ngoài ≤ 10 giây.
- Thay đổi trên lịch ngoài phản ánh về app ≤ 1 phút qua webhook, chậm nhất 15 phút qua poll dự phòng.
- Không tạo sự kiện trùng, kể cả khi mất kết nối rồi kết nối lại.
- Tỉ lệ lỗi đồng bộ ≤ 2% trong mỗi 10 phút; vượt thì cảnh báo vận hành.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người lịch dày (Linh, PM, 6–8 cuộc họp/ngày) | Thấy cuộc họp cạnh task, nhét việc vào khe trống giữa các cuộc họp |
| Người cần khối thời gian dài (Minh, designer / dev) | Giữ khối làm việc trên lịch công ty ở trạng thái bận để không bị đặt họp chồng |
| Người nhiều vai (Hà, freelancer / founder) | Ghi timebox của từng khách hàng vào đúng lịch; việc riêng tư hiện là "Private" |
| Người dùng thành thạo | Timebox bằng phím X, gỡ bằng Ctrl+X, không cần kéo chuột |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Kết nối Google Calendar (OAuth) và Outlook qua Microsoft Graph; nhiều tài khoản lịch trên một người dùng (tối đa 5 `[giả định]`).
- Chọn lịch hiển thị, màu lịch, lịch mặc định ghi timebox, lịch ghi timebox theo channel.
- Hiển thị sự kiện trong Calendar views (G04) và panel Calendar (Shift+C); bộ lọc "Calendars"; zoom.
- Timebox: kéo task vào lịch, kéo block đổi giờ / ngày, kéo cạnh đổi thời lượng, gỡ timebox (Ctrl+X).
- Auto-schedule: X vào khe trống đầu tiên, Shift+X không chia nhỏ — phát hành bản 1.1 theo lộ trình chung, đặc tả sẵn trong tài liệu này.
- Đồng bộ 2 chiều: ghi timebox ra lịch ngoài; nhận sửa / xoá / dời từ lịch ngoài; cảnh báo họp đè timebox.
- Hiển thị block thời gian thực tế (từ timer G07) trên lịch.
- Trạng thái kết nối, kết nối lại, ngắt kết nối.

## 3.2 Ngoài phạm vi

- Apple Calendar / CalDAV → bản 1.1.
- Tạo / sửa sự kiện thường (không gắn task), mời người tham dự, trả lời lời mời → sau 1.1 `[giả định]`.
- Ghi chú cuộc họp, tạo task từ sự kiện trong Daily planning → G08.
- Chế độ xem, điều hướng ngày, projection, cảnh báo khối lượng → G04.
- Timer và dữ liệu thời gian thực tế → G07. Gỡ timebox quá khứ khi rollover → G06. Lập lịch cứng cho task lặp → G03.
- Tích hợp công cụ công việc (Gmail, Jira, Notion…) → G11.

# 4. Nguyên tắc sản phẩm

## 4.1 Mỗi bên giữ phần của mình

Lịch ngoài là nguồn sự thật cho sự kiện; app là nguồn sự thật cho task. App chỉ ghi và sửa sự kiện do chính app tạo (có mã task đánh dấu).

## 4.2 Không bao giờ dời việc của người khác

Xung đột chỉ dời task nội bộ. Cuộc họp mới đè lên timebox thì app cảnh báo và gợi ý, không tự dời gì.

## 4.3 Không trùng, không mất

Mọi lần ghi ra lịch ngoài đều idempotent theo mã task. Mất kết nối thì timebox chờ, kết nối lại thì đẩy tiếp, không tạo bản sao.

## 4.4 Ghi ra ngoài tối thiểu

Chỉ ghi tiêu đề, giờ, trạng thái bận, riêng tư, nhắc và link về task. Không ghi notes. Channel riêng tư luôn ghi là Private.

# 5. Quy tắc theo nhà cung cấp lịch

| **Quy tắc** | **Google Calendar** | **Outlook (Microsoft Graph)** | **Ghi chú** |
|---|---|---|---|
| Quyền xin khi kết nối | `calendar.events`, `calendar.calendarlist.readonly` | `Calendars.ReadWrite`, `offline_access` | Scope tối thiểu; không xin quyền đọc mail |
| Điều kiện ra mắt | Cần Google xác minh app (scope nhạy cảm) | Đăng ký app trên Microsoft Entra `[giả định]` | Google chưa xác minh → rủi ro chặn ra mắt (mục 9) |
| Đồng bộ lần đầu | Đọc sự kiện từ 30 ngày trước → 90 ngày sau | Như Google | Cửa sổ đồng bộ là cấu hình |
| Đồng bộ gia tăng | `syncToken` | Delta query (`deltaLink`) | Chỉ lấy phần thay đổi |
| Token đồng bộ hết hiệu lực | HTTP 410 → đồng bộ lại toàn bộ cửa sổ | Delta token hết hiệu lực → đồng bộ lại toàn bộ cửa sổ | Đồng bộ lại không tạo trùng |
| Nhận thay đổi đẩy về | Webhook `events.watch` | Subscription (webhook) | Gia hạn mỗi 6 giờ cho cả hai |
| Dự phòng | Poll 15 phút | Poll 15 phút | Khi webhook lỗi / hết hạn |
| Đánh dấu sự kiện do app tạo | `extendedProperties.private.appTaskId` | Open extension chứa `appTaskId` | Dùng để nhận diện, chống trùng |
| Tiêu đề | `summary` | `subject` | Tiêu đề task |
| Bận / rảnh | `transparency` = `opaque` / `transparent` | `showAs` = `busy` / `free` | Mặc định bận |
| Riêng tư | `visibility` = `private` / `default` | `sensitivity` = `private` / `normal` | Theo lịch; channel riêng tư luôn Private |
| Nhắc | `reminders.useDefault = true` (theo lịch) | `isReminderOn = true`, 15 phút `[giả định]` | Graph không có nhắc mặc định theo lịch |
| Mô tả | `description` = link về task | `body` (text) = link về task | Không ghi notes |
| Múi giờ | `start` / `end` có `dateTime` + `timeZone` (IANA) | `start` / `end` có `dateTime` + `timeZone` (Windows / IANA) `[giả định]` | Lưu nội bộ UTC + IANA |
| Sự kiện cả ngày | `start.date` | `isAllDay = true` | Không chặn auto-schedule, không trừ sức chứa (EC-17) |
| Giới hạn tốc độ | 429 / 403 rateLimitExceeded → backoff | 429 + `Retry-After` → backoff | Hàng đợi theo tài khoản |

- Các giá trị (cửa sổ đồng bộ, chu kỳ gia hạn, poll, thời gian thử lại) là **cấu hình hệ thống**, không cố định trong code.
- Timebox: thời lượng mặc định khi kéo 30 phút; làm tròn 5 phút; block 5 phút – 24 giờ `[giả định]`; khoảng đệm auto-schedule 0; thử lại ghi lịch tối đa 24 giờ.
- Mặc định cài đặt Timebox: hiện actual trên lịch bật; ẩn planned của task xong; nhắc theo lịch mặc định; bận; riêng tư theo lịch; tự dời khi xung đột bật (giữ Shift để tắt); tự dời khi xong sớm.
- Apple / CalDAV (1.1) sẽ thêm một cột vào bảng này.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Kết nối | Onboarding (G01) hoặc Cài đặt → Lịch → "Kết nối Google / Outlook" → OAuth | Tài khoản lịch `HOAT_DONG`, sự kiện hiện trong app |
| 2 | Chọn lịch | Bật / tắt lịch hiển thị, chọn lịch ghi timebox, lịch theo channel | App đọc và ghi đúng lịch |
| 3 | Xem | Calendar views / panel Calendar hiện sự kiện cạnh task | Thấy khe trống thật |
| 4 | Timebox | Kéo task vào khe, hoặc X để tự xếp | Task có giờ, badge cam trên card |
| 5 | Ghi ra lịch ngoài | Hệ thống tạo sự kiện trên lịch đã chọn | Đồng nghiệp thấy giờ bận |
| 6 | Thay đổi từ lịch ngoài | Dời / xoá sự kiện trên Google / Outlook, họp mới đè khung | App cập nhật, cảnh báo xung đột |
| 7 | Làm việc | Bật timer (G07); block thực tế hiện trên lịch | So được kế hoạch và thực tế |

Bước 7 thuộc G07, chỉ nêu để thấy vị trí của G05. PRD này tập trung bước 1–6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Kết nối và quản lý tài khoản lịch

### US1.1 Kết nối Google Calendar hoặc Outlook

User Story: Là người dùng, tôi muốn kết nối lịch công việc vào app, để thấy cuộc họp cạnh danh sách việc.

AC01: Cài đặt → Lịch có nút "Kết nối Google Calendar" và "Kết nối Outlook"; bấm mở trang OAuth của nhà cung cấp.

AC02: Đồng ý quyền → quay về app; tài khoản hiện email, trạng thái "Đang đồng bộ", sau đó "Đã kết nối".

AC03: Sự kiện trong cửa sổ 30 ngày trước → 90 ngày sau hiện trong app ≤ 30 giây `[giả định]`.

AC04: Người dùng bỏ quyền ghi ở màn OAuth → không kết nối, báo cần đủ quyền.

AC05: Kết nối cùng tài khoản lần hai → không tạo bản trùng, cập nhật token tài khoản cũ.

### US1.2 Kết nối lại và ngắt kết nối

AC01: Token hết hạn / bị thu hồi → tài khoản chuyển "Cần kết nối lại", banner trong app và thông báo (G12); timebox mới vẫn tạo được, chờ đồng bộ (EC-15).

AC02: Kết nối lại → timebox chờ được đẩy ra lịch, không tạo sự kiện trùng.

AC03: Ngắt kết nối hỏi xác nhận, có lựa chọn "Xoá các sự kiện timebox app đã tạo" (mặc định tắt) `[giả định]`; thu hồi token; timebox trong app giữ nguyên.

## UC2. Chọn lịch hiển thị và lịch ghi

### US2.1 Chọn lịch hiển thị

AC01: Mỗi tài khoản liệt kê các lịch; bật / tắt hiển thị, đổi màu từng lịch.

AC02: Lịch ẩn không hiện sự kiện và không tính vào sức chứa ngày (G04).

AC03: Panel "Calendars" trong Calendar views cho bật / tắt nhanh từng lịch.

### US2.2 Chọn lịch ghi timebox

User Story: Là người nhiều vai, tôi muốn timebox của mỗi channel ghi vào đúng lịch, để lịch khách hàng nào chỉ chứa việc của khách hàng đó.

AC01: Có một lịch mặc định ghi timebox; chỉ chọn được lịch có quyền ghi.

AC02: Mỗi channel có thể chọn lịch ghi riêng; không chọn thì dùng lịch mặc định.

AC03: Tắt ghi lịch ("Không ghi ra lịch ngoài") → timebox chỉ tồn tại trong app.

## UC3. Timebox task

### US3.1 Kéo task vào lịch

User Story: Là người dùng, tôi muốn kéo task vào một khung giờ, để giữ thời gian thật cho việc đó.

AC01: Kéo task từ cột ngày / backlog vào ô (ngày D, giờ H) trên Calendar views hoặc panel Calendar → ngày bắt đầu = D, block từ H dài bằng thời lượng kế hoạch, làm tròn 5 phút.

AC02: Task chưa có thời lượng → block 30 phút.

AC03: Card hiện badge giờ màu cam (ví dụ "10:55"); chi tiết task hiện "Thứ Năm, 5/11 · 10:55–11:55 · 1 giờ" kèm icon lịch.

AC04: Thả block đè lên timebox task khác → task bị đè tự dời xuống (khi bật "Tự dời khi xung đột"); giữ Shift khi thả để không dời. Sự kiện ngoài không bao giờ bị dời.

### US3.2 Dời và đổi thời lượng

AC01: Kéo block sang giờ / ngày khác → đổi giờ; sang ngày khác thì đổi ngày bắt đầu (đã kiểm chứng: block 10:55–11:55 kéo sang ngày khác).

AC02: Kéo cạnh dưới block đổi thời lượng → cập nhật thời lượng kế hoạch của task.

AC03: Mỗi thay đổi cập nhật sự kiện trên lịch ngoài ≤ 10 giây.

### US3.3 Gỡ timebox

AC01: Ctrl+X hoặc nút "Gỡ khỏi lịch" trong chi tiết task → xoá block, xoá sự kiện ngoài; task về projection (G04); có toast Hoàn tác.

AC02: Xoá task (G02) → xoá sự kiện ngoài.

## UC4. Auto-schedule

### US4.1 Tự xếp task vào khe trống

User Story: Là người dùng thành thạo, tôi muốn nhấn X là task tự vào khe trống gần nhất, để không phải tìm giờ bằng mắt.

AC01: X trên task → đặt vào khe trống đầu tiên trong giờ làm việc của channel task, từ thời điểm hiện tại (hôm nay) hoặc giờ bắt đầu làm việc (ngày tương lai), cộng khoảng đệm.

AC02: Không có khe đủ dài → X chia task thành nhiều block (tối đa 3, mỗi block ≥ 15 phút) `[giả định]`; Shift+X chỉ nhận khe đủ dài, không chia.

AC03: Sự kiện free, sự kiện cả ngày không chặn khe (EC-17).

AC04: Hết khe trong ngày → báo "Hôm nay hết khe trống", task giữ nguyên (EC-18).

## UC5. Ghi timebox ra lịch ngoài

### US5.1 Sự kiện đúng và kín đáo

AC01: Sự kiện có tiêu đề task, giờ bắt đầu / kết thúc kèm múi giờ, bận, riêng tư theo lịch, nhắc theo lịch, mô tả là link về task; không có notes.

AC02: Task thuộc channel riêng tư → sự kiện luôn Private.

AC03: Hoàn thành sớm (bật "Tự dời khi xong sớm") → block kết thúc tại giờ hoàn thành `[giả định cách hiểu]`; "Ẩn planned của task xong" chỉ ẩn trong app, không xoá sự kiện ngoài.

AC04: Ghi lỗi → timebox hiện biểu tượng lỗi đồng bộ; hệ thống thử lại tới 24 giờ.

## UC6. Nhận thay đổi từ lịch ngoài

### US6.1 Xoá và dời trên lịch ngoài

AC01: Xoá sự kiện timebox trên Google / Outlook → app gỡ timebox, task về projection, nhật ký ghi tác nhân lịch (EC-13).

AC02: Dời sự kiện timebox trên lịch ngoài → app cập nhật giờ; sang ngày khác thì đổi ngày bắt đầu (EC-14).

AC03: Đổi tiêu đề sự kiện trên lịch ngoài → không đổi tiêu đề task; lần ghi sau ghi đè lại `[giả định]`.

### US6.2 Họp đè timebox

User Story: Là người lịch dày, tôi muốn biết khi có cuộc họp mới chồng lên khối làm việc, để tự quyết dời việc nào.

AC01: Sự kiện bận mới chồng khung timebox → card và block hiện cảnh báo xung đột; không tự dời (EC-16).

AC02: Cảnh báo có nút "Dời sang khe trống" (chạy như Shift+X).

AC03: Cuộc họp được dời / xoá khỏi khung → cảnh báo tự mất.

## UC7. Hiển thị thời gian thực tế trên lịch

### US7.1 Block thực tế

AC01: Khi bật "Hiện actual trên lịch", mỗi lần chạy timer (G07) hiện block thực tế trên lịch app, ví dụ "2:01 – 2:02".

AC02: Block thực tế chỉ hiện trong app, không ghi ra lịch ngoài `[giả định]`.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ kết nối lịch | Người dùng mới kết nối ≥ 1 lịch trong 7 ngày đầu / người dùng mới | ≥ 70% |
| Tỉ lệ dùng timebox | Người dùng hoạt động có ≥ 1 timebox / tuần | ≥ 50% |
| Độ trễ ghi lịch | p95 từ lúc tạo timebox đến lúc sự kiện có trên lịch ngoài | ≤ 10 giây |
| Lỗi đồng bộ | Lần ghi / đọc lỗi / tổng lần, mỗi 10 phút | ≤ 2% |
| Sự kiện trùng | Sự kiện có cùng `appTaskId` trên một lịch | 0 |
| Kết nối lại thành công | Tài khoản `CAN_KET_NOI_LAI` được kết nối lại trong 7 ngày | ≥ 60% |
| Xung đột được xử lý | Cảnh báo xung đột được dời / gỡ trong ngày / tổng cảnh báo | Theo dõi |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Xác minh Google OAuth | Scope `calendar.events` là nhạy cảm; chưa xác minh thì giới hạn người dùng và màn cảnh báo "app chưa xác minh" | Nộp hồ sơ sớm; có kế hoạch ra mắt chỉ Outlook nếu Google chậm |
| Webhook bị mất / hết hạn | Không nhận thay đổi đẩy về | Gia hạn mỗi 6 giờ; poll 15 phút; đồng bộ lại toàn bộ khi token đồng bộ hết hiệu lực |
| Giới hạn tốc độ nhà cung cấp | Người dùng kéo nhiều block liên tục | Gộp ghi theo task trong 2 giây `[giả định]`; backoff theo `Retry-After` |
| Múi giờ, giờ mùa hè (EC-02, EC-03) | Hiển thị sai giờ, block lệch 1 giờ | Lưu UTC + IANA; hiển thị theo timezone người dùng; bộ test DST |
| Timebox qua nửa đêm (EC-04) | Block nằm trên 2 ngày | Ngày bắt đầu theo giờ bắt đầu block; hiển thị tách 2 đoạn |
| Người khác sửa sự kiện của app (lịch chia sẻ) | Thay đổi không do người dùng | Xử lý như thay đổi từ lịch ngoài, nhật ký ghi tác nhân lịch |
| Lịch công ty chặn app bên thứ ba | Admin Google Workspace / Entra không cho cấp quyền | Thông báo rõ, hướng dẫn gửi admin |

# 10. Câu hỏi mở

- Ai nộp hồ sơ xác minh Google OAuth, khi nào; có ra mắt 1.0 khi chưa xác minh không?
- Có kéo auto-schedule (X / Shift+X) lên bản 1.0 không? Hiện xếp ở 1.1 theo lộ trình chung.
- Một task có được nhiều block timebox không (cần cho X chia nhỏ)?
- Số tài khoản lịch tối đa trên một người dùng (đề xuất 5)?
- Ngắt kết nối có xoá các sự kiện app đã tạo trên lịch ngoài không?
- "Tự dời khi xong sớm" nghĩa là rút ngắn block hay kéo các timebox sau lên sớm?
- Block thời gian thực tế có ghi ra lịch ngoài không?
- Đổi tiêu đề sự kiện trên lịch ngoài có cập nhật tiêu đề task không?
