# Flow G08 Daily planning và Daily shutdown

> **Nguồn:** [srs-g08](../../features/srs-g08-daily-rituals.md) (commit `8fac830`, sửa theo chốt 09/11/2026) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

Wizard ritual thay vùng chính; sidebar và panel phải vẫn dùng được để kéo task, sự kiện vào (IA-07). Wizard **không** thoát bằng Esc, chỉ bằng × (IA-16, SRS SCR-01 #7, BR-20; chốt 09/11/2026, C31). Wizard không có banner offline riêng: dùng banner offline chung của board (G04 MSG-30, SCR-01 #5, A5).

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-daily-planning-luồng-thủ-công) | Daily planning (luồng thủ công) | SCR-01 khung, SCR-02 … SCR-07 | 18 / 5 (E2 Bỏ (1.1)) |
| [UC-02](#uc-02-daily-shutdown) | Daily shutdown | SCR-01 khung, SCR-08, SCR-09, SCR-10, SCR-07, SCR-11 | 12 / 3 (E1 Bỏ (1.1)) |
| [UC-03](#uc-03-chia-sẻ-kết-quả-ritual) | Chia sẻ kết quả ritual | SCR-07 | 5 / 5 |
| [UC-04](#uc-04-tự-kích-hoạt-và-nhắc-ritual) | Tự kích hoạt và nhắc ritual | SCR-12 lời nhắc | 10 / 2 |
| [UC-05](#uc-05-cài-đặt-ritual-ngày) | Cài đặt ritual ngày | SCR-13 | 3 / 4 (phần ritual tuần của A3 Bỏ (1.1)) |

---

## UC-01 Daily planning (luồng thủ công)

**Mở đầu:** phím P, sidebar "Daily planning", nút "Plan" trên cột ngày D từ hôm nay tới hôm nay + 7 (BR-02), hoặc lời nhắc MSG-01 (UC-04). **Thành công:** phiên `HOAN_TAT`, task ghi chép "Daily planning" đã xong ở D, ảnh chụp kế hoạch đã lưu, chia sẻ đã xếp hàng, màn chuyển tới Home / Today. **Thất bại:** phiên giữ `DANG_LAM` ở bước đang làm, không có task ghi chép; thao tác task đã làm trong các bước vẫn giữ.

### Happy case (1/2): mở wizard, bước 1 – 3

```mermaid
flowchart TD
  start(["Sidebar, phím P, nút Plan trên cột D<br/>hoặc lời nhắc MSG-01"])
  u1[/"Nhấn P, bấm Daily planning, bấm Plan<br/>hoặc Bắt đầu ở lời nhắc"/]
  p1[["RitualGet daily_planning D<br/>chưa có phiên: tạo DANG_LAM, current_step = 1<br/>D = hôm nay: RolloverEnsure G06, BR-06"]]
  s1["SCR-01 Khung wizard · SCR-02 Bước 1 Xem lại hôm qua<br/>header Daily planning · Thứ, dd/mm"]
  u2[/"Mỗi task: Giữ / Dời (D) / Backlog (Z) / Xong (C)<br/>bấm Tiếp hoặc →"/]
  p2[["TaskMove G06, TaskComplete G02<br/>áp ngay, toast Hoàn tác<br/>RitualUpdate current_step = 2"]]
  s2["SCR-03 Bước 2 Thêm task cho hôm nay<br/>trái: danh sách D · phải: tab Lịch, Backlog"]
  u3[/"Kéo sự kiện lịch, task backlog vào D<br/>hoặc gõ task mới · Tiếp"/]
  p3[["TaskCreate G02, TaskMove G06, TimeboxLink G05, BR-07<br/>day.recomputed G04<br/>RitualUpdate current_step = 3"]]
  s3["SCR-04 Bước 3 Kiểm tra khối lượng<br/>planned chưa xong / thời gian trống còn lại, BR-08"]
  m4>"MSG-04 · Callout<br/>Mẹo: một ngày 9–5 có nghỉ trưa thường chỉ đủ cho khoảng 5,5 giờ việc"]
  d3{"Quá tải?<br/>BR-08"}
  m3>"MSG-03 · Inline, thanh so sánh đỏ<br/>Đã lên kế hoạch {X} giờ, chỉ còn {Y} giờ trống<br/>chấm cảnh báo trên task vượt"]
  u4[/"Xem tổng, dời bớt bằng D / Z nếu cần<br/>bấm Tiếp, quá tải không chặn"/]
  p4[["RitualUpdate current_step = 4"]]
  s4["SCR-05 Bước 4 Chốt<br/>tiếp ở Happy case 2/2"]

  start ==> u1 ==> p1 ==> s1 ==> u2 ==> p2 ==> s2 ==> u3 ==> p3 ==> s3 ==> m4 ==> d3
  d3 ==>|"có"| m3 ==> u4
  d3 ==>|"không"| u4
  u4 ==> p4 ==> s4

  class start,u1,p1,s1,u2,p2,s2,u3,p3,s3,m4,d3,u4,p4,s4 happy
  class m3 warn
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

### Happy case (2/2): bước 4 – 6 và hoàn tất

```mermaid
flowchart TD
  s4["SCR-05 Bước 4 Chốt<br/>trái: danh sách task · phải: lịch ngày D"]
  u5[/"Sắp thứ tự bằng kéo / Ctrl+↑↓, kéo task vào lịch để timebox<br/>đặt Giờ kết thúc ngày · Tiếp"/]
  p5[["TimeboxSet G05, tính giờ dự kiến xong BR-09<br/>RitualUpdate current_step = 5, data.endOfDay"]]
  d5{"Dự kiến xong muộn hơn<br/>giờ kết thúc ngày?"}
  m5>"MSG-05 · Inline<br/>Dự kiến xong lúc {giờ} · Kết thúc ngày {giờ}"]
  m6>"MSG-06 · Inline cảnh báo, màu cam<br/>Dự kiến xong lúc {giờ}, muộn hơn giờ kết thúc ngày {n} phút"]
  s5["SCR-06 Bước 5 Daily plan<br/>Kế hoạch hôm nay sinh theo BR-10"]
  u6[/"Đọc / sửa bản kế hoạch, nhập Trở ngại,<br/>chọn Tuỳ chỉnh · Tiếp"/]
  p6[["Lưu nháp vào data BR-05<br/>RitualUpdate current_step = 6"]]
  s6["SCR-07 Bước 6 Chia sẻ<br/>xem trước, chọn đích"]
  x6{{"→ UC-03 Chia sẻ"}}
  u7[/"Bấm Bắt đầu ngày"/]
  p7[["RitualComplete, Idempotency-Key<br/>HOAN_TAT, task ghi chép, planSnapshot BR-11<br/>bản ghi thời gian BR-12, xếp hàng chia sẻ BR-14"]]
  m7>"MSG-09 · Toast<br/>Đã lưu kế hoạch vào task #quot;Daily planning#quot;<br/>có đích email: dòng 2 MSG-10 Đang gửi tới {n} nơi nhận, QC-13 mục 3"]
  ok(["Wizard đóng, chuyển tới Home / Today theo cài đặt<br/>task ghi chép Daily planning đã xong ở ngày D"])

  s4 ==> u5 ==> p5 ==> d5
  d5 ==>|"không"| m5 ==> s5
  d5 ==>|"có · không chặn"| m6 ==> s5
  s5 ==> u6 ==> p6 ==> s6 ==> x6 ==> u7 ==> p7 ==> m7 ==> ok

  class s4,u5,p5,d5,m5,s5,u6,p6,s6,u7,p7,m7 happy
  class m6 warn
  class x6 link
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

### Nhánh thay thế: mở wizard

```mermaid
flowchart TD
  u1[/"P, sidebar, Plan, lời nhắc"/]
  p1[["RitualGet daily_planning D"]]
  s1["SCR-01 · bước current_step"]
  ok(["Bắt đầu ngày · Home / Today"])
  u1 ==> p1 ==> s1 ==> ok

  u1 -->|"A15 · D là ngày nghỉ theo lịch chung"| a15["Không tự mở, không chấm nhắc BR-23<br/>mở tay vẫn chạy luồng chính"]
  a15 --> p1
  p1 -->|"A1 · phiên DANG_LAM ở bước n"| a1["SCR-01 mở về current_step<br/>giữ dữ liệu đã nhập BR-05"]
  a1 --> s1
  p1 -->|"A6 · nút Plan trên cột D từ ngày mai tới hôm nay + 7"| a6["Bước 1 liệt kê task chưa xong của<br/>ngày làm việc liền trước D, BR-06<br/>nút Bắt đầu ngày đổi thành Xong"]
  a6 -->|"đi hết các bước như luồng chính, bấm Xong"| a6b(["RitualComplete, đóng wizard<br/>không chuyển tới Home / Today"])
  p1 -->|"A2 · phiên HOAN_TAT"| a2["SCR-06 chế độ xem bản đã chốt<br/>nút Lên kế hoạch lại"]
  a2 -->|"Lên kế hoạch lại"| a2p[["DANG_LAM bước 1 BR-22<br/>giữ firstCompletedAt, noteTaskId, ảnh chụp lần đầu<br/>mở lại nội dung đã chốt để sửa, B35<br/>hoàn tất lại: ghi đè nội dung task ghi chép cũ, thêm bản ghi thời gian"]]
  a2p --> s1
  a2p -->|"bỏ dở tới hết ngày D"| a2r(["Phiên về HOAN_TAT với nội dung cũ<br/>bỏ bản nháp"])
  p1 -->|"A18 · Daily shutdown hôm trước đã HOAN_TAT"| a18["Bỏ qua bước 1, mở thẳng bước 2 SCR-03<br/>thanh bước hiện bước 1 màu xám, bấm vẫn xem được<br/>BR-06, B32"]
  a18 --> s1
  s1 -->|"A17 · trợ lý AI bật, Plan my day ở đầu bước 1, SCR-01 #9"| g10{{"→ G10 · UC-02 Planning Agent<br/>SCR-02, SCR-03 trong wizard"}}
  g10 -->|"xong, Tiếp ở Review Plan"| a17["Nhảy thẳng tới bước 5 Daily plan SCR-06<br/>current_step = 5, B28"]
  a17 --> ok
  g10 -->|"lỗi, Dừng, Hoàn tác kế hoạch AI: về bước 1"| s1

  p1 -.->|"E1 · D < hôm nay, chưa có phiên"| e1m>"MSG-20 · Toast<br/>Không lên kế hoạch được cho ngày đã qua"]
  e1m -.-> e1(["Không mở wizard"])
  p1 -.->|"E6 · D > hôm nay + 7, RITUAL_DATE_NOT_ALLOWED"| e6m>"MSG-33 · Toast<br/>Chỉ lên kế hoạch được trong 7 ngày tới. Chọn một ngày gần hơn"]
  e6m -.-> e1

  class a6b done
  class u1,p1,s1 happy
  class a15,a1,a6,a2,a2p,a2r,a18 alt
  class a17 ai
  class g10 link
  class e1m,e6m err
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

### Nhánh thay thế: điều hướng, ẩn bước, thoát, ân hạn

```mermaid
flowchart TD
  s1["SCR-01 · bước hiện tại"]
  u2[/"Tiếp hoặc →"/]
  sn["Bước kế tiếp … bước 6 Chia sẻ"]
  p7[["RitualComplete"]]
  ok(["Bắt đầu ngày · Home / Today"])
  s1 ==> u2 ==> sn ==> p7 ==> ok

  u2 -->|"A3 · bước kế tiếp đang AN"| a3["Nhảy qua bước ẩn BR-18<br/>thanh bước hiện bước ẩn màu xám, bấm vẫn xem được"]
  a3 --> sn
  s1 -->|"A4 · ← hoặc Quay lại"| a4["Về bước trước<br/>giữ nguyên dữ liệu các bước"]
  a4 --> s1
  s1 -->|"A10 · Bỏ qua bước này từ lần sau"| a10[["Bước thành AN, lưu ritual.skippedSteps BR-18<br/>vẫn ở bước hiện tại lần này"]]
  a10 --> a10m>"MSG-21 · Toast<br/>Bước #quot;{tên bước}#quot; sẽ được bỏ qua từ lần sau · Hoàn tác"]
  a10m --> s1
  s1 -->|"A5 · bấm ×, Esc không thoát IA-16"| a5[["Lưu current_step, data<br/>không tạo task ghi chép BR-13"]]
  a5 --> a5m>"MSG-16 · Toast<br/>Đã lưu tiến độ. Nhấn {P / O} để làm tiếp"]
  a5m --> a5e(["Wizard đóng, về Home<br/>sidebar Đang dở · bước n / tổng"])
  s1 -->|"A11 · qua mốc đầu ngày D+1 khi đang làm"| a11m>"MSG-30 · Banner SCR-01 #8<br/>Bạn đang hoàn tất {tên ritual} cho {Thứ}, {dd/mm}. Còn {m} phút"]
  a11m --> a11r["Phiên giữ ngày D, bước 1 – 4 vẫn là của D<br/>task bị rollover biến khỏi danh sách qua realtime"]
  a11r -->|"hoàn tất trong 2 giờ ân hạn BR-21"| p7
  a11r -->|"quá ân hạn, RITUAL_GRACE_EXPIRED"| a11f[["QUA_HAN<br/>hoặc về HOAN_TAT nếu đang lên kế hoạch lại BR-22"]]
  a11f --> a11x>"MSG-31 · Toast<br/>Đã quá thời gian hoàn tất {tên ritual} cho {Thứ}, {dd/mm}"]
  a11x --> a11e(["Wizard đóng, không có task ghi chép mới"])

  class s1,u2,sn,p7 happy
  class a3,a4,a10,a10m,a5,a5m,a5e,a11r,a11f,a11e alt
  class a11m,a11x warn
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

