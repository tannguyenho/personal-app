# Flow G02 Quản lý task

> **Nguồn:** [srs-g02](../../features/srs-g02-quan-ly-task.md) (commit `8fac830`, sửa theo chốt 09/11/2026 và chốt 10/11/2026 của brief G02) · **Brief:** [G02](../g02-quan-ly-task.md) (đã duyệt 10/11/2026)
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-tạo-task) | Tạo task | SCR-01 Ô soạn task, SCR-08 Ô thêm nhanh toàn cục, SCR-09 Popover chọn channel, SCR-02 Task card | 7 / 5 |
| [UC-02](#uc-02-xem-và-sửa-chi-tiết-task) | Xem và sửa chi tiết task | SCR-03 Chi tiết task | 12 / 8 |
| [UC-03](#uc-03-hoàn-thành--bỏ-hoàn-thành-task) | Hoàn thành / bỏ hoàn thành | SCR-02, SCR-03 | 7 / 3 |
| [UC-04](#uc-04-xoá-hoàn-tác-và-khôi-phục-task) | Xoá, hoàn tác, khôi phục | SCR-04 Menu "Khác", SCR-05 Thùng rác | 7 / 4 |
| [UC-05](#uc-05-nhân-bản-task) | Nhân bản task | SCR-04, SCR-03 | 2 / 2 |
| [UC-06](#uc-06-quản-lý-context-và-channel) | Quản lý context và channel | SCR-06, SCR-07 | 9 / 7 |

---

## UC-01 Tạo task

**Mở đầu:** board, cột ngày D ≥ hôm nay (cột đã qua không có "+ Thêm task", IA-20); hoặc bất kỳ đâu trên Windows với Ctrl+Shift+A (A7). **Thành công:** task nằm trên cột D (hoặc trong Backlog), tổng thời lượng cột tăng. **Thất bại:** không có task mới, nội dung còn trong ô soạn.

### Happy case

```mermaid
flowchart TD
  start(["Board · cột ngày D ≥ hôm nay"])
  u1[/"Bấm + Thêm task<br/>hoặc chọn cột rồi nhấn A"/]
  s1["SCR-01 Ô soạn task<br/>focus ô tiêu đề, ngày = D"]
  u2[/"Gõ tiêu đề"/]
  d1{"Đủ điều kiện gợi ý AI?<br/>BR-04"}
  p1[["TaskSuggest qua Claude Code<br/>sau 400 ms ngừng gõ"]]
  s2["SCR-01<br/>chip Thời lượng, Channel<br/>có dấu gợi ý AI"]
  u3[/"Tuỳ chọn sửa chip, nhấn Enter"/]
  p2[["Kiểm BR-01, TaskCreate<br/>cập nhật lạc quan BR-03"]]
  ok(["SCR-02 Task card trên cột D<br/>ô soạn giữ mở cho task kế tiếp"])

  start ==> u1 ==> s1 ==> u2 ==> d1
  d1 ==>|"có"| p1 ==> s2 ==> u3
  d1 ==>|"không · A4"| u3
  u3 ==> p2 ==> ok

  class start,u1,s1,u2,d1,u3,p2 happy
  class p1,s2 ai
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
  s1["SCR-01 Ô soạn task"]
  u2[/"Gõ tiêu đề"/]
  u3[/"Nhấn Enter"/]
  p2[["Kiểm BR-01, TaskCreate"]]
  ok(["SCR-02 Task card trên cột D"])

  s1 ==> u2 ==> u3 ==> p2 ==> ok

  u2 -->|"A1 · dán URL"| a1[["TaskFromUrl<br/>không đọc được trong 3 giây thì giữ URL"]]
  a1 --> u3
  u2 -->|"A5 · gõ #"| a5["SCR-09 Popover chọn channel<br/>chữ sau # là từ khoá"]
  a5 -->|"chọn channel"| a5b["Chip Channel = #tên<br/>xoá #... khỏi tiêu đề"]
  a5b --> u2
  u2 -->|"A4 · AI tắt, chưa đồng ý, không có Claude Code,<br/>tắt gợi ý, chậm > 2s, lỗi, hết hạn mức"| a4["Không gợi ý: thời lượng trống,<br/>channel mặc định BR-05"]
  a4 --> u3
  u3 -->|"A2 · đã xoá ngày"| a2[["TaskCreate vào Backlog BR-02"]]
  a2 --> a2m>"MSG-07 · Toast<br/>Đã thêm vào Backlog · Mở Backlog"]
  a2m -->|"bấm Mở Backlog"| a2x{{"→ G06 Backlog"}}
  s1 -->|"A3 · Esc khi đã gõ"| a3(["Ô soạn đóng, bản nháp giữ trên máy<br/>mở lại cùng ngày thấy nội dung cũ"])
  past(["Board · cột ngày đã qua đang chọn<br/>không có nút + Thêm task"]) -->|"A6 · nhấn A, IA-20"| a6["Board cuộn tới cột hôm nay"]
  a6 --> s1

  u3 -.->|"E1 · tiêu đề trống"| e1["Nút tạo disabled<br/>Enter không làm gì"]
  u3 -.->|"E2 · > 500 ký tự"| e2m>"MSG-01 · Inline<br/>Tên task tối đa 500 ký tự"]
  e2m -.-> s1
  p2 -.->|"E6 · D đã thành ngày qua khi gửi<br/>qua mốc đầu ngày lúc ô soạn đang mở, PAST_DATE"| e6m>"MSG-20 · Inline<br/>Không thể đặt task chưa xong vào ngày đã qua"]
  e6m -.-> fail(["Không tạo, nội dung còn trong ô soạn"])
  p2 -.->|"E3 · mất mạng"| e3["SCR-02 card có dấu chờ đồng bộ<br/>tooltip MSG-30, hàng đợi trên máy QC-08"]
  e3 -.->|"có mạng, gửi lại cùng idempotency key"| ok
  p2 -.->|"E4 · lỗi 5xx"| e4["SCR-02 card trạng thái lỗi"]
  e4 -.-> e4m>"MSG-10 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e4m -.->|"Thử lại"| p2

  class s1,u2,u3,p2 happy
  class a1,a5,a5b,a2,a2m,a3,past,a6 alt
  class a4 ai
  class a2x link
  class e1,e2m,e6m,e4,e4m err
  class e3 sync
  class ok done
  class fail fail
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

### Nhánh thay thế: ô thêm nhanh toàn cục (A7)

Màn: SCR-08 Ô thêm nhanh toàn cục (SRS G02, chốt 10/11/2026, O-19). Nguồn: UC-01 A7, US1.1 AC07, D11, IA-19.

```mermaid
flowchart TD
  start(["Bất kỳ đâu trên Windows<br/>app đang mở, ở nền hoặc ở khay"])
  u1[/"Nhấn Ctrl+Shift+A"/]
  d0{"Phím tắt đang bật?<br/>G01 BR-15"}
  s1["SCR-08 Ô thêm nhanh toàn cục<br/>cửa sổ nổi nhỏ, giữa màn hình đang dùng<br/>luôn ở trên, ngày = hôm nay"]
  u2[/"Gõ tiêu đề"/]
  u3[/"Enter"/]
  p1[["TaskCreate như bước 6"]]
  s2>"MSG-29 · Trong SCR-08, khoảng 1 giây<br/>Đã thêm vào Hôm nay"]
  ok(["Ô đóng, focus về app trước<br/>cửa sổ chính ở khay thì vẫn ở khay"])

  start ==> u1 ==> d0
  d0 ==>|"có"| s1 ==> u2 ==> u3 ==> p1 ==> s2 ==> ok
  d0 -->|"không"| off(["Không có gì xảy ra"])
  u2 -->|"Shift+Enter"| p2[["TaskCreate, giữ ô mở<br/>ô trống cho task kế tiếp"]]
  p2 --> u2
  s1 -->|"Click ra ngoài hoặc Esc"| a3(["Ô đóng, bản nháp giữ<br/>mở lại thấy nội dung cũ"])
  u3 -.->|"E1 · tiêu đề trống"| e1["Enter không làm gì"]
  u3 -.->|"E2 · > 500 ký tự"| e2m>"MSG-01 · Inline<br/>Tên task tối đa 500 ký tự"]
  p1 -.->|"E3 · mất mạng"| e3["Hàng đợi trên máy QC-08<br/>vẫn hiện MSG-29"]
  e3 -.-> ok
  p1 -.->|"E4 · lỗi 5xx"| e4m>"MSG-10 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]

  class start,u1,d0,s1,u2,u3,p1,s2 happy
  class p2,a3 alt
  class off alt
  class e1,e2m,e4m err
  class e3 sync
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
| A1 | Dán URL | Về luồng chính, tiêu đề = tiêu đề trang | – |
| A2 | Xoá ngày | Task trong Backlog | MSG-07 |
| A3 | Esc khi đã gõ | Ô soạn đóng, giữ nháp | – |
| A4 | Không có gợi ý AI | Về luồng chính, không chờ | – |
| A5 | Gõ "#" | SCR-09 → chip Channel được gán | – |
| A6 | Phím A trên cột đã qua | Ô soạn mở ở cột hôm nay (IA-20) | – |
| A7 | Ctrl+Shift+A toàn cục | SCR-08, task vào hôm nay (IA-19) | MSG-29 |
| E1 | Tiêu đề trống | Nút tạo disabled | – |
| E2 | > 500 ký tự | Chặn tạo | MSG-01 |
| E3 | Mất mạng | Card chờ đồng bộ → gửi lại | MSG-30 (tooltip) |
| E4 | Lỗi 5xx | Card lỗi, Thử lại | MSG-10 |
| E5 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E6 | Ngày D thành ngày đã qua khi gửi | Không tạo | MSG-20 |

---

## UC-02 Xem và sửa chi tiết task

**Mở đầu:** task card trên board (không ở Đã xoá). **Thành công:** trường đã sửa được lưu, card và tổng ngày cập nhật. **Thất bại:** trường giữ giá trị cũ, có lỗi tại trường.

### Happy case

```mermaid
flowchart TD
  start(["Board · task card"])
  u1[/"Bấm tiêu đề card<br/>hoặc Ctrl+Enter"/]
  p1[["TaskDetail"]]
  s1["SCR-03 Chi tiết task · dialog"]
  u2[/"Sửa một trường: tiêu đề, channel,<br/>priority, ngày, due, thời lượng, notes"/]
  p2[["Kiểm BR-01, BR-07<br/>TaskUpdate chỉ trường đã đổi"]]
  s2["SCR-03 trường mới<br/>card và tổng ngày cập nhật"]
  u3[/"Esc hoặc ×"/]
  ok(["Dialog đóng, focus về card"])

  start ==> u1 ==> p1 ==> s1 ==> u2 ==> p2 ==> s2 ==> u3 ==> ok
  s2 ==>|"sửa trường khác"| u2

  class start,u1,p1,s1,u2,p2,s2,u3 happy
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

### Nhánh thay thế: subtask, comment, nhật ký

```mermaid
flowchart TD
  s1["SCR-03 Chi tiết task"]

  s1 -->|"A1 · + Subtask hoặc V"| a1["Dòng subtask mới"]
  a1 -->|"Enter"| a1p[["SubtaskCreate<br/>mở dòng kế tiếp"]]
  a1p --> a1
  a1 -->|"Esc trên dòng trống"| s1
  a1p -.->|"E2 · subtask thứ 101"| e2m>"MSG-04 · Inline<br/>Mỗi task tối đa 100 subtask"]
  s1 -->|"A9 · task đã Hoàn thành"| a9["Subtask mới Chưa xong<br/>task giữ Hoàn thành BR-17 c"]
  s1 -->|"A2 · bấm dấu xong trên subtask"| a2[["SubtaskUpdate<br/>tooltip Hoàn thành lúc giờ"]]
  a2 -->|"A10 · subtask cuối cùng"| a10["Chỉ subtask xong<br/>task không tự hoàn thành BR-17 b"]
  s1 -->|"A3 · kéo thả hoặc Ctrl+lên/xuống"| a3["Đổi thứ tự subtask"]
  s1 -->|"A8 · icon xoá trên dòng subtask"| a8[["SubtaskDelete<br/>dòng ẩn ngay"]]
  a8 --> a8m>"MSG-21 · Toast ít nhất 5 giây<br/>Đã xoá subtask tiêu đề · Hoàn tác"]
  a8m -->|"Hoàn tác"| a8r[["SubtaskRestore undoToken<br/>về đúng vị trí, trạng thái, thời gian"]]
  a8r --> s1
  s1 -->|"A4 · gõ comment, Enter"| a4[["CommentCreate<br/>Shift+Enter xuống dòng"]]
  s1 -->|"A5 · cuộn cuối dialog"| a5["Nhật ký mới nhất trước<br/>20 dòng, Xem thêm"]

  class s1 happy
  class a1,a1p,a9,a2,a10,a3,a8,a8m,a8r,a4,a5 alt
  class e2m err
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

### Nhánh thay thế và lỗi: sửa trường

```mermaid
flowchart TD
  s1["SCR-03 Chi tiết task"]
  u2[/"Sửa một trường"/]
  p2[["Kiểm BR-01, BR-07<br/>TaskUpdate"]]
  s2["SCR-03 trường mới"]
  s1 ==> u2 ==> p2 ==> s2

  u2 -->|"A6 · due sớm hơn ngày dự định"| a6m>"MSG-06 · Inline dưới due<br/>Hạn chót sớm hơn ngày dự định"]
  a6m --> p2
  u2 -->|"A11 · đổi ngày dự định ở header"| a11[["Đường chọn ngày QC-05<br/>timebox dời theo, reset số ngày bị hoãn<br/>gửi kèm positionVersion"]]
  a11 --> d11{"Instance lặp vào ngày<br/>đã có instance cùng series?"}
  d11 -->|"không"| a11t>"G04 MSG-01 · Toast<br/>Đã chuyển tiêu đề sang thứ, ngày · Hoàn tác"]
  d11 -->|"có"| a11m>"G04 MSG-01 kèm MSG-24 · một toast<br/>dòng 2: Ngày này đã có tên series"]
  a11t --> s2
  a11m --> s2
  u2 -->|"A12 · đổi channel"| a12[["TaskUpdate channelId<br/>lịch làm việc theo channel mới từ hôm nay"]]
  a12 --> a12x{{"→ G04 tính lại projection, sức chứa"}}
  a12 --> s2
  s1 -->|"A7 · thiết bị khác sửa task"| a7["Trường nhận giá trị mới qua realtime"]
  a7 -->|"trường đang gõ dở, khi rời trường"| a7m>"MSG-12 · Inline<br/>Task vừa được cập nhật trên thiết bị khác"]

  u2 -.->|"E1 · vi phạm BR-01"| e1m>"MSG-01 / MSG-02 / MSG-03 · Inline<br/>lỗi tại trường, không gửi"]
  u2 -.->|"E7 · ngày đã qua"| e7["Date picker không cho chọn<br/>server PAST_DATE thì MSG-20"]
  p2 -.->|"E4 · TaskUpdate lỗi"| e4["Trường về giá trị cũ"]
  e4 -.-> e4m>"MSG-10 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  p2 -.->|"E5 · task đã bị xoá, 409 TASK_DELETED"| e5m>"MSG-22 · Toast<br/>Task này đã bị xoá trên thiết bị khác.<br/>Thay đổi chưa được lưu"]
  a11 -.->|"E6 · 412 VERSION_CONFLICT"| e6["Tải lại task, ngày về giá trị server"]
  e6 -.-> e6m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  s1 -.->|"E3 · task bị xoá ở thiết bị khác khi đang mở"| e3(["SCR-03 đóng"])
  e3 -.-> e3m>"MSG-38 · Toast<br/>Task này đã bị xoá trên thiết bị khác · Hoàn tác"]
  p2 -.->|"E8 · mất mạng"| e8["Giá trị mới hiện ngay, hàng đợi QC-08<br/>header SCR-03 và card có dấu chờ đồng bộ MSG-30"]
  e8 -.->|"có mạng, gửi thành công"| s2

  class s1,u2,p2,s2 happy
  class a11,d11,a11t,a12,a7 alt
  class a6m,a11m,a7m warn
  class e8 sync
  class a12x link
  class e1m,e7,e4,e4m,e5m,e6,e6m,e3m err
  class e3 fail
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
| A1 | Thêm subtask | Dòng subtask mới, lặp tới Esc | – |
| A2 | Tích xong subtask | Subtask xong, tooltip giờ | – |
| A3 | Đổi thứ tự subtask | Thứ tự mới | – |
| A4 | Thêm comment | Comment mới | – |
| A5 | Xem nhật ký | 20 dòng, Xem thêm | – |
| A6 | Due < ngày dự định | Lưu, cảnh báo | MSG-06 |
| A7 | Thiết bị khác sửa | Trường cập nhật | MSG-12 (khi đang gõ dở) |
| A8 | Xoá subtask | Dòng ẩn, Hoàn tác được | MSG-21 |
| A9 | Thêm subtask vào task đã xong | Task giữ Hoàn thành | – |
| A10 | Tích subtask cuối | Task không tự xong | – |
| A11 | Đổi ngày dự định | Ngày mới, Hoàn tác được (O-13) | G04 MSG-01; kèm MSG-24 ở dòng 2 khi instance trùng series |
| A12 | Đổi channel | Channel mới → [G04](g04-board-ngay.md) tính lại | – |
| E1 | Vi phạm BR-01 | Không gửi | MSG-01 / 02 / 03 |
| E2 | Subtask thứ 101 | Chặn | MSG-04 |
| E3 | Task bị xoá khi đang mở | Dialog đóng, Hoàn tác được | MSG-38 (O-01) |
| E4 | TaskUpdate lỗi | Giá trị cũ | MSG-10 |
| E5 | Sửa task đã xoá | Bỏ lệnh | MSG-22 |
| E6 | VERSION_CONFLICT khi đổi ngày | Ngày theo server | MSG-23 |
| E7 | Đổi sang ngày đã qua | Không chọn được | MSG-20 |
| E8 | Mất mạng khi sửa | Hàng đợi, chờ đồng bộ → gửi lại (O-15) | MSG-30 (tooltip) |

---

## UC-03 Hoàn thành / bỏ hoàn thành task

**Mở đầu:** task Kế hoạch hoặc Backlog trên card / SCR-03. **Thành công:** task Hoàn thành, thanh tiến độ ngày tăng. **Thất bại:** trạng thái không đổi.

### Happy case

```mermaid
flowchart TD
  start(["Task card hoặc SCR-03<br/>task Kế hoạch / Backlog"])
  u1[/"Bấm dấu xong<br/>hoặc phím C"/]
  p1[["TaskComplete kèm positionVersion<br/>áp BR-08 a-f"]]
  s1["SCR-02 card Hoàn thành<br/>task thường sang cột hôm nay<br/>hiện actual / planned"]
  m1>"MSG-08 · Toast<br/>Đã hoàn thành tiêu đề · Hoàn tác"]
  ok(["Task Hoàn thành<br/>thanh tiến độ ngày cập nhật"])

  start ==> u1 ==> p1 ==> s1 ==> m1 ==> ok

  class start,u1,p1,s1,m1 happy
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
  u1[/"Bấm dấu xong hoặc C"/]
  p1[["TaskComplete, BR-08"]]
  s1["SCR-02 card Hoàn thành"]
  m1>"MSG-08 · Toast · Hoàn tác"]
  u1 ==> p1 ==> s1 ==> m1

  u1 -->|"A1 · task đã xong"| a1[["TaskUncomplete, BR-09"]]
  a1 --> a1m>"MSG-37 · Toast<br/>Đã bỏ đánh dấu xong tiêu đề · Hoàn tác"]
  a1 --> d1{"Cùng ngày làm việc<br/>với completedAt?"}
  d1 -->|"có"| a2r["Về như trước khi hoàn thành:<br/>ngày / bucket, subtask, plannedAsActual"]
  d1 -->|"không"| a1r["Chỉ xoá completedAt<br/>task Kế hoạch hôm nay"]
  m1 -->|"A2 · bấm Hoàn tác"| a2[["TaskUncomplete<br/>nhánh cùng ngày BR-09"]]
  a2 --> a2r
  p1 -->|"A3 · timer đang chạy ở thiết bị khác"| a3[["Server dừng timer<br/>timer.changed tới mọi thiết bị"]]
  a3 --> s1
  p1 -->|"A4 · instance lặp ngày tương lai"| a4["Giữ ngày dự định<br/>instance xong ở cột ngày đó"]
  p1 -->|"A5 · 00:00 tới mốc đầu ngày"| a5["Ngày hoàn thành = ngày làm việc hôm trước<br/>không nhảy cột QC-01"]
  p1 -->|"A6 · bật planned là actual,<br/>không có bản ghi thời gian"| a6["plannedAsActual = true<br/>card actual = planned"]
  a4 --> m1
  a5 --> m1
  a6 --> m1
  start7(["Trợ lý AI qua MCP local<br/>trợ lý bật, đã đồng ý BR-21 a"]) -->|"A7"| a7["Như bước 2-3, tác nhân ai<br/>chip AI, Hoàn tác"]
  a7 --> a7x{{"→ G10 receipt và Hoàn tác"}}

  p1 -.->|"E1 · mất mạng"| e1["Áp ngay trên máy, hàng đợi"]
  e1 -.->|"gửi lên, cụm vị trí đã đổi, 412"| e1m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e1 -.->|"gửi lên thành công"| s1
  p1 -.->|"E2 · TaskComplete lỗi"| e2["Card về trạng thái cũ"]
  e2 -.-> e2m>"MSG-10 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  p1 -.->|"E3 · 409 TASK_DELETED"| e3m>"MSG-22 · Toast<br/>Task này đã bị xoá trên thiết bị khác.<br/>Thay đổi chưa được lưu"]

  class u1,p1,s1,m1 happy
  class a1,a1m,d1,a1r,a2,a2r,a3,a4,a5,a6 alt
  class start7,a7 ai
  class a7x link
  class e1 sync
  class e1m,e2,e2m,e3m err
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
| A1 | Bấm dấu xong trên task đã xong | Kế hoạch (cùng ngày: về như cũ; khác ngày: hôm nay); Hoàn tác được (O-10) | MSG-37 (+ MSG-24 dòng 2 khi instance trùng series, O-08) |
| A2 | Hoàn tác trong toast | Về như trước khi hoàn thành | – |
| A3 | Timer chạy ở thiết bị khác | Timer dừng, task xong | MSG-08 |
| A4 | Instance lặp ngày tương lai | Xong ở cột ngày đó | MSG-08 |
| A5 | Hoàn thành trước mốc đầu ngày | Ngày hoàn thành = hôm trước | MSG-08 |
| A6 | Planned là actual | actual = planned | MSG-08 |
| A7 | AI hoàn thành (không cần công tắc, F4) | Xong (tác nhân ai) → [G10](g10-tro-ly-ai.md) | – |
| A7 (phần task có liên kết tích hợp) | 403 `LINKED_TASK` | Bỏ (1.1) | – |
| E1 | Mất mạng | Hàng đợi; xung đột → trạng thái server | MSG-23 |
| E2 | TaskComplete lỗi | Trạng thái cũ | MSG-10 |
| E3 | Task đã bị xoá | – | MSG-22 |

