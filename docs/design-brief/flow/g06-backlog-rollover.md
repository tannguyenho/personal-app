# Flow G06 Backlog, rollover và lưu trữ

> **Nguồn:** [srs-g06](../../features/srs-g06-backlog-rollover.md) (commit `8fac830`, sửa theo [chốt 09/11/2026](../../review/cau-hoi-chot-flow-2026-11-09.md)) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-chuyển-task-vào-backlog) | Chuyển task vào backlog | SCR-02 Menu chọn bucket, SCR-03 Menu Ngày dự định | 5 / 4 |
| [UC-02](#uc-02-xem-và-tổ-chức-backlog) | Xem và tổ chức backlog | SCR-01 Trang Backlog, SCR-09 Panel Backlog gọn, SCR-04 Tạo / sửa folder | 9 / 5 |
| [UC-03](#uc-03-đưa-task-từ-backlog-ra-ngày) | Đưa task từ backlog ra ngày | SCR-01, SCR-03 | 6 / 4 |
| [UC-04](#uc-04-rollover-hằng-ngày-job-rollover) | Rollover hằng ngày (job) | SCR-07 Nhãn "Dời {n} ngày" trên board | 11 / 3 |
| [UC-05](#uc-05-tự-lưu-trữ-trong-job-rollover) | Tự lưu trữ (trong job) | SCR-05 Panel Lưu trữ | 4 / 0 |
| [UC-06](#uc-06-xem-lưu-trữ-khôi-phục-và-xoá-tất-cả) | Xem Lưu trữ, khôi phục, xoá tất cả | SCR-05, SCR-06 Xác nhận "Xoá tất cả", SCR-08 Chi tiết task chỉ xem | 9 / 4 |
| [UC-07](#uc-07-đảm-bảo-rollover-theo-yêu-cầu-rolloverensure) | Đảm bảo rollover theo yêu cầu | Không có màn riêng; board (G04), Daily planning (G08) | 4 / 2 |

---

## UC-01 Chuyển task vào backlog

**Mở đầu:** task Kế hoạch (hoặc Backlog, để đổi bucket). **Thành công:** task trong đúng bucket, rời cột ngày, tổng thời lượng ngày cập nhật. **Thất bại:** task giữ ngày / bucket cũ.

### Happy case

```mermaid
flowchart TD
  start(["Board · task card Kế hoạch<br/>đang chọn hoặc hover"])
  u1[/"Nhấn Z, không ô nhập nào focus BR-17<br/>hoặc SCR-03 Menu Ngày dự định → Chuyển vào backlog (Z)"/]
  s1["SCR-02 Menu chọn bucket<br/>gần task, bucket hiện tại có dấu chọn"]
  u2[/"Bấm một bucket<br/>hoặc phím 1, 2, 3, 4, 5, 0"/]
  p1[["TaskMove backlogBucket<br/>ẩn task khỏi cột ngay, cập nhật lạc quan"]]
  p2[["Server áp BR-02<br/>G05 xử lý timebox, sự kiện ngoài theo QC-05"]]
  m1>"MSG-01 · Toast ít nhất 5 giây<br/>{tiêu đề} đã chuyển vào {bucket} trong Backlog · Hoàn tác · Mở task · Đóng"]
  ok(["Task trong bucket đã chọn<br/>tổng thời lượng ngày cập nhật"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> p2 ==> m1 ==> ok

  class start,u1,s1,u2,p1,p2,m1 happy
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế

```mermaid
flowchart TD
  u1[/"Nhấn Z hoặc menu Chuyển vào backlog"/]
  s1["SCR-02 Menu chọn bucket"]
  u2[/"Chọn bucket"/]
  p1[["TaskMove backlogBucket"]]
  m1>"MSG-01 · Toast<br/>{tiêu đề} đã chuyển vào {bucket} trong Backlog · Hoàn tác · Mở task · Đóng"]
  ok(["Task trong bucket đã chọn"])
  u1 ==> s1 ==> u2 ==> p1 ==> m1 ==> ok

  u1 -->|"A1 · Shift+Z hoặc SCR-03 Lên đầu backlog"| a1[["TaskMove next_week, position top BR-03<br/>bỏ qua SCR-02"]]
  a1 --> a1m>"MSG-02 · Toast<br/>Đã đưa #quot;{tiêu đề}#quot; lên đầu Backlog · Hoàn tác"]
  start2(["Board · task card"]) -->|"A2 · kéo vào SCR-01 / SCR-09 Backlog"| a2["Thả vào bucket hoặc folder nào<br/>thì chuyển vào đó, toast như phím Z QC-13"]
  a2 --> p1
  s1 -->|"A5 · Esc"| a5(["SCR-02 đóng, không đổi"])
  m1 -->|"A3 · bấm Mở task"| a3x{{"→ G02 · UC-02"}}
  m1 -->|"A4 · Hoàn tác / Ctrl+Z"| a4[["TaskMove undoToken: trả cụm vị trí cũ,<br/>firstPlannedDate, liên kết timebox<br/>G05 tạo lại sự kiện ngoài với giờ cũ"]]
  a1m -->|"A4"| a4
  a4 --> a4e(["Task về ngày và vị trí cũ"])

  class u1,s1,u2,p1,m1 happy
  class a1,a1m,start2,a2,a4,a4e alt
  class a3x link
  class a5 fail
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh lỗi

```mermaid
flowchart TD
  u2[/"Chọn bucket"/]
  p1[["TaskMove backlogBucket"]]
  p2[["Server áp BR-02"]]
  ok(["Task trong bucket đã chọn"])
  u2 ==> p1 ==> p2 ==> ok

  p1 -.->|"E1 · mất mạng"| e1["Áp trên máy, hàng đợi QC-08<br/>đồng bộ sau cùng idempotency key"]
  e1 -.->|"có mạng, gửi lên"| p2
  e1 -.->|"E5 · VERSION_CONFLICT,<br/>server đã rollover task lúc offline"| e5m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e5m -.-> e5(["Task vẽ theo server"])
  p1 -.->|"E2 · 404 / TASK_DELETED"| e2m>"MSG-20 · Toast<br/>Task này không còn tồn tại"]
  e2m -.-> e2(["Gỡ task khỏi màn hình"])
  p1 -.->|"E3 · 5xx / timeout"| e3["Task về cột cũ"]
  e3 -.-> e3m>"MSG-17 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]

  class u2,p1,p2 happy
  class e1 sync
  class e5m,e2m,e3,e3m err
  class ok done
  class e5,e2 fail
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Shift+Z / Lên đầu backlog | Đầu bucket Tuần tới | MSG-02 |
| A2 | Kéo vào trang / panel Backlog | Bucket / folder nơi thả, toast có Hoàn tác (A2 chốt 09/11/2026) | MSG-01 |
| A3 | Bấm Mở task | Chi tiết task → [G02 UC-02](g02-quan-ly-task.md#uc-02-xem-và-sửa-chi-tiết-task) | – |
| A4 | Hoàn tác trên MSG-01 / MSG-02 / Ctrl+Z | Cụm vị trí cũ, timebox, sự kiện ngoài tạo lại | – |
| A5 | Esc khi SCR-02 mở | Không đổi | – |
| E1 | Mất mạng | Hàng đợi, đồng bộ sau | – |
| E2 | Task đã bị xoá ở thiết bị khác | Gỡ khỏi màn hình | MSG-20 |
| E3 | 5xx / timeout | Task về cột cũ | MSG-17 |
| E4 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E5 | VERSION_CONFLICT (lệnh offline trên phiên bản cũ) | Vẽ theo server | MSG-23 |

---

## UC-02 Xem và tổ chức backlog

**Mở đầu:** người dùng đã đăng nhập. **Thành công:** backlog hiển thị theo bucket; folder / task mới được lưu. **Thất bại:** dữ liệu trên máy kèm lỗi tải.

### Happy case

```mermaid
flowchart TD
  start(["Sidebar Backlog hoặc phím B"])
  p1[["BacklogList, BacklogFolderList"]]
  s1["SCR-01 Trang Backlog<br/>6 bucket theo BR-01, số task, tổng thời lượng"]
  u1[/"Cuộn, thu gọn / mở bucket"/]
  ok(["Backlog hiển thị theo bucket"])
  u2[/"Bấm một task"/]
  x1{{"→ G02 · UC-02 chi tiết task"}}

  start ==> p1 ==> s1 ==> u1 ==> ok
  s1 ==> u2 ==> x1

  class start,p1,s1,u1,u2 happy
  class x1 link
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế và lỗi: xem và sắp xếp

```mermaid
flowchart TD
  p1[["BacklogList, BacklogFolderList"]]
  s1["SCR-01 Trang Backlog"]
  p1 ==> s1

  s1 -->|"A1 · bấm nút nhóm theo channel"| a1["SCR-01 chia nhóm theo channel trong mỗi bucket<br/>nhớ lựa chọn trên máy"]
  s1 -->|"A2 · lọc channel"| a2[["BacklogList channelId"]]
  a2 --> s1
  s1 -->|"A3 · Thêm task trên đầu trang"| a3["SCR-01 ô soạn G02, không có ngày<br/>bucket, folder = cái đang mở, mặc định Tuần tới"]
  a3 --> a3x{{"→ G02 · UC-01 · TaskCreate"}}
  s1 -->|"A6 · kéo task giữa bucket / folder / thứ tự"| a6[["TaskMove backlogBucket, folderId,<br/>afterId / beforeId<br/>sang bucket khác: MSG-01 có Hoàn tác<br/>cùng bucket: không toast, Ctrl+Z"]]
  s1 -->|"A7 · bấm nút biểu đồ"| a7["SCR-01 tổng thời lượng<br/>theo bucket và channel"]
  s1 -->|"A8 · bucket rỗng"| a8m>"MSG-04 · Empty state<br/>Chưa có task nào"]
  a9s(["Panel phải → Backlog hoặc Shift+B"]) -->|"A9 · BacklogList"| a9["SCR-09 Panel Backlog gọn<br/>cùng 6 bucket, không có phần lọc<br/>kéo task ra board"]

  p1 -.->|"E4 · BacklogList lỗi"| e4["SCR-01 / SCR-09 dữ liệu lưu trên máy"]
  a9 -.->|"E4"| e4
  e4 -.-> e4m>"QC-MSG-02 · Tại chỗ<br/>Chưa tải được. Thử lại"]
  e4m -.->|"Thử lại"| p1

  class p1,s1 happy
  class a1,a2,a3,a6,a7,a8m,a9s,a9 alt
  class a3x link
  class e4,e4m err
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế và lỗi: folder

```mermaid
flowchart TD
  s1["SCR-01 Trang Backlog"]

  s1 -->|"A4 · Thêm folder"| a4["SCR-04 Tạo / sửa folder"]
  s1 -->|"A5 · menu folder: Đổi tên"| a4
  a4 --> a4u[/"Nhập tên, bấm Lưu / Enter"/]
  a4u --> a4p[["BacklogFolderCreate / BacklogFolderUpdate"]]
  a4p --> a4e(["Folder mới / tên mới trong SCR-01"])
  a4 -->|"A5 · Xoá folder"| a5m>"MSG-08 · Dialog<br/>Xoá folder #quot;{tên}#quot;? {n} task trong folder vẫn ở lại Backlog"]
  a5m -->|"xác nhận"| a5p[["BacklogFolderDelete<br/>task ở lại backlog, folderId = null BR-04"]]
  a5p --> a5e(["Folder biến mất, task còn trong bucket"])

  a4u -.->|"E1 · tên rỗng / > 50 ký tự"| e1m>"MSG-05 · Inline<br/>Tên folder từ 1 đến 50 ký tự"]
  a4p -.->|"E2 · tên trùng, FOLDER_NAME_TAKEN"| e2m>"MSG-06 · Inline<br/>Folder này đã tồn tại"]
  a4p -.->|"E3 · folder thứ 51, LIMIT_FOLDERS"| e3m>"MSG-07 · Inline<br/>Bạn đã có tối đa {max} folder"]
  e1m -.-> a4u
  e2m -.-> a4u
  a4p -.->|"E5 · mất mạng, cả A3, A5, A6"| e5["Chạy trên máy, hàng đợi QC-08 mục 7<br/>dấu Chờ đồng bộ ở folder / task vừa đổi"]
  a5p -.->|"E5"| e5
  e5 -.->|"có mạng, gửi lên"| a4e
  e5 -.->|"server từ chối: trùng tên / quá 50 folder"| e5m(["Bỏ thay đổi trên máy<br/>MSG-06 / MSG-07"])

  class s1 happy
  class a4,a4u,a4p,a5m,a5p alt
  class a4e,a5e done
  class e1m,e2m,e3m err
  class e5 sync
  class e5m fail
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Nhóm theo channel | Nhóm trong bucket, nhớ trên máy | – |
| A2 | Lọc channel | Danh sách lọc | – |
| A3 | Thêm task | Ô soạn không ngày → [G02 UC-01](g02-quan-ly-task.md#uc-01-tạo-task) | – |
| A4 | Thêm folder | SCR-04 → folder mới | – |
| A5 | Đổi tên / xoá folder | SCR-04; xoá: hộp xác nhận, task ở lại backlog | MSG-08 |
| A6 | Kéo task giữa bucket / folder / thứ tự | Vị trí mới; sang bucket khác có toast Hoàn tác, cùng bucket thì không (QC-13) | MSG-01 (sang bucket khác) |
| A7 | Nút biểu đồ | Tổng thời lượng theo bucket, channel | – |
| A8 | Bucket rỗng | Empty state | MSG-04 |
| A9 | Shift+B / panel phải → Backlog | SCR-09 Panel Backlog gọn (C09) | – |
| E1 | Tên folder rỗng / > 50 ký tự | Chặn | MSG-05 |
| E2 | Tên folder trùng | Chặn | MSG-06 |
| E3 | Folder thứ 51 | Chặn | MSG-07 |
| E4 | BacklogList lỗi | Dữ liệu trên máy, Thử lại | QC-MSG-02 |
| E5 | Mất mạng khi thêm task, sửa folder, kéo task | Chạy trên máy, Chờ đồng bộ, gửi lên khi có mạng (QC-08 mục 7) | MSG-06 / MSG-07 nếu server từ chối |

---

## UC-03 Đưa task từ backlog ra ngày

**Mở đầu:** task ở Backlog. **Thành công:** task Kế hoạch trên ngày D, tổng thời lượng ngày D cập nhật. **Thất bại:** task ở lại bucket.

### Happy case

```mermaid
flowchart TD
  start(["SCR-01 Trang Backlog · task Backlog"])
  u1[/"Kéo task vào cột ngày D<br/>ở panel ngày SCR-01 hoặc board G04"/]
  p1[["TaskMove startDate D, afterId / beforeId<br/>hiện task ở cột D ngay"]]
  p2[["Server áp BR-05: bucket, folder = null<br/>reset số ngày bị hoãn; day.recomputed cho D"]]
  m1>"MSG-03 · Toast<br/>Đã chuyển #quot;{tiêu đề}#quot; sang {ngày} · Hoàn tác"]
  ok(["Task Kế hoạch trên cột D<br/>tổng thời lượng ngày D cập nhật"])

  start ==> u1 ==> p1 ==> p2 ==> m1 ==> ok

  class start,u1,p1,p2,m1 happy
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế và lỗi

```mermaid
flowchart TD
  start(["SCR-01 · task Backlog"])
  u1[/"Kéo vào cột ngày D"/]
  p1[["TaskMove startDate, BR-05"]]
  m3>"MSG-03 · Toast<br/>Đã chuyển #quot;{tiêu đề}#quot; sang {ngày} · Hoàn tác"]
  ok(["Task Kế hoạch trên cột D"])
  start ==> u1 ==> p1 ==> m3 ==> ok

  start -->|"A1 · phím S"| a1["startDate = hôm nay"]
  start -->|"A2 · SCR-03 Menu Ngày dự định → chọn ngày"| a2["SCR-03 lịch chọn ngày<br/>ngày < hôm nay disabled"]
  a1 --> p1
  a2 --> p1
  m3 -->|"A6 · Hoàn tác / Ctrl+Z"| a6[["TaskMove undoToken<br/>về đúng bucket, folder, vị trí cũ QC-13"]]
  a6 --> a6e(["Task về lại Backlog như trước"])
  start -->|"A3 · kéo vào lịch"| a3[["startDate = ngày làm việc của ô QC-01<br/>tạo timebox theo G05"]]
  a3 --> a3x{{"→ G05 · UC-03"}}
  a4s(["G08 Daily planning · bucket tới kỳ"]) -->|"A4"| p1
  p1 -->|"A5 · instance lặp, D đã có instance cùng series"| a5m>"MSG-21 · Toast cảnh báo<br/>Ngày này đã có {tên series}"]
  a5m --> ok

  p1 -.->|"E1 · TaskMove lỗi"| e1m>"MSG-17 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  p1 -.->|"E3 · D < hôm nay, PAST_DATE"| e3m>"MSG-24 · Toast<br/>Không thể đặt task chưa xong vào ngày đã qua"]
  e1m -.-> fail(["Task về bucket cũ"])
  e3m -.-> fail
  p1 -.->|"E4 · VERSION_CONFLICT"| e4m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e4m -.-> e4(["Task vẽ theo server"])
  p1 -.->|"E5 · mất mạng"| e5["Task hiện ở cột D trên máy<br/>hàng đợi, dấu Chờ đồng bộ QC-08 mục 7"]
  e5 -.->|"có mạng, gửi lên cùng idempotency key"| ok
  e5 -.->|"bị từ chối"| e3m
  e5 -.->|"bị từ chối"| e4m

  class start,u1,p1,m3 happy
  class a1,a2,a3,a4s,a6,a6e alt
  class a5m warn
  class a3x link
  class e1m,e3m,e4m err
  class e5 sync
  class ok done
  class fail,e4 fail
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Phím S | Hôm nay | MSG-03 |
| A2 | Menu Ngày dự định → chọn ngày | Ngày chọn | MSG-03 |
| A3 | Kéo vào lịch | Ngày của ô, timebox → [G05 UC-03](g05-lich-timebox.md#uc-03-timebox-task-bằng-kéo-thả) | – |
| A4 | Ritual đưa task tới kỳ ra ngày | Như luồng chính → [G08 UC-01](g08-daily-rituals.md#uc-01-daily-planning-luồng-thủ-công); phần G09 Weekly planning (1.1): Bỏ (1.1) | – |
| A5 | Instance lặp, D đã có instance cùng series | Vẫn đặt, cảnh báo | MSG-21 |
| A6 | Hoàn tác / Ctrl+Z | Về đúng bucket, folder, vị trí cũ (QC-13 mục 5) | – |
| E1 | TaskMove lỗi | Về bucket cũ | MSG-17 |
| E2 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E3 | D < hôm nay | Về bucket cũ | MSG-24 |
| E4 | VERSION_CONFLICT | Vẽ theo server | MSG-23 |
| E5 | Mất mạng | Cột D trên máy, Chờ đồng bộ, gửi lên khi có mạng (QC-08 mục 7) | – |

---

## UC-04 Rollover hằng ngày (job `rollover`)

**Mở đầu:** job hệ thống; người dùng vừa qua mốc đầu ngày, chưa có lượt `XONG` cho ngày đó, không ở `CHO_SHUTDOWN`. **Thành công:** mọi task Kế hoạch ngày cũ ở hôm nay hoặc ở Lưu trữ; lượt `XONG`. **Thất bại:** không task nào đổi (rollback); lượt `LOI` hoặc `THAT_BAI`.

### Happy case

```mermaid
flowchart TD
  start(["Job rollover lúc mốc đầu ngày<br/>chạy mỗi 15 phút, người dùng vừa qua mốc QC-01"])
  p1[["Chọn người dùng chưa có lượt XONG BR-13<br/>không THAT_BAI, không lượt DANG_CHAY còn lease"]]
  p2[["Không có phiên shutdown ngày cũ BR-20<br/>rollover_runs = DANG_CHAY, leaseUntil = now + 5 phút"]]
  p3[["Lấy task Kế hoạch có startDate < hôm nay BR-06<br/>nhóm instance lặp theo series, áp BR-11 trước<br/>xem G03 UC-06"]]
  p4[["Một giao dịch: BR-07 startDate = hôm nay,<br/>BR-08 priority về Normal, BR-09 timebox<br/>tăng version từng task"]]
  p5[["Áp BR-12 cho task bị hoãn ≥ ngưỡng · UC-05"]]
  p6[["Nhật ký system BR-16<br/>rollover_runs = XONG kèm số liệu"]]
  p7[["Phát task.upserted, day.recomputed<br/>G05 gỡ liên kết timebox quá khứ, bất đồng bộ"]]
  m1>"MSG-09 · Tooltip trên SCR-07 nhãn Dời {n} ngày<br/>Dời {n} ngày · dự định từ {ngày dự định đầu tiên}"]
  ok(["Board hôm nay: task dở ở đầu / cuối danh sách,<br/>sau instance lặp hôm nay, có SCR-07 nhãn Dời {n} ngày"])

  start ==> p1 ==> p2 ==> p3 ==> p4 ==> p5 ==> p6 ==> p7 ==> m1 ==> ok

  class start,p1,p2,p3,p4,p5,p6,p7,m1 happy
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế

```mermaid
flowchart TD
  start(["Job rollover lúc mốc đầu ngày"])
  p2[["rollover_runs = DANG_CHAY, lease 5 phút"]]
  p3[["Lấy task thoả BR-06, áp BR-11"]]
  p4[["Giao dịch BR-07, BR-08, BR-09"]]
  p5[["Tự lưu trữ BR-12"]]
  p6[["rollover_runs = XONG"]]
  ok(["Board hôm nay có task dở<br/>SCR-07 nhãn Dời {n} ngày"])
  start ==> p2 ==> p3 ==> p4 ==> p5 ==> p6 ==> ok

  start -->|"A1 · lỡ nhiều mốc / startDate cách hôm nay > 1 ngày"| a1["Chuyển một lần về hôm nay, một dòng nhật ký<br/>số ngày bị hoãn tính từ firstPlannedDate EC-05"]
  a1 --> p4
  start -->|"A9 · lượt DANG_CHAY hết lease, worker chết"| p2
  p2 -->|"A7 · phiên Daily shutdown ngày cũ đang làm"| a7["rollover_runs = CHO_SHUTDOWN<br/>task ngày cũ ở yên cột ngày cũ"]
  a7 -->|"ritual.shutdown.closed<br/>hoặc tới mốc + 2 giờ"| p2
  a7 --> a7x{{"→ G08 · UC-02"}}
  p3 -->|"A6 · không có task thoả BR-06"| a6(["Lượt XONG, số liệu 0"])
  p3 -->|"A12 · instance lặp quá khứ đã sửa riêng<br/>hoặc có thời gian thực tế"| a12["Không lưu trữ skipped BR-11, chỉ ở rollover<br/>rollover vào hôm nay như task thường<br/>không làm instance khác thành skipped"]
  a12 --> p4
  p4 -->|"A5 · task đang chạy timer"| a5["Rollover bình thường, timer không dừng"]
  p4 -->|"A10 · hôm nay không có trong lịch, ví dụ Thứ Bảy"| a10["Vẫn chạy; số ngày bị hoãn không tăng<br/>nếu hôm nay không có trong lịch của task BR-10"]
  a5 --> p5
  a10 --> p5
  ok -->|"A3 · đang mở board / chi tiết task"| a3["Card chuyển cột qua realtime<br/>chi tiết đang mở không đóng, ngày cập nhật"]
  ok -->|"A11 · muốn trả lại kết quả"| a11["Không có Hoàn tác Q41<br/>kéo / chọn ngày hoặc đưa vào backlog"]
  a11 --> a11x{{"→ G04 · UC-03 · UC-01"}}
  a4s(["App Windows offline qua mốc"]) -->|"A4"| a4["Rollover tạm trên máy BR-06, BR-07<br/>chỉ hiển thị, không vào hàng đợi QC-08 mục 5"]
  a4 -->|"có mạng"| a4x{{"→ UC-07"}}
  a2s(["Người dùng đổi timezone / mốc đầu ngày trong ngày"]) -->|"A2"| a2["Hiệu lực từ ngày làm việc kế tiếp<br/>hôm nay rollover theo cài đặt cũ, đã XONG không chạy lại"]

  class start,p2,p3,p4,p5,p6 happy
  class a1,a7,a5,a10,a3,a11,a4s,a2s,a2,a12 alt
  class a4 sync
  class a7x,a11x,a4x link
  class ok,a6 done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh lỗi

```mermaid
flowchart TD
  start(["Job rollover lúc mốc đầu ngày"])
  p2[["rollover_runs = DANG_CHAY"]]
  p4[["Giao dịch BR-07, BR-08, BR-09"]]
  p6[["rollover_runs = XONG"]]
  p7[["G05 gỡ liên kết timebox quá khứ"]]
  ok(["Board hôm nay có task dở"])
  start ==> p2 ==> p4 ==> p6 ==> p7 ==> ok

  p4 -.->|"E1 · lỗi CSDL giữa chừng"| e1[["Rollback cả lượt của người dùng<br/>rollover_runs = LOI"]]
  e1 -.->|"lượt job kế tiếp thử lại"| p2
  e1 -.->|"lần lỗi thứ 3"| e3["rollover_runs = THAT_BAI<br/>cảnh báo giám sát, job ngừng thử"]
  e3 -.->|"E3 · lần mở app kế tiếp"| e3x{{"→ UC-07"}}
  p7 -.->|"E2 · G05 gỡ liên kết timebox lỗi"| e2["Không chặn rollover<br/>G05 thử lại qua timebox.push"]
  e2 -.-> ok

  class start,p2,p4,p6,p7 happy
  class e1,e3,e2 err
  class e3x link
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Lỡ nhiều mốc | Chuyển một lần, số ngày bị hoãn đủ | – |
| A2 | Đổi timezone / mốc đầu ngày | Hiệu lực ngày kế tiếp | – |
| A3 | Đang mở board / chi tiết | Cập nhật qua realtime | – |
| A4 | Client offline qua mốc | Rollover tạm trên máy → [UC-07](#uc-07-đảm-bảo-rollover-theo-yêu-cầu-rolloverensure) | – |
| A5 | Task đang chạy timer | Rollover, timer không dừng | – |
| A6 | Không có task thoả BR-06 | Lượt `XONG`, số liệu 0 | – |
| A7 | Phiên Daily shutdown ngày cũ đang làm | `CHO_SHUTDOWN` → [G08 UC-02](g08-daily-rituals.md#uc-02-daily-shutdown) | – |
| A8 | Workspace chỉ đọc | Bỏ (1.1) | – |
| A9 | Lượt `DANG_CHAY` hết lease | Nhận lại, chạy từ bước 2 | – |
| A10 | Hôm nay không có trong lịch | Vẫn chạy, n không tăng | – |
| A11 | Muốn trả lại kết quả | Không Hoàn tác → [G04 UC-03](g04-board-ngay.md#uc-03-di-chuyển-task-giữa-các-ngày), [UC-01](#uc-01-chuyển-task-vào-backlog) | – |
| A12 | Instance lặp quá khứ đã sửa riêng / có thời gian thực tế | Không `skipped`, rollover vào hôm nay như task thường kể cả khi đã có instance cùng series; không làm instance khác thành `skipped`; chỉ ở rollover (B08, ngoại lệ QC-06) | – |
| E1 | Lỗi CSDL | Rollback, `LOI`, lần 3 `THAT_BAI` | – |
| E2 | G05 gỡ timebox lỗi | Không chặn, G05 thử lại | – |
| E3 | `THAT_BAI` | Chạy bù khi mở app → [UC-07](#uc-07-đảm-bảo-rollover-theo-yêu-cầu-rolloverensure) | – |

Instance lặp trong rollover (BR-11): xem [G03 UC-06](g03-task-lap-lai.md#uc-06-xử-lý-instance-trùng-series-trong-một-ngày-qc-06-rollover-g06-phím-d-g04-shutdown-g08).

---

## UC-05 Tự lưu trữ (trong job `rollover`)

**Mở đầu:** job rollover, sau UC-04 bước 4; task có số ngày bị hoãn ≥ 4 (ngưỡng cố định), Tự lưu trữ bật, task không có hoạt động. **Thành công:** task ở Lưu trữ, không còn trên hôm nay. **Thất bại:** như UC-04 (rollback cả lượt).

### Happy case

```mermaid
flowchart TD
  start(["Job rollover lúc mốc đầu ngày<br/>sau UC-04 bước 4"])
  p1[["Task bị hoãn ≥ 4, Tự lưu trữ bật<br/>Lưu trữ: archivedAt = now, archiveReason = stale BR-12"]]
  p2[["Timebox như Đưa vào backlog BR-12<br/>nhật ký: Lưu trữ: bị hoãn {n} ngày"]]
  p3[["Cộng archivedCount vào rollover_runs"]]
  u1[/"Mở app: lượt chạy lúc mở app UC-07 thì toast ngay khi xong<br/>lượt do job chạy trước thì toast lần mở app kế tiếp"/]
  m1>"MSG-11 · Toast<br/>Đã lưu trữ {n} task bị hoãn từ {ngưỡng} ngày làm việc trở lên · Xem Lưu trữ"]
  ok(["Task rời hôm nay, nằm trong SCR-05 Lưu trữ"])
  x1{{"→ UC-06"}}

  start ==> p1 ==> p2 ==> p3 ==> u1 ==> m1 ==> ok
  m1 ==>|"bấm Xem Lưu trữ"| x1

  class start,p1,p2,p3,u1,m1 happy
  class x1 link
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế

```mermaid
flowchart TD
  start(["Job rollover · task bị hoãn ≥ ngưỡng"])
  p1[["Lưu trữ stale BR-12"]]
  m1>"MSG-11 · Toast<br/>Đã lưu trữ {n} task bị hoãn từ {ngưỡng} ngày làm việc trở lên · Xem Lưu trữ"]
  start ==> p1 ==> m1

  start -->|"A1 · Tự lưu trữ tắt"| a1(["Task Kế hoạch hôm nay<br/>SCR-07 nhãn Dời {n} ngày"])
  start -->|"A2 · task đang chạy timer"| a2(["Không lưu trữ ở lượt này<br/>xét lại ở lượt ngày sau"])
  start -->|"A4 · có subtask đã tích<br/>hoặc có thời gian thực tế"| a4(["Không lưu trữ BR-12<br/>task Kế hoạch hôm nay, SCR-07 nhãn Dời {n} ngày"])
  m1 -->|"A3 · muốn trả lại task"| a3["Không có Hoàn tác Q41<br/>timebox, sự kiện ngoài đã gỡ không tạo lại"]
  a3 --> a3x{{"→ UC-06 Khôi phục"}}

  class start,p1,m1 happy
  class a3 alt
  class a1,a2,a4 done
  class a3x link
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Tự lưu trữ tắt | Kế hoạch hôm nay, nhãn "Dời {n} ngày" | – |
| A2 | Task đang chạy timer | Không lưu trữ lượt này | – |
| A3 | Muốn trả lại task | Không Hoàn tác → [UC-06](#uc-06-xem-lưu-trữ-khôi-phục-và-xoá-tất-cả) | – |
| A4 | Task có subtask đã tích / thời gian thực tế | Không lưu trữ, Kế hoạch hôm nay (B11) | – |
| (lỗi) | Không có E#; lỗi lượt xử lý như UC-04 E1 | Rollback cả lượt | – |

---

## UC-06 Xem Lưu trữ, khôi phục và xoá tất cả

**Mở đầu:** người dùng đã đăng nhập. **Thành công:** khôi phục → task Kế hoạch hôm nay (hoặc vào Backlog), số ngày bị hoãn = 0; xoá tất cả → mọi task Lưu trữ vào Thùng rác; toggle Tự lưu trữ được lưu. **Thất bại:** Lưu trữ không đổi.

### Happy case

```mermaid
flowchart TD
  start(["Panel phải → Lưu trữ<br/>hoặc Shift+A"])
  p1[["ArchiveList, mới lưu trữ nhất trước"]]
  s1["SCR-05 Panel Lưu trữ<br/>mỗi dòng có nhãn lý do"]
  m0>"MSG-12 / MSG-13 · Nhãn<br/>Bị hoãn từ {ngưỡng} ngày làm việc trở lên<br/>Đã bỏ qua"]
  u1[/"Bấm Khôi phục trên một dòng<br/>chọn Khôi phục vào hôm nay"/]
  p2[["TaskRestore from archive, áp BR-14<br/>startDate = hôm nay, reset số ngày bị hoãn"]]
  m1>"MSG-14 · Toast<br/>Đã khôi phục #quot;{tiêu đề}#quot; về {hôm nay / ngày} · Hoàn tác"]
  ok(["Task ở đầu danh sách hôm nay"])

  start ==> p1 ==> s1 ==> m0 ==> u1 ==> p2 ==> m1 ==> ok

  class start,p1,s1,m0,u1,p2,m1 happy
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế

