> **Mã:** PLN-PRD-G11 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g11-tich-hop.md

# PRD Tích hợp công cụ trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số và hành vi theo nhà cung cấp đánh dấu `[giả định]` dùng để dựng flow, cần PO và kỹ thuật xác nhận với tài liệu API của từng hãng trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: danh sách tích hợp (Gmail, Outlook, Asana, ClickUp, GitHub, Jira, Linear, Monday.com, Notion, Todoist, Trello, Google Tasks, Microsoft Planner, Microsoft To Do, Apple Reminders, Slack, Microsoft Teams, Zapier, Toggl Track, MCP), nút + trên panel phải hiện icon từng tích hợp, phím tắt mở panel (Shift+G Gmail, Shift+J Jira, Shift+N Notion…), lời mời "Reduce distractions in Slack/Teams when working?" khi bật timer. Chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Việc cần làm của người dùng nằm rải ở email, công cụ quản lý công việc (Jira, Notion…) và nhắn tin nhóm. Nhóm G11 đưa các việc đó vào app: kết nối tài khoản, xem item trong panel phải, kéo item vào ngày thành task liên kết, và đồng bộ trạng thái hoàn thành hai chiều. Bản 1.1 làm Gmail, Jira, Notion; bản 1.2 thêm Slack / Teams để chia sẻ ritual và đổi status khi tập trung. Lịch (Google, Outlook) thuộc G05; task, board, ritual, AI dùng task liên kết nhưng đặc tả ở nhóm riêng (G02, G04, G08, G10).

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Phải mở Jira, Notion, Gmail để biết hôm nay có việc gì | Daily planning mất thời gian, sót việc |
| Chép tay việc từ công cụ sang app | Tiêu đề lệch, mất link về nguồn, tạo trùng |
| Làm xong trong app nhưng nguồn vẫn mở (hoặc ngược lại) | Hai nơi lệch nhau, phải cập nhật hai lần |
| Item ở nguồn bị xoá / mất quyền mà task không biết | Task "mồ côi", bấm link ra lỗi |
| Công cụ ngoài lỗi hoặc giới hạn tần suất làm treo app | Không lập được kế hoạch đúng lúc cần |
| Đang tập trung vẫn bị nhắn Slack / Teams | Mất khối thời gian sâu |

## 1.3 Mục tiêu

- Kéo một item thành task trong ≤ 2 thao tác (mở panel, kéo vào ngày); tiêu đề, link, nguồn điền sẵn.
- Không bao giờ có hai task cho cùng một item.
- Hoàn thành ở một bên → bên kia cập nhật ≤ 1 phút khi có webhook, ≤ 15 phút khi chỉ poll `[giả định]`.
- Lỗi tích hợp không chặn bất kỳ thao tác task nội bộ nào; panel luôn hiện dữ liệu lần cuối kèm thời điểm.
- Ngắt kết nối là thu hồi token và xoá dữ liệu cache, task đã tạo giữ nguyên.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh — PM, Jira + Notion + Gmail | Thấy issue Jira giao cho mình, trang Notion cần duyệt, email cần trả lời ngay trong Daily planning |
| Minh — designer / dev | Kéo issue Jira vào khối thời gian dài; xong task thì issue tự chuyển trạng thái; Slack tự bật DND khi tập trung |
| Hà — freelancer / founder, nhiều khách hàng | Biến email khách hàng thành task có link về thư; gửi Daily plan lên Slack của khách |
| Người dùng thành thạo | Mở panel từng nguồn bằng phím tắt, xem trước (I), mở nguồn (G) |
| Quản trị workspace | Biết dữ liệu tích hợp có hiện cho thành viên khác không (Privacy, G12) |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.1 Gmail, Jira, Notion; bản 1.2 Slack, Teams)

