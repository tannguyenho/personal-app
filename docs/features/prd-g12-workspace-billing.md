> **Mã:** PLN-PRD-G12 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g12-workspace-billing.md

# PRD Workspace, thành viên, quyền riêng tư & thanh toán trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (Billing "Sunsama Free Trial · 1 seat · 14 days remaining · Upgrade Plan", "Team changes"; hộp thoại "Add colleagues to your subscription"; Signup Link, "Disable link invites"; Privacy 6 loại dữ liệu; vai trò "Owner", nhật ký "became an admin (promoted by …)"); chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

G12 lo hai mảng: **kinh doanh** (trial, thanh toán, chế độ chỉ đọc) và **làm việc nhóm** (workspace nhiều thành viên, vai trò, quyền riêng tư, giao và follow task). G12 cũng sở hữu cài đặt Thông báo và trung tâm thông báo trong app: nhóm khác phát sinh sự kiện (G05, G07, G08, G09, G11), G12 quyết định ai nhận, qua kênh nào. Bản 1.0 phục vụ người dùng cá nhân: mỗi tài khoản một workspace do chính họ làm chủ sở hữu (tạo ở G01), trial 14 ngày và thanh toán cơ bản. Bản 1.1 mở mời thành viên, vai trò, Privacy, giao / follow task.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Không biết trial còn bao lâu, bị khoá đột ngột khi hết hạn | Mất mạch làm việc, mất niềm tin, rời bỏ thay vì trả tiền |
| Thanh toán nhiều bước hoặc thiếu phương thức phổ biến ở Việt Nam | Tỉ lệ chuyển từ trial sang trả phí thấp |
| Gia hạn lỗi một lần (thẻ hết hạn, hết hạn mức) là mất quyền ngay | Mất khách trả tiền vì lỗi tạm thời |
| Dùng chung workspace nhưng sợ đồng nghiệp / quản lý thấy hết việc cá nhân | Không dám mời nhóm, sản phẩm không lan trong tổ chức |
| Không biết ai được giao việc gì, việc mình quan tâm đã xong chưa | Phải hỏi qua chat, theo dõi bằng trí nhớ |
| Thông báo dồn dập, trùng lặp, không tắt được | Người dùng tắt hết, bỏ lỡ thông báo quan trọng (trial sắp hết, lịch mất kết nối) |

## 1.3 Mục tiêu

- Người dùng luôn biết trạng thái gói: số ngày trial còn lại hiện ở Billing; nhắc trước 3 ngày và 1 ngày qua email + banner.
- Hết trial hoặc quá hạn không mất dữ liệu: chuyển chỉ đọc, vẫn xuất được, giữ 90 ngày `[giả định]`.
- Nâng cấp ≤ 3 bước từ banner tới thanh toán xong.
- (1.1) Mọi dữ liệu mặc định riêng tư; mời một đồng nghiệp trong ≤ 1 phút.
- Mỗi loại thông báo bật / tắt được theo kênh; cùng một task không gửi quá 1 thông báo trong 5 phút.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân đang dùng thử (Hà freelancer) | Biết còn bao nhiêu ngày, trả tiền nhanh bằng phương thức quen thuộc, không mất dữ liệu nếu chậm trả |
| Chủ sở hữu workspace (người trả tiền) | Quản lý gói, số ghế, hoá đơn; chuyển quyền khi rời nhóm |
| Quản trị workspace (1.1) | Mời, xoá thành viên, đổi vai trò, quản lý channel chung |
| Thành viên nhóm (1.1, Linh PM) | Giữ việc cá nhân riêng tư; nhận việc được giao; theo dõi task của người khác |
| Mọi người dùng | Nhận đúng thông báo cần, qua đúng kênh, tắt được thứ không cần |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.0: trial, thanh toán, thông báo · bản 1.1: thành viên, quyền riêng tư)

Bản 1.0:

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Trial 14 ngày không cần thẻ, nhắc trước 3 ngày và 1 ngày.
- Billing: xem gói, nâng cấp (tháng / năm), thanh toán qua trang của cổng thanh toán, hoá đơn PDF, đổi gói, huỷ gói, thử lại khi gia hạn lỗi, chế độ chỉ đọc.
- Cài đặt Thông báo (bật / tắt theo sự kiện × kênh), trung tâm thông báo trong app, email có link huỷ đăng ký 1 chạm.
- Nhật ký "Team changes" và audit log hành động quản trị, thanh toán.

Bản 1.1:

