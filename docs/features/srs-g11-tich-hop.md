> **Mã:** PLN-SRS-G11-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g11-tich-hop.md

# UC-G11 - Tích hợp công cụ trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO và kỹ thuật xác nhận với tài liệu API của từng hãng. SRS này chỉ mô tả kết nối, cấu hình, panel tích hợp, tạo task từ item, đồng bộ hoàn thành hai chiều, xử lý lỗi tích hợp (bản 1.1: Gmail, Jira, Notion) và Slack / Teams (bản 1.2). Lịch và timebox (G05), task và hoàn thành (G02), kéo thả trên board (G04), timer (G07), chia sẻ ritual (G08), highlights AI (G10), Privacy và thông báo (G12) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> **Cập nhật 04/11/2026** theo [quyết định chốt mâu thuẫn](../review/quyet-dinh-chot-2026-11-04.md) (Q8, Q21, B14, B15, C27–C30, C34). Quy tắc dùng chung tham chiếu [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md): ngày làm việc QC-01, đồng bộ nhiều thiết bị QC-08, chế độ chỉ đọc QC-09, quyền theo gói QC-10 (cả hai có từ 1.1, cùng bản với G11).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng kết nối công cụ, kéo việc từ đó vào ngày thành task liên kết, và hai bên tự khớp trạng thái hoàn thành; lỗi tích hợp không chặn app |
| Actor | Người dùng đã đăng nhập · Hệ thống · Nhà cung cấp (Gmail, Jira, Notion, Slack, Microsoft Teams) · Adapter tích hợp (\[IntegrationAdapter\]) |
| Phạm vi | Danh sách và kết nối OAuth (xin quyền tăng dần), cấu hình theo nhà cung cấp, panel item, tab Tích hợp trong Daily planning và kéo item vào Backlog, xem trước / mở nguồn, tạo task từ item (cả cho Planning Agent G10), chống trùng, chỉ nhập việc của tôi, đồng bộ hoàn thành hai chiều, "Lệch với nguồn", nguồn không còn, giới hạn tần suất, token hết hạn, chế độ chỉ đọc, ngắt kết nối và xoá dữ liệu, hoạt động cho G10, Slack / Teams (1.2) |
| Ngoài phạm vi | Lịch (G05), nhà cung cấp sau 1.2, Zapier / Toggl / MCP, tạo item ở nguồn, đồng bộ notes / comment / subtask, quản trị chặn tích hợp |
| Nền tảng | Bản 1.1: Web (desktop, mobile web), App iOS / Android, desktop dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Kết nối Gmail, Jira, Notion bằng tài khoản của tôi | Việc ở các công cụ hiện trong app |
| US-02 | Người dùng | Chọn project / database / nhãn cần xem và cách đánh dấu xong | Panel chỉ có việc liên quan |
| US-03 | Người dùng | Kéo item vào ngày hoặc lịch thành task có link nguồn | Lên kế hoạch không chép tay |
| US-04 | Người dùng | Kéo lại cùng item không tạo task trùng | Danh sách gọn |
| US-05 | Người dùng | Xong ở app thì nguồn cập nhật, xong ở nguồn thì task cập nhật | Không cập nhật hai lần |
| US-06 | Người dùng | Biết khi nguồn bị xoá / mất quyền mà task vẫn còn | Không mất kế hoạch |
| US-07 | Người dùng | Vẫn dùng panel khi hãng giới hạn tần suất | Không bị treo lúc lập kế hoạch |
| US-08 | Người dùng | Ngắt kết nối sạch | Thu hồi quyền khi không dùng |
| US-09 | Người dùng thành thạo | Mở panel, xem trước, mở nguồn bằng phím tắt | Không rời bàn phím |
| US-10 | Người dùng (1.2) | Chia sẻ ritual lên Slack / Teams và tự bật DND khi timer chạy | Báo cáo nhóm và tập trung |
| US-11 | Người dùng | Lấy item ngay trong bước Thêm task của Daily planning, kéo item vào Backlog | Lập kế hoạch sáng không phải mở panel riêng |
| US-12 | Người dùng | Chỉ thấy và đồng bộ việc được giao cho mình | Không kéo việc của đồng nghiệp vào app, không đóng nhầm issue của người khác |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Nhà cung cấp theo bản.** 1.1: Gmail, Jira (Cloud), Notion. 1.2: Slack, Microsoft Teams. Nhà cung cấp khác hiện "Sắp có" `[giả định]`. Danh sách lấy từ \[AppConfig\] (cờ bật theo nhà cung cấp) |
| BR-02 | **Kết nối.** OAuth 2.0 có `state` chống CSRF và PKCE khi hãng hỗ trợ. **Quyền tối thiểu, xin tăng dần (C29):** lần kết nối đầu chỉ xin scope cơ bản theo PRD mục 5.1 (Gmail `gmail.readonly`; Slack `chat:write`; Teams chỉ quyền gửi tin); bật tính năng cần thêm quyền (Gmail "Lưu trữ thư khi hoàn thành" → `gmail.modify`; Slack / Teams đổi status / DND) → \[IntegrationConnect\] với `features` để xin thêm đúng scope đó; người dùng từ chối → tính năng giữ tắt, scope cũ giữ nguyên. Mỗi người dùng 1 tài khoản / nhà cung cấp; Jira chọn 1 site `[giả định]` |
| BR-03 | **Token.** Mã hoá AES-256-GCM, khoá quản lý trong KMS `[giả định]`; chỉ dùng ở server, không bao giờ trả về client. Làm mới tự động trước khi hết hạn; làm mới bị từ chối (400 / 401 `invalid_grant`) → tích hợp `CAN_KET_NOI_LAI` và thông báo trong app + email (G12) |
| BR-04 | **Một item, một task (EC-20, B14).** \[TaskLink\] khoá duy nhất (userId, provider, `accountId` / `siteId`, `immutableId`) trên task chưa xoá vĩnh viễn, chỉ tính liên kết còn hiệu lực (khác `DA_NGAT_LIEN_KET`). `immutableId`: Jira = issue id số (không dùng key, key đổi khi chuyển project); Notion = page id; Gmail = thread id `[giả định]`. Mọi đường tạo task từ item đều qua \[TaskFromItem\]: kéo panel, phím A, tab Tích hợp Daily planning (BR-23), Backlog, Planning Agent G10 (BR-24). Tạo task từ item đã liên kết: task chưa xoá → không tạo, trả `ALREADY_LINKED` kèm taskId; task trong Thùng rác → khôi phục task đó (QC-03 mục 3) `[giả định]` |
| BR-05 | **Ánh xạ trường.** Tiêu đề: Gmail = chủ đề thư; Jira = "{key} {summary}"; Notion = tiêu đề trang. `externalUrl` = link nguồn. Due ← due date Jira / thuộc tính Date Notion đã chọn `[giả định]`. Vị trí: thả vào cột ngày / ô lịch → `KE_HOACH`, ngày dự định = ngày thả; thả vào Backlog → `BACKLOG`, `backlogBucket` = bucket thả (QC-03). Thời lượng, channel theo gợi ý G02. Không đồng bộ notes, comment, subtask, người được giao |
| BR-06 | **Tiêu đề đổi ở nguồn.** Tiêu đề task có nguồn `integration` → cập nhật theo nguồn; người dùng đã sửa (nguồn `user`) → giữ, không ghi đè `[giả định]` |
| BR-07 | **Task xong → nguồn (mức C).** Bật "Hoàn thành hai chiều" (mặc định bật `[giả định]`) và liên kết không ở `CHI_DOC` (BR-21): Jira chạy transition đã chọn cho project; Notion đặt thuộc tính trạng thái = giá trị "xong"; Gmail lưu trữ thư chỉ khi bật "Lưu trữ thư khi hoàn thành" (mặc định tắt, cần `gmail.modify`, C29). Chạy nền qua job `integration.push`; liên kết `CHO_DONG_BO` tới khi xong. Chỉ người dùng hoàn thành task; AI không bao giờ kích hoạt đẩy này (Q20) |
| BR-08 | **Hoàn tác / bỏ hoàn thành.** Hoàn tác trong toast hoặc bỏ hoàn thành trong vòng 5 phút `[giả định]` → đẩy trạng thái trước đó ra nguồn; Jira không có transition ngược từ trạng thái hiện tại → không đổi nguồn, báo MSG-23, liên kết hiện "Lệch với nguồn" (C27). Sau 5 phút → chỉ đổi trong app, liên kết hiện "Lệch với nguồn" (BR-22) |
| BR-09 | **Nguồn đóng → task (EC-21).** Item vào trạng thái xong ở nguồn (Jira nhóm Done; Notion giá trị "xong"): bật hai chiều và liên kết không ở `CHI_DOC` → hoàn thành task theo G02 (QC-05 dòng "Hoàn thành": dừng timer, subtask, actual, ngày dự định), tác nhân `integration`, nhật ký "{Nhà cung cấp} đánh dấu xong". Tắt hai chiều hoặc liên kết `CHI_DOC` → chỉ nhãn "Đã xong ở {nguồn}" (`CHI_DOC`: `[giả định]`). Gmail không có "đóng": thư bị lưu trữ không hoàn thành task (C28). Item mở lại ở nguồn → task không tự bỏ hoàn thành, ghi nhật ký, hiện "Lệch với nguồn" (C27). Workspace chỉ đọc → BR-25 |
| BR-10 | **Chống vòng lặp.** Mỗi lần đẩy ra nguồn ghi `pushId` và trạng thái đích; sự kiện nhận về trong 2 phút `[giả định]` có cùng trạng thái → bỏ qua |
| BR-11 | **Nguồn không còn (EC-19).** Nguồn trả 404 / 410, hoặc 403 khi đọc item → liên kết `NGUON_KHONG_CON`; task giữ nguyên mọi dữ liệu; card và chi tiết hiện nhãn "Nguồn không còn"; ngừng đẩy trạng thái. Lần đồng bộ sau đọc được item → về `DONG_BO`. Không bao giờ xoá task vì nguồn |
| BR-12 | **Giới hạn tần suất (EC-22).** 429 → chờ theo `Retry-After`; không có → backoff mũ 30 giây, 1, 2, 4, 8, tối đa 15 phút, jitter ± 20% `[giả định]`. Trong thời gian chờ: tích hợp `BI_GIOI_HAN`, panel hiện cache + "Cập nhật lúc {giờ}", kéo item vẫn tạo task từ cache, đẩy trạng thái xếp hàng |
| BR-13 | **Đẩy lỗi.** Lỗi 5xx / mạng khi đẩy → thử lại tới 24 giờ (1, 5, 15, 60 phút rồi mỗi giờ `[giả định]`); hết hạn → liên kết `LOI_DONG_BO`, card có "Thử lại". **Hàng đợi chờ (C27):** job đẩy đang chờ vì `CAN_KET_NOI_LAI` hoặc `BI_GIOI_HAN` giữ tối đa 7 ngày; khi chạy, job đọc trạng thái hoàn thành **hiện tại** của task (không dùng trạng thái lúc xếp hàng), trùng với nguồn → bỏ qua; quá 7 ngày → huỷ job, liên kết hiện "Lệch với nguồn" (BR-22) |
| BR-14 | **Cache item.** Chỉ lưu metadata: externalId, `immutableId`, tiêu đề, trạng thái, hạn, nguồn phụ (project / database / người gửi), người được giao, URL, cập nhật lúc; Gmail thêm đoạn trích ≤ 200 ký tự. Giữ 7 ngày `[giả định]` trên server và trên thiết bị. Xem trước (I) đọc trực tiếp từ nguồn, không lưu |
| BR-15 | **Làm mới.** Webhook / push khi hãng hỗ trợ; poll nền 15 phút; mở panel → làm mới nếu cache > 2 phút; nút làm mới ≤ 1 lần / 30 giây `[giả định]` |
| BR-16 | **Ngắt kết nối (C30, B14).** Gọi thu hồi token ở hãng (nếu có), xoá token, xoá cache item trên server, huỷ webhook, huỷ job đẩy đang chờ; phát realtime `integration.purged` để mọi thiết bị xoá cache item (kể cả đoạn trích Gmail) và huỷ thao tác offline đang chờ của tích hợp đó (\[TaskFromItem\] chưa gửi, "Thử lại" đẩy); phát `integration.disconnected` để G10 xoá dữ liệu của tích hợp đó trong lịch sử AI (G10 BR-23). Task liên kết giữ nguyên, liên kết → `DA_NGAT_LIEN_KET`, link nguồn thành link thường, liên kết **không còn giữ khoá** BR-04. Kết nối lại cùng tài khoản trong 30 ngày `[giả định]` → liên kết khớp lại theo `immutableId`, trừ khi khoá đã thuộc một liên kết khác còn hiệu lực (khi đó liên kết cũ giữ `DA_NGAT_LIEN_KET`) |
| BR-17 | **Không chặn.** Mọi thao tác task trong app thành công độc lập với trạng thái tích hợp; lỗi tích hợp chỉ hiện ở panel, card và Cài đặt |
| BR-18 | **Quyền riêng tư.** Thành viên khác chỉ thấy dữ liệu tích hợp khi Privacy "Tích hợp" = "Thành viên" (G12); mặc định chỉ mình tôi. Workspace chỉ đọc → BR-25 |
| BR-19 | **Hoạt động cho G10 (C28).** \[IntegrationActivity\] trả item mà **chính tài khoản đã kết nối** đã đóng / chuyển trạng thái trong ngày làm việc (QC-01), lấy từ dữ liệu đã đồng bộ, không gọi thêm scope. Actor theo từng nhà cung cấp: Jira = tác giả lần chuyển trạng thái (changelog) là tài khoản đã kết nối `[giả định]`; Notion = `last_edited_by` là người dùng `[giả định]`; Gmail không có hoạt động "đóng", không trả gì. Hoạt động do người khác làm không trả. G10 chỉ gọi khi người dùng bật dùng dữ liệu tích hợp cho AI (G10 BR-20, Q21) |
| BR-20 | **Slack / Teams (1.2).** Kết nối chỉ xin quyền gửi tin; đổi status / DND xin thêm quyền khi bật (BR-02, C29). Chia sẻ ritual chỉ khi người dùng bấm Done (G08). Status / DND khi bật cài đặt: timer bắt đầu → status "Đang tập trung" `[giả định]` (tên task chỉ khi bật "Hiện tên task"), DND trong planned còn lại (15–240 phút `[giả định]`; planned trống → 60 phút); timer dừng → khôi phục status trước đó nếu người dùng chưa tự đổi. Lỗi không ảnh hưởng timer |

