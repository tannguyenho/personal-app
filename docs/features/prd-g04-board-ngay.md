> **Mã:** PLN-PRD-G04 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g04-board-ngay.md

# PRD Board ngày, projection, khối lượng, tìm kiếm & phím tắt trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026 (tooltip "Total: Time planned", nút "Plan" khi hover cột, projection lùi "My job" 9:00 → 9:45 khi thêm task 0:45 lên đầu, cảnh báo "Only 8:00 available" khi đặt task 9 giờ, popover ngày, thông báo tìm kiếm rỗng, toast "Your first keyboard shortcut!"); chỗ khác Sunsama có chủ đích được ghi rõ.
>
> **Quy tắc dùng chung:** PRD này tham chiếu [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md) (QC-01 ngày làm việc, QC-02 lịch làm việc và khung giờ channel, QC-03 trạng thái task, QC-04 số ngày bị hoãn, QC-05 đổi ngày task, QC-06 instance trùng series, QC-08 đồng bộ, QC-09 chỉ đọc bản 1.1), không định nghĩa lại. Thuật ngữ theo [`CONTEXT.md`](../../CONTEXT.md). Cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md) vòng 7: sức chứa ngày không còn lấy min với ngưỡng khối lượng, ngưỡng chỉ là giới hạn riêng của lịch chung (Q48); "Hoãn 1 tuần" = max(ngày dự định, hôm nay) + 7 ngày, rơi vào ngày nghỉ thì giữ nguyên (D5); số ngày bị hoãn theo lịch hiện tại của task (D4).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Board ngày (Home) là màn hình người dùng mở nhiều nhất: mỗi cột là một ngày, chứa task của ngày đó, có tổng thời lượng kế hoạch và giờ dự kiến làm từng task. Nhóm G04 lo cách task được bày ra và di chuyển trên board: các chế độ xem, điều hướng ngày, kéo thả và sắp xếp, projection (giờ dự kiến), cảnh báo khối lượng, bộ lọc channel, tìm kiếm, command menu và phím tắt. Nội dung task (G02), timebox và lịch (G05), backlog (G06), timer (G07), ritual (G08) dùng board này làm nơi hiển thị nhưng đặc tả ở nhóm riêng.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Danh sách việc không cho biết mỗi việc sẽ làm lúc mấy giờ | Người dùng không thấy ngày bị dồn tới đâu cho tới khi đã muộn |
| Không so được tổng việc với thời gian trống sau khi trừ cuộc họp | Lên kế hoạch quá tải, cuối ngày còn nhiều việc, mất động lực (persona Linh, Hà) |
| Dời việc sang ngày khác phải mở từng task, chọn ngày | Ngại sắp xếp lại, danh sách hôm nay phình to |
| Tìm một việc cũ phải cuộn qua nhiều ngày | Tạo trùng việc, mất ngữ cảnh |
| Người dùng thành thạo phải dùng chuột cho thao tác lặp lại | Chậm; phím tắt một chữ dễ kích hoạt nhầm khi gõ (đã gặp trên Sunsama) |

## 1.3 Mục tiêu

- Mở Home là thấy ngay hôm nay và các ngày tới, mỗi ngày có tổng thời lượng và trạng thái quá tải; tải 1 tuần ≤ 500 ms.
- Mỗi task chưa timebox có giờ dự kiến (projection) cập nhật ≤ 200 ms sau mỗi thay đổi trong ngày có 50 task.
- Ngày quá tải được báo bằng màu và số giờ còn trống cụ thể, trước khi người dùng bắt đầu làm; trong ngày, cảnh báo tính trên thời gian trống còn lại và báo khi việc dự kiến kéo quá giờ làm.
- Mọi thao tác trên board làm được bằng bàn phím hoặc command menu; không có phím tắt nào chạy khi đang gõ.
- Tìm thấy task mới tạo ≤ 5 giây, gõ không dấu vẫn khớp.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người lịch dày (Linh, PM, 6–8 cuộc họp/ngày) | Biết sau các cuộc họp còn bao nhiêu giờ thật để làm việc |
| Người cần khối thời gian dài (Minh, designer / dev) | Thấy việc nào sẽ rơi vào khung giờ nào để giữ khối tập trung |
| Người dễ làm quá giờ (Hà, freelancer / founder) | Bị cảnh báo khi nhận quá nhiều việc cho một ngày, dời việc nhanh sang ngày khác |
| Người dùng thành thạo | Điều hướng, di chuyển, sắp xếp, tìm kiếm chỉ bằng bàn phím |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: app Windows (Flutter) ở 1.0 (Q45, ADR-0005). Web và macOS từ 1.1, iOS / Android từ 1.2 dùng cùng đặc tả. Chi tiết kỹ thuật (lưu trên máy, tính nền): tech chốt — `docs/tech/`.
- Home board: cột ngày cuộn ngang vô hạn; header cột có thứ, ngày, thanh tiến độ, "Thêm task", tổng thời lượng, nút "Plan" khi hover.
- Today view: một ngày + lịch của ngày đó.
- Chế độ xem (phím Tab): Board, Calendar 1 ngày, 3 ngày, Weekdays, Week, Month.
- Điều hướng ngày: popover chọn ngày, Hôm nay / Ngày sau / Ngày trước, chip ngày đang xem có × để về hôm nay.
- Di chuyển task: kéo thả giữa cột và trong cột; phím D (sang ngày làm việc kế tiếp), hoãn 1 tuần, S (về hôm nay), Ctrl+↑/↓, Ctrl+Shift+↑/↓. Timebox, timer, số ngày bị hoãn khi đổi ngày theo QC-05.
- Sắp xếp lại một ngày theo 7 tiêu chí; tự sắp task theo cài đặt.
- Projection và giờ dự kiến trên card theo lịch của task (khung giờ channel hoặc lịch chung, QC-02 mục 6); cảnh báo khối lượng trên sức chứa ngày (QC-02 mục 7), cờ "Vượt giờ làm".
- Bộ lọc channel (Shift+F), tìm kiếm (Ctrl+F, gồm cả task Lưu trữ), command menu (Ctrl/Cmd+K), bảng phím tắt (?).
- Khung panel phải: Calendar, Tasks, Backlog, Lưu trữ, Search, tích hợp (1.1+), nút +.
- Gọi "đảm bảo rollover" (G06) khi mở app lần đầu trong ngày làm việc.