- Nền tảng: Web (desktop, mobile web), App iOS / Android, desktop dùng cùng đặc tả.
- Trang Cài đặt → Tích hợp: danh sách nhà cung cấp, trạng thái, kết nối OAuth, cấu hình, ngắt kết nối.
- Panel tích hợp (panel phải, nút + và phím tắt): danh sách item, lọc, tìm, làm mới, xem trước (I), mở nguồn (G).
- Kéo item vào cột ngày (G04) hoặc lịch (G05) → task liên kết; cách bàn phím tương đương.
- Đồng bộ hoàn thành hai chiều (mức C) với Jira, Notion; Gmail theo quy tắc riêng.
- Xử lý item bị xoá / mất quyền, giới hạn tần suất, token hết hạn.
- Cung cấp hoạt động công cụ trong ngày cho highlights AI (G10).
- Bản 1.2: Slack, Teams làm đích chia sẻ ritual (G08) và đổi status / DND khi timer chạy (G07).

## 3.2 Ngoài phạm vi

- Lịch Google / Outlook / Apple → G05.
- Outlook (mail), Asana, ClickUp, GitHub, Linear, Monday.com, Todoist, Trello, Google Tasks, Microsoft Planner, Microsoft To Do, Apple Reminders → sau 1.2, thứ tự chờ chốt (mục 10).
- Zapier, Toggl Track, MCP / API công khai → sau 1.2.
- Tạo item mới ở nguồn từ app (ví dụ tạo issue Jira) → chưa làm `[giả định]`.
- Đồng bộ notes, comment, subtask, người được giao giữa app và nguồn → không làm.
- Đọc tin nhắn Slack / Teams thành task → sau 1.2 `[giả định]`.
- Quản trị workspace chặn / cho phép từng tích hợp → sau 1.2.

# 4. Nguyên tắc sản phẩm

## 4.1 Nguồn giữ việc, app giữ kế hoạch

Tiêu đề và trạng thái thuộc về nguồn; ngày, thời lượng, timebox, thứ tự thuộc về app. Hai bên chỉ trao đổi trạng thái hoàn thành.

## 4.2 Một item, một task

Kéo cùng một item bao nhiêu lần cũng chỉ có một task; lần sau nhảy tới task đã có (EC-20).

## 4.3 Tích hợp hỏng, ngày vẫn chạy

Lỗi, giới hạn tần suất, mất quyền ở nguồn không chặn thao tác trong app. Panel hiện dữ liệu lần cuối và thời điểm (EC-22); task không bao giờ bị xoá vì nguồn (EC-19).

## 4.4 Quyền tối thiểu, ngắt là sạch

Chỉ xin scope cần cho tính năng đang bật. Ngắt kết nối thu hồi token, xoá cache, task đã tạo ở lại.

# 5. Quy tắc theo nhà cung cấp

**5.1 Nhà cung cấp bản 1.1 và 1.2**