- Mời thành viên qua email và link mời chung; vai trò Chủ sở hữu / Quản trị / Thành viên; đổi vai trò, xoá thành viên, rời workspace, chuyển quyền sở hữu, xoá workspace.
- Privacy: 6 loại dữ liệu × "Chỉ mình tôi" / "Thành viên"; "Tắt mời qua link".
- Giao task, follow task.

## 3.2 Ngoài phạm vi

- Giới thiệu bạn bè (1 tháng miễn phí) → chưa đưa vào.
- Danh sách gói, giá, quyền theo gói → chưa định nghĩa (Câu hỏi mở).
- SSO / SCIM, một người thuộc nhiều workspace → chưa có kế hoạch `[giả định]`.
- Đăng ký, tài khoản, xuất dữ liệu, xoá tài khoản → G01. Context & channel → G02.
- Nội dung và thời điểm phát sinh của từng sự kiện thông báo → nhóm phát sinh (G05, G07, G08, G09, G11). Slack / Teams làm kênh thông báo → bản 1.2 (G11).

# 4. Nguyên tắc sản phẩm

## 4.1 Không giữ dữ liệu làm con tin

Hết trial hay quá hạn chỉ chặn ghi; người dùng vẫn xem, xuất dữ liệu và thanh toán được bất cứ lúc nào.

## 4.2 Riêng tư là mặc định

Mọi loại dữ liệu ở "Chỉ mình tôi" tới khi chính người dùng mở cho thành viên khác. Channel private (G02) luôn riêng tư.

## 4.3 Tiền phải khớp

Trạng thái gói chỉ đổi khi cổng thanh toán xác nhận qua webhook, không theo trang chuyển hướng. Mỗi giao dịch xử lý đúng một lần.

## 4.4 Ít mà đủ thông báo

Gộp thông báo trùng, tắt được từng loại theo từng kênh, email huỷ 1 chạm. Thông báo về tiền và bảo mật luôn đến.

# 5. Quy tắc gói, quyền và thông báo

**Gói và lời mời**

| **Mục** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Trial | 14 ngày, không cần thẻ | Bắt đầu khi tạo workspace (G01) | Nhắc trước 3 ngày và 1 ngày (email + banner) |
| Chu kỳ thanh toán | Tháng / năm | — | Giá: câu hỏi mở |
| Số ghế | ≥ số thành viên + lời mời đang chờ | 1 (1.0 luôn là 1) | Tự cộng khi thành viên chấp nhận lời mời (1.1) |
| Thử lại khi gia hạn lỗi | Ngày 1, 3, 7 sau ngày đến hạn | — | Trong thời gian thử lại vẫn dùng đầy đủ |
| Giữ dữ liệu khi chỉ đọc | 90 ngày `[giả định]` | — | Vẫn xuất được (G01) |
| Lời mời qua email | 1–20 email / lần, hết hạn 7 ngày, thu hồi được | Vai trò Thành viên | Sunsama không cho chọn vai trò khi mời; cho chọn (khác có chủ đích) |
| Gộp thông báo | Cùng task, cùng người nhận trong 5 phút → 1 thông báo | — | |
| Lưu trung tâm thông báo | 90 ngày `[giả định]` | — | |

**Ma trận quyền (1.1)**

| **Quyền** | **Chủ sở hữu** | **Quản trị** | **Thành viên** |
|---|---|---|---|
| Quản lý task, lịch, ritual của mình | ✓ | ✓ | ✓ |
| Xem task của người khác trong channel chung | ✓ khi Privacy của người đó cho phép | ✓ khi Privacy cho phép | ✓ khi Privacy cho phép |
| Tạo / sửa context, channel chung | ✓ | ✓ | – |
| Mời, xoá thành viên, đổi vai trò | ✓ | ✓ (trừ Chủ sở hữu) | – |
| Xem Team changes, bật / tắt mời qua link | ✓ | ✓ `[giả định]` | – |
| Billing, xoá workspace, chuyển quyền sở hữu | ✓ | – | – |

**Thông báo: sự kiện → người nhận → kênh mặc định**

