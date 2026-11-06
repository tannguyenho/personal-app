# User flow bản 1.0

Sơ đồ user flow của bản 1.0 vẽ bằng Mermaid, mỗi SRS một file. Mỗi use case có ba phần: **happy case** → **nhánh thay thế và lỗi** → **bảng đối chiếu**. Cách vẽ: [`_quy-uoc.md`](_quy-uoc.md). Ticket: [#10](https://github.com/tannguyenho/personal-app/issues/10).

GitHub hiển thị sẵn Mermaid. Muốn sửa và xem nhanh thì dán khối code vào [mermaid.live](https://mermaid.live). FigJam: chưa làm (PO chốt 05/11/2026: làm Mermaid trước).

| Nhóm | File | UC vẽ | Sơ đồ | UC / nhánh bỏ vì thuộc bản sau |
|---|---|---|---|---|
| G01 | [Tài khoản, onboarding, cài đặt](g01-tai-khoan.md) | 11 | 27 | Một số nhánh 1.1 |
| G02 | [Quản lý task](g02-quan-ly-task.md) (file mẫu) | 6 | 15 | UC-01 E5 |
| G03 | [Task lặp lại](g03-task-lap-lai.md) | 7 | 18 | Một số nhánh 1.1 |
| G04 | [Board ngày](g04-board-ngay.md) | 8 | 20 | Một số nhánh 1.1 |
| G05 | [Lịch và timebox](g05-lich-timebox.md) | 9 | 23 | UC-05 auto-schedule, UC-09 lập lịch cứng (1.1) |
| G06 | [Backlog, rollover, lưu trữ](g06-backlog-rollover.md) | 7 | 18 | Một số nhánh 1.1 |
| G07 | [Focus và timer](g07-focus-timer.md) | 6 | 12 | UC-05 Pomodoro (1.1), UC-08 Focus Bar (1.2) |
| G08 | [Daily planning và shutdown](g08-daily-rituals.md) | 5 | 17 | Nhánh chỉ đọc, ritual tuần (1.1) |
| G10 | [Trợ lý AI](g10-tro-ly-ai.md) | 12 | 28 | Nhánh dùng dữ liệu tích hợp, thẻ chờ duyệt (1.1) |
| G12 | [Workspace, thông báo (phần 1.0)](g12-workspace-billing.md) | 3 | 6 | UC-01 … 03 (1.1); UC-04, 06, 07 (1.2) |
| | **Tổng** | **74** | **184** | |

G09 Weekly và G11 Tích hợp là bản 1.1, không có flow.

## Chỗ SRS còn vênh

Khi vẽ, mỗi file ghi các chỗ SRS mâu thuẫn hoặc thiếu ở mục **"Ghi chú cho brief"** cuối file (khoảng 100 điểm). Phần lớn thuộc ba loại:
- **Chữ chưa có mã MSG**, hoặc MSG dùng sai ngữ cảnh. Ví dụ: G02 MSG-12 dùng cho khung giờ channel; G08 MSG-20 "ngày đã qua" dùng cho ngày quá xa trong tương lai.
- **Màn chưa có mã SCR.** Ví dụ: Today view, menu tài khoản, trang web cho link email.
- **SRS lệch với các quyết định đã chốt.** Ví dụ:
  - Esc thoát wizard ở G08, trái IA-16.
  - Nhãn "Claude Code" trên giao diện G10, trái ADR-0004.
  - Đổi ngày task: G05 BR-21 gỡ timebox, G04 BR-09 giữ timebox.

Brief của từng tính năng xử lý các điểm này ở mục 11 "Chỗ còn mở". Chốt xong thì ghi ngược vào SRS và sửa flow trong cùng commit.

## Đã sửa sau review nghiệp vụ (06/11/2026)

Review flow phát hiện nhiều chỗ flow chép theo SRS cũ, trong khi nguồn cao hơn (QC, IA, tech) đã quyết khác. Các điểm đã có nguồn quyết được ghi ngược vào SRS rồi sửa flow:

| Điểm | Nguồn quyết | SRS đã sửa | Flow đã sửa |
|---|---|---|---|
| Timebox liên kết sự kiện: ở mọi đường chỉ gỡ liên kết, không dời, không xoá sự kiện ngoài | QC-05 (ngoại lệ), B8, G05 BR-21 f | G02 UC-04 A2; G04 BR-09, UC-03 A7; G05 UC-04 A5, A7, A8; PRD G04 câu hỏi mở | G02 UC-04, G04 UC-03, G05 UC-04 |
| Cột ngày đã qua không có "+ Thêm task" / "Plan"; phím A mở ô soạn ở hôm nay | IA-20 | G02 UC-01 bước 1, A6, E6 | G02 UC-01, G04 UC-01 |
| Ô thêm nhanh toàn cục Ctrl+Shift+A | IA-19, D11, G02 US1.1 AC07 | G02 UC-01 A7 | G02 UC-01 (sơ đồ riêng) |
| Tới giờ plan khi cửa sổ ẩn ở khay | IA-05, IA-10, D12 | G08 UC-04 bước 3, A10 | G08 UC-04 |
| Một banner, hàng chờ theo thứ tự ưu tiên | IA-17, G04 SCR-01 #5 | (SRS đã có) | G04 UC-01 (sơ đồ riêng) |
| Phím Ctrl+\\, Ctrl+J, Ctrl+, | IA-15 | G04 UC-08 A1 | G04 UC-08 |
| Câu lỗi `VERSION_CONFLICT` | QC-08 mục 2 | G04 MSG-17 | G04 |
| Đặt lại mật khẩu trên trang web tối giản, không cấp token cho app | tech mục 1 | G01 UC-04, SCR-04, MSG-19 | G01 UC-04 |
| G08 UC-01 A6 (Plan ngày tương lai) không chuyển trang | SRS G08 UC-01 A6 | (SRS đã đúng) | G08 UC-01: A6 có điểm kết thúc riêng |
| Nút "Dừng" của Planning Agent | G10 SCR-02 #6, BR-09 | G10 UC-02 A11 | G10 UC-02 (sơ đồ riêng) |

**PO đã chốt ngày 06/11/2026** ([quyết định F1–F4](../../review/quyet-dinh-chot-2026-11-06.md)), đã sửa SRS và flow:
- F1: phím S = về hôm nay; "Hoãn 1 tuần" chỉ còn là lệnh.
- F2: rollover thất bại một cách hiển thị (banner G06 MSG-25 "Thử lại"); đang chờ thì MSG-32.
- F3: giữ Daily planning có hướng dẫn sau onboarding; G08 BR-28, UC-01 A16.
- F4: bỏ công tắc "Cho phép AI hoàn thành và xoá task"; AI luôn được hoàn thành và xoá (vào Thùng rác, có Hoàn tác).

**Còn mở:**
- Nhãn "Lệch ngày" (QC-01 mục 4): chỉ xuất hiện khi người dùng đổi timezone; chip trong chi tiết task G02 chưa có tooltip MSG-26 như trên card G04.