```mermaid
flowchart TD
  s1["SCR-05 Panel Lưu trữ"]
  u1[/"Khôi phục vào hôm nay"/]
  p2[["TaskRestore from archive, BR-14"]]
  m1>"MSG-14 · Toast<br/>Đã khôi phục #quot;{tiêu đề}#quot; về {hôm nay / ngày} · Hoàn tác"]
  ok(["Task ở đầu hôm nay"])
  s1 ==> u1 ==> p2 ==> m1 ==> ok

  s1 -->|"A1 · bấm Xoá tất cả"| a1["SCR-06 Xác nhận Xoá tất cả"]
  a1 --> a1m>"MSG-15 · Dialog<br/>Xoá tất cả {n} task trong Lưu trữ? Task sẽ nằm trong Thùng rác 30 ngày"]
  a1m -->|"Huỷ"| s1
  a1m -->|"Xoá tất cả"| a1p[["ArchiveDeleteAll<br/>instance lặp: ngày gốc thành ngày ngoại lệ BR-15"]]
  a1p --> a1t>"MSG-16 · Toast<br/>Đã chuyển {n} task vào Thùng rác · Hoàn tác"]
  s1 -->|"A2 · bật / tắt Tự lưu trữ"| a2[["SettingsUpdate autoArchive G01<br/>áp từ lượt rollover kế tiếp"]]
  s1 -->|"A3 · kéo dòng vào cột ngày D"| a3[["TaskRestore from archive, startDate = D<br/>D ≥ hôm nay"]]
  a3 -->|"MSG-14 có Hoàn tác QC-13"| a3e(["Task Kế hoạch trên cột D"])
  s1 -->|"A4 · Lưu trữ rỗng"| a4m>"MSG-19 · Empty state<br/>Không có task nào được lưu trữ<br/>Xoá tất cả disabled"]
  s1 -->|"A5 · cuộn hết trang"| a5[["ArchiveList tải tiếp theo cursor, 50 dòng"]]
  a5 --> s1
  p2 -->|"A6 · instance lặp, ngày đã có instance cùng series"| a6m>"MSG-21 · Toast cảnh báo<br/>Ngày này đã có {tên series}"]
  a3 -->|"A6"| a6m
  a6m --> ok
  a7s(["Kết quả tìm kiếm G04 · task lưu trữ"]) -->|"A7"| a7["SCR-08 Chi tiết task chỉ xem<br/>nút Khôi phục, hai lựa chọn"]
  a7 --> p2
  s1 -->|"A8 · Khôi phục vào Backlog"| a8[["TaskRestore from archive, backlogBucket next_week<br/>BR-14, đầu bucket Tuần tới"]]
  a7 -->|"A8"| a8
  a8 --> a8m>"MSG-26 · Toast<br/>Đã khôi phục #quot;{tiêu đề}#quot; vào Backlog · Hoàn tác"]
  a8m --> a8e(["Task ở đầu bucket Tuần tới"])
  m1 -->|"A9 · Hoàn tác / Ctrl+Z"| a9[["TaskMove undoToken<br/>về Lưu trữ với lý do cũ QC-13"]]
  a8m -->|"A9"| a9
  a1t -->|"A9"| a9
  a9 --> a9e(["Task về lại SCR-05 như trước"])

  class s1,u1,p2,m1 happy
  class a1,a1m,a1p,a1t,a2,a3,a4m,a5,a7s,a7,a8,a8m,a9 alt
  class a6m warn
  class ok,a3e,a8e,a9e done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh lỗi

```mermaid
flowchart TD
  s1["SCR-05 Panel Lưu trữ"]
  u1[/"Bấm Khôi phục"/]
  p2[["TaskRestore from archive"]]
  ok(["Task ở đầu hôm nay"])
  s1 ==> u1 ==> p2 ==> ok
  a1p[["ArchiveDeleteAll"]]
  a3[["TaskRestore startDate = D"]]
  s1 -->|"A1 · Xoá tất cả, xác nhận"| a1p
  s1 -->|"A3 · kéo dòng vào cột ngày D"| a3

  p2 -.->|"E1 · task đã bị xoá ở thiết bị khác"| e1m>"MSG-20 · Toast<br/>Task này không còn tồn tại"]
  e1m -.-> e1(["Gỡ dòng khỏi SCR-05"])
  p2 -.->|"E2 · TaskRestore lỗi"| e2m>"MSG-17 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  a1p -.->|"E2 · ArchiveDeleteAll lỗi"| e2m
  e2m -.-> e2(["Lưu trữ giữ nguyên"])
  a3 -.->|"E4 · D < hôm nay, PAST_DATE"| e4m>"MSG-24 · Toast<br/>Không thể đặt task chưa xong vào ngày đã qua"]
  e4m -.-> e4(["Task ở lại Lưu trữ"])
  p2 -.->|"E5 · mất mạng, cả A2, A3, A8"| e5["Chạy trên máy, hàng đợi QC-08 mục 7<br/>dấu Chờ đồng bộ ở task / công tắc vừa đổi"]
  a3 -.->|"E5"| e5
  e5 -.->|"có mạng, gửi lên"| ok
  e5 -.->|"bị từ chối"| e1m
  s1 -.->|"E5 · mất mạng, Xoá tất cả"| e5m>"MSG-27 · Tooltip trên nút mờ<br/>Cần có mạng để xoá tất cả"]

  class s1,u1,p2 happy
  class a1p,a3 alt
  class e1m,e2m,e4m,e5m err
  class e5 sync
  class ok done
  class e1,e2,e4 fail
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Xoá tất cả | SCR-06 → mọi task Lưu trữ vào Thùng rác | MSG-15, MSG-16 |
| A2 | Bật / tắt Tự lưu trữ | Áp từ lượt rollover kế tiếp | – |
| A3 | Kéo dòng vào cột ngày D | Task Kế hoạch trên D, toast Hoàn tác (QC-13) | MSG-14 |
| A4 | Lưu trữ rỗng | Empty state, Xoá tất cả disabled | MSG-19 |
| A5 | Cuộn hết trang | Tải thêm 50 dòng | – |
| A6 | Khôi phục instance vào ngày đã có instance cùng series | Vẫn khôi phục | MSG-21 |
| A7 | Mở task lưu trữ từ tìm kiếm | SCR-08 chi tiết chỉ xem → Khôi phục ([G04 UC-07](g04-board-ngay.md#uc-07-tìm-kiếm-task)) | MSG-14 / MSG-26 |
| A8 | Khôi phục vào Backlog | Đầu bucket Tuần tới (B12) | MSG-26 |
| A9 | Hoàn tác trên MSG-14 / MSG-26 / MSG-16 | Về lại Lưu trữ với lý do cũ (QC-13 mục 5) | – |
| E1 | Task đã bị xoá ở thiết bị khác | Gỡ dòng | MSG-20 |
| E2 | TaskRestore / ArchiveDeleteAll lỗi | Lưu trữ giữ nguyên | MSG-17 |
| E3 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E4 | D < hôm nay | Ở lại Lưu trữ | MSG-24 |
| E5 | Mất mạng | Khôi phục, Tự lưu trữ: chạy trên máy, Chờ đồng bộ, gửi lên khi có mạng; Xoá tất cả: nút mờ (QC-08 mục 7) | MSG-27 (Xoá tất cả) |

---

## UC-07 Đảm bảo rollover theo yêu cầu (\[RolloverEnsure\])

**Mở đầu:** client mở app lần đầu trong ngày làm việc (G04), hoặc G08 chuẩn bị tải bước "Xem lại hôm qua". **Thành công:** trả trạng thái lượt rollover hôm nay; chạy được thì `XONG` và board nhận kết quả. **Thất bại:** trả lỗi, dữ liệu task không đổi.

### Happy case

```mermaid
flowchart TD
  start(["Mở app lần đầu trong ngày làm việc G04<br/>hoặc G08 trước bước Xem lại hôm qua"])
  p1[["RolloverEnsure, server tính hôm nay QC-01"]]
  p2[["Đọc rollover_runs người dùng, hôm nay"]]
  d1{"Trạng thái lượt?"}
  p3[["Chạy UC-04 bước 2-7 trong request"]]
  p4[["Trả date, status, rolledCount,<br/>archivedCount, skippedCount"]]
  ok(["Board lấy kết quả server làm chuẩn<br/>archivedCount lớn hơn 0 thì hiện MSG-11 ngay"])

  start ==> p1 ==> p2 ==> d1
  d1 ==>|"XONG"| p4
  d1 ==>|"CHO, LOI, THAT_BAI, chưa có bản ghi,<br/>DANG_CHAY hết lease"| p3 ==> p4
  p4 ==> ok

  class start,p1,p2,d1,p3,p4 happy
  class ok done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Nhánh thay thế và lỗi

```mermaid
flowchart TD
  p1[["RolloverEnsure"]]
  d1{"Trạng thái lượt?"}
  p3[["Chạy UC-04 bước 2-7"]]
  p4[["Trả kết quả"]]
  ok(["Board theo kết quả server"])
  p1 ==> d1 ==> p3 ==> p4 ==> ok

  d1 -->|"A1 · DANG_CHAY còn lease"| a1[["Chờ tối đa 10 giây"]]
  a1 -->|"xong"| p4
  a1 -->|"chưa xong"| a1r["Trả DANG_CHAY<br/>client nhận kết quả sau qua realtime"]
  p1 -->|"A2 · trong lúc chờ phản hồi"| a2["Board hiện rollover tạm trên máy<br/>chỉ hiển thị QC-08 mục 5"]
  a1r -->|"A2"| a2
  d1 -->|"A3 · CHO_SHUTDOWN"| a3(["Trả CHO_SHUTDOWN, waitUntil = mốc + 2 giờ<br/>task ngày cũ ở cột ngày cũ"])
  a5s(["Nhiều thiết bị, G04 và G08 cùng gọi"]) -->|"A5"| a5["Idempotent theo người dùng + ngày BR-13<br/>một request chạy, request khác theo A1"]
  a5 --> a1

  p3 -.->|"E1 · chạy trong request lỗi"| e1[["Rollback, tăng số lần lỗi BR-18<br/>trả ROLLOVER_FAILED"]]
  e1 -.-> e1m>"MSG-25 · Banner<br/>Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại"]
  e1m -.->|"Thử lại"| p1
  p1 -.->|"E2 · timeout / mất mạng"| e2["Giữ rollover tạm trên máy<br/>gọi lại khi có mạng"]
  e2 -.-> p1

  class p1,d1,p3,p4 happy
  class a1,a1r,a5s,a5 alt
  class a2,e2 sync
  class e1,e1m err
  class ok,a3 done
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | `DANG_CHAY` còn lease | Chờ ≤ 10 giây; chưa xong trả `DANG_CHAY` | – |
| A2 | Đang chờ / nhận `DANG_CHAY` | Rollover tạm trên máy | – |
| A3 | `CHO_SHUTDOWN` | Không ép chạy, task ngày cũ ở cột cũ | – |
| A4 | Workspace chỉ đọc (`DONG_BANG`) | Bỏ (1.1) | – |
| A5 | Gọi lặp nhiều lần | Idempotent, chỉ một request chạy | – |
| E1 | Chạy trong request lỗi | Rollback, Thử lại | MSG-25 |
| E2 | Timeout / mất mạng | Giữ rollover tạm, gọi lại khi có mạng | – |

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-07 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)".
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG.