| **Sự kiện** | **Người nhận** | **Kênh mặc định** | **Phát hành** | **Nhóm phát sinh** |
|---|---|---|---|---|
| Trial sắp hết (còn 3 ngày, 1 ngày) | Chủ sở hữu | Trong app + email (email không tắt được) | 1.0 | G12 |
| Gia hạn lỗi / sắp chuyển chỉ đọc | Chủ sở hữu | Trong app + email (email không tắt được) `[giả định]` | 1.0 | G12 |
| Lịch / tích hợp mất kết nối | Người đã kết nối | Trong app + email | 1.0 (lịch), 1.1 (tích hợp) | G05, G11 |
| Đến giờ ritual | Người dùng | Trong app; desktop: thông báo hệ thống | 1.0 (desktop 1.1) | G08, G09 |
| Timebox sắp bắt đầu | Người dùng | Reminder của lịch ngoài (theo "nhắc theo lịch mặc định") | 1.0 | G05 |
| Timer chạy quá 4 giờ | Người dùng | Mobile push | 1.1 | G07 |
| Được giao task | Người được giao | Trong app + email | 1.1 | G12 |
| Task đang follow: tạo, giao lại, hoàn thành, comment | Người follow | Email (mobile 1.1, Slack 1.2) | 1.1 | G12 |
| Recap tuần | Người dùng + người nhận thêm | Email Thứ Bảy 00:00 | 1.1 (Beta) | G09 |
| Product updates | Người dùng | Email, mặc định tắt `[giả định]` | 1.0 | G12 |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Gói và quyền theo gói (giới hạn số channel, tích hợp, AI…) chưa định nghĩa; kiến trúc phải đọc quyền theo gói từ cấu hình, không rẽ nhánh theo tên gói trong code.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Dùng thử | Đăng ký (G01), dùng đầy đủ tính năng; Billing hiện "Dùng thử · 1 ghế · còn n ngày" | Trial 14 ngày |
| 2 | Nhắc | Còn 3 ngày, 1 ngày: banner + email có nút "Nâng cấp" | Người dùng biết trước |
| 3 | Nâng cấp | Chọn tháng / năm (và số ghế) → trang thanh toán của cổng → quay lại app | Gói hoạt động, hoá đơn PDF |
| 4 | Gia hạn | Tự thu mỗi kỳ; lỗi thì thử lại ngày 1, 3, 7; hết lượt → chỉ đọc | Không mất khách vì lỗi tạm thời |
| 5 | Mời nhóm (1.1) | "Thêm đồng nghiệp": nhập email, chọn vai trò; hoặc copy link mời | Thành viên mới, ghế tự cộng |
| 6 | Riêng tư (1.1) | Mỗi người chọn loại dữ liệu nào thành viên khác thấy | Chia sẻ có kiểm soát |
| 7 | Phối hợp (1.1) | Giao task, follow task; nhận thông báo | Biết ai làm gì, việc nào xong |
| 8 | Thông báo | Trung tâm thông báo trong app; tắt / bật theo sự kiện × kênh | Đúng thông báo, đúng kênh |

Bước 1 dựa trên G01; PRD này tập trung bước 2–8.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Dùng thử và nâng cấp (1.0)

### US1.1 Biết trạng thái trial

AC01: Cài đặt → Billing hiện tên gói, số ghế, số ngày còn lại (ví dụ "Dùng thử · 1 ghế · còn 14 ngày"), nút "Nâng cấp".

AC02: Còn ≤ 3 ngày: banner trên Home cho chủ sở hữu, đóng được, hiện lại mỗi ngày; email lúc còn 3 ngày và 1 ngày.

### US1.2 Nâng cấp

User Story: Là người dùng đang dùng thử, tôi muốn nâng cấp trong vài bước bằng phương thức thanh toán quen thuộc, để tiếp tục dùng không gián đoạn.

AC01: "Nâng cấp" mở màn chọn gói: chu kỳ tháng / năm, số ghế (1.0 cố định 1), tổng tiền, ngày gia hạn kế tiếp.

AC02: "Thanh toán" chuyển sang trang của cổng thanh toán; app không nhận và không lưu số thẻ.

AC03: Gói chỉ hoạt động khi cổng xác nhận (webhook); trang quay về app hiện "Đang xác nhận thanh toán…" tới khi xác nhận, tối đa 60 giây `[giả định]` rồi báo sẽ gửi email khi xong.

AC04: Thanh toán xong: banner trial biến mất, Billing hiện gói, kỳ gia hạn, hoá đơn PDF; email xác nhận kèm hoá đơn.

## UC2. Gia hạn, huỷ và chế độ chỉ đọc (1.0)

### US2.1 Gia hạn tự động và thử lại

AC01: Đến kỳ, hệ thống thu tiền qua cổng; lỗi → thử lại ngày 1, 3, 7; mỗi lần lỗi gửi email cho chủ sở hữu kèm link cập nhật phương thức thanh toán.

AC02: Trong thời gian thử lại vẫn dùng đầy đủ; banner đỏ cho chủ sở hữu "Thanh toán gia hạn chưa thành công".

### US2.2 Chế độ chỉ đọc

User Story: Là người dùng hết trial chưa trả tiền, tôi muốn vẫn xem và xuất được dữ liệu, để không mất những gì đã làm.

