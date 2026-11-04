> **Mã:** PLN-SRS-G08-WEB · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g08-daily-rituals.md

# UC-G08 - Daily planning & Daily shutdown trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả Daily planning (luồng thủ công), Daily shutdown, chia sẻ kết quả ritual, tự kích hoạt / nhắc ritual và cài đặt ritual ngày. **Các bước Daily shutdown chưa kiểm chứng trên Sunsama**, là đề xuất. Task (G02), board và khối lượng (G04), lịch và timebox (G05), backlog và rollover (G06), timer (G07), ritual tuần và objective (G09), Planning Agent và highlights AI (G10), Slack / Teams (G11), thông báo và chế độ chỉ đọc (G12) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> Đã sửa theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). Quy tắc dùng chung (`QC-xx`) xem [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); thuật ngữ xem [`CONTEXT.md`](../../CONTEXT.md). Mọi "ngày", "hôm nay", "hôm qua", "ngày mai" trong tài liệu này là ngày làm việc (QC-01); "Ngày mai" ở shutdown là ngày làm việc kế tiếp (QC-02).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng mở đầu ngày bằng một kế hoạch vừa sức, kết thúc ngày với việc còn lại đã có chỗ; kết quả ritual được ghi lại và gửi đi trong 1 thao tác |
| Actor | Người dùng đã đăng nhập · Hệ thống · Job \[ritual.prompt\] · Dịch vụ gửi email |
| Phạm vi | Daily planning 6 bước, Daily shutdown 5 bước, lưu tiến độ, tự kích hoạt / nhắc (chỉ ngày làm việc), ritual vắt qua mốc đầu ngày, task ghi chép ritual, ảnh chụp kế hoạch khi hoàn tất Daily planning, chia sẻ (lưu vào task, gửi bản sao cho mình, email), điểm mở rộng cho G09, Cài đặt → Ritual (phần ngày) |
| Ngoài phạm vi | Planning Agent, highlights AI (G10, 1.2; G08 chỉ đặt nút "Hoàn tác kế hoạch AI", BR-24); Weekly planning / review, objective (G09, 1.1); đích Slack / Teams (G11, 1.2); tab Tích hợp trong bước Thêm task và kéo item vào Backlog (G11 đặc tả, 1.1); rollover (G06); bảng đổi ngày task (QC-05) |
| Nền tảng | Web (desktop, mobile web) ở 1.0. App iOS / Android, desktop từ 1.1 dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Được dẫn qua các bước lên kế hoạch mỗi sáng | Bắt đầu ngày có chủ đích |
| US-02 | Người dùng | Quyết định nhanh từng task chưa xong từ hôm qua | Danh sách hôm nay không phình vì việc cũ |
| US-03 | Người dùng | Thấy tổng thời lượng so với thời gian trống và giờ dự kiến xong | Không nhận quá nhiều việc |
| US-04 | Người dùng | Có sẵn bản kế hoạch dạng văn bản, gửi được cho người khác | Không phải gõ lại báo cáo |
| US-05 | Người dùng | Kết thúc ngày bằng một bước tổng kết và xử lý việc còn lại | Dừng làm đúng giờ, ngày mai đã có chỗ cho việc dở |
| US-06 | Người dùng | Thoát giữa chừng rồi quay lại đúng bước | Không mất công đã làm |
| US-07 | Người dùng | Chỉ được nhắc một lần mỗi ngày | Không bị làm phiền |
| US-08 | Người dùng thành thạo | Mở ritual bằng P / O, chuyển bước bằng ← / →, ẩn bước không cần | Làm ritual nhanh |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Phiên ritual.** Mỗi (người dùng, loại, ngày D) có tối đa 1 phiên (`ritual_sessions` UNIQUE(user, type, date)). Loại: `daily_planning`, `daily_shutdown`. D là ngày làm việc theo QC-01 (mốc đầu ngày mặc định 04:00) |
| BR-02 | **Ngày cho phép.** Daily planning: D từ hôm nay đến hôm nay + 7 ngày `[giả định]`. Daily shutdown: chỉ hôm nay, trừ phiên đang làm vắt qua mốc đầu ngày (BR-21). D < hôm nay → chỉ xem phiên đã có, không tạo phiên mới. Mở tay vào ngày nghỉ (ngày không thuộc lịch làm việc, QC-02) vẫn được |
| BR-03 | **Tự kích hoạt Daily planning** khi đủ: cài đặt bật; hôm nay là ngày làm việc theo lịch làm việc (QC-02); giờ hiện tại ≥ giờ Daily planning (mặc định 09:00) và < giờ Daily shutdown của hôm nay; phiên Daily planning hôm nay ở `CHUA_BAT_DAU`; phiên Daily shutdown hôm nay chưa `HOAN_TAT`; `autoPromptedAt` trống (C22). Server ghi `autoPromptedAt` nguyên tử, chỉ thiết bị đầu tiên được tự mở. Tối đa 1 lần / ngày. Vắng nhiều ngày → chỉ xét hôm nay, không tạo phiên hay nhắc cho ngày đã qua (EC-27) |
| BR-04 | **Nhắc Daily shutdown.** Hôm nay là ngày làm việc (QC-02); tới giờ shutdown (mặc định = giờ kết thúc làm việc của hôm nay theo lịch làm việc, 17:00 `[giả định]`), cài đặt bật, phiên shutdown hôm nay chưa `HOAN_TAT` / `BO_QUA` → 1 thông báo (kênh theo G12) có "Bỏ qua hôm nay" (C24); không tự mở `[giả định]`. Tối đa 1 lần / ngày |
| BR-05 | **Lưu tiến độ.** Mỗi lần chuyển bước hoặc sửa nội dung (debounce 1s) lưu `current_step` và `data` của phiên. Mở lại phiên `DANG_LAM` → về `current_step`. Phiên chưa hoàn tất khi D đã qua và hết ân hạn (BR-21) → `QUA_HAN`, trừ phiên lên kế hoạch lại (BR-22); `data` giữ 7 ngày rồi xoá `[giả định]` |
| BR-06 | **Bước Xem lại hôm qua.** Danh sách = task `KE_HOACH`, ngày dự định = D, số ngày bị hoãn ≥ 1 (QC-04 mục 4); với D > hôm nay: task `KE_HOACH` có ngày dự định = ngày làm việc liền trước D. D = hôm nay → gọi API "đảm bảo rollover" \[RolloverEnsure\] của G06 (B6) trước khi tải; API chạy bù hoặc chờ lượt rollover xong rồi mới trả. Trả `CHO_SHUTDOWN` (phiên shutdown hôm qua còn trong ân hạn, BR-21) hoặc `THAT_BAI` → vẫn tải danh sách hiện có, hiện MSG-32, tự tải lại khi rollover xong (realtime). Thao tác: Giữ (mặc định, không đổi gì); Dời "Ngày mai" / phím D (= ngày làm việc kế tiếp, QC-05 dòng "Phím D": không reset số ngày bị hoãn) hoặc chọn ngày (QC-05 dòng "Kéo sang ngày khác, chọn ngày": reset); Backlog (chọn bucket, QC-05 dòng "Đưa vào backlog"); Xong (QC-05 dòng "Hoàn thành", ngày hoàn thành = ngày làm việc của thời điểm bấm, QC-01). Instance lặp rơi vào ngày đã có instance cùng series → QC-06. Thao tác áp ngay, có Hoàn tác |
| BR-07 | **Bước Thêm task.** Nguồn ở 1.0: Lịch (sự kiện ngày D, G05), Backlog (G06; bucket "Tuần tới" lên đầu `[giả định]`), task mới (G02). Kéo sự kiện lịch → tạo task tiêu đề = tên sự kiện, planned = thời lượng sự kiện, kèm **timebox liên kết sự kiện** của G05 (G05 \[TimeboxLink\], B8): không tạo hay đẩy sự kiện mới ra lịch ngoài, giờ đi theo sự kiện gốc, không tính xung đột, không trừ thời gian trống hai lần (BR-08). Một sự kiện chỉ tạo 1 task. Nguồn Objective tuần (G09) ẩn ở 1.0. Tab Tích hợp và kéo item vào Backlog do G11 đặc tả (1.1, C34); ẩn ở 1.0 |
| BR-08 | **Bước Kiểm tra khối lượng** không tự tính mà dùng số liệu ngày của G04 (\[DayGet\]): sức chứa **còn lại** (G04 BR-04; hôm nay tính từ max(bây giờ, giờ bắt đầu làm), C22), quá tải và cờ `VUOT_NGUONG` (G04 BR-05, B7: chỉ tính planned của task chưa xong), cờ "vượt giờ làm" (B7). Task có timebox liên kết sự kiện không bị tính hai lần (B8). Quá tải không chặn chuyển bước |
| BR-09 | **Giờ dự kiến xong** = thời điểm kết thúc muộn nhất của projection / timebox các task chưa xong ngày D (G04, G05), tính từ max(bây giờ, giờ bắt đầu làm việc). So với "giờ kết thúc ngày" (mặc định = giờ Daily shutdown; sửa ở bước Chốt chỉ áp cho ngày D, lưu trong `data`). Muộn hơn → cảnh báo, không chặn. Plan lúc 00:00 – trước mốc đầu ngày thuộc ngày làm việc trước đó (QC-01) |
| BR-10 | **Bản kế hoạch.** Tiêu đề "Kế hoạch hôm nay"; mỗi dòng "{tiêu đề} ({planned})" theo thứ tự board ngày D, gồm task đã xong ngày D (đánh ✓), trừ task ghi chép ritual (BR-27). Theo "Tuỳ chỉnh": phân bổ thời gian (mặc định bật), subtask, task riêng tư (task ở channel private), channel, task đã xong ngày trước (mặc định tắt `[giả định]`). Áp cho cả bản lưu và bản gửi. Sửa tay → `planEdited = true`; "Làm mới" khi `planEdited` → hỏi MSG-14 |
| BR-11 | **Hoàn tất ritual** trong 1 giao dịch: phiên → `HOAN_TAT`, `completedAt` (lần đầu ghi thêm `firstCompletedAt`, không đổi về sau); tạo task ghi chép (hoặc cập nhật task `noteTaskId` nếu đã có): tiêu đề "Daily planning" / "Daily shutdown", ngày dự định = D, đã xong, `isRitualNote = true`, channel = "Channel cho task ritual", notes = nội dung đã chốt; ghi bản ghi thời gian theo BR-12; với `daily_planning` lưu **ảnh chụp kế hoạch** `planSnapshot` (B12): danh sách task `KE_HOACH` của D (id, planned, có timebox hay không), tổng planned, thời gian trống còn lại, cờ quá tải và "vượt giờ làm" (BR-08), thời điểm chụp. Lên kế hoạch lại rồi hoàn tất → lưu thêm bản mới, giữ bản lần đầu; G09 dùng bản lần đầu `[giả định]`. Xếp hàng chia sẻ (BR-14). Idempotent theo Idempotency-Key |
| BR-12 | **Thời gian ritual** = tổng thời gian wizard hiển thị (tab đang mở) từ lần mở đầu tới hoàn tất, bỏ khoảng không tương tác > 5 phút, tối đa 120 phút / lần `[giả định]`. Ghi một bản ghi thời gian `source = ritual` qua G07 \[TimeEntryCreate\] theo QC-07 mục 1–2: chỉ tạo khi lúc hoàn tất người dùng **không có timer đang chạy**; có timer đang chạy → G07 trả `skipped: true`, không tạo bản ghi, task ghi chép vẫn được tạo. Ritual không dùng, không dừng timer (G07). Bản ghi thuộc ngày làm việc của `startedAt` (QC-07). Lên kế hoạch lại → thêm bản ghi mới vào cùng task ghi chép, cùng điều kiện |
| BR-13 | **Không hoàn tất không ghi (EC-26).** Mở, xem, chuyển bước, thoát, `BO_QUA`, `QUA_HAN` không tạo task ghi chép, bản ghi thời gian và ảnh chụp kế hoạch (Sunsama có tạo; khác có chủ đích). Thao tác trên task trong các bước (dời, backlog, xong, tạo, timebox) vẫn giữ vì đó là thao tác của G02 / G05 / G06 |
| BR-14 | **Chia sẻ.** Đích: (a) Lưu vào task ritual — luôn bật; (b) Gửi bản sao cho chính tôi — email chính của tài khoản; (c) đích thêm — email (1.0), Slack / Teams (1.2, G11). Tối đa 10 đích / người dùng; 20 email chia sẻ / người dùng / ngày `[giả định]`. Chỉ gửi sau hoàn tất. Lựa chọn bật / tắt nhớ riêng theo loại ritual. Gửi bất đồng bộ, thử lại 3 lần trong 30 phút `[giả định]`; vẫn lỗi → thông báo trong app có "Thử lại". Email gửi từ địa chỉ hệ thống, reply-to = email người dùng, có link huỷ nhận cho người nhận khác |
| BR-15 | **Shutdown bước Việc đã xong.** Task có `completedAt` thuộc ngày D (trừ task ghi chép ritual, BR-27), mỗi dòng "actual / planned"; tổng actual; phân bổ actual theo channel (thời gian thực tế theo QC-07 mục 5). Có timer đang chạy → bước này hiện banner nhắc MSG-27 kèm "Dừng timer" (G07); hệ thống không tự dừng timer (Q14, QC-05) |
| BR-16 | **Shutdown bước Xử lý task chưa xong.** Task `KE_HOACH` có ngày dự định = D: "Ngày mai" (mặc định `[giả định]`) = ngày làm việc kế tiếp của D (QC-02), áp QC-05 dòng "Shutdown 'Ngày mai'": timebox giữ giờ và dời sang ngày mới, sự kiện ngoài cập nhật theo (timebox liên kết sự kiện: chỉ gỡ liên kết, theo G05 BR-21), timer không dừng, số ngày bị hoãn **không** reset (QC-04); instance lặp rơi vào ngày đã có instance cùng series → QC-06 mục 2 (`LUU_TRU` lý do `skipped`, toast Hoàn tác). Backlog (chọn bucket) → QC-05 dòng "Đưa vào backlog". Xong → QC-05 dòng "Hoàn thành". "Áp dụng cho tất cả: Ngày mai" theo cùng quy tắc. Áp ngay, có Hoàn tác (khôi phục cả liên kết timebox, QC-05) |
| BR-17 | **Highlights 1.0** sinh sẵn danh sách task đã xong ("- {tiêu đề}"), sửa tay, 0–5.000 ký tự. Từ 1.2, nháp do AI soạn (G10) điền vào cùng ô, người dùng duyệt trước khi lưu |
| BR-18 | **Ẩn bước.** "Bỏ qua bước này từ lần sau" lưu vào cài đặt `ritual.skippedSteps`, áp từ lần mở sau; **không** ẩn được bước Chia sẻ của mọi ritual (nơi có nút "Bắt đầu ngày" / "Hoàn tất") và bước Hoàn tất của shutdown (C24). Bật lại trong Cài đặt → Ritual |
| BR-19 | **Chỉ đọc (bản 1.1).** Theo QC-09 dòng "Ritual (G08)": không mở phiên mới; phiên đang `DANG_LAM` lúc vào chỉ đọc được hoàn tất, kể cả các thao tác task bên trong, trong 2 giờ (EC-34). Bản 1.0 không có chế độ chỉ đọc (Q10) |
| BR-20 | **Phím tắt.** P mở Daily planning, O mở Daily shutdown, ← / → chuyển bước, Esc thoát (lưu tiến độ). Chỉ chạy khi không focus ô nhập; trong các bước, D / Z / C dùng như trên board |
| BR-21 | **Ritual vắt qua mốc đầu ngày (Q18).** Phiên `DANG_LAM` của ngày D có `startedAt` trước mốc đầu ngày D+1 được hoàn tất cho D tới tối đa **2 giờ** sau mốc (ân hạn); mọi bước vẫn tính theo D (danh sách, "Ngày mai" = ngày làm việc kế tiếp của D), hoàn tất ghi vào D. Trong ân hạn, wizard hiện MSG-30. Hết ân hạn chưa hoàn tất → `QUA_HAN` (hoặc về `HOAN_TAT` nếu là phiên lên kế hoạch lại, BR-22). **Rollover chờ shutdown:** khi người dùng có phiên `daily_shutdown` của D đang `DANG_LAM` lúc tới mốc, lượt rollover cho D của người dùng đó (G06) hoãn tới khi phiên hoàn tất, bị bỏ dở, hoặc hết 2 giờ, cái nào tới trước. "Bỏ dở" = người dùng đóng wizard shutdown (Esc / ×) sau mốc hoặc chọn "Bỏ qua hôm nay" `[giả định]`; khi đó phiên → `QUA_HAN`. Phiên shutdown hoàn tất / bị bỏ dở → G08 báo G06 (sự kiện `ritual.shutdown.closed`) để rollover đang `CHO_SHUTDOWN` chạy ngay (G06 BR-20). Phiên mở **sau** mốc luôn thuộc ngày làm việc mới |
| BR-22 | **Lên kế hoạch lại / Làm lại (Q18).** Từ phiên `HOAN_TAT`, "Lên kế hoạch lại" (planning) / "Làm lại" (shutdown) → `DANG_LAM` bước 1, giữ `firstCompletedAt`, `noteTaskId`, nội dung đã chốt và ảnh chụp kế hoạch lần đầu. Trong lúc làm lại, phiên vẫn được coi là đã hoàn tất cho mọi phép tính (chuỗi ngày, analytics G09, BR-03 / BR-04 không nhắc lại). Hoàn tất lại → áp BR-11 (cập nhật task ghi chép cũ). Không hoàn tất lại trước khi hết ngày D (kể cả ân hạn BR-21) → phiên quay về `HOAN_TAT` với nội dung cũ, bỏ bản nháp; không bao giờ chuyển sang `QUA_HAN` |
| BR-23 | **Ritual theo lịch làm việc (Q19).** G08 đọc lịch làm việc của G01 (QC-02): ngày nghỉ không tự mở Daily planning (BR-03), không nhắc Daily shutdown (BR-04), không có chấm nhắc ở sidebar; mở tay vẫn được (BR-02). Mọi lựa chọn "Ngày mai" trong ritual = ngày làm việc kế tiếp. Ngày lễ chưa hỗ trợ ở 1.0: người dùng dùng "Bỏ qua hôm nay" (QC-02 mục 4) |
| BR-24 | **Hoàn tác kế hoạch AI (bản 1.2, Q31a).** Khi Planning Agent (G10) đã áp dụng ngay kế hoạch cho ngày D và đề xuất còn thay đổi chưa hoàn tác, bước Daily plan (SCR-06) hiện nút "Hoàn tác kế hoạch AI" → G10 UC-04 (\[ProposalUndo\] mọi thay đổi của đề xuất); sửa đổi của người dùng sau AI được giữ theo G10. Sau khi hoàn tác: `planEdited = false` → sinh lại bản kế hoạch (BR-10); `planEdited = true` → hỏi MSG-14. Kế hoạch có dùng dữ liệu tích hợp đi qua bước duyệt của G10 (Q21), không áp dụng ngay |
| BR-25 | **Điểm mở rộng cho G09 (C24).** G08 cung cấp cho G09 (1.1): (a) `ritual_sessions` nhận thêm `type` = `weekly_planning` / `weekly_review` với `date = weekStart`; BR-02 không áp cho hai loại này, cửa sổ ngày do G09 quy định; (b) khung SCR-01, SCR-07, task ghi chép (BR-11 – BR-14), BR-21, BR-22 dùng chung; (c) nguồn "Objective tuần" trong bước Thêm task (BR-07); (d) G09 BR-04 được chạy Weekly planning trước Daily planning tự mở và giữ `autoPromptedAt` của Daily planning; (e) ảnh chụp kế hoạch (BR-11) đọc qua \[RitualGet\] `planSnapshot` hoặc \[PlanSnapshotList\] |
| BR-26 | **Xung đột phiên giữa thiết bị (C23).** \[RitualUpdate\] / \[RitualComplete\] gửi `If-Match`. 409 `RITUAL_ALREADY_COMPLETED` (phiên đã hoàn tất ở thiết bị khác) → MSG-15, mở bản đã chốt ở chế độ xem; nội dung đang sửa ở máy này giữ trong bản nháp cục bộ tới hết ngày D `[giả định]`. 412 `PRECONDITION_FAILED` (khác phiên bản) → tải lại phiên, gộp `data` theo từng trường (QC-08 mục 3: trường máy này vừa sửa thắng vì server nhận sau), gửi lại một lần; trường của người dùng bị ghi đè → MSG-29 |
| BR-27 | **Task ghi chép ritual không tính vào phép đếm task (C21).** Task có `isRitualNote = true` bị loại khỏi mọi phép đếm số task (task xong, tiến độ theo số task, "{n} task xong" ở SCR-11, ngưỡng "ít dữ liệu" và tỉ lệ hoàn thành của G09) và khỏi danh sách việc đã xong / bản kế hoạch. Bản ghi thời gian của nó vẫn tính vào giờ thực tế (QC-07) |

