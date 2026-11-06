# Flow G04 Board ngày

> **Nguồn:** [srs-g04](../../features/srs-g04-board-ngay.md) (commit `8fac830`) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-xem-board-và-chuyển-chế-độ-xem) | Xem board và chuyển chế độ xem | SCR-01 Home board, SCR-02 Cột ngày, SCR-03 Thanh công cụ | 10 / 4 |
| [UC-02](#uc-02-điều-hướng-ngày) | Điều hướng ngày | SCR-03, SCR-04 Popover chọn ngày | 3 / 2 |
| [UC-03](#uc-03-di-chuyển-task-giữa-các-ngày) | Di chuyển task giữa các ngày | SCR-02 Cột ngày | 7 / 6 |
| [UC-04](#uc-04-sắp-xếp-task-trong-ngày) | Sắp xếp task trong ngày | SCR-02, SCR-05 Menu "Sắp xếp lại" | 4 / 2 |
| [UC-05](#uc-05-tính-projection-và-khối-lượng-ngày) | Tính projection và khối lượng ngày (hệ thống) | SCR-02 | 11 / 2 |
| [UC-06](#uc-06-lọc-theo-channel) | Lọc theo channel | SCR-03, SCR-06 Bộ lọc channel | 4 / 1 |
| [UC-07](#uc-07-tìm-kiếm-task) | Tìm kiếm task | SCR-07 Panel Search | 4 / 3 |
| [UC-08](#uc-08-command-menu-và-phím-tắt) | Command menu và phím tắt | SCR-08 Command menu, SCR-09 Bảng phím tắt | 6 / 2 |

---

## UC-01 Xem board và chuyển chế độ xem

**Mở đầu:** người dùng đã đăng nhập, mở app / phím H / sidebar Home. **Thành công:** board / view hiện đúng tổng, tiến độ, giờ dự kiến, trạng thái ngày; view được lưu trên thiết bị. **Thất bại:** dữ liệu lần cuối trên máy (nếu có) kèm MSG-15.

### Happy case

```mermaid
flowchart TD
  start(["Mở app, phím H hoặc sidebar Home"])
  p1[["Xác định hôm nay BR-01"]]
  d1{"Lần mở đầu tiên<br/>trong ngày làm việc?"}
  p2[["RolloverEnsure BR-25<br/>G06 UC-07"]]
  p3[["DayList 7 ngày từ hôm nay<br/>CalendarEvents G05 cùng khoảng"]]
  p4[["Tính tổng, tiến độ, sức chứa,<br/>projection BR-02 → BR-06"]]
  s1["SCR-01 Home board ở hôm nay, view cuối<br/>SCR-02 cột ngày: header, card theo BR-07"]
  u1[/"Cuộn ngang"/]
  p5[["Còn 2 cột tới mép<br/>DayList thêm 7 ngày"]]
  u2[/"Nhấn Tab hoặc chọn view<br/>trên SCR-03 Thanh công cụ"/]
  p6[["Đổi view BR-13, giữ ngày đang xem<br/>lưu view trên thiết bị"]]
  ok(["SCR-01 ở view mới<br/>tổng, tiến độ, giờ dự kiến, trạng thái ngày đúng"])

  start ==> p1 ==> d1
  d1 ==>|"có"| p2 ==> p3
  d1 ==>|"không"| p3
  p3 ==> p4 ==> s1 ==> u1 ==> p5 ==> u2 ==> p6 ==> ok

  class start,p1,d1,p2,p3,p4,s1,u1,p5,u2,p6 happy
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
  s1["SCR-01 Home board"]
  u2[/"Tab / chọn view"/]
  ok(["SCR-01 ở view mới"])
  s1 ==> u2 ==> ok

  s1 -->|"A1 · phím T / sidebar Today"| a1["Today view, chưa có mã SCR<br/>task của ngày đang xem + lịch ngày G05"]
  s1 -->|"A2 · hover header cột ngày ≥ hôm nay"| a2["SCR-02 #4 nút Plan hiện"]
  a2 -->|"bấm Plan"| a2x{{"→ G08 · UC-01"}}
  s1 -->|"cột ngày đã qua, IA-20"| ia20["SCR-02 #4, #6 không có nút Plan<br/>và không có + Thêm task"]
  ia20 -->|"nhấn A"| ia20x{{"→ G02 · UC-01 A6<br/>ô soạn mở ở cột hôm nay"}}
  u2 -->|"A3 · Calendar views"| a3["SCR-01 Calendar view<br/>sự kiện G05, timebox,<br/>projection mờ hơn sự kiện thật"]
  u2 -->|"A4 · Month view"| a4["SCR-01 Month view<br/>mỗi ngày tối đa 3 task, +n"]
  a4 -->|"bấm +n"| a4b["Popover danh sách task của ngày"]
  s1 -->|"A5 · bật Ẩn task đã xong"| a5["SCR-02 card xong ẩn<br/>tổng, tiến độ vẫn tính BR-02, BR-03"]
  s1 -->|"A6 · ngày > 100 task, EC-40"| a6["SCR-02 danh sách ảo hoá BR-19"]
  s1 -->|"A7 · qua mốc đầu ngày khi đang mở app"| a7["Hôm nay chuyển sang ngày mới<br/>cột cũ thành DA_QUA"]
  a7 --> d7{"Đã nhận kết quả rollover<br/>qua realtime G06?"}
  d7 -->|"có"| s1
  d7 -->|"chưa"| a7b[["Như BR-25: RolloverEnsure<br/>rollover tạm trên máy"]]
  a7b --> s1
  s1 -->|"A8 · timezone thiết bị khác timezone người dùng, EC-02"| a8x{{"→ G01 · UC-06 banner timezone MSG-23 của G01"}}
  a8x --> a8["Hiệu lực từ ngày làm việc kế tiếp: task giữ ngày dự định,<br/>timebox giữ thời điểm tuyệt đối<br/>timebox rơi khác ngày: task vẫn ở cột ngày dự định,<br/>không gắn cờ, không tự sửa F5"]
  s1 -->|"A9 · cửa sổ < 768 px"| a9["SCR-01 1 cột<br/>cuộn ngang / Shift+→/← đổi ngày"]
  s1 -->|"A10 · ngày ngoài khoảng instance lặp đã sinh, C17"| a10["SCR-02 card mờ nhãn Dự kiến BR-23<br/>không kéo được, không tính vào tổng"]

  class s1,u2 happy
  class ia20 alt
  class ia20x link
  class a1,a2,a3,a4,a4b,a5,a6,a7,d7,a7b,a8,a9,a10 alt
  class a2x,a8x link
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
  start(["Mở app, phím H"])
  p2[["RolloverEnsure"]]
  p3[["DayList, CalendarEvents"]]
  s1["SCR-01 Home board"]
  start ==> p2 ==> p3 ==> s1

  p3 -.->|"E1 · mất mạng"| e1["SCR-01 dữ liệu trên máy: 4 tuần + backlog<br/>SCR-01 #5 banner Đang offline<br/>projection tính trên máy"]
  e1 -.->|"qua mốc đầu ngày"| e1b["Rollover tạm trên máy G06"]
  p3 -.->|"E2 · DayList lỗi / timeout"| e2["SCR-01 giữ dữ liệu đã có"]
  e2 -.-> e2m>"MSG-15 · Toast<br/>Chưa tải / lưu được thay đổi. Thử lại"]
  e2m -.->|"Thử lại"| p3
  e2m -.-> fail(["Dữ liệu lần cuối trên máy kèm MSG-15"])
  p3 -.->|"E3 · CalendarEvents lỗi hoặc chưa kết nối lịch"| e3["SCR-02 cờ CHUA_TINH_LICH<br/>sức chứa = giờ làm còn lại, chưa trừ sự kiện"]
  e3 -.-> e3m>"MSG-18 · Tooltip tổng<br/>Chưa tính lịch: chưa kết nối hoặc lịch đang lỗi"]
  e3m -.-> s1
  p2 -.->|"E4 · ROLLOVER_FAILED"| e4["Giữ rollover tạm trên máy"]
  e4 -.-> e4m>"MSG-27 · Banner<br/>Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại"]
  e4m -.->|"Thử lại"| p2
  e4 -.-> p3

  class start,p2,p3,s1 happy
  class e1,e1b sync
  class e2,e2m,e4,e4m err
  class e3,e3m warn
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

### Banner trạng thái (SCR-01 #5, IA-17)

Vùng chính chỉ có **một** banner cùng lúc. Nhiều điều kiện cùng đúng thì banner ưu tiên cao nhất hiện; các banner còn lại chờ tới lượt và vào trung tâm thông báo ([G12 UC-09](g12-workspace-billing.md)).

```mermaid
flowchart TD
  start(["Có điều kiện cần banner<br/>offline / lịch cần kết nối lại /<br/>rollover lỗi / lệch timezone"])
  d1{"Đang có banner<br/>ưu tiên cao hơn?"}
  s1["SCR-01 #5 hiện banner này<br/>thứ tự: offline → lịch cần kết nối lại<br/>→ rollover lỗi → lệch timezone"]
  q1["Banner chờ tới lượt"]
  n1{{"→ G12 · UC-09<br/>đồng thời vào trung tâm thông báo"}}
  d2{"Banner đang hiện<br/>hết điều kiện?"}
  ok(["Banner kế tiếp trong hàng chờ hiện<br/>hoặc không còn banner"])

  start ==> d1
  d1 ==>|"không"| s1 ==> d2
  d1 -->|"có"| q1 --> n1
  q1 -->|"banner trên hết điều kiện"| s1
  d2 ==>|"có: có mạng lại, đã kết nối lại,<br/>rollover xong, chọn Giữ / Đổi timezone"| ok

  class start,d1,s1,d2 happy
  class q1 alt
  class n1 link
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
| A1 | Phím T / sidebar Today | Today view | – |
| A2 | Hover header cột ≥ hôm nay | Nút Plan → [G08 UC-01](g08-daily-rituals.md) | – |
| A3 | Calendar views | Sự kiện, timebox, projection mờ | – |
| A4 | Month view | 3 task / ngày, "+n" mở popover | – |
| A5 | Ẩn task đã xong | Card xong ẩn, tổng giữ | – |
| A6 | Ngày > 100 task | Danh sách ảo hoá | – |
| A7 | Qua mốc đầu ngày khi đang mở | Hôm nay mới, cột cũ `DA_QUA`; chưa có kết quả rollover thì như BR-25 | – |
| A8 | Lệch timezone | Banner của [G01 UC-06](g01-tai-khoan.md); task giữ cột ngày dự định, không gắn cờ (F5) | G01 MSG-23 |
| A9 | Cửa sổ < 768 px | 1 cột | – |
| A10 | Ngày ngoài khoảng instance đã sinh | Instance dự kiến mờ | – |
| E1 | Mất mạng | Dữ liệu trên máy, banner offline | – (chưa có mã MSG) |
| E2 | DayList lỗi / timeout | Giữ dữ liệu, Thử lại | MSG-15 |
| E3 | Lịch lỗi / chưa kết nối | Cờ `CHUA_TINH_LICH` | MSG-18 |
| E4 | `ROLLOVER_FAILED` | Rollover tạm, banner Thử lại | MSG-27 |

---

## UC-02 Điều hướng ngày

**Mở đầu:** đang ở Home, Today view hoặc Calendar views. **Thành công:** ngày / khoảng đang xem đổi đúng, chip ngày cập nhật. **Thất bại:** ngày đang xem không đổi.

### Happy case

```mermaid
flowchart TD
  start(["SCR-03 Thanh công cụ<br/>Home, Today hoặc Calendar view"])
  u1[/"Bấm chip ngày"/]
  s1["SCR-04 Popover chọn ngày"]
  u2[/"Chọn Hôm nay / Ngày sau / Ngày trước<br/>hoặc một ngày trên lịch tháng"/]
  p1[["Cuộn / chuyển tới ngày chọn<br/>DayList nếu chưa có, đóng popover"]]
  ok(["SCR-03 chip hiện ngày đang xem<br/>khác hôm nay thì kèm ×"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> ok

  class start,u1,s1,u2,p1 happy
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
  s0["SCR-03 chip ngày"]
  s1["SCR-04 Popover chọn ngày"]
  u2[/"Chọn ngày"/]
  p1[["Chuyển tới ngày chọn"]]
  ok(["Chip ngày cập nhật"])
  s0 ==> s1 ==> u2 ==> p1 ==> ok

  s0 -->|"A1 · Shift+Space / Shift+→ / Shift+←<br/>hoặc ‹ › SCR-03 #2"| a1[["Dịch theo BR-14<br/>không mở popover"]]
  a1 --> p1
  a1 -->|"A3 · đang ở Calendar views"| a3["Dịch theo khoảng của view:<br/>Weekdays, Week 1 tuần; 3 ngày 3 ngày; Month 1 tháng"]
  a3 --> p1
  ok -->|"A2 · bấm × trên chip"| a2(["Về hôm nay, × ẩn"])

  u2 -.->|"E1 · ngày ngoài ± 5 năm"| e1["SCR-04 ngày đó disabled trên lịch tháng"]
  a1 -.->|"E1 · phím vượt ± 5 năm"| e1m>"MSG-19 · Toast<br/>Chỉ chọn được ngày trong vòng 5 năm tính từ hôm nay"]
  e1m -.-> fail(["Ngày đang xem không đổi"])
  p1 -.->|"E2 · DayList lỗi"| e2["SCR-02 khung cột rỗng"]
  e2 -.-> e2m>"MSG-15 · Toast<br/>Chưa tải / lưu được thay đổi. Thử lại"]
  e2m -.->|"Thử lại"| p1

  class s0,s1,u2,p1 happy
  class a1,a3,a2 alt
  class e1,e1m,e2,e2m err
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
| A1 | Shift+Space / Shift+→ / Shift+← | Ngày mới, không mở popover | – |
| A2 | Bấm × trên chip | Về hôm nay | – |
| A3 | Calendar views | Dịch theo khoảng của view | – |
| E1 | Ngày ngoài ± 5 năm | Ngày disabled / phím không đi tiếp | MSG-19 |
| E2 | DayList lỗi | Khung cột rỗng, Thử lại | MSG-15 |

---

## UC-03 Di chuyển task giữa các ngày

**Mở đầu:** task `KE_HOACH`, `BACKLOG` hoặc `HOAN_THANH` trên board. **Thành công:** cụm vị trí và vị trí đổi theo BR-08 / BR-10, hai ngày được tính lại, nhật ký ghi, có Hoàn tác. **Thất bại:** task về vị trí cũ.

### Happy case

```mermaid
flowchart TD
  start(["SCR-02 cột ngày A · task card"])
  u1[/"Kéo card"/]
  s1["SCR-02 #8 vạch vị trí thả<br/>tới mép thì cuộn tự động"]
  u2[/"Thả vào cột ngày B giữa hai task"/]
  p1[["Kiểm BR-08, chuyển card ngay<br/>TaskMove startDate = B, afterId / beforeId, version"]]
  p2[["Tính lại ngày A và B · UC-05"]]
  m1>"MSG-01 · Toast<br/>Đã chuyển #quot;{tiêu đề}#quot; sang {thứ, ngày} · Hoàn tác"]
  ok(["Task ở cột B đúng vị trí<br/>nhật ký ghi đổi ngày"])

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
  s0(["SCR-02 task card"])
  u1[/"Kéo, thả vào cột B"/]
  p1[["TaskMove"]]
  m1>"MSG-01 · Toast · Hoàn tác"]
  ok(["Task ở cột B"])
  s0 ==> u1 ==> p1 ==> m1 ==> ok

  start2(["Task đang chọn / hover"]) -->|"A1 · phím D / lệnh Hoãn 1 tuần / phím S"| a1[["TaskMove snooze: day / snooze: week /<br/>startDate = hôm nay<br/>server tính ngày đích BR-10"]]
  a1 -->|"D"| a1d>"MSG-05 · Toast<br/>Đã hoãn sang {thứ, ngày} · Hoàn tác"]
  a1 -->|"Hoãn 1 tuần"| a1w>"MSG-06 · Toast<br/>Đã hoãn 1 tuần, sang {thứ, ngày} · Hoàn tác"]
  a1 -->|"S"| a1s>"MSG-07 · Toast<br/>Đã chuyển về hôm nay · Hoàn tác"]
  start2 -->|"A6 · Space nhấc, bàn phím"| a6[/"←/→ đổi cột, ↑/↓ đổi vị trí<br/>Space thả, Esc huỷ"/]
  a6 --> p1
  u1 -->|"A3 · thả vào panel Backlog"| a3[["TaskMove backlogBucket<br/>G06 BR-02"]]
  a3 --> a3x{{"→ G06 · UC-01"}}
  p1 -->|"A2 · task đã timebox"| a2["Giữ giờ, dời timebox sang ngày mới BR-09<br/>timer đang chạy không dừng"]
  a2 --> a2x{{"→ G05 cập nhật sự kiện ngoài"}}
  a2 --> m1
  p1 -->|"A7 · timebox liên kết sự kiện B8"| a7["BR-09: chỉ gỡ liên kết, sự kiện ngoài giữ nguyên<br/>task sang ngày mới không còn timebox đó<br/>QC-05 ngoại lệ, G05 BR-21 f"]
  a7 --> m1
  p1 -->|"A4 · instance lặp, kéo / chọn ngày vào ngày<br/>đã có instance cùng series; chỉ đổi instance này"| a4m>"MSG-23 · Toast cảnh báo<br/>Ngày này đã có {tên series}"]
  a4m --> ok
  a1 -->|"A4 · phím D vào ngày đã có instance cùng series"| a4d["Instance được dời chuyển LUU_TRU<br/>lý do skipped"]
  a4d --> a4dm>"MSG-24 · Toast<br/>{thứ, ngày} đã có {tên series}, bản này được chuyển vào Lưu trữ · Hoàn tác"]
  m1 -->|"A5 · Hoàn tác / Ctrl+Z"| a5[["TaskMove undoToken<br/>trả cụm vị trí, vị trí cũ,<br/>liên kết timebox BR-12"]]
  a1d -->|"A5"| a5
  a1w -->|"A5"| a5
  a1s -->|"A5"| a5
  a4dm -->|"A5"| a5
  a5 --> a5e(["Task về chỗ cũ"])

  class s0,u1,p1,m1 happy
  class start2,a1,a1d,a1w,a1s,a6,a3,a2,a7,a4d,a4dm,a5,a5e alt
  class a4m warn
  class a3x,a2x link
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
  u1[/"Kéo, thả / phím D, S"/]
  p1[["TaskMove"]]
  ok(["Task ở ngày mới · MSG-01"])
  u1 ==> p1 ==> ok

  u1 -.->|"E1 · task chưa xong thả vào ngày < hôm nay"| e1["SCR-02 #8 cột đích mờ, không cho thả"]
  e1 -.-> e1m>"MSG-09 · Toast<br/>Không thể chuyển task chưa xong về ngày đã qua"]
  p1 -.->|"E1 · server PAST_DATE, mọi đường"| e1m
  e1m -.-> fail(["Task về vị trí cũ"])
  p1 -.->|"E2 · ngày đích ngoài ± 5 năm"| e2m>"MSG-19 · Toast<br/>Chỉ chọn được ngày trong vòng 5 năm tính từ hôm nay"]
  e2m -.-> fail
  p1 -.->|"E3 · VERSION_CONFLICT<br/>thiết bị khác / job rollover"| e3["Tải lại task, vẽ theo server"]
  e3 -.-> e3m>"MSG-17 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e3m -.-> e3e(["Task theo trạng thái server"])
  p1 -.->|"E4 · TASK_DELETED"| e4["Gỡ card"]
  e4 -.-> e4m>"MSG-14 · Toast<br/>Task này đã bị xoá"]
  p1 -.->|"E5 · mất mạng"| e5["Áp trên máy, hàng đợi<br/>SyncBatch khi có mạng"]
  e5 -.->|"đồng bộ thành công"| ok
  e5 -.->|"cụm vị trí trên phiên bản cũ bị từ chối"| e3
  p1 -.->|"E7 · TaskMove 5xx"| e7["Trả card về chỗ cũ"]
  e7 -.-> e7m>"MSG-15 · Toast<br/>Chưa tải / lưu được thay đổi. Thử lại"]
  e7m -.-> fail

  class u1,p1 happy
  class e1,e1m,e2m,e3,e3m,e4,e4m,e7,e7m err
  class e5 sync
  class ok done
  class fail,e3e fail
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
| A1 | Phím D / "Hoãn 1 tuần" / phím S | Ngày đích theo BR-10 | MSG-05 / MSG-06 / MSG-07 |
| A2 | Task đã timebox | Timebox dời theo, [G05](g05-lich-timebox.md) cập nhật sự kiện ngoài; timer không dừng | MSG-01 |
| A3 | Thả vào panel Backlog | Task trong backlog → [G06 UC-01](g06-backlog-rollover.md) | – |
| A4 | Instance lặp vào ngày đã có instance cùng series | Kéo / chọn ngày: vẫn đặt; phím D: bản bị dời vào Lưu trữ (`skipped`) | MSG-23 / MSG-24 |
| A5 | Hoàn tác / Ctrl+Z | Về cụm vị trí, vị trí cũ, liên kết timebox | – |
| A6 | Kéo bằng bàn phím | Như kéo thả | MSG-01 |
| A7 | Timebox liên kết sự kiện | Gỡ liên kết, sự kiện giữ nguyên (BR-09, QC-05) | – |
| E1 | Task chưa xong vào ngày < hôm nay | Không thả / server từ chối | MSG-09 |
| E2 | Ngoài ± 5 năm | Task về chỗ cũ | MSG-19 |
| E3 | `VERSION_CONFLICT` | Trạng thái server | MSG-17 |
| E4 | `TASK_DELETED` | Gỡ card | MSG-14 |
| E5 | Mất mạng | Hàng đợi; bị từ chối thì như E3 | MSG-17 (khi xung đột) |
| E6 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E7 | TaskMove 5xx | Task về chỗ cũ | MSG-15 |

