> **Mã:** PLN-PRD-G01 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g01-tai-khoan.md

# PRD Tài khoản, onboarding & cài đặt trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (tooltip theo ngữ cảnh "Task projections", "Your first keyboard shortcut"; danh sách nhóm trong trang Cài đặt); chỗ khác Sunsama có chủ đích được ghi rõ. Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md), gồm vòng 5–6 (Q32–Q46): bản 1.0 là app Windows cho một người dùng ([ADR-0005](../adr/0005-nen-tang-windows-truoc.md)), trợ lý AI chạy qua Claude Code CLI ([ADR-0004](../adr/0004-ai-qua-claude-code-cli.md), QC-12). Quy tắc dùng chung (QC-xx) xem [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md), thuật ngữ xem [`CONTEXT.md`](../../CONTEXT.md), tính năng để bản sau xem [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

G01 là cửa vào sản phẩm: đăng ký, đăng nhập, onboarding lần đầu và trang Cài đặt. Các giá trị G01 thu thập quyết định các nhóm khác chạy đúng:

- timezone và mốc đầu ngày xác định **ngày làm việc** cho mọi nhóm; G01 sở hữu quy tắc này (QC-01);
- **Lịch làm việc chung** (ngày làm việc trong tuần, giờ làm từng ngày) do G01 sở hữu (QC-02 mục 1–4): G04 tính sức chứa, G05 auto-schedule (1.1), G08 không mở ritual vào ngày nghỉ, G09 dựng cột ngày và giờ gửi recap. **Khung giờ channel** do G02 sở hữu (QC-02 mục 5–9); G01 chỉ tham chiếu, không đặc tả lại;
- giờ plan ngày xác định lúc nhắc Daily planning (G08).

Bản 1.0 là **app Windows (Flutter)** cho **một người dùng**, có tài khoản và dữ liệu trên cloud (Q35, Q45, [ADR-0005](../adr/0005-nen-tang-windows-truoc.md)); web và macOS từ 1.1, iOS / Android từ 1.2. Bản 1.0 miễn phí, gắn nhãn Beta: đăng ký tạo workspace cá nhân, **không** tạo trial. Trial 14 ngày và thanh toán bắt đầu từ bản 1.1 (G12, [ADR-0002](../adr/0002-thanh-toan-chuyen-sang-1-1.md)); tài khoản có từ 1.0 nhận trial 14 ngày tính từ ngày phát hành 1.1. Các phần nhiều thành viên (lời mời, xoá tài khoản khi ở workspace nhiều người) là **bản sau** — xem [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md). G01 đặc tả khung trang Cài đặt và các nhóm Chung, Hiển thị, Lịch làm việc, Phím tắt, Hồ sơ, Tài khoản; nhóm **Trợ lý AI** chỉ là điểm vào trong khung trang, hành vi do G10 sở hữu (QC-12); các nhóm cài đặt khác do nhóm sở hữu đặc tả.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Đăng ký nhiều trường, nhiều bước | Người dùng bỏ ngang trước khi thấy giá trị sản phẩm |
| Sau đăng ký app trống, không biết bắt đầu từ đâu | Không quay lại ngày thứ hai |
| Timezone, lịch làm việc, mốc đầu ngày sai | "Hôm nay", projection, lời nhắc ritual lệch giờ; người dùng mất niềm tin |
| Cài đặt phải bấm Lưu, không thấy tác dụng ngay | Quên lưu, tưởng cài đặt không chạy |
| Tài khoản bị dò mật khẩu, lộ việc email đã đăng ký hay chưa | Rủi ro chiếm tài khoản, vi phạm quy định bảo vệ dữ liệu cá nhân |
| Không tự xuất hoặc xoá được dữ liệu | Không đáp ứng Nghị định 13/2023/NĐ-CP, GDPR; phải qua bộ phận hỗ trợ |

## 1.3 Mục tiêu