## 4. Trạng thái

### 4.1. Trạng thái phiên ritual (theo loại và ngày D)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHUA_BAT_DAU` | Chưa có phiên cho (loại, D), hoặc có phiên nhưng chưa vào bước nào (chỉ có `autoPromptedAt`) | Mục sidebar có chấm nhắc sau giờ ritual |
| `DANG_LAM` | Có `startedAt`, `completedAt` trống; D ≥ hôm nay, hoặc D = hôm qua và đang trong ân hạn 2 giờ (BR-21). Có `firstCompletedAt` = đang lên kế hoạch lại (BR-22) | Sidebar "Đang dở · bước {n}/{tổng}"; mở lại về `current_step`. Trong ân hạn: MSG-30 |
| `HOAN_TAT` | `completedAt` có giá trị | Mở ra bản đã chốt ở chế độ xem + "Lên kế hoạch lại" / "Làm lại"; task ghi chép trên board |
| `BO_QUA` | Người dùng chọn "Bỏ qua hôm nay" ở lời nhắc (cả planning và shutdown, C24) | Không nhắc, không tự mở trong ngày; vẫn mở tay được |
| `QUA_HAN` | D đã qua (đã tới mốc đầu ngày D+1), hết ân hạn BR-21 hoặc bị bỏ dở, chưa từng `HOAN_TAT` (`firstCompletedAt` trống) | Không nhắc, không làm bù; chỉ xem `data` trong 7 ngày |