---

## UC-04 Sắp xếp task trong ngày

**Mở đầu:** ngày có ≥ 2 task chưa xong. **Thành công:** vị trí tuỳ chỉnh lưu, projection tính lại, có Hoàn tác. **Thất bại:** thứ tự không đổi.

### Happy case

```mermaid
flowchart TD
  start(["SCR-02 header cột ngày<br/>≥ 2 task chưa xong"])
  u1[/"Menu … chọn Sắp xếp lại<br/>hoặc lệnh trong command menu"/]
  s1["SCR-05 Menu Sắp xếp lại"]
  u2[/"Chọn tiêu chí BR-11: giờ bắt đầu, priority,<br/>ngắn nhất, dài nhất, mới nhất, cũ nhất, channel"/]
  p1[["DayReorder criterion<br/>vẽ lại theo BR-11 rồi BR-07"]]
  m1>"MSG-08 · Toast<br/>Đã sắp xếp theo {tiêu chí} · Hoàn tác"]
  p2[["Tính lại projection"]]
  ok(["Thứ tự mới, vị trí tuỳ chỉnh lưu<br/>task xong không đổi"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> m1 ==> p2 ==> ok

  class start,u1,s1,u2,p1,m1,p2 happy
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
  s1["SCR-05 Menu Sắp xếp lại"]
  p1[["DayReorder"]]
  m1>"MSG-08 · Toast · Hoàn tác"]
  ok(["Thứ tự mới"])
  s1 ==> p1 ==> m1 ==> ok

  s0(["SCR-02 task card trong cột"]) -->|"A1 · kéo trong cột"| a1[["TaskMove cùng startDate<br/>đổi afterId / beforeId"]]
  s0 -->|"A2 · Ctrl+↑/↓, Ctrl+Shift+↑/↓"| a2[["Như A1 theo BR-10: đổi chỗ với task kề<br/>lên đầu / xuống cuối nhóm chưa xong"]]
  a1 --> ok
  a2 --> ok
  a1 -->|"A3 · tự sắp bật, kết quả trái BR-07"| a3["Card về đúng nhóm theo BR-07"]
  a2 -->|"A3"| a3
  p1 -->|"A3"| a3
  a3 --> a3m>"MSG-10 · Toast, một lần / phiên<br/>Đang bật tự sắp: task theo giờ và priority được xếp trước. Tắt trong Cài đặt"]
  m1 -->|"A4 · Hoàn tác"| a4[["DayReorder positions cũ"]]
  a4 --> a4e(["Thứ tự cũ"])

  p1 -.->|"E1 · DayReorder lỗi"| e1["Trả thứ tự cũ"]
  e1 -.-> e1m>"MSG-15 · Toast<br/>Chưa tải / lưu được thay đổi. Thử lại"]
  e1m -.-> fail(["Thứ tự không đổi"])
  p1 -.->|"E2 · VERSION_CONFLICT"| e2["Tải lại ngày"]
  e2 -.-> e2m>"MSG-17 · Toast<br/>Task đã thay đổi trên thiết bị khác"]

  class s1,p1,m1 happy
  class s0,a1,a2,a3,a4,a4e alt
  class a3m warn
  class e1,e1m,e2,e2m err
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
| A1 | Kéo trong cột | Vị trí mới | – |
| A2 | Ctrl+↑/↓, Ctrl+Shift+↑/↓ | Vị trí mới | – |
| A3 | Tự sắp bật, kết quả trái BR-07 | Card về đúng nhóm | MSG-10 (một lần / phiên) |
| A4 | Hoàn tác | Thứ tự cũ | – |
| E1 | DayReorder lỗi | Thứ tự cũ | MSG-15 |
| E2 | `VERSION_CONFLICT` | Tải lại ngày | MSG-17 |

---

## UC-05 Tính projection và khối lượng ngày

**Mở đầu:** hệ thống nhận thay đổi ảnh hưởng ngày D (projection, cảnh báo: D ≥ hôm nay; tổng, tiến độ: mọi ngày). **Thành công:** tổng, tiến độ, sức chứa, trạng thái ngày (4.1), giờ trên card (4.2) đúng; thiết bị khác nhận `day.recomputed` ≤ 5 giây. **Thất bại:** giữ kết quả lần trước.

### Happy case

```mermaid
flowchart TD
  start(["Thay đổi: task tạo / sửa planned / di chuyển / xong / xoá / đổi channel;<br/>calendar.changed G05; lịch chung, khung channel, ngưỡng, khoảng đệm BR-27;<br/>qua mốc phút làm tròn"])
  p1[["Client tính ngay ngày bị ảnh hưởng<br/>BR-02 → BR-06, BR-21, BR-22"]]
  s1["SCR-02 vẽ lại ≤ 200 ms<br/>tổng, tiến độ, trạng thái ngày, giờ trên card"]
  p2[["Server tính lại cùng công thức<br/>phát day.recomputed"]]
  d1{"Kết quả server khác máy?"}
  s2["SCR-02 vẽ theo server"]
  ok(["Ngày đúng trạng thái<br/>thiết bị khác nhận ≤ 5 giây"])

  start ==> p1 ==> s1 ==> p2 ==> d1
  d1 ==>|"có"| s2 ==> ok
  d1 ==>|"không"| ok

  class start,p1,s1,p2,d1,s2 happy
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

