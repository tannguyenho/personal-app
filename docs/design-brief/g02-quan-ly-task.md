# Brief G02 Quản lý task

> **Mã:** PLN-BRIEF-G02 · **Trạng thái:** đã duyệt 10/11/2026 · **Phiên bản:** 1.0
> **Nguồn:** [prd-g02](../features/prd-g02-quan-ly-task.md), [srs-g02](../features/srs-g02-quan-ly-task.md) (commit `2839ede`, đã ghi ngược chốt 10/11/2026), QC-01, QC-03, QC-04, QC-05, QC-07, QC-08, QC-12, QC-13 ([quy tắc dùng chung](../01-quy-tac-dung-chung.md)); quyết định B4, C9, C10, C11, Q12, Q25, Q28, Q33, Q34, D1–D4, D10, D11 ([04/11](../review/quyet-dinh-chot-2026-11-04.md)), F4, F6 ([06/11](../review/quyet-dinh-chot-2026-11-06.md)), A1–A10, C01 ([09/11](../review/cau-hoi-chot-flow-2026-11-09.md)), D01–D09 (10/11)
> **Phụ thuộc:** [kiến trúc thông tin](00-kien-truc-thong-tin.md) (#7, đã duyệt), [nền tảng design system](01-nen-tang-design-system.md) (#8, đã duyệt), brief G03, G04, G05, G06, G07, G10 (chưa viết; G02 chỉ trỏ điểm nối)
> **Flow:** [flow/g02-quan-ly-task.md](flow/g02-quan-ly-task.md) (Mermaid, theo [quy ước](flow/_quy-uoc.md)) · **FigJam:** `[chờ]`
>
> Thay cho [bản thử](_thu-g02-tao-va-chi-tiet-task.md). Các câu O-01 … O-03, O-05 của bản thử đã chốt (IA-06, IA-19, IA-20, G10 BR-30), không hỏi lại; mã O ở mục 11 dưới đây đánh số lại, không trùng nghĩa với bản thử.
>
> **PO duyệt ngày 10/11/2026:** mọi câu O-01 … O-20 ở mục 11 chốt theo đề xuất của brief và đã ghi ngược vào PRD / SRS G02, QC-07, SRS G10, `CONTEXT.md`, nền tảng design system. Hai màn mang mã tạm `SCR-Nxx` (ô thêm nhanh toàn cục, popover chọn channel) thành **SCR-08**, **SCR-09** của SRS G02; chữ thông báo UI-xx thành **MSG-29 … MSG-38** (O-19). Cùng ngày PO duyệt nốt mọi chi tiết `[đề xuất]` còn lại (không thuộc câu O nào), bỏ nhãn; chi tiết hành vi đã ghi vào SRS G02 kèm "(chốt 10/11/2026, brief G02)"; chữ lỗi tên context là MSG-39, MSG-40 (O-17).

## 1. Tóm tắt cho người vẽ

Người dùng ghi một việc bằng cách gõ tên rồi Enter. Ngày lấy theo cột đang đứng. Nếu bật trợ lý AI thì thời lượng và channel được điền sẵn, có dấu ✨. Sau đó người dùng mở task trong dialog để thêm subtask, notes, priority, hạn chót; bấm ✓ khi xong; xoá khi không cần, lấy lại từ Thùng rác trong 30 ngày. Channel phân loại task; mỗi channel có thể có khung giờ riêng.

Ba khoảnh khắc quan trọng nhất:
- **Ghi task ≤ 5 giây** từ lúc mở ô soạn tới Enter (PRD mục 8). Ô soạn không bao giờ chờ AI.
- **Không có nút Lưu.** Sửa ở đâu lưu ở đó; mất mạng thì hiện "Chờ đồng bộ".
- **Không có thao tác mất trắng.** Hoàn thành, xoá task, xoá subtask đều có toast Hoàn tác.

## 2. Phạm vi của brief

**Trong brief**
- Màn: SCR-01 Ô soạn task, SCR-08 Ô thêm nhanh toàn cục, SCR-09 Popover chọn channel, SCR-02 Task card (phần G02), SCR-03 Chi tiết task, SCR-04 Menu "Khác", SCR-05 Thùng rác, SCR-06 Context & channel (gồm khung giờ channel), SCR-07 Xoá channel.
- Flow: F-01 … F-17 (mục 5), phủ UC-01 … UC-06.

**Không trong brief, chỉ ghi điểm nối**

| Phần | Brief | Điểm nối trong G02 |
|---|---|---|
| Cột ngày, nút "Thêm task" trên cột, giờ projection, nhãn "Dự kiến", cờ vượt sức chứa / vượt giờ làm, kéo thả card, đổi chỗ, bộ đếm khối lượng, banner offline, command menu, bảng phím tắt | G04 | SCR-02 chỉ vẽ phần G02 sở hữu (mục 4); tổng cột cập nhật sau mỗi thao tác của G02 |
| Nhãn "Dời {n} ngày", panel / trang Backlog, menu bucket (Z), menu Ngày dự định, panel Lưu trữ, chi tiết task chỉ xem (G06 SCR-08) | G06 | Toast MSG-07 "Mở Backlog"; chip Ngày trong SCR-03 mở menu Ngày dự định G06 SCR-03; tab Thùng rác nằm cạnh tab Lưu trữ |
| Cấu hình lặp, banner series, dấu lặp trên card, menu "Sửa series" | G03 | Mục "Lặp lại" trong SCR-04; SCR-03.S13 |
| Timebox trên card và trong chi tiết | G05 | Vùng #6 của SCR-03 |
| Nút timer, thời gian thực tế (phím E), Focus | G07 | Hover card; "Thực tế" trong SCR-03 chỉ hiển thị |
| Đồng ý dùng AI, cài đặt trợ lý (gồm công tắc "Gợi ý channel", "Gợi ý thời lượng"), nội dung khi bấm chip "AI", Hoạt động AI, khung chat | G10 | Dấu ✨ (SCR-01, SCR-03); chip "AI" trên card (SCR-02.S10) |
| Cài đặt "Vị trí task mới", "Tính planned là actual", "Phím tắt", hiệu ứng chúc mừng, lịch làm việc chung | G01 | Giá trị mặc định cho SCR-01, SCR-02, SCR-06 |

**Bản sau, không vẽ (QC-13 mục 6: ẩn hẳn, không hiện mờ):** ô Objective trong ô soạn (SCR-01 #6) và mục "Gắn objective" (SCR-04 #2), G09 bản 1.1; MSG-11 và luồng chỉ đọc UC-01 E5 (1.1); đính kèm file (1.1); `LINKED_TASK` khi AI hoàn thành / xoá task có liên kết tích hợp (1.1, G11); giao task, follow, quyền channel (1.2). Người vẽ không cần chừa chỗ, trừ hàng chip của ô soạn (thêm được một chip sau).

**Khác Sunsama có chủ đích, người vẽ cần biết** ([kiểm chứng](../research/kiem-chung-sunsama-chrome.md) mục G02)

| App | Sunsama | Nguồn |
|---|---|---|
| Esc trong ô soạn **giữ** bản nháp | Bỏ bản nháp | US1.1 AC04 |
| Không bật trợ lý AI thì **không có** gợi ý, không có dấu ✨ | Vẫn gợi ý (chấm cam) khi tắt AI | Q33, #23-S11 |
| Hoàn thành có toast **Hoàn tác** | Hoàn thành không có toast | PRD 4.3, #22-C3 |
| Xoá subtask có toast Hoàn tác | Chỉ xoá task có Hoàn tác | C9, #22-C3 |
| Bỏ hoàn thành trong cùng ngày làm việc trả lại subtask, ngày cũ | Subtask không trở lại | Q25, #22-C1 |
| Hoàn thành instance lặp ở ngày tương lai giữ ngày đó | Về hôm nay | Q12, #22-C2 |
| Thùng rác giữ 30 ngày, nút "Khôi phục" trên dòng | 7 ngày, chuột phải → Restore | Q28, #22-C4 |
| "Task đang chọn" luôn nhìn thấy được, khác hover; phím một ký tự không chạy khi đang gõ | Gõ khi ô chưa nhận focus thì chạy nhầm phím tắt | G04 BR-17, #22 |

## 3. Danh sách màn hình

| Mã | Màn | Bề mặt (IA) | Điểm vào | Số trạng thái | Ưu tiên vẽ |
|---|---|---|---|---|---|
| SCR-01 | Ô soạn task | Inline trên cột ngày (đầu hoặc cuối danh sách) | Nút "Thêm task" trên cột ngày ≥ hôm nay; phím A; command menu "Thêm task" | 11 | P1 |
| SCR-08 | Ô thêm nhanh toàn cục | Cửa sổ riêng: nổi nhỏ, không viền, giữa màn hình đang dùng, luôn ở trên (IA-19) | Ctrl+Shift+A ở bất kỳ đâu trên Windows; menu khay "Thêm task" | 7 | P2 |
| SCR-09 | Popover chọn channel | Popover | Gõ "#" trong tiêu đề (SCR-01, SCR-08); chip Channel (SCR-01, SCR-08, SCR-03); phím Q / # trên task đang chọn | 4 | P1 |
| SCR-02 | Task card (phần G02) | Trên cột ngày, Today view, panel Tasks (G04) | Sau khi tạo; mở board | 10 | P1 |
| SCR-03 | Chi tiết task | Dialog giữa màn, có "mở rộng" chiếm vùng chính (IA-06) | Bấm tiêu đề card; Ctrl+Enter; chip task trong chat (G10); bản sao sau khi nhân bản | 19 | P1 |
| SCR-04 | Menu "Khác" | Popover | Nút … trên header SCR-03; nút … khi hover card (G03 UC-02 bước 1); chuột phải trên card (O-11) | 2 | P2 |
| SCR-05 | Thùng rác | Tab "Thùng rác" của panel "Lưu trữ · Thùng rác" ở panel phải (IA-09) | Panel phải → Lưu trữ · Thùng rác → tab Thùng rác; Ctrl+K "Task đã xoá gần đây" | 7 | P2 |
| SCR-06 | Context & channel | Nhóm "Context & channel" trong lớp phủ Cài đặt (G01 SCR-06 #3) | Cài đặt → Context & channel; "Quản lý channel" trong bộ lọc (G04 SCR-06 #4) và trong SCR-09 | 12 | P2 |
| SCR-07 | Xoá channel | Dialog xác nhận nhỏ | Icon xoá trên dòng channel (SCR-06) | 4 | P3 |

**Tổng:** 9 màn, 76 trạng thái. SCR-08 và SCR-09 là mã SRS G02 mới, ghi ngược từ mã tạm `SCR-Nxx` của bản chờ duyệt (O-19).

## 4. Màn hình và trạng thái

### SCR-01 Ô soạn task

**Mục đích.** Ghi một việc vào một ngày trong vài giây.

**Cấu trúc.** Thành phần theo SRS SCR-01 #1–#9 (bỏ #6 Objective, 1.1). Thứ tự ưu tiên khi vẽ:
1. **Ô tiêu đề** (`Input/Multiline`) chiếm gần hết chiều ngang, con trỏ nằm sẵn trong ô. Xuống dòng tự động, không giới hạn số dòng hiển thị.
2. **Hàng chip thuộc tính** dưới tiêu đề, thứ tự: Ngày · Thời lượng · Channel · Priority · Vị trí. Chip chưa có giá trị chỉ hiện icon (tooltip UI-03 … UI-07), không hiện chữ "Chưa chọn". Ngoại lệ: chip Ngày luôn có giá trị; chip Channel luôn có giá trị (mặc định "Chưa phân loại", BR-05).
3. **Nút "Thêm"** (UI-10, `Button` `variant=primary` `size=sm`) cuối hàng chip. Người dùng chủ yếu nhấn Enter nên nút không cần nổi bật hơn tiêu đề.

Chip có giá trị do AI gợi ý mang dấu ✨ (`Badge/AI`) ngay trước giá trị. ✨ là icon, không nằm trong chữ (QC-13 mục 4), và phải phân biệt được bằng hình, không chỉ bằng màu (DS-08). Ô soạn chỉ hiểu một ký hiệu là "#" (chọn channel); không có cú pháp khác.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì (khác trạng thái mặc định ở đâu) | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-01.S01 | Đóng | Mặc định trên cột ngày ≥ hôm nay | Chỉ có nút "Thêm task" (UI-01, kèm icon dấu cộng). Cột ngày đã qua **không** có nút | Bấm nút / phím A → S02 hoặc S10 | G04 SCR-02 #6, IA-20 |
| SCR-01.S02 | Mở, trống | Vừa mở bằng nút, phím A, command menu. Phím A khi cột đang chọn là ngày đã qua: board cuộn tới cột hôm nay, ô soạn mở ở cột hôm nay (giống hệt, chỉ khác cột) | Ô tiêu đề trống, placeholder UI-02; chip Ngày = ngày của cột ("Hôm nay" hoặc "Thứ Năm 12/11"); chip Thời lượng, Priority chỉ có icon; chip Channel "Chưa phân loại"; chip Vị trí theo cài đặt "Vị trí task mới" (G01). Nút "Thêm" `disabled`; Enter không làm gì (E1) | Gõ → S03 hoặc S04; dán URL → S07; Esc khi trống → S01 | UC-01 bước 2, A6, E1 |
| SCR-01.S03 | Đang gõ, không có gợi ý AI | Một trong các điều kiện A4: trợ lý AI tắt, chưa đồng ý, máy không có Claude Code, tắt gợi ý, Claude Code lỗi / chậm > 2 giây / báo hết hạn mức | Như S02 nhưng nút "Thêm" bật. Chip Thời lượng trống (chỉ icon), chip Channel "Chưa phân loại". **Không** báo lỗi gì về AI | Enter → tạo (F-01); gõ "#" → SCR-09; Esc → S01 (giữ nháp, A3) | UC-01 A4, BR-04, BR-05, G10 BR-30 |
| SCR-01.S04 | Đang chờ gợi ý | Đủ điều kiện BR-04, đã ngừng gõ 400 ms, chưa có kết quả (tối đa 2 giây) | Như S03; chip Thời lượng và Channel có dấu đang chờ nhẹ (nhãn đọc màn hình UI-11). **Enter vẫn tạo được ngay**, không chờ | Có gợi ý → S05; quá 2 giây / lỗi → S03; gõ tiếp → chờ lại | UC-01 bước 4, A4; SRS mục 10 |
| SCR-01.S05 | Có gợi ý | Claude Code trả về | Chip Thời lượng "✨ 0:30", chip Channel "✨ #Thiết kế"; tooltip ✨ UI-12. Gợi ý không bao giờ ghi đè chip người dùng đã chọn trước đó (giữ nguồn `user`) | Sửa một chip → S06 cho chip đó; Enter → tạo | BR-04, US1.3 AC01 |
| SCR-01.S06 | Gợi ý đã bị sửa | Người dùng đổi giá trị chip có ✨ | Chip đó mất ✨, giữ giá trị người dùng chọn; chip còn lại giữ ✨ | – | US1.3 AC02 |
| SCR-01.S07 | Đang đọc tiêu đề từ link | Dán URL vào ô | Ô tiêu đề hiện URL, cạnh đó dấu đang tải nhỏ (nhãn UI-13), tối đa 3 giây | Đọc được → tiêu đề trang thay URL; không đọc được → giữ URL; cả hai về S03 / S05. Enter trong lúc đọc → tạo với URL làm tiêu đề | UC-01 A1, PRD mục 9 |
| SCR-01.S08 | Tiêu đề quá dài | > 500 ký tự sau khi cắt khoảng trắng | MSG-01 dưới ô (kiểu lỗi, kèm icon); nút "Thêm" `disabled`; Enter không tạo | Xoá bớt → S03 / S05 | UC-01 E2, BR-01 |
| SCR-01.S09 | Không ngày (backlog) | Chọn "Không ngày (backlog)" (UI-09) trong chip Ngày | Chip Ngày ghi "Backlog" (UI-08); chip Vị trí ẩn (vị trí trong backlog theo G06) | Enter → task vào backlog, toast MSG-07 (F-05) | UC-01 A2, BR-02 |
| SCR-01.S10 | Có bản nháp | Người dùng đã gõ rồi Esc / bấm ra ngoài, sau đó mở lại ô soạn **của cùng ngày** (kể cả sau khi đóng app). Ngày của bản nháp đã thành ngày đã qua: bản nháp hiện ở ô soạn hôm nay | Như S03 / S05 với nội dung và chip cũ; con trỏ ở cuối tiêu đề | Tạo task hoặc xoá hết chữ → hết bản nháp | UC-01 A3; O-02 |
| SCR-01.S11 | Ngày đã qua khi gửi | Ô soạn mở trước mốc đầu ngày, Enter sau mốc; server trả `PAST_DATE` | MSG-20 dưới ô; chip Ngày ở kiểu cảnh báo; nội dung còn nguyên; card lạc quan (nếu đã hiện) bị gỡ | Đổi chip Ngày (picker chỉ cho ≥ hôm nay) rồi Enter → tạo | UC-01 E6, QC-05 |

**Dữ liệu mẫu.**
- Tiêu đề ngắn: "Gọi anh Minh về hợp đồng".
- Tiêu đề dài, có dấu, xuống 3 dòng ở cột 240 px (130 ký tự): "Chuẩn bị tài liệu cho buổi workshop thiết kế với nhóm khách hàng Ngân hàng Á Châu, gồm agenda, bộ câu hỏi phỏng vấn và mẫu ghi chú". Thử cả bản lặp câu này tới đủ 500 ký tự và 501 ký tự (S08).
- Kiểm tra dấu: "Ếch ỗng Ữ Ặ kiểm tra dấu chồng hai tầng" ở cỡ chữ của ô soạn và của chip.
- URL: `https://docs.google.com/document/d/1AbCdEfGhIjKlMnOpQrStUvWxYz/edit` → tiêu đề trang "Kế hoạch quý 4 – Google Tài liệu".
- Chip Ngày: "Hôm nay", "Thứ Năm 12/11", "Backlog". Thời lượng: "0:05", "1:30", "24:00" (lớn nhất).
- Channel: "Chưa phân loại"; "#Thiết kế"; dài nhất 50 ký tự "#Dự án chuyển đổi số Ngân hàng Á Châu giai đoạn hai" (chip cắt "…" sau khoảng 20 ký tự, tooltip hiện đủ).
- Priority: Urgent, Priority, Low (Normal không hiện chữ trên chip, chỉ icon).

### SCR-08 Ô thêm nhanh toàn cục

**Mục đích.** Ghi một việc vào hôm nay khi đang ở app khác, không phải mở cửa sổ chính.

**Cấu trúc.** Cửa sổ nổi nhỏ (`Panel/QuickAdd`), không viền, bo `radius/lg`, có `shadow/overlay` (DS-15). Từ trên xuống:
1. Dòng nhỏ UI-14 "Thêm vào Hôm nay · Thứ Ba 10/11".
2. Ô tiêu đề như SCR-01 (placeholder UI-02).
3. Hàng chip **Thời lượng · Channel · Priority**. Không có chip Ngày (luôn hôm nay) và chip Vị trí (theo cài đặt).
4. Dòng gợi ý phím UI-16, chữ phụ.

Không có nút "Thêm": cửa sổ chỉ dùng bằng phím. Gợi ý AI, "#", dán URL chạy như SCR-01.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-08.S01 | Mở, trống | Ctrl+Shift+A ở bất kỳ đâu trên Windows, kể cả khi cửa sổ chính ở khay | Cấu trúc như trên, ô tiêu đề có focus. "Hôm nay" là ngày làm việc (QC-01): lúc 02:00, mốc 04:00 thì dòng UI-14 ghi ngày hôm trước | Gõ → S03; Esc / bấm ra ngoài → đóng, trả focus về app trước | UC-01 A7, IA-19 |
| SCR-08.S02 | Có bản nháp | Mở lại sau khi đã gõ rồi đóng | Như S03 với nội dung cũ, con trỏ ở cuối | – | UC-01 A7 |
| SCR-08.S03 | Đang gõ | – | Như SCR-01.S03 … S07 (không có AI / chờ / có gợi ý / đã sửa / đọc link); "#" mở SCR-09 ngay dưới ô | Enter → S05; Shift+Enter → S06 | UC-01 A7 |
| SCR-08.S04 | Tiêu đề quá dài | > 500 ký tự | MSG-01 dưới ô; Enter, Shift+Enter không làm gì. Tiêu đề trống: Enter không làm gì, không có chữ báo (E1) | Xoá bớt → S03 | UC-01 A7, E1, E2 |
| SCR-08.S05 | Đã thêm, đóng | Sau Enter | Thay toàn bộ nội dung bằng icon dấu tích + MSG-29 "Đã thêm vào Hôm nay" khoảng 1 giây, rồi cửa sổ đóng, focus về app trước. Cửa sổ chính ở khay thì vẫn ở khay. Mất mạng vẫn hiện như vậy (task vào hàng đợi) | Tự đóng | UC-01 A7, flow E3 |
| SCR-08.S06 | Đã thêm, giữ mở | Sau Shift+Enter | Ô tiêu đề trống lại, chip về mặc định; dòng MSG-29 hiện thay dòng UI-14 khoảng 1 giây rồi trả lại | Gõ task kế tiếp → S03 | UC-01 A7 |
| SCR-08.S07 | Phím tắt đã tắt | Người dùng tắt "Phím tắt" (G01 BR-15) | Không mở gì. **Không vẽ**, chỉ ghi để dev biết | – | US1.1 AC07 |

**Dữ liệu mẫu.** Dòng UI-14: "Thêm vào Hôm nay · Thứ Ba 10/11" và dài nhất "Thêm vào Hôm nay · Chủ Nhật 15/11". Tiêu đề: "Trả lời email chị Hà về báo giá", "Ếch ỗng Ữ Ặ kiểm tra dấu chồng hai tầng", tiêu đề 130 ký tự ở mục SCR-01 (cửa sổ cao lên theo nội dung, tối đa 5 dòng rồi cuộn).

### SCR-09 Popover chọn channel

**Mục đích.** Gán channel cho task bằng bàn phím hoặc chuột, trong ô soạn hoặc trên task có sẵn.

**Cấu trúc.** `Combobox/Channel` mở ngay dưới chỗ gọi:
1. Ô tìm (`Input/Text`, placeholder UI-17). Mở từ "#" trong tiêu đề thì ô tìm ẩn, chữ sau "#" chính là từ khoá.
2. "Chưa phân loại" ở đầu, không thuộc context nào (BR-14, O-07).
3. Các channel nhóm theo context (tên context là tiêu đề nhóm). Mỗi dòng: chấm màu + "#tên". Channel đang gán có icon dấu tích bên phải. Channel ẩn không có trong danh sách.

↑/↓ chọn, Enter gán, Esc đóng popover và giữ ô soạn / task như cũ.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-09.S01 | Đầy đủ | Bấm chip Channel; phím Q / # trên task đang chọn; gõ "#" chưa kèm chữ | Như cấu trúc; dòng đang gán được chọn sẵn | Gõ từ khoá → S02; Enter / bấm dòng → gán, đóng | UC-01 A5, US5.2 AC01 |
| SCR-09.S02 | Đang lọc | Có từ khoá ("#kh" trong tiêu đề, hoặc gõ vào ô tìm) | Chỉ dòng khớp, phần khớp in đậm; so khớp không phân biệt hoa thường và dấu; nhóm context không còn dòng nào thì ẩn | Enter → gán; với "#…" trong tiêu đề: xoá "#…" khỏi tiêu đề, con trỏ về tiêu đề. Chip Channel không có ✨ (nguồn `user`) | UC-01 A5 |
| SCR-09.S03 | Không có kết quả | Từ khoá không khớp channel nào | Dòng UI-18 và link "Quản lý channel" (UI-19) mở SCR-06. Không có lối tạo channel nhanh ở 1.0 (O-14) | Xoá bớt từ khoá → S02; Esc → đóng, "#…" giữ nguyên trong tiêu đề | O-14 |
| SCR-09.S04 | Task đang ở channel đã ẩn | Mở từ task có channel đã ẩn | Channel đó hiện ở đầu (trên "Chưa phân loại"), có nhãn "Đã ẩn" (UI-20) và dấu tích; channel ẩn khác vẫn không hiện | Chọn channel khác → gán | UC-06 A2, US5.1 AC03 |

**Dữ liệu mẫu.** "Chưa phân loại"; context `work`: "#Thiết kế", "#Khách hàng ACB", "#Nội bộ", "#Dự án chuyển đổi số Ngân hàng Á Châu giai đoạn hai" (50 ký tự, cắt "…" theo chiều rộng popover, tooltip đủ); context `personal`: "#Cá nhân", "#Sức khoẻ", "#Ếch ỗng Ữ Ặ". Danh sách dài nhất để thử cuộn: 5 context, 40 channel. Từ khoá không khớp: "#kế toán nội bộ quý bốn".

### SCR-02 Task card (phần G02)

**Mục đích.** Cho thấy một task trên cột ngày; thao tác nhanh mà không mở chi tiết.

**Cấu trúc.** Card đầy đủ (`Card/Task`) thuộc brief G04. G02 sở hữu các thành phần SRS SCR-02 #2–#8, #11, #12; thứ tự ưu tiên thông tin:
1. **Tiêu đề** (#2), tối đa 2 dòng rồi cắt "…"; bấm mở SCR-03.
2. **Thời lượng** (#3, `Badge/Duration`): "1:30" hoặc "0:45 / 1:30" khi đã có thời gian thực tế. Ở hàng đầu cùng giờ projection (G04).
3. **Hàng chip phụ:** priority (khi khác Normal), due (khi có, UI-25), channel (chấm màu + "#tên", luôn có), icon link khi task có link nguồn (SRS SCR-02 #12, O-05).
4. **Subtask** (#4): tối đa 5 dòng, mỗi dòng ✓ bấm được + tiêu đề 1 dòng.
5. **Icon trạng thái** (#8 đồng bộ, #11 chip "AI") ở góc, không chen vào tiêu đề.

Phần G04 / G06 / G03 / G05 / G07 trên cùng card (giờ projection, "Dời {n} ngày", dấu lặp, badge giờ timebox, nút timer) chỉ chừa chỗ, không vẽ trong brief này.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-02.S01 | Kế hoạch, tối thiểu | Task `KE_HOACH` chỉ có tiêu đề | Tiêu đề, chip "Chưa phân loại"; không có badge thời lượng. Hiện ≤ 100 ms sau Enter (cập nhật lạc quan), ở đầu hoặc cuối danh sách theo chip Vị trí | – | SRS 4.1, BR-03 |
| SCR-02.S02 | Đủ thông tin | Có thời lượng, priority, due, ≤ 5 subtask | Như cấu trúc; subtask đã xong gạch / mờ | – | US2.3 AC02, AC03 |
| SCR-02.S03 | Nhiều subtask | > 5 subtask | 5 subtask đầu, rồi dòng UI-21 "Còn {n} subtask" (bấm mở SCR-03) | – | SRS SCR-02 #4 |
| SCR-02.S04 | Hover | Chuột trên card | Hiện hover actions: ✓ (UI-22), notes (UI-23), thời lượng (UI-04), priority (UI-06), … (UI-24, mở SCR-04, O-11); nút timer của G07 | Rời chuột → S01 / S02 | SRS SCR-02 #7, G03 UC-02 bước 1 |
| SCR-02.S05 | Đang chọn | ↑/↓ trên board, bấm vùng trống của card, hoặc vừa đóng SCR-03 | Viền / nền "đang chọn" (token nhấn), **khác với hover**; phím tắt (C, Q, G, Ctrl+D, Ctrl+Backspace, Ctrl+Enter) tác động lên card này | Chọn card khác / Esc | G04 BR-10, BR-17, DS-01 |
| SCR-02.S06 | Due quá hạn | Due < hôm nay, task chưa xong | Chip due kiểu nguy hiểm, có icon cảnh báo (không chỉ màu), nhãn đọc màn hình UI-26 | Sửa due / hoàn thành | US2.3 AC03, DS-08 |
| SCR-02.S07 | Hoàn thành | `HOAN_THANH` | Card mờ, ✓ màu thành công, thời lượng "actual / planned" (ví dụ "0:02 / 1:30"); subtask đều đã tích. Task thường nằm ở cột hôm nay; instance lặp ở cột cũ. Hover ✓ đổi tooltip thành "Bỏ đánh dấu xong" | Bấm ✓ / C → bỏ hoàn thành (F-10) | SRS 4.1, BR-08, QC-07 mục 5 |
| SCR-02.S08 | Chờ đồng bộ | Thao tác khi mất mạng (tạo, sửa, hoàn thành, nhân bản) | Icon "Chờ đồng bộ" (`Icon/SyncState`) ở góc card, tooltip MSG-30 | Có mạng, gửi thành công → trạng thái trước; xung đột → CASE-29 | UC-01 E3, UC-02 E8, UC-05 E2, QC-08 mục 7 |
| SCR-02.S09 | Lỗi lưu | \[TaskCreate\] / \[TaskUpdate\] lỗi 5xx sau khi thử lại | Icon lỗi ở góc card, tooltip QC-MSG-01; toast MSG-10 có nút "Thử lại". Bấm icon cũng là thử lại | Thử lại thành công → trạng thái trước | UC-01 E4, QC-13 mục 1 |
| SCR-02.S10 | Do AI thay đổi | Thay đổi gần nhất do trợ lý AI (tạo, sửa, hoàn thành) | Chip "AI" (`Chip/AI`, màu AI, có chữ "AI"); bấm mở phần Hoàn tác của G10 | Người dùng sửa task / hết hạn hoàn tác (G10 BR-07) | SRS SCR-02 #11, QC-12 mục 5 |

**Dữ liệu mẫu.**
- Card tối thiểu: "Gọi anh Minh về hợp đồng" · "#Chưa phân loại".
- Card đủ: "Chuẩn bị workshop thiết kế ACB" · 2:00 · Priority · "Hạn 13/11" · "#Khách hàng ACB" · 3 subtask (1 đã xong).
- Tiêu đề 130 ký tự ở SCR-01 (cắt sau 2 dòng); "Ếch ỗng Ữ Ặ kiểm tra dấu chồng hai tầng" (dòng 2 không bị cắt dấu).
- Thời lượng lớn nhất: "24:00"; actual lớn hơn planned: "31:40 / 24:00".
- Subtask nhiều nhất: 100 → "Còn 95 subtask".
- Channel 50 ký tự (cắt "…" theo chiều rộng card).

### SCR-03 Chi tiết task

**Mục đích.** Xem và sửa mọi thông tin của một task; mọi trường lưu ngay khi sửa.

**Cấu trúc.** Dialog (`Dialog`, kích thước thường và mở rộng). Từ trên xuống, theo SRS SCR-03 #1–#9:
1. **Header thuộc tính** (thanh `Chip/Attribute`): Channel · Priority · Ngày dự định · Hạn chót · "Subtask" (UI-30) · … (SCR-04) · mở rộng · đóng. Chip chưa có giá trị chỉ hiện icon. Chip Ngày dự định mở menu Ngày dự định của G06 (G06 SCR-03). Icon "Chờ đồng bộ" nằm ở đây khi có (S18).
2. **Banner series** của G03 (chỉ với instance lặp, S13).
3. **✓ và tiêu đề**: ô ✓ lớn bên trái, tiêu đề sửa tại chỗ. **Vùng nổi bật nhất.** Dưới tiêu đề: dòng link nguồn (tên miền + icon) khi có (SRS SCR-03 #9, S14).
4. **Thời gian**: "Thực tế" và "Kế hoạch" (UI-32) cạnh nhau, số `tnum`. Bấm "Kế hoạch" mở `Picker/Duration` (ô giờ, ô phút, preset 5 · 10 · 15 · 20 · 25 · 30 · 45 phút · 1 giờ, "Xoá thời lượng"; chữ UI-34). "Thực tế" chỉ hiển thị; sửa thời gian thực tế thuộc G07 (phím E).
5. **Subtask** (`List/Subtask`): mỗi dòng ✓ · tiêu đề · thực tế · kế hoạch · icon xoá (chỉ hiện khi hover / focus dòng). Dòng cuối "Thêm subtask" (UI-31). Không thụt cấp.
6. **Notes** (`Editor/RichText`): đậm, nghiêng, danh sách, checklist, link; placeholder UI-35.
7. **Timebox** (G05 SCR-06 #2), chỉ hiện khi có.
8. **Comment**: ô nhập (placeholder UI-36) + danh sách mới nhất ở dưới cùng; mỗi comment: avatar, tên, giờ, nội dung (O-04).
9. **Nhật ký**: dòng theo mẫu UI-38, 20 dòng mới nhất trước, "Xem thêm" (UI-39).

Tiêu đề các mục Subtask, Notes, Comment, Nhật ký: UI-37. Dòng do AI có nút "Hoàn tác" (G10 UC-04 bước 1).

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-03.S01 | Đang mở | ≤ 500 ms sau khi bấm | Khung dialog, tiêu đề lấy ngay từ card; phần còn lại là `Skeleton` | Có dữ liệu → S02 / S03; lỗi tải → QC-MSG-02 trong thân dialog, "Thử lại" bấm được (QC-13 mục 1) | SRS mục 10, QC-13 mục 1 |
| SCR-03.S02 | Task mới, tối thiểu | Task chỉ có tiêu đề; cũng là bản sao vừa nhân bản mà không có subtask | "Thực tế 0:00 · Kế hoạch Chưa đặt" (UI-33); chip Channel "Chưa phân loại"; Subtask chỉ có dòng "Thêm subtask"; notes placeholder; nhật ký 1 dòng "Bạn tạo task · vừa xong" (bản sao: "Bạn nhân bản từ "{tiêu đề}" · vừa xong") | – | UC-02, UC-05 bước 3 |
| SCR-03.S03 | Task đủ thông tin | Có priority, due, thời lượng, 3–5 subtask, notes, comment, nhật ký > 20 dòng | Như cấu trúc; chip Priority, Hạn chót có giá trị; "Xem thêm" cuối nhật ký tải thêm 20 dòng | – | US2.3, UC-02 A4, A5 |
| SCR-03.S04 | Có giá trị AI | Thời lượng / channel nguồn `ai` | Giá trị kèm ✨, tooltip UI-12; nhật ký có dòng "Trợ lý AI gợi ý channel #…" | Người dùng sửa → mất ✨ | BR-04, PRD 4.2 |
| SCR-03.S05 | Đang thêm subtask | Bấm "Subtask" / phím V / bấm "Thêm subtask" | Dòng mới trống có con trỏ ở cuối danh sách; Enter lưu và mở dòng kế tiếp; Esc trên dòng trống đóng dòng | Esc / bấm ra ngoài | UC-02 A1 |
| SCR-03.S06 | Subtask đã xong | Tích ✓ một subtask | Dòng gạch / mờ; hover ✓ hiện UI-40 "Hoàn thành lúc 09:40". Tích subtask cuối cùng **không** làm task xong: ✓ lớn vẫn rỗng | Bỏ tích → dòng thường | UC-02 A2, A10, BR-17 b |
| SCR-03.S07 | Đủ 100 subtask | Thêm subtask thứ 101 | MSG-04 ngay tại dòng "Thêm subtask"; không tạo; nút "Subtask" trên header `disabled` | Xoá một subtask → hết | UC-02 E2 |
| SCR-03.S08 | Vừa xoá subtask | Bấm icon xoá trên dòng | Dòng thu lại và biến mất ngay; toast MSG-21 ≥ 5 giây | Hoàn tác → dòng hiện lại đúng chỗ, đúng trạng thái, thời lượng, thời gian thực tế; toast tắt → không lấy lại được | UC-02 A8, BR-17 d |
| SCR-03.S09 | Lỗi tại trường | Tiêu đề > 500 ký tự (MSG-01); ô giờ / phút ngoài 1 phút – 24 giờ (MSG-02); notes > 50.000 ký tự hoặc comment > 5.000 ký tự (MSG-03) | Chữ lỗi dưới đúng trường, trường viền lỗi; **không gửi**, giá trị đã lưu trước đó giữ nguyên | Sửa lại hợp lệ → lưu | UC-02 E1, BR-01 |
| SCR-03.S10 | Due sớm hơn ngày dự định | Chọn due < ngày dự định | Vẫn lưu; MSG-06 dưới chip Hạn chót, kiểu cảnh báo | Sửa due / ngày dự định → hết | UC-02 A6, BR-07 |
| SCR-03.S11 | Due quá hạn | Due < hôm nay, task chưa xong | Chip Hạn chót kiểu nguy hiểm, có icon (như SCR-02.S06) | Sửa due / hoàn thành | US2.3 AC03 |
| SCR-03.S12 | Task đã xong | `HOAN_THANH` | ✓ lớn màu thành công; "Thực tế 0:02 · Kế hoạch 1:30" theo QC-07 mục 5 (kể cả `plannedAsActual`); subtask đều đã tích. Vẫn thêm subtask được: subtask mới chưa xong, task vẫn xong | Bấm ✓ / C → bỏ hoàn thành (F-10) | BR-08, BR-17 c, UC-02 A9 |
| SCR-03.S13 | Instance lặp | Task thuộc series | Banner series (G03 SCR-02) trên tiêu đề; mục "Lặp lại" của SCR-04 đổi theo G03 | – | G03 |
| SCR-03.S14 | Có link nguồn | Task tạo từ URL | Dòng dưới tiêu đề: icon link + tên miền ("docs.google.com"), tooltip UI-28; bấm hoặc phím G mở link | – | US1.2 AC02; SRS SCR-03 #9; O-05 |
| SCR-03.S15 | Bị sửa trên thiết bị khác | Có thay đổi realtime | Trường không đang gõ nhận giá trị mới ngay, không báo. Trường đang gõ giữ nguyên; khi rời trường hiện MSG-12 dưới trường đó | – | UC-02 A7, QC-08 mục 3 |
| SCR-03.S16 | Bị xoá trên thiết bị khác | Task chuyển `DA_XOA` khi đang mở | Dialog đóng, focus về board; toast MSG-38 có "Hoàn tác" (không dùng MSG-09) | Hoàn tác → task về như trước khi xoá | UC-02 E3; O-01 |
| SCR-03.S17 | Lưu lỗi | \[TaskUpdate\] lỗi | Trường vừa sửa trả về giá trị cũ; toast MSG-10 có "Thử lại" | Thử lại | UC-02 E4 |
| SCR-03.S18 | Chờ đồng bộ | Sửa khi mất mạng; bản sao vừa nhân bản khi mất mạng (F-13) | Giá trị mới hiện ngay; icon "Chờ đồng bộ" (MSG-30) trên header dialog và trên card | Có mạng → mất icon; xung đột → CASE-29; task đã bị xoá → CASE-31 | UC-02 E8, UC-05 E2, QC-08 mục 7; O-15 |
| SCR-03.S19 | Mở rộng | Bấm nút mở rộng | Dialog chiếm hết vùng chính; nội dung giữ thứ tự, notes rộng hơn. Nút đổi thành "Thu nhỏ" | Bấm "Thu nhỏ" | IA-06 |

**Dữ liệu mẫu.**
- Task đủ thông tin: "Chuẩn bị workshop thiết kế ACB" · "#Khách hàng ACB" · Priority · Thứ Năm 12/11 · Hạn Thứ Sáu 13/11 · Kế hoạch 2:00 · Thực tế 0:45.
- Subtask: "Viết agenda" (0:15, xong lúc 09:40), "Soạn bộ câu hỏi phỏng vấn" (0:45), "In mẫu ghi chú" (0:10), "Đặt phòng họp tầng 3" (0:05), "Gửi lịch mời cho anh Minh, chị Hà và nhóm sản phẩm Ngân hàng Á Châu" (0:05, xuống 2 dòng), "Ếch ỗng Ữ Ặ" (không thời lượng). Danh sách dài nhất: 100 subtask (dialog cuộn, header luôn hiện).
- Notes: một đoạn 3 câu, checklist 3 dòng, một link. Notes dài nhất 50.000 ký tự (vùng notes cuộn trong dialog).
- Comment: "Đã gửi agenda cho chị Hà, chờ phản hồi trước thứ Năm" · Bạn · 14:20.
- Nhật ký: "Bạn đổi thời lượng 1:30 thành 2:00 · 5 phút trước"; "Trợ lý AI gợi ý channel #Khách hàng ACB · hôm qua"; "Bạn tạo task · hôm qua". 45 dòng để thử "Xem thêm".
- Thời gian lớn nhất: "Thực tế 31:40 · Kế hoạch 24:00".

### SCR-04 Menu "Khác"

**Mục đích.** Gom các thao tác ít dùng của một task.

**Cấu trúc.** `Menu/Context`, mục theo SRS SCR-04 (UI-44): Lặp lại · Nhân bản · Sao chép link · đường kẻ · Xoá. Phím tắt hiện bên phải (Nhân bản "Ctrl+D", Xoá "Ctrl+Backspace"). "Xoá" ở cuối, kiểu nguy hiểm. "Gắn objective" ẩn ở 1.0.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-04.S01 | Task thường | Mọi task không thuộc series (kể cả task đã xong) | 4 mục như cấu trúc. "Sao chép link" → toast MSG-18; "Nhân bản" → F-13; "Xoá" → F-11; "Lặp lại" → G03 SCR-01 | Chọn mục / Esc / bấm ra ngoài | SRS SCR-04, UC-04, UC-05 |
| SCR-04.S02 | Instance lặp | Task thuộc series | "Lặp lại" đổi thành mục sửa series (chữ, nội dung và trạng thái mất mạng thuộc G03 SCR-03 #7: mờ, tooltip G03 MSG-27); các mục khác như S01 | – | G03, QC-08 mục 7 |

**Dữ liệu mẫu.** Không có dữ liệu biến đổi; thử menu mở từ card sát mép phải màn (menu lật sang trái) và từ header dialog.

### SCR-05 Thùng rác

**Mục đích.** Lấy lại task đã xoá trong 30 ngày.

**Cấu trúc.** Tab "Thùng rác" (UI-45) trong panel "Lưu trữ · Thùng rác" (rộng 340 px). Từ trên xuống:
1. Tiêu đề "Thùng rác" và mô tả "Task đã xoá trong 30 ngày qua" (UI-46).
2. Danh sách (`List/TrashItem`), mới xoá nhất trước. Mỗi dòng: tiêu đề (1 dòng, cắt "…") · chấm màu + "#channel" · thời lượng · "Đã xoá Thứ Hai 09/11" (UI-48). Nút "Khôi phục" (`Button` `variant=secondary` `size=sm`, UI-47) hiện khi hover / focus dòng.

Không có "Xoá vĩnh viễn" hay "Dọn Thùng rác" ở 1.0 (SRS chỉ có job tự xoá sau 30 ngày).

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-05.S01 | Đang tải | Mở tab | 5 dòng `Skeleton` | Có dữ liệu → S02 / S03; lỗi → S04 | \[TrashList\] |
| SCR-05.S02 | Có task | ≥ 1 task `DA_XOA` | Như cấu trúc; cuộn tới cuối thì tải thêm (dòng `Skeleton` ở cuối) | – | UC-04 A1 |
| SCR-05.S03 | Rỗng | Không có task nào | Chữ UI-49 "Không có task nào bị xoá" ở giữa panel, không có hình minh hoạ | – | SRS SCR-05 #4 |
| SCR-05.S04 | Lỗi tải | \[TrashList\] lỗi | QC-MSG-02 "Chưa tải được. Thử lại" ngay trong panel, "Thử lại" bấm được | Thử lại → S01 | QC-13 mục 1 |
| SCR-05.S05 | Vừa khôi phục | Bấm "Khôi phục" | Dòng thu lại và biến mất; toast MSG-13 nêu nơi đến. Instance lặp vào ngày đã có instance cùng series: **một** toast, dòng 1 MSG-13, dòng 2 MSG-24 (QC-13 mục 3) | – | UC-04 A1, A5, A6, BR-12 |
| SCR-05.S06 | Task đã xoá vĩnh viễn | Khôi phục task vừa quá 30 ngày | Dòng biến mất; toast MSG-14 | – | UC-04 E1 |
| SCR-05.S07 | Mất mạng | Không có mạng | Danh sách đã tải giữ nguyên; nút "Khôi phục" mờ, tooltip MSG-31; chưa tải lần nào → S04 | Có mạng → bình thường | UC-04 E5, QC-08 mục 7; O-15 |

**Dữ liệu mẫu.** "Gọi anh Minh về hợp đồng" · #Chưa phân loại · không thời lượng · Đã xoá Thứ Ba 10/11; "Chuẩn bị tài liệu cho buổi workshop thiết kế với nhóm khách hàng Ngân hàng Á Châu, gồm agenda…" (cắt 1 dòng) · #Dự án chuyển đổi số Ngân hàng Á Châu giai đoạn hai (cắt) · 24:00 · Đã xoá Chủ Nhật 11/10; "Ếch ỗng Ữ Ặ" · #Sức khoẻ · 0:15. Danh sách dài nhất để thử: 240 task.

### SCR-06 Context & channel

**Mục đích.** Tạo, sửa, ẩn, xoá context và channel; đặt khung giờ riêng cho từng channel.

**Cấu trúc.** Một nhóm trong Cài đặt (tiêu đề UI-51). Từ trên xuống:
1. **"Chưa phân loại"** đứng riêng ở đầu: chấm xám, mô tả UI-60, nhãn "Theo lịch làm việc chung" (UI-56). Không có nút xoá, không có công tắc "Khung giờ riêng" (BR-14, D3).
2. **Từng context** (tiêu đề nhóm, sửa tên tại chỗ, icon xoá), dưới đó các dòng channel (`List/ChannelRow`): chấm màu (bấm mở `Picker/Color` 12 màu, DS-12) · tên · công tắc "Riêng tư" (UI-54) · công tắc "Bật" (UI-55) · tóm tắt khung giờ (UI-57 hoặc "Theo lịch làm việc chung") · icon xoá. Cuối nhóm: nút "Tạo channel trong {context}" (UI-52).
3. Cuối trang: nút "Tạo context" (UI-52).
4. **Phần "Khung giờ"** mở bung ngay dưới dòng channel khi bấm vào tóm tắt khung giờ (SRS SCR-06 #7–#10): công tắc "Khung giờ riêng"; khi bật, 7 dòng (`List/WorkWindowDay`) Thứ Hai … Chủ Nhật (UI-62) theo ngày đầu tuần (G01), mỗi dòng: công tắc ngày · giờ bắt đầu · giờ kết thúc (`Picker/Time`, bước 15 phút); dưới cùng ghi chú hiệu lực và nút "Lưu" (`Button` `primary` `sm`), "Huỷ" (`Button` `secondary` `sm`) (UI-59).

Tên, màu, riêng tư, bật / ẩn lưu ngay khi đổi. Chỉ phần Khung giờ có nút "Lưu" (vì là cả khối, BR-22).

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-06.S01 | Mặc định | Mở nhóm | Như cấu trúc; tài khoản mới có "Chưa phân loại" và hai context `work`, `personal` rỗng | – | UC-06 bước 1, B4 |
| SCR-06.S02 | Đang tạo / sửa tên | Bấm "Tạo context" / "Tạo channel trong {context}" / bấm vào tên | Dòng nhập mới (placeholder UI-53) có focus; channel mới chọn sẵn màu kế tiếp chưa dùng. Enter / rời ô → lưu, channel hiện ngay trong ô soạn và bộ lọc; Esc → huỷ dòng mới | Lưu / Esc | UC-06 bước 2–3, A1 |
| SCR-06.S03 | Tên lỗi | Tên channel: trùng trong cùng context (không phân biệt hoa thường) / có "#" / > 50 ký tự / trống. Tên context: trùng với context khác (không phân biệt hoa thường) / > 50 ký tự / trống | Channel: MSG-15 hoặc MSG-17 dưới ô; context: MSG-39 hoặc MSG-40 dưới ô; không lưu, ô giữ focus | Sửa tên → lưu | UC-06 E1, E2, BR-14, O-17 |
| SCR-06.S04 | Channel đã ẩn | Tắt công tắc "Bật" | Dòng mờ, nhãn "Đã ẩn" (UI-20); khung giờ và task giữ nguyên | Bật lại | UC-06 A2 |
| SCR-06.S05 | Không xoá được context | Bấm xoá context còn channel | MSG-16 ngay dưới tiêu đề context; context giữ nguyên | Chuyển / xoá hết channel rồi xoá lại | UC-06 A4 |
| SCR-06.S06 | Khung giờ tắt | Mặc định của mọi channel | Phần Khung giờ: công tắc "Khung giờ riêng" tắt, chữ "Theo lịch làm việc chung" | Bật → S07 | SRS SCR-06 #7, BR-22 |
| SCR-06.S07 | Khung giờ đang sửa | Bật công tắc lần đầu, hoặc mở khung đã bật | 7 dòng ngày, điền sẵn theo lịch chung khi bật lần đầu `[giả định]`; ngày không có trong lịch chung (Chủ Nhật) bật được; nút "Lưu" bật khi có thay đổi hợp lệ | "Lưu" → S09; "Huỷ" → bỏ thay đổi, về khung đã lưu | UC-06 A5, A6 |
| SCR-06.S08 | Khung giờ lỗi | Giờ kết thúc ≤ giờ bắt đầu ở một dòng; hoặc không ngày nào bật | MSG-25 ngay tại dòng lỗi (có thể nhiều dòng cùng lúc); MSG-26 dưới danh sách ngày. Nút "Lưu" `disabled` | Sửa giờ / bật một ngày → S07 | UC-06 E4, E5 |
| SCR-06.S09 | Đã lưu, có khung chờ | Lưu thành công (bật, sửa, hoặc tắt khung) | MSG-27 dưới phần Khung giờ ngay sau khi lưu; sau đó, tới ngày hiệu lực, dòng channel giữ chữ MSG-32 "Khung mới áp dụng từ {ngày}" cạnh tóm tắt khung đang áp (hôm nay vẫn dùng khung cũ) | Tới mốc đầu ngày của ngày hiệu lực → tóm tắt đổi, hết MSG-32 | UC-06 A5–A7, BR-24 |
| SCR-06.S10 | Bị sửa trên thiết bị khác | Khung giờ đổi qua realtime khi đang mở | Không đang sửa: nhận giá trị mới, không báo. Đang sửa dở: giữ bản đang sửa; khi rời phần Khung giờ hiện MSG-28 | "Lưu" → bản này thắng cả khối; "Huỷ" → lấy bản server | UC-06 A9, C01 |
| SCR-06.S11 | Chờ đồng bộ | Lưu khi mất mạng | Dòng channel có icon "Chờ đồng bộ" (MSG-30); MSG-27 tạm chưa hiện ngày, hiện khi server nhận (ngày hiệu lực tính theo lúc server nhận) | Có mạng → S09 | UC-06 E6, QC-08 mục 7 |
| SCR-06.S12 | Lưu lỗi | \[ChannelCreate\] / \[ChannelUpdate\] lỗi 5xx | Giá trị trả về như trước; toast MSG-10 có "Thử lại"; phần Khung giờ đang sửa giữ nguyên bản đang sửa | Thử lại | QC-13 mục 1 |

**Dữ liệu mẫu.**
- Context `work`: "#Công ty" (T2–T6 09:00–17:00, khung riêng), "#Khách hàng ACB", "#Dự án chuyển đổi số Ngân hàng Á Châu giai đoạn hai" (50 ký tự, dòng không vỡ). Context `personal`: "#Cá nhân" (T2–CN 19:00–22:00, khung riêng), "#Sức khoẻ" (đã ẩn), "#Ếch ỗng Ữ Ặ".
- Tóm tắt khung: "Thứ Hai đến Thứ Sáu · 09:00–17:00"; "Thứ Hai đến Chủ Nhật · 19:00–22:00"; giờ khác nhau theo ngày: "5 ngày, giờ khác nhau".
- Khung chờ: "Khung mới áp dụng từ Thứ Tư 11/11". MSG-27: "Áp dụng từ ngày làm việc kế tiếp (Thứ Tư 11/11)".
- Giờ biên: bắt đầu sớm nhất 00:00, muộn nhất 23:45; kết thúc muộn nhất 24:00 (BR-22, O-20).
- Danh sách dài nhất: 5 context, 40 channel.

### SCR-07 Xoá channel

**Mục đích.** Xoá một channel mà không mất task: bắt chọn channel nhận.

**Cấu trúc.** Dialog nhỏ (`Dialog`): tiêu đề MSG-33; nội dung MSG-34 (chữ SRS SCR-07 #1); dropdown channel nhận (`Combobox/Channel`, mặc định "Chưa phân loại", không có channel đang xoá); nút "Huỷ" (`Button` `secondary`) và "Xoá channel" (`Button` `variant=danger`, O-18) (UI-67). Focus ban đầu ở dropdown; Enter không tự xoá.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-07.S01 | Mặc định | Bấm icon xoá trên dòng channel có task | Như cấu trúc, {n} là tổng task gồm cả Lưu trữ, Thùng rác, task lặp | "Xoá channel" → dialog đóng, toast MSG-19, dòng biến mất khỏi SCR-06; "Huỷ" / Esc → đóng | UC-06 A3, BR-14, C10 |
| SCR-07.S02 | Channel chưa có task | n = 0 | Nội dung MSG-35 thay MSG-34; không có dropdown | Như S01 | SRS SCR-07 #1 |
| SCR-07.S03 | Channel có khung giờ riêng | Channel đang có `workWindow` | Thêm một dòng MSG-36 dưới dropdown | Như S01 | UC-06 A3, BR-24, US5.3 AC07 |
| SCR-07.S04 | Xoá lỗi | \[ChannelDelete\] lỗi | Dialog giữ mở; toast MSG-10 có "Thử lại"; nút "Xoá channel" bật lại | Thử lại / Huỷ | QC-13 mục 1 |

**Dữ liệu mẫu.** "Xoá channel #Dự án chuyển đổi số Ngân hàng Á Châu giai đoạn hai?" (tiêu đề xuống 2 dòng); n = 0, 1, 12.480 (số lớn, dấu chấm phân cách nghìn). Toast MSG-19: "Đã xoá channel Khách hàng ACB, 37 task chuyển sang Chưa phân loại".

## 5. User flow

### F-01 Ghi nhanh một task vào ngày

**Mở đầu:** board, cột Thứ Năm 12/11, ô soạn đóng. **Kết thúc:** task trên đầu cột, tổng thời lượng cột tăng. Sơ đồ: [UC-01](flow/g02-quan-ly-task.md#uc-01-tạo-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm "Thêm task" trên cột (hoặc chọn cột rồi nhấn A) | SCR-01.S02, chip Ngày = Thứ Năm 12/11 |
| 2 | Gõ "Gọi anh Minh về hợp đồng" | SCR-01.S03 (không AI) hoặc S04 → S05 (có AI) |
| 3 | Nhấn Enter | SCR-02.S01 ở đầu cột ≤ 100 ms; tổng cột cập nhật; ô soạn giữ mở, trống (SRS UC-01 bước 7) |
| 4 | Nhấn Esc | SCR-01.S01 |

Nhánh: tiêu đề trống → CASE-01; > 500 ký tự → SCR-01.S08; mất mạng → CASE-27; lỗi 5xx → SCR-02.S09; ngày đã qua khi gửi → SCR-01.S11; cột đã qua + A → CASE-11.

### F-02 Ghi nhiều task liên tiếp

**Mở đầu:** như F-01 bước 3. **Kết thúc:** nhiều card liên tiếp trên cột. Sơ đồ: [UC-01](flow/g02-quan-ly-task.md#uc-01-tạo-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Gõ task kế tiếp, Enter | Card mới theo chip Vị trí; ô soạn trống lại |
| 2 | Lặp lại | Chip Ngày giữ nguyên; chip Thời lượng, Channel, Priority về mặc định, không mang giá trị của task trước |

### F-03 Tạo task từ link

**Mở đầu:** ô soạn mở. **Kết thúc:** task có tiêu đề trang, giữ link nguồn. Sơ đồ: [UC-01](flow/g02-quan-ly-task.md#uc-01-tạo-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Dán URL | SCR-01.S07 |
| 2 | – | Tiêu đề trang thay URL; quá 3 giây / không đọc được → giữ URL (CASE-05) |
| 3 | Nhấn Enter | SCR-02 có icon link (O-05); mở chi tiết thấy SCR-03.S14; phím G mở link |

### F-04 Gán channel bằng "#" khi soạn

**Mở đầu:** đang gõ tiêu đề trong SCR-01 hoặc SCR-08. **Kết thúc:** chip Channel có giá trị, tiêu đề sạch "#…". Sơ đồ: [UC-01](flow/g02-quan-ly-task.md#uc-01-tạo-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Gõ "#kh" | SCR-09.S02, lọc theo "kh" |
| 2 | ↑/↓ chọn "#Khách hàng ACB", Enter | Chip Channel = "#Khách hàng ACB" (không ✨); "#kh" bị xoá khỏi tiêu đề; con trỏ về tiêu đề |
| 3 | Enter | Tạo task (F-01 bước 3) |

Nhánh: không khớp → SCR-09.S03; gợi ý AI về sau khi đã chọn → không ghi đè (CASE-22).

### F-05 Tạo task vào backlog

**Mở đầu:** ô soạn mở. **Kết thúc:** task trong Backlog, không hiện trên cột. Sơ đồ: [UC-01](flow/g02-quan-ly-task.md#uc-01-tạo-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Mở chip Ngày, chọn "Không ngày (backlog)" | SCR-01.S09 |
| 2 | Gõ tiêu đề, Enter | Không có card mới trên cột; toast MSG-07 |
| 3 | (Tuỳ chọn) Bấm "Mở Backlog" | Panel Backlog (G06 SCR-09) mở ở panel phải |

### F-06 Ghi nhanh từ bên ngoài app

**Mở đầu:** đang ở app khác, cửa sổ chính ở nền hoặc ở khay. **Kết thúc:** task ở Hôm nay, người dùng vẫn ở app cũ. Sơ đồ: [UC-01 A7](flow/g02-quan-ly-task.md#nhánh-thay-thế-ô-thêm-nhanh-toàn-cục-a7).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Nhấn Ctrl+Shift+A | SCR-08.S01 (hoặc S02 nếu có nháp) |
| 2 | Gõ "Trả lời email chị Hà về báo giá" | SCR-08.S03 |
| 3 | Nhấn Enter | SCR-08.S05 → cửa sổ đóng, focus về app trước |
| 3a | Hoặc Shift+Enter, gõ tiếp | SCR-08.S06 |
| 3b | Hoặc Esc / bấm ra ngoài | Đóng, giữ nháp |

Nhánh: phím tắt đã tắt → SCR-08.S07; lỗi 5xx → CASE-28.

### F-07 Mở chi tiết và bổ sung thông tin

**Mở đầu:** card "Chuẩn bị workshop thiết kế ACB" trên board. **Kết thúc:** task đủ thông tin, card cập nhật. Sơ đồ: [UC-02](flow/g02-quan-ly-task.md#uc-02-xem-và-sửa-chi-tiết-task), [nhánh subtask](flow/g02-quan-ly-task.md#nhánh-thay-thế-subtask-comment-nhật-ký), [nhánh sửa trường](flow/g02-quan-ly-task.md#nhánh-thay-thế-và-lỗi-sửa-trường).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm tiêu đề card (hoặc chọn card rồi Ctrl+Enter) | SCR-03.S01 → S02 / S03 |
| 2 | Bấm "Subtask" (hoặc V), gõ "Viết agenda", Enter, gõ "Soạn câu hỏi", Enter, Esc | SCR-03.S05; mỗi Enter lưu một subtask |
| 3 | Bấm "Kế hoạch", chọn preset 1 giờ | Lưu ngay; tổng cột cập nhật |
| 4 | Mở chip Priority, nhấn 2 | Priority = Priority; chip hiện trên header và card |
| 5 | Mở chip Hạn chót, chọn Thứ Sáu 13/11 | Chip hiện; nếu sớm hơn ngày dự định → SCR-03.S10 |
| 6 | Gõ notes | Lưu sau 1 giây ngừng gõ |
| 7 | Gõ comment, Enter | Comment mới ở cuối danh sách |
| 8 | Esc (nếu đang trong ô nhập: Esc lần 1 bỏ focus, lần 2 đóng) hoặc × | Dialog đóng, focus về card vừa mở (SCR-02.S05) |

Nhánh: đổi ngày → CASE-12, CASE-13; đổi channel → CASE-14; lỗi trường → SCR-03.S09; lưu lỗi → SCR-03.S17; thiết bị khác sửa → SCR-03.S15.

### F-08 Xoá subtask và hoàn tác

**Mở đầu:** SCR-03 có subtask. **Kết thúc:** subtask về đúng chỗ. Sơ đồ: [nhánh subtask](flow/g02-quan-ly-task.md#nhánh-thay-thế-subtask-comment-nhật-ký).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Hover dòng subtask (hoặc Tab tới dòng) | Icon xoá hiện |
| 2 | Bấm icon xoá | SCR-03.S08; toast MSG-21 ≥ 5 giây |
| 3 | Bấm "Hoàn tác" trong toast | Subtask về đúng vị trí, trạng thái, thời lượng, thời gian thực tế |

Toast tắt rồi thì không lấy lại được: subtask không vào Thùng rác (BR-17 d `[giả định]`).

### F-09 Hoàn thành task và hoàn tác

**Mở đầu:** task "Viết báo cáo tuần" ở cột Thứ Năm 12/11 (hôm nay là Thứ Ba 10/11), 2 subtask chưa xong. **Kết thúc:** task xong ở cột hôm nay; hoặc về như cũ nếu hoàn tác. Sơ đồ: [UC-03](flow/g02-quan-ly-task.md#uc-03-hoàn-thành--bỏ-hoàn-thành-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm ✓ trên card / SCR-03, hoặc chọn card rồi nhấn C | ✓ nở nhẹ (hiệu ứng chúc mừng nếu bật); card bay về cột Hôm nay, SCR-02.S07; subtask tự tích; thanh tiến độ hôm nay tăng |
| 2 | – | Toast MSG-08 "Đã hoàn thành "Viết báo cáo tuần" · Hoàn tác" ≥ 5 giây |
| 3 | (Tuỳ chọn) Bấm "Hoàn tác" | Card bay về cột Thứ Năm 12/11, 2 subtask về chưa xong, đúng vị trí cũ |

Nhánh: instance lặp ngày tương lai → CASE-15; trước mốc đầu ngày → CASE-10; timer đang chạy ở thiết bị khác → CASE-32; mất mạng → CASE-29; lỗi → CASE-36; task đã bị xoá → CASE-31.

### F-10 Bỏ hoàn thành

**Mở đầu:** task đã xong (SCR-02.S07 hoặc SCR-03.S12). **Kết thúc:** task ở Kế hoạch. Sơ đồ: [UC-03](flow/g02-quan-ly-task.md#uc-03-hoàn-thành--bỏ-hoàn-thành-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm ✓ (hoặc C) trên task đã xong | – |
| 2a | Cùng ngày làm việc với lúc hoàn thành | Như Hoàn tác ở F-09 bước 3: ngày / bucket cũ, subtask tự tích về chưa xong, bỏ `plannedAsActual` |
| 2b | Ngày làm việc khác | Chỉ bỏ dấu xong; task ở Kế hoạch **hôm nay**; subtask giữ nguyên |
| 3 | – | Toast MSG-37 có "Hoàn tác" (O-10); instance lặp về hôm nay đã có instance cùng series → MSG-24 ở dòng 2 cùng toast (O-08); nhật ký "đánh dấu chưa xong" |

### F-11 Xoá task và hoàn tác

**Mở đầu:** task trên card hoặc trong SCR-03. **Kết thúc:** task trong Thùng rác; hoặc về đúng chỗ cũ. Sơ đồ: [UC-04](flow/g02-quan-ly-task.md#uc-04-xoá-hoàn-tác-và-khôi-phục-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Menu … → "Xoá" (SCR-04.S01), hoặc chọn task rồi Ctrl+Backspace | Không hỏi xác nhận. Card thu lại và biến mất; timer dừng nếu đang chạy; SCR-03 (nếu mở) đóng |
| 2 | – | Toast MSG-09 "Đã xoá · Hoàn tác (Ctrl+Z)" ≥ 5 giây |
| 3 | (Tuỳ chọn) Bấm "Hoàn tác" hoặc Ctrl+Z | Card hiện lại đúng chỗ; timebox liên kết lại, sự kiện ngoài đã xoá được tạo lại với giờ cũ |

Nhánh: task có timebox → CASE-20; instance lặp → CASE-16; lỗi → CASE-36; mất mạng → xoá vẫn chạy trên máy, toast như bước 2 (UC-04 E5); lệnh offline xung đột → CASE-30.

### F-12 Khôi phục từ Thùng rác

**Mở đầu:** toast xoá đã tắt. **Kết thúc:** task về đúng trạng thái trước khi xoá. Sơ đồ: [UC-04](flow/g02-quan-ly-task.md#uc-04-xoá-hoàn-tác-và-khôi-phục-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Panel phải → "Lưu trữ · Thùng rác" → tab "Thùng rác" (hoặc Ctrl+K "Task đã xoá gần đây") | SCR-05.S01 → S02 / S03 |
| 2 | Hover dòng, bấm "Khôi phục" | SCR-05.S05; toast MSG-13 nêu nơi đến (bảng QC-03 mục 3) |

Nhánh: instance trùng series → SCR-05.S05 (toast hai dòng); quá 30 ngày → SCR-05.S06; khôi phục task `KE_HOACH` có ngày đã qua → CASE-17; mất mạng → SCR-05.S07.

### F-13 Nhân bản task

**Mở đầu:** task bất kỳ không ở Thùng rác. **Kết thúc:** bản sao ở Hôm nay, dialog của bản sao đang mở. Sơ đồ: [UC-05](flow/g02-quan-ly-task.md#uc-05-nhân-bản-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Menu … → "Nhân bản", hoặc Ctrl+D | – |
| 2 | – | Bản sao xuất hiện ở cột Hôm nay (đầu hoặc cuối theo cài đặt); SCR-03 của bản sao mở (S02 / S03), nhật ký "nhân bản từ "{tiêu đề}"". Không có toast |

Nhánh: instance lặp → CASE-18; task đã xong → CASE-19; lỗi → CASE-37; mất mạng → bản sao tạo trên máy, mở như bước 2, dấu "Chờ đồng bộ" (SCR-03.S18, UC-05 E2, O-15).

### F-14 Tạo context và channel

**Mở đầu:** Cài đặt → Context & channel. **Kết thúc:** channel mới có trong ô soạn, bộ lọc. Sơ đồ: [UC-06](flow/g02-quan-ly-task.md#uc-06-quản-lý-context-và-channel).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm "Tạo channel trong work" | SCR-06.S02 |
| 2 | Gõ "Khách hàng ACB", chọn màu, Enter | Dòng mới lưu; channel có ngay trong SCR-09 |

Nhánh: tên trùng / có "#" / quá dài → SCR-06.S03; xoá context còn channel → SCR-06.S05.

### F-15 Đặt khung giờ riêng cho channel

**Mở đầu:** SCR-06, channel "#Cá nhân" đang theo lịch chung. **Kết thúc:** khung mới hiệu lực từ ngày làm việc kế tiếp. Sơ đồ: [nhánh khung giờ](flow/g02-quan-ly-task.md#nhánh-thay-thế-và-lỗi-khung-giờ-channel).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm "Theo lịch làm việc chung" trên dòng "#Cá nhân" | SCR-06.S06 |
| 2 | Bật "Khung giờ riêng" | SCR-06.S07, 7 dòng điền sẵn theo lịch chung |
| 3 | Bật Thứ Bảy, Chủ Nhật; đặt mọi ngày 19:00–22:00 | Nút "Lưu" bật |
| 4 | Bấm "Lưu" | SCR-06.S09: MSG-27; dòng channel có MSG-32 tới ngày hiệu lực |

Nhánh: giờ sai / không ngày nào → SCR-06.S08; tắt khung → như bước 4 với "Theo lịch làm việc chung"; thiết bị khác sửa → SCR-06.S10; mất mạng → SCR-06.S11.

### F-16 Xoá channel

**Mở đầu:** SCR-06, channel "#Khách hàng ACB" có 37 task. **Kết thúc:** channel biến mất, task sang channel nhận. Sơ đồ: [nhánh sửa, ẩn, xoá](flow/g02-quan-ly-task.md#nhánh-thay-thế-sửa-ẩn-xoá).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm icon xoá trên dòng | SCR-07.S01 (hoặc S02, S03) |
| 2 | Giữ "Chưa phân loại" hoặc chọn channel khác, bấm "Xoá channel" | Dialog đóng; dòng biến mất; toast MSG-19. Không có Hoàn tác |

Nhánh: "Chưa phân loại" không có icon xoá (SCR-06.S01); lỗi → SCR-07.S04.

### F-17 Đổi channel của task có sẵn

**Mở đầu:** card đang chọn trên board, hoặc SCR-03. **Kết thúc:** channel mới trên card. Sơ đồ: [nhánh sửa trường](flow/g02-quan-ly-task.md#nhánh-thay-thế-và-lỗi-sửa-trường).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Nhấn Q (hoặc #) khi card đang chọn; hoặc bấm chip Channel trong SCR-03 | SCR-09.S01 (S04 nếu channel hiện tại đã ẩn) |
| 2 | Gõ để lọc, Enter | Chip channel trên card / header đổi ngay; projection và tổng cột tính lại (CASE-14) |

Nhánh: Shift+Q nhận channel gợi ý → CASE-26.

## 6. Case chính và edge case

| Mã | Tình huống | Màn / trạng thái | Hiện gì | Tham chiếu |
|---|---|---|---|---|
| **Dữ liệu** | | | | |
| CASE-01 | Tiêu đề trống hoặc toàn khoảng trắng | SCR-01.S02, SCR-08.S04 | Nút "Thêm" `disabled`; Enter không làm gì, không có chữ báo | UC-01 E1 |
| CASE-02 | Tiêu đề 500 ký tự trên card / toast | SCR-02, toast MSG-08 / 13 / 21 | Card cắt sau 2 dòng; toast cắt {tiêu đề} một dòng bằng "…"; SCR-03 hiện đủ | SRS SCR-02 #2 |
| CASE-03 | Task có 100 subtask | SCR-02.S03, SCR-03.S07 | Card 5 dòng + "Còn 95 subtask"; dialog cuộn, không chặn mở | SRS SCR-02 #4, UC-02 E2 |
| CASE-04 | Channel đã ẩn | SCR-09.S04, SCR-02 | Không có trong danh sách chọn; task cũ vẫn hiện channel đó trên card | UC-06 A2, US5.1 AC03 |
| CASE-05 | Link không đọc được tiêu đề (chặn bot, IP nội bộ, quá 3 giây) | SCR-01.S07 | Giữ URL làm tiêu đề, không báo lỗi | UC-01 A1, PRD mục 9 |
| CASE-06 | Comment nhiều dòng | SCR-03 | Enter gửi; Shift+Enter xuống dòng trong ô | UC-02 A4 |
| CASE-07 | Nhật ký > 20 dòng | SCR-03.S03 | "Xem thêm" tải tiếp 20 dòng; hết thì ẩn nút | UC-02 A5 |
| CASE-08 | Đổi thứ tự subtask | SCR-03, `List/Subtask` | Kéo thả hoặc Ctrl+↑/↓ trên dòng; không toast, Ctrl+Z hoàn tác (QC-13 mục 2) | UC-02 A3 |
| CASE-09 | Thêm subtask vào task đã xong | SCR-03.S12 | Subtask mới chưa xong; ✓ lớn vẫn xong; card không đổi trạng thái | UC-02 A9, BR-17 c |
| **Thời gian** | | | | |
| CASE-10 | Hoàn thành lúc 02:00 ngày 11/11, mốc đầu ngày 04:00 | SCR-02.S07 | Ngày hoàn thành là Thứ Ba 10/11; task không nhảy sang cột 11/11 | UC-03 A5, QC-01 |
| CASE-11 | Phím A khi cột đang chọn là ngày đã qua | SCR-01.S02 | Board cuộn tới cột hôm nay, ô soạn mở ở cột hôm nay | UC-01 A6, IA-20 |
| CASE-12 | Đổi ngày dự định trong header SCR-03 | SCR-03, menu Ngày dự định (G06) | Ngày < hôm nay `disabled` trong lịch chọn. Đổi xong: chip Ngày đổi, task chuyển cột; toast G04 MSG-01 có "Hoàn tác" (O-13); server vẫn trả `PAST_DATE` → MSG-20 dưới chip | UC-02 A11, E7, QC-05 |
| CASE-13 | Đổi ngày instance lặp sang ngày đã có instance cùng series | SCR-03 | Vẫn đổi; **một** toast: dòng 1 G04 MSG-01 có Hoàn tác, dòng 2 MSG-24 | UC-02 A11, QC-06 mục 3, QC-13 mục 3 |
| CASE-14 | Đổi channel sang channel có khung giờ riêng | SCR-03 header, SCR-09 | Chỉ đổi chip Channel trong G02; projection, sức chứa của cột tính lại ngay (cách báo trên card thuộc G04) | UC-02 A12, BR-23, BR-24 |
| **Lặp lại, timebox, nhân bản, khôi phục** | | | | |
| CASE-15 | Hoàn thành instance lặp ở ngày tương lai | SCR-02.S07 | Instance xong tại cột ngày đó, không về hôm nay | UC-03 A4, Q12 |
| CASE-16 | Xoá instance lặp | SCR-02, toast MSG-09 | Như xoá thường; ngày gốc thành ngày ngoại lệ, Hoàn tác không gỡ (không hiện gì thêm) | UC-04 A4, G03 BR-15 |
| CASE-17 | Khôi phục task `KE_HOACH` có ngày dự định < hôm nay; task `HOAN_THANH` / `LUU_TRU` / `BACKLOG` | SCR-05.S05 | MSG-13 nêu nơi đến: "về hôm nay" / ngày cũ / "Lưu trữ" / "Backlog · Tuần tới" | UC-04 A6, QC-03 mục 3 |
| CASE-18 | Nhân bản instance lặp | SCR-03 bản sao | Bản sao là task thường: không banner series, không dấu lặp | UC-05 A1 |
| CASE-19 | Nhân bản task đã xong | SCR-03 bản sao | Bản sao Kế hoạch hôm nay, không có subtask (mọi subtask của task gốc đã xong) | UC-05 A2 |
| CASE-20 | Xoá task có timebox | SCR-02, lịch (G05) | Timebox tương lai biến khỏi lịch, sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết. Timebox liên kết sự kiện: chỉ gỡ liên kết, sự kiện giữ nguyên. Hoàn tác khôi phục liên kết; khôi phục từ Thùng rác **không** tạo lại timebox | UC-04 A2, QC-05 |
| CASE-21 | Hoàn thành khi bật "Tính planned là actual", task không có bản ghi thời gian | SCR-02.S07, SCR-03.S12 | "1:30 / 1:30" (actual = planned); không tạo bản ghi | UC-03 A6, QC-07 mục 4 |
| **AI** | | | | |
| CASE-22 | Gợi ý AI về sau khi người dùng đã chọn channel / thời lượng | SCR-01.S05 | Chip đã chọn giữ nguyên, không ✨; chỉ chip còn trống nhận gợi ý | BR-04 |
| CASE-23 | Claude Code chậm > 2 giây hoặc báo hết hạn mức khi đang gợi ý | SCR-01.S04 → S03 | Bỏ gợi ý, không báo lỗi; gợi ý về muộn **không** điền vào task đã tạo | UC-01 A4, G10 BR-30 |
| CASE-24 | Trợ lý AI (Claude Code qua MCP local) hoàn thành task / subtask | SCR-02.S07 + S10 | Như người dùng hoàn thành; card có chip "AI"; Hoàn tác ở chip / G10. Không có toast MSG-08 trong G02 (thông báo thuộc G10) | UC-03 A7, BR-21 |
| CASE-25 | Trợ lý AI xoá task / subtask; người dùng hoàn tác task do AI tạo trong chat | SCR-02, SCR-05 | Task biến khỏi board, vào Thùng rác như xoá thường; Hoàn tác ở G10 | UC-04 A3, A7, BR-21 |
| CASE-26 | Shift+Q nhận channel gợi ý | SCR-09, SCR-03 | Giá trị giữ, mất ✨ (nguồn `user`); không có gợi ý thì không làm gì | US5.2 AC02, BR-04; O-03 |
| **Mạng và đồng bộ** | | | | |
| CASE-27 | Tạo task khi mất mạng rồi có mạng | SCR-02.S08 → S01 | Card hiện ngay có icon "Chờ đồng bộ"; có mạng thì gửi lại cùng idempotency key, không tạo trùng; banner offline của board theo G04 MSG-30 | UC-01 E3, QC-08 |
| CASE-28 | Ô thêm nhanh toàn cục: lưu lỗi 5xx sau khi cửa sổ đã đóng | SCR-02.S09; trung tâm thông báo | Card trên cột Hôm nay ở trạng thái lỗi; toast MSG-10. Cửa sổ chính đang ẩn → toast vào trung tâm thông báo thành dòng chưa đọc (IA-21) | UC-01 A7, E4, F6 |
| CASE-29 | Hoàn thành / xoá / đổi ngày khi mất mạng, nhưng server đã đổi cụm vị trí (ví dụ rollover đã chạy) | SCR-02, SCR-03 | Áp ngay trên máy (icon "Chờ đồng bộ"); khi gửi bị từ chối → card về trạng thái server, toast MSG-23 | UC-03 E1, UC-02 E6, QC-08 mục 2 |
| CASE-30 | Xoá task bằng lệnh offline trên phiên bản cũ | SCR-02 | Task hiện lại theo trạng thái server; toast MSG-23 | UC-04 E4 |
| CASE-31 | Lệnh sửa / hoàn thành (kể cả từ hàng đợi offline) tới task đã bị xoá | SCR-02, SCR-03 | Bỏ lệnh khỏi hàng đợi; toast MSG-22 | UC-02 E5, UC-03 E3 |
| CASE-32 | Hoàn thành task đang chạy timer ở thiết bị khác | SCR-02.S07 | Timer dừng trên mọi thiết bị (chỉ báo timer biến mất, thuộc G07); task xong như thường | UC-03 A3, BR-08 a |
| **Quyền và công tắc** | | | | |
| CASE-33 | Xoá channel hệ thống "Chưa phân loại"; đặt khung giờ cho channel này | SCR-06.S01 | Không có icon xoá, không có công tắc "Khung giờ riêng". Gọi API trực tiếp bị từ chối, không hiện gì trong app | UC-06 E3, E7, D3 |
| CASE-34 | Lịch làm việc chung (G01) đổi | SCR-06 | Channel không có khung riêng hiện tóm tắt "Theo lịch làm việc chung" như cũ; channel đã có khung riêng không đổi | UC-06 A8 |
| CASE-35 | Gõ "a" khi không focus ô nhập; gõ nhanh ≥ 4 ký tự / 1 giây ngoài ô nhập | Board | Mở ô soạn ở cột đang chọn; gõ nhanh thì khoá phím một ký tự 1 giây | G04 BR-17, EC-25 |
| **Lỗi** | | | | |
| CASE-36 | \[TaskComplete\] / \[TaskDelete\] / \[TaskRestore\] lỗi | SCR-02, SCR-05 | Card / dòng về trạng thái trước; toast MSG-10 có "Thử lại" | UC-03 E2, UC-04 E3 |
| CASE-37 | \[TaskDuplicate\] lỗi | SCR-03 | Không mở bản sao; dialog task gốc giữ nguyên; toast MSG-10 | UC-05 E1 |

## 7. Copy

MSG-xx chép nguyên văn từ SRS G02 mục 9 (nguồn vẫn là SRS). MSG của nhóm khác và câu chung QC-MSG ghi rõ nguồn. UI-xx là chữ nhãn, placeholder, tooltip, nhãn đọc màn hình (không phải thông báo), PO duyệt ngày 10/11/2026; brief là nguồn của chữ UI-xx, SRS G02 mục 7 trỏ về đây. Chữ UI-xx là thông báo / toast / xác nhận đã thành MSG-29 … MSG-38 của SRS (O-19, A7); chữ đã có trong SRS nhưng chưa có mã thì ghi nguồn ở cột Ghi chú. Mọi chữ theo [DS-07](01-nen-tang-design-system.md#11-giọng-văn); ký hiệu (dấu tích, dấu cộng, ✨) là icon đặt cạnh chữ (QC-13 mục 4).

**Độ dài biến** dùng chung: {tiêu đề} ≤ 500 ký tự, trong toast cắt một dòng bằng "…"; {tên} channel ≤ 50 ký tự; {context} ≤ 50 ký tự (BR-14, O-17); {tên series} = tiêu đề series, ≤ 500, cắt như {tiêu đề}; {n} có thể tới hàng chục nghìn, dấu chấm phân cách nghìn ("12.480"); {ngày} / {thứ, ngày} dạng "Thứ Năm 12/11", dài nhất "Chủ Nhật 15/11"; {giờ} "09:40".

**Thông báo (MSG)**

| Mã | Nơi hiện | Nội dung (VI) | Biến | Ghi chú |
|---|---|---|---|---|
| MSG-01 | Inline dưới tiêu đề (SCR-01.S08, SCR-08.S04, SCR-03.S09) | Tên task tối đa 500 ký tự | – | |
| MSG-02 | Inline dưới ô giờ / phút (SCR-03.S09) | Thời lượng từ 1 phút đến 24 giờ | – | |
| MSG-03 | Inline dưới notes / ô comment (SCR-03.S09) | Nội dung quá dài | – | |
| MSG-04 | Inline tại dòng "Thêm subtask" (SCR-03.S07) | Mỗi task tối đa 100 subtask | – | |
| MSG-06 | Inline dưới chip Hạn chót (SCR-03.S10) | Hạn chót sớm hơn ngày dự định | – | Kiểu cảnh báo, không chặn |
| MSG-07 | Toast (F-05) | Đã thêm vào Backlog · Mở Backlog | – | "Mở Backlog" là nút; không có Hoàn tác |
| MSG-08 | Toast (F-09) | Đã hoàn thành "{tiêu đề}" · Hoàn tác | {tiêu đề} | "Hoàn tác" là nút, toast ≥ 5 giây |
| MSG-09 | Toast (F-11) | Đã xoá · Hoàn tác (Ctrl+Z) | – | Toast ≥ 5 giây. SCR-03.S16 dùng MSG-38 (O-01) |
| MSG-10 | Toast (SCR-02.S09, SCR-03.S17, SCR-06.S12, SCR-07.S04, CASE-36, CASE-37) | Chưa lưu được thay đổi. Thử lại | – | = QC-MSG-01 (QC-13 mục 1); "Thử lại" là nút |
| MSG-12 | Inline dưới trường (SCR-03.S15) | Task vừa được cập nhật trên thiết bị khác | – | Chỉ cho task; khung giờ dùng MSG-28 |
| MSG-13 | Toast (SCR-05.S05) | Đã khôi phục "{tiêu đề}" về {ngày / Backlog · {bucket} / Lưu trữ} | {ngày}: "hôm nay" / "Thứ Năm 12/11"; {bucket} theo G06 | Không có Hoàn tác. Gộp với MSG-24 ở dòng 2 |
| MSG-14 | Toast (SCR-05.S06) | Task này đã bị xoá vĩnh viễn | – | |
| MSG-15 | Inline dưới ô tên (SCR-06.S03) | Channel này đã tồn tại trong {context} | {context} ≤ 50 | |
| MSG-16 | Inline dưới tên context (SCR-06.S05) | Hãy chuyển hoặc xoá các channel trong context trước | – | |
| MSG-17 | Inline dưới ô tên (SCR-06.S03) | Tên channel 1–50 ký tự, không chứa "#" | – | |
| MSG-18 | Toast (SCR-04) | Đã sao chép link task | – | Icon dấu tích cạnh chữ |
| MSG-19 | Toast (F-16) | Đã xoá channel {tên}, {n} task chuyển sang {channel nhận} | {tên}, {channel nhận} ≤ 50 mỗi biến | Không có Hoàn tác |
| MSG-20 | Inline dưới ô / chip Ngày (SCR-01.S11, CASE-12) | Không thể đặt task chưa xong vào ngày đã qua | – | |
| MSG-21 | Toast (SCR-03.S08) | Đã xoá subtask "{tiêu đề}" · Hoàn tác | {tiêu đề} subtask ≤ 500 | Toast ≥ 5 giây |
| MSG-22 | Toast (CASE-31) | Task này đã bị xoá trên thiết bị khác. Thay đổi chưa được lưu | – | |
| MSG-23 | Toast (CASE-29, CASE-30) | Task đã thay đổi trên thiết bị khác | – | Câu chung QC-08 mục 2 (= G04 MSG-17) |
| MSG-24 | Dòng 2 của toast (SCR-05.S05, CASE-13) | Ngày này đã có {tên series} | {tên series} | = G03 MSG-21 (QC-06 mục 3); gộp một toast theo QC-13 mục 3 |
| MSG-25 | Inline tại dòng ngày (SCR-06.S08) | Giờ kết thúc phải sau giờ bắt đầu | – | = G01 MSG-20 |
| MSG-26 | Inline dưới danh sách ngày (SCR-06.S08) | Chọn ít nhất 1 ngày cho khung giờ của channel | – | |
| MSG-27 | Inline dưới phần Khung giờ (SCR-06.S09) | Áp dụng từ ngày làm việc kế tiếp ({ngày}) | {ngày} "Thứ Tư 11/11" | = G01 MSG-24 |
| MSG-28 | Inline dưới phần Khung giờ (SCR-06.S10) | Khung giờ của channel này vừa được sửa trên thiết bị khác | – | C01 |
| MSG-29 | SCR-08 sau Enter / Shift+Enter (S05, S06) | Đã thêm vào Hôm nay | – | Kèm icon dấu tích; khoảng 1 giây. Trước là UI-15 |
| MSG-30 | Tooltip / nhãn icon chờ đồng bộ (card, header SCR-03, dòng channel) | Chờ đồng bộ | – | QC-08 mục 7. Trước là UI-27 |
| MSG-31 | Tooltip "Khôi phục" mờ (SCR-05.S07) | Cần có mạng để khôi phục | – | O-15. Trước là UI-50 |
| MSG-32 | Ghi chú khung chờ trên dòng channel (SCR-06.S09) | Khung mới áp dụng từ {ngày} | {ngày} "Thứ Tư 11/11" | SRS SCR-06 #9. Trước là UI-58 |
| MSG-33 | Tiêu đề SCR-07 | Xoá channel {tên}? | {tên} ≤ 50, xuống 2 dòng | Trước là UI-63 |
| MSG-34 | Nội dung SCR-07 | Channel {tên} có {n} task (gồm cả task trong Lưu trữ, Thùng rác và task lặp). Chuyển các task này sang: | {n} tới "12.480" | SRS SCR-07 #1. Trước là UI-64 |
| MSG-35 | Nội dung SCR-07.S02 | Channel {tên} chưa có task nào. | – | Trước là UI-65 |
| MSG-36 | Dòng thêm SCR-07.S03 | Task chuyển sang sẽ theo lịch của channel nhận ngay từ hôm nay. Khung giờ của {tên} bị xoá cùng channel | – | BR-24, US5.3 AC07. Trước là UI-66 |
| MSG-37 | Toast bỏ hoàn thành (F-10) | Đã bỏ đánh dấu xong "{tiêu đề}" · Hoàn tác | {tiêu đề} | O-10; toast ≥ 5 giây. Trước là UI-68 |
| MSG-38 | Toast (SCR-03.S16) | Task này đã bị xoá trên thiết bị khác · Hoàn tác | – | O-01, thay MSG-09 ở UC-02 E3. Trước là UI-69 |
| MSG-39 | Inline dưới ô tên context (SCR-06.S03) | Context này đã tồn tại | – | Tên context trùng, không phân biệt hoa thường (BR-14, O-17); cùng giọng MSG-15 |
| MSG-40 | Inline dưới ô tên context (SCR-06.S03) | Tên context 1–50 ký tự | – | Tên context trống hoặc > 50 ký tự (BR-14, O-17); cùng giọng MSG-17, context không có luật "#" |
| G04 MSG-01 | Toast (CASE-12, CASE-13) | Đã chuyển "{tiêu đề}" sang {thứ, ngày} · Hoàn tác | {tiêu đề}, {thứ, ngày} | Nguồn G04; dùng cho đổi ngày trong SCR-03 (SRS UC-02 A11, O-13) |
| G04 MSG-30 | Banner board | Đang offline. Thay đổi được lưu trên máy và tự đồng bộ khi có mạng | – | Nguồn G04; G02 không vẽ banner |
| QC-MSG-01 | Tooltip icon lỗi trên card (SCR-02.S09) | Chưa lưu được thay đổi. Thử lại | – | QC-13 mục 1 |
| QC-MSG-02 | Tại chỗ (SCR-05.S04, SCR-03.S01) | Chưa tải được. Thử lại | – | QC-13 mục 1 |

MSG-05 (dự phòng) và MSG-11 (1.1) không dùng ở 1.0.

**Chữ giao diện (UI), PO duyệt 10/11/2026**

| Mã | Nơi hiện | Nội dung (VI) | Biến | Ghi chú |
|---|---|---|---|---|
| UI-01 | Nút trên cột ngày (SCR-01.S01) | Thêm task | – | Kèm icon dấu cộng; chữ từ SRS UC-01 bước 1 |
| UI-02 | Placeholder tiêu đề (SCR-01, SCR-08) | Gõ tên task hoặc dán link | – | Gộp gợi ý "Dán URL" của SRS SCR-01 #2 |
| UI-03 | Tooltip chip Ngày | Ngày dự định | – | |
| UI-04 | Tooltip chip Thời lượng, hover action thời lượng | Thời lượng | – | |
| UI-05 | Tooltip chip Channel | Channel | – | |
| UI-06 | Tooltip chip Priority, hover action priority | Priority | – | Tên mức: Urgent, Priority, Normal, Low (BR-06) |
| UI-07 | Chip Vị trí | Thêm vào đầu / Thêm vào cuối | – | Hai giá trị |
| UI-08 | Chip Ngày khi không ngày (SCR-01.S09) | Backlog | – | |
| UI-09 | Lựa chọn trong lịch chọn ngày của ô soạn | Không ngày (backlog) | – | Chữ từ SRS SCR-01 #3 |
| UI-10 | Nút tạo (SCR-01) | Thêm | – | |
| UI-11 | Nhãn đọc màn hình khi chờ gợi ý (SCR-01.S04) | Đang lấy gợi ý | – | Không hiện chữ trên màn |
| UI-12 | Tooltip và nhãn đọc màn hình của ✨ | Trợ lý AI gợi ý. Sửa để chọn giá trị khác | – | Tên trợ lý chờ D16 / #25; không dùng chữ "Claude" |
| UI-13 | Nhãn đọc màn hình dấu tải link (SCR-01.S07) | Đang đọc tiêu đề trang | – | |
| UI-14 | Dòng đầu SCR-08 | Thêm vào Hôm nay · {thứ, ngày} | {thứ, ngày} ≤ "Chủ Nhật 15/11" | |
| UI-16 | Dòng gợi ý phím SCR-08 | Enter để thêm. Shift+Enter để thêm tiếp. Esc để đóng | – | |
| UI-17 | Placeholder ô tìm (SCR-09) | Tìm channel | – | |
| UI-18 | SCR-09.S03 | Không có channel nào khớp với "{từ khoá}" | {từ khoá} cắt "…" sau 30 ký tự | |
| UI-19 | Link trong SCR-09.S03 | Quản lý channel | – | Chữ có ở G04 SCR-06 #4 |
| UI-20 | Nhãn channel ẩn (SCR-09.S04, SCR-06.S04) | Đã ẩn | – | |
| UI-21 | Dòng cuối subtask trên card (SCR-02.S03) | Còn {n} subtask | {n} ≤ 95 | |
| UI-22 | Tooltip ✓ trên card / dialog | Đánh dấu xong · C / Bỏ đánh dấu xong · C | – | Hai giá trị theo trạng thái |
| UI-23 | Tooltip hover action notes | Notes | – | |
| UI-24 | Tooltip nút … (card, header SCR-03) | Khác | – | |
| UI-25 | Chip hạn chót (card, header SCR-03) | Hạn {thứ, ngày} | Card: "Hạn 13/11"; dialog: "Hạn Thứ Sáu 13/11" | |
| UI-26 | Nhãn đọc màn hình chip quá hạn | Quá hạn, hạn {thứ, ngày} | – | |
| UI-28 | Tooltip icon / dòng link nguồn | Mở link · G | – | O-05 |
| UI-30 | Nút trên header SCR-03; tooltip | Subtask; tooltip "Thêm subtask · V" | – | Kèm icon dấu cộng |
| UI-31 | Dòng cuối danh sách subtask | Thêm subtask | – | |
| UI-32 | Nhãn thời gian (SCR-03) | Thực tế / Kế hoạch | – | Chữ từ SRS SCR-03 #3 |
| UI-33 | Kế hoạch khi chưa có thời lượng | Chưa đặt | – | |
| UI-34 | Picker thời lượng | giờ / phút / Xoá thời lượng | – | "Xoá thời lượng" từ SRS SCR-03 #3 |
| UI-35 | Placeholder notes | Thêm ghi chú | – | |
| UI-36 | Placeholder ô comment | Viết comment. Enter để gửi, Shift+Enter để xuống dòng | – | |
| UI-37 | Tiêu đề các mục trong SCR-03 | Subtask / Notes / Comment / Nhật ký | – | |
| UI-38 | Dòng nhật ký | {tác nhân} {hành động} · {thời gian tương đối} | {tác nhân}: "Bạn", "Trợ lý AI", "Hệ thống"; {hành động} ví dụ "tạo task", "đổi thời lượng 1:30 thành 2:00", "đánh dấu xong", "đánh dấu chưa xong", "nhân bản từ "{tiêu đề}"" | Mẫu từ SRS SCR-03 #8; {tiêu đề} trong nhật ký cắt 1 dòng |
| UI-39 | Cuối nhật ký | Xem thêm | – | Chữ từ SRS UC-02 A5 |
| UI-40 | Tooltip ✓ subtask đã xong | Hoàn thành lúc {giờ} | {giờ} "09:40" | Chữ từ SRS UC-02 A2 |
| UI-41 | Nhãn đọc màn hình icon xoá subtask | Xoá subtask {tiêu đề} | – | DS-08 |
| UI-42 | Tooltip nút header SCR-03 | Mở rộng / Thu nhỏ / Đóng · Esc / Hạn chót | – | |
| UI-44 | Mục menu SCR-04 | Lặp lại / Nhân bản / Sao chép link / Xoá | – | Chữ từ SRS SCR-04; phím bên phải "Ctrl+D", "Ctrl+Backspace" |
| UI-45 | Tab panel (SCR-05) | Lưu trữ / Thùng rác | – | IA-09 |
| UI-46 | Đầu SCR-05 | Thùng rác / Task đã xoá trong 30 ngày qua | – | Chữ từ SRS SCR-05 #1 |
| UI-47 | Nút trên dòng (SCR-05) | Khôi phục | – | Chữ từ SRS SCR-05 #3 |
| UI-48 | Ngày xoá trên dòng | Đã xoá {thứ, ngày} | – | |
| UI-49 | SCR-05.S03 | Không có task nào bị xoá | – | Chữ từ SRS SCR-05 #4 |
| UI-51 | Tiêu đề nhóm Cài đặt | Context & channel | – | G01 SCR-06 #3 |
| UI-52 | Nút (SCR-06) | Tạo context / Tạo channel trong {context} | {context} ≤ 50, cắt "…" | Chữ từ SRS UC-06 bước 2 |
| UI-53 | Placeholder ô tên | Tên context / Tên channel | – | |
| UI-54 | Công tắc "Riêng tư" và mô tả | Riêng tư. Sự kiện timebox của channel này ghi ra lịch ngoài ở chế độ riêng tư | – | Ở 1.0 chỉ ảnh hưởng G05 (BR-14) |
| UI-55 | Công tắc "Bật" | Hiện trong ô soạn và bộ lọc | – | |
| UI-56 | Phần Khung giờ | Khung giờ riêng / Theo lịch làm việc chung | – | Chữ từ SRS SCR-06 #7 |
| UI-57 | Tóm tắt khung đang áp trên dòng channel | {các ngày} · {giờ bắt đầu}–{giờ kết thúc} | "Thứ Hai đến Thứ Sáu · 09:00–17:00"; giờ khác nhau: "{n} ngày, giờ khác nhau" | |
| UI-59 | Nút phần Khung giờ | Lưu / Huỷ | – | Chữ từ SRS SCR-06 #10 |
| UI-60 | Mô tả dòng "Chưa phân loại" | Channel mặc định. Không xoá được, luôn theo lịch làm việc chung | – | O-07 (không đổi tên, không ẩn được) |
| UI-61 | Tooltip / nhãn icon xoá trên dòng | Xoá channel {tên} / Xoá context {context} | – | |
| UI-62 | Tên ngày trong khung giờ | Thứ Hai / Thứ Ba / Thứ Tư / Thứ Năm / Thứ Sáu / Thứ Bảy / Chủ Nhật | – | |
| UI-67 | Nút SCR-07 | Xoá channel / Huỷ | – | Chữ từ SRS SCR-07 #3, #4 |

(Không dùng mã UI-29, UI-43: đã gộp vào UI-22 và UI-38. Mã UI-15, UI-27, UI-50, UI-58, UI-63 … UI-66, UI-68, UI-69 đã thành MSG-29 … MSG-38, không dùng lại.)

## 8. Tương tác

**Phím tắt.** Phím một ký tự chỉ chạy khi không có ô nhập nào đang focus và cài đặt "Phím tắt" bật; gõ ≥ 4 ký tự trong 1 giây ngoài ô nhập thì khoá phím một ký tự 1 giây (G04 BR-17, G01 BR-15, EC-25). Lệnh trên task áp cho task đang chọn, không có thì task đang hover (G04 BR-10). Trong SCR-03, "task đang chọn" là task đang mở.

| Phím | Ở đâu | Làm gì | Nguồn |
|---|---|---|---|
| A | Board | Mở SCR-01 ở cột đang chọn (mặc định hôm nay; cột đã qua → hôm nay) | UC-01, A6, IA-20 |
| Ctrl+Shift+A | Mọi nơi trên Windows | Mở SCR-08 | UC-01 A7, D11 |
| Enter | SCR-01, SCR-08 | Tạo task | UC-01 bước 5 |
| Shift+Enter | SCR-08 | Tạo và giữ ô mở | UC-01 A7 |
| Esc | SCR-01, SCR-08 | Đóng, giữ bản nháp | UC-01 A3 |
| # | Ô tiêu đề SCR-01, SCR-08 | Mở SCR-09 | UC-01 A5 |
| ↑/↓, Enter, Esc | SCR-09, menu, picker | Chọn, xác nhận, đóng (chỉ đóng lớp trên cùng) | IA-16 |
| ↑/↓ | Board | Chọn task kề | G04 SCR-08 #6 |
| Ctrl+Enter | Task đang chọn | Mở SCR-03 | UC-02 bước 1 |
| Esc | SCR-03 | Lần 1 bỏ focus ô nhập (giữ nội dung), lần 2 đóng dialog | IA-16 |
| V | SCR-03 | Thêm subtask | UC-02 A1 |
| Enter / Esc | Dòng subtask đang gõ | Lưu và mở dòng kế tiếp / đóng dòng trống | UC-02 A1 |
| Ctrl+↑ / Ctrl+↓ | Dòng subtask đang focus | Đổi thứ tự; không toast, Ctrl+Z hoàn tác | UC-02 A3, QC-13 mục 2 |
| 1–4 | Menu priority đang mở | Chọn mức | US2.3 AC01 |
| Q, # | Task đang chọn | Mở SCR-09 | US5.2 AC01 |
| Shift+Q | Task đang chọn | Nhận channel gợi ý, mất ✨; không có gợi ý thì không làm gì (O-03) | US5.2 AC02, BR-04 |
| G | Task có link nguồn | Mở link | US1.2 AC02 |
| C | Task đang chọn | Hoàn thành; task đã xong → bỏ hoàn thành | UC-03 bước 1, A1 |
| Ctrl+D | Task đang chọn | Nhân bản | UC-05 |
| Ctrl+Backspace | Task đang chọn, **không** đang gõ trong ô nhập | Xoá (trong ô nhập, Ctrl+Backspace giữ nghĩa xoá một từ) | UC-04, BR-16 c, O-10 |
| Ctrl+Z | Không đang gõ trong ô nhập | Hoàn tác thao tác gần nhất có toast Hoàn tác còn hiện (hoàn thành, bỏ hoàn thành, xoá task, xoá subtask, đổi ngày); đổi chỗ subtask | UC-04 bước 4, BR-16 b, QC-13 mục 2; O-10 |
| Enter / Shift+Enter | Ô comment | Gửi / xuống dòng | UC-02 A4 |
| Ctrl+K | Mọi nơi trong app | Command menu: "Thêm task", nhóm Thao tác task (hoàn thành, xoá, nhân bản), "Task đã xoá gần đây" | G04 SCR-08, IA-09 |
| Shift+A | Board | Panel Lưu trữ · Thùng rác (tab Lưu trữ) | IA mục 8 |
| Ctrl+, | Mọi nơi trong app | Cài đặt (rồi chọn Context & channel) | IA-15 |

**Focus và Tab**
- **SCR-01 / SCR-08:** mở là focus vào tiêu đề. Tab: Ngày → Thời lượng → Channel → Priority → Vị trí → "Thêm"; Shift+Tab ngược lại. Mở picker bằng Enter hoặc Space trên chip.
- **SCR-03:** mở là focus vào thân dialog (không vào ô nhập), để V, C chạy ngay. Tab: chip header theo thứ tự → "Subtask" → … → mở rộng → đóng → ✓ → tiêu đề → link nguồn → "Kế hoạch" → từng dòng subtask (✓ → tiêu đề → kế hoạch → xoá) → "Thêm subtask" → notes → timebox (G05) → ô comment → nhật ký → "Xem thêm". Focus không ra khỏi dialog. Đóng thì focus về card vừa mở (SCR-02.S05).
- **SCR-05:** Tab qua từng dòng; dòng đang focus hiện "Khôi phục".
- **SCR-06:** Tab theo thứ tự đọc; mở phần Khung giờ bằng Enter trên tóm tắt khung. **SCR-07:** focus đầu ở dropdown; Esc = Huỷ.
- **"Task đang chọn"** luôn nhìn thấy được và khác hover (DS-01 "Bàn phím trước"). Lý do: phím tắt tác động lên task đang chọn; trên Sunsama gõ khi chưa focus đã kích hoạt phím tắt (#22).

**Hover, chuột phải, kéo thả**
- Hover card: hover actions (SCR-02.S04). Hover dòng subtask: icon xoá. Hover dòng Thùng rác: "Khôi phục". Hover ✓ subtask đã xong: "Hoàn thành lúc {giờ}".
- Chuột phải trên card: mở SCR-04 tại vị trí chuột (SRS SCR-02 #7, O-11).
- Kéo thả: chỉ kéo đổi thứ tự subtask trong SCR-03 (không toast, Ctrl+Z, QC-13 mục 2). Kéo card thuộc G04.

**Toast và Hoàn tác** (QC-13)

| Thao tác | Toast | Hoàn tác | Ghi chú |
|---|---|---|---|
| Hoàn thành (✓, C) | MSG-08 | Có, ≥ 5 giây, và Ctrl+Z | O-10 |
| Bỏ hoàn thành | MSG-37 (+ MSG-24 dòng 2 khi instance trùng series) | Có, ≥ 5 giây, và Ctrl+Z | O-10, O-08 |
| Xoá task | MSG-09 | Có, ≥ 5 giây, và Ctrl+Z | Task bị xoá trên thiết bị khác khi đang mở: MSG-38 (O-01) |
| Xoá subtask | MSG-21 | Có, ≥ 5 giây, và Ctrl+Z khi toast còn hiện | O-10 |
| Đổi ngày trong SCR-03 | G04 MSG-01 (+ MSG-24 dòng 2) | Có, và Ctrl+Z | O-13 |
| Tạo vào backlog | MSG-07 | Không; nút "Mở Backlog" | |
| Khôi phục từ Thùng rác | MSG-13 (+ MSG-24 dòng 2) | Không | |
| Sao chép link | MSG-18 | Không | |
| Xoá channel | MSG-19 | Không; đã có dialog xác nhận | |
| Nhân bản | Không có toast | Không | Bản sao mở ngay là đủ báo |
| Đổi thứ tự subtask | Không có toast | Ctrl+Z | QC-13 mục 2 |
| Lỗi lưu | MSG-10 | "Thử lại" | QC-MSG-01 |

- Hai thông báo cùng lúc gộp **một** toast: dòng 1 là kết quả chính và giữ nút của nó, dòng 2 là thông tin phụ (QC-13 mục 3).
- Hoàn tác đưa dữ liệu về đúng trạng thái ngay trước thao tác (QC-13 mục 5).
- Cửa sổ app đang ẩn ở khay / thu nhỏ: toast không bật lên mà vào trung tâm thông báo; nút có thời hạn (Hoàn tác) không mang theo (IA-21, F6).

**Thời gian**
- Gợi ý AI gọi sau 400 ms ngừng gõ, bỏ nếu quá 2 giây (UC-01 bước 4, A4; `[giả định]`).
- Đọc tiêu đề link tối đa 3 giây (PRD mục 9).
- Card hiện ≤ 100 ms sau Enter (cập nhật lạc quan); SCR-03 mở ≤ 500 ms (SRS mục 10).
- Notes lưu sau 1 giây ngừng gõ `[giả định]`; các trường khác lưu khi rời trường hoặc chọn xong.
- Thay đổi từ thiết bị khác hiện ≤ 5 giây; lưu khung giờ → projection / sức chứa tính lại ≤ 1 giây (SRS mục 10).
- SCR-08 hiện MSG-29 "Đã thêm vào Hôm nay" khoảng 1 giây rồi đóng (IA-19).

**Mất mạng** (QC-08 mục 7)
- Tạo, sửa, hoàn thành, xoá task, sửa khung giờ channel chạy ngay trên máy, vào hàng đợi, kèm dấu "Chờ đồng bộ" ở nơi vừa đổi: góc card (SCR-02.S08), header dialog (SCR-03.S18), dòng channel (SCR-06.S11).
- Banner offline là banner chung của board (G04 MSG-30); G02 không có banner riêng.
- Sửa cả chuỗi lặp cần mạng: mục lặp trong SCR-04 mờ, tooltip theo G03.
- Nhân bản khi mất mạng chạy trên máy (bản sao mở ngay, dấu "Chờ đồng bộ", SCR-03.S18); khôi phục từ Thùng rác cần mạng: nút "Khôi phục" mờ, tooltip MSG-31 (SCR-05.S07). Nguồn: SRS UC-05 E2, UC-04 E5 (O-15).

**Chuyển động** (DS-16, chỉ để giải thích việc vừa xảy ra)
- Hoàn thành: ✓ nở nhẹ tại chỗ (khi bật hiệu ứng chúc mừng, G01); task thường ở ngày khác bay về cột Hôm nay. Xong task cuối cùng của hôm nay: hiệu ứng lớn hơn một lần.
- Xoá task, xoá subtask, khôi phục dòng Thùng rác: dòng thu lại; Hoàn tác thì hiện lại tại chỗ.
- Windows tắt hoạt ảnh: mọi chuyển động thay bằng mờ dần ≤ 120 ms, không có hiệu ứng chúc mừng lớn.

**Khả năng truy cập** (DS-08)
- Icon không chữ có nhãn cho Narrator: ✓ (UI-22), ✨ (UI-12), xoá subtask (UI-41), chờ đồng bộ (MSG-30), lỗi lưu (QC-MSG-01), link (UI-28), … (UI-24), mở rộng / đóng (UI-42), xoá channel (UI-61), chấm màu channel (đọc tên channel).
- Màu không bao giờ là dấu hiệu duy nhất: quá hạn có icon (UI-26), ✨ là hình, chip "AI" có chữ, lỗi có icon.
- Mọi thao tác chuột có phím thay: đổi thứ tự subtask (Ctrl+↑/↓), mở menu Khác (Tab tới nút … rồi Enter), hoàn thành (C), xoá (Ctrl+Backspace), chọn channel (Q).
- Kiểm tra bố cục ở text scaling 150% của Windows và với chuỗi "Ếch ỗng Ữ Ặ".

## 9. Component dùng trong brief

Tầng theo [knowledge base component / snowflake](../design-system/00-knowledge-base-components-snowflakes.md): DS = design system dùng chung, Snowflake = gắn nghiệp vụ app.

| Component | Tầng | Dùng ở | Biến thể / trạng thái cần có |
|---|---|---|---|
| `Button` | DS (đã có trong code: `variant=primary\|secondary`, `size=md\|sm`, `disabled`) | "Thêm" SCR-01 (`primary` `sm`); "Khôi phục" SCR-05 (`secondary` `sm`); "Lưu" / "Huỷ" khung giờ (`primary` / `secondary` `sm`); "Huỷ" SCR-07 (`secondary` `md`); "Xoá channel" SCR-07 (`danger` `md`) | `variant=danger` đã ghi vào [nền tảng design system](01-nen-tang-design-system.md#8-quy-ước-đặt-tên-component) mục 8 (O-18), code chưa có; trạng thái hover, focus, pressed, disabled |
| `Button/Icon` | DS (chưa có) | Hover actions card, nút … , mở rộng, đóng, icon xoá subtask / channel | `size=sm\|md`, `tone=neutral\|danger`; luôn có nhãn đọc màn hình |
| `Input/Multiline` | DS | Tiêu đề SCR-01, SCR-08, SCR-03; ô comment | trống có placeholder, đang gõ, lỗi, disabled |
| `Input/Text` | DS | Ô tìm SCR-09, tên context / channel SCR-06 | trống, đang gõ, lỗi |
| `Input/Switch` | DS (nhóm DS-09 chưa có Switch, đề xuất đặt trong Input) | Riêng tư, Bật, Khung giờ riêng, công tắc từng ngày | bật, tắt, disabled, focus |
| `Chip/Attribute` | DS | Hàng chip SCR-01, SCR-08; header SCR-03 | chỉ icon, có giá trị, có ✨, `tone=warning` (MSG-06, S11 ngày đã qua), `tone=danger` (quá hạn), focus |
| `Chip/Channel` | Snowflake | Card, SCR-01, SCR-03, SCR-05 | 12 màu + "Chưa phân loại" xám, tên dài cắt "…", có ✨ |
| `Chip/Priority` | Snowflake | Card | Urgent, Priority, Low (Normal không hiện) |
| `Chip/Due` | Snowflake | Card | thường, quá hạn (icon + `tone=danger`) |
| `Chip/AI` | Snowflake (G10 định nghĩa nội dung) | Card SCR-02.S10 | mặc định, hover, đã hoàn tác (gạch ngang, G10) |
| `Badge/AI` | Snowflake | Dấu ✨ trong chip và trường | – |
| `Badge/Duration` | Snowflake | Card | "planned", "actual / planned", đã xong (mờ) |
| `Combobox/Channel` | Snowflake | SCR-09, dropdown SCR-07 | đầy đủ, đang lọc, không kết quả, có dòng "Đã ẩn", dòng đang chọn |
| `Picker/Date` | DS | Chip Ngày SCR-01, Hạn chót SCR-03 | ngày đã qua disabled, lựa chọn "Không ngày (backlog)" (chỉ ô soạn), hôm nay nổi bật |
| `Picker/Duration` | Snowflake | Chip Thời lượng, "Kế hoạch" SCR-03 | ô giờ + ô phút, preset, "Xoá thời lượng", lỗi MSG-02 |
| `Picker/Time` | DS | Khung giờ SCR-06 | bước 15 phút, lỗi MSG-25 |
| `Picker/Color` | DS | Màu channel SCR-06 | 12 màu, đang chọn, màu đã dùng |
| `Menu/Priority` | Snowflake | Chip Priority | 4 mức, phím 1–4 bên phải |
| `Menu/Context` | DS | SCR-04 | mục thường, mục nguy hiểm, phím tắt bên phải, mục mờ có tooltip |
| `Checkbox/Task` | Snowflake | ✓ task (lớn), ✓ subtask (nhỏ) | chưa xong, xong, hover, focus, nở khi hoàn thành |
| `List/Subtask` | Snowflake | SCR-03 | dòng thường, xong, hover (icon xoá), đang kéo, đang gõ (dòng mới), focus |
| `List/TrashItem` | Snowflake | SCR-05 | thường, hover / focus (nút "Khôi phục"), mất mạng (nút mờ) |
| `List/ChannelRow` | Snowflake | SCR-06 | thường, "Chưa phân loại", đã ẩn, đang sửa tên, lỗi, chờ đồng bộ, có khung chờ |
| `List/WorkWindowDay` | Snowflake | Phần Khung giờ SCR-06 | ngày bật, ngày tắt, lỗi (MSG-25) |
| `Editor/RichText` | DS | Notes | trống có placeholder, có nội dung, lỗi MSG-03 |
| `Card/Task` | Snowflake (G04 sở hữu card đầy đủ) | SCR-02 | các trạng thái SCR-02.S01 … S10 |
| `Panel/QuickAdd` | Snowflake | SCR-08 | trống, đang gõ, đã thêm |
| `Dialog` | DS | SCR-03 (thường, mở rộng), SCR-07 (nhỏ) | có header thuộc tính, xác nhận nguy hiểm |
| `Nav/Tabs` | DS | Panel Lưu trữ · Thùng rác | tab đang chọn, focus |
| `Toast` | DS | Mọi MSG toast | chỉ chữ, có một nút, hai dòng (gộp QC-13 mục 3) |
| `Icon/SyncState` | Snowflake | Card, header SCR-03, dòng channel | chờ đồng bộ, lỗi |
| `Skeleton` | DS | SCR-03.S01, SCR-05.S01 | dòng, khối |

## 10. Tham chiếu nghiệp vụ

| Chủ đề | Nguồn |
|---|---|
| Giới hạn thuộc tính | G02 BR-01, PRD mục 5 |
| Ngày của task mới, backlog, vị trí | G02 BR-02, BR-03; G01 SCR-07 #8 "Vị trí task mới" |
| Gợi ý AI và điều kiện | G02 BR-04, G10 BR-30, QC-12 mục 1–2, 7, Q33 |
| Channel mặc định "Chưa phân loại" | G02 BR-05, BR-14, B4, D3 |
| Priority, due | G02 BR-06, BR-07 |
| Hoàn thành, bỏ hoàn thành | G02 BR-08, BR-09, QC-03 mục 4, QC-05, QC-07, Q12, Q25 |
| Nhân bản | G02 BR-10, C11 |
| Xoá, khôi phục, Thùng rác | G02 BR-11, BR-12, QC-03 mục 3, QC-05, Q28 |
| Nhật ký | G02 BR-13, G10 BR-07 |
| Subtask | G02 BR-17, C9 |
| Trạng thái task | QC-03, SRS G02 mục 4 |
| Đồng bộ, offline | G02 BR-19, QC-08 (mục 7: mất mạng) |
| Ngày làm việc, "hôm nay" | G02 BR-20, QC-01 |
| AI hoàn thành / xoá | G02 BR-21, QC-12 mục 4–5, F4, D10 |
| Khung giờ channel | G02 BR-22 – BR-24, QC-02 mục 5–9, D1–D4, Q38a |
| Phím tắt | G02 BR-16, G04 BR-10, BR-17, G01 BR-15, EC-25, IA mục 8, D11 |
| Toast, Hoàn tác, chữ lỗi chung | QC-13, A1–A10 |
| Bề mặt và điểm vào | IA-06, IA-09, IA-16, IA-19, IA-20, IA-21 |
| Giọng văn, tên component, truy cập, chuyển động | DS-07, DS-09, DS-08, DS-16 |
| Kiểm chứng Sunsama | [`kiem-chung-sunsama-chrome.md`](../research/kiem-chung-sunsama-chrome.md) mục G02 |

## 11. Câu hỏi đã chốt

**PO duyệt ngày 10/11/2026: mọi câu chốt theo cột "Đề xuất của brief"** (cột "Chốt 10/11/2026" ghi nơi đã ghi ngược). Brief không còn câu hỏi mở. Cột "Câu hỏi" và "Đề xuất của brief" giữ nguyên chữ lúc hỏi, nên còn mã cũ (UI-xx, MSG-09).

| Mã | Câu hỏi | Ảnh hưởng tới | Đề xuất của brief | Ai chốt | Chốt 10/11/2026 |
|---|---|---|---|---|---|
| O-01 | Task bị xoá trên thiết bị khác khi đang mở chi tiết: SRS UC-02 E3 dùng MSG-09 "Đã xoá · Hoàn tác (Ctrl+Z)", nghe như chính người dùng vừa xoá | SCR-03.S16 | Dùng UI-69 "Task này đã bị xoá trên thiết bị khác · Hoàn tác" | PO, sửa SRS G02 | Theo đề xuất. Chữ UI-69 thành MSG-38; SRS UC-02 E3 dùng MSG-38 thay MSG-09 |
| O-02 | Bản nháp ô soạn mất khi nào (đóng app, ngày của cột thành ngày đã qua)? | SCR-01.S10, SCR-08.S02 | Giữ trên máy, mỗi ngày một bản nháp, tới khi tạo task hoặc xoá hết chữ; ngày thành ngày đã qua thì bản nháp chuyển sang ô soạn hôm nay | PO, ghi SRS UC-01 A3 | Theo đề xuất. Ghi SRS UC-01 A3, PRD US1.1 AC04, PRD mục 10 |
| O-03 | Shift+Q "nhận channel gợi ý": giá trị giữ ✨ (nguồn `ai`) hay mất ✨ (nguồn `user`)? Không có gợi ý thì làm gì? | CASE-26 | Mất ✨ vì người dùng đã chủ động nhận; không có gợi ý thì không làm gì | PO, ghi SRS BR-04 | Theo đề xuất. Ghi SRS BR-04, PRD US5.2 AC02 |
| O-04 | Giữ comment ở 1.0 không, khi chỉ có một người dùng? (PRD mục 10) | SCR-03 vùng #8 | Giữ theo SRS, đặt sau notes; bỏ được mà không đổi bố cục phía trên | PO | Theo đề xuất. Ghi PRD mục 10 |
| O-05 | Link nguồn hiện ở đâu? SRS SCR-02, SCR-03 chưa có thành phần cho link | SCR-02 hàng chip, SCR-03.S14 | Icon link trên card; dòng tên miền dưới tiêu đề trong SCR-03; bấm hoặc G mở | PO, thêm vào SRS SCR-02, SCR-03 | Theo đề xuất. Thêm SRS SCR-02 #12, SCR-03 #9; PRD US1.2 AC02 |
| O-06 | Có chọn nhiều task để xoá / đổi channel cùng lúc ở 1.0 không? (PRD mục 10) | SCR-02.S05 | Không ở 1.0 | PO | Theo đề xuất. Ghi PRD mục 3.2 và mục 10 |
| O-07 | "Chưa phân loại" có đổi tên / ẩn được không, thuộc context nào? (PRD mục 10, BR-14 `[giả định]`) | SCR-06.S01, SCR-09 | Không đổi tên, không ẩn; đứng riêng ở đầu, không thuộc context | PO, bỏ `[giả định]` BR-14 | Theo đề xuất. Bỏ `[giả định]` ở SRS BR-14; PRD US5.1 AC06, mục 10 |
| O-08 | Bỏ hoàn thành ở ngày làm việc khác đưa instance lặp về hôm nay, mà hôm nay đã có instance cùng series: đường tự động (`skipped`) hay thủ công (cảnh báo)? (PRD mục 10) | F-10, toast | Thủ công: vẫn về hôm nay, MSG-24 ở dòng 2 toast, vì người dùng chủ động | PO, ghi SRS BR-09 | Theo đề xuất. Ghi SRS BR-09, PRD US3.2 AC05, mục 10 |
| O-09 | Xoá subtask đã có bản ghi thời gian: "Thực tế" của task có trừ phần đó không? (PRD mục 10) | SCR-03 vùng Thời gian | Trừ (như task đã xoá, QC-07 mục 5); Hoàn tác cộng lại | PO, ghi QC-07 | Theo đề xuất. Ghi QC-07 mục 5, PRD US2.2 AC08, mục 10 |
| O-10 | Phím tắt có tác dụng phụ: (a) bỏ hoàn thành bằng ✓ / C có toast Hoàn tác không (BR-16 nói C luôn có toast, SRS chưa có MSG)? (b) Ctrl+Z hoàn tác cả hoàn thành và xoá subtask không? (c) Ctrl+Backspace khi đang gõ trong ô nhập là xoá task hay xoá một từ? | F-10, mục 8 | (a) Có, UI-68; (b) Ctrl+Z hoàn tác thao tác gần nhất có toast Hoàn tác còn hiện; (c) trong ô nhập là xoá một từ, không xoá task | PO, ghi SRS BR-16, thêm MSG | Theo đề xuất. Ghi SRS BR-16, UC-03 A1; chữ UI-68 thành MSG-37; PRD US3.2 AC04 |
| O-11 | Chuột phải trên card có mở menu "Khác" không? SRS không nói; G03 nói card có nút … | SCR-02.S04, SCR-04 | Có: chuột phải mở SCR-04; nút … có trong hover actions | PO, thêm vào SRS SCR-02 #7 | Theo đề xuất. Ghi SRS SCR-02 #7 |
| O-12 | G10 SCR-09 #3 ghi "Gợi ý thời lượng (task, subtask)" nhưng G02 không có gợi ý cho subtask; G02 BR-04 nói một "cài đặt gợi ý", G10 có hai công tắc | SCR-03 subtask, SCR-01 | 1.0 chỉ gợi ý cho task; hai công tắc độc lập: tắt "Gợi ý channel" thì chỉ chip Channel không có ✨ | PO, sửa G10 SCR-09 hoặc G02 BR-04 | Theo đề xuất. Sửa G10 SCR-09 #2, #3 và BR-30; G02 BR-04 trỏ về hai công tắc |
| O-13 | Đổi ngày dự định trong header SCR-03 có toast Hoàn tác không? UC-02 A11 chỉ nói MSG-24; PRD 4.3 nói đổi ngày có Hoàn tác | CASE-12, CASE-13 | Có: toast G04 MSG-01 như "chọn ngày" ở board, MSG-24 ở dòng 2 | PO, ghi SRS UC-02 A11 | Theo đề xuất. Ghi SRS UC-02 A11 |
| O-14 | Popover channel không có kết quả: có lối "Tạo channel {từ khoá}" không? | SCR-09.S03 | Không ở 1.0; chỉ có link "Quản lý channel" | PO | Theo đề xuất. Ghi PRD US5.2 AC04, mục 10; SRS SCR-09 #5 |
| O-15 | Nhân bản và khôi phục từ Thùng rác khi mất mạng: UC-04, UC-05 chưa có nhánh E# mất mạng (QC-08 mục 7 yêu cầu); UC-02 chỉ nói gián tiếp ở E5 | SCR-03.S18, SCR-05.S07 | Nhân bản chạy trên máy, "Chờ đồng bộ" (đã có idempotency key); khôi phục cần mạng, nút mờ, UI-50 | PO, thêm E# vào SRS UC-02, UC-04, UC-05 | Theo đề xuất. Thêm SRS UC-02 E8, UC-04 E5, UC-05 E2; chữ UI-50 thành MSG-31 |
| O-16 | Thứ tự tên mức priority và tên tiếng Anh "Urgent, Priority, Normal, Low" trên giao diện tiếng Việt (DS-07: không pha tiếng Anh ngoài thuật ngữ đã chốt) | `Chip/Priority`, `Menu/Priority` | Giữ như BR-06 (đã dùng trong PRD); ghi "priority" vào CONTEXT.md nếu giữ | PO | Theo đề xuất. Ghi `CONTEXT.md` (Priority), PRD US2.3 AC01, mục 10 |
| O-17 | Quy tắc tên context (độ dài, trùng) chưa có trong SRS; MSG-17 chỉ nói channel | SCR-06.S03 | Như channel: 1–50 ký tự, không trùng (không phân biệt hoa thường) | PO, ghi SRS BR-14 | Theo đề xuất. Ghi SRS BR-14, PRD US5.1 AC07. Chữ lỗi cho tên context: MSG-39, MSG-40 (SRS BR-14, UC-06 E1, E2, SCR-06 #2) |
| O-18 | `Button` trong code chỉ có `primary` / `secondary`; "Xoá channel" (SCR-07) cần kiểu nguy hiểm | SCR-07, mục 9 | Thêm `variant=danger` vào `Button` trong design system | PO (design system) | Theo đề xuất. Ghi nền tảng design system mục 8 (chỉ tài liệu, code chưa sửa) |
| O-20 | Khung giờ channel: giờ kết thúc chọn được 24:00 không? BR-22 nói "không vắt qua nửa đêm (24:00)" nhưng không rõ 24:00 có nằm trong ngày | `Picker/Time` SCR-06 | Cho chọn 24:00 làm giờ kết thúc, để có khung tới hết ngày | PO, ghi SRS BR-22 | Theo đề xuất. Ghi SRS BR-22, SCR-06 #8 |
| O-19 | Ghi ngược vào SRS khi PO duyệt brief (không phải câu hỏi) | SRS G02 | Thêm mã SCR cho ô thêm nhanh toàn cục và popover chọn channel (mã tạm `SCR-Nxx`); đổi UI-xx đã duyệt thành MSG (A7), nhất là UI-15, UI-27, UI-58 đã có chữ trong SRS mà chưa có mã | BA | Đã làm. SRS G02 thêm SCR-08, SCR-09; UI-15, UI-27, UI-50, UI-58, UI-63 … UI-66, UI-68, UI-69 thành MSG-29 … MSG-38; chữ nhãn tĩnh giữ mã UI-xx trong brief (SRS mục 7 trỏ về brief) |

## 12. Kiểm tra trước khi giao

Tích lại ngày 10/11/2026, sau khi PO duyệt và đã ghi ngược mục 11; tích lại lần nữa cùng ngày sau khi PO duyệt nốt các `[đề xuất]` còn lại.

- [x] Mỗi màn ở mục 3 có bảng trạng thái và dữ liệu mẫu (9 / 9 màn).
- [x] Mỗi trạng thái có chữ (MSG / UI) cho mọi chỗ hiện chữ. Hai chỗ chữ tạm đã chốt: SCR-03.S16 dùng MSG-38 (O-01), F-10 dùng MSG-37 (O-10). Lỗi tên context (trùng, quá 50 ký tự, trống) theo BR-14 (O-17) có MSG-39, MSG-40 ở SCR-06.S03, thêm ngày 10/11/2026.
- [x] Mỗi flow ở mục 5 trỏ tới sơ đồ UC trong `flow/` (F-01 … F-06 → UC-01; F-07, F-08, F-17 → UC-02; F-09, F-10 → UC-03; F-11, F-12 → UC-04; F-13 → UC-05; F-14 … F-16 → UC-06). Đã kiểm lại anchor với tiêu đề trong file flow ngày 10/11/2026.
- [x] Mọi luồng thay thế (A#) và luồng lỗi (E#) trong SRS của UC-01 … UC-06 đều có trong mục 4 hoặc mục 6, trừ UC-01 E5 (chỉ đọc, 1.1, không vẽ) và UC-04 E2 (SRS đã bỏ). Nhánh mới ngày 10/11/2026: UC-02 E8 → SCR-03.S18; UC-04 E5 → SCR-05.S07, F-11; UC-05 E2 → SCR-03.S18, F-13.
- [x] Không còn `[đề xuất]` chưa duyệt. Mọi `[đề xuất]` gắn với câu O và mọi chữ UI-xx đã bỏ nhãn. Các chi tiết hành vi không thuộc câu O nào (Enter khi đang đọc link, chip Vị trí ẩn khi chọn backlog, so khớp không phân biệt dấu, channel ẩn khác không hiện, F-02 không mang giá trị sang task kế tiếp, SCR-08 không có chip Ngày / Vị trí và không có nút "Thêm", nút "Khôi phục" chỉ hiện khi hover / focus, màu kế tiếp cho channel mới, MSG-27 chờ server nhận mới hiện ngày, Enter không tự xoá ở SCR-07, gợi ý về muộn không điền vào task đã tạo) và cách trình bày (tooltip chip channel dài, header dialog luôn hiện khi cuộn, cửa sổ SCR-08 cao tối đa 5 dòng) PO đã duyệt ngày 10/11/2026, bỏ nhãn; chi tiết hành vi đã ghi vào SRS G02 (UC-01 bước 7, A1, A4; UC-06 E6; SCR-01 #8, SCR-05 #3, SCR-06 #3, SCR-07 #2, SCR-08 #3, #4, SCR-09 #4; SCR-09 #3 đã có sẵn), SRS bỏ `[giả định]` ở UC-01 bước 7, UC-06 E6, SCR-08 #3, #4, SCR-09 #4.
- [x] Không còn câu hỏi mở chặn luồng chính (mục 11 đã chốt hết).
