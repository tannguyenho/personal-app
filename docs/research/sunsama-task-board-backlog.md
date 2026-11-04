# Sunsama làm gì với task, board, backlog, rollover, archive và task lặp

> Ticket: <https://github.com/tannguyenho/personal-app/issues/3>
> Ngày tra cứu: 04/11/2026. Chỉ dùng **tài liệu công khai của Sunsama**: help center `help.sunsama.com` (bản mới "Sunsama User Manual"), changelog chính thức `sunsama.canny.io/changelog` và bảng góp ý `roadmap.sunsama.com`. Bảng góp ý chỉ được dùng để chỉ ra chỗ tài liệu còn trống, hoặc khi có câu trả lời của người trong đội Sunsama; ý kiến của người dùng ở đó không được coi là hành vi của sản phẩm.
> Mỗi ý về Sunsama đều kèm nhãn nguồn, ví dụ [TR]; URL đầy đủ nằm ở mục 5. Điều gì tài liệu không nói thì ghi "tài liệu không nêu" và chuyển sang mục 3 để kiểm chứng bằng Chrome.
> Phía app được đối chiếu với `docs/01-quy-tac-dung-chung.md` (QC-03..QC-06), `docs/features/{prd,srs}-g02/g03/g04/g06-*.md`. Mã BR ghi kèm tên nhóm, ví dụ G06 BR-12.

Cách đánh giá:
- **Giống**: hành vi tương đương.
- **Khác có chủ đích**: tài liệu của ta đã ghi lý do hoặc mã quyết định (Q/C/D/B).
- **Khác chưa chủ đích**: không thấy quyết định nào nói tới, **cần xem lại**.

---

## 1. Tóm tắt

1. Sunsama coi mọi task là "việc của một ngày": mỗi ngày là một cột, và task chưa xong **tự rollover lúc nửa đêm** [KB][TR]. Thẻ task có số ngày rollover liên tiếp, hiện từ lần rollover đầu tiên [CT][CL-2022-11]. App ta giống về khung, nhưng có hai điểm khác có chủ đích: mốc đầu ngày là 04:00, và chỉ đếm ngày có trong lịch làm việc của task (QC-01, QC-04).
2. **Archive chỉ nhận task tự động**: task rollover liên tục nhiều ngày "không có hoạt động hoàn thành" sẽ vào archive. Người dùng tắt được tự lưu trữ và chọn được "N consecutive days"; tài liệu ngụ ý mặc định là 4 ngày [AR][TR]. App ta giống ở con số 4 và ở việc không có lưu trữ thủ công (Q34). Khác ở hai chỗ: app chưa có UI chỉnh ngưỡng, và chưa xét "hoạt động hoàn thành" (subtask đã tích, đã ghi thời gian thực tế).
3. **Backlog có 6 bucket thời gian** (Next week or two … Someday (mặc định), Never) và folder. Task được xếp lịch vào một ngày thì mất folder [BL][CL-BL2]. App ta gần như trùng (G06 BR-01, BR-04, BR-05). Khác ở bucket mặc định, ở priority riêng cho backlog và ở bộ lọc trong backlog.
4. **Task lặp chỉ rollover "cho tới khi đụng instance kế tiếp"**. Instance cũ không sửa thì bị *ẩn*. Instance đã sửa (tên, notes, subtask, thời gian thực tế, planned, channel) thì được *giữ*, nên hôm sau có hai bản [RT][TR]. App ta (QC-06, G03 BR-10, G06 BR-11) đưa mọi instance cũ chưa xong vào Lưu trữ `skipped` và **không phân biệt đã sửa hay chưa**: đây là điểm khác chưa chủ đích lớn nhất.
5. Sửa series trong Sunsama có các lệnh "Stop repeating" (xoá mọi instance *sau* instance đang mở), "Delete all instances" (chỉ xoá instance chưa xong) và "Update all incomplete instances to match this task" (áp cho *mọi* instance chưa xong, kể cả instance trước đó) [RT]. Các lệnh này khớp với bảng phạm vi của G03 BR-08. Câu hỏi mở "Dừng lặp có xoá instance tương lai không" của PRD G03 nhờ vậy có tham chiếu: Sunsama có xoá.
6. Ngưỡng khối lượng của Sunsama có **hai mức màu**: vàng khi gần chạm ngưỡng, đỏ khi vượt. Task thuộc context "Personal" không tính vào khối lượng, và ngưỡng chỉnh được theo từng ngày [PA][CC][US]. App ta chỉ có `QUA_TAI` (đỏ) và tính sức chứa theo giờ làm (Q48). Mức "sắp chạm ngưỡng" chưa được bàn tới.
7. Phím tắt chính của Sunsama: A, C, D (hoãn 1 ngày), Z (backlog), X (tự xếp lịch), Space (timer), Cmd/Ctrl+Delete (xoá), Cmd+D (nhân bản), Shift+A/B/F, Shift+Space, Cmd+K, ? [KS][TM][WN]. App ta có bộ phím gần tương đương, thêm S và Shift+Z.
8. Về xoá và khôi phục, Sunsama chỉ công bố hai đường: Cmd+Z ngay sau khi xoá, và Thùng rác ở panel phải [FAQ][WN]. Toast Hoàn tác, thời gian giữ trong Thùng rác và chỗ task quay về khi khôi phục đều **không có trong tài liệu**.
9. Sunsama giữ "completion credit": ngày cũ vẫn còn bản mờ của task đã làm dở, khi có subtask đã tích hoặc đã ghi thời gian [KB][MD]. Người dùng còn kéo được task vào cột hôm qua để đánh dấu xong [FAQ]. App ta chưa có cả hai (PAST_DATE, C15).
10. Tài liệu công khai **không nói gì về trạng thái màn hình**: cột rỗng, backlog rỗng, archive rỗng, ngày có rất nhiều task. Các câu hỏi về toast, hoàn tác và mặc định cũng chưa có câu trả lời. Mục 3 liệt kê 24 câu cần kiểm chứng bằng Chrome.

---

## 2. Đối chiếu theo chủ đề

### 2.1. Task (tạo, thuộc tính, hoàn thành, xoá / khôi phục, subtask, channel)