## 4. Trạng thái

### 4.1. Trạng thái kết nối tích hợp

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHUA_KET_NOI` | Chưa có token, hoặc đã ngắt kết nối | Cài đặt: nút "Kết nối"; không có icon trên panel phải |
| `DANG_KET_NOI` | Đã mở OAuth, chưa nhận callback (tối đa 10 phút `[giả định]`) | Nút "Đang kết nối…" disabled |
| `DA_KET_NOI` | Token hợp lệ, lần gọi gần nhất thành công | "Đã kết nối · {tài khoản}"; icon trên panel |
| `BI_GIOI_HAN` | Đang chờ sau 429 (BR-12) | Panel: "Cập nhật lúc {giờ} · Đang chờ {nguồn}" (MSG-06) |
| `CAN_KET_NOI_LAI` | Làm mới token bị từ chối, token bị thu hồi, hoặc thiếu scope | Badge cảnh báo trên icon; banner MSG-07 + "Kết nối lại"; thông báo (G12) |
| `LOI` | Lỗi 5xx / mạng liên tục > 1 giờ `[giả định]` | Panel hiện cache + MSG-08; tự thử lại theo poll |

Chuyển trạng thái: `CHUA_KET_NOI` → `DANG_KET_NOI` → `DA_KET_NOI` | `CHUA_KET_NOI` (từ chối / hết thời gian) · `DA_KET_NOI` ⇄ `BI_GIOI_HAN` · `DA_KET_NOI` ⇄ `LOI` · `DA_KET_NOI` / `BI_GIOI_HAN` / `LOI` → `CAN_KET_NOI_LAI` → `DA_KET_NOI` (UC-07) · mọi trạng thái → `CHUA_KET_NOI` (ngắt kết nối).

### 4.2. Trạng thái liên kết task – item

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DONG_BO` | Liên kết hợp lệ, không có thay đổi chờ đẩy | Biểu tượng nguồn trên card; chi tiết hiện "{Nguồn} · {key / tên}" |
| `CHO_DONG_BO` | Có trạng thái đang chờ đẩy ra nguồn (BR-07, BR-12) | Biểu tượng nguồn có chấm "đang cập nhật" |
| `LOI_DONG_BO` | Đẩy thất bại sau 24 giờ (BR-13) hoặc không có transition hợp lệ | Icon cảnh báo, MSG-11 + "Thử lại" |
| `NGUON_KHONG_CON` | Item bị xoá / mất quyền (BR-11) | Nhãn "Nguồn không còn" (MSG-10) |
| `DA_NGAT_LIEN_KET` | Tích hợp đã ngắt (BR-16) | Link thường, không biểu tượng nguồn |

