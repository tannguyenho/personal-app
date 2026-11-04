> **Mã:** PLN-PRD-G07 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g07-focus-timer.md

# PRD Focus & theo dõi thời gian trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Phiên bản: timer, thời gian thực tế, Focus mode ở **1.0**; Pomodoro, màn nghỉ (Take a break) và nhắc nghỉ desktop ở **1.1**; Focus Bar desktop ở **1.2**. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: nút ▶ và "Stop timer · Space", actual đếm màu xanh (0:00:03), badge ở mục Focus trên sidebar, toast "Must focus on today" khi bật timer cho task không thuộc hôm nay (timer vẫn chạy), block thời gian thực tế trên lịch ("2:01 – 2:02"), Focus mode có tab Focus / Pomodoro, Pomodoro "Remaining 0:25:00" với Session 0:25 chỉnh ▲▼, màn "Break" đếm ngược 0:05:00 có PAUSE, END BREAK. Chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Lên kế hoạch chỉ có ích khi biết thực tế đã dùng thời gian thế nào. Nhóm G07 lo việc đo thời gian thực tế trên từng task (timer, nhập tay) và giúp người dùng làm một việc một lúc (Focus mode, Pomodoro, nghỉ). Thời gian thực tế được dùng ở hoàn thành task (G02), lịch (G05, block thực tế), Daily shutdown (G08), Weekly review và analytics (G09).

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Không biết thực tế mất bao lâu cho một việc | Ước lượng sai mãi, ngày nào cũng quá tải |
| Bật / tắt đồng hồ đo ở công cụ khác (Toggl…) | Thêm thao tác, hay quên, số liệu rời khỏi kế hoạch |
| Quên tắt timer | Số liệu sai lệch hàng giờ, mất niềm tin vào báo cáo |
| Màn hình đầy task, lịch, thông báo | Khó tập trung vào một việc |
| Làm liền nhiều giờ không nghỉ | Mệt, hiệu suất giảm cuối ngày (đặc biệt Minh, Hà) |

## 1.3 Mục tiêu

- Bật / dừng timer bằng 1 phím (Space) hoặc 1 lần bấm; chỉ một timer chạy trên toàn tài khoản.
- Thời gian thực tế của task là tổng các lần ghi, sửa được, thể hiện trên card, lịch, review.
- Timer quên tắt được phát hiện: nhắc sau 4 giờ, tự đóng sau 24 giờ và hỏi giờ dừng.
- Có chế độ Focus một task (1.0), Pomodoro và nghỉ (1.1), Focus Bar luôn hiện trên desktop (1.2).

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người cần khối thời gian dài (Minh) | Vào Focus một task, tắt nhiễu, nghỉ đúng nhịp |
| Freelancer / founder (Hà) | Đo chính xác thời gian theo khách hàng (channel), không làm quá giờ |
| Người bận họp (Linh) | Bật / tắt timer nhanh giữa các cuộc họp, nhập bù thời gian đã làm |
| Người dùng thành thạo | Space, F, K, E thay cho chuột |

# 3. Phạm vi

## 3.1 Trong phạm vi (1.0; Pomodoro và nghỉ 1.1; Focus Bar 1.2)

- Nền tảng: Web (desktop, mobile web) ở 1.0. App iOS / Android và desktop từ 1.1; Focus Bar chỉ có trên desktop app (1.2).
- **1.0** Timer trên task và subtask: ▶ trên card / chi tiết, phím Space; một timer toàn tài khoản; dừng tạo bản ghi thời gian (TimeEntry), cộng vào thời gian thực tế, hiện block thực tế trên lịch (G05).
- **1.0** Nhập / sửa / xoá thời gian thực tế bằng tay (phím E).
- **1.0** Focus mode (F hoặc mục Focus ở sidebar): một task, tiêu đề lớn, subtask, notes, comment, Thực tế / Kế hoạch, START.
- **1.0** Âm báo khi còn 10 / 5 / 0 phút so với thời lượng kế hoạch (chọn một mức, mặc định 0).
- **1.0** Giám sát timer: nhắc khi chạy > 4 giờ (trong app ở 1.0, thông báo mobile từ 1.1), tự đóng > 24 giờ và hỏi giờ dừng.
- **1.1** Tab Pomodoro trong Focus mode; màn nghỉ (K); nhắc nghỉ sau 25 phút trên desktop; phím tắt toàn cục Ctrl+Shift+Space.
- **1.2** Focus Bar desktop (hiện khi focus / khi đang chạy timer), macOS menu bar.

