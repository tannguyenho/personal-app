> **Mã:** PLN-PRD-G07 · **Trạng thái:** đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g07-focus-timer.md

# PRD Focus & theo dõi thời gian trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md) và [câu hỏi chốt 09/11/2026](../review/cau-hoi-chot-flow-2026-11-09.md) (B23–B27, C25, C29). G07 sở hữu quy tắc **bản ghi thời gian (QC-07)** trong [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); PRD này tham chiếu QC-07 và các quy tắc dùng chung khác (QC-01 ngày làm việc, QC-05 đổi ngày task, QC-08 đồng bộ, QC-09 chế độ chỉ đọc), không định nghĩa lại. Phiên bản: timer, thời gian thực tế, Focus mode, phím tắt toàn cục Ctrl+Shift+Space (D11) ở **1.0** (app Windows, Q45, ADR-0005); Pomodoro, màn nghỉ (Take a break), nhắc nghỉ trên desktop ở **1.1**; Focus Bar desktop ở **1.2**. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: nút ▶ và "Stop timer · Space", actual đếm màu xanh (0:00:03), badge ở mục Focus trên sidebar, toast "Must focus on today" khi bật timer cho task không thuộc hôm nay (timer vẫn chạy), block thời gian thực tế trên lịch ("2:01 – 2:02"), Focus mode có tab Focus / Pomodoro, Pomodoro "Remaining 0:25:00" với Session 0:25 chỉnh ▲▼, màn "Break" đếm ngược 0:05:00 có PAUSE, END BREAK. Chỗ khác Sunsama có chủ đích được ghi rõ.

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

- Nền tảng: app Windows (Flutter) ở 1.0 (Q45, ADR-0005). Web và macOS từ 1.1, iOS / Android từ 1.2 dùng cùng đặc tả. Focus Bar chỉ có trên app desktop (Windows, macOS; 1.2).
- **1.0** Timer lưu trên server theo giờ bắt đầu: thu nhỏ, đóng cửa sổ app, tắt app hoặc máy ngủ không dừng timer; mở lại app thì đồng hồ hiện đúng thời gian đã chạy. Đóng cửa sổ khi đang có timer thì app thu về khay hệ thống, timer chạy tiếp (D13); cơ chế chạy nền / khay hệ thống: tech chốt — `docs/tech/`.
- **1.0** Timer trên task: ▶ trên card / chi tiết, phím Space; timer luôn chạy trên **task cha**, không chạy trên subtask (QC-07 mục 6, C20); một timer toàn tài khoản; dừng tạo bản ghi thời gian, cộng vào thời gian thực tế, hiện khối thực tế trên lịch (G05).
- **1.0** Nhập / sửa / xoá thời gian thực tế bằng tay (phím E), theo thời lượng hoặc theo khoảng giờ (QC-07 mục 3).
- **1.0** Bản ghi thời gian theo QC-07: thuộc ngày làm việc của thời điểm bắt đầu, nguồn `timer` / `manual` / `auto_closed` / `ritual`.
- **1.0** Focus mode (F hoặc mục Focus ở sidebar): một task, tiêu đề lớn, subtask, notes, comment, Thực tế / Kế hoạch, START.
- **1.0** Âm báo khi còn 10 / 5 / 0 phút so với thời lượng kế hoạch (chọn một mức, mặc định 0).
- **1.0** Giám sát timer: nhắc khi chạy > 4 giờ (1.0: trong app và thông báo Windows, D12; push di động từ 1.2), tự đóng > 24 giờ và hỏi giờ dừng.
- **1.0** Phím tắt toàn cục Ctrl+Shift+Space bật / dừng timer (D11, thay mốc 1.1 của C20).
- **1.1** Tab Pomodoro trong Focus mode; màn nghỉ (K); nhắc nghỉ sau 25 phút trên desktop.
- **1.1** Chế độ chỉ đọc theo QC-09: timer đang chạy tự dừng tại thời điểm vào chỉ đọc.
- **1.2** Focus Bar desktop (hiện khi focus / khi đang chạy timer), macOS menu bar.

