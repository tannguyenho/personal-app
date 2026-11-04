> **Mã:** PLN-PRD-G05 · **Trạng thái:** đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g05-lich-timebox.md

# PRD Lịch & timebox (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md), gồm vòng 7: instance lưu trữ `skipped` xử lý timebox như "Đưa vào backlog" (D6); bản 1.1 vẫn một người dùng, nhiều thành viên từ 1.2 trở đi (Q47). Quy tắc dùng chung (ngày làm việc QC-01, lịch làm việc và khung giờ channel QC-02, đổi ngày task QC-05, bản ghi thời gian QC-07, chế độ chỉ đọc QC-09, quyền theo gói QC-10) xem [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); PRD này chỉ tham chiếu, không định nghĩa lại. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (badge giờ timebox màu cam "10:55" trên card; chi tiết task "Thursday, Nov 5 · 10:55–11:55 · 1 hr" kèm icon lịch; kéo block sang ngày khác đổi ngày bắt đầu; block thời gian thực tế "2:01 – 2:02" trên lịch; panel "Calendars", nút zoom 1x); chỗ khác Sunsama có chủ đích được ghi rõ.

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

- Nền tảng (Q45, ADR-0005): bản 1.0 là app Windows; web và macOS từ 1.1; iOS / Android từ 1.2, dùng cùng đặc tả. Cách app Windows mở trang OAuth của Google / Microsoft và nhận kết quả, cách nhận webhook lịch: tech chốt — `docs/tech/`.
- Kết nối Google Calendar (OAuth) và Outlook qua Microsoft Graph; nhiều tài khoản lịch trên một người dùng. Số tối đa đọc từ bảng quyền theo gói (QC-10), không viết cứng; giá trị 5 `[giả định]`.
- Chọn lịch hiển thị, màu lịch, lịch mặc định ghi timebox, lịch ghi timebox theo channel.
- Hiển thị sự kiện trong Calendar views (G04) và panel Calendar (Shift+C); bộ lọc "Calendars"; zoom.
- Timebox: kéo task vào lịch, kéo timebox đổi giờ / ngày, kéo cạnh đổi thời lượng, gỡ timebox (Ctrl+X). Một task có thể có nhiều timebox (C19). Chỉ tạo timebox trong 90 ngày tới (C18).
- **Timebox liên kết sự kiện** (B8): timebox của task tạo từ một sự kiện có sẵn trên lịch ngoài (G08); đi theo sự kiện gốc, không bao giờ tạo sự kiện mới.
- Auto-schedule: X vào khe trống đầu tiên, Shift+X không chia nhỏ — phát hành bản 1.1 theo lộ trình chung, đặc tả sẵn trong tài liệu này. Nút "Dời sang khe trống" trong cảnh báo xung đột cũng thuộc 1.1, ẩn ở 1.0 (Q17).
- **Lập lịch cứng cho task lặp** — bản **1.1** (Q7): G05 sở hữu, tự tạo timebox cho instance tại giờ `approxTime` của series. Bản 1.0 chỉ hiện `approxTime` trên card (G03).
- Đồng bộ 2 chiều: ghi timebox ra lịch ngoài; nhận sửa / xoá / dời từ lịch ngoài theo một quy tắc xung đột duy nhất (Q15); cảnh báo họp đè timebox.
- Cờ **"Lệch ngày"** khi timebox rơi khác ngày dự định sau khi đổi timezone (Q4, QC-01).
- Hiển thị bản ghi thời gian thực tế (từ G07) trên lịch, chỉ bản ghi có giờ thật (B11, QC-07).
- Trạng thái kết nối, kết nối lại, ngắt kết nối.
- Chế độ chỉ đọc theo QC-09 — bản 1.1.

## 3.2 Ngoài phạm vi