Chuyển: `DONG_BO` ⇄ `CHO_DONG_BO` → `LOI_DONG_BO` → `CHO_DONG_BO` (Thử lại) · `DONG_BO` / `CHO_DONG_BO` ⇄ `NGUON_KHONG_CON` · mọi trạng thái → `DA_NGAT_LIEN_KET` → `DONG_BO` (kết nối lại, BR-16). Trạng thái task (G02) độc lập với trạng thái liên kết.

## 5. Use Case

### UC-01 Kết nối tích hợp

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; nhà cung cấp có trong bản hiện tại (BR-01); tích hợp `CHUA_KET_NOI` |
| Hậu điều kiện thành công | Tích hợp `DA_KET_NOI`; token lưu mã hoá; webhook đăng ký (nếu có); lần đọc item đầu tiên chạy; icon xuất hiện trên panel phải |
| Hậu điều kiện thất bại | Tích hợp `CHUA_KET_NOI`; không lưu token |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Tích hợp (**SCR-01**), nút + trên panel phải, hoặc bước "chọn công cụ công việc" của onboarding (G01); bấm "Kết nối" ở nhà cung cấp |
| 2 | Hệ thống | Gọi \[IntegrationConnect\]; tích hợp `DANG_KET_NOI`; chuyển tới trang OAuth của hãng (cửa sổ mới trên Web, trình duyệt hệ thống trên App) |
| 3 | Người dùng | Đăng nhập và đồng ý quyền ở trang hãng (Notion: chọn trang / database chia sẻ; Jira: chọn site) |
| 4 | Hệ thống | \[IntegrationCallback\] kiểm `state`, đổi code lấy token, mã hoá lưu (BR-03); đăng ký webhook; tích hợp `DA_KET_NOI` |
| 5 | Hệ thống | Mở **SCR-02** cấu hình với giá trị mặc định; chạy \[IntegrationItems\] lần đầu; toast MSG-01 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Mở từ onboarding (G01) | Sau bước 4 quay về onboarding, cấu hình mặc định; SCR-02 mở được sau |
| A2 | Hãng không hỗ trợ webhook / đăng ký webhook lỗi | Vẫn `DA_KET_NOI`, chỉ dùng poll 15 phút (BR-15) |
| A3 | Nhà cung cấp "Sắp có" | Nút "Nhận tin khi có" `[giả định]`; không mở OAuth |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Người dùng từ chối quyền / đóng cửa sổ | `CHUA_KET_NOI`; MSG-02 |
| E2 | `state` sai / hết hạn (> 10 phút) | Không lưu token; MSG-03, cho kết nối lại |
| E3 | Thiếu scope bắt buộc (người dùng bỏ chọn quyền) | Thu hồi token vừa nhận; MSG-04 |
| E4 | Tài khoản hãng đã kết nối với người dùng khác trong cùng workspace | Cho phép (mỗi người token riêng); không chia sẻ dữ liệu (BR-18) |
| E5 | Hãng lỗi 5xx khi đổi token | MSG-05 + "Thử lại" |

