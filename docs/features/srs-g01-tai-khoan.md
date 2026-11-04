> **Mã:** PLN-SRS-G01-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g01-tai-khoan.md

# UC-G01 - Tài khoản, onboarding & cài đặt trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này mô tả đăng ký, đăng nhập, phiên, quên mật khẩu, onboarding, khung trang Cài đặt và các nhóm Chung, Hiển thị, Phím tắt, Hồ sơ, Tài khoản (đổi mật khẩu / email, đăng xuất mọi phiên, xuất dữ liệu, xoá tài khoản). Context & channel (G02), Lịch làm việc (G04 / G05), kết nối lịch (G05), Focus (G07), Daily planning (G08), Ritual (G08 / G09), AI và Beta (G10), Tích hợp (G11), trial, thanh toán, Thông báo, Thành viên, Privacy (G12) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng đăng ký và vào được ngày đầu tiên đã lên kế hoạch trong vài phút; đăng nhập an toàn; tự chỉnh cài đặt và quản lý tài khoản, dữ liệu của mình |
| Actor | Khách (chưa đăng nhập) · Người dùng đã đăng nhập · Hệ thống · Nhà cung cấp danh tính (Google, Microsoft) · Dịch vụ gửi email |
| Phạm vi | Đăng ký email / Google / Microsoft, xác minh email, đăng nhập, phiên và token, đăng xuất, khoá tạm, quên mật khẩu, onboarding 5 bước, tooltip theo ngữ cảnh, khung trang Cài đặt, nhóm Chung / Hiển thị / Phím tắt / Hồ sơ / Tài khoản, xuất dữ liệu, xoá tài khoản |
| Ngoài phạm vi | 2FA TOTP (1.1), lời mời và thành viên (G12, 1.1), trial / thanh toán / Thông báo (G12), nội dung các nhóm cài đặt khác, SSO doanh nghiệp |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Khách | Đăng ký bằng email + mật khẩu hoặc Google / Microsoft | Bắt đầu dùng thử ngay |
| US-02 | Người dùng mới | Được dẫn qua 5 bước có sẵn giá trị gợi ý | App đúng giờ, đúng lịch, có task ngay ngày đầu |
| US-03 | Người dùng | Đăng nhập một lần, phiên tự gia hạn | Không phải đăng nhập lại mỗi ngày |
| US-04 | Người dùng | Đặt lại mật khẩu khi quên | Không mất tài khoản |
| US-05 | Người dùng | Đổi cài đặt và thấy tác dụng ngay | App khớp cách làm việc của tôi |
| US-06 | Người dùng | Được hỏi khi timezone máy khác cài đặt | "Hôm nay" và giờ nhắc luôn đúng |
| US-07 | Người dùng | Đổi mật khẩu, email, đăng xuất mọi thiết bị | Giữ tài khoản an toàn |
| US-08 | Người dùng | Xuất và xoá dữ liệu của mình | Kiểm soát dữ liệu cá nhân |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Định danh.** Tài khoản định danh bằng email chính (cắt khoảng trắng, không phân biệt hoa thường). Một email = một tài khoản; một tài khoản liên kết được nhiều phương thức đăng nhập (mật khẩu, Google, Microsoft) |
| BR-02 | **Mật khẩu.** 10–128 ký tự (tối đa 128 `[giả định]`); không nằm trong danh sách mật khẩu bị lộ; băm Argon2id; không ghi log, không gửi lại qua email |
| BR-03 | **Mã xác minh email.** 6 số, hết hạn 10 phút, dùng 1 lần; nhập sai 5 lần → mã vô hiệu `[giả định]`; "Gửi lại mã" sau 60 giây, ≤ 5 lần / giờ / email `[giả định]`; mã mới làm mã cũ vô hiệu. Tài khoản `CHUA_XAC_MINH` quá 24 giờ bị xoá `[giả định]` |
| BR-04 | **Chống dò email.** Đăng ký bằng email đã có và quên mật khẩu bằng email chưa có trả response, thời gian phản hồi và giao diện giống trường hợp hợp lệ. Thông tin thật chỉ gửi qua email: email đã có tài khoản nhận thư "Bạn đã có tài khoản" kèm link đăng nhập / quên mật khẩu |
| BR-05 | **Khởi tạo khi đăng ký** (một giao dịch): User; Workspace với người dùng là chủ sở hữu (G12); 3 context `work`, `personal`, `uncategorized` (G02); cài đặt mặc định (BR-12); trial 14 ngày (G12); onboarding `CHUA_BAT_DAU`. Đăng ký qua lời mời (1.1): không tạo workspace mới `[giả định]`, gia nhập workspace mời (G12) |
| BR-06 | **Đồng ý xử lý dữ liệu.** Tài khoản mới (mọi phương thức) phải tick đồng ý Điều khoản sử dụng và Chính sách quyền riêng tư (không tick sẵn); lưu phiên bản văn bản và thời điểm đồng ý (Nghị định 13/2023/NĐ-CP, GDPR — chờ pháp chế xác nhận) |
| BR-07 | **Khoá đăng nhập.** Sai mật khẩu 5 lần trong 15 phút → khoá đăng nhập bằng mật khẩu 15 phút, gửi email cảnh báo; Google / Microsoft và quên mật khẩu vẫn dùng được `[giả định]`. Giới hạn 10 lần gọi đăng nhập / phút / IP (429) |
| BR-08 | **Phiên.** Access token JWT 15 phút. Refresh token 30 ngày trong cookie httpOnly, Secure, SameSite=Lax `[giả định]`; mỗi lần làm mới phát token mới, token cũ hết hiệu lực. Token cũ bị dùng lại → thu hồi cả chuỗi token của phiên đó, phát `session.revoked` |
| BR-09 | **Đặt lại mật khẩu.** Link hiệu lực 30 phút, dùng 1 lần, link mới làm link cũ vô hiệu. Đặt lại thành công → mở khoá BR-07, thu hồi mọi phiên khác `[giả định]`, gửi email thông báo |
| BR-10 | **Xác nhận lại.** Đổi mật khẩu, đổi email, xoá tài khoản cần nhập mật khẩu hiện tại; tài khoản chỉ có Google / Microsoft → đăng nhập lại với nhà cung cấp trong 5 phút gần nhất `[giả định]` |
| BR-11 | **Onboarding.** 5 bước theo thứ tự: (1) ngôn ngữ + timezone → (2) kết nối lịch → (3) công cụ công việc → (4) giờ làm việc + giờ plan ngày → (5) task đầu tiên. Mọi trường điền sẵn; bước 2 bỏ qua được; lưu tiến độ sau mỗi bước; mở lại app tiếp tục bước dở. Hoàn tất → mở Daily planning hôm nay ở chế độ có hướng dẫn (G08). Chỉ hiện một lần / tài khoản |
| BR-12 | **Cài đặt.** Mỗi trường lưu ngay qua \[SettingsUpdate\] (chỉ trường đổi), áp dụng ngay không tải lại trang; phát `settings.changed` tới thiết bị khác ≤ 5 giây; xung đột theo trường, bản sau thắng. Mặc định và giới hạn theo PRD mục 5, lấy từ \[AppConfig\] |
| BR-13 | **Timezone.** Mặc định theo thiết bị lúc đăng ký. Mỗi lần mở app so timezone thiết bị với cài đặt; lệch → banner MSG-23, không tự đổi; chọn "Giữ" thì không hỏi lại tới khi timezone thiết bị đổi tiếp. Đổi timezone giữ thời điểm tuyệt đối của timebox (G05) |
| BR-14 | **Giờ bắt đầu ngày** (day_start_time): mặc định 04:00 `[giả định — chờ PO chốt 04:00 hay 00:00]`, khoảng 00:00–06:00 `[giả định]`. Mọi tính toán "hôm nay" (rollover, ritual, AI) dùng mốc này theo timezone người dùng. Đổi giá trị áp dụng từ ngày làm việc kế tiếp `[giả định]` |
| BR-15 | **Phím tắt.** Tắt phím tắt → mọi phím một ký tự ngừng; Ctrl/Cmd+K và Esc vẫn chạy `[giả định]`. Phím một ký tự chỉ chạy khi không focus ô nhập; gõ ≥ 4 ký tự / 1 giây ngoài ô nhập → khoá phím tắt 1 giây (EC-25). Phím toàn cục Ctrl+Shift+A, Ctrl+Shift+Space chỉ trên desktop (1.1) |
| BR-16 | **Tooltip theo ngữ cảnh** hiện tối đa 1 lần / tài khoản (lưu trong cài đặt, đồng bộ mọi thiết bị); đánh dấu đã xem khi đóng hoặc khi làm hành động được gợi ý. 1.0: "Task projections" (lần đầu thấy projection, G04), "Your first keyboard shortcut" (lần đầu dùng phím tắt, G04); danh sách khác `[giả định]` |
| BR-17 | **Đổi email.** Gửi mã 6 số (BR-03) tới email mới; chỉ đổi khi nhập đúng mã. Email mới đã thuộc tài khoản khác → vẫn hiện bước nhập mã, bước xác nhận báo MSG-32 (BR-04). Email cũ nhận thư thông báo có link "Không phải tôi" dẫn tới đặt lại mật khẩu `[giả định]` |
| BR-18 | **Đăng xuất mọi phiên.** Thu hồi mọi refresh token trừ phiên hiện tại; phát `session.revoked`; thiết bị khác về SCR-03 ≤ 1 phút `[giả định]`. Đăng xuất (một phiên hay mọi phiên) xoá dữ liệu offline trên thiết bị bị đăng xuất |
| BR-19 | **Xuất dữ liệu.** Gói zip: JSON đầy đủ (task, subtask, notes, comment, channel, context, time entry, ritual, cài đặt) + CSV (task, time entry). Sẵn sàng ≤ 24 giờ; link tải 7 ngày, cần đăng nhập đúng tài khoản; tối đa 1 yêu cầu đang xử lý. Dùng được khi workspace chỉ đọc (G12) |
| BR-20 | **Xoá tài khoản.** Ngay lập tức: tài khoản `CHO_XOA`, đăng xuất mọi phiên, thu hồi token lịch (G05) và tích hợp (G11), huỷ gói (G12), gửi email xác nhận. Xoá vĩnh viễn mọi dữ liệu ≤ 30 ngày. Chủ sở hữu duy nhất của workspace còn thành viên khác → chặn (G12, EC-36) |
| BR-21 | **Nhật ký bảo mật.** Ghi đăng ký, đăng nhập (thành công / thất bại), khoá, đặt lại / đổi mật khẩu, đổi email, đăng xuất mọi phiên, xuất, xoá: thời điểm, IP, user agent, kết quả. Không ghi mật khẩu, mã, token |