## 3.2 Ngoài phạm vi

- Block thời gian thực tế trên lịch ngoài, timebox → G05.
- Quy tắc "Tính planned là actual" khi hoàn thành → G02; chỉ là giá trị hiển thị, không tạo bản ghi (QC-07 mục 4).
- Bản ghi thời gian của ritual → G08 tạo với nguồn `ritual`, chỉ khi không có timer đang chạy (QC-07 mục 2).
- Cộng thời gian thực tế theo ngày / tuần / channel → chỉ G09 (QC-07 mục 5). G07 chỉ tính thời gian thực tế của từng task.
- Các đường đổi ngày task (phím D, kéo, rollover, backlog, shutdown) → bảng QC-05 (G06); không đường nào trong số này dừng timer.
- Tự đổi status / bật DND trên Slack / Teams khi bật timer (prompt "Reduce distractions in Slack/Teams…") → G11 (bản 1.2).
- Báo cáo thời gian theo tuần, channel → G09 (bản 1.1).
- Đồng bộ thời gian sang Toggl Track → sau 1.2.
- Chặn website / ứng dụng gây nhiễu → chưa đưa vào.

# 4. Nguyên tắc sản phẩm

## 4.1 Một việc một lúc

Chỉ một timer chạy trên toàn tài khoản, luôn trên task cha. Bật timer mới tự đóng timer cũ, không hỏi. Timer chỉ tự dừng khi task được hoàn thành hoặc bị xoá (Q14); dời ngày task không dừng timer.

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
| Lượt timer tối thiểu | < 10 giây thì bỏ, không lưu, không báo (B26) | 10 giây | Tránh bật nhầm |
| Nhập tay tối thiểu | 1 phút (QC-07 mục 3) | — | Áp cho cả thời lượng và khoảng giờ |
| Một bản ghi tối đa | 24 giờ | — | Nhập tay và tự đóng dùng chung giới hạn |
| Nhắc timer chạy lâu | 4 giờ | Bật | Trong app và thông báo Windows (1.0, D12); push di động (1.2) |
| Tự đóng timer | 24 giờ | — | Đóng tạm tại mốc 24 giờ, hỏi giờ dừng thật |
| Âm báo theo thời lượng kế hoạch | Còn 10 / 5 / 0 phút | 0 phút, âm báo bật | Chỉ khi task có thời lượng kế hoạch |
| Vào Focus khi chạy timer | Bật / tắt | Tắt | Cài đặt Focus |
| Phiên Pomodoro (1.1) | 5–90 phút, bước 5 phút | 25 phút | Chỉnh ▲▼ |
| Nghỉ (1.1) | 1–30 phút | 5 phút | Chỉnh ▲▼ |
| Nhắc nghỉ desktop (1.1) | Sau N phút chạy liên tục / nghỉ M phút | 25 / 5 | App desktop (Windows, macOS); thông báo hệ thống |
| Focus Bar (1.2) | Hiện khi focus / khi timing / tắt | Khi focus | Desktop; macOS thêm menu bar |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Thời gian thực tế của task theo QC-07 mục 5 (tổng bản ghi của task và subtask; cộng planned khi task lưu `plannedAsActual` và không có bản ghi nào).
- Bản ghi thuộc ngày làm việc của thời điểm bắt đầu, không chia khi vắt qua mốc đầu ngày (QC-07 mục 1, Q13).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Chọn việc | Chọn task trên hôm nay (hoặc mở Focus bằng F) | Task đang chọn |
| 2 | Bắt đầu | Space / ▶ / START | Timer chạy, actual đếm xanh, badge ở Focus |
| 3 | Tập trung | Focus mode; (1.1) Pomodoro 25 phút; (1.2) Focus Bar luôn hiện | Một việc trên màn hình |
| 4 | Nghỉ (1.1) | K hoặc hết phiên Pomodoro → màn Break 5 phút → END BREAK | Quay lại task |
| 5 | Dừng | Space, hoàn thành hoặc xoá task, hoặc bật timer task khác | Bản ghi thời gian, khối thực tế trên lịch |
| 6 | Chỉnh | E để thêm / sửa thời gian đã làm ngoài app | Thời gian thực tế đúng |