## 3.2 Ngoài phạm vi

- Block thời gian thực tế trên lịch ngoài, timebox → G05.
- Quy tắc "Tính planned là actual" khi hoàn thành → G02.
- Tự đổi status / bật DND trên Slack / Teams khi bật timer (prompt "Reduce distractions in Slack/Teams…") → G11 (bản 1.2).
- Báo cáo thời gian theo tuần, channel → G09 (bản 1.1).
- Đồng bộ thời gian sang Toggl Track → sau 1.2.
- Chặn website / ứng dụng gây nhiễu → chưa đưa vào.

# 4. Nguyên tắc sản phẩm

## 4.1 Một việc một lúc

Chỉ một timer chạy trên toàn tài khoản. Bật timer mới tự đóng timer cũ, không hỏi.

## 4.2 Đo mà không phiền

Bật / dừng bằng một phím. Bật timer cho task không thuộc hôm nay vẫn chạy, chỉ nhắc (giống Sunsama). Quên tắt thì hệ thống phát hiện, không bắt người dùng tự nhớ.

## 4.3 Số liệu thật và sửa được

Thời gian thực tế là tổng các bản ghi có giờ bắt đầu và kết thúc. Người dùng sửa, thêm, xoá được; mọi thay đổi ghi nhật ký.

## 4.4 Focus là chế độ, không phải nhà tù

Vào / thoát Focus bằng một phím; thoát Focus không dừng timer; nghỉ không làm mất số liệu.

# 5. Quy tắc timer và Focus

| **Cấu hình** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Số timer chạy | 1 / tài khoản | — | Khoá duy nhất phía server |
| Bản ghi tối thiểu | < 10 giây thì bỏ, không lưu | 10 giây | Tránh bật nhầm (EC-25) |
| Một bản ghi tối đa | 24 giờ | — | Nhập tay và tự đóng dùng chung giới hạn |
| Nhắc timer chạy lâu | 4 giờ | Bật | Trong app (1.0), thông báo mobile (1.1) |
| Tự đóng timer | 24 giờ | — | Đóng tạm tại mốc 24 giờ, hỏi giờ dừng thật |
| Âm báo theo thời lượng kế hoạch | Còn 10 / 5 / 0 phút | 0 phút, âm báo bật | Chỉ khi task có thời lượng kế hoạch |
| Vào Focus khi chạy timer | Bật / tắt | Tắt | Cài đặt Focus |
| Phiên Pomodoro (1.1) | 5–90 phút, bước 5 phút | 25 phút | Chỉnh ▲▼ |
| Nghỉ (1.1) | 1–30 phút | 5 phút | Chỉnh ▲▼ |
| Nhắc nghỉ desktop (1.1) | Sau N phút chạy liên tục / nghỉ M phút | 25 / 5 | Desktop app |
| Focus Bar (1.2) | Hiện khi focus / khi timing / tắt | Khi focus | Desktop; macOS thêm menu bar |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Thời gian thực tế của task = tổng bản ghi của task và của các subtask `[giả định]`.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Chọn việc | Chọn task trên hôm nay (hoặc mở Focus bằng F) | Task đang chọn |
| 2 | Bắt đầu | Space / ▶ / START | Timer chạy, actual đếm xanh, badge ở Focus |
| 3 | Tập trung | Focus mode; (1.1) Pomodoro 25 phút; (1.2) Focus Bar luôn hiện | Một việc trên màn hình |
| 4 | Nghỉ (1.1) | K hoặc hết phiên Pomodoro → màn Break 5 phút → END BREAK | Quay lại task |
| 5 | Dừng | Space, hoàn thành task, hoặc bật timer task khác | Bản ghi thời gian, block thực tế trên lịch |
| 6 | Chỉnh | E để thêm / sửa thời gian đã làm ngoài app | Thời gian thực tế đúng |

