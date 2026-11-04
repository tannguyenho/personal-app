> **Mã:** PLN-PRD-G06 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g06-backlog-rollover.md

# PRD Backlog, rollover & lưu trữ trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: Backlog 6 bucket ("Someday in the next week or two / next month / next quarter / next year / Someday / Never"), "Add folder", nhóm theo channel, phím Z chọn bucket bằng 1–5, 0 và toast "[task] moved to next month in Backlog · OPEN TASK · DISMISS", Shift+Z lên đầu backlog không hỏi, menu Ngày bắt đầu ("Snooze one day (D), Snooze one week, Move to backlog (Z), Move to top of backlog (Shift+Z)"), Archive có "Auto-archive", "Tasks which have rolled over at least 4 consecutive days", "Delete all". Chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Không phải việc nào cũng làm hôm nay, và không phải việc nào lên kế hoạch cũng xong đúng ngày. Nhóm G06 lo ba nơi giữ task ngoài cột ngày hiện tại: Backlog (việc chưa lên ngày, xếp theo khoảng thời gian dự định), rollover (việc chưa xong tự chuyển sang hôm nay) và Archive (việc đã chuyển ngày quá lâu hoặc bị bỏ qua). Mô hình task (G02), quy tắc instance lặp (G03), board và snooze (G04), timebox (G05) và ritual nhắc bucket tới kỳ (G08, G09) dùng chung dữ liệu này.

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
- 100% task chưa xong của ngày cũ có mặt ở hôm nay trong ≤ 15 phút sau `day_start_time`.
- Task chuyển ngày ≥ 4 ngày liên tiếp tự rời khỏi hôm nay (khi bật Auto-archive), khôi phục được bằng 1 thao tác.
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

- Nền tảng: Web (desktop, mobile web). App iOS / Android và desktop dùng cùng đặc tả từ bản 1.1.
- Panel Backlog (sidebar, phím B): 6 bucket cố định, folder tuỳ chọn, nhóm theo channel, "Thêm task" trên đầu, panel ngày bên phải để kéo task ra.
- Chuyển task vào backlog: Z → chọn bucket (1, 2, 3, 4, 5, 0); Shift+Z lên đầu backlog; mục "Chuyển vào backlog" trong menu Ngày bắt đầu; kéo thả vào panel.
- Lấy task từ backlog ra ngày: kéo vào cột ngày, chọn ngày trong menu Ngày bắt đầu, phím S về hôm nay.
- Rollover tự động task chưa xong về hôm nay (job mỗi 15 phút).
- Archive (panel phải): Auto-archive, task chuyển ngày ≥ 4 ngày liên tiếp, instance lặp "bị bỏ qua", khôi phục về hôm nay, "Xoá tất cả" có xác nhận.

## 3.2 Ngoài phạm vi

- Kéo thả trên board, Snooze 1 ngày / 1 tuần, sắp xếp → G04 (menu Ngày bắt đầu dùng chung).
- Nhắc bucket tới kỳ trong ritual → G08 (Daily planning), G09 (Weekly planning, bản 1.1).
- Quy tắc instance lặp bị bỏ qua → G03 định nghĩa, G06 thực thi.
- Thùng rác → G02. Timebox → G05.
- Tự chuyển task giữa các bucket theo thời gian (ví dụ "Tháng tới" sau 30 ngày thành "Tuần tới") → chưa đưa vào.
- Backlog dùng chung cho nhóm, task được giao vào backlog người nhận → G12 (bản 1.1).

# 4. Nguyên tắc sản phẩm

## 4.1 Hôm nay chỉ chứa việc của hôm nay

Hoãn phải nhanh và không bắt chọn ngày cụ thể: chọn một khoảng ("Tuần tới", "Tháng tới"…) là đủ.

## 4.2 Không việc nào biến mất im lặng

Rollover tự động, Archive ghi rõ lý do, mọi thao tác dọn dẹp đều khôi phục được.

## 4.3 Rollover là tín hiệu, không phải hình phạt

Card hiện số ngày đã chuyển để người dùng tự quyết. Priority trở về Normal để việc cũ không chiếm chỗ việc mới (trừ mức người dùng chọn giữ).

## 4.4 Hệ thống làm đúng một lần

Rollover idempotent theo người dùng + ngày: chạy lại không chuyển hai lần, nhiều ngày lỡ được gộp thành một lần.

# 5. Quy tắc backlog, rollover và lưu trữ

