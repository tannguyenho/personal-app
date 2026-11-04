> **Mã:** PLN-SRS-G02 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g02-quan-ly-task.md

# UC-G02 - Quản lý task trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả vòng đời task (tạo, sửa chi tiết, hoàn thành, nhân bản, xoá / khôi phục) và context / channel. Lặp lại (G03), board và kéo thả (G04), timebox (G05), backlog và rollover (G06), timer (G07) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). Quy tắc `QC-xx` ở [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md). G02 sở hữu **QC-03** (trạng thái task và khôi phục) và **QC-08** (đồng bộ nhiều thiết bị, offline); mục 4 của SRS này là đặc tả chi tiết của QC-03 trong phạm vi G02. G02 cũng sở hữu cài đặt **khung giờ channel** (QC-02 mục 5–9, Q38a), đặc tả ở BR-22 – BR-24, UC-06 và SCR-06. "Hôm nay", "ngày" trong SRS này luôn là ngày làm việc (QC-01).
>
> Cập nhật thêm theo vòng 5–6 (Q33–Q46): bản 1.0 là app Windows cho một người dùng (Q35, Q45, [ADR-0005](../adr/0005-nen-tang-windows-truoc.md)); gợi ý task dùng trợ lý AI qua Claude Code CLI (QC-12, Q33, [ADR-0004](../adr/0004-ai-qua-claude-code-cli.md)); AI hoàn thành / xoá task chỉ khi người dùng bật công tắc (QC-12 mục 4); bỏ lưu trữ thủ công khỏi 1.0 (Q34). Tính năng để bản sau gom ở [`02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md).
>
> Cập nhật theo vòng 7: khung giờ channel một khoảng mỗi ngày, không vắt nửa đêm, bước 15 phút (D1), đổi khung có hiệu lực từ ngày làm việc kế tiếp (D2), "Chưa phân loại" không có khung riêng (D3) — BR-22, BR-24, UC-06, SCR-06; số ngày bị hoãn theo lịch hiện tại của task (D4); công tắc AI hoàn thành / xoá áp cho cả subtask, AI không hoàn thành hay xoá task có liên kết tích hợp (D10) — BR-21; chờ duyệt chỉ áp cho thay đổi sau lần đầu đọc dữ liệu tích hợp (D8); phím toàn cục Ctrl+Shift+A có ở 1.0 (D11); bản 1.1 vẫn một người dùng, nhiều thành viên từ 1.2 trở đi (Q47).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng ghi task trong vài giây, bổ sung chi tiết khi cần, hoàn thành, nhân bản, xoá và khôi phục mà không mất dữ liệu; phân loại task theo channel |
| Actor | Người dùng đã đăng nhập · Hệ thống · Trợ lý AI (Claude Code CLI trên máy người dùng, điều khiển app qua MCP local, QC-12; tác nhân `ai`) · Dịch vụ đọc tiêu đề URL |
| Phạm vi | Tạo task (ô soạn, phím A, dán URL), gợi ý thời lượng / channel qua trợ lý AI, chi tiết task, subtask (một cấp, xoá có Hoàn tác), priority, due, notes, comment, nhật ký, hoàn thành, nhân bản, xoá mềm, Thùng rác 30 ngày, context & channel (channel hệ thống "Chưa phân loại"), khung giờ channel (QC-02 mục 5–9), bộ trạng thái task (QC-03), đồng bộ nhiều thiết bị và offline (QC-08) |
| Ngoài phạm vi | Lặp lại, kéo thả và sắp xếp board, projection và sức chứa (G04, đọc khung giờ channel), timebox và auto-schedule (G05), backlog và rollover (G06), timer, đính kèm file (1.1), lưu trữ thủ công `manual` (bản sau, Q34), giao task / follow và quyền tạo channel chung / riêng tư (bản sau, 1.2 trở đi, Q35, Q47), trial / thanh toán gói cá nhân một người dùng / chế độ chỉ đọc (1.1, QC-09, Q47), gộp task |
| Nền tảng | App **Windows** (Flutter) ở 1.0, một người dùng, dữ liệu trên cloud gắn tài khoản (Q45, ADR-0005). Web, macOS từ 1.1; iOS / Android từ 1.2, dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Gõ tiêu đề rồi Enter là có task trong ngày | Ghi việc nhanh, không mất mạch |
| US-02 | Người dùng | Dán link để tạo task có sẵn tiêu đề | Không phải gõ lại |
| US-03 | Người dùng | Được gợi ý thời lượng và channel | Không phải ước lượng và phân loại thủ công mỗi lần |
| US-04 | Người dùng | Chia task thành subtask, thêm notes, priority, hạn chót | Có đủ thông tin khi làm |
| US-05 | Người dùng | Đánh dấu xong một lần cho cả task và subtask | Đỡ thao tác |
| US-06 | Người dùng | Hoàn tác khi lỡ xoá / lỡ đánh dấu xong, khôi phục từ Thùng rác | Không mất dữ liệu |
| US-07 | Người dùng | Nhân bản task tương tự | Không tạo lại từ đầu |
| US-08 | Người dùng | Tạo và quản lý context / channel | Biết thời gian dành cho từng mảng |
| US-09 | Người dùng thành thạo | Làm mọi thao tác trên bằng phím tắt | Không rời bàn phím |
| US-10 | Người làm nhiều vai | Đặt ngày và giờ riêng cho từng channel | Projection, sức chứa ngày, "ngày làm việc kế tiếp" đúng giờ thật của từng mảng việc |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Thuộc tính và giới hạn.** Tiêu đề 1–500 ký tự (cắt khoảng trắng hai đầu); thời lượng 1 phút – 24 giờ; subtask ≤ 100 / task; notes ≤ 50.000 ký tự; comment 1–5.000 ký tự. Giới hạn lấy từ \[AppConfig\], không hard-code `[giả định]` |
| BR-02 | Task tạo từ cột ngày D có `startDate = D` (ngày dự định). Không có ngày → task thuộc backlog (G06). D < hôm nay → server từ chối (chặn ngày quá khứ, QC-05) |
| BR-03 | Vị trí task mới: đầu hoặc cuối danh sách ngày theo cài đặt "Vị trí task mới" (mặc định đầu) |
| BR-04 | **Gợi ý** (Q33). \[TaskSuggest\] dùng trợ lý AI qua Claude Code CLI trên máy người dùng (QC-12 mục 1); app không gọi LLM nào khác. Chỉ gọi khi đủ cả: trợ lý AI bật và đã đồng ý (QC-12 mục 7), máy có Claude Code dùng được (QC-12 mục 2), cài đặt gợi ý bật. Thiếu một điều kiện → không gọi, không có gợi ý AI: thời lượng trống, channel mặc định (BR-05). Thời lượng và channel do \[TaskSuggest\] trả về được đánh dấu nguồn `ai`; người dùng sửa → nguồn `user`; hệ thống không bao giờ ghi đè giá trị nguồn `user` |
| BR-05 | Mỗi task thuộc đúng một channel. Không có gợi ý và người dùng không chọn → channel hệ thống **"Chưa phân loại"** (`isSystem = true`), do G01 tạo khi đăng ký (B4) |
| BR-06 | Priority: 1 Urgent, 2 Priority, 3 Normal (mặc định), 4 Low |
| BR-07 | Due độc lập với ngày dự định. Due < ngày dự định: cho lưu, hiện cảnh báo MSG-06 |
| BR-08 | **Hoàn thành task** (một giao dịch, ghi cụm vị trí nguyên khối theo QC-03 mục 2): (a) timer và timebox theo QC-05 dòng "Hoàn thành": dừng timer nếu đang chạy; giữ timebox, chỉ rút ngắn khi `completedAt` nằm trong khoảng giờ của timebox (B10); (b) mọi subtask chưa xong chuyển xong, ghi lại danh sách subtask được tự tích; (c) lưu cờ `plannedAsActual` = giá trị cài đặt "Tính planned là actual" (G01) tại thời điểm hoàn thành. Thời gian thực tế hiển thị theo QC-07 mục 4–5; **không tạo bản ghi thời gian** (Q13); (d) ngày dự định theo QC-05: task thường (kể cả task backlog) → `startDate` = `workday(completedAt)` (QC-01), xoá `backlogBucket`; instance lặp → giữ nguyên `startDate` (Q12); (e) số ngày bị hoãn reset (QC-04); (f) lưu ảnh chụp trước khi hoàn thành (`startDate` / `backlogBucket`, danh sách subtask tự tích) để dùng cho BR-09; (g) tác nhân `ai` (qua MCP local) chỉ được hoàn thành khi thoả BR-21 |
| BR-09 | **Bỏ hoàn thành** theo QC-03 mục 4 (Q25). `workday(now)` = `workday(completedAt)` → trả lại mọi tác dụng phụ của BR-08 từ ảnh chụp (f): subtask được tự tích về chưa xong, xoá `plannedAsActual`, trả `startDate` hoặc `backlogBucket` cũ; kết quả giống Hoàn tác trên toast. Khác ngày làm việc → chỉ xoá `completedAt` (và `plannedAsActual`); task ở `KE_HOACH` hôm nay; subtask giữ nguyên. Timer đã dừng không chạy lại |
| BR-10 | **Nhân bản** (C11). Chép: tiêu đề, notes, subtask **chưa xong** (tiêu đề + thời lượng), channel, `plannedMin`, priority. Không chép: series (bản sao là task thường), due, comment, timebox, thời gian thực tế, link nguồn, objective. `startDate` = hôm nay; vị trí theo cài đặt "Vị trí task mới" (BR-03) |
| BR-11 | **Xoá** là xoá mềm: task chuyển `DA_XOA` (`deletedAt`), lưu trạng thái trước khi xoá (`deletedFromStatus`) cho BR-12; không hỏi xác nhận, luôn có Hoàn tác. Timer và timebox theo QC-05 dòng "Xoá": dừng timer và lưu thời gian trước khi xoá; timebox tương lai bị gỡ, sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, giữ sự kiện. Hoàn tác (toast / Ctrl+Z) khôi phục cả liên kết timebox, tạo lại sự kiện ngoài đã xoá với giờ cũ (QC-05). Xoá instance lặp → ngày gốc thành ngày ngoại lệ (G03 BR-15). Giữ trong Thùng rác 30 ngày (QC-03, Q28), sau đó xoá vĩnh viễn. Bản ghi thời gian của task đã xoá không tính (QC-07). Tác nhân `ai` (qua MCP local) chỉ được xoá khi thoả BR-21 |
| BR-12 | **Khôi phục** từ Thùng rác: theo bảng QC-03 mục 3 (về đúng trạng thái trước khi xoá). Khôi phục reset số ngày bị hoãn (QC-04 mục 3). Instance lặp: áp QC-06 đường thủ công (cho khôi phục, cảnh báo MSG-24). Khôi phục từ Thùng rác (sau khi toast đã tắt) không tạo lại timebox. Khôi phục không gỡ ngày ngoại lệ của series (G03 BR-15) |
| BR-13 | Mọi thay đổi ghi \[ActivityLog\]: tác nhân (`user` / `ai` / `integration` / `system`), trường, giá trị cũ, giá trị mới, thời điểm |
| BR-14 | **Channel.** Tên 1–50 ký tự, không chứa "#", không trùng trong cùng context (không phân biệt hoa thường). Xoá channel phải chọn channel nhận task (mặc định "Chưa phân loại"); không xoá task. \[ChannelDelete\] chuyển **mọi** task của channel sang channel nhận, kể cả task `LUU_TRU`, `DA_XOA` (Thùng rác) và mẫu của series lặp (G03) (C10). Không xoá được channel hệ thống "Chưa phân loại" (B4). Channel hệ thống thuộc context nào `[giả định: không thuộc context nào, hiện ở đầu danh sách channel]`. Bản 1.0 một người dùng: người dùng tạo, sửa, xoá channel tự do, không phân quyền; quyền tạo channel chung / riêng tư theo vai trò để bản sau (Q35). Cờ `isPrivate` ở 1.0 chỉ dùng cho G05 (sự kiện timebox ghi ra lịch ngoài thành Private); phần chia sẻ trong workspace để bản sau (Q37). Khung giờ channel theo BR-22 – BR-24 |
| BR-15 | Bản 1 chỉ một người dùng (Q35): người dùng chỉ thấy và sửa task của chính mình. Workspace nhiều thành viên, giao task, follow để bản sau, 1.2 trở đi; bản 1.1 vẫn chỉ một người dùng (Q47; G12, [`02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md)); khi làm, task được giao vào bucket backlog "Tuần sau", đặt lên đầu (Q36) |
| BR-16 | Phím tắt một ký tự chỉ hoạt động khi không có ô nhập nào đang focus; lệnh có tác dụng phụ (C, Ctrl+Backspace) luôn có toast Hoàn tác |
| BR-17 | **Subtask** (C9). (a) Chỉ một cấp: subtask không có subtask con. (b) Tích subtask cuối cùng **không** tự hoàn thành task. (c) Thêm subtask vào task `HOAN_THANH` → subtask `CHUA_XONG`, task giữ `HOAN_THANH`, không mở lại. (d) Xoá subtask không hỏi xác nhận, có toast Hoàn tác (MSG-21) ≥ 5 giây; Hoàn tác trả subtask về đúng vị trí, trạng thái, thời lượng, thời gian thực tế. Subtask đã xoá không vào Thùng rác `[giả định]`. (e) Timer chạy trên task cha, không chạy trên subtask (QC-07 mục 6) |
| BR-18 | **Trạng thái task** theo QC-03 (G02 sở hữu), đặc tả ở mục 4. Mọi thao tác của G02 làm đổi trạng thái hoặc ngày dự định ghi **cụm vị trí** nguyên khối và tăng `positionVersion` |
| BR-19 | **Đồng bộ** theo QC-08 (G02 sở hữu). Lệnh sửa cụm vị trí (hoàn thành, bỏ hoàn thành, xoá, khôi phục, đổi ngày trong SCR-03) gửi kèm `positionVersion`; lệch → 412 `VERSION_CONFLICT`, MSG-23. Trường khác gộp theo từng trường, bản server nhận sau thắng, người dùng bị ghi đè thấy MSG-12. Lệnh sửa task `DA_XOA` → 409 `TASK_DELETED`, MSG-22 |
| BR-20 | **Ngày.** Mọi "hôm nay", "ngày hoàn thành", "ngày xoá" trong G02 tính bằng `workday(t)` của QC-01; không dùng ngày lịch hay nửa đêm |
| BR-21 | **AI hoàn thành / xoá task và subtask** (QC-12 mục 4–5, Q46, D10; thay một phần Q20). Lệnh \[TaskComplete\] / \[TaskDelete\] và lệnh hoàn thành / xoá subtask (\[SubtaskUpdate\] `completedAt`, \[SubtaskDelete\]) với tác nhân `ai` (từ MCP local) chỉ được nhận khi: (a) trợ lý AI đang bật (QC-12 mục 7); (b) người dùng đã bật công tắc "Cho phép AI hoàn thành và xoá task" (mặc định tắt, cài đặt AI của G10); công tắc áp cho cả subtask (D10); (c) cả hoàn thành lẫn xoá: task (với subtask: task cha) **không** có liên kết tích hợp (G11), kể cả khi đã bật công tắc (D10). Thiếu (a) hoặc (b) → 403 `AI_ACTION_FORBIDDEN` · reason `TOGGLE_OFF`; vi phạm (c) → 403 `AI_ACTION_FORBIDDEN` · reason `LINKED_TASK`, áp cho cả hoàn thành và xoá (dùng chung mã của G10); lỗi trả cho Claude Code qua MCP, không đổi task. Lệnh hợp lệ áp đúng BR-08 / BR-11 / BR-17 như người dùng, ghi \[ActivityLog\] tác nhân `ai`, gắn chip "AI" trên task, có Hoàn tác (từng thay đổi và "Hoàn tác kế hoạch AI", G10). Phiên AI đã bật đọc dữ liệu tích hợp → các lệnh **sau** lần đầu đọc dữ liệu tích hợp trong phiên đó chuyển sang chờ duyệt thay vì áp dụng ngay (QC-12 mục 6, D8, G10). Bỏ hoàn thành (BR-09) không có trong MCP `[giả định]` |
| BR-22 | **Khung giờ channel** (QC-02 mục 5, Q38a; G02 sở hữu cài đặt). Mỗi channel do người dùng tạo có trường tuỳ chọn `workWindow`. Channel hệ thống "Chưa phân loại" **không** có khung riêng, luôn theo lịch chung (D3): SCR-06 ẩn phần "Khung giờ" của channel này; server từ chối `workWindow` khác null cho channel `isSystem` (`VALIDATION_FAILED` · field workWindow · `SYSTEM_CHANNEL`). `workWindow` = null (mặc định) → channel dùng lịch làm việc chung (G01 BR-22, `workSchedule`) và tự theo khi lịch chung đổi. Khi bật, `workWindow` = danh sách ngày trong tuần, mỗi ngày {`weekday`, `start`, `end`}; ràng buộc: (a) ≥ 1 ngày (MSG-26); (b) mỗi ngày đúng một khoảng (D1); (c) `end` > `start` (MSG-25), cùng một ngày lịch, không vắt qua nửa đêm (24:00) (D1); (d) giờ theo bước 15 phút (D1), theo timezone của người dùng; (e) được chọn cả ngày không có trong lịch chung (ví dụ Chủ Nhật). Bật lần đầu → điền sẵn bằng lịch chung hiện tại `[giả định]`. Lịch chung đổi sau đó không đổi `workWindow` đã bật. Đồng bộ: `workWindow` gộp như **một trường** theo QC-08 mục 3 (bản server nhận sau thắng cả khối) `[giả định]` |
| BR-23 | **Lịch làm việc của task** (QC-02 mục 6–8). = `workWindow` của channel của task nếu có, ngược lại lịch làm việc chung. G02 chỉ sở hữu cài đặt; các nhóm đọc `workWindow` qua \[ChannelList\] và tự áp: (a) G04 — projection và cờ "Vượt giờ làm" của task theo lịch của task; sức chứa ngày D = thời gian trống trong **hợp** của lịch chung và mọi `workWindow` có ngày D (QC-02 mục 7); (b) G06 — số ngày bị hoãn chỉ đếm ngày có trong lịch của task (QC-04, Q32); (c) G04 phím D, G08 shutdown "Ngày mai" — "ngày làm việc kế tiếp" theo lịch của task (QC-02 mục 2, QC-05); (d) G05 — auto-schedule chỉ xếp task vào khung của channel (bản 1.1). **Không** dùng cho: ritual ngày (G08) và cột ngày G09 (theo lịch chung, QC-02 mục 8); quy tắc lặp (G03, Q43) |
| BR-24 | **Hiệu lực khi đổi khung** (D2, cùng tinh thần Q3, QC-01 mục 3). Bật, sửa hoặc tắt `workWindow` có hiệu lực từ **ngày làm việc kế tiếp** (`workWindowEffectiveFrom` = ngày làm việc kế tiếp của hôm nay theo QC-01): ngày hôm nay vẫn dùng khung cũ (projection, sức chứa, "ngày làm việc kế tiếp" khi dời trong hôm nay); các ngày ≥ `workWindowEffectiveFrom` dùng khung mới ngay khi lưu. Server lưu khung đang áp và khung chờ (`pendingWorkWindow`, `workWindowEffectiveFrom`); tới mốc đầu ngày của `workWindowEffectiveFrom` thì khung chờ thành khung đang áp. Sửa tiếp trước ngày hiệu lực → ghi đè khung chờ. Số ngày bị hoãn luôn tính theo lịch **hiện tại** của task, nên đổi khung hoặc đổi channel có thể làm số thay đổi (D4; G06 BR-10, QC-04 mục 1). Đổi channel của một task (UC-02) hoặc chuyển task khi xoá channel (BR-14) → lịch của task theo channel mới ngay từ hôm nay `[giả định]` |

