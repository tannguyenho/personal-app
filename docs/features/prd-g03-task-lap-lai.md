> **Mã:** PLN-PRD-G03 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g03-task-lap-lai.md

# PRD Task lặp lại trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: picker lặp (Repeats / On / Every N week / At roughly / Save), toast "Task now repeats", banner series ("This task repeats every weekday. This is the first instance of this series. Edit task series. Previous / Next"), instance Thứ Sáu hiện projection 9:00 và sao chép notes, đổi priority một instance không hỏi phạm vi. Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> Đã cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md). Quy tắc `QC-xx` ở [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); G03 sở hữu **QC-06** (instance trùng series trong một ngày). Thuật ngữ (series, instance, ngày gốc, ngày ngoại lệ) theo [`CONTEXT.md`](../../CONTEXT.md).
>
> Cập nhật thêm theo vòng 5–6: quy tắc `WEEKDAYS` hiển thị là "Thứ Hai–Thứ Sáu", quy tắc lặp không theo lịch làm việc (Q43); sửa giờ timebox của instance là sửa riêng (Q44); bản 1.0 là app Windows cho một người dùng (Q35, Q45, [ADR-0005](../adr/0005-nen-tang-windows-truoc.md)).
>
> Cập nhật theo [câu hỏi chốt 09/11/2026](../review/cau-hoi-chot-flow-2026-11-09.md): B08, B14–B16, C10–C16, A1, A3, A6 (QC-08 mục 7, QC-13).
>
> Cập nhật 10/11/2026 theo [brief G03](../design-brief/g03-task-lap-lai.md) đã duyệt (mục 11, O-01 … O-21 chốt theo đề xuất của brief): trả lời các câu hỏi mở ở mục 10, sửa mục 3, mục 5 và AC liên quan.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Nhiều việc lặp theo nhịp cố định: standup mỗi sáng, dọn hộp thư từ Thứ Hai đến Thứ Sáu, báo cáo tuần, gửi hoá đơn cuối tháng. Nhóm G03 lo việc biến một task thành series lặp, sinh sẵn các instance trên những ngày tới, sửa từng instance và sửa cả series. Mô hình task (G02), board và projection (G04), timebox (G05), rollover và Lưu trữ (G06) dùng chung với instance lặp.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Phải tạo lại tay việc định kỳ mỗi ngày / tuần / tháng | Quên việc, mất thời gian ghi chép lặp đi lặp lại |
| Việc định kỳ không hiện trước trên các ngày tới | Không thấy khối lượng tương lai, Daily planning và plan tuần thiếu việc |
| Sửa một lần lại bị hỏi "chỉ lần này hay tất cả" | Thêm một bước, dễ chọn nhầm và sửa lan sang cả series |
| Ngày 29–31 và 29/2 không có ở mọi tháng / năm | Instance bị mất hoặc nhảy sang tháng sau |
| Bỏ lỡ một lần, instance cũ rollover chồng lên instance mới | Cột hôm nay có hai bản của cùng một việc |

## 1.3 Mục tiêu

- Biến một task có sẵn thành task lặp trong ≤ 10 giây: menu … → Lặp lại → chọn quy tắc → Lưu.
- Instance có sẵn trên board 60 ngày tới để G04 tính khối lượng ngày và tuần.
- Sửa một instance không bao giờ hỏi phạm vi; mọi thao tác trên cả series nằm ở một menu "Sửa series".
- Hệ thống không bao giờ tự đặt hai instance của cùng series vào một ngày (QC-06), trừ ngoại lệ B08: instance bị lỡ đã sửa riêng hoặc đã có thời gian thực tế vẫn rollover vào hôm nay.
- Ngày người dùng đã bỏ (xoá instance) không bao giờ bị sinh lại.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Người dùng cá nhân (Linh PM) | Standup, dọn email từ Thứ Hai đến Thứ Sáu, báo cáo tuần tự có trên board |
| Người cần khối thời gian dài (Minh) | Một khối "Deep work" mỗi sáng vào khoảng cùng giờ |
| Freelancer / founder (Hà) | Gửi hoá đơn ngày cuối tháng, gia hạn tên miền hằng năm, không lo tháng ngắn |
| Người dùng thành thạo | Mở cấu hình lặp và sửa series không rời bàn phím |

# 3. Phạm vi

## 3.1 Trong phạm vi (MVP)

