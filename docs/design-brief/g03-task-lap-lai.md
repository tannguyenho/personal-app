# Brief G03 Task lặp lại

> **Mã:** PLN-BRIEF-G03 · **Trạng thái:** đã duyệt 10/11/2026 · **Phiên bản:** 1.0
> **Nguồn:** [prd-g03](../features/prd-g03-task-lap-lai.md), [srs-g03](../features/srs-g03-task-lap-lai.md) (commit `ac483dd`, đã ghi ngược chốt 10/11/2026), QC-01, QC-03, QC-04, QC-05, QC-06, QC-08, QC-13 ([quy tắc dùng chung](../01-quy-tac-dung-chung.md)); quyết định Q7, Q12, Q26, Q35, Q43, Q44, Q45, B5, C12, C13, C14 ([04/11](../review/quyet-dinh-chot-2026-11-04.md)), A1, A3, A6, B08, B14, B15, B16, C10 … C16 ([09/11](../review/cau-hoi-chot-flow-2026-11-09.md))
> **Phụ thuộc:** [kiến trúc thông tin](00-kien-truc-thong-tin.md) (#7, đã duyệt), [nền tảng design system](01-nen-tang-design-system.md) (#8, đã duyệt), [brief G02](g02-quan-ly-task.md) (đã duyệt 10/11/2026), brief G01, G04, G05, G06, G07, G08 (chưa viết; G03 chỉ trỏ điểm nối)
> **Flow:** [flow/g03-task-lap-lai.md](flow/g03-task-lap-lai.md) (Mermaid, theo [quy ước](flow/_quy-uoc.md)) · **FigJam:** `[chờ]`
>
> Brief chỉ vẽ phần G03 thêm vào màn của G02 (menu "Khác", chi tiết task, task card); phần G02 đã duyệt không vẽ lại.
>
> **PO duyệt ngày 10/11/2026:** mọi câu O-01 … O-21 ở mục 11 chốt theo đề xuất của brief (O-11 chọn phương án tính {n} trên máy, không thêm `dryRun`) và đã ghi ngược vào PRD / SRS G03, SRS G02 SCR-04 #1, UC-02 E3, brief G02 SCR-04.S02, SRS G01 SCR-06 #1, kiến trúc thông tin, `CONTEXT.md`. Màn mang mã tạm (mục "Lặp lại") thành **SCR-09** của SRS G03; chữ thông báo UI-25 … UI-28 thành **MSG-29 … MSG-35** (O-21). Các chi tiết `[đề xuất]` không thuộc câu O nào vẫn giữ nhãn, chờ PO duyệt riêng (danh sách ở mục 12).

## 1. Tóm tắt cho người vẽ

Người dùng biến một task có sẵn thành task lặp: menu … → "Lặp lại" → chọn quy tắc → "Lưu". Hệ thống sinh sẵn các lần (instance) trên 60 ngày tới; mỗi card có dấu lặp. Mở một lần thì đầu chi tiết task có banner series: lặp thế nào, đây là lần thứ mấy, "Trước" / "Sau", "Sửa series". Sửa một lần chỉ đổi lần đó, không hỏi gì. Muốn đổi cả chuỗi thì vào menu "Sửa series", hoặc Cài đặt → Task lặp lại.

Ba khoảnh khắc quan trọng nhất:
- **Bật lặp ≤ 10 giây** (PRD mục 1.3, mục 8). Picker gọn, mặc định suy từ ngày của task, có một câu đọc lại quy tắc và ngày lần đầu trước khi bấm "Lưu".
- **Sửa một là một** (PRD mục 4.1). Không có hộp hỏi "chỉ lần này hay tất cả".
- **Thao tác cả chuỗi nói rõ hậu quả và có Hoàn tác.** Toast nêu số lần bị đổi, dòng 2 nêu số lần được giữ (BR-09, MSG-24). Mất mạng thì các thao tác này mờ đi, không chạy nửa vời (QC-08 mục 7).

## 2. Phạm vi của brief

**Trong brief**
- Màn: SCR-09 Mục "Lặp lại", SCR-01 Picker lặp lại, SCR-06 Dấu lặp trên task card, SCR-02 Banner series, SCR-03 Menu "Sửa series", SCR-07 Bộ chọn giờ bắt đầu, SCR-04 Xác nhận xoá instance chưa xong, SCR-08 Xác nhận dừng lặp, SCR-05 Quản lý mọi task lặp.
- Flow: F-01 … F-17 (mục 5), phủ UC-01 … UC-07.
- Job sinh instance (UC-02) và quy tắc instance trùng series (UC-06, QC-06) không có màn riêng: brief chỉ vẽ kết quả người dùng thấy (SCR-06, toast của nhóm khác), mục 6.

**Không trong brief, chỉ ghi điểm nối**

| Phần | Brief | Điểm nối trong G03 |
|---|---|---|
| Menu "Khác" (phần còn lại), dialog chi tiết task, card, hoàn thành / bỏ hoàn thành, xoá, Thùng rác, nhân bản, nhật ký | G02 (đã duyệt) | SCR-09 là mục đầu của G02 SCR-04; SCR-02 là vùng #2 của G02 SCR-03 (G02 SCR-03.S13); SCR-06 nằm trên card (G02 SCR-02) |
| Giờ projection, instance "Dự kiến" ở ngày ngoài 60 ngày (G04 BR-23), kéo thả, phím D và toast G04 MSG-24, command menu, banner offline | G04 | SCR-06 #2 lấy giờ projection khi không có giờ khoảng; lệnh "Lặp lại" trong command menu (SCR-09) |
| Timebox, sửa giờ timebox (làm instance thành sửa riêng, Q44), lập lịch cứng cho task lặp (1.1) | G05 | CASE-20, CASE-32 |
| Rollover, Lưu trữ (nhãn "Đã bỏ qua"), khôi phục từ Lưu trữ, chi tiết chỉ xem (G06 SCR-08), banner lỗi rollover | G06 | F-16; CASE-34 … CASE-38, CASE-42 |
| Dừng timer khi dừng hoặc đổi series | G07 | CASE-30 |
| Shutdown "Ngày mai" (G08 UC-02 A9) | G08 | CASE-40 |
| Cài đặt "Ngày đầu tuần", khung lớp phủ Cài đặt | G01 | SCR-01 (thứ tự nút thứ, MSG-26); SCR-05 nằm trong Cài đặt (O-14) |

**Bản sau hoặc không có, không vẽ (QC-13 mục 6: ẩn hẳn, không hiện mờ):** chế độ chỉ đọc (UC-01 E6, UC-02 A4, MSG-13; 1.1, QC-09); lập lịch cứng (UC-02 A1, BR-06; G05, 1.1, Q7); "Gắn cho cả series" một objective (G09 BR-25, 1.1); task lặp giao cho người khác, nhiều thành viên (BR-14; bản sau, Q35); ngày kết thúc series, lặp theo ngày hoàn thành, lặp theo lịch làm việc (SRS mục 1 "Ngoài phạm vi"; O-20). UC-02 E2 SRS đã bỏ (C10). Người vẽ không cần chừa chỗ trong picker.

**Khác Sunsama có chủ đích, người vẽ cần biết** ([kiểm chứng](../research/kiem-chung-sunsama-chrome.md) mục G03)

| App | Sunsama | Nguồn |
|---|---|---|
| Nhãn "Thứ Hai–Thứ Sáu", không gọi "Ngày làm việc"; luôn Thứ Hai đến Thứ Sáu, không theo lịch làm việc | "Weekdays" | Q43, BR-01 |
| Có "Mỗi N ngày" và mỗi 1–99 tuần / tháng / năm | Không có "mỗi N ngày"; tuần chỉ có một số khoảng cố định | BR-01, #22-C17 |
| "Dừng lặp" xoá các lần tương lai chưa động tới (kể cả lần đang mở nếu nó ở tương lai và chưa động tới, CASE-29), giữ lần đã dời / sửa riêng / có thời gian thực tế; có Hoàn tác | Giữ tới lần đang mở, xoá các lần sau; không Hoàn tác | B14, BR-09, #22-C19 |
| "Xoá mọi lần chưa xong và dừng lặp" có hộp xác nhận và Hoàn tác | Không hỏi, không Hoàn tác | C13, BR-09, #22-C19 |
| Xoá một lần thì ngày đó thành ngày ngoại lệ, lần đó vào Thùng rác 30 ngày | Lần tương lai bị xoá không vào Thùng rác | Q26, BR-15, #22-C20 |
| Hoàn thành một lần ở ngày tương lai giữ nguyên ngày đó | Về hôm nay | Q12, #22-C2 |

## 3. Danh sách màn hình

| Mã | Màn | Bề mặt (IA) | Điểm vào | Số trạng thái | Ưu tiên vẽ |
|---|---|---|---|---|---|
| SCR-09 | Mục "Lặp lại" (trong G02 SCR-04 và command menu) | Mục menu trong popover "Khác"; lệnh trong command menu | Nút … trên card / header chi tiết task; chuột phải trên card; Ctrl+K | 5 | P1 |
| SCR-01 | Picker lặp lại | Popover (IA mục 5) gắn vào chỗ gọi | SCR-09; SCR-03 "Đổi tần suất"; menu dòng SCR-05 "Đổi tần suất" | 16 | P1 |
| SCR-06 | Dấu lặp trên task card (phần G03) | Trên card (G04 `Card/Task`) | Mọi instance trên board, Today, panel Tasks | 8 | P1 |
| SCR-02 | Banner series | Vùng #2 của dialog chi tiết task (G02 SCR-03) | Mở chi tiết một instance | 9 | P1 |
| SCR-03 | Menu "Sửa series" | Popover (IA mục 5) | Link "Sửa series" trên SCR-02 | 5 | P1 |
| SCR-07 | Bộ chọn giờ bắt đầu | Popover cạnh mục menu | SCR-03 "Đặt giờ bắt đầu" | 5 | P2 |
| SCR-04 | Xác nhận xoá instance chưa xong | Dialog xác nhận nhỏ (IA mục 5) | SCR-03 "Xoá mọi lần chưa xong và dừng lặp" | 6 | P2 |
| SCR-08 | Xác nhận dừng lặp (từ danh sách) | Dialog xác nhận nhỏ | Menu dòng SCR-05 "Dừng lặp" | 6 | P2 |
| SCR-05 | Quản lý mọi task lặp | Nhóm "Task lặp lại" trong lớp phủ Cài đặt (IA mục 5) | SCR-03 "Quản lý mọi task lặp"; Cài đặt → Task lặp lại; link trong MSG-14 | 11 | P2 |

**Tổng:** 9 màn, 71 trạng thái. SCR-09 là mã SRS G03 đặt khi PO duyệt (chốt 10/11/2026, O-21); trước đó brief dùng mã tạm vì SRS chỉ có mục "Lặp lại" ở bước 1 của UC-01 và ở G02 SCR-04 #1.

## 4. Màn hình và trạng thái

### SCR-09 Mục "Lặp lại"

**Mục đích.** Điểm vào để bật lặp, hoặc đổi tần suất nếu task đã lặp.

**Cấu trúc.** Mục đầu của G02 SCR-04 (chữ UI-01, icon lặp bên trái), thứ tự menu theo brief G02. Trong command menu: lệnh "Lặp lại" (UI-01) ở nhóm Thao tác task (G04 SCR-08 #3), áp cho task đang chọn, không có thì task đang hover (SRS mục 6). Không có phím tắt một ký tự riêng. Task ở Lưu trữ mở chi tiết chỉ xem (G06 SCR-08) và task ở Thùng rác không có menu "Khác", nên không có trạng thái cho hai trường hợp này.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì (khác trạng thái mặc định ở đâu) | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-09.S01 | Task chưa lặp | Task `KE_HOACH` hoặc `BACKLOG` không thuộc series đang lặp; gồm instance của series đã dừng và instance đã tách khỏi series | Mục bình thường | Chọn → SCR-01.S01 (chế độ tạo). Instance của series đã dừng: tạo series mới từ task đó | UC-01 bước 1, UC-01 A4, BR-02, BR-12 |
| SCR-09.S02 | Task đã xong | Task `HOAN_THANH` | Mục mờ, tooltip MSG-22; lệnh trong command menu mờ, cùng tooltip | Bỏ hoàn thành (G02) → S01 | UC-01 E7, BR-02, C14 |
| SCR-09.S03 | Instance của series đang lặp | Task thuộc series `DANG_LAP` | Mục vẫn ghi "Lặp lại"; chọn → SCR-01.S12 (chế độ Đổi tần suất) | Chọn / Esc | UC-01 A3; O-01 |
| SCR-09.S04 | Instance của series đang lặp, mất mạng | Như S03, không có mạng | Mục mờ, tooltip MSG-27 (cả lệnh trong command menu) | Có mạng → S03 | UC-04 E4, QC-08 mục 7; G02 SCR-04.S02 |
| SCR-09.S05 | Không có task để áp | Ctrl+K khi không có task đang chọn / hover | Lệnh "Lặp lại" không có trong danh sách `[đề xuất]` | – | SRS mục 6 |

**Dữ liệu mẫu.** "Đọc và trả lời email khách hàng" (S01); "Viết báo cáo tuần" đã xong (S02); instance "Standup nhóm sản phẩm" của series Thứ Hai–Thứ Sáu (S03, S04). Thử menu mở từ card sát mép phải màn (menu lật sang trái) và từ header dialog.

### SCR-01 Picker lặp lại

**Mục đích.** Chọn quy tắc lặp trong vài giây và đọc lại bằng một câu trước khi lưu.

**Cấu trúc.** Popover (`Picker/Repeat`) gắn vào chỗ gọi, rộng cố định. Từ trên xuống, theo SRS SCR-01 #1–#10:
1. **Tiêu đề** UI-02: "Lặp lại" (tạo) hoặc "Đổi tần suất" (sửa) `[đề xuất]`.
2. **Ô "Lặp"** (#1, `Combobox/Select`, nhãn UI-03): 6 lựa chọn UI-04, nhãn có giá trị suy từ ngày dự định của task. Khi đủ 200 series, MSG-14 nằm ngay dưới ô này (#10).
3. **Ô "Vào"** đổi theo quy tắc:
   - Hằng tuần: nhóm 7 nút thứ (#2, `Input/Weekdays`, chữ UI-05), thứ tự bắt đầu từ ngày đầu tuần (G01); chọn được nhiều thứ.
   - Hằng tháng theo ngày: ô ngày 1–31. Hằng tháng theo thứ N: ô thứ N + ô thứ. Hằng năm: ô ngày + ô tháng (UI-08). Ba ô này là SRS SCR-01 #11 (O-02). Ghi chú MSG-04 / MSG-05 (#5) nằm dưới ô ngày.
   - Hằng ngày và Thứ Hai–Thứ Sáu: không có ô "Vào".
4. **Ô "Mỗi"** (#3, `Input/Number` + đơn vị UI-06), ẩn với Thứ Hai–Thứ Sáu. Ghi chú MSG-26 (#8) dưới ô khi Hằng tuần với N ≥ 2.
5. **Ô "Vào khoảng"** (#4, `Picker/Time`, bước 15 phút; lựa chọn đầu "Không đặt giờ", UI-07). Không tạo timebox ở 1.0 (BR-06).
6. **Câu mô tả quy tắc** (#6, mẫu UI-10) và dòng "Lần đầu: {ngày}" (#9, UI-09), chữ phụ. Đây là chỗ người dùng kiểm lại nên luôn hiện và đổi ngay khi đổi ô.
7. **Nút "Lưu"** (#7, UI-11, `Button` `variant=primary` `size=sm`). Không có nút "Huỷ": Esc hoặc bấm ra ngoài là huỷ (UC-01 A5).

**Giá trị mặc định khi mở** (UC-01 bước 2, BR-03): quy tắc "Hằng ngày" (O-02); Mỗi 1; thứ = thứ của ngày dự định; ngày D = ngày của ngày dự định; thứ N suy từ ngày dự định (lần thứ 5 trong tháng → "cuối cùng", O-03); "Vào khoảng" trống. Task trong backlog: ngày dự định coi là hôm nay (BR-02).

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì (khác trạng thái mặc định ở đâu) | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-01.S01 | Mở, mặc định | Chọn "Lặp lại" trên task chưa lặp (SCR-09.S01) | Như cấu trúc, giá trị mặc định ở trên; câu mô tả "Hằng ngày"; "Lần đầu: {ngày}" = ngày dự định (khớp mọi ngày). "Lưu" bật | Đổi ô → S02 … S07; "Lưu" → S11; Esc / bấm ra ngoài → đóng, task không đổi, focus về chỗ gọi | UC-01 bước 2, UC-01 A5 |
| SCR-01.S02 | Hằng ngày | Chọn "Hằng ngày" | Ô "Mỗi" + "ngày"; không có ô "Vào" | – | BR-01 |
| SCR-01.S03 | Thứ Hai–Thứ Sáu | Chọn "Thứ Hai–Thứ Sáu" | Không có ô "Vào", không có ô "Mỗi"; câu mô tả "Thứ Hai–Thứ Sáu" | – | BR-01, Q43, PRD US1.1 AC09 |
| SCR-01.S04 | Hằng tuần | Chọn "Hằng tuần" | 7 nút thứ, nút thứ của ngày dự định đã chọn sẵn; ô "Mỗi" + "tuần" | N ≥ 2 → S05 | SCR-01 #2, BR-01 |
| SCR-01.S05 | Hằng tuần, mỗi N ≥ 2 tuần | Ô "Mỗi" từ 2 trở lên | Thêm MSG-26 dưới ô "Mỗi", {thứ} = ngày đầu tuần trong cài đặt hiện tại | N về 1 → S04 | UC-01 A7, BR-03, C14 |
| SCR-01.S06 | Hằng tháng / Hằng năm | Chọn một trong ba quy tắc tháng, năm | Ô "Vào" theo quy tắc (O-02); ô "Mỗi" + "tháng" / "năm" | Chọn ngày 29–31 hoặc 29/2 → S07 | BR-01, O-02, O-03 |
| SCR-01.S07 | Ngày không có ở mọi tháng / năm | Hằng tháng vào ngày 29–31, hoặc Hằng năm vào 29/2 | MSG-04 hoặc MSG-05 dưới ô ngày, kiểu chữ phụ (không phải lỗi); "Lưu" vẫn bật; "Lần đầu" tính theo BR-03 (ngày 31 từ 10/11 → "Lần đầu: Thứ Hai 30/11") | Đổi ngày → hết ghi chú | UC-01 A2, BR-03, PRD US1.2 |
| SCR-01.S08 | Khoảng lặp sai | Ô "Mỗi" trống, 0, > 99 hoặc không phải số | MSG-02 dưới ô, kiểu lỗi có icon; "Lưu" `disabled`; Enter không lưu | Sửa lại 1–99 → trạng thái trước | UC-01 E1, UC-04 E2, BR-01 |
| SCR-01.S09 | Chưa chọn thứ | Hằng tuần, bỏ cả 7 nút | MSG-03 dưới nhóm nút, kiểu lỗi; "Lưu" `disabled`; câu mô tả và "Lần đầu" ẩn | Chọn một thứ → S04 / S05 | UC-01 E2, UC-04 E2 |
| SCR-01.S10 | Đủ 200 series | Chế độ tạo; đã có 200 series đang lặp: biết từ dữ liệu trên máy lúc mở `[đề xuất]`, hoặc server trả `LIMIT_SERIES` khi lưu | MSG-14 ngay dưới ô "Lặp", kiểu lỗi; "Quản lý mọi task lặp" trong câu là link; "Lưu" `disabled` | Bấm link → Cài đặt → Task lặp lại (F-14); Esc | UC-01 E3, BR-12, C16 |
| SCR-01.S11 | Đang lưu | Bấm "Lưu" (hoặc Enter) khi có mạng | "Lưu" có dấu đang xử lý (nhãn đọc UI-30), các ô khoá; popover chưa đóng. Server trả trong ≤ 500 ms (p95), tối đa 5 giây | Thành công → popover đóng, toast MSG-01 (tạo) hoặc MSG-07 (đổi tần suất), F-01 / F-08; lỗi → S13; 412 → S14; `LIMIT_SERIES` → S10; 409 `SERIES_STOPPED` (đổi tần suất) → popover đóng; mở từ banner: như SCR-03.S05; mở từ SCR-05: toast MSG-15, dòng sang tab "Đã dừng" (UC-04 E5, O-12) | UC-01 bước 4–6, UC-04 bước 4–5; SRS mục 10 |
| SCR-01.S12 | Chế độ Đổi tần suất | Mở từ SCR-09.S03, SCR-03 "Đổi tần suất" hoặc menu dòng SCR-05 | Tiêu đề "Đổi tần suất"; các ô điền quy tắc hiện tại; ô "Vào khoảng" ẩn (giờ đổi ở SCR-07); dòng #9 thành "Lần kế tiếp: {ngày}" theo quy tắc mới (O-06); MSG-26 dùng ngày đầu tuần đã lưu trên series, không theo cài đặt hiện tại. Không có S10. Mở từ SCR-05 thì popover neo vào dòng | "Lưu" khi quy tắc không đổi → đóng, không gọi API, không toast; "Lưu" khi đổi → S11; Esc → đóng | UC-04 bước 2, UC-04 A4, UC-04 A7, BR-03, B15 |
| SCR-01.S13 | Lưu lỗi | \[SeriesCreate\] / \[SeriesUpdate\] lỗi 5xx / timeout | Popover giữ mở với lựa chọn đang có; toast MSG-12 có "Thử lại" (gửi lại cùng lựa chọn); task và series không đổi | "Thử lại" / "Lưu" lại → S11; Esc | UC-01 E5, UC-04 E3, QC-13 mục 1 |
| SCR-01.S14 | Series vừa sửa ở thiết bị khác | Chế độ Đổi tần suất, server trả 412 | Các ô nạp lại quy tắc mới nhất (lựa chọn đang sửa bị thay); toast MSG-16; popover giữ mở | "Lưu" lại / Esc | UC-04 E1 |
| SCR-01.S15 | Tạo khi mất mạng | Chế độ tạo, bấm "Lưu" khi không có mạng | Popover đóng ngay; card vào SCR-06.S03; toast MSG-01 với ngày tính trên máy `[đề xuất]` | Có mạng, server nhận → SCR-06.S01; bị từ chối → CASE-44 | UC-01 E4, QC-08 mục 7 |
| SCR-01.S16 | Mất mạng khi đang đổi tần suất | Chế độ Đổi tần suất, mạng mất khi popover đang mở | "Lưu" mờ, tooltip MSG-27; các ô vẫn chỉnh được `[đề xuất]` | Có mạng → S12 | UC-04 E4, QC-08 mục 7 |

**Dữ liệu mẫu.** Hôm nay Thứ Ba 10/11/2026, ngày đầu tuần Thứ Hai, mốc đầu ngày 04:00.
- Task "Đọc và trả lời email khách hàng", ngày dự định Thứ Tư 11/11. Ô "Lặp": "Hằng ngày", "Thứ Hai–Thứ Sáu", "Hằng tuần", "Hằng tháng vào ngày 11", "Hằng tháng vào Thứ Tư thứ 2", "Hằng năm vào 11/11". Chọn Hằng tuần, bấm thêm T2, T6 → câu "Hằng tuần vào Thứ Hai, Thứ Tư, Thứ Sáu", "Lần đầu: Thứ Tư 11/11"; "Vào khoảng" 08:30.
- **Chuỗi phức tạp nhất:** Hằng tháng vào ngày 31 từ task ngày 10/11 → MSG-04 "Tháng không có ngày 31 sẽ dùng ngày cuối tháng", "Lần đầu: Thứ Hai 30/11"; các lần sau 31/12, 31/01/2027, 28/02/2027, 31/03/2027.
- Hằng tháng theo thứ N từ task Thứ Hai 30/11 (Thứ Hai thứ 5 của tháng) → mặc định "Hằng tháng vào Thứ Hai cuối cùng"; lần sau Thứ Hai 28/12.
- Hằng năm vào 29/02 → MSG-05 "Năm không nhuận sẽ dùng ngày 28/2", "Lần đầu: Chủ Nhật 28/02/2027"; năm 2028 về Thứ Ba 29/02/2028.
- Task "Báo cáo tuần cho anh Minh" ngày Thứ Ba 10/11, chọn Hằng tuần, mỗi 2 tuần, chỉ Thứ Sáu → MSG-26 "Tuần tính từ Thứ Hai; giữ cố định cho task lặp này", "Lần đầu: Thứ Sáu 13/11" (task sẽ dời sang ngày đó, UC-01 A6).
- Câu mô tả dài nhất: "Mỗi 99 tuần vào Thứ Hai, Thứ Ba, Thứ Tư, Thứ Năm, Thứ Sáu, Thứ Bảy, Chủ Nhật" (xuống 2–3 dòng, popover không giãn ngang).
- MSG-14: "Bạn đã có 200 task lặp đang chạy, tối đa 200. Dừng bớt trong "Quản lý mọi task lặp"".
- Kiểm tra dấu ở nút thứ và lựa chọn "Thứ Hai–Thứ Sáu" với text scaling 150%.

### SCR-06 Dấu lặp trên task card (phần G03)

**Mục đích.** Cho thấy card là một lần của task lặp, và giờ "khoảng" của nó nếu có.

**Cấu trúc.** Card đầy đủ (`Card/Task`) thuộc G04, phần G02 theo brief G02 SCR-02. G03 thêm hai thành phần ở hàng đầu của card:
1. **Icon lặp** (#1, `Icon/Repeat`, vẽ theo lưới Lucide, DS-06) ngay sau giờ, trước badge thời lượng `[đề xuất]`. Tooltip là câu mô tả quy tắc dạng đứng riêng (UI-14); nhãn đọc màn hình UI-14.
2. **Giờ** (#2): giờ khoảng (`approxTime`) nếu series có, ngược lại giờ projection của G04. Cách phân biệt hai loại giờ ở O-15.

Instance "Dự kiến" ở ngày ngoài 60 ngày (mờ, nhãn "Dự kiến") thuộc G04 BR-23, không vẽ ở đây.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-06.S01 | Instance đang lặp | Instance gắn series `DANG_LAP`, không có giờ khoảng | Icon lặp; giờ projection (G04) | – | SCR-06 #1, BR-06, SRS 4.1 |
| SCR-06.S02 | Có giờ khoảng | Series có `approxTime` | Giờ = giờ khoảng ("08:30") thay giờ projection, tooltip UI-15 (O-15) | Xoá giờ ở SCR-07 → S01 | SCR-06 #2, BR-06, PRD US2.1 AC03 |
| SCR-06.S03 | Vừa bật lặp, chờ đồng bộ | Bật lặp khi mất mạng | Card task ban đầu có icon lặp và icon "Chờ đồng bộ" (G02 MSG-30); các ngày tới chưa có instance | Server tạo xong → S01 và instance mới (S07); `ALREADY_REPEATING` → CASE-44 | UC-01 E4, UC-01 E8 |
| SCR-06.S04 | Instance đã xong | `HOAN_THANH` | Như G02 SCR-02.S07, giữ icon lặp. Instance ngày tương lai hoàn thành vẫn ở cột ngày đó | Bỏ hoàn thành (G02) | UC-03 A6, Q12 |
| SCR-06.S05 | Instance của series đã dừng | Series `DA_DUNG`, instance còn lại | Giữ icon lặp, tooltip MSG-15 (O-15) | – | SRS 4.1, B16 |
| SCR-06.S06 | Instance đã tách | Bị tách khỏi series khi đổi tần suất | Không có icon lặp, như task thường (O-15) | – | UC-03 A8, BR-08 |
| SCR-06.S07 | Instance mới xuất hiện | Job sinh instance; ngay sau bật lặp, đổi tần suất, Hoàn tác (realtime ≤ 5 giây) | Card mới hiện ở cột ngày tương ứng, mờ dần vào (DS-16); không toast. Tổng cột cập nhật (G04) | – | UC-02 bước 5, PRD US2.1 AC01 |
| SCR-06.S08 | Instance bị gỡ | Dừng lặp, đổi tần suất xoá hẳn, xoá mọi lần chưa xong, bị xoá ở thiết bị khác | Card thu lại và biến mất; Hoàn tác thì hiện lại đúng chỗ | – | UC-05 bước 3, UC-03 E3, BR-08 |

**Dữ liệu mẫu.** Tuần 09–15/11 ở view Week:
- "Standup nhóm sản phẩm" · Thứ Hai–Thứ Sáu · giờ khoảng 09:00 · 0:15 · #Công ty: 5 card Thứ Hai 09/11 … Thứ Sáu 13/11 (09/11 đã xong).
- "Đọc và trả lời email khách hàng" · 08:30 · 0:30 · #Khách hàng ACB: card Thứ Tư 11/11, Thứ Sáu 13/11 (Thứ Sáu có "0:20 / 0:30").
- "Báo cáo tuần cho anh Minh" · không giờ khoảng (giờ projection 15:30) · 1:00 · #Công ty: card Thứ Sáu 13/11.
- Tiêu đề 130 ký tự của brief G02 trên card có icon lặp (icon không đẩy tiêu đề xuống dòng ba).
- Tooltip dài nhất: "Mỗi 99 tuần vào Thứ Hai, Thứ Ba, Thứ Tư, Thứ Năm, Thứ Sáu, Thứ Bảy, Chủ Nhật".

### SCR-02 Banner series

**Mục đích.** Cho biết lần đang mở thuộc chuỗi nào, đi tới lần trước / sau, và mở "Sửa series".

**Cấu trúc.** `Banner/Series` nằm giữa header thuộc tính và ✓ tiêu đề của G02 SCR-03 (vùng #2 brief G02). Nền trung tính, không dùng màu cảnh báo (DS-11). Từ trái sang:
1. Icon lặp.
2. Chữ MSG-06 (#1), tối đa 2 dòng.
3. Link "Sửa series" (#2, UI-12).
4. Hai nút "Trước" / "Sau" (#3, `Button/Icon` mũi tên trái / phải kèm nhãn đọc UI-12) ở mép phải.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-02.S01 | Đang lặp | Instance gắn series `DANG_LAP`, có lần trước và lần sau đã sinh | Như cấu trúc | "Trước" / "Sau" → S06; "Sửa series" → SCR-03 (UC-03 A3) | UC-03 bước 2, A1, A3, SCR-02 |
| SCR-02.S02 | Lần đầu tiên | Instance đầu của series | MSG-06 với "lần đầu tiên"; "Trước" `disabled`, tooltip UI-13 | – | UC-03 A1 |
| SCR-02.S03 | Lần kế tiếp chưa sinh | Lần sau nằm ngoài 60 ngày (thường gặp với Hằng năm, Hằng tháng, mỗi N tuần lớn) | "Sau" `disabled`, tooltip MSG-20 | Qua mốc đầu ngày, job sinh tới → S01 | UC-03 A2, UC-02 A3 |
| SCR-02.S04 | Series đã dừng | Series `DA_DUNG`, kể cả vừa dừng ở thiết bị khác (realtime, hoặc 409 `SERIES_STOPPED`) | MSG-15 thay MSG-06; không có "Sửa series"; "Trước" / "Sau" vẫn hiện, bỏ qua instance đã xoá; lần cuối còn lại: "Sau" `disabled`, tooltip UI-13 | Hoàn tác dừng lặp → S01 | UC-03 A5, UC-05 E1, B16 |
| SCR-02.S05 | Instance đã tách | Instance bị tách khi đổi tần suất | MSG-25 thay toàn bộ banner; không có icon lặp, "Sửa series", "Trước" / "Sau" | Hoàn tác đổi tần suất → S01 | UC-03 A8, BR-08 |
| SCR-02.S06 | Đang chuyển sang lần khác | Bấm "Trước" / "Sau" | Dialog giữ khung; nội dung chuyển như G02 SCR-03.S01 (tiêu đề lấy ngay, phần còn lại `Skeleton`). Lần liền kề đã bị xoá → bỏ qua, mở lần kế tiếp còn tồn tại, không báo | Có dữ liệu → S01 … S04 | UC-03 A1, UC-03 E2 |
| SCR-02.S07 | Lần đó không còn | Mở card, hoặc bấm "Trước" / "Sau", server trả 404 `NOT_FOUND` | Không mở; toast MSG-17; card gỡ khỏi board. Dialog đang mở mà instance bị xoá ở thiết bị khác (realtime) → G02 SCR-03.S16 (O-13) | – | UC-03 E3, C11 |
| SCR-02.S08 | Mất mạng | Không có mạng | Banner giữ nguyên; "Sửa series" vẫn mở SCR-03 (ở SCR-03.S02); "Trước" / "Sau" mở được lần đã có trên máy `[đề xuất]` | Có mạng → trạng thái trước | QC-08 mục 7, SCR-03 #7 |
| SCR-02.S09 | Series vừa sửa ở thiết bị khác | Realtime đổi quy tắc / áp mẫu / đặt giờ | Chữ MSG-06 và trường của instance cập nhật ngay, không báo (như G02 SCR-03.S15). Instance đang mở bị tách → S05; bị xoá hẳn → như S07 | – | QC-08 mục 3, BR-08 |

**Dữ liệu mẫu.**
- MSG-06: "Task này lặp lại hằng tuần vào Thứ Hai, Thứ Tư, Thứ Sáu. Đây là lần thứ 2 của series" (lần Thứ Tư 11/11; lần đầu là Thứ Hai 09/11).
- Lần đầu: "Task này lặp lại từ Thứ Hai đến Thứ Sáu. Đây là lần đầu tiên của series".
- Dài nhất (xuống 2 dòng ở dialog thường): "Task này lặp lại mỗi 99 tuần vào Thứ Hai, Thứ Ba, Thứ Tư, Thứ Năm, Thứ Sáu, Thứ Bảy, Chủ Nhật. Đây là lần thứ 365 của series".
- MSG-20: "Lần kế tiếp: Thứ Hai 11/01/2027" (lần Thứ Sáu 08/01/2027 là lần cuối đã sinh của chuỗi Thứ Hai, Thứ Tư, Thứ Sáu).
- MSG-25 với tiêu đề 130 ký tự: tiêu đề cắt "…" để cả câu không quá 2 dòng, tooltip hiện đủ `[đề xuất]`.

### SCR-03 Menu "Sửa series"

**Mục đích.** Gom mọi thao tác trên cả chuỗi vào một chỗ.

**Cấu trúc.** `Menu/Context` mở ngay dưới link "Sửa series". 6 mục theo SRS SCR-03 #1–#6 (chữ UI-16), thứ tự hiển thị theo O-18 (SRS SCR-03): thao tác hay dùng trước, thao tác mất dữ liệu cuối cùng:
1. Đổi tần suất (#2) → SCR-01.S12
2. Đặt giờ bắt đầu (#5) → SCR-07; giờ khoảng hiện tại ghi bên phải mục ("08:30") `[đề xuất]`
3. Cập nhật mọi lần chưa xong theo task này (#3)
4. đường kẻ · Quản lý mọi task lặp (#6) → SCR-05
5. đường kẻ · Dừng lặp (#1), không hỏi xác nhận (có Hoàn tác)
6. Xoá mọi lần chưa xong và dừng lặp (#4), kiểu nguy hiểm → SCR-04

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-03.S01 | Mặc định | Series `DANG_LAP`, có mạng | Như cấu trúc | Chọn mục → F-08 … F-12, F-14; Esc / bấm ra ngoài → đóng | UC-03 A3, SCR-03 #1–#6 |
| SCR-03.S02 | Mất mạng | Không có mạng | Mục 1, 2, 3, 5, 6 (SRS #1–#5) mờ, tooltip MSG-27 trên từng mục; "Quản lý mọi task lặp" vẫn bật | Có mạng → S01 | UC-04 E4, UC-05 E3, SCR-03 #7 |
| SCR-03.S03 | Đang áp thao tác | Chọn "Dừng lặp" hoặc "Cập nhật mọi lần chưa xong theo task này" | Menu đóng ngay; banner hiện dấu đang xử lý nhỏ cạnh "Sửa series" `[đề xuất]`; card chưa đổi tới khi server trả (≤ 5 giây) | Xong → toast MSG-09 / MSG-08 (kèm MSG-24 nếu có), card cập nhật; lỗi → S04; 409 → S05 | UC-04 A1, UC-05 bước 2–3 |
| SCR-03.S04 | Lỗi | 5xx / timeout | Toast MSG-12 có "Thử lại"; series và instance không đổi | "Thử lại" → S03 | UC-04 E3, UC-05 E2 |
| SCR-03.S05 | Series đã dừng ở thiết bị khác | Server trả 409 `SERIES_STOPPED` cho thao tác mở từ SCR-03 (kể cả SCR-01, SCR-07) | Không toast; banner chuyển SCR-02.S04 (chữ MSG-15), dialog làm mới | – | UC-04 E5, UC-05 E1; O-12 |

**Dữ liệu mẫu.** Menu mở ở dialog thường và dialog mở rộng; mục 2 có "08:30" bên phải; mục 3 dài nhất (47 ký tự) không xuống dòng ở độ rộng menu.

### SCR-07 Bộ chọn giờ bắt đầu

**Mục đích.** Đặt hoặc xoá giờ khoảng cho mọi lần chưa xong của chuỗi.

**Cấu trúc.** Popover (`Picker/Time`) mở cạnh mục "Đặt giờ bắt đầu" (chốt 09/11/2026, C12). Từ trên xuống: tiêu đề UI-17; dòng phụ UI-18; danh sách giờ bước 15 phút 00:00 … 23:45 (#1), giờ hiện tại có icon dấu tích; nút "Xoá giờ" (#2, UI-19, `Button` `variant=secondary` `size=sm`). Chọn một giờ là lưu luôn, không có nút "Lưu". Esc / bấm ra ngoài đóng, không đổi (#3).

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-07.S01 | Chưa có giờ | `approxTime` trống | Danh sách cuộn tới 09:00 `[đề xuất]`; "Xoá giờ" `disabled` | Chọn giờ → S03 | UC-04 A2 |
| SCR-07.S02 | Có giờ | `approxTime` có giá trị | Giờ hiện tại có dấu tích, cuộn tới đó; "Xoá giờ" bật | Chọn giờ khác / "Xoá giờ" → S03 | SCR-07 #1, SCR-07 #2 |
| SCR-07.S03 | Đã đặt / đã xoá | Chọn giờ hoặc bấm "Xoá giờ", server nhận | Popover và menu đóng; toast MSG-18 (đặt) hoặc MSG-29 (xoá, O-10); giờ trên card của các lần trong phạm vi đổi ngay; lần có timebox giữ nguyên timebox | Hoàn tác → giờ cũ | UC-04 A2, BR-08, CASE-32 |
| SCR-07.S04 | Mất mạng khi đang mở | Mạng mất sau khi mở | Danh sách và "Xoá giờ" mờ, tooltip MSG-27 | Có mạng → S01 / S02 | UC-04 E4 |
| SCR-07.S05 | Lỗi | 5xx / timeout | Popover đóng; toast MSG-12 có "Thử lại"; giờ không đổi | "Thử lại" | UC-04 E3 |

**Dữ liệu mẫu.** Đổi "08:30" thành "09:00": MSG-18 "Đã đặt giờ 09:00 cho các lần chưa xong · Hoàn tác". Giờ biên 00:00 và 23:45.

### SCR-04 Xác nhận xoá instance chưa xong

**Mục đích.** Chặn thao tác hàng loạt mất dữ liệu bằng một bước xác nhận có số lượng.

**Cấu trúc.** `Dialog` nhỏ: nội dung MSG-10 (#1), không có tiêu đề riêng `[đề xuất]`; hai nút "Huỷ" (#3, `Button` `variant=secondary`) và "Xoá và dừng lặp" (#2, `Button` `variant=danger`), chữ UI-20. Focus đầu ở "Huỷ"; Enter không tự xoá `[đề xuất]`.

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-04.S01 | Mặc định | Chọn "Xoá mọi lần chưa xong và dừng lặp" | MSG-10 với {n} (nguồn số ở O-11) | "Xoá và dừng lặp" → S02; "Huỷ" / Esc → đóng, không đổi | UC-05 A1, C13 |
| SCR-04.S02 | Đang xoá | Bấm "Xoá và dừng lặp" | Nút xác nhận có dấu đang xử lý; hai nút khoá | Xong → dialog đóng, các card bị xoá thu lại; toast MSG-11, dòng 2 MSG-30 khi có lần được giữ (O-09) | UC-05 A1, UC-05 A2, BR-08, BR-15 |
| SCR-04.S03 | Không còn lần nào để xoá | {n} = 0 | Nội dung MSG-32 thay MSG-10 (O-08); nút như S01 | Như S01 | O-08 |
| SCR-04.S04 | Lỗi | 5xx / timeout | Dialog giữ mở, nút bật lại; toast MSG-12 có "Thử lại"; không xoá lần nào | "Thử lại" / "Huỷ" | UC-05 E2 |
| SCR-04.S05 | Mất mạng | Mạng mất khi dialog đang mở | "Xoá và dừng lặp" mờ, tooltip MSG-27 | Có mạng → S01 | UC-05 E3 |
| SCR-04.S06 | Đã dừng ở thiết bị khác | Server trả 409 `SERIES_STOPPED` | Dialog đóng; banner chuyển SCR-02.S04 (MSG-15) | – | UC-05 E1; O-12 |

**Dữ liệu mẫu.** Chuỗi "Đọc và trả lời email khách hàng" (Thứ Hai, Thứ Tư, Thứ Sáu), mở từ lần Thứ Tư 11/11; còn 26 lần chưa xong tới 08/01/2027, lần Thứ Sáu 13/11 đã có 0:20 thời gian thực tế: "Xoá 25 lần chưa xong của "Đọc và trả lời email khách hàng" và dừng lặp? Các lần đã xong và các lần đã có thời gian thực tế được giữ lại. Task xoá nằm trong Thùng rác 30 ngày". Số lớn nhất: Hằng ngày → 61 lần. Tiêu đề 500 ký tự: cắt "…" sau 2 dòng trong dialog `[đề xuất]`.

### SCR-08 Xác nhận dừng lặp (từ danh sách)

**Mục đích.** Dừng một chuỗi ngay trên dòng của danh sách, không cần mở instance (chốt 09/11/2026, B15).

**Cấu trúc.** Như SCR-04: `Dialog` nhỏ, nội dung MSG-28 (#1); nút "Huỷ" (#3, `secondary`) và "Dừng lặp" (#2, `Button` `variant=danger` `[đề xuất]`, vì xoá các lần sắp tới), chữ UI-20. Focus đầu ở "Huỷ".

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-08.S01 | Mặc định | Menu dòng SCR-05 → "Dừng lặp" | MSG-28 với {n} (O-11) | "Dừng lặp" → S03; "Huỷ" / Esc → đóng, không đổi | UC-05 A4, B15 |
| SCR-08.S02 | Không có lần sắp tới bị xoá | {n} = 0 (thường gặp với Hằng năm) | Nội dung MSG-31 thay MSG-28 (O-08) | Như S01 | O-08 |
| SCR-08.S03 | Đang dừng | Bấm "Dừng lặp" | Nút có dấu đang xử lý | Xong → dialog đóng, SCR-05.S09 | UC-05 bước 2–3 |
| SCR-08.S04 | Lỗi | 5xx / timeout | Dialog giữ mở; toast MSG-12 có "Thử lại" | "Thử lại" / "Huỷ" | UC-05 E2 |
| SCR-08.S05 | Mất mạng | Mạng mất khi dialog đang mở | "Dừng lặp" mờ, tooltip MSG-27 | Có mạng → S01 | UC-05 E3 |
| SCR-08.S06 | Đã dừng ở thiết bị khác | Server trả 409 `SERIES_STOPPED` | Dialog đóng; toast MSG-15 (O-12); dòng chuyển sang tab "Đã dừng" | – | UC-05 E1; O-12 |

**Dữ liệu mẫu.** "Dừng lặp "Đọc và trả lời email khách hàng"? 25 lần sắp tới sẽ bị xoá. Các lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại". Chuỗi "Gia hạn tên miền wakeup.vn" (Hằng năm, lần duy nhất là 28/02/2027 chưa động tới): {n} = 1. Tiêu đề 130 ký tự xuống 2 dòng.

### SCR-05 Quản lý mọi task lặp

**Mục đích.** Xem mọi chuỗi lặp ở một chỗ; đổi tần suất, dừng hoặc mở lần kế tiếp mà không phải tìm instance trên board.

**Cấu trúc.** Nhóm "Task lặp lại" trong lớp phủ Cài đặt (IA mục 5; vị trí trong cột trái ở O-14). Từ trên xuống:
1. **Tiêu đề nhóm** "Task lặp lại" và **tabs** "Đang lặp" / "Đã dừng" (#1, `Nav/Tabs`, chữ UI-21), mặc định "Đang lặp"; cạnh tên tab có số lượng `[đề xuất]`.
2. **Danh sách** (#2, `List/SeriesRow`), tab "Đang lặp" sắp theo lần kế tiếp, gần nhất trước. Mỗi dòng: tiêu đề (1 dòng, cắt "…") · câu mô tả quy tắc (UI-10, chữ phụ) · giờ khoảng (nếu có) · chấm màu + "#channel" · "Lần kế tiếp: {ngày}" (chữ MSG-20). Tab "Đã dừng": thay lần kế tiếp bằng UI-23, sắp theo ngày dừng mới nhất `[đề xuất]`.
3. **Nút …** trên dòng (hiện khi hover / focus dòng) mở menu dòng (#3, `Menu/Context`, chữ UI-22): tab "Đang lặp": "Mở lần kế tiếp" · "Đổi tần suất" · đường kẻ · "Dừng lặp"; tab "Đã dừng": chỉ "Mở lần cuối".

**Trạng thái.**

| Mã | Trạng thái | Khi nào | Hiện gì | Ra khỏi trạng thái bằng | Tham chiếu |
|---|---|---|---|---|---|
| SCR-05.S01 | Đang tải | Mở nhóm, đổi tab | 5 dòng `Skeleton` | Có dữ liệu → S02 / S03 / S04 / S05; lỗi → S06 | \[SeriesList\] |
| SCR-05.S02 | Có series đang lặp | Tab "Đang lặp", ≥ 1 series | Như cấu trúc; cuộn tới cuối thì tải thêm | – | UC-07 bước 2, PRD US6.1 AC01 |
| SCR-05.S03 | Rỗng | Tab "Đang lặp", chưa có series | MSG-19 giữa vùng nội dung, không hình minh hoạ `[đề xuất]` | – | UC-07 A2 |
| SCR-05.S04 | Tab "Đã dừng" | Bấm tab "Đã dừng" | Dòng có UI-23 thay lần kế tiếp; menu dòng chỉ "Mở lần cuối" | – | UC-07 A1 |
| SCR-05.S05 | Tab "Đã dừng" rỗng | Chưa dừng series nào | Chữ UI-24 giữa vùng nội dung `[đề xuất]` | – | UC-07 A1 |
| SCR-05.S06 | Lỗi tải | \[SeriesList\] lỗi | QC-MSG-02 tại chỗ, "Thử lại" bấm được; có dữ liệu lần cuối thì giữ danh sách, dòng lỗi nằm trên đầu danh sách | "Thử lại" → S01 | UC-07 E1, QC-13 mục 1, C14 |
| SCR-05.S07 | Mất mạng | Không có mạng | Dữ liệu lần cuối; "Đổi tần suất", "Dừng lặp" trong menu dòng mờ, tooltip MSG-27; "Mở lần kế tiếp" vẫn dùng được | Có mạng → S02 | UC-07 E2, QC-08 mục 7 |
| SCR-05.S08 | Đổi tần suất trên dòng | Menu dòng → "Đổi tần suất" | SCR-01.S12 neo vào dòng; lưu xong dòng cập nhật câu mô tả và lần kế tiếp, vị trí dòng sắp lại; toast MSG-07 | Esc / lưu xong → S02 | UC-04 A7, B15 |
| SCR-05.S09 | Vừa dừng lặp | Xác nhận ở SCR-08 | Dòng thu lại, rời tab "Đang lặp" (sang tab "Đã dừng"); số trên tab đổi; toast MSG-09 (dòng 2 MSG-24 khi có lần được giữ) | Hoàn tác → dòng hiện lại đúng chỗ | UC-05 A4, BR-09 |
| SCR-05.S10 | Lần kế tiếp chưa sinh | Lần kế tiếp nằm ngoài 60 ngày (Hằng năm) | "Mở lần kế tiếp" mờ, tooltip MSG-20 (O-16); "Mở lần cuối" khi không còn lần nào: mờ, tooltip MSG-35 | – | UC-02 A3; O-16 |
| SCR-05.S11 | Series / lần đã bị xoá ở thiết bị khác | "Mở lần kế tiếp" / "Mở lần cuối" nhận 404 `NOT_FOUND` | Toast MSG-17; danh sách tải lại | → S01 | UC-07 E3, C11 |

**Dữ liệu mẫu.** Tab "Đang lặp" (hôm nay Thứ Ba 10/11), theo thứ tự:
- "Standup nhóm sản phẩm" · Thứ Hai–Thứ Sáu · 09:00 · #Công ty · Lần kế tiếp: hôm nay `[đề xuất]`.
- "Đọc và trả lời email khách hàng" · Hằng tuần vào Thứ Hai, Thứ Tư, Thứ Sáu · 08:30 · #Khách hàng ACB · Lần kế tiếp: Thứ Tư 11/11.
- "Báo cáo tuần cho anh Minh" · Mỗi 2 tuần vào Thứ Sáu · #Công ty · Lần kế tiếp: Thứ Sáu 13/11.
- "Gửi hoá đơn tháng cho khách hàng" · Hằng tháng vào ngày 31 · #Khách hàng ACB · Lần kế tiếp: Thứ Hai 30/11.
- "Họp 1-1 với chị Hà" · Hằng tháng vào Thứ Hai cuối cùng · 14:00 · #Công ty · Lần kế tiếp: Thứ Hai 30/11.
- "Gia hạn tên miền wakeup.vn" · Hằng năm vào 29/02 · #Cá nhân · Lần kế tiếp: Chủ Nhật 28/02/2027.
- Dòng dài nhất: tiêu đề 130 ký tự của brief G02 · "Mỗi 99 tuần vào Thứ Hai, …, Chủ Nhật" (cắt "…") · "#Dự án chuyển đổi số Ngân hàng Á Châu giai đoạn hai" (cắt). Danh sách dài nhất: 200 dòng.

Tab "Đã dừng": "Tập thể dục buổi sáng" · Hằng ngày · 06:30 · #Sức khoẻ · Đã dừng Chủ Nhật 08/11.

## 5. User flow

### F-01 Bật lặp hằng tuần cho một task

**Mở đầu:** card "Đọc và trả lời email khách hàng" ở cột Thứ Tư 11/11 (hôm nay Thứ Ba 10/11). **Kết thúc:** card có dấu lặp; các Thứ Hai, Thứ Tư, Thứ Sáu tới có instance. Sơ đồ: [UC-01](flow/g03-task-lap-lai.md#uc-01-bật-lặp-cho-task).

| Bước | Người dùng | Hệ thống / màn hình (mã trạng thái) |
|---|---|---|
| 1 | Hover card, bấm … (hoặc chuột phải; hoặc chọn card rồi Ctrl+K → "Lặp lại") | G02 SCR-04 mở; SCR-09.S01 |
| 2 | Chọn "Lặp lại" | SCR-01.S01, mặc định theo ngày Thứ Tư 11/11 |
| 3 | Chọn "Hằng tuần", bấm T2, T6 | SCR-01.S04; câu "Hằng tuần vào Thứ Hai, Thứ Tư, Thứ Sáu", "Lần đầu: Thứ Tư 11/11" |
| 4 | Mở "Vào khoảng", chọn 08:30 | – |
| 5 | Bấm "Lưu" (hoặc Enter) | SCR-01.S11 → popover đóng; toast MSG-01 "Task giờ sẽ lặp lại hằng tuần vào Thứ Hai, Thứ Tư, Thứ Sáu, bắt đầu từ Thứ Tư 11/11" |
| 6 | – | Card có icon lặp và giờ 08:30 (SCR-06.S02); instance 14 ngày đầu hiện ngay, phần còn lại tới 60 ngày hiện dần (SCR-06.S07) |

Nhánh: Mỗi N sai → SCR-01.S08; không chọn thứ → SCR-01.S09; đủ 200 series → SCR-01.S10; lỗi 5xx → SCR-01.S13; mất mạng → F-04; Esc → SCR-01 đóng, không lưu (UC-01 A5); task đã xong → SCR-09.S02; task đã lặp → F-08.

### F-02 Bật lặp hằng tháng vào ngày 31

**Mở đầu:** task "Gửi hoá đơn tháng cho khách hàng" ở cột Thứ Ba 10/11. **Kết thúc:** task dời sang Thứ Hai 30/11, các lần sau vào ngày cuối tháng. Sơ đồ: [UC-01](flow/g03-task-lap-lai.md#uc-01-bật-lặp-cho-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Menu … → "Lặp lại" | SCR-01.S01 |
| 2 | Chọn "Hằng tháng vào ngày 10", đổi ô ngày thành 31 | SCR-01.S07: MSG-04 "Tháng không có ngày 31 sẽ dùng ngày cuối tháng"; "Lần đầu: Thứ Hai 30/11" |
| 3 | Bấm "Lưu" | Toast MSG-01 "Task giờ sẽ lặp lại hằng tháng vào ngày 31, bắt đầu từ Thứ Hai 30/11"; card bay từ cột 10/11 sang cột 30/11 (DS-16) |

Nhánh: Hằng năm 29/2 → MSG-05 (CASE-11); task ở ngày không khớp quy tắc → F-03.

### F-03 Bật lặp cho task trong backlog hoặc task ở ngày không khớp quy tắc

**Mở đầu:** (a) task "Báo cáo tuần cho anh Minh" ở cột Thứ Ba 10/11; (b) task "Dọn hộp thư" trong panel Backlog. **Kết thúc:** task là lần đầu, ở ngày khớp quy tắc đầu tiên. Sơ đồ: [UC-01](flow/g03-task-lap-lai.md#uc-01-bật-lặp-cho-task).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1a | Bật lặp mỗi 2 tuần vào Thứ Sáu | SCR-01.S05: MSG-26 "Tuần tính từ Thứ Hai; giữ cố định cho task lặp này"; "Lần đầu: Thứ Sáu 13/11" |
| 2a | Bấm "Lưu" | Task dời sang Thứ Sáu 13/11 theo đường "chọn ngày" (QC-05); toast MSG-01 "Task giờ sẽ lặp lại mỗi 2 tuần vào Thứ Sáu, bắt đầu từ Thứ Sáu 13/11"; card bay sang cột 13/11 |
| 1b | Mở menu … của task backlog → "Lặp lại", chọn "Thứ Hai–Thứ Sáu" | SCR-01.S03; "Lần đầu: hôm nay" (ngày dự định coi là hôm nay) |
| 2b | Bấm "Lưu" | Task rời panel Backlog, hiện ở cột hôm nay; toast MSG-01 "Task giờ sẽ lặp lại từ Thứ Hai đến Thứ Sáu, bắt đầu từ hôm nay" |

Hôm nay không khớp quy tắc (task backlog, quy tắc chỉ Thứ Hai): lần đầu là ngày khớp đầu tiên tính từ hôm nay theo BR-02, MSG-01 nêu ngày (chốt O-05, SRS UC-01 A1 đã sửa). Nguồn: UC-01 A1, UC-01 A6, UC-01 A7, BR-02.

### F-04 Bật lặp khi mất mạng

**Mở đầu:** board, banner offline (G04 MSG-30). **Kết thúc:** series được tạo khi có mạng; hoặc bị từ chối vì thiết bị khác đã bật trước. Sơ đồ: [nhánh lỗi UC-01](flow/g03-task-lap-lai.md#nhánh-lỗi).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bật lặp như F-01, bấm "Lưu" | SCR-01.S15: popover đóng; card SCR-06.S03; toast MSG-01 `[đề xuất]` |
| 2 | (Có mạng lại) | Gửi lại cùng idempotency key; server tạo series → SCR-06.S01, instance mới hiện dần |
| 2a | – | Thiết bị khác đã bật lặp task này: toast MSG-23; lệnh bị bỏ, card và banner theo series của thiết bị kia (CASE-44) |

Nguồn: UC-01 E4, UC-01 E8, QC-08 mục 4, mục 7.

### F-05 Instance mới xuất hiện mỗi ngày

**Mở đầu:** hệ thống, qua mốc đầu ngày 04:00 sáng Thứ Tư 11/11. **Kết thúc:** cột ngày thứ 60 (Chủ Nhật 10/01/2027) có instance mới nếu khớp quy tắc. Sơ đồ: [UC-02](flow/g03-task-lap-lai.md#uc-02-sinh-instance-job-recurrencegenerate).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | – | Job sinh instance (mỗi giờ, và ngay sau bật lặp / đổi tần suất) tính các ngày khớp quy tắc tới hôm nay + 60, bỏ ngày ngoại lệ và ngày đã có instance |
| 2 | Đang xem board tuần xa | Card mới hiện (SCR-06.S07), không toast; nhật ký của instance: "Hệ thống · Tạo từ series {tiêu đề}" (UI-29) |

Nhánh: job ngừng nhiều ngày → CASE-15; không có ngày nào trong khoảng → CASE-16; job lỗi → CASE-51. Nguồn: UC-02 bước 1–5, UC-02 A2, UC-02 A3, UC-02 E1, BR-04, BR-05, BR-13.

### F-06 Mở một lần, đi Trước / Sau

**Mở đầu:** card "Đọc và trả lời email khách hàng" Thứ Tư 11/11. **Kết thúc:** đang xem lần Thứ Sáu 13/11. Sơ đồ: [UC-03](flow/g03-task-lap-lai.md#uc-03-xem-và-sửa-một-instance), [nhánh banner series](flow/g03-task-lap-lai.md#nhánh-thay-thế-và-lỗi-banner-series).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm tiêu đề card (hoặc Ctrl+Enter) | G02 SCR-03 mở; SCR-02.S01: "Task này lặp lại hằng tuần vào Thứ Hai, Thứ Tư, Thứ Sáu. Đây là lần thứ 2 của series" |
| 2 | Bấm "Sau" | SCR-02.S06 → chi tiết lần Thứ Sáu 13/11, "lần thứ 3" |
| 3 | Bấm "Trước" hai lần | Về lần Thứ Hai 09/11 (đã xong), SCR-02.S02, "Trước" mờ |

Nhánh: lần liền kề đã bị xoá → bỏ qua (UC-03 E2); lần cuối đã sinh → SCR-02.S03; series đã dừng → SCR-02.S04; instance đã tách → SCR-02.S05; lần đó đã bị xoá ở thiết bị khác → SCR-02.S07; mất mạng → SCR-02.S08.

### F-07 Sửa riêng một lần

**Mở đầu:** chi tiết lần Thứ Sáu 13/11 của "Đọc và trả lời email khách hàng". **Kết thúc:** chỉ lần này đổi; mẫu và các lần khác giữ nguyên. Sơ đồ: [nhánh sửa instance](flow/g03-task-lap-lai.md#nhánh-thay-thế-và-lỗi-sửa-instance).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Đổi thời lượng 0:30 thành 0:45, thêm notes | Lưu ngay như G02 (G02 F-07); **không** có hộp hỏi phạm vi; banner không đổi |
| 2 | Đổi ngày dự định sang Thứ Bảy 14/11 | Card chuyển cột; toast G04 MSG-01 có Hoàn tác (G02 CASE-12); ngày gốc giữ 13/11 |
| 3 | Bấm ✓ ở một lần ngày tương lai | Lần đó xong, ở nguyên cột ngày đó (CASE-21) |

Nhánh: đổi ngày sang ngày đã có lần cùng series → CASE-39 (kéo / chọn ngày), CASE-40 (phím D); xoá lần này → CASE-23; đổi giờ timebox → CASE-20; lưu lỗi → CASE-52. Nguồn: UC-03 bước 3–4, UC-03 A4, UC-03 A6, UC-03 A7, UC-03 A9, UC-03 E1, BR-07.

### F-08 Đổi tần suất từ một lần

**Mở đầu:** chi tiết lần Thứ Hai 16/11 của chuỗi Thứ Hai, Thứ Tư, Thứ Sáu; lần Thứ Sáu 13/11 đã có 0:20 thời gian thực tế. **Kết thúc:** chuỗi lặp Thứ Hai, Thứ Năm; lần Thứ Sáu 13/11 được giữ và tách khỏi chuỗi. Sơ đồ: [UC-04](flow/g03-task-lap-lai.md#uc-04-sửa-series-đổi-tần-suất-đặt-giờ-áp-nội-dung).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm "Sửa series" trên banner (hoặc menu … → "Lặp lại", SCR-09.S03) | SCR-03.S01 |
| 2 | Chọn "Đổi tần suất" | SCR-01.S12 với quy tắc hiện tại |
| 3 | Bỏ T4, T6; chọn T5; bấm "Lưu" | SCR-01.S11 → đóng |
| 4 | – | Lần Thứ Tư, Thứ Sáu tương lai chưa động tới biến khỏi board (SCR-06.S08), lần Thứ Năm hiện ra (SCR-06.S07); lần hôm nay, quá khứ, đã xong giữ nguyên. **Một** toast: dòng 1 MSG-07 "Đã đổi tần suất, 26 lần sắp tới được cập nhật · Hoàn tác", dòng 2 MSG-24 "1 lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại" |
| 5 | Mở lần Thứ Sáu 13/11 | SCR-02.S05: MSG-25 "Lần này đã tách khỏi series "Đọc và trả lời email khách hàng" do đổi tần suất"; card không còn dấu lặp |

Nhánh: quy tắc không đổi → đóng, không gọi API (UC-04 A4); 412 → SCR-01.S14; lỗi → SCR-01.S13; mất mạng → SCR-03.S02; Hoàn tác → F-13; lần đang mở bị xoá hẳn → CASE-29; lần đang chạy timer → CASE-30. Con số 26 = 17 lần bị xoá hẳn + 9 lần Thứ Năm mới, theo O-07 (SRS mục 8). Nguồn: UC-04 bước 1–5, UC-04 A4, UC-04 A5, UC-04 A6, UC-04 E1 … E4, BR-08, BR-17.

### F-09 Cập nhật mọi lần chưa xong theo lần đang mở

**Mở đầu:** chi tiết lần Thứ Sáu 13/11 của "Standup nhóm sản phẩm", vừa thêm subtask "Cập nhật bảng Kanban" và đổi thời lượng 0:15 thành 0:20. **Kết thúc:** mẫu và mọi lần chưa xong từ hôm nay có subtask và thời lượng mới. Sơ đồ: [UC-04 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-1).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | "Sửa series" → "Cập nhật mọi lần chưa xong theo task này" | SCR-03.S03 |
| 2 | – | Toast MSG-08 "Đã cập nhật 43 lần chưa xong theo task này · Hoàn tác"; card các ngày tới đổi thời lượng 0:20 |

Subtask gộp theo tiêu đề: subtask đã tích ở lần hôm nay giữ dấu tích (CASE-09). Lần đã sửa riêng cũng bị ghi đè nội dung, timebox giữ (CASE-31). Nguồn: UC-04 A1, BR-08, C12.

### F-10 Đặt giờ bắt đầu cho cả chuỗi

**Mở đầu:** chi tiết một lần của "Đọc và trả lời email khách hàng", giờ khoảng 08:30. **Kết thúc:** mọi lần chưa xong từ hôm nay hiện 09:00. Sơ đồ: [UC-04 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-1).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | "Sửa series" → "Đặt giờ bắt đầu" | SCR-07.S02, 08:30 có dấu tích |
| 2 | Chọn 09:00 | SCR-07.S03: toast MSG-18 "Đã đặt giờ 09:00 cho các lần chưa xong · Hoàn tác"; giờ trên card đổi |
| 2a | Hoặc bấm "Xoá giờ" | Toast MSG-29 "Đã xoá giờ của các lần chưa xong · Hoàn tác" (O-10); card về giờ projection (SCR-06.S01) |

Lần có timebox: chỉ đổi giờ khoảng, timebox không dời (CASE-32). Nguồn: UC-04 A2, BR-06, BR-08, C12.

### F-11 Dừng lặp từ một lần

**Mở đầu:** chi tiết lần Thứ Hai 09/11 (đã xong) của "Đọc và trả lời email khách hàng". **Kết thúc:** chuỗi đã dừng; lần sắp tới chưa động tới bị xoá; banner MSG-15. Sơ đồ: [UC-05](flow/g03-task-lap-lai.md#uc-05-dừng-lặp--xoá-mọi-instance-chưa-xong).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | "Sửa series" → "Dừng lặp" | SCR-03.S03; không hỏi xác nhận |
| 2 | – | Card các lần tương lai chưa động tới thu lại và biến mất; lần hôm nay, quá khứ, đã xong, đã dời, sửa riêng, có thời gian thực tế giữ nguyên. **Một** toast: dòng 1 MSG-09 "Đã dừng lặp "Đọc và trả lời email khách hàng" · Hoàn tác", dòng 2 MSG-24 "1 lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại" |
| 3 | – | Banner chuyển SCR-02.S04; card còn lại SCR-06.S05 |

Nhánh: lần đang chạy timer → CASE-30; mở từ lần sẽ bị xoá → CASE-29; đã dừng ở thiết bị khác → SCR-03.S05; lỗi → SCR-03.S04; mất mạng → SCR-03.S02; Hoàn tác → F-13. Nguồn: UC-05 bước 1–3, UC-05 A2, UC-05 E1 … E3, BR-08, BR-17, B14.

### F-12 Xoá mọi lần chưa xong và dừng lặp

**Mở đầu:** chi tiết lần Thứ Tư 11/11 của "Đọc và trả lời email khách hàng". **Kết thúc:** chuỗi đã dừng; mọi lần chưa xong (trừ lần có thời gian thực tế) vào Thùng rác, ngày của chúng thành ngày ngoại lệ. Sơ đồ: [UC-05 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-2).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | "Sửa series" → "Xoá mọi lần chưa xong và dừng lặp" | SCR-04.S01 với MSG-10 (nội dung đầy đủ ở SCR-04.S01) |
| 2 | Bấm "Xoá và dừng lặp" | SCR-04.S02 |
| 3 | – | Dialog xác nhận đóng; lần Thứ Tư 11/11 đang mở cũng bị xoá nên dialog chi tiết đóng, focus về board (CASE-29); **một** toast: dòng 1 MSG-11 "Đã xoá 25 lần và dừng lặp · Hoàn tác", dòng 2 MSG-30 "1 lần đã có thời gian thực tế được giữ lại" về lần Thứ Sáu 13/11 (O-09) |

Nhánh: "Huỷ" / Esc → không đổi; {n} = 0 → SCR-04.S03; lỗi → SCR-04.S04; mất mạng → SCR-04.S05; đã dừng ở thiết bị khác → SCR-04.S06. Nguồn: UC-05 A1, UC-05 A2, BR-08, BR-15, BR-17, C13.

### F-13 Hoàn tác thao tác trên cả chuỗi

**Mở đầu:** toast MSG-07 / MSG-08 / MSG-09 / MSG-11 / MSG-18 / MSG-29 (hoặc MSG-33, MSG-34) còn hiện. **Kết thúc:** quy tắc, mẫu và mọi lần bị ảnh hưởng về như trước. Sơ đồ: [UC-04 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-1), [UC-05 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-2).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Bấm "Hoàn tác" trong toast (hoặc Ctrl+Z khi toast còn hiện, `[đề xuất]` theo G02 O-10) | Lần bị xoá hiện lại đúng chỗ (SCR-06.S07); lần bị tách gắn lại chuỗi (banner về SCR-02.S01); series về "Đang lặp"; timebox và sự kiện ngoài khôi phục theo QC-05 |
| 2 | – | Timer đã bị dừng **không** chạy lại; không có toast thứ hai |

Nguồn: UC-04 A3, UC-05 A3, BR-09.

### F-14 Mở danh sách mọi task lặp

**Mở đầu:** banner series hoặc bất kỳ đâu trong app. **Kết thúc:** đang xem lần kế tiếp của một chuỗi. Sơ đồ: [UC-07](flow/g03-task-lap-lai.md#uc-07-quản-lý-mọi-task-lặp).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | "Sửa series" → "Quản lý mọi task lặp"; hoặc Ctrl+, → "Task lặp lại"; hoặc link trong MSG-14 | Dialog chi tiết (nếu đang mở) đóng; Cài đặt mở ở nhóm "Task lặp lại" (O-14); SCR-05.S01 → S02 / S03 |
| 2 | Bấm tab "Đã dừng" | SCR-05.S04 / S05 |
| 3 | Về tab "Đang lặp"; trên dòng "Gửi hoá đơn tháng cho khách hàng" bấm … → "Mở lần kế tiếp" | Cài đặt đóng; board cuộn tới Thứ Hai 30/11; G02 SCR-03 của lần đó mở với SCR-02 (O-14) |

Nhánh: lỗi tải → SCR-05.S06; mất mạng → SCR-05.S07; lần kế tiếp chưa sinh → SCR-05.S10; đã bị xoá → SCR-05.S11. Nguồn: UC-07 bước 1–4, UC-07 A1, UC-07 A2, UC-07 E1 … E3.

### F-15 Đổi tần suất hoặc dừng lặp ngay trên dòng

**Mở đầu:** SCR-05.S02. **Kết thúc:** dòng cập nhật, hoặc chuyển sang tab "Đã dừng". Sơ đồ: [UC-04 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-1), [UC-05 nhánh thay thế](flow/g03-task-lap-lai.md#nhánh-thay-thế-2).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | Trên dòng "Báo cáo tuần cho anh Minh": … → "Đổi tần suất" | SCR-05.S08: SCR-01.S12 neo vào dòng |
| 2 | Đổi mỗi 2 tuần thành mỗi 1 tuần, "Lưu" | Toast MSG-07; dòng ghi "Hằng tuần vào Thứ Sáu" |
| 3 | Trên dòng "Đọc và trả lời email khách hàng": … → "Dừng lặp" | SCR-08.S01 với MSG-28 |
| 4 | Bấm "Dừng lặp" | SCR-08.S03 → SCR-05.S09; toast MSG-09 (+ MSG-24) |

Nhánh: mất mạng → SCR-05.S07; {n} = 0 → SCR-08.S02; đã dừng ở thiết bị khác → SCR-08.S06. Nguồn: UC-04 A7, UC-05 A4, B15.

### F-16 Một lần bị lỡ qua đêm

**Mở đầu:** tối Thứ Ba 10/11 lần "Standup nhóm sản phẩm" hôm đó chưa xong. **Kết thúc:** sáng Thứ Tư 11/11, cột hôm nay chỉ có một lần của chuỗi. Sơ đồ: [UC-06](flow/g03-task-lap-lai.md#uc-06-xử-lý-instance-trùng-series-trong-một-ngày-qc-06-rollover-g06-phím-d-g04-shutdown-g08), [nhánh rollover](flow/g03-task-lap-lai.md#nhánh-thay-thế-và-lỗi-rollover).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1 | – | 04:00 Thứ Tư: rollover (G06). Hôm nay đã có lần Thứ Tư 11/11 của chuỗi → lần 10/11 vào Lưu trữ, lý do "Đã bỏ qua" (G06 MSG-13); không toast; nhật ký "Hệ thống · Bị bỏ qua vì đã có lần lặp hôm nay" (UI-29) |
| 2 | Mở app | Cột hôm nay có một card "Standup nhóm sản phẩm"; lần 10/11 chỉ thấy trong panel Lưu trữ (G06) |

Nhánh: series chưa có lần hôm nay → CASE-35; series đã dừng → CASE-36; lần đã tách → CASE-37; lần quá khứ đã sửa riêng / có thời gian thực tế → CASE-38; rollover lỗi → CASE-42. Nguồn: UC-06 bước 1–3, UC-06 A1, UC-06 A2, UC-06 A6, UC-06 A7, UC-06 E1, BR-10, BR-16.

### F-17 Dời một lần vào ngày đã có lần cùng chuỗi

**Mở đầu:** lần "Standup nhóm sản phẩm" Thứ Năm 12/11 trên board. **Kết thúc:** tuỳ đường: hai lần cùng ngày (có cảnh báo), hoặc lần được dời vào Lưu trữ. Sơ đồ: [nhánh đường đổi ngày khác](flow/g03-task-lap-lai.md#nhánh-thay-thế-đường-đổi-ngày-khác).

| Bước | Người dùng | Hệ thống / màn hình |
|---|---|---|
| 1a | Kéo card sang cột Thứ Sáu 13/11 (hoặc chọn ngày) | Card ở cột 13/11 cạnh lần 13/11; **một** toast: dòng 1 G04 MSG-01, dòng 2 G04 MSG-23 "Ngày này đã có Standup nhóm sản phẩm" (nội dung G03 MSG-21) |
| 1b | Hoặc chọn card rồi nhấn D | Lần 12/11 vào Lưu trữ "Đã bỏ qua"; toast G04 MSG-24 "Thứ Sáu 13/11 đã có Standup nhóm sản phẩm, bản này được chuyển vào Lưu trữ · Hoàn tác" |
| 1c | Hoặc khôi phục một lần "Đã bỏ qua" từ Lưu trữ / một lần từ Thùng rác vào ngày đã có lần | Khôi phục; cảnh báo G06 MSG-21 / G02 MSG-24 (nội dung G03 MSG-21) |

Shutdown "Ngày mai" đi như 1b, chữ toast do G08 (UC-02 A9) dùng nội dung G04 MSG-24. Nguồn: UC-03 A4, UC-06 A3, UC-06 A4, UC-06 A5, BR-16, QC-06, C15.

## 6. Case chính và edge case

| Mã | Tình huống | Màn / trạng thái | Hiện gì | Tham chiếu |
|---|---|---|---|---|
| **Dữ liệu** | | | | |
| CASE-01 | Tiêu đề series 500 ký tự | Toast MSG-09 / MSG-21 / MSG-25, SCR-04, SCR-08, SCR-05 | Toast cắt {tiêu đề} một dòng "…"; dialog cắt sau 2 dòng; dòng SCR-05 cắt 1 dòng, tooltip đủ | G02 BR-01 |
| CASE-02 | Câu mô tả quy tắc dài nhất (mỗi 99 tuần, đủ 7 thứ) | SCR-01, SCR-02, SCR-06 tooltip, SCR-05 | Popover và banner xuống dòng; dòng SCR-05 cắt 1 dòng | BR-01 |
| CASE-03 | Hằng tuần chọn đủ 7 thứ | SCR-01.S04 | Vẫn là Hằng tuần, câu liệt kê đủ 7 thứ; không tự đổi thành Hằng ngày `[đề xuất]` | BR-01 |
| CASE-04 | Chuỗi Hằng ngày: 61 lần trong 60 ngày | Board (G04), SCR-04 | Mỗi cột một card; xoá mọi lần chưa xong {n} tới 61 | BR-04 |
| CASE-05 | 200 series đang lặp | SCR-05.S02, SCR-01.S10 | Danh sách 200 dòng cuộn; bật lặp task thứ 201 bị chặn | BR-12 |
| CASE-06 | Tiêu đề một lần đã sửa riêng khác tiêu đề mẫu | SCR-05, toast | SCR-05 và mọi {tiêu đề} / {tên series} của chuỗi dùng tiêu đề mẫu `[đề xuất]`; MSG-06 không chứa tiêu đề | BR-05, BR-07 |
| CASE-07 | Channel của mẫu bị xoá | SCR-05, SCR-06 | Mẫu và các lần chuyển sang channel nhận; dòng SCR-05 đổi channel, không báo riêng | G02 BR-14, C10, BR-05 |
| CASE-08 | "Cập nhật mọi lần chưa xong theo task này" từ một lần đã xong | SCR-03 | Vẫn làm được; lần đã xong không đổi (bảng phạm vi cột `HOAN_THANH`) `[đề xuất]` | BR-08, C12 |
| CASE-09 | Gộp subtask theo tiêu đề | G02 SCR-03 subtask | Subtask cùng tiêu đề giữ dấu tích và thời gian thực tế; subtask mới thêm ở chưa xong; subtask không còn trong mẫu bị gỡ nếu chưa xong và chưa có thời gian thực tế | BR-08, C12 |
| **Thời gian và ngày** | | | | |
| CASE-10 | Ngày 31 ở tháng 30 ngày và tháng 2 | SCR-01.S07, board | Lần ở 30/11, 31/12, 31/01/2027, 28/02/2027, rồi 31/03/2027 | BR-03, PRD US1.2 AC01 |
| CASE-11 | Hằng năm vào 29/2 | SCR-01.S07 | MSG-05; lần ở 28/02/2027, 29/02/2028 | BR-03, PRD US1.2 AC02 |
| CASE-12 | Mỗi N tuần, sau đó đổi cài đặt ngày đầu tuần (G01) | SCR-01.S05, S12 | Lịch của chuỗi cũ không đổi; MSG-26 ở Đổi tần suất vẫn ghi ngày đầu tuần đã lưu; nút thứ sắp theo cài đặt hiện tại | BR-03, C14, UC-01 A7 |
| CASE-13 | Lịch làm việc có Thứ Bảy, hoặc bỏ Thứ Tư | Board | Thứ Hai–Thứ Sáu không sinh Thứ Bảy; Hằng ngày vẫn sinh Thứ Tư; không có chữ báo | BR-03, Q43 |
| CASE-14 | Qua mốc đầu ngày | SCR-06.S07 | Lần mới cho ngày thứ 60 hiện, không báo | UC-02 bước 1 |
| CASE-15 | Job ngừng nhiều ngày | Board | Không sinh lần cho ngày đã qua; sinh bù từ hôm nay | UC-02 A2, C14 |
| CASE-16 | Không có ngày nào trong 60 ngày tới (Hằng năm, mỗi N lớn) | SCR-02.S03, SCR-05.S10 | Không có card mới; "Sau" mờ với MSG-20; ngày xa hiện "Dự kiến" theo G04 BR-23 | UC-02 A3 |
| CASE-17 | Đổi timezone | Board | Ngày gốc và ngày dự định của các lần đã sinh giữ nguyên | BR-11, QC-01 mục 4 |
| CASE-18 | Bật lặp lúc 02:00 ngày 11/11, mốc đầu ngày 04:00 | SCR-01 | "Hôm nay" là Thứ Ba 10/11; "Lần đầu" và MSG-01 tính theo ngày làm việc | BR-11, QC-01 |
| **Sửa một lần** | | | | |
| CASE-19 | Sửa riêng một lần (priority, thời lượng, notes) | G02 SCR-03 | Không có hộp hỏi phạm vi; mẫu không đổi; không có dấu hiệu "đã sửa riêng" trên card hay banner `[đề xuất]` | BR-07, PRD US2.3 |
| CASE-20 | Đổi giờ / thời lượng timebox của một lần (kéo trên lịch, sửa giờ) | Lịch (G05) | Như G05, không hỏi phạm vi; lần này thành sửa riêng (hệ quả ở CASE-28, CASE-38) | UC-03 A9, BR-07, Q44 |
| CASE-21 | Hoàn thành một lần ở ngày tương lai | SCR-06.S04 | Lần đó xong ở nguyên cột ngày đó | UC-03 A6, Q12 |
| CASE-22 | Bỏ hoàn thành một lần, về hôm nay đã có lần cùng chuỗi | Toast G02 | Toast G02 MSG-37, dòng 2 G02 MSG-24 | G02 BR-09 |
| CASE-23 | Xoá một lần | Toast G02 MSG-09 | Như xoá task thường; ngày gốc thành ngày ngoại lệ: Hoàn tác, khôi phục từ Thùng rác, đổi tần suất qua lại đều không sinh lại ngày đó. Không hiện gì thêm | UC-03 A7, BR-15, Q26 |
| CASE-24 | Xoá lần đầu tiên | SCR-02 | Chuỗi vẫn lặp; lần sau trở thành lần đầu trong banner (MSG-06 với {thứ n} = "đầu tiên") (O-04) | BR-07 |
| CASE-25 | Nhân bản một lần | G02 SCR-03 | Bản sao là task thường, không banner, không dấu lặp | G02 BR-10 |
| CASE-26 | Bật lặp trên một lần của chuỗi đã dừng | SCR-09.S01 → SCR-01.S01 | Tạo chuỗi mới từ lần đó; banner của nó thành "lần đầu tiên" của chuỗi mới | UC-01 A4, BR-12 |
| **Sửa cả chuỗi** | | | | |
| CASE-27 | Đổi tần suất khi có lần hôm nay, quá khứ, đã xong, trong Lưu trữ, Thùng rác | Board | Các lần đó giữ nguyên, không tính vào {n} | UC-04 A5, EC-29, C12 |
| CASE-28 | Đổi tần suất: lần tương lai đã dời / sửa riêng (kể cả sửa giờ timebox) / có thời gian thực tế, ngày gốc không khớp quy tắc mới | SCR-02.S05, SCR-06.S06 | Lần đó được giữ, tách khỏi chuỗi, giữ timebox; toast hai dòng MSG-07 + MSG-24 | UC-04 A6, BR-08, BR-17, Q26, Q44 |
| CASE-29 | Thao tác cả chuỗi xoá luôn lần đang mở (lần tương lai chưa động tới khi Dừng lặp, Xoá mọi lần chưa xong, hoặc ngày gốc không khớp khi Đổi tần suất) | G02 SCR-03 | Dialog chi tiết đóng, focus về board; vẫn hiện toast của thao tác. Hoàn tác đưa card về, không mở lại dialog `[đề xuất]` | BR-08, B14 |
| CASE-30 | Lần trong phạm vi đang chạy timer khi Dừng lặp / Đổi tần suất / Xoá mọi lần chưa xong | Timer (G07), toast | Timer dừng (G07 báo); lần có thời gian thực tế được giữ, đếm vào dòng 2 của toast; Hoàn tác không chạy lại timer | UC-04 A6, UC-05 A2, BR-17, C13 |
| CASE-31 | Cập nhật theo lần đang mở khi có lần đã sửa riêng | Board | Nội dung của lần đó bị ghi đè; timebox giữ nguyên | BR-08, PRD US3.2 AC04 |
| CASE-32 | Đặt giờ bắt đầu khi có lần đã có timebox | Board, lịch (G05) | Chỉ đổi giờ khoảng; timebox không dời | BR-08, PRD US3.3 AC03 |
| CASE-33 | Hoàn tác thao tác cả chuỗi | Toast | Như F-13 | BR-09 |
| **Instance trùng series trong một ngày (QC-06)** | | | | |
| CASE-34 | Rollover, chuỗi đã có lần hôm nay | Lưu trữ (G06) | Lần quá khứ chưa xong vào Lưu trữ "Đã bỏ qua" (G06 MSG-13); không toast | UC-06 bước 2–3, BR-10, EC-30 |
| CASE-35 | Rollover, chuỗi chưa có lần hôm nay, nhiều lần quá khứ chưa xong | Board, Lưu trữ | Lần mới nhất về hôm nay (nhãn "Dời {n} ngày" của G06); các lần cũ hơn "Đã bỏ qua" | UC-06 A1, BR-10 |
| CASE-36 | Rollover, chuỗi đã dừng | Board | Lần quá khứ về hôm nay như task thường | UC-06 A2 |
| CASE-37 | Rollover, lần đã tách | Board | Như task thường, không xét QC-06 | UC-06 A6 |
| CASE-38 | Rollover, lần quá khứ đã sửa riêng / có thời gian thực tế, hôm nay đã có lần cùng chuỗi | Board | Lần đó vẫn về hôm nay: cột hôm nay có **hai** card cùng chuỗi; không làm lần khác thành "Đã bỏ qua" | UC-06 A7, BR-10, B08 |
| CASE-39 | Kéo thả / chọn ngày vào ngày đã có lần cùng chuỗi | Toast G04 | Cho phép; một toast: dòng 1 G04 MSG-01, dòng 2 G04 MSG-23 | UC-03 A4, UC-06 A5, QC-06 mục 3 |
| CASE-40 | Phím D / shutdown "Ngày mai" vào ngày đã có lần cùng chuỗi | Toast G04 / G08 | Lần được dời vào Lưu trữ "Đã bỏ qua"; toast G04 MSG-24 có Hoàn tác (G08 dùng cùng nội dung) | UC-03 A4, UC-06 A4, C15 |
| CASE-41 | Khôi phục từ Lưu trữ / Thùng rác vào ngày đã có lần cùng chuỗi | Toast G06 / G02 | Cho phép; cảnh báo G06 MSG-21 / G02 MSG-24 | UC-06 A3 |
| CASE-42 | Rollover lỗi giữa chừng | Banner G06 | Banner lỗi rollover (G06 MSG-25); chạy bù khi mở app; G03 không vẽ | UC-06 E1, G06 BR-18, BR-19 |
| **Mạng và đồng bộ** | | | | |
| CASE-43 | Bật lặp khi mất mạng | SCR-01.S15, SCR-06.S03 | Như F-04 | UC-01 E4 |
| CASE-44 | Hai thiết bị offline cùng bật lặp một task | Toast | Lệnh tới sau bị từ chối: toast MSG-23; tải lại task và series; card theo chuỗi của thiết bị kia | UC-01 E8, QC-08 mục 4 |
| CASE-45 | Sửa một lần khi mất mạng | G02 SCR-03.S18 | Chạy trên máy, dấu "Chờ đồng bộ" như G02 | QC-08 mục 7, SRS mục 10 |
| CASE-46 | Thao tác cả chuỗi khi mất mạng | SCR-09.S04, SCR-01.S16, SCR-03.S02, SCR-07.S04, SCR-04.S05, SCR-08.S05, SCR-05.S07 | Mờ, tooltip MSG-27; không gọi API | UC-04 E4, UC-05 E3, UC-07 E2 |
| CASE-47 | Chuỗi vừa sửa ở thiết bị khác | SCR-01.S14, SCR-02.S09 | Picker: MSG-16, nạp quy tắc mới; banner: cập nhật ngay, không báo | UC-04 E1, QC-08 mục 3 |
| CASE-48 | Chuỗi đã dừng ở thiết bị khác khi đang thao tác | SCR-03.S05, SCR-04.S06, SCR-08.S06 | MSG-15 (banner, hoặc toast khi không có banner, O-12) | UC-05 E1 |
| CASE-49 | Mở một lần / chuỗi đã bị xoá ở thiết bị khác | SCR-02.S07, SCR-05.S11 | Toast MSG-17; gỡ card / tải lại danh sách | UC-03 E3, UC-07 E3, C11 |
| CASE-50 | Toast của G03 phát sinh khi cửa sổ app ẩn ở khay | Trung tâm thông báo | Nội dung vào trung tâm thông báo thành dòng chưa đọc; không mang nút Hoàn tác | IA-21 |
| **Lỗi** | | | | |
| CASE-51 | Job sinh instance lỗi | Board | Không hiện gì; lần ở ngày xa tới muộn ở lượt sau | UC-02 E1 |
| CASE-52 | Lưu lỗi khi sửa một lần | G02 SCR-03.S17 | Trường về giá trị cũ; toast QC-MSG-01 (G02 MSG-10) | UC-03 E1 |

## 7. Copy

MSG-xx chép nguyên văn từ SRS G03 mục 9 (nguồn vẫn là SRS); ghi chú trong ngoặc của SRS (mã quyết định, "chữ trong ngoặc kép là link") chuyển sang cột Ghi chú. MSG của nhóm khác và câu chung QC-MSG ghi rõ nguồn. UI-xx là chữ nhãn, tooltip, nhãn đọc màn hình (không phải thông báo); brief là nguồn của chữ UI-xx, SRS G03 mục 7 trỏ về đây. Chữ UI-xx là thông báo / toast / xác nhận / tooltip trạng thái đã thành MSG-29 … MSG-35 của SRS (chốt 10/11/2026, O-21). Chữ đã có trong SRS nhưng chưa có mã ghi "Chữ từ SRS …"; chữ thuộc câu O đã duyệt 10/11/2026 bỏ nhãn; chữ mới còn lại gắn `[đề xuất]`, chờ PO. Mọi chữ theo [DS-07](01-nen-tang-design-system.md#11-giọng-văn); ký hiệu (dấu tích, mũi tên, icon lặp) là icon đặt cạnh chữ (QC-13 mục 4).

**Độ dài và dạng biến** dùng chung:
- {tiêu đề}, {tên series} = tiêu đề mẫu của series, ≤ 500 ký tự; trong toast cắt một dòng bằng "…" (CASE-01).
- {mô tả quy tắc} theo mẫu UI-10, dài nhất khoảng 80 ký tự.
- {ngày}: "Thứ Tư 11/11"; khác năm hiện tại thêm năm "Chủ Nhật 28/02/2027", dài nhất "Chủ Nhật 28/02/2027"; trong MSG-01 và dòng "Lần kế tiếp" ở SCR-05, ngày hôm nay ghi "hôm nay" `[đề xuất]`.
- {n}, {k} ≤ 61 với một chuỗi Hằng ngày; {max} = 200 (BR-12). {giờ} "09:00". {thứ} trong MSG-26: "Thứ Hai" hoặc "Chủ Nhật". {D} 1–31.
- {thứ n} trong MSG-06: "đầu tiên" khi là lần 1, ngược lại "thứ {n}" bằng chữ số ("thứ 2", "thứ 365"), đếm theo ngày gốc trong các lần còn gắn chuỗi, không tính lần đã xoá (O-04, SRS mục 9).

**Thông báo (MSG)**

| Mã | Nơi hiện | Nội dung (VI) | Biến | Ghi chú |
|---|---|---|---|---|
| MSG-01 | Toast (F-01 … F-04) | Task giờ sẽ lặp lại {mô tả quy tắc}, bắt đầu từ {ngày} | {mô tả quy tắc}, {ngày} | Không có Hoàn tác (SRS). {ngày} = ngày lần đầu, kể cả khi task bị dời (UC-01 A1, A6) |
| MSG-02 | Inline dưới ô "Mỗi" (SCR-01.S08) | Khoảng lặp từ 1 đến 99 | – | Kiểu lỗi, có icon |
| MSG-03 | Inline dưới nhóm nút thứ (SCR-01.S09) | Chọn ít nhất một thứ trong tuần | – | Kiểu lỗi |
| MSG-04 | Ghi chú dưới ô ngày (SCR-01.S07) | Tháng không có ngày {D} sẽ dùng ngày cuối tháng | {D} 29–31 | Chữ phụ, không phải lỗi |
| MSG-05 | Ghi chú dưới ô ngày (SCR-01.S07) | Năm không nhuận sẽ dùng ngày 28/2 | – | Chữ phụ |
| MSG-06 | Banner (SCR-02.S01 … S03) | Task này lặp lại {mô tả quy tắc}. Đây là lần {thứ n} của series | {mô tả quy tắc}, {thứ n} | Tối đa 2 dòng |
| MSG-07 | Toast (F-08, F-15) | Đã đổi tần suất, {n} lần sắp tới được cập nhật · Hoàn tác | {n} (O-07); n = 0 → MSG-33 | Toast ≥ 5 giây. Dòng 2 MSG-24 khi có lần được giữ |
| MSG-08 | Toast (F-09) | Đã cập nhật {n} lần chưa xong theo task này · Hoàn tác | {n}; n = 0 → MSG-34 | Toast ≥ 5 giây |
| MSG-09 | Toast (F-11, F-15) | Đã dừng lặp "{tiêu đề}" · Hoàn tác | {tiêu đề} | Toast ≥ 5 giây. Dòng 2 MSG-24 khi có lần được giữ |
| MSG-10 | Nội dung SCR-04 | Xoá {n} lần chưa xong của "{tiêu đề}" và dừng lặp? Các lần đã xong và các lần đã có thời gian thực tế được giữ lại. Task xoá nằm trong Thùng rác 30 ngày | {n} (O-11), {tiêu đề} cắt sau 2 dòng | n = 0 → MSG-32 |
| MSG-11 | Toast (F-12) | Đã xoá {n} lần và dừng lặp · Hoàn tác | {n} | Toast ≥ 5 giây. Dòng 2 MSG-30 (O-09) |
| MSG-12 | Toast (SCR-01.S13, SCR-03.S04, SCR-07.S05, SCR-04.S04, SCR-08.S04) | Chưa lưu được thay đổi. Thử lại | – | = QC-MSG-01 (QC-13 mục 1); "Thử lại" là nút |
| MSG-14 | Inline dưới ô "Lặp" (SCR-01.S10) | Bạn đã có {n} task lặp đang chạy, tối đa {max}. Dừng bớt trong "Quản lý mọi task lặp" | {n}, {max} = 200 | Chữ trong ngoặc kép là link mở Cài đặt → Task lặp lại (C16) |
| MSG-15 | Banner (SCR-02.S04); tooltip icon lặp (SCR-06.S05); toast khi không có banner (SCR-08.S06, SCR-01.S11 mở từ SCR-05) | Series này đã dừng lặp | – | O-12, O-15 |
| MSG-16 | Toast (SCR-01.S14) | Series vừa được sửa trên thiết bị khác, đã tải lại | – | |
| MSG-17 | Toast (SCR-02.S07, SCR-05.S11) | Task hoặc series này không còn tồn tại | – | C11; O-13 |
| MSG-18 | Toast (SCR-07.S03) | Đã đặt giờ {giờ} cho các lần chưa xong · Hoàn tác | {giờ} "09:00" | Xoá giờ dùng MSG-29 (O-10) |
| MSG-19 | Empty state (SCR-05.S03) | Chưa có task lặp lại nào. Mở menu … của một task → "Lặp lại" để bắt đầu | – | Dấu "…" và "→" trong chữ SRS nên giữ; xem mục 12 |
| MSG-20 | Tooltip "Sau" mờ (SCR-02.S03); dòng SCR-05; tooltip "Mở lần kế tiếp" mờ (SCR-05.S10); dòng #9 SCR-01.S12 | Lần kế tiếp: {ngày} | {ngày} | O-06, O-16 |
| MSG-21 | Dòng 2 toast của nhóm sở hữu đường thủ công | Ngày này đã có {tên series} | {tên series} | Thông báo gốc QC-06 mục 3; G02 MSG-24, G04 MSG-23, G06 MSG-21 dùng nội dung này. G03 không tự hiện |
| MSG-22 | Tooltip mục "Lặp lại" mờ (SCR-09.S02) | Task đã hoàn thành không bật lặp được | – | Toast cùng chữ nếu API trả `TASK_COMPLETED` |
| MSG-23 | Toast (F-04, CASE-44) | Task này đã được đặt lặp lại trên thiết bị khác, đã tải lại | – | QC-08 mục 4 |
| MSG-24 | Dòng 2 của toast MSG-07 / MSG-09 | {k} lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại | {k} (O-07) | Một toast hai dòng (QC-13 mục 3, A3). MSG-11 dùng MSG-30 (O-09) |
| MSG-25 | Banner thay SCR-02 (SCR-02.S05) | Lần này đã tách khỏi series "{tiêu đề}" do đổi tần suất | {tiêu đề} cắt để câu ≤ 2 dòng | |
| MSG-26 | Ghi chú dưới ô "Mỗi" (SCR-01.S05, S12) | Tuần tính từ {thứ}; giữ cố định cho task lặp này | {thứ} | |
| MSG-27 | Tooltip trên nút / mục mờ khi mất mạng (CASE-46) | Cần có mạng để sửa cả chuỗi | – | QC-08 mục 7, C10 |
| MSG-28 | Nội dung SCR-08 | Dừng lặp "{tiêu đề}"? {n} lần sắp tới sẽ bị xoá. Các lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại | {n} (O-11), {tiêu đề} | B14, B15. n = 0 → MSG-31 |
| MSG-29 | Toast xoá giờ (SCR-07.S03, F-10) | Đã xoá giờ của các lần chưa xong · Hoàn tác | – | O-10; toast ≥ 5 giây. Trước là UI-25 |
| MSG-30 | Dòng 2 của toast MSG-11 (SCR-04.S02, F-12) | {k} lần đã có thời gian thực tế được giữ lại | {k} (O-07) | O-09. Trước là UI-26 |
| MSG-31 | Nội dung SCR-08 khi {n} = 0 (SCR-08.S02) | Dừng lặp "{tiêu đề}"? Không có lần sắp tới nào bị xoá | {tiêu đề} | O-08. Trước là UI-27 (a) |
| MSG-32 | Nội dung SCR-04 khi {n} = 0 (SCR-04.S03) | Dừng lặp "{tiêu đề}"? Không còn lần chưa xong nào để xoá | {tiêu đề} | O-08. Trước là UI-27 (b) |
| MSG-33 | Toast thay MSG-07 khi {n} = 0 | Đã đổi tần suất · Hoàn tác | – | O-08. Trước là UI-27 (c) |
| MSG-34 | Toast thay MSG-08 khi {n} = 0 | Đã cập nhật task lặp theo task này · Hoàn tác | – | O-08. Trước là UI-27 (d) |
| MSG-35 | Tooltip "Mở lần cuối" mờ (SCR-05.S10) | Không còn lần nào của series này | – | O-16. Trước là UI-28 |
| G02 MSG-09 | Toast xoá một lần (CASE-23) | Đã xoá · Hoàn tác (Ctrl+Z) | – | Nguồn G02 |
| G02 MSG-24 | Dòng 2 toast (CASE-22, CASE-41) | Ngày này đã có {tên series} | {tên series} | Nguồn G02, nội dung G03 MSG-21 |
| G02 MSG-30 | Tooltip icon chờ đồng bộ (SCR-06.S03) | Chờ đồng bộ | – | Nguồn G02 |
| G02 MSG-37 | Toast bỏ hoàn thành (CASE-22) | Đã bỏ đánh dấu xong "{tiêu đề}" · Hoàn tác | {tiêu đề} | Nguồn G02 |
| G02 MSG-38 | Toast (SCR-02.S07, O-13) | Task này đã bị xoá trên thiết bị khác · Hoàn tác | – | Nguồn G02 (G02 SCR-03.S16) |
| G04 MSG-01 | Toast (F-07, F-17, CASE-39) | Đã chuyển "{tiêu đề}" sang {thứ, ngày} · Hoàn tác | {tiêu đề}, {thứ, ngày} | Nguồn G04 |
| G04 MSG-23 | Dòng 2 toast G04 MSG-01 (F-17, CASE-39) | Ngày này đã có {tên series} | {tên series} | Nguồn G04, nội dung G03 MSG-21 |
| G04 MSG-24 | Toast (F-17, CASE-40) | {thứ, ngày} đã có {tên series}, bản này được chuyển vào Lưu trữ · Hoàn tác | {thứ, ngày}, {tên series} | Nguồn G04; G08 shutdown dùng cùng nội dung (C15) |
| G04 MSG-30 | Banner board (F-04) | Đang offline. Thay đổi được lưu trên máy và tự đồng bộ khi có mạng | – | Nguồn G04; G03 không vẽ banner |
| G06 MSG-13 | Nhãn lý do trong Lưu trữ (F-16, CASE-34) | Đã bỏ qua | – | Nguồn G06 (B09) |
| G06 MSG-21 | Toast cảnh báo khôi phục (CASE-41) | Ngày này đã có {tên series} | {tên series} | Nguồn G06, nội dung G03 MSG-21 |
| G06 MSG-25 | Banner lỗi rollover (CASE-42) | Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại | – | Nguồn G06 |
| QC-MSG-01 | Toast lỗi lưu (CASE-52) | Chưa lưu được thay đổi. Thử lại | – | QC-13 mục 1 |
| QC-MSG-02 | Tại chỗ (SCR-05.S06) | Chưa tải được. Thử lại | – | QC-13 mục 1, UC-07 E1 |

MSG-13 thuộc 1.1 (chế độ chỉ đọc), không dùng ở 1.0.

**Chữ giao diện (UI)**, câu O đã duyệt 10/11/2026

| Mã | Nơi hiện | Nội dung (VI) | Biến | Ghi chú |
|---|---|---|---|---|
| UI-01 | Mục menu G02 SCR-04, lệnh command menu (SCR-09) | Lặp lại | – | Chữ từ SRS UC-01 bước 1, mục 6 (= G02 UI-44) |
| UI-02 | Tiêu đề SCR-01 | Lặp lại / Đổi tần suất | – | `[đề xuất]` (vị trí tiêu đề); chữ từ SRS SCR-03 #2 |
| UI-03 | Nhãn ô SCR-01 | Lặp / Vào / Mỗi / Vào khoảng | – | Chữ từ SRS SCR-01 #1 … #4 |
| UI-04 | Lựa chọn ô "Lặp" | Hằng ngày / Thứ Hai–Thứ Sáu / Hằng tuần / Hằng tháng vào ngày {D} / Hằng tháng vào {thứ} {thứ N} / Hằng năm vào {ngày/tháng} | {thứ N}: đầu tiên, thứ 2, thứ 3, thứ 4, cuối cùng; {ngày/tháng} "29/02" | Chữ từ SRS SCR-01 #1; thứ tự "{thứ} {thứ N}" và dạng {thứ N} chốt O-04, "cuối cùng" chốt O-03 (SRS SCR-01 #1, BR-01) |
| UI-05 | Nút thứ (SCR-01 #2) | T2 / T3 / T4 / T5 / T6 / T7 / CN; nhãn đọc "Thứ Hai" … "Chủ Nhật", kèm "đã chọn" | – | `[đề xuất]`; nhãn đọc từ SRS mục 10 |
| UI-06 | Đơn vị sau ô "Mỗi" | ngày / tuần / tháng / năm | – | `[đề xuất]` |
| UI-07 | Lựa chọn đầu của "Vào khoảng" | Không đặt giờ | – | Chữ từ SRS SCR-01 #4 |
| UI-08 | Ô "Vào" của quy tắc tháng / năm | Ngày {D} / {thứ N} + {thứ} / {ngày} + Tháng {m} | {D} 1–31, {m} 1–12 | O-02 (SRS SCR-01 #11) |
| UI-09 | Dòng #9 SCR-01 | Lần đầu: {ngày} | {ngày} | Chữ từ SRS SCR-01 #9. Chế độ Đổi tần suất dùng chữ MSG-20 (O-06) |
| UI-10 | Mẫu {mô tả quy tắc} | Trong câu: "hằng ngày", "mỗi {N} ngày", "từ Thứ Hai đến Thứ Sáu", "hằng tuần vào {các thứ}", "mỗi {N} tuần vào {các thứ}", "hằng tháng vào ngày {D}", "hằng tháng vào {thứ} {thứ N}", "hằng năm vào {ngày/tháng}", "mỗi {N} tháng / năm vào …". Đứng riêng (SCR-01 #6, tooltip, SCR-05): viết hoa chữ đầu; Thứ Hai–Thứ Sáu ghi "Thứ Hai–Thứ Sáu" | {các thứ} theo thứ tự ngày đầu tuần, ngăn bằng ", " | O-04; mẫu ghi ở SRS mục 9. Ví dụ SRS SCR-01 #6: "Mỗi 2 tuần vào Thứ Ba, Thứ Năm" |
| UI-11 | Nút SCR-01 | Lưu | – | Chữ từ SRS SCR-01 #7 |
| UI-12 | SCR-02 | Sửa series / Trước / Sau; nhãn đọc nút: "Lần trước" / "Lần sau" | – | Chữ từ SRS SCR-02 #2, #3; nhãn đọc `[đề xuất]` |
| UI-13 | Tooltip "Trước" / "Sau" mờ ở đầu / cuối chuỗi | Đây là lần đầu của series / Đây là lần cuối của series | – | `[đề xuất]`. "Sau" mờ vì chưa sinh dùng MSG-20 |
| UI-14 | Icon lặp (SCR-06 #1) | Tooltip: {mô tả quy tắc} dạng đứng riêng; nhãn đọc: "Task lặp lại: {mô tả quy tắc}" | {mô tả quy tắc} | Nhãn đọc chữ từ SRS mục 10; tooltip theo mẫu UI-10 dạng đứng riêng (O-04, SRS SCR-06 #1) |
| UI-15 | Tooltip giờ khoảng trên card (SCR-06.S02) | Giờ khoảng của task lặp | – | O-15 (SRS SCR-06 #2) |
| UI-16 | Mục SCR-03 | Đổi tần suất / Đặt giờ bắt đầu / Cập nhật mọi lần chưa xong theo task này / Quản lý mọi task lặp / Dừng lặp / Xoá mọi lần chưa xong và dừng lặp | – | Chữ từ SRS SCR-03 #1 … #6, "instance" đổi thành "lần" (O-17); thứ tự theo O-18 |
| UI-17 | Tiêu đề SCR-07 | Giờ bắt đầu | – | `[đề xuất]` |
| UI-18 | Dòng phụ SCR-07 | Áp cho mọi lần chưa xong từ hôm nay | – | `[đề xuất]` |
| UI-19 | Nút SCR-07 | Xoá giờ | – | Chữ từ SRS SCR-07 #2 |
| UI-20 | Nút SCR-04 / SCR-08 | Xoá và dừng lặp / Huỷ; Dừng lặp / Huỷ | – | Chữ từ SRS SCR-04 #2, #3; SCR-08 #2, #3 (C13) |
| UI-21 | SCR-05 | Tiêu đề "Task lặp lại"; tabs "Đang lặp" / "Đã dừng" | Số cạnh tab `[đề xuất]` | Chữ từ SRS UC-07 bước 1, SCR-05 #1 |
| UI-22 | Menu dòng SCR-05 | Mở lần kế tiếp / Đổi tần suất / Dừng lặp / Mở lần cuối | – | Chữ từ SRS SCR-05 #3, UC-07 A1; O-17 |
| UI-23 | Dòng SCR-05 tab "Đã dừng" | Đã dừng {ngày} | {ngày} "Chủ Nhật 08/11" | `[đề xuất]` |
| UI-24 | SCR-05.S05 | Chưa có task lặp nào đã dừng | – | `[đề xuất]` |
| UI-29 | Dòng nhật ký (G02 SCR-03 #8, mẫu G02 UI-38) | Hệ thống: "Tạo từ series {tiêu đề}", "Tách khỏi series do đổi tần suất", "Bị bỏ qua vì đã có lần lặp hôm nay". Bạn: "bật lặp lại {mô tả quy tắc}", "đổi tần suất thành {mô tả quy tắc}", "cập nhật mọi lần chưa xong theo task này", "đặt giờ bắt đầu {giờ}", "dừng lặp" | – | Ba dòng "Hệ thống" chữ từ SRS BR-13, UC-06 bước 3; các dòng "Bạn" `[đề xuất]` (BR-13 chỉ nói có ghi) |
| UI-30 | Nhãn đọc màn hình dấu đang xử lý (SCR-01.S11, SCR-04.S02, SCR-08.S03, SCR-03.S03) | Đang lưu | – | `[đề xuất]` |

(Mã UI-25 … UI-28 đã thành MSG-29 … MSG-35, không dùng lại.)

## 8. Tương tác

**Phím tắt.** Phím một ký tự chỉ chạy khi không có ô nhập nào đang focus (G01 BR-15, EC-25). G03 không thêm phím tắt một ký tự.

| Phím | Ở đâu | Làm gì | Nguồn |
|---|---|---|---|
| Ctrl+K → "Lặp lại" | Task đang chọn / hover | Mở SCR-01 (SCR-09) | SRS mục 6 |
| Tab / Shift+Tab | SCR-01 | Lặp → Vào (nút thứ / ô ngày) → Mỗi → Vào khoảng → link trong MSG-14 (nếu có) → Lưu | SRS mục 10 (SCR-01 điều khiển hoàn toàn bằng bàn phím) |
| ←/→, Space | Nhóm nút thứ | Di chuyển giữa các thứ; bật / tắt thứ đang focus `[đề xuất]` | SRS mục 10 |
| ↑/↓ | Ô "Mỗi" | Tăng / giảm 1 `[đề xuất]` | – |
| Enter | SCR-01 (không trong danh sách đang mở) | "Lưu" khi nút đang bật `[đề xuất]` | – |
| ↑/↓, Enter | Ô "Lặp", SCR-03, SCR-07, menu dòng SCR-05 | Chọn, xác nhận | IA-16 |
| Gõ số | SCR-07 | Nhảy tới giờ gần nhất ("9" → 09:00, "1430" → 14:30) `[đề xuất]` | – |
| Esc | SCR-01, SCR-03, SCR-07, SCR-04, SCR-08 | Đóng lớp trên cùng, không lưu, không đổi | IA-16, UC-01 A5 |
| Ctrl+Z | Không đang gõ trong ô nhập | Hoàn tác thao tác cả chuỗi khi toast còn hiện `[đề xuất]` | G02 O-10, QC-13 mục 2 |
| Ctrl+, | Mọi nơi trong app | Cài đặt (rồi chọn Task lặp lại) | IA-15 |

**Focus và Tab**
- **SCR-01:** mở là focus vào ô "Lặp". Đóng (lưu hoặc Esc) thì focus về chỗ gọi: card, nút … trên header dialog, hoặc dòng SCR-05.
- **SCR-02:** trong thứ tự Tab của G02 SCR-03, sau các chip header và trước ✓: "Sửa series" → "Trước" → "Sau" `[đề xuất]`.
- **SCR-03, SCR-07:** mở là focus vào mục đầu / giờ hiện tại. Mục mờ vẫn nhận focus để đọc được tooltip MSG-27 (DS-08).
- **SCR-04, SCR-08:** focus đầu ở "Huỷ"; Esc = Huỷ.
- **SCR-05:** Tab qua tabs rồi từng dòng; dòng đang focus hiện nút …; Enter trên dòng = "Mở lần kế tiếp" `[đề xuất]`.

**Hover, chuột phải, kéo thả**
- Hover icon lặp: tooltip mô tả quy tắc. Hover "Sau" mờ: MSG-20. Hover dòng SCR-05: nút … hiện.
- Chuột phải trên card: menu "Khác" có SCR-09 (G02 O-11). G03 không thêm chuột phải hay kéo thả riêng; kéo card lặp sang ngày khác thuộc G04 (CASE-39).

**Toast và Hoàn tác** (QC-13)

| Thao tác | Toast | Hoàn tác | Ghi chú |
|---|---|---|---|
| Bật lặp | MSG-01 | Không | Muốn bỏ thì "Dừng lặp" |
| Đổi tần suất | MSG-07 (+ MSG-24 dòng 2) | Có, ≥ 5 giây | BR-09 |
| Cập nhật theo lần đang mở | MSG-08 | Có, ≥ 5 giây | |
| Đặt / xoá giờ bắt đầu | MSG-18 / MSG-29 | Có, ≥ 5 giây | O-10 |
| Dừng lặp | MSG-09 (+ MSG-24 dòng 2) | Có, ≥ 5 giây | Từ SCR-03 không hỏi xác nhận; từ SCR-05 qua SCR-08 |
| Xoá mọi lần chưa xong và dừng lặp | MSG-11 (+ MSG-30 dòng 2, O-09) | Có, ≥ 5 giây | Đã có SCR-04 xác nhận |
| Lỗi lưu | MSG-12 | "Thử lại" | QC-MSG-01 |
| Xung đột / không còn tồn tại | MSG-16, MSG-17, MSG-23 | Không | |

- Hai thông báo cùng lúc gộp **một** toast: dòng 1 là kết quả chính và giữ nút "Hoàn tác", dòng 2 là MSG-24 (với MSG-11 là MSG-30) (QC-13 mục 3, A3).
- Hoàn tác trả quy tắc, mẫu và mọi lần bị ảnh hưởng về đúng như trước (BR-09, QC-13 mục 5); không chạy lại timer.
- Cửa sổ app đang ẩn: toast vào trung tâm thông báo, không mang nút Hoàn tác (IA-21).

**Thời gian**
- \[SeriesCreate\] p95 ≤ 500 ms, gồm sinh 14 ngày đầu; mọi instance 60 ngày hiện đủ trên board ≤ 5 giây (SRS mục 10). Timeout 5 giây cho các API G03 (SRS mục 8).
- Thay đổi từ thiết bị khác hiện ≤ 5 giây.
- Job sinh instance chạy mỗi giờ `[giả định]` của SRS; người dùng không thấy job.
- Toast có Hoàn tác hiện ≥ 5 giây.
- Câu mô tả và "Lần đầu" trong SCR-01 cập nhật ngay khi đổi ô, không chờ server (tính trên máy theo BR-03).

**Mất mạng** (QC-08 mục 7)
- Bật lặp và sửa một lần chạy trên máy, vào hàng đợi, có dấu "Chờ đồng bộ" (SCR-06.S03, CASE-45).
- Mọi thao tác trên cả chuỗi mờ với MSG-27; "Quản lý mọi task lặp" và "Mở lần kế tiếp" vẫn dùng được (CASE-46).
- Banner offline là banner chung của board (G04 MSG-30); G03 không có banner riêng.

**Chuyển động** (DS-16, chỉ để giải thích việc vừa xảy ra)
- Bật lặp làm task dời ngày (UC-01 A6, A1): card bay sang cột ngày lần đầu.
- Instance mới sinh: mờ dần vào. Instance bị xoá do thao tác cả chuỗi: thu lại; Hoàn tác thì hiện lại tại chỗ.
- Windows tắt hoạt ảnh: thay bằng mờ dần ≤ 120 ms.

**Khả năng truy cập** (DS-08, SRS mục 10)
- SCR-01 dùng được hoàn toàn bằng bàn phím. Nút thứ đọc đủ tên ("Thứ Hai") và trạng thái chọn (UI-05); lựa chọn Thứ Hai–Thứ Sáu đọc là "Thứ Hai đến Thứ Sáu".
- Icon lặp có nhãn "Task lặp lại: {mô tả quy tắc}" (UI-14); nút "Trước" / "Sau" có nhãn UI-12; dấu đang xử lý có nhãn UI-30.
- Màu không là dấu hiệu duy nhất: lỗi trong SCR-01 có icon và chữ; mục nguy hiểm trong SCR-03 có chữ rõ, không chỉ màu đỏ.
- Kiểm tra bố cục ở text scaling 150% với câu mô tả dài nhất và chuỗi "Ếch ỗng Ữ Ặ".

## 9. Component dùng trong brief

Tầng theo [knowledge base component / snowflake](../design-system/00-knowledge-base-components-snowflakes.md): DS = design system dùng chung, Snowflake = gắn nghiệp vụ app.

| Component | Tầng | Dùng ở | Biến thể / trạng thái cần có |
|---|---|---|---|
| `Picker/Repeat` | Snowflake | SCR-01 | chế độ tạo / Đổi tần suất; các tổ hợp ô theo 6 quy tắc; lỗi; đang lưu; mất mạng; neo vào menu / dòng |
| `Combobox/Select` | DS (chưa có) | Ô "Lặp", ô thứ N, ô tháng, ô ngày | mặc định, mở, focus, disabled |
| `Input/Weekdays` | Snowflake | SCR-01 #2 | 7 nút, chọn / không chọn, focus, lỗi (MSG-03); thứ tự theo ngày đầu tuần |
| `Input/Number` | DS (chưa có) | Ô "Mỗi" | mặc định, lỗi (MSG-02), có đơn vị bên phải |
| `Picker/Time` | DS (có ở G02) | "Vào khoảng" SCR-01, SCR-07 | bước 15 phút; lựa chọn "Không đặt giờ"; giờ hiện tại có dấu tích; nút "Xoá giờ"; mờ khi mất mạng |
| `Banner/Series` | Snowflake | SCR-02 | đang lặp, lần đầu, lần kế tiếp chưa sinh, đã dừng, đã tách, đang chuyển, mất mạng |
| `Button/Icon` | DS (chưa có, G02) | "Trước" / "Sau", nút … trên dòng SCR-05 | `disabled` có tooltip; luôn có nhãn đọc màn hình |
| `Menu/Context` | DS | G02 SCR-04 (SCR-09), SCR-03, menu dòng SCR-05 | mục thường, mục nguy hiểm, mục mờ có tooltip, giá trị bên phải ("08:30"), đường kẻ |
| `Icon/Repeat` | Snowflake (icon riêng theo lưới Lucide) | SCR-06, SCR-02, SCR-09 | thường; series đã dừng (O-15) |
| `Card/Task` | Snowflake (G04 sở hữu) | SCR-06 | thêm icon lặp và giờ khoảng vào hàng đầu |
| `Icon/SyncState` | Snowflake (G02) | SCR-06.S03 | chờ đồng bộ |
| `Dialog` | DS | SCR-04, SCR-08 | xác nhận nguy hiểm, nội dung 3 dòng |
| `Button` | DS (`variant=primary\|secondary\|danger`) | "Lưu" SCR-01 (`primary` `sm`); "Xoá giờ" (`secondary` `sm`); "Huỷ" (`secondary`); "Xoá và dừng lặp", "Dừng lặp" SCR-08 (`danger`) | hover, focus, pressed, disabled, đang xử lý |
| `Nav/Tabs` | DS | SCR-05 | tab đang chọn, có số, focus |
| `List/SeriesRow` | Snowflake | SCR-05 | đang lặp, đã dừng, hover / focus (nút …), mất mạng, đang thu lại |
| `Toast` | DS | Mọi MSG toast | chỉ chữ, có một nút ("Hoàn tác" / "Thử lại"), hai dòng (QC-13 mục 3) |
| `Skeleton` | DS | SCR-05.S01, SCR-02.S06 | dòng |

## 10. Tham chiếu nghiệp vụ

| Chủ đề | Nguồn |
|---|---|
| Quy tắc lặp, giới hạn, nhãn Thứ Hai–Thứ Sáu | G03 BR-01, PRD mục 5, Q43 |
| Bật lặp, lần đầu, ngày đầu tuần | G03 BR-02, BR-03, C14 |
| Sinh instance, khoảng 60 ngày | G03 BR-04, UC-02 |
| Trường sao chép, mẫu series | G03 BR-05, C10 |
| Giờ khoảng, không timebox ở 1.0 | G03 BR-06, Q7, G05 BR-23 |
| Sửa một lần, sửa riêng (`customized`) | G03 BR-07, Q44 |
| Sửa cả chuỗi, bảng phạm vi | G03 BR-08, C12, C13, B14 |
| Hoàn tác | G03 BR-09, QC-13 mục 5, QC-05 |
| Instance bị lỡ, ngoại lệ B08 | G03 BR-10, G06 BR-11, B08 |
| Hôm nay, timezone | G03 BR-11, QC-01 |
| Giới hạn 200 series, series đã dừng không bật lại | G03 BR-12 |
| Nhật ký | G03 BR-13, G02 BR-13 |
| Một người dùng | G03 BR-14, Q35, Q45 |
| Ngày ngoại lệ | G03 BR-15, Q26 |
| Instance trùng series trong một ngày | G03 BR-16, QC-06, C15 |
| Timer khi đổi / dừng series | G03 BR-17, C13, G07 |
| Trạng thái series và instance | SRS G03 mục 4, QC-03 |
| Đồng bộ, offline | QC-08 (mục 4, mục 7), A6 |
| Toast, Hoàn tác, chữ lỗi chung | QC-13, A1, A3 |
| Bề mặt và điểm vào | IA mục 5, mục 10, mục 11; IA-16, IA-21 |
| Giọng văn, tên component, truy cập, chuyển động | DS-07, DS-09, DS-08, DS-16 |
| Kiểm chứng Sunsama | [`kiem-chung-sunsama-chrome.md`](../research/kiem-chung-sunsama-chrome.md) mục G03 |

## 11. Câu hỏi đã chốt

Các quyết định đã chốt (Q7, Q12, Q26, Q43, Q44, B08, B14, B15, B16, C10 … C16, A1, A3, A6) đã vẽ theo, không hỏi lại.

**PO duyệt ngày 10/11/2026: mọi câu chốt theo cột "Đề xuất của brief"**; O-11 chọn phương án đầu (tính {n} trên máy, không thêm `dryRun`). Cột "Chốt 10/11/2026" ghi nơi đã ghi ngược. Brief không còn câu hỏi mở. Cột "Câu hỏi" và "Đề xuất của brief" giữ nguyên chữ lúc hỏi, nên còn mã cũ (UI-25 … UI-28) và chữ "instance" cũ; mã tạm của mục "Lặp lại" đã đổi thành SCR-09.

| Mã | Câu hỏi | Ảnh hưởng tới | Đề xuất của brief | Ai chốt | Chốt 10/11/2026 |
|---|---|---|---|---|---|
| O-01 | Mục "Lặp lại" trên một lần của chuỗi đang lặp: SRS UC-01 A3 nói mục này mở SCR-01 ở chế độ "Đổi tần suất"; brief G02 (SCR-04.S02) ghi "Lặp lại" đổi thành mục sửa series. Chữ và hành vi là gì, mất mạng thì sao? | SCR-09.S03, S04; G02 SCR-04.S02 | Giữ chữ "Lặp lại", mở SCR-01 chế độ Đổi tần suất (theo SRS); mất mạng thì mờ, tooltip MSG-27. Sửa câu chữ G02 SCR-04.S02 cho khớp | PO, sửa brief G02 | Theo đề xuất. Mục "Lặp lại" là SRS G03 SCR-09 (#3, #4); SRS UC-01 A3, UC-04 E4, BR-02; PRD US1.1 AC01. Sửa brief G02 SCR-04.S02, SCR-03.S13 và SRS G02 SCR-04 #1 |
| O-02 | SRS SCR-01 chỉ có nhãn "Hằng tháng vào ngày {D}", "Hằng tháng vào {thứ N} {thứ}", "Hằng năm vào {ngày/tháng}" suy từ ngày của task, không có ô để chọn ngày khác (ví dụ ngày 31 khi task ở ngày 10), dù UC-01 A2 và MSG-04 nói "ô ngày". Quy tắc chọn sẵn khi mở picker cũng chưa nói | SCR-01.S01, S06, S07 | Thêm ô "Vào" cho ba quy tắc tháng / năm (ngày 1–31; thứ N + thứ; ngày + tháng), mặc định suy từ ngày dự định; nhãn trong ô "Lặp" đổi theo ô "Vào". Quy tắc chọn sẵn là "Hằng ngày" | PO, thêm vào SRS SCR-01 | Theo đề xuất. Thêm SRS SCR-01 #11; SCR-01 #1 và UC-01 bước 2 chọn sẵn "Hằng ngày"; PRD mục 5, US1.1 AC01 |
| O-03 | Hằng tháng theo thứ N có "cuối cùng" không (BR-01 `[giả định]`, PRD mục 10)? Ngày là lần thứ 4 và cũng là lần cuối trong tháng thì mặc định là gì? | SCR-01.S06, UI-04, UI-08 | Có "cuối cùng". Lần thứ 5 → mặc định "cuối cùng"; lần thứ 4 → "thứ 4" (người dùng tự đổi nếu muốn "cuối cùng") | PO, bỏ `[giả định]` BR-01 | Theo đề xuất. Bỏ `[giả định]` ở SRS BR-01, ghi quy tắc mặc định; PRD mục 5, mục 10 |
| O-04 | Câu mô tả quy tắc (dùng ở MSG-01, MSG-06, SCR-01 #6, tooltip, SCR-05) chưa có mẫu. Thứ tự "{thứ N} {thứ}" ở SRS SCR-01 #1 đọc thành "thứ hai Thứ Ba", khác ví dụ "Thứ Tư đầu tiên" của PRD. Lần thứ mấy {thứ n} đếm thế nào khi có lần đã xoá | UI-10, UI-04, MSG-06, CASE-24 | Theo mẫu UI-10; thứ N viết "{thứ} {thứ N}" với chữ số ("Thứ Ba thứ 2") để không lẫn với tên thứ; {thứ n}: "đầu tiên" / "thứ {n}", đếm theo ngày gốc trong các lần còn gắn chuỗi, không tính lần đã xoá | PO, BA ghi vào SRS mục 9 | Theo đề xuất. Mẫu {mô tả quy tắc} và {thứ n} ghi ở SRS mục 9; SRS SCR-01 #1, #6 |
| O-05 | Task backlog (hoặc task hôm nay) bật lặp với quy tắc không khớp hôm nay: SRS UC-01 A1 và PRD US1.1 AC05 ghi "đặt hôm nay", BR-02 tính ngày khớp quy tắc đầu tiên từ hôm nay | F-03, SCR-01 dòng "Lần đầu" | Theo BR-02: lần đầu là ngày khớp đầu tiên ≥ hôm nay (hôm nay nếu khớp); MSG-01 nêu ngày. Sửa chữ UC-01 A1, PRD US1.1 AC05 | PO, BA sửa SRS / PRD | Theo đề xuất. Sửa SRS UC-01 A1, BR-02 (bỏ `[giả định]` "coi ngày dự định là hôm nay"); PRD US1.1 AC05 |
| O-06 | SCR-01 ở chế độ Đổi tần suất: ô "Vào khoảng" có hiện không (giờ đã có SCR-07, dòng SCR-05 không có "Đặt giờ bắt đầu")? Dòng "Lần đầu: {ngày}" còn nghĩa không? | SCR-01.S12 | Ẩn "Vào khoảng" ở chế độ này; dòng #9 dùng chữ MSG-20 "Lần kế tiếp: {ngày}" tính theo quy tắc mới | PO, ghi SRS SCR-01 | Theo đề xuất. Ghi SRS SCR-01 #4, #9; MSG-20 thêm nơi hiện |
| O-07 | {n} trong MSG-07 đếm gì (lần bị xoá, lần mới, lần bị tách)? {k} trong MSG-24 có đếm lần hôm nay, quá khứ, đã xong được giữ không? SRS mục 8 có `affectedCount`, `keptCount` nhưng chưa định nghĩa | MSG-07, MSG-24, F-08 | {n} = số lần tương lai bị xoá hẳn + số lần mới sinh; {k} = số lần ở cột "đã dời / sửa riêng / có thời gian thực tế" của bảng phạm vi được giữ (không đếm hôm nay, quá khứ, đã xong) | BA, ghi SRS mục 8 | Theo đề xuất. Ghi SRS mục 8 "Số trong toast" |
| O-08 | {n} = 0 trong MSG-07, MSG-08, MSG-10, MSG-28 ("0 lần sắp tới sẽ bị xoá" thường gặp với Hằng năm) | SCR-04.S03, SCR-08.S02, toast | Dùng biến thể UI-27 (a) … (d) | PO, thêm MSG | Theo đề xuất. Chữ UI-27 (a) … (d) thành MSG-31 … MSG-34; SRS UC-04 bước 5, A1, UC-05 A1, A4, SCR-04 #1, SCR-08 #1 |
| O-09 | MSG-24 ở dòng 2 của MSG-11 nói "đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại", nhưng "Xoá mọi instance chưa xong" chỉ giữ lần có thời gian thực tế (bảng phạm vi (d)) | F-12, MSG-11 | Dòng 2 của MSG-11 dùng UI-26 "{k} lần đã có thời gian thực tế được giữ lại" | PO, thêm MSG | Theo đề xuất. Chữ UI-26 thành MSG-30; SRS BR-17, UC-05 A2, MSG-24; PRD US4.2 AC02 |
| O-10 | "Xoá giờ" (SCR-07 #2) không có toast: MSG-18 cần {giờ} | SCR-07.S03, F-10 | Thêm UI-25 "Đã xoá giờ của các lần chưa xong · Hoàn tác" | PO, thêm MSG | Theo đề xuất. Chữ UI-25 thành MSG-29; SRS UC-04 A2, SCR-07 #2; PRD US3.3 AC04 |
| O-11 | {n} trong MSG-10, MSG-28 cần có trước khi xác nhận, nhưng \[SeriesStop\] chỉ trả `deletedCount` sau khi chạy; SRS chưa có API xem trước | SCR-04, SCR-08 | Tính trên máy từ các lần đã đồng bộ (đủ 60 ngày); toast sau đó dùng số server trả. Nếu tech muốn chính xác: thêm `dryRun` cho \[SeriesStop\] | Tech, BA | Theo phương án đầu: tính trên máy, toast dùng số server trả; không thêm `dryRun`. Ghi SRS mục 8, SCR-04 #1, SCR-08 #1 |
| O-12 | 409 `SERIES_STOPPED` chỉ có ở UC-05 E1, hiện MSG-15 là banner. UC-04 (đổi tần suất, áp mẫu, đặt giờ) chưa có nhánh này; từ SCR-05 / SCR-08 không có banner để hiện | SCR-03.S05, SCR-04.S06, SCR-08.S06 | Thêm E# cho UC-04 như UC-05 E1. Có banner thì chuyển banner (SCR-02.S04); không có banner (SCR-05) thì toast cùng chữ MSG-15, dòng chuyển sang tab "Đã dừng" | BA, sửa SRS UC-04, UC-05 | Theo đề xuất. Thêm SRS UC-04 E5 `SERIES_STOPPED`; sửa UC-05 E1; MSG-15 thêm nơi hiện dạng toast |
| O-13 | Lần đang mở bị xoá ở thiết bị khác: G02 SCR-03.S16 đóng dialog, toast G02 MSG-38 có Hoàn tác; G03 UC-03 E3 ghi MSG-17 kèm ghi chú "đang mở thì đóng" | SCR-02.S07 | Đang mở và nhận realtime → theo G02 (MSG-38); MSG-17 chỉ khi mở card, bấm Trước / Sau hoặc thao tác chuỗi nhận 404. Sửa chữ UC-03 E3 | PO, BA sửa SRS G03 UC-03 E3 | Theo đề xuất. Sửa SRS G03 UC-03 E3; ghi chú SRS G02 UC-02 E3; PRD US2.2 AC04 |
| O-14 | SCR-05 là nhóm "Task lặp lại" trong Cài đặt (IA mục 5), nhưng G01 SCR-06 #1 chưa liệt kê nhóm này. Mở SCR-05 từ dialog chi tiết, và "Mở lần kế tiếp" từ Cài đặt, xếp lớp thế nào? | SCR-05, F-14 | Thêm "Task lặp lại" vào nhóm "Cá nhân" sau "Timebox". Mở SCR-05 thì đóng dialog chi tiết rồi mở Cài đặt; "Mở lần kế tiếp" đóng Cài đặt, board cuộn tới ngày đó và mở dialog chi tiết | PO, sửa SRS G01 SCR-06 #1 | Theo đề xuất. Thêm "Task lặp lại" vào SRS G01 SCR-06 #1 sau "Timebox"; kiến trúc thông tin đổi "Task lặp" thành "Task lặp lại"; SRS G03 UC-07 bước 1, 4, SCR-05 #3; PRD US6.1 AC02 |
| O-15 | Card: giờ khoảng và giờ projection cùng một chỗ, phân biệt thế nào? Lần của chuỗi đã dừng và lần đã tách có dấu lặp không? | SCR-06.S02, S05, S06 | Giờ khoảng cùng chỗ, tooltip UI-15, không thêm ký hiệu. Chuỗi đã dừng: giữ icon, tooltip MSG-15. Lần đã tách: không icon (là task thường) | PO, ghi SRS SCR-06 | Theo đề xuất. Ghi SRS SCR-06 #1, #2; MSG-15 thêm nơi hiện |
| O-16 | "Mở lần kế tiếp" khi lần kế tiếp chưa sinh (Hằng năm); "Mở instance cuối" khi chuỗi đã dừng không còn lần nào | SCR-05.S10 | Mục mờ: tooltip MSG-20 / UI-28 | PO, ghi SRS SCR-05 #3 | Theo đề xuất. Chữ UI-28 thành MSG-35; ghi SRS SCR-05 #3 |
| O-17 | Nhãn SRS dùng "instance" trên giao diện ("Cập nhật mọi instance chưa xong theo task này", "Xoá mọi instance chưa xong và dừng lặp", "Mở instance cuối"), còn mọi MSG dùng "lần" | UI-16, UI-22 | Đổi "instance" thành "lần": "Cập nhật mọi lần chưa xong theo task này", "Xoá mọi lần chưa xong và dừng lặp", "Mở lần cuối". Giữ "series" (CONTEXT.md) | PO, sửa SRS, ghi `CONTEXT.md` | Theo đề xuất. Đổi nhãn trong SRS (BR-08, UC-04 A1, UC-05 A1, E3, UC-07 A1, E3, SCR-03, SCR-05) và PRD mục 3.1; ghi `CONTEXT.md` (Instance) |
| O-18 | Thứ tự mục trong SCR-03 (SRS đánh số Dừng lặp trước Đổi tần suất) | SCR-03 | Đổi tần suất · Đặt giờ bắt đầu · Cập nhật … · Quản lý mọi task lặp · Dừng lặp · Xoá … (thao tác mất dữ liệu cuối, có đường kẻ) | PO | Theo đề xuất. Ghi thứ tự hiển thị ở SRS SCR-03 (giữ số #) |
| O-19 | "Xoá mọi instance chưa xong" có cần hộp xác nhận không (BR-08 (d) `[giả định]`, PRD mục 10), khi đã có Hoàn tác? | SCR-04 | Giữ hộp xác nhận SCR-04 và Hoàn tác (C13 đã chốt chữ nút) | PO, bỏ `[giả định]` BR-08 | Theo đề xuất. Bỏ `[giả định]` ở SRS BR-08 (d); PRD US4.2 AC01, mục 10 |
| O-20 | Ngày kết thúc series / số lần lặp: SRS ghi ngoài phạm vi, PRD mục 10 còn hỏi | SCR-01 | Không có ở 1.0; không chừa chỗ trong picker | PO, ghi PRD mục 10 | Theo đề xuất. Ghi PRD mục 3.2, mục 10 |
| O-21 | Ghi ngược vào SRS khi PO duyệt brief (không phải câu hỏi) | SRS G03 | Đặt mã SRS cho mục "Lặp lại" (mã tạm của brief, hoặc ghi vào G02 SCR-04 #1); đổi UI-xx là thông báo (UI-25, UI-26, UI-27, UI-28) thành MSG; ghi mẫu UI-10 vào SRS mục 9 | BA | Đã làm. SRS G03 thêm SCR-09 Mục "Lặp lại"; UI-25 … UI-28 thành MSG-29 … MSG-35; mẫu UI-10 ở SRS mục 9; SRS mục 7 trỏ về brief mục 7 cho chữ nhãn tĩnh (giữ mã UI-xx) |

## 12. Kiểm tra trước khi giao

Tích lại ngày 10/11/2026, sau khi PO duyệt mục 11 và đã ghi ngược vào PRD / SRS.

- [x] Mỗi màn ở mục 3 có bảng trạng thái và dữ liệu mẫu (9 / 9 màn).
- [x] Mỗi trạng thái có chữ (MSG / UI) cho mọi chỗ hiện chữ. Chữ thông báo trước là UI-xx nay có mã SRS: xoá giờ MSG-29, dòng 2 của MSG-11 MSG-30, {n} = 0 MSG-31 … MSG-34, "Mở lần cuối" mờ MSG-35 (O-21). MSG-19 giữ "…" và "→" vì chép nguyên văn SRS; nếu PO áp chặt QC-13 mục 4 thì sửa ở SRS.
- [x] Mỗi flow ở mục 5 trỏ tới sơ đồ UC trong `flow/` (F-01 … F-04 → UC-01; F-05 → UC-02; F-06, F-07 → UC-03; F-08 … F-10 → UC-04; F-11, F-12 → UC-05; F-13 → UC-04, UC-05; F-14 → UC-07; F-15 → UC-04, UC-05; F-16, F-17 → UC-06). Đã kiểm lại anchor với tiêu đề trong file flow ngày 10/11/2026.
- [x] Mọi luồng thay thế (A#) và luồng lỗi (E#) trong SRS của UC-01 … UC-07 đều có trong mục 4 hoặc mục 6, trừ UC-01 E6, UC-02 A1, UC-02 A4 (1.1, không vẽ) và UC-02 E2 (SRS đã bỏ), ghi ở mục 2. Nhánh mới ngày 10/11/2026: UC-04 E5 (`SERIES_STOPPED`, O-12) → SCR-01.S11, SCR-03.S05; UC-03 E3 tách nhánh đang mở (O-13) → SCR-02.S07.
- [ ] Không còn `[đề xuất]` chưa duyệt ở luồng chính (P1). Mọi `[đề xuất]` gắn với câu O-01 … O-21 đã bỏ nhãn. Còn các chi tiết không thuộc câu O nào, chờ PO duyệt riêng: lệnh "Lặp lại" không có trong Ctrl+K khi không có task (SCR-09.S05); tiêu đề picker (UI-02); biết đủ 200 series từ dữ liệu trên máy (SCR-01.S10); toast MSG-01 với ngày tính trên máy khi bật lặp lúc mất mạng (SCR-01.S15, F-04); ô vẫn chỉnh được khi mất mạng lúc đổi tần suất (SCR-01.S16); chữ nút thứ và đơn vị (UI-05, UI-06); vị trí icon lặp trước badge thời lượng (SCR-06); Trước / Sau mở lần đã có trên máy khi mất mạng (SCR-02.S08); tooltip đủ tiêu đề ở MSG-25; giờ khoảng bên phải mục "Đặt giờ bắt đầu"; dấu đang xử lý trên banner (SCR-03.S03); cuộn tới 09:00 (SCR-07.S01); tiêu đề và chữ phụ SCR-07 (UI-17, UI-18); SCR-04 không có tiêu đề riêng, Enter không tự xoá, tiêu đề cắt sau 2 dòng; "Dừng lặp" ở SCR-08 kiểu `danger`; số cạnh tab, thứ tự tab "Đã dừng", "Đã dừng {ngày}" (UI-23), empty state không hình và UI-24 (SCR-05); "hôm nay" trong {ngày}; tooltip đầu / cuối chuỗi (UI-13); nhãn đọc "Lần trước" / "Lần sau" (UI-12); dòng nhật ký "Bạn" (UI-29); nhãn đọc "Đang lưu" (UI-30); CASE-03, CASE-06, CASE-08, CASE-19, CASE-29; phím ←/→, Space, ↑/↓, Enter, gõ số, Ctrl+Z (theo G02 O-10); thứ tự Tab của banner; Enter trên dòng SCR-05.
- [x] Không còn câu hỏi mở chặn luồng chính (mục 11 đã chốt hết).
