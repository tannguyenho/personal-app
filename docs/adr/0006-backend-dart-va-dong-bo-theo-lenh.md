---
status: accepted, 05/11/2026
---

# Backend viết bằng Dart, đồng bộ offline theo hàng đợi lệnh

Backend viết bằng Dart (`shelf`, SQL tay trên PostgreSQL) để dùng chung một package `wakeup_core` với app Flutter: `workday()` và các ca chuẩn QC-01, rollover tạm trên máy, sức chứa, số ngày bị hoãn, DTO, lệnh và mã lỗi. Đồng bộ nhiều thiết bị theo **hàng đợi lệnh**: client gửi lệnh nghiệp vụ kèm `baseVersion`, server kiểm tra, áp và gán số thứ tự toàn cục, client kéo thay đổi theo cursor; WebSocket chỉ báo có thay đổi. Mô hình này thể hiện trực tiếp các lần từ chối có nghĩa nghiệp vụ của QC-08 (`VERSION_CONFLICT`, `TASK_DELETED`, `ALREADY_REPEATING`) và Hoàn tác theo lượt AI (`aiTurnId`).

## Considered Options

- TypeScript / Go: hệ sinh thái lớn hơn hoặc nhẹ hơn, nhưng phải viết logic QC-01, QC-04, QC-05 hai lần và giữ cho khớp.
- Supabase / Firebase: logic đồng bộ và job quá đặc thù để đặt trong function, khó test.
- Serverpod: có codegen và ORM nhưng áp đặt kiểu RPC, khó tách, tốn RAM hơn.
- Engine đồng bộ theo hàng (PowerSync, ElectricSQL) hoặc CRDT: không thể hiện được việc từ chối lệnh theo quy tắc nghiệp vụ.

## Consequences

- Microsoft Graph không có SDK Dart chính thức: gọi REST trực tiếp.
- Bản 1.0 không có OpenAPI; nếu sau này có client không phải Dart thì phải sinh tài liệu API từ `wakeup_core`.
- Chi tiết ở [`docs/tech/01`](../tech/01-quyet-dinh-tech-stack-va-api.md) mục 5–6.