| # | Sunsama làm gì (nguồn) | App ta (mã) | Đánh giá |
|---|---|---|---|
| T1 | Tạo task bằng "Add task" trên cột ngày hoặc phím A. Trong ô soạn có các chỉ thị: `@` (start date, kể cả `@backlog`), `~` (planned), `#` (channel), `$` (objective), `!` (priority), `>` (gộp thành subtask). Cmd/Ctrl+Shift+↑/↓ tạo ở đầu / cuối danh sách. Enter tạo task; Cmd/Ctrl+Enter tạo rồi mở task [CT][KS][TM] | Ô soạn và phím A (G02 UC-01, SCR-01). Vị trí task mới theo cài đặt, mặc định ở đầu (G02 BR-03) | Giống ở phần cốt lõi. Ô soạn của ta có hỗ trợ đủ các chỉ thị `@ ~ # ! >` không thì cần đối chiếu G02 SCR-01 (không nằm trong phạm vi tra cứu này) |
| T2 | Thuộc tính gồm notes (rich text), subtask (có thời gian và tick riêng), planned time, actual time, channel [CT][TB] | G02 BR-01 (giới hạn), BR-05 (channel), BR-06 (priority), BR-17 (subtask) | Giống |
| T3 | Hoàn thành bằng nút tròn hoặc phím C [CT]. Hoàn thành mà chưa có actual time thì planned được tính là actual, nếu bật cài đặt [PA][US]. Tài liệu không nói hoàn thành task có tự tích subtask hay không | G02 BR-08: tự tích mọi subtask; lưu `plannedAsActual`; task của ngày tương lai chuyển về hôm nay (QC-05) | Giống ở "planned là actual". Hành vi với subtask và với task tương lai: tài liệu không nêu, xem mục 3 (C1, C2) |
| T4 | Hoàn thành task hôm qua: kéo task vào cột hôm qua hoặc chọn ngày hôm qua rồi tích xong [FAQ] | Chặn đặt task chưa xong vào ngày đã qua (`PAST_DATE`, QC-05, C15). Hoàn thành thì đặt `startDate` = hôm nay (G02 BR-08 d) | **Khác chưa chủ đích, cần xem lại.** C15 chặn ngày quá khứ, nhưng chưa bàn ca "quên tích hôm qua", nên báo cáo theo ngày của ta sẽ ghi sai ngày. Xem gợi ý mục 4 |
| T5 | Xoá bằng Cmd/Ctrl+Delete [KS]. Muốn lấy lại thì "Use CMD Z immediately"; với lần xoá cũ hơn thì vào Thùng rác qua nút + ở panel phải [FAQ][WN] | Xoá mềm, không hỏi, có toast Hoàn tác, Ctrl+Backspace, Thùng rác 30 ngày (G02 BR-11, BR-12; QC-03 mục 3) | Giống về luồng. Thời hạn giữ trong Thùng rác của Sunsama **tài liệu không nêu**; PRD G02 ghi "7 ngày" dựa trên lần kiểm chứng ngày 04/11/2026, đã chốt khác (Q28). Chỗ task về khi khôi phục: tài liệu không nêu (C4) |
| T6 | Subtask: tạo bằng `>` hoặc giữ Alt/Option rồi kéo một task thả lên task khác ("merge"). Task được gộp giữ notes, planned time và liên kết tích hợp. "Convert to task" để tách ngược ra. Task tạo từ sự kiện lịch không có subtask được. Xoá subtask bằng cách Backspace hết dòng. Ẩn / hiện subtask bằng chuột phải [MT][FAQ][TM] | Subtask một cấp; tích subtask cuối không tự hoàn thành task; xoá subtask có Hoàn tác (G02 BR-17) | Giống ở mức một cấp. **Khác chưa chủ đích:** ta chưa thấy luồng gộp task thành subtask, tách subtask thành task, hay ẩn subtask trên card. Sunsama dùng các luồng này như cách chính để xử lý task kéo dài nhiều ngày [TM][MD] |
| T7 | Channel thuộc context. Context có cờ "Personal": task trong đó không tính vào khối lượng. Có thể đặt channel mặc định. Đang lọc theo channel mà tạo task thì task nhận channel đang lọc. Phím Q đổi channel [CC]. Xoá channel thì task thành "uncategorized", dữ liệu không mất [FAQ] | Mỗi task đúng một channel, mặc định "Chưa phân loại" (G02 BR-05). Xoá channel thì chọn channel nhận task (G02 BR-14). Tạo task khi đang lọc nhận channel đang lọc `[giả định]` (G04 UC-06 A3). Khung giờ channel (G02 BR-22) | Giống ở luồng xoá channel và luồng tạo task khi đang lọc; Sunsama giúp xác nhận giả định của G04 UC-06 A3. **Khác có chủ đích:** ta tách công việc và việc riêng bằng khung giờ channel (Q38a, Q48), không dùng cờ Personal |
| T8 | Hai hệ priority. *Daily priority* (Urgent / Priority / Normal / Low) về Normal sau mỗi ngày, trừ các mức người dùng chọn ở "Priority rollover". *Backlog priority* (Urgent / High / Medium / Low / No priority) giữ nguyên [PR][CL-PRIO] | Một bộ priority 1–4 (G02 BR-06). Rollover đưa về Normal, trừ các mức trong tập được giữ (G06 BR-08) | Giống ở daily priority. **Khác chưa chủ đích:** ta chưa có priority riêng cho backlog, nên đưa task vào backlog rồi lấy ra thì priority bị xử lý ra sao chưa được nói |
| T9 | Nhân bản bằng Cmd/Ctrl+D, menu chuột phải hoặc "other actions" [MD][TM] | Ctrl+D (G02 BR-10) | Giống |
| T10 | Undo được công bố: Cmd+Z sau khi xoá [FAQ]; Cmd/Ctrl+Z hoàn tác auto-reschedule [CL-AR]; Sunny và Autoplan có "receipt" kèm nút Undo [CL-2026-09-29]. Tài liệu **không** nói toast Hoàn tác có xuất hiện sau C, D, Z và kéo thả hay không | Mọi lệnh có tác dụng phụ đều có toast Hoàn tác (G02 BR-16, G04 BR-12, G06 BR-17) | Tài liệu không nêu (C3) |

### 2.2. Board ngày (cột ngày, kéo thả, thứ tự, khối lượng, view, phím tắt)

