# Brief G02 Quản lý task — bản thử: tạo task và chi tiết task

> **BẢN THỬ** để PO phản hồi về [khuôn](_khuon.md) ([ticket #9](https://github.com/tannguyenho/personal-app/issues/9)). Chỉ phủ một phần G02: ô soạn task, card ngay sau khi tạo, chi tiết task, menu "Khác". Brief G02 đầy đủ ([#11](https://github.com/tannguyenho/personal-app/issues/11)) sẽ viết lại từ bản này sau khi chốt khuôn, kiến trúc thông tin (#7) và FigJam (#10).
>
> **Mã:** PLN-BRIEF-G02 (thử) · **Trạng thái:** nháp · **Phiên bản:** 1.0
> **Nguồn:** [prd-g02](../features/prd-g02-quan-ly-task.md), [srs-g02](../features/srs-g02-quan-ly-task.md) (commit `130668d`), QC-01, QC-03, QC-08, QC-12, quyết định C9, C11, B4, Q25, Q33, D10, D11
> **Phụ thuộc:** kiến trúc thông tin `[chờ #7]` (chi tiết task mở ở panel, dialog hay cửa sổ; ô thêm nhanh toàn cục), design system `[chờ #8]` (tên component), FigJam `[chờ #10]`
> **Flow:** [flow/g02-quan-ly-task.md](flow/g02-quan-ly-task.md) (UC-01, UC-02) · **FigJam:** `[chờ]`

## 1. Tóm tắt cho người vẽ

Người dùng ghi một việc bằng cách gõ tên rồi Enter, không cần chọn gì thêm. Ngày lấy theo cột đang đứng. Nếu bật trợ lý AI thì thời lượng và channel được điền sẵn, có dấu ✨. Sau đó người dùng mở task để thêm bước nhỏ, ghi chú, priority, hạn chót.

Khoảnh khắc quan trọng nhất: **từ lúc mở ô soạn tới lúc task nằm trên cột không quá 5 giây** (PRD G02 mục 8). Ô soạn không bao giờ bắt người dùng chờ AI. Chi tiết task không có nút Lưu: sửa ở đâu lưu ở đó.

## 2. Phạm vi của brief

**Trong bản thử**
- Màn: SCR-01 Ô soạn task, SCR-N01 Ô thêm nhanh toàn cục, SCR-02 Task card (chỉ các trạng thái liên quan tới tạo và lưu), SCR-03 Chi tiết task, SCR-04 Menu "Khác".
- Flow: F-01 … F-08 (mục 5).

**Không trong bản thử** (vào brief G02 đầy đủ #11, hoặc brief khác)
- Hoàn thành / bỏ hoàn thành, xoá task, Thùng rác (SCR-05), nhân bản: brief G02 đầy đủ. Bản thử chỉ nêu nút nằm ở đâu.
- Context & channel, khung giờ channel (SCR-06, SCR-07): brief G02 đầy đủ.
- Cột ngày, kéo thả, projection, bộ đếm khối lượng: brief G04.
- Timebox trên chi tiết task: brief G05. Timer: brief G07. Cấu hình lặp: brief G03.
- Màn đồng ý và cài đặt trợ lý AI: brief G10.

**Ẩn ở 1.0, chừa chỗ nếu cần:** ô Objective trong ô soạn (SCR-01 #6), mục "Gắn objective" trong menu (SCR-04 #2) thuộc G09, bản 1.1.

**Khác Sunsama có chủ đích, người vẽ cần biết**
- Esc trong ô soạn **giữ** bản nháp; Sunsama bỏ luôn (G02 US1.1 AC04).
- Không bật trợ lý AI thì **không có** gợi ý nào; Sunsama vẫn gợi ý bằng chấm cam kể cả khi tắt AI (Q33, #22, #23-S11).
- Xoá subtask có toast Hoàn tác; Sunsama chỉ có toast Hoàn tác cho xoá task (C9, #22-C3).

## 3. Danh sách màn hình

| Mã | Màn | Bề mặt | Điểm vào | Số trạng thái | Ưu tiên vẽ |
|---|---|---|---|---|---|
| SCR-01 | Ô soạn task | Inline, đầu (hoặc cuối) danh sách của cột ngày | Nút "Thêm task" trên cột; phím A; command menu "Thêm task" | 12 | P1 |
| SCR-N01 | Ô thêm nhanh toàn cục | Cửa sổ nổi nhỏ `[chờ #7]` | Ctrl+Shift+A, kể cả khi app ở nền hoặc thu nhỏ (D11) | 4 | P2 |
| SCR-02 | Task card (phần do tạo / lưu) | Trên cột ngày | Sau Enter ở SCR-01 | 4 | P1 |
| SCR-03 | Chi tiết task | `[chờ #7]` panel phải, dialog hay cửa sổ riêng | Bấm tiêu đề card; Ctrl+Enter khi task đang chọn | 15 | P1 |
| SCR-04 | Menu "Khác" | Menu thả xuống từ nút … | Nút … trên header SCR-03; chuột phải trên card `[đề xuất]` | 2 | P2 |

## 4. Màn hình và trạng thái

### SCR-01 Ô soạn task

**Mục đích.** Ghi một việc vào một ngày trong vài giây.

**Cấu trúc.** Thành phần theo SRS SCR-01 #1–#9. Thứ tự ưu tiên khi vẽ:
1. Ô tiêu đề (`Input/Multiline`) chiếm gần hết chiều ngang, con trỏ nằm sẵn trong ô.
2. Hàng thuộc tính dưới tiêu đề, dạng chip nhỏ, thứ tự: Ngày · Thời lượng · Channel · Priority · Vị trí. Chip chưa có giá trị chỉ hiện icon, không hiện chữ "Chưa chọn".
3. Nút tạo (`Button/Primary`, nhỏ) ở cuối hàng; người dùng chủ yếu dùng Enter nên nút không cần nổi bật.

Chip có giá trị do AI gợi ý mang dấu ✨ ngay trước giá trị. Dấu ✨ phải phân biệt được bằng hình, không chỉ bằng màu (khả năng truy cập).

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi bằng | Tham chiếu |
|---|---|---|---|---|---|
| S01 | Đóng | Mặc định trên cột ngày | Chỉ có nút "+ Thêm task" (UI-01) ở đầu cột | Bấm nút / phím A → S02 | SRS SCR-02 (G04) #6 |
| S02 | Mở, trống | Vừa mở | Ô tiêu đề trống, placeholder UI-02; chip Ngày = ngày của cột; các chip khác chỉ có icon; nút tạo disabled | Gõ → S03 / S04; Esc → S01 | UC-01 bước 2, E1 |
| S03 | Đang gõ, không có AI | Trợ lý AI tắt, chưa đồng ý, máy không có Claude Code, hoặc tắt gợi ý | Như S02 nhưng nút tạo bật; chip Thời lượng trống; chip Channel "Chưa phân loại" | Enter → tạo task (F-01) | BR-04, BR-05, UC-01 A4 |
| S04 | Đang chờ gợi ý | Đủ điều kiện AI, đã ngừng gõ 400 ms, chưa có kết quả (tối đa 2 giây) | Như S03; chip Thời lượng và Channel có dấu hiệu đang chờ nhẹ `[đề xuất]`. **Enter vẫn tạo được ngay** | Có gợi ý → S05; quá 2 giây / lỗi → S03 | UC-01 bước 4, A4; NFR SRS mục 10 |
| S05 | Có gợi ý | Claude Code trả về | Chip Thời lượng "✨ 30 phút", chip Channel "✨ #Thiết kế" | Sửa một chip → S06 cho chip đó; Enter → tạo | BR-04, US1.3 AC01 |
| S06 | Gợi ý đã bị sửa | Người dùng đổi giá trị chip có ✨ | Chip đó mất ✨, giữ giá trị người dùng chọn; chip kia giữ ✨ | – | US1.3 AC02 |
| S07 | Danh sách channel | Gõ "#" trong tiêu đề, hoặc bấm chip Channel | `Combobox/Channel`: ô tìm, "Chưa phân loại" ở đầu, rồi các channel nhóm theo context; channel ẩn không hiện | Chọn → gán channel, xoá "#..." khỏi tiêu đề; Esc → đóng danh sách, giữ ô soạn | UC-01 A5, BR-14 |
| S08 | Danh sách channel không có kết quả | Từ khoá không khớp | Dòng UI-07; không có lối tạo channel nhanh ở 1.0 `[đề xuất]` | Xoá từ khoá → S07 | Chỗ mở O-06 |
| S09 | Đang đọc tiêu đề từ link | Dán URL vào ô trống | Ô tiêu đề hiện URL, kèm dấu đang tải nhỏ (tối đa 3 giây) | Đọc được → tiêu đề trang thay URL; không đọc được → giữ URL; cả hai về S03 / S05 | UC-01 A1, PRD mục 9 |
| S10 | Tiêu đề quá dài | > 500 ký tự | MSG-01 dưới ô; nút tạo disabled; Enter không tạo | Xoá bớt → S03 | UC-01 E2 |
| S11 | Không ngày (backlog) | Chọn "Không ngày (backlog)" trong chip Ngày | Chip Ngày ghi "Backlog" (UI-05) | Enter → task vào backlog, toast MSG-07 (F-05) | UC-01 A2, BR-02 |
| S12 | Có bản nháp | Người dùng đã gõ rồi Esc, sau đó mở lại ô soạn **của cùng cột** | Như S03 / S05 với nội dung cũ; con trỏ ở cuối tiêu đề | – | UC-01 A3; chỗ mở O-04 |

**Dữ liệu mẫu.**
- Tiêu đề ngắn: "Gọi anh Minh về hợp đồng".
- Tiêu đề dài, có dấu, xuống 3 dòng: "Chuẩn bị tài liệu cho buổi workshop thiết kế với nhóm khách hàng Ngân hàng Á Châu, gồm agenda, bộ câu hỏi phỏng vấn và mẫu ghi chú".
- URL: `https://docs.google.com/document/d/1AbC.../edit` → tiêu đề trang "Kế hoạch quý 4 – Google Tài liệu".
- Channel: "Chưa phân loại"; context `work`: "#Thiết kế", "#Khách hàng ACB", "#Nội bộ"; context `personal`: "#Cá nhân", "#Sức khoẻ". Tên channel dài nhất 50 ký tự.
- Thời lượng: 5 phút, 1 giờ 30 phút, 24 giờ (lớn nhất).

### SCR-N01 Ô thêm nhanh toàn cục

**Mục đích.** Ghi một việc vào hôm nay khi đang ở app khác, không phải mở cửa sổ chính.

**Cấu trúc.** Giống SCR-01 nhưng đứng riêng, không có cột ngày phía sau. Chip Ngày = hôm nay (ngày làm việc, QC-01). Hình thức cửa sổ (vị trí, có viền, có luôn ở trên không) `[chờ #7]`.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi bằng | Tham chiếu |
|---|---|---|---|---|---|
| S01 | Mở | Nhấn Ctrl+Shift+A ở bất kỳ đâu trên Windows | Như SCR-01.S02, có thêm dòng nhỏ "Thêm vào Hôm nay" (UI-08) | Gõ → S02; Esc → đóng, trả focus về app trước đó | US1.1 AC07, D11 |
| S02 | Đang gõ | – | Như SCR-01.S03 – S07 | Enter → S03 | – |
| S03 | Đã thêm | Sau Enter | Dòng xác nhận UI-09 khoảng 1 giây, rồi đóng `[đề xuất]` | Tự đóng | Chỗ mở O-03 |
| S04 | Phím tắt đã tắt | Người dùng tắt phím tắt trong cài đặt (G01 BR-15) | Không mở gì. Không cần vẽ, chỉ ghi để dev biết | – | US1.1 AC07 |

### SCR-02 Task card — phần do tạo và lưu

Card đầy đủ (giờ projection, nhãn "Dời n ngày", hover actions) thuộc brief G04. Bản thử chỉ nêu các trạng thái sinh ra ngay khi tạo hoặc lưu task.

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi bằng | Tham chiếu |
|---|---|---|---|---|---|
| S01 | Vừa tạo | ≤ 100 ms sau Enter (cập nhật lạc quan) | Card ở đầu (hoặc cuối) danh sách; tổng thời lượng của cột cập nhật ngay | Server nhận → card bình thường | BR-03, NFR |
| S02 | Chờ đồng bộ | Mất mạng | Icon "chờ đồng bộ" nhỏ trên card (SRS SCR-02 #8), tooltip UI-10 | Có mạng → gửi lại → S01 | UC-01 E3, QC-08 |
| S03 | Lỗi lưu | Server lỗi 5xx | Icon lỗi trên card, toast MSG-10 có "Thử lại" | Thử lại → S01 | UC-01 E4 |
| S04 | Có giá trị AI | Task tạo với giá trị gợi ý còn giữ | `[đề xuất]` card **không** hiện ✨; ✨ chỉ hiện trong ô soạn và chi tiết task, để card gọn | – | Chỗ mở O-07 |

### SCR-03 Chi tiết task

**Mục đích.** Xem và sửa mọi thông tin của một task; mọi trường lưu ngay khi sửa.

**Cấu trúc.** Từ trên xuống, theo SRS SCR-03 #1–#8:
1. **Header thuộc tính** (`Toolbar`): Channel · Priority · Ngày dự định · Due · "+ Subtask" · … · mở rộng · đóng. Chip chưa có giá trị chỉ hiện icon.
2. **✓ và tiêu đề**: ô ✓ lớn bên trái, tiêu đề sửa tại chỗ. Đây là vùng nổi bật nhất.
3. **Thời gian**: hai số "Thực tế" và "Kế hoạch" đặt cạnh nhau. Bấm "Kế hoạch" mở `Picker/Duration` (ô giờ, ô phút, preset 5 · 10 · 15 · 20 · 25 · 30 · 45 phút · 1 giờ, "Xoá thời lượng").
4. **Subtask**: mỗi dòng ✓ · tiêu đề · thực tế · kế hoạch · icon xoá (chỉ hiện khi hover / focus dòng). Dòng cuối "Thêm subtask". Không thụt cấp.
5. **Notes**: rich text (đậm, nghiêng, danh sách, checklist, link).
6. **Timebox**: chỉ hiện khi có (nội dung thuộc brief G05).
7. **Comment**: ô nhập + danh sách. `[chờ O-09]` có giữ ở 1.0 không.
8. **Nhật ký**: 20 dòng mới nhất, "Xem thêm".

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi bằng | Tham chiếu |
|---|---|---|---|---|---|
| S01 | Đang mở | ≤ 500 ms sau khi bấm | Khung SCR-03 với tiêu đề lấy ngay từ card; phần còn lại dạng khung xám (skeleton) | Có dữ liệu → S02 / S03 | NFR SRS mục 10 |
| S02 | Task mới, tối thiểu | Task chỉ có tiêu đề | Thời gian "Thực tế 0:00 · Kế hoạch —"; channel "Chưa phân loại"; subtask chỉ có dòng "Thêm subtask"; notes placeholder UI-11; nhật ký 1 dòng "Bạn tạo task · vừa xong" | – | – |
| S03 | Task đủ thông tin | Có priority, due, thời lượng, 3–5 subtask, notes | Như cấu trúc; priority khác Normal và due hiện chip trên header | – | US2.3 |
| S04 | Có giá trị AI | Thời lượng / channel nguồn `ai` | Giá trị kèm ✨; tooltip UI-12 | Người dùng sửa → mất ✨ | BR-04, PRD 4.2 |
| S05 | Đang thêm subtask | "+ Subtask" / phím V | Dòng mới trống có con trỏ; Enter lưu và mở dòng kế tiếp; Esc trên dòng trống đóng | – | UC-02 A1 |
| S06 | Subtask đã xong | Tích ✓ một subtask | Dòng gạch / mờ; hover ✓ hiện "Hoàn thành lúc {giờ}" (UI-13). Tích subtask cuối **không** làm task xong | – | UC-02 A2, A10, BR-17 b |
| S07 | Đủ 100 subtask | Thêm subtask thứ 101 | MSG-04 tại dòng "Thêm subtask"; không tạo | – | UC-02 E2 |
| S08 | Vừa xoá subtask | Bấm icon xoá trên dòng | Dòng biến mất ngay; toast MSG-21 ≥ 5 giây | Hoàn tác → dòng về đúng chỗ, đúng trạng thái | UC-02 A8, BR-17 d |
| S09 | Due sớm hơn ngày dự định | Chọn due < ngày dự định | Vẫn lưu; MSG-06 dưới chip Due | Sửa due → hết cảnh báo | UC-02 A6, BR-07 |
| S10 | Due quá hạn | Due < hôm nay, task chưa xong | Chip Due mang màu cảnh báo | – | US2.3 AC03 |
| S11 | Task đã xong | `HOAN_THANH` | ✓ xanh; thời gian "actual / planned"; vẫn thêm subtask được, subtask mới chưa xong và task vẫn xong | Bấm ✓ → bỏ hoàn thành (brief G02 đầy đủ) | BR-17 c, UC-02 A9, QC-07 |
| S12 | Instance lặp | Task thuộc series | Icon lặp cạnh tiêu đề; menu "Khác" có mục lặp (nội dung brief G03) | – | G03 |
| S13 | Bị sửa trên thiết bị khác | Có thay đổi realtime | Trường không đang gõ nhận giá trị mới ngay. Trường đang gõ giữ nguyên, khi rời trường hiện MSG-12 | – | UC-02 A7, QC-08 mục 3 |
| S14 | Bị xoá trên thiết bị khác | Task chuyển `DA_XOA` khi đang mở | Đóng SCR-03; toast `[chờ O-08]` | – | UC-02 E3 |
| S15 | Lưu lỗi | \[TaskUpdate\] lỗi | Trường trả về giá trị cũ; toast MSG-10 | Thử lại | UC-02 E4 |

**Dữ liệu mẫu.**
- Task đủ thông tin: "Chuẩn bị workshop thiết kế ACB" · #Khách hàng ACB · Priority · Thứ Năm 06/11 · Due Thứ Sáu 07/11 · Kế hoạch 2:00 · Thực tế 0:45.
- Subtask: "Viết agenda" (15 phút, xong lúc 09:40), "Soạn bộ câu hỏi phỏng vấn" (45 phút), "In mẫu ghi chú" (10 phút), "Đặt phòng họp tầng 3" (5 phút), "Gửi lịch mời cho anh Minh, chị Hà và nhóm sản phẩm" (5 phút).
- Notes: một đoạn 3 câu, một checklist 3 dòng, một link.
- Nhật ký: "Bạn đổi thời lượng 1:30 → 2:00 · 5 phút trước"; "Trợ lý AI gợi ý channel #Khách hàng ACB · hôm qua"; "Bạn tạo task · hôm qua".

### SCR-04 Menu "Khác"

Mục theo SRS SCR-04: Lặp lại · Nhân bản (Ctrl+D) · Xoá (Ctrl+Backspace) · Sao chép link. Mỗi mục hiện phím tắt bên phải. "Gắn objective" ẩn ở 1.0.

| Mã | Trạng thái | Khi nào | Hiện gì | Tham chiếu |
|---|---|---|---|---|
| S01 | Task thường | – | 4 mục như trên; "Xoá" ở cuối, tách bằng đường kẻ, kiểu nguy hiểm | SRS SCR-04 |
| S02 | Instance lặp | Task thuộc series | "Lặp lại" đổi thành mục sửa series (chữ và nội dung thuộc brief G03) | G03 |

## 5. User flow

### F-01 Ghi nhanh một task vào ngày

**Mở đầu:** board, cột Thứ Năm 06/11, ô soạn đóng. **Kết thúc:** task trên đầu cột, tổng thời lượng cột tăng.

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm "+ Thêm task" trên cột (hoặc chọn cột rồi nhấn A) | SCR-01.S02, ngày = 06/11 |
| 2 | Gõ "Gọi anh Minh về hợp đồng" | SCR-01.S03 (không AI) hoặc S04 → S05 (có AI) |
| 3 | Nhấn Enter | SCR-02.S01 ở đầu cột; ô soạn giữ mở, trống, cho task kế tiếp `[giả định]` |
| 4 | Nhấn Esc | SCR-01.S01 |

Nhánh: tiêu đề trống → nút tạo disabled (UC-01 E1); mất mạng → SCR-02.S02; lỗi → SCR-02.S03.

### F-02 Ghi nhiều task liên tiếp

Như F-01, lặp bước 2–3. Sau mỗi Enter ô soạn trống lại, chip Ngày giữ nguyên, chip Channel và Thời lượng về mặc định (không mang giá trị của task trước) `[đề xuất]`.

### F-03 Tạo task từ link

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Mở ô soạn, dán URL | SCR-01.S09 |
| 2 | – | Tiêu đề trang thay URL; không đọc được trong 3 giây thì giữ URL |
| 3 | Nhấn Enter | Task giữ link nguồn; trên card và chi tiết có icon link, phím G mở link |

### F-04 Gán channel bằng "#"

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Đang gõ tiêu đề, gõ "#kh" | SCR-01.S07, danh sách lọc theo "kh" |
| 2 | ↑/↓ chọn "#Khách hàng ACB", Enter | Chip Channel = "#Khách hàng ACB" (không ✨); "#kh" bị xoá khỏi tiêu đề; con trỏ về tiêu đề |
| 3 | Enter | Tạo task |

Nhánh: không có kết quả → SCR-01.S08.

### F-05 Tạo task vào backlog

Trong ô soạn, mở chip Ngày, chọn "Không ngày (backlog)" → SCR-01.S11 → Enter → task không hiện trên cột; toast MSG-07, bấm "Mở Backlog" mở panel Backlog (brief G06).

### F-06 Ghi nhanh từ bên ngoài app

Đang ở app khác → Ctrl+Shift+A → SCR-N01.S01 → gõ → Enter → SCR-N01.S03 → cửa sổ đóng, focus trả về app trước. Task nằm ở Hôm nay.

### F-07 Mở chi tiết và bổ sung thông tin

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm tiêu đề card (hoặc chọn card rồi Ctrl+Enter) | SCR-03.S01 → S02 / S03 |
| 2 | Bấm "+ Subtask" (hoặc V), gõ "Viết agenda", Enter, gõ tiếp "Soạn câu hỏi", Enter, Esc | SCR-03.S05; mỗi Enter lưu một subtask |
| 3 | Bấm "Kế hoạch", chọn preset 1 giờ | Lưu ngay; tổng cột cập nhật |
| 4 | Mở chip Priority, nhấn 2 | Priority = Priority; chip hiện trên header và card |
| 5 | Mở chip Due, chọn Thứ Sáu | Chip Due hiện; nếu sớm hơn ngày dự định → SCR-03.S09 |
| 6 | Gõ notes | Lưu sau 1 giây ngừng gõ `[giả định]` |
| 7 | Esc hoặc × | Đóng SCR-03, focus về card vừa mở |

### F-08 Xoá subtask và hoàn tác

Hover dòng subtask → bấm icon xoá → SCR-03.S08, toast MSG-21 → bấm "Hoàn tác" trong 5 giây → subtask về đúng vị trí, trạng thái, thời lượng, thời gian thực tế. Toast tắt rồi thì không lấy lại được: subtask không vào Thùng rác (BR-17 d `[giả định]`).

## 6. Case chính và edge case

| Mã | Tình huống | Màn / trạng thái | Hiện gì | Tham chiếu |
|---|---|---|---|---|
| **Dữ liệu** | | | | |
| CASE-01 | Tiêu đề toàn khoảng trắng | SCR-01.S02 | Nút tạo disabled, Enter không làm gì | UC-01 E1 |
| CASE-02 | Tiêu đề 500 ký tự trên card | SCR-02 | Cắt sau 2 dòng bằng "…"; SCR-03 hiện đủ | SRS SCR-02 #2 |
| CASE-03 | Task có 100 subtask | SCR-03 | Card chỉ hiện 5 subtask đầu; chi tiết cuộn được | SRS SCR-02 #4, UC-02 E2 |
| CASE-04 | Channel đã ẩn | SCR-01.S07 | Không có trong danh sách; task cũ vẫn hiện channel đó | US5.1 AC03 |
| **Thời gian** | | | | |
| CASE-05 | Cột ngày đã qua | SCR-01 | `[chờ O-02]`; nếu vẫn mở được ô soạn thì Enter → MSG-20, nội dung giữ trong ô | UC-01 E6, QC-05 |
| CASE-06 | Tạo task lúc 02:00 sáng, mốc đầu ngày 04:00 | SCR-N01 | "Hôm nay" là ngày làm việc hôm trước; dòng UI-08 ghi đúng ngày đó | QC-01 |
| CASE-07 | Đổi ngày dự định trong header sang ngày đã qua | SCR-03 header | Date picker không cho chọn ngày < hôm nay | UC-02 E7 |
| CASE-08 | Đổi ngày instance lặp sang ngày đã có instance cùng series | SCR-03 header | Vẫn đổi; toast MSG-24 | UC-02 A11, QC-06 |
| CASE-17 | Đổi channel sang channel có khung giờ riêng | SCR-03 header | Chỉ đổi chip Channel. Projection, sức chứa của cột tính lại ngay; cách báo "Theo khung #{channel}" trên card thuộc brief G04 | UC-02 A12, BR-23, BR-24 |
| **AI** | | | | |
| CASE-09 | Claude Code chậm > 2 giây | SCR-01.S04 → S03 | Bỏ gợi ý, không báo lỗi; gợi ý về muộn **không** điền vào task đã tạo `[đề xuất]` | UC-01 A4 |
| CASE-10 | Claude Code báo hết hạn mức | SCR-01 | `[chờ O-05]` | UC-01 A4, QC-12 mục 8 |
| CASE-11 | Người dùng nhấn Shift+Q nhận channel gợi ý | SCR-01 / SCR-03 | Giá trị giữ, ✨ `[chờ O-10]` | US5.2 AC02 |
| **Mạng và đồng bộ** | | | | |
| CASE-12 | Tạo task khi offline rồi có mạng | SCR-02.S02 → S01 | Không tạo trùng (cùng idempotency key) | UC-01 E3 |
| CASE-13 | Sửa trường đang gõ dở thì thiết bị khác sửa cùng trường | SCR-03.S13 | MSG-12 khi rời trường | QC-08 mục 3 |
| CASE-14 | Đổi ngày ở header trên phiên bản cũ | SCR-03 | Ngày trả về giá trị server; toast MSG-23 | UC-02 E6 |
| CASE-15 | Lệnh sửa (từ hàng đợi offline) tới task đã bị xoá | SCR-03 / SCR-02 | Toast MSG-22 | UC-02 E5 |
| **Phím tắt** | | | | |
| CASE-16 | Gõ "a" khi không focus ô nhập nào | Board | Mở ô soạn ở cột đang chọn. Gõ nhanh ≥ 4 ký tự / giây ngoài ô nhập thì khoá phím tắt 1 giây | BR-16, G01 BR-15, EC-25 |

## 7. Copy

MSG-xx chép nguyên văn từ SRS G02 mục 9; nguồn vẫn là SRS. UI-xx là chữ mới, đều `[đề xuất]`. Giọng văn chung chờ ticket design system (#8).

| Mã | Nơi hiện | Nội dung (VI) | Biến | Ghi chú |
|---|---|---|---|---|
| UI-01 | Nút trên cột | + Thêm task | – | |
| UI-02 | Placeholder SCR-01 | Gõ tên task hoặc dán link | – | Gộp ý SRS SCR-01 #2 "Dán URL" |
| UI-03 | Chip Thời lượng trống, tooltip | Thời lượng | – | |
| UI-04 | Chip Channel mặc định | Chưa phân loại | – | Tên channel hệ thống (B4) |
| UI-05 | Chip Ngày khi không ngày | Backlog | – | |
| UI-06 | Lựa chọn trong date picker | Không ngày (backlog) | – | Có trong SRS SCR-01 #3 |
| UI-07 | Danh sách channel rỗng | Không có channel "{từ khoá}" | {từ khoá} ≤ 50 ký tự | |
| UI-08 | SCR-N01 | Thêm vào Hôm nay · {thứ, ngày} | {thứ, ngày} = "Thứ Năm 06/11" | |
| UI-09 | SCR-N01 sau Enter | Đã thêm vào Hôm nay | – | |
| UI-10 | Tooltip icon chờ đồng bộ | Chưa đồng bộ. Sẽ gửi khi có mạng | – | |
| UI-11 | Placeholder notes | Ghi chú, link, checklist… | – | |
| UI-12 | Tooltip ✨ | Trợ lý AI gợi ý. Sửa để thay | – | Tên trợ lý chờ D16 và #25; không dùng chữ "Claude" |
| UI-13 | Tooltip ✓ subtask | Hoàn thành lúc {giờ} | {giờ} = "09:40" | Có trong US2.2 AC02 |
| MSG-01 | Inline | Tên task tối đa 500 ký tự | – | |
| MSG-04 | Inline | Mỗi task tối đa 100 subtask | – | |
| MSG-06 | Inline dưới due | Hạn chót sớm hơn ngày dự định | – | |
| MSG-07 | Toast | Đã thêm vào Backlog · Mở Backlog | – | "Mở Backlog" là nút |
| MSG-10 | Toast | Chưa lưu được thay đổi. Thử lại | – | "Thử lại" là nút |
| MSG-12 | Inline | Task vừa được cập nhật trên thiết bị khác | – | |
| MSG-20 | Inline / Toast | Không thể đặt task chưa xong vào ngày đã qua | – | |
| MSG-21 | Toast | Đã xoá subtask "{tiêu đề}" · Hoàn tác | {tiêu đề} ≤ 500 ký tự → cắt "…" | |
| MSG-22 | Toast | Task này đã bị xoá trên thiết bị khác. Thay đổi chưa được lưu | – | |
| MSG-23 | Toast | Task đã thay đổi trên thiết bị khác | – | |
| MSG-24 | Toast | Ngày này đã có {tên series} | – | Dùng G03 MSG-21 |

## 8. Tương tác

**Phím tắt** (phím một ký tự chỉ chạy khi không có ô nhập nào đang focus, BR-16)

| Phím | Ở đâu | Làm gì | Nguồn |
|---|---|---|---|
| A | Board | Mở ô soạn ở cột đang chọn, mặc định hôm nay | UC-01 |
| Ctrl+Shift+A | Mọi nơi trên Windows | Mở SCR-N01 | D11 |
| Enter | SCR-01 | Tạo task | UC-01 |
| Esc | SCR-01 | Đóng, giữ bản nháp | UC-01 A3 |
| # | Tiêu đề trong SCR-01 | Mở danh sách channel | UC-01 A5 |
| Ctrl+Enter | Card đang chọn | Mở SCR-03 | UC-02 |
| V | SCR-03 | Thêm subtask | UC-02 A1 |
| Ctrl+↑ / ↓ | Dòng subtask | Đổi thứ tự | UC-02 A3 |
| 1–4 | Menu priority đang mở | Chọn mức | US2.3 |
| Q / # | Task đang chọn | Mở danh sách channel | US5.2 |
| Shift+Q | Task đang chọn | Nhận channel gợi ý | US5.2 |
| G | Task có link | Mở link | US1.2 |
| Ctrl+D, Ctrl+Backspace | Task đang chọn | Nhân bản, xoá | brief G02 đầy đủ |
| Esc | SCR-03 | Đóng | UC-02 |

**Focus**
- Mở ô soạn: focus vào tiêu đề. Tab đi qua chip theo thứ tự Ngày → Thời lượng → Channel → Priority → Vị trí → nút tạo.
- "Task đang chọn" phải nhìn thấy được (viền hoặc nền), khác với hover. Lý do: phím tắt tác động lên task đang chọn, và trên Sunsama gõ nhầm khi chưa focus đã kích hoạt phím tắt (#22).
- Đóng SCR-03: focus về card vừa mở.

**Thời gian**
- Gợi ý AI gọi sau 400 ms ngừng gõ `[giả định]`, bỏ nếu quá 2 giây (UC-01 bước 4, A4).
- Đọc tiêu đề link: tối đa 3 giây (PRD mục 9).
- Card hiện ≤ 100 ms sau Enter; SCR-03 mở ≤ 500 ms (SRS mục 10).
- Notes lưu sau 1 giây ngừng gõ `[giả định]`.
- Toast có Hoàn tác hiện ≥ 5 giây (BR-17 d, UC-04 bước 3).

**Toast và Hoàn tác:** xoá subtask có Hoàn tác. Quy ước toast dùng chung cho cả app chưa chốt (bản đồ, mục "Not yet specified").

**Khả năng truy cập**
- Icon không chữ (xoá subtask, ✨, chờ đồng bộ, …) cần nhãn cho trình đọc màn hình: "Xoá subtask {tiêu đề}", "Giá trị do trợ lý AI gợi ý", "Chưa đồng bộ".
- Đổi thứ tự subtask làm được bằng phím (Ctrl+↑/↓), không chỉ bằng kéo thả.

## 9. Component dùng trong brief

| Component tạm | Dùng ở | Biến thể / trạng thái cần có |
|---|---|---|
| `Input/Multiline` | Tiêu đề SCR-01, SCR-03 | trống, đang gõ, lỗi, disabled |
| `Chip/Attribute` | Hàng thuộc tính SCR-01, header SCR-03 | chỉ icon, có giá trị, có ✨, cảnh báo |
| `Chip/Channel` | Card, SCR-01, SCR-03 | 12 màu, "Chưa phân loại", tên dài |
| `Combobox/Channel` | SCR-01.S07, chip Channel | có nhóm context, đang tìm, không kết quả |
| `Picker/Date` | Chip Ngày, Due | ngày bị khoá (đã qua), "Không ngày (backlog)" |
| `Picker/Duration` | Chip Thời lượng, "Kế hoạch" | ô giờ + ô phút, preset, "Xoá thời lượng" |
| `Menu/Priority` | Chip Priority | 4 mức, phím 1–4 |
| `Checkbox/Task` | ✓ task, ✓ subtask | chưa xong, xong, hover có tooltip |
| `List/Subtask` | SCR-03 | dòng thường, xong, hover (icon xoá), đang kéo, dòng thêm mới |
| `Editor/RichText` | Notes | trống có placeholder, có nội dung |
| `Toast` | MSG-07, 10, 21, 22, 23, 24 | chỉ chữ, có một nút |
| `Menu/Context` | SCR-04 | mục thường, mục nguy hiểm, phím tắt bên phải |
| `Icon/SyncState` | Card | chờ đồng bộ, lỗi |
| `Badge/AI` | ✨ | – |
| `Skeleton` | SCR-03.S01 | – |

## 10. Tham chiếu nghiệp vụ

| Chủ đề | Nguồn |
|---|---|
| Giới hạn thuộc tính | G02 BR-01, PRD mục 5 |
| Gợi ý AI và điều kiện | G02 BR-04, QC-12 mục 1–2, Q33 |
| Channel mặc định | G02 BR-05, B4 |
| Subtask | G02 BR-17, C9 |
| Trạng thái task | QC-03, SRS G02 mục 4 |
| Đồng bộ, offline | QC-08, G02 BR-19 |
| Ngày làm việc, "hôm nay" | QC-01, G02 BR-20 |
| Đổi ngày | QC-05, QC-06 |
| Phím tắt | G02 BR-16, G01 BR-15, EC-25, D11 |
| Kiểm chứng Sunsama | [`kiem-chung-sunsama-chrome.md`](../research/kiem-chung-sunsama-chrome.md) mục G02; [`sunsama-task-board-backlog.md`](../research/sunsama-task-board-backlog.md) T1–T10 |

## 11. Chỗ còn mở

| Mã | Câu hỏi | Ảnh hưởng tới | Đề xuất của brief | Ai chốt |
|---|---|---|---|---|
| O-01 | Chi tiết task mở ở panel phải, dialog hay cửa sổ riêng? | SCR-03 toàn bộ bố cục | **Đã chốt (IA-06):** dialog giữa màn, có "mở rộng" chiếm vùng chính | [IA](00-kien-truc-thong-tin.md) |
| O-02 | Cột ngày đã qua có nút "Thêm task" không? | SCR-01, CASE-05 | **Đã chốt (IA-20):** không có nút; phím A trên cột đã qua mở ô soạn ở hôm nay | [IA](00-kien-truc-thong-tin.md) |
| O-03 | Ô thêm nhanh toàn cục: hình thức cửa sổ; sau Enter đóng hay giữ để gõ tiếp? | SCR-N01 | **Đã chốt (IA-19):** cửa sổ nổi nhỏ giữa màn hình, luôn ở trên; đóng sau Enter, Shift+Enter để gõ tiếp | [IA](00-kien-truc-thong-tin.md) |
| O-04 | Bản nháp sau Esc: giữ theo từng cột, và mất khi nào (đóng app, sang ngày mới)? | SCR-01.S12 | Mỗi cột một bản nháp, giữ tới khi tạo task hoặc xoá hết chữ | PO, ghi vào SRS G02 |
| O-05 | Claude Code hết hạn mức khi đang gợi ý trong ô soạn: im lặng hay báo? | CASE-10 | Im lặng ở ô soạn; báo một lần ở khu trợ lý AI (brief G10) | PO / brief G10 |
| O-06 | Danh sách channel không có kết quả: có lối "Tạo channel {từ khoá}" không? | SCR-01.S08 | Có, tạo trong context đầu tiên, vì đỡ phải vào Cài đặt | PO, ghi vào SRS G02 |
| O-07 | ✨ có hiện trên card không? | SCR-02.S04 | Không | PO |
| O-08 | Task bị xoá trên thiết bị khác khi đang mở chi tiết: UC-02 E3 ghi MSG-09 ("Đã xoá · Hoàn tác") nhưng câu này nghe như chính người dùng vừa xoá | SCR-03.S14 | Dùng MSG-22 hoặc thêm câu mới "Task này đã bị xoá trên thiết bị khác · Hoàn tác" | PO, sửa SRS G02 |
| O-09 | Giữ comment ở 1.0 không, khi chỉ có một người dùng? | SCR-03 #7 | Bỏ ở 1.0; notes đã đủ | PO (PRD G02 mục 10) |
| O-10 | Shift+Q nhận channel gợi ý: giá trị giữ ✨ (nguồn `ai`) hay mất ✨ (nguồn `user`)? | CASE-11 | Mất ✨, vì người dùng đã chủ động chấp nhận | PO, ghi vào SRS G02 BR-04 |
| O-11 | Ô soạn có hỗ trợ thêm chỉ thị như Sunsama (`~` thời lượng, `@` ngày, `!` priority) không? Ctrl+Enter trong ô soạn có "tạo rồi mở" không? | SCR-01 | Để sau 1.0; 1.0 chỉ có `#` | PO |
| O-12 | Sau Enter, task kế tiếp có mang channel / thời lượng của task trước không? | F-02 | Không mang | PO |

## 12. Kiểm tra trước khi giao

- [x] Mỗi màn ở mục 3 có bảng trạng thái; SCR-01 và SCR-03 có dữ liệu mẫu.
- [ ] Mỗi trạng thái có chữ cho mọi chỗ hiện chữ (còn SCR-03.S14 chờ O-08).
- [x] Mỗi flow ở mục 5 trỏ tới sơ đồ UC trong `flow/` (F-01 … F-06 → UC-01; F-07, F-08 → UC-02).
- [x] Mọi luồng A# / E# của UC-01, UC-02 đều có trong mục 4 hoặc mục 6 (trừ UC-01 E5, chế độ chỉ đọc, bản 1.1).
- [ ] Không còn `[đề xuất]` chưa duyệt ở luồng chính (còn SCR-01.S04, F-02).
- [ ] Chỗ còn mở không chặn luồng chính (O-01 chặn bố cục SCR-03).