### UC-02 Cấu hình tích hợp

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tích hợp `DA_KET_NOI` |
| Hậu điều kiện thành công | Cấu hình lưu ngay; panel làm mới theo cấu hình mới |
| Hậu điều kiện thất bại | Cấu hình giữ giá trị cũ; lỗi tại trường |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Tích hợp → chọn nhà cung cấp → **SCR-02** |
| 2 | Hệ thống | Gọi \[IntegrationOptions\] lấy danh sách project / database / nhãn / transition từ hãng |
| 3 | Người dùng | Đổi phạm vi item (Jira: project hoặc JQL; Notion: database, thuộc tính trạng thái, giá trị "xong", thuộc tính Person / Date; Gmail: nhãn), "Hoàn thành hai chiều", channel mặc định `[giả định]` |
| 4 | Hệ thống | Gọi \[IntegrationUpdate\] chỉ với trường đổi; làm mới cache |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Jira: project có nhiều transition vào nhóm Done | Dropdown "Khi hoàn thành task, chuyển issue sang" theo từng project; mặc định transition đầu tiên |
| A2 | Gmail: bật / tắt "Lưu trữ thư khi hoàn thành task" | Lưu ngay; áp dụng cho lần hoàn thành sau |
| A3 | Notion: database chưa được chia sẻ cho app | Nút "Chọn thêm trang trong Notion" mở lại OAuth chọn trang |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | JQL sai cú pháp | Hãng trả 400 → MSG-12 dưới ô, không lưu |
| E2 | Notion: không chọn thuộc tính trạng thái | Tắt "Hoàn thành hai chiều" cho database đó, MSG-13 |
| E3 | \[IntegrationOptions\] lỗi / 429 | Hiện lựa chọn đã lưu, MSG-06 / MSG-08 |

### UC-03 Xem item trong panel tích hợp

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tích hợp không ở `CHUA_KET_NOI` |
| Hậu điều kiện thành công | Panel hiện item theo cấu hình, thời điểm cập nhật; item đã có task được đánh dấu |
| Hậu điều kiện thất bại | Panel hiện cache lần cuối kèm thời điểm, hoặc trạng thái rỗng có hướng dẫn |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm icon nguồn trên panel phải hoặc phím Shift+G / Shift+J / Shift+N |
| 2 | Hệ thống | Mở **SCR-03**, hiện cache ngay; cache > 2 phút → gọi \[IntegrationItems\] (BR-15) |
| 3 | Hệ thống | Cập nhật danh sách: tiêu đề, nguồn phụ, hạn, dấu "Đã lên kế hoạch · {ngày}" cho item có \[TaskLink\]; "Cập nhật lúc {giờ}" |
| 4 | Người dùng | Tìm, cuộn, chọn item |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phím I trên item | Mở **SCR-04** xem trước (\[IntegrationItemPreview\], đọc trực tiếp từ nguồn) |
| A2 | Phím G trên item | Mở URL nguồn ở tab mới / app hãng |
| A3 | Nút làm mới | \[IntegrationItems\] `force=true`; disabled 30 giây sau mỗi lần |
| A4 | Không có item | Trạng thái rỗng MSG-14 + link "Đổi phạm vi" (SCR-02) |
| A5 | Webhook báo item đổi khi panel đang mở | Cập nhật dòng đó qua realtime `integration.changed` `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | 429 (EC-22) | Áp BR-12; giữ cache; dòng trạng thái MSG-06; nút làm mới disabled tới hết thời gian chờ |
| E2 | Token bị từ chối | Tích hợp `CAN_KET_NOI_LAI`; banner MSG-07 + "Kết nối lại" trên panel; vẫn hiện cache |
| E3 | 5xx / mạng | Giữ cache, MSG-08; tự thử lại ở lần poll sau |
| E4 | Mất mạng thiết bị | Hiện cache trên máy (nếu có), MSG-09 |

### UC-04 Tạo task từ item

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Panel nguồn đang mở; workspace không chỉ đọc (BR-18) |
| Hậu điều kiện thành công | Có đúng một task liên kết item (BR-04), `KE_HOACH` ở ngày thả, liên kết `DONG_BO`; nhật ký task ghi "tạo từ {nguồn}" |
| Hậu điều kiện thất bại | Không có task mới; item còn trên panel |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Kéo item từ SCR-03 vào cột ngày D (G04) |
| 2 | Hệ thống | Hiện task ngay ở vị trí thả (cập nhật lạc quan); gọi \[TaskFromItem\] với `integrationId`, `externalId`, `startDate = D`, vị trí, Idempotency-Key |
| 3 | Hệ thống | Server kiểm BR-04; tạo task theo BR-05; tạo \[TaskLink\]; gọi gợi ý thời lượng / channel (G02) |
| 4 | Hệ thống | Card hiện biểu tượng nguồn; item trên panel hiện "Đã lên kế hoạch · {ngày}" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Thả vào ô giờ trên lịch | Tạo task rồi timebox theo G05 (`PUT /tasks/{id}/timebox`) |
| A2 | Không dùng chuột | Chọn item, phím A "Thêm vào hôm nay" hoặc menu "Thêm vào ngày…" chọn ngày `[giả định]` |
| A3 | Item đã có task chưa xoá (EC-20) | Server trả `ALREADY_LINKED` + taskId; client gỡ card lạc quan, cuộn tới / làm nổi task đã có, toast MSG-15 |
| A4 | Task của item đang trong Thùng rác | Khôi phục task đó về ngày D (BR-04), toast MSG-16 |
| A5 | Tích hợp `BI_GIOI_HAN` / `LOI` | Tạo task từ cache; liên kết đánh dấu cần làm mới ở lần đồng bộ sau |
| A6 | Item đã xong ở nguồn | Cho tạo; task tạo ở `KE_HOACH`, hiện nhãn "Đã xong ở {nguồn}" `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Hai thiết bị kéo cùng item cùng lúc | Khoá duy nhất BR-04: một lệnh tạo, lệnh còn lại nhận `ALREADY_LINKED` → A3 |
| E2 | Mất mạng | Xếp hàng đợi trên máy với Idempotency-Key; đồng bộ lại không tạo trùng (G02 UC-01 E3) |
| E3 | Workspace chỉ đọc | MSG-17, không tạo |
| E4 | \[TaskFromItem\] lỗi 5xx | Gỡ card lạc quan, MSG-18 |

