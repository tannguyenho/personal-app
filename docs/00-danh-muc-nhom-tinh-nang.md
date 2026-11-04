# Danh mục nhóm tính năng — ứng dụng lập kế hoạch ngày

Chốt ngày 04/11/2026: 12 nhóm, mỗi nhóm một cặp PRD + SRS theo mẫu Check-in. G02 là bản mẫu đã duyệt cách áp; 11 nhóm còn lại viết theo đúng khuôn G02. Auto-schedule và lập lịch cứng cho task lặp (G05) xếp ở bản 1.1. Ngày 04/11/2026 chốt mâu thuẫn giữa các nhóm: trial và thanh toán chuyển sang 1.1; quy tắc dùng chung chuyển về `01-quy-tac-dung-chung.md`.

| **Nhóm** | **Tên** | **Phát hành** | **Use case SRS tổng** | **PRD** | **SRS** | **Trạng thái** |
|---|---|---|---|---|---|---|
| G01 | Tài khoản, onboarding, cài đặt & lịch làm việc | 1.0 | UC-21, UC-20 (phần cài đặt) | prd-g01-tai-khoan.md | srs-g01-tai-khoan.md | Đã chốt mâu thuẫn — chờ duyệt |
| G02 | Quản lý task (subtask, channel, xoá / khôi phục) | 1.0 | UC-01 → UC-05, UC-24 | prd-g02-quan-ly-task.md | srs-g02-quan-ly-task.md | Đã chốt mâu thuẫn — chờ duyệt |
| G03 | Task lặp lại | 1.0 | UC-04 | prd-g03-task-lap-lai.md | srs-g03-task-lap-lai.md | Đã chốt mâu thuẫn — chờ duyệt |
| G04 | Board ngày, projection, khối lượng, tìm kiếm & phím tắt | 1.0 | UC-06, UC-07, UC-20 (phần phím tắt) | prd-g04-board-ngay.md | srs-g04-board-ngay.md | Đã chốt mâu thuẫn — chờ duyệt |
| G05 | Lịch & timebox (Google / Outlook 2 chiều) | 1.0 | UC-08 | prd-g05-lich-timebox.md | srs-g05-lich-timebox.md | Đã chốt mâu thuẫn — chờ duyệt |
| G06 | Backlog, rollover & lưu trữ | 1.0 | UC-09, UC-10 | prd-g06-backlog-rollover.md | srs-g06-backlog-rollover.md | Đã chốt mâu thuẫn — chờ duyệt |
| G07 | Focus & theo dõi thời gian | 1.0 | UC-11, UC-12 | prd-g07-focus-timer.md | srs-g07-focus-timer.md | Đã chốt mâu thuẫn — chờ duyệt |
| G08 | Daily planning & Daily shutdown | 1.0 | UC-13, UC-14, UC-16 | prd-g08-daily-rituals.md | srs-g08-daily-rituals.md | Đã chốt mâu thuẫn — chờ duyệt |
| G09 | Weekly planning / review, objective, analytics | 1.1 | UC-15, UC-17, UC-26 | prd-g09-weekly-objective.md | srs-g09-weekly-objective.md | Đã chốt mâu thuẫn — chờ duyệt |
| G10 | Trợ lý AI qua Claude Code CLI + MCP local (chat, Agent, gợi ý, highlights) | 1.0 | UC-18 | prd-g10-tro-ly-ai.md | srs-g10-tro-ly-ai.md | Đã chốt mâu thuẫn — chờ duyệt |
| G11 | Tích hợp công cụ (Gmail, Jira, Notion…) | 1.1+ | UC-19 | prd-g11-tich-hop.md | srs-g11-tich-hop.md | Đã chốt mâu thuẫn — chờ duyệt |
| G12 | Workspace, thành viên, quyền riêng tư & thanh toán | 1.0 (workspace cá nhân, thông báo) / 1.1 (trial, thanh toán, thành viên) | UC-22, UC-23, UC-25 | prd-g12-workspace-billing.md | srs-g12-workspace-billing.md | Đã chốt mâu thuẫn — chờ duyệt |

UC-20 của SRS tổng được tách: G01 giữ phần cài đặt, G04 giữ phần phím tắt.

Quy ước mã: PRD `PLN-PRD-Gxx`, SRS `PLN-SRS-Gxx`. Trong mỗi SRS, mã BR, UC, SCR, MSG đánh số lại từ 01 theo nhóm (giống mẫu). Thông báo (UC-25) đặc tả ngay trong nhóm phát sinh thông báo; G12 giữ phần cấu hình kênh thông báo.
