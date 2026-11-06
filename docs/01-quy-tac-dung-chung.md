# Quy tắc dùng chung — ứng dụng lập kế hoạch ngày

Mã tài liệu: `PLN-COMMON`. Chốt ngày 04/11/2026 theo [quyết định chốt mâu thuẫn](review/quyet-dinh-chot-2026-11-04.md).

Tài liệu này giữ các quy tắc mà nhiều nhóm cùng dùng. PRD/SRS của từng nhóm **tham chiếu** tới mã `QC-xx` ở đây, **không định nghĩa lại**. Nếu một nhóm cần ngoại lệ, nhóm đó ghi rõ là ngoại lệ của `QC-xx` nào. Thuật ngữ xem [`CONTEXT.md`](../CONTEXT.md).

| Mã | Quy tắc | Nhóm sở hữu | Nhóm dùng |
|---|---|---|---|
| QC-01 | Ngày làm việc | G01 | Tất cả |
| QC-02 | Lịch làm việc và khung giờ channel | G01 (lịch chung), G02 (khung channel) | G04, G05, G06, G08, G09, G10 |
| QC-03 | Trạng thái task và khôi phục | G02 | G03, G04, G06, G08, G09 |
| QC-04 | Số ngày bị hoãn | G06 | G04, G08 |
| QC-05 | Đổi ngày task | G06 | G02, G04, G05, G07, G08, G10 |
| QC-06 | Instance trùng series trong một ngày | G03 | G04, G06, G08 |
| QC-07 | Bản ghi thời gian | G07 | G02, G08, G09 |
| QC-08 | Đồng bộ nhiều thiết bị và offline | G02 | Tất cả |
| QC-09 | Chế độ chỉ đọc (1.1) | G12 | G03, G05, G06, G07, G08, G10, G11 |
| QC-10 | Quyền theo gói (1.1) | G12 | G05, G11 |
| QC-12 | Trợ lý AI qua Claude Code CLI và MCP local | G10 | G01, G02, G04, G05, G08, G11 |
| QC-11 | Danh mục tình huống biên (EC) | — | Tất cả |

---

## QC-01. Ngày làm việc

1. **Định nghĩa.** Ngày làm việc D kéo dài từ `mốc đầu ngày` của D tới `mốc đầu ngày` của D+1, theo timezone của người dùng. Mốc đầu ngày mặc định **04:00**, người dùng chỉnh trong khoảng **00:00–06:00** (G01). Xem [ADR-0001](adr/0001-ngay-lam-viec-va-timezone.md).
2. **Hàm dùng chung.** `workday(t)` = ngày lịch của (t − mốc đầu ngày), tính theo timezone của người dùng. Mọi chỗ cần biết "ngày" đều dùng hàm này:
   - "hôm nay" và "ngày mai" trên board (G04);
   - ngày dự định khi hoàn thành task (G02);
   - ngày khi kéo task vào lịch (G05);
   - rollover (G06);
   - bản ghi thời gian (G07);
   - ritual (G08);
   - recap tuần (G09);
   - AI hiểu ngày tương đối (G10).

   Không nhóm nào được dùng ngày lịch hay nửa đêm để suy ra ngày của task.
3. **Đổi cài đặt.** Đổi mốc đầu ngày hoặc timezone có hiệu lực từ **ngày làm việc kế tiếp**. Ngày hiện tại kết thúc theo cài đặt cũ. Rollover không chạy lại cho ngày đã có lượt xong. Chỉ hiện một banner duy nhất (MSG-23 của G01).
4. **Đổi timezone không đổi ngày dự định.**
   - Task giữ nguyên ngày dự định.
   - Timebox giữ thời điểm tuyệt đối.
   - Nếu timebox rơi vào ngày làm việc khác với ngày dự định, task và timebox hiện cờ **"Lệch ngày"**. Hệ thống không tự sửa; người dùng tự chọn dời task hoặc dời timebox.
5. **Timebox vắt qua mốc đầu ngày.** Timebox thuộc ngày làm việc của thời điểm bắt đầu.

Bảng ví dụ dùng làm ca kiểm thử chuẩn (cả cho bộ đánh giá AI của G10). Mốc 04:00, timezone Asia/Ho_Chi_Minh:

