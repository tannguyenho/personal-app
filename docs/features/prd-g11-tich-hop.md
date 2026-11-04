> **Mã:** PLN-PRD-G11 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g11-tich-hop.md

# PRD Tích hợp công cụ (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số và hành vi theo nhà cung cấp đánh dấu `[giả định]` dùng để dựng flow, cần PO và kỹ thuật xác nhận với tài liệu API của từng hãng trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: danh sách tích hợp (Gmail, Outlook, Asana, ClickUp, GitHub, Jira, Linear, Monday.com, Notion, Todoist, Trello, Google Tasks, Microsoft Planner, Microsoft To Do, Apple Reminders, Slack, Microsoft Teams, Zapier, Toggl Track, MCP), nút + trên panel phải hiện icon từng tích hợp, phím tắt mở panel (Shift+G Gmail, Shift+J Jira, Shift+N Notion…), lời mời "Reduce distractions in Slack/Teams when working?" khi bật timer. Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> **Cập nhật 04/11/2026** theo [quyết định chốt mâu thuẫn](../review/quyet-dinh-chot-2026-11-04.md) (Q8, Q21, B14, B15, C27–C30, C34). Quy tắc dùng chung (ngày làm việc QC-01, đồng bộ QC-08, chế độ chỉ đọc QC-09, quyền theo gói QC-10) xem [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); PRD này chỉ tham chiếu, không định nghĩa lại. G11 phát hành 1.1 cùng lúc với chế độ chỉ đọc và quyền theo gói (Q10, ADR-0002).
>
> **Cập nhật vòng 5–6 (04/11/2026)** theo Q35, Q45, Q46, [ADR-0004](../adr/0004-ai-qua-claude-code-cli.md), [ADR-0005](../adr/0005-nen-tang-windows-truoc.md): nền tảng 1.0 là app Windows, 1.1 thêm web và macOS; G11 vẫn phát hành 1.1. Dữ liệu tích hợp chỉ đến được trợ lý AI qua công cụ MCP đọc dữ liệu tích hợp của G10, mặc định tắt, và phiên AI đã đọc dữ liệu đó thì các thay đổi sau lần đọc đầu tiên chờ duyệt ([QC-12](../01-quy-tac-dung-chung.md) mục 6, D8). Cập nhật vòng 7: AI không bao giờ hoàn thành hay xoá task có liên kết tích hợp (D10). Bản 1 chỉ cho một người dùng; Privacy và quản trị workspace để bản sau (Q35, [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md)).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Việc cần làm của người dùng nằm rải ở email, công cụ quản lý công việc (Jira, Notion…) và nhắn tin nhóm. Nhóm G11 đưa các việc đó vào app: kết nối tài khoản, xem item trong panel phải, kéo item vào ngày thành task liên kết, và đồng bộ trạng thái hoàn thành hai chiều. Bản 1.1 làm Gmail, Jira, Notion; bản 1.2 thêm Slack / Teams để chia sẻ ritual và đổi status khi tập trung. Bản 1.1 chạy trên app Windows, web và macOS (ADR-0005). Lịch (Google, Outlook) thuộc G05; task, board, ritual, AI dùng task liên kết nhưng đặc tả ở nhóm riêng (G02, G04, G08, G10). Trợ lý AI (G10, Claude Code qua MCP local) chỉ đọc dữ liệu tích hợp khi người dùng bật công tắc riêng (QC-12 mục 6).

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Phải mở Jira, Notion, Gmail để biết hôm nay có việc gì | Daily planning mất thời gian, sót việc |
| Chép tay việc từ công cụ sang app | Tiêu đề lệch, mất link về nguồn, tạo trùng |
| Làm xong trong app nhưng nguồn vẫn mở (hoặc ngược lại) | Hai nơi lệch nhau, phải cập nhật hai lần |
| Item ở nguồn bị xoá / mất quyền mà task không biết | Task "mồ côi", bấm link ra lỗi |
| Kéo cả việc của đồng nghiệp vào app; issue đã giao cho người khác vẫn bị đóng từ app | Lộ dữ liệu người khác, ghi sai lên hệ thống của nhóm |
| Công cụ ngoài lỗi hoặc giới hạn tần suất làm treo app | Không lập được kế hoạch đúng lúc cần |
| Đang tập trung vẫn bị nhắn Slack / Teams | Mất khối thời gian sâu |