### Nhánh thay thế và lỗi: trong các bước

```mermaid
flowchart TD
  s1["SCR-02 Bước 1 Xem lại hôm qua"]
  s2["SCR-03 Bước 2 Thêm task"]
  s5["SCR-06 Bước 5 Daily plan"]
  s6["SCR-07 Bước 6 Chia sẻ"]
  s1 ==> s2 ==>|"bước 3, 4"| s5 ==> s6

  s1 -->|"BR-06 · RolloverEnsure trả DANG_CHAY / CHO_SHUTDOWN"| b6m>"MSG-32 · Inline<br/>Việc từ hôm qua đang được chuyển sang. Danh sách sẽ tự cập nhật"]
  b6m --> b6["Hiện danh sách đang có<br/>tự tải lại khi rollover xong, realtime"]
  s1 -.->|"BR-06 · THAT_BAI / ROLLOVER_FAILED"| b6f>"G06 MSG-25 · Banner<br/>Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại"]
  b6f -.->|"Thử lại"| b6r[["RolloverEnsure lại · G06 BR-24"]]
  b6f -.-> b6
  b6 --> s1
  s1 -->|"A7 · không có task"| a7m>"MSG-17 · Empty state<br/>Không còn việc nào từ hôm qua<br/>nút Tiếp"]
  a7m --> s2
  s2 -->|"A8 · kéo sự kiện đã có task"| a8["Không tạo thêm task"]
  a8 --> a8m>"MSG-28 · Toast<br/>Sự kiện này đã có task · Mở task"]
  a8m -->|"Mở task"| a8x{{"→ G02 · UC-02 Chi tiết task"}}
  s2 -->|"SCR-03 #5 · lịch chưa kết nối"| h5{{"→ G05 · UC-01 Kết nối lịch<br/>hint Kết nối lịch để thấy cuộc họp"}}
  s5 -->|"A9 · Làm mới khi planEdited"| a9m>"MSG-14 · Dialog<br/>Tạo lại bản kế hoạch? Nội dung bạn đã sửa sẽ bị thay thế · Tạo lại · Huỷ"]
  a9m -->|"Tạo lại"| a9r[["Sinh lại bản kế hoạch BR-10<br/>giữ ô Trở ngại"]]
  a9r --> s5
  a9m -->|"Huỷ"| s5
  s5 -->|"A14 · trợ lý AI bật, Planning Agent đã áp dụng cho D"| a14["SCR-06 #5 nút Hoàn tác kế hoạch AI"]
  a14 -->|"bấm"| a14x{{"→ G10 · UC-04 Hoàn tác hành động AI"}}
  a14x --> d14{"planEdited?"}
  d14 -->|"false"| a9r
  d14 -->|"true"| a9m

  s5 -.->|"E5 · Trở ngại > 5.000 ký tự"| e5m>"MSG-22 · Inline<br/>Nội dung tối đa 5.000 ký tự<br/>chặn Tiếp"]

  class s1,s2,s5,s6 happy
  class b6f,b6r err
  class b6,a7m,a8,a8m,a9m,a9r alt
  class b6m warn
  class a14,d14 ai
  class a8x,h5,a14x link
  class e5m err
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

### Nhánh lỗi: thiết bị khác, mất mạng, hoàn tất lỗi

```mermaid
flowchart TD
  s1["SCR-01 · bước bất kỳ"]
  pu[["RitualUpdate, If-Match"]]
  s6["SCR-07 Bước 6 Chia sẻ"]
  u7[/"Bấm Bắt đầu ngày"/]
  p7[["RitualComplete, Idempotency-Key, If-Match"]]
  ok(["Bắt đầu ngày · Home / Today"])
  s1 ==> pu ==> s6 ==> u7 ==> p7 ==> ok

  pu -->|"A12 · 409 RITUAL_ALREADY_COMPLETED"| a12m>"MSG-15 · Toast<br/>Ritual này vừa được hoàn tất trên thiết bị khác"]
  p7 -->|"A12 · 409"| a12m
  a12m --> a12(["SCR-06 chế độ xem bản đã chốt<br/>nội dung đang sửa giữ nháp trên máy tới hết ngày D"])
  pu -->|"A13 · 412 PRECONDITION_FAILED"| a13[["Tải lại phiên, gộp data theo từng trường QC-08<br/>gửi lại một lần BR-26"]]
  a13 --> d13{"Trường của người dùng<br/>bị ghi đè?"}
  d13 -->|"có"| a13m>"MSG-29 · Toast<br/>Ritual vừa được sửa trên thiết bị khác. Đã gộp thay đổi; #quot;{tên trường}#quot; lấy theo bản mới nhất"]
  d13 -->|"không"| s6
  a13m --> s6

  s1 -.->|"E3 · mất mạng"| e3["Wizard chạy trên dữ liệu máy<br/>thao tác task, RitualUpdate xếp hàng"]
  e3 -.-> e3m>"G04 MSG-30 · Banner SCR-01 #5, banner offline chung<br/>Đang offline. Thay đổi được lưu trên máy và tự đồng bộ khi có mạng<br/>wizard không có banner riêng, A5"]
  p7 -.->|"E3 · mất mạng"| e3q["RitualComplete xếp hàng cùng Idempotency-Key<br/>email gửi khi có mạng"]
  e3q -.->|"có mạng, không tạo trùng task ghi chép"| ok
  p7 -.->|"E4 · 5xx / timeout"| e4["Giữ ở bước 6"]
  e4 -.-> e4m>"MSG-12 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e4m -.->|"Thử lại cùng key"| p7

  class s1,pu,s6,u7,p7 happy
  class a12m,a12,a13,d13 alt
  class a13m warn
  class e3,e3q,e3m sync
  class e4,e4m err
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