| Thời điểm | Hôm nay | Ngày mai | Ghi chú |
|---|---|---|---|
| 03/11 23:30 | 03/11 | 04/11 | |
| 04/11 02:10 | 03/11 | 04/11 | AI hỏi lại khi người dùng nói "ngày mai" (G10 BR-05): "Thứ Tư 4/11 hay Thứ Năm 5/11?" |
| 04/11 04:00 | 04/11 | 05/11 | Rollover cho ngày 03/11 chạy từ thời điểm này |
| 04/11 02:00, đổi mốc sang 00:00 | 03/11 | 04/11 | Mốc mới có hiệu lực từ ngày làm việc 04/11 |
| Bay sang Paris (UTC+1) lúc 04/11 20:00 giờ VN | 04/11 | 05/11 | Task giữ nguyên ngày; timebox 23:30 giờ VN hiện 17:30 giờ Paris |

## QC-02. Lịch làm việc

1. G01 sở hữu màn **Lịch làm việc**: chọn các ngày làm việc trong tuần và giờ bắt đầu, kết thúc của từng ngày. Mặc định Thứ Hai–Thứ Sáu, 09:00–17:00 `[giả định]`. Cho thêm Thứ Bảy hoặc bất kỳ ngày nào.
2. **Ngày làm việc kế tiếp** của D là ngày đầu tiên sau D có trong lịch làm việc. "Ngày mai" ở shutdown (G08), phím D (G04) và tuỳ chọn "Ngày mai" khi đổi ngày đều dùng khái niệm này.
3. Những nhóm đọc lịch làm việc:
   - G04 dùng để tính sức chứa;
   - G05 dùng để auto-schedule (1.1);
   - G08 không tự mở và không nhắc ritual vào ngày nghỉ;
   - G09 dựng cột ngày trong tuần.
4. **Ngày lễ:** chưa hỗ trợ ở 1.0. Người dùng bỏ qua ritual bằng "Bỏ qua hôm nay".
5. **Khung giờ channel** (G02 sở hữu, cài trong màn cài đặt channel). Mỗi channel có thể đặt khung riêng gồm các ngày trong tuần và giờ bắt đầu, kết thúc từng ngày, kể cả ngày không có trong lịch chung. Mỗi ngày một khoảng, không vắt qua nửa đêm, bước 15 phút (D1). Đổi khung có hiệu lực từ ngày làm việc kế tiếp (D2). Channel "Chưa phân loại" không có khung riêng (D3). Ví dụ `#Công ty` T2–T6 09:00–17:00, `#Cá nhân` T2–CN 19:00–22:00. Channel không đặt khung riêng thì dùng lịch chung.
6. **Lịch làm việc của task** = khung giờ channel của task nếu có, ngược lại là lịch chung. Dùng cho:
   - projection và cờ "Vượt giờ làm" của task (G04);
   - số ngày bị hoãn của task (QC-04);
   - "ngày làm việc kế tiếp" khi dời task (phím D, shutdown "Ngày mai");
   - auto-schedule chỉ xếp task vào khung của channel của task (G05, bản 1.1).
7. **Sức chứa của một ngày** (G04) = thời gian trống trong **hợp** của lịch chung và mọi khung channel có trong ngày đó. Ngày **quá tải** khi tổng planned của task chưa xong > sức chứa. Ngưỡng khối lượng (G04) chỉ là giới hạn riêng của lịch chung, áp cho các task không có khung channel; không lấy min với sức chứa (Q48).
8. Ritual ngày (G08) và cột ngày của G09 theo **lịch chung**.
9. **Phát hành:** lịch chung, khung giờ channel, sức chứa và projection ở 1.0; auto-schedule dùng khung channel ở 1.1.

## QC-03. Trạng thái task và khôi phục

1. **Một bộ trạng thái duy nhất** (G02 sở hữu):

   | Trạng thái | Điều kiện |
   |---|---|
   | `KE_HOACH` | Có ngày dự định, chưa hoàn thành |
   | `BACKLOG` | Không có ngày dự định, có `backlogBucket` |
   | `HOAN_THANH` | Có `completedAt` |
   | `LUU_TRU` | Có `archivedAt` và `archiveReason` ∈ {`stale`, `skipped`} (lưu trữ thủ công `manual` để bản sau, Q34) |
   | `DA_XOA` | Ở Thùng rác, giữ **30 ngày** rồi xoá vĩnh viễn |

   "Đã dời" không phải trạng thái; đó là thuộc tính suy ra từ số ngày bị hoãn (QC-04). Không nhóm nào thêm trạng thái task riêng.
