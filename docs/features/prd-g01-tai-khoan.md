> **Mã:** PLN-PRD-G01 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g01-tai-khoan.md

# PRD Tài khoản, onboarding & cài đặt trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (tooltip theo ngữ cảnh "Task projections", "Your first keyboard shortcut"; danh sách nhóm trong trang Cài đặt); chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

G01 là cửa vào sản phẩm: đăng ký, đăng nhập, onboarding lần đầu và trang Cài đặt. Các giá trị G01 thu thập quyết định các nhóm khác chạy đúng: timezone và giờ bắt đầu ngày (day_start_time) xác định "hôm nay" cho board, rollover, ritual (G04, G06, G08); giờ làm việc xác định projection và timebox (G04, G05); giờ plan ngày xác định lúc nhắc Daily planning (G08). Đăng ký thành công tạo workspace và bắt đầu trial 14 ngày (G12). G01 đặc tả khung trang Cài đặt và các nhóm Chung, Hiển thị, Phím tắt, Hồ sơ, Tài khoản; các nhóm cài đặt khác do nhóm sở hữu đặc tả.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Đăng ký nhiều trường, nhiều bước | Người dùng bỏ ngang trước khi thấy giá trị sản phẩm |
| Sau đăng ký app trống, không biết bắt đầu từ đâu | Không quay lại ngày thứ hai |
| Timezone, giờ làm việc, giờ bắt đầu ngày sai | "Hôm nay", projection, lời nhắc ritual lệch giờ; người dùng mất niềm tin |
| Cài đặt phải bấm Lưu, không thấy tác dụng ngay | Quên lưu, tưởng cài đặt không chạy |
| Tài khoản bị dò mật khẩu, lộ việc email đã đăng ký hay chưa | Rủi ro chiếm tài khoản, vi phạm quy định bảo vệ dữ liệu cá nhân |
| Không tự xuất hoặc xoá được dữ liệu | Không đáp ứng Nghị định 13/2023/NĐ-CP, GDPR; phải qua bộ phận hỗ trợ |

## 1.3 Mục tiêu

- Đăng ký xong trong ≤ 60 giây với Google / Microsoft, ≤ 2 phút với email + mật khẩu `[giả định]`.
- Hết onboarding, người dùng có: timezone đúng, giờ làm việc, lịch đã kết nối (nếu chọn), ít nhất 1 task hôm nay, và đang ở Daily planning đầu tiên.
- Mọi cài đặt lưu và áp dụng ngay, không có nút Lưu; thiết bị khác thấy thay đổi ≤ 5 giây.
- Người dùng tự đổi mật khẩu, email, đăng xuất mọi phiên, xuất dữ liệu và xoá tài khoản, không cần liên hệ hỗ trợ.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng mới, cá nhân (Linh PM, Minh designer / dev, Hà freelancer) | Đăng ký nhanh bằng tài khoản Google / Microsoft sẵn có; có ngay một ngày được lên kế hoạch |
| Người dùng thành thạo | Chỉnh phím tắt, giờ bắt đầu ngày, ngưỡng khối lượng theo cách làm việc riêng |
| Người được mời vào workspace (bản 1.1) | Đăng ký / đăng nhập xong vào thẳng workspace của nhóm (G12) |
| Người quan tâm bảo mật, quyền riêng tư | Mật khẩu an toàn, biết khi có đăng nhập lạ, tự xuất và xoá dữ liệu |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Đăng ký bằng Google, Microsoft, email + mật khẩu (xác minh bằng mã 6 số).
- Đăng nhập, đăng xuất, quên / đặt lại mật khẩu, khoá tạm khi nhập sai nhiều lần, quản lý phiên đăng nhập.
- Onboarding 5 bước, Daily planning đầu tiên có hướng dẫn (G08), tooltip theo ngữ cảnh hiện 1 lần.
- Trang Cài đặt: khung trang (danh sách nhóm, điều hướng) và nội dung nhóm Chung, Hiển thị, Phím tắt, Hồ sơ, Tài khoản.
- Tài khoản: đổi mật khẩu, đổi email chính, đăng xuất mọi phiên, xuất dữ liệu, xoá tài khoản.

## 3.2 Ngoài phạm vi

- Xác thực 2 lớp (2FA TOTP) → bản 1.1 (G01).
- Nhận lời mời workspace → bản 1.1: phần đăng ký / đăng nhập ở G01, lời mời và thành viên ở G12.
- Trial, thanh toán, cài đặt Thông báo, Thành viên, Privacy, Billing → G12.
- Context & channel → G02. Ritual → G08 (Weekly G09). Timebox, Lịch làm việc → G04 / G05. Focus → G07. AI, Beta → G10. Tích hợp → G05 (lịch) / G11.
- Đăng nhập bằng Apple, SSO doanh nghiệp (SAML) → chưa có kế hoạch `[giả định]`.

