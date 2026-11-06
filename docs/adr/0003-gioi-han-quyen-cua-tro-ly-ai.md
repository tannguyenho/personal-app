---
status: superseded một phần bởi ADR-0004
---

# Trợ lý AI mặc định tắt và không được đánh dấu task hoàn thành

Trợ lý AI chỉ hoạt động sau khi người dùng đồng ý chia sẻ dữ liệu với nhà cung cấp AI; thời điểm đồng ý được lưu, và trước đó không có lời gọi AI nào, kể cả job soạn highlights. AI được tạo task, dời ngày, timebox và ước lượng, nhưng không bao giờ đánh dấu hoàn thành, vì hoàn thành một task có liên kết sẽ đẩy trạng thái ra Jira / Gmail và không hoàn tác trọn vẹn được. Dữ liệu tích hợp (tiêu đề email, issue) mặc định không vào ngữ cảnh AI; khi được bật, mọi hành động AI đề xuất trong ngữ cảnh đó đều phải chờ người dùng duyệt để chặn lệnh ẩn trong nội dung bên ngoài.

## Cập nhật 06/11/2026 (F4)

PO bỏ công tắc "Cho phép AI hoàn thành và xoá task" mà ADR-0004 thêm vào. Khi trợ lý AI đang bật và người dùng đã đồng ý, AI luôn được hoàn thành và xoá task / subtask. Phần còn giữ của ADR này: trợ lý mặc định tắt và cần đồng ý; AI không bao giờ hoàn thành hay xoá task có liên kết tích hợp; xoá của AI chỉ vào Thùng rác. Xem QC-12 mục 4 và [quyết định 06/11](../review/quyet-dinh-chot-2026-11-06.md).