### Nhánh thay thế và lỗi: sự kiện lịch và thời gian

```mermaid
flowchart TD
  start(["Thay đổi ngày D"])
  p1[["Tính trên máy BR-02 → BR-06"]]
  s1["SCR-02 vẽ lại"]
  p2[["Server · day.recomputed"]]
  start ==> p1 ==> s1 ==> p2

  p1 -->|"A1 · sự kiện đã từ chối, free, cả ngày, EC-17"| a1["Không trừ thời gian trống<br/>không chặn projection"]
  a1 --> s1
  p1 -->|"A8 · task có timebox liên kết sự kiện, B8"| a8["Sự kiện gốc trừ thời gian trống, chặn projection<br/>planned của task không cộng khối lượng còn lại"]
  a8 --> s1
  p1 -->|"A4 · timebox vắt qua mốc đầu ngày, EC-04"| a4["Toàn bộ thời lượng tính cho ngày của thời điểm bắt đầu<br/>phần sau mốc chặn projection ngày hôm sau"]
  a4 --> s1
  p1 -->|"A5 · ngày chuyển giờ mùa hè / đông, EC-03"| a5["Thời gian trống theo phút thực, ngày 23 / 25 giờ<br/>giờ projection không tồn tại → giờ hợp lệ kế tiếp"]
  a5 --> s1
  g05(["G05 · calendar.changed"]) -->|"A6 · sự kiện bị dời / xoá ở lịch ngoài, EC-13, EC-14"| a6[["Tính lại ngày cũ và ngày mới"]]
  a6 --> p1
  now(["Hôm nay, qua mốc phút làm tròn"]) -->|"A10"| a10["Thời gian trống còn lại giảm<br/>có thể BINH_THUONG → QUA_TAI không cần thao tác"]
  a10 --> p1

  p1 -.->|"E1 · không lấy được sự kiện lịch"| e1["SCR-02 cờ CHUA_TINH_LICH<br/>sức chứa = giờ làm còn lại, chưa trừ sự kiện"]
  e1 -.-> e1m>"MSG-18 · Tooltip tổng<br/>Chưa tính lịch: chưa kết nối hoặc lịch đang lỗi"]
  e1m -.-> s1
  p1 -.->|"E2 · tính > 200 ms, EC-40"| e2["Tính nền, không chặn giao diện<br/>giữ kết quả cũ tới khi xong"]
  e2 -.-> s1

  class start,p1,s1,p2 happy
  class a1,a8,a4,a5,g05,a6,now,a10 alt
  class e1m warn
  class e1,e2 err
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

### Nhánh thay thế: sức chứa, quá tải, vượt giờ làm

```mermaid
flowchart TD
  p1[["Tính sức chứa BR-04, quá tải BR-05,<br/>projection BR-06"]]
  s1["SCR-02 BINH_THUONG<br/>tổng màu thường, card có giờ dự kiến"]
  p1 ==> s1

  p1 -->|"A11 · có khung giờ channel, QC-02 mục 5-7"| a11["Sức chứa theo hợp các lịch BR-04<br/>projection, VUOT_GIO_LAM theo lịch của từng task"]
  a11 --> dq{"Quá tải BR-05?"}
  dq -->|"không"| s1
  dq -->|"(a) khối lượng còn lại > sức chứa còn lại"| qa["SCR-02 QUA_TAI · tổng đỏ<br/>task làm vượt và task sau nó: chấm VUOT_NGUONG"]
  qa --> qa3>"MSG-03 · Tooltip chấm cảnh báo<br/>Chỉ còn {X} trống"]
  qa --> qa4>"MSG-04 · Tooltip tổng<br/>Việc chưa xong vượt {Y} so với thời gian trống còn lại ({X})"]
  dq -->|"(b) task theo lịch chung > ngưỡng khối lượng"| qb["SCR-02 QUA_TAI · tổng đỏ<br/>task theo lịch chung vượt: chấm VUOT_NGUONG"]
  qb --> qb28>"MSG-28 · Tooltip chấm cảnh báo<br/>Vượt ngưỡng khối lượng {X} của lịch làm việc chung"]
  qb --> qb29>"MSG-29 · Tooltip tổng<br/>Việc theo lịch làm việc chung ({Y}) vượt ngưỡng khối lượng ({X})"]
  p1 -->|"A3 · không còn thời gian trống: họp kín EC-18<br/>hoặc hôm nay đã qua giờ kết thúc làm"| a3["Sức chứa còn lại = 0<br/>mọi task chưa xong có planned VUOT_NGUONG"]
  a3 --> a3m>"MSG-03 · Tooltip chấm cảnh báo<br/>Chỉ còn {X} trống · X = 0:00"]
  p1 -->|"A9 · ngày không có trong lịch chung"| a9["Giờ làm = các khung channel có ngày đó"]
  a9 -->|"không có khung nào: giờ làm = 0"| a3
  a9 -->|"ngày không có trong lịch của task"| a9b["Projection từ 09:00 giả định"]
  a9b --> a2
  p1 -->|"A2 · projection vượt giờ kết thúc làm của lịch của task"| a2["Xếp tiếp sau giờ kết thúc BR-06<br/>task và ngày cờ VUOT_GIO_LAM, đồng hồ cạnh tổng"]
  a2 --> a2m>"MSG-25 · Tooltip<br/>Vượt giờ làm: việc cuối dự kiến xong lúc {giờ}, sau giờ kết thúc {giờ kết thúc}"]
  a2 -->|"xét thêm VUOT_NGUONG"| dq
  p1 -->|"A7 · tắt Hiện projection"| a7["Card KHONG_GIO, không cờ VUOT_GIO_LAM<br/>tổng và cảnh báo quá tải vẫn tính"]
  a7 --> dq

  class p1,s1 happy
  class a11,dq,qa,qb,a3,a9,a9b,a2,a7 alt
  class qa3,qa4,qb28,qb29,a3m,a2m warn
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
| A1 | Sự kiện từ chối / free / cả ngày | Không trừ thời gian trống | – |
| A2 | Projection vượt giờ kết thúc làm | Cờ `VUOT_GIO_LAM`; thêm `VUOT_NGUONG` nếu quá tải | MSG-25 (+ MSG-03 / MSG-28) |
| A3 | Không còn thời gian trống | Sức chứa 0, mọi task có planned `VUOT_NGUONG` | MSG-03 |
| A4 | Timebox vắt qua mốc đầu ngày | Tính cho ngày bắt đầu | – |
| A5 | Ngày chuyển giờ mùa | Phút thực, giờ hợp lệ kế tiếp | – |
| A6 | Sự kiện dời / xoá ở lịch ngoài | Tính lại ngày cũ và mới | – |
| A7 | Tắt "Hiện projection" | Không giờ dự kiến; quá tải vẫn tính | MSG-04 / MSG-29 nếu quá tải |
| A8 | Timebox liên kết sự kiện | Trừ một lần theo sự kiện gốc | – |
| A9 | Ngày không có trong lịch chung | Giờ làm theo khung channel; không có khung → như A3 | MSG-03, MSG-25 |
| A10 | Thời gian trôi qua ở hôm nay | Có thể chuyển `QUA_TAI` | MSG-03 / MSG-04 |
| A11 | Có khung giờ channel | Sức chứa theo hợp lịch; ngưỡng chỉ cho task lịch chung | MSG-03 / 04 (a), MSG-28 / 29 (b) |
| E1 | Không lấy được sự kiện lịch | Cờ `CHUA_TINH_LICH` | MSG-18 |
| E2 | Tính > 200 ms | Tính nền, giữ kết quả cũ | – |