# 4. Nguyên tắc sản phẩm

## 4.1 Thấy giá trị trước, hỏi sau

Đăng ký chỉ hỏi email và mật khẩu (hoặc một nút Google / Microsoft). Mọi trường onboarding có giá trị điền sẵn; bước kết nối lịch bỏ qua được.

## 4.2 Thời gian phải đúng

Timezone lấy từ thiết bị; lệch với cài đặt thì hỏi, không tự đổi. Mọi tính toán "hôm nay" dùng giờ bắt đầu ngày theo timezone người dùng.

## 4.3 Lưu ngay, áp dụng ngay

Đổi cài đặt nào lưu cài đặt đó ngay, giao diện đổi theo ngay, không tải lại trang.

## 4.4 Không lộ, không giữ thừa

Không cho người ngoài biết một email đã đăng ký hay chưa. Không lưu mật khẩu ở dạng đọc được. Người dùng tự xuất và xoá dữ liệu của mình.

# 5. Quy tắc tài khoản và cài đặt mặc định

| **Mục** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Mã xác minh email | 6 số, hết hạn 10 phút, dùng 1 lần; gửi lại sau 60 giây, ≤ 5 lần / giờ `[giả định]` | — | Nhập sai 5 lần → mã vô hiệu `[giả định]` |
| Mật khẩu | ≥ 10 ký tự (tối đa 128 `[giả định]`), không nằm trong danh sách mật khẩu bị lộ | — | Lưu bằng Argon2id |
| Sai mật khẩu | 5 lần trong 15 phút → khoá đăng nhập bằng mật khẩu 15 phút | — | Gửi email cảnh báo |
| Link đặt lại mật khẩu | Hiệu lực 30 phút, dùng 1 lần | — | |
| Phiên đăng nhập | Access token 15 phút; refresh token 30 ngày, xoay vòng mỗi lần dùng | — | Dùng lại refresh token cũ → thu hồi cả chuỗi |
| Xuất dữ liệu | JSON / CSV, sẵn sàng ≤ 24 giờ, link tải 7 ngày | — | Dùng được cả khi workspace chỉ đọc (G12) |
| Xoá tài khoản | Xoá vĩnh viễn ≤ 30 ngày | — | Thu hồi mọi token (phiên, lịch, tích hợp) |
| Ngôn ngữ | Tiếng Việt, English `[giả định]` | Theo trình duyệt | |
| Timezone | Danh sách IANA | Theo thiết bị lúc đăng ký | Lệch thiết bị → cảnh báo |
| Ngày đầu tuần | Thứ Hai / Chủ Nhật `[giả định]` | Thứ Hai | |
| Giờ bắt đầu ngày (day_start_time) | 00:00–06:00 `[giả định]` | 04:00 `[giả định — chờ PO chốt 04:00 hay 00:00]` | Mốc "hôm nay" cho rollover, ritual, AI |
| Ngưỡng khối lượng ngày | 1–24 giờ `[giả định]` | 8 giờ | Dùng ở cảnh báo quá tải (G04) |
| Tính planned là actual | Bật / tắt | Bật | Áp khi hoàn thành task (G02) |
| Tự sắp task | Bật / tắt | Bật | G04 |
| Vị trí task mới · task rollover | Đầu / cuối | Đầu · Đầu | G02, G06 |
| Giữ priority khi rollover | Không / giữ từ mức chọn | Không | G06 |
| Giao diện | Sáng / tối / theo hệ thống | Theo hệ thống `[giả định]` | Phím Shift+L đổi nhanh (G04) |
| Màu sự kiện trên lịch | Theo channel / theo lịch `[giả định]` | Theo channel | |
| Ẩn task đã xong | Bật / tắt | Tắt | |
| Hiệu ứng chúc mừng (pháo giấy) | Bật / tắt | Bật `[giả định]` | Khi hoàn thành task |
| Phím tắt | Bật / tắt | Bật | Toàn cục Ctrl+Shift+A, Ctrl+Shift+Space chỉ trên desktop (1.1) |
| Giờ làm việc (nhập ở onboarding) | Giờ bắt đầu < giờ kết thúc, theo từng ngày | 09:00–17:00 mọi ngày | Giống Sunsama; chỉnh chi tiết ở nhóm Lịch làm việc (G04 / G05) |
| Giờ plan ngày (nhập ở onboarding) | 00:00–23:55 | 09:00 | Nhắc Daily planning (G08) |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Nhóm cài đặt do nhóm khác sở hữu (Ritual, Timebox, Lịch làm việc, Focus, AI, Beta, Thông báo, Context & channel, Thành viên, Privacy, Billing, Tích hợp) chỉ có lối vào trong khung trang Cài đặt; nội dung đặc tả ở nhóm sở hữu.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Đăng ký | Bấm "Tiếp tục với Google / Microsoft" hoặc nhập email + mật khẩu, nhập mã 6 số | Tài khoản, workspace, 3 context mặc định, trial 14 ngày (G12) |
| 2 | Onboarding | 5 bước: ngôn ngữ + timezone → kết nối lịch → công cụ công việc → giờ làm việc + giờ plan → 3 task đầu | Cài đặt cơ bản đúng, có task hôm nay |
| 3 | Ngày đầu tiên | Daily planning có hướng dẫn (G08); tooltip giải thích projection, phím tắt khi gặp lần đầu | Ngày đầu tiên được lên kế hoạch |
| 4 | Dùng hằng ngày | Đăng nhập một lần, phiên tự gia hạn 30 ngày | Không phải đăng nhập lại mỗi ngày |
| 5 | Điều chỉnh | Mở Cài đặt, đổi giá trị, thấy tác dụng ngay | App khớp cách làm việc |
| 6 | Quản lý tài khoản | Đổi mật khẩu / email, đăng xuất mọi phiên, xuất dữ liệu, xoá tài khoản | Người dùng kiểm soát tài khoản và dữ liệu |