PRD này bao trùm cả 6 bước; bước 3–4 có phần thuộc 1.1 / 1.2 như ghi ở mục 3.1.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Bật và dừng timer (1.0)

### US1.1 Bật timer

User Story: Là người dùng, tôi muốn bật đồng hồ cho task đang làm bằng một phím, để đo thời gian thật mà không rời khỏi kế hoạch.

AC01: ▶ trên card (hover) / chi tiết task, hoặc Space khi task đang chọn (không focus ô nhập) → timer chạy; tooltip nút "Dừng timer · Space".

AC02: Thời gian thực tế trên card và chi tiết đếm từng giây, màu xanh (ví dụ 0:00:03); mục Focus ở sidebar có badge.

AC03: Đang có timer chạy ở task khác → timer cũ đóng ngay, timer mới chạy; toast nêu task cũ đã dừng.

AC04: Task không thuộc hôm nay (ngày khác hoặc backlog; "hôm nay" theo ngày làm việc, QC-01) → timer vẫn chạy, toast "Task này không thuộc hôm nay" (Sunsama "Must focus on today").

AC05: Timer chỉ bật trên task cha; dòng subtask không có ▶ (QC-07 mục 6, C20).

AC06 (1.0, desktop): Ctrl+Shift+Space (toàn cục): chưa có timer thì bật timer task gần nhất đã chạy (hoặc task đầu tiên chưa xong của hôm nay); đang có timer thì dừng (D11, C25).

AC07 (1.0, desktop): Menu khay hệ thống có mục timer: chưa có timer → "Bật timer: {task kế tiếp hôm nay}"; đang có timer → dừng timer (B23, C25).

### US1.2 Dừng timer

AC01: Space / nút dừng → bản ghi thời gian lưu; thời gian thực tế cộng dồn; khối thực tế hiện trên lịch (G05).

AC02: Lần chạy < 10 giây không lưu bản ghi và không báo người dùng (B26).

AC03: Hoàn thành hoặc xoá task đang chạy timer → timer dừng và lưu trước (EC-24, QC-05).

AC04: Dời task đang chạy timer bằng phím D, kéo sang ngày khác, rollover, đưa vào backlog, shutdown "Ngày mai" → timer **không** dừng (Q14, QC-05).

AC05: Bản ghi vắt qua mốc đầu ngày (ví dụ 22:00–02:00 với mốc 04:00, hoặc 03:00–05:00) thuộc ngày làm việc của thời điểm bắt đầu, không bị chia (Q13).

AC06: Thu nhỏ, đóng cửa sổ app, tắt app hoặc máy ngủ → timer **không** dừng; mở lại app thì đồng hồ hiện đúng thời gian đã chạy theo giờ bắt đầu. Đóng cửa sổ khi đang có timer → app thu về khay hệ thống, timer chạy tiếp (D13).

### US1.3 Timer cho subtask

(Bỏ — timer luôn chạy trên task cha, xem QC-07 mục 6 / C20.) Nhập tay cho subtask vẫn có ở US2.1.

### US1.4 Nhiều thiết bị

AC01: Bật / dừng ở một thiết bị → thiết bị khác cập nhật ≤ 5 giây.

AC02: Hai thiết bị offline cùng bật timer → khi đồng bộ, server xử lý theo thứ tự nhận (QC-08); phần thời gian chồng nhau bị cắt để không tính hai lần (C20, EC-11); thiết bị bị ảnh hưởng được báo.

### US1.5 Chế độ chỉ đọc (1.1)

AC01: Workspace vào chế độ chỉ đọc khi đang chạy timer → timer tự dừng, giờ dừng = thời điểm vào chỉ đọc (QC-09, Q8).

AC02: Ở chế độ chỉ đọc không bật timer mới, không thêm / sửa bản ghi; vẫn xem được thời gian thực tế.

AC03: Thao tác timer tạo offline trước thời điểm vào chỉ đọc được nhận nếu đồng bộ trong 2 giờ (QC-09).

