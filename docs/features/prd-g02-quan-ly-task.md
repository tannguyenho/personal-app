> **Mã:** PLN-PRD-G02 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g02-quan-ly-task.md

# PRD Quản lý task trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026; chỗ khác Sunsama có chủ đích được ghi rõ.
>
> Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). Quy tắc dùng chung `QC-xx` ở [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); G02 sở hữu **QC-03** (trạng thái task và khôi phục), **QC-08** (đồng bộ nhiều thiết bị, offline) và phần **khung giờ channel** của **QC-02** (mục 5–9). Thuật ngữ theo [`CONTEXT.md`](../../CONTEXT.md).
>
> Cập nhật thêm theo vòng 5–6 (Q33–Q46): bản 1.0 là app Windows cho một người dùng (Q35, Q45, [ADR-0005](../adr/0005-nen-tang-windows-truoc.md)); gợi ý task dùng trợ lý AI qua Claude Code CLI (QC-12, Q33, [ADR-0004](../adr/0004-ai-qua-claude-code-cli.md)); bỏ lưu trữ thủ công khỏi 1.0 (Q34); thêm khung giờ channel (Q38a). Tính năng để bản sau gom ở [`02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md).
>
> Cập nhật theo vòng 7: khung giờ channel một khoảng mỗi ngày, không vắt nửa đêm, bước 15 phút, đổi có hiệu lực từ ngày làm việc kế tiếp, "Chưa phân loại" không có khung riêng (D1–D3); công tắc AI hoàn thành / xoá áp cho cả subtask, AI không hoàn thành hay xoá task có liên kết tích hợp (D10); phím toàn cục Ctrl+Shift+A có ở 1.0 (D11); bản 1.1 vẫn chỉ một người dùng, nhiều thành viên từ 1.2 trở đi (Q47).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Task là đơn vị trung tâm của sản phẩm: board theo ngày, lịch, timebox, backlog, ritual và AI đều đọc / ghi task. Nhóm G02 lo vòng đời của một task: tạo, bổ sung chi tiết, hoàn thành, nhân bản, xoá và khôi phục, cùng channel để phân loại và khung giờ riêng của từng channel. Lặp lại (G03), xếp lên board (G04), timebox (G05), backlog (G06) và timer (G07) nằm ở nhóm riêng nhưng dùng chung mô hình task này.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Ghi một việc mới mất nhiều thao tác (mở form, chọn ngày, chọn loại, ước lượng) | Người dùng ngại ghi, việc nằm trong đầu hoặc rải rác ở chỗ khác |
| Không ước lượng thời lượng cho task | Không biết ngày có quá tải không, không timebox được |
| Chi tiết của việc (bước nhỏ, ghi chú, link) nằm ngoài task | Phải mở nhiều công cụ khi làm việc |
| Xoá hoặc đánh dấu xong nhầm không lấy lại được | Mất dữ liệu, mất niềm tin vào công cụ |
| Không phân loại được thời gian dành cho việc gì | Weekly review và analytics không có dữ liệu theo channel |
| Mỗi mảng việc có giờ riêng (việc công ty T2–T6 ban ngày, việc cá nhân buổi tối cả tuần) nhưng chỉ có một lịch làm việc chung | Projection, sức chứa ngày và "ngày làm việc kế tiếp" sai với việc ngoài giờ hành chính |

## 1.3 Mục tiêu

- Ghi một task trong ≤ 5 giây, chỉ cần gõ tiêu đề và Enter; phần còn lại có giá trị mặc định, hoặc giá trị gợi ý khi bật trợ lý AI (Q33).
- Mọi task đều có thời lượng kế hoạch (người dùng nhập, hoặc trợ lý AI gợi ý) để các nhóm G04, G05 tính được khối lượng ngày.
- Mọi thao tác phá huỷ đều hoàn tác được.
- Mọi task thuộc một channel để thống kê thời gian theo channel; channel có thể có khung giờ riêng để task được xếp và đếm theo đúng giờ của mảng việc đó (Q38a).

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân (dùng chuột là chính) | Gõ nhanh một việc vào ngày, bổ sung bước nhỏ, đánh dấu xong |
| Người dùng thành thạo | Làm mọi thao tác bằng phím tắt, không rời bàn phím |
| Người hay đổi ý / thao tác nhầm | Hoàn tác được ngay khi lỡ xoá hoặc lỡ đánh dấu xong |
| Người làm nhiều vai (công việc, cá nhân, khách hàng) | Phân loại task theo channel và context để xem thời gian dành cho từng mảng; đặt giờ riêng cho từng mảng (ví dụ `#Cá nhân` 19:00–22:00 cả tuần) |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: bản 1.0 là app **Windows** (Flutter), một người dùng, dữ liệu trên cloud gắn tài khoản (Q45, ADR-0005). Web và macOS từ 1.1, iOS / Android từ 1.2, dùng cùng đặc tả.
- Tạo task: từ ô soạn trên cột ngày, phím A, dán URL.
- Gợi ý thời lượng và channel bằng trợ lý AI qua Claude Code CLI (QC-12). Trợ lý AI tắt, chưa đồng ý hoặc máy không có Claude Code → không có gợi ý AI; app không gọi LLM nào khác (Q33).
- Chi tiết task: channel, priority, ngày dự định, hạn chót (due), thời lượng kế hoạch, subtask (một cấp), notes, comment, nhật ký hoạt động.
- Hoàn thành / bỏ hoàn thành task và subtask; xoá subtask có Hoàn tác. Trợ lý AI chỉ hoàn thành / xoá task và subtask khi người dùng bật công tắc riêng; task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá (QC-12 mục 4, D10).
- Nhân bản, xoá mềm, hoàn tác, Thùng rác, khôi phục.
- Bộ trạng thái task dùng chung cho mọi nhóm (QC-03) và quy tắc đồng bộ nhiều thiết bị, offline (QC-08).
- Context và channel: tạo, sửa, ẩn, xoá (chuyển task sang channel khác); channel hệ thống "Chưa phân loại". Bản 1.0 một người dùng: người dùng tạo channel tự do, không phân quyền (Q35).
- **Khung giờ channel** (QC-02 mục 5–9, Q38a): mỗi channel tuỳ chọn đặt ngày và giờ riêng (một khoảng mỗi ngày, D1); không đặt thì dùng lịch làm việc chung (G01); channel "Chưa phân loại" luôn theo lịch chung (D3). G02 sở hữu cài đặt; G04 (projection, sức chứa), G06 (số ngày bị hoãn, QC-04), G04 / G08 (phím D, shutdown "Ngày mai") và G05 (auto-schedule, bản 1.1) đọc để dùng.

## 3.2 Ngoài phạm vi

- Lặp lại task → G03.
- Kéo thả trên board, sắp xếp, projection → G04.
- Timebox lên lịch → G05. Backlog, rollover, lưu trữ tự động → G06. Timer, Focus → G07.
- Đính kèm file → bản 1.1.
- Giao task cho người khác, follow task → bản sau, 1.2 trở đi (Q35, Q47, [`02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md)). Khi làm: task được giao vào bucket backlog "Tuần sau", đặt lên đầu (Q36).
- Quyền tạo channel chung / channel riêng tư theo vai trò trong workspace → bản sau, 1.2 trở đi (Q35, Q47).
- Lưu trữ thủ công (`manual`) → bản sau (Q34). Ở 1.0 người dùng đưa task vào backlog hoặc xoá.
- Trial, thanh toán (gói cá nhân một người dùng, không tính ghế) và chế độ chỉ đọc → bản 1.1 (QC-09, Q47, ADR-0002). Bản 1.0 miễn phí, không giới hạn, gắn nhãn Beta.
- Đổi ngày task (phím D, kéo thả, rollover, backlog) → G04, G06 theo QC-05.
- Gộp task (giữ Alt khi kéo) → sau 1.1.

# 4. Nguyên tắc sản phẩm

## 4.1 Gõ là xong

Chỉ tiêu đề là bắt buộc. Ngày lấy theo cột đang đứng, thời lượng và channel lấy từ gợi ý; người dùng sửa sau nếu muốn.

## 4.2 Gợi ý phải nhìn ra được

Giá trị do trợ lý AI gợi ý (qua Claude Code CLI, QC-12) có biểu tượng ✨ riêng. Người dùng sửa thì biểu tượng mất. Không bao giờ ghi đè giá trị người dùng đã nhập. Không bật trợ lý AI thì không có gợi ý, ô soạn vẫn dùng đủ (Q33).

## 4.3 Không có thao tác mất trắng

Xoá (cả task và subtask), hoàn thành, đổi ngày đều có toast **Hoàn tác** và ghi nhật ký. Task xoá vào Thùng rác, khôi phục được trong 30 ngày (Q28; Sunsama giữ 7 ngày, chọn dài hơn có chủ đích). Khôi phục đưa task về đúng trạng thái trước khi xoá (QC-03).

## 4.4 Lưu ngay, không có nút Lưu

Sửa trường nào lưu trường đó ngay; mất mạng thì giữ ở máy và đồng bộ lại khi có mạng theo QC-08.

# 5. Quy tắc thuộc tính task

| **Thuộc tính** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Tiêu đề | 1–500 ký tự, cắt khoảng trắng hai đầu | — | Bắt buộc |
| Ngày dự định | Ngày làm việc (QC-01), trong khoảng ± 5 năm; task chưa xong không đặt vào ngày đã qua (QC-05) | Ngày của cột đang soạn; trống = backlog (G06) | Hoàn thành: task thường về hôm nay, instance lặp giữ ngày (QC-05) |
| Hạn chót (due) | Ngày, độc lập với ngày dự định | Trống | Due < ngày dự định: cho phép, có cảnh báo |
| Thời lượng kế hoạch | 1 phút – 24 giờ; preset 5, 10, 15, 20, 25, 30, 45 phút, 1 giờ | Gợi ý của trợ lý AI; không có gợi ý (trợ lý tắt, không có Claude Code) thì trống | Cộng vào tổng ngày |
| Priority | Urgent (1), Priority (2), Normal (3), Low (4) | Normal | Reset khi rollover theo cài đặt (G06) |
| Channel | Một channel thuộc một context | Gợi ý của trợ lý AI, không có thì channel hệ thống "Chưa phân loại" (B4) | Mỗi task đúng một channel; lịch làm việc của task theo khung giờ của channel (QC-02 mục 6) |
| Khung giờ channel | Tuỳ chọn; ≥ 1 ngày trong tuần khi bật; mỗi ngày một khoảng giờ, không vắt qua nửa đêm, giờ kết thúc > giờ bắt đầu, bước 15 phút (D1) | Tắt (dùng lịch làm việc chung của G01) | Đổi có hiệu lực từ ngày làm việc kế tiếp (D2). Channel "Chưa phân loại" không có khung riêng, luôn theo lịch chung (D3) |
| Subtask | Một cấp; tối đa 100 / task, tiêu đề 1–500 ký tự | — | Có thời lượng và thời gian thực tế riêng; timer chỉ chạy trên task cha (QC-07) |
| Notes | Rich text, tối đa 50.000 ký tự | Trống | Đậm, nghiêng, danh sách, checklist, link |
| Comment | 1–5.000 ký tự | — | Hiện tác giả, giờ |
| Vị trí task mới | Đầu / cuối danh sách | Đầu | Cài đặt người dùng (G01) |
| Giữ trong Thùng rác | 30 ngày (đã chốt, Q28) | — | Sau đó xoá vĩnh viễn |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Khi đăng ký (G01) tạo context `work`, `personal` và channel hệ thống **"Chưa phân loại"** làm channel mặc định; channel này không xoá được (B4). `work` / `personal` chỉ là context, không phải channel.
- Trạng thái task theo QC-03: Kế hoạch, Backlog, Hoàn thành, Lưu trữ (kèm lý do `stale` / `skipped`; không có lưu trữ thủ công ở 1.0, Q34), Đã xoá. "Đã dời" chỉ là nhãn suy ra từ số ngày bị hoãn (QC-04).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Ghi nhận | Bấm "Thêm task" trên cột ngày (hoặc phím A), gõ tiêu đề, Enter | Task trên cột ngày, có thời lượng và channel gợi ý |
| 2 | Bổ sung chi tiết | Mở task: thêm subtask, notes, priority, due, sửa channel / thời lượng | Task đủ thông tin để làm |
| 3 | Sắp xếp, lên lịch | Kéo sang ngày khác, timebox, đưa vào backlog (G04–G06) | Task ở đúng ngày / giờ |
| 4 | Thực hiện | Bật timer, đánh dấu subtask xong dần (G07) | Thời gian thực tế |
| 5 | Hoàn thành | Bấm ✓ hoặc phím C | Task xong, subtask xong, thời gian thực tế / kế hoạch |
| 6 | Dọn dẹp | Nhân bản việc tương tự; xoá việc không cần; lấy lại từ Thùng rác khi cần | Danh sách gọn, không mất dữ liệu |

Bước 3–4 thuộc nhóm khác, chỉ nêu để thấy vị trí của G02. PRD này tập trung bước 1, 2, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Tạo task

### US1.1 Ghi nhanh một task vào ngày

User Story: Là người dùng, tôi muốn gõ tiêu đề rồi Enter là có task trong ngày, để ghi lại việc mà không mất mạch.

AC01: Ô soạn mở từ nút "Thêm task" trên cột ngày hoặc phím A; con trỏ nằm sẵn trong ô.

AC02: Enter tạo task với ngày dự định = ngày của cột; task hiện ở đầu (hoặc cuối, theo cài đặt) danh sách ngày đó.

AC03: Tiêu đề trống → Enter không tạo task.

AC04: Esc khi đã gõ nội dung → giữ bản nháp, mở lại ô soạn thấy nội dung cũ (Sunsama bỏ luôn bản nháp; khác có chủ đích).

AC05: Ô soạn có sẵn các tuỳ chọn: ngày, thời lượng, channel, objective (1.1), priority, vị trí.

AC06: Cột ngày đã qua (ngày < hôm nay theo ngày làm việc, QC-01) → không tạo được task chưa xong; server từ chối theo QC-05 và báo lỗi.

AC07: Phím toàn cục **Ctrl+Shift+A** (app Windows, có từ 1.0 — D11) mở ô thêm task nhanh kể cả khi app đang chạy nền hoặc cửa sổ không ở trước; task tạo vào hôm nay. Tắt phím tắt trong cài đặt (G01) thì phím này ngừng.

### US1.2 Tạo task từ link

AC01: Dán URL vào ô soạn → tiêu đề task lấy từ tiêu đề trang; không đọc được thì dùng chính URL.

AC02: Task giữ link nguồn; phím G mở link.

### US1.3 Có gợi ý thời lượng và channel

AC01: Sau khi gõ tiêu đề, thời lượng và channel được trợ lý AI gợi ý qua Claude Code CLI (QC-12), có biểu tượng ✨; giá trị gắn nguồn `ai`.

AC02: Người dùng sửa giá trị → biểu tượng ✨ mất, giá trị người dùng không bị ghi đè lại.

AC03: Người dùng tắt gợi ý trong cài đặt → không gợi ý.

AC04: Trợ lý AI đang tắt, chưa qua màn đồng ý, hoặc máy không có Claude Code → không có gợi ý AI, không gọi LLM nào khác; thời lượng trống, channel "Chưa phân loại"; ô soạn vẫn tạo task bình thường (Q33, QC-12 mục 2).

AC05: Claude Code chậm hoặc lỗi → bỏ qua gợi ý, không chặn việc tạo task.

## UC2. Xem và sửa chi tiết task

### US2.1 Mở và sửa task

AC01: Bấm tiêu đề task hoặc Ctrl+Enter mở chi tiết; Esc hoặc nút × đóng.

AC02: Sửa trường nào lưu ngay trường đó, không có nút Lưu.

AC03: Mọi thay đổi ghi vào nhật ký: ai (người / AI / tích hợp / hệ thống), sửa gì, lúc nào.

### US2.2 Chia nhỏ việc bằng subtask

AC01: Thêm subtask bằng nút "+ Subtask" hoặc phím V; Enter tạo subtask kế tiếp.

AC02: Mỗi subtask có thời lượng, thời gian thực tế và ô ✓ riêng; hover hiện "Hoàn thành lúc {giờ}".

AC03: Kéo để đổi thứ tự subtask.

AC04: Subtask chỉ có một cấp: không thêm subtask vào subtask (C9).

AC05: Tích xong subtask cuối cùng **không** tự hoàn thành task (C9).

AC06: Thêm subtask vào task đã hoàn thành → subtask mới ở trạng thái chưa xong, task vẫn hoàn thành, không bị mở lại (C9).

AC07: Xoá subtask (icon xoá trên dòng subtask) không hỏi xác nhận; toast "Đã xoá subtask · Hoàn tác" ≥ 5 giây; Hoàn tác trả subtask về đúng vị trí, trạng thái, thời lượng và thời gian thực tế (C9).

### US2.3 Đặt priority và hạn chót

AC01: Priority chọn trong 4 mức hoặc phím 1–4 khi mở menu priority; task priority cao lên đầu danh sách ngày (khi bật tự sắp xếp).

AC02: Priority khác Normal hiện chip trên card.

AC03: Hạn chót hiện chip trên card; quá hạn đổi màu cảnh báo.

### US2.4 Ghi chú và bình luận

AC01: Notes hỗ trợ đậm, nghiêng, danh sách, checklist, link; lưu ngay khi gõ.

AC02: Comment hiện tác giả và giờ; Enter gửi, Shift+Enter xuống dòng.

## UC3. Hoàn thành task

### US3.1 Đánh dấu xong

User Story: Là người dùng, tôi muốn bấm một lần là task và các bước nhỏ đều xong, để không phải tích từng cái.

AC01: Bấm ✓ trên card / chi tiết hoặc phím C → task xong, mọi subtask chưa xong chuyển xong.

AC02: Task đang chạy timer → timer dừng trước khi đánh dấu xong; timebox giữ, chỉ rút ngắn khi thời điểm hoàn thành nằm trong khoảng giờ của timebox (QC-05, B10).

AC03: Đang bật "Tính planned là actual" → task lưu cờ `plannedAsActual` tại lúc hoàn thành. Task không có bản ghi thời gian thì card hiện actual = planned. Đây chỉ là giá trị hiển thị, **không tạo bản ghi thời gian**; bật / tắt cài đặt sau này không đổi task đã xong (QC-07, Q13).

AC04: "Hôm nay" là ngày làm việc (QC-01): tích xong lúc 02:00 sáng 05/11 (mốc 04:00) vẫn tính cho ngày 04/11. Task thường có ngày dự định khác hôm nay hoặc ở backlog → chuyển về hôm nay. Instance lặp giữ nguyên ngày dự định (QC-05, Q12).

AC05: Card hiện "actual / planned" (ví dụ 0:02 / 1:30); có toast Hoàn tác.

AC06: Số ngày bị hoãn của task reset về 0 (QC-04).

AC07: Trợ lý AI (qua MCP local) chỉ hoàn thành được task khi người dùng đã bật công tắc "Cho phép AI hoàn thành và xoá task" (mặc định tắt). Công tắc áp cho cả subtask (D10). Task có liên kết tích hợp không bao giờ được AI hoàn thành, kể cả khi đã bật. Task do AI hoàn thành có chip "AI", nhật ký ghi tác nhân AI và có Hoàn tác (QC-12 mục 4–5).

### US3.2 Bỏ hoàn thành

AC01: Bấm lại ✓ trong **cùng ngày làm việc** với lúc hoàn thành → kết quả giống Hoàn tác trên toast: trả lại mọi tác dụng phụ (subtask do hoàn thành tự tích, cờ `plannedAsActual`, ngày dự định hoặc bucket trước đó) (QC-03 mục 4, Q25).

AC02: Bấm lại ✓ ở **ngày làm việc khác** → chỉ xoá thời điểm hoàn thành; task ở Kế hoạch hôm nay; subtask giữ nguyên (QC-03 mục 4).

AC03: Nhật ký ghi "đánh dấu chưa xong".

## UC4. Nhân bản, xoá và khôi phục

### US4.1 Nhân bản

AC01: Menu … → Nhân bản (Ctrl+D) tạo bản sao: chép tiêu đề, notes, subtask chưa xong, channel, thời lượng kế hoạch, priority; ngày dự định = hôm nay; vị trí theo cài đặt "Vị trí task mới"; mở bản sao ngay (C11).

AC02: Không chép series: nhân bản một instance lặp cho ra task thường. Các trường khác (due, comment, timebox, thời gian thực tế, link nguồn) không chép (C11).

### US4.2 Xoá và hoàn tác

AC01: Menu … → Xoá hoặc Ctrl+Backspace; không hỏi xác nhận; toast "Đã xoá · Hoàn tác (Ctrl+Z)".

AC02: Ctrl+Z hoặc nút Hoàn tác trong toast khôi phục đủ dữ liệu, đúng vị trí cũ.

AC03: Task xoá nằm trong Thùng rác 30 ngày (Q28); quá hạn xoá vĩnh viễn.

AC04: Task đang chạy timer bị xoá → dừng timer, lưu thời gian trước khi xoá. Timebox xử lý theo QC-05 dòng "Xoá": timebox tương lai bị gỡ và sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, giữ sự kiện. Hoàn tác khôi phục cả liên kết timebox.

AC05: Xoá một instance lặp → ngày gốc của instance thành ngày ngoại lệ của series, series không sinh lại ngày đó (G03, Q26).

AC06: Trợ lý AI chỉ xoá được task (và subtask) khi người dùng đã bật công tắc "Cho phép AI hoàn thành và xoá task"; task có liên kết tích hợp không bao giờ được AI xoá, kể cả khi đã bật (D10); xoá do AI có chip "AI", nhật ký và Hoàn tác như xoá thường (QC-12 mục 4–5).

### US4.3 Khôi phục từ Thùng rác

AC01: Thùng rác (panel phải hoặc lệnh "Task đã xoá gần đây") liệt kê task đã xoá, mới nhất trước.

AC02: Khôi phục → task về đúng trạng thái trước khi xoá theo bảng QC-03 mục 3: task đã xong giữ ngày và thời điểm hoàn thành; task Lưu trữ về Lưu trữ với lý do cũ; task backlog về đúng bucket; task Kế hoạch giữ ngày nếu ≥ hôm nay, ngược lại về hôm nay với số ngày bị hoãn = 0.

AC03: Khôi phục instance lặp vào ngày đã có instance của cùng series → vẫn khôi phục, kèm cảnh báo "Ngày này đã có {tên series}" (QC-06 đường thủ công).

## UC5. Phân loại bằng context và channel

### US5.1 Quản lý channel

AC01: Tạo context; tạo channel trong context: tên, màu, riêng tư (riêng tư ở 1.0 chỉ làm sự kiện timebox ghi ra lịch ngoài thành Private, G05). Bản 1.0 một người dùng: tạo channel tự do, không phân quyền channel chung / riêng tư (Q35, bản sau).

AC02: Tên channel 1–50 ký tự, không chứa "#", không trùng trong cùng context (không phân biệt hoa thường).

AC03: Ẩn channel → không hiện trong ô soạn và bộ lọc; task cũ giữ nguyên.

AC04: Xoá channel → hỏi chuyển task sang channel nào (mặc định "Chưa phân loại"); không xoá task. Chuyển **mọi** task của channel, kể cả task trong Thùng rác, Lưu trữ và mẫu của series lặp (C10).

AC05: Channel hệ thống "Chưa phân loại" không xoá được (B4).

### US5.2 Gán channel cho task

AC01: Gõ "#" trong ô soạn hoặc phím Q / # trên task mở danh sách channel có ô tìm.

AC02: Shift+Q nhận channel gợi ý.

AC03: Đổi channel của task → lịch làm việc của task theo channel mới (khung giờ channel nếu có, ngược lại lịch chung) (QC-02 mục 6).

### US5.3 Đặt khung giờ riêng cho channel

User Story: Là người làm nhiều vai, tôi muốn đặt cho mỗi channel những ngày và giờ riêng (ví dụ `#Công ty` T2–T6 09:00–17:00, `#Cá nhân` T2–CN 19:00–22:00), để projection, sức chứa ngày và việc dời sang "ngày làm việc kế tiếp" đúng với giờ thật của từng mảng việc.

AC01: Trong cài đặt channel có công tắc "Khung giờ riêng", mặc định tắt. Tắt → task của channel dùng lịch làm việc chung (G01) và tự theo khi lịch chung đổi.

AC02: Bật → hiện 7 dòng Thứ Hai … Chủ Nhật, mỗi dòng một công tắc và giờ bắt đầu / kết thúc; điền sẵn theo lịch chung hiện tại `[giả định]`. Được bật cả ngày không có trong lịch chung (ví dụ Chủ Nhật).

AC03: Giờ kết thúc ≤ giờ bắt đầu → báo lỗi tại dòng, không lưu. Bật khung mà không chọn ngày nào → báo lỗi, không lưu. Mỗi ngày một khoảng giờ, chọn theo bước 15 phút, không vắt qua nửa đêm (D1).

AC04: Lưu → hiện ghi chú "Áp dụng từ ngày làm việc kế tiếp ({ngày})"; hôm nay vẫn dùng khung cũ, các ngày từ ngày làm việc kế tiếp trở đi hiển thị theo khung mới ngay (D2, cùng tinh thần Q3).

AC05: Từ ngày có hiệu lực, task của channel dùng khung này cho: projection và cờ "Vượt giờ làm" (G04); số ngày bị hoãn (QC-04, G06); "ngày làm việc kế tiếp" khi dời bằng phím D (G04) hoặc shutdown "Ngày mai" (G08); auto-schedule chỉ xếp trong khung (G05, bản 1.1). Sức chứa của một ngày = thời gian trống trong hợp của lịch chung và mọi khung channel có trong ngày đó (G04, QC-02 mục 7).

AC06: Khung giờ channel **không** ảnh hưởng: ritual ngày (G08) và cột ngày của G09 (theo lịch chung, QC-02 mục 8); quy tắc lặp (G03, Q43).

AC07: Xoá channel có khung giờ riêng → task chuyển sang channel nhận và dùng lịch của channel nhận (US5.1 AC04). Ẩn channel không đổi khung giờ.

AC08: Đổi lịch làm việc chung (G01) không đổi khung của channel đã bật khung riêng.

AC09: Channel hệ thống "Chưa phân loại" không có công tắc "Khung giờ riêng"; task của channel này luôn theo lịch làm việc chung (D3).

AC10: Số ngày bị hoãn của task tính theo lịch **hiện tại** của task: đổi khung giờ channel hoặc đổi channel của task có thể làm số này thay đổi (D4, QC-04 mục 1).

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Thời gian ghi task | Từ mở ô soạn đến Enter | ≤ 5 giây (trung vị) |
| Tỉ lệ task có thời lượng | Task có planned / task tạo mới | ≥ 85% |
| Tỉ lệ giữ gợi ý AI | Task giữ nguyên thời lượng gợi ý / task có gợi ý (chỉ người dùng bật trợ lý AI) | ≥ 60% |
| Tỉ lệ task có channel khác "Chưa phân loại" | Task có channel thật / tổng task | ≥ 80% |
| Tỉ lệ hoàn tác | Hoàn tác / (xoá + hoàn thành) | Theo dõi (cao bất thường = UI dễ bấm nhầm) |
| Task khôi phục từ Thùng rác | Số lần khôi phục / tuần | Theo dõi |
| Channel có khung giờ riêng | Người dùng có ≥ 1 channel bật khung giờ riêng / người dùng hoạt động tuần | Theo dõi |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Gợi ý thời lượng / channel | Gợi ý phụ thuộc trợ lý AI qua Claude Code CLI trên máy người dùng (Q33): trợ lý tắt hoặc không có Claude Code thì không có gợi ý; Claude Code có thể chậm hoặc hết hạn mức của gói Claude | Ô soạn không chờ gợi ý; quá thời gian thì bỏ qua; ẩn gợi ý khi độ tin cậy thấp; không gọi LLM nào khác |
| Khung giờ channel | Nhiều lịch cùng lúc (lịch chung + khung channel) dễ làm người dùng khó hiểu vì sao projection, sức chứa hay "ngày làm việc kế tiếp" khác nhau giữa các task | Tooltip trên card nêu lịch đang áp ("Theo khung #{channel}"); quy tắc tính ở một chỗ (QC-02 mục 5–9) |
| AI hoàn thành / xoá task | Claude Code thao tác sai trên nhiều task | Mặc định tắt; công tắc riêng, áp cho cả subtask; không bao giờ hoàn thành hay xoá task có liên kết tích hợp (D10); chip "AI" và Hoàn tác (QC-12) |
| Đồng bộ nhiều thiết bị | Hai máy sửa cùng task, hoặc máy offline sửa task mà job hệ thống (rollover) vừa đổi | Theo QC-08: cụm vị trí {trạng thái, ngày dự định, bucket, lưu trữ, số ngày bị hoãn} ghi nguyên khối, lệnh offline trên phiên bản cũ bị từ chối; trường khác gộp theo từng trường, thứ tự theo server nhận; notes dùng CRDT (thiết kế kỹ thuật mục 6) |
| Phím tắt một chữ | Gõ khi chưa focus ô nhập kích hoạt lệnh (đã gặp trên Sunsama) | Phím tắt chỉ chạy khi không focus ô nhập; lệnh có tác dụng phụ có toast Hoàn tác |
| Lấy tiêu đề từ URL | Trang chậm, chặn bot, URL nội bộ | Timeout 3 giây, chặn IP nội bộ, fallback dùng URL |
| Thùng rác 30 ngày | Tăng dung lượng lưu trữ | Job xoá vĩnh viễn hằng ngày |

# 10. Câu hỏi mở

- Đã chốt 04/11/2026: Thùng rác giữ 30 ngày, khác có chủ đích với 7 ngày của Sunsama (Q28).
- Esc giữ bản nháp hay bỏ luôn như Sunsama?
- Đã chốt 04/11/2026: channel mặc định là channel hệ thống "Chưa phân loại", tạo khi đăng ký, không xoá được; `work` / `personal` chỉ là context (B4).
- Có cho chọn nhiều task để xoá / chuyển channel cùng lúc ở 1.0 không?
- Comment ở 1.0 có cần không, khi bản 1 chỉ có một người dùng (Q35)? Nếu giữ thì comment chỉ là ghi chú theo thời gian của chính người dùng.
- Channel hệ thống "Chưa phân loại" thuộc context nào (hay đứng riêng), có đổi tên / ẩn được không?
- Bỏ hoàn thành ở ngày làm việc khác đưa instance lặp về hôm nay: nếu hôm nay đã có instance của cùng series thì áp QC-06 theo đường tự động (lưu trữ `skipped`) hay thủ công (cảnh báo)?
- Xoá subtask đã có bản ghi thời gian: bản ghi đó còn tính vào thời gian thực tế của task không (QC-07 mới nói task đã xoá)?
- Đã chốt 04/11/2026: gợi ý thời lượng / channel dùng trợ lý AI qua Claude Code CLI; trợ lý tắt hoặc không có Claude Code thì không có gợi ý AI; không gọi LLM nào khác (Q33, QC-12).
- Đã chốt 04/11/2026: bỏ lưu trữ thủ công (`manual`) khỏi 1.0, để bản sau (Q34).
- Đã chốt 04/11/2026: bản 1 chỉ một người dùng; người dùng tạo channel tự do; quyền tạo channel chung / riêng tư, giao task, follow để bản sau (Q35). Task được giao (bản sau) vào bucket "Tuần sau", đặt lên đầu (Q36).
- Đã chốt 04/11/2026: G02 sở hữu cài đặt khung giờ channel; lịch của task = khung channel nếu có, ngược lại lịch chung (Q38a, QC-02 mục 5–9).
- Đã chốt 04/11/2026: AI chỉ hoàn thành / xoá task khi người dùng bật công tắc; công tắc áp cho cả subtask; task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá (Q46, D10, QC-12 mục 4).
- Đã chốt 04/11/2026: nền tảng 1.0 là app Windows (Flutter), 1.1 web + macOS, 1.2 iOS / Android (Q45, ADR-0005).
- Đã chốt 04/11/2026: khung giờ channel một khoảng mỗi ngày, không vắt qua nửa đêm, bước 15 phút (D1).
- Đã chốt 04/11/2026: đổi khung giờ channel có hiệu lực từ ngày làm việc kế tiếp (D2).
- Đã chốt 04/11/2026: channel hệ thống "Chưa phân loại" không có khung giờ riêng, luôn theo lịch chung (D3).
- Đã chốt 04/11/2026: phím toàn cục Ctrl+Shift+A (thêm task) có ở 1.0 trên app Windows (D11).
