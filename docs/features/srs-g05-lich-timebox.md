> **Mã:** PLN-SRS-G05-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g05-lich-timebox.md

# UC-G05 - Lịch & timebox trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả kết nối Google Calendar / Outlook, chọn lịch, timebox (tạo, dời, đổi thời lượng, gỡ, auto-schedule), ghi timebox ra lịch ngoài và nhận thay đổi từ lịch ngoài. Chế độ xem, điều hướng ngày, projection, cảnh báo khối lượng (G04), nội dung task (G02), lặp lại (G03), rollover gỡ timebox quá khứ (G06), timer và thời gian thực tế (G07), thông báo (G12) đặc tả ở SRS riêng của từng nhóm. Apple / CalDAV thuộc bản 1.1. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng thấy sự kiện lịch cạnh task, đặt task vào khung giờ (timebox) bằng kéo thả hoặc phím, timebox tự có trên Google / Outlook và thay đổi trên lịch ngoài phản ánh về app, không trùng, không mất |
| Actor | Người dùng đã đăng nhập · Hệ thống (job đồng bộ, đẩy timebox) · Google Calendar API · Microsoft Graph |
| Phạm vi | Kết nối / kết nối lại / ngắt tài khoản lịch, chọn lịch hiển thị và lịch ghi (mặc định, theo channel), hiển thị sự kiện, timebox, auto-schedule (X, Shift+X), gỡ timebox (Ctrl+X), đồng bộ 2 chiều, cảnh báo xung đột, block thời gian thực tế |
| Ngoài phạm vi | Apple / CalDAV (1.1), tạo / sửa sự kiện thường, mời người tham dự, ghi chú cuộc họp, chế độ xem lịch và điều hướng (G04), timer (G07) |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
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

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Tài khoản lịch.** Nhà cung cấp `google` / `microsoft` (1.0). Tối đa 5 tài khoản / người dùng `[giả định]`. Khoá duy nhất (userId, provider, providerAccountId): kết nối lại cùng tài khoản chỉ cập nhật token |
| BR-02 | **Quyền.** Google: `calendar.events`, `calendar.calendarlist.readonly`. Microsoft: `Calendars.ReadWrite`, `offline_access`. Thiếu quyền ghi → không tạo kết nối. Token mã hoá AES-256-GCM, không trả về client |
| BR-03 | **Đồng bộ đọc.** Cửa sổ 30 ngày trước → 90 ngày sau. Gia tăng bằng `syncToken` (Google) / delta (Graph); Google 410 hoặc delta token hết hiệu lực → đồng bộ lại toàn bộ cửa sổ. Webhook (`events.watch` / subscription) gia hạn mỗi 6 giờ; webhook lỗi / hết hạn → poll 15 phút. Phát `calendar.changed` khi có thay đổi |
| BR-04 | **Lịch ghi của một block** = lịch ghi của channel task → lịch mặc định của người dùng → không có thì block `CHI_TRONG_APP`. Chỉ lịch có quyền ghi được chọn làm lịch ghi |
| BR-05 | **Tạo timebox.** Thả task vào ô (ngày D, giờ H) → `startDate = D`; block [H, H + planned], H làm tròn 5 phút; planned trống → 30 phút. Block 5 phút – 24 giờ `[giả định]`. Kéo / X là thao tác của người dùng, ghi nhật ký tác nhân `user` |
| BR-06 | **Sửa timebox.** Kéo block sang giờ / ngày khác: `startDate` = ngày địa phương của `startsAt`. Kéo cạnh dưới đổi thời lượng (bước 5 phút): planned = tổng thời lượng các block của task. Ctrl+X / "Gỡ khỏi lịch": xoá mọi block, task về projection (G04) |
| BR-07 | **Tự dời khi xung đột** (cài đặt, mặc định bật): block mới / vừa dời đè block của task khác → task bị đè dời xuống ngay sau block mới, dây chuyền trong cùng ngày, chỉ dời vào thời gian không có sự kiện bận. Giữ Shift khi thả → `skipReschedule = true`, cho phép chồng. Không bao giờ dời sự kiện ngoài |
| BR-08 | **Auto-schedule.** X: tìm khe trống đầu tiên trong giờ làm việc của channel task (mặc định 09:00–17:00, ghi đè theo channel) ở ngày `startDate` (task backlog / không ngày: hôm nay), từ max(giờ bắt đầu làm việc, hiện tại làm tròn lên 5 phút); khe trống = không có sự kiện bận và block khác; cộng khoảng đệm (mặc định 0). Không khe nào đủ dài → chia tối đa 3 block, mỗi block ≥ 15 phút `[giả định]`. Shift+X: chỉ nhận khe đủ dài, không chia. Không có khe → MSG-11, không đổi gì (EC-18). Phát hành ở bản 1.1 theo lộ trình chung; đặc tả sẵn để làm tiếp |
| BR-09 | **Sự kiện không chặn:** sự kiện free (`transparent` / `showAs = free`), sự kiện cả ngày, sự kiện ở lịch đang ẩn không chặn auto-schedule, không gây xung đột (EC-17) |
| BR-10 | **Ghi ra lịch ngoài** theo bảng map mục 8. Không ghi notes, người tham dự, màu. Channel riêng tư → luôn Private; khác → riêng tư theo mặc định của lịch. Bận / rảnh, nhắc theo cài đặt Timebox |
| BR-11 | **Idempotent.** Mỗi block có `blockId`; sự kiện ngoài mang `appTaskId` + `appBlockId`. Trước khi tạo, \[TimeboxPush\] tìm sự kiện có cùng `appBlockId` trên lịch ghi; có → cập nhật, không tạo mới. Không bao giờ có 2 sự kiện cùng `appBlockId` |
| BR-12 | **Thử lại.** \[TimeboxPush\] lỗi → `sync_status = error`, thử lại backoff 1, 5, 15, 60 phút rồi mỗi giờ `[giả định]`, tối đa 24 giờ; quá 24 giờ dừng, chờ người dùng "Thử lại". 429 → theo `Retry-After`. Ghi nhiều lần cùng block trong 2 giây gộp thành 1 `[giả định]` |
| BR-13 | **Chiều ngược (lịch → app).** Chỉ áp cho sự kiện có `appTaskId` của người dùng. Xoá trên lịch ngoài → xoá block; task hết block thì về projection (EC-13). Dời giờ / ngày → cập nhật block, `startDate` theo BR-06; task 1 block thì planned = thời lượng mới (EC-14). Đổi tiêu đề / mô tả / riêng tư / bận → bỏ qua, lần ghi sau ghi đè `[giả định]`. Ghi nhật ký tác nhân `integration` ("Google Calendar đã dời timebox…") |
| BR-14 | **Xung đột với sự kiện ngoài** (EC-16): sự kiện bận (không mang `appTaskId`, ở lịch hiển thị) chồng một phần hoặc toàn bộ block → block có cờ `XUNG_DOT`; không tự dời; gợi ý "Dời sang khe trống" = Shift+X cho task đó. Hết chồng → bỏ cờ |
| BR-15 | **Thời gian.** Lưu `startsAt` / `endsAt` UTC + IANA timezone. Đổi timezone (EC-02): giữ thời điểm tuyệt đối, hiển thị theo timezone mới; `startDate` tính lại theo ngày địa phương mới của `startsAt` `[giả định]`. Giờ mùa hè (EC-03): thời lượng tính bằng phút thực; giờ không tồn tại → dời tới giờ hợp lệ kế tiếp (MSG-24); giờ lặp lại → lần xuất hiện đầu. Qua nửa đêm (EC-04): `startDate` = ngày của `startsAt`; ghi 1 sự kiện liền; lịch app vẽ 2 đoạn |
| BR-16 | **Mất kết nối** (EC-15): refresh token lỗi / bị thu hồi / mất quyền → tài khoản `CAN_KET_NOI_LAI`; block mới / sửa trên lịch đó → `CHO_DONG_BO`; dừng poll / webhook. Kết nối lại → đồng bộ lại toàn bộ cửa sổ rồi đẩy mọi block chờ theo BR-11 |
| BR-17 | **Hoàn thành / xoá task.** Hoàn thành: giữ block và sự kiện. Bật "Tự dời khi xong sớm" và hoàn thành trước `endsAt` → `endsAt` = giờ hoàn thành làm tròn lên 5 phút, cập nhật sự kiện `[giả định cách hiểu]`. "Ẩn planned của task xong" chỉ ẩn block trong app. Xoá task (G02) → xoá sự kiện ngoài; khôi phục không tạo lại timebox |
| BR-18 | **Block thực tế.** Bật "Hiện actual trên lịch" → mỗi TimeEntry (G07) vẽ block thực tế trên lịch app (ví dụ "2:01 – 2:02"); không ghi ra lịch ngoài `[giả định]` |
| BR-19 | **Ngắt kết nối.** Thu hồi token ở nhà cung cấp, huỷ webhook, xoá cache sự kiện. Tuỳ chọn "Xoá các sự kiện timebox app đã tạo" (mặc định tắt) `[giả định]`. Block trong app giữ nguyên, chuyển `CHI_TRONG_APP` |
| BR-20 | Workspace chỉ đọc (G12): xem lịch, đồng bộ đọc tiếp tục; không tạo / sửa / gỡ timebox (MSG-20) |

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
| `CHI_TRONG_APP` (`local`) | Không có lịch ghi (BR-04) hoặc tài khoản đã ngắt | Block bình thường, không icon lịch |