### UC-05 Đồng bộ hoàn thành task ra nguồn

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task có liên kết `DONG_BO`; "Hoàn thành hai chiều" bật; người dùng hoàn thành / bỏ hoàn thành task (G02 UC-03) |
| Hậu điều kiện thành công | Nguồn ở trạng thái tương ứng; liên kết `DONG_BO`; nhật ký task ghi "đã cập nhật {nguồn}" |
| Hậu điều kiện thất bại | Task vẫn xong trong app; liên kết `LOI_DONG_BO` |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Nhận sự kiện task hoàn thành (G02 \[TaskComplete\]) |
| 2 | Hệ thống | Liên kết → `CHO_DONG_BO`; xếp job `integration.push` với `pushId` (BR-10) |
| 3 | Adapter | Jira: chạy transition đã chọn; Notion: cập nhật thuộc tính trạng thái; Gmail: bỏ nhãn Hộp thư đến nếu bật (BR-07) |
| 4 | Hệ thống | Thành công → liên kết `DONG_BO`; cập nhật cache item |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Hoàn tác / bỏ hoàn thành trong 5 phút (BR-08) | Huỷ job chưa chạy; job đã chạy → đẩy trạng thái trước đó |
| A2 | "Hoàn thành hai chiều" tắt | Không đẩy; liên kết giữ `DONG_BO` |
| A3 | Issue Jira đã ở Done / trang Notion đã "xong" | Bỏ qua, `DONG_BO` |
| A4 | 429 | Xếp hàng theo BR-12 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Jira: không có transition hợp lệ từ trạng thái hiện tại | Liên kết `LOI_DONG_BO`; MSG-11 kèm "Mở trong Jira" |
| E2 | 5xx / mạng | Thử lại theo BR-13; hết 24 giờ → `LOI_DONG_BO`, MSG-11 |
| E3 | 404 / 403 | Liên kết `NGUON_KHONG_CON` (UC-06 A3) |
| E4 | Token bị từ chối | Tích hợp `CAN_KET_NOI_LAI`; job giữ trong hàng đợi, chạy lại sau khi kết nối lại |

### UC-06 Nhận thay đổi từ nguồn

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tích hợp `DA_KET_NOI`; có webhook / push hoặc tới lượt poll |
| Hậu điều kiện thành công | Cache item cập nhật; task liên kết cập nhật theo BR-06, BR-09, BR-11; thiết bị khác nhận `task.upserted` ≤ 5 giây |
| Hậu điều kiện thất bại | Cache và task giữ nguyên; thử lại ở lần poll sau |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Nhà cung cấp | Gửi webhook tới \[IntegrationWebhook\], hoặc job `integration.poll` đọc thay đổi từ lần trước |
| 2 | Hệ thống | Xác thực chữ ký webhook; bỏ sự kiện trùng (theo id sự kiện) và sự kiện dội lại (BR-10) |
| 3 | Hệ thống | Cập nhật cache item; tìm \[TaskLink\] theo externalId |
| 4 | Hệ thống | Tiêu đề đổi → áp BR-06. Trạng thái vào "xong" → áp BR-09 (EC-21) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Item xong, hai chiều bật, task đang chạy timer | Dừng timer trước rồi hoàn thành (G02 BR-08a); phát `timer.changed` |
| A2 | Item xong, hai chiều tắt | Nhãn "Đã xong ở {nguồn}" trên card, task không đổi |
| A3 | Item bị xoá / mất quyền (EC-19) | Liên kết `NGUON_KHONG_CON`; task giữ nguyên (BR-11) |
| A4 | Item mở lại ở nguồn | Task không đổi; nhật ký "{Nguồn}: mở lại item" `[giả định]` |
| A5 | Item không có task liên kết | Chỉ cập nhật cache / panel |
| A6 | Item ra khỏi phạm vi cấu hình (đổi người giao, đổi project) | Gỡ khỏi panel; task liên kết giữ nguyên, `DONG_BO` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Chữ ký webhook sai | Trả 401, bỏ qua, ghi log bảo mật |
| E2 | Webhook hết hạn / ngừng | Job `integration.webhook.renew` gia hạn; poll 15 phút vẫn chạy |
| E3 | 429 khi poll | BR-12 |