## 4. Trạng thái

### 4.1. Trạng thái task

Bộ trạng thái và điều kiện của từng trạng thái theo **QC-03 mục 1**; đây là bộ duy nhất cho mọi nhóm, không nhóm nào thêm trạng thái riêng. Bảng dưới chỉ bổ sung cách hiển thị trong G02.

| **Trạng thái** (QC-03) | **Hiển thị** |
| --- | --- |
| `KE_HOACH` | Card trên cột ngày dự định; ✓ rỗng |
| `BACKLOG` | Trong panel Backlog (G06) |
| `HOAN_THANH` | Card mờ, ✓ xanh, hiện "actual / planned" (QC-07 mục 5) |
| `LUU_TRU` (`archiveReason` ∈ `stale` / `skipped`; `manual` để bản sau, Q34) | Chỉ hiện trong panel Lưu trữ (G06), kèm nhãn lý do |
| `DA_XOA` | Chỉ hiện trong Thùng rác (SCR-05), kèm ngày xoá; xoá vĩnh viễn sau 30 ngày |

Thuộc tính suy ra, **không phải trạng thái**: "Đã dời" (số ngày bị hoãn ≥ 1, QC-04), "Lệch ngày" (QC-01 mục 4), timer đang chạy (G07), instance lặp (G03).