## 3.2 Ngoài phạm vi

- Tạo, sửa, hoàn thành, xoá task → G02. Lặp lại → G03.
- Kéo task vào lịch thành timebox, đồng bộ lịch, auto-schedule → G05 (G04 chỉ hiển thị badge giờ và tính sức chứa từ sự kiện).
- Nội dung panel Backlog, Lưu trữ, rollover → G06. Timer, Focus (phím F, K) → G07.
- Nội dung Daily planning / Daily shutdown (nút "Plan", phím P, O) → G08. Panel Objectives (Shift+R) → G09 (bản 1.1).
- Panel từng tích hợp (Gmail, Jira, Notion…) → G11 (bản 1.1+).
- "Latest updates": bỏ khỏi phạm vi (C36).
- Màn Lịch làm việc (ngày làm việc trong tuần, giờ làm từng ngày) → G01 (QC-02). Cài đặt khung giờ channel → G02 (QC-02 mục 5). G04 chỉ đọc cả hai để tính sức chứa, projection, cờ "Vượt giờ làm" và phím D.
- Banner đổi timezone → G01 (MSG-23 là banner duy nhất, QC-01).
- Chế độ chỉ đọc → bản 1.1 (QC-09, ADR-0002).
- Chọn nhiều task để di chuyển cùng lúc → sau 1.1 `[giả định]`.
- Tìm kiếm trong comment → sau 1.1. Tìm kiếm task của người khác trong workspace → bản sau, 1.2 trở đi (nhiều thành viên, Q35, Q47, `docs/02-tinh-nang-ban-sau.md`).

# 4. Nguyên tắc sản phẩm

## 4.1 Nhìn một lần biết ngày có kham nổi không

Header cột luôn hiện tổng thời lượng; vượt sức chứa thì đỏ và nói rõ còn bao nhiêu giờ trống. Không cần mở trang thống kê nào.

## 4.2 Projection chỉ là dự kiến

Giờ dự kiến chỉ hiển thị mờ trong app, không ghi ra lịch ngoài, không chặn giờ của ai. Muốn giữ giờ thật thì timebox (G05).

## 4.3 Kéo được thì gõ phím được

Mọi kéo thả có cách tương đương bằng bàn phím hoặc menu; mọi lệnh có trong command menu kèm phím tắt.

## 4.4 Phím tắt không gây tai nạn

Phím một ký tự không chạy khi đang gõ; lệnh có tác dụng phụ luôn có Hoàn tác. Gõ nhanh liên tục thì tạm khoá phím tắt (Sunsama không chặn; khác có chủ đích, EC-25).

# 5. Quy tắc cấu hình board

