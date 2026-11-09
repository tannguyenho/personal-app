# Flow G12 Workspace, thông báo (phần 1.0)

> **Nguồn:** [srs-g12](../../features/srs-g12-workspace-billing.md) (commit `8fac830`, sửa theo chốt 09/11/2026) · **Brief:** `[chờ]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

Bản 1.0 là app Windows một người dùng, miễn phí, nhãn Beta. G12 ở 1.0 chỉ gồm: workspace cá nhân (đổi tên), cài đặt Thông báo, trung tâm thông báo, huỷ đăng ký email (SRS BR-22). Trial, thanh toán, chế độ chỉ đọc là 1.1; nhiều thành viên, Privacy, giao / follow task là bản sau, từ 1.2 (BR-28).

## Mục lục

| UC | Flow | Màn chính | Nhánh A / E (1.0) |
|---|---|---|---|
| UC-01 | Nâng cấp gói | – | Bỏ (1.1) |
| UC-02 | Hết trial, gia hạn, thử lại và chế độ chỉ đọc | – | Bỏ (1.1) |
| UC-03 | Đổi gói, huỷ gói và tải hoá đơn | – | Bỏ (1.1) |
| UC-04 | Mời thành viên | – | Bỏ (1.2) |
| [UC-05](#uc-05-quản-lý-thành-viên-và-workspace) | Quản lý thành viên và workspace: **chỉ A5 đổi tên workspace** | SCR-12 Workspace | 1 / 3 (phần còn lại Bỏ (1.2)) |
| UC-06 | Cài đặt quyền riêng tư | – | Bỏ (1.2), không vẽ ở 1.0 (C47) |
| UC-07 | Giao task và follow task | – | Bỏ (1.2) |
| [UC-08](#uc-08-cài-đặt-thông-báo-và-huỷ-đăng-ký-email) | Cài đặt thông báo và huỷ đăng ký email | SCR-10, SCR-14 | 2 / 3 (A1, A3 Bỏ (1.1)) |
| [UC-09](#uc-09-trung-tâm-thông-báo) | Trung tâm thông báo | SCR-11 | 5 / 2 |

---

## UC-05 Quản lý thành viên và workspace

Ở 1.0 chỉ có **A5 Đổi tên workspace**; luồng chính (đổi vai trò) và các nhánh khác là bản sau (BR-28). Sơ đồ dưới vẽ A5 như luồng chính của bản 1.0.

**Mở đầu:** Cài đặt → Workspace (SCR-12), người dùng là `OWNER` của workspace cá nhân. **Thành công:** tên workspace mới được lưu ngay. **Thất bại:** không thay đổi.

### Happy case (A5 đổi tên workspace)

```mermaid
flowchart TD
  start(["Avatar → Cài đặt hoặc Ctrl+,<br/>nhóm Workspace"])
  s1["SCR-12 Workspace<br/>Tên workspace 1–80 ký tự<br/>không có nút Xoá workspace ở 1.0, 1.1, B47"]
  u1[/"Sửa tên workspace"/]
  p1[["WorkspaceUpdate name<br/>lưu ngay"]]
  m22>"G01 MSG-22 · Inline cạnh trường, kèm icon dấu tích<br/>Đã lưu"]
  ok(["SCR-12 hiện tên workspace mới"])

  start ==> s1 ==> u1 ==> p1 ==> m22 ==> ok

  class start,s1,u1,p1,m22 happy
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
  s1["SCR-12 Workspace"]
  u1[/"Sửa tên workspace"/]
  p1[["WorkspaceUpdate"]]
  ok(["Tên mới"])
  s1 ==> u1 ==> p1 ==> ok

  p1 -.->|"E4 · lỗi 5xx / timeout"| e4m>"MSG-38 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e4m -.-> fail(["Không thay đổi"])
  u1 -.->|"E5 · tên trống hoặc quá 80 ký tự"| e5m>"MSG-58 · Inline<br/>Tên workspace từ 1 đến 80 ký tự"]
  e5m -.-> fail
  u1 -.->|"E6 · mất mạng"| e6["Áp ngay trên máy, xếp hàng đợi<br/>cạnh trường hiện dấu Chờ đồng bộ, QC-08 mục 7"]
  e6 -.->|"có mạng, dấu đổi thành G01 MSG-22 Đã lưu"| p1

  class s1,u1,p1 happy
  class e6 sync
  class e4m,e5m err
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
| Luồng chính | Đổi vai trò thành viên | Bỏ (1.2) | – |
| A1 | Xoá thành viên | Bỏ (1.2) | – |
| A2 | Chuyển quyền sở hữu | Bỏ (1.2) | – |
| A3 | Rời workspace | Bỏ (1.2) | – |
| A4 | Xoá workspace | Bỏ (1.2, xét lại); 1.0 và 1.1 không có nút, xoá workspace cá nhân = xoá tài khoản ([G01 · UC-09](g01-tai-khoan.md)) (B47) | – |
| A5 | Đổi tên workspace | Tên mới, lưu ngay | G01 MSG-22 (C48) |
| A6 | Chủ mới chưa nhập phương thức thanh toán | Bỏ (1.2) | – |
| E1 | Sai vai trò | Bỏ (1.2) | – |
| E2 | `OWNER` rời khi còn thành viên | Bỏ (1.2) | – |
| E3 | Gõ sai tên workspace / mật khẩu khi xoá, chuyển quyền | Bỏ (1.2) | – |
| E4 | Lỗi 5xx (áp cho A5 theo bảng map lỗi mục 8) | Không thay đổi | MSG-38 |
| E5 | Tên trống hoặc quá 80 ký tự (A5) | Không lưu | MSG-58 (C48) |
| E6 | Mất mạng khi đổi tên (A5) | Áp trên máy, dấu "Chờ đồng bộ", gửi lên khi có mạng (A6) | G01 MSG-22 khi đã gửi |