- Apple Calendar / CalDAV → bản 1.1.
- Tạo / sửa sự kiện thường (không gắn task), mời người tham dự, trả lời lời mời → sau 1.1 `[giả định]`.
- Ghi chú cuộc họp → không có trong lộ trình (C36). Tạo task từ sự kiện trong Daily planning → G08 (G05 cung cấp timebox liên kết sự kiện).
- Chế độ xem, điều hướng ngày, projection, cảnh báo khối lượng → G04.
- Timer và dữ liệu thời gian thực tế → G07 (QC-07). Các đường đổi ngày task (rollover, phím D, backlog, shutdown, hoàn thành, xoá) → bảng QC-05 do G06 sở hữu; G05 chỉ thực hiện phần timebox và sự kiện ngoài theo bảng đó. Lập lịch cứng cho task lặp do **G05** sở hữu (1.1); G03 chỉ lưu `approxTime`.
- Tích hợp công cụ công việc (Gmail, Jira, Notion…) → G11.
- Privacy "Lịch" (người khác trong workspace xem lịch của mình) → bản sau (1.2 trở đi), cùng các tính năng nhiều thành viên ([`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md), Q35, Q37, Q47). Khuyến nghị khi làm: người khác chỉ thấy bận / rảnh và timebox, không thấy chi tiết sự kiện lịch ngoài (tiêu đề, mô tả, người tham dự). Bản 1 chỉ có một người dùng nên G05 không có quyền xem lịch của người khác.
- Cài đặt **khung giờ channel** → G02 (QC-02 mục 5). G05 chỉ đọc khung này cho auto-schedule (1.1).

# 4. Nguyên tắc sản phẩm

## 4.1 Mỗi bên giữ phần của mình

Lịch ngoài là nguồn sự thật cho sự kiện; app là nguồn sự thật cho task. App chỉ ghi và sửa sự kiện do chính app tạo (có mã task đánh dấu). Timebox liên kết sự kiện đi theo sự kiện gốc, app không sửa sự kiện đó (B8).

Khi cả app và lịch ngoài cùng sửa một timebox, áp **một quy tắc duy nhất** (Q15):

| **Thay đổi** | **Kết quả** |
|---|---|
| Giờ / ngày | Lần sửa muộn hơn thắng |
| Sự kiện bị xoá ở lịch ngoài | Gỡ timebox; task giữ nguyên ngày dự định |
| Tiêu đề | App thắng; ghi đè ra lịch ngoài ở lần đồng bộ kế tiếp |
| Sự kiện bị chuyển sang lịch khác | Cập nhật lịch đích của timebox |

## 4.2 Không bao giờ dời việc của người khác

Xung đột chỉ dời task nội bộ. Cuộc họp mới đè lên timebox thì app cảnh báo và gợi ý, không tự dời gì.

## 4.3 Không trùng, không mất

Mọi lần ghi ra lịch ngoài đều idempotent theo mã task. Lịch đích được ghi cố định trên timebox từ lần đẩy đầu (B9). Mất kết nối thì timebox chờ (kể cả timebox chờ xoá), kết nối lại thì đẩy tiếp, không tạo bản sao. Ngắt kết nối thì tách liên kết, sự kiện mồ côi trên lịch ngoài bị bỏ qua (B9).

## 4.5 Ngày của timebox là ngày làm việc

Timebox thuộc ngày làm việc của thời điểm bắt đầu (QC-01). Đổi timezone không đổi ngày dự định; timebox giữ thời điểm tuyệt đối, lệch thì chỉ gắn cờ "Lệch ngày", không tự sửa (Q4).

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
| Sự kiện cả ngày | `start.date` | `isAllDay = true` | Không chặn auto-schedule, không trừ sức chứa (EC-17). Timebox bị đổi thành cả ngày ở lịch ngoài thì gỡ (C18) |
| Sự kiện chặn thời gian (C18) | `transparency = opaque`; trả lời `accepted` / `tentative` / chưa trả lời | `showAs` = `busy` / `tentative` / `oof` `[giả định]` | Bận và tentative chặn; đã từ chối, free, cả ngày không chặn |
| Giới hạn tốc độ | 429 / 403 rateLimitExceeded → backoff | 429 + `Retry-After` → backoff | Hàng đợi theo tài khoản |

- Các giá trị (cửa sổ đồng bộ, chu kỳ gia hạn, poll, thời gian thử lại) là **cấu hình hệ thống**, không cố định trong code.
- Timebox: thời lượng mặc định khi kéo 30 phút; làm tròn 5 phút; mỗi timebox 5 phút – 24 giờ `[giả định]`; chỉ tạo trong 90 ngày tới (C18); khoảng đệm auto-schedule 0; thử lại ghi lịch tối đa 24 giờ.
- Mặc định cài đặt Timebox: hiện actual trên lịch bật; ẩn planned của task xong; nhắc theo lịch mặc định; bận; riêng tư theo lịch; tự dời khi xung đột bật (giữ Shift để tắt); tự dời khi xong sớm (nghĩa: rút ngắn timebox, B10); lập lịch cứng cho task lặp tắt `[giả định]` (1.1).
- Lập lịch cứng (1.1): tạo timebox cho instance trong 7 ngày tới `[giả định]`.
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
| 7 | Làm việc | Bật timer (G07); khối thực tế hiện trên lịch | So được kế hoạch và thực tế |

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

AC02: Kết nối lại → đồng bộ lại toàn bộ có bước so sánh; timebox chờ đẩy và timebox chờ xoá đều được đẩy ra lịch, không tạo sự kiện trùng (B9).

AC03: Ngắt kết nối hỏi xác nhận, có lựa chọn "Xoá các sự kiện timebox app đã tạo" (mặc định tắt) `[giả định]`; thu hồi token; timebox trong app giữ nguyên, tách liên kết với sự kiện ngoài (B9).

AC04: Sau khi ngắt kết nối, sự kiện mồ côi (do app tạo trước đó) bị bỏ qua: sửa / xoá sự kiện đó không làm đổi hay gỡ timebox trong app (B9).

## UC2. Chọn lịch hiển thị và lịch ghi

### US2.1 Chọn lịch hiển thị

AC01: Mỗi tài khoản liệt kê các lịch; bật / tắt hiển thị, đổi màu từng lịch.

AC02: Lịch ẩn không hiện sự kiện và không tính vào sức chứa ngày (G04).

AC03: Panel "Calendars" trong Calendar views cho bật / tắt nhanh từng lịch.

### US2.2 Chọn lịch ghi timebox

User Story: Là người nhiều vai, tôi muốn timebox của mỗi channel ghi vào đúng lịch, để lịch khách hàng nào chỉ chứa việc của khách hàng đó.

AC01: Có một lịch mặc định ghi timebox; chỉ chọn được lịch có quyền ghi.

AC02: Mỗi channel có thể chọn lịch ghi riêng; không chọn thì dùng lịch mặc định. Lịch đích được ghi cố định trên timebox từ lần đẩy đầu; đổi lịch ghi của channel / mặc định chỉ áp cho timebox chưa đẩy lần nào (B9).

AC03: Tắt ghi lịch ("Không ghi ra lịch ngoài") → timebox chỉ tồn tại trong app.

## UC3. Timebox task

### US3.1 Kéo task vào lịch

User Story: Là người dùng, tôi muốn kéo task vào một khung giờ, để giữ thời gian thật cho việc đó.

AC01: Kéo task từ cột ngày / backlog vào ô (ngày D, giờ H) trên Calendar views hoặc panel Calendar → ngày dự định = ngày làm việc của thời điểm bắt đầu timebox (QC-01, Q2); timebox từ H dài bằng thời lượng kế hoạch, làm tròn 5 phút. Ví dụ mốc 04:00: thả vào 02:00 sáng 05/11 → ngày dự định 04/11.

AC02: Task chưa có thời lượng → timebox 30 phút.

AC03: Card hiện badge giờ màu cam (ví dụ "10:55"); chi tiết task hiện "Thứ Năm, 5/11 · 10:55–11:55 · 1 giờ" kèm icon lịch.

AC04: Thả timebox đè lên timebox task khác → task bị đè tự dời xuống (khi bật "Tự dời khi xung đột"); giữ Shift khi thả để không dời. Sự kiện ngoài không bao giờ bị dời.

AC05: Kéo task đã có timebox vào lịch → thêm một timebox mới, timebox cũ giữ nguyên (C19).

AC06: Thả vào ngày cách hôm nay > 90 ngày → không tạo, báo giới hạn 90 ngày (C18).

AC07: Thả task chưa xong vào ngày làm việc đã qua → không tạo, báo không đặt task chưa xong vào ngày đã qua (QC-05).

### US3.2 Dời và đổi thời lượng

AC01: Kéo timebox sang giờ / ngày khác → đổi giờ; sang ngày khác thì ngày dự định = ngày làm việc của giờ bắt đầu mới (QC-01; đã kiểm chứng: timebox 10:55–11:55 kéo sang ngày khác).

AC02: Kéo cạnh dưới timebox đổi thời lượng → cập nhật thời lượng kế hoạch của task.

AC03: Mỗi thay đổi cập nhật sự kiện trên lịch ngoài ≤ 10 giây.

### US3.3 Gỡ timebox

AC01: Ctrl+X hoặc nút "Gỡ khỏi lịch" trong chi tiết task → xoá timebox, xoá sự kiện ngoài; task về projection (G04); có toast Hoàn tác.

AC02: Xoá task (G02) → theo dòng "Xoá" của QC-05: timebox tương lai bị gỡ và xoá sự kiện ngoài; timebox quá khứ chỉ gỡ liên kết, giữ sự kiện ngoài.

### US3.4 Timebox khi task đổi ngày ở nhóm khác

User Story: Là người dùng, tôi muốn timebox và sự kiện trên lịch công ty xử lý giống nhau dù tôi dời task bằng cách nào, để không mất lịch sử và không có sự kiện "ma".

AC01: Mọi đường đổi ngày task (phím D, kéo sang ngày khác, shutdown "Ngày mai", rollover, đưa vào backlog, hoàn thành, xoá, AI dời ngày) xử lý timebox và sự kiện ngoài đúng theo bảng QC-05.

AC02: Rollover gặp timebox quá khứ (kết thúc trước thời điểm rollover) → giữ sự kiện trên lịch ngoài làm lịch sử, chỉ gỡ liên kết trong app (Q6).

AC03: Hoàn tác của các đường do người dùng hoặc AI thực hiện khôi phục cả liên kết timebox; sự kiện ngoài đã bị xoá thì được tạo lại với giờ cũ (QC-05). Rollover và tự lưu trữ (`stale`) là job hệ thống, **không có Hoàn tác**, chỉ ghi nhật ký; người dùng tự kéo task về nếu cần (Q41).

### US3.5 Lệch ngày sau khi đổi timezone

AC01: Đổi timezone → ngày dự định của task giữ nguyên, timebox giữ thời điểm tuyệt đối (Q4, QC-01).

AC02: Timebox rơi vào ngày làm việc khác ngày dự định → card và timebox hiện cờ "Lệch ngày"; hệ thống không tự sửa.

AC03: Cờ "Lệch ngày" có hai lựa chọn: "Dời task sang {ngày của timebox}" và "Dời timebox về {ngày dự định}" (giữ giờ địa phương). Chọn một trong hai thì cờ mất.

AC04: Chỉ hiện banner đổi timezone MSG-23 của G01; G05 không có banner riêng.

### US3.6 Timebox liên kết sự kiện

User Story: Là người lịch dày, tôi muốn kéo cuộc họp thành task mà không sinh thêm sự kiện trùng trên lịch công ty.

AC01: Task tạo từ sự kiện lịch (Daily planning, G08) có timebox liên kết sự kiện, giờ bằng giờ sự kiện; app không tạo sự kiện mới (B8).

AC02: Sự kiện gốc đổi giờ / ngày → timebox đi theo. Sự kiện gốc bị xoá → gỡ timebox, task giữ nguyên.

AC03: Timebox liên kết sự kiện không kéo / đổi thời lượng được trong app; tooltip hướng dẫn sửa trên lịch ngoài.

AC04: Không gắn cờ xung đột với chính sự kiện gốc hay sự kiện khác; thời gian trống của ngày chỉ trừ một lần (B8).

## UC4. Auto-schedule

### US4.1 Tự xếp task vào khe trống

User Story: Là người dùng thành thạo, tôi muốn nhấn X là task tự vào khe trống gần nhất, để không phải tìm giờ bằng mắt.

AC01: X trên task → đặt vào khe trống đầu tiên trong **lịch làm việc của task** (QC-02 mục 6: khung giờ channel của task nếu channel có đặt khung, ngược lại lịch chung), từ thời điểm hiện tại (hôm nay) hoặc giờ bắt đầu của khung đó (ngày tương lai), cộng khoảng đệm. Không xếp task ra ngoài khung channel của nó, kể cả khi lịch chung còn trống (Q38a).

AC02: Không có khe đủ dài → X chia task thành nhiều timebox (tối đa 3, mỗi timebox ≥ 15 phút) `[giả định]`; Shift+X chỉ nhận khe đủ dài, không chia.

AC03: Sự kiện bận và tentative chặn khe; sự kiện đã từ chối, free, cả ngày không chặn (C18, EC-17). Timebox liên kết sự kiện chỉ tính một lần cùng sự kiện gốc (B8).

AC05: Lịch chung do G01 sở hữu, khung giờ channel do G02 sở hữu và cài trong màn cài đặt channel (QC-02 mục 5–6); G05 chỉ đọc, không có màn cài giờ riêng. Ngày dự định của task không có trong lịch làm việc của task (ví dụ task `#Công ty` khung T2–T6 vào Thứ Bảy) → không có khe, xử lý như AC04.

AC04: Hết khe trong ngày → báo "Hôm nay hết khe trống", task giữ nguyên (EC-18).

## UC5. Ghi timebox ra lịch ngoài

### US5.1 Sự kiện đúng và kín đáo

AC01: Sự kiện có tiêu đề task, giờ bắt đầu / kết thúc kèm múi giờ, bận, riêng tư theo lịch, nhắc theo lịch, mô tả là link về task; không có notes.

AC02: Task thuộc channel riêng tư → sự kiện luôn Private.

AC03: Hoàn thành (bật "Tự dời khi xong sớm") → chỉ rút ngắn timebox có giờ hoàn thành nằm trong khoảng giờ của nó: timebox kết thúc tại giờ hoàn thành (B10). Hoàn thành trước giờ bắt đầu hoặc sau giờ kết thúc → giữ nguyên timebox. "Ẩn planned của task xong" chỉ ẩn trong app, không xoá sự kiện ngoài.

AC05: Timebox liên kết sự kiện không bao giờ được ghi ra lịch ngoài (B8).

AC04: Ghi lỗi → timebox hiện biểu tượng lỗi đồng bộ; hệ thống thử lại tới 24 giờ.

## UC6. Nhận thay đổi từ lịch ngoài

### US6.1 Xoá và dời trên lịch ngoài

AC01: Xoá sự kiện timebox trên Google / Outlook → app gỡ timebox, task giữ nguyên ngày dự định và về projection, nhật ký ghi tác nhân lịch (EC-13, Q15).

AC02: Dời sự kiện timebox trên lịch ngoài → app cập nhật giờ; sang ngày khác thì ngày dự định = ngày làm việc của giờ bắt đầu mới (EC-14). App và lịch ngoài cùng sửa giờ → lần sửa muộn hơn thắng (Q15).

AC03: Đổi tiêu đề sự kiện trên lịch ngoài → không đổi tiêu đề task; app ghi đè tiêu đề ra lịch ngoài ở lần đồng bộ kế tiếp (Q15).

AC04: Chuyển sự kiện timebox sang lịch khác (cùng tài khoản) → app cập nhật lịch đích của timebox, không coi là xoá (Q15).

AC05: Sự kiện timebox bị đổi thành sự kiện cả ngày → gỡ timebox, thông báo trong app (C18).

### US6.2 Họp đè timebox

User Story: Là người lịch dày, tôi muốn biết khi có cuộc họp mới chồng lên khối làm việc, để tự quyết dời việc nào.

AC01: Sự kiện bận hoặc tentative mới chồng khung timebox → card và timebox hiện cảnh báo xung đột; không tự dời (EC-16, C18).

AC02: Bản 1.0: cảnh báo chỉ có "Giữ nguyên" và "Mở lịch" (Q17). Bản 1.1 thêm "Dời sang khe trống" (chạy như Shift+X).

AC03: Cuộc họp được dời / xoá khỏi khung → cảnh báo tự mất.

## UC7. Hiển thị thời gian thực tế trên lịch

### US7.1 Khối thực tế

AC01: Khi bật "Hiện actual trên lịch", mỗi bản ghi thời gian có giờ thật (timer, nhập theo khoảng giờ, tự dừng, ritual) hiện thành khối thực tế trên lịch app, ví dụ "2:01 – 2:02". Bản ghi nhập theo thời lượng không vẽ lên lịch (B11, QC-07).

AC02: Khối thực tế chỉ hiện trong app, không ghi ra lịch ngoài `[giả định]`.

## UC8. Lập lịch cứng cho task lặp (1.1)

### US8.1 Tự tạo timebox cho instance

User Story: Là người có việc lặp cố định giờ (standup 9:30), tôi muốn instance tự có timebox trên lịch, để đồng nghiệp thấy giờ bận mà tôi không phải kéo mỗi ngày.

AC01: Cài đặt Timebox có toggle "Lập lịch cứng cho task lặp" (mặc định tắt `[giả định]`). Bật → mọi series có `approxTime` được lập lịch cứng (Q7).

AC02: Hệ thống tạo timebox cho instance `KE_HOACH` có ngày dự định trong 7 ngày tới `[giả định]`, bắt đầu tại `approxTime` theo ngày làm việc của instance, dài bằng thời lượng kế hoạch (trống → 30 phút). Instance ngoài cửa sổ được tạo dần khi cửa sổ trượt tới.

AC03: Timebox lập lịch cứng là timebox thường: ghi ra lịch ngoài, có cờ xung đột nếu chồng sự kiện bận, không tự dời khi xung đột với sự kiện ngoài.

AC04: Người dùng sửa giờ hoặc gỡ timebox của một instance → instance đó thành "sửa riêng" (cờ `customized`, theo G03 BR-07), hệ thống không tạo lại hay ghi đè (đã chốt, Q44).

AC05: Đổi `approxTime` hoặc quy tắc lặp của series → timebox của instance chưa sửa riêng được dời theo giờ mới; instance bị G03 xoá khi đổi quy tắc thì timebox xử lý như dòng "Xoá" của QC-05; instance đã tách khỏi series (Q26) giữ timebox.

AC06: Dừng series hoặc tắt toggle → ngừng tạo timebox mới; timebox đã có giữ nguyên, trừ instance bị G03 xoá (theo QC-05).

AC07: Instance bị dời (phím D, kéo, rollover, shutdown, backlog, lưu trữ do trùng series) → timebox theo bảng QC-05. Instance tự lưu trữ `stale` xử lý timebox như "Đưa vào backlog" (đã chốt, Q42, QC-05); instance lưu trữ `skipped` (trùng series, QC-06) cũng như "Đưa vào backlog" (đã chốt, D6, QC-05).

AC08: Không tạo timebox cho ngày quá 90 ngày (C18) hoặc khi workspace ở chế độ chỉ đọc (QC-09).

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
| Giới hạn tốc độ nhà cung cấp | Người dùng kéo nhiều timebox liên tục | Gộp ghi theo task trong 2 giây `[giả định]`; backoff theo `Retry-After` |
| Múi giờ, giờ mùa hè (EC-02, EC-03) | Hiển thị sai giờ, timebox lệch 1 giờ; task và timebox lệch ngày sau khi bay | Lưu UTC + IANA; hiển thị theo timezone người dùng; đổi timezone theo QC-01 mục 4 (cờ "Lệch ngày"); bộ test DST và bảng ví dụ QC-01 |
| Timebox qua mốc đầu ngày (EC-04) | Timebox nằm trên 2 ngày | Thuộc ngày làm việc của thời điểm bắt đầu (QC-01 mục 5); hiển thị tách 2 đoạn |
| Lập lịch cứng (1.1) | Sinh hàng loạt sự kiện trên Google / Outlook | Mặc định tắt; cửa sổ 7 ngày `[giả định]`; idempotent theo `appBlockId` |
| Người khác sửa sự kiện của app (lịch chia sẻ) | Thay đổi không do người dùng | Xử lý như thay đổi từ lịch ngoài, nhật ký ghi tác nhân lịch |
| Lịch công ty chặn app bên thứ ba | Admin Google Workspace / Entra không cho cấp quyền | Thông báo rõ, hướng dẫn gửi admin |

# 10. Câu hỏi mở

- Ai nộp hồ sơ xác minh Google OAuth, khi nào; có ra mắt 1.0 khi chưa xác minh không?
- Đã chốt 04/11/2026: auto-schedule (X / Shift+X) giữ ở 1.1; nút "Dời sang khe trống" ẩn ở 1.0, cảnh báo xung đột chỉ có "Giữ nguyên" và "Mở lịch" (Q17).
- Đã chốt 04/11/2026: một task được nhiều timebox; kéo task đã có timebox thì thêm timebox mới (C19).
- Số tài khoản lịch tối đa: Đã chốt 04/11/2026 là đọc từ bảng quyền theo gói của G12 (QC-10); con số 5 vẫn `[giả định]`. Còn mở: bản 1.0 (miễn phí, không giới hạn) có áp giới hạn kỹ thuật này không?
- Ngắt kết nối: Đã chốt 04/11/2026 là tách liên kết, bỏ qua sự kiện mồ côi (B9). Còn mở: có cho tuỳ chọn xoá các sự kiện app đã tạo không (hiện `[giả định]` có, mặc định tắt)?
- Đã chốt 04/11/2026: "Tự dời khi xong sớm" = rút ngắn timebox, chỉ khi thời điểm hoàn thành nằm trong khoảng giờ của nó (B10).
- Khối thời gian thực tế có ghi ra lịch ngoài không? (hiện `[giả định]` không)
- Đã chốt 04/11/2026: đổi tiêu đề trên lịch ngoài không đổi task; app thắng và ghi đè ở lần đồng bộ kế tiếp (Q15).
- Đã chốt 04/11/2026: lập lịch cứng cho task lặp do G05 sở hữu, phát hành 1.1 (Q7). Còn mở: số ngày tạo trước (đề xuất 7), có cho bật / tắt riêng từng series không.
- Đã chốt 04/11/2026: sửa giờ (hoặc gỡ) timebox của instance lặp lập lịch cứng tính là sửa riêng (`customized`, G03 BR-07); hệ thống không tạo lại, không ghi đè (Q44).
- Đã chốt 04/11/2026: instance tự lưu trữ `stale` xử lý timebox như "Đưa vào backlog" (Q42, QC-05); instance lưu trữ `skipped` (trùng series) cũng xử lý như "Đưa vào backlog" (D6, QC-05).
- Đã chốt 04/11/2026: auto-schedule (1.1) chỉ xếp task vào khung giờ channel của task, channel không có khung thì dùng lịch chung; G02 sở hữu cài đặt khung giờ channel (Q38a, QC-02 mục 5–6).
- Đã chốt 04/11/2026: rollover và tự lưu trữ không có Hoàn tác; Hoàn tác khôi phục liên kết timebox chỉ áp cho đường do người dùng / AI thực hiện (Q41, QC-05).
- Đã chốt 04/11/2026: Privacy "Lịch" để bản sau; khuyến nghị người khác chỉ thấy bận / rảnh và timebox, không thấy chi tiết sự kiện ngoài (Q37, `docs/02-tinh-nang-ban-sau.md`).
- Sự kiện timebox bị đổi thành sự kiện lặp hoặc dài > 24 giờ ở lịch ngoài thì xử lý thế nào?
- Cờ "Lệch ngày" có hiện cho task đã hoàn thành không (ví dụ hoàn thành sớm task ngày mai: task về hôm nay theo QC-05, timebox giữ ở ngày mai)?
