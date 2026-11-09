> **Mã:** PLN-PRD-G06 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g06-backlog-rollover.md

# PRD Backlog, rollover & lưu trữ trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: Backlog 6 bucket ("Someday in the next week or two / next month / next quarter / next year / Someday / Never"), "Add folder", nhóm theo channel, phím Z chọn bucket bằng 1–5, 0 và toast "[task] moved to next month in Backlog · OPEN TASK · DISMISS", Shift+Z lên đầu backlog không hỏi, menu Ngày bắt đầu ("Snooze one day (D), Snooze one week, Move to backlog (Z), Move to top of backlog (Shift+Z)"), Archive có "Auto-archive", "Tasks which have rolled over at least 4 consecutive days", "Delete all". Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> **Quy tắc dùng chung:** PRD này tham chiếu [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md) (QC-01 ngày làm việc, QC-02 lịch làm việc và khung giờ channel, QC-03 trạng thái task, QC-04 số ngày bị hoãn, QC-05 đổi ngày task, QC-06 instance trùng series, QC-08 đồng bộ, QC-09 chỉ đọc). G06 sở hữu QC-04 và QC-05. Thuật ngữ theo [`CONTEXT.md`](../../CONTEXT.md); "Archive" trên Sunsama tương ứng **Lưu trữ** trong app. Cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md) vòng 7: số ngày bị hoãn theo lịch hiện tại của task (D4); "Hoãn 1 tuần" = max(ngày dự định, hôm nay) + 7 ngày, rơi vào ngày nghỉ thì giữ nguyên (D5); lưu trữ `skipped` xử lý timebox như "Đưa vào backlog" (D6).
>
> Cập nhật theo [câu hỏi chốt 09/11/2026](../review/cau-hoi-chot-flow-2026-11-09.md): B06–B13, C06–C09, A2, A9, A10 (QC-13).

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Không phải việc nào cũng làm hôm nay, và không phải việc nào lên kế hoạch cũng xong đúng ngày. Nhóm G06 lo ba nơi giữ task ngoài cột ngày hiện tại: Backlog (việc chưa lên ngày, xếp theo khoảng thời gian dự định), rollover (việc chưa xong tự chuyển sang hôm nay) và Lưu trữ (việc bị hoãn quá lâu hoặc bị bỏ qua). G06 cũng sở hữu hai quy tắc dùng chung: số ngày bị hoãn (QC-04) và bảng đổi ngày task (QC-05). Mô hình task (G02), quy tắc instance lặp (G03), board và phím D (G04), timebox (G05) và ritual nhắc bucket tới kỳ (G08, G09) dùng chung dữ liệu này.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Việc "để sau" trộn với việc hôm nay | Cột ngày quá tải, khó tập trung vào việc thật sự cần làm |
| Việc hoãn không có mốc quay lại | Bị quên hẳn, hoặc nằm mãi trên danh sách gây ồn |
| Việc chưa xong nằm lại ngày cũ | Mỗi sáng phải kéo tay sang hôm nay, dễ sót việc |
| Việc trễ dồn ngày này qua ngày khác | Danh sách hôm nay phình to, cảm giác thất bại |
| Không phân biệt việc bị bỏ dở với việc lặp đã có bản mới | Hôm nay có hai bản cùng một việc lặp |

## 1.3 Mục tiêu

