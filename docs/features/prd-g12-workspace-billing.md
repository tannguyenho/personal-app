> **Mã:** PLN-PRD-G12 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g12-workspace-billing.md

# PRD Workspace, thành viên, quyền riêng tư & thanh toán trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (Billing "Sunsama Free Trial · 1 seat · 14 days remaining · Upgrade Plan", "Team changes"; hộp thoại "Add colleagues to your subscription"; Signup Link, "Disable link invites"; Privacy 6 loại dữ liệu — bản này dùng 5 loại, bỏ "Ghi chú cuộc họp"; vai trò "Owner", nhật ký "became an admin (promoted by …)"); chỗ khác Sunsama có chủ đích được ghi rõ. Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md) (gồm vòng 5–7: Q35–Q37, Q45–Q47, D12), [ADR-0002](../adr/0002-thanh-toan-chuyen-sang-1-1.md) và [ADR-0005](../adr/0005-nen-tang-windows-truoc.md); quy tắc dùng chung (QC-09 chỉ đọc, QC-10 quyền theo gói, QC-12 trợ lý AI) xem [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md). Tính năng nhiều thành viên giữ đặc tả nhưng để **bản sau**, xem [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

G12 lo hai mảng: **kinh doanh** (trial, thanh toán gói cá nhân, chế độ chỉ đọc — 1.1) và **làm việc nhóm** (workspace nhiều thành viên, ghế, vai trò, quyền riêng tư, giao và follow task — bản sau, 1.2 trở đi). G12 cũng sở hữu cài đặt Thông báo và trung tâm thông báo trong app: nhóm khác phát sinh sự kiện (G05, G07, G08, G09, G11), G12 quyết định ai nhận, qua kênh nào. Bản 1.0 là **app Windows (Flutter)** cho **một người dùng**, có tài khoản và dữ liệu trên cloud (Q35, Q45, ADR-0005), **miễn phí, không giới hạn, gắn nhãn Beta**: mỗi tài khoản một workspace cá nhân do chính họ làm chủ sở hữu (tạo ở G01); G12 ở 1.0 chỉ còn workspace cá nhân và thông báo (cài đặt, trung tâm, huỷ đăng ký email). Bản 1.1 (thêm web, macOS) vẫn cho **một người dùng**, mở trial 14 ngày, thanh toán **gói cá nhân** (không tính ghế), chế độ chỉ đọc, quyền theo gói (Q47, ADR-0002). Người dùng có từ 1.0 nhận trial 14 ngày tính từ ngày phát hành 1.1. Mời thành viên, ghế và tính tiền theo ghế, vai trò, Privacy, giao / follow task, chuyển quyền sở hữu là **bản sau, 1.2 trở đi** (Q35, Q37, Q47) — đặc tả giữ nguyên trong tài liệu này, gắn nhãn "bản sau", danh sách gom ở [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md).

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

- (1.0) Mỗi loại thông báo bật / tắt được theo kênh; cùng một task không gửi quá 1 thông báo trong 5 phút.
- (1.1) Người dùng luôn biết trạng thái gói: số ngày trial còn lại hiện ở Billing; nhắc trước 3 ngày và 1 ngày qua email + banner.
- (1.1) Hết trial hoặc quá hạn không mất dữ liệu ngay: chuyển chỉ đọc (đóng băng theo QC-09), vẫn xuất được, giữ 90 ngày.
- (1.1) Nâng cấp ≤ 3 bước từ banner tới thanh toán xong. Không bao giờ trừ tiền khi chủ sở hữu không chủ động bấm.
- (Bản sau) Mọi dữ liệu mặc định riêng tư; mời một đồng nghiệp trong ≤ 1 phút.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân bản Beta 1.0, đang dùng thử từ 1.1 (Hà freelancer) | Biết còn bao nhiêu ngày, trả tiền nhanh bằng phương thức quen thuộc, không mất dữ liệu nếu chậm trả |
| Chủ sở hữu workspace (người trả tiền, 1.1 — gói cá nhân) | Quản lý gói, hoá đơn; không bị thu tiền ngoài ý muốn; (bản sau, 1.2 trở đi) số ghế, chuyển quyền khi rời nhóm |
| Quản trị workspace (bản sau) | Mời, xoá thành viên, đổi vai trò, quản lý channel chung |
| Thành viên nhóm (bản sau, Linh PM) | Giữ việc cá nhân riêng tư; nhận việc được giao; theo dõi task của người khác |
| Mọi người dùng | Nhận đúng thông báo cần, qua đúng kênh, tắt được thứ không cần |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.0: workspace cá nhân, thông báo · bản 1.1: trial, thanh toán gói cá nhân, chỉ đọc, quyền theo gói · bản sau, 1.2 trở đi: thành viên, ghế, quyền riêng tư, giao / follow task)

Bản 1.0 (miễn phí, nhãn Beta):