---

## UC-06 Lọc theo channel

**Mở đầu:** đang ở Home / Today / Calendar views. **Thành công:** chỉ card thuộc bộ lọc hiển thị, bộ lọc lưu trên thiết bị. **Thất bại:** bộ lọc không đổi.

### Happy case

```mermaid
flowchart TD
  start(["SCR-03 Thanh công cụ<br/>Home, Today hoặc Calendar view"])
  u1[/"Bấm nút lọc hoặc Shift+F"/]
  s1["SCR-06 Bộ lọc channel"]
  u2[/"Chọn Tất cả, một context<br/>hoặc tích từng channel"/]
  p1[["Ẩn card ngoài bộ lọc BR-15<br/>tổng, tiến độ, cảnh báo vẫn tính toàn bộ<br/>lưu bộ lọc trên thiết bị"]]
  m1>"MSG-12 · Thanh công cụ<br/>Đang lọc: {n} channel · Bỏ lọc"]
  ok(["Chỉ card thuộc bộ lọc hiển thị"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> m1 ==> ok

  class start,u1,s1,u2,p1,m1 happy
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
  s1["SCR-06 Bộ lọc channel"]
  u2[/"Chọn bộ lọc"/]
  p1[["Ẩn card ngoài bộ lọc"]]
  m1>"MSG-12 · Thanh công cụ · Bỏ lọc"]
  ok(["Board đang lọc"])
  s1 ==> u2 ==> p1 ==> m1 ==> ok

  s1 -->|"A1 · Quản lý channel"| a1x{{"→ G02 · UC-06"}}
  m1 -->|"A2 · bấm Bỏ lọc"| a2(["Về Tất cả"])
  ok -->|"A3 · tạo task khi đang lọc một channel"| a3["Ô soạn: channel mặc định<br/>= channel đang lọc, giả định"]
  a3 --> a3x{{"→ G02 · UC-01"}}
  g02(["G02 · channel trong bộ lọc bị xoá / ẩn"]) -->|"A4"| a4[["Bỏ channel đó khỏi bộ lọc"]]
  a4 --> d4{"Bộ lọc còn rỗng?"}
  d4 -->|"có"| a2
  d4 -->|"không"| p1

  s1 -.->|"E1 · không tải được danh sách channel"| e1["SCR-06 dùng danh sách trên máy<br/>lọc trên dữ liệu đã tải"]
  e1 -.-> u2

  class s1,u2,p1,m1 happy
  class a2,a3,g02,a4,d4 alt
  class a1x,a3x link
  class e1 sync
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
| A1 | "Quản lý channel" | Context & channel → [G02 UC-06](g02-quan-ly-task.md#uc-06-quản-lý-context-và-channel) | – |
| A2 | Bấm "Bỏ lọc" | Tất cả | – |
| A3 | Tạo task khi đang lọc | Channel mặc định = channel đang lọc `[giả định]` → [G02 UC-01](g02-quan-ly-task.md#uc-01-tạo-task) | – |
| A4 | Channel trong bộ lọc bị xoá / ẩn | Bỏ khỏi bộ lọc; rỗng → Tất cả | – |
| E1 | Không tải được danh sách channel | Dùng danh sách trên máy | – |

---

## UC-07 Tìm kiếm task

**Mở đầu:** người dùng đã đăng nhập. **Thành công:** danh sách kết quả hiện, bấm kết quả mở chi tiết task. **Thất bại:** giữ kết quả cũ, hiện lỗi.

### Happy case

```mermaid
flowchart TD
  start(["Khung app · bất kỳ màn nào"])
  u1[/"Ctrl+F hoặc biểu tượng Search<br/>ở panel phải"/]
  s1["SCR-07 Panel Search<br/>focus ô tìm"]
  u2[/"Gõ từ khoá, tuỳ chọn lọc Ngày, Channel"/]
  p1[["Sau 250 ms ngừng gõ<br/>TaskSearch BR-16"]]
  s2["SCR-07 kết quả: tiêu đề tô sáng, ngày,<br/>#channel, dấu xong, nhãn Lưu trữ"]
  u3[/"Bấm kết quả hoặc ↑/↓ + Enter"/]
  p2[["Mở chi tiết task G02"]]
  d1{"Task trong backlog?"}
  ok(["Chi tiết task mở<br/>board cuộn tới ngày của task"])
  ok2(["Chi tiết task mở<br/>panel Backlog mở G06"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> s2 ==> u3 ==> p2 ==> d1
  d1 ==>|"không"| ok
  d1 ==>|"có"| ok2

  class start,u1,s1,u2,p1,s2,u3,p2,d1 happy
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
  u2[/"Gõ từ khoá"/]
  p1[["TaskSearch"]]
  s2["SCR-07 kết quả"]
  u3[/"Chọn kết quả"/]
  x1{{"→ G02 · UC-02"}}
  u2 ==> p1 ==> s2 ==> u3 ==> x1

  u2 -->|"A1 · truy vấn < 2 ký tự"| a1m>"MSG-11 · Inline<br/>Nhập ít nhất 2 ký tự"]
  a1m -->|"không gọi API"| u2
  s2 -->|"A2 · cuộn tới cuối danh sách"| a2[["Tải trang kế, cursor"]]
  a2 --> s2
  p1 -->|"A3 · mất mạng"| a3["SCR-07 tìm trên dữ liệu trên máy<br/>4 tuần + backlog, ghi chú Kết quả trên máy"]
  a3 --> u3
  u3 -->|"A4 · kết quả là task lưu trữ"| a4["Chi tiết task ở chế độ xem<br/>có nút khôi phục"]
  a4 --> a4x{{"→ G06 · UC-06 A7"}}

  p1 -.->|"E1 · không có kết quả"| e1m>"MSG-02 · Panel Search<br/>Không tìm thấy kết quả. Thử diễn đạt khác."]
  p1 -.->|"E2 · 429"| e2m>"MSG-13 · Panel Search<br/>Đang tìm chậm hơn bình thường, thử lại sau giây lát"]
  e2m -.->|"tự thử lại sau 2 giây"| p1
  p1 -.->|"E3 · 5xx / timeout"| e3["SCR-07 giữ kết quả cũ"]
  e3 -.-> e3m>"MSG-15 · Toast<br/>Chưa tải / lưu được thay đổi. Thử lại"]

  class u2,p1,s2,u3 happy
  class a1m,a2,a4 alt
  class a3 sync
  class x1,a4x link
  class e1m,e2m,e3,e3m err
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
| A1 | Truy vấn < 2 ký tự | Không gọi API | MSG-11 |
| A2 | Cuộn tới cuối | Tải trang kế | – |
| A3 | Mất mạng | Tìm trên máy, ghi chú "Kết quả trên máy" | – (chưa có mã MSG) |
| A4 | Kết quả là task lưu trữ | Chi tiết ở chế độ xem, nút khôi phục → [G06 UC-06](g06-backlog-rollover.md) | – |
| E1 | Không có kết quả | Trạng thái rỗng | MSG-02 |
| E2 | 429 | Tự thử lại sau 2 giây | MSG-13 |
| E3 | 5xx / timeout | Giữ kết quả cũ | MSG-15 |

