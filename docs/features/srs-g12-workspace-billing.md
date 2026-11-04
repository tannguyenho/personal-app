> **Mã:** PLN-SRS-G12-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g12-workspace-billing.md

# UC-G12 - Workspace, thành viên, quyền riêng tư & thanh toán trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này mô tả trial, thanh toán, chế độ chỉ đọc, cài đặt Thông báo và trung tâm thông báo (bản 1.0); mời thành viên, vai trò, Privacy, giao / follow task (bản 1.1). Đăng ký, tài khoản, xuất / xoá dữ liệu (G01), context & channel (G02), backlog (G06), timer (G07), ritual (G08, G09) và nội dung các sự kiện thông báo phát sinh ở nhóm khác (G05, G07, G08, G09, G11) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng biết rõ trạng thái gói, nâng cấp nhanh, không mất dữ liệu khi hết hạn; nhóm dùng chung workspace mà việc cá nhân vẫn riêng tư; ai cũng nhận đúng thông báo qua đúng kênh |
| Actor | Chủ sở hữu · Quản trị (1.1) · Thành viên (1.1) · Người được mời (1.1) · Hệ thống · Cổng thanh toán · Dịch vụ gửi email |
| Phạm vi | 1.0: trial, nâng cấp, gia hạn, thử lại, đổi gói / ghế, huỷ, hoá đơn, chỉ đọc, cài đặt Thông báo, trung tâm thông báo, huỷ đăng ký email, Team changes, audit log. 1.1: mời (email, link), vai trò, xoá / rời, chuyển quyền sở hữu, xoá workspace, Privacy, giao task, follow task |
| Ngoài phạm vi | Giới thiệu bạn bè, danh sách gói / giá / quyền theo gói (chưa định nghĩa), SSO / SCIM, Slack / Teams làm kênh thông báo (1.2, G11) |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả (thêm kênh mobile push, thông báo hệ thống desktop) |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Chủ sở hữu đang dùng thử | Thấy số ngày trial còn lại và được nhắc trước khi hết | Không bị gián đoạn bất ngờ |
| US-02 | Chủ sở hữu | Nâng cấp trong vài bước qua cổng thanh toán quen thuộc | Tiếp tục dùng ngay |
| US-03 | Chủ sở hữu | Được thử lại khi gia hạn lỗi, vẫn xem / xuất dữ liệu khi hết hạn | Không mất khách, không mất dữ liệu |
| US-04 | Chủ sở hữu | Đổi chu kỳ, số ghế, huỷ gói, tải hoá đơn | Tự quản lý chi phí |
| US-05 | Chủ sở hữu / Quản trị | Mời đồng nghiệp bằng email hoặc link, đổi vai trò, xoá thành viên | Quản lý nhóm |
| US-06 | Thành viên | Chọn loại dữ liệu nào người khác thấy | Giữ việc cá nhân riêng tư |
| US-07 | Thành viên | Giao task cho đồng nghiệp, theo dõi task quan tâm | Biết ai làm gì, việc nào xong |
| US-08 | Người dùng | Bật / tắt từng loại thông báo theo kênh, xem lại trong app | Không bị làm phiền, không bỏ lỡ việc quan trọng |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Vai trò.** `OWNER` (đúng 1 / workspace), `ADMIN`, `MEMBER`. Quyền theo ma trận PRD mục 5, kiểm tra ở server cho mọi API; client chỉ ẩn / disable nút. 1.0: workspace chỉ có 1 người, là `OWNER` |
| BR-02 | **Trial.** Bắt đầu khi tạo workspace (G01), kéo dài 14 ngày (kết thúc đúng 14 × 24 giờ sau khi tạo `[giả định]`), không cần thẻ, đủ tính năng của bản đang phát hành. Nhắc khi còn 3 ngày và 1 ngày: email + banner + thông báo trong app (MSG-42) |
| BR-03 | **Checkout.** Chọn chu kỳ tháng / năm và số ghế (≥ thành viên + lời mời đang chờ; 1.0 cố định 1). Thanh toán trên trang của cổng (hosted checkout); app không nhận, không lưu số thẻ (PCI DSS). Gói chỉ chuyển `HOAT_DONG` khi webhook của cổng xác nhận, không theo trang chuyển hướng |
| BR-04 | **Webhook.** Xác thực chữ ký; idempotent theo ID giao dịch / ID sự kiện của cổng (EC-35); sự kiện có thời điểm cũ hơn trạng thái hiện tại thì ghi nhận nhưng không đổi trạng thái; mọi sự kiện lưu vào nhật ký thanh toán |
| BR-05 | **Gia hạn.** Đến kỳ, cổng tự thu. Lỗi → `THU_LAI`, thử lại ngày 1, 3, 7 sau ngày đến hạn; mỗi lần lỗi email + thông báo cho chủ sở hữu. Trong `THU_LAI` vẫn dùng đầy đủ. Lần ngày 7 lỗi → `CHI_DOC` |
| BR-06 | **Chỉ đọc.** Áp khi hết trial chưa trả, hết kỳ sau khi huỷ, hoặc thử lại ngày 7 lỗi. Mọi API ghi dữ liệu nghiệp vụ (task, lịch, ritual, timer, channel, mời) trả 402 `WORKSPACE_READ_ONLY`. Vẫn cho: đọc, xuất dữ liệu (G01), thanh toán, cài đặt tài khoản / thông báo, đăng xuất. Timer đang chạy bị dừng và lưu `[giả định]`; ngừng ghi timebox ra lịch ngoài (G05). Giữ dữ liệu 90 ngày `[giả định]`, email nhắc trước 30 và 7 ngày `[giả định]`, sau đó xoá theo quy trình xoá của G01 |
| BR-07 | **Hết hạn giữa thao tác (EC-34).** Ritual hoặc thao tác bắt đầu trước thời điểm hết hạn được hoàn tất (ân hạn tối đa 2 giờ `[giả định]`); thao tác mới sau thời điểm đó bị chặn theo BR-06 |
| BR-08 | **Đổi gói / số ghế.** Tăng ghế, tháng → năm: tính theo tỷ lệ phần kỳ còn lại, thu ngay. Giảm ghế: không thấp hơn thành viên + lời mời đang chờ, hiệu lực kỳ sau `[giả định]`. Năm → tháng: hiệu lực cuối kỳ `[giả định]`. Luôn hiện số tiền trước khi xác nhận (MSG-10) |
| BR-09 | **Huỷ gói.** Hiệu lực cuối kỳ (`CHO_HUY`), trước đó "Tiếp tục gói" được; không hoàn tiền phần còn lại `[giả định]`; hết kỳ → `CHI_DOC`. Xoá tài khoản / xoá workspace huỷ gói ngay |
| BR-10 | **Hoá đơn.** Mỗi lần thu thành công sinh hoá đơn PDF (gói, kỳ, số ghế, số tiền, thuế `[giả định]`), gửi email cho chủ sở hữu, tải lại được trong Billing |
| BR-11 | **Mời qua email (1.1).** 1–20 email / lần; mỗi email kèm tên (tuỳ chọn) và vai trò `ADMIN` / `MEMBER` (mặc định `MEMBER`; Sunsama không cho chọn — khác có chủ đích). Lời mời hết hạn sau 7 ngày, thu hồi được, "Gửi lại" đặt hạn mới. Email đã là thành viên / đang có lời mời chờ → không gửi, trả về danh sách bỏ qua (EC-32). Lời mời gắn với email: chấp nhận phải đăng nhập đúng email đó `[giả định]`. Chấp nhận → +1 ghế, tính theo BR-08 (trong trial không tính tiền `[giả định]`) |
| BR-12 | **Link mời chung (1.1).** Mỗi workspace 1 link, vai trò `MEMBER`; "Tạo link mới" vô hiệu link cũ; "Tắt mời qua link" (Privacy, cấp workspace) → link trả `LINK_INVITES_DISABLED` |
| BR-13 | **Xoá / rời thành viên (EC-31).** Trong một giao dịch: dừng và lưu timer đang chạy; task được giao chưa xong chuyển về người giao; thu hồi phiên vào workspace, phát `session.revoked`, đăng xuất ≤ 1 phút; ghế giảm từ kỳ sau. Dữ liệu riêng của người rời: ẩn, giữ 30 ngày rồi xoá `[giả định]`. Tài khoản không còn workspace → lần đăng nhập sau tạo workspace cá nhân mới như G01 `[giả định]` |
| BR-14 | **Chủ sở hữu (EC-36).** Chủ sở hữu duy nhất không rời workspace, không xoá tài khoản (G01) khi workspace còn thành viên khác. Chuyển quyền sở hữu: chỉ `OWNER`, cần xác nhận lại mật khẩu (như G01), người nhận thành `OWNER`, người cũ thành `ADMIN`, billing theo chủ sở hữu mới, cả hai nhận email. Xoá workspace: chỉ `OWNER`, gõ đúng tên workspace `[giả định]`; huỷ gói, đăng xuất mọi thành viên, dữ liệu xoá ≤ 30 ngày |
| BR-15 | **Privacy (1.1).** Mỗi người tự đặt cho dữ liệu của mình: 6 loại (Task, Highlights, Channel, Lịch, Ghi chú cuộc họp, Tích hợp) × "Chỉ mình tôi" / "Thành viên"; mặc định "Chỉ mình tôi". Channel private (G02) luôn ẩn với người khác. Quyền kiểm tra ở tầng truy vấn server. Đổi sang "Chỉ mình tôi" → người khác mất quyền ≤ 5 giây (EC-33) |
| BR-16 | **Giao task (1.1).** Chỉ giao cho thành viên cùng workspace; task trong channel private không giao được `[giả định]`. Người được giao nhận task vào backlog của họ (G06) + thông báo MSG-40 (trong app + email). Người giao tự động follow `[giả định]`. Giao lại → người mới nhận MSG-40, task rời backlog người cũ. Ghi \[ActivityLog\] (G02) |
| BR-17 | **Follow (1.1).** Người follow nhận MSG-41 khi task được tạo (với task tạo sẵn người follow), giao lại, hoàn thành, có comment mới; không gửi cho chính người thực hiện hành động |
| BR-18 | **Cài đặt thông báo.** Bảng sự kiện × kênh (Trong app, Email, Mobile push 1.1, Desktop 1.1) với mặc định theo PRD mục 5; lưu trong cài đặt người dùng (\[SettingsUpdate\] của G01). Email "Trial sắp hết" và "Gia hạn lỗi" bắt buộc, không tắt được `[giả định]`. Product updates mặc định tắt `[giả định]`. Sự kiện / kênh chưa phát hành không hiện |
| BR-19 | **Gửi thông báo.** Gộp mọi thông báo cùng task, cùng người nhận trong 5 phút thành 1 (MSG-43). Email (trừ bắt buộc) có link huỷ đăng ký 1 chạm không cần đăng nhập, tắt đúng sự kiện × email, kèm header List-Unsubscribe `[giả định]`. Email lỗi tạm thời thử lại 3 lần `[giả định]`; bị trả về (bounce) cứng → ngừng gửi email tới địa chỉ đó, báo trong app |
| BR-20 | **Trung tâm thông báo.** Lưu 90 ngày `[giả định]`; badge số chưa đọc, tối đa "99+"; mới nhất trước, cursor pagination; đọc trên một thiết bị → đồng bộ thiết bị khác qua realtime ≤ 5 giây |
| BR-21 | **Audit / Team changes.** Ghi mọi hành động quản trị và thanh toán (mời, thu hồi, chấp nhận, đổi vai trò, xoá / rời, chuyển quyền, tắt / tạo link mời, nâng cấp, đổi gói, huỷ, gia hạn lỗi, chuyển chỉ đọc): tác nhân, đối tượng, giá trị cũ / mới, thời điểm. Team changes hiện cho `OWNER` / `ADMIN` dạng "{A} trở thành Quản trị (do {B} nâng quyền)" |