### Nhánh thay thế: chế độ có hướng dẫn (A16)

Chỉ cho phiên Daily planning **đầu tiên** của tài khoản, mở ngay sau onboarding (BR-28, F3, G01 US2.2).

```mermaid
flowchart TD
  start(["Xong onboarding · G01 UC-05 bước 7"])
  p1[["RitualGet daily_planning hôm nay<br/>phiên đầu tiên: data.guided = true"]]
  s1["SCR-01 wizard thay vùng chính<br/>đầu mỗi bước có một dòng lời dẫn UI-xx [đề xuất]<br/>không có Bỏ qua bước này"]
  s2["Bước 2 Thêm task cho hôm nay<br/>đã có sẵn task vừa tạo ở onboarding"]
  t1["Khái niệm lần đầu gặp: tooltip<br/>projection, timebox, phím tắt · G01 US2.3"]
  u1[/"Đi hết 6 bước như luồng chính<br/>bấm Bắt đầu ngày"/]
  ok(["Phiên HOAN_TAT<br/>các lần sau là Daily planning thường"])

  start ==>|"A16"| p1 ==> s1 ==> s2 ==> u1 ==> ok
  s1 -.-> t1
  s1 -->|"bấm × giữa chừng"| d1(["Phiên DANG_LAM giữ data.guided<br/>mở lại vẫn ở chế độ có hướng dẫn"])

  class start,p1,s1,s2,u1 alt
  class t1,d1 alt
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
| A1 | Phiên đang `DANG_LAM` ở bước n | Mở về `current_step`, giữ dữ liệu | – |
| A2 | Phiên đã `HOAN_TAT` | SCR-06 chế độ xem → Lên kế hoạch lại về bước 1, mở lại nội dung đã chốt để sửa, hoàn tất ghi đè (B35); bỏ dở → `HOAN_TAT` nội dung cũ | – |
| A3 | Bước đang `AN` | Nhảy qua, thanh bước hiện màu xám | – |
| A4 | ← / Quay lại | Bước trước, giữ dữ liệu | – |
| A5 | Bấm × giữa chừng (Esc không thoát, IA-16) | Wizard đóng, về Home, không có task ghi chép | MSG-16 |
| A6 | D từ ngày mai tới hôm nay + 7 (nút Plan cột tương lai) | Bước 1 là task của ngày trước D; nút "Xong", không chuyển trang. Cách duy nhất lên kế hoạch ngày mai, không có chế độ buổi tối (B31) | – |
| A7 | Bước 1 không có task | Empty state, nút Tiếp | MSG-17 |
| A8 | Kéo sự kiện đã có task | Không tạo thêm; Mở task → [G02 · UC-02](g02-quan-ly-task.md#uc-02-xem-và-sửa-chi-tiết-task) | MSG-28 |
| A9 | Làm mới khi `planEdited` | Tạo lại (giữ Trở ngại) hoặc Huỷ | MSG-14 |
| A10 | Bỏ qua bước này từ lần sau | Bước `AN` từ lần sau, vẫn ở bước hiện tại | MSG-21 |
| A11 | Qua mốc đầu ngày khi đang làm | Hoàn tất cho D trong 2 giờ; quá hạn → `QUA_HAN` / `HOAN_TAT`, wizard đóng | MSG-30, MSG-31 |
| A12 | Phiên vừa hoàn tất ở thiết bị khác (409) | Bản đã chốt ở chế độ xem | MSG-15 |
| A13 | Phiên bị sửa ở thiết bị khác (412) | Gộp theo trường, gửi lại | MSG-29 (khi bị ghi đè) |
| A14 | Trợ lý AI bật, Planning Agent đã áp dụng cho D | Hoàn tác kế hoạch AI → [G10 · UC-04](g10-tro-ly-ai.md); sinh lại hoặc hỏi | MSG-14 (khi `planEdited`) |
| A15 | D là ngày nghỉ theo lịch chung | Không tự mở, không chấm nhắc; mở tay chạy luồng chính | – |
| A16 | Phiên đầu tiên sau onboarding | Chế độ có hướng dẫn (BR-28); xong thì các lần sau là bản thường | UI-xx [đề xuất] |
| A17 | Trợ lý AI bật, bấm Plan my day ở đầu bước 1 (SCR-01 #9) | → [G10 · UC-02](g10-tro-ly-ai.md); xong nhảy tới bước 5 Daily plan; lỗi, Dừng, Hoàn tác kế hoạch AI về bước 1 (B28) | – |
| A18 | Daily shutdown hôm trước đã `HOAN_TAT` | Bỏ qua bước 1, mở thẳng bước 2; bước 1 xám, bấm vẫn xem được (B32) | – |
| E1 | D < hôm nay, chưa có phiên | Không mở wizard | MSG-20 |
| E2 | Từ 1.1: workspace chỉ đọc | Bỏ (1.1) | – |
| E3 | Mất mạng | Chạy trên dữ liệu máy, xếp hàng, gửi khi có mạng | G04 MSG-30, banner offline chung (MSG-23 bỏ, A5) |
| E4 | `RitualComplete` 5xx / timeout | Giữ bước 6, Thử lại cùng key | MSG-12 |
| E5 | Trở ngại > 5.000 ký tự | Chặn Tiếp | MSG-22 |
| E6 | D > hôm nay + 7 (`RITUAL_DATE_NOT_ALLOWED`) | Không mở wizard (B29) | MSG-33 |
| BR-06 | `RolloverEnsure` trả `DANG_CHAY` / `CHO_SHUTDOWN` | Danh sách hiện có, tự tải lại | MSG-32 |
| BR-06 | `RolloverEnsure` trả `THAT_BAI` / lỗi `ROLLOVER_FAILED` | Danh sách hiện có, banner "Thử lại" (G06 BR-24) | G06 MSG-25 |
| BR-08 | Quá tải ở bước 3 | Cảnh báo, không chặn | MSG-03 |
| BR-09 | Dự kiến xong muộn hơn giờ kết thúc ngày | Cảnh báo, không chặn | MSG-06 |
| – | Lịch chưa kết nối ở bước 2 (SCR-03 #5) | → [G05 · UC-01](g05-lich-timebox.md) | – |

---

## UC-02 Daily shutdown

**Mở đầu:** phím O, sidebar "Daily shutdown", hoặc lời nhắc MSG-02; D = hôm nay hoặc phiên D đang trong ân hạn. **Thành công:** phiên `HOAN_TAT`; task chưa xong của D đã có chỗ; task ghi chép "Daily shutdown"; thông điệp cuối ngày hiện; rollover đang chờ được chạy. **Thất bại:** phiên giữ `DANG_LAM`, không có task ghi chép.

Các bước Daily shutdown là **đề xuất, chưa kiểm chứng trên Sunsama** (SRS).

### Happy case

```mermaid
flowchart TD
  start(["Sidebar, phím O<br/>hoặc lời nhắc MSG-02"])
  u1[/"Nhấn O, bấm Daily shutdown<br/>hoặc Daily shutdown (O) ở lời nhắc"/]
  p1[["RitualGet daily_shutdown D<br/>chưa có phiên: tạo DANG_LAM"]]
  s1["SCR-01 · SCR-08 Bước 1 Việc đã xong<br/>actual / planned, tổng h:mm, phân bổ theo channel BR-15"]
  u2[/"Xem · Tiếp"/]
  p2[["RitualUpdate current_step = 2"]]
  s2["SCR-09 Bước 2 Xử lý task chưa xong<br/>mỗi dòng: Ngày mai (ngày đích của task) · Backlog · Xong"]
  u3[/"Chọn cho từng task bằng D / Z / C<br/>hoặc Áp dụng cho tất cả: Ngày mai · Tiếp"/]
  p3[["Áp ngay BR-16: TaskMove G06, TaskComplete G02<br/>không reset số ngày bị hoãn, toast Hoàn tác<br/>RitualUpdate current_step = 3"]]
  s3["SCR-10 Bước 3 Highlights<br/>danh sách sinh sẵn từ task đã xong BR-17<br/>ô Ghi chú riêng, chỉ mình bạn thấy, B34"]
  u4[/"Sửa highlights, viết ghi chú riêng nếu muốn · Tiếp"/]
  p4[["Lưu nháp vào data<br/>RitualUpdate current_step = 4"]]
  s4["SCR-07 Bước 4 Chia sẻ"]
  x4{{"→ UC-03 Chia sẻ"}}
  u5[/"Bấm Hoàn tất"/]
  p5[["RitualComplete: BR-11, notes = việc đã xong + highlights<br/>không gồm ghi chú riêng<br/>BR-12, BR-14; ritual.shutdown.closed tới G06"]]
  m5>"MSG-26 · Toast<br/>Đã lưu vào task #quot;Daily shutdown#quot;<br/>có đích email: dòng 2 MSG-10 Đang gửi tới {n} nơi nhận, QC-13 mục 3"]
  s5["SCR-11 Bước 5 Hoàn tất<br/>{n} task xong · {h:mm} thực tế"]
  m6>"MSG-19 · Màn Hoàn tất, khi thông điệp cài đặt trống<br/>Hôm nay vậy là đủ. Hẹn gặp lại ngày mai."]
  u6[/"Bấm Đóng"/]
  ok(["Về Home<br/>task chưa xong đã có chỗ, có task ghi chép Daily shutdown"])

  start ==> u1 ==> p1 ==> s1 ==> u2 ==> p2 ==> s2 ==> u3 ==> p3 ==> s3 ==> u4 ==> p4 ==> s4
  s4 ==> x4 ==> u5 ==> p5 ==> m5 ==> s5 ==> m6 ==> u6 ==> ok

  class start,u1,p1,s1,u2,p2,s2,u3,p3,s3,u4,p4,s4,u5,p5,m5,s5,m6,u6 happy
  class x4 link
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