## 1.3 Mục tiêu

- Kéo một item thành task trong ≤ 2 thao tác (mở panel, kéo vào ngày); tiêu đề, link, nguồn điền sẵn.
- Không bao giờ có hai task cho cùng một item, dù item được kéo từ panel, từ Daily planning hay do Planning Agent (G10) tạo.
- Chỉ đưa vào app việc được giao cho chính người dùng (B15).
- Hoàn thành ở một bên → bên kia cập nhật ≤ 1 phút khi có webhook, ≤ 15 phút khi chỉ poll `[giả định]`.
- Lỗi tích hợp không chặn bất kỳ thao tác task nội bộ nào; panel luôn hiện dữ liệu lần cuối kèm thời điểm.
- Ngắt kết nối là thu hồi token và xoá dữ liệu cache trên server và mọi thiết bị, task đã tạo giữ nguyên.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh — PM, Jira + Notion + Gmail | Thấy issue Jira giao cho mình, trang Notion cần duyệt, email cần trả lời ngay trong Daily planning |
| Minh — designer / dev | Kéo issue Jira vào khối thời gian dài; xong task thì issue tự chuyển trạng thái; Slack tự bật DND khi tập trung |
| Hà — freelancer / founder, nhiều khách hàng | Biến email khách hàng thành task có link về thư; gửi Daily plan lên Slack của khách |
| Người dùng thành thạo | Mở panel từng nguồn bằng phím tắt, xem trước (I), mở nguồn (G) |
| Người dùng thận trọng với AI | Tự quyết có cho trợ lý AI đọc email / issue không; nếu cho thì mọi thay đổi AI làm sau khi đọc đều chờ mình duyệt |
| Quản trị workspace (bản sau, Q35) | Biết dữ liệu tích hợp có hiện cho thành viên khác không (Privacy, G12) |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.1 Gmail, Jira, Notion; bản 1.2 Slack, Teams)

- Nền tảng: bản 1.1 trên app Windows (Flutter), web và macOS dùng cùng đặc tả; iOS / Android từ 1.2 (Q45, ADR-0005). OAuth trên app desktop mở trình duyệt hệ thống (luồng cụ thể: tech chốt).
- Trang Cài đặt → Tích hợp: danh sách nhà cung cấp, trạng thái, kết nối OAuth, cấu hình, ngắt kết nối.
- Panel tích hợp (panel phải, nút + và phím tắt): danh sách item, lọc, tìm, làm mới, xem trước (I), mở nguồn (G).
- Kéo item vào cột ngày (G04), lịch (G05) hoặc Backlog (G06) → task liên kết; cách bàn phím tương đương.
- Tab "Tích hợp" trong bước Thêm task của Daily planning (G08) và kéo item vào Backlog (bản 1.1, C34).
- Cơ chế "một item, một task" dùng chung cho mọi đường tạo task từ item, kể cả Planning Agent (G10) (B14).
- Chỉ nhập item được giao cho mình; item đổi người giao thì liên kết chuyển chỉ đọc (B15).
- Đồng bộ hoàn thành hai chiều (mức C) với Jira, Notion; Gmail theo quy tắc riêng; nhãn "Lệch với nguồn" khi hai bên không khớp (C27).
- Xử lý item bị xoá / mất quyền, giới hạn tần suất, token hết hạn, chế độ chỉ đọc (QC-09).
- Cung cấp hoạt động công cụ trong ngày cho highlights AI (G10), chỉ hoạt động của chính tài khoản đã kết nối (C28).
- Cung cấp dữ liệu cho công cụ MCP đọc dữ liệu tích hợp của G10 (danh sách item, hoạt động trong ngày): chỉ metadata, chỉ việc của tôi, chỉ khi người dùng bật công tắc của G10 (QC-12 mục 6).
- Bản 1.2: Slack, Teams làm đích chia sẻ ritual (G08) và đổi status / DND khi timer chạy (G07).

## 3.2 Ngoài phạm vi