| **Cấu hình** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Ngưỡng khối lượng | 1–24 giờ, bước 30 phút `[giả định]` | 8 giờ `[giả định]` | Cài đặt người dùng (G01). Chỉ là giới hạn riêng của lịch chung, áp cho task không có khung giờ channel; không làm giảm sức chứa ngày (Q48, QC-02 mục 7) |
| Lịch làm việc | Lịch chung: ngày làm việc trong tuần và giờ làm từng ngày (QC-02 mục 1, G01 sở hữu). Khung giờ channel: ngày và giờ riêng của từng channel (QC-02 mục 5–7, G02 sở hữu) | Lịch chung Thứ Hai–Thứ Sáu, 09:00–17:00 `[giả định]` cho giờ; channel mặc định không có khung riêng | Sức chứa ngày = thời gian trống trong **hợp** của lịch chung và mọi khung channel có trong ngày (QC-02 mục 7). Projection, cờ "Vượt giờ làm" và "ngày làm việc kế tiếp" của phím D theo **lịch của task**: khung channel của task nếu có, ngược lại lịch chung (QC-02 mục 6) |
| Mốc đầu ngày | 00:00–06:00 (QC-01) | 04:00 | Quyết định "hôm nay" là ngày nào; đổi có hiệu lực từ ngày làm việc kế tiếp |
| Hiện projection | Bật / tắt | Bật | Tắt thì card không hiện giờ dự kiến |
| Projection mờ hơn sự kiện thật | Bật / tắt | Bật | Áp trên Calendar views |
| Khoảng đệm giữa các task | 0–60 phút `[giả định]` | 0 | Dùng chung với auto-schedule (G05, bản 1.1) |
| Tự sắp task | Bật / tắt | Bật | Timebox theo giờ → priority → vị trí tuỳ chỉnh; task xong xuống cuối |
| Ẩn task đã xong | Bật / tắt | Tắt | |
| Số ngày tải mỗi lần cuộn | 7 ngày `[giả định]` | – | Board giữ trong bộ nhớ ± 3 tuần quanh ngày đang xem |
| Ảo hoá danh sách cột | Khi cột > 100 task `[giả định]` | – | EC-40: ngày 500 task vẫn cuộn mượt |
| Tìm kiếm | Truy vấn ≥ 2 ký tự, 50 kết quả mỗi trang `[giả định]` | – | Không phân biệt hoa thường và dấu; gồm task Lưu trữ (C17) |
| Khoá phím tắt khi gõ nhanh | ≥ 4 ký tự trong 1 giây → khoá 1 giây `[giả định]` | Bật | EC-25 |

- Các giá trị là **cấu hình hệ thống / cài đặt người dùng**, không cố định trong code.
- Chế độ xem cuối cùng và bộ lọc channel được nhớ theo thiết bị.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Mở app | Vào Home (phím H): cột hôm nay ở đầu, các ngày tới bên phải | Thấy việc hôm nay và tổng thời lượng từng ngày |
| 2 | Đánh giá khối lượng | Đọc tổng ở header cột, giờ dự kiến trên card; cột đỏ nếu quá tải | Biết ngày nào cần bớt việc |
| 3 | Sắp xếp | Kéo task sang ngày khác, phím D / S, Ctrl+↑/↓, sắp lại theo tiêu chí | Mỗi ngày vừa sức chứa, thứ tự đúng ý |
| 4 | Điều hướng, đổi góc nhìn | Shift+→/←, popover ngày, Tab đổi Board / Calendar / Month | Xem đúng khoảng thời gian cần |
| 5 | Tìm và lọc | Shift+F lọc channel, Ctrl+F tìm task cũ | Thấy đúng nhóm việc / đúng task |
| 6 | Làm nhanh bằng phím | Ctrl+K gõ tên lệnh; ? xem bảng phím tắt | Không rời bàn phím |

Timebox (G05), Daily planning (G08), timer (G07) diễn ra trên board nhưng thuộc nhóm khác. PRD này tập trung bước 1–6 ở phần hiển thị, di chuyển, tính toán và điều khiển.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Xem board ngày

### US1.1 Xem các ngày dạng cột

User Story: Là người dùng, tôi muốn thấy hôm nay và các ngày tới cạnh nhau, mỗi ngày có tổng thời lượng, để biết việc đang dồn vào đâu.

AC01: Home mở với cột hôm nay ở mép trái vùng nội dung; cuộn ngang tải thêm 7 ngày mỗi lần, cả về quá khứ và tương lai.

AC02: Header cột hiện tên thứ, ngày, thanh tiến độ (thời lượng task xong / tổng thời lượng), nút "Thêm task", tổng thời lượng dạng H:MM.

AC03: Hover tổng thời lượng hiện tooltip "Tổng: thời lượng kế hoạch".

AC04: Hover header cột hôm nay hoặc ngày tương lai hiện nút "Plan", bấm mở Daily planning của ngày đó (G08).

AC05: "Hôm nay" là ngày làm việc theo QC-01: lúc 02:00 ngày 05/11, mốc đầu ngày 04:00, hôm nay vẫn là 04/11 (dùng bảng ví dụ của QC-01 làm ca kiểm thử).

AC06: Lần mở app đầu tiên trong ngày làm việc, board gọi "đảm bảo rollover" (G06); việc dở của hôm trước hiện ở hôm nay kể cả khi job rollover định kỳ bị lỗi. Nếu người dùng còn đang shutdown ngày cũ, việc dở ở yên ngày cũ tới khi phiên xong hoặc tối đa 2 giờ sau mốc (Q18).

