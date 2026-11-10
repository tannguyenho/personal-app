# Flow G07 Focus và theo dõi thời gian

> **Nguồn:** [srs-g07](../../features/srs-g07-focus-timer.md) (commit `8fac830`, cập nhật theo chốt 09/11/2026) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-bật-timer) | Bật timer | SCR-01 Điều khiển timer | 5 / 3 |
| [UC-02](#uc-02-dừng-timer) | Dừng timer | SCR-01 | 4 / 3 |
| [UC-03](#uc-03-nhập-sửa-xoá-thời-gian-thực-tế) | Nhập, sửa, xoá thời gian thực tế | SCR-02 Thời gian thực tế | 6 / 4 |
| [UC-04](#uc-04-focus-mode-và-âm-báo) | Focus mode và âm báo | SCR-03 Focus mode | 4 / 2 |
| UC-05 | Pomodoro và nghỉ | SCR-04, SCR-05 | Bỏ (1.1) |
| [UC-06](#uc-06-giám-sát-timer-chạy-lâu-job-timerwatchdog) | Giám sát timer chạy lâu (hệ thống) | SCR-06 Xác nhận giờ dừng | 6 / 2 |
| [UC-07](#uc-07-đồng-bộ-timer-nhiều-thiết-bị-và-offline) | Đồng bộ timer nhiều thiết bị và offline (hệ thống) | SCR-01 | 6 / 2 |
| UC-08 | Focus Bar | SCR-07 | Bỏ (1.2) |

---

## UC-01 Bật timer

**Mở đầu:** task cha thoả BR-02 (không ở `DA_XOA`, `LUU_TRU`) trên card hoặc trong chi tiết task. **Thành công:** timer `DANG_CHAY` trên task, timer cũ (nếu có) đã đóng, mọi thiết bị nhận `timer.changed`. **Thất bại:** timer giữ như trước.

### Happy case

```mermaid
flowchart TD
  start(["Task cha trên card hoặc chi tiết task"])
  u1[/"Bấm nút Bắt đầu timer trên card khi hover / chi tiết<br/>hoặc Space khi task đang chọn"/]
  s1["SCR-01 đồng hồ chạy ngay, lạc quan<br/>thực tế đếm giây màu xanh"]
  p1[["TimerStart taskId, clientOpId<br/>server áp BR-01 trong một giao dịch"]]
  p2[["Phát timer.changed"]]
  s2["SCR-01 nút Dừng timer · Space<br/>badge ở mục Focus trên sidebar"]
  d1{"Có timer cũ ở task khác?"}
  m1>"MSG-02 · Toast<br/>Đã dừng timer #quot;{task cũ}#quot; và bắt đầu #quot;{task mới}#quot;"]
  ok(["Timer DANG_CHAY trên task"])

  start ==> u1 ==> s1 ==> p1 ==> p2 ==> s2 ==> d1
  d1 ==>|"có"| m1 ==> ok
  d1 ==>|"không"| ok

  class start,u1,s1,p1,p2,s2,d1,m1 happy
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
  u1[/"Bắt đầu timer / Space"/]
  p1[["TimerStart"]]
  s2["SCR-01 timer đang chạy"]
  ok(["Timer DANG_CHAY"])
  u1 ==> p1 ==> s2 ==> ok

  p1 -->|"A1 · task không thuộc hôm nay / backlog"| a1m>"MSG-01 · Toast<br/>Task này không thuộc hôm nay, timer vẫn đang chạy"]
  a1m --> s2
  s2 -->|"A2 · bật Vào Focus khi chạy timer"| a2x{{"→ UC-04 · SCR-03 Focus mode"}}
  win(["Bất kỳ đâu trên Windows<br/>app ở khay hoặc nền, chưa có timer"]) -->|"A4 · Ctrl+Shift+Space toàn cục"| a4[["Chọn task gần nhất đã chạy<br/>hoặc task đầu tiên chưa xong của hôm nay"]]
  a4 --> p1
  win -->|"A6 · menu khay Bật timer: {task kế tiếp hôm nay}"| a6[["Task chưa xong đầu tiên của hôm nay<br/>BR-23, B23"]]
  a6 --> p1
  u1 -->|"A5 · có bản ghi TU_DONG đang chờ"| a5x{{"→ UC-06 · SCR-06 Xác nhận giờ dừng"}}
  a5x -->|"xác nhận xong, rồi mới bật"| p1

  p1 -.->|"E1 · mất mạng"| e1["Chạy trên máy, startedAt giờ máy<br/>xếp hàng đợi"]
  e1 -.-> e1x{{"→ UC-07 đồng bộ"}}
  p1 -.->|"E2 · task đã bị xoá / lưu trữ, 404 / 409"| e2["Huỷ đồng hồ"]
  e2 -.-> e2m>"MSG-24 · Toast<br/>Không bật được timer vì task đã bị xoá hoặc đã lưu trữ"]
  e2m -.-> fail(["Timer giữ như trước"])
  p1 -.->|"E4 · 5xx / timeout sau retry"| e4["Huỷ đồng hồ"]
  e4 -.-> e4m>"MSG-09 · Toast<br/>Chưa lưu được thời gian. Thử lại"]
  e4m -.-> fail

  class u1,p1,s2 happy
  class win,a4,a6 alt
  class a1m warn
  class a2x,a5x,e1x link
  class e1 sync
  class e2,e2m,e4,e4m err
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

### Đối chiếu

| Mã | Điều kiện | Kết thúc ở | Thông báo |
|---|---|---|---|
| A1 | Task không thuộc hôm nay / backlog | Vẫn chạy, không đổi ngày task | MSG-01 |
| A2 | Bật "Vào Focus khi chạy timer" | SCR-03 → [UC-04](#uc-04-focus-mode-và-âm-báo) | – |
| A3 | (SRS đã bỏ) | – | – |
| A4 | Ctrl+Shift+Space toàn cục, chưa có timer | Timer task gần nhất / task đầu tiên chưa xong hôm nay; đang có timer thì phím này dừng → [UC-02](#uc-02-dừng-timer) (C25) | – |
| A6 | Menu khay "Bật timer: {task kế tiếp hôm nay}" (B23) | Timer task chưa xong đầu tiên của hôm nay | – |
| A5 | Có bản ghi `TU_DONG` chờ | SCR-06 trước → [UC-06](#uc-06-giám-sát-timer-chạy-lâu-job-timerwatchdog), rồi bật | MSG-20 |
| E1 | Mất mạng | Chạy trên máy, hàng đợi → [UC-07](#uc-07-đồng-bộ-timer-nhiều-thiết-bị-và-offline) | – |
| E2 | Task đã xoá / lưu trữ | Huỷ đồng hồ | MSG-24 (C28) |
| E3 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E4 | 5xx / timeout sau retry | Huỷ đồng hồ | MSG-09 |

---

## UC-02 Dừng timer

**Mở đầu:** timer `DANG_CHAY` hoặc `CHAY_LAU`; dừng từ card, chi tiết, Focus, hoặc Ctrl+Shift+Space và menu khay (C25). **Thành công:** bản ghi thời gian đóng (BR-04), thực tế cộng dồn, block thực tế hiện trên lịch (G05). **Thất bại:** timer vẫn chạy.

### Happy case

```mermaid
flowchart TD
  start(["Timer DANG_CHAY / CHAY_LAU"])
  u1[/"Space hoặc nút dừng trên card, chi tiết task, Focus mode<br/>hoặc Ctrl+Shift+Space, menu khay Dừng timer C25"/]
  s1["SCR-01 đồng hồ dừng ngay"]
  p1[["TimerStop<br/>server đặt endedAt BR-04"]]
  d1{"Lượt chạy < 10 giây?"}
  p2[["Bỏ bản ghi, không báo BR-04, B26"]]
  p3[["Tính lại thực tế<br/>phát timer.changed, task.upserted"]]
  s2["SCR-01 thực tế H:MM<br/>G05 vẽ block thực tế trên lịch"]
  ok(["Bản ghi đóng, thực tế cộng dồn"])

  start ==> u1 ==> s1 ==> p1 ==> d1
  d1 ==>|"có"| p2 ==> p3
  d1 ==>|"không"| p3
  p3 ==> s2 ==> ok

  class start,u1,s1,p1,d1,p2,p3,s2 happy
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
  u1[/"Space / nút dừng / Ctrl+Shift+Space / menu khay"/]
  p1[["TimerStop"]]
  s2["SCR-01 thực tế H:MM"]
  ok(["Bản ghi đóng"])
  u1 ==> p1 ==> s2 ==> ok

  g02{{"→ G02 · UC-03 / UC-04<br/>hoàn thành / xoá task đang chạy"}} -->|"A1"| a1[["Server dừng timer trước<br/>trong cùng giao dịch BR-06"]]
  a1 --> s2
  dev(["Thiết bị này đang hiện timer chạy"]) -->|"A3 · dừng ở thiết bị khác"| a3["Nhận timer.changed, dừng đồng hồ"]
  a3 --> a3m>"MSG-07 · Toast<br/>Timer đã được dừng trên thiết bị khác"]
  dev -->|"A4 · task đang chạy bị dời ngày: D, kéo, rollover,<br/>backlog, shutdown Ngày mai, AI"| a4(["Không dừng timer BR-06<br/>đồng hồ chạy tiếp"])
  p1 -->|"A6 · lượt chạy vắt qua mốc đầu ngày"| a6["Bản ghi thuộc workday(startedAt)<br/>không chia BR-20"]
  a6 --> s2

  p1 -.->|"E1 · mất mạng"| e1["endedAt giờ máy vào hàng đợi<br/>gửi TimerStop endedAt khi có mạng"]
  e1 -.-> e1x{{"→ UC-07 đồng bộ"}}
  p1 -.->|"E2 · 409 TIMER_NOT_RUNNING"| e2[["Tải lại TimerGet"]]
  e2 -.-> e2m>"MSG-07 · Toast<br/>Timer đã được dừng trên thiết bị khác"]
  p1 -.->|"E3 · 5xx / timeout"| e3["Giữ trạng thái dừng trên máy<br/>hàng đợi, thử lại"]
  e3 -.->|"thử lại"| p1
  e3 -.->|"quá 3 lần"| e3m>"MSG-09 · Toast<br/>Chưa lưu được thời gian. Thử lại"]

  class u1,p1,s2 happy
  class dev,a1,a3,a3m,a4,a6 alt
  class g02,e1x link
  class e1,e3 sync
  class e2,e2m,e3m err
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
| A1 | Hoàn thành / xoá task đang chạy | Timer dừng trước, rồi [G02 UC-03](g02-quan-ly-task.md#uc-03-hoàn-thành--bỏ-hoàn-thành-task) / [UC-04](g02-quan-ly-task.md#uc-04-xoá-hoàn-tác-và-khôi-phục-task) xử lý | Theo G02 |
| A2 | Vào nghỉ / hết phiên Pomodoro | Bỏ (1.1) | – |
| A3 | Dừng ở thiết bị khác | Đồng hồ dừng | MSG-07 |
| A4 | Task đang chạy bị dời ngày | Timer chạy tiếp | – |
| A5 | Workspace vào chỉ đọc | Bỏ (1.1) | – |
| A6 | Vắt qua mốc đầu ngày | Bản ghi thuộc ngày bắt đầu | – |
| E1 | Mất mạng | Hàng đợi → [UC-07](#uc-07-đồng-bộ-timer-nhiều-thiết-bị-và-offline) | – |
| E2 | `TIMER_NOT_RUNNING` | Tải lại timer | MSG-07 |
| E3 | 5xx / timeout | Dừng trên máy, thử lại; quá 3 lần báo lỗi | MSG-09 |

---

## UC-03 Nhập, sửa, xoá thời gian thực tế

**Mở đầu:** task không ở `DA_XOA`. **Thành công:** bản ghi được thêm / sửa / xoá, thực tế tính lại, nhật ký ghi (BR-18). **Thất bại:** bản ghi không đổi, lỗi tại ô.

### Happy case

```mermaid
flowchart TD
  start(["Task đang chọn / hover<br/>hoặc chi tiết task"])
  u1[/"Phím E hoặc bấm ô Thực tế<br/>trong chi tiết task"/]
  p1[["TimeEntryList"]]
  s1["SCR-02 Thời gian thực tế<br/>đích = task, danh sách bản ghi, tổng"]
  u2[/"Chọn chế độ Thời lượng / Khoảng giờ,<br/>nhập giờ + phút hoặc khoảng giờ, Enter"/]
  p2[["Kiểm BR-05 theo chế độ<br/>TimeEntryCreate source manual, entryMode"]]
  m1>"MSG-03 · Toast<br/>Đã ghi {H:MM} cho #quot;{tiêu đề}#quot; · Hoàn tác"]
  ok(["Bản ghi mới, thực tế tính lại<br/>nhật ký ghi BR-18"])

  start ==> u1 ==> p1 ==> s1 ==> u2 ==> p2 ==> m1 ==> ok

  class start,u1,p1,s1,u2,p2,m1 happy
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
  s1["SCR-02 Thời gian thực tế"]
  u2[/"Nhập, Enter"/]
  p2[["Kiểm BR-05, TimeEntryCreate"]]
  m1>"MSG-03 · Toast · Hoàn tác"]
  ok(["Bản ghi mới"])
  s1 ==> u2 ==> p2 ==> m1 ==> ok

  s1 -->|"A1 · sửa giờ một bản ghi tại chỗ"| a1[["TimeEntryUpdate<br/>bản ghi TU_DONG → needsReview = false"]]
  a1 --> a1m>"MSG-25 · Inline cạnh dòng, kèm icon dấu tích<br/>Đã lưu"]
  a1m --> ok
  m1 -->|"Hoàn tác"| m1u[["Xoá bản ghi vừa nhập<br/>thực tế về như trước QC-13 mục 5"]]
  s1 -->|"A6 · sửa bản ghi ritual / timer"| a6["Như A1, giờ do người dùng đặt<br/>giữ source, giả định"]
  a6 --> a1
  s1 -->|"A2 · xoá bản ghi"| a2[["TimeEntryDelete"]]
  a2 --> a2m>"MSG-04 · Toast<br/>Đã xoá bản ghi {H:MM} · Hoàn tác"]
  a2m -->|"Hoàn tác"| a2r[["Tạo lại bản ghi"]]
  s1 -->|"A3 · chọn subtask ở Đích / E trên dòng subtask"| a3["SCR-02 đích = subtask<br/>cộng vào thực tế của task"]
  a3 --> u2
  p2 -->|"A4 · Khoảng giờ chồng bản ghi đã đóng"| a4m>"MSG-08 · Inline cảnh báo<br/>Khoảng giờ này trùng với một lần ghi khác"]
  a4m -->|"vẫn lưu"| m1
  p2 -->|"A5 · Thời lượng khi có timer chạy / trùng giờ"| a5["Lưu, không kiểm chồng lấn, không cảnh báo<br/>không vẽ lên lịch"]
  a5 --> m1

  u2 -.->|"E1 · giờ kết thúc ≤ giờ bắt đầu"| e1m>"MSG-05 · Inline<br/>Giờ kết thúc phải sau giờ bắt đầu"]
  u2 -.->|"E2 · < 1 phút hoặc > 24 giờ"| e2m>"MSG-06 · Inline<br/>Mỗi lần ghi từ 1 phút đến 24 giờ"]
  u2 -.->|"E3 · Khoảng giờ: kết thúc ở tương lai<br/>hoặc chồng timer đang chạy"| e3m>"MSG-18 · Inline<br/>Không ghi được thời gian trong tương lai hoặc trùng timer đang chạy"]
  e1m -.-> fail(["Bản ghi không đổi, lỗi tại ô"])
  e2m -.-> fail
  e3m -.-> fail
  p2 -.->|"E4 · 5xx / timeout"| e4m>"MSG-09 · Toast<br/>Chưa lưu được thời gian. Thử lại"]
  e4m -.-> fail2(["Giữ nội dung đã nhập"])

  class s1,u2,p2,m1 happy
  class a1,a1m,m1u,a6,a2,a2m,a2r,a3,a5 alt
  class a4m warn
  class e1m,e2m,e3m,e4m err
  class ok done
  class fail,fail2 fail
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
| (bước 4) | Hoàn tác trên MSG-03 | Xoá bản ghi vừa nhập (C29) | MSG-03 |
| A1 | Sửa giờ một bản ghi | Bản ghi cập nhật; `TU_DONG` hết chờ xác nhận | MSG-25 (C29) |
| A2 | Xoá bản ghi | Xoá cứng, Hoàn tác tạo lại | MSG-04 |
| A3 | Nhập cho subtask | Đích = subtask | MSG-03 |
| A4 | Khoảng giờ chồng bản ghi đã đóng | Vẫn lưu | MSG-08 |
| A5 | Thời lượng khi đang có timer / trùng giờ | Lưu, không cảnh báo, không lên lịch | MSG-03 |
| A6 | Sửa bản ghi `ritual` / `timer` | Như A1, giữ `source` `[giả định]` | – |
| E1 | Giờ kết thúc ≤ giờ bắt đầu | Không lưu | MSG-05 |
| E2 | < 1 phút hoặc > 24 giờ | Không lưu | MSG-06 |
| E3 | Kết thúc ở tương lai / chồng timer đang chạy | Không lưu | MSG-18 |
| E4 | 5xx / timeout | Giữ nội dung đã nhập | MSG-09 |
| E5 | Workspace chỉ đọc | Bỏ (1.1) | – |

---

## UC-04 Focus mode và âm báo

**Mở đầu:** người dùng đã đăng nhập; không có task để focus thì đi nhánh A3 (C26). **Thành công:** Focus mode hiện một task, điều khiển timer được từ Focus. **Thất bại:** ở lại màn hiện tại.

### Happy case

```mermaid
flowchart TD
  start(["Khung app · bất kỳ màn nào"])
  u1[/"Phím F hoặc mục Focus ở sidebar"/]
  p1[["Chọn task BR-12: task đang chọn,<br/>không có thì task đầu tiên chưa xong của hôm nay"]]
  s1["SCR-03 Focus mode · tab Focus<br/>toàn cửa sổ, ẩn sidebar và panel phải"]
  u2[/"START hoặc Space"/]
  p2[["UC-01 Bật timer"]]
  u3[/"Làm việc: tích subtask, ghi notes"/]
  d1{"Còn lại chạm mức cài đặt<br/>10 / 5 / 0 phút? BR-07"}
  m1>"MSG-10 · Toast + âm báo<br/>Còn {n} phút cho #quot;{tiêu đề}#quot; / Đã hết thời lượng kế hoạch cho #quot;{tiêu đề}#quot;"]
  u4[/"Esc hoặc nút Thoát"/]
  ok(["Về màn trước, timer giữ nguyên"])

  start ==> u1 ==> p1 ==> s1 ==> u2 ==> p2 ==> u3 ==> d1
  d1 ==>|"có"| m1 ==> u4
  d1 ==>|"chưa / task không có kế hoạch"| u4
  u4 ==> ok

  class start,u1,p1,s1,u2,p2,u3,d1,m1,u4 happy
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
  p1[["Chọn task BR-12"]]
  s1["SCR-03 Focus mode"]
  u3[/"Làm việc"/]
  m1>"MSG-10 · Toast + âm báo"]
  u4[/"Esc"/]
  ok(["Về màn trước, timer giữ nguyên"])
  p1 ==> s1 ==> u3 ==> m1 ==> u4 ==> ok

  p1 -->|"A3 · hôm nay không có task chưa xong,<br/>không có task chọn"| a3m>"MSG-19 · Empty state<br/>Chọn một task của hôm nay để bắt đầu focus"]
  s1 -->|"A2 · dropdown tiêu đề, chọn task hôm nay khác"| a2["SCR-03 task mới<br/>timer không tự chuyển"]
  a2 --> s1
  u3 -->|"A1 · bấm hoàn thành task"| a1x{{"→ G02 · UC-03"}}
  a1x --> a1["SCR-03 gợi ý task kế tiếp chưa xong của hôm nay<br/>Bắt đầu hoặc Thoát"]
  a1 -->|"Bắt đầu"| a1b[["Focus chuyển sang task kế tiếp<br/>bật timer luôn UC-01, B25"]]
  a1b --> s1
  a1 -->|"Thoát"| ok
  m1 -->|"A4 · đã tắt âm báo trong cài đặt Focus"| a4["Chỉ hiện MSG-10, không phát âm"]

  s1 -.->|"E1 · task bị xoá khi đang ở Focus"| e1(["Focus đóng"])
  e1 -.-> e1m>"MSG-16 · Toast<br/>Task không còn tồn tại hoặc đã lưu trữ, timer đã dừng"]
  m1 -.->|"E2 · không phát được âm thanh"| e2["Chỉ hiện MSG-10"]
  e2 -.->|"lần đầu"| e2m>"MSG-10 và MSG-23 · một toast QC-13 mục 3<br/>Không phát được âm báo. Kiểm tra âm thanh của Windows"]

  class p1,s1,u3,m1,u4 happy
  class a3m,a2,a1,a1b,a4 alt
  class a1x link
  class e1m,e2,e2m err
  class ok done
  class e1 fail
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
| A1 | Hoàn thành task trong Focus | [G02 UC-03](g02-quan-ly-task.md#uc-03-hoàn-thành--bỏ-hoàn-thành-task), gợi ý task kế tiếp; "Bắt đầu" chuyển task và bật timer luôn (B25) | Theo G02 |
| A2 | Đổi task trong Focus | Task mới, timer không tự chuyển | – |
| A3 | Không có task để focus | Empty state | MSG-19 |
| A4 | Tắt âm báo | Chỉ toast | MSG-10 |
| E1 | Task bị xoá khi ở Focus | Đóng Focus | MSG-16 |
| E2 | Không phát được âm thanh | Chỉ toast; lần đầu thêm dòng gợi ý kiểm tra âm thanh (C27) | MSG-10, lần đầu MSG-10 + MSG-23 (một toast) |

Tab Pomodoro, nút "Nghỉ một chút (K)" trên SCR-03: Bỏ (1.1).

---

## UC-06 Giám sát timer chạy lâu (job `timer.watchdog`)

**Mở đầu:** có bản ghi thời gian `endedAt` trống. SCR-06 hiện ngay nếu cửa sổ app đang mở, hoặc lần đầu cửa sổ được mở lên nếu app đang ở khay (B24). **Thành công:** timer > 4 giờ được nhắc đúng một lần; timer > 24 giờ tự đóng và chờ xác nhận, người dùng chọn giờ dừng thật. **Thất bại:** lượt sau xử lý lại (idempotent).

### Happy case

```mermaid
flowchart TD
  start(["Timer đang chạy<br/>job timer.watchdog mỗi 5 phút"])
  d1{"Chạy > 4 giờ, chưa nhắc?"}
  p1[["Tạo thông báo G12 + thông báo Windows<br/>đặt longRunNotifiedAt"]]
  m1>"MSG-11 · Thông báo<br/>Timer cho #quot;{tiêu đề}#quot; đã chạy hơn 4 giờ. Bạn vẫn đang làm? · Dừng · Dừng lúc… · Vẫn đang làm"]
  d2{"Chạy > 24 giờ?"}
  p2[["Đóng theo BR-09: endedAt = startedAt + 24 giờ<br/>auto_closed, needsReview; timer.changed; nhật ký system"]]
  u1[/"Cửa sổ app đang mở: hiện ngay<br/>app ở khay: lần đầu cửa sổ được mở lên B24"/]
  s1["SCR-06 Xác nhận giờ dừng · dialog"]
  m2>"MSG-20 · Dialog<br/>Timer cho #quot;{tiêu đề}#quot; chạy hơn 24 giờ nên đã tự dừng. Bạn dừng lúc mấy giờ?"]
  u2[/"Chọn giờ dừng thật trong startedAt tới<br/>min(now, startedAt + 24 giờ), bấm Lưu"/]
  p3[["TimeEntryUpdate endedAt, needsReview: false<br/>thực tế tính lại"]]
  ok(["Bản ghi DA_DONG với giờ dừng thật"])

  start ==> d1
  d1 ==>|"có"| p1 ==> m1 ==> d2
  d1 ==>|"không"| d2
  d2 ==>|"chưa · lượt sau"| start
  d2 ==>|"có"| p2 ==> u1 ==> s1 ==> m2 ==> u2 ==> p3 ==> ok

  class start,d1,p1,m1,d2,p2,u1,s1,m2,u2,p3 happy
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
  p1[["Tạo thông báo"]]
  m1>"MSG-11 · Thông báo"]
  p2[["Tự đóng BR-09"]]
  s1["SCR-06 Xác nhận giờ dừng"]
  u2[/"Chọn giờ, Lưu"/]
  ok(["Bản ghi với giờ dừng thật"])
  p1 ==> m1 ==> p2 ==> s1 ==> u2 ==> ok

  m1 -->|"A1 · bấm Dừng"| a1x{{"→ UC-02 với endedAt = now"}}
  m1 -->|"A2 · bấm Vẫn đang làm"| a2(["Giữ timer<br/>không nhắc lại trong lượt này"])
  m1 -->|"A6 · bấm Dừng lúc…"| a6["Bộ chọn giờ như SCR-06 #2<br/>trong (startedAt, min(now, startedAt + 24 giờ)]<br/>mặc định giờ hoạt động cuối"]
  a6 -->|"Lưu"| a6p[["TimerStop endedAt, áp BR-04"]]
  a6p --> a6e(["Bản ghi đóng ở giờ đã chọn"])
  s1 -->|"A3 · Giữ 24 giờ"| a3[["needsReview = false, giữ endedAt"]]
  a3 --> a3e(["Bản ghi 24 giờ"])
  s1 -->|"A4 · Xoá bản ghi"| a4[["TimeEntryDelete"]]
  a4 --> a4m>"MSG-04 · Toast<br/>Đã xoá bản ghi {H:MM} · Hoàn tác"]
  s1 -->|"A5 · không chọn được giờ"| a5["Giờ dừng mặc định<br/>= giờ hoạt động cuối trên app, giả định"]
  a5 --> u2

  p1 -.->|"E1 · gửi thông báo lỗi"| e1["Thử lại 3 lần<br/>không chặn bước tự đóng"]
  e1 -.-> p2
  p2 -.->|"E2 · lỗi CSDL khi tự đóng"| e2["Rollback"]
  e2 -.->|"lượt 5 phút sau làm lại"| p2

  class p1,m1,p2,s1,u2 happy
  class a2,a6,a6p,a6e,a3,a3e,a4,a4m,a5 alt
  class a1x link
  class e1,e2 err
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
| A1 | Bấm "Dừng" trong MSG-11 | [UC-02](#uc-02-dừng-timer), `endedAt` = now | – |
| A2 | Bấm "Vẫn đang làm" | Timer chạy tiếp, không nhắc lại lượt này | – |
| A3 | SCR-06 "Giữ 24 giờ" | Bản ghi 24 giờ | – |
| A4 | SCR-06 "Xoá bản ghi" | Bản ghi xoá | MSG-04 |
| A5 | SCR-06 không chọn được giờ | Mặc định giờ hoạt động cuối `[giả định]` | – |
| A6 | Bấm "Dừng lúc…" trong MSG-11 | Bộ chọn giờ, cùng khoảng với SCR-06 (B24) → TimerStop | – |
| E1 | Gửi thông báo lỗi | Thử lại 3 lần, vẫn tự đóng | – |
| E2 | Lỗi CSDL khi tự đóng | Rollback, lượt sau làm lại | – |

Thông báo MSG-11 nằm ở trung tâm thông báo [G12 UC-09](g12-workspace-billing.md); push di động: Bỏ (1.2).

---

## UC-07 Đồng bộ timer nhiều thiết bị và offline

**Mở đầu:** người dùng dùng ≥ 2 thiết bị, hoặc một thiết bị vừa có mạng lại sau khi bật / dừng timer offline. **Thành công:** mọi thiết bị hiện cùng một timer, dữ liệu thoả BR-01. **Thất bại:** thiết bị giữ trạng thái cục bộ, thử lại ở lần kết nối sau.

### Happy case

```mermaid
flowchart TD
  start(["Thiết bị có mạng lại<br/>sau khi bật / dừng timer offline"])
  p1[["SyncBatch gửi hàng đợi<br/>theo thứ tự clientOpId"]]
  p2[["Server xử lý lệnh timer theo thứ tự nhận QC-08<br/>chỉnh mốc giờ máy BR-11, áp BR-01, BR-10"]]
  p3[["Phát timer.changed tới mọi thiết bị"]]
  d1{"Thiết bị này có timer bị đóng<br/>hoặc bản ghi bị cắt?"}
  m1>"MSG-17 · Toast<br/>Hai thiết bị cùng bật timer khi mất mạng; giữ timer #quot;{tiêu đề}#quot; bật sau"]
  m2>"MSG-22 · Toast<br/>Đã bỏ {H:MM} trùng với lần ghi khác khi đồng bộ cho #quot;{tiêu đề}#quot;"]
  ok(["Mọi thiết bị hiện cùng một timer"])

  start ==> p1 ==> p2 ==> p3 ==> d1
  d1 ==>|"timer bị đóng"| m1 ==> ok
  d1 ==>|"bản ghi bị cắt"| m2 ==> ok
  d1 ==>|"không"| ok

  class start,p1,p2,p3,d1,m1,m2 happy
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
  p1[["SyncBatch"]]
  p2[["Server xử lý theo thứ tự nhận"]]
  p3[["timer.changed"]]
  ok(["Mọi thiết bị cùng một timer"])
  p1 ==> p2 ==> p3 ==> ok

  on(["Thiết bị đang mở app, online"]) -->|"A1 · nhận timer.changed"| a1["SCR-01 cập nhật ≤ 5 giây<br/>không cần tải lại"]
  on -->|"A2 · mất kết nối realtime"| a2[["TimerGet khi kết nối lại<br/>và mỗi 60 giây khi app mở"]]
  a2 --> a1
  re(["Mở lại app sau khi đóng cửa sổ / tắt máy<br/>trong lúc timer chạy BR-23"]) -->|"A7"| a7[["TimerGet"]]
  a7 --> d7{"Timer đã quá 24 giờ?"}
  d7 -->|"không"| a7s["Home ở hôm nay, không vào Focus<br/>SCR-01 đồng hồ theo startedAt + độ lệch server"]
  d7 -->|"có"| a7x{{"→ UC-06 · SCR-06 hiện ngay khi cửa sổ mở lên"}}
  p2 -->|"A3 · lệnh dừng offline cho timer<br/>đã bị timer khác đóng"| a3["Bỏ lệnh dừng<br/>giữ mốc đóng sớm hơn"]
  a3 --> p3
  p2 -->|"A4 · bản ghi offline chồng bản ghi<br/>timer / auto_closed đã có"| a4["Cắt phần chồng của bản ghi tới sau<br/>còn < 10 giây thì bỏ"]
  a4 --> a4m>"MSG-22 · Toast<br/>Đã bỏ {H:MM} trùng với lần ghi khác khi đồng bộ cho #quot;{tiêu đề}#quot;"]
  a4m --> p3
  p2 -->|"A6 · task của lệnh đã bị dời ngày"| a6["Vẫn áp lệnh<br/>ngày bản ghi theo startedAt BR-20"]
  a6 --> p3

  p2 -.->|"E1 · task của lệnh đã bị xoá"| e1["Bỏ lệnh"]
  e1 -.-> e1m>"MSG-16 · Toast<br/>Task không còn tồn tại hoặc đã lưu trữ, timer đã dừng"]
  p2 -.->|"E2 · giờ máy lệch > 2 phút"| e2[["Server điều chỉnh mốc BR-11<br/>ghi nhật ký"]]
  e2 -.-> p3

  class p1,p2,p3 happy
  class on,a1,a2,re,a7,d7,a7s,a3,a4,a4m,a6 alt
  class a7x link
  class e1,e1m,e2 err
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
| A1 | Thiết bị online nhận `timer.changed` | Cập nhật ≤ 5 giây | – |
| A2 | Mất kết nối realtime | TimerGet khi kết nối lại / mỗi 60 giây | – |
| A3 | Dừng offline cho timer đã bị đóng | Bỏ lệnh dừng, giữ mốc sớm hơn | – |
| A4 | Bản ghi offline chồng bản ghi đã có | Cắt phần chồng của bản tới sau | MSG-22 |
| A5 | Lệnh offline trước khi vào chỉ đọc | Bỏ (1.1) | – |
| A6 | Task của lệnh đã bị dời ngày | Vẫn áp, ngày theo `startedAt` | – |
| A7 | Mở lại app khi timer đang chạy | Home, đồng hồ đúng; > 24 giờ → [UC-06](#uc-06-giám-sát-timer-chạy-lâu-job-timerwatchdog) | – |
| E1 | Task của lệnh đã bị xoá | Bỏ lệnh | MSG-16 |
| E2 | Giờ máy lệch > 2 phút | Server chỉnh mốc, ghi nhật ký | – |

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-04, UC-06, UC-07 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)" / "SRS đã bỏ"; UC-05 Bỏ (1.1), UC-08 Bỏ (1.2).
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG.