- Đăng ký xong trong ≤ 60 giây với Google / Microsoft, ≤ 2 phút với email + mật khẩu `[giả định]`.
- Hết onboarding, người dùng có: timezone đúng, lịch làm việc, lịch đã kết nối (nếu chọn), ít nhất 1 task hôm nay, và đang ở Daily planning đầu tiên.
- Mọi cài đặt lưu và áp dụng ngay, không có nút Lưu; thiết bị khác thấy thay đổi ≤ 5 giây.
- Người dùng tự đổi mật khẩu, email, đăng xuất mọi phiên, xuất dữ liệu và xoá tài khoản, không cần liên hệ hỗ trợ.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng mới, cá nhân (Linh PM, Minh designer / dev, Hà freelancer) | Đăng ký nhanh bằng tài khoản Google / Microsoft sẵn có; có ngay một ngày được lên kế hoạch |
| Người dùng thành thạo | Chỉnh phím tắt, mốc đầu ngày, lịch làm việc, ngưỡng khối lượng theo cách làm việc riêng |
| Người được mời vào workspace (bản sau — xem `docs/02-tinh-nang-ban-sau.md`) | Đăng ký / đăng nhập xong vào thẳng workspace của nhóm (G12) |
| Người quan tâm bảo mật, quyền riêng tư | Mật khẩu an toàn, biết khi có đăng nhập lạ, tự xuất và xoá dữ liệu |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: **app Windows (Flutter)**, một người dùng, tài khoản và dữ liệu trên cloud (Q35, Q45, ADR-0005). Web và macOS từ bản 1.1, iOS / Android từ bản 1.2, dùng cùng đặc tả. Tech stack, cách lưu phiên trên máy: tech chốt — `docs/tech/`.
- Đăng ký bằng Google, Microsoft, email + mật khẩu (xác minh bằng mã 6 số). Trên app desktop, đăng nhập Google / Microsoft mở **trình duyệt hệ thống** tới trang của nhà cung cấp, xong thì tự quay lại app.
- Đăng nhập, đăng xuất, quên / đặt lại mật khẩu, khoá tạm khi nhập sai nhiều lần, quản lý phiên đăng nhập trên thiết bị Windows.
- Onboarding 5 bước, Daily planning đầu tiên có hướng dẫn (G08), tooltip theo ngữ cảnh hiện 1 lần.
- Trang Cài đặt: khung trang (danh sách nhóm, điều hướng) và nội dung nhóm Chung, Hiển thị, Lịch làm việc, Phím tắt, Hồ sơ, Tài khoản; điểm vào nhóm **Trợ lý AI** (nội dung do G10 đặc tả, QC-12).
- Ngày làm việc (QC-01) và Lịch làm việc chung (QC-02 mục 1–4): G01 sở hữu cài đặt và quy tắc. Khung giờ channel (QC-02 mục 5–9) thuộc G02.
- Tài khoản: đổi mật khẩu, đổi email chính (có link "Không phải tôi"), đăng xuất mọi phiên, xuất dữ liệu, xoá tài khoản, rút lại và xin lại đồng ý xử lý dữ liệu.

## 3.2 Ngoài phạm vi

- Xác thực 2 lớp (2FA TOTP) → bản 1.1 (G01).
- Nhận lời mời workspace → bản sau (Q35, xem `docs/02-tinh-nang-ban-sau.md`): phần đăng ký / đăng nhập ở G01, lời mời và thành viên ở G12.
- Trial, thanh toán, Billing → G12, bản 1.1. Thành viên, Privacy → G12, bản sau (Q35, Q37). Cài đặt Thông báo → G12, bản 1.0.
- Context & channel, khung giờ channel → G02. Ritual → G08 (Weekly G09). Timebox → G05. Focus → G07. Trợ lý AI (bật / tắt, phát hiện Claude Code, MCP local, quyền của AI, màn đồng ý), Beta → G10, QC-12; G01 chỉ đặt lối vào. Tích hợp → G05 (lịch) / G11.
- Ngày lễ trong Lịch làm việc → chưa hỗ trợ ở 1.0 (QC-02 mục 4).
- Đăng nhập bằng Apple, SSO doanh nghiệp (SAML) → chưa có kế hoạch `[giả định]`.

# 4. Nguyên tắc sản phẩm

## 4.1 Thấy giá trị trước, hỏi sau

Đăng ký chỉ hỏi email và mật khẩu (hoặc một nút Google / Microsoft). Mọi trường onboarding có giá trị điền sẵn; bước kết nối lịch bỏ qua được.

## 4.2 Thời gian phải đúng

Timezone lấy từ thiết bị; lệch với cài đặt thì hỏi, không tự đổi. Mọi tính toán "hôm nay" dùng ngày làm việc theo QC-01.

## 4.3 Lưu ngay, áp dụng ngay

Đổi cài đặt nào lưu cài đặt đó ngay, giao diện đổi theo ngay, không phải khởi động lại app.

## 4.4 Không lộ, không giữ thừa

Không cho người ngoài biết một email đã đăng ký hay chưa. Không lưu mật khẩu ở dạng đọc được. Người dùng tự xuất và xoá dữ liệu của mình.

# 5. Quy tắc tài khoản và cài đặt mặc định