AC07: Ngày ở xa, ngoài khoảng instance lặp đã sinh, hiện instance lặp dự kiến dạng mờ, nhãn "Dự kiến" (C17); không tính vào tổng `[giả định]`.

AC08: Card có số ngày bị hoãn ≥ 1 hiện nhãn "Dời {n} ngày" (QC-04); n chỉ đếm ngày có trong lịch **hiện tại** của task, nên đổi lịch, khung giờ channel hoặc channel có thể làm n thay đổi (QC-04 mục 1, Q32, D4).

### US1.4 Đổi timezone

AC01: Banner đổi timezone chỉ có một, do G01 hiển thị (MSG-23 của G01); board không hiện banner riêng.

AC02: Task giữ ngày dự định (vẫn nằm ở cột ngày dự định); timebox giữ thời điểm tuyệt đối. Timebox rơi vào ngày làm việc khác ngày dự định thì không gắn cờ, hệ thống không tự sửa; người dùng tự kéo task hoặc timebox nếu muốn khớp (QC-01 mục 4, Q4, F5).

### US1.2 Today view

AC01: Phím T hoặc mục "Today" ở sidebar mở một ngày: danh sách task bên trái, lịch của ngày bên phải.

AC02: Today view dùng cùng projection, tổng, cảnh báo với cột ngày trên board.

### US1.3 Đổi chế độ xem

AC01: Phím Tab (hoặc menu chọn view) đổi lần lượt: Board → Calendar 1 ngày → 3 ngày → Weekdays → Week → Month → Board.

AC02: Calendar views hiện sự kiện lịch, timebox (G05) và projection mờ hơn sự kiện thật (khi bật cài đặt).

AC03: Month view hiện mỗi ngày tối đa 3 task, phần còn lại "+n" `[giả định]`.

AC04: View cuối cùng được nhớ trên thiết bị; mở lại app vào đúng view đó.

## UC2. Điều hướng ngày

### US2.1 Nhảy tới ngày cần xem

AC01: Popover ngày có Hôm nay (Shift+Space), Ngày sau (Shift+→), Ngày trước (Shift+←) và lịch tháng để chọn ngày.

AC02: Khi đang xem ngày khác hôm nay, thanh công cụ hiện chip ngày đang xem có ×; bấm × về hôm nay.

AC03: Ở Calendar views, Shift+→/← dịch đúng một khoảng của view: Weekdays và Week dịch 1 tuần (C17); 1 ngày, 3 ngày, Month dịch 1 ngày, 3 ngày, 1 tháng `[giả định]`.

AC04: Chọn ngày ngoài ± 5 năm so với hôm nay không cho phép (khớp giới hạn ngày G02).

## UC3. Di chuyển và sắp xếp task

### US3.1 Kéo thả task

User Story: Là người dùng, tôi muốn kéo task sang ngày khác hoặc lên xuống trong ngày, để sắp lại kế hoạch mà không mở task.

AC01: Kéo task sang cột khác → ngày dự định = ngày cột đó, task nằm đúng vị trí thả; nhật ký ghi "đặt ngày dự định thành {ngày}".

AC02: Kéo trong cột → đổi vị trí; các cột liên quan tính lại tổng, projection ngay.

AC03: Kéo sang ngày khác đặt lại số ngày bị hoãn về 0 (QC-04). Task đã timebox giữ giờ, dời timebox sang ngày mới; timer đang chạy không dừng (QC-05).

AC04: Kéo sang ngày khác có toast "Đã chuyển sang {ngày} · Hoàn tác"; Hoàn tác khôi phục cả liên kết timebox (QC-05).

AC05: Kéo task chưa xong vào ngày đã qua bị chặn; server cũng từ chối với mọi đường (QC-05, C15).

AC06: Kéo instance lặp vào ngày đã có instance cùng series → vẫn đặt, kèm cảnh báo "Ngày này đã có {tên series}" (QC-06).

AC07: Thay đổi đồng thời trên thiết bị khác (hoặc do rollover) → lệnh trên phiên bản cũ bị từ chối, người dùng thấy "Task đã thay đổi trên thiết bị khác" (QC-08).

### US3.2 Di chuyển bằng phím

AC01: D chuyển task sang ngày làm việc kế tiếp **theo lịch của task** (QC-02 mục 2, 6) của max(ngày dự định, hôm nay) (C15), không đặt lại số ngày bị hoãn (QC-04); lệnh "Hoãn 1 tuần" (command menu / menu Ngày dự định) đặt ngày dự định = max(ngày dự định, hôm nay) + 7 ngày, rơi vào ngày không có trong lịch của task thì giữ nguyên ngày đó (D5); S đưa về hôm nay; "Hoãn 1 tuần" và S đặt lại số ngày bị hoãn về 0 (QC-04 mục 3, dòng "Hoãn 1 tuần, phím S" của QC-05, Q40); mỗi lệnh có toast Hoàn tác.