### Nhánh thay thế và lỗi: trong các bước

```mermaid
flowchart TD
  s1["SCR-08 Bước 1 Việc đã xong"]
  s2["SCR-09 Bước 2 Xử lý task chưa xong"]
  s3["SCR-10 Bước 3 Highlights"]
  s4["SCR-07 Bước 4 Chia sẻ"]
  s1 ==> s2 ==> s3 ==> s4

  s1 -->|"A1 · timer đang chạy"| a1m>"MSG-27 · Banner SCR-08 #4<br/>Timer đang chạy cho #quot;{tiêu đề}#quot; · Dừng timer<br/>hệ thống không tự dừng"]
  a1m -->|"Dừng timer"| a1x{{"→ G07 · UC-02 Dừng timer"}}
  s1 -->|"BR-15 · không có task xong"| m18>"MSG-18 · Empty state<br/>Hôm nay chưa có task nào xong"]
  m18 --> s2
  s2 -->|"A2 · không có task chưa xong"| a2>"MSG-34 · Empty state<br/>Không còn việc nào dở<br/>nút Tiếp"]
  a2 --> s3
  s2 -->|"A12 · Để tự chuyển sang mai, SCR-09 #4"| a12["Bỏ qua cả bước, không toast<br/>task chưa chọn giữ ngày D, rollover G06 chuyển sang hôm sau<br/>BR-16, B33"]
  a12 --> s3
  s2 -->|"A3 · Ngày mai cho task đang chạy timer"| a3["Dời theo BR-16<br/>timer không dừng QC-05"]
  s2 -->|"A9 · Ngày mai đưa instance lặp vào ngày<br/>đã có instance cùng series"| a9["Instance vào LUU_TRU lý do skipped, QC-06<br/>timebox xử lý như Đưa vào backlog, toast Hoàn tác"]
  s3 -->|"A7 · trợ lý AI bật, G10 đã soạn nháp"| a7["SCR-10 điền nháp AI, nhãn Nháp AI<br/>chưa có nháp, lỗi, chậm > 10 giây: giữ danh sách sinh sẵn"]
  a7 --> a7x{{"→ G10 · UC-05 Highlights AI"}}
  a7 --> s4
  s1 -->|"A6 · Bỏ qua bước này từ lần sau<br/>không áp cho Chia sẻ, Hoàn tất"| a6[["Bước thành AN BR-18"]]
  a6 --> a6m>"MSG-21 · Toast<br/>Bước #quot;{tên bước}#quot; sẽ được bỏ qua từ lần sau · Hoàn tác"]

  s3 -.->|"E4 · highlights hoặc ghi chú riêng > 5.000 ký tự"| e4m>"MSG-22 · Inline<br/>Nội dung tối đa 5.000 ký tự<br/>chặn Tiếp"]

  class s1,s2,s3,s4 happy
  class m18,a2,a3,a9,a6,a6m,a12 alt
  class a1m warn
  class a7 ai
  class a1x,a7x link
  class e4m err
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

### Nhánh thay thế: mở, bỏ qua hôm nay, thoát

```mermaid
flowchart TD
  m02>"MSG-02 · Thông báo Windows / banner SCR-12<br/>Đến giờ kết thúc ngày · Daily shutdown (O) · Bỏ qua hôm nay"]
  u1[/"O, sidebar, Daily shutdown (O)"/]
  p1[["RitualGet daily_shutdown D"]]
  s1["SCR-01 · bước current_step"]
  ok(["SCR-11 Hoàn tất"])
  m02 ==> u1 ==> p1 ==> s1 ==> ok

  m02 -->|"A10 · Bỏ qua hôm nay"| a10[["RitualUpdate status = BO_QUA, C24"]]
  a10 --> a10e(["Không nhắc lại trong ngày<br/>vẫn mở tay được"])
  p1 -->|"A4 · phiên HOAN_TAT"| a4["SCR-10 chế độ xem + Làm lại"]
  a4 -->|"Làm lại"| a4p[["DANG_LAM bước 1 BR-22<br/>mở lại highlights, ghi chú riêng đã chốt để sửa, B35<br/>hoàn tất lại ghi đè nội dung task ghi chép cũ"]]
  a4p --> s1
  a4p -->|"bỏ dở tới hết ngày D"| a4r(["Phiên về HOAN_TAT với nội dung cũ"])
  s1 -->|"A5 · bấm × trước mốc đầu ngày D+1"| a5[["Lưu current_step, data<br/>không tạo task ghi chép"]]
  a5 --> a5m>"MSG-16 · Toast<br/>Đã lưu tiến độ. Nhấn {P / O} để làm tiếp"]
  a5m --> a5e(["Wizard đóng, về Home"])
  s1 -->|"A5 · bấm × sau mốc đầu ngày D+1"| a5b[["Bỏ dở BR-21: phiên QUA_HAN<br/>ritual.shutdown.closed, rollover chạy ngay"]]
  a5b --> a5e

  class m02,u1,p1,s1 happy
  class a10,a10e,a4,a4p,a4r,a5,a5m,a5e,a5b alt
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