- Lịch Google / Outlook / Apple → G05.
- Outlook (mail), Asana, ClickUp, GitHub, Linear, Monday.com, Todoist, Trello, Google Tasks, Microsoft Planner, Microsoft To Do, Apple Reminders → sau 1.2, thứ tự chờ chốt (mục 10).
- Zapier, Toggl Track, MCP / API công khai cho agent bên ngoài (từ xa) → sau 1.2. (MCP local cho Claude Code trên chính máy người dùng thuộc G10, có từ 1.0 — QC-12.)
- Tạo item mới ở nguồn từ app (ví dụ tạo issue Jira) → chưa làm `[giả định]`.
- Đồng bộ notes, comment, subtask, người được giao giữa app và nguồn → không làm.
- Đọc tin nhắn Slack / Teams thành task → sau 1.2 `[giả định]`.
- Quản trị workspace chặn / cho phép từng tích hợp, Privacy "Tích hợp" → bản sau (Q35).

# 4. Nguyên tắc sản phẩm

## 4.1 Nguồn giữ việc, app giữ kế hoạch

Tiêu đề và trạng thái thuộc về nguồn; ngày, thời lượng, timebox, thứ tự thuộc về app. Hai bên chỉ trao đổi trạng thái hoàn thành.

## 4.2 Một item, một task

Kéo cùng một item bao nhiêu lần, từ đâu, hoặc do Planning Agent tạo, cũng chỉ có một task; lần sau nhảy tới task đã có (EC-20). Item được nhận ra bằng tài khoản / site và id bất biến ở nguồn (Jira dùng id số, không dùng key), nên issue chuyển project vẫn là cùng một item. Liên kết đã ngắt không còn giữ item (B14).

## 4.3 Tích hợp hỏng, ngày vẫn chạy

Lỗi, giới hạn tần suất, mất quyền ở nguồn không chặn thao tác trong app. Panel hiện dữ liệu lần cuối và thời điểm (EC-22); task không bao giờ bị xoá vì nguồn (EC-19).

## 4.4 Quyền tối thiểu, ngắt là sạch

Chỉ xin scope cần cho tính năng đang bật; tính năng cần thêm quyền (ví dụ lưu trữ thư Gmail, đổi status Slack / Teams) xin thêm khi người dùng bật (C29). Ngắt kết nối thu hồi token, xoá cache trên server và mọi thiết bị, huỷ hàng đợi offline liên quan, xoá dữ liệu của tích hợp đó trong lịch sử AI của app (G10); task đã tạo ở lại (C30).

## 4.6 Dữ liệu tích hợp với trợ lý AI chỉ là dữ liệu

Trợ lý AI (G10) chạy bằng Claude Code trên máy người dùng và chỉ thấy dữ liệu tích hợp qua công cụ MCP đọc dữ liệu tích hợp, mặc định tắt. Khi người dùng bật, công cụ chỉ trả metadata của việc giao cho mình (không nội dung thư, không đoạn trích Gmail); phiên AI đã đọc dữ liệu này thì mọi thay đổi sau lần đọc đầu tiên chờ người dùng duyệt trong app, thay đổi trước đó giữ nguyên (QC-12 mục 6, D8). Task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá, kể cả khi người dùng cho phép AI hoàn thành và xoá task (QC-12 mục 4, D10), nên AI không bao giờ đẩy trạng thái ra nguồn.

## 4.5 Chỉ việc của tôi

App chỉ nhập item được giao cho chính người dùng: Jira theo assignee, Notion bắt buộc có thuộc tính Person, Gmail là hộp thư của chính tài khoản. Item đổi sang người khác thì liên kết chuyển chỉ đọc và app ngừng đẩy trạng thái ra nguồn (B15).

# 5. Quy tắc theo nhà cung cấp

**5.1 Nhà cung cấp bản 1.1 và 1.2**

