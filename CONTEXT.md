# Personal App — lập kế hoạch ngày

Ứng dụng giúp một người lên kế hoạch cho từng ngày làm việc: gom task và lịch về một chỗ, timebox task lên lịch, rồi khép ngày bằng ritual. Bảng thuật ngữ dưới đây là ngôn ngữ chung cho mọi PRD/SRS trong `docs/`.

## Thời gian

**Ngày làm việc**:
Khoảng thời gian từ mốc đầu ngày của một ngày tới mốc đầu ngày hôm sau, theo timezone của người dùng. Mọi khái niệm "hôm nay", "ngày mai", "ngày của task" đều chỉ ngày làm việc, không chỉ ngày lịch.
_Avoid_: ngày lịch, ngày dương lịch (khi nói về task)

**Mốc đầu ngày**:
Giờ mà một ngày làm việc bắt đầu; mặc định 04:00, người dùng chỉnh trong khoảng 00:00–06:00. Thay đổi có hiệu lực từ ngày làm việc kế tiếp.
_Avoid_: day_start_time (trong văn bản nghiệp vụ), nửa đêm

**Lịch làm việc**:
Các ngày làm việc trong tuần và giờ làm của từng ngày do người dùng chọn; mặc định Thứ Hai–Thứ Sáu. "Ngày làm việc kế tiếp" bỏ qua các ngày không nằm trong lịch làm việc.
_Avoid_: work schedule, giờ hành chính

**Bản ghi thời gian**:
Một khoảng thời gian thực tế người dùng đã làm cho một task, từ timer, nhập tay hoặc ritual. Thuộc về ngày làm việc của thời điểm bắt đầu.
_Avoid_: TimeEntry (trong văn bản nghiệp vụ), log giờ

## Task

**Task**:
Một việc người dùng cần làm, nằm ở đúng một trong năm trạng thái: Kế hoạch, Backlog, Hoàn thành, Lưu trữ, Đã xoá.
_Avoid_: việc, item (item dùng cho dữ liệu nguồn tích hợp)

**Ngày dự định**:
Ngày làm việc mà task đang được xếp vào. Không tự đổi khi người dùng đổi timezone.
_Avoid_: ngày bắt đầu, due date

**Lưu trữ**:
Trạng thái của task đã rời board ngày nhưng chưa bị xoá; luôn kèm lý do: bị bỏ quên (stale), bị bỏ qua (instance lặp), hoặc do người dùng.
_Avoid_: Archive (trong văn bản nghiệp vụ), bị bỏ qua (như một trạng thái riêng)

**Rollover**:
Việc hệ thống tự chuyển task chưa xong của ngày làm việc đã qua sang ngày làm việc hiện tại.
_Avoid_: chuyển ngày tự động, carry-over

**Số ngày bị hoãn**:
Số ngày làm việc tính từ ngày dự định đầu tiên của task tới hôm nay, khi task liên tục bị đẩy sang ngày sau mà không được lên lịch lại có chủ đích. Là cơ sở cho nhãn "Dời n ngày" và việc tự lưu trữ.
_Avoid_: rolloverCount, số lần rollover

**Series**:
Quy tắc lặp của một task lặp lại, sinh ra các instance theo lịch.
_Avoid_: task gốc, mẫu lặp

**Instance**:
Một task cụ thể do series sinh ra cho một ngày làm việc.
_Avoid_: bản sao, occurrence

## Lịch

**Timebox**:
Khoảng giờ người dùng dành cho một task trên lịch; được lưu như một thời điểm tuyệt đối và có thể đồng bộ thành sự kiện trên lịch ngoài.
_Avoid_: block (trong văn bản nghiệp vụ), lịch hẹn

**Lệch ngày**:
Tình trạng timebox của task rơi vào ngày làm việc khác với ngày dự định của task, thường sau khi đổi timezone. Hệ thống chỉ cảnh báo, không tự sửa.

**Lập lịch cứng**:
Chế độ tự tạo timebox cho instance của series tại giờ cố định.
_Avoid_: hard schedule

**Timebox liên kết sự kiện**:
Timebox gắn với một sự kiện có sẵn trên lịch ngoài (ví dụ cuộc họp được kéo vào thành task); đi theo sự kiện gốc và không bao giờ tạo sự kiện mới.

## Gói & quyền

**Trợ lý AI**:
Các tính năng gọi mô hình AI (chat, Planning Agent, highlights). Mặc định tắt cho tới khi người dùng đồng ý chia sẻ dữ liệu; không bao giờ tự đánh dấu task hoàn thành.
_Avoid_: Sunny (tên hiển thị, không dùng trong quy tắc)

**Chế độ chỉ đọc**:
Trạng thái của workspace khi không còn quyền dùng trả phí: người dùng chỉ xem được, và mọi việc tự động ghi dữ liệu nghiệp vụ đều bị đóng băng. Chỉ có từ khi có thanh toán (bản 1.1).
_Avoid_: khoá tài khoản, hết hạn