- Hoãn một task vào backlog bằng 2 phím (Z + số bucket) hoặc 1 tổ hợp (Shift+Z).
- 95% người dùng có task chưa xong của ngày cũ chuyển sang hôm nay trong ≤ 15 phút sau mốc đầu ngày (B6). Lượt lỗi được chạy bù ngay khi người dùng mở app.
- Task bị hoãn ≥ 4 ngày làm việc `[giả định]` (chỉ đếm ngày có trong lịch làm việc của task, Q32) tự rời khỏi hôm nay (khi bật Tự lưu trữ), khôi phục được bằng 1 thao tác từ Lưu trữ.
- Bucket tới kỳ được nhắc lại trong Daily planning (G08) và Weekly planning (G09, bản 1.1).

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân | Gạt việc chưa cần làm ra khỏi hôm nay mà không phải chọn ngày cụ thể |
| Người hay ôm việc (Hà) | Thấy việc nào đang bị dời mãi để quyết định làm, hoãn hay bỏ |
| Người bận họp (Linh) | Sáng mở app thấy sẵn việc dở hôm qua, không phải dọn tay |
| Người dùng thành thạo | Hoãn, đưa lên đầu backlog, khôi phục bằng phím tắt |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: app Windows (Flutter) ở 1.0 (Q45, ADR-0005). Web và macOS từ 1.1, iOS / Android từ 1.2 dùng cùng đặc tả. Job rollover chạy phía server; chi tiết kỹ thuật: tech chốt — `docs/tech/`.
- Panel Backlog (sidebar, phím B): 6 bucket cố định, folder tuỳ chọn, nhóm theo channel, "Thêm task" trên đầu, panel ngày bên phải để kéo task ra.
- Chuyển task vào backlog: Z → chọn bucket (1, 2, 3, 4, 5, 0); Shift+Z lên đầu backlog; mục "Chuyển vào backlog" trong menu Ngày dự định; kéo thả vào panel.
- Lấy task từ backlog ra ngày: kéo vào cột ngày, chọn ngày trong menu Ngày dự định, phím S về hôm nay.
- Rollover tự động task chưa xong về hôm nay (job mỗi 15 phút `[giả định]`), chạy mọi ngày kể cả ngày không có trong lịch làm việc (Q32), có lease và trạng thái thất bại; API "đảm bảo rollover" chạy bù khi người dùng mở app, dùng chung với G08. Rollover không có Hoàn tác (Q41).
- Lưu trữ (panel phải): Tự lưu trữ, task bị hoãn ≥ 4 ngày làm việc `[giả định]`, instance lặp "bị bỏ qua", khôi phục về hôm nay, "Xoá tất cả" có xác nhận. Tự lưu trữ không có Hoàn tác (Q41).
- Hai quy tắc dùng chung: số ngày bị hoãn (QC-04), bảng đổi ngày task (QC-05).

## 3.2 Ngoài phạm vi

- Kéo thả trên board, phím D, hoãn 1 tuần, sắp xếp → G04 (menu Ngày dự định dùng chung).
- Nhắc bucket tới kỳ trong ritual → G08 (Daily planning), G09 (Weekly planning, bản 1.1).
- Quy tắc instance trùng series → G03 định nghĩa (QC-06), G06 thực thi ở đường rollover.
- Thùng rác → G02. Timebox → G05.
- Chế độ chỉ đọc và hành vi rollover khi chỉ đọc → bản 1.1 (QC-09, ADR-0002).
- Tự chuyển task giữa các bucket theo thời gian (ví dụ "Tháng tới" sau 30 ngày thành "Tuần tới") → chưa đưa vào.
- Backlog dùng chung cho nhóm, task được giao → bản sau, 1.2 trở đi (nhiều thành viên, Q35, Q47, `docs/02-tinh-nang-ban-sau.md`). Hướng đã chốt: task được giao vào bucket "Tuần tới" của người nhận, đặt lên đầu (Q36; US1.3 AC03).
- Lưu trữ thủ công (`archiveReason = manual`) → bản sau (Q34, `docs/02`). Ở 1.0, người dùng muốn bỏ một task thì đưa vào backlog (ví dụ bucket "Không bao giờ") hoặc xoá.
- Mức ưu tiên (priority) riêng của Backlog → không có ở 1.0 (chốt 09/11/2026, B13). Task giữ priority của chính nó (G02); thứ tự trong bucket do người dùng kéo thả.
- Chỉnh ngưỡng Tự lưu trữ trên giao diện → không có ở 1.0, ngưỡng cố định (chốt 09/11/2026, B10).

# 4. Nguyên tắc sản phẩm

## 4.1 Hôm nay chỉ chứa việc của hôm nay

Hoãn phải nhanh và không bắt chọn ngày cụ thể: chọn một khoảng ("Tuần tới", "Tháng tới"…) là đủ.

## 4.2 Không việc nào biến mất im lặng

Rollover tự động, Lưu trữ ghi rõ lý do, mọi task bị dọn dẹp đều khôi phục được. Rollover và tự lưu trữ là job hệ thống: không có Hoàn tác, chỉ ghi nhật ký (Q41); người dùng tự kéo task về hoặc khôi phục từ Lưu trữ. Rollover không xoá sự kiện trên lịch ngoài.

## 4.3 Rollover là tín hiệu, không phải hình phạt