| **Nhà cung cấp** | **Bản** | **Quyền truy cập** | **Item hiện trên panel** | **Task tạo ra** | **Task xong → nguồn** | **Nguồn đóng → task** | **Nhận thay đổi** | **Phím mở panel** |
|---|---|---|---|---|---|---|---|---|
| Gmail | 1.1 | OAuth Google, `gmail.modify` (scope hạn chế, cần thẩm định bảo mật của Google) `[giả định]` | Thư trong Hộp thư đến, mới nhất trước; lọc theo nhãn, gắn sao `[giả định]` | Tiêu đề = chủ đề thư; link về thread; nguồn "Gmail · {người gửi}" | Lưu trữ thư (bỏ khỏi Hộp thư đến), tắt được `[giả định]` | Không tự đánh dấu xong — lưu trữ thư không có nghĩa là xong việc `[giả định]` | Gmail push qua Pub/Sub `[giả định]`; poll 15 phút | Shift+G |
| Jira (Cloud) | 1.1 | OAuth 2.0 (3LO) Atlassian, `read:jira-work`, `write:jira-work`, `offline_access` `[giả định]` | Issue giao cho tôi, chưa ở nhóm trạng thái Done; lọc theo project / JQL lưu sẵn `[giả định]` | Tiêu đề = "{KEY-123} {summary}"; link issue; due ← due date Jira `[giả định]` | Chạy transition người dùng chọn cho từng project; mặc định transition đầu tiên vào nhóm Done `[giả định]` | Issue vào nhóm Done → task xong (EC-21) | Webhook động `[giả định]`; poll 15 phút | Shift+J |
| Notion | 1.1 | OAuth public integration; người dùng chọn trang / database chia sẻ cho app | Trang trong database đã chọn có thuộc tính Status hoặc Checkbox; lọc "giao cho tôi" theo thuộc tính Person `[giả định]` | Tiêu đề trang; link trang; due ← thuộc tính Date người dùng chọn `[giả định]` | Đặt thuộc tính trạng thái = giá trị "xong" người dùng ánh xạ | Thuộc tính = giá trị "xong" → task xong (EC-21) | Webhook `[giả định]`; poll 15 phút | Shift+N |
| Slack | 1.2 | OAuth Slack, `chat:write`, `users.profile:write`, `dnd:write` `[giả định]` | Không có panel item ở 1.2 | — | — | — | — | — |
| Microsoft Teams | 1.2 | Microsoft Graph, `ChannelMessage.Send`, `Chat.ReadWrite`, `Presence.ReadWrite` `[giả định]` | Không có panel item ở 1.2 | — | — | — | — | — |

Slack và Teams ở 1.2 dùng cho hai việc: đích chia sẻ Daily planning / Daily shutdown (G08, chỉ gửi khi người dùng bấm Done) và đổi status / DND khi timer chạy (G07).

**5.2 Nhà cung cấp sau 1.2 (thứ tự chờ chốt)**

| **Nhà cung cấp** | **Loại** | **Phím (theo Sunsama)** | **Ghi chú** `[giả định]` |
|---|---|---|---|
| Outlook (mail) | Email | Shift+O | Dùng chung kết nối Microsoft với lịch (G05) |
| Asana, ClickUp, Monday.com, Trello, Todoist | Quản lý công việc | Shift+S, Shift+U, Shift+M, Shift+E, Shift+D | Cùng adapter: đọc item giao cho tôi, hoàn thành 2 chiều |
| GitHub, Linear | Issue kỹ thuật | Shift+I, Shift+V | Issue / PR giao cho tôi |
| Google Tasks, Microsoft Planner, Microsoft To Do | Danh sách việc | — | Hoàn thành 2 chiều |
| Apple Reminders | Danh sách việc | — | Chỉ qua app iOS / macOS (không có API web) |
| Zapier | Tự động hoá | — | Trigger / action trên task |
| Toggl Track | Theo dõi thời gian | — | Đẩy TimeEntry (G07) sang Toggl |
| MCP | Giao thức cho agent ngoài | — | Cùng quyền với API công khai |

**5.3 Quy tắc chung mọi nhà cung cấp** `[giả định]`

| **Quy tắc** | **Giá trị** | **Ghi chú** |
|---|---|---|
| Item hiện trên panel | Tối đa 200 / nguồn, cuộn tải thêm | Mới cập nhật nhất trước |
| Làm mới panel | Khi mở panel nếu cache > 2 phút; nút làm mới ≤ 1 lần / 30 giây | Poll nền 15 phút |
| Giới hạn tần suất (429) | Theo Retry-After; không có thì backoff 30 giây → 15 phút, có jitter | Panel hiện dữ liệu lần cuối + thời điểm (EC-22) |
| Đẩy trạng thái ra nguồn lỗi | Thử lại tới 24 giờ | Giống timebox G05 |
| Cache item | Chỉ metadata (tiêu đề, trạng thái, hạn, URL; Gmail thêm đoạn trích ≤ 200 ký tự), giữ 7 ngày | Không lưu nội dung thư / mô tả đầy đủ |
| Hoàn thành 2 chiều | Bật / tắt theo từng tích hợp | Mặc định bật |
| Token | Mã hoá AES-256-GCM, chỉ dùng ở server | Ngắt kết nối thu hồi token |

