> **Mã:** PLN-SRS-G05 · **Trạng thái:** đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g05-lich-timebox.md

# UC-G05 - Lịch & timebox (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md), gồm vòng 7 (instance lưu trữ `skipped` xử lý timebox như "Đưa vào backlog" — D6; thông báo Windows và trong app từ 1.0 — D12; nhiều thành viên từ 1.2 trở đi — Q47). SRS này chỉ mô tả kết nối Google Calendar / Outlook, chọn lịch, timebox (tạo, dời, đổi thời lượng, gỡ, auto-schedule, timebox liên kết sự kiện, lập lịch cứng cho task lặp — 1.1), ghi timebox ra lịch ngoài và nhận thay đổi từ lịch ngoài. Quy tắc dùng chung tham chiếu [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md): ngày làm việc (QC-01), lịch làm việc và khung giờ channel (QC-02), đổi ngày task (QC-05), bản ghi thời gian (QC-07), đồng bộ nhiều thiết bị (QC-08), chế độ chỉ đọc (QC-09, 1.1), quyền theo gói (QC-10, 1.1). Trong tài liệu này "block" chỉ cách vẽ timebox trên lưới lịch; thuật ngữ nghiệp vụ là timebox. Chế độ xem, điều hướng ngày, projection, cảnh báo khối lượng (G04), nội dung task (G02), lặp lại (G03), rollover (G06), timer và thời gian thực tế (G07), thông báo (G12) đặc tả ở SRS riêng của từng nhóm. Apple / CalDAV thuộc bản 1.1. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng thấy sự kiện lịch cạnh task, đặt task vào khung giờ (timebox) bằng kéo thả hoặc phím, timebox tự có trên Google / Outlook và thay đổi trên lịch ngoài phản ánh về app, không trùng, không mất |
| Actor | Người dùng đã đăng nhập · Hệ thống (job đồng bộ, đẩy timebox) · Google Calendar API · Microsoft Graph |
| Phạm vi | Kết nối / kết nối lại / ngắt tài khoản lịch, chọn lịch hiển thị và lịch ghi (mặc định, theo channel), hiển thị sự kiện, timebox, timebox liên kết sự kiện, cờ "Lệch ngày", auto-schedule (X, Shift+X — 1.1), lập lịch cứng cho task lặp (1.1), gỡ timebox (Ctrl+X), đồng bộ 2 chiều, cảnh báo xung đột, khối thời gian thực tế |
| Ngoài phạm vi | Apple / CalDAV (1.1), tạo / sửa sự kiện thường, mời người tham dự, ghi chú cuộc họp, chế độ xem lịch và điều hướng (G04), timer (G07), cài đặt khung giờ channel (G02, QC-02 mục 5). Privacy "Lịch" (người khác xem lịch của mình) → bản sau, 1.2 trở đi ([`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md), Q37, Q47): khuyến nghị người khác chỉ thấy bận / rảnh và timebox, không thấy chi tiết sự kiện lịch ngoài; bản 1 chỉ có một người dùng (Q35) |
| Nền tảng | App Windows ở 1.0; web, macOS từ 1.1; iOS / Android từ 1.2, dùng cùng đặc tả (Q45, ADR-0005). Luồng OAuth trên app Windows, nơi nhận webhook lịch và cache sự kiện trên máy: tech chốt — `docs/tech/` |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Kết nối Google Calendar hoặc Outlook | Thấy cuộc họp cạnh danh sách việc |
| US-02 | Người dùng | Chọn lịch nào hiện, lịch nào nhận timebox (theo channel) | Lịch công việc và cá nhân không lẫn nhau |
| US-03 | Người dùng | Kéo task vào một khung giờ, kéo để dời / đổi thời lượng | Giữ thời gian thật cho việc |
| US-04 | Người dùng thành thạo | Nhấn X để task tự vào khe trống, Ctrl+X để gỡ | Không phải tìm giờ bằng mắt |
| US-05 | Người cần khối làm việc dài | Timebox hiện trên lịch công ty ở trạng thái bận | Không bị đặt họp chồng |
| US-06 | Người dùng | Sửa / xoá sự kiện trên Google / Outlook thì app tự cập nhật | Không có task "ma" |
| US-07 | Người lịch dày | Được cảnh báo khi họp mới đè khối làm việc | Tự quyết dời việc nào |
| US-08 | Người dùng | Mất kết nối rồi kết nối lại không bị trùng sự kiện | Lịch sạch, tin được |
| US-09 | Người dùng (1.1) | Instance của task lặp tự có timebox tại giờ cố định | Không phải kéo mỗi ngày |
| US-10 | Người lịch dày | Kéo cuộc họp thành task mà không tạo sự kiện trùng | Lịch công ty không bị nhân đôi |
| US-11 | Người hay đi công tác | Task không nhảy cột khi đổi timezone, được báo khi timebox lệch ngày | Tự quyết dời task hay dời timebox |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Tài khoản lịch.** Nhà cung cấp `google` / `microsoft` (1.0). Số tài khoản tối đa / người dùng đọc từ bảng quyền theo gói (QC-10), không viết cứng; giá trị 5 `[giả định]`. Khoá duy nhất (userId, provider, providerAccountId): kết nối lại cùng tài khoản chỉ cập nhật token |
| BR-02 | **Quyền.** Google: `calendar.events`, `calendar.calendarlist.readonly`. Microsoft: `Calendars.ReadWrite`, `offline_access`. Thiếu quyền ghi → không tạo kết nối. Token mã hoá AES-256-GCM, không trả về client |
| BR-03 | **Đồng bộ đọc.** Cửa sổ 30 ngày trước → 90 ngày sau. Gia tăng bằng `syncToken` (Google) / delta (Graph); Google 410 hoặc delta token hết hiệu lực → đồng bộ lại toàn bộ cửa sổ, có **bước so sánh**: timebox `DA_DONG_BO` trong cửa sổ mà sự kiện (tìm theo `appBlockId`) không còn trong kết quả → xử lý như sự kiện bị xoá (BR-13) (B9). Webhook (`events.watch` / subscription) gia hạn mỗi 6 giờ; webhook lỗi / hết hạn → poll 15 phút. Phát `calendar.changed` khi có thay đổi |
| BR-04 | **Lịch đích của timebox.** Trước lần đẩy đầu: lịch ghi của channel task → lịch mặc định của người dùng → không có thì timebox `CHI_TRONG_APP`. Lần đẩy đầu thành công ghi **cố định** `calendarId` lên timebox; sau đó đổi channel, đổi lịch ghi của channel hay lịch mặc định không đổi lịch đích (B9). Lịch đích chỉ đổi khi sự kiện bị chuyển sang lịch khác ở lịch ngoài (BR-13). Chỉ lịch có quyền ghi được chọn làm lịch ghi |
| BR-05 | **Tạo timebox.** Thả task vào ô (ngày D, giờ H) → timebox [H, H + planned], H làm tròn 5 phút; planned trống → 30 phút; `startDate` = `workday(startsAt)` (QC-01, Q2). Mỗi timebox 5 phút – 24 giờ `[giả định]`. Chỉ tạo khi `startsAt` ≤ hôm nay + 90 ngày (C18). Task chưa xong không được đặt vào ngày làm việc < hôm nay (QC-05). Một task có nhiều timebox; kéo task đã có timebox vào lịch → thêm timebox mới, không thay timebox cũ (C19). Kéo / X là thao tác của người dùng, ghi nhật ký tác nhân `user` |
| BR-06 | **Sửa timebox.** Kéo timebox sang giờ / ngày khác: `startDate` = `workday(startsAt)` của timebox vừa kéo (QC-01, Q2). Kéo cạnh dưới đổi thời lượng (bước 5 phút): planned = tổng thời lượng các block của task. Ctrl+X / "Gỡ khỏi lịch": xoá mọi block, task về projection (G04) |
| BR-07 | **Tự dời khi xung đột** (cài đặt, mặc định bật): block mới / vừa dời đè block của task khác → task bị đè dời xuống ngay sau block mới, dây chuyền trong cùng ngày, chỉ dời vào thời gian không có sự kiện bận. Giữ Shift khi thả → `skipReschedule = true`, cho phép chồng. Không bao giờ dời sự kiện ngoài |
| BR-08 | **Auto-schedule (1.1).** X: tìm khe trống đầu tiên trong **lịch làm việc của task** (QC-02 mục 6: khung giờ channel của task nếu channel có đặt khung, ngược lại lịch chung; Q38a) ở ngày `startDate` (task backlog / không ngày: hôm nay), từ max(giờ bắt đầu của khung đó trong ngày, hiện tại làm tròn lên 5 phút); không bao giờ xếp ra ngoài khung đó, kể cả khi lịch chung còn trống; ngày không có trong lịch làm việc của task → không có khe (MSG-11). Lịch chung do G01 sở hữu, khung giờ channel do G02 sở hữu (QC-02 mục 1, 5); G05 chỉ đọc; khe trống = không có sự kiện chặn (BR-09) và timebox khác; timebox liên kết sự kiện chỉ tính một lần cùng sự kiện gốc (BR-21); cộng khoảng đệm (mặc định 0). Không khe nào đủ dài → chia tối đa 3 block, mỗi block ≥ 15 phút `[giả định]`. Shift+X: chỉ nhận khe đủ dài, không chia. Không có khe → MSG-11, không đổi gì (EC-18). Phát hành ở bản 1.1 theo lộ trình chung; đặc tả sẵn để làm tiếp |
| BR-09 | **Phân loại sự kiện ngoài** (C18, EC-17). **Chặn** (chặn auto-schedule, gây `XUNG_DOT`, trừ sức chứa G04): sự kiện bận (`opaque` / `showAs = busy`), tentative (người dùng trả lời "có thể" hoặc `showAs = tentative`). **Không chặn:** sự kiện người dùng đã từ chối, free (`transparent` / `showAs = free`), sự kiện cả ngày, sự kiện ở lịch đang ẩn. Sự kiện lặp: phân loại từng lần xuất hiện như trên. Out of office (`showAs = oof` / `eventType = outOfOffice`) coi là bận `[giả định]` |
| BR-10 | **Ghi ra lịch ngoài** theo bảng map mục 8. Không ghi notes, người tham dự, màu. Channel riêng tư → luôn Private; khác → riêng tư theo mặc định của lịch. Bận / rảnh, nhắc theo cài đặt Timebox |
| BR-11 | **Idempotent.** Mỗi timebox có `blockId`; sự kiện ngoài mang `appTaskId` + `appBlockId`. Trước khi tạo, \[TimeboxPush\] tìm sự kiện có cùng `appBlockId` trên **mọi lịch** của tài khoản lịch đích; có → cập nhật (và cập nhật `calendarId` nếu sự kiện nằm ở lịch khác), không tạo mới. Không bao giờ có 2 sự kiện cùng `appBlockId` |
| BR-12 | **Thử lại.** \[TimeboxPush\] lỗi → `sync_status = error`, thử lại backoff 1, 5, 15, 60 phút rồi mỗi giờ `[giả định]`, tối đa 24 giờ; quá 24 giờ dừng, chờ người dùng "Thử lại". 429 → theo `Retry-After`. Ghi nhiều lần cùng block trong 2 giây gộp thành 1 `[giả định]` |
| BR-13 | **Quy tắc xung đột hai phía (lịch ↔ app)** (Q15). Là quy tắc duy nhất, áp cho UC-04 E2, UC-06 A3, UC-07, UC-08 A4. Chỉ áp cho sự kiện có `appTaskId` của người dùng và timebox còn liên kết (không áp cho timebox `CHI_TRONG_APP`, BR-19). (a) **Giờ / ngày:** lần sửa muộn hơn thắng; "muộn hơn" so `updated` của sự kiện (giờ server nhà cung cấp) với thời điểm server app nhận lần sửa trong app (QC-08) `[giả định cách so]`. Lịch ngoài thắng → cập nhật timebox, `startDate` theo BR-06; task 1 timebox thì planned = thời lượng mới (EC-14). App thắng → ghi đè ra lịch ngoài. (b) **Xoá ở lịch ngoài:** gỡ timebox; task giữ nguyên ngày dự định; task hết timebox thì về projection (EC-13). (c) **Tiêu đề:** app thắng; xếp `timebox.push` ghi đè tiêu đề ở lần đồng bộ kế tiếp. Mô tả / riêng tư / bận: như tiêu đề `[giả định]`. (d) **Chuyển sang lịch khác** (cùng tài khoản): cập nhật `calendarId` của timebox, không coi là xoá. (e) **Đổi thành sự kiện cả ngày:** gỡ timebox như (b), thông báo MSG-31 (C18). Ghi nhật ký tác nhân `integration` ("Google Calendar đã dời timebox…") |
| BR-14 | **Xung đột với sự kiện ngoài** (EC-16): sự kiện chặn (BR-09; không mang `appTaskId`, ở lịch hiển thị) chồng một phần hoặc toàn bộ timebox → timebox có cờ `XUNG_DOT`; không tự dời. Bản 1.0: gợi ý "Giữ nguyên" và "Mở lịch". Bản 1.1 thêm "Dời sang khe trống" = Shift+X cho task đó (Q17). Hết chồng → bỏ cờ. Timebox liên kết sự kiện không gắn và không gây `XUNG_DOT` (BR-21) |
| BR-15 | **Thời gian.** Lưu `startsAt` / `endsAt` UTC + IANA timezone. Ngày của timebox = `workday(startsAt)` (QC-01). **Đổi timezone** (EC-02): theo QC-01 mục 3–4 — `startDate` giữ nguyên, timebox giữ thời điểm tuyệt đối, hiển thị theo timezone mới; không tính lại `startDate`; lệch ngày thì gắn cờ theo BR-22 (Q4). Giờ mùa hè (EC-03): thời lượng tính bằng phút thực; giờ không tồn tại → dời tới giờ hợp lệ kế tiếp (MSG-24); giờ lặp lại → lần xuất hiện đầu. **Vắt qua mốc đầu ngày** (EC-04): thuộc ngày làm việc của `startsAt` (QC-01 mục 5); ghi 1 sự kiện liền; lịch app vẽ 2 đoạn |
| BR-16 | **Mất kết nối** (EC-15): refresh token lỗi / bị thu hồi / mất quyền → tài khoản `CAN_KET_NOI_LAI`; timebox mới / sửa trên lịch đó → `CHO_DONG_BO`; timebox bị gỡ → `CHO_XOA`; dừng poll / webhook. Kết nối lại → đồng bộ lại toàn bộ cửa sổ (có bước so sánh, BR-03) rồi đẩy mọi timebox `CHO_DONG_BO`, `LOI` **và `CHO_XOA`** theo BR-11 (B9) |
| BR-17 | **Hoàn thành / xoá task** — theo QC-05. Hoàn thành: giữ timebox và sự kiện. Bật "Tự dời khi xong sớm" → chỉ rút ngắn timebox có `startsAt` < thời điểm hoàn thành < `endsAt`: `endsAt` = thời điểm hoàn thành làm tròn lên 5 phút, cập nhật sự kiện; timebox khác của task giữ nguyên (B10). Bỏ hoàn thành trong cùng ngày làm việc → trả `endsAt` cũ (QC-03 mục 4). "Ẩn planned của task xong" chỉ ẩn timebox trong app. Xoá task (G02): timebox tương lai → gỡ, xoá sự kiện ngoài; timebox quá khứ → gỡ liên kết, giữ sự kiện ngoài. Hoàn tác trên toast khôi phục liên kết (BR-25); khôi phục từ Thùng rác không tạo lại timebox |
| BR-18 | **Khối thực tế.** Bật "Hiện actual trên lịch" → mỗi bản ghi thời gian (QC-07) **có giờ thật** vẽ một khối thực tế trên lịch app (ví dụ "2:01 – 2:02"): nguồn `timer`, `auto_closed`, `ritual`, và `manual` nhập theo khoảng giờ. Bản ghi `manual` nhập theo thời lượng không vẽ (B11). Không ghi ra lịch ngoài `[giả định]` |
| BR-19 | **Ngắt kết nối.** Thu hồi token ở nhà cung cấp, huỷ webhook, xoá cache sự kiện. Tuỳ chọn "Xoá các sự kiện timebox app đã tạo" (mặc định tắt) `[giả định]`. Timebox trong app giữ nguyên, chuyển `CHI_TRONG_APP` và **tách liên kết**: xoá `externalEventId`, `calendarId` (B9). Sự kiện mồ côi (mang `appBlockId` của timebox đã tách) bị bỏ qua ở mọi lần đồng bộ sau, kể cả khi kết nối lại cùng tài khoản: không áp BR-13, không liên kết lại |
| BR-20 | **Chế độ chỉ đọc (1.1)** — theo QC-09. API ghi timebox trả 402 `WORKSPACE_READ_ONLY` (MSG-20). Đồng bộ lịch chỉ cập nhật cache hiển thị sự kiện ngoài: không áp BR-13 lên timebox / task, không đẩy timebox ra, không chạy lập lịch cứng (BR-23). Bản 1.0 không có chế độ chỉ đọc |
| BR-21 | **Timebox liên kết sự kiện** (B8). Timebox có `kind = event_linked` và `linkedEventId`, `calendarId` của sự kiện gốc; tạo qua \[TimeboxLink\] khi task được tạo từ sự kiện lịch (G08 bước Thêm task) `[giả định: chỉ đường này ở 1.0]`. Quy tắc: (a) không bao giờ đẩy ra lịch ngoài, không có `sync_status` đẩy; (b) đi theo sự kiện gốc: sự kiện đổi giờ / ngày → timebox và `startDate` cập nhật như BR-13 (a) phía lịch ngoài; sự kiện bị xoá / đổi thành cả ngày → gỡ timebox, task giữ nguyên; (c) không kéo, đổi thời lượng hay auto-schedule được trong app (MSG-26); Ctrl+X chỉ gỡ liên kết, không đụng sự kiện ngoài; (d) không gắn và không gây `XUNG_DOT`, không bị BR-07 dời; (e) thời gian trống chỉ trừ một lần (sự kiện gốc), G04 không cộng timebox này vào phần đã chiếm; (f) xoá / rollover / đổi ngày task: chỉ gỡ liên kết, không xoá sự kiện ngoài. Các timebox thường khác của cùng task (C19) theo quy tắc thường |
| BR-22 | **Cờ "Lệch ngày"** (Q4, QC-01 mục 4). Task `KE_HOACH` có timebox mà `workday(startsAt)` ≠ `startDate` → gắn cờ `LECH_NGAY` trên task và timebox; hệ thống không tự sửa. Tính lại cờ khi đổi timezone, khi đổi `startDate`, khi timebox đổi giờ. Người dùng chọn: "Dời task sang {ngày timebox}" (đổi `startDate`, như kéo sang ngày khác của QC-05) hoặc "Dời timebox về {ngày dự định}" (giữ giờ địa phương, đổi ngày). Chỉ banner MSG-23 của G01 thông báo đổi timezone; G05 không có banner riêng |
| BR-23 | **Lập lịch cứng cho task lặp (1.1)** (Q7). G05 sở hữu; G03 chỉ lưu `approxTime`. (a) **Bật:** toggle "Lập lịch cứng cho task lặp" trong cài đặt Timebox (SCR-01 #7), mặc định tắt `[giả định]`; áp cho mọi series có `approxTime`. (b) **Cửa sổ:** job `timebox.hardschedule` tạo timebox cho instance `KE_HOACH` có `startDate` trong [hôm nay, hôm nay + N ngày], N = 7 `[giả định]`; chạy khi G03 sinh instance, khi bật toggle, và mỗi ngày tại mốc đầu ngày. (c) **Giờ:** `startsAt` = `approxTime` theo giờ địa phương thuộc ngày làm việc `startDate` (`approxTime` < mốc đầu ngày → ngày lịch kế tiếp, QC-01); thời lượng = planned, trống → 30 phút; lịch đích theo BR-04. (d) **Idempotent:** mỗi instance tối đa một timebox lập lịch cứng (`hardScheduled = true`); đã có thì bỏ qua. (e) **Sửa riêng (Q44):** người dùng kéo / đổi giờ / đổi thời lượng / gỡ timebox lập lịch cứng → đó là sửa riêng instance theo G03 BR-07: instance đặt cờ `customized = true`, không bao giờ tạo lại hay ghi đè timebox. G05 không dùng cờ riêng. (f) **Sửa series** (đổi `approxTime`, planned, quy tắc): timebox của instance chưa sửa riêng (`customized = false`, G03 BR-07) trong cửa sổ được cập nhật theo giờ mới; instance G03 xoá khi đổi quy tắc → timebox xử lý như dòng "Xoá" của QC-05; instance đã tách khỏi series (Q26) giữ timebox. (g) **Dừng series / tắt toggle:** ngừng tạo mới; timebox đã có giữ nguyên, trừ instance bị G03 xoá. (h) **Instance đổi ngày** (D, kéo, rollover, shutdown, backlog) → QC-05; instance tự lưu trữ `stale` → như "Đưa vào backlog" (Q42, QC-05); instance lưu trữ `skipped` (QC-06) → như "Đưa vào backlog" (D6, QC-05). (i) Xung đột với sự kiện chặn → vẫn tạo, gắn `XUNG_DOT` (BR-14), không tự dời `[giả định]`. (j) Không tạo xa hơn 90 ngày (C18); dừng khi chỉ đọc (BR-20). Tác nhân nhật ký `system` |
| BR-24 | **Sự kiện chưa phân loại** (sự kiện timebox bị đổi thành sự kiện lặp, hoặc dài > 24 giờ ở lịch ngoài): áp BR-13 (a) theo lần xuất hiện đầu / theo giờ mới, không chặn bởi giới hạn 24 giờ `[giả định — chờ PO]` |
| BR-25 | **Đổi ngày task từ nhóm khác** — theo bảng QC-05 (G06 sở hữu); G05 chỉ thực hiện cột "Timebox" và "Sự kiện trên lịch ngoài". Timebox "quá khứ" = `endsAt` ≤ thời điểm thao tác (rollover: thời điểm rollover). Rollover: timebox quá khứ → gỡ khỏi task (không qua `CHO_XOA`, không gọi DELETE), **giữ** sự kiện ngoài làm lịch sử; timebox tương lai giữ (Q6). Tự lưu trữ `stale` (G06) và lưu trữ do trùng series `skipped` (QC-06; rollover, phím D, shutdown "Ngày mai"): như "Đưa vào backlog" (Q42, D6). Hoàn tác của các đường do người dùng hoặc AI thực hiện → khôi phục timebox và liên kết lại đúng `externalEventId` cũ; sự kiện ngoài đã bị xoá thì tạo lại với giờ cũ (QC-05). **Rollover và tự lưu trữ không có Hoàn tác** (job hệ thống, chỉ ghi nhật ký tác nhân `system`; Q41, QC-05). Timer không bị G05 dừng trong mọi trường hợp |

## 4. Trạng thái

### 4.1. Trạng thái kết nối lịch (tài khoản)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHUA_KET_NOI` | Người dùng chưa có tài khoản lịch nào | SCR-01 chỉ có nút kết nối; G04 gắn cờ "chưa tính lịch" |
| `DANG_UY_QUYEN` | Đã mở OAuth, chưa nhận callback | Nút kết nối hiện "Đang chờ xác nhận…"; hết 10 phút `[giả định]` → về trạng thái trước |
| `DANG_DONG_BO` | Đồng bộ lần đầu hoặc đồng bộ lại toàn bộ (BR-03, BR-16) | "Đang đồng bộ…" + vòng xoay; sự kiện hiện dần |
| `HOAT_DONG` (`status = active`) | Token hợp lệ, webhook còn hạn | "Đã kết nối" + thời điểm đồng bộ gần nhất |
| `DONG_BO_CHAM` | Token hợp lệ, webhook lỗi / hết hạn, đang poll 15 phút | Chấm vàng, tooltip "Cập nhật mỗi 15 phút" |
| `CAN_KET_NOI_LAI` (`status = needs_reconnect`) | Refresh token lỗi / bị thu hồi / mất quyền | Chấm đỏ, banner MSG-06 (SCR-09), nút "Kết nối lại" |
| `DA_NGAT` | Người dùng ngắt kết nối (BR-19) | Không còn trong danh sách |

Chuyển: `CHUA_KET_NOI` → `DANG_UY_QUYEN` → `DANG_DONG_BO` → `HOAT_DONG` (UC-01) · `HOAT_DONG` ⇄ `DONG_BO_CHAM` (job gia hạn webhook) · `HOAT_DONG` / `DONG_BO_CHAM` → `CAN_KET_NOI_LAI` (lỗi token) → `DANG_DONG_BO` (UC-08) · mọi trạng thái → `DA_NGAT` (UC-08).

### 4.2. sync_status của block timebox

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHO_DONG_BO` (`pending`) | Block vừa tạo / sửa, chưa ghi xong; hoặc tài khoản `CAN_KET_NOI_LAI` | Block có viền nét đứt, icon đồng hồ, tooltip MSG-07 |
| `DA_DONG_BO` (`synced`) | Sự kiện ngoài khớp block (có `externalEventId`, etag mới nhất) | Block bình thường, icon lịch |
| `LOI` (`error`) | Ghi lỗi, đang thử lại ≤ 24 giờ hoặc đã dừng thử lại | Icon cảnh báo, tooltip MSG-08 có "Thử ngay" |
| `CHO_XOA` (`pending_delete`) | Block đã gỡ trong app, sự kiện ngoài chưa xoá xong | Block ẩn khỏi lịch app; job tiếp tục xoá |
| `CHI_TRONG_APP` (`local`) | Không có lịch ghi (BR-04) hoặc tài khoản đã ngắt (đã tách liên kết, BR-19) | Block bình thường, không icon lịch |
| `LIEN_KET_SU_KIEN` (`linked`) | Timebox liên kết sự kiện (BR-21); không đẩy | Block viền liền màu lịch gốc, icon liên kết; không kéo được |

Cờ phụ đi kèm mọi trạng thái trên: `XUNG_DOT` (BR-14; không áp cho `LIEN_KET_SU_KIEN`) — viền cam + icon cảnh báo trên block và card; `LECH_NGAY` (BR-22) — nhãn "Lệch ngày" trên block và card. Chuyển: tạo / sửa → `CHO_DONG_BO` → `DA_DONG_BO` hoặc `LOI` (UC-06) · `LOI` → `CHO_DONG_BO` (thử lại) · gỡ → `CHO_XOA` → xoá bản ghi (kể cả khi tài khoản `CAN_KET_NOI_LAI`: giữ `CHO_XOA` tới khi kết nối lại, BR-16) · ngắt kết nối → `CHI_TRONG_APP` · tạo từ sự kiện → `LIEN_KET_SU_KIEN` → xoá bản ghi khi sự kiện gốc bị xoá / gỡ liên kết.

## 5. Use Case

### UC-01 Kết nối tài khoản lịch

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; số tài khoản lịch < giới hạn (BR-01) |
| Hậu điều kiện thành công | Tài khoản `HOAT_DONG`; danh sách lịch lưu; lịch chính bật hiển thị và làm lịch ghi mặc định (nếu chưa có); sự kiện trong cửa sổ đã tải; webhook đăng ký |
| Hậu điều kiện thất bại | Không có tài khoản mới; trạng thái cũ giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Lịch (**SCR-01**) hoặc bước kết nối lịch của onboarding (G01) → "Kết nối Google Calendar" / "Kết nối Outlook" |
| 2 | Hệ thống | Gọi \[CalendarConnect\], chuyển sang trang OAuth với scope BR-02, `state` chống CSRF |
| 3 | Người dùng | Chọn tài khoản, đồng ý quyền |
| 4 | Hệ thống | \[CalendarCallback\]: đổi code lấy token, kiểm tra đủ scope, lưu tài khoản (BR-01), đọc danh sách lịch |
| 5 | Hệ thống | Tài khoản `DANG_DONG_BO`; job `calendar.sync` tải sự kiện cửa sổ 30 / 90 ngày; đăng ký webhook |
| 6 | Hệ thống | Mở **SCR-02** của tài khoản; toast MSG-01; xong đồng bộ → `HOAT_DONG`, phát `calendar.changed` (G04 tính lại sức chứa) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tài khoản đã kết nối trước đó (cùng providerAccountId) | Cập nhật token, giữ cấu hình lịch; MSG-04 |
| A2 | Đã có lịch ghi mặc định | Không đổi lịch mặc định; lịch của tài khoản mới chỉ bật hiển thị |
| A3 | Đăng ký webhook lỗi | Tài khoản `DONG_BO_CHAM`, poll 15 phút; job `calendar.watch.renew` thử lại |
| A4 | Lịch có > 2.500 sự kiện trong cửa sổ `[giả định]` | Tải theo trang; hiện sự kiện tuần đang xem trước |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Người dùng huỷ ở màn OAuth | Về SCR-01, MSG-03 |
| E2 | Bỏ tích quyền ghi / thiếu scope | Không lưu tài khoản, thu hồi token vừa cấp, MSG-02 |
| E3 | Admin tổ chức chặn app | MSG-22 |
| E4 | Đã đủ số tài khoản tối đa (BR-01) | Nút kết nối disabled, MSG-05 |
| E5 | `state` sai / callback quá 10 phút | Huỷ, MSG-21 |

### UC-02 Chọn lịch hiển thị và lịch ghi timebox

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có ≥ 1 tài khoản `HOAT_DONG` / `DONG_BO_CHAM` |
| Hậu điều kiện thành công | Cấu hình hiển thị / màu / lịch ghi được lưu; lịch app và sức chứa ngày (G04) cập nhật |
| Hậu điều kiện thất bại | Cấu hình cũ giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Mở **SCR-02** của tài khoản |
| 2 | Người dùng | Bật / tắt "Hiển thị" và chọn màu từng lịch; chọn "Lịch ghi timebox mặc định" |
| 3 | Hệ thống | Kiểm tra lịch ghi có quyền ghi (BR-04); gọi \[CalendarUpdate\]; vẽ lại lịch; phát `calendar.changed` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Chọn lịch ghi theo channel | **SCR-03**: mỗi channel chọn một lịch ghi hoặc "Theo mặc định" → \[ChannelCalendarUpdate\] |
| A2 | Bật / tắt nhanh trong panel "Calendars" của Calendar views (G04) | Chỉ đổi hiển thị, như bước 3 |
| A3 | Chọn "Không ghi ra lịch ngoài" làm mặc định | Block mới `CHI_TRONG_APP`; block cũ giữ sự kiện đã có `[giả định]` |
| A4 | Đổi lịch ghi khi đã có timebox tương lai | Chỉ áp cho timebox chưa đẩy lần nào; timebox đã đẩy giữ lịch đích cố định (BR-04, B9) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Chọn lịch chỉ đọc làm lịch ghi | Lựa chọn disabled, tooltip MSG-15 |
| E2 | \[CalendarUpdate\] lỗi | Trả về giá trị cũ, MSG-21 |

### UC-03 Timebox task bằng kéo thả

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task chưa xoá; đang ở Calendar views / Today view / panel Calendar (G04); workspace không chỉ đọc |
| Hậu điều kiện thành công | Task có block theo BR-05; `startDate` cập nhật; block `CHO_DONG_BO` rồi `DA_DONG_BO`; card có badge giờ cam; G04 tính lại projection |
| Hậu điều kiện thất bại | Task không có block mới; vị trí cũ giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Kéo task từ cột ngày / danh sách / backlog vào lưới giờ (**SCR-04**) |
| 2 | Hệ thống | Hiện bóng block dài = planned (hoặc 30 phút), bám bước 5 phút, hiện giờ bắt đầu – kết thúc |
| 3 | Người dùng | Thả ở ô (D, H) |
| 4 | Hệ thống | Áp BR-05; áp BR-07 nếu đè block khác; vẽ block **SCR-05** ngay (lạc quan); gọi \[TimeboxSet\] |
| 5 | Hệ thống | Server lưu block `CHO_DONG_BO`, xếp job `timebox.push` (UC-06); toast MSG-09 có "Hoàn tác" |
| 6 | Hệ thống | Card hiện badge giờ cam; chi tiết task hiện "Thứ Năm, 5/11 · 10:55–11:55 · 1 giờ" (**SCR-06**) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Block đè block task khác, tự dời bật | Dời task bị đè (BR-07); toast MSG-23 có "Hoàn tác" |
| A2 | Giữ Shift khi thả | `skipReschedule = true`, cho phép chồng |
| A3 | Thả chồng lên sự kiện ngoài bận | Cho phép; block có cờ `XUNG_DOT` (BR-14) |
| A4 | Task backlog / ngày khác | `startDate` = `workday(startsAt)` (BR-05); task rời backlog (G06) / cột cũ (G04); số ngày bị hoãn reset như "kéo sang ngày khác" (QC-05) |
| A5 | Timebox vắt qua mốc đầu ngày (EC-04) | Thuộc ngày làm việc của `startsAt` (QC-01 mục 5); vẽ 2 đoạn trên 2 cột; ghi 1 sự kiện liền |
| A6 | Ô thả rơi vào giờ không tồn tại do đổi giờ (EC-03) | Dời tới giờ hợp lệ kế tiếp, tooltip MSG-24 |
| A7 | Không có lịch ghi (BR-04) | Block `CHI_TRONG_APP`, không xếp job |
| A8 | Tài khoản lịch ghi `CAN_KET_NOI_LAI` (EC-15) | Block `CHO_DONG_BO`, chờ UC-08 |
| A9 | Kéo bằng bàn phím | Chọn task → lệnh "Timebox…" trong command menu (G04) → chọn ngày, giờ `[giả định]` |
| A10 | Task đã có ≥ 1 timebox | Thêm timebox mới, timebox cũ giữ nguyên (BR-05, C19); `startDate` theo BR-06; badge "+n" (SCR-06) |
| A11 | Thả vào giờ trước mốc đầu ngày (ví dụ 02:00 sáng 05/11, mốc 04:00) | `startDate` = 04/11 (QC-01); vẽ ở cột ngày lịch 05/11 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Thời lượng ngoài 5 phút – 24 giờ | MSG-17, không tạo |
| E2 | Task đã bị xoá ở thiết bị khác | Gỡ bóng block, MSG-25 |
| E3 | Mất mạng | Lưu trên máy, \[SyncBatch\] gửi lại với cùng Idempotency-Key |
| E4 | Workspace chỉ đọc (1.1, QC-09) | Không cho thả, MSG-20 |
| E5 | \[TimeboxSet\] lỗi 5xx | Gỡ block, trả task về chỗ cũ, MSG-21 |
| E6 | `startsAt` > hôm nay + 90 ngày (C18) | Không tạo, MSG-27 |
| E7 | Task chưa xong, `workday(startsAt)` < hôm nay (QC-05) | Không tạo, trả task về chỗ cũ, MSG-28 |

### UC-04 Dời, đổi thời lượng, gỡ timebox

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task có ≥ 1 block; workspace không chỉ đọc |
| Hậu điều kiện thành công | Block / planned / `startDate` cập nhật theo BR-06; sự kiện ngoài cập nhật hoặc xoá ≤ 10 giây |
| Hậu điều kiện thất bại | Block giữ như cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Kéo thân block sang giờ / ngày khác, hoặc kéo cạnh dưới |
| 2 | Hệ thống | Áp BR-06, BR-07; vẽ ngay; gọi \[TimeboxSet\] với `blockId` |
| 3 | Hệ thống | Block `CHO_DONG_BO`; job `timebox.push` cập nhật sự kiện |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Ctrl+X / "Gỡ khỏi lịch" (SCR-06) | \[TimeboxDelete\]; timebox `CHO_XOA`; task về projection; toast MSG-10 có "Hoàn tác" (tạo lại timebox với giờ cũ). Timebox liên kết sự kiện: chỉ gỡ liên kết, không xoá sự kiện ngoài (BR-21) |
| A2 | Kéo timebox sang ngày khác | `startDate` = `workday(startsAt)` (BR-06; đã kiểm chứng 10:55–11:55 sang ngày khác); G04 tính lại 2 ngày; ngày quá khứ với task chưa xong → MSG-28 (QC-05) |
| A3 | Task có nhiều timebox, kéo cạnh một timebox | planned = tổng các timebox (BR-06) |
| A4 | Hoàn thành task khi thời điểm hoàn thành nằm trong [`startsAt`, `endsAt`], bật "Tự dời khi xong sớm" | Rút `endsAt` theo BR-17 (B10); ngoài khoảng → giữ nguyên |
| A5 | Xoá task (G02) | Theo dòng "Xoá" của QC-05 (BR-17): timebox tương lai `CHO_XOA` như A1; timebox quá khứ gỡ liên kết, giữ sự kiện. Timebox liên kết sự kiện: chỉ gỡ liên kết, không xoá sự kiện ngoài (BR-21 f) |
| A6 | Rollover task có timebox quá khứ (G06) | Theo dòng "Rollover" của QC-05 (Q6, BR-25): gỡ timebox khỏi task, **giữ** sự kiện trên lịch ngoài, không gọi DELETE; timebox tương lai giữ; tác nhân `system`. Rollover không có Hoàn tác (Q41, QC-05 ghi chú "Hoàn tác"); người dùng tự kéo task về nếu cần. Tự lưu trữ `stale` (G06) và instance lưu trữ `skipped` trong lượt rollover xử lý như A8, cũng không có Hoàn tác (Q41, Q42, D6) |
| A7 | Phím D, kéo task sang ngày khác, shutdown "Ngày mai", AI dời ngày (G04, G08, G10) | Theo QC-05: timebox giữ giờ, dời sang ngày mới, cập nhật sự kiện ngoài; timer không dừng. Timebox liên kết sự kiện: chỉ gỡ liên kết, không dời sự kiện ngoài (BR-21 f). Instance lặp bị phím D / shutdown "Ngày mai" chuyển `LUU_TRU` `skipped` (QC-06 mục 2) → xử lý như A8 (D6), có Hoàn tác theo A9 |
| A8 | Đưa task vào backlog (G04, G06) | Theo QC-05: timebox tương lai `CHO_XOA` (xoá sự kiện ngoài); timebox quá khứ gỡ liên kết, giữ sự kiện. Timebox liên kết sự kiện: chỉ gỡ liên kết, không xoá sự kiện ngoài (BR-21 f) |
| A9 | Hoàn tác các đường A5, A7, A8 (do người dùng hoặc AI thực hiện) | Khôi phục timebox, liên kết lại `externalEventId` cũ; sự kiện ngoài đã bị xoá → tạo lại với giờ cũ (BR-25). Không áp cho A6 (rollover) và tự lưu trữ: hai đường này không có Hoàn tác (Q41, QC-05) |
| A10 | Kéo / đổi thời lượng timebox liên kết sự kiện | Không cho; tooltip MSG-26 (BR-21) |
| A11 | Timebox lập lịch cứng (1.1) bị kéo / đổi giờ / đổi thời lượng / gỡ | Áp như luồng chính / A1; instance thành "sửa riêng" `customized = true` (BR-23 e, Q44) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Thời lượng mới < 5 phút | Dừng ở 5 phút, MSG-17 |
| E2 | Timebox vừa đổi giờ từ lịch ngoài / thiết bị khác | Áp BR-13 (a): lần sửa server nhận sau thắng, không báo lỗi; vẽ theo kết quả server. Timebox đã bị gỡ (sự kiện bị xoá, BR-13 b) → `TIMEBOX_REMOVED`, vẽ theo server, MSG-29 |
| E3 | \[TimeboxSet\] / \[TimeboxDelete\] lỗi | Trả block về như cũ, MSG-21 |

### UC-05 Auto-schedule (X / Shift+X) — bản 1.1

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task chưa xong, chưa có block; phím tắt bật, không focus ô nhập (G04); workspace không chỉ đọc |
| Hậu điều kiện thành công | Task có 1–3 block theo BR-08; block `CHO_DONG_BO`; toast Hoàn tác |
| Hậu điều kiện thất bại | Task không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Chọn / hover task, nhấn X (hoặc lệnh "Tự xếp lịch" trong command menu G04) |
| 2 | Hệ thống | Gọi \[TimeboxAuto\] `split = true` |
| 3 | Hệ thống (server) | Lấy lịch làm việc của task (QC-02 mục 5–6: khung giờ channel của task do G02 cài, không có thì lịch chung của G01), sự kiện bận (BR-09), block khác; tìm khe theo BR-08, chỉ trong khung đó |
| 4 | Hệ thống | Tạo block, xếp `timebox.push`; client vẽ block, badge cam; toast MSG-09 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Shift+X | `split = false`; chỉ nhận khe đủ dài |
| A2 | Không khe đủ dài, X | Chia ≤ 3 block, mỗi block ≥ 15 phút; toast MSG-09 ghi "{n} khối" |
| A3 | Sự kiện không chặn trong lịch làm việc của task (BR-09: đã từ chối, free, cả ngày — EC-17) | Bỏ qua, coi như trống. Sự kiện tentative chặn như sự kiện bận |
| A4 | Task không có planned | Dùng 30 phút |
| A5 | Gọi từ "Dời sang khe trống" của cảnh báo xung đột (UC-07 A3; chỉ từ 1.1, Q17) | Như A1, thay thế timebox cũ |
| A6 | Gõ nhanh ≥ 4 ký tự / 1 giây (EC-25) | Phím X bị khoá 1 giây (G04), không chạy |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Không còn khe trong ngày (EC-18) | MSG-11, task giữ nguyên |
| E2 | Shift+X không có khe đủ dài nhưng X chia được | MSG-12 |
| E3 | \[TimeboxAuto\] lỗi / timeout | MSG-21 |

### UC-06 Đẩy timebox ra lịch ngoài (job `timebox.push`)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Timebox `CHO_DONG_BO` / `CHO_XOA` / `LOI` (đang thử lại), không phải `LIEN_KET_SU_KIEN` (BR-21); tài khoản lịch ghi `HOAT_DONG` / `DONG_BO_CHAM`; workspace không chỉ đọc (1.1, BR-20) |
| Hậu điều kiện thành công | Sự kiện ngoài khớp block; block `DA_DONG_BO` (hoặc bản ghi bị xoá với `CHO_XOA`); lưu `externalEventId`, etag |
| Hậu điều kiện thất bại | Block `LOI`, lịch thử lại theo BR-12 |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Lấy block; gộp các thay đổi cùng block trong 2 giây (BR-12) |
| 2 | Hệ thống | Có `externalEventId` → PATCH sự kiện trên `calendarId` đã cố định; chưa có → tìm sự kiện có `appBlockId` trên mọi lịch của tài khoản (BR-11); có thì PATCH, không thì tạo mới trên lịch đích theo BR-04 |
| 3 | Hệ thống | Dựng nội dung theo bảng map mục 8 |
| 4 | Hệ thống | Lưu `externalEventId`, etag; lần đẩy đầu lưu cố định `calendarId` (BR-04); `DA_DONG_BO`; phát `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Block `CHO_XOA` | DELETE sự kiện; 404 / 410 coi như đã xoá; xoá bản ghi block |
| A2 | Lịch ghi của channel / mặc định đổi, hoặc task đổi channel, sau khi đã có sự kiện | Giữ sự kiện ở lịch đích đã cố định (BR-04, UC-02 A4); không tạo sự kiện ở lịch mới |
| A3 | Sự kiện bị sửa ngoài app (etag khác) trước khi PATCH | Đọc bản mới, áp BR-13: giờ → bên sửa muộn hơn thắng; tiêu đề → app thắng, ghi đè; sự kiện đã chuyển lịch → cập nhật `calendarId` rồi PATCH ở lịch mới |
| A4 | Timebox `CHO_XOA` được tạo khi tài khoản `CAN_KET_NOI_LAI` | Giữ `CHO_XOA`, đẩy ở UC-08 bước 4 (BR-16, B9) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | 429 / rate limit | Theo `Retry-After`; block giữ `CHO_DONG_BO`; người dùng thao tác lúc đó thấy MSG-16 |
| E2 | 5xx / timeout | `LOI`, thử lại BR-12; quá 24 giờ dừng, tooltip MSG-08 "Thử ngay" |
| E3 | 401 / `invalid_grant` (EC-15) | Tài khoản `CAN_KET_NOI_LAI` (BR-16); block giữ `CHO_DONG_BO` |
| E4 | 403 lịch mất quyền ghi | Block `LOI`; SCR-02 đánh dấu lịch chỉ đọc, MSG-15 |
| E5 | Sự kiện đã bị xoá ngoài (404 khi PATCH) | Trước hết tìm `appBlockId` trên mọi lịch của tài khoản (BR-11): thấy → sự kiện đã chuyển lịch, áp BR-13 (d); không thấy → áp BR-13 (b) gỡ timebox (EC-13), không tạo lại |

### UC-07 Nhận thay đổi từ lịch ngoài

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tài khoản `HOAT_DONG` / `DONG_BO_CHAM` |
| Hậu điều kiện thành công | Cache sự kiện cập nhật; block liên quan cập nhật / xoá theo BR-13; cờ `XUNG_DOT` đúng; `calendar.changed` phát tới thiết bị ≤ 5 giây sau khi xử lý |
| Hậu điều kiện thất bại | Cache giữ bản cũ; lần poll / webhook sau xử lý lại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Google / Microsoft | Gọi \[CalendarWebhook\] (hoặc tới lượt poll 15 phút) |
| 2 | Hệ thống | Xác thực webhook (channel token / clientState); xếp job `calendar.sync` cho lịch đó |
| 3 | Hệ thống | Đọc phần thay đổi bằng `syncToken` / delta (BR-03) |
| 4 | Hệ thống | Sự kiện không có `appTaskId` → cập nhật cache, phân loại theo BR-09, tính lại `XUNG_DOT` cho timebox cùng khoảng (BR-14); sự kiện là gốc của timebox liên kết → áp BR-21 (b) |
| 5 | Hệ thống | Sự kiện có `appTaskId` của timebox còn liên kết → áp BR-13; ghi nhật ký. Sự kiện mồ côi (BR-19) → bỏ qua |
| 6 | Hệ thống | Phát `calendar.changed` / `task.upserted`; G04 tính lại sức chứa, projection |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Sự kiện timebox bị xoá trên lịch ngoài (EC-13) | Không thấy `appBlockId` ở lịch khác của tài khoản → BR-13 (b): gỡ timebox; task giữ nguyên ngày dự định, về projection nếu hết timebox; thông báo trong app MSG-14 |
| A2 | Sự kiện timebox bị dời giờ / ngày (EC-14) | BR-13 (a): lần sửa muộn hơn thắng; lịch ngoài thắng → cập nhật timebox, `startDate`, planned (1 timebox); không thông báo, chỉ ghi nhật ký. Tính lại cờ `LECH_NGAY` (BR-22) |
| A3 | Sự kiện chặn mới (bận / tentative, BR-09) chồng timebox (EC-16) | Gắn `XUNG_DOT`; card và timebox hiện cảnh báo **SCR-07** (MSG-13). Bản 1.0: "Giữ nguyên" và "Mở lịch". Bản 1.1 thêm "Dời sang khe trống" (UC-05 A5) (Q17) |
| A4 | Sự kiện mới không chặn: đã từ chối, free, cả ngày (BR-09, EC-17) | Không gắn `XUNG_DOT`. Người dùng từ chối một sự kiện đang gây `XUNG_DOT` → bỏ cờ |
| A5 | Google 410 / delta hết hiệu lực | `DANG_DONG_BO`, đồng bộ lại toàn bộ cửa sổ; đối chiếu theo `appBlockId`, không tạo trùng; bước so sánh: timebox `DA_DONG_BO` không còn sự kiện → như A1 (BR-03, B9) |
| A6 | Sự kiện timebox bị đổi tiêu đề / mô tả / riêng tư / bận ngoài app | BR-13 (c): app thắng; xếp `timebox.push` ghi đè ở lần đồng bộ kế tiếp |
| A7 | Timezone người dùng đổi (EC-02) | Theo QC-01 mục 3–4 (Q4): không đổi `startsAt` / `endsAt`, **không** tính lại `startDate`; tính lại cờ `LECH_NGAY` (BR-22); G04 vẽ lại. Không hiện banner riêng (chỉ MSG-23 của G01) |
| A8 | Sự kiện chuyển sang ngày có giờ mùa hè (EC-03) | Giữ thời điểm tuyệt đối do lịch ngoài gửi; hiển thị theo giờ địa phương |
| A9 | Sự kiện timebox bị đổi thành sự kiện cả ngày (C18) | BR-13 (e): gỡ timebox, task giữ nguyên; MSG-31 |
| A10 | Sự kiện timebox bị chuyển sang lịch khác cùng tài khoản | BR-13 (d): cập nhật `calendarId` của timebox; không gỡ, không tạo sự kiện mới. Lịch mới chỉ đọc → timebox giữ liên kết, lần ghi sau lỗi theo UC-06 E4 |
| A11 | Sự kiện gốc của timebox liên kết đổi giờ / bị xoá / đổi thành cả ngày | BR-21 (b): timebox đi theo / bị gỡ, task giữ nguyên; MSG-14 khi gỡ |
| A12 | Sự kiện mang `appBlockId` của timebox đã tách liên kết (sau ngắt kết nối) | Bỏ qua (BR-19) |
| A13 | Workspace chỉ đọc (1.1) | Chỉ cập nhật cache sự kiện; bỏ qua bước 5 (BR-20, QC-09) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Webhook không xác thực được | Trả 401, bỏ qua, ghi log bảo mật |
| E2 | Token lỗi khi đọc (EC-15) | `CAN_KET_NOI_LAI` (UC-08) |
| E3 | 429 | Backoff; giữ cache cũ; panel lịch hiện "Cập nhật lúc {giờ}" |
| E4 | Lỗi > 2% trong 10 phút | Cảnh báo vận hành (mục 10) |

### UC-08 Kết nối lại và ngắt kết nối

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tài khoản `CAN_KET_NOI_LAI` (kết nối lại) / bất kỳ (ngắt) |
| Hậu điều kiện thành công | Kết nối lại: `HOAT_DONG`, mọi block chờ đã đẩy, không trùng. Ngắt: tài khoản `DA_NGAT`, token thu hồi, block `CHI_TRONG_APP` |
| Hậu điều kiện thất bại | Trạng thái cũ giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Kết nối lại" trên banner **SCR-09** hoặc SCR-01 |
| 2 | Hệ thống | Như bước 2–4 UC-01 với cùng tài khoản (A1 UC-01) |
| 3 | Hệ thống | `DANG_DONG_BO`: đồng bộ lại toàn bộ cửa sổ, đối chiếu sự kiện có `appBlockId`, có bước so sánh (BR-03); áp BR-13 cho thay đổi xảy ra ở lịch ngoài trong lúc mất kết nối |
| 4 | Hệ thống | Đẩy mọi timebox `CHO_DONG_BO` / `LOI` / `CHO_XOA` theo BR-11 (UC-06, BR-16, B9); `HOAT_DONG`; ẩn banner |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Ngắt kết nối | SCR-01 → "Ngắt kết nối" → **SCR-08** (MSG-18) → \[CalendarDisconnect\] áp BR-19 (tách liên kết); toast MSG-19 |
| A2 | Ngắt có tích "Xoá các sự kiện timebox app đã tạo" | Job xoá mọi sự kiện có `appTaskId` trên các lịch của tài khoản trước khi thu hồi token; không đụng sự kiện gốc của timebox liên kết |
| A3 | Kết nối lại bằng tài khoản khác email | Tạo tài khoản mới (UC-01); tài khoản cũ vẫn `CAN_KET_NOI_LAI` |
| A4 | Sự kiện timebox đã có trên lịch từ trước khi mất kết nối; cả timebox trong app và sự kiện đều đã đổi | Áp BR-13 (thay cho "app luôn thắng"): giờ → bên sửa muộn hơn thắng; tiêu đề → app thắng; sự kiện bị xoá → gỡ timebox; chuyển lịch → cập nhật `calendarId` |
| A5 | Kết nối lại một tài khoản đã ngắt trước đó (`DA_NGAT`) | Như UC-01; sự kiện mồ côi của lần kết nối trước bị bỏ qua, không liên kết lại timebox `CHI_TRONG_APP` (BR-19) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Kết nối lại vẫn thiếu scope | MSG-02, giữ `CAN_KET_NOI_LAI` |
| E2 | Thu hồi token ở nhà cung cấp lỗi khi ngắt | Vẫn xoá token phía app, ghi log, thử thu hồi lại tối đa 3 lần |

### UC-09 Lập lịch cứng cho task lặp (job `timebox.hardschedule`) — bản 1.1

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Toggle "Lập lịch cứng cho task lặp" bật (SCR-01 #7); series có `approxTime`; workspace không chỉ đọc |
| Hậu điều kiện thành công | Mỗi instance `KE_HOACH` trong cửa sổ N ngày, chưa sửa riêng, có đúng một timebox lập lịch cứng theo BR-23; timebox `CHO_DONG_BO` rồi `DA_DONG_BO` |
| Hậu điều kiện thất bại | Instance không có timebox; lượt chạy sau làm lại (idempotent) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Kích hoạt khi: G03 sinh instance, người dùng bật toggle, hoặc mốc đầu ngày hằng ngày (BR-23 b) |
| 2 | Hệ thống | Lấy instance `KE_HOACH` của series có `approxTime`, `startDate` trong cửa sổ, chưa có timebox `hardScheduled`, `customized = false` (G03 BR-07) |
| 3 | Hệ thống | Tính `startsAt` / `endsAt` theo BR-23 (c); bỏ qua nếu vượt 90 ngày (C18) |
| 4 | Hệ thống | Tạo timebox (`hardScheduled = true`), tính `XUNG_DOT` (BR-14), xếp `timebox.push` (UC-06); nhật ký tác nhân `system` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng kéo / đổi giờ / đổi thời lượng / gỡ timebox lập lịch cứng | Áp UC-04; instance `customized = true` (G03 BR-07); không tạo lại, không ghi đè (BR-23 e, Q44) |
| A2 | Series đổi `approxTime` / planned / quy tắc (G03) | Cập nhật timebox của instance chưa sửa riêng trong cửa sổ; instance bị G03 xoá → dòng "Xoá" QC-05; instance đã tách khỏi series giữ timebox (BR-23 f) |
| A3 | Dừng series (G03) hoặc tắt toggle | Ngừng tạo; timebox đã có giữ nguyên (BR-23 g); tắt toggle không xoá timebox cũ |
| A4 | Instance bị dời ngày / vào backlog / bị lưu trữ | Theo QC-05 và BR-23 (h) |
| A5 | Giờ `approxTime` chồng sự kiện chặn | Vẫn tạo, gắn `XUNG_DOT` (BR-23 i) |
| A6 | Instance đã hoàn thành trước khi job chạy | Không tạo |
| A7 | Không có lịch ghi (BR-04) | Timebox `CHI_TRONG_APP` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Lỗi CSDL / timeout | Rollback lượt của series đó, lượt sau làm lại |
| E2 | Workspace vào chỉ đọc giữa lượt | Dừng lượt (BR-20); chạy lại khi thoát chỉ đọc, chỉ cho ngày ≥ hôm nay (QC-09) |

### UC-10 Tạo timebox liên kết sự kiện

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Sự kiện ngoài có trong cache, không mang `appTaskId`, không phải cả ngày; task vừa được tạo từ sự kiện (G08 bước Thêm task) |
| Hậu điều kiện thành công | Task có timebox `LIEN_KET_SU_KIEN` cùng giờ sự kiện; không có sự kiện mới trên lịch ngoài |
| Hậu điều kiện thất bại | Task không có timebox liên kết; task vẫn tồn tại (G08 xử lý) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống (G08) | Gọi \[TimeboxLink\] `{taskId, calendarId, eventId}` |
| 2 | Hệ thống | Kiểm tra sự kiện tồn tại; tạo timebox `kind = event_linked` với `startsAt` / `endsAt` của sự kiện; `startDate` = `workday(startsAt)` (BR-21) |
| 3 | Hệ thống | Không xếp `timebox.push`; phát `task.upserted`; G04 tính sức chứa không trừ hai lần |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Sự kiện đã có task liên kết | Trả timebox đã có, không tạo thêm (G08 BR-07: một sự kiện một task) |
| A2 | Sự kiện là một lần xuất hiện của sự kiện lặp | Liên kết với đúng lần xuất hiện đó (`eventId` của instance) `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Sự kiện không còn / tài khoản `CAN_KET_NOI_LAI` | `EVENT_NOT_FOUND`; G08 tạo task không có timebox `[giả định]` |

### UC-11 Xử lý cờ "Lệch ngày"

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task `KE_HOACH` có cờ `LECH_NGAY` (BR-22); workspace không chỉ đọc |
| Hậu điều kiện thành công | `workday(startsAt)` của mọi timebox bằng `startDate`; cờ bỏ |
| Hậu điều kiện thất bại | Cờ giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm nhãn "Lệch ngày" trên card / block / SCR-06 → popover MSG-30 |
| 2 | Người dùng | Chọn "Dời task sang {ngày timebox}" hoặc "Dời timebox về {ngày dự định}" |
| 3 | Hệ thống | Dời task: đổi `startDate` như "kéo sang ngày khác" (QC-05). Dời timebox: \[TimeboxSet\] giữ giờ địa phương, đổi ngày; đẩy sự kiện (UC-06) |
| 4 | Hệ thống | Tính lại cờ; toast Hoàn tác |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng không xử lý | Cờ giữ nguyên; hệ thống không tự sửa (Q4) |
| A2 | "Dời task" tới ngày đã có instance cùng series | Cảnh báo theo QC-06 (đường thủ công) |
| A3 | Timebox liên kết sự kiện | Chỉ có "Dời task" (BR-21) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Ngày đích < hôm nay với task chưa xong | MSG-28 (QC-05) |

## 6. Điểm vào

| **Điểm vào** | **App Windows (1.0)** | **Web, macOS (1.1)** | **iOS / Android (1.2)** | **Ghi chú** |
| --- | --- | --- | --- | --- |
| Onboarding bước "Kết nối lịch" (G01) | ✓ | ✓ | ✓ | UC-01, bỏ qua được |
| Cài đặt → Lịch | ✓ | ✓ | ✓ | SCR-01, SCR-02 |
| Cài đặt → Context & channel → dòng channel → "Lịch ghi" | ✓ | ✓ | ✓ | SCR-03 |
| Kéo task vào Calendar views / Today view / panel Calendar (Shift+C) | ✓ | ✓ | ✓ (nhấn giữ để kéo) | UC-03 |
| Phím X / Shift+X / Ctrl+X, command menu | ✓ (X / Shift+X từ 1.1) | ✓ | – | UC-05, UC-04 A1 |
| Chi tiết task → mục Timebox | ✓ | ✓ | ✓ | SCR-06 |
| Banner "Cần kết nối lại" / thông báo (G12; ở app Windows là thông báo trong app và thông báo Windows, có từ 1.0 — D12) | ✓ | ✓ | ✓ | SCR-09, UC-08 |
| Daily planning → kéo sự kiện lịch thành task (G08) | ✓ | ✓ | ✓ | UC-10 |
| Nhãn "Lệch ngày" trên card / block / chi tiết | ✓ | ✓ | ✓ | UC-11 |
| Cài đặt → Lịch → "Lập lịch cứng cho task lặp" (1.1) | ✓ (từ 1.1) | ✓ | ✓ | UC-09 |
| Trợ lý AI qua MCP local: timebox / gỡ timebox, dời ngày (G10, QC-12) | ✓ (khi trợ lý AI bật) | Tech chốt — `docs/tech/` | Tech chốt — `docs/tech/` | Áp như thao tác của người dùng, tác nhân AI, có Hoàn tác (QC-12 mục 5) |

## 7. Mô tả màn hình

### SCR-01 Cài đặt → Lịch

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Kết nối Google Calendar" / "Kết nối Outlook" | Button | UC-01; disabled khi đủ số tài khoản tối đa (BR-01, MSG-05) |
| 2 | Danh sách tài khoản | List | Logo nhà cung cấp, email, trạng thái 4.1, "Đồng bộ lúc {giờ}"; bấm mở SCR-02 |
| 3 | "Kết nối lại" | Button | Chỉ hiện khi `CAN_KET_NOI_LAI` |
| 4 | "Ngắt kết nối" | Button (nguy hiểm) | Mở SCR-08 |
| 5 | Lịch ghi timebox mặc định | Dropdown | Chỉ lịch có quyền ghi + "Không ghi ra lịch ngoài" |
| 6 | Cài đặt Timebox | Nhóm toggle | Hiện actual trên lịch, Ẩn planned của task xong, Bận / rảnh, Nhắc theo lịch, Tự dời khi xung đột, Tự dời khi xong sớm (rút ngắn timebox, BR-17) (G01 khung trang) |
| 7 | Lập lịch cứng cho task lặp (1.1) | Toggle | Mặc định tắt `[giả định]`; mô tả "Tự tạo timebox tại giờ khoảng của task lặp trong 7 ngày tới"; bật → UC-09; tắt → UC-09 A3. Ẩn ở 1.0 |

### SCR-02 Lịch của một tài khoản

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tên lịch | Text | – | Từ nhà cung cấp; nhãn "Chỉ đọc" nếu không có quyền ghi |
| 2 | Hiển thị | Toggle | – | Tắt → ẩn sự kiện, không tính sức chứa (G04) |
| 3 | Màu | Color picker | – | Mặc định màu của nhà cung cấp |
| 4 | Lịch ghi mặc định | Radio | Không | Lịch chỉ đọc disabled (MSG-15) |

### SCR-03 Lịch ghi theo channel

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Channel | Text | – | "#tên" kèm màu (G02) |
| 2 | Lịch ghi | Dropdown | Không | "Theo mặc định" / lịch có quyền ghi / "Không ghi ra lịch ngoài" |
| 3 | (Bỏ — xem QC-02 mục 5–6) | – | – | Khung giờ channel do G02 sở hữu, cài trong màn cài đặt channel; G05 chỉ đọc cho auto-schedule (BR-08, 1.1) |

### SCR-04 Lưới lịch (Calendar views, Today view, panel Calendar)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Cột ngày + trục giờ | Grid | Bước kéo 5 phút; vùng ngoài giờ làm việc tô xám, giờ làm việc của ngày = hợp của lịch chung và mọi khung giờ channel có trong ngày đó (QC-02 mục 7) `[giả định cách hiển thị]` |
| 2 | Sự kiện ngoài | Block | Màu theo lịch; sự kiện free hiện sọc; tentative viền nét đứt; đã từ chối gạch ngang `[giả định]`; sự kiện cả ngày ở dải trên cùng (BR-09) |
| 3 | Block timebox | Block | SCR-05 |
| 4 | Projection | Block mờ | Từ G04, mờ hơn sự kiện thật khi bật cài đặt |
| 5 | Khối thực tế | Block mảnh | "2:01 – 2:02"; chỉ bản ghi có giờ thật (BR-18) |
| 6 | Vạch giờ hiện tại | Line | Chỉ ở hôm nay |
| 7 | Panel "Calendars" | Checkbox list | Bật / tắt nhanh hiển thị từng lịch (UC-02 A2) |
| 8 | Zoom | Icon button | "1x", +, −; 3 mức `[giả định]` |

### SCR-05 Block timebox

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề + giờ | Text | "{tiêu đề} · 10:55–11:55" |
| 2 | Thân block | Draggable | Kéo dời giờ / ngày (UC-04); giữ Shift = không tự dời |
| 3 | Cạnh dưới | Resize handle | Đổi thời lượng, bước 5 phút, tối thiểu 5 phút |
| 4 | Biểu tượng đồng bộ | Icon | Theo 4.2; `LOI` bấm "Thử ngay" |
| 5 | Cảnh báo xung đột | Icon cam | Mở SCR-07 |
| 6 | ✓ | Checkbox | Hoàn thành task (G02) |
| 7 | Nhãn "Lệch ngày" | Badge | Hiện khi `LECH_NGAY` (BR-22); bấm → UC-11 |
| 8 | Icon liên kết sự kiện | Icon | Chỉ timebox `LIEN_KET_SU_KIEN`; thân và cạnh không kéo được, tooltip MSG-26 (BR-21) |

### SCR-06 Timebox trên card và chi tiết task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Badge giờ trên card | Badge cam | Giờ bắt đầu block đầu, ví dụ "10:55"; nhiều block thêm "+n" |
| 2 | Mục Timebox trong chi tiết task | Text + icon lịch | "Thứ Năm, 5/11 · 10:55–11:55 · 1 giờ"; tên lịch ghi; trạng thái 4.2 |
| 3 | "Gỡ khỏi lịch" | Button | Ctrl+X → UC-04 A1 |
| 4 | "Tự xếp lịch" | Button | 1.1; chỉ hiện khi chưa có timebox; X → UC-05 |
| 5 | "Lệch ngày" | Badge + popover | MSG-30, hai lựa chọn của UC-11 |

### SCR-07 Popover xung đột

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-13 |
| 2 | "Dời sang khe trống" | Button | **Bản 1.1**, ẩn ở 1.0 (Q17); UC-05 A5 |
| 3 | "Giữ nguyên" | Button | Ẩn cảnh báo cho cặp timebox – sự kiện này |
| 4 | "Mở lịch" | Button | Mở Calendar views (G04) tại ngày, giờ của timebox để người dùng tự kéo `[giả định cách hiểu]` (Q17) |

### SCR-08 Xác nhận ngắt kết nối

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-18 |
| 2 | "Xoá các sự kiện timebox app đã tạo" | Checkbox | Mặc định tắt (BR-19) |
| 3 | "Ngắt kết nối" | Button (nguy hiểm) | \[CalendarDisconnect\]; toast MSG-19 |
| 4 | "Huỷ" | Button | Đóng |

### SCR-09 Banner cần kết nối lại

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-06, có số block đang chờ |
| 2 | "Kết nối lại" | Button | UC-08 |
| 3 | × | Icon | Ẩn trong 24 giờ `[giả định]`; chấm đỏ ở SCR-01 vẫn còn |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[CalendarAccounts\] `GET /calendar/accounts` | – | Account[] {id, provider, email, status, lastSyncedAt, calendars[]} | 5s / 1 lần |
| \[CalendarConnect\] `GET /calendar/accounts/{provider}/connect` | provider, returnTo | Redirect URL OAuth (`state`) | 5s / 1 lần |
| \[CalendarCallback\] `GET /calendar/accounts/{provider}/callback` `[giả định]` | code, state | Redirect về app + accountId | 10s / không retry |
| \[CalendarUpdate\] `PATCH /calendars/{id}` | isVisible, color, isDefaultWrite | Calendar | 5s / 2 lần |
| \[ChannelCalendarUpdate\] `PATCH /channels/{id}` `[giả định]` | writeCalendarId (khung giờ channel thuộc API cài đặt channel của G02, QC-02 mục 5) | Channel | 5s / 2 lần |
| \[CalendarDisconnect\] `DELETE /calendar/accounts/{id}` | deleteAppEvents (bool) | 204 | 10s / 1 lần |
| \[CalendarEvents\] `GET /calendar/events?from&to` | from, to (≤ 42 ngày) | Event[] {id, calendarId, title, startsAt, endsAt, allDay, busy, appTaskId?, appBlockId?} | 5s / 1 lần |
| \[TimeboxSet\] `PUT /tasks/{id}/timebox` | startsAt, endsAt, calendarId?, skipReschedule?, blockId? (trống = thêm timebox mới, C19), version, Idempotency-Key | Task + blocks[] {blockId, kind (`app` / `event_linked`), startsAt, endsAt, calendarId, syncStatus, conflict, dayMismatch, hardScheduled}, tasksRescheduled[] | 5s / 2 lần cùng key |
| \[TimeboxDelete\] `DELETE /tasks/{id}/timebox` | blockId? (trống = mọi timebox) | Task | 5s / 2 lần |
| \[TimeboxLink\] `POST /tasks/{id}/timebox/link` `[giả định]` | calendarId, eventId, Idempotency-Key | Task + block {kind: `event_linked`} | 5s / 2 lần cùng key |
| Job `timebox.hardschedule` (1.1) | userId, seriesId? | createdCount, updatedCount | Khi sinh instance, khi bật toggle, mỗi mốc đầu ngày; idempotent theo instance |
| \[TimeboxAuto\] `POST /tasks/{id}/timebox/auto` `[giả định]` | split (bool), date?, Idempotency-Key | Task + blocks[] | 5s / 1 lần |
| \[TimeboxRetry\] `POST /tasks/{id}/timebox/retry` `[giả định]` | blockId | blocks[] | 5s / 1 lần |
| \[CalendarWebhook\] `POST /webhooks/calendar/{provider}` | Header kênh (Google) / `validationToken`, `clientState` (Graph) | 200 / 202 trong ≤ 3s, xử lý bất đồng bộ | Nhà cung cấp tự gửi lại |
| \[SyncBatch\] `POST /sync/batch` | Hàng đợi thao tác offline | Kết quả từng thao tác | 10s / backoff |
| Job `calendar.sync` | accountId, calendarId, mode (incremental / full) | – | Theo BR-03; 429 backoff |
| Job `calendar.watch.renew` | accountId | – | Mỗi 6 giờ; lỗi → `DONG_BO_CHAM` |
| Job `timebox.push` | blockId | – | BR-12, tối đa 24 giờ |
| Realtime `calendar.changed`, `task.upserted` | – | {from, to, calendarIds} / Task | Thiết bị khác ≤ 5 giây |

**Map trường timebox → sự kiện lịch ngoài**

| **Trường app** | **Google Calendar** | **Microsoft Graph** | **Quy tắc** |
| --- | --- | --- | --- |
| Tiêu đề task | `summary` | `subject` | Cắt 500 ký tự; đổi tiêu đề task → cập nhật |
| `startsAt` + timezone | `start.dateTime`, `start.timeZone` | `start.dateTime`, `start.timeZone` | UTC nội bộ → giờ địa phương + IANA (Graph nhận IANA `[giả định]`) |
| `endsAt` + timezone | `end.dateTime`, `end.timeZone` | `end.dateTime`, `end.timeZone` | Như trên; vắt qua mốc đầu ngày / nửa đêm vẫn ghi liền một sự kiện (EC-04) |
| Bận / rảnh (cài đặt, mặc định bận) | `transparency`: `opaque` / `transparent` | `showAs`: `busy` / `free` | – |
| Riêng tư | `visibility`: `private` / `default` | `sensitivity`: `private` / `normal` | Channel riêng tư → luôn private; khác → mặc định của lịch |
| Nhắc (theo lịch) | `reminders.useDefault = true` | `isReminderOn = true`, `reminderMinutesBeforeStart = 15` `[giả định]` | – |
| Link về task | `description` | `body` (`contentType = text`) | "Mở trong Wakeup: {url}"; không ghi notes |
| `appTaskId`, `appBlockId` | `extendedProperties.private` | Open extension (`extensionName` `[giả định]`) | Nhận diện, chống trùng (BR-11) |
| `calendarId` (lịch đích) | `calendarId` của sự kiện | `calendar.id` | Cố định từ lần đẩy đầu; chỉ đổi theo BR-13 (d) |
| Timebox liên kết sự kiện | Không ghi | Không ghi | BR-21 |
| `externalEventId`, etag | `id`, `etag` | `id`, `changeKey` | Lưu phía app để PATCH / phát hiện sửa ngoài |
| Notes, comment, subtask, channel, màu, người tham dự | Không ghi | Không ghi | BR-10 |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `OAUTH_CANCELLED` | MSG-03 |
| `OAUTH_SCOPE_MISSING` | MSG-02 |
| `OAUTH_ADMIN_BLOCKED` | MSG-22 |
| `CALENDAR_ACCOUNT_LIMIT` | MSG-05 |
| `CALENDAR_NEEDS_RECONNECT` | MSG-06 |
| `CALENDAR_READ_ONLY` | MSG-15 |
| `NO_FREE_SLOT` | MSG-11 |
| `NO_CONTIGUOUS_SLOT` (Shift+X) | MSG-12 |
| `VALIDATION_FAILED` · field endsAt · DURATION_RANGE | MSG-17 |
| `PROVIDER_RATE_LIMITED` (429) | MSG-16 |
| `NOT_FOUND` (task đã xoá) | MSG-25 |
| `WORKSPACE_READ_ONLY` (402, 1.1) | MSG-20 |
| `TIMEBOX_LINKED_READONLY` (sửa timebox liên kết sự kiện) | MSG-26 |
| `TIMEBOX_TOO_FAR` (> 90 ngày) | MSG-27 |
| `VALIDATION_FAILED` · `PAST_DATE` (QC-05, mã do G02 sở hữu) | MSG-28 |
| `TIMEBOX_REMOVED` (timebox đã bị gỡ ở lịch ngoài / thiết bị khác) | MSG-29 |
| `VERSION_CONFLICT` (409 / 412) trên cụm vị trí (QC-08), 5xx / timeout, `state` OAuth sai | MSG-21 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | Đã kết nối {email}. Đang tải sự kiện… |
| MSG-02 | Inline | Cần quyền xem và sửa lịch để dùng timebox. Hãy kết nối lại và giữ đủ quyền |
| MSG-03 | Toast | Đã huỷ kết nối {Google Calendar / Outlook} |
| MSG-04 | Toast | {email} đã được kết nối trước đó, đã cập nhật quyền |
| MSG-05 | Inline | Đã đạt tối đa {n} tài khoản lịch |
| MSG-06 | Banner | Mất kết nối {nhà cung cấp} ({email}). {n} timebox đang chờ đồng bộ · Kết nối lại |
| MSG-07 | Tooltip | Đang chờ đồng bộ lên {tên lịch} |
| MSG-08 | Tooltip | Chưa ghi được lên {tên lịch}. Đang thử lại · Thử ngay |
| MSG-09 | Toast | Đã đặt "{tiêu đề}" lúc {giờ bắt đầu}–{giờ kết thúc} · Hoàn tác |
| MSG-10 | Toast | Đã gỡ "{tiêu đề}" khỏi lịch · Hoàn tác |
| MSG-11 | Toast | Hôm nay hết khe trống |
| MSG-12 | Toast | Không có khe đủ dài cho "{tiêu đề}". Nhấn X để chia thành nhiều khối |
| MSG-13 | Popover | Trùng với "{tên sự kiện}" ({giờ}) · Giữ nguyên · Mở lịch (1.1 thêm: Dời sang khe trống) |
| MSG-14 | Thông báo trong app | Timebox của "{tiêu đề}" đã được gỡ vì sự kiện bị xoá trên {tên lịch}. Task vẫn ở {ngày dự định} |
| MSG-15 | Tooltip | Lịch này chỉ đọc, hãy chọn lịch khác để ghi timebox |
| MSG-16 | Toast | {Nhà cung cấp} đang giới hạn tốc độ, timebox sẽ được đồng bộ sau ít phút |
| MSG-17 | Inline | Thời lượng khối từ 5 phút đến 24 giờ |
| MSG-18 | Dialog | Ngắt kết nối {email}? Sự kiện sẽ không hiện trong app nữa; timebox trong app được giữ lại |
| MSG-19 | Toast | Đã ngắt kết nối {email} |
| MSG-20 | Banner (1.1) | Gói dùng thử đã hết. Nâng cấp để tiếp tục timebox task |
| MSG-21 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-22 | Toast | Tổ chức của bạn chặn ứng dụng truy cập lịch. Hãy liên hệ quản trị viên |
| MSG-23 | Toast | Đã dời {n} task để nhường chỗ · Hoàn tác |
| MSG-24 | Tooltip | Giờ này không tồn tại do đổi giờ, đã đặt lúc {giờ} |
| MSG-25 | Toast | Task này đã bị xoá |
| MSG-26 | Tooltip | Timebox này đi theo sự kiện "{tên sự kiện}" trên {tên lịch}. Hãy đổi giờ trên lịch đó |
| MSG-27 | Toast | Chỉ tạo được timebox trong 90 ngày tới |
| MSG-28 | Toast | Không đặt task chưa xong vào ngày đã qua |
| MSG-29 | Toast | Timebox này đã bị gỡ trên thiết bị khác hoặc trên lịch ngoài |
| MSG-30 | Popover | Lệch ngày: timebox ở {ngày timebox}, task ở {ngày dự định} · Dời task sang {ngày timebox} · Dời timebox về {ngày dự định} |
| MSG-31 | Thông báo trong app | Timebox của "{tiêu đề}" đã được gỡ vì sự kiện được đổi thành cả ngày trên {tên lịch} |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Block hiện trong app ≤ 100 ms sau khi thả (lạc quan); \[TimeboxSet\] p95 ≤ 300 ms; timebox xuất hiện trên lịch ngoài ≤ 10 giây (p95); thay đổi lịch ngoài về app ≤ 1 phút qua webhook, ≤ 15 phút qua poll; \[TimeboxAuto\] ≤ 1 giây; job `timebox.hardschedule` (1.1) xong ≤ 5 phút sau mốc đầu ngày |
| Offline | Tạo / dời / gỡ timebox khi mất mạng, timebox `CHO_DONG_BO`; sự kiện ngoài hiện bản cache 4 tuần; đồng bộ lại qua \[SyncBatch\] không tạo trùng; thứ tự và xung đột theo QC-08 (giờ timebox là trường gộp theo từng trường; `startDate` thuộc cụm vị trí) |
| Độ tin cậy | 0 sự kiện trùng `appBlockId`; job `timebox.push`, `calendar.sync` idempotent; lỗi đồng bộ > 2% trong 10 phút → cảnh báo vận hành |
| Bảo mật | Token OAuth mã hoá AES-256-GCM, không trả về client, thu hồi khi ngắt kết nối / xoá tài khoản (G01); webhook xác thực bằng channel token / `clientState`; scope tối thiểu (BR-02); không ghi notes ra ngoài; channel riêng tư luôn Private |
| Log / audit | \[ActivityLog\] cho tạo / dời / gỡ timebox, tác nhân `user` / `integration` / `system`; log hệ thống không chứa tiêu đề task, tiêu đề sự kiện |
| Tracking | Sự kiện: `calendar_connect_started` (provider), `calendar_connected`, `calendar_connect_failed` (lý do), `calendar_reconnected`, `calendar_disconnected`, `calendar_visibility_changed`, `timebox_created` (cách: kéo / X / Shift+X), `timebox_moved`, `timebox_resized`, `timebox_removed`, `auto_schedule_no_slot`, `timebox_push_failed`, `external_event_deleted_timebox_removed`, `conflict_shown`, `conflict_resolved` (giữ / mở lịch / dời — 1.1), `timebox_linked_created`, `day_mismatch_shown`, `day_mismatch_resolved` (dời task / dời timebox), `hard_schedule_created` (1.1), `hard_schedule_detached` (1.1) |
| Accessibility | WCAG 2.1 AA; timebox làm được không cần kéo (X, lệnh "Timebox…" trong command menu, nhập giờ trong chi tiết task); block có nhãn đọc màn hình "{tiêu đề}, {giờ bắt đầu} đến {giờ kết thúc}, {trạng thái đồng bộ}"; xung đột không chỉ dùng màu |
| Tuân thủ nhà cung cấp | Đạt yêu cầu xác minh Google OAuth (scope nhạy cảm) trước khi mở cho người dùng ngoài danh sách thử nghiệm; tuân thủ chính sách dữ liệu người dùng Google API |
