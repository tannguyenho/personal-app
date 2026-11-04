# Tính năng để bản sau

Bản 1.0 là app Windows cho **một người dùng** (Q35, Q45). Danh sách dưới đây giữ lại các tính năng đã đặc tả hoặc đã chốt hướng nhưng **không làm ở 1.0**, để không bị mất khi lên kế hoạch các bản sau. Đặc tả chi tiết vẫn nằm trong PRD/SRS của nhóm tương ứng, được gắn nhãn phiên bản.

## Nhiều thành viên (workspace nhóm)

| Tính năng | Quyết định đã chốt | Nhóm |
|---|---|---|
| Mời thành viên qua email / link chung | Ghế mua trước; hết ghế thì chờ OWNER mua thêm (Q22) | G12 |
| Người đã có workspace nhận lời mời | Chuyển task cá nhân hoặc chặn tuỳ trường hợp (Q23) | G12 |
| Giao task, follow task | Task được giao hiển thị với người giao / người follow, bất kể Privacy (Q24); task được giao vào bucket "Tuần sau", lên đầu (Q36) | G02, G06, G12 |
| Privacy (Task, Lịch…) | Privacy "Lịch": người khác chỉ thấy bận / rảnh và timebox, không thấy chi tiết sự kiện ngoài (khuyến nghị, chờ chốt khi làm — Q37) | G05, G12 |
| Quyền tạo channel chung | Thành viên tạo channel riêng tư; channel chung chỉ OWNER / ADMIN (khuyến nghị, chờ chốt khi làm — Q35) | G02, G12 |
| Xoá tài khoản khi ở workspace nhiều người, chuyển quyền sở hữu | Q27 | G01, G12 |

## Gói & thanh toán (bản 1.1)

Trial 14 ngày, thanh toán, chế độ chỉ đọc (QC-09), quyền theo gói (QC-10). Cổng thanh toán còn mở (Q30). Xem ADR-0002.

## Nền tảng

| Bản | Nền tảng |
|---|---|
| 1.0 | Windows (Flutter) |
| 1.1 | Web, macOS |
| 1.2 | iOS, Android |

Trợ lý AI dựa trên Claude Code CLI trên máy (QC-12); cách cung cấp AI trên web và di động để tech chốt.

## Tính năng khác

| Tính năng | Bản | Ghi chú |
|---|---|---|
| Auto-schedule, lập lịch cứng cho task lặp | 1.1 | G05; dùng khung giờ channel (QC-02) |
| Weekly planning / review, objective, analytics | 1.1 | G09 |
| Tích hợp Gmail / Jira / Notion | 1.1 | G11 |
| Slack / Teams, Focus Bar | 1.2 | G07, G11 |
| Lưu trữ thủ công (`manual`) | Sau 1.0 | Q34 |
| Ngày lễ trong lịch làm việc | Sau 1.0 | QC-02 mục 4 |