Cờ phụ `XUNG_DOT` (BR-14) đi kèm mọi trạng thái trên: viền cam + icon cảnh báo trên block và card. Chuyển: tạo / sửa → `CHO_DONG_BO` → `DA_DONG_BO` hoặc `LOI` (UC-06) · `LOI` → `CHO_DONG_BO` (thử lại) · gỡ → `CHO_XOA` → xoá bản ghi · ngắt kết nối → `CHI_TRONG_APP`.

## 5. Use Case

### UC-01 Kết nối tài khoản lịch

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; số tài khoản lịch < 5 |
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
| E4 | Đã đủ 5 tài khoản | Nút kết nối disabled, MSG-05 |
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
| A4 | Đổi lịch ghi khi đã có block tương lai | Chỉ áp cho block mới; block cũ ở lịch cũ `[giả định]` |

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
| A4 | Task backlog / ngày khác | `startDate = D`; task rời backlog (G06) / cột cũ (G04) |
| A5 | Block vượt qua nửa đêm (EC-04) | `startDate` = ngày bắt đầu; vẽ 2 đoạn trên 2 cột; ghi 1 sự kiện liền |
| A6 | Ô thả rơi vào giờ không tồn tại do đổi giờ (EC-03) | Dời tới giờ hợp lệ kế tiếp, tooltip MSG-24 |
| A7 | Không có lịch ghi (BR-04) | Block `CHI_TRONG_APP`, không xếp job |
| A8 | Tài khoản lịch ghi `CAN_KET_NOI_LAI` (EC-15) | Block `CHO_DONG_BO`, chờ UC-08 |
| A9 | Kéo bằng bàn phím | Chọn task → lệnh "Timebox…" trong command menu (G04) → chọn ngày, giờ `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Thời lượng ngoài 5 phút – 24 giờ | MSG-17, không tạo |
| E2 | Task đã bị xoá ở thiết bị khác | Gỡ bóng block, MSG-25 |
| E3 | Mất mạng | Lưu trên máy, \[SyncBatch\] gửi lại với cùng Idempotency-Key |
| E4 | Workspace chỉ đọc | Không cho thả, MSG-20 |
| E5 | \[TimeboxSet\] lỗi 5xx | Gỡ block, trả task về chỗ cũ, MSG-21 |

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
| A1 | Ctrl+X / "Gỡ khỏi lịch" (SCR-06) | \[TimeboxDelete\]; block `CHO_XOA`; task về projection; toast MSG-10 có "Hoàn tác" (tạo lại block với giờ cũ) |
| A2 | Kéo block sang ngày khác | `startDate` đổi (đã kiểm chứng 10:55–11:55 sang ngày khác); G04 tính lại 2 ngày |
| A3 | Task có nhiều block, kéo cạnh một block | planned = tổng các block (BR-06) |
| A4 | Hoàn thành task trước `endsAt`, bật "Tự dời khi xong sớm" | Rút `endsAt` theo BR-17 |
| A5 | Xoá task (G02) | Xoá mọi block, sự kiện ngoài như A1 |
| A6 | Rollover task có block quá khứ (G06) | Gỡ block như A1, tác nhân `system` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Thời lượng mới < 5 phút | Dừng ở 5 phút, MSG-17 |
| E2 | `VERSION_CONFLICT` (block đã đổi từ lịch ngoài / thiết bị khác) | Vẽ theo server, MSG-21 |
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
| 3 | Hệ thống (server) | Lấy giờ làm việc theo channel, sự kiện bận (BR-09), block khác; tìm khe theo BR-08 |
| 4 | Hệ thống | Tạo block, xếp `timebox.push`; client vẽ block, badge cam; toast MSG-09 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Shift+X | `split = false`; chỉ nhận khe đủ dài |
| A2 | Không khe đủ dài, X | Chia ≤ 3 block, mỗi block ≥ 15 phút; toast MSG-09 ghi "{n} khối" |
| A3 | Sự kiện free / cả ngày trong giờ làm việc (EC-17) | Bỏ qua, coi như trống |
| A4 | Task không có planned | Dùng 30 phút |
| A5 | Gọi từ "Dời sang khe trống" của cảnh báo xung đột (UC-07 A3) | Như A1, thay thế block cũ |
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
| Tiền điều kiện | Block `CHO_DONG_BO` / `CHO_XOA` / `LOI` (đang thử lại); tài khoản lịch ghi `HOAT_DONG` / `DONG_BO_CHAM` |
| Hậu điều kiện thành công | Sự kiện ngoài khớp block; block `DA_DONG_BO` (hoặc bản ghi bị xoá với `CHO_XOA`); lưu `externalEventId`, etag |
| Hậu điều kiện thất bại | Block `LOI`, lịch thử lại theo BR-12 |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Lấy block; gộp các thay đổi cùng block trong 2 giây (BR-12) |
| 2 | Hệ thống | Có `externalEventId` → PATCH sự kiện; chưa có → tìm sự kiện có `appBlockId` (BR-11); có thì PATCH, không thì tạo mới |
| 3 | Hệ thống | Dựng nội dung theo bảng map mục 8 |
| 4 | Hệ thống | Lưu `externalEventId`, etag; `DA_DONG_BO`; phát `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Block `CHO_XOA` | DELETE sự kiện; 404 / 410 coi như đã xoá; xoá bản ghi block |
| A2 | Lịch ghi của channel đổi sau khi đã có sự kiện | Giữ sự kiện ở lịch cũ (UC-02 A4) |
| A3 | Sự kiện bị sửa ngoài app (etag khác) trước khi PATCH | Đọc bản mới, áp BR-13 trước rồi mới ghi |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | 429 / rate limit | Theo `Retry-After`; block giữ `CHO_DONG_BO`; người dùng thao tác lúc đó thấy MSG-16 |
| E2 | 5xx / timeout | `LOI`, thử lại BR-12; quá 24 giờ dừng, tooltip MSG-08 "Thử ngay" |
| E3 | 401 / `invalid_grant` (EC-15) | Tài khoản `CAN_KET_NOI_LAI` (BR-16); block giữ `CHO_DONG_BO` |
| E4 | 403 lịch mất quyền ghi | Block `LOI`; SCR-02 đánh dấu lịch chỉ đọc, MSG-15 |
| E5 | Sự kiện đã bị xoá ngoài (404 khi PATCH) | Áp BR-13 xoá block (EC-13), không tạo lại |

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
| 4 | Hệ thống | Sự kiện không có `appTaskId` → cập nhật cache, tính lại `XUNG_DOT` cho block cùng khoảng (BR-14) |
| 5 | Hệ thống | Sự kiện có `appTaskId` → áp BR-13 lên block; ghi nhật ký |
| 6 | Hệ thống | Phát `calendar.changed` / `task.upserted`; G04 tính lại sức chứa, projection |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Sự kiện timebox bị xoá trên lịch ngoài (EC-13) | Xoá block; task về projection; thông báo trong app MSG-14 |
| A2 | Sự kiện timebox bị dời giờ / ngày (EC-14) | Cập nhật block, `startDate`, planned (1 block) theo BR-13; không thông báo, chỉ ghi nhật ký |
| A3 | Cuộc họp bận mới chồng block (EC-16) | Gắn `XUNG_DOT`; card và block hiện cảnh báo **SCR-07** (MSG-13) với "Dời sang khe trống" (UC-05 A5) và "Giữ nguyên" |
| A4 | Sự kiện mới là free / cả ngày (EC-17) | Không gắn `XUNG_DOT` |
| A5 | Google 410 / delta hết hiệu lực | `DANG_DONG_BO`, đồng bộ lại toàn bộ cửa sổ; đối chiếu theo `appBlockId`, không tạo trùng |
| A6 | Sự kiện timebox bị đổi tiêu đề / riêng tư ngoài app | Bỏ qua (BR-13); lần ghi sau ghi đè |
| A7 | Timezone người dùng đổi (EC-02) | Không đổi `startsAt` / `endsAt`; tính lại `startDate` theo BR-15; G04 vẽ lại |
| A8 | Sự kiện chuyển sang ngày có giờ mùa hè (EC-03) | Giữ thời điểm tuyệt đối do lịch ngoài gửi; hiển thị theo giờ địa phương |

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
| 3 | Hệ thống | `DANG_DONG_BO`: đồng bộ lại toàn bộ cửa sổ, đối chiếu sự kiện có `appBlockId` |
| 4 | Hệ thống | Đẩy mọi block `CHO_DONG_BO` / `LOI` theo BR-11 (UC-06); `HOAT_DONG`; ẩn banner |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Ngắt kết nối | SCR-01 → "Ngắt kết nối" → **SCR-08** (MSG-18) → \[CalendarDisconnect\] áp BR-19; toast MSG-19 |
| A2 | Ngắt có tích "Xoá các sự kiện timebox app đã tạo" | Job xoá mọi sự kiện có `appTaskId` trên các lịch của tài khoản |
| A3 | Kết nối lại bằng tài khoản khác email | Tạo tài khoản mới (UC-01); tài khoản cũ vẫn `CAN_KET_NOI_LAI` |
| A4 | Sự kiện timebox đã có trên lịch từ trước khi mất kết nối, block đã đổi trong app | PATCH theo bản trong app (app là nguồn của task) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Kết nối lại vẫn thiếu scope | MSG-02, giữ `CAN_KET_NOI_LAI` |
| E2 | Thu hồi token ở nhà cung cấp lỗi khi ngắt | Vẫn xoá token phía app, ghi log, thử thu hồi lại tối đa 3 lần |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Onboarding bước "Kết nối lịch" (G01) | ✓ | ✓ | UC-01, bỏ qua được |
| Cài đặt → Lịch | ✓ | ✓ | SCR-01, SCR-02 |
| Cài đặt → Context & channel → dòng channel → "Lịch ghi" | ✓ | ✓ | SCR-03 |
| Kéo task vào Calendar views / Today view / panel Calendar (Shift+C) | ✓ | ✓ (nhấn giữ để kéo) | UC-03 |
| Phím X / Shift+X / Ctrl+X, command menu | ✓ | ✓ (desktop) | UC-05, UC-04 A1 |
| Chi tiết task → mục Timebox | ✓ | ✓ | SCR-06 |
| Banner "Cần kết nối lại" / thông báo (G12) | ✓ | ✓ | SCR-09, UC-08 |