- Nền tảng: **app Windows (Flutter)**, một người dùng, tài khoản và dữ liệu trên cloud (Q35, Q45, ADR-0005). Web và macOS từ bản 1.1, iOS / Android từ bản 1.2, dùng cùng đặc tả.
- Workspace cá nhân: mỗi tài khoản một workspace, là chủ sở hữu; đổi tên workspace. Không có nút "Xoá workspace": muốn xoá thì xoá tài khoản (G01) (B47). Không có trial, Billing, chế độ chỉ đọc.
- Cài đặt Thông báo (bật / tắt theo sự kiện × kênh), trung tâm thông báo trong app, thông báo hệ thống của Windows (D12: nhắc ritual, nhắc timer > 4 giờ), email có link huỷ đăng ký 1 chạm.

Bản 1.1:

- Trial 14 ngày không cần thẻ, mỗi email một lần, nhắc trước 3 ngày và 1 ngày. Người dùng có từ 1.0 nhận trial 14 ngày tính từ ngày phát hành 1.1.
- Billing: xem gói, nâng cấp (tháng / năm), thanh toán qua trang của cổng thanh toán, hoá đơn điện tử (NĐ 123/2020, có mã số thuế), đổi gói, huỷ gói, thử lại khi gia hạn lỗi, hoàn tiền, tranh chấp. Gói là **gói cá nhân cho một người dùng, không tính ghế**; checkout không chọn số ghế (Q47, ADR-0002). Ghế và tính tiền theo ghế đi cùng tính năng nhiều thành viên (bản sau, 1.2 trở đi).
- Chế độ chỉ đọc theo QC-09; quyền theo gói theo QC-10 (số tài khoản lịch, số tích hợp). Trợ lý AI **không có hạn mức theo gói** (QC-10, QC-12 mục 8).
- Audit log hành động thanh toán.

Bản sau (1.2 trở đi; nhiều thành viên — Q35, Q37, Q47, xem [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md); đặc tả giữ nguyên, chưa làm ở bản 1):

- Nhật ký "Team changes" và audit log hành động quản trị.
- Mời thành viên qua email và link mời chung, trong giới hạn ghế đã mua; vai trò Chủ sở hữu / Quản trị / Thành viên; đổi vai trò, xoá thành viên, rời workspace, chuyển quyền sở hữu, xoá workspace (xét lại ở 1.2, B47); nhận lời mời khi đã có workspace.
- Privacy: 5 loại dữ liệu × "Chỉ mình tôi" / "Thành viên"; "Tắt mời qua link".
- Giao task (task được giao vào bucket "Tuần sau", đặt lên đầu — Q36), follow task.

## 3.2 Ngoài phạm vi

- Giới thiệu bạn bè (1 tháng miễn phí) → chưa đưa vào.
- Danh sách gói, giá → chưa định nghĩa (Câu hỏi mở). Cấu trúc quyền theo gói: QC-10.
- SSO / SCIM → chưa có kế hoạch `[giả định]`. Một người thuộc nhiều workspace → bản sau (Q23).
- Hạn mức AI theo gói → không có: AI chạy bằng Claude Code CLI của người dùng, dùng hạn mức gói Claude của chính họ (Q46, QC-12 mục 8).
- "Latest updates" trên panel phải → không thuộc phạm vi bộ PRD này.
- "Ghi chú cuộc họp" → bỏ khỏi Privacy (không nhóm nào sở hữu tính năng này).
- Đăng ký, tài khoản, xuất dữ liệu, xoá tài khoản → G01. Context & channel → G02.
- Nội dung và thời điểm phát sinh của từng sự kiện thông báo → nhóm phát sinh (G05, G07, G08, G09, G11). Slack / Teams làm kênh thông báo → bản 1.2 (G11).

# 4. Nguyên tắc sản phẩm

## 4.1 Không giữ dữ liệu làm con tin

Hết trial hay quá hạn (1.1) thì workspace "đóng băng" (QC-09): người dùng không ghi được, và hệ thống cũng không tự ghi (rollover, sinh instance, tích hợp, AI đều dừng), nên không có gì thay đổi sau lưng người dùng. Người dùng vẫn xem, xuất dữ liệu và thanh toán được bất cứ lúc nào; thanh toán xong thì rollover chạy bù một lần.

## 4.2 Riêng tư là mặc định (bản sau)

Áp dụng khi có workspace nhiều thành viên (bản sau, Q35, Q37). Mọi loại dữ liệu ở "Chỉ mình tôi" tới khi chính người dùng mở cho thành viên khác. Channel private (G02) luôn riêng tư. Privacy chỉ áp cho task tự tạo: task đã giao hoặc có người follow luôn hiển thị (tiêu đề, trạng thái, comment) với người giao, người được giao và người follow.

## 4.3 Tiền phải khớp

Trạng thái gói chỉ đổi khi cổng thanh toán xác nhận qua webhook, không theo trang chuyển hướng. Mỗi giao dịch xử lý đúng một lần. Bản 1.1 là gói cá nhân, không có ghế (Q47). (Bản sau) Ghế mua trước: không bao giờ tự cộng ghế hay trừ tiền khi chủ sở hữu không chủ động bấm.

## 4.4 Ít mà đủ thông báo