---

## UC-08 Cài đặt thông báo và huỷ đăng ký email

**Mở đầu:** Cài đặt → Thông báo (SCR-10), hoặc link "Huỷ nhận loại email này" trong email (không cần đăng nhập). **Thành công:** ô sự kiện × kênh được lưu; thông báo sau đó gửi theo cài đặt mới. **Thất bại:** giữ cài đặt cũ.

### Happy case

```mermaid
flowchart TD
  start(["Avatar → Cài đặt hoặc Ctrl+, nhóm Thông báo<br/>hoặc icon Cài đặt thông báo trên SCR-11"])
  p1[["SettingsGet nhóm notifications"]]
  s1["SCR-10 Cài đặt Thông báo<br/>bảng sự kiện × kênh của bản 1.0:<br/>Trong app · Email · Desktop (thông báo Windows)"]
  u1[/"Bật / tắt một ô"/]
  p2[["SettingsUpdate"]]
  s2["SCR-10 ô mới, G01 MSG-22 Đã lưu<br/>kèm icon dấu tích"]
  ok(["Thông báo kế tiếp gửi theo cài đặt mới"])

  start ==> p1 ==> s1 ==> u1 ==> p2 ==> s2 ==> ok

  class start,p1,s1,u1,p2,s2 happy
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
  s1["SCR-10 Cài đặt Thông báo"]
  u1[/"Bật / tắt một ô"/]
  p2[["SettingsUpdate"]]
  s2["SCR-10 dấu Đã lưu"]
  s1 ==> u1 ==> p2 ==> s2

  s1 -->|"A4 · Windows chưa cho app gửi thông báo"| a4["SCR-10 #3 nút Cho phép thông báo trên thiết bị<br/>ẩn khi đã cho phép"]
  a4 -->|"bấm"| a4b(["Mở quyền thông báo của Windows"])
  u1 -->|"BR-18 · bật Product updates, SCR-10 #4"| pu[["Lưu đồng ý tiếp thị kèm thời điểm<br/>tắt, tức rút lại, được bất cứ lúc nào"]]
  pu --> p2
  mail(["Email thông báo · link Huỷ nhận loại email này<br/>mở trong trình duyệt, không cần đăng nhập"]) -->|"A2"| a2[["Unsubscribe với token<br/>tắt đúng sự kiện × email"]]
  a2 --> a2m>"MSG-35 · SCR-14 Trang huỷ đăng ký email<br/>Đã huỷ nhận email #quot;{loại}#quot; · Bật lại"]
  a2m -->|"Bật lại"| a2u[["Unsubscribe undo=true"]]

  a2 -.->|"E1 · token sai / hết hạn, UNSUBSCRIBE_TOKEN_INVALID"| e1m>"MSG-36 · SCR-14<br/>Link huỷ đăng ký không hợp lệ. Mở Cài đặt → Thông báo để chỉnh"]
  p2 -.->|"E2 · SettingsUpdate lỗi"| e2["Ô về giá trị cũ"]
  e2 -.-> e2m>"MSG-38 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  u1 -.->|"E3 · mất mạng"| e3["Áp ngay trên máy, xếp hàng đợi<br/>cạnh ô hiện dấu Chờ đồng bộ, QC-08 mục 7"]
  e3 -.->|"có mạng"| p2

  class s1,u1,p2,s2 happy
  class e3 sync
  class a4,a4b,pu,mail,a2,a2m,a2u alt
  class e1m,e2,e2m err
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
| A1 | Ô bắt buộc (email thanh toán, trial, sắp xoá dữ liệu) | Bỏ (1.1): ẩn ở 1.0, SRS UC-08 A1, SCR-10 #2 ghi "(1.1)" (C49) | MSG-34 (1.1) |
| A2 | Bấm link huỷ nhận trong email | SCR-14, tắt đúng sự kiện × email; Bật lại được. Link "Mở cài đặt thông báo" (SCR-14 #3) ẩn ở 1.0, bật từ 1.1 (B48) | MSG-35 |
| A3 | Recap tuần: thêm người nhận (G09) | Bỏ (1.1) | – |
| A4 | Windows chưa cho phép thông báo | Nút mở quyền thông báo của Windows | – |
| E1 | Token huỷ đăng ký sai / hết hạn | SCR-14 báo lỗi | MSG-36 |
| E2 | `SettingsUpdate` lỗi | Ô về giá trị cũ | MSG-38 |
| E3 | Mất mạng khi bật / tắt ô | Áp trên máy, dấu "Chờ đồng bộ", gửi lên khi có mạng; xung đột theo G01 BR-12 (A6) | G01 MSG-22 khi đã gửi |
| BR-18 | Bật Product updates | Lưu đồng ý tiếp thị kèm thời điểm | – |

---

## UC-09 Trung tâm thông báo

**Mở đầu:** sự kiện từ nhóm phát sinh (G05, G07, G08…); người dùng bấm chuông ở cụm dưới sidebar, hoặc bấm thông báo Windows. **Thành công:** thông báo hiện đúng người nhận, đúng kênh; trạng thái đọc đồng bộ mọi thiết bị. **Thất bại:** thông báo giữ `CHUA_DOC`.

### Happy case

```mermaid
flowchart TD
  start(["Sự kiện từ nhóm phát sinh<br/>G05, G07, G08…"])
  p1[["Áp cài đặt người nhận BR-18, gộp 5 phút BR-19<br/>tạo thông báo CHUA_DOC, notification.created<br/>gửi email, thông báo Windows nếu kênh bật"]]
  s1["SCR-11 #1 Chuông ở cụm dưới sidebar<br/>badge chưa đọc tăng trong ≤ 5 giây, tối đa 99+"]
  u1[/"Bấm chuông"/]
  p2[["NotificationList"]]
  s2["SCR-11 Trung tâm thông báo · popover cạnh chuông<br/>mới nhất trước, chấm chưa đọc"]
  u2[/"Bấm một thông báo"/]
  p3[["NotificationRead → DA_DOC<br/>đồng bộ thiết bị khác ≤ 5 giây"]]
  ok(["Mở đúng đích theo bảng loại thông báo 1.0<br/>SRS UC-09, C51"])

  start ==> p1 ==> s1 ==> u1 ==> p2 ==> s2 ==> u2 ==> p3 ==> ok

  class start,p1,s1,u1,p2,s2,u2,p3 happy
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
  p1[["Tạo thông báo CHUA_DOC"]]
  s1["SCR-11 #1 Chuông + badge"]
  u1[/"Bấm chuông"/]
  p2[["NotificationList"]]
  s2["SCR-11 Trung tâm thông báo"]
  u2[/"Bấm một thông báo"/]
  p3[["NotificationRead"]]
  ok(["Mở đúng đích"])
  p1 ==> s1 ==> u1 ==> p2 ==> s2 ==> u2 ==> p3 ==> ok

  p1 -->|"BR-19 · nhiều thông báo cùng task, cùng người nhận trong 5 phút"| g43>"MSG-43 · Trung tâm / email<br/>#quot;{tiêu đề}#quot;: {n} cập nhật mới"]
  win(["Thông báo Windows của app"]) -->|"điểm vào · bấm thông báo, IA-10"| wa["Đưa cửa sổ app lên trước<br/>kể cả từ khay"]
  t5(["Nhóm khác phát toast<br/>khi cửa sổ app ẩn ở khay / thu nhỏ"]) -->|"A5 · IA-21"| a5["Không bật toast<br/>tạo dòng chưa đọc trên máy, badge tăng<br/>không mang nút Hoàn tác"]
  a5 --> s1
  wa --> p3
  s2 -->|"A1 · Đánh dấu tất cả đã đọc"| a1[["NotificationRead all=true<br/>badge về 0 trên mọi thiết bị"]]
  s2 -->|"A3 · cuộn tới cuối danh sách"| a3[["Tải trang kế, cursor"]]
  a3 --> s2
  s2 -->|"SCR-11 #5 · chưa có thông báo"| m37>"MSG-37 · Empty state<br/>Chưa có thông báo nào"]
  s2 -->|"SCR-11 #4 · icon Cài đặt thông báo"| x8{{"→ UC-08 Cài đặt thông báo"}}
  s2 -->|"A4 · thông báo quá 90 ngày"| a4(["Tự xoá khỏi danh sách BR-20"])
  p3 -->|"A2 · đích không còn, task đã xoá"| a2m>"MSG-30 · Toast<br/>Nội dung này đã bị xoá hoặc bạn không còn quyền xem"]
  a2m --> a2(["SCR-11 giữ mở"])

  p2 -.->|"E1 · NotificationList lỗi / mất mạng"| e1["SCR-11 hiện danh sách đã cache"]
  e1 -.-> e1m>"QC-MSG-02 · Tại chỗ trong SCR-11<br/>Chưa tải được. Thử lại"]
  e1m -.->|"Thử lại"| p2
  p1 -.->|"E2 · email bị trả về cứng"| e2[["Ngừng gửi email tới địa chỉ đó"]]
  e2 -.-> e2m>"MSG-57 · Trung tâm thông báo<br/>Email của bạn không nhận được thư. Kiểm tra địa chỉ email trong Cài đặt, mục Tài khoản"]
  e2m -.->|"bấm dòng"| e2x{{"→ G01 · UC-07 Tài khoản, SCR-11"}}

  class p1,s1,u1,p2,s2,u2,p3 happy
  class g43,win,wa,a1,a3,m37,a4,a2m,a2,t5,a5 alt
  class x8,e2x link
  class e1,e1m,e2,e2m err
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
| A1 | Đánh dấu tất cả đã đọc | Badge về 0 mọi thiết bị | – |
| A2 | Đích không còn (task đã xoá) | SCR-11 giữ mở | MSG-30 |
| A3 | Cuộn tới cuối | Tải trang kế | – |
| A4 | Thông báo quá 90 ngày | Tự xoá | – |
| A5 | Toast phát sinh khi cửa sổ ẩn (IA-21) | Dòng chưa đọc trong SCR-11, không bật toast | Nội dung toast gốc |
| E1 | `NotificationList` lỗi / mất mạng | Danh sách cache, Thử lại | QC-MSG-02 (lỗi tải, QC-13 mục 1) |
| E2 | Email bị trả về cứng | Ngừng email, báo trong app; bấm → [G01 · UC-07](g01-tai-khoan.md) | MSG-57 (C52) |
| BR-19 | Nhiều cập nhật cùng task trong 5 phút | Gộp thành 1 | MSG-43 |
| – | Danh sách rỗng (SCR-11 #5) | Empty state | MSG-37 |
| – | Bấm thông báo Windows (mục 6, IA-10) | Cửa sổ lên trước, mở đúng đích | – |

Đích của từng loại thông báo 1.0: bảng "Loại thông báo 1.0 → màn được mở" ngay dưới UC-09 trong [SRS](../../features/srs-g12-workspace-billing.md) (C51).

## Kiểm tra

- [x] Mọi A# / E# của UC-05 (A5), UC-08, UC-09 bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)" / "Bỏ (1.2)". UC-01 … UC-03 Bỏ (1.1); UC-04, UC-06, UC-07 Bỏ (1.2).
- [x] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG (UC-09 E2 có MSG-57 từ 09/11/2026).
- [x] Nội dung MSG chép nguyên văn mục 9 SRS (dấu ngoặc kép viết bằng `#quot;` cho Mermaid).

**Ghi chú cho brief G12**
- ~~**Quyền riêng tư không thuộc 1.0.** UC-06 Privacy là bản sau.~~ **Đã sửa 09/11/2026 (C47):** SRS UC-06 ghi nhãn "(1.2)", không vẽ ở 1.0.
- ~~**SCR-12 #2 "Xoá workspace" ghi "1.1, chỉ `OWNER`"**, trái UC-05 A4, BR-14, BR-28.~~ **Đã sửa 09/11/2026 (B47):** không có nút ở 1.0 và 1.1; workspace một người xoá bằng xoá tài khoản (G01); xét lại ở 1.2 (SRS BR-14, UC-05 A4, SCR-12 #2).
- ~~**Đổi tên workspace thiếu thông báo** (tên trống / quá dài, "Đã lưu").~~ **Đã sửa 09/11/2026 (C48):** "Đã lưu" dùng G01 MSG-22; thêm MSG-58 và UC-05 E5.
- ~~**UC-08 A1 ô bắt buộc không có ở 1.0.**~~ **Đã sửa 09/11/2026 (C49):** UC-08 A1, SCR-10 #2, MSG-34 ghi "(1.1)", ẩn ở 1.0.
- ~~**SCR-14 ở 1.0**: link "Mở cài đặt thông báo" cần đăng nhập mà 1.0 chưa có web app.~~ **Đã sửa 09/11/2026 (B48):** link ẩn ở 1.0, bật từ 1.1; sơ đồ UC-08 bỏ cạnh này.
- ~~**UC-09 bước 2 ghi "Chuông trên thanh điều hướng"**.~~ **Đã sửa 09/11/2026 (C50):** UC-09 bước 2, 3 và SCR-11 #1 ghi chuông ở cụm dưới sidebar, danh sách là popover.
- ~~**UC-09 bước 4**: Billing là 1.1; chưa có bảng loại thông báo 1.0 → đích.~~ **Đã sửa 09/11/2026 (C51):** SRS có bảng "Loại thông báo 1.0 → màn được mở" dưới UC-09, bỏ Billing.
- ~~**UC-09 E2** dùng chữ "Email của bạn không nhận được thư" `[giả định]`, chưa có mã MSG.~~ **Đã sửa 09/11/2026 (C52):** MSG-57, bỏ `[giả định]`.
- **Đã sửa 09/11/2026 (A1):** UC-09 E1 lỗi tải danh sách dùng câu lỗi tải chung QC-MSG-02, thôi dùng MSG-38 (câu lỗi lưu).
- **Đã sửa 09/11/2026 (A6):** thêm nhánh mất mạng UC-05 E6 (đổi tên workspace) và UC-08 E3 (cài đặt Thông báo) theo QC-08 mục 7: chạy trên máy, dấu "Chờ đồng bộ", gửi lên khi có mạng.