Card hiện "Dời {n} ngày" (số ngày bị hoãn, QC-04) để người dùng tự quyết. Đẩy việc sang ngày sau một cách thụ động (rollover, phím D, shutdown "Ngày mai") không xoá số này; chỉ lên lịch lại có chủ đích mới đặt lại. Priority trở về Normal để việc cũ không chiếm chỗ việc mới (trừ mức người dùng chọn giữ).

## 4.4 Hệ thống làm đúng một lần

Rollover idempotent theo người dùng + ngày: chạy lại không chuyển hai lần, nhiều ngày lỡ được gộp thành một lần. Lượt bị kẹt hoặc lỗi không làm người dùng mất việc dở cả ngày: hệ thống chạy bù khi họ mở app.

# 5. Quy tắc backlog, rollover và lưu trữ

| **Cấu hình** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Bucket backlog | 6 cố định: Tuần tới (1), Tháng tới (2), Quý tới (3), Năm tới (4), Một ngày nào đó (5), Không bao giờ (0) `[giả định]` | — | Không đổi tên, không xoá; số trong ngoặc là phím |
| Folder backlog | Tối đa 50 / người dùng, tên 1–50 ký tự `[giả định]` | Không có | Nhóm tuỳ chọn, không thay bucket |
| Mốc ngày mới | Mốc đầu ngày theo QC-01, 00:00–06:00 | 04:00 | Đổi có hiệu lực từ ngày làm việc kế tiếp (Q3) |
| Chu kỳ job rollover | 15 phút `[giả định]` | — | Quét người dùng vừa qua mốc |
| Lease một lượt rollover | 5 phút | — | Quá hạn coi như chưa chạy (B6) |
| Số lần thử trước khi "thất bại" | 3 | — | Sau đó chạy bù khi người dùng mở app (B6) |
| Chờ phiên shutdown | Tối đa 2 giờ sau mốc đầu ngày | — | Rollover chờ phiên shutdown của ngày cũ hoàn tất hoặc bỏ dở (Q18) |
| Vị trí task rollover | Đầu / cuối danh sách hôm nay, luôn sau instance lặp của hôm nay; trong khối: ngày cũ tăng dần, rồi vị trí cũ | Đầu | Cài đặt Chung (G01); thứ tự theo C16 |
| Giữ priority khi rollover | Tập mức được giữ | Tập rỗng (không giữ) | Mức không giữ → về Normal (C16) |
| Tự lưu trữ | Bật / tắt | Bật `[giả định]` | Toggle trong panel Lưu trữ |
| Ngưỡng Tự lưu trữ | Số ngày bị hoãn (QC-04), chỉ đếm ngày có trong lịch làm việc của task (QC-02 mục 6, Q32) | 4 `[giả định]` | Như Sunsama về con số; khác Sunsama ở chỗ không đếm ngày nghỉ của task. Cố định, không chỉnh trên giao diện ở 1.0 (B10) |
| Miễn tự lưu trữ | Task có subtask đã tích hoặc đã có thời gian thực tế không bị lưu trữ `stale` (B11). Instance lặp bị lỡ đã sửa riêng hoặc đã có thời gian thực tế không bị lưu trữ `skipped`, rollover như task thường (B08) | — | Chốt 09/11/2026 |
| Timebox ngày cũ khi rollover | Theo QC-05: timebox quá khứ gỡ liên kết, task về projection; timebox tương lai giữ | — | Sự kiện quá khứ trên lịch ngoài **giữ lại** làm lịch sử (Q6) |
| Timebox khi tự lưu trữ hoặc lưu trữ do trùng series | Theo dòng "Tự lưu trữ (`stale`), lưu trữ do trùng series (`skipped`)" của QC-05: như "Đưa vào backlog" — timebox tương lai gỡ, sự kiện ngoài bị xoá; timebox quá khứ gỡ liên kết, sự kiện giữ | — | Q42 (`stale`), D6 (`skipped`) |
| Hoàn tác rollover / tự lưu trữ | Không có | — | Job hệ thống, chỉ ghi nhật ký (Q41, QC-05) |
| Thời gian giữ trong Lưu trữ | Không giới hạn đến khi xoá `[giả định]` | — | "Xoá tất cả" đưa vào Thùng rác 30 ngày (G02, Q28) |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Số ngày bị hoãn giữ hay reset theo QC-04; timebox, sự kiện ngoài và timer khi đổi ngày theo QC-05.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Hoãn | Nhấn Z trên task, chọn "Tháng tới"; hoặc Shift+Z | Task rời cột ngày, nằm trong bucket; toast có "Hoàn tác", "Mở task" |
| 2 | Chờ | Backlog nhóm theo bucket, folder, channel | Việc để sau có chỗ riêng, không làm ồn hôm nay |
| 3 | Nhắc lại | Ritual hiện bucket tới kỳ (G08, G09) | Người dùng chọn việc đưa vào ngày |
| 4 | Lên ngày | Kéo task từ backlog vào cột ngày (hôm nay hoặc sau) | Task có ngày dự định |
| 5 | Chưa xong | Qua mốc đầu ngày, task tự chuyển sang hôm nay, card hiện "Dời {n} ngày" | Hôm nay đủ việc dở |
| 6 | Dọn dẹp | Bị hoãn ≥ 4 ngày làm việc `[giả định]` → Lưu trữ; mở Lưu trữ để khôi phục hoặc xoá | Hôm nay gọn, không mất dữ liệu |