| **Nhà cung cấp** | **Bản** | **Quyền truy cập** | **Item hiện trên panel** | **Task tạo ra** | **Task xong → nguồn** | **Nguồn đóng → task** | **Nhận thay đổi** | **Phím mở panel** |
|---|---|---|---|---|---|---|---|---|
| Gmail | 1.1 | OAuth Google, mặc định `gmail.readonly`; xin thêm `gmail.modify` chỉ khi người dùng bật "Lưu trữ thư khi hoàn thành task" (C29). Cả hai là scope hạn chế, cần thẩm định bảo mật của Google `[giả định — kỹ thuật xác nhận]` | Thư trong Hộp thư đến của chính tài khoản, mới nhất trước; lọc theo nhãn, gắn sao `[giả định]` | Tiêu đề = chủ đề thư; link về thread; nguồn "Gmail · {người gửi}" | Lưu trữ thư (bỏ khỏi Hộp thư đến) chỉ khi bật; mặc định tắt (C29) | Không có "đóng": lưu trữ thư không hoàn thành task (C28) | Gmail push qua Pub/Sub `[giả định]`; poll 15 phút | Shift+G |
| Jira (Cloud) | 1.1 | OAuth 2.0 (3LO) Atlassian, `read:jira-work`, `write:jira-work`, `offline_access` `[giả định]` | Chỉ issue có assignee là tài khoản đã kết nối (B15), chưa ở nhóm trạng thái Done; lọc theo project / JQL lưu sẵn, luôn kèm điều kiện "giao cho tôi" | Tiêu đề = "{KEY-123} {summary}"; link issue; due ← due date Jira `[giả định]`. Nhận ra item bằng site + issue id số, không bằng key (B14) | Chạy transition người dùng chọn cho từng project; mặc định transition đầu tiên vào nhóm Done `[giả định]` | Issue vào nhóm Done → task xong (EC-21) | Webhook động `[giả định]`; poll 15 phút | Shift+J |
| Notion | 1.1 | OAuth public integration; người dùng chọn trang / database chia sẻ cho app | Trang trong database đã chọn có thuộc tính Status hoặc Checkbox và thuộc tính Person (bắt buộc) chứa người dùng (B15) | Tiêu đề trang; link trang; due ← thuộc tính Date người dùng chọn `[giả định]` | Đặt thuộc tính trạng thái = giá trị "xong" người dùng ánh xạ | Thuộc tính = giá trị "xong" → task xong (EC-21) | Webhook `[giả định]`; poll 15 phút | Shift+N |
| Slack | 1.2 | OAuth Slack, `chat:write` khi kết nối; `users.profile:write`, `dnd:write` xin thêm khi bật đổi status / DND (C29) `[giả định — tên scope]` | Không có panel item ở 1.2 | — | — | — | — | — |
| Microsoft Teams | 1.2 | Microsoft Graph, chỉ quyền gửi tin (`ChannelMessage.Send`, `ChatMessage.Send`) khi kết nối; `Presence.ReadWrite` xin thêm khi bật đổi status (C29) `[giả định — tên scope]` | Không có panel item ở 1.2 | — | — | — | — | — |

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
| Toggl Track | Theo dõi thời gian | — | Đẩy bản ghi thời gian (G07) sang Toggl |
| MCP / API công khai (từ xa) | Giao thức cho agent ngoài | — | Cùng quyền với API công khai. Khác MCP local của G10 (Claude Code trên chính máy, có từ 1.0, QC-12) |

**5.3 Quy tắc chung mọi nhà cung cấp**

| **Quy tắc** | **Giá trị** | **Ghi chú** |
|---|---|---|
| Item hiện trên panel | Tối đa 200 / nguồn, cuộn tải thêm | Mới cập nhật nhất trước |
| Làm mới panel | Khi mở panel nếu cache > 2 phút; nút làm mới ≤ 1 lần / 30 giây | Poll nền 15 phút |
| Giới hạn tần suất (429) | Theo Retry-After; không có thì backoff 30 giây → 15 phút, có jitter | Panel hiện dữ liệu lần cuối + thời điểm (EC-22) |
| Đẩy trạng thái ra nguồn lỗi | Thử lại tới 24 giờ | Giống timebox G05 |
| Hàng đợi đẩy chờ (cần kết nối lại, giới hạn tần suất) | Tối đa 7 ngày; khi chạy đọc trạng thái hiện tại của task, không đẩy trạng thái cũ (C27) | Quá 7 ngày → bỏ, hiện "Lệch với nguồn" |
| Cache item | Chỉ metadata (tiêu đề, trạng thái, hạn, URL; Gmail thêm đoạn trích ≤ 200 ký tự), giữ 7 ngày | Không lưu nội dung thư / mô tả đầy đủ; ngắt kết nối xoá cả cache trên thiết bị (C30) |
| Hoàn thành 2 chiều | Bật / tắt theo từng tích hợp | Mặc định bật |
| Token | Mã hoá AES-256-GCM, chỉ dùng ở server | Ngắt kết nối thu hồi token |
| Số tích hợp được kết nối | Theo bảng quyền theo gói của G12 (QC-10) | Không viết cứng |
| Chế độ chỉ đọc (QC-09, Q8) | Webhook / poll chỉ cập nhật cache panel; không tạo, hoàn thành hay sửa task; không đẩy trạng thái ra nguồn | Bản 1.1 |
| Dữ liệu tích hợp với trợ lý AI (QC-12 mục 6) | Chỉ qua công cụ MCP đọc dữ liệu tích hợp của G10, mặc định tắt; trả metadata item (tiêu đề, trạng thái, hạn, nguồn phụ, URL) và hoạt động trong ngày của chính tài khoản; không nội dung thư, không đoạn trích Gmail, không nội dung xem trước; phiên AI đã đọc → các thay đổi sau lần đọc đầu tiên chờ duyệt (D8) | Đoạn trích Gmail: `[giả định — không đưa]` |
| AI và task liên kết | Task có liên kết tích hợp còn hiệu lực không bao giờ được AI hoàn thành hay xoá (QC-12 mục 4, D10) | — |