| # | Sunsama làm gì (nguồn) | App ta (mã) | Đánh giá |
|---|---|---|---|
| B1 | Mỗi ngày một cột gồm header ngày, nút tạo task và danh sách task. Cột ngày cũ hiện việc đã làm, cột tương lai hiện việc đã lên kế hoạch. Bấm header để "focus" ngày, quyết định lịch ở panel phải hiện ngày nào [KB][WN] | SCR-02 cột ngày; trạng thái `DA_QUA` / `TRONG` / `XONG_HET` / `QUA_TAI` / `BINH_THUONG` (G04 mục 4.1, BR-21) | Giống ở khung. Sunsama **không công bố** trạng thái màn hình của cột (rỗng, toàn task xong…) (C5) |
| B2 | Có 3 cách dời task giữa các ngày: kéo thả, biểu tượng lịch trên card, menu "Start date" [KB]. Phím D là "Snooze one day" [KS] | Kéo thả / chọn ngày, có reset số ngày bị hoãn (G04 BR-08). D = ngày làm việc kế tiếp theo lịch của task, không reset (G04 BR-10, QC-04 mục 2). "Hoãn 1 tuần", S | Giống ở 3 cách dời. **Khác có chủ đích:** D theo lịch của task (Q38a). D của Sunsama tính từ ngày nào và có reset bộ đếm rollover không: tài liệu không nêu (C6) |
| B3 | Đổi thứ tự bằng kéo thả, hoặc chuột phải chọn "Move to top" / "Move to Bottom". Lệnh sort qua Cmd+K, gõ "Sort": theo thời gian, task đã xếp lịch trên/dưới task chưa xếp, task chưa có channel, task chưa có planned, "Reorder by priority" (chạy một lần) [KB][TM][CP] | Ctrl+↑/↓ và Ctrl+Shift+↑/↓; menu "Sắp xếp lại" với 7 tiêu chí, có Hoàn tác (G04 BR-10, BR-11, BR-12) | Giống về chức năng. Tiêu chí sort khác: Sunsama có lọc "chưa channel / chưa planned" như một bước dọn dẹp |
| B4 | Auto-sort: xếp lại vị trí khi task được tạo, đổi priority, đổi planned hoặc bắt đầu timer. Auto-sort giữ nguyên vị trí người dùng tự kéo ngược thứ tự priority ("manual pins"), và task đang chạy timer luôn nằm đầu danh sách [AS] | Tự sắp: timebox → priority → vị trí tuỳ chỉnh; task xong xuống cuối (G04 BR-07) | **Khác chưa chủ đích, cần xem lại** hai quy tắc: "manual pin" (ta có giữ vị trí người dùng đã kéo ngược priority không) và "task chạy timer lên đầu" |
| B5 | Bộ đếm khối lượng ở đầu mỗi cột. Ở hôm nay bấm vào để xoay vòng 3 chế độ: *Total: time remaining*, *Work: time remaining* (bỏ channel personal), *Actual vs planned* [PA][KB] | Tổng thời lượng gồm cả task đã xong, cộng thanh tiến độ (G04 BR-02, BR-03) | **Khác chưa chủ đích:** Sunsama cho xem "còn lại", ta hiện tổng kèm thanh tiến độ. Nên cân nhắc cho bộ đếm xoay vòng (mục 4) |
| B6 | Ngưỡng khối lượng: tổng planned của task không thuộc channel personal gần chạm ngưỡng thì **vàng**, vượt ngưỡng thì **đỏ** [PA]. Ngưỡng tính bằng giờ, có "Custom by day" [US]. Ở bước Daily Planning, Sunsama so tổng với ngưỡng rồi hiện cảnh báo, kèm timeline giờ dự kiến xong so với giờ shutdown; người dùng dùng D hoặc Z để giảm tải [DPL] | Quá tải khi khối lượng còn lại > sức chứa theo giờ làm, hoặc vượt ngưỡng của lịch chung (G04 BR-04, BR-05). Cờ "Vượt giờ làm" (BR-22) | **Khác có chủ đích** ở công thức (Q48, B7). **Khác chưa chủ đích:** chưa có mức "sắp chạm" (vàng), chưa có ngưỡng theo từng ngày trong tuần |
| B7 | "Completion credit" (breadcrumb): ngày có tích subtask hoặc ghi actual time nhưng task chưa xong thì để lại bản mờ của task, không có ô tick chính, ở cột ngày đó [KB][MD]. Thẻ trên cột chỉ hiện planned/actual của riêng ngày đó; mở chi tiết thì thấy tổng cộng dồn [PA][FAQ] | Không thấy khái niệm tương đương. Bản ghi thời gian thuộc ngày của `startedAt` (QC-07, G06 BR-09) | **Khác chưa chủ đích, cần xem lại.** Không có breadcrumb thì cột ngày cũ không phản ánh việc đã làm dở |
| B8 | Điều hướng: date picker, Shift+→/← sang ngày khác, Shift+Space về hôm nay [TV][WN]. Home có Board và Calendar view; Tab mở Calendar view [WN]. Today view (T) chỉ hiện một danh sách, có cả bộ lọc [TV] | Shift+Space, Shift+→/←; Board / Calendar 1 ngày / 3 ngày / Weekdays / Week / Month, Tab xoay vòng (G04 BR-13, BR-14) | Giống. Tài liệu Sunsama không liệt kê các kiểu calendar view (1/3/7 ngày) (C7) |
| B9 | Lọc theo channel / context bằng Shift+F. Khi lọc, board chỉ còn task của channel đó [CC][WN] | Lọc chỉ ẩn card; tổng và cảnh báo vẫn tính trên toàn bộ task `[giả định]` (G04 BR-15) | Tài liệu không nói bộ đếm khối lượng có đi theo bộ lọc không. PRD G04 ghi "Sunsama tính theo bộ lọc", lấy từ lần kiểm chứng nội bộ (C8) |
| B10 | Ẩn task đã xong khỏi danh sách: bật trong cài đặt, xem lại bằng cách bấm "N tasks completed" [US] | Task xong xuống cuối (G04 BR-07) | **Khác chưa chủ đích, nhỏ:** cân nhắc thêm tuỳ chọn ẩn task đã xong |
| B11 | Phím trên task đang chọn: Cmd/Ctrl+Enter mở task, Space timer, C xong, F focus, X tự xếp lịch, D hoãn 1 ngày, Z vào backlog, Cmd/Ctrl+Delete xoá, G mở nguồn; W planned, E actual, Q channel. Toàn cục: ? (danh sách phím), H, T, P, O, Cmd/Ctrl+K, Cmd/Ctrl+F. Có công tắc tổng tắt mọi phím tắt [KS][PA][CC][US] | G04 BR-17 (phím một ký tự, khoá khi gõ nhanh), BR-18 (command menu), SCR-09; G02 BR-16 | Giống ở phần lớn. **Khác có chủ đích:** khoá phím khi gõ nhanh (EC-25). Sunsama không có S (về hôm nay) và Shift+Z |
| B12 | Ngày nhiều task: Sunsama khuyên dùng Today view, Focus mode, lọc context, và dọn task chưa xong khỏi hôm nay [TM]. Tài liệu **không** nói gì về hiệu năng hay giới hạn số task | Ảo hoá khi > 100 task (G04 BR-19, EC-40) | Tài liệu không nêu |

### 2.3. Backlog

| # | Sunsama làm gì (nguồn) | App ta (mã) | Đánh giá |
|---|---|---|---|
| L1 | Có 6 bucket: Next week or two, Next month, Next quarter, Next year, Someday (**mặc định**), Never [BL][CL-BL2] | 6 bucket cố định, phím 1–5, 0 (G06 BR-01) | Giống về danh sách. Mặc định khác: ta dùng Shift+Z → "Tuần tới" (G06 BR-03, `[giả định]`) |
| L2 | Đưa vào backlog bằng một trong các cách: kéo thả; hover rồi Z; `@backlog`; date picker → chọn bucket (chọn được folder luôn); "Add a task" ở đầu backlog [BL] | Z mở menu chọn bucket (SCR-02); Shift+Z không hỏi; kéo thả (G06 UC-01, BR-02, BR-03) | Giống. Z của Sunsama vào bucket nào: tài liệu không nêu (C9) |
| L3 | Folder chỉ có trong backlog; task được xếp vào một ngày thì mất folder. Changelog viết "folder designation will be hidden" [BL][CL-BL2] | Lấy ra ngày → `folderId` = null (G06 BR-05) | Giống. Chữ "hidden" làm nảy câu hỏi: đưa task lại vào backlog thì folder cũ có quay lại không (C10) |
| L4 | Lấy task ra khỏi backlog bằng cách kéo vào cột ngày, hoặc chọn ngày ở biểu tượng lịch [BL]. Daily Planning có bước nhập task từ backlog [DPL] | G06 UC-03, BR-05 | Giống |
| L5 | Có bộ lọc channel/context, priority, folder và ô tìm theo tên ngay trong backlog [BL] | Nút nhóm theo channel, nút biểu đồ (G06 SCR-01). Tìm toàn cục có cả backlog (G04 BR-16) | **Khác chưa chủ đích, nhỏ:** trong backlog chưa có lọc theo priority / folder, cũng chưa có ô tìm riêng |
| L6 | Gợi ý cách dùng: task rollover nhiều lần thì chuyển vào backlog; tạo task lặp "Review Backlog" mỗi tuần; backlog không thay cho công cụ quản lý dự án [BL][TM] | — | Gợi ý cho onboarding / copy |
| L7 | Bucket có tự chuyển theo thời gian không (ví dụ "Next month" thành "Next week")? Tài liệu **không** nêu | Câu hỏi mở trong PRD G06 | C11 |