### Nhánh ân hạn, thiết bị khác và lỗi

```mermaid
flowchart TD
  s1["SCR-01 · bước bất kỳ"]
  s4["SCR-07 Bước 4 Chia sẻ"]
  p5[["RitualComplete"]]
  ok(["SCR-11 Hoàn tất"])
  s1 ==> s4 ==> p5 ==> ok

  s1 -->|"A8 · qua mốc đầu ngày D+1 khi đang làm"| a8["Rollover cho D của người dùng hoãn BR-21<br/>danh sách bước 2 không đổi dưới tay"]
  a8 --> a8m>"MSG-30 · Banner SCR-01 #8<br/>Bạn đang hoàn tất {tên ritual} cho {Thứ}, {dd/mm}. Còn {m} phút"]
  a8m -->|"hoàn tất trong 2 giờ; rollover chạy ngay cho task còn lại"| p5
  a8m -->|"quá 2 giờ"| a8f[["QUA_HAN, rollover chạy"]]
  a8f --> a8x>"MSG-31 · Toast<br/>Đã quá thời gian hoàn tất {tên ritual} cho {Thứ}, {dd/mm}"]
  a8x --> a8e(["Wizard đóng"])
  p5 -->|"A11 · 409 / 412 thiết bị khác, BR-26"| a11{{"→ UC-01 A12, A13<br/>MSG-15 / MSG-29"}}

  s1 -.->|"E2 · mất mạng, như UC-01 E3"| e2["Chạy trên dữ liệu máy, hàng đợi<br/>RitualComplete gửi lại cùng key"]
  e2 -.-> e2m>"G04 MSG-30 · Banner SCR-01 #5, banner offline chung<br/>Đang offline. Thay đổi được lưu trên máy và tự đồng bộ khi có mạng<br/>wizard không có banner riêng, A5"]
  e2 -.->|"có mạng"| p5
  p5 -.->|"E3 · RitualComplete lỗi"| e3["Giữ ở bước 4"]
  e3 -.-> e3m>"MSG-12 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e3m -.->|"Thử lại"| p5

  class s1,s4,p5 happy
  class a8,a8f,a8e alt
  class a8m,a8x warn
  class a11 link
  class e2,e2m sync
  class e3,e3m err
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
| A1 | Timer đang chạy ở bước 1 | Banner, Dừng timer → [G07 · UC-02](g07-focus-timer.md); không tự dừng | MSG-27 |
| A2 | Không có task chưa xong | Empty state, Tiếp | MSG-34 (C33) |
| A3 | Ngày mai cho task chạy timer | Dời, timer chạy tiếp | – |
| A4 | Phiên đã `HOAN_TAT` | SCR-10 chế độ xem → Làm lại, mở lại nội dung đã chốt để sửa, hoàn tất ghi đè (B35); bỏ dở → `HOAN_TAT` nội dung cũ | – |
| A5 | Bấm × giữa chừng | Trước mốc: lưu tiến độ; sau mốc: `QUA_HAN`, rollover chạy | MSG-16 |
| A6 | Bỏ qua bước này từ lần sau | Bước `AN` (không áp cho Chia sẻ, Hoàn tất) | MSG-21 |
| A7 | Trợ lý AI bật, có nháp highlights | Nháp AI trong SCR-10 → [G10 · UC-05](g10-tro-ly-ai.md); không có nháp → danh sách sinh sẵn | – |
| A8 | Qua mốc đầu ngày khi đang làm | Hoàn tất cho D trong 2 giờ; quá → `QUA_HAN`, wizard đóng | MSG-30, MSG-31 |
| A9 | Ngày mai đưa instance lặp vào ngày trùng series | Instance `LUU_TRU` (skipped), Hoàn tác | – |
| A10 | Bỏ qua hôm nay ở MSG-02 | Phiên `BO_QUA` | – |
| A11 | Thiết bị khác sửa / hoàn tất | Như UC-01 A12, A13 | MSG-15 / MSG-29 |
| A12 | Để tự chuyển sang mai ở bước 2 | Sang bước 3, task còn lại để rollover xử lý (B33) | – |
| E1 | Từ 1.1: workspace chỉ đọc | Bỏ (1.1) | – |
| E2 | Mất mạng | Hàng đợi, gửi khi có mạng | G04 MSG-30, banner offline chung (MSG-23 bỏ, A5) |
| E3 | `RitualComplete` lỗi | Giữ bước 4, Thử lại | MSG-12 |
| E4 | Highlights hoặc ghi chú riêng > 5.000 ký tự | Chặn Tiếp | MSG-22 |
| BR-15 | Không có task xong ở bước 1 | Empty state | MSG-18 |

---

## UC-03 Chia sẻ kết quả ritual

**Mở đầu:** bước Chia sẻ của UC-01 (bước 6) hoặc UC-02 (bước 4). **Thành công:** nội dung lưu vào task ghi chép; mỗi đích bật có bản ghi gửi `CHO_GUI` → `DA_GUI`; lựa chọn đích được nhớ. **Thất bại:** ritual vẫn hoàn tất; đích lỗi ở `LOI`, có thông báo "Thử lại".

### Happy case

```mermaid
flowchart TD
  start(["Bước Chia sẻ<br/>UC-01 bước 6 hoặc UC-02 bước 4"])
  p1[["ShareDestList"]]
  s1["SCR-07 Chia sẻ<br/>Lưu vào task ritual bật cố định<br/>đích khác bật / tắt theo lần trước của loại ritual này"]
  u1[/"Bật / tắt Gửi bản sao cho chính tôi<br/>tính là đích email, B30"/]
  u2[/"Bấm Thêm nơi nhận, nhập email, Enter"/]
  p2[["Kiểm định dạng, trùng, ≤ 10 đích BR-14<br/>ShareDestCreate"]]
  s2["SCR-07 đích mới bật cho lần này"]
  u3[/"Xem trước nội dung<br/>bấm Bắt đầu ngày / Hoàn tất"/]
  p3[["ShareDestUpdate lưu lựa chọn bật / tắt<br/>hoàn tất ritual"]]
  x3{{"→ UC-01 bước 14 / UC-02 bước 10"}}
  m3>"MSG-10 · dòng 2 của toast hoàn tất MSG-09 / MSG-26<br/>khi có ≥ 1 đích email, kể cả bản sao cho chính tôi, B30<br/>Đang gửi tới {n} nơi nhận"]
  p4[["Job gửi từng đích<br/>CHO_GUI → DA_GUI"]]
  ok(["Nội dung trong task ghi chép<br/>email tới từng nơi nhận"])

  start ==> p1 ==> s1 ==> u1 ==> u2 ==> p2 ==> s2 ==> u3 ==> p3 ==> x3 ==> m3 ==> p4 ==> ok

  class start,p1,s1,u1,u2,p2,s2,u3,p3,m3,p4 happy
  class x3 link
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
  s1["SCR-07 Chia sẻ"]
  u2[/"Thêm nơi nhận, nhập email, Enter"/]
  p2[["Kiểm BR-14, ShareDestCreate"]]
  u3[/"Bắt đầu ngày / Hoàn tất"/]
  p3[["ShareDestUpdate, hoàn tất ritual"]]
  p4[["Job gửi từng đích"]]
  ok(["DA_GUI"])
  s1 ==> u2 ==> p2 ==> u3 ==> p3 ==> p4 ==> ok

  s1 -->|"A1 · bấm × trên dòng đích"| a1[["ShareDestDelete<br/>dòng biến khỏi danh sách"]]
  s1 -->|"A2 · chọn Slack / Teams"| a2["Mục hiện Có ở bản 1.2<br/>không chọn được, G11"]
  s1 -->|"A3 · thoát wizard trước khi hoàn tất"| a3(["Không gửi gì<br/>lựa chọn đích chưa lưu"])
  p2 -->|"A5 · email đã có trong danh sách"| a5["Không thêm<br/>dòng đã có nhấp nháy và được bật"]

  p2 -.->|"E1 · email sai định dạng, VALIDATION_FAILED"| e1m>"MSG-07 · Inline<br/>Email không hợp lệ"]
  p2 -.->|"E2 · đích thứ 11, LIMIT_SHARE_DESTINATIONS"| e2m>"MSG-08 · Inline<br/>Tối đa 10 nơi nhận"]
  p3 -.->|"E3 · vượt 20 email chia sẻ / ngày, 429"| e3m>"MSG-24 · Toast<br/>Đã đạt giới hạn 20 email chia sẻ hôm nay. Nội dung vẫn được lưu vào task"]
  e3m -.-> e3(["Ritual vẫn hoàn tất<br/>chỉ lưu vào task"])
  p4 -.->|"E4 · gửi lỗi sau 3 lần thử trong 30 phút"| e4["Đích LOI"]
  e4 -.-> e4m>"MSG-11 · Thông báo trong app<br/>Chưa gửi được tới {nơi nhận}. Thử lại"]
  e4m -->|"A4 · bấm Thử lại"| a4[["ShareRetry<br/>LOI → CHO_GUI"]]
  a4 --> p4
  p2 -.->|"E5 · mất mạng"| e5["Kiểm định dạng, trùng trên máy<br/>ShareDestCreate / Delete / Update xếp hàng đợi<br/>dòng đích hiện dấu Chờ đồng bộ, QC-08 mục 7"]
  e5 -.->|"có mạng, server nhận"| u3
  e5 -.->|"có mạng, server từ chối đích thứ 11"| e2m

  class s1,u2,p2,u3,p3,p4 happy
  class a1,a2,a3,a5,a4 alt
  class e5 sync
  class e1m,e2m,e3m,e4,e4m err
  class ok done
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
| A1 | Gỡ một đích | Đích bị xoá | – |
| A2 | Chọn Slack / Teams ở 1.0 | Không chọn được, nhãn "Có ở bản 1.2" | – |
| A3 | Thoát wizard trước hoàn tất | Không gửi, lựa chọn chưa lưu | – |
| A4 | Thử lại trong MSG-11 | Đích `LOI` → `CHO_GUI` | – |
| A5 | Email đã có | Dòng cũ nhấp nháy, bật | – |
| E1 | Email sai định dạng | Không thêm | MSG-07 |
| E2 | Đích thứ 11 | Không thêm | MSG-08 |
| E3 | Vượt 20 email / ngày | Ritual hoàn tất, chỉ lưu vào task | MSG-24 |
| E4 | Gửi lỗi sau 3 lần thử | Đích `LOI`, thông báo trong app | MSG-11 |
| E5 | Mất mạng khi thêm, gỡ, bật / tắt nơi nhận | Áp trên máy, dấu "Chờ đồng bộ", gửi lên khi có mạng; server từ chối đích thứ 11 thì gỡ dòng (A6) | MSG-08 (khi bị từ chối) |