| **Mục** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Mã xác minh email | 6 số, hết hạn 10 phút, dùng 1 lần; gửi lại sau 60 giây, ≤ 5 lần / giờ `[giả định]` | — | Nhập sai 5 lần → mã vô hiệu `[giả định]` |
| Mật khẩu | ≥ 10 ký tự (tối đa 128 `[giả định]`), không nằm trong danh sách mật khẩu bị lộ | — | Lưu bằng Argon2id |
| Sai mật khẩu | 5 lần trong 15 phút → khoá đăng nhập bằng mật khẩu 15 phút, khoá theo cặp tài khoản + IP | — | Luôn trả một thông báo chung; email cảnh báo ≤ 1 lần / 24 giờ |
| Link đặt lại mật khẩu | Hiệu lực 30 phút, dùng 1 lần | — | |
| Phiên đăng nhập | Access token 15 phút; refresh token 30 ngày, xoay vòng mỗi lần dùng; lưu an toàn trên thiết bị Windows (cách lưu: tech chốt — `docs/tech/`) | — | Dùng lại refresh token cũ → thu hồi cả chuỗi |
| Xuất dữ liệu | JSON / CSV, sẵn sàng ≤ 24 giờ, link tải 7 ngày; gồm dữ liệu mình sở hữu (+ task được giao cho mình — bản sau, Q35) | — | Dùng được cả khi workspace chỉ đọc (1.1, QC-09) |
| Xoá tài khoản | Xoá vĩnh viễn ≤ 30 ngày; không xoá được khi đang có yêu cầu xuất dữ liệu đang xử lý | — | Thu hồi mọi token (phiên, lịch, tích hợp). Ngoại lệ lưu giữ: hoá đơn, chứng từ 10 năm (G12); nhật ký bảo mật 1 năm, ẩn danh |
| Đổi email: "Không phải tôi" | Link trong thư gửi email cũ, hiệu lực 72 giờ | — | Huỷ việc đổi email, đăng xuất mọi thiết bị, gửi link đặt lại mật khẩu tới email cũ |
| Tài khoản chưa xác minh | Tự xoá sau 24 giờ | — | Đăng nhập Google / Microsoft có email đã xác minh thay thế bản đăng ký chưa xác minh |
| Ngôn ngữ | Tiếng Việt, English `[giả định]` | Theo ngôn ngữ của Windows | |
| Timezone | Danh sách IANA | Theo thiết bị lúc đăng ký | Lệch thiết bị → cảnh báo |
| Ngày đầu tuần | Thứ Hai / Chủ Nhật `[giả định]` | Thứ Hai | |
| Mốc đầu ngày | 00:00–06:00 | 04:00 | Ngày làm việc theo QC-01; đổi có hiệu lực từ ngày làm việc kế tiếp |
| Ngưỡng khối lượng ngày | 1–24 giờ `[giả định]` | 8 giờ | Dùng ở cảnh báo quá tải (G04) |
| Tính planned là actual | Bật / tắt | Bật | Áp khi hoàn thành task (G02); chỉ là giá trị hiển thị, chốt trên task lúc hoàn thành (QC-07 mục 4) |
| Tự sắp task | Bật / tắt | Bật | G04 |
| Vị trí task mới · task rollover | Đầu / cuối | Đầu · Đầu | G02, G06 |
| Giữ priority khi rollover | Không giữ / giữ các mức được chọn (tập mức) | Không giữ | G06 |
| Giao diện | Sáng / tối / theo hệ thống | Theo hệ thống `[giả định]` | Phím Shift+L đổi nhanh (G04) |
| Màu sự kiện trên lịch | Theo channel / theo lịch `[giả định]` | Theo channel | |
| Ẩn task đã xong | Bật / tắt | Tắt | |
| Hiệu ứng chúc mừng (pháo giấy) | Bật / tắt | Bật `[giả định]` | Khi hoàn thành task |
| Phím tắt | Bật / tắt | Bật | Phím toàn cục Ctrl+Shift+A, Ctrl+Shift+Space trên app desktop, từ 1.1 (C20) |
| Lịch làm việc chung (nhập ở onboarding) | Chọn các ngày làm việc trong tuần; giờ bắt đầu < giờ kết thúc, theo từng ngày | Thứ Hai–Thứ Sáu, 09:00–17:00 `[giả định giờ]` | QC-02 mục 1–4; cho thêm Thứ Bảy hoặc ngày bất kỳ; chỉnh ở nhóm Lịch làm việc (G01). Khung giờ riêng của từng channel: G02 (QC-02 mục 5) |
| Giờ plan ngày (nhập ở onboarding) | 00:00–23:55 | 09:00 | Nhắc Daily planning (G08) |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Nhóm cài đặt do nhóm khác sở hữu (Ritual, Timebox, Focus, Trợ lý AI, Beta, Thông báo, Context & channel, Tích hợp; bản sau: Thành viên, Privacy; 1.1: Billing) chỉ có lối vào trong khung trang Cài đặt; nội dung đặc tả ở nhóm sở hữu.
- Nhóm **Trợ lý AI** (G10 sở hữu hành vi, QC-12) gồm: bật / tắt trợ lý (mặc định tắt); trạng thái phát hiện Claude Code (đã cài, đã đăng nhập, phiên bản hỗ trợ; chưa có thì hiện hướng dẫn cài); công tắc "Cho phép AI hoàn thành và xoá task" (mặc định tắt); công tắc cho AI đọc dữ liệu tích hợp (mặc định tắt). Bật lần đầu hiện màn đồng ý gọn của G10 (QC-12 mục 7).
- Xung đột cài đặt giữa các thiết bị xử lý theo từng trường (QC-08 mục 3); người dùng được báo khi giá trị họ vừa đổi bị ghi đè.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Đăng ký | Cài và mở app Windows; bấm "Tiếp tục với Google / Microsoft" (mở trình duyệt hệ thống, xong quay lại app) hoặc nhập email + mật khẩu, nhập mã 6 số | Tài khoản, workspace cá nhân, context `work` / `personal`, channel hệ thống "Chưa phân loại"; 1.0 không có trial (Beta miễn phí), từ 1.1 trial 14 ngày (G12) |
| 2 | Onboarding | 5 bước: ngôn ngữ + timezone → kết nối lịch → công cụ công việc → lịch làm việc + giờ plan → 3 task đầu | Cài đặt cơ bản đúng, có task hôm nay |
| 3 | Ngày đầu tiên | Daily planning có hướng dẫn (G08); tooltip giải thích projection, phím tắt khi gặp lần đầu | Ngày đầu tiên được lên kế hoạch |
| 4 | Dùng hằng ngày | Đăng nhập một lần trên máy Windows, phiên tự gia hạn 30 ngày | Không phải đăng nhập lại mỗi ngày |
| 5 | Điều chỉnh | Mở Cài đặt, đổi giá trị, thấy tác dụng ngay | App khớp cách làm việc |
| 6 | Quản lý tài khoản | Đổi mật khẩu / email, đăng xuất mọi phiên, xuất dữ liệu, xoá tài khoản | Người dùng kiểm soát tài khoản và dữ liệu |