## 7. Mô tả màn hình

### SCR-01 Cài đặt → Lịch

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Kết nối Google Calendar" / "Kết nối Outlook" | Button | UC-01; disabled khi đủ 5 tài khoản (MSG-05) |
| 2 | Danh sách tài khoản | List | Logo nhà cung cấp, email, trạng thái 4.1, "Đồng bộ lúc {giờ}"; bấm mở SCR-02 |
| 3 | "Kết nối lại" | Button | Chỉ hiện khi `CAN_KET_NOI_LAI` |
| 4 | "Ngắt kết nối" | Button (nguy hiểm) | Mở SCR-08 |
| 5 | Lịch ghi timebox mặc định | Dropdown | Chỉ lịch có quyền ghi + "Không ghi ra lịch ngoài" |
| 6 | Cài đặt Timebox | Nhóm toggle | Hiện actual trên lịch, Ẩn planned của task xong, Bận / rảnh, Nhắc theo lịch, Tự dời khi xung đột, Tự dời khi xong sớm (G01 khung trang) |

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
| 3 | Giờ làm việc riêng | Time range | Không | Ghi đè giờ làm việc cho auto-schedule (BR-08) |

### SCR-04 Lưới lịch (Calendar views, Today view, panel Calendar)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Cột ngày + trục giờ | Grid | Bước kéo 5 phút; vùng ngoài giờ làm việc tô xám |
| 2 | Sự kiện ngoài | Block | Màu theo lịch; sự kiện free hiện sọc; sự kiện cả ngày ở dải trên cùng |
| 3 | Block timebox | Block | SCR-05 |
| 4 | Projection | Block mờ | Từ G04, mờ hơn sự kiện thật khi bật cài đặt |
| 5 | Block thực tế | Block mảnh | "2:01 – 2:02" (BR-18) |
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