| **Cấu hình** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Bucket backlog | 6 cố định: Tuần tới (1), Tháng tới (2), Quý tới (3), Năm tới (4), Một ngày nào đó (5), Không bao giờ (0) | — | Không đổi tên, không xoá; số trong ngoặc là phím |
| Folder backlog | Tối đa 50 / người dùng, tên 1–50 ký tự | Không có | Nhóm tuỳ chọn, không thay bucket |
| Mốc ngày mới | `day_start_time` theo timezone người dùng | 04:00 `[giả định — chờ PO chốt 04:00 hay 00:00]` | Dùng chung G04, G08, G10 |
| Chu kỳ job rollover | 15 phút | — | Quét người dùng vừa qua mốc |
| Vị trí task rollover | Đầu / cuối danh sách hôm nay | Đầu | Cài đặt Chung (G01) |
| Giữ priority khi rollover | Không giữ / giữ các mức được chọn | Không giữ | Không giữ → về Normal |
| Auto-archive | Bật / tắt | Bật `[giả định]` | Toggle trong panel Archive |
| Ngưỡng Auto-archive | 4 ngày rollover liên tiếp | 4 | Như Sunsama |
| Timebox ngày cũ khi rollover | Gỡ khỏi task, task về projection | — | Sự kiện quá khứ trên lịch ngoài xử lý theo G05 |
| Thời gian giữ trong Archive | Không giới hạn đến khi xoá | — | "Xoá tất cả" đưa vào Thùng rác 30 ngày (G02) |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Chuyển vào backlog, đổi ngày bằng tay, hoàn thành → bộ đếm rollover về 0.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Hoãn | Nhấn Z trên task, chọn "Tháng tới"; hoặc Shift+Z | Task rời cột ngày, nằm trong bucket; toast có "Mở task" |
| 2 | Chờ | Backlog nhóm theo bucket, folder, channel | Việc để sau có chỗ riêng, không làm ồn hôm nay |
| 3 | Nhắc lại | Ritual hiện bucket tới kỳ (G08, G09) | Người dùng chọn việc đưa vào ngày |
| 4 | Lên ngày | Kéo task từ backlog vào cột ngày | Task có ngày bắt đầu |
| 5 | Chưa xong | Qua `day_start_time`, task tự chuyển sang hôm nay, card hiện số ngày đã chuyển | Hôm nay đủ việc dở |
| 6 | Dọn dẹp | Chuyển ≥ 4 ngày liên tiếp → Archive; mở Archive để khôi phục hoặc xoá | Hôm nay gọn, không mất dữ liệu |

Bước 3 thuộc G08 / G09, chỉ nêu để thấy vị trí của G06. PRD này tập trung bước 1, 2, 4, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Hoãn task vào backlog

### US1.1 Hoãn theo khoảng thời gian

User Story: Là người dùng, tôi muốn gạt một task sang "Tháng tới" bằng hai phím, để hôm nay chỉ còn việc cần làm mà không phải chọn ngày cụ thể.

AC01: Nhấn Z khi task đang chọn / hover (không focus ô nhập) mở menu 6 bucket; phím 1, 2, 3, 4, 5, 0 chọn ngay.

AC02: Chọn bucket → task rời cột ngày, vào đầu bucket đó; toast "{tiêu đề} đã chuyển vào {bucket} trong Backlog · Mở task · Đóng" (kiểm chứng trên Sunsama: "… moved to next month in Backlog · OPEN TASK · DISMISS").

AC03: Task có timebox → timebox bị gỡ (G05 xoá sự kiện trên lịch ngoài); bộ đếm rollover về 0.

AC04: Menu Ngày bắt đầu có "Chuyển vào backlog (Z)" và "Lên đầu backlog (Shift+Z)" cạnh "Hoãn 1 ngày (D)", "Hoãn 1 tuần" (G04).

### US1.2 Đưa lên đầu backlog

AC01: Shift+Z chuyển task lên đầu bucket "Tuần tới" không hỏi `[giả định]` (Sunsama: "top of backlog"); toast có Hoàn tác.

### US1.3 Ghi task thẳng vào backlog

AC01: "Thêm task" trên đầu panel Backlog tạo task không có ngày, ở bucket đang xem (mặc định "Tuần tới") và folder đang mở.

AC02: Xoá ngày trong ô soạn trên cột ngày cũng tạo task vào backlog (G02).

## UC2. Xem và tổ chức backlog

### US2.1 Mở backlog

AC01: Phím B hoặc mục Backlog ở sidebar mở trang Backlog: các bucket theo thứ tự, mỗi bucket có số task và tổng thời lượng.