Chuyển trạng thái: `CHUA_BAT_DAU` → `DANG_LAM` (mở, UC-01 / UC-02) · `CHUA_BAT_DAU` → `BO_QUA` (UC-04, cả hai loại) · `BO_QUA` → `DANG_LAM` (mở tay) · `DANG_LAM` → `HOAN_TAT` (BR-11; kể cả trong ân hạn BR-21) · `HOAN_TAT` → `DANG_LAM` ("Lên kế hoạch lại" / "Làm lại", giữ `firstCompletedAt`, `noteTaskId`, BR-22) · `DANG_LAM` có `firstCompletedAt` → `HOAN_TAT` với nội dung cũ (hết ngày D và ân hạn mà chưa hoàn tất lại, BR-22) · `CHUA_BAT_DAU` / `BO_QUA` → `QUA_HAN` (tới mốc đầu ngày D+1) · `DANG_LAM` không có `firstCompletedAt` → `QUA_HAN` (hết ân hạn 2 giờ sau mốc đầu ngày D+1, hoặc bị bỏ dở sau mốc, BR-21). `HOAN_TAT` không bao giờ chuyển sang `QUA_HAN`. Chỉ `DANG_LAM` → `HOAN_TAT` tạo hoặc cập nhật task ghi chép (BR-13).

### 4.2. Trạng thái bước wizard

`HIEN` ⇄ `AN`. "Bỏ qua bước này từ lần sau" → `AN` (BR-18); bật lại trong Cài đặt → `HIEN`. Bước `AN` bị nhảy qua khi chuyển bước.

### 4.3. Trạng thái gửi chia sẻ (mỗi đích, mỗi lần hoàn tất)

`CHO_GUI` → `DA_GUI` | `LOI` (sau 3 lần thử, BR-14). `LOI` → `CHO_GUI` khi bấm "Thử lại". Đích "Lưu vào task ritual" luôn `DA_GUI` ngay khi hoàn tất.

## 5. Use Case