Gộp thông báo trùng, tắt được từng loại theo từng kênh, email huỷ 1 chạm. Thông báo về tiền và bảo mật luôn đến.

# 5. Quy tắc gói, quyền và thông báo

**Gói (1.1) và lời mời, ghế (bản sau); bản 1.0 miễn phí, không có gói**

| **Mục** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Trial | 14 ngày, không cần thẻ, mỗi email 1 lần | Tài khoản mới: bắt đầu khi tạo workspace (G01). Tài khoản có từ 1.0: bắt đầu ngày phát hành 1.1 | Nhắc trước 3 ngày và 1 ngày (email + banner) |
| Nâng cấp trong trial | Không mất ngày trial | — | Kỳ trả phí đầu tiên bắt đầu khi trial kết thúc |
| Chu kỳ thanh toán | Tháng / năm | — | Giá: câu hỏi mở |
| Số ghế | 1.1: không có — gói cá nhân một người dùng, không tính ghế, checkout không chọn số ghế (Q47). Bản sau: mua trước, ≥ số thành viên | — | (Bản sau) Không tự cộng; lời mời đang chờ không chiếm ghế; trong trial không giới hạn ghế `[giả định]` |
| Hết ghế (bản sau) | Người chấp nhận lời mời chờ tới khi chủ sở hữu mua thêm ghế | — | Chủ sở hữu được báo |
| Thử lại khi gia hạn lỗi | Ngày 1, 3, 7 sau ngày đến hạn | — | Trong thời gian thử lại vẫn dùng đầy đủ |
| Giữ dữ liệu khi chỉ đọc | 90 ngày | — | Vẫn xuất được (G01); hết 90 ngày chỉ xoá dữ liệu workspace, không xoá tài khoản; báo chủ sở hữu (bản sau: mọi thành viên), email bắt buộc |
| Hoá đơn | Hoá đơn điện tử theo NĐ 123/2020, có mã số thuế | — | Giữ 10 năm |
| Hoàn tiền | Huỷ giữa kỳ (bản sau: cả giảm ghế): không `[giả định]`; xoá tài khoản: hoàn phần còn lại `[giả định — chờ pháp chế]` | — | Có xử lý hoàn tiền và tranh chấp từ cổng |
| Lời mời qua email (bản sau) | 1–20 email / lần, hết hạn 7 ngày, thu hồi được | Vai trò Thành viên | Sunsama không cho chọn vai trò khi mời; cho chọn (khác có chủ đích) |
| Gộp thông báo | Cùng task, cùng người nhận trong 5 phút → 1 thông báo | — | |
| Lưu trung tâm thông báo | 90 ngày `[giả định]` | — | |

**Ma trận quyền (bản sau — Q35)**

| **Quyền** | **Chủ sở hữu** | **Quản trị** | **Thành viên** |
|---|---|---|---|
| Quản lý task, lịch, ritual của mình | ✓ | ✓ | ✓ |
| Xem task của người khác trong channel chung | ✓ khi Privacy của người đó cho phép | ✓ khi Privacy cho phép | ✓ khi Privacy cho phép |
| Xem task mình đã giao, được giao hoặc đang follow | ✓ luôn (tiêu đề, trạng thái, comment) | ✓ luôn | ✓ luôn |
| Tạo / sửa context, channel chung | ✓ | ✓ | – |
| Mời, xoá thành viên, đổi vai trò | ✓ | ✓ (trừ Chủ sở hữu) | – |
| Xem Team changes, bật / tắt mời qua link | ✓ | ✓ `[giả định]` | – |
| Billing, xoá workspace, chuyển quyền sở hữu | ✓ | – | – |

**Thông báo: sự kiện → người nhận → kênh mặc định**