Bước 3 dùng Daily planning của G08; PRD này chỉ đặc tả phần dẫn từ onboarding sang và tooltip.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Đăng ký

### US1.1 Đăng ký bằng email và mật khẩu

User Story: Là người dùng mới, tôi muốn đăng ký chỉ bằng email và mật khẩu, để bắt đầu dùng ngay.

AC01: Màn đăng ký có email, mật khẩu, ô đồng ý Điều khoản sử dụng và Chính sách quyền riêng tư (không tick sẵn).

AC02: Mật khẩu < 10 ký tự hoặc nằm trong danh sách bị lộ → báo lỗi ngay dưới ô, không gửi mã.

AC03: Hợp lệ → gửi mã 6 số tới email, mở màn nhập mã; mã hết hạn sau 10 phút; dán mã đủ 6 số tự gửi.

AC04: Nhập đúng mã → tạo tài khoản, workspace cá nhân (người dùng là chủ sở hữu), 2 context `work`, `personal`, channel hệ thống "Chưa phân loại" (không xoá được, là channel mặc định — G02), mở onboarding. Bản 1.0 không tạo trial (Beta miễn phí); từ 1.1 bắt đầu trial 14 ngày, mỗi email chỉ một lần (G12).

AC05: "Gửi lại mã" bật sau 60 giây `[giả định]`.

### US1.2 Đăng ký bằng Google hoặc Microsoft

AC01: Nút "Tiếp tục với Google" và "Tiếp tục với Microsoft" có ở cả màn đăng ký và đăng nhập.

AC02: Tài khoản Google / Microsoft gắn với tài khoản app theo `provider + sub`, không theo email. Đã liên kết → đăng nhập luôn, kể cả khi email bên nhà cung cấp đã đổi.

AC03: Huỷ ở trang Google / Microsoft → quay về màn đăng nhập, có thông báo, không tạo gì.

AC07: Trên app Windows, bấm nút mở **trình duyệt hệ thống** tới trang Google / Microsoft (không đăng nhập trong cửa sổ nhúng của app); app hiện trạng thái "Đang chờ đăng nhập trong trình duyệt" kèm nút "Huỷ". Xong trên trình duyệt → tự quay lại app và đăng nhập. Đóng trình duyệt hoặc quá thời gian chờ `[giả định: 5 phút]` → app về màn đăng nhập, có thông báo thử lại. Cách trình duyệt trả kết quả về app: tech chốt — `docs/tech/`.

AC04: Email chưa có tài khoản → hỏi đồng ý Điều khoản một lần rồi tạo tài khoản như US1.1 AC04.

AC05: Email đã có tài khoản **chưa xác minh** (đăng ký email dở) → bản đăng ký chưa xác minh bị thay thế, mật khẩu cũ bị huỷ; tạo tài khoản mới như AC04. Kẻ gian đăng ký trước bằng email người khác không giữ được tài khoản.

AC06: Email đã có tài khoản **đã xác minh** dùng mật khẩu, chưa liên kết phương thức này → phải nhập mật khẩu tài khoản đó để liên kết; không tự liên kết.

### US1.3 Email đã có tài khoản

AC01: Đăng ký bằng email đã có → giao diện giống hệt trường hợp email mới (vẫn sang màn nhập mã); hệ thống gửi tới email đó thư "Bạn đã có tài khoản" kèm link đăng nhập và quên mật khẩu.

AC02: Màn nhập mã luôn có link "Đã có tài khoản? Đăng nhập · Quên mật khẩu".

## UC2. Onboarding lần đầu

### US2.1 Thiết lập cơ bản trong 5 bước

User Story: Là người dùng mới, tôi muốn được dẫn qua vài bước ngắn có sẵn giá trị gợi ý, để app đúng giờ, đúng lịch của tôi ngay từ ngày đầu.