### 2.4. Rollover

| # | Sunsama làm gì (nguồn) | App ta (mã) | Đánh giá |
|---|---|---|---|
| R1 | Mọi task chưa xong tự rollover sang ngày hôm sau lúc **nửa đêm** [TR][KB][CT] | Rollover theo ngày làm việc, mốc đầu ngày 04:00 (QC-01, G06 BR-06) | **Khác có chủ đích** (Q2) |
| R2 | Thẻ task hiện số trong vòng tròn, là số ngày rollover *liên tiếp*. Từ 11/2022 số này hiện ngay từ lần rollover đầu tiên [CT][TB][CL-2022-11] | Nhãn "Dời {n} ngày" khi n ≥ 1; n chỉ đếm ngày có trong lịch của task (QC-04, G04 BR-26) | Giống ở cách hiển thị. **Khác có chủ đích** ở cách đếm (Q32). Sunsama có reset bộ đếm khi người dùng tự kéo task sang ngày khác không: tài liệu không nêu (C12) |
| R3 | Vị trí sau rollover do cài đặt "Task rollover position" quyết định (Top / Bottom). Task rollover giữ thứ tự của hôm trước [US][CL-RO2] | Cài đặt "Vị trí task rollover", mặc định đầu; giữ thứ tự cũ; luôn nằm sau instance lặp của hôm nay (G06 BR-07, C16) | Giống. Mặc định của Sunsama: tài liệu không nêu (C13) |
| R4 | Rollover đưa daily priority về Normal, trừ các mức người dùng chọn giữ [PR][US] | G06 BR-08 | Giống |
| R5 | Sự kiện lịch đã nhập làm task cũng rollover nếu chưa xong. Cài đặt "Auto-complete imported calendar events" chặn được việc này [TR] | Sự kiện thuộc G05 | Ngoài phạm vi; ghi lại để G05 tham khảo |
| R6 | Evening planning có cài đặt "Automatically rollover tasks during evening planning": bật thì tự chuyển task chưa xong sang ngày mai; tắt thì hiện hộp cho người dùng chọn task nào chuyển [US]. Changelog 02/2025 ghi: ở chế độ này không dời các cuộc họp sang ngày mai [CL-2025-02-21] | Shutdown "Ngày mai", "Áp dụng cho tất cả" (G08, QC-05) | Giống về ý. Chi tiết thuộc G08 |
| R7 | Timer quên tắt qua đêm trên task bị rollover: Sunsama chỉ đưa ra một cách làm thủ công gồm 4 bước [TM] | Timer không dừng khi rollover (QC-05); có EC-23 (G07) | Ta làm kỹ hơn, khác có chủ đích |
| R8 | Hoàn tác rollover: tài liệu **không** nêu. Ca nhiều ngày không mở app: tài liệu **không** nêu. Ca đổi múi giờ: changelog có nhiều bản sửa lỗi task lặp bị nhân đôi hoặc biến mất khi đổi múi giờ [CL-2024-04][CL-2024-12] | Không có Hoàn tác (Q41); gộp nhiều ngày bị lỡ (EC-05); idempotent (EC-06); đổi timezone có hiệu lực từ ngày kế tiếp (QC-01) | Ta đặc tả kỹ hơn. Lỗi múi giờ của Sunsama cho thấy EC-02 rất cần kiểm thử |
| R9 | Có người dùng đề nghị cho chỉnh rollover hoặc ngưỡng archive **theo channel**. Bài góp ý chưa có trạng thái và chưa có trả lời chính thức [RM-CH] | Số ngày bị hoãn đếm theo lịch của task (khung channel) (QC-04) | Ta đã đi xa hơn Sunsama theo hướng mà người dùng của họ đang đề nghị |

### 2.5. Archive (Lưu trữ)

| # | Sunsama làm gì (nguồn) | App ta (mã) | Đánh giá |
|---|---|---|---|
| A1 | Task vào archive khi đã rollover nhiều ngày liên tiếp "without any completion activity". Archive **chỉ nhận task tự động, không lưu trữ thủ công** [AR][TR] | Tự lưu trữ khi n ≥ 4 (`stale`, G06 BR-12); không có lưu trữ thủ công ở bản 1.0 (Q34) | Giống ở chỗ không có lưu trữ thủ công. **Khác chưa chủ đích:** ta chỉ xét n; chưa xét "completion activity" (subtask đã tích, đã ghi actual) (C14) |
| A2 | Có toggle tắt tự lưu trữ và dropdown "N consecutive days" ở đầu panel. Tài liệu viết "expand the threshold from four days", ngụ ý mặc định là 4 [AR]. Changelog năm 2020 cho biết tính năng này vốn được bật sẵn với mọi người [CL-ARC] | Toggle "Tự lưu trữ" (SCR-05); ngưỡng 4 `[giả định]` | Giống ở con số. **Khác chưa chủ đích:** SCR-05 chưa có chỗ chỉnh ngưỡng. Mặc định bật hay tắt vẫn là câu hỏi mở của PRD G06 (C15) |
| A3 | Có callout "N tasks moved to archive" ở cuối danh sách task, bấm vào mở archive; badge số (màu hồng) trên biểu tượng mặt trăng. Mở archive bằng Shift+A hoặc command palette [AR][TR][CL-2023-05][CL-2024-03] | Toast MSG-11 "Đã lưu trữ {n} task … · Xem Lưu trữ"; Shift+A (G06 UC-06) | **Khác chưa chủ đích, nhỏ:** Sunsama dùng callout cố định trong danh sách cộng badge, ta dùng toast. Toast tắt rồi thì người dùng không còn dấu hiệu gì (xem mục 4) |
| A4 | Task ở trong archive cho tới khi người dùng chuyển đi, hoàn thành hoặc xoá [TR]. Chọn task trong archive rồi bấm Z thì task vào backlog; dùng phím mũi tên để duyệt danh sách (trả lời trên bảng góp ý, trạng thái "Complete") [RM-AB]. Lỗi đã sửa 04/2026: chọn folder backlog cho task trong archive thì task lại về hôm nay trước [CL-2026-04] | Chỉ có "Khôi phục" (về hôm nay), kéo vào ngày D, "Xoá tất cả" (G06 UC-06, BR-14, BR-15) | **Khác chưa chủ đích:** chưa có luồng chuyển thẳng từ Lưu trữ vào backlog, hoàn thành ngay trong Lưu trữ, hay xoá từng task |
| A5 | Cách phân loại task trong archive mà Sunsama gợi ý: không quan trọng thì xoá hoặc đưa vào backlog; quá tải thì lên kế hoạch ít hơn; quan trọng nhưng đang trì hoãn thì kéo lại vào danh sách và đặt khung giờ. Thêm task lặp "Review Archive" [AR] | — | Dùng làm copy cho trạng thái của panel Lưu trữ (mục 4) |
| A6 | Instance lặp trong archive: changelog có các bản sửa lỗi "many instances of recurring tasks to appear in the archive" và "future recurring tasks could incorrectly show in the archive". Như vậy theo thiết kế, instance lặp thường không vào archive [CL-2025-02-21][CL-2025-02-28] | Instance trùng series → Lưu trữ `skipped` (QC-06, G06 BR-11) | **Khác chưa chủ đích, cần xem lại** (xem 2.6 R-L4) |
| A7 | Không tìm thấy task: việc đầu tiên là xem archive, rồi kiểm tra bộ lọc channel có đang ở "#all" không [TS] | Tìm kiếm có kết quả trong Lưu trữ, gắn nhãn (G04 BR-16, C17) | Giống ở ý, ta làm tốt hơn |