| **Sự kiện** | **Người nhận** | **Kênh mặc định** | **Phát hành** | **Nhóm phát sinh** |
|---|---|---|---|---|
| Trial sắp hết (còn 3 ngày, 1 ngày) | Chủ sở hữu | Trong app + email (email không tắt được `[giả định]`) | 1.1 | G12 |
| Bắt đầu trial cho người dùng 1.0 | Chủ sở hữu | Trong app + email `[giả định]` | 1.1 | G12 |
| Gia hạn lỗi / sắp chuyển chỉ đọc | Chủ sở hữu | Trong app + email (email không tắt được) `[giả định]` | 1.1 | G12 |
| Sắp xoá dữ liệu workspace chỉ đọc (còn 30, 7 ngày `[giả định]`) | Chủ sở hữu (bản sau: mọi thành viên) | Trong app + email (email không tắt được) | 1.1 | G12 |
| Có người chờ ghế | Chủ sở hữu | Trong app + email | Bản sau | G12 |
| Chủ sở hữu mới cần nhập phương thức thanh toán | Chủ sở hữu mới | Trong app + email | Bản sau | G12 |
| Hoàn tiền / tranh chấp | Chủ sở hữu | Trong app + email | 1.1 | G12 |
| Lịch / tích hợp mất kết nối | Người đã kết nối | Trong app + email | 1.0 (lịch), 1.1 (tích hợp) | G05, G11 |
| Đến giờ ritual | Người dùng | Trong app + thông báo hệ thống Windows (D12) | 1.0 (ritual tuần: 1.1) | G08, G09 |
| Timebox sắp bắt đầu | Người dùng | Reminder của lịch ngoài (theo "nhắc theo lịch mặc định") | 1.0 | G05 |
| Timer chạy quá 4 giờ | Người dùng | Trong app + thông báo hệ thống Windows (D12); mobile push từ 1.2 | 1.0 | G07 |
| Được giao task | Người được giao | Trong app + email | Bản sau | G12 |
| Task đang follow: tạo, giao lại, hoàn thành, comment | Người follow | Email (mobile 1.2, Slack 1.2) | Bản sau | G12 |
| Recap tuần | Người dùng + người nhận thêm | Email tại mốc đầu ngày của ngày sau ngày làm việc cuối tuần (QC-02, G01) | 1.1 (Beta) | G09 |
| Product updates | Người dùng | Email, mặc định tắt `[giả định]` | 1.0 | G12 |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Quyền theo gói (1.1) theo bảng cấu hình QC-10 do G12 sở hữu: số tài khoản lịch, số tích hợp. Trợ lý AI **không có hạn mức theo gói** — AI chạy bằng Claude Code CLI trên máy người dùng, dùng hạn mức gói Claude của chính họ (Q46, QC-12 mục 8; thay C32). Không nhóm nào viết cứng con số hay rẽ nhánh theo tên gói. Danh sách gói và giá vẫn là câu hỏi mở.
- Kênh thông báo theo nền tảng: Trong app và Email từ 1.0; Desktop (thông báo hệ thống Windows) từ 1.0 (D12), macOS từ 1.1; Mobile push từ 1.2 (Q45).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 0 | Beta (1.0) | Đăng ký (G01), dùng miễn phí không giới hạn; chỉnh thông báo | Workspace cá nhân |
| 1 | Dùng thử (1.1) | Đăng ký mới hoặc người dùng 1.0 khi 1.1 phát hành; dùng đầy đủ; Billing hiện "Dùng thử · còn n ngày" (gói cá nhân, không hiện ghế — Q47) | Trial 14 ngày |
| 2 | Nhắc (1.1) | Còn 3 ngày, 1 ngày: banner + email có nút "Nâng cấp" | Người dùng biết trước |
| 3 | Nâng cấp (1.1) | Chọn tháng / năm, thông tin hoá đơn (không chọn số ghế, Q47) → trang thanh toán của cổng → quay lại app | Gói hoạt động (kỳ đầu từ khi hết trial), hoá đơn điện tử |
| 4 | Gia hạn (1.1) | Tự thu mỗi kỳ; lỗi thì thử lại ngày 1, 3, 7; hết lượt → chỉ đọc (đóng băng, QC-09) | Không mất khách vì lỗi tạm thời |
| 5 | Mời nhóm (bản sau) | "Thêm đồng nghiệp": nhập email, chọn vai trò; hoặc copy link mời; người chấp nhận vào khi còn ghế trống | Thành viên mới trong số ghế đã mua |
| 6 | Riêng tư (bản sau) | Mỗi người chọn loại dữ liệu nào thành viên khác thấy | Chia sẻ có kiểm soát |
| 7 | Phối hợp (bản sau) | Giao task, follow task; nhận thông báo | Biết ai làm gì, việc nào xong |
| 8 | Thông báo (1.0) | Trung tâm thông báo trong app; tắt / bật theo sự kiện × kênh | Đúng thông báo, đúng kênh |

Bước 0–1 dựa trên G01; PRD này tập trung bước 2–8.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Dùng thử và nâng cấp (1.1)

### US1.1 Biết trạng thái trial

AC01: Cài đặt → Billing hiện tên gói, số ngày còn lại (ví dụ "Dùng thử · còn 14 ngày"), nút "Nâng cấp". Bản 1.1 không hiện số ghế (gói cá nhân, Q47).

AC02: Còn ≤ 3 ngày: banner trên Home cho chủ sở hữu, đóng được, hiện lại mỗi ngày; email lúc còn 3 ngày và 1 ngày.

AC03: Mỗi email chỉ được trial 1 lần; xoá tài khoản rồi đăng ký lại bằng cùng email không có trial mới.

AC04: Tài khoản có từ bản 1.0: khi 1.1 phát hành, workspace chuyển sang trial 14 ngày tính từ ngày phát hành, có thông báo trong app và email.

### US1.2 Nâng cấp

User Story: Là người dùng đang dùng thử, tôi muốn nâng cấp trong vài bước bằng phương thức thanh toán quen thuộc, để tiếp tục dùng không gián đoạn.

AC01: "Nâng cấp" mở màn chọn gói: chu kỳ tháng / năm (gói cá nhân, không chọn số ghế — Q47), thông tin xuất hoá đơn (tên, mã số thuế, địa chỉ, email nhận), tổng tiền, ngày bắt đầu kỳ.

AC02: "Thanh toán" chuyển sang trang của cổng thanh toán; app không nhận và không lưu số thẻ.