**Ghi chú cho brief G06**
- ~~MSG-01 (toast sau Z) không có "Hoàn tác" trong khi BR-17 nói Z luôn có toast Hoàn tác~~ **Đã sửa 09/11/2026 (B06):** MSG-01 thêm "Hoàn tác"; UC-01 bước 6, A4 và sơ đồ UC-01 sửa theo.
- ~~Lỗi `ROLLOVER_FAILED` có hai thông báo cùng chữ (G06 MSG-25, G04 MSG-27), G08 lại hiện MSG-32 khi `THAT_BAI`~~ **Đã sửa trước 09/11/2026 (F2, BR-24):** chỉ một banner MSG-25 ở mọi nơi; G04 MSG-27 dùng đúng nội dung này; MSG-32 chỉ cho trạng thái đang chờ.
- ~~UC-07 E1 trả `ROLLOVER_FAILED` nhưng API cũng trả `status = THAT_BAI`; chưa rõ giao diện khác nhau thế nào~~ **Đã sửa trước 09/11/2026 (F2, BR-24 b):** `ROLLOVER_FAILED` và `THAT_BAI` hiển thị như nhau, banner MSG-25 có "Thử lại".
- ~~UC-02 E4 dùng MSG-17 (câu lỗi lưu) cho lỗi tải BacklogList~~ **Đã sửa 09/11/2026 (C07, A1):** UC-02 E4 dùng QC-MSG-02 "Chưa tải được. Thử lại" tại chỗ; MSG-17 trỏ về QC-MSG-01.
- ~~MSG-14, MSG-16, MSG-03 có "Hoàn tác" nhưng không A# nào nói Hoàn tác làm gì~~ **Đã sửa 09/11/2026 (A10):** thêm UC-03 A6 (về đúng bucket, folder, vị trí cũ) và UC-06 A9 (về lại Lưu trữ với lý do cũ); BR-14, BR-15 ghi rõ. Đã vẽ.
- ~~UC-01 A2 (kéo vào Backlog) và UC-03 (kéo ra ngày) không nói có toast / Hoàn tác~~ **Đã sửa 09/11/2026 (A2):** kéo vào Backlog có MSG-01, kéo ra ngày có MSG-03, kéo từ Lưu trữ ra ngày có MSG-14, kéo sang bucket khác có MSG-01; cùng bucket thì không toast (BR-17, QC-13 mục 2).
- ~~MSG-11 viết "từ {ngưỡng} ngày", MSG-12 viết "từ {ngưỡng} ngày làm việc"~~ **Đã sửa 09/11/2026 (C06):** MSG-11 viết "ngày làm việc" như MSG-12.
- ~~UC-06 A7 mở "chi tiết ở chế độ xem" nhưng không có mã SCR~~ **Đã sửa 09/11/2026 (C08):** thêm SCR-08 Chi tiết task chỉ xem, có nút "Khôi phục" hai lựa chọn.
- ~~UC-05 bước 4: lượt chạy trong \[RolloverEnsure\] lúc mở app thì MSG-11 hiện ngay hay đợi lần mở sau~~ **Đã sửa 09/11/2026 (B07):** hiện ngay khi lượt chạy xong; lượt do job chạy trước thì hiện lần mở app kế tiếp (UC-05 bước 4, UC-07 bước 5).
- ~~UC-03 A4 gộp G08 (1.0) và G09 Weekly planning (1.1)~~ **Đã sửa 09/11/2026 (A9):** SRS ghi "G09 Weekly planning (1.1)"; sơ đồ chỉ vẽ G08.
- ~~IA có panel Backlog gọn (Shift+B) nhưng SRS chỉ có SCR-01~~ **Đã sửa 09/11/2026 (C09):** thêm SCR-09 Panel Backlog gọn (cùng bucket với SCR-01, bỏ phần lọc) và UC-02 A9.
- Mới 09/11/2026 (A6): thêm nhánh mất mạng UC-02 E5, UC-03 E5, UC-06 E5 (chạy trên máy, dấu "Chờ đồng bộ"). "Xoá tất cả" khi mất mạng: nút mờ, MSG-27 `[giả định]`.
- Mới 09/11/2026 (B08, B09, B11, B12): instance lặp đã sửa riêng / có thời gian thực tế không bị `skipped` (UC-04 A12); MSG-13 thành "Đã bỏ qua"; task có hoạt động không bị tự lưu trữ (UC-05 A4); khôi phục vào Backlog (UC-06 A8, MSG-26). Bucket đích khi khôi phục vào Backlog vẫn là `[giả định]` ("Tuần tới", đầu bucket).