### 2.6. Task lặp

| # | Sunsama làm gì (nguồn) | App ta (mã) | Đánh giá |
|---|---|---|---|
| L-1 | Bật lặp: mở task → "…" → "Repeat". Chi tiết task được chép sang mọi instance, nên nên đặt channel, subtask, notes và planned trước khi bật [RT][CT] | G03 UC-01, BR-02, BR-05 (chép tiêu đề, notes, channel, planned, approxTime; priority và subtask `[giả định]`) | Giống. Sunsama xác nhận **có chép subtask** [RT]; priority thì tài liệu không nêu (C16) |
| L-2 | Tần suất được ghi trong help center: Weekdays (T2–T6), Weekly (chọn thứ) [RT][FAQ]. Changelog có thêm hằng năm (10/2024) và có nhắc tới "monthly recurring tasks" (12/2023) [CL-2024-10][CL-2023-12]. Ngày kết thúc / số lần lặp: changelog 06/2026 chỉ nói Sunny giờ "gives a clear message" khi được yêu cầu tạo task lặp có ngày kết thúc [CL-2026-06] | DAILY, WEEKDAYS, WEEKLY, MONTHLY_DAY, MONTHLY_NTH, YEARLY, interval 1–99 (G03 BR-01). Chưa có ngày kết thúc (câu hỏi mở G03) | Ta có nhiều lựa chọn hơn. Sunsama có hỗ trợ ngày kết thúc hay không thì changelog mơ hồ (C17) |
| L-3 | "Roughly at": giờ ước lượng, dùng để tự xếp lịch và sắp thứ tự trong danh sách [RT]. Từ 07/2025 có "rigid projections": instance lặp có giờ ước lượng được vẽ cố định lên lịch, có dấu `~` trước giờ trên card, mặc định bật [CL-RIGID] | `approxTime` chỉ hiện trên card; lập lịch cứng để bản 1.1 (G03 BR-06, Q7) | **Khác có chủ đích** (Q7). Dấu `~` đáng học cho card |
| L-4 | **Rollover của task lặp**: instance rollover "until they collide with another instance of the same task". Instance cũ chưa sửa thì bị *ẩn* (chỉ còn instance mới). Instance đã sửa thì *giữ*, nên hôm sau có 2 bản. Các thao tác tính là "sửa": tên, notes, subtask, ghi actual time, planned time, channel [RT][TR] | Series đã có instance hôm nay → instance cũ chưa xong vào Lưu trữ `skipped`, chỉ ghi nhật ký, **không phân biệt có sửa hay không** (QC-06 mục 2, G03 BR-10, G06 BR-11). G03 BR-07 đã có cờ `customized` nhưng QC-06 không dùng tới | **Khác chưa chủ đích, cần xem lại (ưu tiên cao).** Có ba điểm: (1) instance đã có ghi chú hoặc thời gian của người dùng bị đưa khỏi hôm nay; (2) Sunsama *ẩn* chứ không đưa vào archive, còn ta đưa vào Lưu trữ nên làm đầy panel; (3) có thể dùng lại cờ `customized` (và thời gian thực tế) để miễn trừ |
| L-5 | Instance bị lỡ nhiều ngày: "only see tomorrow's instance" cho instance chưa sửa [RT] | Series chưa có instance hôm nay → giữ instance quá khứ mới nhất, instance cũ hơn thành `skipped` `[giả định]` (G03 BR-10) | Gần giống. Sunsama giữ instance *của hôm nay* (bản mới sinh), không đẩy bản cũ lên. Ca "hôm nay không phải ngày lặp" thì tài liệu không nêu (C18) |
| L-6 | Duyệt qua series bằng nút "previous" / "next" trên một instance [RT] | SCR-02 banner series; SCR-05 "Quản lý mọi task lặp" (G03) | **Khác chưa chủ đích, nhỏ:** cân nhắc nút trước / sau trong banner series |
| L-7 | Sửa series ("Edit task series"). *Stop repeating*: giữ instance hiện tại và các instance trước, xoá mọi instance sau. *Change repeat frequency*: đổi cả tần suất và "roughly at". *Change start time*. *Delete all instances*: xoá mọi instance chưa xong, giữ instance đã xong. *Update all incomplete instances to match this task*: áp cho **mọi** instance chưa xong, "not just instances after the one you clicked". Sửa một instance thì chỉ đổi instance đó, muốn áp cho cả series thì dùng lệnh "Update" [RT] | G03 BR-07, BR-08 và bảng phạm vi: (a) dừng thì xoá mềm instance tương lai chưa sửa `[giả định]`, giữ hôm nay; (c) chép vào hôm nay và tương lai, quá khứ giữ nguyên; (d) xoá mọi instance chưa xong (cần xác nhận `[giả định]`) | Giống ở cách hiểu chung. Sunsama trả lời được câu hỏi mở của PRD G03 "Dừng lặp có xoá instance tương lai không": **có xoá**. Khác nhỏ: Sunsama lấy mốc là *instance đang mở*, ta lấy mốc là *hôm nay*. Mức hỏi xác nhận của Delete all: tài liệu không nêu (C19) |
| L-8 | Subtask trên instance tương lai mặc định thu gọn. Muốn đổi cho cả series thì ẩn/hiện trên một instance rồi chạy "Update all incomplete instances" [RT]. Có người dùng muốn routine có subtask làm dở *không* rollover (góp ý, chưa có trạng thái) [RM-SUB] | G03 BR-08 (c) gộp subtask theo tiêu đề | Ý tưởng cho design: thu gọn subtask của instance lặp |
| L-9 | Bật lặp cho một task đã rollover vài ngày thì thấy "một bản cho mỗi ngày đã rollover". Đó là lịch sử rollover của chính task, xoá thoải mái được [RT] | G03 BR-02: task trở thành instance đầu, không có lịch sử nhiều ngày | Hệ quả của mô hình dữ liệu Sunsama (một task hiện trên nhiều ngày). Ta không gặp ca này |
| L-10 | Xoá một instance: tài liệu **không** nói có tạo ngày ngoại lệ hay ảnh hưởng series không | G02 BR-11, G03 BR-15 (ngày ngoại lệ vĩnh viễn) | C20 |
| L-11 | Đặt thứ tự task lặp trong ngày: changelog 07/2021 "set the order of your recurring tasks for each day" [CL-ORD] | Rollover xếp sau instance lặp của hôm nay (G06 BR-07) | Giống ở ý |

---

## 3. Tài liệu công khai không trả lời được — cần kiểm chứng bằng Chrome