**Chuyển trạng thái** (mọi chuyển ghi cụm vị trí nguyên khối, QC-03 mục 2):

| **Từ** | **Sang** | **Sự kiện** | **Nhóm** |
| --- | --- | --- | --- |
| – | `KE_HOACH` / `BACKLOG` | Tạo task (UC-01), sinh instance lặp (G03), tạo từ item (G11) | G02, G03, G11 |
| `KE_HOACH` / `BACKLOG` | `HOAN_THANH` | Hoàn thành (UC-03, BR-08) | G02 |
| `HOAN_THANH` | `KE_HOACH` / `BACKLOG` | Bỏ hoàn thành, Hoàn tác (UC-03 A1, A2, BR-09). Khác ngày làm việc → luôn `KE_HOACH` hôm nay | G02 |
| `KE_HOACH` ⇄ `BACKLOG` | | Đổi ngày, đưa vào backlog, lấy ra ngày (QC-05) | G04, G06 |
| `KE_HOACH` | `LUU_TRU` | Rollover tự lưu trữ (`stale`, QC-04); instance trùng series trên đường tự động (`skipped`, QC-06). Không có lưu trữ tay (`manual`) ở 1.0 (Q34) | G06 (QC-06 do G04, G06, G08 thực thi) |
| `LUU_TRU` | `KE_HOACH` | Khôi phục từ Lưu trữ | G06 |
| `KE_HOACH` / `BACKLOG` / `HOAN_THANH` / `LUU_TRU` | `DA_XOA` | Xoá (UC-04), "Xoá tất cả" trong Lưu trữ (G06), xoá instance của series (G03 BR-08) | G02, G03, G06 |
| `DA_XOA` | Trạng thái trước khi xoá | Hoàn tác, khôi phục từ Thùng rác (UC-04, BR-12, QC-03 mục 3) | G02 |
| `DA_XOA` | (xoá vĩnh viễn) | Quá 30 ngày trong Thùng rác (job hằng ngày) | G02 |

### 4.2. Trạng thái subtask

`CHUA_XONG` ⇄ `XONG`; subtask có thể bị xoá (BR-17 d), không có trạng thái `DA_XOA` riêng.

- Task chuyển `HOAN_THANH` → mọi subtask `CHUA_XONG` thành `XONG` (BR-08 b).
- Bỏ hoàn thành trong cùng ngày làm việc → subtask được tự tích quay về `CHUA_XONG`; khác ngày → subtask giữ nguyên (BR-09).
- Subtask cuối cùng chuyển `XONG` → task **không** đổi trạng thái (BR-17 b).
- Thêm subtask vào task `HOAN_THANH` → subtask mới `CHUA_XONG`, task giữ `HOAN_THANH` (BR-17 c).

## 5. Use Case