Giá trị trong bảng 5.3 là `[giả định]` trừ các dòng ghi mã quyết định (C27, C30, QC-09, QC-10, QC-12).

- Các giá trị là **cấu hình hệ thống**, không cố định trong code.
- Tác nhân trong nhật ký task cho mọi thay đổi do tích hợp: `integration` (kèm tên nhà cung cấp).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Kết nối | Cài đặt → Tích hợp, nút + trên panel phải, hoặc bước "chọn công cụ công việc" của onboarding (G01) → OAuth | Tích hợp `DA_KET_NOI`, icon xuất hiện trên panel phải |
| 2 | Cấu hình | Chọn project / database / nhãn cần xem, ánh xạ trạng thái "xong", bật / tắt 2 chiều | Panel chỉ hiện việc liên quan |
| 3 | Lấy việc | Mở panel (Shift+J…), xem trước (I), kéo item vào cột ngày, lịch hoặc Backlog; hoặc kéo từ tab Tích hợp trong Daily planning (G08) | Task liên kết có tiêu đề, link, nguồn |
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

AC05: Lần kết nối đầu chỉ xin quyền tối thiểu (Gmail: chỉ đọc; Slack / Teams: chỉ gửi tin). Bật tính năng cần thêm quyền → mở lại trang hãng để xin đúng quyền đó; người dùng từ chối → tính năng giữ tắt, kết nối cũ vẫn dùng được (C29).

### US1.2 Chọn việc cần xem

AC01: Jira: chọn site, project, hoặc dán JQL; Notion: chọn database và thuộc tính trạng thái, giá trị "xong"; Gmail: chọn nhãn (mặc định Hộp thư đến).

AC02: Bật / tắt "Hoàn thành hai chiều" theo từng tích hợp; Gmail có thêm "Lưu trữ thư khi hoàn thành task" (mặc định tắt; bật thì xin thêm quyền theo US1.1 AC05).

AC03: Thay đổi cấu hình lưu ngay, panel làm mới theo cấu hình mới.

AC04: Jira: dù chọn project hay dán JQL, panel chỉ hiện issue giao cho tài khoản đã kết nối (B15).

AC05: Notion: bắt buộc chọn thuộc tính Person; database không có thuộc tính Person thì không chọn được, có thông báo giải thích (B15).

### US1.3 Ngắt kết nối

AC01: "Ngắt kết nối" hỏi xác nhận, nói rõ: task đã tạo vẫn giữ, chỉ mất liên kết đồng bộ.

AC02: Sau khi ngắt: token bị thu hồi ở hãng, cache item bị xoá trên server và trên mọi thiết bị (kể cả đoạn trích Gmail), thao tác offline đang chờ của tích hợp đó bị huỷ, dữ liệu của tích hợp đó trong lịch sử AI bị xoá (G10), icon biến khỏi panel (C30).

AC03: Liên kết đã ngắt không còn giữ item: sau khi kết nối lại bằng tài khoản khác, kéo cùng item tạo được task mới (B14).

## UC2. Đưa việc từ công cụ vào ngày

### US2.1 Xem việc trong panel