2. **Cụm vị trí** gồm {trạng thái, ngày dự định, `backlogBucket`, `archivedAt`/`archiveReason`, số ngày bị hoãn}. Mọi thao tác ghi cụm này cùng nhau và giữ các bất biến:
   - `KE_HOACH` thì có ngày dự định và không có bucket;
   - `BACKLOG` thì ngược lại.
3. **Khôi phục từ Thùng rác** đưa task về đúng trạng thái trước khi xoá:

   | Trạng thái trước khi xoá | Sau khi khôi phục |
   |---|---|
   | `KE_HOACH`, ngày dự định ≥ hôm nay | Giữ ngày |
   | `KE_HOACH`, ngày dự định < hôm nay | Về hôm nay, số ngày bị hoãn = 0 |
   | `BACKLOG` | Về đúng bucket |
   | `HOAN_THANH` | Giữ ngày dự định và `completedAt` |
   | `LUU_TRU` | Về Lưu trữ với lý do cũ |
   | Instance lặp (bất kỳ trạng thái nào ở trên) | Như trên, rồi áp QC-06 (đường thủ công: cảnh báo) |
4. **Bỏ hoàn thành:**
   - Trong cùng ngày làm việc với lúc hoàn thành: trả lại mọi tác dụng phụ của việc hoàn thành (subtask, thời gian thực tế tự gán, ngày dự định hoặc bucket trước đó). Kết quả giống Hoàn tác trên toast.
   - Sang ngày làm việc khác: chỉ xoá `completedAt`; task ở `KE_HOACH` hôm nay.

## QC-04. Số ngày bị hoãn

1. **Định nghĩa.** Số ngày bị hoãn = số ngày có trong lịch làm việc của task (QC-02 mục 6) tính từ `firstPlannedDate` tới hôm nay. Ngày không có trong lịch làm việc của task không được đếm; rollover vẫn chạy mọi ngày. Số được tính theo lịch **hiện tại** của task, nên đổi lịch, khung giờ hoặc channel có thể làm số thay đổi (D4). `firstPlannedDate` là ngày dự định tại lần đặt có chủ đích gần nhất. Giá trị này thay cho `rolloverCount` trong toàn bộ tài liệu.
2. **Không reset** (`firstPlannedDate` giữ nguyên) khi task bị đẩy sang ngày sau theo kiểu thụ động: rollover, phím D, shutdown chọn "Ngày mai" (kể cả "Áp dụng cho tất cả").
3. **Reset** (`firstPlannedDate` = ngày dự định mới) khi người dùng đặt ngày có chủ đích hoặc task rời luồng ngày: chọn ngày bằng bộ chọn ngày, kéo sang ngày khác, "Hoãn 1 tuần", phím S, đưa vào backlog, hoàn thành, khôi phục từ Lưu trữ hoặc Thùng rác.
4. **Hiển thị.** Card hiện nhãn "Dời {n} ngày" khi n ≥ 1. Bước "Xem lại hôm qua" của Daily planning lấy task có n ≥ 1.
5. **Tự lưu trữ.** Khi n ≥ **4** `[giả định]`, rollover chuyển task sang `LUU_TRU` với lý do `stale`.
6. **Chế độ chỉ đọc (1.1).** Các ngày workspace bị đóng băng không tính vào n (QC-09).

## QC-05. Đổi ngày task

Mọi đường làm thay đổi ngày dự định hoặc đưa task ra khỏi ngày đều theo bảng sau. Nhóm sở hữu đường đó (cột cuối) chỉ tham chiếu bảng, không tự quy định lại.