- Các giá trị là **cấu hình hệ thống**, không cố định trong code.
- Tác nhân trong nhật ký task cho mọi thay đổi do tích hợp: `integration` (kèm tên nhà cung cấp).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Kết nối | Cài đặt → Tích hợp, nút + trên panel phải, hoặc bước "chọn công cụ công việc" của onboarding (G01) → OAuth | Tích hợp `DA_KET_NOI`, icon xuất hiện trên panel phải |
| 2 | Cấu hình | Chọn project / database / nhãn cần xem, ánh xạ trạng thái "xong", bật / tắt 2 chiều | Panel chỉ hiện việc liên quan |
| 3 | Lấy việc | Mở panel (Shift+J…), xem trước (I), kéo item vào cột ngày hoặc lịch | Task liên kết có tiêu đề, link, nguồn |
| 4 | Làm việc | Timebox, timer (G05, G07); Slack / Teams tự bật DND (1.2) | Thời gian thực tế |
| 5 | Hoàn thành | Bấm ✓ trong app hoặc đóng item ở nguồn | Hai bên cùng "xong" |
| 6 | Duy trì | Xử lý "Nguồn không còn", kết nối lại khi token hết hạn, ngắt kết nối | Dữ liệu sạch, không task mồ côi |

Bước 4 thuộc G05 / G07, chỉ nêu để thấy vị trí của G11. PRD này tập trung bước 1, 2, 3, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Kết nối và cấu hình tích hợp

### US1.1 Kết nối một công cụ

User Story: Là Linh, tôi muốn kết nối Jira, Notion và Gmail một lần, để mọi việc của tôi hiện trong app.

AC01: Cài đặt → Tích hợp liệt kê nhà cung cấp theo nhóm (Email, Quản lý công việc, Nhắn tin); mỗi dòng có trạng thái và nút "Kết nối".

AC02: "Kết nối" mở OAuth của hãng; quay về app → trạng thái "Đã kết nối · {tài khoản}", icon xuất hiện trên panel phải.

AC03: Người dùng từ chối quyền ở trang hãng → quay về, trạng thái giữ "Chưa kết nối", có thông báo.

AC04: Nhà cung cấp chưa hỗ trợ ở bản hiện tại hiện "Sắp có" `[giả định]`.

### US1.2 Chọn việc cần xem

AC01: Jira: chọn site, project, hoặc dán JQL; Notion: chọn database và thuộc tính trạng thái, giá trị "xong"; Gmail: chọn nhãn (mặc định Hộp thư đến).

AC02: Bật / tắt "Hoàn thành hai chiều" theo từng tích hợp; Gmail có thêm "Lưu trữ thư khi hoàn thành task".

AC03: Thay đổi cấu hình lưu ngay, panel làm mới theo cấu hình mới.

### US1.3 Ngắt kết nối

AC01: "Ngắt kết nối" hỏi xác nhận, nói rõ: task đã tạo vẫn giữ, chỉ mất liên kết đồng bộ.

AC02: Sau khi ngắt: token bị thu hồi ở hãng, cache item bị xoá, icon biến khỏi panel.

## UC2. Đưa việc từ công cụ vào ngày

### US2.1 Xem việc trong panel

AC01: Bấm icon trên panel phải hoặc phím tắt (Shift+G, Shift+J, Shift+N) mở panel nguồn đó.

AC02: Mỗi item hiện: tiêu đề, nguồn phụ (project / database / người gửi), hạn nếu có; item đã có task hiện dấu "Đã lên kế hoạch · {ngày}".