AC01: Hết trial / hết kỳ sau khi huỷ / thử lại ngày 7 lỗi → workspace chỉ đọc: xem được, xuất được (G01), thanh toán được; mọi thao tác ghi bị chặn với banner "Nâng cấp để tiếp tục".

AC02: Đang làm dở một ritual hoặc thao tác lúc hết hạn → cho hoàn tất thao tác đó rồi mới chỉ đọc (EC-34).

AC03: Thanh toán thành công → bỏ chỉ đọc ngay, không mất dữ liệu.

AC04: Chỉ đọc quá 90 ngày `[giả định]` → dữ liệu bị xoá; email nhắc trước 30 ngày và 7 ngày `[giả định]`.

### US2.3 Đổi gói, số ghế, huỷ, hoá đơn

AC01: Đổi chu kỳ hoặc số ghế tính tiền theo tỷ lệ phần kỳ còn lại; hiện số tiền trước khi xác nhận.

AC02: Huỷ gói có hiệu lực cuối kỳ; trước đó có nút "Tiếp tục gói".

AC03: Danh sách hoá đơn tải được PDF.

## UC3. Thành viên (1.1)

### US3.1 Mời đồng nghiệp

User Story: Là chủ sở hữu / quản trị, tôi muốn mời đồng nghiệp bằng email trong một hộp thoại, để cả nhóm dùng chung workspace.

AC01: Hộp thoại "Thêm đồng nghiệp vào gói" (Sunsama: "Add colleagues to your subscription"): mỗi dòng email + tên (tuỳ chọn) + vai trò; "Thêm người"; 1–20 email / lần.

AC02: Ghi chú "Mỗi người có không gian riêng tư của mình" và "Mỗi người được mời cộng 1 ghế vào gói" kèm số tiền tăng theo tỷ lệ (ngoài trial).

AC03: Email đã là thành viên hoặc đang có lời mời chờ → không gửi trùng, báo danh sách bỏ qua (EC-32).

AC04: Lời mời hết hạn sau 7 ngày; danh sách lời mời chờ có "Gửi lại", "Thu hồi".

### US3.2 Link mời chung

AC01: "Link đăng ký" + "Sao chép link"; ai có link đăng ký / đăng nhập (G01) là vào workspace với vai trò Thành viên.

AC02: "Tạo link mới" vô hiệu link cũ; bật "Tắt mời qua link" thì link không dùng được.

### US3.3 Đổi vai trò, xoá thành viên

AC01: Đổi vai trò Quản trị ⇄ Thành viên; Team changes ghi "{A} trở thành Quản trị (do {B} nâng quyền)".

AC02: Xoá thành viên: dừng timer đang chạy, task họ được giao chưa xong chuyển về người giao, họ bị đăng xuất khỏi workspace ≤ 1 phút (EC-31).

### US3.4 Chuyển quyền sở hữu, rời và xoá workspace

AC01: Chủ sở hữu chuyển quyền cho một thành viên; chủ sở hữu cũ thành Quản trị.

AC02: Chủ sở hữu duy nhất muốn rời workspace hoặc xoá tài khoản (G01) khi còn thành viên khác → chặn tới khi chuyển quyền (EC-36).

AC03: Xoá workspace chỉ chủ sở hữu, phải gõ tên workspace để xác nhận; huỷ gói, mọi thành viên bị đăng xuất.

## UC4. Quyền riêng tư (1.1)

### US4.1 Chọn dữ liệu nào thành viên khác thấy

AC01: Privacy liệt kê 6 loại dữ liệu: Task, Highlights, Channel, Lịch, Ghi chú cuộc họp, Tích hợp; mỗi loại chọn "Chỉ mình tôi" / "Thành viên"; mặc định "Chỉ mình tôi".

AC02: Đổi sang "Chỉ mình tôi" → người khác đang xem mất quyền ≤ 5 giây (EC-33).

AC03: Channel private (G02) không hiện với người khác dù cài đặt là "Thành viên".

## UC5. Giao task và follow task (1.1)

### US5.1 Giao task

AC01: Chi tiết task (G02) có ô "Giao cho" chọn thành viên; người được giao nhận task vào backlog của họ (G06) và thông báo trong app + email.

AC02: Giao lại cho người khác → người mới nhận thông báo, người cũ không còn thấy task trong backlog (trừ khi follow).

### US5.2 Follow task

AC01: Nút "Theo dõi" trên chi tiết task; người follow nhận thông báo khi task được giao lại, hoàn thành, có comment mới.

AC02: Bỏ theo dõi bất cứ lúc nào; người giao tự động follow `[giả định]`.