---

## UC-04 Xoá, hoàn tác và khôi phục task

**Mở đầu:** task không ở Đã xoá (xoá) hoặc ở Thùng rác (khôi phục). **Thành công:** task biến khỏi board và lịch; hoặc về trạng thái trước khi xoá. **Thất bại:** trạng thái không đổi.

### Happy case

```mermaid
flowchart TD
  start(["Task card hoặc SCR-03"])
  u1[/"Menu ... chọn Xoá<br/>hoặc Ctrl+Backspace"/]
  s0["SCR-04 Menu Khác"]
  p1[["Dừng timer nếu đang chạy BR-11<br/>TaskDelete, ẩn task ngay"]]
  m1>"MSG-09 · Toast ít nhất 5 giây<br/>Đã xoá · Hoàn tác (Ctrl+Z)"]
  ok(["Task biến khỏi board và lịch<br/>nằm trong Thùng rác 30 ngày"])
  u2[/"Tuỳ chọn: Hoàn tác hoặc Ctrl+Z"/]
  p2[["TaskRestore undo=true<br/>về vị trí cũ, khôi phục liên kết timebox,<br/>sự kiện ngoài đã bị xoá thì tạo lại QC-05"]]
  ok2(["Task về đúng chỗ cũ"])

  start ==> s0 ==> u1 ==> p1 ==> m1 ==> ok
  m1 ==> u2 ==> p2 ==> ok2

  class start,s0,u1,p1,m1,u2,p2 happy
  class ok,ok2 done
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
  u1[/"Xoá"/]
  p1[["TaskDelete"]]
  m1>"MSG-09 · Toast · Hoàn tác"]
  ok(["Task trong Thùng rác"])
  u1 ==> p1 ==> m1 ==> ok

  p1 -->|"A2 · task có timebox"| a2["Timebox thường: tương lai gỡ, sự kiện ngoài bị xoá<br/>quá khứ chỉ gỡ liên kết QC-05"]
  a2 --> m1
  p1 -->|"A2 · timebox liên kết sự kiện"| a2l["Chỉ gỡ liên kết, sự kiện ngoài giữ nguyên<br/>QC-05 ngoại lệ, G05 BR-21 f"]
  a2l --> m1
  p1 -->|"A4 · instance lặp"| a4["Ngày gốc vào danh sách ngày ngoại lệ<br/>G03 BR-15, hoàn tác không gỡ"]
  a4 --> m1
  ai0(["Trợ lý AI qua MCP local<br/>trợ lý bật, đã đồng ý BR-21 a"]) -->|"A7"| p1
  ai1(["Khung chat G10 · Hoàn tác<br/>task do AI tạo"]) -->|"A3"| ok

  ok -->|"A1 · toast đã tắt"| a1["SCR-05 Thùng rác<br/>panel Lưu trữ · Thùng rác, tab Thùng rác"]
  a1 -->|"Khôi phục"| a1p[["TaskRestore, BR-12"]]
  a1p --> a6["A6 · về trạng thái trước khi xoá:<br/>Kế hoạch / Hoàn thành / Lưu trữ / Backlog bucket<br/>timebox không tạo lại A2"]
  a6 --> a1m>"MSG-13 · Toast<br/>Đã khôi phục tiêu đề về nơi đến"]
  a1p -->|"A5 · instance vào ngày đã có<br/>instance cùng series"| a5m>"MSG-13 kèm MSG-24 · Toast<br/>Ngày này đã có tên series"]

  a1p -.->|"E1 · quá 30 ngày"| e1m>"MSG-14 · Toast<br/>Task này đã bị xoá vĩnh viễn"]
  e1m -.-> e1(["Gỡ khỏi danh sách"])
  p1 -.->|"E3 · TaskDelete / TaskRestore lỗi"| e3m>"MSG-10 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  a1p -.->|"E3"| e3m
  p1 -.->|"E4 · lệnh offline, 412 VERSION_CONFLICT"| e4m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e3m -.-> e3(["Trạng thái trước đó"])
  e4m -.-> e3
  p1 -.->|"E5 · mất mạng"| e5["Xoá chạy trên máy, hàng đợi QC-08<br/>toast như luồng chính"]
  e5 -.-> m1
  a1 -.->|"E5 · mất mạng"| e5r["SCR-05 nút Khôi phục mờ<br/>tooltip MSG-31 Cần có mạng để khôi phục"]

  class u1,p1,m1 happy
  class a2,a4,a1,a1p,a6,a1m,ai1 alt
  class a2l warn
  class ai0 ai
  class a5m warn
  class e1m,e3m,e4m,e5r err
  class e5 sync
  class ok done
  class e1,e3 fail
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
| A1 | Khôi phục khi toast đã tắt | SCR-05 → trạng thái trước khi xoá | MSG-13 |
| A2 | Task có timebox | Xoá theo QC-05; timebox liên kết sự kiện chỉ gỡ liên kết, không xoá sự kiện; khôi phục không tạo lại timebox | MSG-09 |
| A3 | Hoàn tác task AI tạo trong chat | Thùng rác | – |
| A4 | Xoá instance lặp | Thêm ngày ngoại lệ | MSG-09 |
| A5 | Khôi phục instance trùng series | Vẫn khôi phục | MSG-13 + MSG-24 |
| A6 | Khôi phục task Hoàn thành / Lưu trữ / Backlog | Về đúng trạng thái cũ | MSG-13 |
| A7 | AI xoá (không cần công tắc, F4) | Như xoá thường, vào Thùng rác | – |
| A7 (phần task có liên kết tích hợp) | 403 `LINKED_TASK` | Bỏ (1.1) | – |
| E1 | Quá 30 ngày | Gỡ khỏi danh sách | MSG-14 |
| E2 | (SRS đã bỏ) | – | – |
| E3 | Lỗi xoá / khôi phục | Trạng thái trước | MSG-10 |
| E4 | VERSION_CONFLICT | Trạng thái server | MSG-23 |
| E5 | Mất mạng | Xoá: hàng đợi, như luồng chính; khôi phục: nút mờ (O-15) | MSG-09; MSG-31 (tooltip) |

---

## UC-05 Nhân bản task

**Mở đầu:** task không ở Đã xoá. **Thành công:** bản sao trong danh sách hôm nay, SCR-03 mở bản sao. **Thất bại:** không có task mới.

### Happy case

```mermaid
flowchart TD
  start(["Task card hoặc SCR-03"])
  u1[/"Menu ... chọn Nhân bản<br/>hoặc Ctrl+D"/]
  p1[["TaskDuplicate, BR-10"]]
  s1["SCR-03 của bản sao<br/>nhật ký: nhân bản từ tiêu đề"]
  ok(["Bản sao ở hôm nay<br/>đầu hoặc cuối theo cài đặt BR-03"])

  start ==> u1 ==> p1 ==> s1 ==> ok

  class start,u1,p1,s1 happy
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
  u1[/"Nhân bản"/]
  p1[["TaskDuplicate"]]
  s1["SCR-03 của bản sao"]
  u1 ==> p1 ==> s1

  p1 -->|"A1 · instance lặp"| a1["Bản sao là task thường<br/>không thuộc series, không icon lặp"]
  p1 -->|"A2 · task đã xong"| a2["Bản sao Kế hoạch hôm nay<br/>không có subtask"]
  a1 --> s1
  a2 --> s1
  p1 -.->|"E1 · lỗi"| e1m>"MSG-10 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e1m -.-> fail(["Không mở bản sao"])
  p1 -.->|"E2 · mất mạng"| e2["Bản sao tạo trên máy, idempotency key<br/>SCR-03 bản sao có dấu chờ đồng bộ MSG-30"]
  e2 -.->|"có mạng, gửi lại cùng key"| s1

  class u1,p1,s1 happy
  class a1,a2 alt
  class e1m err
  class e2 sync
  class fail fail
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
| A1 | Nhân bản instance lặp | Task thường | – |
| A2 | Nhân bản task đã xong | Kế hoạch hôm nay, không subtask | – |
| E1 | Lỗi | Không mở bản sao | MSG-10 |
| E2 | Mất mạng | Bản sao trên máy, chờ đồng bộ → gửi lại (O-15) | MSG-30 (tooltip) |