## 4. Trạng thái

### 4.1. Trạng thái tài khoản

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHUA_XAC_MINH` | Đăng ký bằng email, chưa nhập đúng mã | Đăng nhập → mở SCR-02 |
| `HOAT_DONG` | Đã xác minh (hoặc tạo qua Google / Microsoft) | Dùng bình thường |
| `TAM_KHOA` | Sai mật khẩu 5 lần / 15 phút, chưa hết 15 phút | SCR-03 hiện MSG-15; Google / Microsoft vẫn đăng nhập được |
| `CHO_XOA` | Đã xác nhận xoá, chưa quá 30 ngày | Không đăng nhập được; dữ liệu ẩn |
| `DA_XOA` | Đã xoá vĩnh viễn | Không còn bản ghi; email dùng đăng ký lại được |

Chuyển trạng thái: `CHUA_XAC_MINH` → `HOAT_DONG` (UC-01) · `HOAT_DONG` ⇄ `TAM_KHOA` (UC-03, hết 15 phút hoặc UC-04) · `HOAT_DONG` → `CHO_XOA` (UC-09) → `DA_XOA` (job xoá vĩnh viễn).

### 4.2. Trạng thái onboarding và yêu cầu xuất

Onboarding: `CHUA_BAT_DAU` → `DANG_LAM` (lưu bước 1–5) → `HOAN_TAT`. Yêu cầu xuất dữ liệu: `DANG_XU_LY` → `SAN_SANG` (có link) → `HET_HAN` (sau 7 ngày); job lỗi → `LOI`, tự thử lại 3 lần `[giả định]` rồi báo người dùng tạo lại.

## 5. Use Case

### UC-01 Đăng ký bằng email và mật khẩu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Khách chưa đăng nhập |
| Hậu điều kiện thành công | Tài khoản `HOAT_DONG`, dữ liệu khởi tạo theo BR-05; người dùng đã đăng nhập, ở SCR-05 bước 1 |
| Hậu điều kiện thất bại | Không có tài khoản `HOAT_DONG`; nội dung đã nhập còn trên form |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | Mở **SCR-01**, nhập email, mật khẩu, tick đồng ý, bấm "Tạo tài khoản" |
| 2 | Hệ thống | Kiểm tra định dạng email, độ dài mật khẩu, ô đồng ý ở client; gọi \[AuthSignup\] |
| 3 | Hệ thống | Server kiểm tra BR-02 (danh sách bị lộ); tạo bản ghi `CHUA_XAC_MINH`, lưu đồng ý (BR-06), gửi mã (BR-03); mở **SCR-02** với MSG-05 |
| 4 | Khách | Nhập hoặc dán mã 6 số (đủ 6 số tự gửi) |
| 5 | Hệ thống | Gọi \[AuthVerifyEmail\]; đúng → khởi tạo theo BR-05, cấp token (BR-08), mở **SCR-05** bước 1 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Email đã có tài khoản | Bước 3 trả response như thường, mở SCR-02 (BR-04); email nhận thư "Bạn đã có tài khoản" |
| A2 | Bấm "Gửi lại mã" (bật sau 60 giây) | Gọi \[AuthResendCode\]; mã cũ vô hiệu; đếm ngược 60 giây lại |
| A3 | Bấm "Đổi email" trên SCR-02 | Về SCR-01, giữ email đã nhập để sửa |
| A4 | Mở từ link mời workspace (1.1) | Email điền sẵn và khoá; bước 5 gia nhập workspace mời thay vì tạo workspace mới (BR-05, G12) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Email sai định dạng | MSG-01 dưới ô, không gửi |
| E2 | Mật khẩu ngoài 10–128 ký tự / nằm trong danh sách bị lộ | MSG-02 / MSG-03, không gửi mã |
| E3 | Chưa tick đồng ý | MSG-04, nút "Tạo tài khoản" vẫn bấm được để hiện lỗi |
| E4 | Mã sai | MSG-06 kèm số lần còn lại |
| E5 | Mã hết hạn / sai quá 5 lần | MSG-07, ô mã bị khoá tới khi gửi mã mới |
| E6 | Gửi lại quá 5 lần / giờ | MSG-08 |
| E7 | Quá giới hạn gọi (429) / 5xx / mất mạng | MSG-09 / MSG-10, giữ nội dung form |

### UC-02 Đăng ký / đăng nhập bằng Google hoặc Microsoft

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Khách chưa đăng nhập |
| Hậu điều kiện thành công | Tài khoản mới (BR-05) hoặc tài khoản có sẵn được đăng nhập; phương thức Google / Microsoft được liên kết |
| Hậu điều kiện thất bại | Không tạo, không đăng nhập; khách ở SCR-03 kèm thông báo |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | Bấm "Tiếp tục với Google" / "Tiếp tục với Microsoft" trên SCR-01 hoặc SCR-03 |
| 2 | Hệ thống | Gọi \[AuthOAuthStart\]; chuyển tới trang nhà cung cấp kèm `state` và PKCE |
| 3 | Khách | Chọn tài khoản, đồng ý trên trang nhà cung cấp |
| 4 | Hệ thống | \[AuthOAuthCallback\] kiểm tra `state`, lấy email đã xác minh |
| 5 | Hệ thống | Email đã liên kết với tài khoản → cấp token (BR-08), mở Home hoặc bước onboarding dở |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Email chưa có tài khoản | Hiện SCR-01 rút gọn chỉ có ô đồng ý (BR-06) → bấm "Tạo tài khoản" → khởi tạo BR-05 → SCR-05 bước 1 |
| A2 | Email trùng tài khoản mật khẩu chưa liên kết phương thức này | Hỏi mật khẩu tài khoản hiện có (MSG-13) `[giả định]`; đúng → liên kết rồi đăng nhập |
| A3 | Từ link mời workspace (1.1) | Sau bước 5 gia nhập workspace mời (G12) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Khách huỷ trên trang nhà cung cấp / `state` sai hoặc hết hạn | Về SCR-03, MSG-11 |
| E2 | Nhà cung cấp không trả email đã xác minh | Về SCR-03, MSG-12 |
| E3 | Nhà cung cấp lỗi / timeout | Về SCR-03, MSG-11 |
| E4 | A2 nhập sai mật khẩu | MSG-14; tính vào BR-07 |

### UC-03 Đăng nhập, duy trì phiên và đăng xuất

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tài khoản `HOAT_DONG` hoặc `TAM_KHOA` (chỉ OAuth) |
| Hậu điều kiện thành công | Có phiên hợp lệ (BR-08); mở Home hoặc bước onboarding dở |
| Hậu điều kiện thất bại | Không có phiên; khách ở SCR-03 |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | Mở **SCR-03**, nhập email, mật khẩu, bấm "Đăng nhập" |
| 2 | Hệ thống | Gọi \[AuthLogin\]; kiểm tra BR-07 |
| 3 | Hệ thống | Đúng → cấp access token + cookie refresh token; onboarding chưa `HOAN_TAT` → SCR-05 bước dở, ngược lại → Home |
| 4 | Hệ thống | Trước khi access token hết hạn 1 phút `[giả định]` gọi \[AuthRefresh\] |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Đăng xuất | Menu tài khoản → "Đăng xuất" → \[AuthLogout\]; xoá cookie và dữ liệu offline (BR-18); về SCR-03 |
| A2 | Tài khoản `CHUA_XAC_MINH` | Gửi mã mới (BR-03), mở SCR-02 với MSG-05 |
| A3 | Tài khoản bật 2FA (1.1) | Sau mật khẩu đúng hỏi mã TOTP 6 số |
| A4 | Mở từ link mời workspace (1.1) | Sau bước 3 gia nhập workspace mời (G12) |
| A5 | Nhận `session.revoked` | Xoá token, dữ liệu offline; về SCR-03 với MSG-16 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Sai email hoặc mật khẩu | MSG-14, không nói sai trường nào |
| E2 | Sai lần thứ 5 trong 15 phút / đang `TAM_KHOA` | Chuyển `TAM_KHOA`, gửi email cảnh báo; MSG-15 |
| E3 | 429 theo IP | MSG-09 |
| E4 | \[AuthRefresh\] trả 401 (hết hạn / dùng lại token) | Thu hồi chuỗi (BR-08), về SCR-03 với MSG-16; thay đổi chưa đồng bộ giữ trong hàng đợi tới khi đăng nhập lại đúng tài khoản |
| E5 | 5xx / mất mạng | MSG-10 |

### UC-04 Quên và đặt lại mật khẩu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Khách chưa đăng nhập |
| Hậu điều kiện thành công | Mật khẩu mới có hiệu lực (BR-09); khách đã đăng nhập, mở Home |
| Hậu điều kiện thất bại | Mật khẩu không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | SCR-03 → "Quên mật khẩu" → **SCR-04** phần 1, nhập email, bấm "Gửi link" |
| 2 | Hệ thống | Gọi \[AuthPasswordForgot\]; luôn hiện MSG-17 (BR-04); email có tài khoản nhận link 30 phút |
| 3 | Khách | Mở link trong email → **SCR-04** phần 2, nhập mật khẩu mới |
| 4 | Hệ thống | Gọi \[AuthPasswordReset\]; áp BR-02, BR-09; cấp token, mở Home, toast MSG-19 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tài khoản chỉ có Google / Microsoft | Link vẫn gửi; đặt mật khẩu xong thêm phương thức mật khẩu vào tài khoản |
| A2 | Tài khoản đang `TAM_KHOA` | Đặt lại thành công → `HOAT_DONG` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Link hết hạn / đã dùng / bị link mới thay | MSG-18 có nút "Gửi link mới" |
| E2 | Mật khẩu mới không đạt BR-02 | MSG-02 / MSG-03 |
| E3 | 429 / 5xx | MSG-09 / MSG-10 |

### UC-05 Onboarding lần đầu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập; onboarding `CHUA_BAT_DAU` hoặc `DANG_LAM` |
| Hậu điều kiện thành công | Onboarding `HOAN_TAT`; cài đặt ngôn ngữ, timezone, giờ làm việc, giờ plan đã lưu; ≥ 1 task hôm nay; Daily planning (G08) đang mở |
| Hậu điều kiện thất bại | Onboarding giữ ở bước đang làm; dữ liệu bước trước đã lưu |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Mở **SCR-05** bước 1: ngôn ngữ (theo trình duyệt), timezone (theo thiết bị) |
| 2 | Người dùng | Giữ hoặc sửa, bấm "Tiếp"; hệ thống gọi \[SettingsUpdate\] (giá trị + `onboardingStep`) |
| 3 | Người dùng | Bước 2: chọn Google Calendar / Outlook → luồng kết nối của G05 → quay lại bước 2 có ✓ "Đã kết nối" → "Tiếp" |
| 4 | Người dùng | Bước 3: chọn công cụ đang dùng (chọn nhiều) → "Tiếp"; lưu `workTools` để gợi ý tích hợp khi phát hành (G11) |
| 5 | Người dùng | Bước 4: chỉnh giờ làm việc (mặc định 09:00–17:00 mọi ngày) và giờ plan ngày (mặc định 09:00) → "Tiếp" |
| 6 | Người dùng | Bước 5: nhập 1–3 task cho hôm nay (thời lượng, channel gợi ý theo G02) → "Bắt đầu ngày đầu tiên" |
| 7 | Hệ thống | Tạo task (G02); gọi \[OnboardingComplete\]; mở Daily planning hôm nay ở chế độ có hướng dẫn (G08) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Bỏ qua" ở bước 2 | Sang bước 3; Cài đặt → Lịch (G05) có lời nhắc kết nối |
| A2 | Bấm ← | Về bước trước, giữ giá trị đã nhập |
| A3 | Đóng tab / mất phiên giữa chừng | Lần mở sau vào đúng bước `onboardingStep` |
| A4 | Bước 3 chọn "Không dùng công cụ nào" | Bỏ chọn các ô khác, sang bước 4 |
| A5 | Timezone bước 1 khác timezone thiết bị khi mở lại | Không hiện banner MSG-23 trong lúc onboarding |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Kết nối lịch lỗi / bị từ chối quyền | Quay lại bước 2, thông báo của G05; vẫn "Tiếp" hoặc "Bỏ qua" được |
| E2 | Giờ kết thúc ≤ giờ bắt đầu | MSG-20, chặn "Tiếp" |
| E3 | Bước 5 chưa có task nào | Nút disabled, MSG-21 `[giả định]` |
| E4 | Lưu bước / tạo task lỗi | MSG-10, giữ ở bước hiện tại, giữ nội dung |

### UC-06 Xem và đổi cài đặt

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | Giá trị mới lưu, áp dụng ngay, đồng bộ thiết bị khác (BR-12) |
| Hậu điều kiện thất bại | Trường giữ giá trị cũ, có thông báo |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu tài khoản → "Cài đặt" (hoặc command menu "Mở cài đặt") |
| 2 | Hệ thống | Gọi \[SettingsGet\]; mở **SCR-06**, chọn sẵn nhóm Chung (**SCR-07**) |
| 3 | Người dùng | Chọn nhóm (Chung / Hiển thị **SCR-08** / Phím tắt **SCR-09**), đổi một giá trị |
| 4 | Hệ thống | Kiểm tra giới hạn; gọi \[SettingsUpdate\] chỉ với trường đổi; áp dụng ngay; MSG-22 cạnh trường |
| 5 | Hệ thống | Phát `settings.changed`; thiết bị khác cập nhật ≤ 5 giây |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Chọn nhóm do nhóm khác sở hữu | Mở trang con của nhóm đó (G02, G04 / G05, G07, G08, G10, G11, G12) |
| A2 | Mở app, timezone thiết bị khác cài đặt | Banner MSG-23: "Đổi sang…" → \[SettingsUpdate\]; "Giữ…" → lưu timezone thiết bị đã bỏ qua (BR-13) |
| A3 | Đổi giờ bắt đầu ngày | Lưu; hiện MSG-24 (BR-14) |
| A4 | Đổi ngôn ngữ | Tải gói chuỗi mới, đổi giao diện không tải lại trang |
| A5 | Thiết bị khác vừa đổi cùng trường | Nhận giá trị mới qua realtime; trường đang mở dropdown không bị đóng |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Ngưỡng khối lượng ngoài 1–24 giờ | MSG-25, không gửi |
| E2 | \[SettingsUpdate\] lỗi | Trả trường về giá trị cũ, MSG-26 |
| E3 | Mất mạng | Áp dụng ngay trên máy, xếp hàng đợi, đồng bộ khi có mạng |

### UC-07 Hồ sơ và bảo mật tài khoản

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | Hồ sơ / mật khẩu / email được đổi, hoặc các phiên khác bị thu hồi; ghi nhật ký (BR-21) |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → "Hồ sơ" (**SCR-10**) |
| 2 | Người dùng | Sửa tên hiển thị hoặc tải ảnh đại diện |
| 3 | Hệ thống | Kiểm tra giới hạn; gọi \[MeUpdate\]; MSG-22; tên / ảnh mới hiện ở menu tài khoản, comment (G02) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Đổi mật khẩu | **SCR-11** → "Đổi mật khẩu" → nhập mật khẩu hiện tại + mới → \[MeUpdate\] (BR-02, BR-10); thu hồi phiên khác `[giả định]`; MSG-30 |
| A2 | Đổi email | SCR-11 → "Đổi email" → nhập email mới + mật khẩu → \[MeUpdate\] → MSG-31, nhập mã → \[AuthVerifyEmail\] (`purpose=change_email`) → MSG-33 (BR-17) |
| A3 | Đăng xuất mọi thiết bị khác | SCR-11 → nút → \[AuthLogout\] `?all=true` (giữ phiên hiện tại) → MSG-34 (BR-18) |
| A4 | Tài khoản chỉ có Google / Microsoft | "Đổi mật khẩu" đổi thành "Tạo mật khẩu"; xác nhận lại qua nhà cung cấp (BR-10) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tên ngoài 1–80 ký tự / ảnh sai định dạng hoặc > 2 MB | MSG-27 / MSG-28 |
| E2 | Mật khẩu hiện tại sai | MSG-29; tính vào BR-07 |
| E3 | Mật khẩu mới không đạt BR-02 | MSG-02 / MSG-03 |
| E4 | Email mới không dùng được | MSG-32 ở bước nhập mã (BR-17) |
| E5 | Lỗi 5xx | MSG-10, giữ giá trị cũ |

### UC-08 Xuất dữ liệu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập; không có yêu cầu xuất `DANG_XU_LY` |
| Hậu điều kiện thành công | Yêu cầu `DANG_XU_LY`; khi xong `SAN_SANG`, người dùng nhận email có link |
| Hậu điều kiện thất bại | Không tạo yêu cầu |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-11 → "Xuất dữ liệu" |
| 2 | Hệ thống | Gọi \[DataExport\]; SCR-11 hiện MSG-35 và trạng thái yêu cầu |
| 3 | Hệ thống | Job tạo gói theo BR-19 trong ≤ 24 giờ; gửi email có link (hiệu lực 7 ngày) |
| 4 | Người dùng | Bấm link → đăng nhập nếu cần → tải file; SCR-11 cũng có nút "Tải xuống" khi `SAN_SANG` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Workspace chỉ đọc (G12) | Vẫn xuất được như luồng chính |
| A2 | Link quá 7 ngày | Trạng thái `HET_HAN`; nút "Tạo bản xuất mới" |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Đã có yêu cầu đang xử lý | MSG-36 |
| E2 | Job lỗi sau 3 lần thử | Trạng thái `LOI`, email báo, nút "Thử lại" |
| E3 | Mở link bằng tài khoản khác | 403, trang "Link này thuộc tài khoản khác" |

### UC-09 Xoá tài khoản

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập; không phải chủ sở hữu duy nhất của workspace còn thành viên khác |
| Hậu điều kiện thành công | Tài khoản `CHO_XOA`, áp BR-20; người dùng ở màn MSG-38 |
| Hậu điều kiện thất bại | Tài khoản không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-11 → "Xoá tài khoản" → **SCR-12** |
| 2 | Hệ thống | Hiện hậu quả: số task, kết nối lịch / tích hợp sẽ bị thu hồi, gói sẽ bị huỷ (G12); gợi ý "Xuất dữ liệu trước" |
| 3 | Người dùng | Nhập mật khẩu (hoặc xác nhận lại qua nhà cung cấp, BR-10), gõ "XOÁ", bấm "Xoá vĩnh viễn" |
| 4 | Hệ thống | Gọi \[AccountDelete\]; áp BR-20; về màn MSG-38 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Xuất dữ liệu trước" | Đóng SCR-12, chạy UC-08 |
| A2 | Đang có timer chạy | Dừng và lưu time entry trước khi xoá (G07) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Chủ sở hữu duy nhất, workspace còn thành viên (1.1) | MSG-37 có link "Chuyển quyền sở hữu" (G12); nút xoá disabled |
| E2 | Mật khẩu sai / chưa gõ đúng "XOÁ" | MSG-29 / MSG-39 |
| E3 | Lỗi 5xx | MSG-10, tài khoản giữ nguyên |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Trang chủ / landing → "Đăng ký" | ✓ | ✓ | SCR-01 |
| Link mời workspace (1.1) | ✓ | ✓ | SCR-01 / SCR-03 có email điền sẵn (G12) |
| Link trong email xác minh / đặt lại mật khẩu / xuất dữ liệu | ✓ | ✓ (deep link) | SCR-02 / SCR-04 / SCR-11 |
| Lần đăng nhập đầu, onboarding chưa xong | ✓ | ✓ | SCR-05 bước dở |
| Menu tài khoản → "Cài đặt" / command menu "Mở cài đặt" | ✓ | ✓ | SCR-06 |
| Banner lệch timezone trên Home | ✓ | ✓ | SCR-13 |
| Bảng phím tắt (phím ?) → "Cài đặt phím tắt" | ✓ | – | SCR-09 |

## 7. Mô tả màn hình

### SCR-01 Đăng ký

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Tiếp tục với Google", "Tiếp tục với Microsoft" | Button | – | UC-02 |
| 2 | Email | Text | Có | Định dạng email; sai → MSG-01 |
| 3 | Mật khẩu | Password + nút hiện / ẩn | Có | 10–128 ký tự (MSG-02); thanh độ mạnh `[giả định]` |
| 4 | Đồng ý Điều khoản và Chính sách quyền riêng tư | Checkbox + link | Có | Không tick sẵn; thiếu → MSG-04 |
| 5 | "Tạo tài khoản" | Button | – | Loading khi gửi; chặn bấm 2 lần |
| 6 | "Đã có tài khoản? Đăng nhập" | Link | – | SCR-03 |

### SCR-02 Nhập mã xác minh

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Mô tả | Text | – | MSG-05 |
| 2 | Mã 6 số | 6 ô số | Có | Dán 6 số tự điền và gửi; sai → MSG-06; hết hạn → MSG-07 |
| 3 | "Gửi lại mã" | Link | – | Đếm ngược 60 giây; quá giới hạn → MSG-08 |
| 4 | "Đổi email" | Link | – | A3 UC-01 |

### SCR-03 Đăng nhập

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Tiếp tục với Google", "Tiếp tục với Microsoft" | Button | – | UC-02 |
| 2 | Email, Mật khẩu | Text, Password | Có | Lỗi chung MSG-14; khoá MSG-15 |
| 3 | "Đăng nhập" | Button | – | Loading khi gửi |
| 4 | "Quên mật khẩu?" | Link | – | SCR-04 |
| 5 | Vùng thông báo | Inline | – | MSG-11 / MSG-12 / MSG-16 khi được chuyển về từ luồng khác |

### SCR-04 Quên / đặt lại mật khẩu

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | (Phần 1) Email + "Gửi link" | Text + Button | Có | Luôn hiện MSG-17 sau khi gửi |
| 2 | (Phần 2) Mật khẩu mới | Password | Có | BR-02 (MSG-02 / MSG-03); link hỏng → MSG-18 |
| 3 | (Phần 2) "Đặt mật khẩu" | Button | – | UC-04 bước 4 |

### SCR-05 Onboarding

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Thanh tiến độ "Bước n / 5" | Progress | – | Có nút ← từ bước 2 |
| 2 | Bước 1: Ngôn ngữ, Timezone | Dropdown, Dropdown có tìm | Có | Điền sẵn theo trình duyệt / thiết bị |
| 3 | Bước 2: "Kết nối Google Calendar", "Kết nối Outlook", "Bỏ qua" | Button | Không | Luồng G05; đã kết nối hiện ✓ và email lịch |
| 4 | Bước 3: Công cụ đang dùng | Lưới chọn nhiều (logo + tên) | Không | Gmail, Outlook, Jira, Notion, Asana, Trello, Linear, ClickUp, GitHub, Todoist, Slack, Teams, "Khác", "Không dùng công cụ nào" `[giả định danh sách]` |
| 5 | Bước 4: Giờ làm việc | Chọn ngày + giờ bắt đầu / kết thúc | Có | Mặc định 09:00–17:00 mọi ngày; kết thúc ≤ bắt đầu → MSG-20 |
| 6 | Bước 4: Giờ plan ngày | Time picker (bước 5 phút) | Có | Mặc định 09:00 |
| 7 | Bước 5: 3 ô task | Text ×3 | ≥ 1 ô `[giả định]` | Tiêu đề theo G02; thời lượng gợi ý có ✨; trống hết → MSG-21 |
| 8 | "Tiếp" / "Bắt đầu ngày đầu tiên" | Button | – | Lưu bước; bước 5 → UC-05 bước 7 |

### SCR-06 Khung trang Cài đặt

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Cột trái: nhóm "Cá nhân" | Nav list | Chung · Hiển thị · Ritual (G08) · Timebox (G05) · Lịch làm việc (G04 / G05) · Phím tắt · Focus (G07) · AI (G10) · Beta (G10, ẩn ở 1.0) · Thông báo (G12) |
| 2 | Cột trái: nhóm "Tài khoản" | Nav list | Hồ sơ · Tài khoản |
| 3 | Cột trái: nhóm "Workspace" | Nav list | Context & channel (G02) · Thành viên (G12, 1.1) · Privacy (G12, 1.1) · Billing (G12) · Tích hợp (G05 / G11) |
| 4 | Vùng nội dung | Panel | Nội dung nhóm đang chọn; URL theo nhóm để mở thẳng (`/settings/{nhom}`) |
| 5 | Ô tìm cài đặt | Search `[giả định]` | Lọc theo tên cài đặt, mở đúng nhóm và cuộn tới trường |
| 6 | Đóng | Icon × / Esc | Về màn trước |

Mobile web: cột trái thành danh sách màn đầu, chọn nhóm mở màn nội dung có nút ←.

### SCR-07 Cài đặt Chung

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ngôn ngữ | Dropdown | Có | A4 UC-06 |
| 2 | Timezone | Dropdown có tìm | Có | Hiện "Theo thiết bị: {tz}" khi lệch |
| 3 | Ngày đầu tuần | Dropdown | Có | Thứ Hai / Chủ Nhật |
| 4 | Giờ bắt đầu ngày | Time picker | Có | 00:00–06:00; ghi chú MSG-24 |
| 5 | Ngưỡng khối lượng ngày | Ô giờ | Có | 1–24 giờ (MSG-25) |
| 6 | Tính planned là actual | Toggle | – | Mặc định bật |
| 7 | Tự sắp task | Toggle | – | Mặc định bật |
| 8 | Vị trí task mới · Vị trí task rollover | Segmented Đầu / Cuối | – | Mặc định Đầu · Đầu |
| 9 | Giữ priority khi rollover | Dropdown | – | Không / từ Urgent / từ Priority `[giả định]` |

### SCR-08 Cài đặt Hiển thị

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Giao diện | Segmented Sáng / Tối / Hệ thống | – | Đổi ngay |
| 2 | Màu sự kiện trên lịch | Dropdown | – | Theo channel (mặc định) / theo lịch |
| 3 | Ẩn task đã xong | Toggle | – | Mặc định tắt |
| 4 | Hiệu ứng chúc mừng | Toggle | – | Mặc định bật `[giả định]`; bật thì chạy thử 1 lần |

### SCR-09 Cài đặt Phím tắt

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Bật phím tắt | Toggle | – | BR-15 |
| 2 | Phím toàn cục (desktop, 1.1) | Hiển thị phím | – | Ctrl+Shift+A thêm task · Ctrl+Shift+Space bật / dừng timer; ẩn trên Web |
| 3 | Bảng phím tắt | Danh sách theo nhóm | – | Cùng dữ liệu với bảng phím ? (G04); chỉ xem ở 1.0 `[giả định]` |

### SCR-10 Hồ sơ

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ảnh đại diện | Upload + crop | Không | JPG / PNG ≤ 2 MB (MSG-28); "Xoá ảnh" về chữ cái đầu |
| 2 | Tên hiển thị | Text | Có | 1–80 ký tự (MSG-27) |
| 3 | Email | Text chỉ đọc | – | Link "Đổi email" → SCR-11 |

### SCR-11 Tài khoản

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Phương thức đăng nhập | List | Mật khẩu / Google / Microsoft đã liên kết |
| 2 | "Đổi mật khẩu" / "Tạo mật khẩu" | Button → dialog | A1, A4 UC-07 |
| 3 | "Đổi email" | Button → dialog 2 bước | A2 UC-07 |
| 4 | Xác thực 2 lớp | Toggle | Ẩn ở 1.0 (1.1) |
| 5 | "Đăng xuất mọi thiết bị khác" | Button | A3 UC-07 |
| 6 | "Xuất dữ liệu" + trạng thái | Button + text | UC-08; hiện MSG-35 / "Tải xuống" / "Đã hết hạn" |
| 7 | "Xoá tài khoản" | Button (nguy hiểm) | SCR-12 |

### SCR-12 Xoá tài khoản

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "Xoá tài khoản sẽ xoá {n} task, ngắt {m} kết nối và huỷ gói hiện tại. Dữ liệu bị xoá vĩnh viễn trong 30 ngày, không khôi phục được." |
| 2 | "Xuất dữ liệu trước" | Link | A1 UC-09 |
| 3 | Mật khẩu | Password | Sai → MSG-29 |
| 4 | Ô gõ "XOÁ" | Text | Khác "XOÁ" → MSG-39 |
| 5 | "Xoá vĩnh viễn" | Button (nguy hiểm) | Disabled tới khi 3, 4 hợp lệ; chủ sở hữu duy nhất → disabled + MSG-37 |
| 6 | "Huỷ" | Button | Đóng |

### SCR-13 Banner timezone và tooltip theo ngữ cảnh

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Banner lệch timezone | Banner đầu Home | MSG-23; hai nút "Đổi sang…", "Giữ…" (BR-13) |
| 2 | Tooltip theo ngữ cảnh | Popover neo vào thành phần | Tiêu đề + 1–2 câu + "Đã hiểu"; hiện 1 lần (BR-16) |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[AuthSignup\] `POST /auth/signup` | email, password, consentVersion, locale, timezone, inviteToken?, Idempotency-Key | verificationId (202) | 10s / 1 lần cùng key |
| \[AuthVerifyEmail\] `POST /auth/verify-email` | verificationId, code, purpose (`signup` / `change_email`) | accessToken, user, onboardingState; cookie refresh | 5s / không retry |
| \[AuthResendCode\] `POST /auth/verify-email/resend` `[giả định]` | verificationId | nextAllowedAt | 5s / không retry |
| \[AuthLogin\] `POST /auth/login` | email, password, totp? (1.1), inviteToken? | accessToken, user, onboardingState; cookie refresh | 10s / không retry |
| \[AuthOAuthStart\] `GET /auth/oauth/{provider}/start` | provider (`google` / `microsoft`), redirectUri, inviteToken? | 302 tới nhà cung cấp (state, PKCE) | 5s / 1 lần |
| \[AuthOAuthCallback\] `GET /auth/oauth/{provider}/callback` | code, state | 302 về app; `needsConsent` / `needsLink` nếu A1 / A2 UC-02 | 10s / không retry |
| \[AuthRefresh\] `POST /auth/refresh` | cookie refresh | accessToken; cookie refresh mới | 5s / 2 lần (lỗi mạng), 401 không retry |
| \[AuthLogout\] `POST /auth/logout(?all=true)` | cookie refresh | 204; `revokedCount` khi all | 5s / 1 lần |
| \[AuthPasswordForgot\] `POST /auth/password/forgot` | email | 202 (luôn) | 5s / 1 lần |
| \[AuthPasswordReset\] `POST /auth/password/reset` | token, newPassword | accessToken; cookie refresh | 10s / không retry |
| \[MeGet\] / \[MeUpdate\] `GET` / `PATCH /me` | displayName, avatar; currentPassword + newPassword; currentPassword + newEmail | User; `pendingEmailVerificationId` khi đổi email | 5s / 2 lần (GET), 1 lần (PATCH) |
| \[SettingsGet\] / \[SettingsUpdate\] `GET` / `PATCH /me/settings` | Trường thay đổi (kể cả `onboardingStep`, `tipsSeen`, `workTools`), version | Settings, version | 5s / 2 lần |
| \[OnboardingComplete\] `POST /me/onboarding/complete` | Idempotency-Key | onboardingState, dailyPlanningUrl | 5s / 2 lần cùng key |
| \[DataExport\] `POST /me/export` · `GET /me/export/{id}` `[giả định]` | Idempotency-Key | exportId, status, downloadUrl?, expiresAt | 5s / 1 lần |
| \[AccountDelete\] `DELETE /me` | currentPassword hoặc reauthToken, confirmText | 202, purgeBefore | 10s / không retry |
| \[AppConfig\] | – | Giới hạn BR-02, BR-03, mặc định cài đặt | Cache 1h |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field email | MSG-01 |
| `VALIDATION_FAILED` · field password | MSG-02 |
| `PASSWORD_BREACHED` | MSG-03 |
| `CONSENT_REQUIRED` | MSG-04 |
| `CODE_INVALID` | MSG-06 |
| `CODE_EXPIRED` / `CODE_ATTEMPTS_EXCEEDED` | MSG-07 |
| `RESEND_LIMITED` (429) | MSG-08 |
| `RATE_LIMITED` (429) | MSG-09 |
| `OAUTH_FAILED` / `OAUTH_STATE_INVALID` | MSG-11 |
| `OAUTH_EMAIL_UNVERIFIED` | MSG-12 |
| `ACCOUNT_LINK_REQUIRED` (409) | MSG-13 |
| `INVALID_CREDENTIALS` (401) | MSG-14 |
| `ACCOUNT_LOCKED` (403) | MSG-15 |
| `EMAIL_NOT_VERIFIED` (403) | Mở SCR-02, MSG-05 |
| `REFRESH_REUSED` / `SESSION_REVOKED` (401) | MSG-16 |
| `RESET_TOKEN_INVALID` | MSG-18 |
| `VALIDATION_FAILED` · field workHours | MSG-20 |
| `VALIDATION_FAILED` · field workloadThresholdMin | MSG-25 |
| `VALIDATION_FAILED` · field displayName / avatar | MSG-27 / MSG-28 |
| `WRONG_PASSWORD` (403) | MSG-29 |
| `EMAIL_CHANGE_REJECTED` (422) | MSG-32 |
| `EXPORT_IN_PROGRESS` (409) | MSG-36 |
| `OWNER_MUST_TRANSFER` (409) | MSG-37 |
| `VERSION_CONFLICT` (412) ở \[SettingsUpdate\] | Lấy giá trị server, không báo |
| 5xx / timeout | MSG-10 (xác thực, tài khoản) / MSG-26 (cài đặt) |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Inline | Email chưa đúng định dạng |
| MSG-02 | Inline | Mật khẩu cần từ 10 đến 128 ký tự |
| MSG-03 | Inline | Mật khẩu này đã bị lộ trong một vụ rò rỉ dữ liệu. Hãy chọn mật khẩu khác |
| MSG-04 | Inline | Bạn cần đồng ý với Điều khoản sử dụng và Chính sách quyền riêng tư |
| MSG-05 | SCR-02 | Chúng tôi đã gửi mã 6 số tới {email}. Mã có hiệu lực 10 phút. Đã có tài khoản? Đăng nhập · Quên mật khẩu |
| MSG-06 | Inline | Mã chưa đúng. Bạn còn {n} lần thử |
| MSG-07 | Inline | Mã đã hết hạn hoặc không còn dùng được. Gửi mã mới |
| MSG-08 | Inline | Bạn đã yêu cầu quá nhiều mã. Thử lại sau {m} phút |
| MSG-09 | Toast | Bạn thao tác quá nhanh. Thử lại sau ít phút |
| MSG-10 | Toast | Không kết nối được máy chủ. Thử lại |
| MSG-11 | SCR-03 | Đăng nhập bằng {Google / Microsoft} chưa thành công. Thử lại |
| MSG-12 | SCR-03 | Tài khoản {Google / Microsoft} chưa xác minh email. Hãy đăng nhập bằng email và mật khẩu |
| MSG-13 | Dialog | {email} đã có tài khoản. Nhập mật khẩu để liên kết với {Google / Microsoft} |
| MSG-14 | SCR-03 | Email hoặc mật khẩu chưa đúng |
| MSG-15 | SCR-03 | Đăng nhập bằng mật khẩu tạm khoá do nhập sai nhiều lần. Thử lại sau {m} phút hoặc dùng "Quên mật khẩu" |
| MSG-16 | SCR-03 | Phiên đăng nhập đã kết thúc. Hãy đăng nhập lại |
| MSG-17 | SCR-04 | Nếu {email} có tài khoản, chúng tôi đã gửi link đặt lại mật khẩu. Link có hiệu lực 30 phút |
| MSG-18 | SCR-04 | Link đã hết hạn hoặc đã được dùng · Gửi link mới |
| MSG-19 | Toast | Đã đặt lại mật khẩu. Các thiết bị khác đã được đăng xuất |
| MSG-20 | Inline | Giờ kết thúc phải sau giờ bắt đầu |
| MSG-21 | Inline | Thêm ít nhất 1 task để bắt đầu |
| MSG-22 | Inline cạnh trường | ✓ Đã lưu |
| MSG-23 | Banner | Máy bạn đang ở múi giờ {tz thiết bị}, cài đặt đang là {tz}. Đổi sang {tz thiết bị} · Giữ {tz} |
| MSG-24 | Inline dưới trường | Áp dụng từ ngày làm việc kế tiếp ({ngày}) |
| MSG-25 | Inline | Ngưỡng khối lượng từ 1 đến 24 giờ |
| MSG-26 | Toast | Chưa lưu được cài đặt. Thử lại |
| MSG-27 | Inline | Tên hiển thị từ 1 đến 80 ký tự |
| MSG-28 | Inline | Ảnh đại diện JPG hoặc PNG, tối đa 2 MB |
| MSG-29 | Inline | Mật khẩu hiện tại chưa đúng |
| MSG-30 | Toast | Đã đổi mật khẩu. Các thiết bị khác đã được đăng xuất |
| MSG-31 | Inline | Đã gửi mã tới {email mới}. Email đăng nhập chỉ đổi khi bạn nhập đúng mã |
| MSG-32 | Inline | Không đổi được sang email này |
| MSG-33 | Toast | Đã đổi email đăng nhập thành {email} |
| MSG-34 | Toast | Đã đăng xuất {n} thiết bị khác |
| MSG-35 | Inline | Đang chuẩn bị dữ liệu. Chúng tôi sẽ gửi email khi xong (tối đa 24 giờ) |
| MSG-36 | Inline | Đã có một yêu cầu xuất dữ liệu đang xử lý |
| MSG-37 | Inline | Bạn là chủ sở hữu duy nhất của workspace còn thành viên khác. Hãy chuyển quyền sở hữu trước · Chuyển quyền sở hữu |
| MSG-38 | Màn hình | Tài khoản đã được xoá. Dữ liệu sẽ bị xoá vĩnh viễn trong vòng 30 ngày |
| MSG-39 | Inline | Gõ "XOÁ" để xác nhận |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | \[AuthLogin\] / \[AuthSignup\] p95 ≤ 800 ms (gồm băm Argon2id); \[SettingsUpdate\] p95 ≤ 300 ms; cài đặt áp dụng trên giao diện ≤ 100 ms; mỗi bước onboarding chuyển ≤ 500 ms; email mã / link tới hộp thư ≤ 1 phút (p95) |
| Offline | Đăng ký, đăng nhập, đổi mật khẩu / email, xuất, xoá cần mạng. Cài đặt nhóm Chung / Hiển thị / Phím tắt đổi được khi mất mạng, đồng bộ sau. Đăng xuất xoá dữ liệu offline (BR-18) |
| Đồng bộ | `settings.changed`, `session.revoked` tới thiết bị khác ≤ 5 giây |
| Bảo mật | HTTPS bắt buộc; Argon2id cho mật khẩu; PKCE + `state` cho OAuth; refresh token xoay vòng, phát hiện dùng lại (BR-08); chống CSRF cho endpoint dùng cookie; rate limit 10 lần đăng nhập / phút / IP, 600 req / phút / user; mã và token chỉ lưu dạng băm; phản hồi đăng ký / quên mật khẩu không lộ email (BR-04) |
| Quyền riêng tư, tuân thủ | Lưu bản đồng ý (BR-06); xuất ≤ 24 giờ, xoá ≤ 30 ngày gồm cả bản sao lưu theo chu kỳ; Nghị định 13/2023/NĐ-CP và GDPR chờ pháp chế xác nhận; nơi lưu dữ liệu (Việt Nam hay không) — câu hỏi mở |
| Log / audit | Nhật ký bảo mật theo BR-21, giữ 1 năm; log hệ thống không chứa mật khẩu, mã, token, nội dung task |
| Tracking | Sự kiện: `signup_started`, `signup_completed` (phương thức), `email_verified`, `login_succeeded` / `login_failed`, `account_locked`, `password_reset_requested` / `_completed`, `onboarding_step_completed` (bước, bỏ qua?), `onboarding_completed`, `tip_shown` / `tip_dismissed`, `setting_changed` (tên cài đặt, không ghi giá trị cá nhân), `timezone_banner_action`, `data_export_requested`, `account_deleted` |
| Accessibility | Form có nhãn, lỗi đọc được bằng trình đọc màn hình (aria-live); ô mã 6 số hỗ trợ dán và tự điền OTP; điều hướng toàn bộ bằng bàn phím; tương phản đạt WCAG 2.1 AA ở cả giao diện sáng / tối |