### UC-07 Ngắt kết nối và kết nối lại

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tích hợp không ở `CHUA_KET_NOI` |
| Hậu điều kiện thành công | Ngắt: `CHUA_KET_NOI`, token thu hồi và xoá, cache xoá, liên kết `DA_NGAT_LIEN_KET`. Kết nối lại: `DA_KET_NOI`, cấu hình và liên kết khôi phục |
| Hậu điều kiện thất bại | Trạng thái không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-02 → "Ngắt kết nối" |
| 2 | Hệ thống | Mở **SCR-06**: "{n} task đang liên kết với {nguồn} sẽ được giữ lại, không còn đồng bộ" |
| 3 | Người dùng | Bấm "Ngắt kết nối" |
| 4 | Hệ thống | Gọi \[IntegrationDisconnect\]: thu hồi token ở hãng, xoá token, huỷ webhook, xoá cache, liên kết → `DA_NGAT_LIEN_KET`, huỷ job đẩy đang chờ (BR-16); toast MSG-19 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Kết nối lại khi `CAN_KET_NOI_LAI` | Banner / Cài đặt "Kết nối lại" → luồng UC-01 bước 2–4; giữ cấu hình; chạy job đẩy đang chờ; không tạo task trùng |
| A2 | Kết nối lại sau khi đã ngắt, cùng tài khoản, trong 30 ngày | Liên kết khớp lại theo externalId → `DONG_BO` (BR-16) |
| A3 | Kết nối lại bằng tài khoản khác | Liên kết cũ giữ `DA_NGAT_LIEN_KET`; cấu hình về mặc định |
| A4 | Người dùng thu hồi quyền app ngay trên trang hãng | Lần gọi sau nhận 401 → `CAN_KET_NOI_LAI` |
| A5 | Xoá tài khoản (G01) | Ngắt mọi tích hợp như bước 4 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Gọi thu hồi ở hãng lỗi | Vẫn xoá token trong app, hoàn tất ngắt; ghi log để thử thu hồi lại nền |

### UC-08 Slack / Teams: chia sẻ ritual và status / DND (bản 1.2)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Slack hoặc Teams `DA_KET_NOI` |
| Hậu điều kiện thành công | Bản ritual gửi tới kênh đã chọn; hoặc status / DND đổi theo timer và được khôi phục |
| Hậu điều kiện thất bại | Ritual vẫn hoàn tất, timer vẫn chạy; báo lỗi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bước chia sẻ của Daily planning / shutdown (G08) → "Add destination" → chọn Slack / Teams → chọn kênh / cuộc trò chuyện (\[MessagingDestinations\]) |
| 2 | Người dùng | Bấm Done của ritual |
| 3 | Hệ thống | Gọi \[MessagingSend\] với nội dung bản kế hoạch (G08); nhớ đích cho lần sau (G08 share-destinations) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Lần đầu bật timer khi có Slack / Teams | Lời mời "Giảm phân tâm trên Slack / Teams khi làm việc? App có thể tự đổi status và bật DND khi bạn bắt đầu hoặc dừng timer" (G07); "Bật" → **SCR-07** lưu cài đặt |
| A2 | Timer bắt đầu (`timer.changed`) và cài đặt bật | Lưu status hiện tại; gọi \[PresenceUpdate\]: status "Đang tập trung", DND theo BR-20 |
| A3 | Timer dừng / chuyển task | Khôi phục status đã lưu nếu status hiện tại vẫn là status app đặt; tắt DND (Slack: `dnd.endSnooze`) `[giả định]` |
| A4 | Người dùng tự đổi status khi đang focus | Không khôi phục đè khi timer dừng |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Gửi tin lỗi / bot không có quyền vào kênh | Ritual vẫn hoàn tất; MSG-20 kèm "Thử lại" |
| E2 | Đổi status / DND lỗi | Timer không bị ảnh hưởng; ghi log, không báo lặp lại quá 1 lần / ngày |
| E3 | Token Slack / Teams bị từ chối | `CAN_KET_NOI_LAI` (UC-07 A1) |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Cài đặt → Tích hợp | ✓ | ✓ | SCR-01 |
| Nút + trên panel phải | ✓ | ✓ | Mở SCR-01 lọc nhà cung cấp chưa kết nối |
| Onboarding bước "chọn công cụ công việc" (G01) | ✓ | ✓ | UC-01 A1 |
| Icon nguồn trên panel phải | ✓ | ✓ | SCR-03 |
| Phím Shift+G / Shift+J / Shift+N | ✓ | ✓ (desktop) | Gmail / Jira / Notion |
| Command menu (Ctrl/Cmd+K) "Mở {nguồn}" | ✓ | ✓ (desktop) | SCR-03 |
| Banner "Kết nối lại" / thông báo (G12) | ✓ | ✓ | UC-07 A1 |
| Bước chia sẻ ritual (G08), lời mời khi bật timer (G07) | ✓ | ✓ | UC-08, bản 1.2 |

## 7. Mô tả màn hình

### SCR-01 Cài đặt → Tích hợp

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Ghi chú lịch | Text | "Lịch Google / Outlook nằm ở Cài đặt → Lịch" (G05) |
| 2 | Nhóm nhà cung cấp | Section | Email · Quản lý công việc · Nhắn tin · Khác |
| 3 | Dòng nhà cung cấp | List item | Logo, tên, trạng thái (mục 4.1), tài khoản đã kết nối |
| 4 | "Kết nối" / "Cấu hình" / "Kết nối lại" | Button | Theo trạng thái; "Sắp có" disabled cho nhà cung cấp chưa hỗ trợ |

### SCR-02 Cấu hình tích hợp

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tài khoản | Text | – | "{email / workspace / site}" |
| 2 | Phạm vi item | Multi-select / Text | Có | Jira: project hoặc JQL (sai → MSG-12); Notion: database; Gmail: nhãn (mặc định Hộp thư đến) |
| 3 | Notion: thuộc tính trạng thái, giá trị "xong", Person, Date | Dropdown | Có (khi bật hai chiều) | Thiếu trạng thái → MSG-13 |
| 4 | Jira: "Khi hoàn thành task, chuyển issue sang" | Dropdown theo project | Không | Danh sách transition vào nhóm Done |
| 5 | Hoàn thành hai chiều | Toggle | – | Mặc định bật `[giả định]` |
| 6 | Gmail: Lưu trữ thư khi hoàn thành task | Toggle | – | Mặc định bật `[giả định]` |
| 7 | Channel mặc định cho task từ nguồn này | Dropdown | Không | Trống = gợi ý G02 `[giả định]` |
| 8 | Lần đồng bộ gần nhất | Text | – | "Cập nhật lúc {giờ}"; lỗi gần nhất nếu có |
| 9 | "Ngắt kết nối" | Button nguy hiểm | – | SCR-06 |