## UC2. Nhập và sửa thời gian thực tế (1.0)

### US2.1 Nhập bù

User Story: Là người dùng, tôi muốn ghi lại thời gian đã làm khi quên bật timer, để số liệu cuối tuần vẫn đúng.

AC01: Phím E (hover / chọn task) hoặc bấm ô "Thực tế" mở ô nhập: nhập thời lượng (giờ, phút) hoặc khoảng giờ bắt đầu – kết thúc.

AC02: Danh sách bản ghi của task hiện giờ, thời lượng, nguồn (timer / nhập tay / tự dừng / ritual); sửa, xoá từng bản ghi.

AC03: Giờ kết thúc ≤ giờ bắt đầu, bản ghi < 1 phút hoặc > 24 giờ, hoặc ở tương lai → báo lỗi, không lưu.

AC04: Thêm và xoá có toast Hoàn tác; Hoàn tác của lần thêm là xoá bản ghi vừa nhập. Sửa bản ghi hiện "Đã lưu" kèm icon tại dòng đó. Mọi thay đổi ghi nhật ký (C29).

AC05: Nhập theo **thời lượng** → không kiểm tra chồng lấn (kể cả khi đang có timer chạy), không vẽ lên lịch (B11, QC-07 mục 3).

AC06: Nhập theo **khoảng giờ** → kiểm tra chồng lấn: chồng timer đang chạy thì báo lỗi; chồng bản ghi đã đóng thì cho lưu kèm cảnh báo; có vẽ lên lịch (B11).

AC07: Nhập cho subtask được (chọn subtask trong ô nhập); cộng vào thực tế của task theo QC-07 mục 5.

## UC3. Focus mode (1.0)

### US3.1 Làm một task

AC01: F hoặc mục Focus ở sidebar mở Focus mode của task đang chọn (không có task chọn → task đầu tiên chưa xong của hôm nay).

AC02: Màn hình: tiêu đề lớn, subtask (chỉ tích xong, không có timer riêng), notes, comment, Thực tế / Kế hoạch, nút START / STOP; tab Focus / Pomodoro (Pomodoro ẩn ở 1.0).

AC03: Esc thoát Focus, timer vẫn chạy; hoàn thành task trong Focus → gợi ý task kế tiếp của hôm nay; bấm "Bắt đầu" thì chuyển sang task đó và bật timer luôn (B25).

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

AC01: Timer chạy > 4 giờ → nhắc "Bạn vẫn đang làm?" với Dừng / Dừng lúc… / Vẫn đang làm (B27; 1.0: trong app và thông báo Windows, kể cả khi cửa sổ app đang thu nhỏ hoặc ở khay hệ thống, D12; push di động từ 1.2).

AC03: "Dừng lúc…" cho chọn giờ dừng thật sau giờ bắt đầu, muộn nhất là mốc sớm hơn trong hai mốc "hiện tại" và "giờ bắt đầu + 24 giờ"; bản ghi lưu với giờ đã chọn (B11, B24).

AC02: Timer chạy > 24 giờ → tự đóng tại mốc 24 giờ; hỏi giờ dừng thật ngay nếu cửa sổ app đang mở, hoặc lần đầu cửa sổ được mở lên nếu app đang ở khay; mặc định giờ hoạt động cuối trên app; khoảng chọn giờ như AC03 (EC-23, B24).

## UC6. Focus Bar (1.2, desktop)

### US6.1 Thanh focus luôn hiện

AC01: Desktop app hiện thanh nổi trên mọi cửa sổ khi đang focus hoặc đang chạy timer (theo cài đặt): tiêu đề task, thời gian thực tế / kế hoạch, dừng, hoàn thành, mở app.

AC02: macOS: menu bar hiện thời gian đang chạy.