### UC-01 Tạo task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; (từ 1.1) workspace không ở chế độ chỉ đọc (QC-09) |
| Hậu điều kiện thành công | Task lưu ở trạng thái `KE_HOACH` (hoặc `BACKLOG`); hiện trên cột ngày; tổng thời lượng ngày cập nhật; nhật ký ghi "tạo task" |
| Hậu điều kiện thất bại | Không có task mới; nội dung đã gõ còn trong ô soạn |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Thêm task" trên cột ngày D (hoặc phím A khi cột D đang chọn) |
| 2 | Hệ thống | Mở **SCR-01**, focus vào ô tiêu đề; ngày = D |
| 3 | Người dùng | Gõ tiêu đề |
| 4 | Hệ thống | Sau 400 ms ngừng gõ `[giả định]`, nếu đủ điều kiện BR-04 (trợ lý AI bật, đã đồng ý, có Claude Code, bật gợi ý) gọi \[TaskSuggest\] qua Claude Code CLI; điền thời lượng và channel có biểu tượng ✨ (BR-04) |
| 5 | Người dùng | Tuỳ chọn sửa ngày, thời lượng, channel, priority, vị trí; nhấn Enter |
| 6 | Hệ thống | Kiểm tra BR-01; gọi \[TaskCreate\] (idempotency key do client sinh); hiện task ngay theo BR-03 (cập nhật lạc quan) |
| 7 | Hệ thống | Đóng ô soạn hoặc giữ mở để gõ task kế tiếp `[giả định: giữ mở]` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng dán URL ở bước 3 | Gọi \[TaskFromUrl\]; tiêu đề = tiêu đề trang, không đọc được → dùng URL; task giữ link nguồn |
| A2 | Người dùng xoá ngày ở bước 5 | Task tạo vào backlog (BR-02), toast MSG-07 có link mở Backlog |
| A3 | Người dùng nhấn Esc khi đã gõ | Đóng ô soạn, giữ bản nháp trên máy; mở lại ô soạn của cùng ngày thấy nội dung cũ |
| A4 | \[TaskSuggest\] lỗi / chậm > 2s / tắt gợi ý / trợ lý AI tắt hoặc chưa đồng ý / máy không có Claude Code (QC-12 mục 2) / Claude Code báo hết hạn mức | Không có gợi ý AI, không gọi LLM nào khác (Q33); thời lượng trống, channel mặc định (BR-05); ô soạn không chờ, tạo task bình thường |
| A5 | Gõ "#" trong tiêu đề | Mở danh sách channel có ô tìm; chọn → gán channel, xoá "#..." khỏi tiêu đề |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tiêu đề trống sau khi cắt khoảng trắng | Enter không làm gì; nút tạo disabled |
| E2 | Tiêu đề > 500 ký tự | MSG-01 dưới ô, chặn tạo |
| E3 | Mất mạng | Lưu vào hàng đợi trên máy (QC-08), card có biểu tượng "chờ đồng bộ"; có mạng gửi lại với cùng idempotency key (không tạo trùng) |
| E4 | \[TaskCreate\] lỗi 5xx | Card chuyển trạng thái lỗi, MSG-10 có nút "Thử lại" |
| E5 | (1.1) Workspace chỉ đọc (QC-09) | MSG-11, không tạo |
| E6 | Ngày D < hôm nay (cột ngày đã qua) | Server trả `VALIDATION_FAILED` · field startDate · `PAST_DATE` (QC-05); MSG-20, không tạo; nội dung còn trong ô soạn |

### UC-02 Xem và sửa chi tiết task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task tồn tại, không ở `DA_XOA` |
| Hậu điều kiện thành công | Trường đã sửa được lưu; nhật ký ghi thay đổi (BR-13) |
| Hậu điều kiện thất bại | Trường giữ giá trị cũ; hiện lỗi tại trường |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm tiêu đề task hoặc Ctrl+Enter |
| 2 | Hệ thống | Gọi \[TaskDetail\]; mở **SCR-03** |
| 3 | Người dùng | Sửa một trường (tiêu đề, channel, priority, ngày, due, thời lượng, notes) |
| 4 | Hệ thống | Kiểm tra BR-01, BR-07; gọi \[TaskUpdate\] chỉ với trường đã đổi; cập nhật card và tổng ngày |
| 5 | Người dùng | Đóng bằng Esc hoặc nút × |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Thêm subtask | Nút "+ Subtask" hoặc phím V → dòng mới; Enter lưu (\[SubtaskCreate\]) và mở dòng kế tiếp; Esc trên dòng trống đóng |
| A2 | Đánh dấu subtask xong | ✓ trên dòng subtask → \[SubtaskUpdate\]; tooltip "Hoàn thành lúc {giờ}" |
| A3 | Đổi thứ tự subtask | Kéo thả hoặc Ctrl+↑/↓ trên dòng subtask |
| A4 | Thêm comment | Gõ vào ô comment, Enter gửi (\[CommentCreate\]); Shift+Enter xuống dòng |
| A5 | Xem nhật ký | Cuối SCR-03 hiện \[ActivityLog\] mới nhất trước, 20 dòng đầu, "Xem thêm" |
| A6 | Đặt due < ngày dự định | Lưu, hiện MSG-06 |
| A7 | Task đang có thay đổi từ thiết bị khác | Trường nhận giá trị mới qua realtime (gộp theo từng trường, QC-08 mục 3); trường đang gõ dở không bị thay, hiện MSG-12 khi người dùng rời trường |
| A8 | Xoá subtask | Icon xoá trên dòng subtask (hiện khi hover / focus dòng) → \[SubtaskDelete\]; dòng ẩn ngay; toast MSG-21 ≥ 5 giây. Bấm "Hoàn tác" trong toast → \[SubtaskRestore\] với `undoToken`; subtask về đúng vị trí, trạng thái, thời lượng, thời gian thực tế (BR-17 d) |
| A9 | Thêm subtask khi task đã `HOAN_THANH` | Tạo subtask `CHUA_XONG`; task giữ `HOAN_THANH`, card không đổi trạng thái (BR-17 c) |
| A10 | Tích xong subtask cuối cùng | Chỉ subtask chuyển `XONG`; task không tự hoàn thành (BR-17 b) |
| A11 | Đổi ngày dự định trong header SCR-03 | Theo đường "chọn ngày" của QC-05 (timebox giữ giờ dời sang ngày mới, reset số ngày bị hoãn); gửi kèm `positionVersion` (BR-19); instance lặp vào ngày đã có instance cùng series → cho phép, cảnh báo MSG-24 (QC-06 đường thủ công) |
| A12 | Đổi channel của task | \[TaskUpdate\] `channelId`; lịch làm việc của task theo channel mới (BR-23) ngay từ hôm nay (BR-24); G04 tính lại projection, sức chứa của các ngày bị ảnh hưởng |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Vi phạm BR-01 | Lỗi tại trường (MSG-01 / MSG-02 / MSG-03), không gửi |
| E2 | Subtask thứ 101 | MSG-04, chặn thêm |
| E3 | Task bị xoá ở thiết bị khác khi đang mở | Đóng SCR-03, MSG-09 kèm "Hoàn tác" |
| E4 | \[TaskUpdate\] lỗi | Trả trường về giá trị cũ, MSG-10 |
| E5 | Lệnh sửa (kể cả từ hàng đợi offline) tới task đã `DA_XOA` | 409 `TASK_DELETED`; bỏ lệnh khỏi hàng đợi, MSG-22 (QC-08 mục 4) |
| E6 | Đổi ngày ở A11 trên phiên bản cụm vị trí cũ | 412 `VERSION_CONFLICT`; tải lại task, trả ngày về giá trị server, MSG-23 (QC-08 mục 2) |
| E7 | Đổi ngày ở A11 sang ngày < hôm nay | Date picker không cho chọn; server trả `PAST_DATE`, MSG-20 (QC-05) |