AC03: Có ô tìm, nút làm mới, dòng "Cập nhật lúc {giờ}".

### US2.2 Kéo item thành task

User Story: Là Minh, tôi muốn kéo một issue Jira vào chiều thứ Năm, để có task có sẵn link và lên lịch luôn.

AC01: Kéo item vào cột ngày → task `startDate` = ngày đó; kéo vào lịch → task có timebox (G05).

AC02: Task có tiêu đề nguồn, link, biểu tượng nguồn; thời lượng và channel theo gợi ý (G02).

AC03: Không dùng chuột: chọn item, nhấn A (thêm vào hôm nay) hoặc menu "Thêm vào ngày…" `[giả định]`.

AC04: Phím I xem trước item; phím G mở item ở nguồn (tab mới).

### US2.3 Không tạo trùng

AC01: Kéo item đã có task chưa xoá → không tạo mới; mở / cuộn tới task đã có, toast "Việc này đã có trong {ngày}" (EC-20).

AC02: Task của item đang trong Thùng rác → khôi phục task đó thay vì tạo mới `[giả định]`.

AC03: Hai thiết bị kéo cùng item cùng lúc → chỉ một task được tạo.

## UC3. Đồng bộ trạng thái hai chiều

### US3.1 Hoàn thành trong app cập nhật nguồn

AC01: Bật hai chiều: hoàn thành task → Jira chạy transition đã chọn; Notion đặt giá trị "xong"; Gmail lưu trữ thư nếu bật.

AC02: Cập nhật nguồn chạy nền; lỗi không chặn hoàn thành trong app; card hiện biểu tượng "Chưa cập nhật được {nguồn}" và "Thử lại".

AC03: Hoàn tác trong toast → trả nguồn về trạng thái trước `[giả định]`.

### US3.2 Đóng ở nguồn hoàn thành task

AC01: Item chuyển sang trạng thái xong ở nguồn và đang bật hai chiều → task đánh dấu xong theo quy tắc hoàn thành (G02), nhật ký ghi "Jira đánh dấu xong" (tác nhân integration) (EC-21).

AC02: Tắt hai chiều → task không đổi, hiện nhãn "Đã xong ở {nguồn}".

AC03: Item mở lại ở nguồn → task không tự bỏ hoàn thành, nhật ký ghi lại `[giả định]`.

### US3.3 Nguồn bị xoá hoặc mất quyền

AC01: Item bị xoá, hoặc người dùng mất quyền xem → task giữ nguyên, nhãn "Nguồn không còn" (EC-19).

AC02: Bấm link / phím G → thông báo nguồn không còn truy cập được, không mở trang lỗi.

AC03: Quyền được cấp lại → nhãn tự mất ở lần đồng bộ sau.

## UC4. Tích hợp gặp sự cố

### US4.1 Bị giới hạn tần suất

AC01: Hãng trả 429 → app chờ theo Retry-After / backoff, không gọi dồn (EC-22).

AC02: Panel hiện dữ liệu lần cuối kèm "Cập nhật lúc {giờ} · Đang chờ {nguồn}"; kéo item vẫn được.

### US4.2 Token hết hạn

AC01: Làm mới token thất bại → trạng thái "Cần kết nối lại"; banner trên panel và thông báo trong app + email (G12).

AC02: Kết nối lại cùng tài khoản → giữ cấu hình và liên kết cũ; không tạo task trùng.

## UC5. Slack và Teams (bản 1.2)

### US5.1 Chia sẻ ritual lên Slack / Teams

AC01: Khi Slack / Teams đã kết nối, "Add destination" của bước chia sẻ (G08) có thêm kênh / cuộc trò chuyện Slack, Teams.

AC02: Chỉ gửi khi người dùng bấm Done; gửi lỗi → báo lỗi, ritual vẫn hoàn tất.

### US5.2 Tự bật DND khi tập trung