AC01: Bước 1 ngôn ngữ + timezone, điền sẵn theo cài đặt của Windows.

AC02: Bước 2 kết nối Google Calendar hoặc Outlook (G05); có "Bỏ qua"; kết nối lỗi vẫn đi tiếp được.

AC03: Bước 3 chọn công cụ công việc đang dùng (chọn nhiều); 1.0 chỉ lưu lựa chọn để gợi ý tích hợp khi phát hành (G11).

AC04: Bước 4 lịch làm việc (mặc định Thứ Hai–Thứ Sáu, 09:00–17:00 `[giả định giờ]`, thêm được Thứ Bảy hoặc ngày khác) và giờ plan ngày (mặc định 09:00).

AC05: Bước 5 có 3 ô nhập task cho hôm nay; cần ít nhất 1 task để hoàn tất `[giả định]`.

AC06: Có nút ← quay lại; đóng app giữa chừng → mở lại tiếp tục đúng bước dở.

### US2.2 Daily planning đầu tiên có hướng dẫn

AC01: Hoàn tất bước 5 → mở Daily planning của hôm nay (G08) ở chế độ có hướng dẫn, các task vừa tạo đã nằm trong danh sách.

AC02: Onboarding chỉ hiện một lần cho mỗi tài khoản.

### US2.3 Tooltip theo ngữ cảnh

AC01: Lần đầu gặp một khái niệm (ví dụ projection — tooltip "Task projections"; lần đầu dùng phím tắt — "Your first keyboard shortcut", như Sunsama) hiện tooltip giải thích ngắn.

AC02: Mỗi tooltip hiện tối đa 1 lần cho mỗi tài khoản, trên mọi thiết bị.

## UC3. Đăng nhập và phiên

### US3.1 Đăng nhập

AC01: Đăng nhập bằng email + mật khẩu hoặc Google / Microsoft; xong mở Home (hoặc bước onboarding còn dở).

AC02: Sai email hoặc mật khẩu, hoặc đang bị khoá tạm → luôn một thông báo chung, không nói sai trường nào, không cho biết email có tài khoản hay không.

AC03: Phiên tự gia hạn; không dùng app quá 30 ngày mới phải đăng nhập lại.

AC04: Bị đăng xuất từ xa (đổi mật khẩu, "Đăng xuất mọi thiết bị khác" trên thiết bị khác) → thay đổi chưa đồng bộ trên máy Windows được giữ lại (mã hoá, gắn với tài khoản) và gửi lên khi đăng nhập lại đúng tài khoản (QC-08 mục 6).

AC05: Chủ động đăng xuất trên máy Windows khi còn thay đổi chưa đồng bộ → cảnh báo trước; người dùng xác nhận thì mới xoá dữ liệu offline của app trên máy đó.

### US3.2 Khoá tạm khi nhập sai nhiều lần

AC01: Sai mật khẩu 5 lần trong 15 phút từ cùng một IP → khoá đăng nhập bằng mật khẩu 15 phút cho cặp tài khoản + IP đó (IP khác vẫn đăng nhập được), gửi email cảnh báo cho chủ tài khoản tối đa 1 lần / 24 giờ.

AC02: Trong thời gian khoá vẫn dùng được "Quên mật khẩu"; đặt lại thành công thì mở khoá.

### US3.3 Quên mật khẩu

AC01: Nhập email → luôn hiện "Nếu email có tài khoản, chúng tôi đã gửi link…", kể cả email chưa đăng ký.

AC02: Link hiệu lực 30 phút, dùng 1 lần; đặt lại xong đăng nhập luôn, các thiết bị khác bị đăng xuất `[giả định]`.

### US3.4 Đăng nhập từ lời mời workspace (bản sau — xem `docs/02-tinh-nang-ban-sau.md`, Q35)

AC01: Mở link mời → đăng ký hoặc đăng nhập với email được mời điền sẵn → vào thẳng workspace mời (G12). Đăng ký qua lời mời không tạo workspace cá nhân (mỗi người một workspace; nhiều workspace để bản sau).

AC02: Người đã có workspace nhận lời mời → xử lý theo G12 (workspace một người, chưa trả phí: chuyển task cá nhân sang workspace mới; đang trả phí hoặc có thành viên khác: chặn).

## UC4. Cài đặt

### US4.1 Mở và đổi cài đặt

User Story: Là người dùng, tôi muốn đổi một cài đặt và thấy tác dụng ngay, để không phải nhớ bấm Lưu.

AC01: Mở Cài đặt từ menu tài khoản; cột trái liệt kê các nhóm, cột phải là nội dung nhóm.

AC02: Đổi giá trị nào lưu ngay giá trị đó, hiện dấu ✓ "Đã lưu" cạnh trường; giao diện áp dụng ngay.

AC03: Nhóm do nhóm tính năng khác sở hữu mở trang con của nhóm đó; nhóm chưa phát hành ở bản hiện tại không hiện.

AC04: Cùng một trường bị đổi trên hai thiết bị → bản server nhận sau thắng; thiết bị có giá trị bị ghi đè hiện thông báo kèm giá trị mới. Các trường khác không bị ảnh hưởng.