Bước 3 dùng Daily planning của G08; PRD này chỉ đặc tả phần dẫn từ onboarding sang và tooltip.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Đăng ký

### US1.1 Đăng ký bằng email và mật khẩu

User Story: Là người dùng mới, tôi muốn đăng ký chỉ bằng email và mật khẩu, để bắt đầu dùng thử ngay.

AC01: Màn đăng ký có email, mật khẩu, ô đồng ý Điều khoản sử dụng và Chính sách quyền riêng tư (không tick sẵn).

AC02: Mật khẩu < 10 ký tự hoặc nằm trong danh sách bị lộ → báo lỗi ngay dưới ô, không gửi mã.

AC03: Hợp lệ → gửi mã 6 số tới email, mở màn nhập mã; mã hết hạn sau 10 phút; dán mã đủ 6 số tự gửi.

AC04: Nhập đúng mã → tạo tài khoản, workspace (người dùng là chủ sở hữu), 3 context `work`, `personal`, `uncategorized`, bắt đầu trial 14 ngày (G12), mở onboarding.

AC05: "Gửi lại mã" bật sau 60 giây `[giả định]`.

### US1.2 Đăng ký bằng Google hoặc Microsoft

AC01: Nút "Tiếp tục với Google" và "Tiếp tục với Microsoft" có ở cả màn đăng ký và đăng nhập.

AC02: Email chưa có tài khoản → hỏi đồng ý Điều khoản một lần rồi tạo tài khoản như US1.1 AC04; email đã có → đăng nhập luôn.

AC03: Huỷ ở trang Google / Microsoft → quay về màn đăng nhập, có thông báo, không tạo gì.

### US1.3 Email đã có tài khoản

AC01: Đăng ký bằng email đã có → giao diện giống hệt trường hợp email mới (vẫn sang màn nhập mã); hệ thống gửi tới email đó thư "Bạn đã có tài khoản" kèm link đăng nhập và quên mật khẩu.

AC02: Màn nhập mã luôn có link "Đã có tài khoản? Đăng nhập · Quên mật khẩu".

## UC2. Onboarding lần đầu

### US2.1 Thiết lập cơ bản trong 5 bước

User Story: Là người dùng mới, tôi muốn được dẫn qua vài bước ngắn có sẵn giá trị gợi ý, để app đúng giờ, đúng lịch của tôi ngay từ ngày đầu.

AC01: Bước 1 ngôn ngữ + timezone, điền sẵn theo trình duyệt / thiết bị.

AC02: Bước 2 kết nối Google Calendar hoặc Outlook (G05); có "Bỏ qua"; kết nối lỗi vẫn đi tiếp được.

AC03: Bước 3 chọn công cụ công việc đang dùng (chọn nhiều); 1.0 chỉ lưu lựa chọn để gợi ý tích hợp khi phát hành (G11).

