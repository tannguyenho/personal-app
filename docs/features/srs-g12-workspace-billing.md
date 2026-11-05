> **Mã:** PLN-SRS-G12 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g12-workspace-billing.md

# UC-G12 - Workspace, thành viên, quyền riêng tư & thanh toán trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này mô tả workspace cá nhân, cài đặt Thông báo, trung tâm thông báo và huỷ đăng ký email (bản 1.0 — app Windows, một người dùng, miễn phí, nhãn Beta; [ADR-0005](../adr/0005-nen-tang-windows-truoc.md)); trial, thanh toán **gói cá nhân một người dùng, không tính ghế**, chế độ chỉ đọc, quyền theo gói (bản 1.1 — Q47, xem [ADR-0002](../adr/0002-thanh-toan-chuyen-sang-1-1.md)); mời thành viên, ghế và tính tiền theo ghế, vai trò, Privacy, giao / follow task, chuyển quyền sở hữu (**bản sau**, 1.2 trở đi — Q35, Q37, Q47, xem BR-28 và [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md); đặc tả giữ nguyên, chưa làm). G12 sở hữu QC-09 (chế độ chỉ đọc) và QC-10 (quyền theo gói) trong [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); SRS này tham chiếu, không định nghĩa lại. Trợ lý AI không có hạn mức theo gói (QC-12 mục 8). Cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md), gồm vòng 5–7 (Q35–Q37, Q45–Q47, D12). Đăng ký, tài khoản, xuất / xoá dữ liệu (G01), context & channel (G02), backlog (G06), timer (G07), ritual (G08, G09) và nội dung các sự kiện thông báo phát sinh ở nhóm khác (G05, G07, G08, G09, G11) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng biết rõ trạng thái gói, nâng cấp nhanh, không mất dữ liệu khi hết hạn; nhóm dùng chung workspace mà việc cá nhân vẫn riêng tư; ai cũng nhận đúng thông báo qua đúng kênh |
| Actor | Chủ sở hữu · Quản trị (bản sau) · Thành viên (bản sau) · Người được mời (bản sau) · Hệ thống · Cổng thanh toán · Dịch vụ gửi email |
| Phạm vi | 1.0: workspace cá nhân (BR-22), cài đặt Thông báo, trung tâm thông báo, huỷ đăng ký email. 1.1 (gói cá nhân một người dùng, không tính ghế — Q47): trial, chuyển người dùng 1.0 sang trial (BR-23), nâng cấp, gia hạn, thử lại, đổi gói, huỷ, hoàn tiền / tranh chấp, hoá đơn điện tử, chỉ đọc (QC-09), quyền theo gói (QC-10), audit log thanh toán. Bản sau (1.2 trở đi, BR-28): ghế và tính tiền theo ghế, Team changes, mời (email, link) theo ghế mua trước, nhận lời mời khi đã có workspace, vai trò, xoá / rời, chuyển quyền sở hữu, xoá workspace nhiều người, Privacy, giao task, follow task |
| Ngoài phạm vi | Giới thiệu bạn bè, danh sách gói / giá (câu hỏi mở), SSO / SCIM, một người thuộc nhiều workspace (bản sau), hạn mức AI theo gói (không có — QC-12 mục 8), "Latest updates", Slack / Teams làm kênh thông báo (1.2, G11) |
| Nền tảng | **App Windows (Flutter)** ở 1.0, một người dùng, tài khoản và dữ liệu trên cloud (Q45, ADR-0005); kênh thông báo: trong app, email, thông báo Windows (D12). Web và macOS từ 1.1, iOS / Android từ 1.2 (thêm kênh mobile push), dùng cùng đặc tả. Chi tiết kỹ thuật: tech chốt — `docs/tech/` |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Chủ sở hữu đang dùng thử (1.1) | Thấy số ngày trial còn lại và được nhắc trước khi hết | Không bị gián đoạn bất ngờ |
| US-02 | Chủ sở hữu (1.1) | Nâng cấp trong vài bước qua cổng thanh toán quen thuộc | Tiếp tục dùng ngay |
| US-03 | Chủ sở hữu (1.1) | Được thử lại khi gia hạn lỗi, vẫn xem / xuất dữ liệu khi hết hạn | Không mất khách, không mất dữ liệu |
| US-04 | Chủ sở hữu (1.1) | Đổi chu kỳ, huỷ gói, tải hoá đơn (số ghế: bản sau) | Tự quản lý chi phí |
| US-05 | Chủ sở hữu / Quản trị (bản sau) | Mời đồng nghiệp bằng email hoặc link, đổi vai trò, xoá thành viên | Quản lý nhóm |
| US-06 | Thành viên (bản sau) | Chọn loại dữ liệu nào người khác thấy | Giữ việc cá nhân riêng tư |
| US-07 | Thành viên (bản sau) | Giao task cho đồng nghiệp, theo dõi task quan tâm | Biết ai làm gì, việc nào xong |
| US-08 | Người dùng (1.0) | Bật / tắt từng loại thông báo theo kênh, xem lại trong app | Không bị làm phiền, không bỏ lỡ việc quan trọng |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Vai trò.** `OWNER` (đúng 1 / workspace), `ADMIN`, `MEMBER`. Quyền theo ma trận PRD mục 5, kiểm tra ở server cho mọi API; client chỉ ẩn / disable nút. Bản 1: workspace chỉ có 1 người, là `OWNER` (BR-22, BR-28); `ADMIN`, `MEMBER` là bản sau. Mỗi người thuộc đúng 1 workspace; nhiều workspace cho một người để bản sau |
| BR-02 | **Trial (1.1).** Tài khoản đăng ký từ 1.1: trial bắt đầu khi tạo workspace (G01), kéo dài 14 ngày (kết thúc đúng 14 × 24 giờ sau khi tạo `[giả định]`), không cần thẻ, đủ tính năng của bản đang phát hành. **Mỗi email chỉ được trial 1 lần** (tính cả email của tài khoản đã xoá; lưu dạng băm); email đã dùng trial → workspace mới không có trial, ở `CHI_DOC` tới khi nâng cấp `[giả định]`. Tài khoản có từ 1.0: theo BR-23. Nhắc khi còn 3 ngày và 1 ngày: email + banner + thông báo trong app (MSG-42) |
| BR-03 | **Checkout (1.1).** Chọn chu kỳ tháng / năm; **không chọn số ghế** — bản 1.1 là gói cá nhân một người dùng, không tính ghế (Q47, ADR-0002). Chọn số ghế (≥ số thành viên hiện tại; lời mời đang chờ không tính) đi cùng nhiều thành viên, bản sau (BR-27, BR-28). Thanh toán trên trang của cổng (hosted checkout); app không nhận, không lưu số thẻ (PCI DSS). Thu thông tin xuất hoá đơn theo BR-10. Gói chỉ chuyển `HOAT_DONG` khi webhook của cổng xác nhận, không theo trang chuyển hướng. Nâng cấp khi đang `DUNG_THU`: không mất ngày trial; **kỳ trả phí đầu tiên bắt đầu khi trial kết thúc** (`trialEndsAt`), lần thu đầu tại thời điểm đó `[giả định]`; MSG-53 |
| BR-04 | **Webhook.** Xác thực chữ ký; idempotent theo ID giao dịch / ID sự kiện của cổng (EC-35); sự kiện có thời điểm cũ hơn trạng thái hiện tại thì ghi nhận nhưng không đổi trạng thái; mọi sự kiện lưu vào nhật ký thanh toán. Sự kiện `refund` và `dispute` xử lý theo BR-26 |
| BR-05 | **Gia hạn (1.1).** Đến kỳ, cổng tự thu. Lỗi → `THU_LAI`, thử lại ngày 1, 3, 7 sau ngày đến hạn; mỗi lần lỗi email + thông báo cho chủ sở hữu. Trong `THU_LAI` vẫn dùng đầy đủ. Lần ngày 7 lỗi → `CHI_DOC`. Chủ sở hữu huỷ gói khi đang `THU_LAI` → `CHO_HUY`, ngừng thử lại, dùng đầy đủ tới hết lịch thử lại (ngày 7) `[giả định]` rồi `CHI_DOC` |
| BR-06 | **Chỉ đọc (1.1).** Áp khi hết trial chưa trả, hết kỳ sau khi huỷ, hoặc thử lại ngày 7 lỗi. Hành vi của API, job, webhook, timer, ritual, AI, tích hợp, thao tác offline và việc thoát chỉ đọc theo **QC-09** (đóng băng toàn bộ); timer đang chạy bị dừng, `endedAt` = thời điểm vào chỉ đọc (Q8, G07 BR-19). Lỗi ghi: 402 `WORKSPACE_READ_ONLY`. **Giữ dữ liệu 90 ngày**; email nhắc trước 30 và 7 ngày `[giả định]` (MSG-51) gửi `OWNER` (bản sau: **mọi thành viên**), là email bắt buộc (không tắt được). Hết 90 ngày: chỉ xoá **dữ liệu workspace** (task, series, channel, ritual, bản ghi thời gian, liên kết tích hợp của workspace), **không** xoá tài khoản; gói chuyển `DA_XOA_DU_LIEU`; hoá đơn giữ theo BR-10; thành viên đăng nhập lại theo BR-13 (workspace cá nhân mới) `[giả định]` |
| BR-07 | **Hết hạn giữa thao tác (EC-34).** Ân hạn 2 giờ cho ritual đang làm và thao tác offline tạo trước thời điểm vào chỉ đọc, theo QC-09; thao tác mới sau thời điểm đó bị chặn theo BR-06 |
| BR-08 | **Đổi gói (1.1; số ghế: bản sau).** Mọi thay đổi làm tăng tiền chỉ xảy ra khi `OWNER` chủ động bấm "Xác nhận". Tháng → năm: tính theo tỷ lệ phần kỳ còn lại, thu ngay. Năm → tháng: hiệu lực cuối kỳ `[giả định]`. Bản 1.1 không đổi số ghế (gói cá nhân, Q47). (Bản sau — BR-27, BR-28) Tăng ghế: tính theo tỷ lệ phần kỳ còn lại, thu ngay; giảm ghế: không thấp hơn số thành viên hiện tại, hiệu lực kỳ sau `[giả định]`. Luôn hiện số tiền trước khi xác nhận (MSG-10) |
| BR-09 | **Huỷ gói (1.1).** Hiệu lực cuối kỳ (`CHO_HUY`), trước đó "Tiếp tục gói" được; huỷ giữa kỳ (bản sau: cả giảm ghế): không hoàn tiền phần còn lại `[giả định]`; hết kỳ → `CHI_DOC`. Xoá tài khoản `OWNER` workspace một người (G01 BR-20) / xoá workspace: huỷ gói ngay; hoàn tiền phần còn lại khi xoá tài khoản theo BR-26 `[giả định — chờ pháp chế]` |
| BR-10 | **Hoá đơn (1.1).** Hoá đơn điện tử theo Nghị định 123/2020/NĐ-CP, mỗi lần thu thành công (gói, kỳ, số tiền, thuế `[giả định]`; số ghế từ bản sau), gửi email cho chủ sở hữu, tải lại được (PDF) trong Billing. Thông tin xuất hoá đơn trên SCR-03 / SCR-02: tên người mua hoặc đơn vị, mã số thuế (bắt buộc khi xuất cho tổ chức `[giả định]`), địa chỉ, email nhận hoá đơn. Hoá đơn và chứng từ giữ **10 năm**, kể cả khi tài khoản / workspace bị xoá |
| BR-11 | **Mời qua email (bản sau — BR-28).** 1–20 email / lần; mỗi email kèm tên (tuỳ chọn) và vai trò `ADMIN` / `MEMBER` (mặc định `MEMBER`; Sunsama không cho chọn — khác có chủ đích). Lời mời hết hạn sau 7 ngày, thu hồi được, "Gửi lại" đặt hạn mới. Email đã là thành viên / đang có lời mời chờ → không gửi, trả về danh sách bỏ qua (EC-32). Lời mời gắn với email: chấp nhận phải đăng nhập đúng email đó `[giả định]`. Chấp nhận chỉ vào được workspace khi **còn ghế trống** (BR-27); hết ghế → lời mời `CHO_GHE`, không tự cộng ghế, không trừ tiền. Người đã có workspace chấp nhận → BR-25 |
| BR-12 | **Link mời chung (bản sau — BR-28).** Mỗi workspace 1 link, vai trò `MEMBER`; "Tạo link mới" vô hiệu link cũ; "Tắt mời qua link" (Privacy, cấp workspace) → link trả `LINK_INVITES_DISABLED`. Vào qua link cũng theo BR-27 (chỉ khi còn ghế trống; hết ghế → `CHO_GHE`) và BR-25 |
| BR-13 | **Xoá / rời thành viên (bản sau — BR-28; EC-31).** Trong một giao dịch: dừng và lưu timer đang chạy; task được giao cho người rời chưa xong chuyển về người giao; gỡ người rời khỏi danh sách follow; thu hồi phiên vào workspace, phát `session.revoked`, đăng xuất ≤ 1 phút; ghế giảm từ kỳ sau. **Task cá nhân** (người rời tự tạo, không được giao) chuyển sang một **workspace cá nhân mới** của người đó, tạo ngay trong giao dịch, Privacy mặc định; gói của workspace mới: câu hỏi mở (email đã dùng trial thì không có trial — BR-02). Người rời nhận MSG-28. Xoá tài khoản khi không phải `OWNER` (G01 BR-20) chạy BR-13 trước rồi mới xoá |
| BR-14 | **Chủ sở hữu (bản sau — BR-28; EC-36).** Workspace một người (bản 1): xoá workspace = xoá tài khoản theo G01 BR-20. `OWNER` không rời workspace, không xoá tài khoản (G01 BR-20) khi workspace còn thành viên khác: phải chuyển quyền sở hữu hoặc xoá workspace trước. **Chuyển quyền sở hữu:** chỉ `OWNER`, xác nhận lại theo G01 BR-10 (mật khẩu hoặc `reauthToken` Google / Microsoft); người nhận thành `OWNER`, người cũ thành `ADMIN`; cả hai nhận email. Thanh toán: **gỡ phương thức thanh toán của chủ cũ ngay**; khách hàng trên cổng, người nhận hoá đơn và email thanh toán chuyển sang chủ mới; chủ mới nhập phương thức thanh toán trước kỳ kế tiếp (MSG-50); tới kỳ chưa có → gói chuyển `THU_LAI` (BR-05). Gói đang `CHO_HUY` / `DUNG_THU` không cần thẻ, giữ trạng thái `[giả định]`. **Xoá workspace:** chỉ `OWNER`, gõ đúng tên workspace `[giả định]`; huỷ gói, đăng xuất mọi thành viên, dữ liệu xoá ≤ 30 ngày, hoá đơn giữ theo BR-10 |
| BR-15 | **Privacy (bản sau — BR-28).** Mỗi người tự đặt cho dữ liệu của mình: 5 loại (Task, Highlights, Channel, Lịch, Tích hợp) × "Chỉ mình tôi" / "Thành viên"; mặc định "Chỉ mình tôi". Privacy **chỉ áp cho task tự tạo**: task được giao hoặc có người follow luôn hiển thị tiêu đề, trạng thái, comment với người giao, người được giao và người follow, bất kể Privacy. Channel private (G02) luôn ẩn với người khác. **Privacy "Lịch"** ở "Thành viên": người khác chỉ thấy bận / rảnh và timebox, không thấy chi tiết sự kiện của lịch ngoài (tiêu đề, người tham dự, mô tả) — khuyến nghị, chờ chốt khi làm (Q37; G05 đặc tả phần hiển thị). Quyền kiểm tra ở tầng truy vấn server. Đổi sang "Chỉ mình tôi" → người khác mất quyền ≤ 5 giây (EC-33), trừ ngoại lệ giao / follow ở trên |
| BR-16 | **Giao task (bản sau — BR-28).** Chỉ giao cho thành viên cùng workspace; task trong channel private không giao được `[giả định]`. Người được giao nhận task vào backlog của họ ở bucket **"Tuần sau"** (`next_week`, G06 BR-23), đặt lên **đầu** bucket (Q36; G06 ghi `backlogBucket` theo QC-03 mục 2) + thông báo MSG-40 (trong app + email). Người giao tự động follow `[giả định]`. Giao lại → người mới nhận MSG-40, task rời backlog người cũ. Hiển thị theo ngoại lệ của BR-15. Ghi \[ActivityLog\] (G02) |
| BR-17 | **Follow (bản sau — BR-28).** Người follow nhận MSG-41 khi task được tạo (với task tạo sẵn người follow), giao lại, hoàn thành, có comment mới; không gửi cho chính người thực hiện hành động; chỉ gửi cho người còn là thành viên workspace (BR-13). Người follow luôn xem được task theo ngoại lệ của BR-15 |
| BR-18 | **Cài đặt thông báo (1.0).** Bảng sự kiện × kênh (Trong app, Email, Desktop — thông báo Windows từ 1.0 (D12), macOS từ 1.1; Mobile push từ 1.2) với mặc định theo PRD mục 5; lưu trong cài đặt người dùng (\[SettingsUpdate\] của G01, xung đột theo G01 BR-12). Email bắt buộc, không tắt được: "Sắp xoá dữ liệu workspace chỉ đọc" (BR-06); "Trial sắp hết" và "Gia hạn lỗi" `[giả định]` — đều từ 1.1. Product updates mặc định tắt `[giả định]`; bật là một đồng ý tiếp thị, lưu thời điểm, tắt (rút lại) được bất cứ lúc nào. Sự kiện / kênh chưa phát hành không hiện |
| BR-19 | **Gửi thông báo.** Gộp mọi thông báo cùng task, cùng người nhận trong 5 phút thành 1 (MSG-43). Email (trừ bắt buộc) có link huỷ đăng ký 1 chạm không cần đăng nhập, tắt đúng sự kiện × email, kèm header List-Unsubscribe `[giả định]`. Email lỗi tạm thời thử lại 3 lần `[giả định]`; bị trả về (bounce) cứng → ngừng gửi email tới địa chỉ đó, báo trong app |
| BR-20 | **Trung tâm thông báo.** Lưu 90 ngày `[giả định]`; badge số chưa đọc, tối đa "99+"; mới nhất trước, cursor pagination; đọc trên một thiết bị → đồng bộ thiết bị khác qua realtime ≤ 5 giây |
| BR-21 | **Audit / Team changes.** Audit hành động thanh toán từ 1.1; hành động quản trị và màn Team changes từ bản sau (BR-28). Ghi mọi hành động quản trị và thanh toán (mời, thu hồi, chấp nhận, chờ ghế, đổi vai trò, xoá / rời, chuyển quyền, tắt / tạo link mời, nâng cấp, đổi gói, huỷ, gia hạn lỗi, hoàn tiền, tranh chấp, chuyển chỉ đọc, xoá dữ liệu workspace): tác nhân, đối tượng, giá trị cũ / mới, thời điểm. Team changes hiện cho `OWNER` / `ADMIN` dạng "{A} trở thành Quản trị (do {B} nâng quyền)" |
| BR-22 | **Bản 1.0 (Beta).** App Windows, một người dùng (Q35, Q45). Mỗi tài khoản có một workspace cá nhân, là `OWNER` (G01 BR-05). Miễn phí, không giới hạn, gắn nhãn Beta; không có trạng thái gói, trial, Billing, banner gói, chế độ chỉ đọc, quyền theo gói. G12 ở 1.0 chỉ gồm: workspace cá nhân (đổi tên, SCR-12 #1), cài đặt Thông báo (UC-08), trung tâm thông báo (UC-09), huỷ đăng ký email |
| BR-23 | **Chuyển người dùng 1.0 sang 1.1.** Khi phát hành 1.1, mọi workspace có từ 1.0 chuyển `DUNG_THU` với `trialEndsAt` = thời điểm phát hành 1.1 + 14 ngày, không tính là đã dùng trial trước đó; email của chủ sở hữu được đánh dấu đã dùng trial (BR-02). Thông báo trial cho người dùng 1.0: MSG-55 trong app + email `[giả định]` |
| BR-24 | **Quyền theo gói (1.1).** G12 sở hữu bảng cấu hình quyền theo gói (QC-10), chỉ gồm: số tài khoản lịch kết nối (G05) và số tích hợp kết nối (G11). Trợ lý AI **không có hạn mức theo gói**: AI chạy bằng Claude Code CLI trên máy người dùng, dùng hạn mức gói Claude của chính họ (Q46, QC-12 mục 8; thay C32). Nhóm khác đọc từ cấu hình qua \[BillingGet\] `entitlements`, không rẽ nhánh theo tên gói. Danh sách gói, giá: câu hỏi mở |
| BR-25 | **Nhận lời mời khi đã có workspace (bản sau — BR-28).** (a) Workspace hiện tại chỉ có mình, gói `DUNG_THU`, `CHI_DOC` (chưa trả phí) hoặc Beta → hỏi MSG-48; đồng ý → trong một giao dịch: chuyển task cá nhân (series, channel đi kèm `[giả định]`) sang workspace mời với Privacy "Chỉ mình tôi", đóng (xoá) workspace cũ, rồi vào workspace mời theo BR-27. (b) Workspace hiện tại `HOAT_DONG` / `THU_LAI` (đang trả phí) hoặc có thành viên khác → chặn, MSG-47: phải huỷ gói hoặc chuyển quyền sở hữu trước. Gói `CHO_HUY` coi như đã huỷ, cho nhận theo (a) `[giả định]`, phần kỳ còn lại không hoàn |
| BR-26 | **Hoàn tiền và tranh chấp (1.1).** Sự kiện từ cổng: `refund` toàn phần cho kỳ hiện tại → gói `CHI_DOC` `[giả định]`; `refund` một phần → giữ trạng thái; `dispute` mở → giữ trạng thái, cảnh báo nội bộ; `dispute` thua → `CHI_DOC` `[giả định]`. Mỗi sự kiện sinh chứng từ điều chỉnh (BR-10), email MSG-54 cho chủ sở hữu, ghi BR-21. Hoàn tiền phần còn lại khi xoá tài khoản `[giả định — chờ pháp chế]`; huỷ giữa kỳ (bản sau: cả giảm ghế) không hoàn `[giả định]` |
| BR-27 | **Ghế mua trước (bản sau, 1.2 trở đi — BR-28).** Bản 1.1: gói cá nhân một người dùng, **không tính ghế**, không chọn hay đổi số ghế (Q47, ADR-0002). Từ bản sau: số ghế do `OWNER` mua (BR-03, BR-08); ghế trống = số ghế − số thành viên. Lời mời đang chờ **không** chiếm ghế. Lời mời email và link chung chỉ cho vào khi còn ghế trống; hết ghế → lời mời `CHO_GHE`, người được mời thấy MSG-46, `OWNER` nhận MSG-49. Không bao giờ tự cộng ghế hay trừ tiền khi `OWNER` không chủ động bấm. `OWNER` mua thêm ghế → người `CHO_GHE` được vào theo thứ tự chấp nhận sớm nhất `[giả định]`, mỗi ghế mới một người. Trong `DUNG_THU`: số ghế không giới hạn `[giả định]`; nâng cấp phải mua ≥ số thành viên |
| BR-28 | **Phạm vi một người dùng** (Q35, Q36, Q37, Q47). Bản 1.0 và 1.1 chỉ cho một người dùng; workspace luôn có đúng 1 người là `OWNER`; bản 1.1 có trial và thanh toán **gói cá nhân một người dùng, không tính ghế** (Q47, ADR-0002). Các phần nhiều thành viên trong SRS này giữ nguyên đặc tả nhưng **chưa làm**, phát hành ở bản sau (1.2 trở đi) — xem [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md): vai trò `ADMIN` / `MEMBER` (BR-01), mời và link mời (BR-11, BR-12, UC-04), xoá / rời thành viên (BR-13), chuyển quyền sở hữu, xoá workspace nhiều người (BR-14, UC-05 trừ A5), Privacy (BR-15, UC-06), giao / follow task (BR-16, BR-17, UC-07), Team changes (BR-21), nhận lời mời khi đã có workspace (BR-25), ghế mua trước và chọn / đổi số ghế (BR-27; phần ghế của BR-03, BR-08, UC-01 E5, UC-03 A5 – A6 / E1, SCR-03 #2), các thông báo MSG-09, MSG-15 – MSG-29, MSG-31 – MSG-33, MSG-40, MSG-41, MSG-44 – MSG-50, MSG-52. Quyết định đã chốt cho bản sau: task được giao vào bucket "Tuần sau", lên đầu (Q36, BR-16); Privacy "Lịch" chỉ lộ bận / rảnh và timebox (Q37, khuyến nghị, BR-15); thành viên tạo channel riêng tư, channel chung chỉ `OWNER` / `ADMIN` (khuyến nghị, chờ chốt khi làm). Trước khi phát hành, API tương ứng trả 404 |

## 4. Trạng thái

### 4.1. Trạng thái gói (1.1)

Bản 1.0 không có trạng thái gói (BR-22). Từ 1.1:

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DUNG_THU` | Trong 14 ngày trial (BR-02, BR-23); có thể đã nâng cấp, chờ kỳ đầu tại `trialEndsAt` (BR-03) | Billing "Dùng thử · còn {d} ngày" (không hiện số ghế ở 1.1, Q47); banner MSG-01 khi còn ≤ 3 ngày và chưa nâng cấp |
| `HOAT_DONG` | Đã thanh toán, kỳ hiện tại còn hạn | Billing hiện gói, ngày gia hạn |
| `THU_LAI` | Gia hạn lỗi, đang trong lịch thử lại ngày 1, 3, 7 | Banner đỏ MSG-02 cho chủ sở hữu; dùng đầy đủ |
| `CHO_HUY` | Đã huỷ, kỳ hiện tại còn hạn | Billing "Kết thúc ngày {ngày}" + "Tiếp tục gói" |
| `CHI_DOC` | Hết trial chưa trả / hết kỳ sau huỷ / thử lại ngày 7 lỗi / hoàn tiền toàn phần hoặc thua tranh chấp (BR-26) | Banner MSG-03 cho người dùng (bản sau: mọi thành viên); đóng băng theo QC-09 |
| `DA_XOA_DU_LIEU` | `CHI_DOC` quá 90 ngày, dữ liệu workspace đã xoá (BR-06) | Không còn workspace; tài khoản vẫn còn (bản sau: tài khoản mọi thành viên) |

Chuyển trạng thái: `DUNG_THU` → `HOAT_DONG` (UC-01, tại `trialEndsAt` nếu đã nâng cấp trong trial) hoặc → `CHI_DOC` (hết trial, UC-02) · `HOAT_DONG` → `THU_LAI` → `HOAT_DONG` / `CHI_DOC` (UC-02) · `THU_LAI` → `CHO_HUY` (huỷ khi đang thử lại, BR-05) · `HOAT_DONG` ⇄ `CHO_HUY` (UC-03) · `CHO_HUY` → `CHI_DOC` (hết kỳ) · `HOAT_DONG` / `THU_LAI` / `CHO_HUY` → `CHI_DOC` (refund toàn phần, dispute thua — BR-26) · `CHI_DOC` → `HOAT_DONG` (UC-01; thoát chỉ đọc theo QC-09) · `CHI_DOC` → `DA_XOA_DU_LIEU` (quá 90 ngày, BR-06).

### 4.2. Trạng thái lời mời và thông báo

Lời mời (bản sau — BR-28): `CHO_CHAP_NHAN` → `DA_CHAP_NHAN` (UC-04, còn ghế) / `CHO_GHE` (chấp nhận khi hết ghế, BR-27) / `HET_HAN` (sau 7 ngày) / `DA_THU_HOI`. `CHO_GHE` → `DA_CHAP_NHAN` (OWNER mua thêm ghế; có thành viên rời làm trống ghế `[giả định]`) / `DA_THU_HOI`. "Gửi lại" đưa `HET_HAN` về `CHO_CHAP_NHAN` với hạn mới. Thông báo (1.0): `CHUA_DOC` → `DA_DOC` (UC-09).

## 5. Use Case

### UC-01 Nâng cấp gói (1.1)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng là `OWNER`; gói `DUNG_THU` hoặc `CHI_DOC` |
| Hậu điều kiện thành công | Gói `HOAT_DONG`; hoá đơn PDF; email xác nhận; banner gỡ, hết chỉ đọc; audit BR-21 ghi |
| Hậu điều kiện thất bại | Gói giữ trạng thái cũ; không bị trừ tiền nếu cổng chưa xác nhận |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu | Bấm "Nâng cấp" trên **SCR-01**, **SCR-02** hoặc link trong email nhắc |
| 2 | Hệ thống | Gọi \[BillingGet\]; mở **SCR-03**: chu kỳ tháng / năm (không có số ghế, BR-03, Q47), thông tin xuất hoá đơn (BR-10), tổng tiền, ngày bắt đầu kỳ (đang `DUNG_THU`: `trialEndsAt`) |
| 3 | Chủ sở hữu | Chọn chu kỳ, nhập thông tin xuất hoá đơn, bấm "Thanh toán" |
| 4 | Hệ thống | Gọi \[BillingCheckout\] (Idempotency-Key); mở `checkoutUrl` của cổng (app desktop: trong trình duyệt hệ thống, cách quay về app như G01 BR-25 — tech chốt, `docs/tech/`) |
| 5 | Chủ sở hữu | Thanh toán trên trang của cổng |
| 6 | Cổng thanh toán | Gửi webhook → \[BillingWebhook\]: áp BR-04; gói `HOAT_DONG`; sinh hoá đơn (BR-10); gửi email; ghi BR-21 |
| 7 | Hệ thống | Cổng chuyển về app → SCR-03 hiện MSG-04, gọi \[BillingGet\] mỗi 3 giây tối đa 60 giây `[giả định]`; thấy `HOAT_DONG` → toast MSG-06, gỡ banner, bỏ chỉ đọc |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Quá 60 giây chưa có xác nhận | MSG-05; webhook đến sau → email + thông báo trong app, gói kích hoạt bình thường |
| A2 | Webhook đến trước khi người dùng quay về app | Bước 7 thấy `HOAT_DONG` ngay ở lần gọi đầu |
| A3 | `ADMIN` / `MEMBER` bấm "Nâng cấp" (bản sau — BR-28) | SCR-03 chỉ đọc, ghi "Chỉ chủ sở hữu thanh toán được", nút "Nhắc chủ sở hữu" gửi thông báo trong app `[giả định]` |
| A4 | Đang `CHI_DOC` | Thanh toán xong bỏ chỉ đọc ngay; dữ liệu giữ nguyên; rollover chạy bù một lần, không tính ngày đóng băng vào số ngày bị hoãn (QC-09) |
| A5 | Đang `DUNG_THU` | Cổng lưu phương thức thanh toán, chưa thu; gói giữ `DUNG_THU` tới `trialEndsAt` rồi `HOAT_DONG` và thu kỳ đầu (BR-03); bước 7 hiện MSG-53 thay MSG-06; banner trial gỡ |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Người dùng huỷ trên cổng / thẻ bị từ chối | Cổng chuyển về SCR-03 kèm trạng thái huỷ; MSG-07 |
| E2 | \[BillingCheckout\] lỗi / cổng không phản hồi | MSG-08; giữ lựa chọn trên SCR-03 |
| E3 | Webhook trùng (EC-35) | Bỏ qua, trả 200, không sinh hoá đơn thứ hai |
| E4 | Webhook sai chữ ký | Trả 400, không đổi trạng thái, cảnh báo nội bộ |
| E5 | (Bản sau — BR-28) Số ghế < số thành viên | MSG-09, chặn "Thanh toán". Bản 1.1 không có (Q47) |
| E6 | Mã số thuế sai định dạng (10 hoặc 13 số `[giả định]`) | MSG-56 tại trường, chặn "Thanh toán" |

### UC-02 Hết trial, gia hạn, thử lại và chế độ chỉ đọc (1.1)

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
| 3 | Hệ thống | Tới thời điểm hết trial, chưa thanh toán → `CHI_DOC` (BR-06): đóng băng theo QC-09 (dừng job ghi, timer tự dừng tại mốc), áp BR-07 cho thao tác đang dở; ghi BR-21 |
| 4 | Hệ thống | SCR-01 hiện MSG-03 cho người dùng (bản sau: mọi thành viên); thao tác ghi trả 402 → MSG-03 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Gói `HOAT_DONG` tới kỳ gia hạn, cổng thu thành công | Webhook → kỳ mới, hoá đơn (BR-10), email |
| A2 | Gia hạn lỗi | `THU_LAI`; MSG-02 cho chủ sở hữu; email kèm link cập nhật phương thức thanh toán; thử lại ngày 1, 3, 7 (BR-05) |
| A3 | Một lần thử lại thành công / chủ sở hữu cập nhật thẻ và thanh toán | `HOAT_DONG`, gỡ MSG-02 |
| A4 | Lần thử ngày 7 lỗi | `CHI_DOC` như bước 3–4 |
| A5 | `CHO_HUY` tới cuối kỳ | `CHI_DOC` như bước 3–4 |
| A6 | Người dùng đang làm Daily planning / shutdown lúc hết hạn (EC-34) | Cho hoàn tất ritual trong 2 giờ, kể cả thao tác task bên trong (BR-07, QC-09); sau đó banner MSG-03 |
| A7 | `CHI_DOC` còn 30 / 7 ngày tới mốc xoá | MSG-51 cho `OWNER` (bản sau: **mọi thành viên**): trong app + email bắt buộc (BR-06, BR-18) |
| A8 | `CHI_DOC` đủ 90 ngày | Xoá dữ liệu workspace (không xoá tài khoản) → `DA_XOA_DU_LIEU`; email cho `OWNER` (bản sau: mọi thành viên); ghi BR-21; hoá đơn giữ (BR-10) |
| A9 | Huỷ gói khi đang `THU_LAI` | `CHO_HUY`, ngừng thử lại (BR-05); gỡ MSG-02 |
| A10 | Webhook `refund` / `dispute` | Áp BR-26; MSG-54 cho chủ sở hữu |
| A11 | Thao tác offline tạo trước mốc chỉ đọc, đồng bộ trong 2 giờ sau mốc | Nhận như bình thường (QC-09) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Job chạy lại / chạy trùng | Idempotent theo workspace + mốc; không gửi nhắc trùng |
| E2 | Webhook đến sai thứ tự | Áp BR-04: sự kiện cũ hơn trạng thái hiện tại không đổi trạng thái |
| E3 | Đối soát hằng ngày `[giả định]` thấy lệch với cổng | Cảnh báo nội bộ; trạng thái theo dữ liệu cổng sau khi kiểm tra |

### UC-03 Đổi gói, huỷ gói và tải hoá đơn (1.1; đổi số ghế: bản sau)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng là `OWNER`; gói `HOAT_DONG`, `THU_LAI` hoặc `CHO_HUY` |
| Hậu điều kiện thành công | Gói / trạng thái huỷ cập nhật theo BR-08, BR-09; audit BR-21 ghi (Team changes: bản sau) |
| Hậu điều kiện thất bại | Gói giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu | SCR-02 → "Đổi gói" → SCR-03 ở chế độ đổi |
| 2 | Chủ sở hữu | Chọn chu kỳ mới (số ghế: bản sau, BR-08) |
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
| A5 | Năm → tháng (bản sau: cả giảm ghế) | Ghi "Có hiệu lực từ {ngày}" (BR-08), không thu ngay |
| A6 | (Bản sau — BR-28) Tăng ghế khi có lời mời `CHO_GHE` | Sau webhook xác nhận: người chờ vào theo BR-27, mỗi người nhận thông báo đã vào workspace |
| A7 | Sửa thông tin xuất hoá đơn | SCR-02 → "Thông tin hoá đơn" → \[BillingUpdate\] `billingInfo`; áp cho hoá đơn kế tiếp (BR-10) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | (Bản sau — BR-28) Số ghế < số thành viên | MSG-09, chặn xác nhận |
| E2 | Thu phần chênh lỗi | Giữ gói cũ, MSG-07 |
| E3 | Không phải `OWNER` | MSG-14 |
| E4 | Lỗi 5xx | MSG-38 |

### UC-04 Mời thành viên (bản sau — BR-28)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người mời là `OWNER` / `ADMIN`; workspace không `CHI_DOC` |
| Hậu điều kiện thành công | Lời mời `CHO_CHAP_NHAN`, email đã gửi; khi chấp nhận: thành viên mới chiếm 1 ghế trống (hoặc `CHO_GHE` khi hết ghế), Team changes ghi; số ghế và tiền không tự đổi |
| Hậu điều kiện thất bại | Không có lời mời mới |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Chủ sở hữu / Quản trị | Cài đặt → Thành viên (**SCR-05**) → "Thêm đồng nghiệp" → **SCR-06** |
| 2 | Chủ sở hữu / Quản trị | Nhập email, tên (tuỳ chọn), vai trò; "Thêm người" cho dòng mới |
| 3 | Hệ thống | Kiểm tra định dạng, ≤ 20 dòng; hiện ghế đang dùng / tổng ghế (MSG-52); số lời mời vượt số ghế trống thì nhắc người chấp nhận sau sẽ chờ ghế (BR-27) |
| 4 | Chủ sở hữu / Quản trị | Bấm "Gửi lời mời" |
| 5 | Hệ thống | Gọi \[InviteCreate\]; bỏ email trùng (EC-32); tạo lời mời 7 ngày, gửi email; MSG-17; SCR-05 hiện mục "Đang chờ" |
| 6 | Người được mời | Mở link → **SCR-13** → đăng ký / đăng nhập (G01) → \[InviteAccept\] → vào thẳng workspace |
| 7 | Hệ thống | Còn ghế trống (BR-27) → lời mời `DA_CHAP_NHAN`, thành viên chiếm 1 ghế; Team changes ghi; người mời nhận thông báo trong app |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Dùng link mời chung | SCR-06 "Link đăng ký" → "Sao chép link" → MSG-18; "Tạo link mới" → MSG-19 → \[InviteLinkRotate\] (BR-12) |
| A2 | "Gửi lại" lời mời đang chờ / hết hạn | \[InviteResend\]; hạn mới 7 ngày |
| A3 | "Thu hồi" lời mời | \[InviteRevoke\] → `DA_THU_HOI`; link trả MSG-20 |
| A4 | Workspace đang `DUNG_THU` | Không giới hạn ghế `[giả định]`; ghi "Khi nâng cấp, bạn mua số ghế ≥ số thành viên" |
| A5 | Bước 7: hết ghế trống | Lời mời `CHO_GHE`; SCR-13 hiện MSG-46; `OWNER` nhận MSG-49 (trong app + email); không cộng ghế, không thu tiền (BR-27) |
| A6 | Người được mời đã có workspace một người, chưa trả phí (BR-25 a) | Trước bước 7: SCR-13 hiện MSG-48; "Nhận lời mời" → chuyển task cá nhân sang workspace mời ("Chỉ mình tôi"), đóng workspace cũ, rồi bước 7 |
| A7 | `OWNER` mua thêm ghế khi có lời mời `CHO_GHE` | UC-03 A6; người chờ vào theo thứ tự (BR-27) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | > 20 email / email sai định dạng | MSG-15 / MSG-16 tại dòng lỗi |
| E2 | Link hết hạn / bị thu hồi / link chung đã tạo mới | SCR-13 hiện MSG-20 |
| E3 | Link chung khi đã bật "Tắt mời qua link" | SCR-13 hiện MSG-21 |
| E4 | Người nhận đăng nhập bằng email khác email được mời | MSG-44, nút "Đăng xuất và đăng nhập email khác" |
| E5 | Người gọi là `MEMBER` / workspace `CHI_DOC` | MSG-14 / MSG-03 |
| E6 | Người được mời có workspace đang trả phí hoặc có thành viên khác (BR-25 b) | SCR-13 hiện MSG-47, không vào workspace mời; lời mời giữ `CHO_CHAP_NHAN` tới hạn |

### UC-05 Quản lý thành viên và workspace (bản sau — BR-28; riêng A5 đổi tên workspace có từ 1.0)

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
| A1 | Xoá thành viên | Menu … → "Xoá khỏi workspace" → **SCR-07** (MSG-23) → \[MemberRemove\] → BR-13 (task cá nhân sang workspace cá nhân mới) → MSG-24; người bị xoá thấy MSG-28 |
| A2 | Chuyển quyền sở hữu | SCR-05 → "Chuyển quyền sở hữu" → SCR-07 chọn người + mật khẩu hoặc "Xác nhận bằng Google / Microsoft" (G01 BR-10) → \[OwnershipTransfer\] → MSG-26; gỡ thẻ chủ cũ; chủ mới nhận MSG-50 (BR-14) |
| A3 | Rời workspace (`ADMIN` / `MEMBER`) | SCR-05 → "Rời workspace" → xác nhận → \[MemberLeave\] → BR-13 |
| A4 | Xoá workspace | Cài đặt → Workspace (**SCR-12**) → "Xoá workspace" → gõ tên → \[WorkspaceDelete\] (BR-14) |
| A5 | Đổi tên workspace (1.0 và 1.1) | SCR-12 → \[WorkspaceUpdate\]; lưu ngay |
| A6 | Chủ mới chưa nhập phương thức thanh toán tới kỳ kế tiếp | Gia hạn lỗi → `THU_LAI` (BR-05), MSG-02 cho chủ mới |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | `ADMIN` đổi vai trò / xoá `OWNER`; `MEMBER` gọi API quản trị | MSG-14 |
| E2 | `OWNER` rời workspace khi còn thành viên (EC-36) | MSG-25, nút "Chuyển quyền sở hữu" · "Xoá workspace" |
| E3 | Tên workspace gõ không khớp / mật khẩu sai / `reauthToken` không hợp lệ | MSG-27 / thông báo của G01 (MSG-29 / MSG-11) |
| E4 | Lỗi 5xx | MSG-38 |

### UC-06 Cài đặt quyền riêng tư (bản sau — BR-28)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Workspace có ≥ 2 thành viên hoặc lời mời đang chờ (ngược lại SCR-08 vẫn mở được, chỉ có ghi chú) |
| Hậu điều kiện thành công | Cài đặt Privacy của người dùng lưu; quyền xem của người khác cập nhật ≤ 5 giây |
| Hậu điều kiện thất bại | Giữ cài đặt cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Privacy (**SCR-08**) |
| 2 | Hệ thống | Gọi \[PrivacyGet\]; hiện 5 loại dữ liệu và ghi chú MSG-29 |
| 3 | Người dùng | Đổi một loại giữa "Chỉ mình tôi" / "Thành viên" |
| 4 | Hệ thống | Gọi \[PrivacyUpdate\]; phát `settings.changed`; quyền xem của thành viên khác cập nhật ≤ 5 giây (BR-15) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | `OWNER` / `ADMIN` bật "Tắt mời qua link" | \[PrivacyUpdate\] cấp workspace; link chung trả MSG-21 (BR-12) |
| A2 | Thành viên khác đang xem dữ liệu vừa chuyển "Chỉ mình tôi" (EC-33) | Phía họ ẩn dữ liệu, đóng chi tiết đang mở, MSG-30; trừ task họ đã giao / được giao / đang follow (BR-15) |
| A3 | Task trong channel private | Luôn ẩn với người khác, bất kể cài đặt |
| A4 | Task được giao hoặc có người follow | Luôn hiện tiêu đề, trạng thái, comment với người giao, người được giao, người follow, bất kể Privacy (BR-15) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[PrivacyUpdate\] lỗi | Trả về giá trị cũ, MSG-38 |
| E2 | `MEMBER` đổi "Tắt mời qua link" | Toggle disabled; API trả MSG-14 |

### UC-07 Giao task và follow task (bản sau — BR-28)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task tồn tại, không ở `DA_XOA` (G02, QC-03); người thao tác thấy được task (BR-15); workspace không `CHI_DOC` |
| Hậu điều kiện thành công | Người được giao / người follow cập nhật; thông báo gửi theo BR-16, BR-17; nhật ký task ghi |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Chi tiết task (G02) → ô "Giao cho" (**SCR-09**) → chọn thành viên |
| 2 | Hệ thống | Gọi \[TaskAssign\]; task vào backlog của người được giao ở bucket "Tuần sau", đầu bucket (BR-16, Q36, G06); người giao tự follow; task hiển thị với người giao / được giao / follow bất kể Privacy (BR-15) |
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
| A4 | Hệ điều hành chưa cho app gửi thông báo (Windows 1.0, D12; macOS 1.1; iOS / Android 1.2) | Hiện nút "Cho phép thông báo" mở quyền thông báo của hệ điều hành |

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

iOS / Android (1.2) dùng cùng điểm vào với cột Web / macOS.

| **Điểm vào** | **App Windows** (1.0) | **Web / macOS** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Banner trial / gia hạn lỗi / chỉ đọc trên Home | ✓ (từ 1.1) | ✓ | SCR-01 → SCR-03 |
| Email nhắc trial, gia hạn lỗi, sắp xoá dữ liệu | ✓ (từ 1.1, deep link) | ✓ | SCR-03 / trang cổng / G01 xuất dữ liệu |
| Cài đặt → Billing | ✓ (từ 1.1) | ✓ | SCR-02 |
| Thông báo "{email} đang chờ ghế" (MSG-49) | Bản sau | Bản sau | SCR-03 chế độ đổi, tăng ghế (BR-28) |
| Cài đặt → Workspace | ✓ | ✓ | SCR-12 (bản 1: chỉ đổi tên) |
| Cài đặt → Thành viên / menu workspace "Mời đồng nghiệp" | Bản sau | Bản sau | SCR-05, SCR-06 (BR-28) |
| Link mời trong email / link mời chung | Bản sau | Bản sau | SCR-13 → G01 (BR-28) |
| Cài đặt → Privacy | Bản sau | Bản sau | SCR-08 (BR-28) |
| Chi tiết task → "Giao cho" / "Theo dõi" | Bản sau | Bản sau | SCR-09 (BR-28) |
| Cài đặt → Thông báo | ✓ | ✓ | SCR-10 |
| Chuông ở cụm dưới sidebar | ✓ | ✓ | SCR-11 dạng popover cạnh chuông (IA-10) |
| Thông báo hệ thống Windows của app | ✓ (D12) | macOS ✓ | Đưa cửa sổ app lên trước (kể cả từ khay) rồi mở đúng đích như SCR-11 (IA-10) |
| Link "Huỷ nhận loại email này" | Trình duyệt (trang web tối giản, không cần app) | ✓ | SCR-14 |

## 7. Mô tả màn hình

### SCR-01 Banner gói (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Banner trial | Banner (thông tin) | MSG-01, chỉ chủ sở hữu, khi còn ≤ 3 ngày và chưa nâng cấp; đóng được, hiện lại ngày hôm sau |
| 2 | Banner gia hạn lỗi | Banner (đỏ) | MSG-02, chỉ chủ sở hữu, không đóng được |
| 3 | Banner chỉ đọc | Banner (đỏ) | MSG-03 cho người dùng (bản sau: mọi thành viên; `ADMIN` / `MEMBER` thấy "Liên hệ chủ sở hữu" thay nút "Nâng cấp") |

### SCR-02 Billing (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Thẻ gói | Card | "{Gói} · {còn d ngày / gia hạn ngày …}" (Sunsama: "Sunsama Free Trial · 1 seat · 14 days remaining"); bản 1.1 không hiện ghế (Q47), bản sau thêm "{đã dùng x / y} ghế"; đã nâng cấp trong trial: "Bắt đầu tính tiền ngày {trialEndsAt}" |
| 2 | "Nâng cấp" / "Đổi gói" | Button | SCR-03 |
| 3 | Phương thức thanh toán | Text + link | Loại thẻ / ví, 4 số cuối do cổng trả về; "Cập nhật" → A4 UC-03; trống sau chuyển quyền → MSG-50 |
| 4 | Hoá đơn | List | Ngày, số tiền, trạng thái (kể cả hoàn tiền / điều chỉnh), "PDF" |
| 7 | Thông tin xuất hoá đơn | Text + "Sửa" | Tên người mua / đơn vị, mã số thuế, địa chỉ, email nhận; A7 UC-03 |
| 5 | Team changes | List | Nhật ký BR-21 mới nhất trước; chỉ `OWNER` / `ADMIN` |
| 6 | "Huỷ gói" / "Tiếp tục gói" | Link | SCR-04 / A2 UC-03 |

(Bản sau) `ADMIN` / `MEMBER` chỉ thấy mục 1 và 5 (`ADMIN`). Bản 1 không hiện mục 5 Team changes.

### SCR-03 Chọn / đổi gói (1.1)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Chu kỳ | Segmented Tháng / Năm | Có | Hiện giá và mức tiết kiệm của gói năm (giá: câu hỏi mở) |
| 2 | Số ghế (bản sau — BR-28) | Stepper | Bản sau | Bản 1.1 không hiện (gói cá nhân, Q47). Bản sau: ≥ số thành viên (MSG-09); hiện số lời mời `CHO_GHE` để gợi ý mua thêm (BR-27) |
| 3 | Tổng tiền, ngày bắt đầu kỳ / gia hạn kế tiếp | Text | – | Đang `DUNG_THU`: kỳ bắt đầu `trialEndsAt` (BR-03); chế độ đổi: hiện MSG-10 |
| 6 | Thông tin xuất hoá đơn | Text ×4 (tên, mã số thuế, địa chỉ, email) | Tên, email: Có; mã số thuế: khi xuất cho tổ chức `[giả định]` | BR-10; mã số thuế sai → MSG-56 |
| 4 | "Thanh toán" / "Xác nhận" | Button | – | UC-01 bước 4 / UC-03 bước 5; chặn bấm 2 lần |
| 5 | Trạng thái xác nhận | Inline | – | MSG-04 khi quay về từ cổng; MSG-05 sau 60 giây |

### SCR-04 Huỷ gói (1.1)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "Gói vẫn dùng đầy đủ tới {ngày}. Sau đó workspace chuyển chỉ đọc; bạn vẫn xem và xuất được dữ liệu." |
| 2 | Lý do huỷ | Radio + text | Không bắt buộc `[giả định]` |
| 3 | "Huỷ gói" | Button (nguy hiểm) | \[BillingCancel\]; MSG-12 |
| 4 | "Giữ gói" | Button | Đóng |

### SCR-05 Thành viên (bản sau — BR-28)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Thêm đồng nghiệp" | Button | SCR-06; ẩn với `MEMBER` |
| 2 | Danh sách thành viên | List | Avatar, tên, email, vai trò ("Chủ sở hữu" không đổi được ở đây), ngày tham gia |
| 3 | Menu vai trò | Dropdown | UC-05 bước 1–3; ẩn với `MEMBER` |
| 4 | Menu … | Menu | "Xoá khỏi workspace" (SCR-07); "Chuyển quyền sở hữu" (chỉ `OWNER`) |
| 5 | Mục "Đang chờ" | List | Email, vai trò, hạn; "Gửi lại", "Thu hồi" |
| 6 | "Rời workspace" | Link | A3 UC-05; chủ sở hữu duy nhất → MSG-25 |
| 7 | Ghế | Text + link | MSG-52; "Mua thêm ghế" (chỉ `OWNER`) → SCR-03 chế độ đổi |
| 8 | Mục "Chờ ghế" | List | Email, thời điểm chấp nhận (lời mời `CHO_GHE`, BR-27); "Thu hồi" |

### SCR-06 Mời đồng nghiệp (bản sau — BR-28)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tiêu đề | Text | – | "Thêm đồng nghiệp vào gói" (Sunsama: "Add colleagues to your subscription") |
| 2 | Dòng mời: Email, Tên, Vai trò | Text, Text, Dropdown | Email: Có | Email sai → MSG-16; vai trò mặc định Thành viên |
| 3 | "Thêm người" | Link | – | Thêm dòng; quá 20 → MSG-15 |
| 4 | Ghi chú | Text | – | "Mỗi người có không gian riêng tư của mình." + MSG-52 (ghế đang dùng; người chấp nhận khi hết ghế sẽ chờ). Không cộng ghế, không hiện tiền tăng (BR-27); A4 UC-04 khi trial |
| 5 | Link đăng ký | Text chỉ đọc + "Sao chép link" + "Tạo link mới" | – | MSG-18 / MSG-19; ẩn khi bật "Tắt mời qua link" |
| 6 | "Gửi lời mời" | Button | – | Disabled khi không có email hợp lệ |

### SCR-07 Xoá thành viên / chuyển quyền sở hữu (bản sau — BR-28)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung xoá | Text | MSG-23 |
| 2 | "Xoá" | Button (nguy hiểm) | \[MemberRemove\]; MSG-24 |
| 3 | Chuyển quyền: chọn người nhận | Dropdown | Thành viên hiện có, trừ chính mình |
| 4 | Chuyển quyền: xác nhận lại | Password hoặc "Xác nhận bằng Google / Microsoft" | Theo G01 BR-10 (`reauthToken`); ghi chú "Phương thức thanh toán của bạn sẽ được gỡ; chủ mới cần nhập phương thức thanh toán trước {ngày gia hạn}" |
| 5 | "Chuyển quyền" | Button | \[OwnershipTransfer\]; MSG-26 |
| 6 | "Huỷ" | Button | Đóng |

### SCR-08 Privacy (bản sau — BR-28)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ghi chú | Text | – | MSG-29 |
| 2 | Task, Highlights, Channel, Lịch, Tích hợp | 5 dropdown "Chỉ mình tôi" / "Thành viên" | Có | Mặc định "Chỉ mình tôi"; lưu ngay (UC-06). Ghi chú dưới "Task": "Task bạn giao, được giao hoặc có người theo dõi luôn hiện với những người đó" (BR-15) |
| 3 | Tắt mời qua link | Toggle (cấp workspace) | – | Chỉ `OWNER` / `ADMIN`; A1 UC-06 |

### SCR-09 Giao task và theo dõi (thành phần trong chi tiết task G02, bản sau — BR-28)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | "Giao cho" | Dropdown có tìm (avatar + tên) | Danh sách thành viên; "Bỏ giao"; disabled với task channel private (MSG-45) |
| 2 | Avatar người được giao trên card (G02 SCR-02) | Avatar | Hover hiện tên |
| 3 | "Theo dõi" / "Đang theo dõi" | Toggle button | A3 UC-07 |
| 4 | Người theo dõi | Avatar list | Tối đa 5 avatar + "+n" |

### SCR-10 Cài đặt Thông báo

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Bảng sự kiện × kênh | Ma trận toggle | – | Hàng: sự kiện PRD mục 5 (theo bản phát hành); cột: Trong app, Email, Desktop (thông báo hệ thống Windows, 1.0, D12), Mobile (1.2) |
| 2 | Ô bắt buộc | Toggle khoá | – | Tooltip MSG-34 |
| 3 | "Cho phép thông báo trên thiết bị" | Button | – | A4 UC-08; ẩn khi đã cho phép |
| 4 | Product updates | Toggle | – | Mặc định tắt `[giả định]` |

### SCR-11 Trung tâm thông báo

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Chuông + badge | Icon | Số chưa đọc, tối đa "99+" |
| 2 | Danh sách | Popover cạnh chuông (IA-10) | Mới nhất trước; mỗi dòng: icon loại, nội dung (MSG-40 – MSG-43…), thời gian tương đối, chấm chưa đọc |
| 3 | "Đánh dấu tất cả đã đọc" | Link | A1 UC-09 |
| 4 | "Cài đặt thông báo" | Icon | SCR-10 |
| 5 | Trạng thái rỗng | Empty state | MSG-37 |

### SCR-12 Workspace

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tên workspace | Text | 1–80 ký tự `[giả định]`; `OWNER` / `ADMIN` sửa được; lưu ngay (1.0 và 1.1) |
| 2 | "Xoá workspace" | Button (nguy hiểm) | 1.1, chỉ `OWNER`; mở dialog: hậu quả, ô gõ tên (MSG-27), "Xoá vĩnh viễn". Ẩn ở 1.0 (xoá workspace cá nhân = xoá tài khoản, G01) |

### SCR-13 Trang lời mời (bản sau — BR-28)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "{Người mời} mời bạn vào {workspace}" |
| 2 | "Tạo tài khoản" / "Đăng nhập" | Button | G01 với email điền sẵn, `inviteToken` |
| 3 | Lỗi | Inline | MSG-20 / MSG-21 / MSG-44 / MSG-47 |
| 4 | Xác nhận chuyển dữ liệu | Dialog | MSG-48 khi người được mời đã có workspace một người chưa trả phí (BR-25 a) |
| 5 | Trạng thái chờ ghế | Inline | MSG-46 (BR-27) |

### SCR-14 Trang huỷ đăng ký email

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Kết quả | Text | MSG-35 / MSG-36 |
| 2 | "Bật lại" | Button | \[Unsubscribe\] `undo=true` |
| 3 | "Mở cài đặt thông báo" | Link | SCR-10 (cần đăng nhập) |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[BillingGet\] `GET /billing` (1.1) | – | status, plan, interval, seats, seatsUsed, pendingSeatInvites (ba trường ghế: bản sau, Q47), trialEndsAt, firstPeriodStart, currentPeriodEnd, cancelAt, paymentMethodSummary, billingInfo, entitlements (QC-10: số tài khoản lịch, số tích hợp; không có hạn mức AI) | 5s / 2 lần |
| \[BillingCheckout\] `POST /billing/checkout` (1.1) | interval, seats? (bản sau; 1.1 không gửi, Q47), billingInfo {name, taxId?, address, invoiceEmail}, returnUrl, Idempotency-Key | checkoutUrl, checkoutId | 10s / 1 lần cùng key |
| \[BillingWebhook\] `POST /webhooks/billing` (1.1) | Payload + chữ ký của cổng, eventId; loại sự kiện gồm thanh toán, gia hạn, `refund`, `dispute` (BR-26) | 200 (kể cả trùng) / 400 (chữ ký sai) | Cổng tự retry; xử lý ≤ 10s |
| \[BillingUpdate\] `PATCH /billing/subscription` `[giả định]` (1.1) | interval?, seats? (bản sau), billingInfo?, preview | prorationAmount, nextAmount, effectiveAt | 10s / 1 lần |
| \[BillingCancel\] / \[BillingResume\] `POST /billing/cancel`, `/billing/resume` `[giả định]` | reason? | status, cancelAt | 5s / 1 lần |
| \[InvoiceList\] `GET /billing/invoices` `[giả định]` | cursor | Invoice[] (pdfUrl) | 5s / 1 lần |
| \[TeamChanges\] `GET /billing/team-changes` `[giả định]` | cursor | Entry[] | 5s / 1 lần |
| \[MemberList\] / \[MemberUpdate\] / \[MemberRemove\] `GET /members`, `PATCH` / `DELETE /members/{id}` | role | Member, seats | 5s / 1 lần |
| \[MemberLeave\] `POST /members/me/leave` `[giả định]` | – | 204 | 5s / 1 lần |
| \[InviteCreate\] `POST /invites` | items[{email, name?, role}], Idempotency-Key | created[], skipped[{email, reason}] | 10s / 1 lần cùng key |
| \[InviteResend\] / \[InviteRevoke\] `POST /invites/{id}/resend`, `DELETE /invites/{id}` | id | Invite | 5s / 1 lần |
| \[InviteLinkRotate\] `POST /invites/link` | – | signupLinkUrl | 5s / 1 lần |
| \[InviteAccept\] `POST /invites/{token}/accept` `[giả định]` | token (sau khi đăng nhập, G01), confirmMoveData? (BR-25 a) | workspaceId, role, status (`DA_CHAP_NHAN` / `CHO_GHE`), `needsMoveConfirm`, movedTaskCount | 5s / 2 lần |
| \[PrivacyGet\] / \[PrivacyUpdate\] `GET` / `PATCH /privacy` | dataType → `only_me` / `members`; disableLinkInvites (cấp workspace) | Privacy | 5s / 2 lần |
| \[OwnershipTransfer\] `POST /workspace/transfer-ownership` `[giả định]` | newOwnerId, currentPassword \| reauthToken (G01 BR-10) | Workspace, paymentMethodRequiredBy | 10s / không retry |
| \[WorkspaceUpdate\] / \[WorkspaceDelete\] `PATCH` / `DELETE /workspace` `[giả định]` | name / confirmName | Workspace / 202 | 10s / không retry (DELETE) |
| \[TaskAssign\] `PUT /tasks/{id}/assignee` `[giả định]` | assigneeId \| null | Task | 5s / 2 lần |
| \[TaskFollow\] / \[TaskUnfollow\] `POST` / `DELETE /tasks/{id}/followers` `[giả định]` | – | followers[] | 5s / 2 lần |
| \[SettingsGet\] / \[SettingsUpdate\] | Nhóm `notifications` (G01) | Settings | Theo G01 |
| \[NotificationList\] `GET /notifications` | cursor, limit ≤ 200, unreadOnly? | Notification[], unreadCount, nextCursor | 5s / 2 lần |
| \[NotificationRead\] `POST /notifications/read` | ids[] \| all | unreadCount | 5s / 2 lần |
| \[Unsubscribe\] `POST /notifications/unsubscribe` `[giả định]` | token, undo? | eventType, channel, enabled | 5s / 1 lần |

Path đánh dấu `[giả định]` chưa có trong danh sách API đã chốt; cần BE xác nhận. Mọi API ghi dữ liệu nghiệp vụ khi `CHI_DOC` trả 402 `WORKSPACE_READ_ONLY` (BR-06, QC-09). API Billing, trial chỉ có từ 1.1; ở 1.0 trả 404. API thành viên, lời mời, ghế, Privacy, chuyển quyền sở hữu, giao / follow task (\[MemberList\], \[MemberUpdate\], \[MemberRemove\], \[MemberLeave\], \[Invite\*\], \[PrivacyGet\] / \[PrivacyUpdate\], \[OwnershipTransfer\], \[TeamChanges\], \[TaskAssign\], \[TaskFollow\] / \[TaskUnfollow\]) là bản sau (BR-28); trước đó trả 404.

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
| `NO_SEAT_AVAILABLE` (202, lời mời `CHO_GHE`) | MSG-46 |
| `EXISTING_WORKSPACE_BLOCKS_JOIN` (409) | MSG-47 |
| `MOVE_DATA_CONFIRM_REQUIRED` (409) | MSG-48 |
| `TAX_ID_INVALID` (422) | MSG-56 |
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
| MSG-09 | Inline | Số ghế không được ít hơn {n} (số thành viên hiện tại) |
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
| MSG-23 | Dialog | Xoá {tên} khỏi workspace? Timer đang chạy sẽ dừng, {n} task được giao chưa xong chuyển về người giao, task cá nhân của {tên} chuyển sang workspace cá nhân mới của họ. Gói giảm 1 ghế từ kỳ sau |
| MSG-24 | Toast | Đã xoá {tên} khỏi workspace |
| MSG-25 | Inline | Bạn là chủ sở hữu duy nhất. Hãy chuyển quyền sở hữu trước · Chuyển quyền sở hữu |
| MSG-26 | Toast | {tên} là chủ sở hữu mới. Bạn trở thành Quản trị |
| MSG-27 | Inline | Gõ đúng tên workspace để xác nhận |
| MSG-28 | Màn hình | Bạn không còn là thành viên của {workspace}. Task cá nhân của bạn đã được chuyển sang workspace cá nhân mới |
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
| MSG-46 | SCR-13 | {workspace} đã hết ghế. Chúng tôi đã báo chủ sở hữu; bạn sẽ vào workspace ngay khi có ghế trống |
| MSG-47 | SCR-13 | Bạn đang có workspace "{tên}" đang trả phí hoặc có thành viên khác. Hãy huỷ gói hoặc chuyển quyền sở hữu trước khi nhận lời mời |
| MSG-48 | Dialog | Task cá nhân của bạn sẽ chuyển sang {workspace mời} ở chế độ "Chỉ mình tôi", workspace "{tên cũ}" sẽ bị đóng · Nhận lời mời · Huỷ |
| MSG-49 | Trung tâm / email | {email} đã chấp nhận lời mời nhưng {workspace} đã hết ghế · Mua thêm ghế |
| MSG-50 | Trung tâm / email | Bạn là chủ sở hữu mới của {workspace}. Hãy nhập phương thức thanh toán trước {ngày} để gói không bị gián đoạn · Cập nhật thanh toán |
| MSG-51 | Trung tâm / email (bắt buộc) | Workspace {tên} ở chế độ chỉ đọc. Dữ liệu workspace sẽ bị xoá ngày {ngày}; tài khoản của bạn vẫn giữ. Xuất dữ liệu trước ngày đó · Xuất dữ liệu · Nâng cấp |
| MSG-52 | Inline SCR-05 / SCR-06 | Đang dùng {x}/{y} ghế. Người chấp nhận lời mời khi hết ghế sẽ chờ tới khi bạn mua thêm ghế · Mua thêm ghế |
| MSG-53 | Toast | Đã lưu phương thức thanh toán. Gói {gói} bắt đầu tính tiền từ {ngày kết thúc trial} |
| MSG-54 | Trung tâm / email | Đã ghi nhận {hoàn tiền {số tiền} / tranh chấp} cho hoá đơn {số}. Trạng thái gói: {trạng thái} |
| MSG-55 | Trung tâm / email | Bản mới đã có gói trả phí. Bạn được dùng thử miễn phí 14 ngày, tới {ngày} · Xem gói |
| MSG-56 | Inline | Mã số thuế chưa đúng định dạng |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | SCR-02 mở ≤ 1s; webhook xử lý xong ≤ 10s từ khi nhận; thông báo trong app tới người nhận ≤ 5s; email thông báo ≤ 2 phút (p95); \[InviteCreate\] 20 email ≤ 2s |
| Độ tin cậy | Webhook idempotent (BR-04); đối soát trạng thái gói với cổng hằng ngày; job `billing.lifecycle` idempotent; job chuyển 1.0 → 1.1 (BR-23) idempotent theo workspace; không mất thông báo khi dịch vụ email lỗi (hàng đợi, thử lại BR-19); chế độ chỉ đọc đóng băng mọi job ghi theo QC-09 |
| Nền tảng | 1.0: app Windows (Flutter), một người dùng (ADR-0005); thông báo hệ thống Windows (D12). Trang huỷ đăng ký email (SCR-14) và trang cổng thanh toán mở trong trình duyệt. Web, macOS (1.1), iOS / Android (1.2) dùng cùng quy tắc nghiệp vụ |
| Offline | Billing, mời, thành viên, Privacy cần mạng; trung tâm thông báo xem bản cache, đánh dấu đã đọc xếp hàng đợi |
| Bảo mật | Không chạm số thẻ (PCI DSS — chỉ hosted checkout của cổng); xác thực chữ ký webhook, chỉ nhận từ IP / secret của cổng; quyền vai trò (BR-01) và Privacy (BR-15) kiểm tra ở server, có kiểm thử tự động cho cả 5 loại dữ liệu và ngoại lệ giao / follow; token mời và token huỷ đăng ký ngẫu nhiên ≥ 128 bit, chỉ lưu dạng băm |
| Quyền riêng tư, tuân thủ | Product updates cần đồng ý, rút lại được (BR-18); hoá đơn điện tử theo NĐ 123/2020/NĐ-CP, thu mã số thuế, giữ hoá đơn và chứng từ 10 năm (BR-10); hoàn tiền khi xoá tài khoản chờ pháp chế (Luật Bảo vệ quyền lợi người tiêu dùng 2023); nơi lưu dữ liệu: 1.0 máy chủ khu vực châu Á, cần hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (NĐ 13/2023), pháp chế xác nhận trước phát hành |
| Log / audit | BR-21 cho mọi hành động quản trị và thanh toán, giữ ≥ 1 năm; nhật ký webhook giữ payload đã lược bỏ dữ liệu cá nhân |
| Tracking | Sự kiện: `trial_banner_shown`, `upgrade_clicked` (nguồn), `checkout_started`, `checkout_completed` / `_failed`, `subscription_renewed` / `_retry_failed`, `workspace_read_only`, `subscription_changed`, `subscription_cancelled` / `_resumed`, `trial_migrated_from_beta`, `subscription_refunded` / `_disputed`, `workspace_data_purged`, `invite_sent` (số email, vai trò), `invite_accepted`, `invite_waiting_seat`, `invite_blocked_existing_workspace`, `personal_data_moved` (số task), `invite_link_copied`, `member_role_changed`, `member_removed`, `ownership_transferred`, `privacy_changed` (loại dữ liệu), `task_assigned`, `task_followed`, `notification_setting_changed`, `notification_opened`, `email_unsubscribed` |
| Accessibility | Banner có role="status" / "alert" theo mức độ; ma trận toggle SCR-10 có nhãn "{sự kiện} – {kênh}"; badge chuông đọc được số chưa đọc; điều hướng bằng bàn phím đầy đủ; tương phản đạt WCAG 2.1 AA ở cả giao diện sáng / tối |