### US4.2 Timezone và mốc đầu ngày

AC01: Mở app ở timezone khác cài đặt → banner duy nhất (của G01) hỏi "Đổi sang {timezone thiết bị}" hoặc "Giữ {timezone}"; không tự đổi. Không nhóm nào hiện banner timezone riêng.

AC02: Đổi mốc đầu ngày hoặc timezone có hiệu lực từ ngày làm việc kế tiếp, có ghi chú dưới trường; ngày hiện tại kết thúc theo cài đặt cũ (QC-01 mục 3).

AC03: Đổi timezone không đổi ngày dự định của task; timebox giữ thời điểm tuyệt đối; timebox rơi khác ngày dự định thì hiện cờ "Lệch ngày", hệ thống không tự sửa (QC-01 mục 4).

### US4.3 Hiển thị và phím tắt

AC01: Đổi giao diện sáng / tối / hệ thống đổi ngay, không khởi động lại app.

AC02: Tắt phím tắt → mọi phím tắt một ký tự ngừng hoạt động; Ctrl/Cmd+K vẫn mở command menu `[giả định]`.

AC03: Trang Phím tắt liệt kê đủ phím theo nhóm, giống bảng mở bằng phím ? (G04).

### US4.4 Lịch làm việc

User Story: Là người làm việc Thứ Hai–Thứ Bảy, tôi muốn chọn ngày nào trong tuần là ngày làm việc và giờ làm từng ngày, để app không đẩy việc hay nhắc ritual vào ngày nghỉ.

AC01: Cài đặt → Lịch làm việc: bật / tắt từng ngày trong tuần, mỗi ngày bật có giờ bắt đầu và kết thúc. Mặc định Thứ Hai–Thứ Sáu, 09:00–17:00 `[giả định giờ]`.

AC02: Cần ít nhất 1 ngày làm việc `[giả định]`; giờ kết thúc phải sau giờ bắt đầu.

AC03: "Ngày làm việc kế tiếp" bỏ qua ngày nghỉ: shutdown chọn "Ngày mai" (G08) và phím D (G04) đưa task tới ngày làm việc kế tiếp theo **lịch làm việc của task** — khung giờ channel của task nếu có, ngược lại lịch chung (QC-02 mục 2, 6).

AC04: Lịch làm việc chung được G04 dùng để tính sức chứa (cùng các khung giờ channel, QC-02 mục 7), G05 để auto-schedule (1.1), G08 để không tự mở / nhắc ritual vào ngày nghỉ, G09 để dựng cột ngày và gửi recap tuần tại mốc đầu ngày của ngày sau ngày làm việc cuối tuần. Ritual và cột ngày G09 luôn theo lịch chung (QC-02 mục 8).

AC05: Ngày lễ chưa hỗ trợ ở 1.0; người dùng bỏ qua ritual bằng "Bỏ qua hôm nay" (G08).

AC06: Trang Lịch làm việc chỉ chỉnh **lịch chung**. Khung giờ riêng của từng channel (ví dụ `#Cá nhân` T2–CN 19:00–22:00) đặt trong cài đặt channel do G02 sở hữu (QC-02 mục 5); trang có ghi chú và link "Đặt khung giờ cho channel" mở cài đặt channel của G02.

### US4.5 Nhóm cài đặt Trợ lý AI (điểm vào)

User Story: Là người dùng, tôi muốn tìm thấy mọi cài đặt về trợ lý AI ở một chỗ trong Cài đặt, để bật / tắt trợ lý và giới hạn những gì AI được làm.

AC01: Khung trang Cài đặt có nhóm "Trợ lý AI". G01 chỉ đặt lối vào; nội dung, hành vi và thông báo do G10 đặc tả theo QC-12.

AC02: Nhóm gồm: bật / tắt trợ lý (mặc định tắt); trạng thái phát hiện Claude Code (đã cài, đã đăng nhập, phiên bản hỗ trợ; chưa có → hướng dẫn "Cài Claude Code để bật trợ lý AI", QC-12 mục 2); công tắc "Cho phép AI hoàn thành và xoá task" (mặc định tắt, QC-12 mục 4); công tắc cho AI đọc dữ liệu tích hợp (mặc định tắt, QC-12 mục 6).

AC03: Bật trợ lý lần đầu → màn đồng ý gọn của G10 nói rõ dữ liệu nào được đưa cho Claude Code; app lưu thời điểm đồng ý (QC-12 mục 7). Đồng ý này tách khỏi đồng ý xử lý dữ liệu của tài khoản (US5.6).

AC04: Trợ lý AI không có hạn mức theo gói (QC-10, QC-12 mục 8); nhóm không hiện số lượt dùng.

## UC5. Hồ sơ và tài khoản

### US5.1 Sửa hồ sơ

AC01: Sửa tên hiển thị (1–80 ký tự `[giả định]`) và ảnh đại diện (JPG / PNG ≤ 2 MB `[giả định]`); lưu ngay.

