# Flow G03 Task lặp lại

> **Nguồn:** [srs-g03](../../features/srs-g03-task-lap-lai.md) (commit `8fac830`, sửa theo [chốt 09/11/2026](../../review/cau-hoi-chot-flow-2026-11-09.md)) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-bật-lặp-cho-task) | Bật lặp cho task | SCR-01 Picker lặp lại, SCR-06 Dấu lặp trên card | 7 / 7 |
| [UC-02](#uc-02-sinh-instance-job-recurrencegenerate) | Sinh instance (job) | Không có màn riêng; kết quả ở SCR-06 trên board | 2 / 1 |
| [UC-03](#uc-03-xem-và-sửa-một-instance) | Xem và sửa một instance | SCR-02 Banner series (trong G02 SCR-03) | 9 / 3 |
| [UC-04](#uc-04-sửa-series-đổi-tần-suất-đặt-giờ-áp-nội-dung) | Sửa series: đổi tần suất, đặt giờ, áp nội dung | SCR-03 Menu "Sửa series", SCR-01, SCR-07 Bộ chọn giờ bắt đầu | 7 / 4 |
| [UC-05](#uc-05-dừng-lặp--xoá-mọi-instance-chưa-xong) | Dừng lặp / xoá mọi instance chưa xong | SCR-03, SCR-04 Xác nhận xoá, SCR-08 Xác nhận dừng lặp | 4 / 3 |
| [UC-06](#uc-06-xử-lý-instance-trùng-series-trong-một-ngày-qc-06-rollover-g06-phím-d-g04-shutdown-g08) | Instance trùng series trong một ngày (QC-06) | Không có màn riêng; G06 SCR-05 Lưu trữ | 7 / 1 |
| [UC-07](#uc-07-quản-lý-mọi-task-lặp) | Quản lý mọi task lặp | SCR-05 Quản lý mọi task lặp | 2 / 3 |

---

## UC-01 Bật lặp cho task

**Mở đầu:** task Kế hoạch hoặc Backlog, chưa thuộc series đang lặp. **Thành công:** series Đang lặp, task là instance đầu, instance 60 ngày tới đã sinh. **Thất bại:** không có series, task không đổi.

### Happy case

```mermaid
flowchart TD
  start(["Task card hoặc G02 SCR-03 Chi tiết task<br/>task Kế hoạch / Backlog"])
  u1[/"Menu ... chọn Lặp lại<br/>hoặc Ctrl+K → Lặp lại"/]
  s1["SCR-01 Picker lặp lại<br/>mặc định theo startDate BR-03<br/>Lần đầu: ngày"]
  u2[/"Chọn quy tắc, thứ, Mỗi N,<br/>tuỳ chọn giờ Vào khoảng, bấm Lưu"/]
  p1[["Kiểm BR-01<br/>SeriesCreate kèm idempotency key"]]
  p2[["Server tạo series BR-02: weekStart, anchorDate,<br/>instance đầu; sinh đồng bộ 14 ngày đầu"]]
  p3[["Phần còn lại tới 60 ngày · UC-02"]]
  m1>"MSG-01 · Toast<br/>Task giờ sẽ lặp lại {mô tả quy tắc}, bắt đầu từ {ngày}"]
  ok(["SCR-01 đóng; card có SCR-06 dấu lặp<br/>instance mới hiện trên board qua realtime"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> p2 ==> p3 ==> m1 ==> ok

  class start,u1,s1,u2,p1,p2,p3,m1 happy
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
  u1[/"Menu ... chọn Lặp lại"/]
  s1["SCR-01 Picker lặp lại"]
  u2[/"Chọn quy tắc, bấm Lưu"/]
  p2[["SeriesCreate, BR-02"]]
  m1>"MSG-01 · Toast<br/>Task giờ sẽ lặp lại {mô tả quy tắc}, bắt đầu từ {ngày}"]
  ok(["Card có SCR-06 dấu lặp"])
  u1 ==> s1 ==> u2 ==> p2 ==> m1 ==> ok

  u1 -->|"A3 · task đã thuộc series Đang lặp"| a3{{"→ UC-04 · SCR-01 chế độ Đổi tần suất"}}
  u1 -->|"A4 · task thuộc series Đã dừng"| a4["Tạo series mới từ task này BR-12"]
  a4 --> s1
  s1 -->|"A5 · bấm ra ngoài / Esc"| a5(["SCR-01 đóng, không lưu"])
  u2 -->|"A2 · Hằng tháng ngày 29-31 / Hằng năm 29/2"| a2m>"MSG-04 / MSG-05 · Hint dưới ô ngày<br/>Tháng không có ngày {D} sẽ dùng ngày cuối tháng<br/>Năm không nhuận sẽ dùng ngày 28/2"]
  a2m -->|"vẫn cho lưu"| u2
  u2 -->|"A7 · Hằng tuần, N ≥ 2"| a7m>"MSG-26 · Hint<br/>Tuần tính từ {thứ}; giữ cố định cho task lặp này"]
  a7m --> u2
  p2 -->|"A1 · task trong Backlog"| a1["Instance đầu đặt hôm nay BR-02"]
  a1 -->|"MSG-01 nêu ngày"| m1
  p2 -->|"A6 · ngày dự định không khớp quy tắc"| a6["Instance đầu = ngày khớp đầu tiên sau đó<br/>task dời sang ngày đó BR-02"]
  a6 -->|"MSG-01 nêu ngày"| m1

  class u1,s1,u2,p2,m1 happy
  class a4,a2m,a7m,a1,a6 alt
  class a3 link
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
  u1[/"Menu ... chọn Lặp lại"/]
  s1["SCR-01 Picker lặp lại"]
  u2[/"Chọn quy tắc, bấm Lưu"/]
  p1[["Kiểm BR-01, SeriesCreate"]]
  p2[["Server tạo series BR-02"]]
  ok(["Card có SCR-06 dấu lặp"])
  u1 ==> s1 ==> u2 ==> p1 ==> p2 ==> ok

  u1 -.->|"E7 · task đã Hoàn thành"| e7m>"MSG-22 · Tooltip trên mục Lặp lại disabled<br/>Task đã hoàn thành không bật lặp được<br/>API trả 409 TASK_COMPLETED"]
  u2 -.->|"E1 · Mỗi N ngoài 1-99"| e1m>"MSG-02 · Inline tại ô<br/>Khoảng lặp từ 1 đến 99<br/>nút Lưu disabled"]
  u2 -.->|"E2 · Hằng tuần, không chọn thứ nào"| e2m>"MSG-03 · Inline<br/>Chọn ít nhất một thứ trong tuần<br/>nút Lưu disabled"]
  p1 -.->|"E3 · đã có 200 series đang lặp, LIMIT_SERIES"| e3m>"MSG-14 · Inline ngay dưới ô Lặp, SCR-01 #10<br/>Bạn đã có {n} task lặp đang chạy, tối đa {max}. Dừng bớt trong #quot;Quản lý mọi task lặp#quot;"]
  e3m -.->|"bấm link Quản lý mọi task lặp"| e3x{{"→ UC-07 · Cài đặt, Task lặp lại"}}
  p1 -.->|"E4 · mất mạng"| e4["Hàng đợi trên máy QC-08<br/>card có dấu chờ đồng bộ<br/>instance chỉ hiện khi server sinh xong"]
  e4 -.->|"có mạng, gửi lại cùng idempotency key"| p2
  e4 -.->|"E8 · đã bật lặp trên thiết bị khác,<br/>409 ALREADY_REPEATING"| e8m>"MSG-23 · Toast<br/>Task này đã được đặt lặp lại trên thiết bị khác, đã tải lại"]
  e8m -.-> e8(["Bỏ lệnh khỏi hàng đợi<br/>tải lại task và series"])
  p1 -.->|"E5 · 5xx / timeout"| e5m>"MSG-12 QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e5m -.->|"Thử lại"| p1
  e5m -.-> fail(["Task không đổi, không có series"])

  class u1,s1,u2,p1,p2 happy
  class e7m,e1m,e2m,e3m,e8m,e5m err
  class e3x link
  class e4 sync
  class ok done
  class e8,fail fail
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
| A1 | Task trong Backlog | Instance đầu hôm nay | MSG-01 (nêu ngày) |
| A2 | Ngày 29-31 / 29/2 | Vẫn lưu, có ghi chú | MSG-04 / MSG-05 |
| A3 | Task đã thuộc series đang lặp | [→ UC-04](#uc-04-sửa-series-đổi-tần-suất-đặt-giờ-áp-nội-dung) | – |
| A4 | Task thuộc series đã dừng | Series mới từ task này | MSG-01 |
| A5 | Bấm ra ngoài / Esc | SCR-01 đóng, không lưu | – |
| A6 | Ngày dự định không khớp quy tắc | Task dời sang ngày khớp đầu tiên | MSG-01 (nêu ngày) |
| A7 | Hằng tuần, N ≥ 2 | Hint ngày đầu tuần | MSG-26 |
| E1 | Mỗi N ngoài 1-99 | Lưu disabled | MSG-02 |
| E2 | Hằng tuần không chọn thứ | Lưu disabled | MSG-03 |
| E3 | Đã có 200 series | Chặn, MSG-14 dưới ô Lặp; link mở Cài đặt → Task lặp lại [→ UC-07](#uc-07-quản-lý-mọi-task-lặp) (C16) | MSG-14 |
| E4 | Mất mạng | Hàng đợi, card chờ đồng bộ | – |
| E5 | 5xx / timeout | Task không đổi, Thử lại | MSG-12 (QC-MSG-01) |
| E6 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E7 | Task đã Hoàn thành | Mục Lặp lại disabled | MSG-22 |
| E8 | Đã bật lặp trên thiết bị khác | Bỏ lệnh, tải lại | MSG-23 |

---

## UC-02 Sinh instance (job `recurrence.generate`)

**Mở đầu:** job hệ thống, có series Đang lặp với `generatedUntil` < hôm nay + 60 ngày. **Thành công:** mỗi ngày khớp quy tắc tới hôm nay + 60 ngày (trừ ngày ngoại lệ) có đúng một instance. **Thất bại:** series giữ `generatedUntil` cũ, lần chạy sau sinh bù.

### Happy case

```mermaid
flowchart TD
  start(["Job recurrence.generate mỗi giờ<br/>người dùng vừa qua mốc đầu ngày QC-01<br/>hoặc ngay sau UC-01, UC-04"])
  p1[["Chọn series Đang lặp có<br/>generatedUntil < hôm nay + 60 ngày"]]
  p2[["Tính ngày khớp quy tắc BR-03 trong<br/>(max(generatedUntil, hôm qua), hôm nay + 60]<br/>loại ngày ngoại lệ BR-15"]]
  p3[["Mỗi ngày: chèn instance theo mẫu BR-05<br/>startDate = seriesDate, không timebox<br/>ngày gốc đã có instance thì bỏ qua BR-04"]]
  p4[["Cập nhật generatedUntil<br/>nhật ký system: Tạo từ series {tiêu đề} BR-13"]]
  p5[["Phát task.upserted, day.recomputed G04"]]
  ok(["Board: instance mới có SCR-06 dấu lặp<br/>trên các ngày tới"])

  start ==> p1 ==> p2 ==> p3 ==> p4 ==> p5 ==> ok

  class start,p1,p2,p3,p4,p5 happy
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
  start(["Job recurrence.generate"])
  p2[["Tính ngày khớp quy tắc, loại ngày ngoại lệ"]]
  p3[["Chèn instance theo mẫu"]]
  p4[["Cập nhật generatedUntil"]]
  ok(["Board có instance mới"])
  start ==> p2 ==> p3 ==> p4 ==> ok

  start -->|"A2 · job không chạy nhiều ngày"| a2["Sinh bù khoảng còn thiếu từ hôm nay<br/>ngày trong quá khứ không sinh C14"]
  a2 --> p2
  p2 -->|"A3 · không có ngày nào trong khoảng"| a3["Chỉ cập nhật generatedUntil"]
  a3 --> p4

  p3 -.->|"E1 · lỗi CSDL giữa chừng"| e1[["Rollback series đó<br/>thử lại 3 lần, backoff 1-5-15 phút"]]
  e1 -.->|"thử lại thành công"| p4
  e1 -.->|"quá 3 lần"| fail(["Ghi log cảnh báo<br/>series giữ generatedUntil cũ, lần chạy sau sinh bù"])

  class start,p2,p3,p4 happy
  class a2,a3 alt
  class e1 err
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
| A1 | Lập lịch cứng (G05) | Bỏ (1.1) | – |
| A2 | Job không chạy nhiều ngày | Sinh bù từ hôm nay | – |
| A3 | Không có ngày nào trong khoảng | Chỉ cập nhật `generatedUntil` | – |
| A4 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E1 | Lỗi CSDL | Rollback series, thử lại 3 lần, rồi log cảnh báo | – |
| E2 | (SRS đã bỏ) | – | – |

---

## UC-03 Xem và sửa một instance

**Mở đầu:** instance không ở Đã xoá. **Thành công:** trường đã sửa chỉ đổi trên instance này. **Thất bại:** trường giữ giá trị cũ.

### Happy case

```mermaid
flowchart TD
  start(["Board · task card có SCR-06 dấu lặp"])
  u1[/"Mở chi tiết instance<br/>bấm tiêu đề card hoặc Ctrl+Enter"/]
  p1[["TaskDetail kèm series:<br/>quy tắc, vị trí, Trước / Sau, nextDate"]]
  s1["G02 SCR-03 Chi tiết task<br/>SCR-02 Banner series ở đầu"]
  m1>"MSG-06 · Banner<br/>Task này lặp lại {mô tả quy tắc}. Đây là lần {thứ n} của series"]
  u2[/"Sửa trường bất kỳ"/]
  p2[["API G02 cho riêng instance<br/>không hỏi phạm vi, mẫu series không đổi BR-07"]]
  ok(["Chỉ instance này thay đổi"])

  start ==> u1 ==> p1 ==> s1 ==> m1 ==> u2 ==> p2 ==> ok

  class start,u1,p1,s1,m1,u2,p2 happy
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

### Nhánh thay thế và lỗi: banner series

```mermaid
flowchart TD
  s1["G02 SCR-03 · SCR-02 Banner series"]
  u2[/"Sửa trường"/]
  s1 ==> u2

  s1 -->|"A1 · bấm Trước / Sau"| a1["SCR-02 · chi tiết instance liền kề<br/>instance đầu: Trước disabled"]
  a1 --> s1
  a1 -.->|"E2 · instance liền kề đã bị xoá"| e2["Bỏ qua, mở instance kế tiếp còn tồn tại"]
  e2 -.-> s1
  s1 -->|"A2 · lần kế tiếp ngoài 60 ngày"| a2m>"MSG-20 · Tooltip trên Sau disabled<br/>Lần kế tiếp: {ngày}"]
  s1 -->|"A3 · bấm Sửa series"| a3["SCR-03 Menu Sửa series"]
  a3 --> a3x{{"→ UC-04 · UC-05 · UC-07"}}
  s1 -->|"A5 · series Đã dừng"| a5m>"MSG-15 · Banner<br/>Series này đã dừng lặp<br/>ẩn Sửa series; Trước / Sau vẫn hiện, bỏ qua instance đã xoá"]
  a5m --> a1
  e3s(["Board · mở chi tiết instance"]) -.->|"E3 · 404 NOT_FOUND, đã xoá ở thiết bị khác"| e3m>"MSG-17 · Toast<br/>Task hoặc series này không còn tồn tại"]
  e3m -.-> e3(["Không mở chi tiết, gỡ card khỏi board"])
  s1 -->|"A8 · instance đã tách khỏi series"| a8m>"MSG-25 · Banner thay SCR-02<br/>Lần này đã tách khỏi series #quot;{tiêu đề}#quot; do đổi tần suất<br/>không có Sửa series, Trước / Sau"]

  class s1,u2 happy
  class a1,a2m,a3,a5m,a8m alt
  class a3x link
  class e2,e3s,e3m err
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

### Nhánh thay thế và lỗi: sửa instance

```mermaid
flowchart TD
  s1["G02 SCR-03 · SCR-02 Banner series"]
  u2[/"Sửa trường bất kỳ"/]
  p2[["API G02 cho riêng instance"]]
  ok(["Chỉ instance này thay đổi"])
  s1 ==> u2 ==> p2 ==> ok

  u2 -->|"A4 · dời sang ngày khác, giữ ngày gốc"| d4{"Ngày đích đã có instance<br/>cùng series?"}
  d4 -->|"không"| p2
  d4 -->|"có · kéo thả / chọn ngày"| a4m>"MSG-21 · Toast<br/>Ngày này đã có {tên series}"]
  a4m --> ok
  d4 -->|"có · phím D"| a4d["Instance chuyển Lưu trữ lý do skipped<br/>toast Hoàn tác là G04 MSG-24"]
  a4d --> a4x{{"→ G04 · UC-03"}}
  u2 -->|"A6 · hoàn thành instance ngày tương lai"| a6["Giữ nguyên ngày dự định<br/>G02 BR-08 d"]
  a6 --> a6x{{"→ G02 · UC-03"}}
  u2 -->|"A7 · xoá instance"| a7[["Theo G02 UC-04 A4<br/>ngày gốc thành ngày ngoại lệ BR-15"]]
  a7 --> a7x{{"→ G02 · UC-04"}}
  u2 -->|"A9 · đổi giờ / thời lượng timebox"| a9["Áp theo G05, customized = true Q44<br/>không hỏi phạm vi, mẫu không đổi"]
  a9 --> a9x{{"→ G05 · UC-04"}}

  p2 -.->|"E1 · lỗi khi lưu"| e1["Trường về giá trị cũ"]
  e1 -.-> e1m>"QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]

  class s1,u2,p2 happy
  class d4,a4d,a6,a7,a9 alt
  class a4m warn
  class a4x,a6x,a7x,a9x link
  class e1,e1m err
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
| A1 | Bấm Trước / Sau | Chi tiết instance liền kề | – |
| A2 | Lần kế tiếp ngoài 60 ngày | Sau disabled | MSG-20 |
| A3 | Bấm Sửa series | SCR-03 → [UC-04](#uc-04-sửa-series-đổi-tần-suất-đặt-giờ-áp-nội-dung), [UC-05](#uc-05-dừng-lặp--xoá-mọi-instance-chưa-xong), [UC-07](#uc-07-quản-lý-mọi-task-lặp) | – |
| A4 | Dời instance sang ngày khác | Kéo / chọn ngày: cho phép; phím D: Lưu trữ `skipped` → [G04 UC-03](g04-board-ngay.md#uc-03-di-chuyển-task-giữa-các-ngày) | MSG-21 (kéo / chọn ngày); G04 MSG-24 (phím D) |
| A5 | Series đã dừng | Banner, ẩn Sửa series; Trước / Sau vẫn hiện, bỏ qua instance đã xoá (B16) | MSG-15 |
| A6 | Hoàn thành instance ngày tương lai | Giữ ngày dự định → [G02 UC-03](g02-quan-ly-task.md#uc-03-hoàn-thành--bỏ-hoàn-thành-task) | – |
| A7 | Xoá instance | Thêm ngày ngoại lệ → [G02 UC-04](g02-quan-ly-task.md#uc-04-xoá-hoàn-tác-và-khôi-phục-task) | – |
| A8 | Instance đã tách khỏi series | Banner thay SCR-02 | MSG-25 |
| A9 | Đổi giờ / thời lượng timebox | `customized` → [G05 UC-04](g05-lich-timebox.md#uc-04-dời-đổi-thời-lượng-gỡ-timebox) | – |
| E1 | Lỗi khi lưu | Giá trị cũ | QC-MSG-01 (G02 MSG-10) |
| E2 | Instance liền kề đã bị xoá | Mở instance kế tiếp còn tồn tại | – |
| E3 | Mở instance đã bị xoá ở thiết bị khác | Không mở, gỡ card (C11) | MSG-17 |

---

## UC-04 Sửa series: đổi tần suất, đặt giờ, áp nội dung

**Mở đầu:** series Đang lặp, có mạng; người dùng đang mở một instance, hoặc ở dòng SCR-05 (chỉ Đổi tần suất). **Thành công:** quy tắc / giờ / mẫu cập nhật, instance bị ảnh hưởng cập nhật theo bảng phạm vi (BR-08). **Thất bại:** series và instance không đổi.

### Happy case

```mermaid
flowchart TD
  start(["G02 SCR-03 chi tiết instance<br/>SCR-02 Banner series"])
  u1[/"Bấm Sửa series"/]
  s1["SCR-03 Menu Sửa series"]
  u2[/"Chọn Đổi tần suất"/]
  s2["SCR-01 Picker lặp lại<br/>quy tắc hiện tại"]
  u3[/"Đổi quy tắc, bấm Lưu"/]
  p1[["SeriesUpdate kèm If-Match version<br/>áp BR-08 b theo bảng phạm vi, so ngày gốc"]]
  p2[["Sinh instance theo quy tắc mới · UC-02"]]
  m1>"MSG-07 · Toast<br/>Đã đổi tần suất, {n} lần sắp tới được cập nhật · Hoàn tác"]
  ok(["Instance tương lai theo quy tắc mới trên board"])

  start ==> u1 ==> s1 ==> u2 ==> s2 ==> u3 ==> p1 ==> p2 ==> m1 ==> ok

  class start,u1,s1,u2,s2,u3,p1,p2,m1 happy
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
  s1["SCR-03 Menu Sửa series"]
  s2["SCR-01 Picker lặp lại"]
  u3[/"Đổi quy tắc, bấm Lưu"/]
  p1[["SeriesUpdate, BR-08 b"]]
  m1>"MSG-07 · Toast<br/>Đã đổi tần suất, {n} lần sắp tới được cập nhật · Hoàn tác"]
  ok(["Instance theo quy tắc mới"])
  s1 ==> s2 ==> u3 ==> p1 ==> m1 ==> ok

  s1 -->|"A1 · Cập nhật mọi instance chưa xong theo task này"| a1[["SeriesApplyFrom id instance đang mở<br/>BR-08 c, subtask gộp theo tiêu đề"]]
  a1 --> a1m>"MSG-08 · Toast<br/>Đã cập nhật {n} lần chưa xong theo task này · Hoàn tác"]
  s1 -->|"A2 · Đặt giờ bắt đầu"| a2["SCR-07 Bộ chọn giờ bắt đầu<br/>bước 15 phút, Xoá giờ"]
  a2 --> a2p[["SeriesUpdate approxTime, BR-08 e"]]
  a2p --> a2m>"MSG-18 · Toast<br/>Đã đặt giờ {giờ} cho các lần chưa xong · Hoàn tác"]
  u3 -->|"A4 · quy tắc mới giống quy tắc cũ"| a4(["SCR-01 đóng, không gọi API"])
  p1 -->|"A5 · instance quá khứ, hôm nay, đã xong,<br/>Lưu trữ, Đã xoá"| a5["Giữ nguyên EC-29, C12"]
  a5 --> m1
  p1 -->|"A6 · instance tương lai đã dời / sửa riêng /<br/>chạy timer / có thời gian thực tế, ngày gốc không khớp"| a6[["Dừng timer nếu đang chạy<br/>giữ instance, tách khỏi series BR-17"]]
  a6 --> a6m>"MSG-07 dòng 1, MSG-24 dòng 2 · Một toast QC-13<br/>Đã đổi tần suất, {n} lần sắp tới được cập nhật · Hoàn tác<br/>{k} lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại"]
  a7s(["SCR-05 dòng series · menu Đổi tần suất"]) -->|"A7 · không mở instance"| s2
  m1 -->|"A3 · bấm Hoàn tác"| a3[["SeriesUpdate / SeriesApplyFrom kèm undoToken<br/>khôi phục theo BR-09, timer không chạy lại"]]
  a1m -->|"A3"| a3
  a2m -->|"A3"| a3
  a6m -->|"A3"| a3
  a3 --> a3e(["Quy tắc, mẫu, instance về như trước"])

  class s1,s2,u3,p1,m1 happy
  class a1,a1m,a2,a2p,a2m,a5,a6,a3,a3e,a7s alt
  class a6m warn
  class a4 fail
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
  s2["SCR-01 Picker lặp lại"]
  u3[/"Đổi quy tắc, bấm Lưu"/]
  p1[["SeriesUpdate kèm If-Match version"]]
  ok(["Instance theo quy tắc mới"])
  s2 ==> u3 ==> p1 ==> ok

  u3 -.->|"E2 · vi phạm BR-01"| e2m>"MSG-02 / MSG-03 · Inline<br/>Khoảng lặp từ 1 đến 99<br/>Chọn ít nhất một thứ trong tuần"]
  e2m -.-> s2
  p1 -.->|"E1 · 412 VERSION_CONFLICT,<br/>series vừa sửa ở thiết bị khác"| e1[["Tải lại series"]]
  e1 -.-> e1m>"MSG-16 · Toast<br/>Series vừa được sửa trên thiết bị khác, đã tải lại"]
  e1m -.->|"SCR-01 giữ mở với quy tắc mới nhất"| s2
  p1 -.->|"E3 · 5xx / timeout"| e3m>"MSG-12 QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e3m -.-> fail(["Series không đổi"])
  e4s(["SCR-03 hoặc dòng SCR-05"]) -.->|"E4 · mất mạng"| e4m>"MSG-27 · Tooltip trên nút mờ<br/>Cần có mạng để sửa cả chuỗi"]
  e4m -.-> e4(["Không gọi API, series không đổi"])

  class s2,u3,p1 happy
  class e2m,e1,e1m,e3m,e4s,e4m err
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
| A1 | Cập nhật mọi instance chưa xong theo task này | Mẫu và instance trong phạm vi theo instance đang mở | MSG-08 |
| A2 | Đặt giờ bắt đầu | SCR-07 → `approxTime` mới cho mẫu và instance trong phạm vi (C12) | MSG-18 |
| A3 | Bấm Hoàn tác | Về như trước (BR-09) | – |
| A4 | Quy tắc mới giống cũ | SCR-01 đóng, không gọi API | – |
| A5 | Instance quá khứ, hôm nay, đã xong, Lưu trữ, Đã xoá | Giữ nguyên | MSG-07 |
| A6 | Instance đã dời / sửa riêng / có timer, thời gian thực tế, ngày gốc không khớp | Giữ, tách khỏi series (banner MSG-25 ở [UC-03](#uc-03-xem-và-sửa-một-instance) A8) | MSG-07 + MSG-24, một toast hai dòng (QC-13 mục 3) |
| A7 | Đổi tần suất từ dòng SCR-05 | SCR-01 ngay trên dòng, không mở instance (B15) | MSG-07 |
| E1 | VERSION_CONFLICT | Tải lại, SCR-01 giữ mở | MSG-16 |
| E2 | Vi phạm BR-01 | Lưu disabled | MSG-02 / MSG-03 |
| E3 | 5xx / timeout | Series không đổi | MSG-12 (QC-MSG-01) |
| E4 | Mất mạng | Nút mờ, không gọi API (QC-08 mục 7) | MSG-27 |

---

## UC-05 Dừng lặp / xoá mọi instance chưa xong

**Mở đầu:** series Đang lặp, có mạng; SCR-03 đang mở, hoặc dòng series ở SCR-05. **Thành công:** series Đã dừng; instance bị xoá mềm hoặc giữ theo bảng phạm vi BR-08 (a) / (d). **Thất bại:** series Đang lặp, instance không đổi.

### Happy case

```mermaid
flowchart TD
  start(["SCR-02 Banner series · bấm Sửa series"])
  s1["SCR-03 Menu Sửa series"]
  u1[/"Chọn Dừng lặp"/]
  p1[["SeriesStop: stoppedAt, áp BR-08 a<br/>xoá mềm instance tương lai chưa động tới<br/>giữ instance đã dời, sửa riêng, có thời gian thực tế"]]
  p2[["Gỡ instance bị xoá khỏi board<br/>timebox theo QC-05 dòng Xoá"]]
  m1>"MSG-09 · Toast<br/>Đã dừng lặp #quot;{tiêu đề}#quot; · Hoàn tác"]
  ok(["Series Đã dừng<br/>instance còn lại có banner MSG-15"])

  start ==> s1 ==> u1 ==> p1 ==> p2 ==> m1 ==> ok

  class start,s1,u1,p1,p2,m1 happy
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
  s1["SCR-03 Menu Sửa series"]
  u1[/"Chọn Dừng lặp"/]
  p1[["SeriesStop, BR-08 a"]]
  m1>"MSG-09 · Toast<br/>Đã dừng lặp #quot;{tiêu đề}#quot; · Hoàn tác"]
  ok(["Series Đã dừng"])
  s1 ==> u1 ==> p1 ==> m1 ==> ok

  s1 -->|"A1 · Xoá mọi instance chưa xong và dừng lặp"| a1["SCR-04 Xác nhận xoá instance chưa xong"]
  a1 --> a1m>"MSG-10 · Dialog<br/>Xoá {n} lần chưa xong của #quot;{tiêu đề}#quot; và dừng lặp? Các lần đã xong<br/>và các lần đã có thời gian thực tế được giữ lại. Task xoá nằm trong Thùng rác 30 ngày"]
  a1m -->|"Huỷ"| a1c(["SCR-04 đóng, không thay đổi"])
  a1m -->|"Xoá và dừng lặp"| a1p[["SeriesStop deleteIncomplete=true<br/>BR-08 d, ngày ngoại lệ BR-15"]]
  a1p --> a1t>"MSG-11 · Toast<br/>Đã xoá {n} lần và dừng lặp · Hoàn tác"]
  p1 -->|"A2 · instance trong phạm vi đang chạy timer"| a2[["Dừng timer G07<br/>instance có thời gian thực tế: giữ BR-17"]]
  a1p -->|"A2"| a2
  a2 --> a2m>"MSG-09 / MSG-11 dòng 1, MSG-24 dòng 2 · Một toast QC-13<br/>{k} lần đã dời, sửa riêng hoặc có thời gian thực tế được giữ lại"]
  p1 -->|"có instance được giữ, bước 3"| a2m
  m1 -->|"A3 · bấm Hoàn tác"| a3[["Khôi phục instance, series Đang lặp BR-09<br/>timer đã dừng không chạy lại"]]
  a1t -->|"A3"| a3
  a2m -->|"A3"| a3
  a3 --> a3e(["Series Đang lặp như trước"])
  a4s(["SCR-05 dòng series · menu Dừng lặp"]) -->|"A4 · không mở instance"| a4["SCR-08 Xác nhận dừng lặp"]
  a4 --> a4m>"MSG-28 · Dialog<br/>Dừng lặp #quot;{tiêu đề}#quot;? {n} lần sắp tới sẽ bị xoá. Các lần đã dời,<br/>sửa riêng hoặc có thời gian thực tế được giữ lại"]
  a4m -->|"Dừng lặp"| p1
  a4m -->|"Huỷ"| a4c(["SCR-08 đóng, không thay đổi"])

  class s1,u1,p1,m1 happy
  class a1,a1m,a1p,a1t,a2,a3,a3e,a4s,a4,a4m alt
  class a2m warn
  class ok done
  class a1c,a4c fail
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
  s1["SCR-03 Menu Sửa series"]
  u1[/"Chọn Dừng lặp"/]
  p1[["SeriesStop, BR-08 a"]]
  a1p[["SeriesStop deleteIncomplete=true"]]
  ok(["Series Đã dừng"])
  s1 ==> u1 ==> p1 ==> ok
  s1 -->|"A1 · Xoá và dừng lặp"| a1p

  p1 -.->|"E1 · 409 SERIES_STOPPED, đã dừng ở thiết bị khác"| e1m>"MSG-15 · Banner<br/>Series này đã dừng lặp"]
  a1p -.->|"E1"| e1m
  e1m -.-> e1(["Làm mới chi tiết instance"])
  p1 -.->|"E2 · 5xx / timeout"| e2m>"MSG-12 QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  a1p -.->|"E2"| e2m
  e2m -.-> e2(["Không xoá instance nào<br/>series Đang lặp"])
  e3s(["SCR-03 hoặc dòng SCR-05"]) -.->|"E3 · mất mạng"| e3m>"MSG-27 · Tooltip trên nút mờ<br/>Cần có mạng để sửa cả chuỗi"]
  e3m -.-> e3(["Không gọi API, series Đang lặp"])

  class s1,u1,p1 happy
  class a1p alt
  class e1m,e2m,e3s,e3m err
  class ok done
  class e1,e2,e3 fail
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
| A1 | Xoá mọi instance chưa xong và dừng lặp | SCR-04 → "Xoá và dừng lặp" (C13) → xoá mềm, ngày ngoại lệ, series Đã dừng | MSG-10, MSG-11 |
| A2 | Instance đang chạy timer | Dừng timer, giữ instance có thời gian thực tế | MSG-24, dòng 2 của toast MSG-09 / MSG-11 (QC-13 mục 3) |
| A3 | Bấm Hoàn tác | Series Đang lặp, instance khôi phục | – |
| A4 | Dừng lặp từ dòng SCR-05 | SCR-08 → như luồng chính, không mở instance (B15) | MSG-28, MSG-09 |
| E1 | Series đã dừng ở thiết bị khác | Làm mới | MSG-15 |
| E2 | 5xx / timeout | Không xoá gì | MSG-12 (QC-MSG-01) |
| E3 | Mất mạng | Nút mờ, không gọi API (QC-08 mục 7) | MSG-27 |

---

## UC-06 Xử lý instance trùng series trong một ngày (QC-06; rollover G06, phím D G04, shutdown G08)

**Mở đầu:** job rollover sau mốc đầu ngày, có instance chưa xong ngày dự định < hôm nay; hoặc một đường đổi ngày đưa instance vào ngày D đã có instance cùng series. **Thành công:** đường tự động / hàng loạt không để hai instance cùng series trong một ngày; đường thủ công cho phép, có cảnh báo. **Thất bại:** instance giữ nguyên, lượt sau xử lý lại.

G06 thực thi rollover: xem [G06 UC-04](g06-backlog-rollover.md#uc-04-rollover-hằng-ngày-job-rollover).

### Happy case

```mermaid
flowchart TD
  start(["Job rollover G06 lúc mốc đầu ngày"])
  p1[["Nhóm instance chưa xong quá khứ theo seriesId"]]
  p2[["Hôm nay đã có instance của series QC-06 mục 1<br/>mọi instance quá khứ: Lưu trữ,<br/>archiveReason = skipped BR-10"]]
  p3[["Nhật ký system: Bị bỏ qua vì đã có lần lặp hôm nay<br/>không có toast; phát task.upserted"]]
  m1>"G06 MSG-13 · Nhãn trong Lưu trữ<br/>Đã bỏ qua"]
  ok(["Hôm nay chỉ có một instance của series<br/>instance quá khứ trong G06 SCR-05 Lưu trữ"])

  start ==> p1 ==> p2 ==> p3 ==> m1 ==> ok

  class start,p1,p2,p3,m1 happy
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

### Nhánh thay thế và lỗi: rollover

```mermaid
flowchart TD
  start(["Job rollover G06 lúc mốc đầu ngày"])
  p1[["Nhóm instance quá khứ theo seriesId"]]
  d1{"Hôm nay đã có instance<br/>của series? QC-06 mục 1"}
  p2[["Mọi instance quá khứ: Lưu trữ skipped"]]
  ok(["Hôm nay chỉ có một instance của series"])
  start ==> p1 ==> d1
  d1 ==>|"có"| p2 ==> ok

  d1 -->|"A1 · chưa có"| a1[["Instance quá khứ mới nhất rollover về hôm nay<br/>instance cũ hơn: skipped BR-10"]]
  a1 --> ok
  p1 -->|"A2 · series Đã dừng"| a2["Không áp BR-10<br/>rollover như task thường"]
  p1 -->|"A6 · instance đã tách khỏi series"| a6["Không áp QC-06<br/>rollover như task thường"]
  p1 -->|"A7 · instance đã sửa riêng<br/>hoặc có thời gian thực tế"| a7["Không lưu trữ skipped BR-10<br/>rollover như task thường"]
  a2 --> x1{{"→ G06 · UC-04"}}
  a6 --> x1
  a7 --> x1

  p2 -.->|"E1 · lỗi giữa chừng"| e1[["Rollback theo người dùng<br/>G06 BR-18: thử lại lượt sau, 3 lần lỗi THAT_BAI"]]
  e1 -.->|"chạy bù khi mở app, G06 BR-19"| e1x{{"→ G06 · UC-07"}}
  e1 -.-> fail(["Instance giữ nguyên<br/>lần chạy sau xử lý lại"])

  class start,p1,d1,p2 happy
  class a1,a2,a6,a7 alt
  class x1,e1x link
  class e1 err
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

### Nhánh thay thế: đường đổi ngày khác

```mermaid
flowchart TD
  start2(["Một đường đổi ngày đưa instance vào ngày D<br/>đã có instance cùng series"])
  d2{"Đường nào?"}
  start2 --> d2

  d2 -->|"A3 · khôi phục instance skipped từ Lưu trữ<br/>hoặc instance từ Thùng rác"| a35m>"MSG-21 · Toast<br/>Ngày này đã có {tên series}"]
  d2 -->|"A5 · kéo thả hoặc chọn ngày G04"| a35m
  a35m --> a35(["Cho phép, hai instance cùng ngày<br/>QC-06 mục 3"])
  a35 --> a3x{{"→ G06 · UC-06 · G02 · UC-04 · G04 · UC-03"}}
  d2 -->|"A4 · phím D G04, shutdown Ngày mai G08<br/>kể cả Áp dụng cho tất cả"| a4["Instance được đưa vào: Lưu trữ skipped QC-06 mục 2<br/>toast Hoàn tác là G04 MSG-24 / G08, G03 không định nghĩa"]
  a4 --> a4x{{"→ G04 · UC-03 · G08 · UC-02"}}

  class start2,d2,a4 alt
  class a35m warn
  class a35 done
  class a3x,a4x link
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
| A1 | Series chưa có instance hôm nay | Instance mới nhất rollover, cũ hơn `skipped` | – |
| A2 | Series đã dừng | Rollover như task thường → [G06 UC-04](g06-backlog-rollover.md#uc-04-rollover-hằng-ngày-job-rollover) | – |
| A3 | Khôi phục từ Lưu trữ / Thùng rác vào ngày đã có instance | Cho phép → [G06 UC-06](g06-backlog-rollover.md#uc-06-xem-lưu-trữ-khôi-phục-và-xoá-tất-cả), [G02 UC-04](g02-quan-ly-task.md#uc-04-xoá-hoàn-tác-và-khôi-phục-task) | MSG-21 |
| A4 | Phím D / shutdown "Ngày mai" | Lưu trữ `skipped`, toast Hoàn tác của G04 / G08 → [G04 UC-03](g04-board-ngay.md#uc-03-di-chuyển-task-giữa-các-ngày), [G08 UC-02](g08-daily-rituals.md#uc-02-daily-shutdown) | G04 MSG-24 / G08 UC-02 A9 (C15) |
| A5 | Kéo thả / chọn ngày | Cho phép → [G04 UC-03](g04-board-ngay.md#uc-03-di-chuyển-task-giữa-các-ngày) | MSG-21 |
| A6 | Instance đã tách | Không áp QC-06 | – |
| A7 | Instance đã sửa riêng / có thời gian thực tế | Không `skipped`, rollover như task thường (B08) → [G06 UC-04](g06-backlog-rollover.md#uc-04-rollover-hằng-ngày-job-rollover) | – |
| E1 | Lỗi giữa chừng | Rollback, thử lại theo G06 → [G06 UC-07](g06-backlog-rollover.md#uc-07-đảm-bảo-rollover-theo-yêu-cầu-rolloverensure) | – |

---

## UC-07 Quản lý mọi task lặp

**Mở đầu:** SCR-03 hoặc Cài đặt → Task lặp lại. **Thành công:** danh sách series hiển thị, thao tác chọn chạy qua UC-03 / UC-04 / UC-05. **Thất bại:** lỗi tải, giữ dữ liệu lần cuối.

### Happy case

```mermaid
flowchart TD
  start(["SCR-03 Menu Sửa series<br/>hoặc Cài đặt → Task lặp lại"])
  u1[/"Chọn Quản lý mọi task lặp"/]
  p1[["SeriesList status=active"]]
  s1["SCR-05 Quản lý mọi task lặp<br/>tab Đang lặp, sắp theo lần kế tiếp"]
  u2[/"Menu dòng của một series"/]
  x3{{"→ UC-03 · Mở lần kế tiếp"}}
  x4{{"→ UC-04 A7 · Đổi tần suất, SCR-01 ngay trên dòng"}}
  x5{{"→ UC-05 A4 · Dừng lặp, SCR-08 ngay trên dòng"}}

  start ==> u1 ==> p1 ==> s1 ==> u2
  u2 ==> x3
  u2 ==> x4
  u2 ==> x5

  class start,u1,p1,s1,u2 happy
  class x3,x4,x5 link
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
  p1[["SeriesList status=active"]]
  s1["SCR-05 Quản lý mọi task lặp"]
  p1 ==> s1

  s1 -->|"A1 · tab Đã dừng"| a1[["SeriesList status=stopped"]]
  a1 --> a1s["SCR-05 tab Đã dừng<br/>chỉ có Mở instance cuối"]
  a1s --> a1x{{"→ UC-03"}}
  p1 -->|"A2 · không có series"| a2m>"MSG-19 · Empty state<br/>Chưa có task lặp lại nào. Mở menu … của một task → #quot;Lặp lại#quot; để bắt đầu"]

  p1 -.->|"E1 · SeriesList lỗi"| e1m>"QC-MSG-02 · Tại chỗ trong SCR-05<br/>Chưa tải được. Thử lại"]
  e1m -.->|"Thử lại"| p1
  e1m -.-> fail(["Giữ dữ liệu lần cuối"])
  s1 -.->|"E2 · mất mạng"| e2m>"MSG-27 · Tooltip trên Đổi tần suất, Dừng lặp mờ<br/>Cần có mạng để sửa cả chuỗi"]
  e2m -.-> e2(["Dữ liệu lần cuối<br/>Mở lần kế tiếp vẫn dùng được"])
  s1 -.->|"E3 · Mở lần kế tiếp, 404 NOT_FOUND"| e3m>"MSG-17 · Toast<br/>Task hoặc series này không còn tồn tại"]
  a1s -.->|"E3"| e3m
  e3m -.->|"tải lại danh sách"| p1

  class p1,s1 happy
  class a1,a1s,a2m alt
  class a1x link
  class e1m,e2m,e3m err
  class fail,e2 fail
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
| A1 | Lọc Đã dừng | Chỉ có "Mở instance cuối" → [UC-03](#uc-03-xem-và-sửa-một-instance) | – |
| A2 | Không có series | Empty state | MSG-19 |
| E1 | SeriesList lỗi | Giữ dữ liệu lần cuối, Thử lại (C14) | QC-MSG-02 |
| E2 | Mất mạng | Dữ liệu lần cuối, Đổi tần suất / Dừng lặp mờ (QC-08 mục 7) | MSG-27 |
| E3 | Instance / series đã bị xoá ở thiết bị khác | Tải lại danh sách (C11) | MSG-17 |

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-07 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)" / "SRS đã bỏ".
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG.

**Ghi chú cho brief G03**
- ~~SRS mục 10 nói thao tác series cần mạng, nhưng UC-04, UC-05, UC-07 không có nhánh mất mạng và không có MSG tooltip~~ **Đã sửa 09/11/2026 (C10 / A6):** thêm UC-04 E4, UC-05 E3, UC-07 E2 và MSG-27 "Cần có mạng để sửa cả chuỗi"; SCR-03 #7. Đã vẽ.
- ~~MSG-17 (`NOT_FOUND`) không UC nào dùng~~ **Đã sửa 09/11/2026 (C11):** UC-03 E3 (mở instance đã xoá), UC-07 E3 (mở từ danh sách). Đã vẽ.
- ~~UC-04 A2 mở bộ chọn giờ nhưng không có mã SCR~~ **Đã sửa 09/11/2026 (C12):** thêm SCR-07 Bộ chọn giờ bắt đầu.
- ~~Nút xác nhận ở SCR-04 là "Xoá và dừng lặp", UC-05 A1 ghi "Xoá và dừng"~~ **Đã sửa 09/11/2026 (C13):** thống nhất "Xoá và dừng lặp".
- ~~UC-07 cho "Đổi tần suất" / "Dừng lặp" trên dòng SCR-05 trong khi UC-04 cần đang mở instance~~ **Đã sửa 09/11/2026 (B15):** làm ngay trên dòng: Đổi tần suất mở SCR-01 (UC-04 A7), Dừng lặp mở SCR-08 với MSG-28 (UC-05 A4); tiền điều kiện UC-04 sửa theo.
- ~~UC-07 E1 dùng MSG-12 (câu lỗi lưu) cho lỗi tải danh sách~~ **Đã sửa 09/11/2026 (C14 / A1):** UC-07 E1 dùng QC-MSG-02 tại chỗ.
- ~~UC-03 E1 dẫn G02 MSG-10, trong khi G03 MSG-12 có cùng chữ~~ **Đã sửa 09/11/2026 (C14 / A1):** cả hai trỏ về QC-MSG-01; UC-03 E1 hiện QC-MSG-01.
- ~~MSG-24 "kèm" MSG-07 / 09 / 11: một toast hai dòng hay hai toast~~ **Đã sửa 09/11/2026 (A3):** một toast, dòng 1 là MSG-07 / 09 / 11 kèm Hoàn tác, dòng 2 là MSG-24 (QC-13 mục 3).
- ~~UC-03 A5: series đã dừng thì Trước / Sau hiện hay ẩn~~ **Đã sửa 09/11/2026 (B16):** vẫn hiện, bỏ qua instance đã xoá; SCR-02 #3 sửa theo.
- ~~Toast Hoàn tác khi instance vào Lưu trữ `skipped` do phím D / shutdown: G03 không định nghĩa~~ **Đã sửa 09/11/2026 (C15):** G03 chỉ trỏ sang G04 MSG-24 và G08 UC-02 A9 (BR-16, UC-03 A4, UC-06 A4).
- ~~UC-01 E3: MSG-14 hiện ở đâu, "Quản lý mọi task lặp" có phải link~~ **Đã sửa 09/11/2026 (C16):** hiện ngay dưới ô Lặp (SCR-01 #10); là link mở Cài đặt → Task lặp lại.
- Mới 09/11/2026 (B14, B08): "Dừng lặp" chỉ xoá instance tương lai chưa động tới, giữ instance đã dời / sửa riêng / có thời gian thực tế (bảng phạm vi, UC-05 bước 2); instance bị lỡ đã sửa riêng / có thời gian thực tế không bị `skipped` (UC-06 A7).