Bước 3 thuộc G08 / G09, chỉ nêu để thấy vị trí của G06. PRD này tập trung bước 1, 2, 4, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Hoãn task vào backlog

### US1.1 Hoãn theo khoảng thời gian

User Story: Là người dùng, tôi muốn gạt một task sang "Tháng tới" bằng hai phím, để hôm nay chỉ còn việc cần làm mà không phải chọn ngày cụ thể.

AC01: Nhấn Z khi task đang chọn / hover (không focus ô nhập) mở menu 6 bucket; phím 1, 2, 3, 4, 5, 0 chọn ngay.

AC02: Chọn bucket → task rời cột ngày, vào đầu bucket đó; toast "{tiêu đề} đã chuyển vào {bucket} trong Backlog · Hoàn tác · Mở task · Đóng" (kiểm chứng trên Sunsama: "… moved to next month in Backlog · OPEN TASK · DISMISS"; nút Hoàn tác thêm theo chốt 09/11/2026, B06).

AC03: Task có timebox → xử lý theo dòng "Đưa vào backlog" của QC-05: timebox tương lai bị gỡ và sự kiện trên lịch ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ lại. Timer đang chạy không dừng. Số ngày bị hoãn về 0 (QC-04).

AC04: Menu Ngày dự định có "Chuyển vào backlog (Z)" và "Lên đầu backlog (Shift+Z)" cạnh "Hoãn 1 ngày (D)", "Hoãn 1 tuần" (G04).

AC05: Hoàn tác trả task về ngày, vị trí cũ, khôi phục liên kết timebox; sự kiện ngoài đã bị xoá được tạo lại với giờ cũ (QC-05).

AC06: Đang offline mà task đã bị đổi ở nơi khác (ví dụ server đã rollover) → lệnh bị từ chối, người dùng thấy "Task đã thay đổi trên thiết bị khác" (QC-08).

AC07: Kéo task từ board vào trang hoặc panel Backlog cho cùng toast có Hoàn tác như phím Z (QC-13 mục 2, chốt 09/11/2026, A2).

### US1.2 Đưa lên đầu backlog

AC01: Shift+Z chuyển task lên đầu bucket "Tuần tới" không hỏi `[giả định]` (Sunsama: "top of backlog"); toast có Hoàn tác.

### US1.3 Ghi task thẳng vào backlog

AC01: "Thêm task" trên đầu panel Backlog tạo task không có ngày, ở bucket đang xem (mặc định "Tuần tới") và folder đang mở.

AC02: Xoá ngày trong ô soạn trên cột ngày cũng tạo task vào backlog (G02).

AC03 (bản sau, Q35, Q36 — `docs/02-tinh-nang-ban-sau.md`): task người khác giao cho người dùng vào bucket "Tuần tới" (`next_week`; quyết định Q36 gọi là "Tuần sau") của người nhận, đặt lên đầu bucket. Không có ở 1.0.

## UC2. Xem và tổ chức backlog

### US2.1 Mở backlog

AC01: Phím B hoặc mục Backlog ở sidebar mở trang Backlog: các bucket theo thứ tự, mỗi bucket có số task và tổng thời lượng.

