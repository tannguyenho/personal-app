# Khuôn design brief

> **Trạng thái:** bản thử, chờ PO phản hồi ([ticket #9](https://github.com/tannguyenho/personal-app/issues/9)). Bản thử đầu tiên theo khuôn: [`_thu-g02-tao-va-chi-tiet-task.md`](_thu-g02-tao-va-chi-tiet-task.md).
>
> Bản đồ: [issue #2](https://github.com/tannguyenho/personal-app/issues/2).

## Brief dùng để làm gì

Designer đọc brief là vẽ được ngay trong Figma, không phải mở PRD/SRS để hỏi lại nghiệp vụ. Brief trả lời ba câu hỏi:
- **Vẽ màn nào, mỗi màn có những trạng thái nào?**
- **Mỗi trạng thái hiện gì, chữ gì?**
- **Người dùng đi từ đâu tới đâu, bấm gì thì ra gì?**

Brief **không** định nghĩa lại quy tắc nghiệp vụ. Quy tắc nằm ở PRD/SRS, QC, `CONTEXT.md` và ADR. Brief chỉ nói quy tắc đó **trông ra sao** trên màn hình, kèm mã tham chiếu để ai cần thì mở nguồn.

## Quy ước

| Quy ước | Ý nghĩa |
|---|---|
| Tên file | `gxx-<ten-tinh-nang>.md`, ví dụ `g02-quan-ly-task.md`. File bắt đầu bằng `_` là khuôn hoặc bản thử |
| Mã màn | Dùng lại mã `SCR-xx` của SRS cùng nhóm. Màn chưa có trong SRS thì đặt `SCR-Nxx` (N = mới) và ghi vào mục "Chỗ còn mở" để bổ sung ngược vào SRS |
| Mã trạng thái | `<mã màn>.Sxx`, ví dụ `SCR-01.S03`. Đánh số trong từng màn |
| Mã flow | `F-xx`, đánh số trong từng brief. Flow đi qua nhiều tính năng đặt ở brief của tính năng **khởi phát** flow; brief khác chỉ ghi link |
| Mã case | `CASE-xx`, đánh số trong từng brief. Không dùng `EC-xx` để tránh nhầm với danh mục chung QC-11; case nào ứng với một EC thì ghi mã EC ở cột tham chiếu |
| Mã copy | Dùng lại `MSG-xx` của SRS. Chữ trên giao diện chưa có trong SRS (nhãn, placeholder, empty state) đặt `UI-xx` và gắn `[đề xuất]` cho tới khi PO duyệt |
| Component | Viết trong backtick theo tên tạm, ví dụ `Chip/Channel`. Tên chính thức chốt ở ticket design system ([#8](https://github.com/tannguyenho/personal-app/issues/8)); brief chỉ cần nhất quán trong file và liệt kê ở mục 9 |
| `[đề xuất]` | Brief đề xuất, nguồn chưa nói. PO duyệt thì bỏ nhãn và ghi ngược vào PRD/SRS nếu là nghiệp vụ |
| `[chờ #n]` | Phụ thuộc ticket khác chưa xong, ví dụ `[chờ #7]` cho kiến trúc thông tin |
| Tham chiếu | Viết ngắn `G02 BR-08`, `QC-03 mục 4`, `D10`, `#22-C3` (câu C3 trong ticket kiểm chứng #22) |

**Mức chi tiết.** Viết đủ để designer quyết định *hiện cái gì*, không quyết định *trông thế nào*. Không ghi màu, cỡ chữ, khoảng cách: đó là việc của design system. Được ghi thứ tự ưu tiên thông tin, độ dài nội dung thật, và cái gì phải nổi bật hơn cái gì.

---

## Khung một brief

Chép nguyên khung dưới đây khi mở brief mới. Mục nào không có nội dung thì ghi "Không có" thay vì xoá, để người đọc biết là đã xét.

```markdown
# Brief Gxx <Tên tính năng>

> **Mã:** PLN-BRIEF-Gxx · **Trạng thái:** nháp / chờ PO / đã duyệt · **Phiên bản:** 1.0
> **Nguồn:** prd-gxx, srs-gxx (commit `xxxxxxx`), QC-xx, quyết định Dxx / Qxx
> **Phụ thuộc:** kiến trúc thông tin (#7), design system (#8), brief Gyy
> **FigJam:** <link file, link frame của từng flow> [chờ #10]

## 1. Tóm tắt cho người vẽ
3–5 dòng: người dùng làm gì ở tính năng này, khoảnh khắc quan trọng nhất là gì,
và một thước đo thành công từ PRD (ví dụ "ghi task ≤ 5 giây").

## 2. Phạm vi của brief
- Trong brief: các màn, các flow.
- Không trong brief (và nằm ở brief nào): ...
- Khác Sunsama có chủ đích mà người vẽ cần biết: ...

## 3. Danh sách màn hình
| Mã | Màn | Bề mặt | Điểm vào | Số trạng thái | Ưu tiên vẽ |
Bề mặt = panel / dialog / cửa sổ / inline / toast..., theo kiến trúc thông tin (#7).
Ưu tiên vẽ: P1 (luồng chính), P2 (trạng thái phụ), P3 (hiếm gặp).

## 4. Màn hình và trạng thái
Mỗi màn một mục con:

### SCR-xx <Tên màn>
**Mục đích.** Một câu.
**Cấu trúc.** Các vùng từ trên xuống / trái sang, mỗi vùng ghi component tạm
và thứ tự ưu tiên thông tin. Chỉ nêu cái SRS chưa nói hoặc cần nói rõ cho người vẽ;
cái SRS đã có thì trỏ "SRS SCR-xx #n".
**Trạng thái.**
| Mã | Trạng thái | Khi nào | Hiện gì (khác trạng thái mặc định ở đâu) | Ra khỏi trạng thái bằng | Tham chiếu |
**Dữ liệu mẫu.** Nội dung thật để vẽ: tiêu đề dài nhất, tiếng Việt có dấu,
số lớn nhất, danh sách dài nhất. Người vẽ dùng đúng bộ này để thử bố cục.

## 5. User flow
Mỗi flow một mục con:

### F-xx <Tên flow>
**Mở đầu:** ở đâu, trạng thái gì. **Kết thúc:** người dùng thấy gì.
| Bước | Người dùng | Hệ thống / màn hình (mã trạng thái) |
Nhánh rẽ: ghi "→ CASE-xx" hoặc "→ F-yy".
FigJam: link frame.

## 6. Case chính và edge case
| Mã | Tình huống | Màn / trạng thái | Hiện gì | Tham chiếu |
Gom theo nhóm: dữ liệu (rỗng, dài, nhiều), mạng và đồng bộ, AI, thời gian
(mốc đầu ngày, ngày đã qua), quyền / công tắc, lỗi.

## 7. Copy
| Mã | Nơi hiện | Nội dung (VI) | Biến | Ghi chú |
MSG-xx chép nguyên văn từ SRS (nguồn vẫn là SRS). UI-xx là chữ mới, gắn [đề xuất].
Ghi độ dài dài nhất có thể của biến, ví dụ {tiêu đề} tới 500 ký tự → toast cắt "…".

## 8. Tương tác
- Phím tắt và điều kiện chạy.
- Thứ tự focus và Tab; trạng thái "đang chọn" nhìn thấy được.
- Hover, chuột phải, kéo thả.
- Toast và Hoàn tác: thao tác nào có, hiện bao lâu.
- Thời gian: debounce, timeout, cập nhật lạc quan.
- Chuyển động (nếu có ý nghĩa nghiệp vụ, ví dụ task bay sang cột hôm nay).
- Khả năng truy cập: nhãn cho trình đọc màn hình của icon, phím thay cho kéo thả.

## 9. Component dùng trong brief
| Component tạm | Dùng ở | Biến thể / trạng thái cần có |
Mục này gom lên danh mục component chung của bản đồ.

## 10. Tham chiếu nghiệp vụ
| Chủ đề | Nguồn |
Chỉ mục, không chép lại nội dung.

## 11. Chỗ còn mở
| Mã | Câu hỏi | Ảnh hưởng tới | Đề xuất của brief | Ai chốt |
Câu nào đã chốt: ghi quyết định, rồi ghi ngược vào PRD/SRS/QC.

## 12. Kiểm tra trước khi giao
- [ ] Mỗi màn ở mục 3 có bảng trạng thái và dữ liệu mẫu.
- [ ] Mỗi trạng thái có chữ (MSG / UI) cho mọi chỗ hiện chữ.
- [ ] Mỗi flow ở mục 5 có frame FigJam.
- [ ] Mọi luồng thay thế (A#) và luồng lỗi (E#) trong SRS của các UC thuộc brief
      đều có trong mục 4 hoặc mục 6.
- [ ] Không còn `[đề xuất]` chưa duyệt ở luồng chính (P1).
- [ ] Chỗ còn mở không chặn luồng chính.
```

## Ghi chú khi viết

- **Đọc theo UC, viết theo màn.** SRS tổ chức theo use case; người vẽ làm việc theo màn. Đi lần lượt từng UC, đưa mỗi luồng A# / E# vào đúng trạng thái của màn mà nó hiện ra. Mục 12 kiểm lại là không sót.
- **Trạng thái là "cái người dùng thấy khác đi".** Hai tình huống nghiệp vụ khác nhau mà hiện giống hệt nhau thì gộp một trạng thái, ghi cả hai ở cột "Khi nào".
- **Mỗi chỗ có chữ phải có mã copy.** Không viết "hiện thông báo lỗi" mà không có nội dung.
- **Kết quả kiểm chứng Sunsama** ([`docs/research/kiem-chung-sunsama-chrome.md`](../research/kiem-chung-sunsama-chrome.md)) dùng ở mục 2 (khác có chủ đích) và mục 11 (cần chốt). Không mô tả giao diện Sunsama để người vẽ chép.
- **Bản 1.1 trở đi** (objective, trial, chế độ chỉ đọc, web) không vẽ. Thành phần ẩn ở 1.0 ghi một dòng ở mục 2 để người vẽ chừa chỗ nếu cần.