### UC-03 Hoàn thành / bỏ hoàn thành task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task ở `KE_HOACH` hoặc `BACKLOG` (hoàn thành) / `HOAN_THANH` (bỏ hoàn thành) |
| Hậu điều kiện thành công | Áp BR-08 hoặc BR-09; thanh tiến độ ngày cập nhật; nhật ký ghi |
| Hậu điều kiện thất bại | Trạng thái không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm ✓ trên card / SCR-03, hoặc phím C khi task đang chọn |
| 2 | Hệ thống | Gọi \[TaskComplete\] kèm `positionVersion`; server áp BR-08 (a)–(f) trong một giao dịch |
| 3 | Hệ thống | Card chuyển `HOAN_THANH`; task thường chuyển sang cột hôm nay (ngày làm việc) nếu khác ngày cũ, instance lặp ở nguyên cột; hiện "actual / planned"; hiệu ứng chúc mừng nếu bật |
| 4 | Hệ thống | Toast MSG-08 có "Hoàn tác" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm ✓ trên task đã xong | Gọi \[TaskUncomplete\], áp BR-09: cùng ngày làm việc với `completedAt` → như A2; khác ngày → chỉ xoá `completedAt`, task ở `KE_HOACH` hôm nay |
| A2 | Bấm Hoàn tác trong toast | Gọi \[TaskUncomplete\]; server trả `startDate` / `backlogBucket`, subtask được tự tích, `plannedAsActual` về như trước bước 2 (BR-09, nhánh cùng ngày) |
| A3 | Hoàn thành task đang chạy timer ở thiết bị khác | Server dừng timer (BR-08 a), phát sự kiện `timer.changed` tới mọi thiết bị |
| A4 | Hoàn thành instance lặp ở ngày tương lai | Giữ nguyên ngày dự định (BR-08 d, Q12); instance hiện xong ở cột ngày đó |
| A5 | Hoàn thành lúc 00:00–mốc đầu ngày (ví dụ 02:00 ngày 05/11, mốc 04:00) | Ngày hoàn thành = 04/11 (`workday`, QC-01); task không nhảy sang cột 05/11 |
| A6 | Đang bật "Tính planned là actual", task không có bản ghi thời gian | Lưu `plannedAsActual = true`; card hiện actual = planned; không tạo bản ghi thời gian (BR-08 c) |
| A7 | Trợ lý AI (Claude Code qua MCP local) hoàn thành task | Kiểm BR-21: đủ điều kiện → áp BR-08 như bước 2–3, tác nhân `ai`, chip "AI", Hoàn tác (G10); thiếu công tắc → 403 `AI_ACTION_FORBIDDEN` · `TOGGLE_OFF`; task có liên kết tích hợp → 403 `AI_ACTION_FORBIDDEN` · `LINKED_TASK`; task không đổi. Hoàn thành subtask bởi AI kiểm cùng điều kiện (BR-21, D10) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Mất mạng | Áp ngay trên máy, xếp hàng đợi, đồng bộ sau (E3 UC-01). Khi gửi lên mà cụm vị trí trên server đã đổi (ví dụ rollover đã chạy) → 412 `VERSION_CONFLICT`, card về trạng thái server, MSG-23 (QC-08 mục 2) |
| E2 | \[TaskComplete\] lỗi | Trả card về trạng thái cũ, MSG-10 |
| E3 | Task đã bị xoá ở thiết bị khác | 409 `TASK_DELETED`, MSG-22 |

### UC-04 Xoá, hoàn tác và khôi phục task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task không ở `DA_XOA` (xoá) / ở `DA_XOA` (khôi phục) |
| Hậu điều kiện thành công | Xoá: task `DA_XOA`, biến khỏi board và lịch; timer, timebox, sự kiện ngoài xử lý theo QC-05 dòng "Xoá" (BR-11). Khôi phục: task về trạng thái trước khi xoá theo BR-12 (QC-03 mục 3) |
| Hậu điều kiện thất bại | Trạng thái không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … → "Xoá" (**SCR-04**) hoặc Ctrl+Backspace khi task đang chọn |
| 2 | Hệ thống | Dừng timer nếu đang chạy (BR-11); gọi \[TaskDelete\]; ẩn task ngay |
| 3 | Hệ thống | Toast MSG-09 "Đã xoá · Hoàn tác (Ctrl+Z)" trong ≥ 5 giây |
| 4 | Người dùng | (Tuỳ chọn) Bấm Hoàn tác / Ctrl+Z → \[TaskRestore\] `undo=true`; task về đúng vị trí cũ, liên kết timebox được khôi phục, sự kiện ngoài đã xoá được tạo lại với giờ cũ (QC-05) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Khôi phục sau khi toast đã tắt | Người dùng mở **SCR-05** Thùng rác (panel phải hoặc lệnh "Task đã xoá gần đây") → "Khôi phục" → \[TaskRestore\] áp BR-12, toast MSG-13 |
| A2 | Task có timebox | Xoá: theo QC-05 dòng "Xoá" (timebox tương lai gỡ, sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết). Hoàn tác (bước 4): khôi phục liên kết. Khôi phục từ Thùng rác (A1): không tạo lại timebox, task về projection |
| A3 | Task do AI tạo, người dùng bấm Hoàn tác trong khung chat (G10) | Task vào Thùng rác như xoá thường |
| A4 | Xoá instance lặp | Như luồng chính; thêm ngày gốc vào danh sách ngày ngoại lệ của series (G03 BR-15). Hoàn tác / khôi phục không gỡ ngày ngoại lệ |
| A5 | Khôi phục instance lặp vào ngày đã có instance của cùng series (QC-06 mục 1) | Vẫn khôi phục; toast MSG-13 kèm cảnh báo MSG-24 (QC-06 mục 3) |
| A6 | Khôi phục task trước đó `HOAN_THANH` / `LUU_TRU` / `BACKLOG` | Về đúng trạng thái trước khi xoá theo QC-03 mục 3: giữ ngày dự định và `completedAt`; về Lưu trữ với lý do cũ; về đúng bucket. MSG-13 nêu nơi đến |
| A7 | Trợ lý AI (Claude Code qua MCP local) xoá task | Kiểm BR-21 (a), (b), (c): đủ điều kiện → như bước 2, tác nhân `ai`, chip "AI", Hoàn tác (G10); chưa bật công tắc → 403 `AI_ACTION_FORBIDDEN` · `TOGGLE_OFF`; task có liên kết tích hợp → 403 `AI_ACTION_FORBIDDEN` · `LINKED_TASK` (D10); task không đổi. Xoá subtask bởi AI kiểm cùng điều kiện (BR-21) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Khôi phục task đã quá 30 ngày (đã xoá vĩnh viễn) | MSG-14, gỡ khỏi danh sách |
| E2 | (Bỏ — xoá channel đã chuyển cả task trong Thùng rác sang channel nhận, BR-14, C10) | – |
| E3 | \[TaskDelete\] / \[TaskRestore\] lỗi | Trả về trạng thái trước, MSG-10 |
| E4 | Xoá task trên phiên bản cụm vị trí cũ (lệnh offline) | 412 `VERSION_CONFLICT`, task hiện lại theo trạng thái server, MSG-23 (QC-08) |

### UC-05 Nhân bản task

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Task không ở `DA_XOA` |
| Hậu điều kiện thành công | Có task mới theo BR-10 trong danh sách hôm nay, ở đầu hoặc cuối theo cài đặt "Vị trí task mới" (BR-03); SCR-03 mở task mới |
| Hậu điều kiện thất bại | Không có task mới |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu … → "Nhân bản" hoặc Ctrl+D |
| 2 | Hệ thống | Gọi \[TaskDuplicate\]; tạo bản sao theo BR-10 |
| 3 | Hệ thống | Mở **SCR-03** của bản sao; nhật ký bản sao ghi "nhân bản từ {tiêu đề}" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Nhân bản instance lặp | Bản sao là task thường, không thuộc series, không có biểu tượng lặp (BR-10) |
| A2 | Nhân bản task đã xong | Bản sao `KE_HOACH` hôm nay; chỉ chép subtask chưa xong (task xong thì mọi subtask đã xong → bản sao không có subtask) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[TaskDuplicate\] lỗi | MSG-10, không mở bản sao |