- Nền tảng: bản 1.0 là app **Windows** (Flutter), một người dùng, dữ liệu trên cloud gắn tài khoản (Q45, ADR-0005). Web và macOS từ 1.1, iOS / Android từ 1.2, dùng cùng đặc tả.
- Bật lặp cho task có sẵn từ menu … → Lặp lại (card và chi tiết task).
- 6 kiểu quy tắc: Daily, Thứ Hai–Thứ Sáu (`WEEKDAYS`), Weekly (chọn thứ, mỗi N tuần), Monthly theo ngày, Monthly theo "thứ N", Yearly; khoảng lặp 1–99; giờ "khoảng" (At roughly). Quy tắc lặp tính theo lịch dương, **không** theo lịch làm việc (G01) hay khung giờ channel (G02) (Q43).
- Sinh instance tự động tới 60 ngày phía trước, không sinh ngày đã qua; instance hiện dạng projection trên board.
- Ngày ngoại lệ: ngày gốc của instance người dùng đã xoá, series không sinh lại.
- Banner series trong chi tiết instance: mô tả quy tắc, vị trí trong series, Trước / Sau, "Sửa series".
- Menu "Sửa series" 6 thao tác: Dừng lặp, Đổi tần suất, Cập nhật mọi lần chưa xong theo task này, Xoá mọi lần chưa xong và dừng lặp, Đặt giờ bắt đầu, Quản lý mọi task lặp; có bảng phạm vi cho từng thao tác. Chữ trên giao diện dùng "lần" thay "instance"; thứ tự hiển thị theo SRS SCR-03 (chốt 10/11/2026, O-17, O-18 brief G03).
- Quy tắc instance trùng series trong một ngày (QC-06, G03 sở hữu): đường tự động (rollover G06, phím D G04, shutdown "Ngày mai" G08) lưu trữ instance thừa; đường thủ công cho phép kèm cảnh báo. Nhóm sở hữu từng đường thực thi.

## 3.2 Ngoài phạm vi