Chuẩn bị chung: tài khoản Sunsama thử nghiệm, múi giờ cố định, tạo 2 context (Work, Personal có bật "Personal") và vài channel. Nên tắt Auto-sort khi kiểm thứ tự. Ca nào cần qua đêm thì đặt máy chờ, hoặc ghi lại rồi kiểm tra vào ngày hôm sau.

| Mã | Câu hỏi | Thao tác gợi ý |
|---|---|---|
| C1 | Hoàn thành task có tự tích các subtask chưa xong không? Bỏ hoàn thành thì subtask có trở lại như cũ không? | Tạo task có 3 subtask, tích 1, bấm C trên task, mở chi tiết. Bỏ tích task rồi xem lại subtask |
| C2 | Hoàn thành task ở cột ngày tương lai thì task ở lại ngày đó hay chuyển về hôm nay? Với instance lặp thì sao? | Tạo task ở ngày mai, bấm C. Làm lại với instance lặp của ngày mai |
| C3 | Những thao tác nào có toast Hoàn tác (C, D, Z, kéo thả, xoá, xoá subtask, đổi channel)? Toast hiện bao lâu? Ctrl+Z dùng được cho thao tác nào? | Lần lượt làm từng thao tác, quay màn hình để ghi toast và thời gian hiển thị; thử Ctrl+Z sau mỗi thao tác |
| C4 | Thùng rác: giữ bao lâu (PRD ghi 7 ngày, cần chụp nguồn)? Khôi phục thì task về ngày cũ, hôm nay hay backlog? Task quá khứ hoặc task trong backlog khôi phục về đâu? | Xoá 3 task: một ở hôm nay, một ở ngày đã qua (task đã rollover), một ở backlog. Mở Thùng rác (nút + ở panel phải), chụp lại dòng chữ về thời hạn, khôi phục từng task |
| C5 | Trạng thái màn hình: cột ngày rỗng (copy, minh hoạ), ngày toàn task đã xong, backlog rỗng, archive rỗng, kết quả tìm kiếm rỗng | Chuyển sang ngày tương lai chưa có gì; tích hết task một ngày; dọn backlog và archive của tài khoản thử. Chụp từng màn |
| C6 | Phím D: lấy hôm nay hay ngày của task làm mốc? D trên task của ngày tương lai thì sao? D có bỏ qua cuối tuần không? D có reset số rollover không? | Bấm D trên task hôm nay, task ngày mai và task đang có số rollover; làm vào Thứ Sáu để xem có nhảy sang Thứ Hai không |
| C7 | Có những kiểu Calendar view nào (1 ngày, 3 ngày, tuần, tháng)? Tab xoay vòng qua những view nào? | Bấm Tab nhiều lần, rồi mở menu "Board" |
| C8 | Khi lọc channel, bộ đếm khối lượng và màu cảnh báo tính trên task đang hiện hay trên toàn bộ task? | Tạo 4 giờ task Work và 4 giờ task Personal-channel, đặt ngưỡng 6 giờ, lọc theo một channel rồi đọc bộ đếm |
| C9 | Z (hover) đưa task vào bucket nào: Someday hay hỏi người dùng? Task đứng ở đầu hay cuối bucket? | Hover lên một task, bấm Z, mở backlog |
| C10 | Task có folder được xếp vào một ngày rồi đưa lại vào backlog: folder cũ có quay lại không ("hidden" hay bị xoá)? | Gán folder, kéo task ra hôm nay, rồi bấm Z |
| C11 | Bucket có tự chuyển theo thời gian không (ví dụ "Next month" thành "Next week or two" khi tới kỳ)? | Đọc mô tả trong UI. Nếu không có, đặt task ở "Next month" và theo dõi qua đầu tháng (cần thời gian dài) |
| C12 | Kéo task đang có số rollover sang ngày mai, hoặc đưa vào backlog rồi lấy ra: số rollover có về 0 không? Số này đếm cả cuối tuần không? | Để một task rollover qua 2 đêm, rồi kéo nó sang ngày mai, xem số trên card hôm sau. Theo dõi một task qua cuối tuần |
| C13 | Mặc định của "Task rollover position", "Priority rollover", "Workload threshold", "Hide completed tasks", "Auto-sort" | Tài khoản mới → Settings → General / Display, chụp màn |
| C14 | "Completion activity": tích một subtask hoặc ghi actual time trên task đang rollover có làm bộ đếm về 0 hay chặn tự lưu trữ không? | Đặt ngưỡng archive 2 ngày; cho 2 task rollover, mỗi ngày tích 1 subtask của task A; xem task nào bị lưu trữ |
| C15 | Tài khoản mới có bật tự lưu trữ không? Ngưỡng mặc định có đúng 4 ngày không? Dropdown cho chọn những giá trị nào? Ngày nghỉ cuối tuần có được đếm không? | Mở panel archive ở tài khoản mới, chụp toggle và dropdown |
| C16 | Instance mới sinh của task lặp có chép priority (daily) không? Có chép planned time, channel, notes không? | Tạo task có priority Urgent, notes, subtask; bật Weekly; xem instance tuần sau |
| C17 | Picker lặp có tuỳ chọn hằng ngày / hằng tháng (ngày N, thứ N) / mỗi N tuần / ngày kết thúc không? | Mở "Repeat", chụp toàn bộ các lựa chọn |
| C18 | Instance lặp bị lỡ khi hôm nay không phải ngày lặp (ví dụ lặp T2/T4, bỏ lỡ T2): sang T3 bản T2 có rollover không? Sang T4 thì sao? | Tạo series T2/T4, không tích T2, xem T3 và T4 |
| C19 | "Delete all instances" và "Stop repeating" có hỏi xác nhận hay có Hoàn tác không? "Stop repeating" mở từ một instance tương lai thì instance hôm nay còn không? | Thực hiện trên series thử, quay màn hình |
| C20 | Xoá một instance (Cmd+Delete) rồi khôi phục từ Thùng rác: instance có quay lại không, và series có sinh lại instance cho ngày đó không? | Xoá instance tuần sau, khôi phục, rồi đổi tần suất series qua lại |
| C21 | Instance lặp đã sửa (thêm notes) bị lỡ: hôm sau có đúng 2 bản không? Bản đã sửa còn rollover tiếp hay vào archive sau N ngày? | Thêm notes cho instance hôm nay, không tích; theo dõi 2–5 ngày |
| C22 | Mức vàng của ngưỡng khối lượng: "approaches" là bao nhiêu phần trăm hay bao nhiêu phút? Màu cảnh báo có áp cho ngày tương lai không? | Đặt ngưỡng 4 giờ; tăng planned dần (3h, 3h30, 3h50, 4h10), chụp màu bộ đếm. Lặp lại ở ngày mai |
| C23 | Kéo task chưa xong vào cột ngày đã qua: được phép không, có cảnh báo không? Task đó có rollover lại vào đêm nay không? | Kéo một task hôm nay vào cột hôm qua, đừng tích; xem hôm sau |
| C24 | Ngày có rất nhiều task (100+): cuộn có mượt không, có gom nhóm hay giới hạn hiển thị không? | Dùng Zapier/API hoặc dán nhanh để tạo khoảng 150 task trong một ngày |

---

## 4. Gợi ý cho design brief