Bấm kết quả task thường → [G02 UC-02](g02-quan-ly-task.md#uc-02-xem-và-sửa-chi-tiết-task); task backlog → panel Backlog [G06](g06-backlog-rollover.md).

---

## UC-08 Command menu và phím tắt

**Mở đầu:** ứng dụng đang focus; với phím một ký tự: không có ô nhập focus và cài đặt "Phím tắt" bật (BR-17). **Thành công:** lệnh chạy đúng ngữ cảnh; lệnh có tác dụng phụ có Hoàn tác. **Thất bại:** không có lệnh nào chạy.

### Happy case

```mermaid
flowchart TD
  start(["App đang focus"])
  u1[/"Ctrl+K"/]
  s1["SCR-08 Command menu<br/>lệnh theo nhóm BR-18"]
  d1{"Có task đang chọn / hover?"}
  s2["SCR-08 nhóm Thao tác task lên đầu<br/>tiêu đề menu ghi tên task"]
  u2[/"Gõ để lọc không dấu, ↑/↓ chọn, Enter"/]
  p1[["Chạy lệnh, đóng menu"]]
  d2{"Lệnh có tác dụng phụ?"}
  s3["Toast Hoàn tác của chính lệnh đó<br/>ví dụ MSG-05 khi Hoãn 1 ngày"]
  ok(["Lệnh chạy đúng ngữ cảnh"])

  start ==> u1 ==> s1 ==> d1
  d1 ==>|"có"| s2 ==> u2
  d1 ==>|"không"| u2
  u2 ==> p1 ==> d2
  d2 ==>|"có"| s3 ==> ok
  d2 ==>|"không"| ok

  class start,u1,s1,d1,s2,u2,p1,d2,s3 happy
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
  s1["SCR-08 Command menu"]
  u2[/"Gõ lọc, Enter"/]
  p1[["Chạy lệnh"]]
  ok(["Lệnh chạy"])
  s1 ==> u2 ==> p1 ==> ok

  k0(["Board · không có ô nhập focus<br/>cài đặt Phím tắt bật"])
  k0 -->|"A1 · gõ thẳng phím tắt: H, T, P, O, B, Tab, D, S, F,<br/>Shift+F, Shift+C/T/B/A, <, >, Shift+L…<br/>Ctrl+\ panel phải, Ctrl+J Trợ lý, Ctrl+, Cài đặt IA-15"| a1[["Chạy lệnh như bước 4<br/>không mở menu"]]
  a1 --> ok
  a1 -->|"A2 · lần đầu dùng phím tắt"| a2m>"MSG-21 · Toast, một lần / tài khoản<br/>Phím tắt đầu tiên của bạn! Nhấn ? để xem tất cả"]
  k0 -->|"A3 · phím ?"| a3["SCR-09 Bảng phím tắt"]
  a3 -->|"link cài đặt"| a3x{{"→ G01 · UC-06 Cài đặt → Phím tắt"}}
  k0 -->|"A4 · gõ ≥ 4 ký tự trong 1 giây, EC-25"| a4["Khoá phím một ký tự 1 giây<br/>ký tự gõ lúc khoá bị bỏ qua"]
  a4 --> a4e(["Không lệnh nào chạy"])
  a1 -->|"A5 · lệnh thuộc nhóm khác<br/>lệnh chưa có ở 1.0 không hiện"| a5a{{"→ G08 · P, O"}}
  a1 -->|"A5"| a5b{{"→ G07 · F, Space"}}
  in0(["Ô nhập đang focus"]) -->|"A6 · Ctrl+F, Tab"| a6["Giữ hành vi chuẩn của ô nhập trên Windows"]

  u2 -.->|"E1 · không có lệnh khớp"| e1m>"MSG-22 · Command menu<br/>Không có lệnh phù hợp"]
  s1 -.->|"E2 · lệnh cần task, không có task chọn / hover"| e2["Lệnh không hiện trong menu"]
  k0 -.->|"E2 · phím tắt cần task, không có task"| e2b(["Phím tắt không làm gì"])

  class s1,u2,p1 happy
  class k0,a1,a2m,a3,a4,a4e,in0,a6 alt
  class a3x,a5a,a5b link
  class e1m,e2 err
  class ok done
  class e2b fail
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
| A1 | Gõ thẳng phím tắt | Lệnh chạy, không mở menu | Toast của lệnh |
| A2 | Lần đầu dùng phím tắt | Lệnh chạy | MSG-21 |
| A3 | Phím ? | SCR-09; link → Cài đặt Phím tắt [G01 UC-06](g01-tai-khoan.md) | – |
| A4 | Gõ nhanh ≥ 4 ký tự / 1 giây | Khoá phím một ký tự 1 giây | – |
| A5 | Lệnh thuộc nhóm khác | [G08](g08-daily-rituals.md) (P, O), [G07](g07-focus-timer.md) (F, Space); K và Shift+R là lệnh 1.1, không hiện | – |
| A6 | Ctrl+F, Tab trong ô nhập | Hành vi chuẩn của ô nhập. Phím trùng trình duyệt: Bỏ (1.1) | – |
| E1 | Không có lệnh khớp | Danh sách rỗng | MSG-22 |
| E2 | Lệnh cần task, không có task | Lệnh ẩn / phím không làm gì | – |
| E3 | Workspace chỉ đọc | Bỏ (1.1) | – |

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-08 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)".
- [x] Mọi nút màn hình có mã SCR, trừ Today view (SRS chưa đặt mã, ghi chú 2); mọi nút thông báo có mã MSG, trừ hai chỗ SRS chưa đặt mã (ghi chú 3).

**Ghi chú cho brief G04**
1. **UC-01 A9 mâu thuẫn với IA-11.** SRS ghi "cửa sổ < 768 px → 1 cột"; kiến trúc thông tin chốt cửa sổ tối thiểu 800 × 600 và mốc 1280 / 1024 px, nên mốc 768 px không bao giờ xảy ra. Cần chốt mốc nào board chuyển 1 cột.
2. **Today view chưa có mã SCR** (UC-01 A1; IA chỉ dẫn "G04 UC-01 A1, G05 SCR-04"). Panel Tasks (Shift+T) cũng còn là `SCR-N`. Đề xuất đặt mã trong SRS.
3. **Thông báo chưa có mã MSG:** banner "Đang offline" (UC-01 E1, SCR-01 #5) và ghi chú "Kết quả trên máy" (UC-07 A3). Sơ đồ đang vẽ chúng là trạng thái màn; cần thêm MSG để có nguyên văn.
4. **BR-17 mâu thuẫn UC-08 A6.** BR-17: "Ctrl/Cmd+K, Ctrl+F luôn chạy"; UC-08 A6: Ctrl+F trong ô nhập giữ hành vi chuẩn của ô nhập. Cần chốt Ctrl+F khi đang gõ mở Search hay không.
5. **Phím K ở 1.0.** UC-08 A1 và SCR-08 #7 liệt kê "K nghỉ (G07)" không ghi phiên bản; G07 BR-14, BR-17 ghi K là 1.1. Theo UC-08 A5 ("lệnh chưa có ở 1.0 không hiện"), sơ đồ đã bỏ K khỏi danh sách 1.0; đề xuất sửa A1 và SCR-08 #7.
6. **UC-02 E2:** "khung cột rỗng có MSG-15 'Thử lại'" nhưng MSG-15 khai báo nơi hiện là Toast. Cần chốt MSG-15 nằm trong cột hay là toast.
7. **UC-03 A4:** kéo / chọn ngày vào ngày đã có instance cùng series hiện MSG-23; SRS không nói MSG-23 thay MSG-01 hay hiện cùng. Nếu thay thì người dùng mất nút "Hoàn tác" của MSG-01.
8. ~~**UC-03 A7 / BR-09** còn `[giả định]`~~ **Đã sửa 06/11/2026:** theo QC-05 (ngoại lệ timebox liên kết sự kiện), chỉ gỡ liên kết, sự kiện ngoài giữ nguyên; đã ghi ngược vào SRS G04 BR-09, UC-03 A7.
9. **Kéo trong cột (UC-04 A1, A2)** không có toast / MSG; BR-12 nói mọi thao tác BR-10 có Hoàn tác "toast hoặc Ctrl+Z". Cần chốt có toast không.
10. **UC-04 tiền điều kiện** ghi "workspace không chỉ đọc" thiếu nhãn "(1.1)"; BR-20 nói 1.0 không có chế độ chỉ đọc.
11. **UC-03 A3** (thả vào panel Backlog) không ghi thông báo; phụ thuộc G06 UC-01.