User Story: Là Minh, tôi muốn Slack tự bật DND khi tôi bắt đầu timer, để không bị cắt ngang khi làm việc sâu.

AC01: Lần đầu bật timer khi có Slack / Teams → lời mời "Giảm phân tâm trên Slack / Teams khi làm việc?" (G07), đồng ý bật cài đặt.

AC02: Timer chạy → status "Đang tập trung" và DND trong thời gian planned còn lại; timer dừng → trả status trước đó.

AC03: Mặc định không hiện tên task trên status `[giả định]`.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu 1.1** |
|---|---|---|
| Tỉ lệ kết nối | Người dùng hoạt động có ≥ 1 tích hợp / người dùng hoạt động | ≥ 40% |
| Task từ tích hợp | Task tạo từ item / task tạo mới (người đã kết nối) | ≥ 25% |
| Task trùng | Số item có > 1 task chưa xoá | 0 |
| Cập nhật nguồn thành công | Lần đẩy trạng thái thành công trong 24 giờ / lần đẩy | ≥ 99% |
| Độ trễ đồng bộ hoàn thành | Từ đóng ở một bên đến bên kia cập nhật | p95 ≤ 1 phút (webhook), ≤ 15 phút (poll) |
| Kết nối hỏng | Tích hợp ở `CAN_KET_NOI_LAI` / tích hợp đã kết nối | ≤ 5% |
| Dùng DND (1.2) | Người dùng Slack / Teams bật DND theo timer | ≥ 30% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Thẩm định Gmail | `gmail.modify` là scope hạn chế, cần Google xác minh và đánh giá bảo mật; có thể chậm ra mắt Gmail | Nộp sớm cùng hồ sơ lịch (G05); phương án chỉ đọc (`gmail.readonly`, không lưu trữ thư) nếu bị chậm |
| Duyệt app của Atlassian / Notion / Slack / Microsoft | Thời gian duyệt chưa rõ | Đưa vào kế hoạch phát hành 1.1 / 1.2 |
| Giới hạn tần suất của hãng | Nhiều người dùng chung một app OAuth | Backoff, cache, ưu tiên webhook; giám sát 429 theo hãng |
| Webhook không ổn định / hết hạn | Mất sự kiện | Poll 15 phút dự phòng; gia hạn webhook định kỳ |
| Vòng lặp đồng bộ | App đẩy trạng thái → nguồn bắn webhook → app xử lý lại | Đánh dấu thay đổi do app đẩy, bỏ qua sự kiện dội lại |
| Dữ liệu email nhạy cảm | Nghị định 13/2023/NĐ-CP, GDPR | Chỉ lưu metadata, xem trước đọc trực tiếp, cần pháp chế xác nhận |
| Workflow Jira đa dạng | Không có trạng thái "Done" chung | Cho chọn transition theo project; không có transition hợp lệ → chỉ cập nhật trong app, báo người dùng |
| API hãng thay đổi | Adapter hỏng | Adapter chung, kiểm thử hợp đồng hằng ngày |

# 10. Câu hỏi mở

- Danh sách tích hợp ưu tiên cho thị trường Việt Nam là gì (ngoài danh sách Sunsama)?
- Thứ tự phát hành các nhà cung cấp sau 1.2?
- Gmail: hoàn thành task có lưu trữ thư không, hay chỉ đánh dấu đã đọc / không làm gì?
- Hoàn thành hai chiều mặc định bật hay tắt?
- Item mở lại ở nguồn có bỏ hoàn thành task không?
- Tiêu đề ở nguồn đổi có cập nhật tiêu đề task không (khi người dùng chưa sửa)?
- Một người dùng có được kết nối nhiều tài khoản / nhiều site Jira cùng nhà cung cấp không?
- Status Slack / Teams có hiện tên task không?
- Ai nộp hồ sơ xác minh Google cho Gmail, khi nào (chung với G05)?
- Quản trị workspace có cần chặn / cho phép từng tích hợp không?