| Đường | Timebox | Sự kiện trên lịch ngoài | Timer đang chạy | Số ngày bị hoãn | Nhóm |
|---|---|---|---|---|---|
| Phím D | Giữ giờ, dời sang ngày mới | Cập nhật theo | Không dừng | Không reset | G04 |
| Kéo sang ngày khác, chọn ngày | Giữ giờ, dời sang ngày mới | Cập nhật theo | Không dừng | Reset | G04 |
| Shutdown "Ngày mai" | Giữ giờ, dời sang ngày làm việc kế tiếp | Cập nhật theo | Không dừng (bước đầu shutdown có nhắc) | Không reset | G08 |
| Rollover | Timebox quá khứ (`endsAt` ≤ thời điểm rollover): gỡ liên kết. Timebox tương lai: giữ | Quá khứ: **giữ** làm lịch sử | Không dừng | Không reset | G06 |
| Đưa vào backlog | Timebox tương lai: gỡ. Quá khứ: gỡ liên kết | Tương lai: **xoá**. Quá khứ: giữ | Không dừng | Reset | G04, G06 |
| Hoàn thành | Giữ; rút ngắn khi thời điểm hoàn thành nằm trong khoảng giờ của timebox | Cập nhật theo | **Dừng** | Reset | G02 |
| Xoá | Tương lai: gỡ. Quá khứ: gỡ liên kết | Tương lai: xoá. Quá khứ: giữ | **Dừng** | — | G02 |
| Phím S: về hôm nay (F1) | Như "kéo sang ngày khác" | Cập nhật theo | Không dừng | Reset | G04, G06 |
| "Hoãn 1 tuần" (= max(ngày dự định, hôm nay) + 7 ngày, D5); chỉ qua command menu / menu Ngày dự định, không có phím tắt (F1) | Như "kéo sang ngày khác" | Cập nhật theo | Không dừng | Reset | G04, G06 |
| Tự lưu trữ (`stale`), lưu trữ do trùng series (`skipped`, D6) | Như "Đưa vào backlog" | Như "Đưa vào backlog" | Không dừng | — | G06 |
| AI dời ngày | Như "kéo sang ngày khác" | Như trên | Không dừng | Reset | G10 |

- **Ngoại lệ: timebox liên kết sự kiện** (G05 BR-21, B8). Timebox gắn với sự kiện có sẵn trên lịch ngoài không theo các cột Timebox / Sự kiện ngoài ở trên: ở mọi đường (đổi ngày, rollover, đưa vào backlog, xoá) chỉ gỡ liên kết, **không** dời và **không** xoá sự kiện ngoài; timebox đi theo sự kiện gốc (sự kiện đổi giờ thì timebox đổi theo, sự kiện bị xoá hoặc đổi thành cả ngày thì gỡ timebox, task giữ nguyên). Các timebox thường khác của cùng task theo bảng trên.
- **Hoàn tác** của các đường do người dùng (hoặc AI) thực hiện khôi phục cả liên kết timebox; sự kiện ngoài đã bị xoá thì được tạo lại với giờ cũ. **Rollover và tự lưu trữ không có Hoàn tác** (job hệ thống, chỉ ghi nhật ký); người dùng tự kéo task về nếu cần.
- **Chặn ngày quá khứ.** Server từ chối đặt task chưa xong vào ngày < hôm nay, với mọi đường, bằng mã lỗi chung `PAST_DATE` (G02 sở hữu; trả trong `VALIDATION_FAILED`). Không nhóm nào đặt mã riêng. Phím D = ngày làm việc kế tiếp của max(ngày dự định, hôm nay).
- **Hoàn thành task của ngày tương lai:**
  - task thường: ngày dự định chuyển về hôm nay;
  - instance lặp: giữ nguyên ngày dự định.

## QC-06. Instance trùng series trong một ngày

1. Một ngày làm việc **đã có instance** của series S khi có instance của S mà ngày gốc hoặc ngày dự định bằng ngày đó, ở trạng thái `KE_HOACH` hoặc `HOAN_THANH`.
2. **Đường tự động hoặc hàng loạt** đưa một instance của S vào ngày đã có instance của S: instance được đưa vào chuyển sang `LUU_TRU` với lý do `skipped`, kèm toast Hoàn tác (rollover thì không có toast, chỉ ghi nhật ký). Các đường này gồm: rollover, phím D, shutdown "Ngày mai".
3. **Đường thủ công từng task** (kéo thả, chọn ngày, khôi phục): vẫn cho đặt, kèm cảnh báo "Ngày này đã có {tên series}". Thông báo gốc là **G03 MSG-21**; các nhóm khác (G02 MSG-24, G04 MSG-23, G06 MSG-21) giữ mã riêng nhưng dùng đúng nội dung này.