### SCR-03 Panel tích hợp (panel phải)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Header | Toolbar | Logo + tên nguồn · ô tìm · làm mới · cấu hình (SCR-02) |
| 2 | Dòng trạng thái | Text | "Cập nhật lúc {giờ}"; MSG-06 / MSG-07 / MSG-08 khi có sự cố |
| 3 | Nhóm item | Section | Jira theo project; Notion theo database; Gmail theo ngày nhận |
| 4 | Item | Card kéo được | Tiêu đề, nguồn phụ, hạn; "Đã lên kế hoạch · {ngày}" nếu đã có task; I xem trước, G mở nguồn, A thêm vào hôm nay `[giả định]` |
| 5 | Trạng thái rỗng | Empty state | MSG-14 + "Đổi phạm vi" |
| 6 | Tải thêm | Cuộn vô hạn | Tối đa 200 item / nguồn `[giả định]` |

### SCR-04 Xem trước item

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề, nguồn, trạng thái ở nguồn | Header | Đọc trực tiếp từ nguồn (BR-14) |
| 2 | Nội dung | Text chỉ đọc | Gmail: người gửi, giờ, nội dung thư; Jira: mô tả, người giao, độ ưu tiên; Notion: thuộc tính và đoạn đầu trang `[giả định]` |
| 3 | "Thêm vào hôm nay" / "Mở trong {nguồn}" | Button | UC-04 A2 / phím G |
| 4 | Đóng | Icon | Esc |

### SCR-05 Khối nguồn trên task card và chi tiết task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Biểu tượng nguồn | Icon trên card (G02 SCR-02) | Theo trạng thái liên kết mục 4.2 |
| 2 | Dòng nguồn trong chi tiết (G02 SCR-03) | Link | "{Nguồn} · {key / tên} · {trạng thái ở nguồn}"; G mở nguồn |
| 3 | Nhãn "Nguồn không còn" | Chip xám | Hover → MSG-10 |
| 4 | Nhãn "Đã xong ở {nguồn}" | Chip | UC-06 A2; bấm → hoàn thành task |
| 5 | Cảnh báo đồng bộ | Icon + "Thử lại" | Khi `LOI_DONG_BO` (MSG-11) |

### SCR-06 Ngắt kết nối

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "{n} task đang liên kết với {nguồn} sẽ được giữ lại, không còn đồng bộ. Dữ liệu tạm của {nguồn} sẽ bị xoá" |
| 2 | "Ngắt kết nối" | Button (nguy hiểm) | \[IntegrationDisconnect\] |
| 3 | "Huỷ" | Button | Đóng |

### SCR-07 Slack / Teams: tập trung (bản 1.2)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Đổi status khi timer chạy | Toggle | – | Mặc định tắt tới khi người dùng đồng ý lời mời |
| 2 | Nội dung status | Text | Không | Mặc định "Đang tập trung"; ≤ 100 ký tự |
| 3 | Hiện tên task | Toggle | – | Mặc định tắt `[giả định]` |
| 4 | Bật DND khi timer chạy | Toggle | – | Thời lượng theo BR-20 |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[IntegrationList\] `GET /integrations` | – | Integration[] (provider, status, account, lastSyncedAt, lastError) | 5s / 1 lần |
| \[IntegrationConnect\] `GET /integrations/{provider}/connect` | provider, returnTo | Redirect URL OAuth (state, PKCE) | 5s / 1 lần |
| \[IntegrationCallback\] `GET /integrations/{provider}/callback` | code, state | Redirect về app; Integration | Đổi token 10s / 2 lần |
| \[IntegrationOptions\] `GET /integrations/{id}/options` | id | projects / databases / labels / transitions / properties | 10s / 1 lần |
| \[IntegrationUpdate\] `PATCH /integrations/{id}` | scope, twoWay, archiveOnComplete, transitionByProject, statusMapping, defaultChannelId | Integration | 5s / 2 lần |
| \[IntegrationDisconnect\] `DELETE /integrations/{id}` | id | 204, linkedTaskCount | 10s / 1 lần (thu hồi ở hãng chạy nền) |
| \[IntegrationItems\] `GET /integrations/{id}/items` | cursor, q, force | Item[], fetchedAt, stale (bool), retryAt | 5s (trả cache nếu hãng chậm) / không retry từ client |
| \[IntegrationItemPreview\] `GET /integrations/{id}/items/{externalId}` | externalId | Nội dung xem trước (không lưu) | 8s / 1 lần |
| \[TaskFromItem\] `POST /tasks/from-integration` | integrationId, externalId, startDate, position, Idempotency-Key | Task + TaskLink, hoặc 409 `ALREADY_LINKED` {taskId} | 5s / 3 lần cùng key |
| \[TaskLinkRetry\] `POST /tasks/{id}/link/retry` | id | TaskLink | 5s / 1 lần |
| \[IntegrationWebhook\] `POST /webhooks/integrations/{provider}` | Payload hãng + chữ ký | 200 trong ≤ 3s, xử lý nền | Hãng tự retry; idempotent theo id sự kiện |
| \[IntegrationActivity\] `GET /integrations/activity?date` | date | Activity[] (provider, externalId, title, action, at) | 5s / 1 lần (dùng bởi G10) |
| \[MessagingDestinations\] `GET /integrations/{id}/destinations` (1.2) | q | Channel / chat[] | 5s / 1 lần |
| \[MessagingSend\] (1.2, nội bộ khi Done ritual) | destinationId, content | messageRef | 10s / 3 lần nền |
| \[PresenceUpdate\] (1.2, nội bộ theo `timer.changed`) | status, dndMinutes / restore | ok | 5s / 2 lần |
| \[AppConfig\] | – | Cờ nhà cung cấp, BR-12, BR-13, BR-15 | Cache 1h |