---

## UC-06 Quản lý context và channel

**Mở đầu:** Cài đặt → Context & channel, hoặc "Quản lý channel" trong bộ lọc. **Thành công:** context / channel được tạo, sửa, ẩn, xoá; khung giờ channel lưu và có hiệu lực từ ngày làm việc kế tiếp. **Thất bại:** không thay đổi.

### Happy case

```mermaid
flowchart TD
  start(["Cài đặt → Context & channel<br/>hoặc Quản lý channel trong bộ lọc"])
  s1["SCR-06 Context & channel"]
  u1[/"Tạo context hoặc<br/>Tạo channel trong context"/]
  u2[/"Nhập tên, chọn màu,<br/>bật / tắt riêng tư"/]
  p1[["Kiểm BR-14, ChannelCreate"]]
  ok(["Channel hiện ngay trong<br/>ô soạn và bộ lọc"])

  start ==> s1 ==> u1 ==> u2 ==> p1 ==> ok

  class start,s1,u1,u2,p1 happy
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

### Nhánh thay thế: sửa, ẩn, xoá

```mermaid
flowchart TD
  s1["SCR-06 Context & channel"]
  u2[/"Nhập tên"/]
  p1[["ChannelCreate"]]
  s1 ==> u2 ==> p1

  s1 -->|"A1 · đổi tên / màu / riêng tư"| a1[["ChannelUpdate tại dòng channel"]]
  s1 -->|"A2 · tắt Bật"| a2["Channel ẩn khỏi ô soạn và bộ lọc<br/>task và khung giờ giữ nguyên"]
  s1 -->|"A3 · xoá channel"| a3["SCR-07 chọn channel nhận task"]
  a3 -->|"Xác nhận"| a3p[["ChannelDelete moveTasksTo<br/>chuyển mọi task, kể cả Lưu trữ, Đã xoá, mẫu series"]]
  a3p --> a3m>"MSG-19 · Toast<br/>Đã xoá channel tên, n task chuyển sang channel nhận"]
  s1 -->|"A4 · xoá context còn channel"| a4m>"MSG-16 · Inline<br/>Hãy chuyển hoặc xoá các channel trong context trước"]
  s1 -.->|"E3 · channel Chưa phân loại"| e3["Nút xoá ẩn"]

  u2 -.->|"E1 · tên trùng trong context"| e1m>"MSG-15 · Inline<br/>Channel này đã tồn tại trong context"]
  u2 -.->|"E2 · có # hoặc > 50 ký tự"| e2m>"MSG-17 · Inline<br/>Tên channel 1-50 ký tự, không chứa #"]
  a1 -.->|"E1 / E2"| e1m

  class s1,u2,p1 happy
  class a1,a2,a3,a3p,a3m alt
  class a4m,e1m,e2m,e3 err
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

