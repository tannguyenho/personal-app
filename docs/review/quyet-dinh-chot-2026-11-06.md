# Quyết định chốt sau review flow — 06/11/2026

PO chốt các điểm còn vênh mà review user flow ([ticket #10](https://github.com/tannguyenho/personal-app/issues/10), [`design-brief/flow/`](../design-brief/flow/README.md)) phát hiện. Mã **F** tách với các mã B / C / D / Q của [quyết định 04/11](quyet-dinh-chot-2026-11-04.md).

| Mã | Quyết định | Đã sửa |
|---|---|---|
| F1 | **Phím S = về hôm nay** (cả task trên board lẫn task backlog). "Hoãn 1 tuần" ít dùng nên chỉ còn là lệnh trong command menu / menu Ngày dự định, không có phím tắt | QC-05 tách hai dòng; G04 BR-10; G06 ví dụ số ngày bị hoãn; PRD G04 mục 10 |
| F2 | **Rollover thất bại chỉ có một cách hiển thị**, G06 sở hữu: banner G06 MSG-25 có "Thử lại", theo hàng chờ banner (IA-17). Đang chờ (`DANG_CHAY`, `CHO_SHUTDOWN`) không phải lỗi: board hiện rollover tạm, Daily planning hiện MSG-32 | G06 BR-24, MSG-25; G04 BR-25, MSG-27; G08 BR-06, bảng mã lỗi; flow G08 |
| F3 | **Giữ "Daily planning có hướng dẫn"** sau onboarding (PRD G01 US2.2). IA-12 sửa theo: xong onboarding vào Home hôm nay, Daily planning ở chế độ có hướng dẫn thay vùng chính | IA mục 6, IA-12. Chế độ có hướng dẫn **chưa được định nghĩa** trong G08: chờ PO |
| F4 | **AI được phép xoá và điều chỉnh task** | Chờ PO làm rõ phạm vi (bỏ công tắc hay đổi mặc định) trước khi sửa QC-12 |