### UC-06 Quản lý context và channel

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập |
| Hậu điều kiện thành công | Context / channel được tạo, sửa, ẩn hoặc xoá; task của channel bị xoá đã chuyển sang channel nhận; khung giờ channel (nếu đổi) lưu theo BR-22, hiệu lực theo BR-24 |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → "Context & channel" hoặc "Quản lý channel" trong bộ lọc → **SCR-06** |
| 2 | Người dùng | "Tạo context" hoặc "Tạo channel trong {context}"; nhập tên, chọn màu, bật / tắt riêng tư (ở 1.0 chỉ ảnh hưởng G05, BR-14). Bản 1.0 không phân quyền tạo channel (Q35) |
| 3 | Hệ thống | Kiểm tra BR-14; gọi \[ChannelCreate\]; channel hiện ngay trong ô soạn, bộ lọc |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Đổi tên / màu / riêng tư | Sửa tại dòng channel → \[ChannelUpdate\] |
| A2 | Ẩn channel | Tắt "Bật" → không hiện trong ô soạn và bộ lọc; task giữ nguyên; khung giờ channel giữ nguyên và vẫn áp cho task của channel |
| A3 | Xoá channel | Mở **SCR-07** chọn channel nhận task → \[ChannelDelete\] với `moveTasksTo`; server chuyển mọi task của channel, kể cả `LUU_TRU`, `DA_XOA` và mẫu series (BR-14, C10), trong một giao dịch. Task đã chuyển dùng lịch làm việc của channel nhận ngay (BR-24); khung giờ của channel bị xoá mất theo channel |
| A4 | Xoá context | Chỉ cho xoá context rỗng; còn channel → MSG-16 |
| A5 | Bật "Khung giờ riêng" cho channel (Q38a) | Trên dòng channel mở phần "Khung giờ" (SCR-06 #7–#10); bật công tắc → 7 dòng Thứ Hai … Chủ Nhật điền sẵn theo lịch chung hiện tại (BR-22) `[giả định]`; người dùng bật / tắt từng ngày (kể cả ngày không có trong lịch chung), chọn giờ bắt đầu / kết thúc (một khoảng / ngày, bước 15 phút, không vắt nửa đêm — D1); bấm "Lưu" → kiểm BR-22 → \[ChannelUpdate\] `workWindow`; server trả `workWindowEffectiveFrom` = ngày làm việc kế tiếp (BR-24); hiện MSG-27 |
| A6 | Sửa khung giờ đã bật | Như A5; khung mới là khung chờ, có hiệu lực từ ngày làm việc kế tiếp; hôm nay vẫn dùng khung cũ (BR-24); MSG-27 |
| A7 | Tắt "Khung giờ riêng" | \[ChannelUpdate\] `workWindow = null`; từ ngày làm việc kế tiếp task của channel dùng lịch chung (BR-24); MSG-27 |
| A8 | Lịch làm việc chung (G01) đổi | Channel không bật khung riêng theo lịch chung mới (theo hiệu lực của G01); channel đã bật khung riêng không đổi (BR-22) |
| A9 | Khung giờ được sửa trên thiết bị khác khi đang mở | Nhận giá trị mới qua realtime, gộp cả khối `workWindow` (BR-22); đang sửa dở → giữ bản đang sửa, hiện MSG-12 khi rời phần "Khung giờ" |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tên trùng trong context | MSG-15 |
| E2 | Tên chứa "#" hoặc > 50 ký tự | MSG-17 |
| E3 | Xoá channel hệ thống "Chưa phân loại" | Nút xoá ẩn (BR-14) |
| E4 | Khung giờ: giờ kết thúc ≤ giờ bắt đầu ở một ngày | MSG-25 tại dòng đó; nút "Lưu" disabled; server trả `VALIDATION_FAILED` · field workWindow · `END_BEFORE_START` |
| E5 | Khung giờ bật nhưng không ngày nào được bật | MSG-26; nút "Lưu" disabled; server trả `VALIDATION_FAILED` · field workWindow · `EMPTY` |
| E6 | Mất mạng khi lưu khung giờ | Lưu vào hàng đợi trên máy (QC-08), dòng channel có biểu tượng "chờ đồng bộ"; ngày hiệu lực tính theo thời điểm server nhận `[giả định]` |
| E7 | Đặt khung giờ cho channel hệ thống "Chưa phân loại" (gọi API trực tiếp; UI không có phần "Khung giờ" cho channel này) | Server trả `VALIDATION_FAILED` · field workWindow · `SYSTEM_CHANNEL`, không lưu (BR-22, D3) |

## 6. Điểm vào

| **Điểm vào** | **App Windows** (1.0) | **Web, macOS** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Nút "Thêm task" trên cột ngày | ✓ | ✓ | Ngày = cột đó |
| Phím A / command menu "Thêm task" | ✓ | ✓ | Cột ngày đang chọn, mặc định hôm nay |
| Phím tắt toàn cục Ctrl+Shift+A | ✓ (có từ 1.0, D11) | macOS ✓, web – | Ngày = hôm nay; chạy cả khi cửa sổ app không ở trước; tắt phím tắt (G01 BR-15) thì ngừng |
| Dán URL vào ô soạn | ✓ | ✓ | A1 UC-01 |
| Bấm tiêu đề card / Ctrl+Enter | ✓ | ✓ | Mở SCR-03 |
| Panel phải → Thùng rác / lệnh "Task đã xoá gần đây" | ✓ | ✓ | Mở SCR-05 |
| Cài đặt → Context & channel / bộ lọc → "Quản lý channel" | ✓ | ✓ | Mở SCR-06 |
| Dòng channel trong SCR-06 → "Khung giờ" | ✓ | ✓ | UC-06 A5–A7; không có ở channel "Chưa phân loại" (D3) |
| Claude Code qua MCP local (hoàn thành, xoá task và subtask) | ✓ khi bật trợ lý AI và công tắc (BR-21) | Cách cung cấp AI trên web để tech chốt (ADR-0004) | UC-03 A7, UC-04 A7 |

## 7. Mô tả màn hình

### SCR-01 Ô soạn task

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tiêu đề | Text nhiều dòng | Có | 1–500 ký tự; dán URL → A1; gõ "#" → danh sách channel (A5); quá 500 → MSG-01 |
| 2 | Gợi ý "Dán URL" | Hint | – | Hiện khi ô trống |
| 3 | Ngày dự định | Date picker | Không | Mặc định ngày của cột; có lựa chọn "Không ngày (backlog)"; không chọn được ngày < hôm nay (QC-05) |
| 4 | Thời lượng | Picker | Không | Ô giờ + ô phút, preset 5–45 phút, 1 giờ; giá trị gợi ý có ✨ (chỉ khi có gợi ý AI, BR-04) |
| 5 | Channel | Dropdown có tìm | Không | Giá trị gợi ý có ✨ (chỉ khi có gợi ý AI, BR-04); danh sách nhóm theo context |
| 6 | Objective | Dropdown | Không | Ẩn ở 1.0 (G09) |
| 7 | Priority | Menu cờ | Không | 4 mức, phím 1–4 khi menu mở |
| 8 | Vị trí | Toggle | Không | Đầu / cuối danh sách |
| 9 | Enter / nút tạo | Action | – | Disabled khi tiêu đề trống |

### SCR-02 Task card (trên cột ngày)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Giờ | Text | Giờ projection (G04) hoặc badge giờ timebox (G05) |
| 2 | Tiêu đề | Text | Bấm mở SCR-03; quá 2 dòng thì cắt "…" |
| 3 | Thời lượng | Badge | "planned" hoặc "actual / planned" khi đã có thời gian thực tế |
| 4 | Subtask | List | Hiện tối đa 5 subtask, ✓ bấm được trực tiếp |
| 5 | Priority, due | Chip | Hiện khi khác Normal / có due; due quá hạn màu cảnh báo |
| 6 | Channel | Nhãn "#tên" | Màu theo channel |
| 7 | Hover actions | Icon | ✓ hoàn thành, notes, thời lượng, priority |
| 8 | Biểu tượng đồng bộ | Icon | "Chờ đồng bộ" / "Lỗi, thử lại" (UC-01 E3, E4) |
| 9 | Nhãn "Dời {n} ngày" | Chip | Hiện khi số ngày bị hoãn n ≥ 1 (QC-04 mục 4) |
| 10 | Cờ "Lệch ngày" | Chip | Hiện khi timebox rơi vào ngày làm việc khác ngày dự định (QC-01 mục 4) |
| 11 | Chip "AI" | Chip | Hiện khi thay đổi gần nhất trên task do trợ lý AI thực hiện (kể cả hoàn thành / xoá theo BR-21); bấm mở Hoàn tác (G10, QC-12 mục 5) |

### SCR-03 Chi tiết task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Header thuộc tính | Toolbar | Channel · Priority · Ngày dự định (UC-02 A11) · Due · "+ Subtask" · menu … (SCR-04) · mở rộng · đóng |
| 2 | ✓ và tiêu đề | Checkbox + text | Sửa tiêu đề tại chỗ; ✓ → UC-03 |
| 3 | Thời gian | Hiển thị | "Thực tế" (theo QC-07 mục 5, gồm cả trường hợp `plannedAsActual`) và "Kế hoạch"; bấm Kế hoạch mở picker ô giờ / ô phút + preset + "Xoá thời lượng" |
| 4 | Danh sách subtask | List | Mỗi dòng: ✓, tiêu đề, thực tế, kế hoạch, icon xoá (UC-02 A8); kéo đổi thứ tự; không thụt cấp (một cấp, BR-17 a); dòng "Thêm subtask" |
| 5 | Notes | Rich text | Lưu khi gõ (debounce 1s `[giả định]`) |
| 6 | Timebox | Thông tin | Ngày, giờ bắt đầu – kết thúc, thời lượng (G05); ẩn khi không có |
| 7 | Comment | Input + list | Avatar, tên, giờ, nội dung |
| 8 | Nhật ký | List | "{tác nhân} {hành động} · {thời gian tương đối}" |

### SCR-04 Menu "Khác" của task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Lặp lại | Menu item | Mở cấu hình lặp (G03) |
| 2 | Gắn objective | Menu item | Ẩn ở 1.0 (G09) |
| 3 | Nhân bản | Menu item | Ctrl+D → UC-05 |
| 4 | Xoá | Menu item | Ctrl+Backspace → UC-04 |
| 5 | Sao chép link | Menu item | Copy link task, toast MSG-18 |

### SCR-05 Thùng rác

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề + mô tả | Header | "Thùng rác · Task đã xoá trong 30 ngày qua" |
| 2 | Danh sách task | List | Mới xoá nhất trước; mỗi dòng: tiêu đề, channel, thời lượng, ngày xoá |
| 3 | "Khôi phục" | Button (theo dòng) | → UC-04 A1 |
| 4 | Trạng thái rỗng | Empty state | "Không có task nào bị xoá" |

### SCR-06 Context & channel

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Tạo context", "Tạo channel" | Button | – | Mở dòng nhập mới |
| 2 | Tên context / channel | Text | Có | BR-14; trùng → MSG-15; sai định dạng → MSG-17 |
| 3 | Màu | Color picker | Có | 12 màu cố định `[giả định]` |
| 4 | Riêng tư | Toggle | Không | Ở 1.0 chỉ ảnh hưởng hiển thị trên lịch ngoài (G05: sự kiện timebox luôn Private); chia sẻ trong workspace (G12) để bản sau (Q35, Q37) |
| 5 | Bật / ẩn | Toggle | – | A2 UC-06 |
| 6 | Xoá | Icon | – | Mở SCR-07; ẩn với channel hệ thống "Chưa phân loại" |
| 7 | Khung giờ riêng | Toggle (theo dòng channel) | Không | Mặc định tắt = dùng lịch làm việc chung (G01, nhãn "Theo lịch làm việc chung"); bật → hiện #8 (UC-06 A5, A7; BR-22). Ẩn với channel hệ thống "Chưa phân loại", channel này luôn hiện nhãn "Theo lịch làm việc chung" (D3) |
| 8 | Ngày và giờ của khung | 7 dòng Thứ Hai … Chủ Nhật, thứ tự theo ngày đầu tuần (G01); mỗi dòng: toggle + 2 time picker | Có khi #7 bật | Điền sẵn theo lịch chung khi bật lần đầu `[giả định]`; bật được ngày không có trong lịch chung; bước 15 phút; một khoảng / ngày, không vắt qua nửa đêm (24:00) (D1); kết thúc ≤ bắt đầu → MSG-25; không ngày nào bật → MSG-26 |
| 9 | Ghi chú hiệu lực | Text | – | Sau khi lưu: MSG-27; khi có khung chờ: "Khung mới áp dụng từ {ngày}" (BR-24) |
| 10 | "Lưu" / "Huỷ" (phần Khung giờ) | Button | – | "Lưu" disabled khi vi phạm BR-22; "Huỷ" bỏ thay đổi chưa lưu |

### SCR-07 Xoá channel

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "Channel {tên} có {n} task (gồm cả task trong Lưu trữ, Thùng rác và task lặp). Chuyển các task này sang:" (BR-14) |
| 2 | Channel nhận | Dropdown | Mặc định "Chưa phân loại", không chứa channel đang xoá |
| 3 | "Xoá channel" | Button (nguy hiểm) | Gọi \[ChannelDelete\]; toast MSG-19 |
| 4 | "Huỷ" | Button | Đóng |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[TaskSuggest\] (chạy trên máy, qua Claude Code CLI, QC-12) | title, startDate | plannedMin, channelId, confidence; nguồn `ai` | 2s / không retry (bỏ qua gợi ý). Không gọi khi thiếu điều kiện BR-04 |
| \[TaskCreate\] `POST /tasks` | title, startDate, plannedMin, plannedSource, channelId, priority, position, Idempotency-Key | Task | 5s / retry 3 lần cùng key |
| \[TaskFromUrl\] `POST /tasks/from-url` | url, startDate | Task (title, externalRef) | 5s (đọc trang 3s) / 1 lần |
| \[TaskDetail\] `GET /tasks/{id}` | id | Task (gồm `status`, `archiveReason`, `plannedAsActual`, `positionVersion`, số ngày bị hoãn) + subtasks + timebox + actualMin | 5s / 1 lần |
| \[TaskUpdate\] `PATCH /tasks/{id}` | Trường thay đổi; `positionVersion` bắt buộc khi đổi cụm vị trí (BR-19), If-Match (tuỳ chọn) cho trường khác | Task, version, positionVersion | 5s / 2 lần |
| \[TaskComplete\] / \[TaskUncomplete\] | id, positionVersion; tác nhân (`user` / `ai` / `integration`) suy từ kênh gọi (MCP local → `ai`) | Task, timer (nếu bị dừng); tác nhân `ai` sai BR-21 → 403 `AI_ACTION_FORBIDDEN` (`TOGGLE_OFF` / `LINKED_TASK`) | 5s / 2 lần |
| \[TaskDuplicate\] `POST /tasks/{id}/duplicate` | id, Idempotency-Key | Task mới | 5s / 2 lần cùng key |
| \[TaskDelete\] `DELETE /tasks/{id}` | id, positionVersion; tác nhân như \[TaskComplete\] | deletedAt, deletedFromStatus; tác nhân `ai` sai BR-21 → 403 `AI_ACTION_FORBIDDEN` (`TOGGLE_OFF` / `LINKED_TASK`, D10) | 5s / 2 lần |
| \[TaskRestore\] `POST /tasks/{id}/restore` | id, `undo` (true khi Hoàn tác từ toast) | Task, `sameSeriesWarning` (true khi áp QC-06 mục 3) | 5s / 2 lần |
| \[TrashList\] `GET /tasks/trash` | cursor, limit | Task[], nextCursor | 5s / 1 lần |
| \[SubtaskCreate\] / \[SubtaskUpdate\] / \[SubtaskDelete\] | taskId, title, plannedMin, position, completedAt; tác nhân như \[TaskComplete\] | Subtask; \[SubtaskDelete\] trả thêm `undoToken`; tác nhân `ai` hoàn thành (`completedAt`) / xoá sai BR-21 → 403 `AI_ACTION_FORBIDDEN` (`TOGGLE_OFF` / `LINKED_TASK`, D10) | 5s / 2 lần |
| \[SubtaskRestore\] `POST /tasks/{taskId}/subtasks/restore` | undoToken | Subtask | 5s / 2 lần |
| \[CommentCreate\] / \[CommentList\] | taskId, body | Comment | 5s / 1 lần |
| \[ActivityLog\] `GET /tasks/{id}/activity` | id, cursor | Entry[] | 5s / 1 lần |
| \[ChannelCreate\] / \[ChannelUpdate\] / \[ChannelDelete\] | name, color, contextId, isPrivate, isHidden, moveTasksTo; `workWindow` (\[ChannelCreate\] / \[ChannelUpdate\]; null = dùng lịch chung) = [{`weekday` 1–7, `start` "HH:mm", `end` "HH:mm"}] theo BR-22; If-Match (tuỳ chọn) | Channel (`isSystem`, `workWindow` đang áp, `pendingWorkWindow`, `workWindowEffectiveFrom`, BR-24); \[ChannelDelete\] trả `movedTaskCount`, `movedSeriesCount` | 5s / 1 lần |
| \[ChannelList\] `GET /channels` | includeHidden | Channel[] (gồm `workWindow`, `pendingWorkWindow`, `workWindowEffectiveFrom`); G04, G05, G06, G08 đọc để tính lịch làm việc của task (BR-23) | 5s / 1 lần; cache trên máy, cập nhật qua realtime `channel.changed` |
| \[AppConfig\] | – | Giới hạn BR-01 | Cache 1h |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field title · TOO_LONG | MSG-01 |
| `VALIDATION_FAILED` · field plannedMin | MSG-02 |
| `VALIDATION_FAILED` · field notes / comment | MSG-03 |
| `LIMIT_SUBTASKS` | MSG-04 |
| `CHANNEL_NAME_TAKEN` | MSG-15 |
| `CONTEXT_NOT_EMPTY` | MSG-16 |
| `NOT_FOUND` (task đã xoá vĩnh viễn) | MSG-14 |
| `VALIDATION_FAILED` · field startDate · `PAST_DATE` | MSG-20 |
| `TASK_DELETED` (409) | MSG-22 |
| `VERSION_CONFLICT` (412) | MSG-23 |
| `WORKSPACE_READ_ONLY` (402, từ 1.1) | MSG-11 |
| `VALIDATION_FAILED` · field workWindow · `END_BEFORE_START` | MSG-25 |
| `VALIDATION_FAILED` · field workWindow · `EMPTY` | MSG-26 |
| `VALIDATION_FAILED` · field workWindow · `SYSTEM_CHANNEL` | Không hiện trong app (UI không cho đặt khung cho "Chưa phân loại", D3); MSG-10 nếu lọt tới người dùng |
| `AI_ACTION_FORBIDDEN` (403) · reason `TOGGLE_OFF` / `LINKED_TASK` | Không hiện trong app; trả cho Claude Code qua MCP để AI báo lại người dùng trong chat (G10) |
| 5xx / timeout | MSG-10 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Inline | Tên task tối đa 500 ký tự |
| MSG-02 | Inline | Thời lượng từ 1 phút đến 24 giờ |
| MSG-03 | Inline | Nội dung quá dài |
| MSG-04 | Inline | Mỗi task tối đa 100 subtask |
| MSG-05 | – | (dự phòng) |
| MSG-06 | Inline dưới due | Hạn chót sớm hơn ngày dự định |
| MSG-07 | Toast | Đã thêm vào Backlog · Mở Backlog |
| MSG-08 | Toast | Đã hoàn thành "{tiêu đề}" · Hoàn tác |
| MSG-09 | Toast | Đã xoá · Hoàn tác (Ctrl+Z) |
| MSG-10 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-11 | Banner | (1.1) Gói dùng thử đã hết. Nâng cấp để tiếp tục thêm và sửa task |
| MSG-12 | Inline | Task vừa được cập nhật trên thiết bị khác |
| MSG-13 | Toast | Đã khôi phục "{tiêu đề}" về {ngày / Backlog · {bucket} / Lưu trữ} |
| MSG-14 | Toast | Task này đã bị xoá vĩnh viễn |
| MSG-15 | Inline | Channel này đã tồn tại trong {context} |
| MSG-16 | Inline | Hãy chuyển hoặc xoá các channel trong context trước |
| MSG-17 | Inline | Tên channel 1–50 ký tự, không chứa "#" |
| MSG-18 | Toast | Đã sao chép link task |
| MSG-19 | Toast | Đã xoá channel {tên}, {n} task chuyển sang {channel nhận} |
| MSG-20 | Inline / Toast | Không thể đặt task chưa xong vào ngày đã qua |
| MSG-21 | Toast | Đã xoá subtask "{tiêu đề}" · Hoàn tác |
| MSG-22 | Toast | Task này đã bị xoá trên thiết bị khác. Thay đổi chưa được lưu |
| MSG-23 | Toast | Task đã thay đổi trên thiết bị khác |
| MSG-24 | Toast | Ngày này đã có {tên series} (dùng G03 MSG-21, QC-06) |
| MSG-25 | Inline | Giờ kết thúc phải sau giờ bắt đầu (cùng nội dung G01 MSG-20) |
| MSG-26 | Inline | Chọn ít nhất 1 ngày cho khung giờ của channel |
| MSG-27 | Inline dưới phần Khung giờ | Áp dụng từ ngày làm việc kế tiếp ({ngày}) (cùng nội dung G01 MSG-24) |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Nền tảng | App Windows (Flutter) ở 1.0 (Q45, ADR-0005); giao diện theo design system Figma riêng; dữ liệu lưu trên cloud gắn tài khoản, có bản trên máy để chạy offline. Kiến trúc cụ thể do tech chốt (`docs/tech/`) |
| Hiệu năng | Task hiện trên cột ≤ 100 ms sau Enter (cập nhật lạc quan); \[TaskCreate\] p95 ≤ 300 ms; SCR-03 mở ≤ 500 ms; ô soạn không bao giờ chờ \[TaskSuggest\] (Claude Code chạy trên máy, có thể chậm); lưu khung giờ channel → G04 tính lại projection / sức chứa ≤ 1 giây |
| Offline | Tạo, sửa, hoàn thành, xoá, sửa khung giờ channel chạy được khi mất mạng; đồng bộ lại không tạo trùng (idempotency key); xử lý xung đột, hàng đợi khi bị đăng xuất từ xa theo QC-08 |
| Đồng bộ | Thay đổi hiện trên thiết bị khác ≤ 5 giây qua realtime. Thứ tự theo thời điểm server nhận; job hệ thống cũng tăng phiên bản (QC-08 mục 1) |
| Toàn vẹn | Cụm vị trí (QC-03 mục 2) ghi nguyên khối; bất biến `KE_HOACH` ⇒ có `startDate`, không có `backlogBucket`; `BACKLOG` ⇒ ngược lại; kiểm ở server |
| Bảo mật | Chỉ chủ task đọc / sửa được (BR-15); lấy tiêu đề URL chặn IP nội bộ, timeout 3s; notes lọc HTML chống XSS; quyền AI hoàn thành / xoá kiểm ở server theo BR-21, không chỉ ở MCP local |
| Log / audit | \[ActivityLog\] cho mọi thay đổi (BR-13), gồm tác nhân `ai`; log hệ thống không chứa tiêu đề / notes |
| Tracking | Sự kiện: mở ô soạn, tạo task (nguồn: nút / phím / URL), giữ / sửa gợi ý, mở chi tiết, thêm / xoá / hoàn tác xoá subtask, hoàn thành, bỏ hoàn thành (cùng ngày / khác ngày), hoàn tác, xoá, khôi phục, nhân bản, tạo / xoá channel, bật / sửa / tắt khung giờ channel, hoàn thành / xoá bởi AI (được nhận / bị từ chối theo mã lỗi), xung đột `VERSION_CONFLICT` / `TASK_DELETED` |
| Accessibility | Mọi thao tác có phím tắt tương đương; ✓ và nút icon có nhãn đọc màn hình; tương phản đạt WCAG 2.1 AA ở cả giao diện sáng / tối |