### Nhánh thay thế và lỗi: khung giờ channel

```mermaid
flowchart TD
  s1["SCR-06 dòng channel"]
  s1 -->|"A5 · bật Khung giờ riêng"| a5["SCR-06 #7-#10 · 7 dòng Thứ Hai - Chủ Nhật<br/>điền sẵn theo lịch chung"]
  s1 -->|"A6 · sửa khung đã bật"| a5
  a5 --> u1[/"Bật / tắt từng ngày, chọn giờ<br/>bước 15 phút, bấm Lưu"/]
  u1 --> p1[["Kiểm BR-22, ChannelUpdate workWindow"]]
  p1 --> m1>"MSG-27 · Inline dưới phần Khung giờ<br/>Áp dụng từ ngày làm việc kế tiếp (ngày)"]
  m1 --> ok(["Khung mới hiệu lực từ ngày làm việc kế tiếp<br/>hôm nay vẫn dùng khung cũ BR-24"])
  s1 -->|"A7 · tắt Khung giờ riêng"| a7[["ChannelUpdate workWindow = null"]]
  a7 --> m1
  g01(["G01 · lịch làm việc chung đổi"]) -->|"A8"| a8["Channel không có khung riêng theo lịch chung mới<br/>channel có khung riêng không đổi"]
  s1 -->|"A9 · thiết bị khác sửa khung giờ"| a9["Nhận qua realtime, gộp cả khối workWindow"]
  a9 -->|"đang sửa dở, khi rời phần Khung giờ"| a9m>"MSG-28 · Inline dưới phần Khung giờ<br/>Khung giờ của channel này vừa được sửa trên thiết bị khác"]

  u1 -.->|"E4 · giờ kết thúc không sau giờ bắt đầu"| e4m>"MSG-25 · Inline tại dòng<br/>Giờ kết thúc phải sau giờ bắt đầu<br/>nút Lưu disabled"]
  u1 -.->|"E5 · không bật ngày nào"| e5m>"MSG-26 · Inline<br/>Chọn ít nhất 1 ngày cho khung giờ của channel<br/>nút Lưu disabled"]
  p1 -.->|"E6 · mất mạng"| e6["Hàng đợi trên máy<br/>dòng channel có dấu chờ đồng bộ MSG-30"]
  e6 -.->|"có mạng; hiệu lực tính theo lúc server nhận"| m1
  api(["Gọi API trực tiếp cho Chưa phân loại"]) -.->|"E7"| e7(["VALIDATION_FAILED SYSTEM_CHANNEL<br/>không lưu; UI không có phần Khung giờ"])

  class s1 happy
  class a5,u1,p1,m1,a7,g01,a8,a9 alt
  class a9m warn
  class e4m,e5m err
  class e6 sync
  class ok done
  class api,e7 fail
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
| A1 | Đổi tên / màu / riêng tư | Channel cập nhật | – |
| A2 | Ẩn channel | Ẩn khỏi ô soạn, bộ lọc | – |
| A3 | Xoá channel | SCR-07 → task chuyển sang channel nhận | MSG-19 |
| A4 | Xoá context còn channel | Chặn | MSG-16 |
| A5 | Bật khung giờ riêng | Hiệu lực ngày làm việc kế tiếp | MSG-27 |
| A6 | Sửa khung đã bật | Khung chờ, hiệu lực ngày kế tiếp | MSG-27 |
| A7 | Tắt khung giờ riêng | Theo lịch chung từ ngày kế tiếp | MSG-27 |
| A8 | Lịch chung G01 đổi | Chỉ channel không có khung riêng đổi | – |
| A9 | Thiết bị khác sửa khung giờ | Gộp cả khối | MSG-28 |
| E1 | Tên trùng | Chặn | MSG-15 |
| E2 | Tên có "#" / > 50 ký tự | Chặn | MSG-17 |
| E3 | Xoá "Chưa phân loại" | Nút xoá ẩn | – |
| E4 | Giờ kết thúc ≤ bắt đầu | Lưu disabled | MSG-25 |
| E5 | Không ngày nào bật | Lưu disabled | MSG-26 |
| E6 | Mất mạng khi lưu | Hàng đợi, chờ đồng bộ | MSG-30 (tooltip) |
| E7 | API đặt khung cho "Chưa phân loại" | Không lưu | – |

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-06 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)" / "SRS đã bỏ".
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG.

**Ghi chú cho brief G02 đầy đủ (#11)**
- ~~MSG-12 dùng chữ "Task vừa được cập nhật…" cho khung giờ channel (UC-06 A9).~~ **Đã sửa 09/11/2026 (C01):** thêm MSG-28 "Khung giờ của channel này vừa được sửa trên thiết bị khác"; UC-06 A9 thôi dùng MSG-12.
- **Đã sửa 09/11/2026 (A1):** MSG-10 "Chưa lưu được thay đổi. Thử lại" là câu lỗi lưu chung QC-MSG-01 (QC-13 mục 1); G02 chỉ trỏ về, chữ không đổi.
- **Đã sửa 10/11/2026 (brief G02 duyệt, O-01 … O-20):** ô thêm nhanh toàn cục là SCR-08, popover chọn channel là SCR-09; "Đã thêm vào Hôm nay" là MSG-29, "Chờ đồng bộ" MSG-30; UC-02 E3 dùng MSG-38 thay MSG-09 (O-01); UC-02 A11 có toast G04 MSG-01 có Hoàn tác (O-13); UC-03 A1 có toast MSG-37 (O-10); thêm nhánh mất mạng UC-02 E8, UC-04 E5, UC-05 E2 (O-15).
