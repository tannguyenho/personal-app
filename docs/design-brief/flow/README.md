# User flow bản 1.0

Sơ đồ user flow của bản 1.0 vẽ bằng Mermaid, mỗi SRS một file. Mỗi use case có ba phần: **happy case** → **nhánh thay thế và lỗi** → **bảng đối chiếu**. Cách vẽ: [`_quy-uoc.md`](_quy-uoc.md). Ticket: [#10](https://github.com/tannguyenho/personal-app/issues/10).

GitHub hiển thị sẵn Mermaid. Muốn sửa và xem nhanh thì dán khối code vào [mermaid.live](https://mermaid.live). FigJam: chưa làm (PO chốt 05/11/2026: làm Mermaid trước).

| Nhóm | File | UC vẽ | Sơ đồ | UC / nhánh bỏ vì thuộc bản sau |
|---|---|---|---|---|
| G01 | [Tài khoản, onboarding, cài đặt](g01-tai-khoan.md) | 11 | 27 | Một số nhánh 1.1 |
| G02 | [Quản lý task](g02-quan-ly-task.md) (file mẫu) | 6 | 14 | UC-01 E5 |
| G03 | [Task lặp lại](g03-task-lap-lai.md) | 7 | 18 | Một số nhánh 1.1 |
| G04 | [Board ngày](g04-board-ngay.md) | 8 | 19 | Một số nhánh 1.1 |
| G05 | [Lịch và timebox](g05-lich-timebox.md) | 9 | 23 | UC-05 auto-schedule, UC-09 lập lịch cứng (1.1) |
| G06 | [Backlog, rollover, lưu trữ](g06-backlog-rollover.md) | 7 | 18 | Một số nhánh 1.1 |
| G07 | [Focus và timer](g07-focus-timer.md) | 6 | 12 | UC-05 Pomodoro (1.1), UC-08 Focus Bar (1.2) |
| G08 | [Daily planning và shutdown](g08-daily-rituals.md) | 5 | 17 | Nhánh chỉ đọc, ritual tuần (1.1) |
| G10 | [Trợ lý AI](g10-tro-ly-ai.md) | 12 | 27 | Nhánh dùng dữ liệu tích hợp, thẻ chờ duyệt (1.1) |
| G12 | [Workspace, thông báo (phần 1.0)](g12-workspace-billing.md) | 3 | 6 | UC-01 … 03 (1.1); UC-04, 06, 07 (1.2) |
| | **Tổng** | **74** | **181** | |

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
