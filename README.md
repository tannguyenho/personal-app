# Personal App — ứng dụng lập kế hoạch ngày

Bộ tài liệu yêu cầu cho một ứng dụng lập kế hoạch ngày có chủ đích. Ứng dụng tham chiếu [Sunsama](https://www.sunsama.com): gom task và lịch về một chỗ, dẫn người dùng qua các ritual mỗi ngày và mỗi tuần, timebox task lên lịch, theo dõi thời gian tập trung, và có AI hỗ trợ lập kế hoạch.

> **Trạng thái:** đã chốt mâu thuẫn giữa các nhóm ngày 04/11/2026 ([quyết định](docs/review/quyet-dinh-chot-2026-11-04.md)), chờ PO duyệt từng nhóm. Các con số còn gắn `[giả định]` cần xác nhận trước khi đưa vào phát triển.

## Sản phẩm làm gì

Một ngày làm việc trong ứng dụng đi theo vòng lặp sau:

```
Daily planning → Việc hôm nay → Timebox lên lịch → Focus & timer → Hoàn thành → Daily shutdown
      ↑                                                                               │
      └──────────── sang ngày mới: việc chưa xong tự rollover, việc hoãn vào backlog ─┘
```

Bên ngoài vòng ngày là vòng tuần: Weekly planning (đặt objective vào sáng Thứ Hai) và Weekly review (tổng kết vào chiều Thứ Sáu).

## Lộ trình phát hành

| Phiên bản | Phạm vi |
|---|---|
| **1.0 (MVP, Beta)** | **App Windows (Flutter)**, một người dùng. Tài khoản, task, task lặp lại, board ngày, lịch Google / Outlook và timebox, khung giờ channel, backlog và rollover, timer và Focus, Daily planning, Daily shutdown, **trợ lý AI qua Claude Code CLI + MCP local**. Miễn phí, không giới hạn ([ADR-0002](docs/adr/0002-thanh-toan-chuyen-sang-1-1.md), [ADR-0004](docs/adr/0004-ai-qua-claude-code-cli.md), [ADR-0005](docs/adr/0005-nen-tang-windows-truoc.md)) |
| **1.1** | **Web, macOS.** Trial 14 ngày, thanh toán và chế độ chỉ đọc; workspace nhiều thành viên; Weekly planning / review, objective, analytics, Pomodoro, auto-schedule, lập lịch cứng cho task lặp, Gmail / Jira / Notion |
| **1.2** | **iOS / Android.** Slack / Teams, Focus Bar |

## Cấu trúc thư mục

```
.
├── README.md
├── CONTEXT.md                          # bảng thuật ngữ chung
└── docs/
    ├── 00-danh-muc-nhom-tinh-nang.md   # danh mục 12 nhóm, trạng thái từng tài liệu
    ├── 01-quy-tac-dung-chung.md        # quy tắc dùng chung QC-01..QC-12 (ngày làm việc, trạng thái task, đổi ngày, AI…)
    ├── 02-tinh-nang-ban-sau.md         # tính năng đã chốt hướng nhưng để bản sau (nhiều thành viên, thanh toán…)
    ├── tech/                           # câu hỏi tech stack & API, chờ grill riêng với tech
    ├── adr/                            # quyết định khó đảo ngược
    ├── review/                         # báo cáo review và quyết định chốt mâu thuẫn
    └── features/
        ├── prd-g01-tai-khoan.md        # PRD: vì sao, cho ai, phạm vi, user story, AC, chỉ số
        ├── srs-g01-tai-khoan.md        # SRS: business rule, trạng thái, use case, màn hình, API, thông báo
        └── …                           # mỗi nhóm một cặp prd-gxx / srs-gxx
```

## Danh mục tài liệu

| Nhóm | Tính năng | Phát hành | PRD | SRS |
|---|---|---|---|---|
| G01 | Tài khoản, onboarding, cài đặt & lịch làm việc | 1.0 | [prd-g01](docs/features/prd-g01-tai-khoan.md) | [srs-g01](docs/features/srs-g01-tai-khoan.md) |
| G02 | Quản lý task (subtask, channel, xoá / khôi phục) | 1.0 | [prd-g02](docs/features/prd-g02-quan-ly-task.md) | [srs-g02](docs/features/srs-g02-quan-ly-task.md) |
| G03 | Task lặp lại | 1.0 | [prd-g03](docs/features/prd-g03-task-lap-lai.md) | [srs-g03](docs/features/srs-g03-task-lap-lai.md) |
| G04 | Board ngày, projection, khối lượng, tìm kiếm & phím tắt | 1.0 | [prd-g04](docs/features/prd-g04-board-ngay.md) | [srs-g04](docs/features/srs-g04-board-ngay.md) |
| G05 | Lịch & timebox (Google / Outlook hai chiều) | 1.0 | [prd-g05](docs/features/prd-g05-lich-timebox.md) | [srs-g05](docs/features/srs-g05-lich-timebox.md) |
| G06 | Backlog, rollover & lưu trữ | 1.0 | [prd-g06](docs/features/prd-g06-backlog-rollover.md) | [srs-g06](docs/features/srs-g06-backlog-rollover.md) |
| G07 | Focus & theo dõi thời gian | 1.0 | [prd-g07](docs/features/prd-g07-focus-timer.md) | [srs-g07](docs/features/srs-g07-focus-timer.md) |
| G08 | Daily planning & Daily shutdown | 1.0 | [prd-g08](docs/features/prd-g08-daily-rituals.md) | [srs-g08](docs/features/srs-g08-daily-rituals.md) |
| G09 | Weekly planning / review, objective, analytics | 1.1 | [prd-g09](docs/features/prd-g09-weekly-objective.md) | [srs-g09](docs/features/srs-g09-weekly-objective.md) |
| G10 | Trợ lý AI qua Claude Code CLI + MCP local (Planning Agent, chat, highlights, gợi ý) | 1.0 | [prd-g10](docs/features/prd-g10-tro-ly-ai.md) | [srs-g10](docs/features/srs-g10-tro-ly-ai.md) |
| G11 | Tích hợp công cụ (Gmail, Jira, Notion…) | 1.1+ | [prd-g11](docs/features/prd-g11-tich-hop.md) | [srs-g11](docs/features/srs-g11-tich-hop.md) |
| G12 | Workspace, thành viên, quyền riêng tư & thanh toán | 1.0 / 1.1 | [prd-g12](docs/features/prd-g12-workspace-billing.md) | [srs-g12](docs/features/srs-g12-workspace-billing.md) |

## Cách đọc

- **Bắt đầu từ PRD** để hiểu vấn đề, người dùng và phạm vi. Sau đó đọc **SRS** để biết chi tiết cần làm.
- **PRD** có 10 mục: bối cảnh và vấn đề, người dùng, phạm vi, nguyên tắc sản phẩm, quy tắc / cấu hình, luồng trải nghiệm, use case + user story + acceptance criteria, chỉ số, rủi ro, câu hỏi mở.
- **SRS** có 10 mục: tổng quan, user story, business rule (BR), trạng thái, use case (luồng chính, luồng thay thế A#, luồng lỗi E#), điểm vào, màn hình (SCR), API, danh sách thông báo (MSG), yêu cầu phi chức năng.
- **Giao diện** theo design system riêng trên Figma; mục màn hình (SCR) trong SRS chỉ mô tả thành phần và hành vi, không mô tả hình ảnh.
- **API, mã lỗi, job** trong SRS là hợp đồng nghiệp vụ tham khảo; tech stack và API chốt riêng ([`docs/tech/`](docs/tech/00-cau-hoi-tech-stack-va-api.md)).
- Mỗi tài liệu chỉ mô tả phần thuộc nhóm của nó. Phần thuộc nhóm khác được ghi chú `(Gxx)` để người đọc mở tài liệu nhóm đó.
- Quy tắc nhiều nhóm cùng dùng nằm ở [`docs/01-quy-tac-dung-chung.md`](docs/01-quy-tac-dung-chung.md) và được tham chiếu bằng mã `QC-xx`. Thuật ngữ chuẩn nằm ở [`CONTEXT.md`](CONTEXT.md).

## Quy ước

| Quy ước | Ý nghĩa |
|---|---|
| `PLN-PRD-Gxx`, `PLN-SRS-Gxx-WEB` | Mã tài liệu của nhóm Gxx |
| `QC-xx` | Mã quy tắc dùng chung trong `docs/01-quy-tac-dung-chung.md` |
| `BR-01`, `UC-01`, `SCR-01`, `MSG-01` | Mã business rule, use case, màn hình, thông báo; đánh số lại từ 01 trong từng SRS |
| `EC-xx` | Mã tình huống biên (side case) dùng chung cho mọi nhóm; danh mục ở QC-11 |
| `[giả định]` | Giá trị chưa chốt, cần PO / BA xác nhận |
| "khác có chủ đích" | Điểm sản phẩm cố ý làm khác Sunsama |
| "đã kiểm chứng" | Hành vi đã test thực tế trên Sunsama ngày 04/11/2026 |

## Quyết định đã chốt (04/11/2026)

Chi tiết ở [quyết định chốt mâu thuẫn](docs/review/quyet-dinh-chot-2026-11-04.md) và [`docs/adr/`](docs/adr/).

- Ngày làm việc bắt đầu lúc **04:00** (chỉnh trong 00:00–06:00); đổi cài đặt có hiệu lực từ ngày làm việc kế tiếp; đổi timezone không đổi ngày của task (QC-01, ADR-0001).
- Thùng rác giữ task đã xoá **30 ngày**.
- Bản 1.0 miễn phí; trial, thanh toán và chế độ chỉ đọc ở bản 1.1 (ADR-0002).
- Bản 1.0 là app Windows (Flutter) cho một người dùng, có tài khoản và dữ liệu trên cloud; web + macOS ở 1.1, di động ở 1.2 (ADR-0005).
- Trợ lý AI chạy bằng Claude Code CLI của người dùng, điều khiển app qua MCP local, có từ 1.0; mặc định tắt; thay đổi áp dụng ngay kèm Hoàn tác; chờ duyệt khi dùng dữ liệu tích hợp; hoàn thành / xoá task chỉ khi người dùng bật công tắc (QC-12, ADR-0004).
- Mỗi channel có thể đặt khung giờ riêng (QC-02).
- Bản 1.0 không bắt buộc lưu dữ liệu tại Việt Nam, dùng máy chủ khu vực châu Á.

## Câu hỏi còn mở

- Pháp chế xác nhận hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (Nghị định 13/2023) trước khi phát hành 1.0.
- Cổng thanh toán (gợi ý Stripe cho thẻ quốc tế, VNPay / MoMo cho nội địa) và định nghĩa các gói giá: chốt trước khi làm 1.1.
- Chính sách hoàn tiền khi xoá tài khoản giữa kỳ (chờ pháp chế).
- Ai nộp hồ sơ xác minh Google OAuth và khi nào. Việc này có thể chặn ngày ra mắt.
- Tech stack và API: chờ buổi grill riêng ([`docs/tech/`](docs/tech/00-cau-hoi-tech-stack-va-api.md)).
- Các giá trị còn gắn `[giả định]` và câu hỏi mở còn lại ở mục 10 của từng PRD.

## Tài liệu liên quan

Các tài liệu dưới đây soạn trên Claude, chỉ người được chia sẻ mới mở được:

- PRD tổng — phân tích tính năng Sunsama, kết quả test và bảng đối chiếu với bản gốc
- SRS tổng theo chuẩn ISO/IEC/IEEE 29148 — 26 use case, 41 tình huống biên, ma trận kiểm chứng 154 yêu cầu
- Thiết kế kỹ thuật & đặc tả API — MVP 1.0: kiến trúc, schema PostgreSQL, 60 endpoint REST, realtime / offline, job nền, tích hợp lịch

## Cách cập nhật tài liệu

1. Sửa file trong `docs/features/`, giữ nguyên cấu trúc 10 mục và cách đánh mã. Quy tắc dùng chung chỉ sửa ở `docs/01-quy-tac-dung-chung.md`.
2. Khi chốt một giá trị `[giả định]`, xoá nhãn này và ghi quyết định vào câu hỏi mở tương ứng.
3. Cập nhật cột trạng thái trong `docs/00-danh-muc-nhom-tinh-nang.md` (Nháp → Đã duyệt).