AC05: Ví dụ phím D (lịch chung Thứ Hai–Thứ Sáu; `#Cá nhân` có khung Thứ Hai–Chủ Nhật 19:00–22:00; `#Công ty` không đặt khung): Thứ Sáu 06/11 nhấn D trên task `#Công ty` → Thứ Hai 09/11; trên task `#Cá nhân` → Thứ Bảy 07/11.

AC02: Ctrl+↑/↓ lên / xuống một vị trí; Ctrl+Shift+↑/↓ lên đầu / xuống cuối ngày.

AC03: Lệnh áp vào task đang chọn; không có task chọn thì áp vào task đang hover.

AC04: D đưa instance lặp vào ngày đã có instance cùng series → instance được dời chuyển vào Lưu trữ (lý do "bị bỏ qua"), toast có Hoàn tác (QC-06).

### US3.3 Sắp lại một ngày theo tiêu chí

AC01: Menu "Sắp xếp lại" của cột cho 7 tiêu chí: giờ bắt đầu, priority, ngắn nhất, dài nhất, mới nhất, cũ nhất, channel.

AC02: Sắp lại chỉ áp vào task chưa xong của ngày đó; task xong vẫn ở cuối; có toast Hoàn tác.

AC03: Khi bật "Tự sắp task", task đã timebox và priority vẫn được ưu tiên theo quy tắc tự sắp; card hiện gợi ý tắt tự sắp nếu kết quả khác tiêu chí đã chọn.

## UC4. Projection và cảnh báo khối lượng

### US4.1 Giờ dự kiến trên card

User Story: Là người dùng, tôi muốn thấy mỗi việc dự kiến làm lúc mấy giờ, để biết việc cuối cùng sẽ xong khi nào.

AC01: Task chưa timebox, chưa xong, có thời lượng được xếp lần lượt theo thứ tự hiển thị, mỗi task vào khe trống sớm nhất **trong lịch của task** (khung giờ channel của task nếu có, ngược lại lịch chung — QC-02 mục 6), bỏ qua sự kiện bận, timebox và task đã xếp trước, cộng khoảng đệm. Chỉ có một lịch (không channel nào đặt khung) thì kết quả là xếp liên tiếp từ giờ bắt đầu làm việc.

AC02: Thêm task 0:45 lên đầu ngày có task "My job" dự kiến 9:00 → "My job" lùi thành 9:45 (đã kiểm chứng trên Sunsama).

AC03: Hôm nay, nếu đã qua giờ bắt đầu làm việc, projection tính từ thời điểm hiện tại làm tròn lên 5 phút `[giả định]`.

AC04: Giờ dự kiến hiện mờ; task đã timebox hiện badge giờ màu cam (G05); task không có thời lượng không có giờ dự kiến `[giả định]`.

AC05: Projection không ghi ra lịch ngoài.

AC06: Ví dụ khung giờ channel (Thứ Năm 05/11, lịch chung 09:00–17:00, `#Cá nhân` 19:00–22:00, không có sự kiện): thứ tự hiển thị "Đọc sách" (`#Cá nhân`, 1:00) rồi "Báo cáo" (`#Công ty`, 2:00) → "Đọc sách" dự kiến 19:00, "Báo cáo" dự kiến 9:00.

### US4.2 Cảnh báo quá tải

User Story: Là người dùng, tôi muốn được báo khi tổng việc vượt thời gian trống, để bớt việc trước khi bắt đầu ngày.

AC01: Sức chứa còn lại = thời gian trống còn lại, **không** lấy min với ngưỡng khối lượng (Q48). Thời gian trống còn lại = thời gian trong **hợp** của lịch chung và mọi khung giờ channel có trong ngày (QC-02 mục 7; khoảng chồng nhau chỉ tính một lần), với hôm nay chỉ tính từ bây giờ, trừ sự kiện bận (busy, tentative).

AC02: Quá tải khi planned của task **chưa xong** > sức chứa còn lại (B7) → tổng ở header chuyển đỏ; task chưa xong làm tổng cộng dồn vượt sức chứa (và các task chưa xong sau nó) hiện chấm cảnh báo "Chỉ còn X giờ trống". Task đã xong không bao giờ mang chấm cảnh báo.

AC03: Đặt một task 9 giờ vào ngày trống (tương lai), lịch chung 09:00–17:00, không channel nào có khung → cảnh báo "Chỉ còn 8:00 trống" (Sunsama: "Only 8:00 available", đã kiểm chứng).