AC03: Gói chỉ hoạt động khi cổng xác nhận (webhook); trang quay về app hiện "Đang xác nhận thanh toán…" tới khi xác nhận, tối đa 60 giây `[giả định]` rồi báo sẽ gửi email khi xong.

AC04: Thanh toán xong: banner trial biến mất, Billing hiện gói, kỳ gia hạn, hoá đơn điện tử (PDF); email xác nhận kèm hoá đơn.

AC05: Nâng cấp khi đang dùng thử không làm mất ngày trial: kỳ trả phí đầu tiên bắt đầu khi trial kết thúc.

## UC2. Gia hạn, huỷ và chế độ chỉ đọc (1.1)

### US2.1 Gia hạn tự động và thử lại

AC01: Đến kỳ, hệ thống thu tiền qua cổng; lỗi → thử lại ngày 1, 3, 7; mỗi lần lỗi gửi email cho chủ sở hữu kèm link cập nhật phương thức thanh toán.

AC02: Trong thời gian thử lại vẫn dùng đầy đủ; banner đỏ cho chủ sở hữu "Thanh toán gia hạn chưa thành công".

### US2.2 Chế độ chỉ đọc

User Story: Là người dùng hết trial chưa trả tiền, tôi muốn vẫn xem và xuất được dữ liệu, để không mất những gì đã làm.

AC01: Hết trial / hết kỳ sau khi huỷ / thử lại ngày 7 lỗi → workspace chỉ đọc theo QC-09: xem được, xuất được (G01), thanh toán được; mọi thao tác ghi bị chặn với banner "Nâng cấp để tiếp tục"; mọi job tự ghi (rollover, sinh instance, tích hợp, AI) dừng; timer đang chạy tự dừng tại mốc hết hạn.

AC02: Đang làm dở một ritual lúc hết hạn → cho hoàn tất trong 2 giờ, kể cả các thao tác task bên trong; thao tác offline tạo trước mốc được nhận nếu đồng bộ trong 2 giờ (EC-34, QC-09).

AC03: Thanh toán thành công → bỏ chỉ đọc ngay, không mất dữ liệu; rollover chạy bù một lần, các ngày bị đóng băng không tính vào số ngày bị hoãn.

AC04: Chỉ đọc quá 90 ngày → chỉ xoá dữ liệu workspace, tài khoản vẫn còn; chủ sở hữu (bản sau: mọi thành viên) nhận email nhắc trước 30 ngày và 7 ngày `[giả định]`, email này không tắt được.

### US2.3 Đổi gói, huỷ, hoá đơn (đổi số ghế: bản sau)

AC01: Đổi chu kỳ (bản sau: cả tăng số ghế) tính tiền theo tỷ lệ phần kỳ còn lại; hiện số tiền trước khi xác nhận; chỉ thu khi chủ sở hữu bấm "Xác nhận".

AC02: Huỷ gói có hiệu lực cuối kỳ; trước đó có nút "Tiếp tục gói". Huỷ khi đang thử lại gia hạn → ngừng thử lại.

AC03: Danh sách hoá đơn tải được PDF; hoá đơn điện tử theo NĐ 123/2020, có mã số thuế khi người mua là tổ chức; giữ 10 năm.

AC04: Hoàn tiền hoặc tranh chấp từ cổng thanh toán được ghi vào hoá đơn, báo chủ sở hữu; hoàn tiền toàn phần hoặc thua tranh chấp → workspace chỉ đọc `[giả định]`.

## UC3. Thành viên (bản sau — xem `docs/02-tinh-nang-ban-sau.md`, Q35)

### US3.1 Mời đồng nghiệp

User Story: Là chủ sở hữu / quản trị, tôi muốn mời đồng nghiệp bằng email trong một hộp thoại, để cả nhóm dùng chung workspace.

AC01: Hộp thoại "Thêm đồng nghiệp vào gói" (Sunsama: "Add colleagues to your subscription"): mỗi dòng email + tên (tuỳ chọn) + vai trò; "Thêm người"; 1–20 email / lần.

AC02: Ghi chú "Mỗi người có không gian riêng tư của mình" và số ghế đang dùng / đã mua. Mời không làm tăng ghế hay tiền; người chấp nhận khi hết ghế sẽ chờ tới khi chủ sở hữu mua thêm ghế.

AC03: Email đã là thành viên hoặc đang có lời mời chờ → không gửi trùng, báo danh sách bỏ qua (EC-32).

AC04: Lời mời hết hạn sau 7 ngày; danh sách lời mời chờ có "Gửi lại", "Thu hồi".

AC05: Người được mời chấp nhận khi còn ghế trống → vào workspace. Hết ghế → người đó thấy "Workspace đã hết ghế", chủ sở hữu nhận thông báo có nút "Mua thêm ghế"; mua xong thì người chờ được vào. Không bao giờ trừ tiền khi chủ sở hữu không chủ động bấm.

AC06: Người được mời đã có workspace một người, chưa trả phí (Beta 1.0, trial, chỉ đọc) → được hỏi xác nhận; đồng ý thì task cá nhân chuyển sang workspace mới ở chế độ "Chỉ mình tôi" và workspace cũ bị đóng.