**Trạng thái màn hình**
- **Cột ngày**: nên có trạng thái thật cho `TRONG` (rỗng), không chỉ "Thêm task". Sunsama khuyên chỉ để ở hôm nay những việc làm được [TM]; câu này dùng được làm copy cho ngày rỗng ở tương lai, ví dụ "Chưa có việc cho ngày này. Kéo từ Backlog hoặc thêm task".
- **Bộ đếm khối lượng**: nên có 3 mức: bình thường, sắp chạm (vàng), vượt (đỏ) [PA]. Khi bấm vào thì xoay vòng giữa "còn lại", "còn lại (công việc)" và "thực tế / dự định" [PA]. Ở mức đỏ, tooltip nên gợi ý hành động: "Nhấn D để hoãn, Z để đưa vào Backlog", giống cách Sunsama đặt D/Z ngay trong bước khối lượng của Daily Planning [DPL].
- **Ngày đã qua**: nên hiện breadcrumb, tức bản mờ không có ô tick, cho task làm dở trong ngày (có subtask đã tích hoặc có thời gian thực tế) [KB][MD]. Như vậy cột ngày cũ là nhật ký đúng của những gì đã làm. Việc này cần PO quyết định vì nó chạm tới QC-07.
- **Lưu trữ**: ngoài toast MSG-11, nên có callout cố định ở cuối danh sách hôm nay, "{n} task đã chuyển vào Lưu trữ", bấm vào là mở panel. Thêm badge trên biểu tượng Lưu trữ [AR][TR]. Toast tắt rồi thì người dùng vẫn có dấu hiệu để tìm.
- **Panel Lưu trữ**: nên có hướng dẫn triage 3 nhánh lấy từ [AR]: "Không quan trọng → Xoá / Backlog · Quá nhiều việc → lên kế hoạch ít hơn · Quan trọng nhưng đang trì hoãn → Khôi phục và đặt giờ". Trên mỗi dòng nên có thêm "Đưa vào Backlog" (phím Z) [RM-AB]. Khi rỗng, empty state MSG-19 có thể kèm một câu giải thích lý do task vào đây.
- **Backlog**: mỗi bucket hiện số task và tổng thời lượng (ta đã có). Nên thêm bộ lọc priority / folder và ô tìm trong trang [BL].