AC04: Sự kiện đã từ chối, free, sự kiện cả ngày, timebox do app tạo và sự kiện ở lịch đang ẩn không trừ vào thời gian trống. Task có timebox liên kết sự kiện (ví dụ cuộc họp kéo vào thành task) chỉ trừ thời gian một lần qua sự kiện gốc, planned của task không cộng thêm (B8).

AC05: Dời bớt task / xoá cuộc họp → cảnh báo tự mất ngay khi khối lượng còn lại ≤ sức chứa còn lại và việc theo lịch chung không vượt ngưỡng (AC10).

AC06: Mỗi ngày chỉ hiện một trạng thái, theo thứ tự ưu tiên: Đã qua > Trống > Xong hết > Quá tải > Bình thường (B7).

AC07: Cờ "Vượt giờ làm" xét theo lịch của task (QC-02 mục 6): task có giờ dự kiến kết thúc sau giờ kết thúc làm của lịch của task, hoặc nằm ở ngày không có trong lịch của task, mang cờ; ngày có cờ khi có ít nhất một task mang cờ. Ví dụ: 16:00, lịch chung tới 17:00, còn 4 giờ việc `#Công ty` chưa timebox → task cuối và ngày có cờ "Vượt giờ làm", tooltip nêu giờ dự kiến xong việc cuối (B7); khung 19:00–22:00 của `#Cá nhân` không cứu task `#Công ty`.

AC08: Ngày không có trong lịch chung và không có khung channel nào (ví dụ Thứ Bảy với lịch mặc định, không channel nào đặt khung) có sức chứa 0; ngưỡng khối lượng không thay cho sức chứa (Q48).

AC09: Ví dụ sức chứa theo khung giờ channel (QC-02 mục 7), không có sự kiện: lịch chung Thứ Hai–Thứ Sáu 09:00–17:00, `#Cá nhân` Thứ Hai–Chủ Nhật 19:00–22:00 → Thứ Năm 05/11 thời gian trống 11:00; Thứ Bảy 07/11 thời gian trống 3:00. Thêm channel `#Dự án` khung Thứ Hai–Thứ Sáu 08:00–12:00 → Thứ Năm thời gian trống 12:00 (08:00–17:00 và 19:00–22:00; phần 09:00–12:00 không cộng hai lần).

AC10: **Ngưỡng khối lượng** (cài đặt G01) chỉ là giới hạn riêng của lịch chung, áp cho task không có khung giờ channel (Q48, QC-02 mục 7): tổng planned của các task chưa xong theo lịch chung > ngưỡng → ngày cũng quá tải, task theo lịch chung làm tổng vượt ngưỡng (và các task theo lịch chung chưa xong sau nó) hiện chấm cảnh báo "Vượt ngưỡng khối lượng". Task có khung giờ channel không tính vào ngưỡng.

AC11: Ví dụ (Thứ Năm 05/11, lịch chung 09:00–17:00, `#Cá nhân` 19:00–22:00, ngưỡng 8 giờ, không có sự kiện; sức chứa 11:00): `#Công ty` 6:00 + `#Cá nhân` 3:00 → không quá tải; `#Công ty` 9:00 → quá tải do vượt ngưỡng dù còn trong sức chứa; `#Công ty` 7:00 + `#Cá nhân` 5:00 = 12:00 → quá tải do vượt sức chứa. Thứ Bảy 07/11, `#Cá nhân` 4:00 → quá tải (sức chứa 3:00), ngưỡng không áp.

## UC5. Lọc và tìm kiếm

### US5.1 Lọc theo channel

AC01: Bộ lọc (Shift+F) cho chọn Tất cả, theo context (work, personal…) hoặc từng channel; có mục "Quản lý channel" (G02).

AC02: Đang lọc → thanh công cụ hiện "Đang lọc" và nút bỏ lọc; card ngoài bộ lọc bị ẩn.

AC03: Tổng thời lượng và cảnh báo khối lượng vẫn tính trên toàn bộ task của ngày `[giả định]` (Sunsama tính theo bộ lọc; chờ PO chốt).

### US5.2 Tìm kiếm task

User Story: Là người dùng, tôi muốn gõ vài chữ là tìm ra task cũ, để không tạo trùng việc.

AC01: Ctrl+F mở panel Search bên phải, con trỏ nằm sẵn trong ô tìm.

AC02: Lọc theo Ngày (Mọi lúc, Tuần trước, Tháng trước) và Channel; kết quả tô sáng từ khoá.

AC03: Không phân biệt hoa thường và dấu: "bao cao" khớp "Báo cáo tuần".

AC04: Task mới tạo hoặc vừa đổi tên tìm thấy ≤ 5 giây (Sunsama trễ index; khác có chủ đích).

AC05: Không có kết quả → "Không tìm thấy kết quả. Thử diễn đạt khác."

AC06: Bấm kết quả mở chi tiết task (G02) và cuộn board tới ngày của task.