AC02: Nút nhóm theo channel (#) chia task trong bucket theo channel; nút biểu đồ hiện phân bổ thời lượng theo bucket / channel `[giả định]`.

AC03: Panel ngày bên phải hiện cột hôm nay (đổi ngày được) để kéo task ra.

### US2.2 Folder

AC01: "Thêm folder" tạo folder tên 1–50 ký tự; kéo task vào folder; task trong folder vẫn thuộc bucket của nó.

AC02: Đổi tên, xoá folder; xoá folder không xoá task, task ở lại bucket.

### US2.3 Đưa task ra ngày

AC01: Kéo task từ backlog vào cột ngày D → ngày bắt đầu = D, task rời backlog.

AC02: Bàn phím: S đưa về hôm nay; menu Ngày bắt đầu chọn ngày bất kỳ.

## UC3. Rollover tự động

### US3.1 Việc dở tự sang hôm nay

User Story: Là người dùng, tôi muốn sáng mở app đã thấy việc chưa xong hôm qua nằm ở hôm nay, để không phải kéo tay và không sót việc.

AC01: Qua `day_start_time`, mọi task chưa xong có ngày bắt đầu trước hôm nay chuyển sang hôm nay trong ≤ 15 phút, ở đầu danh sách (theo cài đặt).

AC02: Card hiện dấu chuyển ngày kèm số ngày liên tiếp; tooltip "Chuyển từ {ngày} · {n} ngày liên tiếp".

AC03: Priority về Normal trừ mức được chọn giữ; timebox ngày cũ bị gỡ, task về projection.

AC04: Thời gian thực tế, subtask, notes giữ nguyên.

### US3.2 Nhiều ngày bị lỡ

AC01: Job không chạy được nhiều ngày (sự cố) hoặc task có ngày cũ hơn hôm qua → chuyển một lần về hôm nay, bộ đếm +1, nhật ký một dòng (EC-05).

AC02: Đổi timezone hoặc `day_start_time` làm mốc dịch chuyển → không chuyển hai lần trong cùng một ngày (EC-06).

### US3.3 Instance lặp

AC01: Instance lặp cũ chưa xong, series đã có instance hôm nay → không chuyển, vào Archive nhãn "bị bỏ qua" (EC-30, quy tắc G03).

## UC4. Lưu trữ và khôi phục

### US4.1 Tự lưu trữ việc bị dời mãi

AC01: Bật Auto-archive, task chuyển ≥ 4 ngày liên tiếp → vào Archive ngay trong lượt rollover, không còn trên hôm nay.

AC02: Lần mở app đầu tiên sau đó có toast nêu số task vừa lưu trữ, link "Xem Archive" `[giả định]`.

AC03: Tắt Auto-archive → task tiếp tục chuyển ngày, không bị lưu trữ.

### US4.2 Xem Archive và khôi phục

AC01: Panel phải → Archive liệt kê task lưu trữ, mới nhất trước, mỗi dòng có lý do: "Chuyển ngày ≥ 4 ngày" hoặc "Bị bỏ qua".

AC02: "Khôi phục" → task về đầu hôm nay, bộ đếm về 0; toast có Hoàn tác.

### US4.3 Xoá tất cả

AC01: "Xoá tất cả" mở hộp xác nhận nêu số task; xác nhận → mọi task trong Archive vào Thùng rác 30 ngày (G02).

AC02: Toast có Hoàn tác.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ dùng backlog | Người dùng hoãn ≥ 1 task / tuần / người dùng hoạt động tuần | ≥ 50% |
| Tỉ lệ task backlog được lên ngày | Task rời backlog vào ngày / task vào backlog, trong 30 ngày | ≥ 30% |
| Độ trễ rollover | Từ `day_start_time` đến lúc task chuyển xong (p95) | ≤ 15 phút |
| Tỉ lệ task rollover | Task chuyển ngày / task có ngày bắt đầu hôm qua | Theo dõi (cao = plan quá tải) |
| Tỉ lệ khôi phục từ Archive | Task khôi phục / task vào Archive | Theo dõi (cao = ngưỡng 4 ngày quá gắt) |
| Lỗi job rollover | Lượt lỗi / tổng lượt | ≤ 0,1% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| `day_start_time` chưa chốt | 04:00 hay 00:00 thay đổi thời điểm rollover | Là cấu hình; một nơi tính "hôm nay" dùng chung |
| Người dùng nghỉ phép | Vắng ≥ 4 ngày, quay lại thấy nhiều task đã vào Archive | Toast số task lưu trữ khi mở lại; Daily planning (G08) bước 1 nhắc Archive `[giả định]` |
| Job rollover | Chạy trùng hoặc lỗi giữa chừng | Khoá theo người dùng + ngày; mỗi người dùng một giao dịch; lượt sau xử lý lại |
| Rollover khi đang mở board | Task nhảy cột khi người dùng đang thao tác | Cập nhật qua realtime; không đóng chi tiết task đang mở |
| Timebox (G05) | Gỡ timebox quá khứ phải đồng bộ lịch ngoài | Gọi G05 bất đồng bộ; lỗi lịch không chặn rollover |
| Instance lặp (G03) | Hai nhóm cùng xử lý instance cũ | G06 là nơi duy nhất thực thi; G03 chỉ định nghĩa quy tắc |

# 10. Câu hỏi mở

- day_start_time 04:00 hay 00:00?
- Auto-archive mặc định bật hay tắt (Sunsama chưa kiểm chứng mặc định)?
- Ngày người dùng không mở app có tính vào chuỗi 4 ngày không? Đề xuất: có (job chạy phía server).
- Shift+Z đưa lên đầu bucket nào: "Tuần tới" hay bucket hiện tại của task?
- Gỡ timebox quá khứ có xoá sự kiện trên Google / Outlook không, hay giữ làm lịch sử?
- Có tự chuyển task giữa các bucket khi tới kỳ không?
- Task trong Archive có hiện trong tìm kiếm (G04) không?