AC07: Người được mời có workspace đang trả phí hoặc có thành viên khác → chặn, yêu cầu huỷ gói hoặc chuyển quyền sở hữu trước. Một người thuộc nhiều workspace: bản sau.

### US3.2 Link mời chung

AC01: "Link đăng ký" + "Sao chép link"; ai có link đăng ký / đăng nhập (G01) là vào workspace với vai trò Thành viên, **chỉ khi còn ghế trống** (như US3.1 AC05); dán link vào nhóm đông người không làm tăng ghế hay tiền.

AC02: "Tạo link mới" vô hiệu link cũ; bật "Tắt mời qua link" thì link không dùng được.

### US3.3 Đổi vai trò, xoá thành viên

AC01: Đổi vai trò Quản trị ⇄ Thành viên; Team changes ghi "{A} trở thành Quản trị (do {B} nâng quyền)".

AC02: Xoá thành viên: dừng timer đang chạy, task họ được giao chưa xong chuyển về người giao, họ bị đăng xuất khỏi workspace ≤ 1 phút (EC-31). Task cá nhân của họ chuyển sang một workspace cá nhân mới của họ, không bị xoá.

AC03: Thành viên (không phải chủ sở hữu) xoá tài khoản (G01) → rời workspace như AC02 trước rồi mới xoá; gói của nhóm không bị huỷ.

### US3.4 Chuyển quyền sở hữu, rời và xoá workspace

AC01: Chủ sở hữu chuyển quyền cho một thành viên (xác nhận lại bằng mật khẩu hoặc Google / Microsoft); chủ sở hữu cũ thành Quản trị. Phương thức thanh toán của chủ cũ bị gỡ ngay; chủ mới nhập phương thức thanh toán trước kỳ kế tiếp, nếu không gói chuyển sang "thu lại tiền".

AC02: Chủ sở hữu muốn rời workspace hoặc xoá tài khoản (G01) khi còn thành viên khác → chặn tới khi chuyển quyền hoặc xoá workspace (EC-36).

AC03: Xoá workspace chỉ chủ sở hữu, phải gõ tên workspace để xác nhận; huỷ gói, mọi thành viên bị đăng xuất. Xét lại ở 1.2; bản 1.0 và 1.1 không có nút này, workspace một người xoá bằng cách xoá tài khoản (G01) (B47).

## UC4. Quyền riêng tư (bản sau — xem `docs/02-tinh-nang-ban-sau.md`, Q35, Q37)

### US4.1 Chọn dữ liệu nào thành viên khác thấy

AC01: Privacy liệt kê 5 loại dữ liệu: Task, Highlights, Channel, Lịch, Tích hợp; mỗi loại chọn "Chỉ mình tôi" / "Thành viên"; mặc định "Chỉ mình tôi".

AC02: Đổi sang "Chỉ mình tôi" → người khác đang xem mất quyền ≤ 5 giây (EC-33), trừ AC04.

AC03: Channel private (G02) không hiện với người khác dù cài đặt là "Thành viên".

AC04: Privacy chỉ áp cho task tự tạo. Task đã giao hoặc có người follow luôn hiện tiêu đề, trạng thái, comment với người giao, người được giao và người follow.

AC05: Privacy "Lịch" ở "Thành viên" → người khác chỉ thấy bận / rảnh và timebox của người đó, **không** thấy chi tiết sự kiện của lịch ngoài (tiêu đề, người tham dự, ghi chú) — khuyến nghị, chờ chốt khi làm (Q37); ảnh hưởng G05.

## UC5. Giao task và follow task (bản sau — xem `docs/02-tinh-nang-ban-sau.md`, Q35, Q36)

### US5.1 Giao task

AC01: Chi tiết task (G02) có ô "Giao cho" chọn thành viên; người được giao nhận task vào backlog của họ ở bucket **"Tuần sau"**, đặt lên đầu bucket (Q36, G06) và thông báo trong app + email.

AC02: Giao lại cho người khác → người mới nhận thông báo, người cũ không còn thấy task trong backlog (trừ khi follow).

### US5.2 Follow task

AC01: Nút "Theo dõi" trên chi tiết task; người follow nhận thông báo khi task được giao lại, hoàn thành, có comment mới.

AC02: Bỏ theo dõi bất cứ lúc nào; người giao tự động follow `[giả định]`.

## UC6. Thông báo (1.0)

### US6.1 Cài đặt thông báo

AC01: Cài đặt → Thông báo hiện bảng sự kiện × kênh (Trong app, Email, Desktop — thông báo hệ thống Windows từ 1.0 (D12), Mobile từ 1.2); mỗi ô là một công tắc; sự kiện / kênh chưa phát hành ở bản hiện tại không hiện.

AC02: Ô bắt buộc (từ 1.1: email sắp xoá dữ liệu workspace chỉ đọc; email trial sắp hết, gia hạn lỗi `[giả định]`) hiện khoá kèm giải thích. Ở 1.0 không có ô bắt buộc nào nên phần này ẩn (C49).