AC01: Bấm icon trên panel phải hoặc phím tắt (Shift+G, Shift+J, Shift+N) mở panel nguồn đó.

AC02: Mỗi item hiện: tiêu đề, nguồn phụ (project / database / người gửi), hạn nếu có; item đã có task hiện dấu "Đã lên kế hoạch · {ngày}".

AC03: Có ô tìm, nút làm mới, dòng "Cập nhật lúc {giờ}".

AC04: Panel chỉ có item được giao cho người dùng (B15); item đổi sang người khác biến khỏi panel ở lần đồng bộ sau.

### US2.2 Kéo item thành task

User Story: Là Minh, tôi muốn kéo một issue Jira vào chiều thứ Năm, để có task có sẵn link và lên lịch luôn.

AC01: Kéo item vào cột ngày → task `startDate` = ngày đó; kéo vào lịch → task có timebox (G05).

AC02: Task có tiêu đề nguồn, link, biểu tượng nguồn; thời lượng và channel theo gợi ý (G02).

AC03: Không dùng chuột: chọn item, nhấn A (thêm vào hôm nay) hoặc menu "Thêm vào ngày…" `[giả định]`.

AC04: Phím I xem trước item; phím G mở item ở nguồn (tab mới).

AC05: Kéo item vào panel Backlog (G06) → task ở Backlog, đúng bucket được thả, không có ngày dự định (bản 1.1, C34).

### US2.3 Không tạo trùng

AC01: Kéo item đã có task chưa xoá → không tạo mới; mở / cuộn tới task đã có, toast "Việc này đã có trong {ngày}" (EC-20).

AC02: Task của item đang trong Thùng rác → khôi phục task đó thay vì tạo mới `[giả định]`.

AC03: Hai thiết bị kéo cùng item cùng lúc → chỉ một task được tạo.

AC04: Item được nhận ra bằng tài khoản / site và id bất biến ở nguồn; issue Jira chuyển project (đổi key) vẫn là cùng item, không tạo task thứ hai (B14).

AC05: Trợ lý AI (G10: Planning Agent, chat, Claude Code trong terminal) tạo task từ item cũng đi qua cùng cơ chế, và chỉ sau khi người dùng duyệt (QC-12 mục 6); item đã có task thì AI không tạo thêm (B14).

### US2.4 Lấy việc từ công cụ trong Daily planning (bản 1.1)

User Story: Là Linh, tôi muốn thấy issue Jira và email cần trả lời ngay trong bước Thêm task của Daily planning, để lập kế hoạch sáng mà không phải mở panel riêng.

AC01: Bước "Thêm task cho hôm nay" của Daily planning (G08) có tab "Tích hợp" cạnh Lịch và Backlog từ bản 1.1 (C34).

AC02: Tab liệt kê item theo từng nguồn (chọn nguồn bằng chip), cùng dữ liệu và dấu "Đã lên kế hoạch · {ngày}" như panel tích hợp.

AC03: Kéo item vào danh sách hôm nay → task liên kết ngày D của ritual; kéo vào Backlog → task ở Backlog; áp mọi quy tắc của US2.2, US2.3.

AC04: Chưa kết nối tích hợp nào → tab hiện hướng dẫn và nút "Kết nối công cụ" (mở Cài đặt → Tích hợp).

## UC3. Đồng bộ trạng thái hai chiều

### US3.1 Hoàn thành trong app cập nhật nguồn

AC01: Bật hai chiều: hoàn thành task → Jira chạy transition đã chọn; Notion đặt giá trị "xong"; Gmail lưu trữ thư nếu bật.

AC02: Cập nhật nguồn chạy nền; lỗi không chặn hoàn thành trong app; card hiện biểu tượng "Chưa cập nhật được {nguồn}" và "Thử lại".

AC03: Hoàn tác trong toast → trả nguồn về trạng thái trước `[giả định]`. Jira không có transition ngược từ trạng thái hiện tại → chỉ báo cho người dùng, không đổi gì ở nguồn (C27).

AC04: Hai bên không còn khớp (bỏ hoàn thành sau thời hạn đẩy ngược, item mở lại ở nguồn, hàng đợi đẩy quá 7 ngày) → card và chi tiết task hiện nhãn "Lệch với nguồn" và nút "Đồng bộ lại" (C27).