AC07: Kết quả gồm cả task trong Lưu trữ, gắn nhãn "Lưu trữ"; mở ra ở chế độ xem, có nút khôi phục (G06) (C17).

## UC6. Command menu và phím tắt

### US6.1 Gọi lệnh bằng Ctrl/Cmd+K

AC01: Ctrl/Cmd+K mở command menu; gõ để lọc lệnh (không phân biệt dấu); Enter chạy; mỗi lệnh hiện phím tắt tương ứng.

AC02: Lệnh nhóm theo: Thao tác task, Lên lịch task, Thứ tự task, Điều hướng task, Focus, Điều hướng ngày, Điều hướng trang, Chung.

AC03: Lệnh theo ngữ cảnh: có task đang chọn / hover thì nhóm Thao tác task hiện trên cùng; không có thì nhóm này ẩn.

### US6.2 Bảng phím tắt và lần đầu dùng phím tắt

AC01: Phím ? mở bảng phím tắt theo nhóm.

AC02: Lần đầu người dùng dùng một phím tắt hiện toast "Phím tắt đầu tiên của bạn!" (một lần / tài khoản).

AC03: Tắt "Phím tắt" trong cài đặt (G01) → phím một ký tự không chạy; Ctrl/Cmd+K vẫn chạy.

### US6.3 Không kích hoạt nhầm

AC01: Phím một ký tự không chạy khi ô nhập đang focus.

AC02: Gõ ≥ 4 ký tự trong 1 giây ngoài ô nhập → phím tắt một ký tự tạm khoá 1 giây (EC-25: trên Sunsama gõ nhầm làm bật timer, vào màn nghỉ, đổi trạng thái xong).

AC03: Lệnh có tác dụng phụ (D, S, Ctrl+↑/↓, sắp lại) có toast Hoàn tác và Ctrl+Z.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Ngày quá tải được xử lý | Ngày hôm nay chuyển từ quá tải về bình thường trước 12:00 / ngày hôm nay quá tải lúc mở app | ≥ 40% |
| Tỉ lệ ngày quá tải | Ngày có trạng thái quá tải lúc mốc đầu ngày / ngày có task | Theo dõi, kỳ vọng giảm theo thời gian dùng |
| Thao tác bằng phím | Di chuyển / điều hướng bằng phím hoặc command menu / tổng thao tác cùng loại | ≥ 25% ở người dùng thành thạo |
| Hoàn tác sau phím tắt ≤ 5 giây | Hoàn tác ngay sau lệnh phím tắt / lệnh phím tắt | ≤ 3% (cao = kích hoạt nhầm) |
| Tìm kiếm thành công | Lượt tìm có bấm kết quả / lượt tìm | ≥ 60% |
| Tải board | p95 thời gian đọc 1 tuần | ≤ 500 ms |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Sự kiện lịch (G05) | Sức chứa và projection cần sự kiện bận; lịch chưa đồng bộ thì số sai | Khi lịch lỗi / chưa kết nối, tính sức chứa = giờ làm còn lại chưa trừ sự kiện (không dùng ngưỡng, Q48) và hiện ghi chú "chưa tính lịch" |
| Mốc đầu ngày | Đã chốt 04:00, chỉnh 00:00–06:00 (Q2) | Dùng `workday(t)` của QC-01; không tự tính ngày ở board |
| Lịch làm việc (G01) và khung giờ channel (G02) | Sức chứa, projection, cờ "Vượt giờ làm" và phím D phụ thuộc lịch chung (G01) và khung giờ channel (G02) | G01, G02 sở hữu (QC-02 mục 1, 5); G04 chỉ đọc. Đổi lịch chung, khung channel hoặc channel của task → tính lại các ngày bị ảnh hưởng |
| Rollover (G06) | Job rollover lỗi làm hôm nay thiếu việc dở | Gọi "đảm bảo rollover" khi mở app (B6) |
| Ngày rất nhiều task (EC-40) | 500 task / ngày làm board giật, projection chậm | Ảo hoá danh sách; projection tính nền, không chặn giao diện (cơ chế: tech chốt — `docs/tech/`), chỉ tính lại ngày bị đổi |
| Đồng bộ nhiều thiết bị | Hai máy kéo cùng task, hoặc máy offline kéo task mà server đã rollover | Theo QC-08: thứ tự server nhận, cụm vị trí ghi nguyên khối, lệnh trên phiên bản cũ bị từ chối; thiết bị thua nhận realtime và vẽ lại |
| Phím tắt trùng hệ điều hành / ô nhập | Trên Windows, Tab và Ctrl+F có nghĩa sẵn trong ô nhập và khi chuyển focus | Chỉ xử lý khi board focus; Tab trong ô nhập giữ hành vi chuẩn. Phím trùng trình duyệt xử lý khi có bản web (1.1) |
| Tìm kiếm không dấu | Chuẩn hoá tiếng Việt (đ/Đ, tổ hợp dấu) | Chỉ mục lưu bản bỏ dấu; bộ test tiếng Việt |
| Đổi timezone (EC-02) | "Hôm nay" đổi khi người dùng bay sang múi giờ khác | Theo QC-01: có hiệu lực từ ngày làm việc kế tiếp; banner duy nhất là G01 MSG-23; task giữ ngày dự định, timebox giữ thời điểm tuyệt đối; lệch thì không gắn cờ, không tự sửa, người dùng tự kéo (F5) |