**Ghi chú cho brief G07**
1. ~~**Phím toàn cục và menu khay chỉ có chiều "bật"**; menu khay khi chưa có timer chưa ghi.~~ **Đã sửa 09/11/2026 (B23 / C25):** Ctrl+Shift+Space và menu khay dừng timer khi đang có timer (UC-02 bước 1, BR-17, BR-23); menu khay khi chưa có timer có "Bật timer: {task kế tiếp hôm nay}" (UC-01 A6). Sơ đồ UC-01, UC-02 đã thêm.
2. ~~**Nút trong MSG-11 lệch PRD.**~~ **Đã sửa 09/11/2026 (B27):** giữ "Dừng · Dừng lúc… · Vẫn đang làm" theo SRS; PRD US5.1 AC01 sửa theo.
3. ~~**"Lần mở app kế tiếp" (UC-06 bước 4, BR-09)** chưa rõ với app ở khay; hai bộ chọn giờ khác khoảng.~~ **Đã sửa 09/11/2026 (B24):** SCR-06 hiện ngay nếu cửa sổ đang mở, nếu app ở khay thì hiện lần đầu cửa sổ được mở lên; giờ dừng chọn trong (`startedAt`, min(now, `startedAt` + 24 giờ)], chung cho SCR-06 và "Dừng lúc…".
4. ~~**UC-04 tiền điều kiện mâu thuẫn A3.**~~ **Đã sửa 09/11/2026 (C26):** bỏ điều kiện "có ít nhất 1 task chưa xong hoặc có task đang chọn" khỏi tiền điều kiện; A3 xử lý trường hợp đó.
5. ~~**UC-04 A1** "Bắt đầu" sau khi hoàn thành: chỉ chuyển task hay bật timer luôn?~~ **Đã sửa 09/11/2026 (B25):** chuyển sang task kế tiếp và bật timer luôn; sơ đồ UC-04 thêm bước bật timer.
6. ~~**UC-04 E2** "lần đầu gợi ý kiểm tra âm thanh" chưa có mã MSG / chữ.~~ **Đã sửa 09/11/2026 (C27):** MSG-23 "Không phát được âm báo. Kiểm tra âm thanh của Windows", là dòng 2 của toast MSG-10 (QC-13 mục 3).
7. ~~**MSG-16** dùng cho UC-01 E2, chữ không khớp ngữ cảnh.~~ **Đã sửa 09/11/2026 (C28):** UC-01 E2 dùng MSG-24 "Không bật được timer vì task đã bị xoá hoặc đã lưu trữ"; MSG-16 giữ cho timer đang chạy và lệnh offline.
8. ~~**BR-04 bỏ lượt chạy dưới 10 giây** không có phản hồi.~~ **Đã sửa 09/11/2026 (B26):** không báo người dùng (thường là bấm nhầm).
9. ~~**UC-03:** Hoàn tác của MSG-03 chưa ghi cách xử lý; A1 sửa bản ghi không có xác nhận.~~ **Đã sửa 09/11/2026 (C29):** Hoàn tác xoá bản ghi vừa nhập (QC-13 mục 5); sửa bản ghi hiện MSG-25 "Đã lưu" kèm icon dấu tích.
10. ~~**\[TimeEntryList\]** còn `[giả định — chưa có trong danh sách API]`.~~ **Đã sửa 09/11/2026 (C30):** việc kỹ thuật, không cần PO; chốt khi viết code, SRS giữ nguyên.