### SCR-06 Timebox trên card và chi tiết task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Badge giờ trên card | Badge cam | Giờ bắt đầu block đầu, ví dụ "10:55"; nhiều block thêm "+n" |
| 2 | Mục Timebox trong chi tiết task | Text + icon lịch | "Thứ Năm, 5/11 · 10:55–11:55 · 1 giờ"; tên lịch ghi; trạng thái 4.2 |
| 3 | "Gỡ khỏi lịch" | Button | Ctrl+X → UC-04 A1 |
| 4 | "Tự xếp lịch" | Button | Chỉ hiện khi chưa có block; X → UC-05 |

### SCR-07 Popover xung đột

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-13 |
| 2 | "Dời sang khe trống" | Button | UC-05 A5 |
| 3 | "Giữ nguyên" | Button | Ẩn cảnh báo cho cặp block – sự kiện này |

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
| \[ChannelCalendarUpdate\] `PATCH /channels/{id}` `[giả định]` | writeCalendarId, workingHours | Channel | 5s / 2 lần |
| \[CalendarDisconnect\] `DELETE /calendar/accounts/{id}` | deleteAppEvents (bool) | 204 | 10s / 1 lần |
| \[CalendarEvents\] `GET /calendar/events?from&to` | from, to (≤ 42 ngày) | Event[] {id, calendarId, title, startsAt, endsAt, allDay, busy, appTaskId?, appBlockId?} | 5s / 1 lần |
| \[TimeboxSet\] `PUT /tasks/{id}/timebox` | startsAt, endsAt, calendarId?, skipReschedule?, blockId?, version, Idempotency-Key | Task + blocks[] {blockId, startsAt, endsAt, syncStatus}, tasksRescheduled[] | 5s / 2 lần cùng key |
| \[TimeboxDelete\] `DELETE /tasks/{id}/timebox` | blockId? (trống = mọi block) | Task | 5s / 2 lần |
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
| `endsAt` + timezone | `end.dateTime`, `end.timeZone` | `end.dateTime`, `end.timeZone` | Như trên; qua nửa đêm ghi liền (EC-04) |
| Bận / rảnh (cài đặt, mặc định bận) | `transparency`: `opaque` / `transparent` | `showAs`: `busy` / `free` | – |
| Riêng tư | `visibility`: `private` / `default` | `sensitivity`: `private` / `normal` | Channel riêng tư → luôn private; khác → mặc định của lịch |
| Nhắc (theo lịch) | `reminders.useDefault = true` | `isReminderOn = true`, `reminderMinutesBeforeStart = 15` `[giả định]` | – |
| Link về task | `description` | `body` (`contentType = text`) | "Mở trong {app}: {url}"; không ghi notes |
| `appTaskId`, `appBlockId` | `extendedProperties.private` | Open extension (`extensionName` `[giả định]`) | Nhận diện, chống trùng (BR-11) |
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
| `WORKSPACE_READ_ONLY` (402) | MSG-20 |
| `VERSION_CONFLICT` (409 / 412), 5xx / timeout, `state` OAuth sai | MSG-21 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Toast | Đã kết nối {email}. Đang tải sự kiện… |
| MSG-02 | Inline | Cần quyền xem và sửa lịch để dùng timebox. Hãy kết nối lại và giữ đủ quyền |
| MSG-03 | Toast | Đã huỷ kết nối {Google Calendar / Outlook} |
| MSG-04 | Toast | {email} đã được kết nối trước đó, đã cập nhật quyền |
| MSG-05 | Inline | Đã đạt tối đa 5 tài khoản lịch |
| MSG-06 | Banner | Mất kết nối {nhà cung cấp} ({email}). {n} timebox đang chờ đồng bộ · Kết nối lại |
| MSG-07 | Tooltip | Đang chờ đồng bộ lên {tên lịch} |
| MSG-08 | Tooltip | Chưa ghi được lên {tên lịch}. Đang thử lại · Thử ngay |
| MSG-09 | Toast | Đã đặt "{tiêu đề}" lúc {giờ bắt đầu}–{giờ kết thúc} · Hoàn tác |
| MSG-10 | Toast | Đã gỡ "{tiêu đề}" khỏi lịch · Hoàn tác |
| MSG-11 | Toast | Hôm nay hết khe trống |
| MSG-12 | Toast | Không có khe đủ dài cho "{tiêu đề}". Nhấn X để chia thành nhiều khối |
| MSG-13 | Popover | Trùng với "{tên sự kiện}" ({giờ}) · Dời sang khe trống · Giữ nguyên |
| MSG-14 | Thông báo trong app | Timebox của "{tiêu đề}" đã được gỡ vì sự kiện bị xoá trên {tên lịch} |
| MSG-15 | Tooltip | Lịch này chỉ đọc, hãy chọn lịch khác để ghi timebox |
| MSG-16 | Toast | {Nhà cung cấp} đang giới hạn tốc độ, timebox sẽ được đồng bộ sau ít phút |
| MSG-17 | Inline | Thời lượng khối từ 5 phút đến 24 giờ |
| MSG-18 | Dialog | Ngắt kết nối {email}? Sự kiện sẽ không hiện trong app nữa; timebox trong app được giữ lại |
| MSG-19 | Toast | Đã ngắt kết nối {email} |
| MSG-20 | Banner | Gói dùng thử đã hết. Nâng cấp để tiếp tục timebox task |
| MSG-21 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-22 | Toast | Tổ chức của bạn chặn ứng dụng truy cập lịch. Hãy liên hệ quản trị viên |
| MSG-23 | Toast | Đã dời {n} task để nhường chỗ · Hoàn tác |
| MSG-24 | Tooltip | Giờ này không tồn tại do đổi giờ, đã đặt lúc {giờ} |
| MSG-25 | Toast | Task này đã bị xoá |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Block hiện trong app ≤ 100 ms sau khi thả (lạc quan); \[TimeboxSet\] p95 ≤ 300 ms; timebox xuất hiện trên lịch ngoài ≤ 10 giây (p95); thay đổi lịch ngoài về app ≤ 1 phút qua webhook, ≤ 15 phút qua poll; \[TimeboxAuto\] ≤ 1 giây |
| Offline | Tạo / dời / gỡ timebox khi mất mạng, block `CHO_DONG_BO`; sự kiện ngoài hiện bản cache 4 tuần; đồng bộ lại qua \[SyncBatch\] không tạo trùng |
| Độ tin cậy | 0 sự kiện trùng `appBlockId`; job `timebox.push`, `calendar.sync` idempotent; lỗi đồng bộ > 2% trong 10 phút → cảnh báo vận hành |
| Bảo mật | Token OAuth mã hoá AES-256-GCM, không trả về client, thu hồi khi ngắt kết nối / xoá tài khoản (G01); webhook xác thực bằng channel token / `clientState`; scope tối thiểu (BR-02); không ghi notes ra ngoài; channel riêng tư luôn Private |
| Log / audit | \[ActivityLog\] cho tạo / dời / gỡ timebox, tác nhân `user` / `integration` / `system`; log hệ thống không chứa tiêu đề task, tiêu đề sự kiện |
| Tracking | Sự kiện: `calendar_connect_started` (provider), `calendar_connected`, `calendar_connect_failed` (lý do), `calendar_reconnected`, `calendar_disconnected`, `calendar_visibility_changed`, `timebox_created` (cách: kéo / X / Shift+X), `timebox_moved`, `timebox_resized`, `timebox_removed`, `auto_schedule_no_slot`, `timebox_push_failed`, `external_event_deleted_timebox_removed`, `conflict_shown`, `conflict_resolved` (dời / giữ) |
| Accessibility | WCAG 2.1 AA; timebox làm được không cần kéo (X, lệnh "Timebox…" trong command menu, nhập giờ trong chi tiết task); block có nhãn đọc màn hình "{tiêu đề}, {giờ bắt đầu} đến {giờ kết thúc}, {trạng thái đồng bộ}"; xung đột không chỉ dùng màu |
| Tuân thủ nhà cung cấp | Đạt yêu cầu xác minh Google OAuth (scope nhạy cảm) trước khi mở cho người dùng ngoài danh sách thử nghiệm; tuân thủ chính sách dữ liệu người dùng Google API |