### US5.2 Đổi mật khẩu, đổi email

AC01: Đổi mật khẩu và đổi email đều cần xác nhận lại: nhập mật khẩu hiện tại, hoặc đăng nhập lại qua Google / Microsoft đã liên kết.

AC02: Đổi email → gửi mã 6 số tới email mới; chỉ đổi khi nhập đúng mã; email cũ nhận thư thông báo có link "Không phải tôi".

AC03: Đổi mật khẩu → các thiết bị khác bị đăng xuất `[giả định]`.

AC04: Bấm "Không phải tôi" trong 72 giờ → huỷ việc đổi email (email cũ trở lại là email đăng nhập), đăng xuất mọi thiết bị, gửi link đặt lại mật khẩu tới **email cũ**. Quá 72 giờ link hết hiệu lực.

### US5.3 Đăng xuất mọi phiên

AC01: Nút "Đăng xuất mọi thiết bị khác"; thiết bị khác về màn đăng nhập ≤ 1 phút `[giả định]`.

### US5.4 Xuất dữ liệu

User Story: Là người dùng, tôi muốn tải toàn bộ dữ liệu của mình, để lưu trữ hoặc chuyển sang công cụ khác.

AC01: Bấm "Xuất dữ liệu" → nhận email có link tải trong ≤ 24 giờ; link hiệu lực 7 ngày.

AC02: File gồm JSON đầy đủ và CSV cho task, bản ghi thời gian; dùng được cả khi workspace chỉ đọc (1.1, QC-09).

AC03: Phạm vi xuất = dữ liệu mình sở hữu; thêm task được giao cho mình khi có giao task (bản sau, Q35).

### US5.5 Xoá tài khoản

AC01: Cần xác nhận lại (mật khẩu hoặc Google / Microsoft) và gõ "XOÁ" để xác nhận `[giả định]`.

AC02: Xoá → đăng xuất mọi phiên, thu hồi kết nối lịch / tích hợp, xoá workspace cá nhân (từ 1.1: huỷ gói, G12); dữ liệu bị xoá vĩnh viễn ≤ 30 ngày. Giữ lại có cơ sở pháp lý: hoá đơn, chứng từ 10 năm (G12); nhật ký bảo mật 1 năm, ẩn danh.

AC03: (Bản sau — workspace nhiều người, xem `docs/02-tinh-nang-ban-sau.md`) Không phải chủ sở hữu → trước khi xoá, người dùng rời workspace theo G12 (task được giao chưa xong trả về người giao, giảm ghế); gói của nhóm **không** bị huỷ.

AC04: (Bản sau — workspace nhiều người) Chủ sở hữu của workspace còn thành viên khác → chặn, yêu cầu chuyển quyền sở hữu hoặc xoá workspace trước (G12). Chủ sở hữu workspace chỉ có mình (mọi tài khoản ở 1.0 và 1.1) → xoá tài khoản kèm xoá workspace, huỷ gói nếu có (G12).

AC05: Đang có yêu cầu xuất dữ liệu đang xử lý → không cho xoá tới khi bản xuất sẵn sàng hoặc lỗi.

### US5.6 Rút lại đồng ý và xin đồng ý lại

User Story: Là người dùng, tôi muốn xem mình đã đồng ý gì, rút lại khi muốn, và được hỏi lại khi điều khoản thay đổi, để kiểm soát việc xử lý dữ liệu cá nhân (Nghị định 13/2023/NĐ-CP).

AC01: Cài đặt → Tài khoản hiện phiên bản Điều khoản / Chính sách quyền riêng tư đã đồng ý và thời điểm đồng ý.

AC02: Điều khoản hoặc Chính sách có phiên bản mới cần đồng ý lại → lần mở app kế tiếp hiện màn đồng ý phiên bản mới; chưa đồng ý thì chỉ dùng được xuất dữ liệu, xoá tài khoản, đăng xuất `[giả định]`.

AC03: "Rút lại đồng ý xử lý dữ liệu" → giải thích hậu quả: không thể tiếp tục cung cấp dịch vụ, tài khoản chuyển sang luồng xoá (US5.5) `[giả định — chờ pháp chế]`.

