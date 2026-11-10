# Nền tảng design system — app Windows bản 1.0

> **Mã:** PLN-DS · **Trạng thái:** đã duyệt 05/11/2026 · **Ticket:** [#8](https://github.com/tannguyenho/personal-app/issues/8) · **Bản đồ:** [#2](https://github.com/tannguyenho/personal-app/issues/2)
>
> Chốt qua buổi grilling ngày 04/11/2026, gồm 16 quyết định **DS-01 … DS-16** (mục 12). Đây là bản nền tảng (foundations) để PO dựng design system trong Figma. Tài liệu chỉ chốt **hướng và cấu trúc token**; mã màu cụ thể do PO chọn khi dựng, theo các ràng buộc ghi ở đây. Con số `[giả định]` thì designer chỉnh được.
>
> Liên quan: [kiến trúc thông tin](00-kien-truc-thong-tin.md) (khung và bề mặt), [khuôn brief](_khuon.md) (brief gọi component theo quy ước ở mục 8).

## 1. Cá tính và nguyên tắc

App **điềm tĩnh, có chủ đích** (DS-01): nhiều khoảng trắng, ít màu, nhấn đúng chỗ. Bốn nguyên tắc dùng để quyết định mọi chỗ còn lưỡng lự:

| Nguyên tắc | Nghĩa là | Ví dụ |
|---|---|---|
| **Yên tĩnh trước** | Màu chỉ dùng để báo trạng thái hoặc chỉ chỗ cần nhìn. Mặc định là trung tính | Channel hiện bằng chấm màu, không tô nền; không có màu "info" riêng |
| **Bàn phím trước** | Mọi thứ thấy được thì tới được bằng phím. Trạng thái đang chọn luôn nhìn thấy, khác với hover | Viền focus rõ ở mọi control; kéo thả luôn có phím thay thế |
| **Trung thực về trạng thái** | Chờ đồng bộ, lỗi, do AI làm, có Hoàn tác đều phải hiện rõ, không giấu | Icon "chờ đồng bộ" trên card; chip "AI"; toast nói đúng việc vừa xảy ra |
| **Gõ là xong** | Không bắt người dùng điền form. Giá trị mặc định tốt, sửa tại chỗ, lưu ngay | Ô soạn chỉ cần tiêu đề; chi tiết task không có nút Lưu |

## 2. Nền tảng và quy ước Windows

Design system **riêng, dùng chung cho mọi nền tảng** (Windows 1.0, web và macOS 1.1). Chỉ theo Windows ở phần vỏ (DS-02):

| Phần | Theo | Ghi chú |
|---|---|---|
| Thanh tiêu đề | App tự vẽ, cùng màu nền với sidebar | Giữ ba nút −, □, × chuẩn của Windows và Snap Layouts khi hover nút □ |
| Khay hệ thống, thông báo | Của Windows | Theo [IA](00-kien-truc-thong-tin.md) mục 7 |
| Phím tắt | Quy ước Windows (Ctrl) | macOS 1.1 đổi sang ⌘ |
| Menu, dialog, control, chuột phải | Design system của app | Không dùng control WinUI |
| Font | Đóng gói trong app (Inter) | Không phụ thuộc font của máy |

## 3. Giao diện sáng và tối

(DS-03)
- Vẽ giao diện **sáng trước**. Giao diện **tối có ngay từ đầu**, dựng bằng token màu (mỗi token có giá trị sáng và tối), không vẽ tay từng màn. Mỗi màn chỉ cần kiểm lại ở giao diện tối.
- Mặc định: **Hệ thống** (theo Windows). Người dùng đổi ở Cài đặt → Hiển thị (G01 SCR-08).
- Màu channel, màu ngữ nghĩa, màu nhấn và màu AI đều có biến thể riêng cho nền tối. Không chỉ đảo độ sáng.

## 4. Màu

### 4.1 Cấu trúc token

Ba tầng, Figma dùng Variables với hai mode Sáng / Tối:

1. **Bảng gốc** (primitive): các thang màu, ví dụ `teal/50 … teal/900`, `gray/0 … gray/950`. Chỉ tầng 2 được dùng tới tầng này.
2. **Token ngữ nghĩa**: `bg/*`, `text/*`, `border/*`, `accent/*`, `success/*`, `warning/*`, `danger/*`, `ai/*`, `channel/01 … 12`. **Component chỉ dùng token tầng này.**
3. **Token của component** (khi cần): ví dụ `card/bg-hover`.

### 4.2 Màu nhấn và màu AI

(DS-10)

| Vai trò | Sắc | Dùng cho | Ràng buộc |
|---|---|---|---|
| **Nhấn** | Xanh ngọc đậm (teal) | Nút chính, đang chọn, viền focus, cột hôm nay | Phải cách xa xanh lá (thành công) để không đọc nhầm "đang chọn" thành "đã xong" |
| **AI** | Tím | ✨, chip "AI", thẻ chờ duyệt, viền khung chat khi AI đang xử lý | Chỉ dùng cho những gì AI làm hoặc gợi ý. Không dùng làm màu trang trí |

### 4.3 Màu ngữ nghĩa

(DS-11) Không có màu "info" riêng. Thông tin trung tính (banner offline, toast thường) dùng thang xám và màu nhấn.

| Ý nghĩa | Sắc | Dùng cho |
|---|---|---|
| Trung tính | Xám hơi lạnh, 10 bậc | Nền, chữ, viền; task Kế hoạch; chờ đồng bộ |
| Thành công | Xanh lá | ✓ hoàn thành, thanh tiến độ ngày |
| Cảnh báo | Hổ phách | "Dời n ngày", due sắp tới, khối lượng sắp chạm ngưỡng (nếu brief G04 giữ mức vàng) |
| Nguy hiểm | Đỏ | Quá tải, due quá hạn, lỗi, nút xoá |
| AI | Tím (4.2) | Mục 4.2 |
| Nhấn | Teal (4.2) | Mục 4.2 |

Mỗi màu ngữ nghĩa có ít nhất bốn token: `*/fg` (chữ, icon), `*/bg` (nền nhạt), `*/border`, `*/solid` (nền đặc cho nút). Màu **luôn đi kèm icon hoặc chữ** (DS-08).

### 4.4 Màu channel

(DS-12)
- 12 màu chia đều trên vòng màu, cùng độ sáng và độ bão hoà; mỗi màu có biến thể nền tối. Thay cho 12 màu `[giả định]` ở G02 SCR-06 #3.
- **Trên card, trong ô soạn, bộ lọc:** chấm màu + "#tên". Không tô nền đặc, để channel màu đỏ không bị đọc thành cảnh báo.
- **Trên lịch:** block timebox tô nhạt bằng màu channel, viền trái đậm cùng màu.
- Channel hệ thống "Chưa phân loại": màu xám trung tính, không thuộc 12 màu.

## 5. Chữ

(DS-05, DS-13)
- Font **Inter**, đóng gói trong app, dùng chữ số đều chiều rộng (`tnum`) cho mọi con số thời gian: đồng hồ timer, "1:30 / 2:00", tổng ngày, giờ projection.
- Độ đậm: 400 (thường), 500 (nhấn nhẹ), 600 (tiêu đề).

| Token | Cỡ / dòng `[giả định]` | Dùng cho |
|---|---|---|
| `text/caption` | 12 / 18 | Nhãn phụ, thời gian tương đối, chip |
| `text/small` | 13 / 20 | Header cột ngày (600), menu, tooltip |
| `text/body` | 14 / 21 | Chữ thân bài; tiêu đề task trên card (500) |
| `text/body-lg` | 16 / 24 | Tiêu đề trong chi tiết task, ô soạn |
| `text/title` | 20 / 26 | Tiêu đề panel, dialog |
| `text/heading` | 24 / 32 | Tiêu đề bước wizard, Cài đặt |
| `text/display` | 32 / 40 | Màn onboarding, màn chào |
| `text/timer` | 48 / 56 | Đồng hồ ở Focus mode |

Chiều cao dòng **1,5 cho chữ thân bài** để dấu tiếng Việt chồng hai tầng ("Ế", "ỗ") không bị cắt; 1,3 cho tiêu đề. Kiểm tra mọi component với chuỗi "Ếch ỗng Ữ Ặ" ở cỡ nhỏ nhất.

## 6. Bố cục

### 6.1 Mật độ

(DS-04) **Một mức** ở 1.0, theo chuẩn app desktop năng suất. Không có cài đặt mật độ.

### 6.2 Khoảng cách và kích thước

(DS-14) Bước cơ sở **4 px**. Token khoảng cách: `space/1` = 4 · `space/2` = 8 · `space/3` = 12 · `space/4` = 16 · `space/6` = 24 · `space/8` = 32 · `space/12` = 48.

| Thành phần | Kích thước `[giả định]` |
|---|---|
| Sidebar | 220 px; thu gọn 56 px |
| Panel phải | 340 px |
| Cột ngày | 240 px; tối thiểu 200 px |
| Ô bấm được | Tối thiểu 32 × 32 px |
| Màn 1920 px | ~7 cột ngày khi đóng panel phải, 5–6 cột khi mở |

Mốc cửa sổ hẹp theo [IA](00-kien-truc-thong-tin.md) mục 4 (1280 / 1024 px, tối thiểu 800 × 600).

### 6.3 Bo góc, viền, đổ bóng

(DS-15)

| Token | Giá trị `[giả định]` | Dùng cho |
|---|---|---|
| `radius/sm` | 6 px | Control: nút, ô nhập, chip |
| `radius/md` | 8 px | Card, menu, popover |
| `radius/lg` | 12 px | Dialog, panel nổi, ô thêm nhanh toàn cục |

- Tách lớp chủ yếu bằng **viền mảnh và nền khác bậc**, không bằng bóng.
- `shadow/overlay` chỉ cho lớp thật sự nổi: popover, dialog, ô thêm nhanh toàn cục. `shadow/drag` cho card đang kéo.

## 7. Icon

(DS-06) Bộ **Lucide**, nét outline. Cỡ 16 px (trong chip, dòng), 20 px (toolbar, sidebar). Icon riêng của app (✨ Trợ lý, dấu lặp, chip "AI", chờ đồng bộ) vẽ thêm theo đúng lưới và độ dày nét của Lucide. Icon không chữ luôn có nhãn cho trình đọc màn hình (mục 9).

## 8. Quy ước đặt tên component

(DS-09)
- Tên **tiếng Anh**, dạng `Nhóm/Tên`. Ví dụ: `Chip/Channel`, `Picker/Duration`, `List/Subtask`.
- Nhóm: Button, Input, Checkbox, Chip, Badge, Picker, Combobox, Menu, List, Card, Toast, Banner, Dialog, Panel, Nav, Editor, Icon, Skeleton. Thêm nhóm mới thì ghi vào đây.
- Biến thể và trạng thái đặt bằng **property** của Figma, không đặt trong tên: `state=default|hover|focus|pressed|disabled`, `tone=neutral|accent|success|warning|danger|ai`, `size=sm|md`.
- Brief viết tiếng Việt nhưng gọi component bằng tên tiếng Anh này (khuôn brief mục 9).
- `Button` có `variant=primary|secondary|danger`; `danger` cho nút nguy hiểm (nền `danger/solid`), ví dụ "Xoá channel" (G02 SCR-07) (chốt 10/11/2026, O-18 [brief G02](g02-quan-ly-task.md); code chưa có biến thể này).

## 9. Khả năng truy cập

(DS-08)

| Mục | Yêu cầu 1.0 |
|---|---|
| Tương phản | WCAG 2.1 AA ở cả sáng và tối: chữ ≥ 4,5 : 1, chữ lớn và icon / viền control ≥ 3 : 1 |
| Bàn phím | Mọi thao tác làm được bằng phím, kể cả những gì làm bằng kéo thả; viền focus luôn hiện, tương phản ≥ 3 : 1 |
| Trình đọc màn hình | Icon không chữ có nhãn cho Narrator (ví dụ "Xoá subtask {tiêu đề}", "Giá trị do trợ lý AI gợi ý") |
| Màu | Không bao giờ là dấu hiệu duy nhất: quá tải, quá hạn, do AI làm đều có thêm icon hoặc chữ |
| Cỡ chữ | Tôn trọng text scaling của Windows; bố cục không vỡ ở 150% |
| Chuyển động | Tôn trọng cài đặt tắt hoạt ảnh của Windows (mục 10.1) |
| High Contrast | Không vỡ giao diện ở 1.0; hỗ trợ đầy đủ để sau |

## 10. Chuyển động

(DS-16)
- Thời lượng `motion/fast` 120 ms, `motion/base` 200 ms; ease-out.
- Chỉ dùng chuyển động khi nó **giải thích một việc vừa xảy ra**:
  - task hoàn thành ở ngày khác bay về cột hôm nay;
  - card nhấc lên khi kéo, thả xuống đúng vạch;
  - panel phải và lớp trượt đi vào;
  - dòng bị xoá thu lại, Hoàn tác thì hiện lại tại chỗ.
- **Hiệu ứng chúc mừng** (G01 SCR-08 #4, mặc định bật): ✓ nở nhẹ tại chỗ mỗi lần hoàn thành. Xong task cuối cùng của hôm nay thì có hiệu ứng lớn hơn, một lần, không phủ kín màn hình.

### 10.1 Khi Windows tắt hoạt ảnh

Mọi chuyển động thay bằng mờ dần (fade) ≤ 120 ms; không có hiệu ứng chúc mừng lớn.

## 11. Giọng văn

(DS-07) Áp cho mọi copy trong app, cả `MSG-xx` của SRS lẫn `UI-xx` của brief.

| Quy tắc | Nên | Không nên |
|---|---|---|
| Xưng hô: không xưng khi không cần; khi cần thì dùng "bạn" | "Đã xoá · Hoàn tác" | "Bạn đã xoá task thành công!" |
| Câu ngắn, mở đầu bằng động từ | "Kết nối lại lịch Google" | "Có lỗi xảy ra với việc kết nối lịch của bạn" |
| Không dấu chấm than, không đùa trong thông báo lỗi | "Chưa lưu được thay đổi. Thử lại" | "Úi! Có gì đó sai sai rồi!" |
| Lỗi nói đủ hai ý: việc gì không làm được, và làm gì tiếp | "Không thể đặt task chưa xong vào ngày đã qua" + chọn ngày khác | "Thao tác không hợp lệ" |
| Toast nói đúng việc **đã** xảy ra | "Đã chuyển 3 task vào Lưu trữ" | Một câu chung chung cho nhiều tình huống (bài học Sunsama, #21) |
| Giữ thuật ngữ đã chốt trong [`CONTEXT.md`](../../CONTEXT.md), không dịch | task, backlog, channel, timebox, rollover | "công việc", "khối thời gian" |
| Không pha tiếng Anh ngoài các thuật ngữ đó | "Hoàn tác" | "Undo" |
| Ngày và giờ theo kiểu Việt | "Thứ Năm 06/11", "09:40", "1:30" | "Nov 6", "9:40 AM" |
| Tên trợ lý không chứa "Claude"; "chạy bằng Claude Code" viết chữ thường, chỉ ở chỗ cần nói nguồn | – | – (chờ D16 và [#25](https://github.com/tannguyenho/personal-app/issues/25)) |

Bản tiếng Anh theo cùng quy tắc; sentence case cho mọi nhãn.

## 12. Quyết định

| Mã | Quyết định | Câu grilling |
|---|---|---|
| DS-01 | Cá tính điềm tĩnh, có chủ đích; bốn nguyên tắc ở mục 1 | Q1 |
| DS-02 | Design system riêng cho mọi nền tảng; chỉ theo Windows ở phần vỏ | Q2 |
| DS-03 | Vẽ sáng trước, tối dựng bằng token; mặc định Hệ thống | Q3 |
| DS-04 | Một mức mật độ ở 1.0 | Q4 |
| DS-05 | Font Inter, đóng gói trong app, chữ số đều chiều rộng | Q5 |
| DS-06 | Icon Lucide; icon riêng vẽ theo lưới Lucide | Q6 |
| DS-07 | Giọng văn như mục 11 | Q7 |
| DS-08 | Khả năng truy cập như mục 9 | Q8 |
| DS-09 | Tên component tiếng Anh `Nhóm/Tên`, biến thể bằng property | Q9 |
| DS-10 | Nhấn teal, AI tím | Q10 |
| DS-11 | Bảng màu ngữ nghĩa mục 4.3, không có màu info | Q11 |
| DS-12 | 12 màu channel đều trên vòng màu; chấm màu trên card, tô nhạt trên lịch | Q12 |
| DS-13 | Thang chữ mục 5, dòng 1,5 cho thân bài | Q13 |
| DS-14 | Bước 4 px và kích thước khung mục 6.2 | Q14 |
| DS-15 | Bo góc 6 / 8 / 12; tách lớp bằng viền, bóng chỉ cho lớp nổi | Q15 |
| DS-16 | Chuyển động 120–200 ms, chỉ để giải thích; hiệu ứng chúc mừng nhỏ, lớn hơn khi xong cả ngày | Q16 |

## 13. Đã sửa ngược và việc còn mở

| Tài liệu | Sửa | Theo |
|---|---|---|
| srs-g02 SCR-06 #3 | 12 màu channel theo DS-12, bỏ `[giả định]` | DS-12 |
| srs-g01 SCR-08 #1 | Ghi mặc định "Hệ thống" | DS-03 |
| srs-g01 SCR-08 #4 | Mô tả hiệu ứng chúc mừng theo DS-16 | DS-16 |
| `_khuon.md` mục Quy ước | Component theo DS-09 | DS-09 |
| Mục 8 | `Button` thêm `variant=danger` | O-18 brief G02 (10/11/2026) |

Còn mở, không thuộc ticket này:
- Tên hiển thị của trợ lý AI (D16), chờ kết quả [#25](https://github.com/tannguyenho/personal-app/issues/25).
- Mức cảnh báo vàng của khối lượng ngày: brief G04 quyết định; design system đã có token `warning`.
- Danh mục component đầy đủ: gom từ các brief (mục "Not yet specified" của bản đồ).