- Rollover, Lưu trữ → G06. Board, projection, sắp xếp → G04.
- Timebox và "Lập lịch cứng cho task lặp" → G05 (SRS G05 BR-23 / UC-09, cửa sổ 7 ngày `[giả định]`), phát hành **bản 1.1** (Q7). Bản 1.0 chỉ lưu và hiện giờ "khoảng", không tạo timebox.
- Chế độ chỉ đọc (dừng sinh instance) → bản 1.1 (QC-09).
- Ngày kết thúc series / số lần lặp tối đa → không có ở 1.0, picker không chừa chỗ (chốt 10/11/2026, O-20).
- Lặp theo ngày hoàn thành ("3 ngày sau khi xong") → sau 1.1.
- Gắn objective cho task lặp → G09 (bản 1.1); objective không sao chép sang instance.
- Task lặp giao cho người khác → bản sau (Q35, [`02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md)); bản 1 chỉ một người dùng.
- Lặp theo lịch làm việc ("mỗi ngày làm việc" theo G01 / khung giờ channel) → không có ở 1.0 (Q43); xem Câu hỏi mở.

# 4. Nguyên tắc sản phẩm

## 4.1 Sửa một là một

Sửa một instance chỉ đổi instance đó, không hỏi phạm vi (giống Sunsama). Muốn đổi cả series thì vào "Sửa series".

## 4.2 Thấy trước tương lai

Instance có mặt sẵn trên các ngày tới ở dạng projection, không cố định giờ, để người dùng thấy khối lượng khi plan ngày và tuần.

## 4.3 Một series, một ngày, một instance

Hệ thống không tự đặt hai instance cùng series vào một ngày (QC-06), trừ ngoại lệ B08. Instance bị đưa vào ngày đã có instance qua đường tự động (rollover, phím D, shutdown "Ngày mai") chuyển vào Lưu trữ với lý do "bị bỏ qua". Ngoại lệ B08 (chỉ ở rollover): instance bị lỡ đã sửa riêng hoặc đã có thời gian thực tế vẫn rollover vào hôm nay như task thường, không làm instance khác bị bỏ qua. Người dùng chủ động kéo thả, chọn ngày hay khôi phục thì vẫn được đặt, kèm cảnh báo.

## 4.4 Quá khứ không đổi

Sửa quy tắc hay nội dung series chỉ áp cho instance chưa xong ở hiện tại và tương lai. Instance đã xong, instance trong Lưu trữ và Thùng rác giữ nguyên (C12). Instance đã có thời gian thực tế không bao giờ bị xoá vì sửa hay dừng series (C13).

## 4.5 Ngày đã bỏ là bỏ hẳn

Xoá một instance thì ngày gốc của nó thành ngày ngoại lệ; series không sinh lại ngày đó, kể cả sau khi đổi tần suất qua lại hay Thùng rác đã xoá vĩnh viễn (Q26).

# 5. Quy tắc lặp

| **Quy tắc** | **Tham số / giới hạn** | **Mặc định khi mở picker** | **Ghi chú** |
|---|---|---|---|
| Daily | Mỗi N ngày, N = 1–99 | N = 1 | — |
| Thứ Hai–Thứ Sáu (`WEEKDAYS`) | Cố định Thứ Hai – Thứ Sáu | — | Không có khoảng lặp. Nhãn là "Thứ Hai–Thứ Sáu", không gọi "Ngày làm việc"; không đổi theo lịch làm việc (Q43) |
| Weekly | Chọn 1–7 thứ; mỗi N tuần, N = 1–99 | Thứ của ngày dự định của task; N = 1 | Ngày đầu tuần lấy theo cài đặt (G01) lúc tạo series và cố định cho series đó (C14) |
| Monthly theo ngày | Ngày D = 1–31; mỗi N tháng | D = ngày của ngày dự định | D = 29–31 → ngày cuối tháng ở tháng ngắn hơn |
| Monthly theo "thứ N" | Thứ nhất / hai / ba / tư / cuối cùng + thứ trong tuần; mỗi N tháng | Suy từ ngày dự định (ví dụ "Thứ Tư đầu tiên") | Ngày là lần thứ 5 trong tháng → mặc định "cuối cùng"; lần thứ 4 → "thứ 4", người dùng tự đổi nếu muốn "cuối cùng" (chốt 10/11/2026, O-03) |
| Yearly | Ngày / tháng; mỗi N năm | Ngày / tháng của ngày dự định | 29/2 → 28/2 ở năm không nhuận |
| Giờ "khoảng" | Bước 15 phút `[giả định]`; trống được | Trống | Chỉ hiện trên card ở 1.0; thành timebox khi bật lập lịch cứng (G05, bản 1.1) |
| Khoảng sinh trước | 60 ngày | — | Job sinh instance chạy hằng ngày; không sinh ngày < hôm nay |
| Ngày ngoại lệ | Danh sách ngày gốc người dùng đã bỏ, lưu trên series | Rỗng | Không bao giờ sinh lại; không mất khi Thùng rác xoá vĩnh viễn (Q26) |
| Số series đang lặp | Tối đa 200 / người dùng `[giả định]` | — | Chặn tạo thêm, gợi ý dừng series cũ |

| **Trường của instance mới** | **Sao chép từ series?** |
|---|---|
| Tiêu đề, notes, channel, thời lượng kế hoạch, giờ "khoảng" | Có |
| Priority, subtask (tiêu đề + thời lượng, trạng thái chưa xong) | Có `[giả định]` |
| Comment, objective, timebox, thời gian thực tế, nhật ký | Không |

- Các giới hạn là **cấu hình hệ thống**, không cố định trong code.
- Mở picker để bật lặp: quy tắc chọn sẵn là Daily ("Hằng ngày"). Monthly theo ngày, Monthly theo "thứ N" và Yearly có ô chọn ngày / thứ N + thứ / ngày + tháng, mặc định suy từ ngày dự định (chốt 10/11/2026, O-02).
- Instance đầu tiên chính là task ban đầu, đặt vào ngày khớp quy tắc đầu tiên tính từ ngày dự định của task (không trước hôm nay); ngày dự định đã khớp thì giữ nguyên. Các instance sau sinh theo quy tắc tính từ ngày đó (C14).
- Không bật lặp cho task đã hoàn thành (C14).
- **Quy tắc lặp không theo lịch làm việc** (Q43). Ngày sinh instance chỉ do quy tắc quyết định. Ví dụ: lịch làm việc có Thứ Bảy, quy tắc Thứ Hai–Thứ Sáu vẫn không sinh Thứ Bảy; lịch làm việc bỏ Thứ Tư, quy tắc Hằng ngày vẫn sinh Thứ Tư. Lịch làm việc của task (QC-02 mục 6) chỉ ảnh hưởng projection, sức chứa, số ngày bị hoãn và "ngày làm việc kế tiếp" của instance như task thường.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Bật lặp | Menu … → Lặp lại, chọn quy tắc, (tuỳ chọn) giờ "khoảng", Lưu | Toast "Task giờ sẽ lặp lại"; task ban đầu là instance đầu |
| 2 | Sinh instance | Hệ thống sinh instance trên các ngày khớp quy tắc trong 60 ngày tới | Instance hiện projection trên cột ngày, có biểu tượng lặp |
| 3 | Làm từng lần | Mở instance: banner series, Trước / Sau; hoàn thành, sửa riêng lần này | Instance xong; series không đổi |
| 4 | Bỏ lỡ | Instance chưa xong qua ngày: rollover hoặc vào Lưu trữ lý do "bị bỏ qua" (QC-06, G06) | Hôm nay chỉ có một instance của series |
| 5 | Sửa series | "Sửa series": đổi tần suất, đặt giờ, áp nội dung instance này cho mọi instance chưa xong | Instance tương lai chưa xong cập nhật |
| 6 | Kết thúc | Dừng lặp, hoặc xoá mọi instance chưa xong và dừng lặp | Không sinh thêm instance |

Bước 4 do G06 thực thi theo quy tắc của G03. PRD này tập trung bước 1, 2, 3, 5, 6.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Bật lặp cho task

### US1.1 Đặt quy tắc lặp

User Story: Là người dùng, tôi muốn đặt một task lặp theo ngày, Thứ Hai–Thứ Sáu, tuần, tháng hoặc năm, để không phải tạo lại việc định kỳ.

AC01: Menu … của task (card hoặc chi tiết) có mục "Lặp lại"; mở picker với các ô Lặp (6 quy tắc), Vào (thứ khi Weekly; ngày, thứ N + thứ, ngày + tháng khi Monthly / Yearly, chốt 10/11/2026, O-02), Mỗi N tuần / tháng / năm, Vào khoảng (giờ), Lưu. Task đã lặp thì mục vẫn ghi "Lặp lại", mở picker ở chế độ đổi tần suất; mất mạng thì mục này mờ, tooltip "Cần có mạng để sửa cả chuỗi" (chốt 10/11/2026, O-01).

AC02: Giá trị mặc định suy từ ngày dự định của task (thứ, ngày trong tháng, "thứ N").

AC03: Lưu → task ban đầu thành instance đầu, đặt vào ngày khớp quy tắc đầu tiên tính từ ngày dự định (giữ nguyên nếu ngày dự định đã khớp); toast "Task giờ sẽ lặp lại" nêu ngày lần đầu (Sunsama "Task now repeats") (C14). Ví dụ: task Thứ Ba, quy tắc Hằng tuần Thứ Hai → lần đầu là Thứ Hai kế tiếp.

AC04: Khoảng lặp ngoài 1–99 hoặc Weekly không chọn thứ nào → nút Lưu disabled, hiện lỗi tại ô.

AC05: Task trong backlog (không có ngày) bật lặp → ngày dự định coi là hôm nay; instance đầu đặt vào ngày khớp quy tắc đầu tiên tính từ hôm nay (hôm nay nếu khớp), toast nói rõ ngày (chốt 10/11/2026, O-05).

AC06: Task đã hoàn thành → mục "Lặp lại" disabled, tooltip giải thích (C14).

AC07: Weekly mỗi N ≥ 2 tuần: ngày đầu tuần lấy theo cài đặt lúc tạo và cố định cho series; đổi cài đặt ngày đầu tuần sau đó không làm lệch lịch của series (C14).

AC08: Hai thiết bị offline cùng bật lặp một task → chỉ một series được tạo; thiết bị tới sau thấy thông báo task đã được đặt lặp lại (QC-08).

AC09: Ô Lặp hiện lựa chọn "Thứ Hai–Thứ Sáu" (không phải "Ngày làm việc"). Quy tắc này luôn sinh Thứ Hai đến Thứ Sáu, bất kể lịch làm việc hay khung giờ channel của task (Q43).

AC10: Đã có 200 series đang lặp → lỗi hiện ngay dưới ô Lặp; chữ "Quản lý mọi task lặp" là link mở Cài đặt → Task lặp lại (chốt 09/11/2026, C16).

### US1.2 Ngày không tồn tại ở mọi tháng / năm

AC01: Monthly ngày 31 → tháng 30 ngày sinh vào ngày 30, tháng 2 sinh vào 28 (hoặc 29 năm nhuận); tháng sau quay lại ngày 31.

AC02: Yearly 29/2 → năm không nhuận sinh vào 28/2.

AC03: Picker hiện ghi chú khi chọn ngày 29–31 hoặc 29/2 để người dùng biết trước.

## UC2. Xem và làm từng instance

### US2.1 Instance có sẵn trên board

AC01: Sau khi bật lặp, instance của 60 ngày tới hiện trên cột ngày tương ứng trong ≤ 5 giây.

AC02: Instance không có giờ cố định: hiện giờ projection (G04). Kiểm chứng: instance Thứ Sáu của task lặp Thứ Hai–Thứ Sáu hiện 9:00 theo projection, notes được sao chép.

AC03: Card instance có biểu tượng lặp; có giờ "khoảng" thì hiện giờ đó (bản 1.0 không tạo timebox).

AC04: Không sinh instance cho ngày đã qua, kể cả khi job ngừng chạy nhiều ngày (C14).

### US2.2 Banner series và điều hướng

AC01: Chi tiết instance có banner: "Task này lặp lại {mô tả quy tắc}. Đây là lần {thứ n} của series." + "Sửa series" + Trước / Sau.

AC02: Trước / Sau mở instance liền kề theo ngày; instance đầu thì Trước disabled; chưa sinh tới thì Sau hiện ngày lần kế tiếp.

AC03: Series đã dừng → banner "Series này đã dừng lặp"; Trước / Sau vẫn hiện, bỏ qua các instance đã xoá (chốt 09/11/2026, B16).

AC04: Mở một instance đã bị xoá ở thiết bị khác → thông báo "Task hoặc series này không còn tồn tại", card được gỡ khỏi board (C11). Instance đang mở thì bị xoá ở thiết bị khác → như task thường bị xoá khi đang mở (G02): chi tiết đóng, toast có Hoàn tác (chốt 10/11/2026, O-13).

### US2.3 Sửa một instance

User Story: Là người dùng, tôi muốn sửa riêng lần hôm nay mà không bị hỏi, để thao tác nhanh và không làm hỏng các lần sau.

AC01: Sửa bất kỳ trường nào của instance (tiêu đề, priority, thời lượng, notes, ngày…) chỉ đổi instance đó, không có hộp hỏi phạm vi (kiểm chứng: đổi priority instance Thứ Sáu).

AC02: Hoàn thành, xoá, dời ngày một instance không ảnh hưởng instance khác.

AC03: Xoá một instance → ngày gốc thành ngày ngoại lệ, không bao giờ sinh lại, kể cả sau khi khôi phục từ Thùng rác, Thùng rác xoá vĩnh viễn sau 30 ngày, hay đổi tần suất qua lại (Q26).

AC04: Hoàn thành sớm một instance của ngày tương lai → instance giữ nguyên ngày dự định, không nhảy về hôm nay (Q12).

AC05: Dời instance vào ngày đã có instance của cùng series: kéo thả / chọn ngày → vẫn dời, cảnh báo "Ngày này đã có {tên series}"; phím D → instance được dời chuyển vào Lưu trữ lý do "bị bỏ qua", có toast Hoàn tác (QC-06).

AC06: Đổi giờ hoặc thời lượng timebox của một instance (kéo trên lịch, sửa giờ) → instance được tính là **sửa riêng** (Q44), như khi sửa tiêu đề hay thời lượng; các thao tác "Sửa series" sau đó xử lý instance này theo cột "đã dời / sửa riêng" của bảng phạm vi (US3.1 AC02, US4.1 AC01). Đặt mới hoặc gỡ timebox cũng tính là sửa riêng `[giả định]`.

## UC3. Sửa series

### US3.1 Đổi tần suất

AC01: "Sửa series" → "Đổi tần suất" mở lại picker với quy tắc hiện tại.

AC02: Lưu → chỉ instance chưa xong có ngày sau hôm nay bị ảnh hưởng, so khớp theo **ngày gốc**: ngày gốc khớp quy tắc mới thì giữ; không khớp thì instance chưa dời, chưa sửa riêng bị xoá hẳn (không tạo ngày ngoại lệ), còn instance đã dời, sửa riêng (kể cả đã sửa giờ timebox, Q44) hoặc có thời gian thực tế được giữ và tách khỏi series, giữ cả timebox. Instance hôm nay, quá khứ, đã xong, trong Lưu trữ, Thùng rác giữ nguyên (EC-29, C12, Q26).

AC03: Toast nêu số instance thay đổi và số instance được giữ, có Hoàn tác.

AC04: Instance bị ảnh hưởng đang chạy timer → timer dừng; Hoàn tác không chạy lại timer (C13).

AC05: Số instance được giữ là dòng 2 của cùng toast, không phải toast thứ hai (QC-13 mục 3, A3).

AC06: Mất mạng → mọi thao tác trên cả series (Dừng lặp, Đổi tần suất, Cập nhật theo task này, Xoá và dừng lặp, Đặt giờ bắt đầu) mờ, tooltip "Cần có mạng để sửa cả chuỗi" (QC-08 mục 7, A6, C10). Sửa một instance vẫn làm được khi mất mạng.

### US3.2 Cập nhật mọi instance chưa xong theo task này

AC01: Tiêu đề, notes, channel, thời lượng, priority, subtask của instance đang mở được chép sang series và mọi instance chưa xong từ hôm nay.

AC02: Subtask gộp theo tiêu đề: subtask cùng tiêu đề trên instance đang làm dở giữ trạng thái xong và thời gian thực tế (C12).

AC03: Instance đã xong, trong Lưu trữ, Thùng rác không đổi; toast nêu số instance, có Hoàn tác.

AC04: Instance đã sửa riêng (kể cả đã sửa giờ timebox, Q44) cũng bị ghi đè các trường nội dung; timebox của instance không phải trường được chép nên giữ nguyên.

### US3.3 Đặt giờ bắt đầu

AC01: Đặt hoặc xoá giờ "khoảng" cho series qua bộ chọn giờ bước 15 phút có "Xoá giờ" (SRS G03 SCR-07, C12); áp cho mọi instance chưa xong từ hôm nay.

AC02: Bản 1.0 không tạo timebox. "Lập lịch cứng cho task lặp" do G05 đặc tả (SRS G05 BR-23 / UC-09), phát hành bản 1.1 (Q7).

AC03: Instance đã có timebox (người dùng tự timebox) → chỉ đổi giờ "khoảng", không dời timebox.

AC04: Đặt giờ và "Xoá giờ" đều có toast Hoàn tác (chốt 10/11/2026, O-10).

## UC4. Dừng lặp và xoá

### US4.1 Dừng lặp

AC01: "Sửa series" → "Dừng lặp": không sinh thêm instance; instance tương lai chưa động tới bị xoá mềm; instance tương lai đã dời, đã sửa riêng (kể cả sửa giờ timebox) hoặc đã có thời gian thực tế được giữ; instance hôm nay và trước đó giữ nguyên (chốt 09/11/2026, B14).

AC02: Toast có Hoàn tác, dòng 2 nêu số instance được giữ (A3); banner instance còn lại đổi thành "Series đã dừng lặp".

AC03: Instance đang chạy timer bị ảnh hưởng → dừng timer; instance đã có thời gian thực tế được giữ, không xoá (C13).

### US4.2 Xoá mọi instance chưa xong và dừng lặp

AC01: Hiện xác nhận có số instance sẽ xoá (khác Sunsama về mức hỏi; thao tác hàng loạt nên hỏi, vẫn có Hoàn tác, chốt 10/11/2026, O-19); nút xác nhận là "Xoá và dừng lặp" (C13).

AC02: Mọi instance chưa xong vào Thùng rác (G02) và ngày gốc của chúng thành ngày ngoại lệ; instance đã xong, đã có thời gian thực tế, trong Lưu trữ giữ nguyên; series dừng; toast có Hoàn tác, dòng 2 nêu số lần đã có thời gian thực tế được giữ (C12, C13; chốt 10/11/2026, O-09).

## UC5. Instance bị bỏ lỡ

### US5.1 Không có hai bản cùng một việc hôm nay

AC01: "Series đã có instance hôm nay" = có instance có ngày gốc hoặc ngày dự định bằng hôm nay, ở trạng thái Kế hoạch hoặc Hoàn thành (B5, QC-06).

AC02: Instance cũ chưa xong, series đã có instance hôm nay → instance cũ không rollover, vào Lưu trữ với lý do "bị bỏ qua" (EC-30, G06).

AC03: Series chưa có instance hôm nay → chỉ instance cũ mới nhất rollover về hôm nay; các instance cũ hơn vào Lưu trữ lý do "bị bỏ qua" `[giả định]`.

AC04: Khôi phục instance "bị bỏ qua" từ Lưu trữ được (G06); hôm nay đã có instance thì vẫn khôi phục, kèm cảnh báo "Ngày này đã có {tên series}" (QC-06).

AC05: Phím D hoặc shutdown "Ngày mai" đưa instance vào ngày đã có instance → instance đó vào Lưu trữ lý do "bị bỏ qua", có toast Hoàn tác (QC-06). Chữ toast do G04 (phím D) và G08 (shutdown) định nghĩa (C15).

AC06: Instance cũ chưa xong nhưng đã sửa riêng hoặc đã có thời gian thực tế không vào Lưu trữ "bị bỏ qua"; được giữ và rollover vào hôm nay như task thường, kể cả khi hôm nay đã có instance của cùng series, và không làm instance khác bị bỏ qua. Chỉ áp cho rollover; phím D và shutdown "Ngày mai" giữ như AC05 (chốt 09/11/2026, B08).

## UC6. Quản lý mọi task lặp

### US6.1 Xem tất cả series

AC01: "Sửa series" → "Quản lý mọi task lặp" (hoặc Cài đặt → Task lặp lại) liệt kê series: tiêu đề, quy tắc, giờ "khoảng", channel, lần kế tiếp, trạng thái.

AC02: Từ mỗi dòng: mở instance kế tiếp, đổi tần suất (mở picker ngay trên dòng), dừng lặp (hộp xác nhận ngay trên dòng); không cần mở instance trước (chốt 09/11/2026, B15). "Quản lý mọi task lặp" là nhóm "Task lặp lại" trong Cài đặt (nhóm "Cá nhân", sau "Timebox"); mở từ chi tiết task thì chi tiết đóng trước; mở lần kế tiếp thì Cài đặt đóng, board cuộn tới ngày đó và mở chi tiết (chốt 10/11/2026, O-14).

AC03: Lọc "Đang lặp" / "Đã dừng".

AC04: Tải danh sách lỗi → "Chưa tải được. Thử lại" tại chỗ (QC-MSG-02, C14). Mất mạng → đổi tần suất, dừng lặp trên dòng mờ, tooltip "Cần có mạng để sửa cả chuỗi" (A6).

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu MVP** |
|---|---|---|
| Tỉ lệ người dùng có series | Người dùng có ≥ 1 series đang lặp / người dùng hoạt động tuần | ≥ 40% |
| Tỉ lệ hoàn thành instance | Instance xong / instance có ngày ≤ hôm nay | ≥ 60% |
| Tỉ lệ instance bị bỏ qua | Instance vào Lưu trữ lý do "bị bỏ qua" / instance có ngày ≤ hôm nay | Theo dõi (cao = quy tắc quá dày) |
| Series dừng sớm | Series dừng trong 14 ngày đầu / series mới | ≤ 30% |
| Thời gian bật lặp | Từ mở picker đến Lưu | ≤ 10 giây (trung vị) |
| Lỗi sinh instance | Lượt job lỗi / tổng lượt | ≤ 0,1% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Job sinh instance | Job lỗi hoặc chạy trùng tạo instance trùng; ngày đã bỏ bị sinh lại sau khi Thùng rác xoá vĩnh viễn | Khoá duy nhất (series, ngày gốc) trên instance còn gắn series; danh sách ngày ngoại lệ lưu trên series, độc lập Thùng rác (Q26); job idempotent, chạy lại an toàn |
| Dung lượng | 60 ngày × nhiều series × nhiều người dùng | Giới hạn 200 series / người dùng; instance tương lai là bản ghi nhẹ |
| Timezone, DST | Đổi timezone làm lệch ngày instance | Ngày instance lưu theo ngày (không giờ); đổi timezone không đổi ngày dự định, ngày gốc đã sinh (QC-01) |
| Board quá tải | Nhiều series Daily làm cột ngày dài | Hiện tổng thời lượng và cảnh báo khối lượng (G04) |
| Instance trùng ngày (G04, G06, G08) | Nhiều đường đổi ngày có thể dồn hai instance vào một ngày | G03 sở hữu QC-06; G06 (rollover), G04 (phím D, kéo thả), G08 (shutdown) thực thi theo QC-06 |
| Lịch ngoài (G05) | Lập lịch cứng tạo nhiều sự kiện trên Google / Outlook | Lập lịch cứng thuộc G05, bản 1.1 (Q7); cửa sổ tạo timebox 7 ngày `[giả định]`, do G05 chốt (SRS G05 BR-23 b) |

# 10. Câu hỏi mở

- Có cần ngày kết thúc series / số lần lặp ở 1.0 không? **Chốt 10/11/2026 (O-20):** không có ở 1.0; picker không chừa chỗ (mục 3.2).
- Instance mới có sao chép priority và subtask không (Sunsama chưa kiểm chứng)?
- "Dừng lặp" có xoá instance tương lai đã sinh hay giữ lại? **Chốt 09/11/2026 (B14):** xoá các instance tương lai chưa động tới; giữ instance đã dời, đã sửa riêng hoặc đã có thời gian thực tế (US4.1 AC01).
- Xoá mọi instance chưa xong có cần hộp xác nhận hay chỉ toast Hoàn tác như xoá thường (G02)? **Chốt 10/11/2026 (O-19):** có cả hộp xác nhận và toast Hoàn tác (US4.2 AC01, SRS BR-08 d).
- Monthly theo "thứ N" có lựa chọn "cuối cùng" không? **Chốt 10/11/2026 (O-03):** có; ngày là lần thứ 5 trong tháng → mặc định "cuối cùng", lần thứ 4 → "thứ 4" (mục 5, SRS BR-01).
- Đã chốt 04/11/2026: "hôm nay" là ngày làm việc, mốc đầu ngày mặc định 04:00, chỉnh trong 00:00–06:00 (Q2, QC-01).
- Xoá task ban đầu (instance đầu) có dừng series không? Đề xuất: không.
- Đã chốt 04/11/2026: lập lịch cứng cho task lặp do G05 sở hữu, phát hành bản 1.1; G03 chỉ giữ giờ "khoảng" (Q7).
- Đã chốt 04/11/2026: xoá instance tạo ngày ngoại lệ vĩnh viễn; đổi quy tắc so theo ngày gốc, instance đã dời / sửa riêng được giữ và tách khỏi series (Q26).
- Đã chốt 04/11/2026: "series đã có instance hôm nay" = ngày gốc hoặc ngày dự định bằng hôm nay, trạng thái Kế hoạch hoặc Hoàn thành (B5); hai instance cùng ngày xử lý theo QC-06 (Q11).
- Khi series chưa có instance hôm nay và có nhiều instance quá khứ chưa xong: giữ instance mới nhất hay cũ nhất (thứ tự rollover theo C16 là ngày cũ tăng dần)?
- "Sửa riêng" một instance gồm những thao tác nào (đề xuất: sửa trường được sao chép từ mẫu, trừ tích subtask)? Đã chốt 04/11/2026 một phần: sửa giờ timebox của instance là sửa riêng (Q44). Còn mở: đặt mới / gỡ timebox có tính là sửa riêng không (bản này giả định có).
- Đã chốt 04/11/2026: nhãn quy tắc `WEEKDAYS` là "Thứ Hai–Thứ Sáu", không phải "Ngày làm việc"; quy tắc lặp không theo lịch làm việc (Q43).
- Đã chốt 04/11/2026: bản 1.0 là app Windows (Flutter), một người dùng; task lặp giao cho người khác để bản sau (Q35, Q45).
- Có cần quy tắc lặp "theo lịch làm việc" (sinh vào các ngày có trong lịch làm việc chung hoặc khung giờ channel) ở bản sau không? Q43 chỉ chốt 1.0 không có.
- "Dừng lặp" có xoá instance tương lai đã dời hoặc sửa riêng không, hay giữ như khi đổi tần suất (Q26)? **Chốt 09/11/2026 (B14):** giữ, như khi đổi tần suất; instance vẫn gắn series đã dừng.
- **Chốt 09/11/2026 (B15):** đổi tần suất và dừng lặp làm ngay trên dòng của "Quản lý mọi task lặp", không cần mở instance (US6.1 AC02).
- **Chốt 09/11/2026 (B16):** series đã dừng vẫn hiện Trước / Sau, bỏ qua instance đã xoá (US2.2 AC03).
- **Chốt 09/11/2026 (B08):** instance bị lỡ đã sửa riêng hoặc đã có thời gian thực tế không bị lưu trữ "bị bỏ qua", rollover như task thường (US5.1 AC06).