# 10. Câu hỏi mở

- Đã chốt 04/11/2026: mốc đầu ngày mặc định 04:00, chỉnh trong 00:00–06:00 (Q2).
- Bộ lọc channel có làm tổng và cảnh báo khối lượng tính theo bộ lọc như Sunsama không?
- Đã chốt 04/11/2026: quá tải tính trên thời gian trống còn lại và planned của task chưa xong; thêm cờ "Vượt giờ làm" (B7).
- Task không có thời lượng có chiếm khe trong projection không (đề xuất: không)?
- Đã chốt 04/11/2026: kéo task đã timebox sang ngày khác giữ giờ, dời timebox sang ngày mới, timer không dừng (Q14, QC-05).
- Đã chốt 04/11/2026: không đặt task chưa xong vào ngày đã qua, server kiểm với mọi đường (C15).
- "Sắp xếp lại" khi đang bật tự sắp: tạm tắt tự sắp cho ngày đó hay chỉ đổi vị trí tuỳ chỉnh?
- Phím hoãn 1 tuần là gì (Shift+D đã dùng cho Todoist ở G11)?
- Đã chốt 04/11/2026: "Hoãn 1 tuần" và phím S đặt lại số ngày bị hoãn; đã thêm dòng "Hoãn 1 tuần, phím S" vào QC-05 và QC-04 mục 3 (Q40).
- Đã chốt 06/11/2026: phím S = về hôm nay; "Hoãn 1 tuần" ít dùng nên chỉ còn là lệnh, không có phím tắt. QC-05 tách thành hai dòng (F1).
- Đã chốt 04/11/2026: "Hoãn 1 tuần" = max(ngày dự định, hôm nay) + 7 ngày; rơi vào ngày nghỉ (ngày không có trong lịch của task) thì giữ nguyên ngày đó, không lùi (D5).
- Đã chốt 04/11/2026: số ngày bị hoãn tính theo lịch hiện tại của task; đổi lịch, khung giờ channel hoặc channel thì số có thể thay đổi (D4, QC-04 mục 1).
- Đã chốt 04/11/2026: bỏ "ghi đè giờ làm việc theo channel `[giả định]`", thay bằng khung giờ channel do G02 sở hữu. Sức chứa ngày = thời gian trống trong hợp lịch chung và mọi khung channel có trong ngày; projection, cờ "Vượt giờ làm" và "ngày làm việc kế tiếp" của phím D theo lịch của task (Q38a, QC-02 mục 5–7).
- Đã chốt 04/11/2026: số ngày bị hoãn chỉ đếm ngày có trong lịch làm việc của task; rollover vẫn chạy mọi ngày (Q32, QC-04 mục 1).
- ~~Kéo task có timebox liên kết sự kiện (B8) sang ngày khác: gỡ liên kết hay giữ và gắn cờ "Lệch ngày"?~~ **Đã chốt theo QC-05 (ngoại lệ timebox liên kết sự kiện) và G05 BR-21 (f):** chỉ gỡ liên kết, không dời và không xoá sự kiện ngoài (sửa ngược 06/11/2026).
- Đã chốt 04/11/2026: thời gian trống của ngày tính trên hợp lịch chung và mọi khung channel (Q38a), nên Thứ Bảy có khung `#Cá nhân` thì có sức chứa; ngày không có trong lịch chung lẫn khung channel nào có sức chứa 0, không dùng ngưỡng khối lượng thay thế (Q48).
- Đã chốt 04/11/2026: bỏ công thức min(ngưỡng, thời gian trống còn lại). Sức chứa = thời gian trống trong hợp lịch chung và các khung channel; quá tải khi planned của task chưa xong > sức chứa; ngưỡng khối lượng chỉ là giới hạn riêng của lịch chung, áp cho task không có khung channel (Q48, QC-02 mục 7).
- Projection khi có nhiều lịch: SRS tạm xếp mỗi task vào khe trống sớm nhất trong lịch của task theo thứ tự hiển thị; task ở ngày không có trong lịch của task tạm xếp từ giờ bắt đầu mặc định 09:00 và mang cờ "Vượt giờ làm". Cần PO xác nhận.
- Instance lặp dự kiến ở ngày xa (C17) có tính vào tổng thời lượng và cảnh báo quá tải không? SRS tạm không tính.
