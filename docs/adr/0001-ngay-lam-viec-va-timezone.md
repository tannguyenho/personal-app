# Ngày của task là ngày làm việc, không đổi theo timezone

Mọi nhóm tính "hôm nay" và ngày của task bằng **ngày làm việc**, với mốc đầu ngày mặc định 04:00 (chỉnh trong 00:00–06:00). Người dùng làm việc khuya tới 2 giờ sáng vẫn ở "hôm nay", không bị rollover giữa chừng. Đổi mốc đầu ngày hoặc timezone có hiệu lực từ ngày làm việc kế tiếp. Khi đổi timezone, ngày dự định của task giữ nguyên, còn timebox giữ thời điểm tuyệt đối (khớp với sự kiện Google/Outlook). Nếu hai thứ rơi khác ngày thì hệ thống chỉ gắn cờ "lệch ngày", không tự dời task.

**Cập nhật 06/11/2026 (F5):** bỏ cờ "lệch ngày". Khi timebox rơi khác ngày dự định, hệ thống không gắn cờ và vẫn không tự sửa; người dùng tự kéo task hoặc timebox nếu muốn khớp. Xem [quyết định chốt 06/11/2026](../review/quyet-dinh-chot-2026-11-06.md).

## Considered Options

- Dùng nửa đêm cố định (ngày lịch): đơn giản hơn, nhưng cắt ngang phiên làm việc khuya và trái với cách người dùng nghĩ về "hôm nay".
- Tính lại ngày của task theo timezone mới: giữ timebox và ngày luôn khớp nhau, nhưng làm task nhảy cột khi đi công tác, và có thể dồn hai instance lặp vào cùng một ngày.

## Consequences

Mọi quy tắc dựa trên "ngày" (hoàn thành task, gán ngày khi timebox, rollover, ritual, recap tuần, AI hiểu "ngày mai") phải dùng chung một định nghĩa ngày làm việc trong `docs/01-quy-tac-dung-chung.md`.