### US6.2 Trung tâm thông báo

AC01: Biểu tượng chuông ở cụm dưới sidebar có badge số chưa đọc (tối đa "99+"); bấm mở danh sách dạng popover cạnh chuông, mới nhất trước (C50); bấm một thông báo mở đúng nơi liên quan và đánh dấu đã đọc.

AC02: "Đánh dấu tất cả đã đọc"; thông báo mới hiện ≤ 5 giây không cần tải lại.

AC03: Mỗi loại thông báo của 1.0 mở đúng một màn theo bảng "Loại thông báo 1.0 → màn được mở" trong SRS (UC-09); thông báo thanh toán là 1.1 (C51).

AC04: Email bị trả về cứng → ngừng gửi email tới địa chỉ đó và báo trong app, có mã thông báo riêng (C52).

### US6.3 Huỷ đăng ký email 1 chạm

AC01: Mọi email thông báo (trừ email bắt buộc) có link "Huỷ nhận loại email này"; bấm là tắt ngay, không cần đăng nhập, có trang xác nhận và nút "Bật lại".

AC02: Ở 1.0 trang xác nhận không có link "Mở cài đặt thông báo" vì chưa có web app; link bật từ 1.1 (B48).

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu** |
|---|---|---|
| Chuyển đổi trial → trả phí (1.1) | Workspace trả phí trong 30 ngày sau khi bắt đầu trial / workspace bắt đầu trial; tách riêng người dùng Beta 1.0 và người dùng mới | ≥ 10% |
| Thời gian nâng cấp (1.1) | Từ bấm "Nâng cấp" tới gói hoạt động | ≤ 3 phút (trung vị) |
| Tỉ lệ cứu được gia hạn lỗi (1.1) | Gia hạn thành công ở lần thử lại / gia hạn lỗi lần đầu | ≥ 40% |
| Tỉ lệ quay lại từ chỉ đọc (1.1) | Workspace chỉ đọc thanh toán trong 90 ngày / workspace chỉ đọc | Theo dõi |
| Lời mời chờ ghế (bản sau) | Lời mời `CHO_GHE` được vào trong 7 ngày / lời mời `CHO_GHE` | Theo dõi |
| Workspace nhiều thành viên (bản sau) | Workspace ≥ 2 thành viên hoạt động / workspace trả phí | ≥ 20% |
| Tỉ lệ chấp nhận lời mời (bản sau) | Lời mời được chấp nhận / lời mời gửi | ≥ 50% |
| Tỉ lệ tắt thông báo | Người dùng tắt ≥ 1 loại / người dùng hoạt động | Theo dõi (cao = thông báo gây phiền) |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Cổng thanh toán chưa chốt | Gợi ý Stripe cho thẻ quốc tế, VNPay / MoMo cho thanh toán nội địa; thu định kỳ tự động bằng ví / thẻ nội địa có thể bị hạn chế | Thiết kế lớp cổng thanh toán trừu tượng; chốt cổng trước 1.1, trước khi làm UC1–UC2 |
| Hoá đơn, thuế tại Việt Nam | Hoá đơn điện tử theo NĐ 123/2020, mã số thuế, VAT; giữ chứng từ 10 năm | Chọn nhà cung cấp hoá đơn điện tử; kế toán xác nhận thuế suất trước 1.1 |
| Hoàn tiền khi xoá tài khoản | Luật Bảo vệ quyền lợi người tiêu dùng 2023 có thể yêu cầu hoàn phần chưa dùng | Tạm giả định hoàn phần còn lại; pháp chế xác nhận |
| Chuyển dữ liệu ra nước ngoài | 1.0 dùng máy chủ khu vực châu Á | Hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (NĐ 13/2023); pháp chế xác nhận trước phát hành |
| Webhook trễ, trùng, sai thứ tự | Gói kích hoạt chậm hoặc bị xử lý hai lần | Idempotent theo ID giao dịch (EC-35); đối soát hằng ngày với cổng; trang "Đang xác nhận" |
| Lộ dữ liệu giữa thành viên (bản sau) | Lỗi kiểm tra Privacy làm lộ task cá nhân | Kiểm tra quyền ở tầng truy vấn server; kiểm thử tự động cho cả 5 loại dữ liệu và ngoại lệ giao / follow |
| Thu tiền ngoài ý muốn qua lời mời / link chung (bản sau) | Chủ sở hữu bị thu thêm tiền không lường trước | Đã xử lý: ghế mua trước, hết ghế thì người mới chờ; chỉ thu khi chủ sở hữu bấm; log trong Team changes |
| Người dùng Beta 1.0 bị bất ngờ khi có gói trả phí | Rời bỏ khi trial 1.1 hết | Báo trước trong app + email khi 1.1 phát hành; trial 14 ngày từ ngày phát hành |
| Email vào thư rác | Nhắc trial, gia hạn lỗi không tới | SPF / DKIM / DMARC; luôn kèm thông báo trong app |
| Tiếp thị qua email | Product updates cần đồng ý theo Nghị định 13/2023/NĐ-CP, GDPR | Mặc định tắt `[giả định]`; pháp chế xác nhận |