AC03: (Chuyển sang US1.1 AC06 — phím tắt Ctrl+Shift+Space thuộc bản 1.0, không phụ thuộc Focus Bar, D11.)

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
| Offline nhiều thiết bị | Hai timer chạy song song, thời gian bị tính hai lần | Xử lý theo thứ tự server nhận (QC-08); cắt phần chồng lấn (C20, EC-11) |
| Thu nhỏ / đóng cửa sổ app, máy ngủ | Đồng hồ trên máy không đếm khi app không chạy; người dùng tưởng đóng cửa sổ là dừng timer | Timer lưu ở server; app chỉ hiển thị theo `startedAt`; đóng cửa sổ không dừng timer, thu về khay hệ thống (D13); cơ chế: tech chốt — `docs/tech/` |
| Thông báo khi không nhìn app (1.0) | App di động chưa có tới 1.2 | 1.0 nhắc trong app (trung tâm thông báo, G12) và thông báo Windows (D12); push di động từ 1.2 |
| Lịch ngoài (G05) | Khối thực tế không ghi ra lịch ngoài | Chỉ hiển thị trong app ở 1.0 `[giả định]`; chỉ bản ghi có giờ thật (B11) |
| Ritual chồng timer (G08) | Làm ritual trong lúc timer chạy bị tính hai lần | Ritual chỉ tạo bản ghi khi không có timer chạy (QC-07 mục 2) |

# 10. Câu hỏi mở

- Đã chốt 04/11/2026: thời gian thực tế của task cộng cả bản ghi của subtask (QC-07 mục 5, Q13). Timer chỉ chạy trên task cha (C20).
- Ngưỡng bỏ lượt timer ngắn: 10 giây hay 1 phút? Một phần đã chốt 04/11/2026: nhập tay tối thiểu 1 phút (QC-07 mục 3). **Chốt 09/11/2026 (B26):** lượt timer dưới 10 giây bị bỏ, không báo người dùng (thường là bấm nhầm).
- Hết phiên Pomodoro / hết giờ nghỉ có tự bật lại timer task không?
- Đã chốt 04/11/2026: nhắc timer > 4 giờ ở 1.0 bằng thông báo Windows và trong app, không có email (D12).
- Đã chốt 04/11/2026: đóng cửa sổ app khi đang có timer thì thu về khay hệ thống, timer chạy tiếp (D13).
- Khối thời gian thực tế có ghi ra Google / Outlook không (G05)?
- Trạng thái Pomodoro / nghỉ có đồng bộ giữa thiết bị không, hay chỉ trên thiết bị đang dùng?
- Đã chốt 04/11/2026: phím tắt toàn cục Ctrl+Shift+Space có ở bản 1.0 (D11, thay mốc 1.1 của C20); Focus Bar giữ 1.2.
- Đã chốt 04/11/2026: workspace vào chỉ đọc (1.1) thì timer tự dừng tại thời điểm vào chỉ đọc (Q8, QC-09).
- Đã chốt 04/11/2026: chỉ hoàn thành và xoá task dừng timer; các đường dời ngày, kể cả shutdown "Ngày mai", không dừng (Q14).
- **Chốt 09/11/2026 (B23):** menu khay khi chưa có timer có mục "Bật timer: {task kế tiếp hôm nay}"; khi đang có timer, menu khay và Ctrl+Shift+Space dừng timer (C25).
- **Chốt 09/11/2026 (B24):** timer tự đóng sau 24 giờ thì màn hỏi giờ dừng hiện ngay nếu cửa sổ đang mở, hoặc lần đầu cửa sổ được mở lên nếu app ở khay; giờ dừng chọn trong khoảng từ giờ bắt đầu tới mốc sớm hơn giữa "bây giờ" và "bắt đầu + 24 giờ", áp chung cho "Dừng lúc…".
- **Chốt 09/11/2026 (B25):** trong Focus mode, xong task rồi bấm "Bắt đầu" thì chuyển sang task kế tiếp và bật timer luôn.
- **Chốt 09/11/2026 (B27):** nhắc timer chạy quá 4 giờ giữ ba nút "Dừng · Dừng lúc… · Vẫn đang làm".
- Cắt phần chồng lấn khi đồng bộ offline (C20): khi bản ghi tới sau nằm giữa bản ghi đã có (bị chia làm hai đoạn) thì giữ cả hai đoạn hay chỉ giữ đoạn dài hơn?