## QC-07. Bản ghi thời gian

1. Bản ghi thời gian có `source` ∈ {`timer`, `manual`, `auto_closed`, `ritual`}. Bản ghi thuộc ngày làm việc của `startedAt`, **không chia** khi vắt qua mốc đầu ngày.
2. **Ritual** (G08) chỉ tạo bản ghi `ritual` khi người dùng không có timer đang chạy, xét **tại thời điểm hoàn tất ritual** (G07 BR-21, G08 BR-12). Có timer đang chạy lúc đó → không tạo bản ghi; task ghi chép vẫn được tạo. Ritual không dừng timer.
3. **Nhập tay:**
   - Nhập theo **thời lượng**: không kiểm tra chồng lấn, không vẽ lên lịch.
   - Nhập theo **khoảng giờ**: kiểm tra chồng lấn, có vẽ lên lịch.
   - Mức tối thiểu 1 phút.
4. **"Tính planned là actual"** là giá trị hiển thị, **không tạo bản ghi**. Lúc hoàn thành, task lưu cờ `plannedAsActual` theo cài đặt tại thời điểm đó. Bật hoặc tắt cài đặt sau này không làm đổi số liệu quá khứ.
5. **Thời gian thực tế** của task = Σ bản ghi của task và subtask, cộng planned nếu `plannedAsActual` và không có bản ghi nào. G09 là nhóm duy nhất cộng số liệu theo ngày hoặc tuần. Bản ghi của task đã xoá không tính.
6. Timer luôn chạy trên **task cha**, không chạy trên subtask.

## QC-08. Đồng bộ nhiều thiết bị và offline

1. **Thứ tự** tính theo thời điểm server nhận được, không theo đồng hồ của thiết bị. Thao tác của job hệ thống (rollover, sinh instance, đồng bộ lịch, tích hợp) cũng tăng phiên bản như thao tác của người dùng.
2. **Cụm vị trí** (QC-03 mục 2) được ghi nguyên khối. Lệnh offline sửa cụm này trên phiên bản cũ bị từ chối (`VERSION_CONFLICT`), và người dùng thấy "Task đã thay đổi trên thiết bị khác".
3. Các trường khác (tiêu đề, ghi chú, priority, planned…) gộp theo từng trường; bản server nhận sau thắng. Trường của người dùng bị ghi đè thì có thông báo.
4. Lệnh sửa vào task đã `DA_XOA` bị từ chối (`TASK_DELETED`). Hai thiết bị offline cùng bật lặp cho một task: lệnh tới sau bị từ chối (`ALREADY_REPEATING`).
5. **Rollover tạm trên máy** chỉ để hiển thị, không bao giờ vào hàng đợi đồng bộ.
6. **Bị đăng xuất từ xa** (`session.revoked`): giữ hàng đợi offline (mã hoá, gắn userId) và gửi lên khi đăng nhập lại đúng tài khoản. Chỉ xoá khi người dùng chủ động đăng xuất, sau khi đã cảnh báo còn thay đổi chưa đồng bộ.

## QC-09. Chế độ chỉ đọc (bản 1.1)

Áp dụng từ bản 1.1, khi có thanh toán ([ADR-0002](adr/0002-thanh-toan-chuyen-sang-1-1.md)). Bản 1.0 không có chế độ chỉ đọc. Nguyên tắc: **đóng băng toàn bộ**.