# 10. Câu hỏi mở

- Chọn cổng thanh toán nào: Stripe, VNPay, MoMo, hay kết hợp? **Còn mở, chốt trước 1.1** (Q30); gợi ý Stripe cho thẻ quốc tế, VNPay / MoMo cho thanh toán nội địa.
- Danh sách gói, giá tháng / năm là gì? **Còn mở.** Đã chốt 04/11/2026: cấu trúc quyền theo gói theo QC-10 chỉ gồm số tài khoản lịch và số tích hợp; AI **không có hạn mức theo gói** (Q46, QC-12 mục 8 — thay C32).
- Đã chốt 04/11/2026: bản 1.0 là app Windows (Flutter), có tài khoản và dữ liệu trên cloud; 1.1 thêm web + macOS; 1.2 thêm iOS / Android (Q45, ADR-0005).
- Đã chốt 04/11/2026: bản 1 chỉ cho một người dùng; mời, ghế, vai trò, giao / follow task, Privacy, chuyển quyền sở hữu để bản sau (1.2 trở đi), gom ở `docs/02-tinh-nang-ban-sau.md` (Q35, Q37, Q47).
- Đã chốt 04/11/2026 một phần: bản 1.0 không bắt buộc lưu tại Việt Nam, dùng máy chủ khu vực châu Á, kèm hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (Q29). **Còn mở:** pháp chế xác nhận trước khi phát hành.
- Đã chốt 04/11/2026: giữ dữ liệu workspace chỉ đọc 90 ngày, sau đó chỉ xoá dữ liệu workspace, không xoá tài khoản; báo mọi thành viên, email bắt buộc (C8).
- Đã chốt 04/11/2026 một phần: hoàn tiền khi xoá tài khoản `[giả định — chờ pháp chế]`; có xử lý hoàn tiền / tranh chấp từ cổng (C6). Huỷ giữa kỳ vẫn `[giả định: không hoàn]`; giảm ghế thuộc bản sau.
- (Bản sau) Có cho chọn vai trò khi mời (khác Sunsama) không? (Đang thiết kế là có.)
- Đã chốt 04/11/2026: thành viên bị xoá khỏi workspace → task cá nhân chuyển sang workspace cá nhân mới của họ (C7).
- Đã chốt 04/11/2026: mỗi người một workspace. Người được mời đã có workspace một người chưa trả phí → chuyển task cá nhân sang workspace mới, đóng workspace cũ; đang trả phí hoặc có thành viên khác → chặn. Trial 1 lần mỗi email (Q23, C7).
- Product updates mặc định bật hay tắt? (Đang giả định tắt.)
- (Mới) Workspace cá nhân mới cho email đã dùng trial ở gói nào khi không còn trial `[giả định: chỉ đọc tới khi nâng cấp]`? (Bản sau) Cùng câu hỏi cho workspace cá nhân mới tạo cho người bị xoá khỏi workspace.
- (Mới, bản sau) Trong trial, workspace có giới hạn số ghế không `[giả định: không]`? Người chờ ghế được vào theo thứ tự nào `[giả định: chấp nhận sớm nhất trước]`?
- Đã chốt 04/11/2026 (bản sau): task được giao vào backlog người nhận ở bucket "Tuần sau", đặt lên đầu bucket (Q36).
- Đã chốt hướng 04/11/2026 (bản sau): thành viên tạo channel riêng tư; channel chung chỉ Chủ sở hữu / Quản trị — khuyến nghị, chờ chốt khi làm (Q35, `docs/02-tinh-nang-ban-sau.md`). Bản 1 một người dùng nên G02 cho tạo channel tự do.
- Đã chốt hướng 04/11/2026 (bản sau): Privacy "Lịch" ở "Thành viên" → người khác chỉ thấy bận / rảnh và timebox, không thấy chi tiết sự kiện của lịch ngoài — khuyến nghị, chờ chốt khi làm (Q37). G05 cần đặc tả khi làm.
- ADR-0002 xếp workspace nhiều thành viên cùng 1.1 với thanh toán; Q35 dời sang "bản sau" mà chưa nêu số phiên bản. Gói 1.1 khi chỉ một người dùng có còn tính theo ghế không? — Đã chốt 04/11/2026: bản 1.1 có trial và thanh toán gói cá nhân cho một người dùng, không tính ghế, checkout không chọn số ghế; nhiều thành viên, ghế và mọi thứ liên quan để bản 1.2 trở đi; ADR-0002 đã sửa (Q47).
- Có nút "Xoá workspace" không? **Chốt 09/11/2026 (B47):** không có ở 1.0 và 1.1; workspace một người xoá bằng cách xoá tài khoản (G01); xét lại ở 1.2 khi có nhiều thành viên.
- Trang huỷ đăng ký email có link "Mở cài đặt thông báo" trong khi 1.0 chưa có web app? **Chốt 09/11/2026 (B48):** ẩn link ở 1.0, bật khi có web (1.1).