PRD này bao trùm cả 6 bước; bước 3–4 có phần thuộc 1.1 / 1.2 như ghi ở mục 3.1.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Bật và dừng timer (1.0)

### US1.1 Bật timer

User Story: Là người dùng, tôi muốn bật đồng hồ cho task đang làm bằng một phím, để đo thời gian thật mà không rời khỏi kế hoạch.

AC01: ▶ trên card (hover) / chi tiết task, hoặc Space khi task đang chọn (không focus ô nhập) → timer chạy; tooltip nút "Dừng timer · Space".

AC02: Thời gian thực tế trên card và chi tiết đếm từng giây, màu xanh (ví dụ 0:00:03); mục Focus ở sidebar có badge.

AC03: Đang có timer chạy ở task khác → timer cũ đóng ngay, timer mới chạy; toast nêu task cũ đã dừng.

AC04: Task không thuộc hôm nay (ngày khác hoặc backlog) → timer vẫn chạy, toast "Task này không thuộc hôm nay" (Sunsama "Must focus on today").

### US1.2 Dừng timer

AC01: Space / nút dừng → bản ghi thời gian lưu; thời gian thực tế cộng dồn; block thực tế hiện trên lịch (G05).

AC02: Lần chạy < 10 giây không lưu bản ghi.

AC03: Hoàn thành hoặc xoá task đang chạy timer → timer dừng và lưu trước (EC-24).

### US1.3 Timer cho subtask

AC01: Mỗi subtask có ▶ riêng; bản ghi gắn subtask, cộng vào thực tế của subtask và của task.

AC02: Bật timer subtask khi task cha đang chạy → timer task cha đóng, timer subtask chạy (vẫn một timer).

### US1.4 Nhiều thiết bị

AC01: Bật / dừng ở một thiết bị → thiết bị khác cập nhật ≤ 5 giây.

AC02: Hai thiết bị offline cùng bật timer → khi đồng bộ giữ timer bật sau, timer kia đóng tại thời điểm timer sau bắt đầu (EC-11).

## UC2. Nhập và sửa thời gian thực tế (1.0)

### US2.1 Nhập bù

User Story: Là người dùng, tôi muốn ghi lại thời gian đã làm khi quên bật timer, để số liệu cuối tuần vẫn đúng.

AC01: Phím E (hover / chọn task) hoặc bấm ô "Thực tế" mở ô nhập: nhập thời lượng (giờ, phút) hoặc khoảng giờ bắt đầu – kết thúc.

AC02: Danh sách bản ghi của task hiện giờ, thời lượng, nguồn (timer / nhập tay / tự đóng); sửa, xoá từng bản ghi.

AC03: Giờ kết thúc ≤ giờ bắt đầu, bản ghi > 24 giờ hoặc ở tương lai → báo lỗi, không lưu.

AC04: Thêm / sửa / xoá có toast Hoàn tác và ghi nhật ký.

## UC3. Focus mode (1.0)

### US3.1 Làm một task

AC01: F hoặc mục Focus ở sidebar mở Focus mode của task đang chọn (không có task chọn → task đầu tiên chưa xong của hôm nay).

AC02: Màn hình: tiêu đề lớn, subtask, notes, comment, Thực tế / Kế hoạch, nút START / STOP; tab Focus / Pomodoro (Pomodoro ẩn ở 1.0).

AC03: Esc thoát Focus, timer vẫn chạy; hoàn thành task trong Focus → gợi ý task kế tiếp của hôm nay.

AC04: Bật "Vào Focus khi chạy timer" → bật timer ở bất kỳ đâu mở Focus mode.

### US3.2 Âm báo theo kế hoạch

AC01: Khi thời gian còn lại (kế hoạch − thực tế) chạm mức đã chọn (10 / 5 / 0 phút) → âm báo + toast một lần cho mỗi lần chạy.

## UC4. Pomodoro và nghỉ (1.1)

### US4.1 Pomodoro

AC01: Tab Pomodoro hiện "Còn lại 0:25:00", phiên chỉnh ▲▼ (bước 5 phút), START bật timer task và đếm ngược.

AC02: Hết phiên → âm báo, timer task dừng, gợi ý nghỉ.