| Thành phần | Khi workspace chỉ đọc |
|---|---|
| API ghi của người dùng | Trả 402 `WORKSPACE_READ_ONLY`. Vẫn cho: đọc, xuất dữ liệu, thanh toán, cài đặt tài khoản và thông báo, đăng xuất |
| Rollover (G06) | Dừng |
| Sinh instance lặp (G03) | Dừng |
| Đồng bộ lịch (G05) | Chỉ cập nhật cache hiển thị sự kiện ngoài. Không sửa timebox hay task. Không đẩy timebox ra |
| Timer (G07) | Timer đang chạy tự dừng, `endedAt` = thời điểm vào chỉ đọc |
| Ritual (G08) | Không mở phiên mới. Phiên đang làm được hoàn tất, kể cả các thao tác task bên trong, trong 2 giờ |
| AI (G10) | Không gọi AI, kể cả job highlights |
| Tích hợp (G11) | Chỉ cập nhật cache panel. Không hoàn thành hay sửa task từ webhook. Không đẩy trạng thái ra nguồn |
| Thao tác offline | Thao tác tạo trước thời điểm vào chỉ đọc được nhận nếu đồng bộ trong 2 giờ |

**Khi thoát chỉ đọc:** rollover chạy bù **một lần**, không tính các ngày bị đóng băng vào số ngày bị hoãn. Sinh instance lặp chỉ cho ngày ≥ hôm nay.

## QC-10. Quyền theo gói (bản 1.1)

Bản 1.0 miễn phí, không giới hạn, gắn nhãn Beta. Từ 1.1, các nhóm đọc hạn mức từ bảng cấu hình của G12; không nhóm nào viết cứng con số trong logic.

| Quyền | Trial / trả phí | Nhóm dùng |
|---|---|---|
| Số tài khoản lịch kết nối | 5 `[giả định]` | G05 |
| Số tích hợp kết nối | Không giới hạn `[giả định]` | G11 |

Trợ lý AI **không có hạn mức theo gói**: AI chạy bằng Claude Code CLI trên máy người dùng và dùng hạn mức của gói Claude của chính họ (QC-12).

## QC-12. Trợ lý AI qua Claude Code CLI và MCP local

Áp dụng từ bản **1.0** (app Windows). Xem [ADR-0004](adr/0004-ai-qua-claude-code-cli.md).

1. **Bộ não AI là Claude Code CLI trên máy người dùng.** Người dùng tự cài Claude Code và đăng nhập tài khoản Claude của họ. App phát hiện CLI và dùng nó cho mọi tính năng AI: chat (giao diện như chat thường), Planning Agent, soạn highlights, gợi ý task. App không tự gọi LLM nào khác.
2. **Không có Claude Code** (chưa cài, chưa đăng nhập, phiên bản không hỗ trợ): mọi tính năng AI bị ẩn, thay bằng hướng dẫn "Cài Claude Code để bật trợ lý AI". Mọi chức năng lõi vẫn chạy đủ.
3. **MCP server local.** App chạy một MCP server trên máy, chỉ nhận kết nối từ máy đó. Claude Code (do app gọi, hoặc do người dùng tự mở trong terminal) điều khiển app qua các công cụ:
   - đọc: board ngày, backlog, lịch và sự kiện, task, objective;
   - ghi: tạo task, sửa tiêu đề / ghi chú / planned / channel, dời ngày (theo QC-05, dòng "AI dời ngày"), đưa vào backlog, timebox / gỡ timebox, hoàn thành task, xoá task (mục 4);
   - đọc dữ liệu tích hợp (email, Jira, Notion…): chỉ có khi người dùng bật công tắc riêng (mục 6).
4. **Hoàn thành và xoá task** (F4): khi trợ lý bật, AI luôn được hoàn thành và xoá task / subtask, không cần công tắc riêng. Xoá của AI là xoá mềm vào Thùng rác; AI không xoá vĩnh viễn hay dọn Thùng rác. Task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá (D10).
5. **Áp dụng ngay.** Mọi thay đổi qua MCP được áp dụng ngay, gắn chip "AI" trên task, ghi nhật ký, và có Hoàn tác (từng thay đổi và "Hoàn tác kế hoạch AI" cho cả lượt). Planning Agent lỗi giữa chừng thì giữ phần đã áp dụng, vẫn có Hoàn tác cả lượt (D9).
6. **Dữ liệu tích hợp chỉ là dữ liệu.** Công cụ đọc dữ liệu tích hợp mặc định tắt. Khi đã bật, mọi thay đổi **sau lần đầu đọc dữ liệu tích hợp** trong cùng phiên AI đó chuyển thành **chờ duyệt** trong app thay vì áp dụng ngay, để chặn lệnh ẩn trong nội dung bên ngoài (D8).
7. **Đồng ý.** Trợ lý AI mặc định tắt. Lần bật đầu tiên hiện một màn gọn nói rõ dữ liệu nào được đưa cho Claude Code; app lưu thời điểm đồng ý. Tắt trợ lý thì MCP server ngừng nhận kết nối.
8. **Không có hạn mức theo gói** (QC-10). Lỗi hết hạn mức đến từ Claude Code thì app hiện thông báo của Claude Code và chuyển sang luồng thủ công (EC-39).