### UC-01 Daily planning (luồng thủ công)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; D hợp lệ theo BR-02; workspace không chỉ đọc (từ 1.1), hoặc phiên đã `DANG_LAM` (BR-19) |
| Hậu điều kiện thành công | Phiên `HOAN_TAT`; task ghi chép "Daily planning" đã xong ở ngày D; ảnh chụp kế hoạch đã lưu (BR-11); chia sẻ đã xếp hàng; màn hình chuyển tới Home / Today theo cài đặt |
| Hậu điều kiện thất bại | Phiên giữ `DANG_LAM` ở bước đang làm; không có task ghi chép; thao tác task đã làm trong các bước vẫn giữ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Nhấn P, bấm "Daily planning" ở sidebar, nút "Plan" trên cột ngày D (G04), hoặc lời nhắc MSG-01 (UC-04) |
| 2 | Hệ thống | Gọi \[RitualGet\] `daily_planning` D; chưa có phiên → tạo `DANG_LAM`, `current_step = 1`; D = hôm nay → gọi \[RolloverEnsure\] của G06 (BR-06, B6); mở **SCR-01** với **SCR-02** |
| 3 | Người dùng | **Bước 1 – Xem lại hôm qua (SCR-02):** với từng task chọn Giữ / Dời (D) / Backlog (Z) / Xong (C); bấm "Tiếp" hoặc → |
| 4 | Hệ thống | Áp thao tác ngay qua API nhóm sở hữu (G06 \[TaskMove\], G02 \[TaskComplete\]), toast Hoàn tác; \[RitualUpdate\] `current_step = 2` |
| 5 | Người dùng | **Bước 2 – Thêm task cho hôm nay (SCR-03):** kéo sự kiện lịch, task backlog vào danh sách D, hoặc gõ task mới; "Tiếp" |
| 6 | Hệ thống | Tạo / chuyển task (G02, G06, BR-07); cập nhật tổng ngày qua `day.recomputed` (G04); \[RitualUpdate\] `current_step = 3` |
| 7 | Người dùng | **Bước 3 – Kiểm tra khối lượng (SCR-04):** xem tổng thời lượng và thời gian trống; dời bớt task nếu cần; "Tiếp" |
| 8 | Hệ thống | Tính quá tải theo BR-08; quá tải → MSG-03 và chấm cảnh báo trên task vượt; luôn hiện mẹo MSG-04; \[RitualUpdate\] `current_step = 4` |
| 9 | Người dùng | **Bước 4 – Chốt (SCR-05):** sắp thứ tự, kéo task vào lịch ngày để timebox, đặt giờ kết thúc ngày; "Tiếp" |
| 10 | Hệ thống | Timebox qua G05; tính giờ dự kiến xong (BR-09), hiện MSG-05 hoặc MSG-06; \[RitualUpdate\] `current_step = 5`, `data.endOfDay` |
| 11 | Người dùng | **Bước 5 – Daily plan (SCR-06):** đọc / sửa bản kế hoạch, nhập "Trở ngại", chọn "Tuỳ chỉnh"; "Tiếp" |
| 12 | Hệ thống | Sinh bản kế hoạch theo BR-10; lưu nháp vào `data` (BR-05); \[RitualUpdate\] `current_step = 6` |
| 13 | Người dùng | **Bước 6 – Chia sẻ (SCR-07):** xem trước, chọn đích (UC-03); bấm "Bắt đầu ngày" |
| 14 | Hệ thống | Gọi \[RitualComplete\] (Idempotency-Key): áp BR-11 (kèm ảnh chụp kế hoạch), BR-12, xếp hàng BR-14; toast MSG-09; đóng wizard, chuyển tới Home / Today theo cài đặt |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phiên đang `DANG_LAM` ở bước n | Mở về `current_step`, giữ dữ liệu đã nhập (BR-05) |
| A2 | Phiên đã `HOAN_TAT` | Mở SCR-06 chế độ xem; "Lên kế hoạch lại" → `DANG_LAM` bước 1, giữ `firstCompletedAt` (BR-22); hoàn tất lại cập nhật task ghi chép cũ, thêm bản ghi thời gian (BR-12); bỏ dở tới hết ngày D → phiên về `HOAN_TAT` với nội dung cũ (BR-22) |
| A3 | Bước ở trạng thái `AN` (BR-18) | Nhảy qua bước đó khi chuyển bước; thanh bước hiện bước ẩn màu xám, bấm vào vẫn xem được |
| A4 | Người dùng bấm ← / "Quay lại" | Về bước trước, giữ nguyên dữ liệu các bước |
| A5 | Esc / × giữa chừng | Lưu `current_step`, `data`; đóng wizard; toast MSG-16; không tạo task ghi chép (BR-13, EC-26) |
| A6 | D > hôm nay (nút "Plan" trên cột tương lai) | Bước 1 liệt kê task chưa xong của ngày trước D (BR-06); "Bắt đầu ngày" đổi thành "Xong", không chuyển trang |
| A7 | Bước 1 không có task | Hiện MSG-17, nút "Tiếp" |
| A8 | Bước 2 kéo sự kiện đã có task | Không tạo thêm; toast MSG-28 "Mở task" |
| A9 | Bước 5 bấm "Làm mới" khi `planEdited` | Dialog MSG-14; đồng ý → sinh lại bản kế hoạch, giữ ô "Trở ngại" |
| A10 | Bấm "Bỏ qua bước này từ lần sau" | Bước → `AN` (BR-18), toast MSG-21 có Hoàn tác; vẫn ở bước hiện tại lần này |
| A11 | Qua mốc đầu ngày khi đang làm (ví dụ bắt đầu 03:55, mốc 04:00) | Theo BR-21: phiên giữ ngày D, hoàn tất được cho D tới 06:00; wizard hiện MSG-30; danh sách bước 1–4 vẫn là của D. Rollover cho D có thể chạy trong lúc này (rollover chỉ chờ phiên shutdown); task bị rollover biến mất khỏi danh sách D qua realtime, không làm lỗi "Bắt đầu ngày". Quá 06:00 chưa hoàn tất → `QUA_HAN` (hoặc về `HOAN_TAT` nếu đang lên kế hoạch lại, BR-22), wizard đóng với MSG-31 |
| A12 | Phiên vừa hoàn tất ở thiết bị khác | \[RitualUpdate\] / \[RitualComplete\] trả 409 → MSG-15; mở bản đã chốt ở chế độ xem (BR-26) |
| A13 | Phiên bị sửa ở thiết bị khác (412) | Tải lại phiên, gộp `data` theo từng trường, gửi lại; trường bị ghi đè → MSG-29 (BR-26) |
| A14 | Bản 1.2: Planning Agent đã áp dụng kế hoạch cho D | SCR-06 hiện "Hoàn tác kế hoạch AI" (BR-24); bấm → G10 UC-04; xong → sinh lại bản kế hoạch hoặc hỏi MSG-14 |
| A15 | D là ngày nghỉ theo lịch làm việc | Không tự mở, không chấm nhắc (BR-23); mở tay vẫn chạy luồng chính |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | D < hôm nay và chưa có phiên | MSG-20, không mở wizard (BR-02) |
| E2 | Từ 1.1: workspace chỉ đọc khi chưa có phiên | MSG-13, không mở (BR-19); phiên đang `DANG_LAM` vẫn hoàn tất được trong 2 giờ (QC-09, EC-34) |
| E3 | Mất mạng | Wizard chạy trên dữ liệu máy; thao tác task và \[RitualUpdate\] xếp hàng; \[RitualComplete\] xếp hàng cùng Idempotency-Key, email gửi khi có mạng; banner MSG-23 |
| E4 | \[RitualComplete\] lỗi 5xx / timeout | Giữ ở bước 6, MSG-12 "Thử lại" (cùng key, không tạo trùng task) |
| E5 | "Trở ngại" > 5.000 ký tự | MSG-22, chặn "Tiếp" |

### UC-02 Daily shutdown

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; D = hôm nay, hoặc phiên D đang trong ân hạn (BR-02, BR-21); workspace không chỉ đọc (từ 1.1), hoặc phiên đã `DANG_LAM` |
| Hậu điều kiện thành công | Phiên `HOAN_TAT`; task chưa xong của D đã có chỗ (ngày làm việc kế tiếp / backlog / xong); task ghi chép "Daily shutdown"; thông điệp cuối ngày hiện; rollover đang chờ (BR-21) được chạy |
| Hậu điều kiện thất bại | Phiên giữ `DANG_LAM`; không có task ghi chép |