**Copy**
- Nhãn số ngày bị hoãn: Sunsama chỉ dùng số trong vòng tròn [CT]. "Dời {n} ngày" của ta rõ hơn; ở mức ngưỡng − 1, nên thêm câu báo trước kiểu "mai sẽ vào Lưu trữ" (G06 SCR-07 #2 đã có ý này).
- Giải thích task lặp bị ẩn hoặc bị lưu trữ: Sunsama giải thích bằng ví dụ "Check Email" [RT]. Tooltip của ta cho `skipped` (MSG-13 "Bị bỏ qua · đã có lần lặp hôm nay") nên giữ văn phong ngắn và cụ thể như vậy.
- Trong menu "Sửa series", nên ghi rõ phạm vi ngay trên mục, như câu cảnh báo của Sunsama "this will change all incomplete instances not just instances after the one you clicked" [RT].

**Tương tác đáng học**
- Chỉ thị trong ô soạn: `@` ngày (có `@backlog`), `~` planned, `#` channel, `!` priority, `>` gộp làm subtask; Cmd/Ctrl+Shift+↑/↓ để tạo ở đầu / cuối [CT].
- Giữ Alt và kéo thả để gộp task thành subtask; "Convert to task" để tách ra [MT]. Đây là cách chính để xử lý việc kéo dài nhiều ngày.
- Chuột phải chọn "Move to top / bottom" khi danh sách dài [KB]. Các lệnh sort một lần trong Command menu, gồm "task chưa có planned" và "task chưa có channel" [TM].
- Auto-sort tôn trọng "manual pin" và đưa task đang chạy timer lên đầu [AS].
- Ẩn / hiện subtask trên card; subtask của instance lặp mặc định thu gọn [TM][RT].
- Nút "trước / sau" để duyệt các instance của một series [RT].
- Dấu `~` trước giờ ước lượng của instance lặp trên card [CL-RIGID].
- Tuỳ chọn ẩn task đã xong, có dòng "{n} task đã xong" để mở lại [US].

**Điểm cần PO quyết định trước khi vẽ** (từ các mục "Khác chưa chủ đích")
1. QC-06 có miễn trừ instance lặp đã sửa riêng hoặc đã có thời gian thực tế không (2.6 L-4)? Instance `skipped` nên *ẩn* hay hiện trong Lưu trữ?
2. Có cho đánh dấu xong task ở ngày đã qua không (2.1 T4)? Có cần breadcrumb không (2.2 B7)?
3. Có cho chỉnh ngưỡng Tự lưu trữ trên UI không (2.5 A2)? Subtask đã tích hoặc thời gian thực tế có tính là "hoạt động" không (2.5 A1)?
4. Có mức cảnh báo "sắp chạm ngưỡng" không, có ngưỡng theo từng ngày không (2.2 B6)?
5. Có cho đi thẳng từ Lưu trữ sang Backlog không (2.5 A4)? Có priority riêng cho backlog không (2.1 T8)?

---

## 5. Nguồn

Help center (help.sunsama.com, đọc ngày 04/11/2026):

[TB]: https://help.sunsama.com/docs/getting-started/basics/task-basics
[KB]: https://help.sunsama.com/docs/getting-started/basics/kanban-task-view
[TR]: https://help.sunsama.com/docs/getting-started/basics/task-rollover-and-recurring-tasks-the-basics
[CT]: https://help.sunsama.com/docs/usage-guides/tasks/creating-tasks
[TM]: https://help.sunsama.com/docs/usage-guides/tasks/task-management
[RT]: https://help.sunsama.com/docs/usage-guides/tasks/recurring-tasks
[PR]: https://help.sunsama.com/docs/usage-guides/tasks/task-priority
[AS]: https://help.sunsama.com/docs/usage-guides/tasks/auto-sort
[PA]: https://help.sunsama.com/docs/usage-guides/tasks/planned-and-actual-times
[MT]: https://help.sunsama.com/docs/usage-guides/tasks/merge-tasks
[AR]: https://help.sunsama.com/docs/usage-guides/archive
[BL]: https://help.sunsama.com/docs/usage-guides/backlog
[CC]: https://help.sunsama.com/docs/usage-guides/channels-and-contexts
[KS]: https://help.sunsama.com/docs/usage-guides/keyboard-driven-actions/keyboard-shortcuts
[CP]: https://help.sunsama.com/docs/usage-guides/keyboard-driven-actions/command-palette
[WN]: https://help.sunsama.com/docs/usage-guides/workspace-navigation
[TV]: https://help.sunsama.com/docs/usage-guides/today-view
[DPL]: https://help.sunsama.com/docs/usage-guides/daily-planning/legacy
[US]: https://help.sunsama.com/docs/settings/user-settings
[FAQ]: https://help.sunsama.com/docs/faq/faq
[TS]: https://help.sunsama.com/docs/faq/troubleshooting
[MD]: https://help.sunsama.com/docs/pro-tips/multi-day-tasks

Changelog chính thức (sunsama.canny.io):

[CL-RO2]: https://sunsama.canny.io/changelog/rollover-20
[CL-ARC]: https://sunsama.canny.io/changelog/automatic-archive
[CL-ORD]: https://sunsama.canny.io/changelog/ordering-recurring-tasks
[CL-2022-11]: https://sunsama.canny.io/changelog/weekly-update-november-4-2022
[CL-AR]: https://sunsama.canny.io/changelog/auto-reschedule
[CL-2023-05]: https://sunsama.canny.io/changelog/weekly-update-may-26-2023
[CL-2023-12]: https://sunsama.canny.io/changelog/weekly-update-december-8-2023-1
[CL-2024-03]: https://sunsama.canny.io/changelog/weekly-update-march-22-2024
[CL-2024-04]: https://sunsama.canny.io/changelog/weekly-update-april-26-2024
[CL-2024-10]: https://sunsama.canny.io/changelog/weekly-update-october-11-2024
[CL-2024-12]: https://sunsama.canny.io/changelog/weekly-update-december-20-2024
[CL-2025-02-21]: https://sunsama.canny.io/changelog/weekly-update-february-21-2025
[CL-2025-02-28]: https://sunsama.canny.io/changelog/weekly-update-february-28-2025
[CL-RIGID]: https://sunsama.canny.io/changelog/visualize-recurring-tasks-at-a-set-time-on-your-calendar-via-rigid-projections
[CL-BL2]: https://sunsama.canny.io/changelog/backlog-20
[CL-2026-04]: https://sunsama.canny.io/changelog/weekly-product-changelog-april-17-2026
[CL-PRIO]: https://sunsama.canny.io/changelog/task-priority-auto-sort
[CL-2026-06]: https://sunsama.canny.io/changelog/weekly-product-changelog-june-12-2026
[CL-2026-09-29]: https://sunsama.canny.io/changelog/weekly-product-changelog-september-29-2026

Bảng góp ý (roadmap.sunsama.com) — chỉ dùng để chỉ ra chỗ trống hoặc khi có câu trả lời của đội Sunsama:

[RM-AB]: https://roadmap.sunsama.com/mobile-apps/p/easily-move-item-from-archived-to-backlog
[RM-CH]: https://roadmap.sunsama.com/improvements/p/set-task-rollover-days-by-channel
[RM-SUB]: https://roadmap.sunsama.com/improvements/p/allow-user-to-choose-if-partially-completed-recurring-tasks-rollover

| Nhãn | URL |
|---|---|
| TB | https://help.sunsama.com/docs/getting-started/basics/task-basics |
| KB | https://help.sunsama.com/docs/getting-started/basics/kanban-task-view |
| TR | https://help.sunsama.com/docs/getting-started/basics/task-rollover-and-recurring-tasks-the-basics |
| CT | https://help.sunsama.com/docs/usage-guides/tasks/creating-tasks |
| TM | https://help.sunsama.com/docs/usage-guides/tasks/task-management |
| RT | https://help.sunsama.com/docs/usage-guides/tasks/recurring-tasks |
| PR | https://help.sunsama.com/docs/usage-guides/tasks/task-priority |
| AS | https://help.sunsama.com/docs/usage-guides/tasks/auto-sort |
| PA | https://help.sunsama.com/docs/usage-guides/tasks/planned-and-actual-times |
| MT | https://help.sunsama.com/docs/usage-guides/tasks/merge-tasks |
| AR | https://help.sunsama.com/docs/usage-guides/archive |
| BL | https://help.sunsama.com/docs/usage-guides/backlog |
| CC | https://help.sunsama.com/docs/usage-guides/channels-and-contexts |
| KS | https://help.sunsama.com/docs/usage-guides/keyboard-driven-actions/keyboard-shortcuts |
| CP | https://help.sunsama.com/docs/usage-guides/keyboard-driven-actions/command-palette |
| WN | https://help.sunsama.com/docs/usage-guides/workspace-navigation |
| TV | https://help.sunsama.com/docs/usage-guides/today-view |
| DPL | https://help.sunsama.com/docs/usage-guides/daily-planning/legacy |
| US | https://help.sunsama.com/docs/settings/user-settings |
| FAQ | https://help.sunsama.com/docs/faq/faq |
| TS | https://help.sunsama.com/docs/faq/troubleshooting |
| MD | https://help.sunsama.com/docs/pro-tips/multi-day-tasks |
| CL-RO2 | https://sunsama.canny.io/changelog/rollover-20 |
| CL-ARC | https://sunsama.canny.io/changelog/automatic-archive |
| CL-ORD | https://sunsama.canny.io/changelog/ordering-recurring-tasks |
| CL-2022-11 | https://sunsama.canny.io/changelog/weekly-update-november-4-2022 |
| CL-AR | https://sunsama.canny.io/changelog/auto-reschedule |
| CL-2023-05 | https://sunsama.canny.io/changelog/weekly-update-may-26-2023 |
| CL-2023-12 | https://sunsama.canny.io/changelog/weekly-update-december-8-2023-1 |
| CL-2024-03 | https://sunsama.canny.io/changelog/weekly-update-march-22-2024 |
| CL-2024-04 | https://sunsama.canny.io/changelog/weekly-update-april-26-2024 |
| CL-2024-10 | https://sunsama.canny.io/changelog/weekly-update-october-11-2024 |
| CL-2024-12 | https://sunsama.canny.io/changelog/weekly-update-december-20-2024 |
| CL-2025-02-21 | https://sunsama.canny.io/changelog/weekly-update-february-21-2025 |
| CL-2025-02-28 | https://sunsama.canny.io/changelog/weekly-update-february-28-2025 |
| CL-RIGID | https://sunsama.canny.io/changelog/visualize-recurring-tasks-at-a-set-time-on-your-calendar-via-rigid-projections |
| CL-BL2 | https://sunsama.canny.io/changelog/backlog-20 |
| CL-2026-04 | https://sunsama.canny.io/changelog/weekly-product-changelog-april-17-2026 |
| CL-PRIO | https://sunsama.canny.io/changelog/task-priority-auto-sort |
| CL-2026-06 | https://sunsama.canny.io/changelog/weekly-product-changelog-june-12-2026 |
| CL-2026-09-29 | https://sunsama.canny.io/changelog/weekly-product-changelog-september-29-2026 |
| RM-AB | https://roadmap.sunsama.com/mobile-apps/p/easily-move-item-from-archived-to-backlog |
| RM-CH | https://roadmap.sunsama.com/improvements/p/set-task-rollover-days-by-channel |
| RM-SUB | https://roadmap.sunsama.com/improvements/p/allow-user-to-choose-if-partially-completed-recurring-tasks-rollover |

Ghi chú về độ tin cậy:
- Trang Daily Planning hiện tại [DP: https://help.sunsama.com/docs/usage-guides/daily-planning] mô tả bản "agentic" (beta). Mô tả cảnh báo khối lượng lấy từ trang bản cũ [DPL].
- "Mặc định 4 ngày" của archive là suy ra từ câu "expand the threshold from four days" [AR], không phải câu khẳng định trực tiếp.
- Trả lời trên [RM-AB] được gắn huy hiệu thành viên, nhưng trang không ghi rõ người trả lời là nhân viên Sunsama.
- Các chỗ PRD ghi "đã kiểm chứng trên Sunsama ngày 04/11/2026" (ví dụ Thùng rác 7 ngày, bộ đếm đi theo bộ lọc) **không có trong tài liệu công khai**; nên lưu ảnh chụp làm bằng chứng khi kiểm chứng bằng Chrome (C4, C8).