AC04: Bước 4 giờ làm việc (mặc định 09:00–17:00 mọi ngày) và giờ plan ngày (mặc định 09:00).

AC05: Bước 5 có 3 ô nhập task cho hôm nay; cần ít nhất 1 task để hoàn tất `[giả định]`.

AC06: Có nút ← quay lại; đóng tab giữa chừng → mở lại tiếp tục đúng bước dở.

### US2.2 Daily planning đầu tiên có hướng dẫn

AC01: Hoàn tất bước 5 → mở Daily planning của hôm nay (G08) ở chế độ có hướng dẫn, các task vừa tạo đã nằm trong danh sách.

AC02: Onboarding chỉ hiện một lần cho mỗi tài khoản.

### US2.3 Tooltip theo ngữ cảnh

AC01: Lần đầu gặp một khái niệm (ví dụ projection — tooltip "Task projections"; lần đầu dùng phím tắt — "Your first keyboard shortcut", như Sunsama) hiện tooltip giải thích ngắn.

AC02: Mỗi tooltip hiện tối đa 1 lần cho mỗi tài khoản, trên mọi thiết bị.

## UC3. Đăng nhập và phiên

### US3.1 Đăng nhập

AC01: Đăng nhập bằng email + mật khẩu hoặc Google / Microsoft; xong mở Home (hoặc bước onboarding còn dở).

AC02: Sai email hoặc mật khẩu → một thông báo chung, không nói sai trường nào.

AC03: Phiên tự gia hạn; không dùng app quá 30 ngày mới phải đăng nhập lại.

### US3.2 Khoá tạm khi nhập sai nhiều lần

AC01: Sai mật khẩu 5 lần trong 15 phút → khoá đăng nhập bằng mật khẩu 15 phút, gửi email cảnh báo cho chủ tài khoản.

AC02: Trong thời gian khoá vẫn dùng được "Quên mật khẩu"; đặt lại thành công thì mở khoá.

### US3.3 Quên mật khẩu

AC01: Nhập email → luôn hiện "Nếu email có tài khoản, chúng tôi đã gửi link…", kể cả email chưa đăng ký.

AC02: Link hiệu lực 30 phút, dùng 1 lần; đặt lại xong đăng nhập luôn, các thiết bị khác bị đăng xuất `[giả định]`.

### US3.4 Đăng nhập từ lời mời workspace (bản 1.1)

AC01: Mở link mời → đăng ký hoặc đăng nhập với email được mời điền sẵn → vào thẳng workspace mời (G12).

## UC4. Cài đặt

### US4.1 Mở và đổi cài đặt

User Story: Là người dùng, tôi muốn đổi một cài đặt và thấy tác dụng ngay, để không phải nhớ bấm Lưu.

AC01: Mở Cài đặt từ menu tài khoản; cột trái liệt kê các nhóm, cột phải là nội dung nhóm.

AC02: Đổi giá trị nào lưu ngay giá trị đó, hiện dấu ✓ "Đã lưu" cạnh trường; giao diện áp dụng ngay.

AC03: Nhóm do nhóm tính năng khác sở hữu mở trang con của nhóm đó; nhóm chưa phát hành ở bản hiện tại không hiện.

### US4.2 Timezone và giờ bắt đầu ngày

AC01: Mở app ở timezone khác cài đặt → banner hỏi "Đổi sang {timezone thiết bị}" hoặc "Giữ {timezone}"; không tự đổi.

AC02: Đổi giờ bắt đầu ngày áp dụng từ ngày làm việc kế tiếp `[giả định]`, có ghi chú dưới trường.

### US4.3 Hiển thị và phím tắt

AC01: Đổi giao diện sáng / tối / hệ thống đổi ngay, không tải lại trang.

AC02: Tắt phím tắt → mọi phím tắt một ký tự ngừng hoạt động; Ctrl/Cmd+K vẫn mở command menu `[giả định]`.

AC03: Trang Phím tắt liệt kê đủ phím theo nhóm, giống bảng mở bằng phím ? (G04).

## UC5. Hồ sơ và tài khoản

### US5.1 Sửa hồ sơ

AC01: Sửa tên hiển thị (1–80 ký tự `[giả định]`) và ảnh đại diện (JPG / PNG ≤ 2 MB `[giả định]`); lưu ngay.

### US5.2 Đổi mật khẩu, đổi email

AC01: Đổi mật khẩu và đổi email đều cần nhập lại mật khẩu hiện tại.

AC02: Đổi email → gửi mã 6 số tới email mới; chỉ đổi khi nhập đúng mã; email cũ nhận thư thông báo.