Các bước dưới đây là **đề xuất, chưa kiểm chứng trên Sunsama**.

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Nhấn O, bấm "Daily shutdown" ở sidebar, hoặc lời nhắc MSG-02 |
| 2 | Hệ thống | Gọi \[RitualGet\] `daily_shutdown` D; tạo phiên `DANG_LAM` nếu chưa có; mở **SCR-01** với **SCR-08** |
| 3 | Người dùng | **Bước 1 – Việc đã xong (SCR-08):** xem danh sách task xong, tổng thời gian, phân bổ theo channel; "Tiếp" |
| 4 | Hệ thống | Tính theo BR-15; có timer đang chạy → banner MSG-27 (A1); không có task xong → MSG-18; \[RitualUpdate\] `current_step = 2` |
| 5 | Người dùng | **Bước 2 – Xử lý task chưa xong (SCR-09):** chọn Ngày mai (ngày làm việc kế tiếp) / Backlog / Xong cho từng task; "Tiếp" |
| 6 | Hệ thống | Áp ngay theo BR-16 (G06, G02), toast Hoàn tác; \[RitualUpdate\] `current_step = 3` |
| 7 | Người dùng | **Bước 3 – Highlights (SCR-10):** sửa danh sách highlights sinh sẵn; "Tiếp" |
| 8 | Hệ thống | Sinh sẵn theo BR-17, lưu nháp vào `data`; \[RitualUpdate\] `current_step = 4` |
| 9 | Người dùng | **Bước 4 – Chia sẻ (SCR-07):** xem trước, chọn đích (UC-03); bấm "Hoàn tất" |
| 10 | Hệ thống | Gọi \[RitualComplete\]: BR-11 (notes = việc đã xong + highlights), BR-12, BR-14; toast MSG-26 |
| 11 | Hệ thống | **Bước 5 – Hoàn tất (SCR-11):** hiện thông điệp cuối ngày (cài đặt, mặc định MSG-19), tổng thời gian hôm nay, nút "Đóng" về Home |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Timer đang chạy ở bước 1 | SCR-08 hiện MSG-27 với nút "Dừng timer" (G07); hệ thống không tự dừng timer (Q14, BR-15) |
| A2 | Không có task chưa xong ở bước 2 | Hiện "Không còn việc nào dở", nút "Tiếp" |
| A3 | Chọn "Ngày mai" cho task đang chạy timer | Dời theo BR-16; timer **không** dừng (QC-05) |
| A4 | Phiên đã `HOAN_TAT` | Mở SCR-10 chế độ xem + "Làm lại" → `DANG_LAM` bước 1 (BR-22); hoàn tất lại cập nhật task ghi chép cũ; bỏ dở tới hết ngày D → về `HOAN_TAT` với nội dung cũ |
| A5 | Esc / × giữa chừng | Như UC-01 A5; toast MSG-16 (phím O). Sau mốc đầu ngày D+1 → coi là bỏ dở (BR-21): phiên `QUA_HAN`, rollover chạy ngay |
| A6 | Bấm "Bỏ qua bước này từ lần sau" | Như UC-01 A10 (không áp cho bước Chia sẻ, Hoàn tất, BR-18) |
| A7 | Từ 1.2 bật highlights AI (G10) | Bước 3 điền nháp AI; lỗi / chậm > 10 giây → dùng danh sách sinh sẵn của BR-17 |
| A8 | Qua mốc đầu ngày khi đang làm (ví dụ bắt đầu 03:50, mốc 04:00) | BR-21: rollover cho D của người dùng hoãn; danh sách bước 2 không đổi dưới tay người dùng; hoàn tất được cho D tới 06:00, wizard hiện MSG-30; hoàn tất → rollover chạy ngay cho task còn lại. Quá 06:00 → `QUA_HAN`, rollover chạy, wizard đóng với MSG-31 |
| A9 | Thao tác "Ngày mai" đưa instance lặp vào ngày đã có instance cùng series | QC-06 mục 2: instance được đưa vào → `LUU_TRU` lý do `skipped`, toast Hoàn tác |
| A10 | Chọn "Bỏ qua hôm nay" ở lời nhắc MSG-02 | Phiên → `BO_QUA` (C24); không nhắc lại trong ngày |
| A11 | Phiên bị sửa / hoàn tất ở thiết bị khác | Như UC-01 A12, A13 (BR-26) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Từ 1.1: workspace chỉ đọc khi chưa có phiên | MSG-13, không mở (BR-19) |
| E2 | Mất mạng | Như UC-01 E3 |
| E3 | \[RitualComplete\] lỗi | Giữ ở bước 4, MSG-12 "Thử lại" |
| E4 | Highlights > 5.000 ký tự | MSG-22, chặn "Tiếp" |

### UC-03 Chia sẻ kết quả ritual

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đang ở bước Chia sẻ của UC-01 hoặc UC-02 |
| Hậu điều kiện thành công | Nội dung lưu vào task ghi chép; mỗi đích bật có bản ghi gửi `CHO_GUI` → `DA_GUI`; lựa chọn đích được nhớ |
| Hậu điều kiện thất bại | Ritual vẫn hoàn tất; đích lỗi ở `LOI`, có thông báo "Thử lại" |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Gọi \[ShareDestList\]; hiện **SCR-07**: "Lưu vào task ritual" bật cố định, các đích khác bật / tắt theo lần trước của loại ritual này |
| 2 | Người dùng | Bật / tắt "Gửi bản sao cho chính tôi"; bấm "Thêm nơi nhận" → nhập email → Enter |
| 3 | Hệ thống | Kiểm tra định dạng, trùng, ≤ 10 đích (BR-14); gọi \[ShareDestCreate\]; đích mới bật cho lần này |
| 4 | Người dùng | Xem trước nội dung (bản kế hoạch hoặc highlights theo "Tuỳ chỉnh"); bấm "Bắt đầu ngày" / "Hoàn tất" |
| 5 | Hệ thống | Lưu lựa chọn bật / tắt (\[ShareDestUpdate\]); hoàn tất ritual (UC-01 bước 14 / UC-02 bước 10); toast MSG-10 khi có ≥ 1 đích email |
| 6 | Hệ thống | Job gửi từng đích; thành công → `DA_GUI` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Gỡ một đích | Icon × trên dòng → \[ShareDestDelete\] |
| A2 | Chọn Slack / Teams ở 1.0 | Mục hiện "Có ở bản 1.2", không chọn được (G11) |
| A3 | Thoát wizard trước khi bấm hoàn tất | Không gửi gì (PRD 4.4); lựa chọn đích chưa lưu |
| A4 | Bấm "Thử lại" trong thông báo MSG-11 | Gọi \[ShareRetry\] cho đích `LOI` → `CHO_GUI` |
| A5 | Nhập email đã có trong danh sách | Không thêm, nhấp nháy dòng đã có và bật nó |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Email sai định dạng | MSG-07, không thêm |
| E2 | Đích thứ 11 | MSG-08, không thêm |
| E3 | Vượt 20 email chia sẻ / ngày | Ritual vẫn hoàn tất, chỉ lưu vào task; toast MSG-24 |
| E4 | Gửi lỗi sau 3 lần thử | Đích → `LOI`; thông báo trong app MSG-11 có "Thử lại" |