---

## UC-04 Tự kích hoạt và nhắc ritual

**Mở đầu:** job `[ritual.prompt]` mỗi 5 phút, cài đặt "Tự kích hoạt" / "Tự nhắc shutdown" bật. **Thành công:** Daily planning tự mở đúng 1 lần trong ngày trên 1 thiết bị; shutdown được nhắc 1 lần. **Thất bại:** không tự mở; người dùng vẫn mở tay được.

### Happy case

```mermaid
flowchart TD
  start(["Job ritual.prompt chạy mỗi 5 phút"])
  p1[["Chọn người dùng vừa tới giờ Daily planning theo timezone<br/>hôm nay là ngày làm việc theo lịch chung BR-23"]]
  p2[["Kiểm BR-03<br/>tạo thông báo và chấm nhắc ở sidebar"]]
  m1>"MSG-01 · SCR-12, thông báo Windows + trong app<br/>Đến giờ lên kế hoạch cho hôm nay · Bắt đầu (P) · Bỏ qua hôm nay"]
  p3[["Cửa sổ app đang hiện, hoặc lần đầu đưa cửa sổ lên sau giờ plan,<br/>gọi RitualGet; server trả autoOpen = true, ghi autoPromptedAt nguyên tử"]]
  s1["SCR-01 wizard Daily planning tự mở<br/>thay vùng chính"]
  x1{{"→ UC-01 bước 2"}}
  ok(["Daily planning tự mở đúng 1 lần trong ngày<br/>trên 1 thiết bị"])
  u1[/"Bấm Bỏ qua hôm nay trên SCR-12"/]
  p4[["RitualUpdate status = BO_QUA"]]
  ok2(["Không nhắc, không tự mở trong ngày<br/>vẫn mở tay được"])

  start ==> p1 ==> p2 ==> m1 ==> p3 ==> s1 ==> x1 ==> ok
  m1 ==>|"hoặc"| u1 ==> p4 ==> ok2

  class start,p1,p2,m1,p3,s1,u1,p4 happy
  class x1 link
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

### Nhánh thay thế: Daily planning

```mermaid
flowchart TD
  start(["Job ritual.prompt"])
  p1[["Chọn người dùng tới giờ plan"]]
  p2[["Kiểm BR-03, MSG-01, chấm nhắc"]]
  p3[["RitualGet, autoOpen"]]
  s1["SCR-01 wizard tự mở"]
  start ==> p1 ==> p2 ==> p3 ==> s1

  p1 -->|"A8 · hôm nay là ngày nghỉ theo lịch chung,<br/>kể cả khi có khung giờ channel"| a8(["Không thông báo, không tự mở,<br/>không chấm nhắc BR-23"])
  p1 -->|"A2 · vắng nhiều ngày EC-27"| a2["Chỉ xét hôm nay, không nhắc ngày đã qua<br/>phiên cũ chưa xong QUA_HAN<br/>phiên lên kế hoạch lại về HOAN_TAT"]
  a2 --> p2
  p2 -->|"A6 · tắt Tự kích hoạt"| a6(["Không tự mở<br/>vẫn có chấm nhắc ở sidebar"])
  p3 -->|"A1 · thiết bị khác gọi RitualGet trước"| a1(["Thiết bị này chỉ có chấm nhắc"])
  p3 -->|"A3 · đang gõ trong ô nhập hoặc đang ở Focus"| a3["Không tự mở<br/>autoPromptedAt vẫn ghi"]
  a3 --> a3m>"MSG-01 · SCR-12 dạng banner, hàng chờ IA-17<br/>đứng sau mọi banner lỗi và offline<br/>Đến giờ lên kế hoạch cho hôm nay · Bắt đầu (P) · Bỏ qua hôm nay"]
  b4(["Mở app trước giờ plan"]) -->|"A4"| a4["Không tự mở<br/>tới giờ khi app đang mở thì gọi RitualGet"]
  a4 --> p3
  b9(["Lần đầu mở app sau giờ Daily shutdown,<br/>hoặc shutdown hôm nay đã HOAN_TAT"]) -->|"A9"| a9(["Không tự mở Daily planning, C22<br/>vẫn mở tay được"])
  p2 -->|"A10 · cửa sổ ẩn ở khay hoặc thu nhỏ, IA-05"| a10["Người dùng chỉ thấy thông báo Windows MSG-01<br/>chưa gọi RitualGet khi cửa sổ chưa hiện"]
  a10 -->|"bấm thông báo, IA-10"| a10b["Đưa cửa sổ lên trước"]
  a10 -->|"tự mở cửa sổ từ khay"| a10b
  a10b --> p3
  s1 -->|"A7 · đổi timezone / giờ plan sau khi đã tự mở"| a7(["Không mở lại trong ngày D, khoá theo autoPromptedAt<br/>mốc đầu ngày, timezone mới có hiệu lực từ ngày làm việc kế tiếp"])

  class start,p1,p2,p3,s1 happy
  class a8,a2,a6,a1,a3,a3m,b4,a4,b9,a9,a7,a10,a10b alt
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