AC05: Task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá, kể cả khi người dùng bật "Cho phép AI hoàn thành và xoá task" của G10, nên AI không bao giờ đẩy trạng thái ra nguồn (QC-12 mục 4, Q46, D10; thay Q20 ở phần này).

### US3.2 Đóng ở nguồn hoàn thành task

AC01: Item chuyển sang trạng thái xong ở nguồn và đang bật hai chiều → task đánh dấu xong theo quy tắc hoàn thành (G02), nhật ký ghi "Jira đánh dấu xong" (tác nhân integration) (EC-21).

AC02: Tắt hai chiều → task không đổi, hiện nhãn "Đã xong ở {nguồn}".

AC03: Item mở lại ở nguồn → task không tự bỏ hoàn thành, nhật ký ghi lại, card hiện "Lệch với nguồn" (C27).

AC04: Workspace ở chế độ chỉ đọc (bản 1.1) → thay đổi từ nguồn chỉ cập nhật panel, không hoàn thành hay sửa task (QC-09, Q8).

AC05: Item đổi sang người khác → liên kết chuyển "chỉ đọc": app ngừng đẩy trạng thái ra nguồn, task giữ nguyên; item đóng ở nguồn chỉ hiện nhãn "Đã xong ở {nguồn}" `[giả định]` (B15).

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

AC01: Lần đầu bật timer khi có Slack / Teams → lời mời "Giảm phân tâm trên Slack / Teams khi làm việc?" (G07), đồng ý bật cài đặt và xin thêm quyền đổi status / DND (C29).

AC02: Timer chạy → status "Đang tập trung" và DND trong thời gian planned còn lại; timer dừng → trả status trước đó.

AC03: Mặc định không hiện tên task trên status `[giả định]`.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu 1.1** |
|---|---|---|
| Tỉ lệ kết nối | Người dùng hoạt động có ≥ 1 tích hợp / người dùng hoạt động | ≥ 40% |
| Task từ tích hợp | Task tạo từ item / task tạo mới (người đã kết nối) | ≥ 25% |
| Task trùng | Số item (theo khoá tài khoản / site + id bất biến, B14) có > 1 task chưa xoá với liên kết còn hiệu lực | 0 |
| Cập nhật nguồn thành công | Lần đẩy trạng thái thành công trong 24 giờ / lần đẩy | ≥ 99% |
| Độ trễ đồng bộ hoàn thành | Từ đóng ở một bên đến bên kia cập nhật | p95 ≤ 1 phút (webhook), ≤ 15 phút (poll) |
| Kết nối hỏng | Tích hợp ở `CAN_KET_NOI_LAI` / tích hợp đã kết nối | ≤ 5% |
| Dùng DND (1.2) | Người dùng Slack / Teams bật DND theo timer | ≥ 30% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Thẩm định Gmail | Scope Gmail là scope hạn chế, cần Google xác minh và đánh giá bảo mật; có thể chậm ra mắt Gmail | Nộp sớm cùng hồ sơ lịch (G05); mặc định chỉ đọc (`gmail.readonly`), `gmail.modify` chỉ xin khi bật lưu trữ thư (C29) |
| Lệnh ẩn trong item | Tiêu đề email / issue do người lạ viết có thể chứa câu lệnh cho Claude Code | Công cụ MCP đọc dữ liệu tích hợp mặc định tắt; phiên AI đã đọc thì các thay đổi sau lần đọc đầu tiên chờ duyệt trong app (D8); AI không hoàn thành, không xoá task liên kết (G10, Q21, QC-12 mục 4, 6, D10) |
| Dữ liệu của người khác | JQL tự do hoặc database Notion chung kéo việc của đồng nghiệp vào app và vào AI | Chỉ nhập item giao cho mình; đổi người giao → liên kết chỉ đọc (B15); công cụ MCP chỉ trả item giao cho mình |
| Duyệt app của Atlassian / Notion / Slack / Microsoft | Thời gian duyệt chưa rõ | Đưa vào kế hoạch phát hành 1.1 / 1.2 |
| Giới hạn tần suất của hãng | Nhiều người dùng chung một app OAuth | Backoff, cache, ưu tiên webhook; giám sát 429 theo hãng |
| Webhook không ổn định / hết hạn | Mất sự kiện | Poll 15 phút dự phòng; gia hạn webhook định kỳ |
| Vòng lặp đồng bộ | App đẩy trạng thái → nguồn bắn webhook → app xử lý lại | Đánh dấu thay đổi do app đẩy, bỏ qua sự kiện dội lại |
| Dữ liệu email nhạy cảm | Nghị định 13/2023/NĐ-CP, GDPR; metadata có thể đi qua Claude Code của người dùng khi bật công cụ đọc | Chỉ lưu metadata, xem trước đọc trực tiếp; công cụ MCP không trả nội dung thư; cần pháp chế xác nhận |
| App desktop (Windows, macOS) | OAuth từ app desktop; nhận realtime khi app đóng | Trình duyệt hệ thống + luồng loopback / PKCE, đồng bộ khi mở lại: tech chốt |
| Workflow Jira đa dạng | Không có trạng thái "Done" chung | Cho chọn transition theo project; không có transition hợp lệ → chỉ cập nhật trong app, báo người dùng |
| API hãng thay đổi | Adapter hỏng | Adapter chung, kiểm thử hợp đồng hằng ngày |