### UC-04 Tự kích hoạt và nhắc ritual

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Cài đặt "Tự kích hoạt" / "Tự nhắc shutdown" bật; người dùng đã đăng nhập ít nhất một thiết bị |
| Hậu điều kiện thành công | Daily planning tự mở đúng 1 lần trong ngày trên 1 thiết bị; shutdown được nhắc 1 lần |
| Hậu điều kiện thất bại | Không tự mở; người dùng vẫn mở tay được |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job \[ritual.prompt\] chạy mỗi 5 phút `[giả định]`, chọn người dùng vừa tới giờ Daily planning / Daily shutdown theo timezone, và hôm nay là ngày làm việc của họ (BR-23) |
| 2 | Hệ thống | Daily planning: kiểm tra BR-03; tạo thông báo trong app MSG-01 (kênh theo G12) và chấm nhắc ở sidebar |
| 3 | Hệ thống | Client đang mở (hoặc lần đầu mở app sau giờ plan) gọi \[RitualGet\]; server trả `autoOpen = true` và ghi `autoPromptedAt` nguyên tử |
| 4 | Hệ thống | Client nhận `autoOpen = true` → mở UC-01 bước 2 |
| 5 | Người dùng | Làm Daily planning (UC-01) / Daily shutdown (UC-02), hoặc chọn "Bỏ qua hôm nay" trên SCR-12 → \[RitualUpdate\] `status = BO_QUA` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Nhiều thiết bị đang mở | Chỉ thiết bị gọi \[RitualGet\] đầu tiên nhận `autoOpen`; thiết bị khác chỉ có chấm nhắc |
| A2 | Vắng nhiều ngày (EC-27) | Chỉ xét hôm nay; không tạo phiên, không nhắc cho ngày đã qua; phiên cũ chưa xong → `QUA_HAN` (phiên lên kế hoạch lại → `HOAN_TAT`, BR-22) |
| A3 | Tới giờ khi người dùng đang gõ trong ô nhập hoặc đang ở Focus (G07) | Không tự mở; hiện SCR-12 dạng banner MSG-01; `autoPromptedAt` vẫn ghi `[giả định]` |
| A4 | Mở app trước giờ plan | Không tự mở; tới giờ khi app đang mở → bước 3 |
| A5 | Daily shutdown tới giờ (BR-04) | Thông báo MSG-02 + chấm nhắc; không tự mở; "Bỏ qua hôm nay" → phiên shutdown `BO_QUA` (C24) |
| A6 | Tắt "Tự kích hoạt" | Không tự mở; vẫn có chấm nhắc ở sidebar `[giả định]` |
| A7 | Đổi timezone / đổi giờ plan sau khi đã tự mở hôm nay | Không mở lại trong ngày D (khoá theo `autoPromptedAt`). Đổi mốc đầu ngày / timezone có hiệu lực từ ngày làm việc kế tiếp (QC-01 mục 3) |
| A8 | Hôm nay là ngày nghỉ theo lịch làm việc (QC-02) | Không tạo thông báo, không tự mở, không chấm nhắc (BR-23) |
| A9 | Lần đầu mở app sau giờ Daily shutdown, hoặc phiên shutdown hôm nay đã `HOAN_TAT` | Không tự mở Daily planning (C22); vẫn mở tay được |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Job lỗi / trễ | Lần quét sau xử lý lại; idempotent theo (người dùng, loại, D); lần đầu mở app vẫn tự mở theo bước 3 |
| E2 | \[RitualGet\] lỗi khi tự mở | Không tự mở, giữ chấm nhắc; không ghi `autoPromptedAt` |

### UC-05 Cài đặt ritual ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Cài đặt lưu và áp dụng ngay trên mọi thiết bị (`settings.changed`) |
| Hậu điều kiện thất bại | Giá trị cũ giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → Ritual (**SCR-13**) |
| 2 | Hệ thống | Gọi \[SettingsGet\] (G01); hiện phần ritual ngày |
| 3 | Người dùng | Đổi một giá trị: giờ Daily planning, tự kích hoạt, sau khi plan đi tới, tự nhắc shutdown, giờ shutdown, thông điệp cuối ngày, channel cho task ritual |
| 4 | Hệ thống | Gọi \[SettingsUpdate\] chỉ với trường đổi; áp ngay (BR-03, BR-04 tính lại cho hôm nay nếu chưa nhắc) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bật lại bước đã ẩn | Bỏ bước khỏi `ritual.skippedSteps` → `HIEN` |
| A2 | Đổi channel cho task ritual | Chỉ áp cho task ghi chép tạo sau |
| A3 | Cài đặt ritual tuần, nháp highlights AI | Hiện cùng trang nhưng thuộc G09 (1.1), G10 (1.2) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Thông điệp cuối ngày > 280 ký tự | MSG-25, không lưu |
| E2 | Channel cho task ritual bị xoá (G02) | Tự về channel mặc định của người dùng, ghi nhật ký |
| E3 | \[SettingsUpdate\] lỗi | Trả giá trị cũ, MSG-12 |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Phím P / O, command menu "Daily planning" / "Daily shutdown" | ✓ | – | Ngày = hôm nay |
| Sidebar "Daily planning" / "Daily shutdown" | ✓ | ✓ | Có chấm nhắc, trạng thái "Đang dở" |
| Nút "Plan" khi hover cột ngày (G04) | ✓ | – | Ngày = cột đó (BR-02) |
| Tự mở (UC-04) | ✓ | ✓ | 1 lần / ngày |
| Thông báo / banner nhắc (SCR-12) | ✓ | ✓ (desktop: thông báo hệ thống) | Kênh theo G12 |
| Mở task ghi chép ritual | ✓ | ✓ | Gợi ý "Dùng phím P để vào Daily planning" |
| Cài đặt → Ritual | ✓ | ✓ | SCR-13 |

## 7. Mô tả màn hình

Ánh xạ bước → màn hình: Daily planning bước 1–6 = SCR-02 → SCR-07; Daily shutdown bước 1–5 = SCR-08, SCR-09, SCR-10, SCR-07, SCR-11. Mọi bước nằm trong khung SCR-01. Mobile web: hai cột của một bước chuyển thành hai tab.

### SCR-01 Khung wizard ritual (dùng chung)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tên ritual + ngày | Header | "Daily planning · Thứ Tư, 04/11"; ngày tương lai có nhãn ngày |
| 2 | Thanh bước | Stepper | Bước hiện tại đậm; bước `AN` màu xám; bấm để nhảy bước |
| 3 | "Đây là gì?" | Link | Popover giải thích bước |
| 4 | "Làm mới" | Button | Tải lại dữ liệu bước; ở bước Daily plan / Highlights → A9 UC-01 |
| 5 | "Bỏ qua bước này từ lần sau" | Link | BR-18; ẩn ở bước Chia sẻ, Hoàn tất |
| 6 | ← "Quay lại" / → "Tiếp" | Button | Phím ← / → khi không focus ô nhập |
| 7 | × | Icon | Thoát, lưu tiến độ (A5 UC-01); với shutdown sau mốc đầu ngày → bỏ dở (BR-21) |
| 8 | Banner ân hạn | Banner | MSG-30 khi phiên đang trong ân hạn (BR-21) |

### SCR-02 Bước 1 – Xem lại hôm qua

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Danh sách task chưa xong | List | BR-06; mỗi dòng: tiêu đề, channel, planned, nhãn "Dời {n} ngày" (n = số ngày bị hoãn, QC-04) |
| 2 | Thao tác theo dòng | Segmented | Giữ (mặc định) · Dời · Backlog · Xong; phím D / Z / C trên dòng đang chọn |
| 3 | Chọn ngày / bucket | Popover | Mở khi chọn Dời / Backlog (G06) |
| 4 | Trạng thái rỗng | Empty state | MSG-17 |

### SCR-03 Bước 2 – Thêm task cho hôm nay

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Danh sách ngày D | List (trái) | Card task (G02), tổng planned ở đầu; kéo đổi thứ tự |
| 2 | Ô "Thêm task" | Input | Ô soạn của G02, ngày = D |
| 3 | Tab nguồn | Tabs (phải) | Lịch · Backlog; Tích hợp (G11 đặc tả, 1.1, C34) và Objective tuần (G09, 1.1) ẩn ở 1.0 |
| 4 | Item nguồn | List | Kéo vào danh sách trái hoặc "+ Hôm nay"; sự kiện → task có timebox liên kết sự kiện (BR-07); sự kiện đã có task → MSG-28 |
| 5 | Lịch chưa kết nối | Hint | "Kết nối lịch để thấy cuộc họp" → G05 |

### SCR-04 Bước 3 – Kiểm tra khối lượng

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tổng planned task chưa xong / thời gian trống còn lại | Thanh so sánh | Đỏ khi quá tải (BR-08), kèm MSG-03; cờ "vượt giờ làm" theo G04 |
| 2 | Danh sách task ngày D | List | Task vượt ngưỡng có chấm cảnh báo; D / Z dời ngay |
| 3 | Mẹo | Callout | MSG-04 |