### US4.2 Nghỉ

AC01: K hoặc "Nghỉ một chút" mở màn Break đếm ngược 0:05:00, chỉnh được, có TẠM DỪNG và KẾT THÚC NGHỈ.

AC02: Vào nghỉ dừng timer task; thời gian nghỉ không tính vào task; KẾT THÚC NGHỈ hoặc hết giờ → quay về task, không tự bật lại timer `[giả định]`.

AC03: Desktop: chạy liên tục 25 phút → thông báo hệ thống gợi ý nghỉ 5 phút.

## UC5. Timer quên tắt (1.0)

### US5.1 Nhắc và tự đóng

AC01: Timer chạy > 4 giờ → nhắc "Bạn vẫn đang làm?" với Dừng / Tiếp tục (1.0 trong app; 1.1 thêm thông báo mobile).

AC02: Timer chạy > 24 giờ → tự đóng tại mốc 24 giờ; lần mở app kế tiếp hỏi giờ dừng thật, mặc định giờ hoạt động cuối trên app (EC-23).

## UC6. Focus Bar (1.2, desktop)

### US6.1 Thanh focus luôn hiện

AC01: Desktop app hiện thanh nổi trên mọi cửa sổ khi đang focus hoặc đang chạy timer (theo cài đặt): tiêu đề task, thời gian thực tế / kế hoạch, dừng, hoàn thành, mở app.

AC02: macOS: menu bar hiện thời gian đang chạy.

AC03: Ctrl+Shift+Space (toàn cục) bật / dừng timer task gần nhất.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ người dùng dùng timer | Người dùng có ≥ 1 bản ghi timer / tuần / người dùng hoạt động tuần | ≥ 40% |
| Tỉ lệ task xong có thực tế | Task xong có bản ghi (timer hoặc nhập tay) / task xong | ≥ 50% |
| Timer bị tự đóng | Timer đóng ở mốc 24 giờ / tổng timer | ≤ 1% |
| Bản ghi bị sửa | Bản ghi timer bị sửa giờ / tổng bản ghi timer | Theo dõi (cao = quên tắt nhiều) |
| Độ lệch kế hoạch | Trung vị \|thực tế − kế hoạch\| / kế hoạch của task xong | Theo dõi, kỳ vọng giảm theo thời gian |
| Sử dụng Focus mode | Phiên Focus / người dùng hoạt động / tuần | Theo dõi |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Space là phím tắt | Gõ nhầm bật timer (đã gặp trên Sunsama) | Chỉ khi không focus ô nhập; khoá phím tắt 1 giây khi gõ nhanh; bản ghi < 10 giây bỏ |
| Đồng hồ máy lệch | Thiết bị đặt giờ sai làm bản ghi lệch | Server ghi `startedAt` theo giờ server khi online; offline dùng giờ máy, server chỉnh khi lệch > 2 phút `[giả định]` |
| Offline nhiều thiết bị | Hai timer chạy song song | Giữ timer sau (EC-11), đóng timer trước tại mốc bắt đầu của timer sau |
| Trình duyệt ngủ / đóng tab | Timer web không đếm khi tab ngủ | Timer lưu ở server; client chỉ hiển thị theo `startedAt` |
| Thông báo mobile ở 1.0 | App mobile chưa có ở 1.0 | 1.0 nhắc trong app (trung tâm thông báo, G12); push mobile từ 1.1 |
| Lịch ngoài (G05) | Block thực tế không ghi ra lịch ngoài | Chỉ hiển thị trong app ở 1.0 `[giả định]` |

# 10. Câu hỏi mở

- Thời gian thực tế của task có cộng thời gian của subtask không?
- Ngưỡng bỏ bản ghi ngắn: 10 giây hay 1 phút?
- Hết phiên Pomodoro / hết giờ nghỉ có tự bật lại timer task không?
- Nhắc timer > 4 giờ ở 1.0 (chưa có app mobile) qua email hay chỉ trong app?
- Block thời gian thực tế có ghi ra Google / Outlook không (G05)?
- Trạng thái Pomodoro / nghỉ có đồng bộ giữa thiết bị không, hay chỉ trên thiết bị đang dùng?