AC03: Đổi mật khẩu → các thiết bị khác bị đăng xuất `[giả định]`.

### US5.3 Đăng xuất mọi phiên

AC01: Nút "Đăng xuất mọi thiết bị khác"; thiết bị khác về màn đăng nhập ≤ 1 phút `[giả định]`.

### US5.4 Xuất dữ liệu

User Story: Là người dùng, tôi muốn tải toàn bộ dữ liệu của mình, để lưu trữ hoặc chuyển sang công cụ khác.

AC01: Bấm "Xuất dữ liệu" → nhận email có link tải trong ≤ 24 giờ; link hiệu lực 7 ngày.

AC02: File gồm JSON đầy đủ và CSV cho task, time entry; dùng được cả khi workspace chỉ đọc (G12).

### US5.5 Xoá tài khoản

AC01: Cần nhập lại mật khẩu và gõ "XOÁ" để xác nhận `[giả định]`.

AC02: Xoá → đăng xuất mọi phiên, thu hồi kết nối lịch / tích hợp, huỷ gói (G12); dữ liệu bị xoá vĩnh viễn ≤ 30 ngày.

AC03: Chủ sở hữu duy nhất của workspace còn thành viên khác (1.1) → chặn, yêu cầu chuyển quyền sở hữu trước (G12).

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ hoàn tất đăng ký | Tài khoản tạo xong / lượt mở màn đăng ký | ≥ 60% |
| Thời gian đăng ký | Từ mở màn đăng ký đến vào bước 1 onboarding | ≤ 60 giây với OAuth (trung vị) |
| Tỉ lệ hoàn tất onboarding | Hoàn tất bước 5 / tài khoản mới | ≥ 70% |
| Tỉ lệ kết nối lịch ở onboarding | Kết nối thành công ở bước 2 / tài khoản mới | ≥ 50% |
| Kích hoạt ngày đầu | Hoàn tất Daily planning đầu tiên trong 24 giờ / tài khoản mới | ≥ 50% |
| Quay lại ngày 2 | Có hoạt động ngày thứ 2 / tài khoản mới | ≥ 40% |
| Tỉ lệ khoá do sai mật khẩu | Lượt khoá / lượt đăng nhập | Theo dõi (tăng đột biến = bị dò mật khẩu) |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Xác minh Google OAuth (G05) | Scope lịch cần Google xác minh app; chưa xong thì bước 2 onboarding hiện màn cảnh báo "app chưa xác minh" | Nộp xác minh sớm; trước khi xong, bước 2 cho bỏ qua rõ ràng |
| Gửi email | Mã xác minh, link đặt lại vào thư rác hoặc trễ | Dịch vụ gửi email có SPF / DKIM / DMARC; theo dõi tỉ lệ giao thư; "Gửi lại mã" |
| Danh sách mật khẩu bị lộ | Cần nguồn dữ liệu và cách tra không lộ mật khẩu | Tra theo tiền tố hash (k-anonymity) hoặc danh sách nội bộ `[giả định]` |
| Tuân thủ Nghị định 13/2023/NĐ-CP, GDPR | Đồng ý xử lý dữ liệu, quyền xuất / xoá, nơi lưu dữ liệu | Pháp chế xác nhận nội dung đồng ý và quy trình xoá trước ra mắt |
| Timezone thiết bị sai | Máy đặt sai múi giờ → "hôm nay" sai | Không tự đổi; banner hỏi người dùng |
| Đổi giờ bắt đầu ngày giữa ngày | Rollover, ritual chạy hai lần hoặc bỏ sót | Áp dụng từ ngày làm việc kế tiếp; job rollover idempotent theo người dùng + ngày (G06) |

# 10. Câu hỏi mở

- Giờ bắt đầu ngày (day_start_time) mặc định 04:00 hay 00:00?
- Dữ liệu người dùng Việt Nam có phải lưu tại Việt Nam không?
- Đăng nhập Google / Microsoft bằng email đã có tài khoản mật khẩu: tự liên kết hay bắt nhập mật khẩu để liên kết `[giả định: bắt nhập mật khẩu]`?
- Người đăng ký qua lời mời (1.1) có được tạo workspace riêng không `[giả định: không]`?
- Xoá tài khoản có cho khôi phục trong 30 ngày không `[giả định: không]`?
- Bản 1.0 hỗ trợ những ngôn ngữ nào (Tiếng Việt, English)?
- Bước 5 onboarding bắt buộc ít nhất 1 task hay cho bỏ qua?