AC04: Đồng ý dùng Trợ lý AI là đồng ý riêng, qua màn gọn của G10 khi bật trợ lý lần đầu (QC-12 mục 7); xem và rút lại ở Cài đặt → Trợ lý AI (G10). Đồng ý nhận email Product updates rút lại ở Cài đặt → Thông báo (G12). Cả hai không ảnh hưởng tài khoản.

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
| Tuân thủ Nghị định 13/2023/NĐ-CP, GDPR | Đồng ý xử lý dữ liệu, quyền xuất / xoá, rút lại đồng ý, nơi lưu dữ liệu | Pháp chế xác nhận nội dung đồng ý, luồng rút lại đồng ý và quy trình xoá trước ra mắt |
| Chuyển dữ liệu ra nước ngoài | 1.0 dùng máy chủ khu vực châu Á, không lưu tại Việt Nam | Lập hồ sơ đánh giá tác động chuyển dữ liệu cá nhân ra nước ngoài (NĐ 13/2023); pháp chế xác nhận trước phát hành |
| Timezone thiết bị sai | Máy đặt sai múi giờ → "hôm nay" sai | Không tự đổi; banner MSG-23 hỏi người dùng |
| Đổi mốc đầu ngày / timezone giữa ngày | Rollover, ritual chạy hai lần hoặc bỏ sót | Có hiệu lực từ ngày làm việc kế tiếp; không chạy lại rollover cho ngày đã có lượt xong (QC-01 mục 3) |
| Chiếm trước tài khoản | Kẻ gian đăng ký email nạn nhân rồi bỏ đó, hoặc đổi email sang địa chỉ của mình | Tài khoản chưa xác minh tự xoá sau 24 giờ và bị OAuth có email đã xác minh thay thế; link "Không phải tôi" 72 giờ gửi tới email cũ |
| Đăng nhập Google / Microsoft trên app desktop | Trình duyệt hệ thống không trả được kết quả về app (bị chặn, người dùng đóng nhầm), người dùng kẹt ở màn chờ | Màn chờ có nút "Huỷ" và hết thời gian chờ; luôn còn đường email + mật khẩu; cách trả kết quả về app: tech chốt — `docs/tech/` |
| Link trong email khi 1.0 chưa có web | Link đặt lại mật khẩu, "Không phải tôi", tải bản xuất mở trong trình duyệt, nhưng 1.0 chỉ có app Windows | Cần trang web tối giản cho các link này hoặc mở app qua deep link — câu hỏi mở, tech chốt |

# 10. Câu hỏi mở

- Đã chốt 04/11/2026: mốc đầu ngày mặc định 04:00, chỉnh trong 00:00–06:00; đổi mốc hoặc timezone có hiệu lực từ ngày làm việc kế tiếp (Q2, Q3; QC-01).
- Đã chốt 04/11/2026 một phần: bản 1.0 không bắt buộc lưu tại Việt Nam, dùng máy chủ khu vực châu Á, kèm hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (Q29). **Còn mở:** pháp chế xác nhận trước khi phát hành.
- Đã chốt 04/11/2026: đăng nhập Google / Microsoft bằng email của tài khoản đã xác minh thì phải nhập mật khẩu để liên kết; tài khoản chưa xác minh bị thay thế và mật khẩu cũ bị huỷ; phương thức gắn theo `provider + sub` (B1, B2).
- Đã chốt 04/11/2026: người đăng ký qua lời mời (bản sau) không tạo workspace riêng; mỗi người một workspace, nhiều workspace để bản sau (Q23).
- Đã chốt 04/11/2026: bản 1.0 là app Windows (Flutter), có tài khoản và dữ liệu trên cloud; 1.1 thêm web + macOS, 1.2 thêm iOS / Android; tech stack và API chốt riêng ở `docs/tech/` (Q45, ADR-0005).
- Đã chốt 04/11/2026: bản 1 chỉ cho một người dùng; lời mời, xoá tài khoản khi ở workspace nhiều người, chuyển quyền sở hữu để bản sau, gom ở `docs/02-tinh-nang-ban-sau.md` (Q35, Q37).
- Đã chốt 04/11/2026: trợ lý AI chạy bằng Claude Code CLI, có từ 1.0, mặc định tắt, màn đồng ý gọn; G01 chỉ đặt nhóm cài đặt "Trợ lý AI", hành vi do G10 sở hữu (Q46, QC-12, ADR-0004).
- Đã chốt 04/11/2026: lịch làm việc chung do G01 sở hữu; khung giờ channel do G02 sở hữu (Q38 / Q38a, QC-02).
- (Mới) Bản 1.0 chỉ có app Windows: link đặt lại mật khẩu, "Không phải tôi", tải bản xuất dữ liệu trong email mở ở đâu — trang web tối giản hay mở app qua deep link? Cần tech chốt (`docs/tech/`).
- (Mới) Phím toàn cục Ctrl+Shift+A, Ctrl+Shift+Space đang để 1.1 (C20) khi 1.0 đã là app desktop: giữ 1.1 hay đưa lên 1.0?
- Xoá tài khoản có cho khôi phục trong 30 ngày không `[giả định: không]`?
- Bản 1.0 hỗ trợ những ngôn ngữ nào (Tiếng Việt, English)?
- Bước 5 onboarding bắt buộc ít nhất 1 task hay cho bỏ qua?
- (Mới) Rút lại đồng ý xử lý dữ liệu bắt buộc thì tài khoản chuyển sang xoá, hay còn trạng thái tạm ngừng xử lý? Chưa đồng ý phiên bản Điều khoản mới thì được dùng những gì? Cần pháp chế xác nhận (C5).
- (Mới) Đổi Lịch làm việc có hiệu lực ngay hay từ ngày làm việc kế tiếp `[giả định: từ ngày làm việc kế tiếp]`? Có cần ít nhất 1 ngày làm việc không `[giả định: có]`?