## UC6. Thông báo (1.0)

### US6.1 Cài đặt thông báo

AC01: Cài đặt → Thông báo hiện bảng sự kiện × kênh (Trong app, Email, Mobile, Desktop); mỗi ô là một công tắc; sự kiện / kênh chưa phát hành ở bản hiện tại không hiện.

AC02: Ô bắt buộc (email trial sắp hết, gia hạn lỗi) hiện khoá kèm giải thích.

### US6.2 Trung tâm thông báo

AC01: Biểu tượng chuông có badge số chưa đọc (tối đa "99+"); mở danh sách mới nhất trước; bấm một thông báo mở đúng nơi liên quan và đánh dấu đã đọc.

AC02: "Đánh dấu tất cả đã đọc"; thông báo mới hiện ≤ 5 giây không cần tải lại.

### US6.3 Huỷ đăng ký email 1 chạm

AC01: Mọi email thông báo (trừ email bắt buộc) có link "Huỷ nhận loại email này"; bấm là tắt ngay, không cần đăng nhập, có trang xác nhận và nút "Bật lại".

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu** |
|---|---|---|
| Chuyển đổi trial → trả phí | Workspace trả phí trong 30 ngày sau khi bắt đầu trial / workspace bắt đầu trial | ≥ 10% |
| Thời gian nâng cấp | Từ bấm "Nâng cấp" tới gói hoạt động | ≤ 3 phút (trung vị) |
| Tỉ lệ cứu được gia hạn lỗi | Gia hạn thành công ở lần thử lại / gia hạn lỗi lần đầu | ≥ 40% |
| Tỉ lệ quay lại từ chỉ đọc | Workspace chỉ đọc thanh toán trong 90 ngày / workspace chỉ đọc | Theo dõi |
| Workspace nhiều thành viên (1.1) | Workspace ≥ 2 thành viên hoạt động / workspace trả phí | ≥ 20% |
| Tỉ lệ chấp nhận lời mời (1.1) | Lời mời được chấp nhận / lời mời gửi | ≥ 50% |
| Tỉ lệ tắt thông báo | Người dùng tắt ≥ 1 loại / người dùng hoạt động | Theo dõi (cao = thông báo gây phiền) |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Cổng thanh toán chưa chốt | Stripe hay VNPay / MoMo; thu định kỳ tự động bằng ví / thẻ nội địa có thể bị hạn chế | Thiết kế lớp cổng thanh toán trừu tượng; chốt cổng trước khi làm UC1–UC2 |
| Hoá đơn, thuế tại Việt Nam | Có thể cần hoá đơn điện tử, VAT | Kế toán / pháp chế xác nhận trước ra mắt |
| Webhook trễ, trùng, sai thứ tự | Gói kích hoạt chậm hoặc bị xử lý hai lần | Idempotent theo ID giao dịch (EC-35); đối soát hằng ngày với cổng; trang "Đang xác nhận" |
| Lộ dữ liệu giữa thành viên (1.1) | Lỗi kiểm tra Privacy làm lộ task cá nhân | Kiểm tra quyền ở tầng truy vấn server; kiểm thử tự động cho cả 6 loại dữ liệu |
| Ghế tự cộng khi mời | Chủ sở hữu bị thu thêm tiền không lường trước | Hiện số tiền tăng ngay trong hộp thoại mời; log trong Team changes |
| Email vào thư rác | Nhắc trial, gia hạn lỗi không tới | SPF / DKIM / DMARC; luôn kèm thông báo trong app |
| Tiếp thị qua email | Product updates cần đồng ý theo Nghị định 13/2023/NĐ-CP, GDPR | Mặc định tắt `[giả định]`; pháp chế xác nhận |

# 10. Câu hỏi mở

- Chọn cổng thanh toán nào: Stripe, VNPay, MoMo, hay kết hợp?
- Danh sách gói, giá tháng / năm, quyền theo gói là gì?
- Dữ liệu người dùng Việt Nam có phải lưu tại Việt Nam không?
- Giữ dữ liệu workspace chỉ đọc 90 ngày có đúng không; sau đó xoá hay giữ tiếp?
- Có hoàn tiền khi huỷ giữa kỳ, giảm ghế, hoặc xoá tài khoản không `[giả định: không]`?
- Có cho chọn vai trò khi mời (khác Sunsama) không?
- Thành viên bị xoá khỏi workspace thì task riêng của họ xử lý thế nào `[giả định: ẩn 30 ngày rồi xoá]`?
- Người được mời có workspace cá nhân riêng (và trial riêng) không?
- Product updates mặc định bật hay tắt?