# 10. Câu hỏi mở

- Danh sách tích hợp ưu tiên cho thị trường Việt Nam là gì (ngoài danh sách Sunsama)?
- Thứ tự phát hành các nhà cung cấp sau 1.2?
- Gmail: hoàn thành task có lưu trữ thư không, hay chỉ đánh dấu đã đọc / không làm gì? — Đã chốt 04/11/2026: mặc định chỉ đọc (`gmail.readonly`), không làm gì với thư; lưu trữ thư chỉ khi người dùng bật và cấp thêm quyền (C29). Gmail không có "đóng" (C28).
- Hoàn thành hai chiều mặc định bật hay tắt?
- Item mở lại ở nguồn có bỏ hoàn thành task không? — Đã chốt 04/11/2026: không tự bỏ hoàn thành; hiện nhãn "Lệch với nguồn" và nút "Đồng bộ lại" (C27).
- Tiêu đề ở nguồn đổi có cập nhật tiêu đề task không (khi người dùng chưa sửa)?
- Một người dùng có được kết nối nhiều tài khoản / nhiều site Jira cùng nhà cung cấp không? (Khoá chống trùng đã gồm tài khoản / site theo B14, nên mở rộng sau không phải đổi dữ liệu.)
- "Dữ liệu của người khác" là gì, nhập việc của ai? — Đã chốt 04/11/2026: chỉ item giao cho mình (Jira assignee; Notion bắt buộc Person); đổi người giao → liên kết chỉ đọc, ngừng đẩy ngược (B15).
- Liên kết chỉ đọc (item đã giao cho người khác): item đóng ở nguồn có hoàn thành task không, hay chỉ hiện nhãn? Item giao lại cho mình thì liên kết có tự về đồng bộ không?
- "Đồng bộ lại" khi "Lệch với nguồn" đẩy trạng thái của app ra nguồn hay lấy trạng thái nguồn về app?
- Kéo item vào Backlog: bucket mặc định khi thả vào tiêu đề panel (không vào bucket cụ thể)?
- Status Slack / Teams có hiện tên task không?
- Ai nộp hồ sơ xác minh Google cho Gmail, khi nào (chung với G05)?
- Quản trị workspace có cần chặn / cho phép từng tích hợp không? — Đã chốt 04/11/2026: bản 1 chỉ một người dùng; quản trị workspace và Privacy để bản sau (Q35).
- Dữ liệu tích hợp có được gửi cho AI không? — Đã chốt 04/11/2026: chỉ qua công cụ MCP đọc dữ liệu tích hợp của G10, mặc định tắt; phiên AI đã đọc thì các thay đổi sau lần đầu đọc dữ liệu tích hợp trong phiên đó chờ duyệt (Q21, Q46, QC-12 mục 6, D8).
- Công cụ MCP đọc dữ liệu tích hợp có trả đoạn trích Gmail (≤ 200 ký tự) không, hay chỉ chủ đề thư (đang giả định: chỉ chủ đề)?
- AI (khi người dùng cho phép xoá) có được xoá task có liên kết tích hợp không? — Đã chốt 04/11/2026: không; AI không bao giờ hoàn thành hay xoá task có liên kết tích hợp (D10, QC-12 mục 4).