### SCR-05 Bước 4 – Chốt

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Danh sách task | List (trái) | – | Kéo / Ctrl+↑↓ đổi thứ tự; giờ projection trên card (G04) |
| 2 | Lịch ngày D | Calendar (phải) | – | Kéo task vào để timebox (G05); sự kiện thật đậm, projection mờ |
| 3 | Giờ kết thúc ngày | Time picker | Có | Mặc định giờ Daily shutdown; bước 5 phút; phải sau giờ bắt đầu làm việc |
| 4 | Giờ dự kiến xong | Text | – | MSG-05; muộn hơn mục 3 → MSG-06 màu cam (BR-09) |

### SCR-06 Bước 5 – Daily plan

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Kế hoạch hôm nay" | Rich text | – | Sinh theo BR-10; sửa tay → `planEdited` |
| 2 | "Trở ngại" | Text nhiều dòng | Không | 0–5.000 ký tự; quá → MSG-22 |
| 3 | "Tuỳ chỉnh" | Popover 5 toggle | – | Phân bổ thời gian · Subtask · Task riêng tư · Channel · Task đã xong hôm trước; đổi → sinh lại phần tự sinh |
| 4 | Chế độ xem (phiên `HOAN_TAT`) | Read-only + button | – | "Lên kế hoạch lại" → A2 UC-01 |
| 5 | "Hoàn tác kế hoạch AI" (bản 1.2) | Button phụ | – | Chỉ hiện khi Planning Agent đã áp dụng kế hoạch cho D và còn thay đổi chưa hoàn tác (BR-24); A14 UC-01 |

### SCR-07 Chia sẻ (bước 6 Daily planning, bước 4 Daily shutdown)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Lưu vào task ritual" | Toggle (khoá bật) | – | Luôn bật (BR-14) |
| 2 | "Gửi bản sao cho chính tôi" | Toggle | – | Gửi tới email chính |
| 3 | Danh sách nơi nhận | List toggle | – | Email; Slack / Teams "Có ở bản 1.2"; × gỡ đích |
| 4 | "Thêm nơi nhận" | Email input | – | Định dạng → MSG-07; > 10 → MSG-08 |
| 5 | Xem trước | Preview | – | Nội dung đúng như sẽ gửi |
| 6 | "Bắt đầu ngày" / "Hoàn tất" | Button chính | – | UC-01 bước 14 / UC-02 bước 10; disabled khi đang gửi |

### SCR-08 Shutdown bước 1 – Việc đã xong

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Danh sách task xong | List | BR-15; mỗi dòng "actual / planned", channel |
| 2 | Tổng thời gian | Số lớn | Tổng actual hôm nay, "h:mm" |
| 3 | Phân bổ theo channel | Thanh ngang | Màu theo channel; kèm bảng số cho đọc màn hình |
| 4 | Timer đang chạy | Banner | MSG-27 + "Dừng timer" (A1 UC-02); không tự dừng (Q14) |
| 5 | Trạng thái rỗng | Empty state | MSG-18 |

### SCR-09 Shutdown bước 2 – Xử lý task chưa xong

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Danh sách task chưa xong ngày D | List | Tiêu đề, planned, actual đã có |
| 2 | Thao tác theo dòng | Segmented | Ngày mai (mặc định) · Backlog · Xong (BR-16); phím D / Z / C. Nhãn "Ngày mai" kèm ngày đích, ví dụ "Ngày mai (Thứ Hai, 10/11)" khi ngày làm việc kế tiếp không phải D+1 |
| 3 | "Áp dụng cho tất cả: Ngày mai" | Link | Dời mọi task chưa chọn theo BR-16 (không reset số ngày bị hoãn), toast Hoàn tác |

### SCR-10 Shutdown bước 3 – Highlights

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Highlights | Rich text | Không | Sinh sẵn theo BR-17; 0–5.000 ký tự; quá → MSG-22 |
| 2 | Nhãn nguồn | Badge | – | 1.2: "✨ Nháp AI" khi do G10 soạn |
| 3 | Chế độ xem (phiên `HOAN_TAT`) | Read-only + button | – | "Làm lại" → A4 UC-02 |

### SCR-11 Shutdown bước 5 – Hoàn tất

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Thông điệp cuối ngày | Text lớn | Theo cài đặt; trống → MSG-19 |
| 2 | Tóm tắt | Text | "{n} task xong · {h:mm} thực tế"; n không tính task ghi chép ritual (BR-27) |
| 3 | "Đóng" | Button | Về Home |

### SCR-12 Lời nhắc ritual

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Banner / thông báo | MSG-01 (planning) hoặc MSG-02 (shutdown) |
| 2 | "Bắt đầu" | Button | Mở UC-01 / UC-02 |
| 3 | "Bỏ qua hôm nay" | Link | Có ở cả lời nhắc planning và shutdown (C24); phiên → `BO_QUA` (UC-04 bước 5) |