### Nhánh thay thế và lỗi: Daily shutdown, job

```mermaid
flowchart TD
  start(["Job ritual.prompt"])
  p1[["Chọn người dùng tới giờ ritual<br/>ngày làm việc theo lịch chung"]]
  p3[["RitualGet, autoOpen"]]
  s1["SCR-01 wizard Daily planning tự mở"]
  start ==> p1 ==> p3 ==> s1

  p1 -->|"A5 · tới giờ Daily shutdown"| a5[["Kiểm BR-04: cài đặt bật,<br/>phiên shutdown chưa HOAN_TAT / BO_QUA"]]
  a5 --> a5m>"MSG-02 · SCR-12, thông báo Windows + trong app<br/>Đến giờ kết thúc ngày · Daily shutdown (O) · Bỏ qua hôm nay"]
  a5m --> a5c(["Chấm nhắc ở sidebar<br/>không tự mở"])
  a5m -->|"Daily shutdown (O)"| x5{{"→ UC-02 Daily shutdown"}}
  a5m -->|"Bỏ qua hôm nay"| a5b[["RitualUpdate status = BO_QUA, C24"]]

  start -.->|"E1 · job lỗi / trễ"| e1["Lần quét sau xử lý lại<br/>idempotent theo người dùng, loại, D<br/>lần đầu mở app vẫn tự mở theo bước 3"]
  e1 -.-> p1
  p3 -.->|"E2 · RitualGet lỗi khi tự mở"| e2(["Không tự mở, giữ chấm nhắc<br/>không ghi autoPromptedAt"])

  class start,p1,p3,s1 happy
  class a5,a5m,a5c,a5b alt
  class x5 link
  class e1 err
  class e2 fail
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
| A1 | Nhiều thiết bị đang mở | Thiết bị đầu tiên tự mở; thiết bị khác chỉ chấm nhắc | – |
| A2 | Vắng nhiều ngày | Chỉ xét hôm nay; phiên cũ `QUA_HAN` (lên kế hoạch lại → `HOAN_TAT`) | – |
| A3 | Đang gõ / đang ở Focus | Không tự mở, banner SCR-12 vào hàng chờ IA-17, sau mọi banner lỗi và offline (A5) | MSG-01 |
| A4 | Mở app trước giờ plan | Tới giờ thì tự mở | – |
| A5 | Tới giờ Daily shutdown | Thông báo + chấm nhắc, không tự mở; Bỏ qua → `BO_QUA` | MSG-02 |
| A6 | Tắt Tự kích hoạt | Không tự mở, vẫn chấm nhắc | – |
| A7 | Đổi timezone / giờ plan sau khi đã tự mở | Không mở lại trong ngày | – |
| A8 | Ngày nghỉ theo lịch chung | Không thông báo, không tự mở, không chấm nhắc | – |
| A9 | Mở app sau giờ shutdown / shutdown đã xong | Không tự mở | – |
| A10 | Cửa sổ ẩn ở khay / thu nhỏ khi tới giờ (IA-05) | Chỉ thông báo Windows; wizard mở khi cửa sổ được đưa lên | MSG-01 |
| E1 | Job lỗi / trễ | Lần quét sau xử lý lại | – |
| E2 | `RitualGet` lỗi khi tự mở | Không tự mở, giữ chấm nhắc | – |

---

## UC-05 Cài đặt ritual ngày

**Mở đầu:** Cài đặt → Ritual (SCR-13). **Thành công:** cài đặt lưu và áp ngay trên mọi thiết bị (`settings.changed`). **Thất bại:** giá trị cũ giữ nguyên.

### Happy case

```mermaid
flowchart TD
  start(["Avatar → Cài đặt hoặc Ctrl+,<br/>nhóm Ritual"])
  p1[["SettingsGet G01"]]
  s1["SCR-13 Cài đặt → Ritual, phần ngày"]
  u1[/"Đổi một giá trị: giờ Daily planning, tự kích hoạt,<br/>sau khi plan đi tới, tự nhắc shutdown, giờ shutdown,<br/>thông điệp cuối ngày, channel cho task ritual"/]
  p2[["SettingsUpdate chỉ trường đổi<br/>BR-03, BR-04 tính lại cho hôm nay nếu chưa nhắc"]]
  ok(["Áp ngay trên mọi thiết bị<br/>settings.changed"])

  start ==> p1 ==> s1 ==> u1 ==> p2 ==> ok

  class start,p1,s1,u1,p2 happy
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
  s1["SCR-13 Cài đặt → Ritual"]
  u1[/"Đổi một giá trị"/]
  p2[["SettingsUpdate"]]
  ok(["Áp ngay trên mọi thiết bị"])
  s1 ==> u1 ==> p2 ==> ok

  s1 -->|"A1 · Hiện lại bước đã ẩn, SCR-13 #8"| a1[["Bỏ bước khỏi ritual.skippedSteps<br/>bước về HIEN"]]
  a1 --> p2
  u1 -->|"A2 · đổi channel cho task ritual"| a2["Chỉ áp cho task ghi chép tạo sau"]
  a2 --> p2
  s1 -->|"A3 · nháp highlights AI, chỉ khi trợ lý AI bật"| a3x{{"→ G10 · UC-07 Cài đặt AI"}}
  s1 -->|"SCR-13 #10 · Theo Lịch làm việc"| l10{{"→ G01 · UC-10 Lịch làm việc"}}

  u1 -.->|"E1 · thông điệp cuối ngày > 280 ký tự"| e1m>"MSG-25 · Inline<br/>Thông điệp tối đa 280 ký tự"]
  e1m -.-> e1(["Không lưu"])
  g02{{"G02 · UC-06 A3 xoá channel"}} -.->|"E2 · channel cho task ritual bị xoá"| e2["Tự về channel mặc định của người dùng<br/>ghi nhật ký"]
  p2 -.->|"E3 · SettingsUpdate lỗi"| e3["Trả giá trị cũ"]
  e3 -.-> e3m>"MSG-12 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  u1 -.->|"E4 · mất mạng"| e4["Áp ngay trên máy, xếp hàng đợi<br/>cạnh trường hiện dấu Chờ đồng bộ, QC-08 mục 7"]
  e4 -.->|"có mạng"| p2

  class s1,u1,p2 happy
  class e4 sync
  class a1,a2 alt
  class a3x,l10,g02 link
  class e1m,e2,e3,e3m err
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
| A1 | Bật lại bước đã ẩn | Bước `HIEN` | – |
| A2 | Đổi channel cho task ritual | Áp cho task ghi chép tạo sau | – |
| A3 | Nháp highlights AI (trợ lý AI bật) | → [G10 · UC-07](g10-tro-ly-ai.md) | – |
| A3 | Cài đặt ritual tuần (G09) | Bỏ (1.1) | – |
| E1 | Thông điệp > 280 ký tự | Không lưu | MSG-25 |
| E2 | Channel cho task ritual bị xoá ([G02 · UC-06](g02-quan-ly-task.md#uc-06-quản-lý-context-và-channel)) | Về channel mặc định | – |
| E3 | `SettingsUpdate` lỗi | Giá trị cũ | MSG-12 |
| E4 | Mất mạng | Áp trên máy, dấu "Chờ đồng bộ", gửi lên khi có mạng; xung đột theo G01 BR-12 (A6) | – |
| – | SCR-13 #10 "Theo Lịch làm việc" | → [G01 · UC-10](g01-tai-khoan.md) | – |

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-05 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)".
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG. Banner offline dùng G04 MSG-30 (SCR-01 #5).
- [x] Nội dung MSG chép nguyên văn mục 9 SRS (dấu ngoặc kép viết bằng `#quot;` cho Mermaid).

**Ghi chú cho brief G08**
- ~~**Esc trong wizard mâu thuẫn.** BR-20, UC-01 A5, BR-21 ghi Esc thoát wizard, trái SCR-01 #7 và IA-16.~~ **Đã sửa 09/11/2026 (C31):** SRS BR-20, BR-21, UC-01 A5, UC-02 A5 chỉ còn ×; Esc không thoát wizard.
- ~~**Vị trí "Plan my day" chưa có trong SRS G08**; G10 UC-02 E1 gọi ô là "Obstacles in my way".~~ **Đã sửa 09/11/2026 (B28 / C32):** nút ở đầu bước 1 (SRS SCR-01 #9, SCR-02 #5, UC-01 A17); xong nhảy tới bước 5, lỗi / Dừng về bước 1; sơ đồ "mở wizard" vẽ lại. G08 giữ tên ô "Trở ngại" (SCR-06 #2); phía G10 do G10 sửa.
- ~~**UC-02 A2 "Không còn việc nào dở"** chưa có mã MSG.~~ **Đã sửa 09/11/2026 (C33):** thêm MSG-34, SCR-09 #5.
- ~~**D quá xa trong tương lai.** `RITUAL_DATE_NOT_ALLOWED` map sang MSG-20 sai nghĩa; nút "Plan" trên cột > +7 chưa rõ.~~ **Đã sửa 09/11/2026 (B29):** BR-02 bỏ `[giả định]`, cột > hôm nay + 7 không có nút "Plan"; thêm UC-01 E6 và MSG-33; MSG-20 chỉ còn cho ngày đã qua.
- ~~**Hai banner offline.** UC-01 E3 dùng banner MSG-23 riêng của ritual.~~ **Đã sửa 09/11/2026 (A5 / C34):** bỏ MSG-23; UC-01 E3, UC-02 E2 dùng banner offline chung G04 MSG-30 (SCR-01 #5).
- ~~**Banner lời nhắc SCR-12** không có trong thứ tự ưu tiên banner của IA-17.~~ **Đã sửa 09/11/2026 (A5):** SCR-12 đứng cuối hàng chờ IA-17, sau mọi banner lỗi và offline (IA mục 3; SRS UC-04 A3, SCR-12 #1).
- ~~**Hai toast cùng lúc khi hoàn tất** (MSG-09 / MSG-26 và MSG-10); "Gửi bản sao cho chính tôi" có tính là đích email không.~~ **Đã sửa 09/11/2026 (A3 / B30):** gộp một toast theo QC-13 mục 3 (dòng 1 MSG-09 / MSG-26, dòng 2 MSG-10); bản sao cho chính mình tính là đích email.
- **Đã sửa 09/11/2026 (B31 – B35):** không có chế độ buổi tối (UC-01 A6); bỏ qua bước "Xem lại hôm qua" khi shutdown hôm trước đã xong (UC-01 A18); nút "Để tự chuyển sang mai" (UC-02 A12, SCR-09 #4); ô Ghi chú riêng tách khỏi highlights (BR-17, SCR-10 #4); làm lại mở lại nội dung cũ để sửa, hoàn tất thì ghi đè (BR-22). Dòng phụ dưới ô Ghi chú riêng là `UI-xx [đề xuất]`, brief đặt chữ.
- **Đã sửa 09/11/2026 (A6):** thêm nhánh mất mạng UC-03 E5 (nơi nhận) và UC-05 E4 (cài đặt) theo QC-08 mục 7: chạy trên máy, dấu "Chờ đồng bộ", gửi lên khi có mạng. Banner offline ghi mã G04 MSG-30.
