# Flow G05 Lịch & timebox

> **Nguồn:** [srs-g05](../../features/srs-g05-lich-timebox.md) (commit `8fac830`, cập nhật theo chốt 09/11/2026) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| [UC-01](#uc-01-kết-nối-tài-khoản-lịch) | Kết nối tài khoản lịch | SCR-01 Cài đặt → Lịch, SCR-02 Lịch của một tài khoản | 4 / 5 |
| [UC-02](#uc-02-chọn-lịch-hiển-thị-và-lịch-ghi-timebox) | Chọn lịch hiển thị và lịch ghi timebox | SCR-02, SCR-03 Lịch ghi theo channel | 4 / 2 |
| [UC-03](#uc-03-timebox-task-bằng-kéo-thả) | Timebox task bằng kéo thả | SCR-04 Lưới lịch, SCR-05 Block timebox, SCR-06 | 11 / 6 |
| [UC-04](#uc-04-dời-đổi-thời-lượng-gỡ-timebox) | Dời, đổi thời lượng, gỡ timebox | SCR-05, SCR-06 | 11 / 4 |
| UC-05 | Auto-schedule (X / Shift+X) | – | Bỏ (1.1) |
| [UC-06](#uc-06-đẩy-timebox-ra-lịch-ngoài-job-timeboxpush) | Đẩy timebox ra lịch ngoài (job chạy nền) | SCR-05 (trạng thái đồng bộ) | 4 / 5 |
| [UC-07](#uc-07-nhận-thay-đổi-từ-lịch-ngoài) | Nhận thay đổi từ lịch ngoài (chạy nền) | SCR-04, SCR-05, SCR-07 Popover xung đột | 12 / 4 |
| [UC-08](#uc-08-kết-nối-lại-và-ngắt-kết-nối) | Kết nối lại và ngắt kết nối | SCR-09 Banner, SCR-01, SCR-08 Xác nhận ngắt | 5 / 2 |
| UC-09 | Lập lịch cứng cho task lặp | – | Bỏ (1.1) |
| [UC-10](#uc-10-tạo-timebox-liên-kết-sự-kiện) | Tạo timebox liên kết sự kiện | SCR-05 (block liên kết) | 2 / 1 |
| UC-11 | Xử lý cờ "Lệch ngày" | – | Bỏ (F5) |

---

## UC-01 Kết nối tài khoản lịch

**Mở đầu:** Cài đặt → Lịch (SCR-01) hoặc bước "Kết nối lịch" của onboarding (G01); số tài khoản lịch dưới giới hạn. **Thành công:** tài khoản `HOAT_DONG`, lịch chính bật hiển thị và làm lịch ghi mặc định (nếu chưa có), sự kiện trong cửa sổ đã tải. **Thất bại:** không có tài khoản mới, trạng thái cũ giữ nguyên.

### Happy case

```mermaid
flowchart TD
  start(["SCR-01 Cài đặt → Lịch<br/>hoặc onboarding bước Kết nối lịch · G01"])
  u1[/"Bấm Kết nối Google Calendar<br/>hoặc Kết nối Outlook"/]
  p1[["CalendarConnect<br/>scope BR-02, state chống CSRF"]]
  s1["SCR-01 nút kết nối DANG_UY_QUYEN<br/>MSG-34 Đang chờ xác nhận…"]
  u2[/"Trang OAuth Google / Microsoft:<br/>chọn tài khoản, đồng ý quyền"/]
  p2[["CalendarCallback<br/>đổi code lấy token, kiểm đủ scope<br/>lưu tài khoản BR-01, đọc danh sách lịch"]]
  p3[["DANG_DONG_BO · job calendar.sync<br/>tải cửa sổ 30 ngày trước / 90 ngày sau<br/>đăng ký webhook"]]
  s2["SCR-02 Lịch của tài khoản<br/>MSG-35 Đang đồng bộ… sự kiện hiện dần"]
  m1>"MSG-01 · Toast<br/>Đã kết nối {email}. Đang tải sự kiện…"]
  p4[["Xong đồng bộ: HOAT_DONG<br/>phát calendar.changed, G04 tính lại sức chứa"]]
  ok(["SCR-01 tài khoản Đã kết nối + giờ đồng bộ<br/>lịch chính hiển thị, là lịch ghi mặc định"])

  start ==> u1 ==> p1 ==> s1 ==> u2 ==> p2 ==> p3 ==> s2 ==> m1 ==> p4 ==> ok

  class start,u1,p1,s1,u2,p2,p3,s2,m1,p4 happy
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
  start(["SCR-01 Cài đặt → Lịch"])
  u1[/"Bấm Kết nối Google Calendar / Outlook"/]
  u2[/"Trang OAuth: đồng ý quyền"/]
  p2[["CalendarCallback"]]
  p3[["DANG_DONG_BO · calendar.sync<br/>đăng ký webhook"]]
  ok(["SCR-02, tài khoản HOAT_DONG"])
  start ==> u1 ==> u2 ==> p2 ==> p3 ==> ok

  p2 -->|"A1 · cùng providerAccountId đã kết nối"| a1[["Cập nhật token<br/>giữ cấu hình lịch"]]
  a1 --> a1m>"MSG-04 · Toast<br/>{email} đã được kết nối trước đó, đã cập nhật quyền"]
  a1m --> a1ok(["Tài khoản cũ, quyền đã cập nhật"])
  p2 -->|"A2 · đã có lịch ghi mặc định"| a2["Không đổi lịch mặc định<br/>lịch của tài khoản mới chỉ bật hiển thị"]
  a2 --> p3
  p3 -->|"A3 · đăng ký webhook lỗi"| a3["SCR-01 chấm vàng DONG_BO_CHAM<br/>tooltip MSG-33 Cập nhật mỗi 15 phút"]
  a3 --> a3p[["Poll 15 phút<br/>job calendar.watch.renew thử lại"]]
  a3p -->|"gia hạn được"| ok
  p3 -->|"A4 · trên 2.500 sự kiện trong cửa sổ"| a4["SCR-02 tải theo trang<br/>sự kiện tuần đang xem hiện trước"]
  a4 --> ok

  start -.->|"E4 · đã đủ số tài khoản tối đa BR-01"| e4["SCR-01 nút kết nối disabled"]
  e4 -.-> e4m>"MSG-05 · Inline<br/>Đã đạt tối đa {n} tài khoản lịch"]
  u2 -.->|"E1 · huỷ ở màn OAuth"| e1m>"MSG-03 · Toast<br/>Đã huỷ kết nối {Google Calendar / Outlook}"]
  p2 -.->|"E2 · bỏ tích quyền ghi / thiếu scope"| e2[["Không lưu tài khoản<br/>thu hồi token vừa cấp"]]
  e2 -.-> e2m>"MSG-02 · Inline dưới dòng tài khoản lịch SCR-01<br/>Cần quyền xem và sửa lịch để dùng timebox.<br/>Hãy kết nối lại và giữ đủ quyền"]
  p2 -.->|"E3 · admin tổ chức chặn app"| e3m>"MSG-22 · Toast<br/>Tổ chức của bạn chặn ứng dụng truy cập lịch.<br/>Hãy liên hệ quản trị viên"]
  p2 -.->|"E5 · state sai / callback quá 10 phút"| e5[["Huỷ kết nối"]]
  e5 -.-> e5m>"MSG-36 · Toast<br/>Chưa kết nối được {Google Calendar / Outlook}. Thử lại"]
  e1m -.-> fail(["Về SCR-01, không có tài khoản mới<br/>trạng thái cũ giữ nguyên"])
  e2m -.-> fail
  e3m -.-> fail
  e5m -.-> fail

  class start,u1,u2,p2,p3 happy
  class a1,a1m,a2,a3p,a4 alt
  class a3 sync
  class e4,e4m,e1m,e2,e2m,e3m,e5,e5m err
  class ok,a1ok done
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
| A1 | Tài khoản đã kết nối trước đó | Token cập nhật, cấu hình lịch giữ | MSG-04 |
| A2 | Đã có lịch ghi mặc định | Về luồng chính, lịch mới chỉ bật hiển thị | – |
| A3 | Đăng ký webhook lỗi | `DONG_BO_CHAM`, poll 15 phút | – |
| A4 | Trên 2.500 sự kiện | Tải theo trang, tuần đang xem trước | – |
| E1 | Huỷ ở màn OAuth | SCR-01, không có tài khoản mới | MSG-03 |
| E2 | Thiếu quyền ghi / scope | SCR-01, không lưu, thu hồi token | MSG-02 (dưới dòng tài khoản lịch) |
| E3 | Admin tổ chức chặn app | SCR-01, không có tài khoản mới | MSG-22 |
| E4 | Đủ 5 tài khoản (B17) | SCR-01, nút kết nối disabled | MSG-05 |
| E5 | `state` sai / callback quá 10 phút | SCR-01, huỷ | MSG-36 |

---

## UC-02 Chọn lịch hiển thị và lịch ghi timebox

**Mở đầu:** có ít nhất 1 tài khoản `HOAT_DONG` / `DONG_BO_CHAM`. Lịch ghi timebox mặc định chỉ chọn ở SCR-01 #5 (A3, B18). **Thành công:** cấu hình hiển thị / màu / lịch ghi được lưu; lịch app và sức chứa ngày (G04) cập nhật. **Thất bại:** cấu hình cũ giữ nguyên.

### Happy case

```mermaid
flowchart TD
  start(["SCR-01 Cài đặt → Lịch<br/>danh sách tài khoản"])
  u1[/"Bấm một tài khoản"/]
  s1["SCR-02 Lịch của một tài khoản"]
  u2[/"Bật / tắt Hiển thị, chọn màu từng lịch"/]
  p1[["CalendarUpdate"]]
  p2[["Vẽ lại lịch<br/>phát calendar.changed"]]
  ok(["SCR-02 cấu hình mới<br/>lưới lịch và sức chứa ngày G04 cập nhật"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> p2 ==> ok

  class start,u1,s1,u2,p1,p2 happy
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
  start(["SCR-01 Cài đặt → Lịch"])
  s1["SCR-02 Lịch của một tài khoản"]
  u2[/"Đổi Hiển thị / màu"/]
  p1[["CalendarUpdate"]]
  ok(["Cấu hình mới, lịch vẽ lại"])
  start ==> s1 ==> u2 ==> p1 ==> ok

  start1(["Cài đặt → Context & channel<br/>dòng channel → Lịch ghi"]) -->|"A1 · lịch ghi theo channel"| a1["SCR-03 Lịch ghi theo channel"]
  a1 --> a1u[/"Chọn Theo mặc định / lịch có quyền ghi<br/>/ Không ghi ra lịch ngoài"/]
  a1u --> a1p[["ChannelCalendarUpdate"]]
  a1p --> ok
  start2(["SCR-04 panel Calendars · Calendar views G04"]) -->|"A2 · bật / tắt nhanh"| a2[["Chỉ đổi hiển thị<br/>như bước 3"]]
  a2 --> p1
  start -->|"A3 · SCR-01 #5 Lịch ghi timebox mặc định"| a3u[/"Chọn lịch có quyền ghi<br/>hoặc Không ghi ra lịch ngoài"/]
  a3u --> a3p[["Kiểm quyền ghi BR-04<br/>CalendarUpdate isDefaultWrite"]]
  a3p --> ok
  a3p -->|"A3 · chọn Không ghi ra lịch ngoài"| a3["Timebox mới CHI_TRONG_APP<br/>timebox cũ giữ sự kiện đã có"]
  a3 --> ok
  a3p -->|"A4 · đã có timebox tương lai"| a4["Chỉ áp cho timebox chưa đẩy lần nào<br/>timebox đã đẩy giữ lịch đích BR-04"]
  a1p -->|"A4"| a4
  a4 --> ok

  a3u -.->|"E1 · chọn lịch chỉ đọc làm lịch ghi"| e1["SCR-01 #5 / SCR-03 lựa chọn disabled"]
  a1u -.->|"E1"| e1
  e1 -.-> e1m>"MSG-15 · Tooltip<br/>Lịch này chỉ đọc, hãy chọn lịch khác để ghi timebox"]
  p1 -.->|"E2 · CalendarUpdate lỗi"| e2["Trả về giá trị cũ"]
  a1p -.->|"E2"| e2
  a3p -.->|"E2"| e2
  e2 -.-> e2m>"QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e2m -.-> fail(["Cấu hình cũ giữ nguyên"])

  class start,s1,u2,p1 happy
  class start1,a1,a1u,a1p,start2,a2,a3u,a3p,a3,a4 alt
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
| A1 | Chọn lịch ghi theo channel | SCR-03, lịch ghi của channel lưu | – |
| A2 | Bật / tắt nhanh ở panel Calendars ([G04](g04-board-ngay.md)) | Chỉ đổi hiển thị | – |
| A3 | Chọn lịch ghi mặc định ở SCR-01 #5 (nơi duy nhất, B18) | Lịch ghi mặc định lưu; "Không ghi ra lịch ngoài" → block mới `CHI_TRONG_APP` | – |
| A4 | Đổi lịch ghi khi đã có timebox tương lai | Chỉ áp cho timebox chưa đẩy | – |
| E1 | Chọn lịch chỉ đọc (SCR-01 #5, SCR-03) | Lựa chọn disabled | MSG-15 |
| E2 | `CalendarUpdate` / `ChannelCalendarUpdate` lỗi | Giá trị cũ | QC-MSG-01 |

---

## UC-03 Timebox task bằng kéo thả

**Mở đầu:** task chưa xoá, đang ở Calendar views / Today view / panel Calendar (G04). **Thành công:** task có block theo BR-05, `startDate` cập nhật, block `CHO_DONG_BO` rồi `DA_DONG_BO`, card có badge giờ cam, G04 tính lại projection. **Thất bại:** task không có block mới, vị trí cũ giữ nguyên.

### Happy case

```mermaid
flowchart TD
  start(["SCR-04 Lưới lịch<br/>Calendar views / Today view / panel Calendar · G04"])
  u1[/"Kéo task từ cột ngày / danh sách / backlog<br/>vào lưới giờ"/]
  s1["SCR-04 bóng block dài = planned hoặc 30 phút<br/>bám bước 5 phút, hiện giờ bắt đầu – kết thúc"]
  u2[/"Thả ở ô ngày D, giờ H"/]
  p1[["Áp BR-05, BR-07<br/>TimeboxSet"]]
  s2["SCR-05 Block timebox vẽ ngay · lạc quan<br/>viền nét đứt, icon đồng hồ CHO_DONG_BO"]
  p2[["Server lưu block CHO_DONG_BO<br/>xếp job timebox.push · UC-06"]]
  m1>"MSG-09 · Toast<br/>Đã đặt #quot;{tiêu đề}#quot; lúc {giờ bắt đầu}–{giờ kết thúc} · Hoàn tác"]
  ok(["SCR-06 card badge giờ cam 10:55<br/>chi tiết: Thứ Năm, 5/11 · 10:55–11:55 · 1 giờ<br/>G04 tính lại projection"])

  start ==> u1 ==> s1 ==> u2 ==> p1 ==> s2 ==> p2 ==> m1 ==> ok

  class start,u1,s1,u2,p1,s2,p2,m1 happy
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
  start(["SCR-04 Lưới lịch"])
  u2[/"Thả ở ô D, H"/]
  p1[["BR-05, BR-07 · TimeboxSet"]]
  s2["SCR-05 Block timebox"]
  p2[["Lưu CHO_DONG_BO, xếp timebox.push"]]
  m1>"MSG-09 · Toast · Hoàn tác"]
  ok(["SCR-06 card badge giờ cam"])
  start ==> u2 ==> p1 ==> s2 ==> p2 ==> m1 ==> ok

  start9(["Task đang chọn"]) -->|"A9 · bàn phím"| a9[/"Command menu G04 → Timebox…<br/>chọn ngày, giờ"/]
  a9 --> p1
  u2 -->|"A2 · giữ Shift khi thả"| a2[["skipReschedule = true<br/>cho phép chồng block"]]
  a2 --> s2
  u2 -->|"A6 · ô rơi vào giờ không tồn tại do đổi giờ EC-03"| a6m>"MSG-24 · Tooltip<br/>Giờ này không tồn tại do đổi giờ, đã đặt lúc {giờ}"]
  a6m --> p1
  u2 -->|"A11 · thả trước mốc đầu ngày<br/>vd 02:00 sáng 05/11, mốc 04:00"| a11["startDate = 04/11 QC-01<br/>vẽ ở cột ngày lịch 05/11"]
  a11 --> p1
  p1 -->|"A1 · đè block task khác, Tự dời bật"| a1[["Dời task bị đè BR-07<br/>dây chuyền trong ngày, chỉ vào giờ không bận<br/>block mới vẽ, lưu như luồng chính"]]
  a1 --> a1m>"MSG-09 và MSG-23 · một toast QC-13 mục 3<br/>Đã đặt #quot;{tiêu đề}#quot; lúc {giờ bắt đầu}–{giờ kết thúc} · Hoàn tác<br/>Đã dời {n} task để nhường chỗ"]
  a1m --> ok
  p1 -->|"A3 · chồng sự kiện ngoài bận"| a3["SCR-05 block cờ XUNG_DOT<br/>viền cam, icon cảnh báo BR-14"]
  a3 --> p2
  p1 -->|"A4 · task backlog / ngày khác"| a4["startDate = workday(startsAt)<br/>task rời backlog / cột cũ<br/>reset số ngày bị hoãn QC-05"]
  a4 --> a4x{{"→ G06 · UC-03, G04 · UC-03"}}
  a4 --> s2
  p1 -->|"A5 · vắt qua mốc đầu ngày EC-04"| a5["SCR-04 vẽ 2 đoạn trên 2 cột<br/>thuộc ngày của startsAt, ghi 1 sự kiện liền"]
  a5 --> s2
  p1 -->|"A10 · task đã có timebox"| a10["Thêm timebox mới, giữ timebox cũ C19<br/>startDate theo BR-06, badge +n SCR-06"]
  a10 --> s2
  p2 -->|"A7 · không có lịch ghi BR-04"| a7["SCR-05 block CHI_TRONG_APP<br/>không icon lịch, không xếp job"]
  a7 --> m1
  p2 -->|"A8 · tài khoản lịch ghi CAN_KET_NOI_LAI"| a8["SCR-05 block CHO_DONG_BO<br/>chờ kết nối lại"]
  a8 --> a8x{{"→ UC-08"}}
  a8 --> m1

  class start,u2,p1,s2,p2,m1 happy
  class start9,a9,a2,a11,a1,a1m,a4,a5,a10,a7 alt
  class a6m,a3 warn
  class a8 sync
  class a4x,a8x link
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
  u2[/"Thả ở ô D, H"/]
  p1[["BR-05 · TimeboxSet"]]
  s2["SCR-05 Block timebox"]
  p2[["Lưu CHO_DONG_BO, xếp timebox.push"]]
  ok(["SCR-06 card badge giờ cam"])
  u2 ==> p1 ==> s2 ==> p2 ==> ok

  p1 -.->|"E1 · thời lượng ngoài 5 phút – 24 giờ"| e1m>"MSG-17 · Inline<br/>Thời lượng khối từ 5 phút đến 24 giờ"]
  p1 -.->|"E6 · startsAt sau hôm nay + 90 ngày"| e6m>"MSG-27 · Toast<br/>Chỉ tạo được timebox trong 90 ngày tới"]
  p1 -.->|"E7 · task chưa xong, ngày làm việc đã qua"| e7["Trả task về chỗ cũ"]
  e7 -.-> e7m>"MSG-28 · Toast<br/>Không đặt task chưa xong vào ngày đã qua"]
  p1 -.->|"E2 · task đã bị xoá ở thiết bị khác"| e2["Gỡ bóng block"]
  e2 -.-> e2m>"MSG-25 · Toast<br/>Task này đã bị xoá"]
  s2 -.->|"E5 · TimeboxSet lỗi 5xx"| e5["Gỡ block, trả task về chỗ cũ"]
  e5 -.-> e5m>"QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  s2 -.->|"E3 · mất mạng"| e3["SCR-05 block CHO_DONG_BO<br/>lưu trên máy"]
  e3 -.-> e3m>"MSG-07 · Tooltip<br/>Đang chờ đồng bộ lên {tên lịch}"]
  e3 -.->|"có mạng: SyncBatch cùng Idempotency-Key"| p2
  e1m -.-> fail(["Không có block mới<br/>task ở vị trí cũ"])
  e6m -.-> fail
  e7m -.-> fail
  e2m -.-> fail
  e5m -.-> fail

  class u2,p1,s2,p2 happy
  class e1m,e6m,e7,e7m,e2,e2m,e5,e5m err
  class e3,e3m sync
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
| A1 | Đè block task khác, tự dời bật | Task bị đè dời xuống; Hoàn tác trả cả hai về như trước | MSG-09 + MSG-23 (một toast, A3) |
| A2 | Giữ Shift khi thả | Cho phép chồng | MSG-09 |
| A3 | Thả chồng sự kiện ngoài bận | Block có cờ `XUNG_DOT` (popover ở [UC-07](#uc-07-nhận-thay-đổi-từ-lịch-ngoài) A3) | MSG-09 |
| A4 | Task backlog / ngày khác | `startDate` mới, rời backlog / cột cũ → [G06 UC-03](g06-backlog-rollover.md#uc-03-đưa-task-từ-backlog-ra-ngày), [G04 UC-03](g04-board-ngay.md#uc-03-di-chuyển-task-giữa-các-ngày) | MSG-09 |
| A5 | Vắt qua mốc đầu ngày | 2 đoạn trên lưới, 1 sự kiện | MSG-09 |
| A6 | Giờ không tồn tại do đổi giờ | Dời tới giờ hợp lệ kế tiếp | MSG-24 |
| A7 | Không có lịch ghi | Block `CHI_TRONG_APP` | MSG-09 |
| A8 | Lịch ghi `CAN_KET_NOI_LAI` | Block `CHO_DONG_BO` → [UC-08](#uc-08-kết-nối-lại-và-ngắt-kết-nối) | MSG-09 |
| A9 | Bàn phím | Command menu "Timebox…" ([G04 UC-08](g04-board-ngay.md#uc-08-command-menu-và-phím-tắt), B20) | MSG-09 |
| A10 | Task đã có timebox | Thêm timebox, badge "+n" | MSG-09 |
| A11 | Thả trước mốc đầu ngày | `startDate` = ngày làm việc hôm trước | MSG-09 |
| E1 | Thời lượng ngoài 5 phút – 24 giờ | Không tạo | MSG-17 |
| E2 | Task bị xoá ở thiết bị khác | Gỡ bóng block | MSG-25 |
| E3 | Mất mạng | Block chờ đồng bộ → `SyncBatch` | MSG-07 |
| E4 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E5 | `TimeboxSet` lỗi 5xx | Gỡ block, task về chỗ cũ | QC-MSG-01 |
| E6 | Quá 90 ngày | Không tạo | MSG-27 |
| E7 | Ngày đã qua, task chưa xong | Không tạo, task về chỗ cũ | MSG-28 |

---

## UC-04 Dời, đổi thời lượng, gỡ timebox

**Mở đầu:** task có ít nhất 1 block trên SCR-04 / SCR-06. **Thành công:** block, planned, `startDate` cập nhật theo BR-06; sự kiện ngoài cập nhật hoặc xoá trong 10 giây. **Thất bại:** block giữ như cũ.

### Happy case

```mermaid
flowchart TD
  start(["SCR-05 Block timebox trên SCR-04"])
  u1[/"Kéo thân block sang giờ / ngày khác<br/>hoặc kéo cạnh dưới, bước 5 phút"/]
  p1[["Áp BR-06, BR-07, vẽ ngay<br/>TimeboxSet kèm blockId"]]
  s1["SCR-05 block giờ mới<br/>CHO_DONG_BO"]
  p2[["Job timebox.push cập nhật sự kiện · UC-06"]]
  ok(["Block, planned, startDate cập nhật<br/>sự kiện ngoài cập nhật trong 10 giây"])

  start ==> u1 ==> p1 ==> s1 ==> p2 ==> ok

  class start,u1,p1,s1,p2 happy
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

### Nhánh thay thế: thao tác trên block

```mermaid
flowchart TD
  start(["SCR-05 Block timebox"])
  u1[/"Kéo thân hoặc cạnh dưới"/]
  p1[["BR-06, BR-07 · TimeboxSet"]]
  s1["SCR-05 block giờ mới"]
  ok(["Sự kiện ngoài cập nhật"])
  start ==> u1 ==> p1 ==> s1 ==> ok

  start -->|"A1 · Gỡ khỏi lịch trên block SCR-05 / SCR-06"| a1[["TimeboxDelete kèm blockId<br/>chỉ block đó CHO_XOA, block khác giữ nguyên<br/>hết timebox thì task về projection G04"]]
  start12(["Card task / chi tiết task"]) -->|"A12 · Ctrl+X trên task"| a12[["TimeboxDelete không blockId<br/>mọi block CHO_XOA, task về projection G04"]]
  start -->|"A1 · timebox liên kết sự kiện"| a1l["Chỉ gỡ liên kết<br/>không xoá sự kiện ngoài BR-21"]
  a1l --> a1m
  a1 --> a1m>"MSG-10 · Toast<br/>Đã gỡ #quot;{tiêu đề}#quot; khỏi lịch · Hoàn tác"]
  a12 --> a1m
  a1m --> a1ok(["Block ẩn khỏi lịch app<br/>job xoá sự kiện ngoài"])
  a1m -->|"Hoàn tác"| a1u[["Tạo lại các timebox vừa gỡ với giờ cũ"]]
  a1u --> ok
  u1 -->|"A10 · timebox liên kết sự kiện"| a10m>"MSG-26 · Tooltip<br/>Timebox này đi theo sự kiện #quot;{tên sự kiện}#quot; trên {tên lịch}.<br/>Hãy đổi giờ trên lịch đó"]
  p1 -->|"A2 · kéo sang ngày khác"| a2[["startDate = workday(startsAt)<br/>G04 tính lại 2 ngày"]]
  a2 --> s1
  a2 -.->|"A2 · ngày đã qua, task chưa xong"| a2m>"MSG-28 · Toast<br/>Không đặt task chưa xong vào ngày đã qua"]
  p1 -->|"A3 · nhiều timebox, kéo cạnh một block"| a3["planned = tổng các timebox"]
  a3 --> s1

  class start,u1,p1,s1 happy
  class a1,start12,a12,a1l,a1m,a1u,a2,a3 alt
  class a10m,a2m err
  class ok,a1ok done
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

### Nhánh lỗi: thao tác trên block

```mermaid
flowchart TD
  start(["SCR-05 Block timebox"])
  u1[/"Kéo thân hoặc cạnh dưới, hoặc gỡ"/]
  p1[["BR-06, BR-07 · TimeboxSet / TimeboxDelete"]]
  s1["SCR-05 block giờ mới"]
  ok(["Sự kiện ngoài cập nhật"])
  start ==> u1 ==> p1 ==> s1 ==> ok

  u1 -.->|"E1 · thời lượng mới dưới 5 phút"| e1["Dừng ở 5 phút"]
  e1 -.-> e1m>"MSG-17 · Inline<br/>Thời lượng khối từ 5 phút đến 24 giờ"]
  s1 -.->|"E2 · đổi giờ trong ngày, vừa đổi ở lịch ngoài / thiết bị khác"| e2[["BR-13 a: lần sửa server nhận sau thắng<br/>vẽ theo server, không báo lỗi"]]
  s1 -.->|"E2 · kéo sang ngày khác, VERSION_CONFLICT"| e2c[["Cụm vị trí đã đổi ở thiết bị khác<br/>tải lại task"]]
  e2c -.-> e2cm>"QC-08 mục 2 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e2cm -.-> e2cf(["Vẽ theo server"])
  s1 -.->|"E2 · timebox đã bị gỡ, TIMEBOX_REMOVED"| e2m>"MSG-29 · Toast<br/>Timebox này đã bị gỡ trên thiết bị khác hoặc trên lịch ngoài"]
  e2m -.-> e2f(["Vẽ theo server, block biến mất"])
  p1 -.->|"E3 · TimeboxSet / TimeboxDelete lỗi"| e3["Block về như cũ"]
  e3 -.-> e3m>"QC-MSG-01 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e3m -.-> fail(["Block giữ như cũ"])
  p1 -.->|"E4 · mất mạng"| e4["Chạy trên máy QC-08 mục 7<br/>dời: SCR-05 block CHO_DONG_BO giờ mới<br/>gỡ: block ẩn, MSG-10 vẫn có Hoàn tác<br/>card có dấu Chờ đồng bộ"]
  e4 -.-> e4m>"MSG-07 · Tooltip<br/>Đang chờ đồng bộ lên {tên lịch}"]
  e4 -.->|"có mạng: SyncBatch cùng Idempotency-Key"| ok
  e4 -.->|"bị từ chối do xung đột"| e2c

  class start,u1,p1,s1 happy
  class e1,e1m,e2c,e2cm,e2m,e3,e3m err
  class e2,e4,e4m sync
  class ok done
  class e2cf,e2f,fail fail
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

### Nhánh thay thế: đường đổi ngày, hoàn thành, xoá từ nhóm khác

```mermaid
flowchart TD
  g02c(["G02 · UC-03 hoàn thành task"]) -->|"A4 · thời điểm xong trong startsAt – endsAt<br/>bật Tự dời khi xong sớm"| a4[["Rút endsAt = thời điểm xong làm tròn lên 5 phút<br/>cập nhật sự kiện BR-17"]]
  g02c -->|"A4 · ngoài khoảng hoặc tắt"| a4n(["Timebox giữ nguyên"])
  g02d(["G02 · UC-04 xoá task"]) -->|"A5"| a5[["Theo dòng Xoá QC-05"]]
  g06b(["Đưa task vào backlog · G04, G06"]) -->|"A8"| a8[["Theo QC-05: như Đưa vào backlog"]]
  g04d(["Phím D, kéo sang ngày khác, shutdown Ngày mai,<br/>AI dời ngày · G04, G08, G10"]) -->|"A7"| a7[["Timebox thường giữ giờ, dời sang ngày mới<br/>cập nhật sự kiện ngoài, timer không dừng"]]
  g04d -->|"A7 · instance lặp chuyển LUU_TRU skipped"| a8
  g06r(["G06 · UC-04 rollover hằng ngày · job"]) -->|"A6 · timebox quá khứ"| a6[["Gỡ timebox khỏi task, giữ sự kiện ngoài<br/>không gọi DELETE, tác nhân system<br/>timebox tương lai giữ"]]
  a6 --> a6ok(["Không có Hoàn tác<br/>người dùng tự kéo task về nếu cần"])
  g06r -->|"A6 · tự lưu trữ stale / instance skipped"| a8
  a5 -->|"timebox thường"| fut[["Timebox tương lai CHO_XOA<br/>xoá sự kiện ngoài"]]
  a5 -->|"timebox thường"| past[["Timebox quá khứ gỡ liên kết<br/>giữ sự kiện ngoài"]]
  a8 -->|"timebox thường"| fut
  a8 -->|"timebox thường"| past
  a5 -->|"timebox liên kết sự kiện"| lk[["Chỉ gỡ liên kết<br/>không dời, không xoá sự kiện ngoài<br/>QC-05 ngoại lệ, BR-21 f"]]
  a7 -->|"timebox liên kết sự kiện"| lk
  a8 -->|"timebox liên kết sự kiện"| lk
  a4 --> x6{{"→ UC-06 Đẩy timebox"}}
  a7 --> x6
  fut --> x6
  a5 -->|"A9 · Hoàn tác"| a9[["Khôi phục timebox, liên kết lại externalEventId cũ<br/>sự kiện ngoài đã bị xoá → tạo lại với giờ cũ"]]
  a7 -->|"A9 · Hoàn tác"| a9
  a8 -->|"A9 · Hoàn tác, trừ rollover và tự lưu trữ"| a9
  a9 --> x6

  class g02c,g02d,g06b,g04d,g06r,a4,a5,a8,a7,a6,fut,past,a9 alt
  class lk warn
  class a4n,a6ok done
  class x6 link
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
| A1 | "Gỡ khỏi lịch" trên một block (B22) | Chỉ block đó `CHO_XOA`; hết timebox thì task về projection; Hoàn tác tạo lại | MSG-10 |
| A2 | Kéo sang ngày khác | `startDate` mới; ngày đã qua thì chặn | MSG-28 (ngày đã qua) |
| A3 | Kéo cạnh một trong nhiều timebox | planned = tổng | – |
| A4 | Hoàn thành trong khoảng timebox ([G02 UC-03](g02-quan-ly-task.md#uc-03-hoàn-thành--bỏ-hoàn-thành-task)) | `endsAt` rút ngắn | – |
| A5 | Xoá task ([G02 UC-04](g02-quan-ly-task.md#uc-04-xoá-hoàn-tác-và-khôi-phục-task)) | Tương lai `CHO_XOA`, quá khứ gỡ liên kết; timebox liên kết sự kiện chỉ gỡ liên kết, giữ sự kiện | – |
| A6 | Rollover ([G06 UC-04](g06-backlog-rollover.md#uc-04-rollover-hằng-ngày-job-rollover)) | Gỡ timebox quá khứ, giữ sự kiện, không Hoàn tác | – |
| A7 | Phím D / kéo ngày / shutdown / AI ([G04 UC-03](g04-board-ngay.md#uc-03-di-chuyển-task-giữa-các-ngày), [G08 UC-02](g08-daily-rituals.md#uc-02-daily-shutdown), [G10 UC-03](g10-tro-ly-ai.md#uc-03-trò-chuyện-và-ra-lệnh-cho-trợ-lý)) | Timebox dời theo ngày mới; timebox liên kết sự kiện chỉ gỡ liên kết | – |
| A8 | Đưa vào backlog ([G06 UC-01](g06-backlog-rollover.md#uc-01-chuyển-task-vào-backlog)) | Như A5 | – |
| A9 | Hoàn tác A5, A7, A8 ([G10 UC-04](g10-tro-ly-ai.md#uc-04-hoàn-tác-hành-động-ai) khi do AI) | Timebox và liên kết khôi phục | – |
| A10 | Kéo timebox liên kết sự kiện | Không cho | MSG-26 |
| A11 | Timebox lập lịch cứng | Bỏ (1.1) | – |
| A12 | Ctrl+X trên task (B22) | Mọi block `CHO_XOA`, task về projection; Hoàn tác tạo lại hết | MSG-10 |
| E1 | Thời lượng dưới 5 phút | Dừng ở 5 phút | MSG-17 |
| E2 | Đổi từ lịch ngoài / thiết bị khác | Đổi giờ trong ngày: theo server, không báo; kéo sang ngày khác bị `VERSION_CONFLICT`: tải lại (B21); đã bị gỡ thì báo | Câu xung đột QC-08 mục 2 (kéo sang ngày khác); MSG-29 (khi bị gỡ) |
| E3 | `TimeboxSet` / `TimeboxDelete` lỗi | Block như cũ | QC-MSG-01 |
| E4 | Mất mạng (C22) | Chạy trên máy, dấu "Chờ đồng bộ", gửi lại qua `SyncBatch` | MSG-07 |

---

## UC-06 Đẩy timebox ra lịch ngoài (job `timebox.push`)

**Mở đầu:** sự kiện hệ thống: timebox `CHO_DONG_BO` / `CHO_XOA` / `LOI` (không phải `LIEN_KET_SU_KIEN`), tài khoản lịch ghi `HOAT_DONG` / `DONG_BO_CHAM`. **Thành công:** sự kiện ngoài khớp block, block `DA_DONG_BO` (hoặc bản ghi bị xoá với `CHO_XOA`). **Thất bại:** block `LOI`, thử lại theo BR-12.

### Happy case

```mermaid
flowchart TD
  start(["Hệ thống: block vừa tạo / sửa CHO_DONG_BO<br/>job timebox.push chạy"])
  p1[["Lấy block<br/>gộp thay đổi cùng block trong 2 giây BR-12"]]
  d1{"Đã có externalEventId?"}
  p2[["PATCH sự kiện trên calendarId đã cố định"]]
  p3[["Tìm appBlockId trên mọi lịch của tài khoản BR-11<br/>có thì PATCH, không thì tạo mới trên lịch đích BR-04"]]
  p4[["Dựng nội dung theo bảng map mục 8"]]
  p5[["Lưu externalEventId, etag<br/>lần đẩy đầu cố định calendarId · DA_DONG_BO<br/>phát task.upserted"]]
  ok(["SCR-05 block bình thường, icon lịch<br/>sự kiện có trên Google / Outlook"])

  start ==> p1 ==> d1
  d1 ==>|"có"| p2 ==> p4
  d1 ==>|"chưa"| p3 ==> p4
  p4 ==> p5 ==> ok

  class start,p1,d1,p2,p3,p4,p5 happy
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
  start(["Hệ thống: job timebox.push"])
  p1[["Lấy block, gộp 2 giây"]]
  pw[["PATCH hoặc tạo sự kiện"]]
  p5[["Lưu externalEventId, etag · DA_DONG_BO"]]
  ok(["SCR-05 block icon lịch"])
  start ==> p1 ==> pw ==> p5 ==> ok

  p1 -->|"A1 · block CHO_XOA"| a1[["DELETE sự kiện<br/>404 / 410 coi như đã xoá"]]
  a1 --> a1ok(["Bản ghi block bị xoá"])
  p1 -->|"A2 · lịch ghi channel / mặc định đổi,<br/>hoặc task đổi channel, sau khi đã có sự kiện"| a2["Giữ sự kiện ở lịch đích đã cố định<br/>không tạo sự kiện ở lịch mới"]
  a2 --> pw
  pw -->|"A3 · etag khác: sự kiện bị sửa ngoài app"| a3[["Đọc bản mới, áp BR-13<br/>giờ: bên sửa muộn hơn thắng · tiêu đề: app thắng<br/>đã chuyển lịch: cập nhật calendarId rồi PATCH"]]
  a3 --> p5
  start4(["Hệ thống: timebox bị gỡ<br/>khi tài khoản CAN_KET_NOI_LAI"]) -->|"A4"| a4["Giữ CHO_XOA"]
  a4 --> a4x{{"→ UC-08 bước 4"}}

  class start,p1,pw,p5 happy
  class a1,a2,a3,start4 alt
  class a4 sync
  class a4x link
  class ok,a1ok done
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
  start(["Hệ thống: job timebox.push"])
  pw[["PATCH hoặc tạo sự kiện"]]
  p5[["DA_DONG_BO"]]
  ok(["SCR-05 block icon lịch"])
  start ==> pw ==> p5 ==> ok

  pw -.->|"E1 · 429 / rate limit"| e1[["Chờ theo Retry-After<br/>block giữ CHO_DONG_BO"]]
  e1 -.->|"người dùng đang thao tác"| e1m>"MSG-16 · Toast<br/>{Nhà cung cấp} đang giới hạn tốc độ,<br/>timebox sẽ được đồng bộ sau ít phút"]
  e1 -.->|"hết thời gian chờ"| pw
  pw -.->|"E2 · 5xx / timeout"| e2[["LOI · thử lại 1, 5, 15, 60 phút<br/>rồi mỗi giờ, tối đa 24 giờ BR-12"]]
  e2 -.->|"thử lại"| pw
  e2 -.-> e2s["SCR-05 block icon cảnh báo"]
  e2s -.-> e2m>"MSG-08 · Tooltip<br/>Chưa ghi được lên {tên lịch}. Đang thử lại · Thử ngay"]
  e2m -.->|"Thử ngay · TimeboxRetry"| pw
  e2 -.->|"quá 24 giờ"| e2f(["Block LOI, dừng thử lại<br/>chờ người dùng Thử ngay"])
  pw -.->|"E3 · 401 / invalid_grant EC-15"| e3[["Tài khoản CAN_KET_NOI_LAI BR-16<br/>block giữ CHO_DONG_BO"]]
  e3 -.-> e3m>"MSG-06 · Banner SCR-09<br/>Mất kết nối {nhà cung cấp} ({email}).<br/>{n} timebox đang chờ đồng bộ · Kết nối lại"]
  e3m -.-> e3x{{"→ UC-08"}}
  pw -.->|"E4 · 403 lịch mất quyền ghi"| e4["Block LOI<br/>SCR-02 đánh dấu lịch Chỉ đọc"]
  e4 -.-> e4m>"MSG-15 · Tooltip<br/>Lịch này chỉ đọc, hãy chọn lịch khác để ghi timebox"]
  pw -.->|"E5 · 404 khi PATCH"| e5[["Tìm appBlockId trên mọi lịch BR-11"]]
  e5 -.->|"thấy"| e5a[["BR-13 d: sự kiện đã chuyển lịch<br/>cập nhật calendarId"]]
  e5a -.-> pw
  e5 -.->|"không thấy"| e5b[["BR-13 b: gỡ timebox, không tạo lại EC-13<br/>task giữ ngày dự định"]]
  e5b -.-> e5m>"MSG-14 · Thông báo trong app<br/>Timebox của #quot;{tiêu đề}#quot; đã được gỡ vì sự kiện bị xoá<br/>trên {tên lịch}. Task vẫn ở {ngày dự định}"]
  e5m -.-> e5f(["Timebox bị gỡ"])

  class start,pw,p5 happy
  class e1,e3 sync
  class e1m,e2,e2s,e2m,e3m,e4,e4m,e5,e5a,e5b,e5m err
  class e3x link
  class ok done
  class e2f,e5f fail
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
| A1 | Block `CHO_XOA` | Sự kiện xoá, bản ghi block xoá | – |
| A2 | Lịch ghi / channel đổi sau khi đã có sự kiện | Sự kiện giữ ở lịch đích cố định | – |
| A3 | Sự kiện bị sửa ngoài app (etag khác) | Áp BR-13 rồi PATCH | – |
| A4 | `CHO_XOA` khi tài khoản `CAN_KET_NOI_LAI` | Chờ [UC-08](#uc-08-kết-nối-lại-và-ngắt-kết-nối) bước 4 | – |
| E1 | 429 | Chờ `Retry-After`, giữ `CHO_DONG_BO` | MSG-16 |
| E2 | 5xx / timeout | `LOI`, thử lại tới 24 giờ | MSG-08 |
| E3 | 401 / `invalid_grant` | `CAN_KET_NOI_LAI` → [UC-08](#uc-08-kết-nối-lại-và-ngắt-kết-nối) | MSG-06 |
| E4 | 403 mất quyền ghi | Block `LOI`, lịch đánh dấu chỉ đọc | MSG-15 |
| E5 | 404 khi PATCH | Chuyển lịch → cập nhật; không thấy → gỡ timebox (B19) | MSG-14 (khi gỡ) |
| (tiền điều kiện) | Workspace chỉ đọc | Bỏ (1.1) | – |

---

## UC-07 Nhận thay đổi từ lịch ngoài

**Mở đầu:** sự kiện hệ thống: Google / Microsoft gọi webhook, hoặc tới lượt poll 15 phút; tài khoản `HOAT_DONG` / `DONG_BO_CHAM`. **Thành công:** cache sự kiện cập nhật, block liên quan cập nhật / xoá theo BR-13, cờ `XUNG_DOT` đúng, thiết bị nhận `calendar.changed` trong 5 giây. **Thất bại:** cache giữ bản cũ, lần poll / webhook sau xử lý lại.

### Happy case

```mermaid
flowchart TD
  start(["Hệ thống: Google / Microsoft gọi CalendarWebhook<br/>hoặc tới lượt poll 15 phút"])
  p1[["Xác thực webhook: channel token / clientState<br/>xếp job calendar.sync cho lịch đó"]]
  p2[["Đọc phần thay đổi bằng syncToken / delta BR-03"]]
  d1{"Sự kiện có appTaskId<br/>của timebox còn liên kết?"}
  p3[["Cập nhật cache, phân loại BR-09<br/>tính lại XUNG_DOT BR-14<br/>gốc của timebox liên kết → BR-21 b"]]
  p4[["Áp BR-13, ghi nhật ký tác nhân integration"]]
  p5[["Phát calendar.changed / task.upserted<br/>G04 tính lại sức chứa, projection"]]
  ok(["SCR-04 lưới lịch, SCR-05 block cập nhật<br/>trên mọi thiết bị trong 5 giây"])

  start ==> p1 ==> p2 ==> d1
  d1 ==>|"không"| p3 ==> p5
  d1 ==>|"có"| p4 ==> p5
  p5 ==> ok

  class start,p1,p2,d1,p3,p4,p5 happy
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

### Nhánh thay thế: sự kiện timebox do app tạo

```mermaid
flowchart TD
  start(["Hệ thống: calendar.sync"])
  p2[["Đọc thay đổi syncToken / delta"]]
  d1{"Sự kiện có appTaskId?"}
  p4[["Áp BR-13"]]
  p5[["Phát calendar.changed / task.upserted"]]
  start ==> p2 ==> d1
  d1 ==>|"có, timebox còn liên kết"| p4 ==> p5

  p2 -->|"A5 · Google 410 / delta hết hiệu lực"| a5[["DANG_DONG_BO: đồng bộ lại toàn bộ cửa sổ<br/>đối chiếu appBlockId, không tạo trùng"]]
  a5 --> d1
  a5 -->|"bước so sánh: timebox DA_DONG_BO<br/>không còn sự kiện"| a1
  p2 -->|"A8 · sự kiện sang ngày đổi giờ mùa hè EC-03"| a8["Giữ thời điểm tuyệt đối từ lịch ngoài<br/>hiển thị theo giờ địa phương"]
  a8 --> d1
  d1 -->|"A12 · appBlockId của timebox đã tách liên kết"| a12(["Bỏ qua BR-19"])
  p4 -->|"A1 · sự kiện timebox bị xoá EC-13"| a1[["Không thấy appBlockId ở lịch khác<br/>BR-13 b: gỡ timebox, task giữ ngày dự định<br/>hết timebox thì về projection"]]
  a1 --> a1m>"MSG-14 · Thông báo trong app<br/>Timebox của #quot;{tiêu đề}#quot; đã được gỡ vì sự kiện bị xoá<br/>trên {tên lịch}. Task vẫn ở {ngày dự định}"]
  a1m --> p5
  p4 -->|"A2 · sự kiện bị dời giờ / ngày EC-14"| a2[["BR-13 a: bên sửa muộn hơn thắng<br/>lịch ngoài thắng → cập nhật timebox, startDate,<br/>planned nếu 1 timebox; chỉ ghi nhật ký"]]
  a2 --> p5
  p4 -->|"A6 · đổi tiêu đề / mô tả / riêng tư / bận"| a6[["BR-13 c: app thắng<br/>xếp timebox.push ghi đè"]]
  a6 --> a6x{{"→ UC-06"}}
  p4 -->|"A9 · đổi thành sự kiện cả ngày"| a9[["BR-13 e: gỡ timebox, task giữ nguyên"]]
  a9 --> a9m>"MSG-31 · Thông báo trong app<br/>Timebox của #quot;{tiêu đề}#quot; đã được gỡ vì sự kiện<br/>được đổi thành cả ngày trên {tên lịch}"]
  a9m --> p5
  p4 -->|"A10 · chuyển sang lịch khác cùng tài khoản"| a10[["BR-13 d: cập nhật calendarId<br/>không gỡ, không tạo sự kiện mới<br/>lịch mới chỉ đọc → lần ghi sau lỗi UC-06 E4"]]
  a10 --> p5
  start7(["Hệ thống: timezone người dùng đổi EC-02"]) -->|"A7"| a7[["Giữ startsAt / endsAt, không tính lại startDate<br/>không gắn cờ F5, G04 vẽ lại<br/>không banner riêng, chỉ G01 MSG-23"]]
  a7 --> a7x{{"→ G01 · UC-06 banner timezone"}}

  class start,p2,d1,p4,p5 happy
  class a5,a8,a12,a1,a2,a6,a9,a10,start7,a7 alt
  class a1m,a9m warn
  class a6x,a7x link
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

### Nhánh thay thế và lỗi: sự kiện ngoài, xung đột

```mermaid
flowchart TD
  start(["Hệ thống: CalendarWebhook / poll"])
  p1[["Xác thực webhook, xếp calendar.sync"]]
  p2[["Đọc thay đổi syncToken / delta"]]
  p3[["Sự kiện không có appTaskId:<br/>cập nhật cache, phân loại BR-09"]]
  p5[["Phát calendar.changed"]]
  start ==> p1 ==> p2 ==> p3 ==> p5

  p3 -->|"A3 · sự kiện chặn mới bận / tentative<br/>chồng timebox EC-16"| a3["SCR-05 block và card cờ XUNG_DOT<br/>viền cam, icon cảnh báo"]
  a3 --> u3[/"Bấm icon cảnh báo"/]
  u3 --> a3s["SCR-07 Popover xung đột"]
  a3s --> a3m>"MSG-13 · Popover<br/>Trùng với #quot;{tên sự kiện}#quot; ({giờ}) · Giữ nguyên · Mở lịch"]
  a3m -->|"Giữ nguyên"| a3k(["Ẩn cảnh báo cho cặp timebox – sự kiện này"])
  a3m -->|"Mở lịch"| a3x{{"→ G04 · UC-01 Calendar views<br/>tại ngày, giờ của timebox"}}
  p3 -->|"A4 · sự kiện không chặn: từ chối / free / cả ngày"| a4["Không gắn XUNG_DOT<br/>từ chối sự kiện đang gây XUNG_DOT → bỏ cờ"]
  a4 --> p5
  p3 -->|"A11 · gốc của timebox liên kết<br/>đổi giờ / bị xoá / đổi thành cả ngày"| a11[["BR-21 b: timebox đi theo hoặc bị gỡ<br/>task giữ nguyên"]]
  a11 --> p5
  a11 -->|"gỡ vì sự kiện bị xoá"| a11m>"MSG-14 · Thông báo trong app<br/>Timebox của #quot;{tiêu đề}#quot; đã được gỡ vì sự kiện bị xoá<br/>trên {tên lịch}. Task vẫn ở {ngày dự định}"]
  a11 -->|"gỡ vì sự kiện đổi thành cả ngày"| a11c>"MSG-31 · Thông báo trong app<br/>Timebox của #quot;{tiêu đề}#quot; đã được gỡ vì sự kiện<br/>được đổi thành cả ngày trên {tên lịch}"]

  p1 -.->|"E1 · webhook không xác thực được"| e1(["Trả 401, bỏ qua, ghi log bảo mật"])
  p2 -.->|"E2 · token lỗi khi đọc EC-15"| e2[["Tài khoản CAN_KET_NOI_LAI"]]
  e2 -.-> e2x{{"→ UC-08"}}
  p2 -.->|"E3 · 429"| e3[["Backoff, giữ cache cũ"]]
  e3 -.-> e3s>"MSG-32 · Text panel lịch SCR-04<br/>Cập nhật lúc {giờ}"]
  p2 -.->|"E4 · lỗi trên 2% trong 10 phút"| e4(["Cảnh báo vận hành<br/>người dùng không thấy"])

  class start,p1,p2,p3,p5 happy
  class u3,a3s,a4,a11 alt
  class a3,a3m,a11m,a11c warn
  class a3x,e2x link
  class a3k done
  class e2,e3s err
  class e3 sync
  class e1,e4 fail
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
| A1 | Sự kiện timebox bị xoá | Gỡ timebox, task giữ ngày | MSG-14 |
| A2 | Sự kiện timebox bị dời | Bên sửa muộn hơn thắng | – |
| A3 | Sự kiện chặn mới chồng timebox | `XUNG_DOT`, SCR-07 bản 1.0 chỉ có "Giữ nguyên" / "Mở lịch" (C17) ([G04 UC-01](g04-board-ngay.md#uc-01-xem-board-và-chuyển-chế-độ-xem)) | MSG-13 |
| A3 (nút "Dời sang khe trống") | Dời theo Shift+X | Bỏ (1.1) | – |
| A4 | Sự kiện không chặn | Không gắn cờ / bỏ cờ | – |
| A5 | Google 410 / delta hết hiệu lực | Đồng bộ lại toàn bộ, không trùng | – (MSG-14 nếu gỡ) |
| A6 | Đổi tiêu đề / mô tả / riêng tư / bận | App thắng → [UC-06](#uc-06-đẩy-timebox-ra-lịch-ngoài-job-timeboxpush) | – |
| A7 | Timezone đổi | Giữ giờ tuyệt đối, không gắn cờ (F5); banner ở [G01 UC-06](g01-tai-khoan.md#uc-06-xem-và-đổi-cài-đặt) | – (G01 MSG-23) |
| A8 | Ngày đổi giờ mùa hè | Hiển thị giờ địa phương | – |
| A9 | Đổi thành sự kiện cả ngày | Gỡ timebox | MSG-31 |
| A10 | Chuyển sang lịch khác | Cập nhật `calendarId` | – |
| A11 | Gốc của timebox liên kết đổi / xoá / đổi thành cả ngày | Timebox đi theo / bị gỡ | MSG-14 (bị xoá), MSG-31 (đổi thành cả ngày, C18) |
| A12 | Sự kiện mồ côi | Bỏ qua | – |
| A13 | Workspace chỉ đọc | Bỏ (1.1) | – |
| E1 | Webhook không xác thực | 401, log bảo mật | – |
| E2 | Token lỗi | `CAN_KET_NOI_LAI` → [UC-08](#uc-08-kết-nối-lại-và-ngắt-kết-nối) | – |
| E3 | 429 | Giữ cache | MSG-32 |
| E4 | Lỗi trên 2% / 10 phút | Cảnh báo vận hành | – |

---

## UC-08 Kết nối lại và ngắt kết nối

**Mở đầu:** tài khoản `CAN_KET_NOI_LAI` (kết nối lại) hoặc bất kỳ (ngắt). **Thành công:** kết nối lại: `HOAT_DONG`, mọi block chờ đã đẩy, không trùng; ngắt: tài khoản `DA_NGAT`, token thu hồi, block `CHI_TRONG_APP`. **Thất bại:** trạng thái cũ giữ nguyên.

### Happy case

```mermaid
flowchart TD
  start(["Tài khoản CAN_KET_NOI_LAI<br/>SCR-01 chấm đỏ, thông báo trong app / Windows G12"])
  s1["SCR-09 Banner cần kết nối lại"]
  m1>"MSG-06 · Banner<br/>Mất kết nối {nhà cung cấp} ({email}).<br/>{n} timebox đang chờ đồng bộ · Kết nối lại"]
  u1[/"Bấm Kết nối lại<br/>trên SCR-09 hoặc SCR-01"/]
  p1[["Như bước 2–4 UC-01, cùng tài khoản<br/>CalendarConnect, OAuth, CalendarCallback"]]
  p2[["DANG_DONG_BO: đồng bộ lại toàn bộ cửa sổ<br/>đối chiếu appBlockId, bước so sánh BR-03<br/>áp BR-13 cho thay đổi lúc mất kết nối"]]
  p3[["Đẩy mọi timebox CHO_DONG_BO / LOI / CHO_XOA<br/>theo BR-11 · UC-06"]]
  ok(["SCR-01 Đã kết nối HOAT_DONG<br/>banner ẩn, không sự kiện trùng"])

  start ==> s1 ==> m1 ==> u1 ==> p1 ==> p2 ==> p3 ==> ok

  class start,s1,m1,u1,p1,p2,p3 happy
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

### Nhánh thay thế và lỗi: kết nối lại

```mermaid
flowchart TD
  s1["SCR-09 Banner cần kết nối lại"]
  u1[/"Bấm Kết nối lại"/]
  p1[["OAuth, CalendarCallback"]]
  p2[["Đồng bộ lại toàn bộ cửa sổ"]]
  p3[["Đẩy timebox chờ · UC-06"]]
  ok(["HOAT_DONG, banner ẩn"])
  s1 ==> u1 ==> p1 ==> p2 ==> p3 ==> ok

  s1 -->|"bấm ×"| s1h["SCR-09 ẩn 24 giờ<br/>chấm đỏ ở SCR-01 vẫn còn"]
  p1 -->|"A3 · tài khoản khác email"| a3[["Tạo tài khoản mới<br/>tài khoản cũ vẫn CAN_KET_NOI_LAI"]]
  a3 --> a3x{{"→ UC-01"}}
  p2 -->|"A4 · cả timebox và sự kiện đều đã đổi"| a4[["BR-13: giờ → bên sửa muộn hơn thắng<br/>tiêu đề → app thắng · sự kiện bị xoá → gỡ timebox<br/>chuyển lịch → cập nhật calendarId"]]
  a4 --> p3
  start5(["SCR-01 · kết nối lại tài khoản đã ngắt DA_NGAT"]) -->|"A5"| a5[["Như UC-01; sự kiện mồ côi bị bỏ qua<br/>không liên kết lại timebox CHI_TRONG_APP"]]
  a5 --> a5x{{"→ UC-01"}}

  p1 -.->|"E1 · vẫn thiếu scope"| e1m>"MSG-02 · Inline dưới dòng tài khoản lịch SCR-01<br/>Cần quyền xem và sửa lịch để dùng timebox.<br/>Hãy kết nối lại và giữ đủ quyền"]
  e1m -.-> e1(["Giữ CAN_KET_NOI_LAI"])

  class s1,u1,p1,p2,p3 happy
  class s1h,a3,a4,start5,a5 alt
  class a3x,a5x link
  class e1m err
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

### Nhánh thay thế và lỗi: ngắt kết nối

```mermaid
flowchart TD
  start(["SCR-01 Cài đặt → Lịch · tài khoản"])
  start -->|"A1 · bấm Ngắt kết nối"| a1s["SCR-08 Xác nhận ngắt kết nối<br/>checkbox xoá sự kiện mặc định tắt"]
  a1s --> a1m>"MSG-18 · Dialog<br/>Ngắt kết nối {email}? Sự kiện sẽ không hiện trong app nữa;<br/>timebox trong app được giữ lại"]
  a1m -->|"Huỷ"| a1c(["Đóng dialog, không đổi"])
  a1m --> a1u[/"Bấm Ngắt kết nối"/]
  a1m -->|"A2 · tích Xoá các sự kiện timebox app đã tạo"| a2u[/"Bấm Ngắt kết nối"/]
  a2u --> a2[["Xoá mọi sự kiện có appTaskId trên các lịch<br/>trước khi thu hồi token<br/>không đụng sự kiện gốc của timebox liên kết"]]
  a2 --> a1p
  a1u --> a1p[["CalendarDisconnect · BR-19<br/>thu hồi token, huỷ webhook, xoá cache sự kiện<br/>timebox CHI_TRONG_APP, tách liên kết"]]
  a1p --> a1t>"MSG-19 · Toast<br/>Đã ngắt kết nối {email}"]
  a1t --> a1ok(["Tài khoản DA_NGAT, không còn trong danh sách"])
  a1p -.->|"E2 · thu hồi token ở nhà cung cấp lỗi"| e2[["Vẫn xoá token phía app, ghi log<br/>thử thu hồi lại tối đa 3 lần"]]
  e2 -.-> a1t

  class start,a1s,a1m,a1u,a1p,a1t,a2u,a2 alt
  class e2 err
  class a1c,a1ok done
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
| A1 | Ngắt kết nối | SCR-08 → `DA_NGAT`, timebox `CHI_TRONG_APP` | MSG-18, MSG-19 |
| A2 | Tích "Xoá các sự kiện timebox app đã tạo" | Sự kiện app tạo bị xoá trước khi thu hồi | MSG-19 |
| A3 | Kết nối lại bằng email khác | Tài khoản mới → [UC-01](#uc-01-kết-nối-tài-khoản-lịch) | – |
| A4 | Cả hai phía đều đã đổi | Áp BR-13 | – |
| A5 | Kết nối lại tài khoản đã ngắt | Như [UC-01](#uc-01-kết-nối-tài-khoản-lịch), không liên kết lại | – |
| E1 | Vẫn thiếu scope | Giữ `CAN_KET_NOI_LAI` | MSG-02 |
| E2 | Thu hồi token ở nhà cung cấp lỗi | Vẫn ngắt, thử thu hồi lại 3 lần | MSG-19 |

---

## UC-10 Tạo timebox liên kết sự kiện

**Mở đầu:** Daily planning bước Thêm task (G08): người dùng kéo sự kiện lịch thành task; sự kiện có trong cache, không mang `appTaskId`, không phải cả ngày. **Thành công:** task có timebox `LIEN_KET_SU_KIEN` cùng giờ sự kiện, không có sự kiện mới trên lịch ngoài. **Thất bại:** task không có timebox liên kết, task vẫn tồn tại (G08 xử lý).

### Happy case

```mermaid
flowchart TD
  start(["G08 · UC-01 Daily planning bước Thêm task<br/>kéo sự kiện lịch thành task"])
  p1[["G08 gọi TimeboxLink<br/>taskId, calendarId, eventId"]]
  p2[["Kiểm sự kiện tồn tại<br/>tạo timebox kind = event_linked, giờ của sự kiện<br/>startDate = workday(startsAt)"]]
  p3[["Không xếp timebox.push, phát task.upserted<br/>G04 tính sức chứa không trừ hai lần"]]
  ok(["SCR-05 block LIEN_KET_SU_KIEN<br/>viền liền màu lịch gốc, icon liên kết, không kéo được"])

  start ==> p1 ==> p2 ==> p3 ==> ok

  class start,p1,p2,p3 happy
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
  p1[["TimeboxLink"]]
  p2[["Tạo timebox event_linked"]]
  p3[["Phát task.upserted"]]
  ok(["SCR-05 block LIEN_KET_SU_KIEN"])
  p1 ==> p2 ==> p3 ==> ok

  p2 -->|"A1 · sự kiện đã có task liên kết"| a1(["Trả timebox đã có, không tạo thêm<br/>G08 BR-07: một sự kiện một task"])
  p2 -->|"A2 · một lần xuất hiện của sự kiện lặp"| a2["Liên kết đúng lần xuất hiện đó<br/>eventId của instance"]
  a2 --> p3
  p2 -.->|"E1 · sự kiện không còn / tài khoản CAN_KET_NOI_LAI"| e1[["EVENT_NOT_FOUND"]]
  e1 -.-> e1m>"MSG-14 · Thông báo trong app<br/>Timebox của #quot;{tiêu đề}#quot; đã được gỡ vì sự kiện bị xoá<br/>trên {tên lịch}. Task vẫn ở {ngày dự định}"]
  e1m -.-> e1x{{"→ G08 · UC-01 tạo task không có timebox"}}
  e1x -.-> fail(["Task không có timebox liên kết"])

  class p1,p2,p3 happy
  class a1,a2 alt
  class e1,e1m err
  class e1x link
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
| A1 | Sự kiện đã có task liên kết | Timebox đã có | – |
| A2 | Lần xuất hiện của sự kiện lặp | Liên kết đúng lần đó | – |
| E1 | Sự kiện không còn / cần kết nối lại | Task không có timebox → [G08 UC-01](g08-daily-rituals.md#uc-01-daily-planning-luồng-thủ-công) | MSG-14 (`EVENT_NOT_FOUND`, C23) |

---

## UC-11 Xử lý cờ "Lệch ngày"

Bỏ theo F5 (06/11/2026): không còn cờ Lệch ngày.

## Kiểm tra

- [x] Mọi A# / E# của UC-01 … UC-10 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)"; UC-05 và UC-09 thuần 1.1, UC-11 bỏ theo F5, ghi bỏ ở Mục lục.
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG.

**Ghi chú cho brief G05**
- ~~MSG-13 chứa cả phần của 1.1, brief nên tách nội dung theo bản.~~ **Đã sửa 09/11/2026 (C17):** MSG-13 bản 1.0 chỉ có "Giữ nguyên · Mở lịch"; "Dời sang khe trống" ghi "(1.1)", ẩn hẳn ở 1.0 (QC-13 mục 6). Sơ đồ UC-07 đã bỏ phần 1.1.
- ~~UC-07 A11 dùng MSG-14 cho cả trường hợp sự kiện gốc đổi thành cả ngày.~~ **Đã sửa 09/11/2026 (C18):** nhánh đổi thành cả ngày dùng MSG-31; sơ đồ UC-07 tách hai thông báo.
- ~~UC-06 E5 (404 khi PATCH, không thấy sự kiện) gỡ timebox nhưng không nói có MSG-14.~~ **Đã sửa 09/11/2026 (B19):** gỡ timebox và báo MSG-14 như UC-07 A1; đã thêm vào sơ đồ UC-06.
- ~~"Cập nhật lúc {giờ}", "Cập nhật mỗi 15 phút", "Đang chờ xác nhận…", "Đang đồng bộ…" chưa có mã MSG.~~ **Đã sửa 09/11/2026 (C19):** MSG-32, MSG-33, MSG-34, MSG-35.
- ~~UC-01 E5 dùng MSG-21 "Chưa lưu được thay đổi", không hợp ngữ cảnh kết nối lịch.~~ **Đã sửa 09/11/2026 (C20):** MSG-36 "Chưa kết nối được {Google Calendar / Outlook}. Thử lại".
- ~~UC-01 E4: PRD còn hỏi bản 1.0 có áp giới hạn số tài khoản lịch không.~~ **Đã sửa 09/11/2026 (B17):** có, giới hạn kỹ thuật 5 tài khoản, đọc từ bảng quyền; bỏ `[giả định]`.
- ~~Lịch ghi mặc định có ở hai chỗ (SCR-01 #5 và SCR-02 #4).~~ **Đã sửa 09/11/2026 (B18):** chỉ chọn ở SCR-01 #5, có "Không ghi ra lịch ngoài"; SCR-02 #4 bỏ; UC-02 bước 2 và A3 sửa theo; sơ đồ UC-02 vẽ lại.
- ~~UC-01 E1, E2, E3, E5 không nói người dùng dừng ở màn nào; MSG-02 inline không nói ở đâu.~~ **Đã sửa 09/11/2026 (C21):** E1–E5 kết thúc ở SCR-01; MSG-02 hiện ngay dưới dòng tài khoản lịch.
- ~~UC-03 A1: không rõ MSG-23 thay thế hay hiện cùng MSG-09.~~ **Đã sửa 09/11/2026 (A3):** một toast, dòng 1 MSG-09 giữ Hoàn tác, dòng 2 MSG-23 (QC-13 mục 3).
- ~~UC-03 A9 dẫn tới lệnh "Timebox…" mà SRS G04 chưa có.~~ **Đã sửa 09/11/2026 (B20):** giữ A9, bỏ `[giả định]`; lệnh nằm trong command menu G04 (G04 bổ sung).
- ~~BR-21 (f) và SRS G04 BR-09 mâu thuẫn về timebox liên kết sự kiện khi đổi ngày.~~ **Đã sửa 06/11/2026:** G04 BR-09 theo QC-05 (chỉ gỡ liên kết); UC-04 A5, A7, A8 đã có nhánh timebox liên kết sự kiện.
- ~~UC-04 không có nhánh mất mạng.~~ **Đã sửa 09/11/2026 (C22):** thêm E4: dời / gỡ chạy trên máy, dấu "Chờ đồng bộ", gửi lại qua `SyncBatch` (QC-08 mục 7).
- ~~UC-04 E2 nói "không báo lỗi" nhưng map lỗi gán `VERSION_CONFLICT` → MSG-21.~~ **Đã sửa 09/11/2026 (B21):** kéo sang ngày khác bị `VERSION_CONFLICT` thì báo câu xung đột chung QC-08 mục 2 và tải lại; đổi giờ trong ngày vẫn không báo. Map lỗi mục 8 tách dòng.
- ~~Gỡ timebox luôn xoá mọi block của task, không gỡ riêng được một block.~~ **Đã sửa 09/11/2026 (B22):** "Gỡ khỏi lịch" trên một block chỉ gỡ block đó (UC-04 A1, SCR-05 #9, SCR-06 #3); Ctrl+X trên task gỡ hết (UC-04 A12).
- ~~UC-10 E1 trả `EVENT_NOT_FOUND`, mã này không có trong bảng map lỗi.~~ **Đã sửa 09/11/2026 (C23):** `EVENT_NOT_FOUND` → MSG-14.
- ~~SCR-05 #6 ghi thành phần là ký hiệu dấu tích.~~ **Đã sửa 09/11/2026 (C24):** dấu xong là icon (QC-13 mục 4).
- **Đã sửa 09/11/2026 (A1):** MSG-21 bỏ, các nhánh lỗi lưu trỏ về QC-MSG-01 (QC-13 mục 1).