### SCR-13 Cài đặt → Ritual (phần ngày)

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Giờ Daily planning | Time picker | Có | Bước 5 phút; mặc định 09:00 |
| 2 | Tự kích hoạt Daily planning | Toggle | – | Mặc định bật |
| 3 | Sau khi plan đi tới | Select | Có | Home (mặc định) / Today |
| 4 | Tự nhắc Daily shutdown | Toggle | – | Mặc định bật |
| 5 | Giờ Daily shutdown | Time picker | Có | Mặc định giờ kết thúc làm việc của từng ngày theo lịch làm việc (QC-02) `[giả định]` |
| 10 | Ngày ritual chạy | Text + liên kết | – | "Theo Lịch làm việc: {danh sách ngày}" → mở Lịch làm việc (G01, QC-02); chỉ đọc ở trang này |
| 6 | Thông điệp cuối ngày | Text | Không | 0–280 ký tự; quá → MSG-25 |
| 7 | Channel cho task ritual | Dropdown | Có | Danh sách channel (G02) |
| 8 | Bước đã ẩn | List + "Hiện lại" | – | A1 UC-05 |
| 9 | Ritual tuần, nháp highlights | Liên kết | – | G09 (1.1), G10 (1.2) |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[RitualGet\] `GET /rituals/{type}/{date}` | type, date | status, currentStep, data, autoOpen, completedAt, firstCompletedAt, graceUntil, noteTaskId, planSnapshot, skippedSteps, version | 5s / 1 lần |
| \[RitualUpdate\] `PATCH /rituals/{type}/{date}` | currentStep, data (trường đổi), status (`BO_QUA`), If-Match | Phiên, version | 5s / 2 lần |
| \[RitualComplete\] `POST /rituals/{type}/{date}/complete` | content, obstacles, endOfDay, customize, activeSeconds, shareDestinationIds[], If-Match, Idempotency-Key | Phiên, noteTask, timeEntry (null khi có timer đang chạy, BR-12), planSnapshot (`daily_planning`), shareDeliveries[] | 10s / 3 lần cùng key |
| \[PlanSnapshotList\] `GET /rituals/daily_planning/snapshots?from&to` `[giả định — chưa có trong thiết kế kỹ thuật]` | from, to | Snapshot[] (date, takenAt, tasks[] {id, plannedMin, hasTimebox}, totalPlannedMin, availableMin, overloaded, overWorkHours, isFirst) | 5s / 1 lần |
| \[RolloverEnsure\] `POST /rollover/ensure` (G06) | Không có body | date, status (`XONG` / `DANG_CHAY` / `CHO_SHUTDOWN` / `DONG_BANG` / `THAT_BAI`), waitUntil (B6, G06 BR-19) | Theo SRS G06 |
| \[TimeboxLink\] (G05) | taskId, calendarId, eventId | Timebox liên kết sự kiện (G05 BR-21) | Theo SRS G05 |
| \[TimeEntryCreate\] (G07) | taskId, source = `ritual`, startedAt, durationSec | TimeEntry \| `skipped: true` khi có timer đang chạy (G07 BR-21) | Theo SRS G07 |
| Sự kiện `ritual.shutdown.closed` | userId, date, kết quả (`HOAN_TAT` / `QUA_HAN`) | G06 chạy rollover đang `CHO_SHUTDOWN` (BR-21) | – |
| \[ProposalUndo\] (G10, 1.2) | Theo SRS G10 | Theo SRS G10 | Theo SRS G10 |
| \[ShareRetry\] `POST /rituals/{type}/{date}/share/retry` `[giả định — chưa có trong thiết kế kỹ thuật]` | deliveryIds[] | shareDeliveries[] | 5s / 1 lần |
| \[ShareDestList\] `GET /share-destinations` | – | Destination[] (id, kind `self` / `email` / `slack` / `teams`, address, enabledFor) | 5s / 1 lần |
| \[ShareDestCreate\] / \[ShareDestUpdate\] / \[ShareDestDelete\] `POST` / `PATCH` / `DELETE /share-destinations` | kind, address, enabledFor, Idempotency-Key (POST) | Destination | 5s / 1 lần |
| \[DayGet\] `GET /days?from&to` (G04) | from, to | Task[], totalPlannedMin, availableMin, overloaded, projections[] | 5s / 1 lần |
| \[TaskMove\] `POST /tasks/{id}/move` (G04 / G06) | startDate \| backlogBucket \| snooze | Task | 5s / 2 lần |
| \[TaskComplete\], \[TaskCreate\] (G02); \[TimeboxSet\] `PUT /tasks/{id}/timebox` (G05) | Theo SRS nhóm sở hữu | Task | Theo SRS nhóm sở hữu |
| \[SettingsGet\] / \[SettingsUpdate\] `GET` / `PATCH /me/settings` (G01) | ritual.* | Settings | 5s / 2 lần |
| Job \[ritual.prompt\] | Mỗi 5 phút | Thông báo, cờ chờ tự mở | Idempotent theo (user, type, date) |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field address | MSG-07 |
| `LIMIT_SHARE_DESTINATIONS` | MSG-08 |
| `VALIDATION_FAILED` · field obstacles / content · TOO_LONG | MSG-22 |
| `VALIDATION_FAILED` · field endOfDayMessage | MSG-25 |
| `RITUAL_DATE_NOT_ALLOWED` | MSG-20 |
| `RITUAL_ALREADY_COMPLETED` (409) | MSG-15 (BR-26) |
| `PRECONDITION_FAILED` (412) | Tải lại, gộp theo trường, gửi lại; trường bị ghi đè → MSG-29 (BR-26) |
| `RITUAL_GRACE_EXPIRED` | MSG-31 (BR-21) |
| `LIMIT_SHARE_EMAILS_DAILY` (429) | MSG-24 |
| `WORKSPACE_READ_ONLY` (402) | MSG-13 |
| 5xx / timeout | MSG-12 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Thông báo / banner | Đến giờ lên kế hoạch cho hôm nay · Bắt đầu (P) · Bỏ qua hôm nay |
| MSG-02 | Thông báo / banner | Đến giờ kết thúc ngày · Daily shutdown (O) · Bỏ qua hôm nay |
| MSG-03 | Inline | Đã lên kế hoạch {X} giờ, chỉ còn {Y} giờ trống |
| MSG-04 | Callout | Mẹo: một ngày 9–5 có nghỉ trưa thường chỉ đủ cho khoảng 5,5 giờ việc |
| MSG-05 | Inline | Dự kiến xong lúc {giờ} · Kết thúc ngày {giờ} |
| MSG-06 | Inline cảnh báo | Dự kiến xong lúc {giờ}, muộn hơn giờ kết thúc ngày {n} phút |
| MSG-07 | Inline | Email không hợp lệ |
| MSG-08 | Inline | Tối đa 10 nơi nhận |
| MSG-09 | Toast | Đã lưu kế hoạch vào task "Daily planning" |
| MSG-10 | Toast | Đang gửi tới {n} nơi nhận |
| MSG-11 | Thông báo trong app | Chưa gửi được tới {nơi nhận}. Thử lại |
| MSG-12 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-13 | Banner | (Từ 1.1) Gói dùng thử đã hết. Nâng cấp để tiếp tục lên kế hoạch |
| MSG-14 | Dialog | Tạo lại bản kế hoạch? Nội dung bạn đã sửa sẽ bị thay thế · Tạo lại · Huỷ |
| MSG-15 | Toast | Ritual này vừa được hoàn tất trên thiết bị khác |
| MSG-16 | Toast | Đã lưu tiến độ. Nhấn {P / O} để làm tiếp |
| MSG-17 | Empty state | Không còn việc nào từ hôm qua |
| MSG-18 | Empty state | Hôm nay chưa có task nào xong |
| MSG-19 | Màn Hoàn tất | Hôm nay vậy là đủ. Hẹn gặp lại ngày mai. |
| MSG-20 | Toast | Không lên kế hoạch được cho ngày đã qua |
| MSG-21 | Toast | Bước "{tên bước}" sẽ được bỏ qua từ lần sau · Hoàn tác |
| MSG-22 | Inline | Nội dung tối đa 5.000 ký tự |
| MSG-23 | Banner | Đang ngoại tuyến. Kế hoạch được lưu trên máy và sẽ gửi khi có mạng |
| MSG-24 | Toast | Đã đạt giới hạn 20 email chia sẻ hôm nay. Nội dung vẫn được lưu vào task |
| MSG-25 | Inline | Thông điệp tối đa 280 ký tự |
| MSG-26 | Toast | Đã lưu vào task "Daily shutdown" |
| MSG-27 | Banner | Timer đang chạy cho "{tiêu đề}" · Dừng timer |
| MSG-28 | Toast | Sự kiện này đã có task · Mở task |
| MSG-29 | Toast | Ritual vừa được sửa trên thiết bị khác. Đã gộp thay đổi; "{tên trường}" lấy theo bản mới nhất |
| MSG-30 | Banner | Bạn đang hoàn tất {tên ritual} cho {Thứ}, {dd/mm}. Còn {m} phút |
| MSG-31 | Toast | Đã quá thời gian hoàn tất {tên ritual} cho {Thứ}, {dd/mm} |
| MSG-32 | Inline | Việc từ hôm qua đang được chuyển sang. Danh sách sẽ tự cập nhật |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Mở wizard ≤ 1 giây; chuyển bước ≤ 300 ms; sinh bản kế hoạch ≤ 200 ms cho ngày 50 task; \[RitualComplete\] p95 ≤ 500 ms; email tới hộp thư ≤ 2 phút |
| Offline | Toàn bộ wizard chạy trên dữ liệu máy (IndexedDB 4 tuần + backlog); hoàn tất xếp hàng, gửi lại cùng Idempotency-Key, không tạo trùng task ghi chép |
| Đồng bộ | Theo QC-08. Thay đổi task trong ritual hiện trên thiết bị khác ≤ 5 giây; phiên ritual đồng bộ khi mở lại (\[RitualGet\]), ghi đè được chặn bằng If-Match; 409 / 412 xử lý theo BR-26 |
| Rollover | Lượt rollover hoãn vì phiên shutdown (BR-21) chạy ≤ 1 phút sau khi phiên hoàn tất / bị bỏ dở / hết ân hạn |
| Bảo mật | Chỉ chủ phiên đọc / sửa; nội dung email lọc HTML, chống chèn header; task riêng tư chỉ có trong bản gửi khi bật "Tuỳ chỉnh"; giới hạn 20 email / ngày; SPF / DKIM / DMARC cho domain gửi |
| Log / audit | Log gửi chia sẻ: đích (băm), thời điểm, kết quả, số lần thử; không log nội dung kế hoạch / highlights; tác nhân `system` cho task ghi chép |
| Tracking | Sự kiện: `ritual_opened` (type, source: auto / shortcut / sidebar / plan_button / notification), `ritual_step_viewed`, `ritual_step_hidden`, `ritual_exited` (step), `ritual_completed` (type, activeSeconds, overloaded, inGrace, isReplan), `ritual_prompt_dismissed`, `ritual_grace_expired`, `ritual_ai_plan_undone` (1.2), `ritual_share_sent` (kind, count), `ritual_share_failed` |
| Accessibility | Wizard điều hướng hoàn toàn bằng bàn phím, focus giữ trong wizard; mọi kéo thả có menu tương đương (Dời / Thêm vào hôm nay / Đặt giờ); biểu đồ phân bổ có bảng số thay thế; WCAG 2.1 AA ở giao diện sáng / tối |