## 4. Trạng thái

### 4.1. Trạng thái gói

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DUNG_THU` | Trong 14 ngày trial, chưa thanh toán | Billing "Dùng thử · {n} ghế · còn {d} ngày"; banner MSG-01 khi còn ≤ 3 ngày |
| `HOAT_DONG` | Đã thanh toán, kỳ hiện tại còn hạn | Billing hiện gói, ngày gia hạn |
| `THU_LAI` | Gia hạn lỗi, đang trong lịch thử lại ngày 1, 3, 7 | Banner đỏ MSG-02 cho chủ sở hữu; dùng đầy đủ |
| `CHO_HUY` | Đã huỷ, kỳ hiện tại còn hạn | Billing "Kết thúc ngày {ngày}" + "Tiếp tục gói" |
| `CHI_DOC` | Hết trial chưa trả / hết kỳ sau huỷ / thử lại ngày 7 lỗi | Banner MSG-03 cho mọi thành viên; thao tác ghi bị chặn |

Chuyển trạng thái: `DUNG_THU` → `HOAT_DONG` (UC-01) hoặc → `CHI_DOC` (hết trial, UC-02) · `HOAT_DONG` → `THU_LAI` → `HOAT_DONG` / `CHI_DOC` (UC-02) · `HOAT_DONG` ⇄ `CHO_HUY` (UC-03) · `CHO_HUY` → `CHI_DOC` (hết kỳ) · `CHI_DOC` → `HOAT_DONG` (UC-01). `CHI_DOC` quá 90 ngày → xoá dữ liệu (BR-06).

### 4.2. Trạng thái lời mời và thông báo

Lời mời: `CHO_CHAP_NHAN` → `DA_CHAP_NHAN` (UC-04) / `HET_HAN` (sau 7 ngày) / `DA_THU_HOI`. "Gửi lại" đưa `HET_HAN` về `CHO_CHAP_NHAN` với hạn mới. Thông báo: `CHUA_DOC` → `DA_DOC` (UC-09).

## 5. Use Case

### UC-01 Nâng cấp gói (1.0)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng là `OWNER`; gói `DUNG_THU` hoặc `CHI_DOC` |
| Hậu điều kiện thành công | Gói `HOAT_DONG`; hoá đơn PDF; email xác nhận; banner gỡ, hết chỉ đọc; Team changes ghi |
| Hậu điều kiện thất bại | Gói giữ trạng thái cũ; không bị trừ tiền nếu cổng chưa xác nhận |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu | Bấm "Nâng cấp" trên **SCR-01**, **SCR-02** hoặc link trong email nhắc |
| 2 | Hệ thống | Gọi \[BillingGet\]; mở **SCR-03**: chu kỳ tháng / năm, số ghế (1.0 cố định 1), tổng tiền, ngày gia hạn kế tiếp |
| 3 | Chủ sở hữu | Chọn chu kỳ (1.1: số ghế), bấm "Thanh toán" |
| 4 | Hệ thống | Gọi \[BillingCheckout\] (Idempotency-Key); chuyển tới `checkoutUrl` của cổng |
| 5 | Chủ sở hữu | Thanh toán trên trang của cổng |
| 6 | Cổng thanh toán | Gửi webhook → \[BillingWebhook\]: áp BR-04; gói `HOAT_DONG`; sinh hoá đơn (BR-10); gửi email; ghi BR-21 |
| 7 | Hệ thống | Cổng chuyển về app → SCR-03 hiện MSG-04, gọi \[BillingGet\] mỗi 3 giây tối đa 60 giây `[giả định]`; thấy `HOAT_DONG` → toast MSG-06, gỡ banner, bỏ chỉ đọc |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Quá 60 giây chưa có xác nhận | MSG-05; webhook đến sau → email + thông báo trong app, gói kích hoạt bình thường |
| A2 | Webhook đến trước khi người dùng quay về app | Bước 7 thấy `HOAT_DONG` ngay ở lần gọi đầu |
| A3 | `ADMIN` / `MEMBER` bấm "Nâng cấp" (1.1) | SCR-03 chỉ đọc, ghi "Chỉ chủ sở hữu thanh toán được", nút "Nhắc chủ sở hữu" gửi thông báo trong app `[giả định]` |
| A4 | Đang `CHI_DOC` | Thanh toán xong bỏ chỉ đọc ngay; dữ liệu giữ nguyên |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Người dùng huỷ trên cổng / thẻ bị từ chối | Cổng chuyển về SCR-03 kèm trạng thái huỷ; MSG-07 |
| E2 | \[BillingCheckout\] lỗi / cổng không phản hồi | MSG-08; giữ lựa chọn trên SCR-03 |
| E3 | Webhook trùng (EC-35) | Bỏ qua, trả 200, không sinh hoá đơn thứ hai |
| E4 | Webhook sai chữ ký | Trả 400, không đổi trạng thái, cảnh báo nội bộ |

### UC-02 Hết trial, gia hạn, thử lại và chế độ chỉ đọc (1.0)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Gói `DUNG_THU`, `HOAT_DONG`, `THU_LAI` hoặc `CHO_HUY` |
| Hậu điều kiện thành công | Gói chuyển đúng theo mục 4.1; chủ sở hữu được báo trước mỗi thay đổi |
| Hậu điều kiện thất bại | Trạng thái không đổi; job chạy lại không tạo thông báo / hoá đơn trùng |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job `billing.lifecycle` `[giả định]` chạy mỗi 15 phút, quét workspace tới mốc |
| 2 | Hệ thống | Trial còn 3 ngày / 1 ngày → MSG-42 trong app + email; SCR-01 hiện MSG-01 (BR-02) |
| 3 | Hệ thống | Tới thời điểm hết trial, chưa thanh toán → `CHI_DOC` (BR-06), áp BR-07 cho thao tác đang dở; ghi BR-21 |
| 4 | Hệ thống | SCR-01 hiện MSG-03 cho mọi thành viên; thao tác ghi trả 402 → MSG-03 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Gói `HOAT_DONG` tới kỳ gia hạn, cổng thu thành công | Webhook → kỳ mới, hoá đơn (BR-10), email |
| A2 | Gia hạn lỗi | `THU_LAI`; MSG-02 cho chủ sở hữu; email kèm link cập nhật phương thức thanh toán; thử lại ngày 1, 3, 7 (BR-05) |
| A3 | Một lần thử lại thành công / chủ sở hữu cập nhật thẻ và thanh toán | `HOAT_DONG`, gỡ MSG-02 |
| A4 | Lần thử ngày 7 lỗi | `CHI_DOC` như bước 3–4 |
| A5 | `CHO_HUY` tới cuối kỳ | `CHI_DOC` như bước 3–4 |
| A6 | Người dùng đang làm Daily planning / shutdown lúc hết hạn (EC-34) | Cho hoàn tất ritual (BR-07); sau đó banner MSG-03 |
| A7 | `CHI_DOC` còn 30 / 7 ngày tới mốc xoá | Email cho chủ sở hữu; quá 90 ngày → xoá dữ liệu (BR-06) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Job chạy lại / chạy trùng | Idempotent theo workspace + mốc; không gửi nhắc trùng |
| E2 | Webhook đến sai thứ tự | Áp BR-04: sự kiện cũ hơn trạng thái hiện tại không đổi trạng thái |
| E3 | Đối soát hằng ngày `[giả định]` thấy lệch với cổng | Cảnh báo nội bộ; trạng thái theo dữ liệu cổng sau khi kiểm tra |

### UC-03 Đổi gói, số ghế, huỷ gói và tải hoá đơn (1.0)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng là `OWNER`; gói `HOAT_DONG`, `THU_LAI` hoặc `CHO_HUY` |
| Hậu điều kiện thành công | Gói / số ghế / trạng thái huỷ cập nhật theo BR-08, BR-09; Team changes ghi |
| Hậu điều kiện thất bại | Gói giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu | SCR-02 → "Đổi gói" → SCR-03 ở chế độ đổi |
| 2 | Chủ sở hữu | Chọn chu kỳ / số ghế mới |
| 3 | Hệ thống | Gọi \[BillingUpdate\] với `preview=true`; hiện MSG-10 (số tiền theo tỷ lệ, giá kỳ sau) |
| 4 | Chủ sở hữu | Bấm "Xác nhận" |
| 5 | Hệ thống | Gọi \[BillingUpdate\]; cổng thu phần chênh (nếu có); webhook xác nhận → MSG-11 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Huỷ gói | SCR-02 → "Huỷ gói" → **SCR-04** → \[BillingCancel\] → `CHO_HUY`, MSG-12 |
| A2 | Tiếp tục gói đã huỷ | SCR-02 → "Tiếp tục gói" → \[BillingResume\] → `HOAT_DONG`, MSG-13 |
| A3 | Tải hoá đơn | SCR-02 danh sách hoá đơn (\[InvoiceList\]) → "PDF" |
| A4 | Cập nhật phương thức thanh toán | Chuyển tới trang quản lý của cổng `[giả định]`; quay về SCR-02 |
| A5 | Năm → tháng, giảm ghế | Ghi "Có hiệu lực từ {ngày}" (BR-08), không thu ngay |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Số ghế < thành viên + lời mời đang chờ | MSG-09, chặn xác nhận |
| E2 | Thu phần chênh lỗi | Giữ gói cũ, MSG-07 |
| E3 | Không phải `OWNER` | MSG-14 |
| E4 | Lỗi 5xx | MSG-38 |

### UC-04 Mời thành viên (1.1)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người mời là `OWNER` / `ADMIN`; workspace không `CHI_DOC` |
| Hậu điều kiện thành công | Lời mời `CHO_CHAP_NHAN`, email đã gửi; khi chấp nhận: thành viên mới, ghế +1, Team changes ghi |
| Hậu điều kiện thất bại | Không có lời mời mới |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu / Quản trị | Cài đặt → Thành viên (**SCR-05**) → "Thêm đồng nghiệp" → **SCR-06** |
| 2 | Chủ sở hữu / Quản trị | Nhập email, tên (tuỳ chọn), vai trò; "Thêm người" cho dòng mới |
| 3 | Hệ thống | Kiểm tra định dạng, ≤ 20 dòng; hiện số ghế sau khi mời và số tiền tăng theo tỷ lệ (BR-11) |
| 4 | Chủ sở hữu / Quản trị | Bấm "Gửi lời mời" |
| 5 | Hệ thống | Gọi \[InviteCreate\]; bỏ email trùng (EC-32); tạo lời mời 7 ngày, gửi email; MSG-17; SCR-05 hiện mục "Đang chờ" |
| 6 | Người được mời | Mở link → **SCR-13** → đăng ký / đăng nhập (G01) → \[InviteAccept\] → vào thẳng workspace |
| 7 | Hệ thống | Lời mời `DA_CHAP_NHAN`; ghế +1 (BR-08); Team changes ghi; người mời nhận thông báo trong app |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Dùng link mời chung | SCR-06 "Link đăng ký" → "Sao chép link" → MSG-18; "Tạo link mới" → MSG-19 → \[InviteLinkRotate\] (BR-12) |
| A2 | "Gửi lại" lời mời đang chờ / hết hạn | \[InviteResend\]; hạn mới 7 ngày |
| A3 | "Thu hồi" lời mời | \[InviteRevoke\] → `DA_THU_HOI`; link trả MSG-20 |
| A4 | Workspace đang `DUNG_THU` | Không hiện số tiền tăng; ghi "Ghế được tính khi nâng cấp" `[giả định]` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | > 20 email / email sai định dạng | MSG-15 / MSG-16 tại dòng lỗi |
| E2 | Link hết hạn / bị thu hồi / link chung đã tạo mới | SCR-13 hiện MSG-20 |
| E3 | Link chung khi đã bật "Tắt mời qua link" | SCR-13 hiện MSG-21 |
| E4 | Người nhận đăng nhập bằng email khác email được mời | MSG-44, nút "Đăng xuất và đăng nhập email khác" |
| E5 | Người gọi là `MEMBER` / workspace `CHI_DOC` | MSG-14 / MSG-03 |

### UC-05 Quản lý thành viên và workspace (1.1)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người thao tác có quyền theo BR-01 (đổi vai trò, xoá: `OWNER` / `ADMIN`; chuyển quyền, xoá workspace: `OWNER`; rời: mọi vai trò) |
| Hậu điều kiện thành công | Vai trò / thành viên / chủ sở hữu / workspace thay đổi theo BR-13, BR-14; Team changes ghi |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu / Quản trị | SCR-05 → menu vai trò trên dòng thành viên |
| 2 | Chủ sở hữu / Quản trị | Chọn `ADMIN` / `MEMBER` |
| 3 | Hệ thống | Gọi \[MemberUpdate\]; quyền mới áp dụng từ request kế tiếp; Team changes ghi (BR-21); MSG-22 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Xoá thành viên | Menu … → "Xoá khỏi workspace" → **SCR-07** (MSG-23) → \[MemberRemove\] → BR-13 → MSG-24; người bị xoá thấy MSG-28 |
| A2 | Chuyển quyền sở hữu | SCR-05 → "Chuyển quyền sở hữu" → SCR-07 chọn người + mật khẩu → \[OwnershipTransfer\] → MSG-26 (BR-14) |
| A3 | Rời workspace (`ADMIN` / `MEMBER`) | SCR-05 → "Rời workspace" → xác nhận → \[MemberLeave\] → BR-13 |
| A4 | Xoá workspace | Cài đặt → Workspace (**SCR-12**) → "Xoá workspace" → gõ tên → \[WorkspaceDelete\] (BR-14) |
| A5 | Đổi tên workspace | SCR-12 → \[WorkspaceUpdate\]; lưu ngay |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | `ADMIN` đổi vai trò / xoá `OWNER`; `MEMBER` gọi API quản trị | MSG-14 |
| E2 | Chủ sở hữu duy nhất rời workspace khi còn thành viên (EC-36) | MSG-25, nút "Chuyển quyền sở hữu" |
| E3 | Tên workspace gõ không khớp / mật khẩu sai | MSG-27 / thông báo của G01 |
| E4 | Lỗi 5xx | MSG-38 |

### UC-06 Cài đặt quyền riêng tư (1.1)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Workspace có ≥ 2 thành viên hoặc lời mời đang chờ (ngược lại SCR-08 vẫn mở được, chỉ có ghi chú) |
| Hậu điều kiện thành công | Cài đặt Privacy của người dùng lưu; quyền xem của người khác cập nhật ≤ 5 giây |
| Hậu điều kiện thất bại | Giữ cài đặt cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Privacy (**SCR-08**) |
| 2 | Hệ thống | Gọi \[PrivacyGet\]; hiện 6 loại dữ liệu và ghi chú MSG-29 |
| 3 | Người dùng | Đổi một loại giữa "Chỉ mình tôi" / "Thành viên" |
| 4 | Hệ thống | Gọi \[PrivacyUpdate\]; phát `settings.changed`; quyền xem của thành viên khác cập nhật ≤ 5 giây (BR-15) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | `OWNER` / `ADMIN` bật "Tắt mời qua link" | \[PrivacyUpdate\] cấp workspace; link chung trả MSG-21 (BR-12) |
| A2 | Thành viên khác đang xem dữ liệu vừa chuyển "Chỉ mình tôi" (EC-33) | Phía họ ẩn dữ liệu, đóng chi tiết đang mở, MSG-30 |
| A3 | Task trong channel private | Luôn ẩn với người khác, bất kể cài đặt |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[PrivacyUpdate\] lỗi | Trả về giá trị cũ, MSG-38 |
| E2 | `MEMBER` đổi "Tắt mời qua link" | Toggle disabled; API trả MSG-14 |

### UC-07 Giao task và follow task (1.1)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task tồn tại, không ở `DA_XOA` (G02); người thao tác thấy được task (BR-15); workspace không `CHI_DOC` |
| Hậu điều kiện thành công | Người được giao / người follow cập nhật; thông báo gửi theo BR-16, BR-17; nhật ký task ghi |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Chi tiết task (G02) → ô "Giao cho" (**SCR-09**) → chọn thành viên |
| 2 | Hệ thống | Gọi \[TaskAssign\]; task vào backlog của người được giao (G06); người giao tự follow |
| 3 | Hệ thống | Gửi MSG-40 cho người được giao (trong app + email theo cài đặt); \[ActivityLog\] ghi "giao cho {tên}"; toast MSG-31 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Giao lại cho người khác | Người mới nhận MSG-40; người follow nhận MSG-41; task rời backlog người cũ |
| A2 | Bỏ giao | Task về backlog của người giao `[giả định]` |
| A3 | Bấm "Theo dõi" / "Bỏ theo dõi" | \[TaskFollow\] / \[TaskUnfollow\]; MSG-33 |
| A4 | Task được follow hoàn thành / có comment | Người follow (trừ người thực hiện) nhận MSG-41 (BR-17) |
| A5 | Nhiều cập nhật cùng task trong 5 phút | Gộp thành MSG-43 (BR-19) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Người được chọn không còn là thành viên | MSG-32, làm mới danh sách |
| E2 | Task thuộc channel private | Ô "Giao cho" disabled, tooltip MSG-45 |
| E3 | Workspace `CHI_DOC` / lỗi 5xx | MSG-03 / MSG-38 |

### UC-08 Cài đặt thông báo và huỷ đăng ký email (1.0)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập (huỷ đăng ký từ email: không cần) |
| Hậu điều kiện thành công | Ô sự kiện × kênh lưu; thông báo sau đó gửi theo cài đặt mới |
| Hậu điều kiện thất bại | Giữ cài đặt cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Thông báo (**SCR-10**) |
| 2 | Hệ thống | Gọi \[SettingsGet\] (nhóm `notifications`); hiện bảng sự kiện × kênh của bản đang phát hành (BR-18) |
| 3 | Người dùng | Bật / tắt một ô |
| 4 | Hệ thống | Gọi \[SettingsUpdate\]; hiện ✓ "Đã lưu" như G01; áp dụng cho thông báo kế tiếp |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Ô bắt buộc | Khoá, tooltip MSG-34 |
| A2 | Bấm link "Huỷ nhận loại email này" trong email | \[Unsubscribe\] với token → tắt đúng sự kiện × email → **SCR-14** MSG-35, nút "Bật lại" |
| A3 | Recap tuần: thêm người nhận | Mở cài đặt của G09 |
| A4 | Trình duyệt chưa cho phép thông báo (desktop / mobile, 1.1) | Hiện nút "Cho phép thông báo" gọi quyền của hệ điều hành |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Token huỷ đăng ký sai / hết hạn | SCR-14 hiện MSG-36 |
| E2 | \[SettingsUpdate\] lỗi | Trả ô về giá trị cũ, MSG-38 |

### UC-09 Trung tâm thông báo (1.0)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | Thông báo hiện đúng người nhận, đúng kênh; trạng thái đọc đồng bộ mọi thiết bị |
| Hậu điều kiện thất bại | Thông báo giữ `CHUA_DOC` |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Nhận sự kiện từ nhóm phát sinh; áp cài đặt người nhận (BR-18), gộp 5 phút (BR-19); tạo thông báo `CHUA_DOC`; phát `notification.created`; gửi email nếu kênh bật |
| 2 | Hệ thống | Chuông trên thanh điều hướng tăng badge ≤ 5 giây |
| 3 | Người dùng | Bấm chuông → **SCR-11**; hệ thống gọi \[NotificationList\] |
| 4 | Người dùng | Bấm một thông báo → mở đúng đích (task, Billing, Cài đặt lịch…); \[NotificationRead\] đánh dấu `DA_DOC` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Đánh dấu tất cả đã đọc" | \[NotificationRead\] `all=true`; badge về 0 trên mọi thiết bị |
| A2 | Đích không còn (task đã xoá, mất quyền xem) | Giữ SCR-11 mở, toast MSG-30 |
| A3 | Cuộn tới cuối danh sách | Tải trang kế (cursor) |
| A4 | Thông báo quá 90 ngày | Tự xoá (BR-20) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[NotificationList\] lỗi / mất mạng | SCR-11 hiện danh sách đã cache + MSG-38 "Thử lại" |
| E2 | Email bị trả về cứng | Ngừng email tới địa chỉ đó, tạo thông báo trong app "Email của bạn không nhận được thư" `[giả định]` (BR-19) |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Banner trial / gia hạn lỗi / chỉ đọc trên Home | ✓ | ✓ | SCR-01 → SCR-03 |
| Email nhắc trial, gia hạn lỗi | ✓ | ✓ (deep link) | SCR-03 / trang cổng |
| Cài đặt → Billing | ✓ | ✓ | SCR-02 |
| Cài đặt → Thành viên / menu workspace "Mời đồng nghiệp" | ✓ (1.1) | ✓ | SCR-05, SCR-06 |
| Link mời trong email / link mời chung | ✓ (1.1) | ✓ | SCR-13 → G01 |
| Cài đặt → Privacy | ✓ (1.1) | ✓ | SCR-08 |
| Chi tiết task → "Giao cho" / "Theo dõi" | ✓ (1.1) | ✓ | SCR-09 |
| Cài đặt → Thông báo | ✓ | ✓ | SCR-10 |
| Chuông trên thanh điều hướng | ✓ | ✓ | SCR-11 |
| Link "Huỷ nhận loại email này" | ✓ | – | SCR-14 |

## 7. Mô tả màn hình

### SCR-01 Banner gói

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Banner trial | Banner (thông tin) | MSG-01, chỉ chủ sở hữu, khi còn ≤ 3 ngày; đóng được, hiện lại ngày hôm sau |
| 2 | Banner gia hạn lỗi | Banner (đỏ) | MSG-02, chỉ chủ sở hữu, không đóng được |
| 3 | Banner chỉ đọc | Banner (đỏ) | MSG-03 cho mọi thành viên; `ADMIN` / `MEMBER` thấy "Liên hệ chủ sở hữu" thay nút "Nâng cấp" |

### SCR-02 Billing

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Thẻ gói | Card | "{Gói} · {n} ghế · {còn d ngày / gia hạn ngày …}" (Sunsama: "Sunsama Free Trial · 1 seat · 14 days remaining") |
| 2 | "Nâng cấp" / "Đổi gói" | Button | SCR-03 |
| 3 | Phương thức thanh toán | Text + link | Loại thẻ / ví, 4 số cuối do cổng trả về; "Cập nhật" → A4 UC-03 |
| 4 | Hoá đơn | List | Ngày, số tiền, trạng thái, "PDF" |
| 5 | Team changes | List | Nhật ký BR-21 mới nhất trước; chỉ `OWNER` / `ADMIN` |
| 6 | "Huỷ gói" / "Tiếp tục gói" | Link | SCR-04 / A2 UC-03 |

`ADMIN` / `MEMBER` (1.1) chỉ thấy mục 1 và 5 (`ADMIN`).

### SCR-03 Chọn / đổi gói

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Chu kỳ | Segmented Tháng / Năm | Có | Hiện giá và mức tiết kiệm của gói năm (giá: câu hỏi mở) |
| 2 | Số ghế | Stepper | Có | ≥ thành viên + lời mời chờ (MSG-09); 1.0 cố định 1, ẩn stepper |
| 3 | Tổng tiền, ngày gia hạn kế tiếp | Text | – | Chế độ đổi: hiện MSG-10 |
| 4 | "Thanh toán" / "Xác nhận" | Button | – | UC-01 bước 4 / UC-03 bước 5; chặn bấm 2 lần |
| 5 | Trạng thái xác nhận | Inline | – | MSG-04 khi quay về từ cổng; MSG-05 sau 60 giây |

### SCR-04 Huỷ gói

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "Gói vẫn dùng đầy đủ tới {ngày}. Sau đó workspace chuyển chỉ đọc; bạn vẫn xem và xuất được dữ liệu." |
| 2 | Lý do huỷ | Radio + text | Không bắt buộc `[giả định]` |
| 3 | "Huỷ gói" | Button (nguy hiểm) | \[BillingCancel\]; MSG-12 |
| 4 | "Giữ gói" | Button | Đóng |

### SCR-05 Thành viên (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Thêm đồng nghiệp" | Button | SCR-06; ẩn với `MEMBER` |
| 2 | Danh sách thành viên | List | Avatar, tên, email, vai trò ("Chủ sở hữu" không đổi được ở đây), ngày tham gia |
| 3 | Menu vai trò | Dropdown | UC-05 bước 1–3; ẩn với `MEMBER` |
| 4 | Menu … | Menu | "Xoá khỏi workspace" (SCR-07); "Chuyển quyền sở hữu" (chỉ `OWNER`) |
| 5 | Mục "Đang chờ" | List | Email, vai trò, hạn; "Gửi lại", "Thu hồi" |
| 6 | "Rời workspace" | Link | A3 UC-05; chủ sở hữu duy nhất → MSG-25 |

### SCR-06 Mời đồng nghiệp (1.1)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tiêu đề | Text | – | "Thêm đồng nghiệp vào gói" (Sunsama: "Add colleagues to your subscription") |
| 2 | Dòng mời: Email, Tên, Vai trò | Text, Text, Dropdown | Email: Có | Email sai → MSG-16; vai trò mặc định Thành viên |
| 3 | "Thêm người" | Link | – | Thêm dòng; quá 20 → MSG-15 |
| 4 | Ghi chú | Text | – | "Mỗi người có không gian riêng tư của mình. Mỗi người được mời cộng 1 ghế: +{số tiền} cho kỳ này" (A4 UC-04 khi trial) |
| 5 | Link đăng ký | Text chỉ đọc + "Sao chép link" + "Tạo link mới" | – | MSG-18 / MSG-19; ẩn khi bật "Tắt mời qua link" |
| 6 | "Gửi lời mời" | Button | – | Disabled khi không có email hợp lệ |

### SCR-07 Xoá thành viên / chuyển quyền sở hữu (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung xoá | Text | MSG-23 |
| 2 | "Xoá" | Button (nguy hiểm) | \[MemberRemove\]; MSG-24 |
| 3 | Chuyển quyền: chọn người nhận | Dropdown | Thành viên hiện có, trừ chính mình |
| 4 | Chuyển quyền: mật khẩu | Password | Xác nhận lại như G01 |
| 5 | "Chuyển quyền" | Button | \[OwnershipTransfer\]; MSG-26 |
| 6 | "Huỷ" | Button | Đóng |

### SCR-08 Privacy (1.1)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ghi chú | Text | – | MSG-29 |
| 2 | Task, Highlights, Channel, Lịch, Ghi chú cuộc họp, Tích hợp | 6 dropdown "Chỉ mình tôi" / "Thành viên" | Có | Mặc định "Chỉ mình tôi"; lưu ngay (UC-06) |
| 3 | Tắt mời qua link | Toggle (cấp workspace) | – | Chỉ `OWNER` / `ADMIN`; A1 UC-06 |

### SCR-09 Giao task và theo dõi (thành phần trong chi tiết task G02, 1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Giao cho" | Dropdown có tìm (avatar + tên) | Danh sách thành viên; "Bỏ giao"; disabled với task channel private (MSG-45) |
| 2 | Avatar người được giao trên card (G02 SCR-02) | Avatar | Hover hiện tên |
| 3 | "Theo dõi" / "Đang theo dõi" | Toggle button | A3 UC-07 |
| 4 | Người theo dõi | Avatar list | Tối đa 5 avatar + "+n" |

### SCR-10 Cài đặt Thông báo

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Bảng sự kiện × kênh | Ma trận toggle | – | Hàng: sự kiện PRD mục 5 (theo bản phát hành); cột: Trong app, Email, Mobile (1.1), Desktop (1.1) |
| 2 | Ô bắt buộc | Toggle khoá | – | Tooltip MSG-34 |
| 3 | "Cho phép thông báo trên trình duyệt / thiết bị" | Button | – | A4 UC-08; ẩn khi đã cho phép |
| 4 | Product updates | Toggle | – | Mặc định tắt `[giả định]` |

### SCR-11 Trung tâm thông báo

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Chuông + badge | Icon | Số chưa đọc, tối đa "99+" |
| 2 | Danh sách | Popover / panel | Mới nhất trước; mỗi dòng: icon loại, nội dung (MSG-40 – MSG-43…), thời gian tương đối, chấm chưa đọc |
| 3 | "Đánh dấu tất cả đã đọc" | Link | A1 UC-09 |
| 4 | "Cài đặt thông báo" | Icon | SCR-10 |
| 5 | Trạng thái rỗng | Empty state | MSG-37 |

### SCR-12 Workspace

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tên workspace | Text | 1–80 ký tự `[giả định]`; `OWNER` / `ADMIN` sửa được; lưu ngay |
| 2 | "Xoá workspace" | Button (nguy hiểm) | Chỉ `OWNER`; mở dialog: hậu quả, ô gõ tên (MSG-27), "Xoá vĩnh viễn" |

### SCR-13 Trang lời mời (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "{Người mời} mời bạn vào {workspace}" |
| 2 | "Tạo tài khoản" / "Đăng nhập" | Button | G01 với email điền sẵn, `inviteToken` |
| 3 | Lỗi | Inline | MSG-20 / MSG-21 / MSG-44 |

### SCR-14 Trang huỷ đăng ký email

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Kết quả | Text | MSG-35 / MSG-36 |
| 2 | "Bật lại" | Button | \[Unsubscribe\] `undo=true` |
| 3 | "Mở cài đặt thông báo" | Link | SCR-10 (cần đăng nhập) |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[BillingGet\] `GET /billing` | – | status, plan, interval, seats, trialEndsAt, currentPeriodEnd, cancelAt, paymentMethodSummary | 5s / 2 lần |
| \[BillingCheckout\] `POST /billing/checkout` | interval, seats, returnUrl, Idempotency-Key | checkoutUrl, checkoutId | 10s / 1 lần cùng key |
| \[BillingWebhook\] `POST /webhooks/billing` | Payload + chữ ký của cổng, eventId | 200 (kể cả trùng) / 400 (chữ ký sai) | Cổng tự retry; xử lý ≤ 10s |
| \[BillingUpdate\] `PATCH /billing/subscription` `[giả định]` | interval?, seats?, preview | prorationAmount, nextAmount, effectiveAt | 10s / 1 lần |
| \[BillingCancel\] / \[BillingResume\] `POST /billing/cancel`, `/billing/resume` `[giả định]` | reason? | status, cancelAt | 5s / 1 lần |
| \[InvoiceList\] `GET /billing/invoices` `[giả định]` | cursor | Invoice[] (pdfUrl) | 5s / 1 lần |
| \[TeamChanges\] `GET /billing/team-changes` `[giả định]` | cursor | Entry[] | 5s / 1 lần |
| \[MemberList\] / \[MemberUpdate\] / \[MemberRemove\] `GET /members`, `PATCH` / `DELETE /members/{id}` | role | Member, seats | 5s / 1 lần |
| \[MemberLeave\] `POST /members/me/leave` `[giả định]` | – | 204 | 5s / 1 lần |
| \[InviteCreate\] `POST /invites` | items[{email, name?, role}], Idempotency-Key | created[], skipped[{email, reason}] | 10s / 1 lần cùng key |
| \[InviteResend\] / \[InviteRevoke\] `POST /invites/{id}/resend`, `DELETE /invites/{id}` | id | Invite | 5s / 1 lần |
| \[InviteLinkRotate\] `POST /invites/link` | – | signupLinkUrl | 5s / 1 lần |
| \[InviteAccept\] `POST /invites/{token}/accept` `[giả định]` | token (sau khi đăng nhập, G01) | workspaceId, role | 5s / 2 lần |
| \[PrivacyGet\] / \[PrivacyUpdate\] `GET` / `PATCH /privacy` | dataType → `only_me` / `members`; disableLinkInvites (cấp workspace) | Privacy | 5s / 2 lần |
| \[OwnershipTransfer\] `POST /workspace/transfer-ownership` `[giả định]` | newOwnerId, currentPassword | Workspace | 10s / không retry |
| \[WorkspaceUpdate\] / \[WorkspaceDelete\] `PATCH` / `DELETE /workspace` `[giả định]` | name / confirmName | Workspace / 202 | 10s / không retry (DELETE) |
| \[TaskAssign\] `PUT /tasks/{id}/assignee` `[giả định]` | assigneeId \| null | Task | 5s / 2 lần |
| \[TaskFollow\] / \[TaskUnfollow\] `POST` / `DELETE /tasks/{id}/followers` `[giả định]` | – | followers[] | 5s / 2 lần |
| \[SettingsGet\] / \[SettingsUpdate\] | Nhóm `notifications` (G01) | Settings | Theo G01 |
| \[NotificationList\] `GET /notifications` | cursor, limit ≤ 200, unreadOnly? | Notification[], unreadCount, nextCursor | 5s / 2 lần |
| \[NotificationRead\] `POST /notifications/read` | ids[] \| all | unreadCount | 5s / 2 lần |
| \[Unsubscribe\] `POST /notifications/unsubscribe` `[giả định]` | token, undo? | eventType, channel, enabled | 5s / 1 lần |

Path đánh dấu `[giả định]` chưa có trong danh sách API đã chốt; cần BE xác nhận. Mọi API ghi dữ liệu nghiệp vụ khi `CHI_DOC` trả 402 `WORKSPACE_READ_ONLY` (BR-06).

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `WORKSPACE_READ_ONLY` (402) | MSG-03 |
| `PAYMENT_CANCELLED` / `PAYMENT_FAILED` | MSG-07 |
| `PAYMENT_GATEWAY_UNAVAILABLE` | MSG-08 |
| `SEATS_BELOW_MEMBERS` (422) | MSG-09 |
| `FORBIDDEN` (403, sai vai trò) | MSG-14 |
| `INVITE_LIMIT` (422) | MSG-15 |
| `VALIDATION_FAILED` · field email | MSG-16 |
| `INVITE_INVALID` (404, hết hạn / thu hồi) | MSG-20 |
| `LINK_INVITES_DISABLED` (403) | MSG-21 |
| `INVITE_EMAIL_MISMATCH` (403) | MSG-44 |
| `OWNER_MUST_TRANSFER` (409) | MSG-25 |
| `WORKSPACE_NAME_MISMATCH` (422) | MSG-27 |
| `MEMBERSHIP_REVOKED` (401) | MSG-28 |
| `NOT_FOUND` (404, mất quyền xem theo Privacy / đã xoá) | MSG-30 |
| `ASSIGNEE_NOT_MEMBER` (422) | MSG-32 |
| `ASSIGN_PRIVATE_CHANNEL` (422) | MSG-45 |
| `NOTIFICATION_REQUIRED` (422) | MSG-34 |
| `UNSUBSCRIBE_TOKEN_INVALID` (404) | MSG-36 |
| 5xx / timeout | MSG-38 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Banner | Bạn còn {n} ngày dùng thử · Nâng cấp |
| MSG-02 | Banner | Thanh toán gia hạn chưa thành công. Chúng tôi sẽ thử lại ngày {ngày} · Cập nhật thanh toán |
| MSG-03 | Banner / toast | Workspace đang ở chế độ chỉ đọc. Nâng cấp để tiếp tục thêm và sửa · Nâng cấp · Xuất dữ liệu |
| MSG-04 | Inline SCR-03 | Đang xác nhận thanh toán… |
| MSG-05 | Inline SCR-03 | Cổng thanh toán chưa xác nhận. Chúng tôi sẽ gửi email khi xong |
| MSG-06 | Toast | Đã nâng cấp lên {gói}. Hoá đơn đã gửi tới {email} |
| MSG-07 | Toast | Thanh toán chưa thành công hoặc đã bị huỷ · Thử lại |
| MSG-08 | Toast | Không mở được trang thanh toán. Thử lại |
| MSG-09 | Inline | Số ghế không được ít hơn {n} (thành viên và lời mời đang chờ) |
| MSG-10 | Dialog | Kỳ này: {số tiền} cho phần còn lại tới {ngày}. Từ {ngày}: {số tiền} / {tháng / năm} |
| MSG-11 | Toast | Đã cập nhật gói |
| MSG-12 | Toast | Gói sẽ kết thúc ngày {ngày}. Bạn vẫn dùng đầy đủ tới lúc đó · Tiếp tục gói |
| MSG-13 | Toast | Đã tiếp tục gói |
| MSG-14 | Toast | Bạn không có quyền thực hiện thao tác này |
| MSG-15 | Inline | Tối đa 20 email mỗi lần |
| MSG-16 | Inline | Email chưa đúng định dạng |
| MSG-17 | Toast | Đã gửi {n} lời mời. Bỏ qua {m} email đã là thành viên hoặc đang chờ: {danh sách} |
| MSG-18 | Toast | Đã sao chép link mời |
| MSG-19 | Dialog | Tạo link mới sẽ vô hiệu link cũ. Tiếp tục? |
| MSG-20 | SCR-13 | Lời mời đã hết hạn hoặc đã bị thu hồi. Hãy nhờ người mời gửi lại |
| MSG-21 | SCR-13 | Workspace này đã tắt mời qua link |
| MSG-22 | Toast | {tên} đã trở thành {vai trò} |
| MSG-23 | Dialog | Xoá {tên} khỏi workspace? Timer đang chạy sẽ dừng, {n} task được giao chưa xong chuyển về người giao. Gói giảm 1 ghế từ kỳ sau |
| MSG-24 | Toast | Đã xoá {tên} khỏi workspace |
| MSG-25 | Inline | Bạn là chủ sở hữu duy nhất. Hãy chuyển quyền sở hữu trước · Chuyển quyền sở hữu |
| MSG-26 | Toast | {tên} là chủ sở hữu mới. Bạn trở thành Quản trị |
| MSG-27 | Inline | Gõ đúng tên workspace để xác nhận |
| MSG-28 | Màn hình | Bạn không còn là thành viên của {workspace} |
| MSG-29 | Inline SCR-08 | Workspace của bạn đang riêng tư. Chỉ dữ liệu bạn đặt "Thành viên" mới hiện với người khác |
| MSG-30 | Toast | Nội dung này đã bị xoá hoặc bạn không còn quyền xem |
| MSG-31 | Toast | Đã giao "{tiêu đề}" cho {tên} |
| MSG-32 | Inline | Chỉ giao được cho thành viên của workspace |
| MSG-33 | Toast | Đang theo dõi "{tiêu đề}" / Đã bỏ theo dõi "{tiêu đề}" |
| MSG-34 | Tooltip | Thông báo về thanh toán luôn được gửi qua email |
| MSG-35 | SCR-14 | Đã huỷ nhận email "{loại}" · Bật lại |
| MSG-36 | SCR-14 | Link huỷ đăng ký không hợp lệ. Mở Cài đặt → Thông báo để chỉnh |
| MSG-37 | Empty state | Chưa có thông báo nào |
| MSG-38 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-39 | – | (dự phòng) |
| MSG-40 | Trung tâm / email | {người giao} đã giao cho bạn "{tiêu đề}" |
| MSG-41 | Trung tâm / email | "{tiêu đề}" bạn theo dõi: {người} đã {hoàn thành / giao cho {tên} / bình luận} |
| MSG-42 | Trung tâm / email | Gói dùng thử còn {n} ngày · Nâng cấp |
| MSG-43 | Trung tâm / email | "{tiêu đề}": {n} cập nhật mới |
| MSG-44 | SCR-13 | Lời mời này gửi tới {email}. Hãy đăng nhập bằng email đó |
| MSG-45 | Tooltip | Task trong channel riêng tư không giao được cho người khác |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | SCR-02 mở ≤ 1s; webhook xử lý xong ≤ 10s từ khi nhận; thông báo trong app tới người nhận ≤ 5s; email thông báo ≤ 2 phút (p95); \[InviteCreate\] 20 email ≤ 2s |
| Độ tin cậy | Webhook idempotent (BR-04); đối soát trạng thái gói với cổng hằng ngày; job `billing.lifecycle` idempotent; không mất thông báo khi dịch vụ email lỗi (hàng đợi, thử lại BR-19) |
| Offline | Billing, mời, thành viên, Privacy cần mạng; trung tâm thông báo xem bản cache, đánh dấu đã đọc xếp hàng đợi |
| Bảo mật | Không chạm số thẻ (PCI DSS — chỉ hosted checkout của cổng); xác thực chữ ký webhook, chỉ nhận từ IP / secret của cổng; quyền vai trò (BR-01) và Privacy (BR-15) kiểm tra ở server, có kiểm thử tự động cho cả 6 loại dữ liệu; token mời và token huỷ đăng ký ngẫu nhiên ≥ 128 bit, chỉ lưu dạng băm |
| Quyền riêng tư, tuân thủ | Product updates cần đồng ý (BR-18); hoá đơn, thuế theo quy định Việt Nam — chờ kế toán / pháp chế; nơi lưu dữ liệu — câu hỏi mở |
| Log / audit | BR-21 cho mọi hành động quản trị và thanh toán, giữ ≥ 1 năm; nhật ký webhook giữ payload đã lược bỏ dữ liệu cá nhân |
| Tracking | Sự kiện: `trial_banner_shown`, `upgrade_clicked` (nguồn), `checkout_started`, `checkout_completed` / `_failed`, `subscription_renewed` / `_retry_failed`, `workspace_read_only`, `subscription_changed`, `subscription_cancelled` / `_resumed`, `invite_sent` (số email, vai trò), `invite_accepted`, `invite_link_copied`, `member_role_changed`, `member_removed`, `ownership_transferred`, `privacy_changed` (loại dữ liệu), `task_assigned`, `task_followed`, `notification_setting_changed`, `notification_opened`, `email_unsubscribed` |
| Accessibility | Banner có role="status" / "alert" theo mức độ; ma trận toggle SCR-10 có nhãn "{sự kiện} – {kênh}"; badge chuông đọc được số chưa đọc; điều hướng bằng bàn phím đầy đủ; tương phản đạt WCAG 2.1 AA ở cả giao diện sáng / tối |