AC02: Nút nhóm theo channel (#) chia task trong bucket theo channel; nút biểu đồ hiện phân bổ thời lượng theo bucket / channel `[giả định]`.

AC03: Panel ngày bên phải hiện cột hôm nay (đổi ngày được) để kéo task ra.

AC04: Shift+B mở panel Backlog gọn ở panel phải: cùng các bucket với trang Backlog, không có phần lọc, nhóm theo channel, biểu đồ và quản lý folder; dùng để kéo task ra board (chốt 09/11/2026, C09).

AC05: Tải Backlog lỗi → vẫn hiện dữ liệu trên máy, kèm "Chưa tải được. Thử lại" tại chỗ (QC-MSG-02, C07).

### US2.2 Folder

AC01: "Thêm folder" tạo folder tên 1–50 ký tự; kéo task vào folder; task trong folder vẫn thuộc bucket của nó.

AC02: Đổi tên, xoá folder; xoá folder không xoá task, task ở lại bucket.

### US2.3 Đưa task ra ngày

AC01: Kéo task từ backlog vào cột ngày D → ngày dự định = D, task rời backlog, số ngày bị hoãn bắt đầu từ 0 (QC-04); toast có Hoàn tác như phím S (QC-13 mục 2, A2). Hoàn tác đưa task về đúng bucket, folder và vị trí cũ (QC-13 mục 5, A10).

AC02: Bàn phím: S đưa về hôm nay; menu Ngày dự định chọn ngày bất kỳ từ hôm nay trở đi.

AC03: Không đặt được vào ngày đã qua; server cũng từ chối (QC-05, C15).

AC04: Instance lặp đưa vào ngày đã có instance cùng series → vẫn đặt, kèm cảnh báo "Ngày này đã có {tên series}" (QC-06).

## UC3. Rollover tự động

### US3.1 Việc dở tự sang hôm nay

User Story: Là người dùng, tôi muốn sáng mở app đã thấy việc chưa xong hôm qua nằm ở hôm nay, để không phải kéo tay và không sót việc.

AC01: Qua mốc đầu ngày (QC-01), mọi task chưa xong có ngày dự định trước hôm nay chuyển sang hôm nay; 95% người dùng xong trong ≤ 15 phút (B6). Khối task được chuyển nằm ở đầu (hoặc cuối, theo cài đặt) danh sách hôm nay, sau các instance lặp của hôm nay, xếp theo ngày dự định cũ tăng dần rồi vị trí cũ (C16).

AC02: Card hiện nhãn "Dời {n} ngày", n là số ngày bị hoãn (QC-04); tooltip "Dời {n} ngày · dự định từ {ngày}".

AC03: Priority về Normal trừ các mức nằm trong tập được chọn giữ (C16). Timebox quá khứ bị gỡ liên kết, sự kiện trên lịch ngoài giữ lại làm lịch sử; task về projection; timebox tương lai giữ nguyên; timer không dừng (QC-05).

AC04: Thời gian thực tế, subtask, notes giữ nguyên.

AC05: Người dùng đang làm Daily shutdown của ngày cũ lúc qua mốc → rollover chờ tới khi phiên hoàn tất, bỏ dở, hoặc tối đa 2 giờ sau mốc (Q18).

AC06: Lượt rollover kẹt quá 5 phút được chạy lại; lỗi 3 lần thì chuyển "thất bại" và được chạy bù ngay khi người dùng mở app. Trong lúc chờ, board vẫn hiện việc dở ở hôm nay (chỉ trên máy) `[giả định]`.

AC07: Rollover chạy mọi ngày, kể cả ngày không có trong lịch làm việc; số ngày bị hoãn chỉ đếm ngày có trong lịch làm việc của task (khung giờ channel nếu có, ngược lại lịch chung — QC-02 mục 6, QC-04 mục 1, Q32). Ví dụ (lịch chung Thứ Hai–Thứ Sáu; `#Cá nhân` có khung Thứ Hai–Chủ Nhật): task `#Công ty` dự định Thứ Sáu 06/11, chưa xong → Thứ Bảy, Chủ Nhật vẫn được rollover nhưng n = 0; Thứ Hai 09/11 n = 1; tự lưu trữ (ngưỡng 4) vào Thứ Năm 12/11, không phải Thứ Ba 10/11. Task `#Cá nhân` cùng ngày dự định: Thứ Hai 09/11 n = 3; tự lưu trữ vào Thứ Ba 10/11.

AC08: Rollover không có Hoàn tác và không có toast (Q41); thay đổi ghi nhật ký. Người dùng muốn trả task về ngày khác thì kéo hoặc chọn ngày (G04).

AC09: n tính theo lịch **hiện tại** của task (D4): người dùng đổi khung giờ channel, đổi lịch chung hoặc đổi channel của task thì n được tính lại trên toàn bộ khoảng từ ngày dự định đầu tiên, có thể tăng hoặc giảm ngay. Ví dụ task `#Công ty` ở AC07 đang n = 1 vào Thứ Hai 09/11, chuyển sang `#Cá nhân` → n = 3 ngay.

### US3.2 Nhiều ngày bị lỡ

AC01: Job không chạy được nhiều ngày (sự cố) hoặc task có ngày cũ hơn hôm qua → chuyển một lần về hôm nay, nhật ký một dòng (EC-05); nhãn "Dời {n} ngày" vẫn đúng số ngày có trong lịch làm việc của task kể từ ngày dự định đầu tiên (QC-04 mục 1).

AC02: Đổi timezone hoặc mốc đầu ngày → có hiệu lực từ ngày làm việc kế tiếp; không chạy lại rollover cho ngày đã có lượt xong (Q3, EC-06).

### US3.3 Instance lặp

AC01: Instance lặp cũ chưa xong, series đã có instance hôm nay → không chuyển, vào Lưu trữ với lý do "bị bỏ qua" (`skipped`, EC-30, QC-06); không có toast, chỉ ghi nhật ký.

AC02: Instance lưu trữ `skipped` xử lý timebox như "Đưa vào backlog": timebox tương lai bị gỡ và sự kiện trên lịch ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ lại; timer không dừng (D6, dòng "lưu trữ do trùng series" của QC-05). Áp cho mọi đường lưu trữ `skipped` (rollover, phím D, shutdown "Ngày mai").

AC03: Instance cũ chưa xong nhưng đã sửa riêng hoặc đã có thời gian thực tế → không vào Lưu trữ "bị bỏ qua"; rollover về hôm nay như task thường, kể cả khi hôm nay đã có instance của series (chốt 09/11/2026, B08).

### US3.4 Chế độ chỉ đọc (bản 1.1)

AC01: Workspace chỉ đọc → rollover dừng. Khi thoát chỉ đọc, rollover chạy bù một lần và không tính các ngày bị đóng băng vào số ngày bị hoãn (QC-09).

## UC4. Lưu trữ và khôi phục

### US4.1 Tự lưu trữ việc bị dời mãi

AC01: Bật Tự lưu trữ, task có số ngày bị hoãn ≥ 4 `[giả định]` (ngưỡng cố định, không chỉnh trên giao diện ở 1.0, B10) → vào Lưu trữ (lý do `stale`) ngay trong lượt rollover, không còn trên hôm nay. Timebox xử lý như "Đưa vào backlog": timebox tương lai bị gỡ và sự kiện trên lịch ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ lại; timer không dừng (dòng "Tự lưu trữ" của QC-05, Q42).

AC02: Có toast nêu số task vừa lưu trữ, link "Xem Lưu trữ": lượt rollover chạy ngay lúc mở app thì toast hiện ngay khi lượt chạy xong; lượt do job chạy trước đó thì toast hiện lần mở app kế tiếp (chốt 09/11/2026, B07). Toast viết "ngày làm việc" như nhãn trong Lưu trữ (C06). Toast không có Hoàn tác (Q41).

AC03: Tắt Tự lưu trữ → task tiếp tục chuyển ngày, nhãn "Dời {n} ngày" tăng dần, không bị lưu trữ.

AC04: Tự lưu trữ không có Hoàn tác (Q41). Người dùng khôi phục task từ Lưu trữ (US4.2); timebox tương lai đã gỡ và sự kiện ngoài đã xoá không được tạo lại.

AC05: Task có hoạt động (ít nhất một subtask đã tích, hoặc đã có thời gian thực tế) không bị tự lưu trữ dù số ngày bị hoãn ≥ ngưỡng; task ở lại hôm nay với nhãn "Dời {n} ngày" (chốt 09/11/2026, B11).

### US4.2 Xem Lưu trữ và khôi phục

AC01: Panel phải → Lưu trữ liệt kê task lưu trữ, mới nhất trước, mỗi dòng có lý do theo SRS G06 MSG-12 / MSG-13: "Bị hoãn từ 4 ngày làm việc trở lên" (`stale`) hoặc "Đã bỏ qua" (`skipped`; instance bị bỏ qua luôn hiện trong Lưu trữ, chốt 09/11/2026, B09). Lưu trữ thủ công (`manual`, nhãn "Bạn đã lưu trữ") bỏ ở 1.0 (Q34, bản sau).

AC02: "Khôi phục" có hai lựa chọn (chốt 09/11/2026, B12): "Khôi phục vào hôm nay" → task về đầu hôm nay; "Khôi phục vào Backlog" → task vào đầu bucket "Tuần tới" `[giả định]`. Số ngày bị hoãn về 0; toast có Hoàn tác. Kéo task vào ngày cụ thể chỉ cho ngày từ hôm nay trở đi, cũng có toast Hoàn tác (A2). Hoàn tác đưa task về lại Lưu trữ với lý do cũ (QC-13 mục 5, A10).

AC03: Khôi phục instance lặp vào ngày đã có instance cùng series → vẫn khôi phục, kèm cảnh báo "Ngày này đã có {tên series}" (QC-06).

AC04: Task trong Lưu trữ có trong kết quả tìm kiếm (G04), gắn nhãn "Lưu trữ" (C17). Bấm mở chi tiết task ở chế độ chỉ xem (SRS G06 SCR-08, chốt 09/11/2026, C08), có nút "Khôi phục".

### US4.3 Xoá tất cả

AC01: "Xoá tất cả" mở hộp xác nhận nêu số task; xác nhận → mọi task trong Lưu trữ vào Thùng rác 30 ngày (G02, Q28).

AC02: Toast có Hoàn tác; Hoàn tác đưa mọi task về lại Lưu trữ với lý do cũ (QC-13 mục 5, A10).

AC03: Khôi phục một task như vậy từ Thùng rác đưa task về lại Lưu trữ với lý do cũ, không về hôm nay (QC-03).

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ dùng backlog | Người dùng hoãn ≥ 1 task / tuần / người dùng hoạt động tuần | ≥ 50% |
| Tỉ lệ task backlog được lên ngày | Task rời backlog vào ngày / task vào backlog, trong 30 ngày | ≥ 30% |
| Độ trễ rollover | Từ mốc đầu ngày đến lúc lượt `XONG` (p95; không tính lượt chờ shutdown) | ≤ 15 phút (B6) |
| Tỉ lệ task rollover | Task chuyển ngày / task có ngày dự định hôm qua | Theo dõi (cao = plan quá tải) |
| Tỉ lệ khôi phục từ Lưu trữ | Task khôi phục / task vào Lưu trữ | Theo dõi (cao = ngưỡng 4 ngày quá gắt) |
| Lỗi job rollover | Lượt lỗi / tổng lượt | ≤ 0,1% |
| Lượt thất bại | Lượt `THAT_BAI` / tổng lượt; lượt được chạy bù qua API đảm bảo rollover | Theo dõi, kỳ vọng ≈ 0 |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Mốc đầu ngày | Đã chốt 04:00, chỉnh 00:00–06:00 (Q2) | Một hàm `workday(t)` dùng chung (QC-01) |
| Người dùng nghỉ phép | Vắng ≥ 4 ngày làm việc, quay lại thấy nhiều task đã vào Lưu trữ. Cuối tuần không có trong lịch của task không bị đếm (Q32), nhưng ngày nghỉ phép / ngày lễ trong tuần vẫn bị đếm (ngày lễ chưa hỗ trợ ở 1.0, QC-02 mục 4) | Toast số task lưu trữ khi mở lại; Daily planning (G08) bước 1 nhắc Lưu trữ `[giả định]` |
| Job rollover | Chạy trùng, worker chết, hoặc lỗi giữa chừng | Khoá theo người dùng + ngày; lease 5 phút; mỗi người dùng một giao dịch; 3 lần lỗi → thất bại, chạy bù khi mở app (B6) |
| Rollover khi đang mở board | Task nhảy cột khi người dùng đang thao tác | Cập nhật qua realtime; không đóng chi tiết task đang mở |
| Timebox (G05) | Gỡ liên kết timebox quá khứ phải đồng bộ với G05 | Gọi G05 bất đồng bộ; không xoá sự kiện ngoài; lỗi lịch không chặn rollover |
| Instance lặp (G03) | Hai nhóm cùng xử lý instance cũ | G03 định nghĩa (QC-06); G06 thực thi ở đường rollover |
| Ritual vắt qua mốc (G08) | Rollover chạy giữa lúc người dùng đang shutdown ngày cũ | Rollover chờ phiên shutdown tối đa 2 giờ (Q18) |
| Đồng bộ offline | Người dùng offline đưa task vào backlog trong lúc server rollover task đó | Cụm vị trí ghi nguyên khối; lệnh trên phiên bản cũ bị từ chối (QC-08) |
| Chế độ chỉ đọc (1.1) | Rollover tiếp tục lưu trữ task khi người dùng không thao tác được | Rollover dừng khi chỉ đọc, chạy bù một lần khi thoát (QC-09) |

# 10. Câu hỏi mở

- Đã chốt 04/11/2026: mốc đầu ngày mặc định 04:00, chỉnh trong 00:00–06:00; đổi có hiệu lực từ ngày làm việc kế tiếp (Q2, Q3).
- Tự lưu trữ mặc định bật hay tắt (Sunsama chưa kiểm chứng mặc định)?
- Đã chốt 04/11/2026: số ngày bị hoãn = số ngày làm việc từ ngày dự định đầu tiên tới hôm nay, không phụ thuộc người dùng có mở app hay không (Q5, QC-04).
- Shift+Z đưa lên đầu bucket nào: "Tuần tới" hay bucket hiện tại của task?
- Đã chốt 04/11/2026: rollover giữ sự kiện quá khứ trên lịch ngoài làm lịch sử, chỉ gỡ liên kết trong app (Q6, Q14). Rollover và tự lưu trữ không có Hoàn tác; Hoàn tác khôi phục liên kết timebox chỉ áp cho đường do người dùng / AI làm (Q41, QC-05).
- Có tự chuyển task giữa các bucket khi tới kỳ không?
- Đã chốt 04/11/2026: task Lưu trữ có trong kết quả tìm kiếm, gắn nhãn (C17).
- Đã chốt 04/11/2026: số ngày bị hoãn chỉ đếm ngày có trong lịch làm việc của task (khung giờ channel nếu có, ngược lại lịch chung); rollover vẫn chạy mọi ngày. Task `#Công ty` lên Thứ Sáu bị tự lưu trữ vào Thứ Năm tuần sau, không phải Thứ Ba (Q32, QC-04 mục 1; US3.1 AC07).
- Đã chốt 04/11/2026: bỏ lưu trữ thủ công (`manual`) khỏi 1.0; người dùng đưa vào backlog hoặc xoá; để bản sau (Q34, `docs/02`).
- Đã chốt 04/11/2026: tự lưu trữ (`stale`) xử lý timebox như "Đưa vào backlog" — đã thêm dòng "Tự lưu trữ" vào QC-05 (Q42).
- Đã chốt 04/11/2026: "Hoãn 1 tuần" và phím S đặt lại số ngày bị hoãn (Q40, QC-04 mục 3, QC-05).
- Đã chốt 04/11/2026: số ngày bị hoãn tính theo lịch hiện tại của task; đổi khung giờ channel, đổi lịch chung hoặc đổi channel của task thì n được tính lại (có thể tăng hoặc giảm ngay) (D4, QC-04 mục 1).
- Đã chốt 04/11/2026: "Hoãn 1 tuần" = max(ngày dự định, hôm nay) + 7 ngày; rơi vào ngày nghỉ thì giữ nguyên ngày đó (D5, QC-05; G04 sở hữu lệnh).
- Đã chốt 04/11/2026: instance lưu trữ `skipped` (trùng series) xử lý timebox như "Đưa vào backlog" (D6, QC-05).
- **Chốt 09/11/2026 (B08):** instance lặp bị lỡ đã sửa riêng hoặc đã có thời gian thực tế được miễn lưu trữ "bị bỏ qua", rollover như task thường (US3.3 AC03).
- **Chốt 09/11/2026 (B09):** instance bị bỏ qua hiện trong Lưu trữ, nhãn "Đã bỏ qua" (US4.2 AC01).
- **Chốt 09/11/2026 (B10):** ngưỡng Tự lưu trữ cố định, không chỉnh trên giao diện ở 1.0. Con số 4 vẫn là `[giả định]`.
- **Chốt 09/11/2026 (B11):** subtask đã tích hoặc thời gian thực tế tính là "có hoạt động", task không bị tự lưu trữ (US4.1 AC05).
- **Chốt 09/11/2026 (B12):** khôi phục từ Lưu trữ có hai lựa chọn "Khôi phục vào hôm nay" và "Khôi phục vào Backlog" (US4.2 AC02). Còn mở: bucket đích khi khôi phục vào Backlog (bản này giả định "Tuần tới", đầu bucket).
- **Chốt 09/11/2026 (B13):** Backlog không có mức ưu tiên riêng ở 1.0.