Job: `integration.poll` (15 phút / tích hợp), `integration.push` (BR-07, BR-13), `integration.webhook.renew` (gia hạn trước khi hết hạn), `integration.token.refresh`, `integration.cache.purge` (hằng ngày, BR-14). Realtime: `task.upserted` (task đổi do tích hợp), `integration.changed` `[giả định]` (trạng thái kết nối, item mới).

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `OAUTH_DENIED` | MSG-02 |
| `OAUTH_STATE_INVALID` | MSG-03 |
| `INTEGRATION_SCOPE_INSUFFICIENT` | MSG-04 |
| `PROVIDER_UNAVAILABLE` (5xx hãng, khi kết nối) | MSG-05 |
| `PROVIDER_RATE_LIMITED` (429) | MSG-06 |
| `INTEGRATION_NEEDS_RECONNECT` (401 từ hãng) | MSG-07 |
| `PROVIDER_UNAVAILABLE` (khi đọc item) | MSG-08 |
| `SOURCE_NOT_FOUND` (404 / 410 / 403 item) | MSG-10 |
| `SOURCE_PUSH_FAILED` / `NO_VALID_TRANSITION` | MSG-11 |
| `VALIDATION_FAILED` · field jql | MSG-12 |
| `VALIDATION_FAILED` · field statusMapping | MSG-13 |
| `ALREADY_LINKED` (409) | MSG-15 |
| `WORKSPACE_READ_ONLY` (402) | MSG-17 |
| `MESSAGING_SEND_FAILED` | MSG-20 |
| 5xx / timeout khác | MSG-18 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | Đã kết nối {nguồn}. Mở panel bằng {phím tắt} |
| MSG-02 | Toast | Chưa kết nối {nguồn} vì quyền truy cập chưa được cấp |
| MSG-03 | Toast | Phiên kết nối đã hết hạn. Thử kết nối lại |
| MSG-04 | Dialog | {nguồn} cần đủ quyền {danh sách quyền} để hoạt động. Hãy kết nối lại và giữ các quyền này |
| MSG-05 | Toast | {nguồn} đang gặp sự cố. Thử lại sau ít phút |
| MSG-06 | Dòng trạng thái panel | Cập nhật lúc {giờ} · {nguồn} tạm giới hạn truy cập, tự làm mới lúc {giờ} |
| MSG-07 | Banner | Kết nối {nguồn} đã hết hạn. Kết nối lại để tiếp tục đồng bộ |
| MSG-08 | Dòng trạng thái panel | Cập nhật lúc {giờ} · Chưa tải được dữ liệu mới từ {nguồn} |
| MSG-09 | Dòng trạng thái panel | Đang ngoại tuyến · Dữ liệu lúc {giờ} |
| MSG-10 | Tooltip / toast | Không còn truy cập được việc này trên {nguồn} (đã xoá hoặc bạn không còn quyền). Task vẫn được giữ |
| MSG-11 | Inline chi tiết task | Chưa cập nhật được trạng thái trên {nguồn}. Thử lại · Mở trong {nguồn} |
| MSG-12 | Inline | JQL không hợp lệ: {lỗi từ Jira} |
| MSG-13 | Inline | Chọn thuộc tính trạng thái và giá trị "xong" để bật hoàn thành hai chiều |
| MSG-14 | Empty state | Không có việc nào trong phạm vi đã chọn · Đổi phạm vi |
| MSG-15 | Toast | Việc này đã có trong {ngày} · Mở task |
| MSG-16 | Toast | Đã khôi phục "{tiêu đề}" từ Thùng rác về {ngày} |
| MSG-17 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-18 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-19 | Toast | Đã ngắt kết nối {nguồn}. {n} task được giữ lại |
| MSG-20 | Toast | Chưa gửi được tới {kênh}. Thử lại |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Panel hiện cache ≤ 300 ms; làm mới từ hãng ≤ 5 giây (p95); task từ item hiện ≤ 100 ms sau khi thả (lạc quan); đồng bộ hoàn thành p95 ≤ 1 phút (webhook), ≤ 15 phút (poll) |
| Offline | Panel hiện cache trên máy; tạo task từ item cache xếp hàng đợi, đồng bộ lại không trùng (Idempotency-Key + BR-04); kết nối / cấu hình cần mạng |
| Độ tin cậy | Lỗi tích hợp không chặn thao tác task (BR-17); webhook idempotent theo id sự kiện; job đẩy idempotent theo `pushId`; cảnh báo vận hành khi tỉ lệ lỗi một hãng > 2% / 10 phút hoặc 429 tăng đột biến |
| Bảo mật | Token AES-256-GCM, khoá trong KMS, không trả về client (BR-03); OAuth `state` + PKCE; xác thực chữ ký webhook; scope tối thiểu (PRD mục 5.1); ngắt kết nối thu hồi token (BR-16) |
| Quyền riêng tư | Chỉ lưu metadata, giữ 7 ngày, xem trước không lưu (BR-14); Privacy "Tích hợp" (G12); xuất dữ liệu (G01) gồm danh sách liên kết; Nghị định 13/2023/NĐ-CP, GDPR (cần pháp chế xác nhận) |
| Log / audit | \[ActivityLog\] tác nhân `integration` cho mọi thay đổi task do nguồn; log kết nối / ngắt / kết nối lại; log hệ thống không chứa tiêu đề item, nội dung thư, token |
| Tracking | Sự kiện: `integration_connect_started`, `integration_connected` (provider), `integration_connect_failed` (lý do), `integration_panel_opened`, `integration_item_previewed`, `task_created_from_item` (provider, đích: cột / lịch), `integration_duplicate_blocked`, `integration_push_succeeded` / `_failed`, `integration_source_completed_task`, `integration_source_missing`, `integration_rate_limited`, `integration_reconnected`, `integration_disconnected`, `slack_dnd_enabled` (1.2) |
| Accessibility | Mọi kéo item có cách bàn phím / menu tương đương (UC-04 A2); icon nguồn và trạng thái có nhãn đọc màn hình; trạng thái lỗi không chỉ dựa vào màu; tương phản WCAG 2.1 AA sáng / tối |