## QC-11. Danh mục tình huống biên (EC)

Định nghĩa gốc của các mã EC nằm ở SRS tổng (ngoài repo). Bảng dưới liệt kê các mã đang dùng trong bộ PRD/SRS, kèm mô tả suy ra từ ngữ cảnh. Bảng **cần đối chiếu với SRS tổng** trước khi duyệt. Không thấy các mã EC-07 đến EC-10, EC-12, EC-28 và EC-41 được dùng ở đâu.

| Mã | Tình huống | Nhóm chính |
|---|---|---|
| EC-01 | AI hiểu ngày tương đối ("ngày mai") lúc giữa đêm, trước mốc đầu ngày | G10, QC-01 |
| EC-02 | Đổi timezone | QC-01 |
| EC-03 | Chuyển giờ mùa hè / đông | G05, G07 |
| EC-04 | Timebox vắt qua nửa đêm / mốc đầu ngày | G05, QC-01 |
| EC-05 | Nhiều ngày bị lỡ rollover được gộp thành một lần | G06 |
| EC-06 | Không rollover hai lần cho cùng một ngày | G06 |
| EC-11 | Hai timer chạy song song trên hai thiết bị offline | G07 |
| EC-13 | Sự kiện timebox bị xoá ở lịch ngoài | G05 |
| EC-14 | Sự kiện timebox bị dời ở lịch ngoài | G05 |
| EC-15 | Mất kết nối lịch (token lỗi / bị thu hồi) | G05 |
| EC-16 | Timebox chồng với sự kiện bận | G05 |
| EC-17 | Sự kiện free, đã từ chối hoặc cả ngày không chặn thời gian | G05 |
| EC-18 | Hết khe trống trong ngày | G04, G05 |
| EC-19 | Item nguồn không còn hoặc mất quyền xem; task không bị xoá | G11 |
| EC-20 | Kéo một item nhiều lần chỉ tạo một task | G11 |
| EC-21 | Item nguồn chuyển sang trạng thái "xong" | G11 |
| EC-22 | Panel tích hợp hiện dữ liệu lần cuối khi lỗi | G11 |
| EC-23 | Quên tắt timer | G07 |
| EC-24 | Hoàn thành hoặc xoá task đang chạy timer | G07, QC-05 |
| EC-25 | Khoá phím tắt khi gõ nhanh | G01, G04, G07 |
| EC-26 | Mở xem ritual không tạo task | G08 |
| EC-27 | Vắng nhiều ngày chỉ nhắc ritual hôm nay | G08 |
| EC-29 | Đổi quy tắc lặp không đụng instance hôm nay, quá khứ, đã xong | G03 |
| EC-30 | Instance cũ không rollover khi series đã có instance hôm nay | G03, QC-06 |
| EC-31 | Xoá / rời thành viên workspace | G12 |
| EC-32 | Mời trùng email | G12 |
| EC-33 | Đổi Privacy thu hồi quyền xem | G12 |
| EC-34 | Hết hạn gói giữa một thao tác | G12, QC-09 |
| EC-35 | Webhook thanh toán tới trùng | G12 |
| EC-36 | Chủ sở hữu duy nhất xoá tài khoản khi còn thành viên | G01, G12 |
| EC-37 | Thay đổi AI áp dụng ngay, có Hoàn tác cả lượt; chờ duyệt khi phiên có dữ liệu tích hợp (QC-12 mục 5–6) | G10 |
| EC-38 | Hoàn tác AI không xoá phần người dùng đã sửa | G10 |
| EC-39 | AI lỗi thì chuyển sang luồng thủ công | G10 |
| EC-40 | Ngày có rất nhiều task (500) | G04 |
