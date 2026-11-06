# Review sơ đồ user flow — chi tiết từng mục

Phần chi tiết của [`review-flow-vs-srs-2026-11-05.md`](review-flow-vs-srs-2026-11-05.md): mỗi phát hiện ở bảng mục 3 được viết đầy đủ theo khuôn **flow đang vẽ (trích nguyên văn) → nguồn nói (trích nguyên văn) → không ổn ở chỗ → sửa cụ thể → ai làm**. Số `Gxx-#` trùng số # trong bảng. Dòng trích là dòng trong file flow tại commit `f85da4e` (= `main` sau PR #29). Các mục này cũng được đăng thành comment inline trên [PR #29](https://github.com/tannguyenho/personal-app/pull/29).

Cuối mỗi nhóm có mục **Ghi chú cho brief — cần thêm**: câu viết sẵn để dán vào phần ghi chú cuối file flow tương ứng.

---

## G01 Tài khoản (`docs/design-brief/flow/g01-tai-khoan.md`)

Số thứ tự # trùng bảng mục 3 "G01" của `docs/review/review-flow-vs-srs-2026-11-05.md`. Mọi trích dẫn chép đúng chữ, đúng dòng tại thời điểm review (commit flow `8fac830`).

Viết tắt file nguồn: `srs-g01` = `docs/features/srs-g01-tai-khoan.md`; `prd-g01` = `docs/features/prd-g01-tai-khoan.md`; `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`; `tech` = `docs/tech/01-quyet-dinh-tech-stack-va-api.md`; `srs-g07` = `docs/features/srs-g07-focus-timer.md`; `g08` = `docs/design-brief/flow/g08-daily-rituals.md`; `g12` = `docs/design-brief/flow/g12-workspace-billing.md`.

---

#### G01-1 · Đặt lại mật khẩu kết thúc trong app dù link mở trên web — Cao

**Flow đang vẽ** (`g01-tai-khoan.md:422, 425–427`; rút gọn lặp lại ở `:450–454`):
```text
  u3[/"Mở link trong email<br/>deep link hoặc trang web tối giản [giả định]"/]
  p2[["AuthPasswordReset, áp BR-02, BR-09<br/>mở khoá BR-07, thu hồi phiên khác, gửi email<br/>cấp token"]]
  m2>"MSG-19 · Toast<br/>Đã đặt lại mật khẩu. Các thiết bị khác đã được đăng xuất"]
  ok(["Home, đã đăng nhập"])
```

**Nguồn nói:**
- `tech:22`: "| Trang web tối giản (xác minh email, đặt lại mật khẩu, "Không phải tôi", tải bản xuất, huỷ đăng ký email, chính sách quyền riêng tư); web 1.1 sau này | `wakeup.tannguyenho.tech` |"
- `srs-g01:218`: "Mở link trong email → **SCR-04** phần 2, nhập mật khẩu mới (1.0 chưa có web: link mở app qua deep link hoặc trang web tối giản `[giả định — tech chốt, docs/tech/]`)"
- `srs-g01:219`: "Gọi \[AuthPasswordReset\]; áp BR-02, BR-09; cấp token, mở Home, toast MSG-19"

**Không ổn ở chỗ:** SRS tự ghi "tech chốt" và tech đã chốt: link đặt lại mật khẩu mở trên **trang web tối giản**, không deep link. Flow còn giữ `[giả định]` và chép bước 4 của SRS, nên kết thúc là "cấp token → toast MSG-19 → Home, đã đăng nhập". Một trang web tĩnh không thể cấp token cho app Windows, không mở được Home, không hiện toast trong app. Designer sẽ vẽ SCR-04 phần 2 như một màn trong app, còn trên thực tế người dùng đặt mật khẩu xong đang đứng ở trình duyệt, app vẫn ở SCR-03. Cùng lỗi lặp ở MSG-18 (`g01:…` nhánh E1, "SCR-04" là trang web) và ở hai chỗ khác còn `[giả định]`: `g01:873` (UC-07 A5 "trang web tối giản [giả định]") và `g01:929` (UC-08 bước 4 "Bấm link trong email, đăng nhập nếu cần").

**Sửa:**
- SRS UC-04 bước 3 (`srs-g01:218`) → "Mở link trong email → trang web tối giản **SCR-04** phần 2 (tech: `wakeup.tannguyenho.tech`), nhập mật khẩu mới". Bỏ `[giả định — tech chốt]`.
- SRS UC-04 bước 4 (`srs-g01:219`) → "Gọi \[AuthPasswordReset\]; áp BR-02, BR-09; trang hiện MSG-19 và nút "Mở app"; app (nếu đang mở) về SCR-03, không tự đăng nhập". Hậu điều kiện thành công (UC-04) bỏ "khách đã đăng nhập, mở Home". MSG-19 đổi nơi hiện từ "Toast" thành "SCR-04 (web)". Bảng API bỏ "accessToken; refresh token" khỏi response của \[AuthPasswordReset\], hoặc giữ và nói rõ chỉ dùng từ 1.1 web.
- Flow: đổi `u3`, `p2`, `m2`, `ok` thành
```text
  u3[/"Mở link trong email<br/>trình duyệt, trang web tối giản"/]
  s2["SCR-04 phần 2 · trang web · mật khẩu mới"]
  p2[["AuthPasswordReset, áp BR-02, BR-09<br/>mở khoá BR-07, thu hồi mọi phiên, gửi email"]]
  m2>"MSG-19 · SCR-04 web<br/>Đã đặt lại mật khẩu. Các thiết bị khác đã được đăng xuất"]
  ok(["Trang web báo xong · app ở SCR-03, đăng nhập bằng mật khẩu mới"])
```
- `g01:873` và `g01:929`: bỏ chữ "[giả định]", ghi "trang web tối giản (tech)".
- **PO / tech chốt:** UC-08 bước 4 "đăng nhập nếu cần" và E3 "mở link bằng tài khoản khác" cần cơ chế kiểm "đúng tài khoản" trên web khi web chưa có đăng nhập (1.1). Mặc định đề xuất: link tải có token ký, 7 ngày, không cần đăng nhập; bỏ E3 ở 1.0.

**Ai làm:** SRS rồi Flow; một câu hỏi cho PO / tech (UC-08).

---

#### G01-2 · "Daily planning có hướng dẫn" không tồn tại ở G08 — Cao

**Flow đang vẽ** (`g01-tai-khoan.md:522–523`):
```text
  x2{{"→ G08 · UC-01<br/>Daily planning hôm nay, có hướng dẫn"}}
  ok(["Daily planning hôm nay đang mở<br/>onboarding HOAN_TAT"])
```

**Nguồn nói:**
- `srs-g01:48` (BR-11): "Hoàn tất → mở Daily planning hôm nay ở chế độ có hướng dẫn (G08). Chỉ hiện một lần / tài khoản"
- `srs-g01:254` (UC-05 bước 7): "Tạo task (G02); gọi \[OnboardingComplete\]; mở Daily planning hôm nay ở chế độ có hướng dẫn (G08)"
- `prd-g01:193` (US2.2 AC01): "Hoàn tất bước 5 → mở Daily planning của hôm nay (G08) ở chế độ có hướng dẫn, các task vừa tạo đã nằm trong danh sách."
- `g08:22` (UC-01 Mở đầu): "**Mở đầu:** phím P, sidebar "Daily planning", nút "Plan" trên cột ngày D ≥ hôm nay, hoặc lời nhắc MSG-01 (UC-04)."
- `docs/features/srs-g08-daily-rituals.md`: không có chữ "hướng dẫn" hay "onboarding" ở bất kỳ dòng nào (đã grep).

**Không ổn ở chỗ:** Flow G01 làm đúng SRS/PRD G01, nhưng đích trỏ tới không có nội dung: SRS G08 không định nghĩa "chế độ có hướng dẫn" (khác gì wizard thường, hướng dẫn gì, tắt khi nào), và flow G08 UC-01 không có điểm vào "từ onboarding". Designer G08 vẽ wizard theo file G08 sẽ không biết có trạng thái "lần đầu, có hướng dẫn"; designer G01 thì không có màn để tham chiếu. Lỗi nằm ở phía G08, không phải flow G01.

**Sửa:**
- SRS G08 (chủ sở hữu) thêm: điểm vào "Hoàn tất onboarding (G01 UC-05 bước 7)" ở mục 6; UC-01 thêm nhánh A# "Mở từ onboarding, lần đầu: wizard hiện lớp hướng dẫn ngắn ở mỗi bước (tooltip theo BR-16 của G01), task vừa tạo đã ở bước 2". Hoặc nếu PO không muốn chế độ riêng: sửa BR-11, UC-05 bước 7 (G01) và PRD US2.2 AC01 thành "mở Daily planning hôm nay (G08)" và bỏ chữ "có hướng dẫn".
- Flow G08 UC-01: thêm vào nút `start` "…hoặc xong onboarding G01 · UC-05".
- Flow G01: giữ nút `x2`, sau khi G08 có mã nhánh thì ghi "→ G08 · UC-01 A#".
- **PO chốt:** có chế độ "có hướng dẫn" hay không. Mặc định đề xuất: có, dùng tooltip theo ngữ cảnh (G01 BR-16) ngay trong wizard, không làm màn riêng.

**Ai làm:** PO, rồi SRS G08, rồi Flow (G08 và G01).

---

#### G01-3 · Onboarding xong mở Daily planning hay về Home — TB

**Flow đang vẽ** (`g01-tai-khoan.md:523`, lặp ở `:552`):
```text
  ok(["Daily planning hôm nay đang mở<br/>onboarding HOAN_TAT"])
```

**Nguồn nói:**
- `srs-g01:48` (BR-11): "Hoàn tất → mở Daily planning hôm nay ở chế độ có hướng dẫn (G08)."
- `srs-g01:545` (SCR-05, chính SRS này): "Xong onboarding → Home hôm nay (IA-12)."
- `IA:120`: "Như trên. Bước nhập task trông giống ô soạn thật. Xong thì vào Home hôm nay (IA-12)"
- `IA:214`: "| IA-12 | Đăng nhập và onboarding toàn cửa sổ, không có sidebar; xong onboarding vào Home hôm nay | Q12 |"
- `IA:63` (vùng chính, wizard Daily planning): "Sidebar và panel phải vẫn dùng được, để kéo từ Backlog / Lịch vào. Không thoát bằng Esc, chỉ bằng × (IA-16). × lưu tiến độ, về Home"

**Không ổn ở chỗ:** SRS G01 tự mâu thuẫn: BR-11 và UC-05 nói "mở Daily planning", SCR-05 nói "Home hôm nay". IA (đã duyệt 04/11, mục 7 ghi "chỗ nào SRS còn ghi khác thì sửa ngược") thắng. Hai cách đọc không loại trừ nhau: theo IA mục 3, wizard Daily planning nằm **trong** khung app, thay vùng chính của Home. Nhưng flow ghi "Daily planning hôm nay đang mở" không nói có khung ba vùng hay không, designer có thể vẽ wizard toàn cửa sổ nối thẳng từ onboarding toàn cửa sổ.

**Sửa:**
- Flow: `ok(["Khung app, Home hôm nay (IA-12)<br/>wizard Daily planning tự mở thay vùng chính<br/>onboarding HOAN_TAT"])`.
- SRS BR-11 (`srs-g01:48`) và UC-05 bước 7 (`srs-g01:254`): thêm "trong khung app (IA-12); wizard thay vùng chính của Home (IA-07)".
- **PO chốt:** sau onboarding, wizard tự mở ngay hay chỉ về Home và chờ lời nhắc? Mặc định đề xuất: tự mở ngay (giữ ý PRD US2.2 AC01), và lượt tự mở này tính là lượt "tự mở một lần / ngày" của G08.

**Ai làm:** PO, rồi SRS, rồi Flow.

---

#### G01-4 · Xác nhận lại (A6 reauth) bị đẩy về màn đăng nhập — TB

**Flow đang vẽ** (`g01-tai-khoan.md:194` trong "Nhánh thay thế"; `:146, 180` và `:233–235` trong "Nhánh lỗi" dùng chung cho A6):
```text
  a6s(["Màn cần xác nhận lại BR-10<br/>SCR-11 dialog, SCR-12, sau MSG-48"]) -->|"A6 · purpose=reauth"| p1
  m1>"MSG-49 · Overlay SCR-01 / SCR-03<br/>Hãy hoàn tất đăng nhập {Google / Microsoft} trong trình duyệt vừa mở.<br/>App sẽ tự tiếp tục khi xong · Huỷ"]
  m1 -->|"A7 · bấm Huỷ"| a7(["Về SCR-01 / SCR-03, không hiện lỗi<br/>bỏ state đang chờ, kết quả về sau bị bỏ qua"])
  p1 -.->|"E5 · không mở được trình duyệt"| e5m>"MSG-50 · SCR-03<br/>Chưa nhận được kết quả đăng nhập từ trình duyệt.<br/>Thử lại, hoặc đăng nhập bằng email và mật khẩu"]
  e1m -.-> fail(["SCR-03 kèm thông báo<br/>không tạo, không đăng nhập<br/>email + mật khẩu vẫn dùng được"])
```

**Nguồn nói:**
- `srs-g01:62` (BR-25): "Trong lúc chờ, app hiện trạng thái chờ (MSG-49) có nút "Huỷ". … Hết thời gian chờ `[giả định: 5 phút]` hoặc không mở được trình duyệt → về SCR-03 với MSG-50. Áp dụng cả cho xác nhận lại (`purpose=reauth`, BR-10)"
- `srs-g01:785`: "| MSG-49 | Overlay SCR-01 / SCR-03 | …"
- `srs-g01:786`: "| MSG-50 | SCR-03 | Chưa nhận được kết quả đăng nhập từ trình duyệt. Thử lại, hoặc đăng nhập bằng email và mật khẩu |"
- `srs-g01:153` (UC-02 A6): "Không cấp phiên mới; `provider + sub` phải khớp tài khoản đang đăng nhập → trả `reauthToken` về màn đang mở; không khớp → MSG-11"

**Không ổn ở chỗ:** Khi xác nhận lại, người dùng **đang đăng nhập** và đang đứng trong dialog Đổi mật khẩu / Đổi email (SCR-11), Xoá tài khoản (SCR-12) hoặc sau MSG-48. Flow nối A6 vào `p1` rồi dùng chung overlay, nút Huỷ (A7), timeout (E5) và nút `fail` của luồng đăng nhập, tất cả kết thúc ở "SCR-01 / SCR-03" và "không đăng nhập". Đọc sơ đồ, designer sẽ hiểu bấm Huỷ hoặc hết 5 phút trong lúc đổi mật khẩu thì app văng ra màn đăng nhập. SRS cũng viết vậy ở BR-25 ("về SCR-03 với MSG-50", "áp dụng cả cho xác nhận lại"), nên nguồn sai là SRS; phần ghi chú cho brief (`g01:1278`) mới chỉ nêu MSG-11, chưa nêu MSG-49/MSG-50/A7/E5.

**Sửa:**
- SRS BR-25 (`srs-g01:62`): thêm câu "Khi `purpose=reauth`: overlay MSG-49 hiện trên dialog đang mở; "Huỷ", hết thời gian chờ, không mở được trình duyệt và MSG-11 đều quay về dialog đó, giữ giá trị đã nhập, phiên hiện tại không đổi." MSG-49 nơi hiện: "Overlay SCR-01 / SCR-03 / dialog xác nhận lại"; MSG-50 và MSG-11 nơi hiện thêm "dialog xác nhận lại".
- Flow UC-02: tách A6 thành sơ đồ nhỏ riêng (hoặc thêm kết thúc riêng), ví dụ
```text
  a6s(["Dialog SCR-11 / SCR-12 / sau MSG-48<br/>bấm Xác nhận bằng Google / Microsoft"]) -->|"A6 · purpose=reauth"| a6p[["AuthOAuthStart purpose=reauth"]]
  a6p --> a6m>"MSG-49 · Overlay trên dialog · Huỷ"]
  a6m -->|"khớp tài khoản"| a6ok(["reauthToken về dialog đang mở<br/>phiên không đổi"])
  a6m -->|"Huỷ / hết 5 phút / lỗi trình duyệt"| a6k(["Về dialog đang mở, giữ giá trị đã nhập<br/>MSG-50 / MSG-11 trong dialog"])
```

**Ai làm:** SRS rồi Flow.

---

#### G01-5 · UC-10 xung đột 412 kết thúc sai và khác nhãn UC-06 — TB

**Flow đang vẽ** (`g01-tai-khoan.md:1140, 1144, 1149`):
```text
  p2 -.->|"E3 · xung đột 412, như UC-06 A6"| e3bm>"MSG-41 · Toast<br/>#quot;{tên cài đặt}#quot; vừa được đổi trên thiết bị khác thành {giá trị}.<br/>Thay đổi của bạn ở mục này chưa được lưu"]
  e3bm -.-> fail
  class e1m,e2m,e3m,e3bm err
```
với `fail(["Giữ lịch làm việc cũ"])` (`:1141`). Cùng tình huống ở UC-06 (`g01:691–692`) vẽ:
```text
  p2 -->|"A6 · 412, trường đã đổi ở thiết bị khác"| a6["Trường đó lấy giá trị server<br/>các trường khác trong lệnh vẫn lưu"]
  a6 --> a6m>"MSG-41 · Toast<br/>…"]
```
và `class a6m warn`.

**Nguồn nói:**
- `srs-g01:49` (BR-12): "thiết bị có lệnh bị từ chối (412) lấy giá trị server **của trường đó** và hiện MSG-41; các trường khác trong cùng lệnh vẫn được lưu"
- `srs-g01:302` (UC-06 A6): "Trường đó lấy giá trị server, hiện MSG-41; các trường khác trong lệnh vẫn lưu"
- `srs-g01:449` (UC-10 E3): "| E3 | \[SettingsUpdate\] lỗi / xung đột | Như UC-06 E2 / A6 |"
- `_quy-uoc.md:123`: "Nhánh giống nhau ở nhiều UC … vẫn vẽ ở từng UC, vì designer vẽ theo màn; nhưng nhãn phải giống hệt nhau."

**Không ổn ở chỗ:** Sau 412, bảng Lịch làm việc phải hiện **giá trị server** (giá trị thiết bị kia vừa lưu), không phải "lịch làm việc cũ" trước khi người dùng sửa. Flow nối MSG-41 vào nút `fail` "Giữ lịch làm việc cũ" và tô class err; UC-06 vẽ cùng tình huống là nhánh thay thế, class warn, có nút "lấy giá trị server". Designer vẽ màn SCR-14 sẽ không có trạng thái "bảng đổi theo thiết bị khác", và hai màn cùng một cơ chế lại có hai nhãn khác nhau, trái quy ước mục 5.

**Sửa:** Flow UC-10, thay ba dòng trên bằng
```text
  p2 -->|"A6 · 412, trường đã đổi ở thiết bị khác"| a6["workSchedule lấy giá trị server<br/>bảng vẽ lại theo thiết bị khác"]
  a6 --> a6m>"MSG-41 · Toast<br/>#quot;{tên cài đặt}#quot; vừa được đổi trên thiết bị khác thành {giá trị}.<br/>Thay đổi của bạn ở mục này chưa được lưu"]
  class a6 alt
  class a6m warn
```
Bảng đối chiếu (`g01:1171`): tách E3 thành "E3 · SettingsUpdate lỗi → giữ lịch cũ, MSG-26" và "A6 · xung đột 412 → workSchedule theo server, MSG-41". Mục Kiểm tra giữ nguyên (SRS chỉ có mã E3, flow ghi chú rằng A6 mượn mã của UC-06).

**Ai làm:** Flow.

---

#### G01-6 · Nhánh nhiều thành viên ghi "Bỏ (1.1)" thay vì "Bỏ (1.2)" — TB

**Flow đang vẽ** (`g01-tai-khoan.md:6`; các dòng bảng `:124, 261, 397, 1079, 1080, 1081, 1264, 1270`):
```text
Bản 1.0 là app Windows cho một người dùng. Các nhánh của web / macOS, 2FA, trial, thanh toán, chế độ chỉ đọc, lời mời và workspace nhiều thành viên không vẽ, ghi "Bỏ (1.1)" ở bảng đối chiếu.
| A4 | Mở từ link mời workspace (bản sau, BR-26) | Bỏ (1.1) | – |
| A3 | Không phải `OWNER` (bản sau, BR-26) | Bỏ (1.1) | – |
| E1 | `OWNER`, workspace còn thành viên (bản sau) | Bỏ (1.1) | – |
| E2 | `OWNER` workspace còn thành viên (bản sau) | Bỏ (1.1) | – |
```

**Nguồn nói:**
- `srs-g01:63` (BR-26): "Các phần nhiều thành viên trong SRS này giữ nguyên đặc tả nhưng **chưa làm**, phát hành ở bản sau (1.2 trở đi; bản 1.1 vẫn chỉ một người dùng, Q47) … đăng ký / đăng nhập qua lời mời (BR-05, UC-01 A4, UC-02 A3, UC-03 A4), … xoá tài khoản khi ở workspace nhiều người (BR-20 a, b; UC-09 A3, E1; MSG-37, MSG-45)"
- `g12:15–18` (file G12 cùng bộ) ghi các mục tương ứng là "Bỏ (1.2)".

**Không ổn ở chỗ:** Chữ "Bỏ (1.1)" nói với designer rằng nhánh này sẽ cần ngay ở bản kế tiếp. Theo BR-26 và Q47, mọi nhánh lời mời / workspace nhiều người là 1.2 trở đi; chỉ 2FA (UC-03 A3) và chế độ chỉ đọc (UC-08 A1) mới thật sự là 1.1. Hai file flow G01 và G12 đang ghi khác nhau cho cùng một nhóm tính năng.

**Sửa:** Flow, đổi chữ:
- `g01:6`: "… 2FA, trial, thanh toán, chế độ chỉ đọc ghi "Bỏ (1.1)"; lời mời và workspace nhiều thành viên ghi "Bỏ (1.2)" ở bảng đối chiếu."
- `g01:124, 261, 397, 1079, 1081, 1264`: "Bỏ (1.1)" → "Bỏ (1.2)".
- `g01:1080` (UC-09 A4): "(phần huỷ gói: Bỏ (1.1))" giữ nguyên, vì gói là 1.1.
- `g01:1270` (Kiểm tra): "… hoặc ghi "Bỏ (1.1)" / "Bỏ (1.2)"."
- Giữ `g01:396` (UC-03 A3 2FA) và `g01:988` (UC-08 A1 chỉ đọc) là "Bỏ (1.1)".

**Ai làm:** Flow.

---

#### G01-7 · Danh sách nhóm của trang Cài đặt thiếu Workspace, Task lặp, Hoạt động AI — TB

**Flow đang vẽ** (`g01-tai-khoan.md:651` và bảng `:724`; liên quan `g12:34`):
```text
  s1 -->|"A1 · chọn nhóm do nhóm khác sở hữu"| a1x{{"→ G02, G05, G07, G08, G10, G11, G12<br/>trang con của nhóm sở hữu"}}
| A1 | Nhóm do nhóm khác sở hữu | Trang con của nhóm đó (G02, G05, G07, G08, G10, G11 (1.1, chưa có flow), [G12](g12-workspace-billing.md)) | – |
```
`g12:34`: `start(["Avatar → Cài đặt hoặc Ctrl+,<br/>nhóm Workspace"])`

**Nguồn nói:**
- `srs-g01:564` (SCR-06 #1, nhóm "Cá nhân"): "Chung · Hiển thị · Lịch làm việc (G01, SCR-14) · Ritual (G08) · Timebox (G05) · Phím tắt · Focus (G07) · Trợ lý AI (SCR-16 → G10 …) · Beta (G10) · Thông báo (G12)"
- `srs-g01:566` (SCR-06 #3, nhóm "Workspace"): "Context & channel (G02, gồm khung giờ channel) · Thành viên (G12, bản sau) · Privacy (G12, bản sau) · Billing (G12, 1.1) · Tích hợp (G05 / G11)"
- `IA:105`: "Gồm mọi nhóm của G01 SCR-06, kể cả Context & channel (G02 SCR-06), Lịch (G05 SCR-01 … 03), Ritual (G08 SCR-13), Trợ lý AI (G10 SCR-09), Hoạt động AI (G10 SCR-12), Task lặp (G03 SCR-05), Thông báo (G12 SCR-10), Workspace (G12 SCR-12)"
- `srs-g01:297` (UC-06 A1): "Mở trang con của nhóm đó (G02, G05, G07, G08, G10, G11, G12)"

**Không ổn ở chỗ:** SCR-06 là màn do G01 sở hữu và là khung mà mọi trang con treo vào. Nó không có mục "Workspace" (G12 SCR-12, 1.0), "Task lặp" (G03 SCR-05) và "Hoạt động AI" (G10 SCR-12), dù IA mục 5 (đã duyệt) liệt kê đủ. Flow G01 UC-06 A1 chép SRS nên thiếu G03; flow G12 UC-05 phải viết "nhóm Workspace" vì SRS G01 không có tên mục để trỏ. Designer vẽ cột trái SCR-06 theo SRS sẽ thiếu ba mục.

**Sửa:**
- SRS SCR-06 #1 (`srs-g01:564`): thêm "Task lặp (G03, SCR-05)" sau "Ritual (G08)" và "Hoạt động AI (G10, SCR-12)" sau "Trợ lý AI". SCR-06 #3 (`srs-g01:566`): thêm "Workspace (G12, SCR-12 — 1.0 chỉ đổi tên)" đầu danh sách. UC-06 A1 (`srs-g01:297`): "(G02, G03, G05, G07, G08, G10, G11, G12)".
- Flow G01 `g01:651` và `:724`: thêm G03 vào danh sách.
- Flow G12 `g12:34`: `start(["Avatar → Cài đặt hoặc Ctrl+,<br/>nhóm Workspace → mục Workspace (SCR-12)"])`.
- **PO chốt:** thứ tự mục trong nhóm "Workspace" ở 1.0 (chỉ còn Context & channel, Workspace, Tích hợp (G05)). Mặc định đề xuất: Workspace · Context & channel · Tích hợp.

**Ai làm:** SRS rồi Flow (G01 và G12).

---

#### G01-8 · Banner lệch timezone vẽ như luôn hiện ngay — TB

**Flow đang vẽ** (`g01-tai-khoan.md:660`):
```text
  a2s(["Mở app · Home<br/>timezone thiết bị khác cài đặt"]) -->|"A2"| a2m>"MSG-23 · Banner SCR-13<br/>Máy bạn đang ở múi giờ {tz thiết bị}, cài đặt đang là {tz}.<br/>Đổi sang {tz thiết bị} · Giữ {tz}"]
```

**Nguồn nói:**
- `IA:67–72`: "**Banner** nằm ở đầu vùng chính, **tối đa một** cùng lúc, theo thứ tự ưu tiên (IA-17): 1. Offline (G04 SCR-01 #5) 2. Lịch cần kết nối lại (G05 SCR-09) 3. Rollover lỗi (G04 MSG-27) 4. Lệch timezone (G01 SCR-13)"
- `IA:73`: "Banner thấp hơn chờ tới lượt và đồng thời vào trung tâm thông báo."
- `IA:219`: "| IA-17 | Tối đa một banner, theo thứ tự ưu tiên; banner chờ vào trung tâm thông báo | Q17 |"
- `srs-g01:642` (SCR-13 #1): "| 1 | Banner lệch timezone | Banner đầu Home | MSG-23; hai nút "Đổi sang…", "Giữ…" (BR-13); banner timezone duy nhất của app |"
- `srs-g01:298` (UC-06 A2): "Mở app, timezone thiết bị khác cài đặt | Banner MSG-23: …"

**Không ổn ở chỗ:** MSG-23 là banner có ưu tiên thấp nhất. Khi mở app mà đang offline hoặc lịch cần kết nối lại, banner timezone **không hiện** mà vào trung tâm thông báo và chờ. Flow vẽ "Mở app → MSG-23" vô điều kiện, nên designer không có trạng thái "dòng thông báo lệch timezone trong SCR-11 (G12)" và không biết banner có thể hiện muộn, ở view khác chứ không chỉ Home. SRS SCR-13 ghi "Banner đầu Home" còn IA ghi "đầu vùng chính" (mọi view của Home, Today, Backlog…); IA thắng.

**Sửa:**
- Flow UC-06, thêm thoi sau `a2s`:
```text
  a2s -->|"A2"| a2d{"Có banner ưu tiên cao hơn?<br/>IA-17"}
  a2d -->|"không"| a2m
  a2d -->|"có · offline / lịch / rollover"| a2w["Chờ tới lượt<br/>đồng thời vào trung tâm thông báo"]
  a2w --> a2x{{"→ G12 · UC-09"}}
  a2w -->|"tới lượt"| a2m
```
và đổi nhãn `a2m` thành "MSG-23 · Banner SCR-13, đầu vùng chính".
- SRS SCR-13 #1 (`srs-g01:642`): "Banner đầu Home" → "Banner đầu vùng chính, ưu tiên 4 theo IA-17; chờ lượt thì vào trung tâm thông báo (G12 UC-09)". UC-06 A2 (`srs-g01:298`) thêm cùng câu.

**Ai làm:** Flow; SRS sửa theo (câu chữ), không cần PO.

---

#### G01-9 · SCR-15 vẽ là "Màn hình", IA chốt là dialog chặn — TB

**Flow đang vẽ** (`g01-tai-khoan.md:1185–1186`):
```text
  s1["SCR-15 Đồng ý phiên bản Điều khoản mới"]
  m1>"MSG-47 · Màn hình<br/>Điều khoản sử dụng / Chính sách quyền riêng tư đã cập nhật ngày {ngày}.<br/>Đọc và đồng ý để tiếp tục dùng app"]
```

**Nguồn nói:**
- `IA:110`: "| Đồng ý Điều khoản mới | Dialog chặn | Mở app khi có phiên bản mới | | G01 SCR-15 |"
- `srs-g01:783`: "| MSG-47 | Màn hình | Điều khoản sử dụng / Chính sách quyền riêng tư đã cập nhật ngày {ngày}. Đọc và đồng ý để tiếp tục dùng app |"
- `IA:33` (bề mặt Dialog / lớp phủ): "Khung phía sau: Mờ đi, không thao tác được"

**Không ổn ở chỗ:** "Màn hình" trong G01 là kiểu màn toàn cửa sổ không có khung (như MSG-38, MSG-42). IA xếp SCR-15 là **dialog chặn** trên khung app (khung mờ phía sau, Esc không đóng vì phải đồng ý mới tiếp). Hai cách vẽ khác hẳn nhau; designer theo flow sẽ vẽ SCR-15 toàn cửa sổ. IA thắng SRS.

**Sửa:**
- Flow: `s1["SCR-15 Đồng ý phiên bản Điều khoản mới<br/>dialog chặn trên khung app, IA mục 5"]`; `m1>"MSG-47 · Dialog SCR-15<br/>…"]`. Ghi thêm cạnh `s1 -->|"Esc / bấm ngoài"| s1` ("không đóng được") hoặc một dòng chú thích dưới sơ đồ.
- SRS MSG-47 (`srs-g01:783`): nơi hiện "Màn hình" → "Dialog SCR-15 (chặn)". SCR-15 (`srs-g01:666`) thêm câu đầu mục: "Dialog chặn trên khung app (IA mục 5); không đóng bằng Esc hay ×; chỉ các link #4 thoát được."

**Ai làm:** SRS rồi Flow.

---

#### G01-10 · UC-01 E7 (429 / 5xx / mất mạng) chỉ gắn vào SCR-01 — Thấp

**Flow đang vẽ** (`g01-tai-khoan.md:72, 79, 88–89`):
```text
  p3[["AuthVerifyEmail"]]
  s2 -->|"A2 · bấm Gửi lại mã, bật sau 60 giây"| a2[["AuthResendCode<br/>mã cũ vô hiệu, đếm ngược 60 giây lại"]]
  p1 -.->|"E7 · 429 / 5xx / mất mạng"| e7m>"MSG-09 / MSG-10 · Toast<br/>Bạn thao tác quá nhanh. Thử lại sau ít phút /<br/>Không kết nối được máy chủ. Thử lại"]
  e1m -.-> fail(["SCR-01 giữ nội dung form<br/>không gửi, không có tài khoản"])
```

**Nguồn nói:**
- `srs-g01:124` (UC-01 E7): "| E7 | Quá giới hạn gọi (429) / 5xx / mất mạng | MSG-09 / MSG-10, giữ nội dung form |"
- `srs-g01:680–681` (API): \[AuthVerifyEmail\] "5s / không retry", \[AuthResendCode\] "5s / không retry" — hai lệnh này cũng gọi mạng.

**Không ổn ở chỗ:** SRS ghi E7 chung cho cả UC (không nói chỉ bước 2), nhưng flow chỉ mọc nhánh từ `p1` (gửi form SCR-01) và kết thúc "SCR-01 giữ nội dung form". Khi mất mạng lúc nhập mã (`p3`) hay bấm "Gửi lại mã" (`a2`), người dùng đang ở SCR-02; kết thúc đúng là "ở SCR-02, giữ mã đã gõ, mã cũ vẫn còn hiệu lực". Designer sẽ không vẽ trạng thái lỗi mạng cho SCR-02.

**Sửa:** Flow, thêm
```text
  p3 -.->|"E7 · 429 / 5xx / mất mạng"| e7m
  a2 -.->|"E7 · 429 / 5xx / mất mạng"| e7m
  e7m -.->|"từ SCR-02"| fail2(["SCR-02 giữ mã đã gõ<br/>mã đang chờ vẫn hiệu lực"])
  class fail2 fail
```
Bảng đối chiếu E7: "Giữ nội dung form (SCR-01) / giữ mã (SCR-02)". SRS E7 (`srs-g01:124`) thêm "(mọi bước; ở SCR-02 giữ mã đã gõ)".

**Ai làm:** Flow (SRS thêm một cụm từ).

---

#### G01-11 · UC-05 E1 (kết nối lịch lỗi) nhảy thẳng sang bước 3 — Thấp

**Flow đang vẽ** (`g01-tai-khoan.md:564–565`):
```text
  x1 -.->|"E1 · kết nối lịch lỗi / bị từ chối quyền"| e1["SCR-05 bước 2, thông báo của G05<br/>vẫn Tiếp hoặc Bỏ qua được"]
  e1 -.-> s3
```

**Nguồn nói:**
- `srs-g01:270` (UC-05 E1): "| E1 | Kết nối lịch lỗi / bị từ chối quyền | Quay lại bước 2, thông báo của G05; vẫn "Tiếp" hoặc "Bỏ qua" được |"
- `prd-g01:181` (US2.1 AC02): "Bước 2 kết nối Google Calendar hoặc Outlook (G05); có "Bỏ qua"; kết nối lỗi vẫn đi tiếp được."

**Không ổn ở chỗ:** Nhãn nút `e1` đúng ("bước 2, vẫn Tiếp hoặc Bỏ qua được"), nhưng cạnh `e1 -.-> s3` nối thẳng sang bước 3 như thể hệ thống tự chuyển. Theo SRS, người dùng quay lại bước 2 cùng thông báo lỗi và **tự chọn**: thử kết nối lại (`u2`), Tiếp hoặc Bỏ qua (A1). Designer đọc cạnh này sẽ nghĩ lỗi lịch tự đẩy sang bước 3, bỏ trạng thái "bước 2 có lỗi, còn nút kết nối lại".

**Sửa:** Flow, thay `e1 -.-> s3` bằng `e1 -.-> s2` (về nút `s2["SCR-05 bước 2 · kết nối lịch"]`), để từ `s2` đi tiếp theo cạnh đang có (`s2 ==> x1`, `s2 -->|"A1 · Bỏ qua"| a1`). Bảng đối chiếu E1: "Kết thúc ở: bước 2 kèm lỗi G05; người dùng chọn kết nối lại / Tiếp / Bỏ qua".

**Ai làm:** Flow.

---

#### G01-12 · UC-09 A2 trỏ sang G07 · UC-02 nhưng G07 không có nhánh "xoá tài khoản" — Thấp

**Flow đang vẽ** (`g01-tai-khoan.md:1042`):
```text
  p1 -->|"A2 · đang có timer chạy"| a2x{{"→ G07 · UC-02<br/>dừng và lưu bản ghi thời gian trước khi xoá"}}
```

**Nguồn nói:**
- `srs-g01:405` (UC-09 A2): "| A2 | Đang có timer chạy | Dừng và lưu bản ghi thời gian trước khi xoá (G07) |"
- `srs-g07:145–150` (UC-02 luồng thay thế, đủ): A1 "Hoàn thành / xoá task đang chạy (G02)", A2 "Vào nghỉ (1.1) / hết phiên Pomodoro (1.1)", A3 "Dừng ở thiết bị khác", A4 "Task đang chạy bị dời ngày", A5 "Workspace vào chỉ đọc (1.1)", A6 "Lượt chạy vắt qua mốc đầu ngày". Không có "xoá tài khoản".
- `_quy-uoc.md:22`: "Flow liên tính năng | Vẽ ở file của tính năng **khởi phát**. File khác chỉ có nút "sang flow khác" trỏ tới đó"

**Không ổn ở chỗ:** Nút lục giác trỏ tới một UC không có nhánh tương ứng. Việc dừng timer ở đây do **server** làm trong giao dịch \[AccountDelete\], người dùng không bấm gì, không có toast; G07 UC-02 vẽ dừng timer do người dùng. Designer G07 sẽ không biết có trường hợp timer bị dừng ngầm khi xoá tài khoản (và kết thúc là đăng xuất, không có màn G07 nào hiện ra). Tương tự với MSG-07 "dừng ở thiết bị khác": các thiết bị khác đang bị đăng xuất (BR-20) nên cũng không thấy.

**Sửa:**
- SRS G07 UC-02: thêm nhánh "A7 · Xoá tài khoản (G01 UC-09): server dừng timer trước trong cùng giao dịch, không toast (thiết bị bị đăng xuất theo G01 BR-20)". Sửa G07 BR-06 nếu đang nói "không đường nào khác dừng timer" (mục R6 của báo cáo tổng).
- Flow G07 UC-02: thêm điểm vào từ G01 UC-09 (nút stadium + cạnh tới bước server).
- Flow G01 (`g01:1042`): giữ nút, sau khi G07 có mã thì ghi "→ G07 · UC-02 A7". Tạm thời đổi nhãn thành "G07 · UC-02 (server dừng timer trong giao dịch, chưa có mã nhánh ở G07)".

**Ai làm:** SRS G07 rồi Flow G07; Flow G01 đổi nhãn.

---

#### G01-13 · "Menu tài khoản" và nút bắt đầu Cài đặt thiếu Ctrl+, — Thấp

**Flow đang vẽ** (`g01-tai-khoan.md:362` và `:616`):
```text
  a1s(["Menu tài khoản · Đăng xuất"]) -->|"A1"| d1{"Còn thay đổi<br/>chưa đồng bộ?"}
  start(["Menu tài khoản → Cài đặt<br/>hoặc command menu Mở cài đặt"])
```

**Nguồn nói:**
- `IA:52` (sidebar, cụm dưới): "| | Avatar | – | Menu: Cài đặt (Ctrl+,) · Phím tắt (?) · Đăng xuất · Thoát app |"
- `IA:105` (Cài đặt, đi tới bằng): "Avatar → Cài đặt; Ctrl+,; Ctrl+K "Mở cài đặt"; link "mở thẳng nhóm" từ nơi khác"
- `srs-g01:560` (SCR-06): "Mở bằng avatar → "Cài đặt", Ctrl+, (IA-15) hoặc command menu"
- `g01:1275` (ghi chú cho brief): "**Màn chưa có mã SCR:** menu tài khoản (UC-03 A1, UC-06 bước 1); …"

**Không ổn ở chỗ:** IA gọi menu này là menu **Avatar** ở cụm dưới sidebar, có 4 mục cố định, và đã được SRS SCR-06 chép theo. Flow vẫn gọi "Menu tài khoản" và nút bắt đầu UC-06 thiếu phím Ctrl+, (IA-15) dù file G12 (`g12:34`) đã ghi "Avatar → Cài đặt hoặc Ctrl+,". Phần ghi chú cho brief nói "menu tài khoản chưa có mã SCR" trong khi IA mục 2 đã định nghĩa nó. Lỗi nhỏ nhưng làm hai file flow gọi cùng một thứ bằng hai tên.

**Sửa:** Flow:
- `g01:362`: `a1s(["Avatar ở sidebar → Đăng xuất<br/>IA mục 2"])`.
- `g01:616`: `start(["Avatar → Cài đặt hoặc Ctrl+,<br/>hoặc Ctrl+K Mở cài đặt"])` (giống `g12:34`).
- `g01:1275`: bỏ "menu tài khoản (UC-03 A1, UC-06 bước 1)" khỏi danh sách màn chưa có mã; thêm dòng "Menu Avatar: theo IA mục 2 (4 mục), chưa có mã SCR trong G01; brief G04 (sidebar) vẽ".
- SRS UC-03 A1 (`srs-g01:187`) và UC-06 bước 1 (`srs-g01:287`): "Menu tài khoản" → "menu Avatar (IA mục 2)".

**Ai làm:** Flow (SRS đổi chữ theo).

---

### Ghi chú cho brief — cần thêm (`g01-tai-khoan.md`, mục "Ghi chú cho brief G01", sau dòng 1273)

Dán các dòng sau vào cuối danh sách:

- **Link trong email mở trên trang web tối giản (tech đã chốt, `docs/tech/01:22`):** SCR-04 phần 2 (đặt lại mật khẩu, MSG-18, MSG-19), trang "Không phải tôi" (MSG-42 / MSG-43) và trang tải bản xuất đều là trang web `wakeup.tannguyenho.tech`, không nằm trong app. UC-04 không kết thúc "Home, đã đăng nhập"; app vẫn ở SCR-03. Brief cần một mục "trang web tối giản" riêng (giao diện tối thiểu, không có khung app). SRS UC-04 bước 3–4 chờ sửa.
- **"Daily planning có hướng dẫn" chưa có ở G08:** BR-11 và UC-05 bước 7 trỏ sang chế độ này nhưng SRS G08 không định nghĩa, flow G08 UC-01 không có điểm vào từ onboarding. Chờ SRS G08; brief G01 chỉ vẽ tới nút "Bắt đầu ngày đầu tiên".
- **Onboarding xong về Home hôm nay (IA-12), wizard Daily planning mở thay vùng chính:** BR-11 ghi "mở Daily planning", SCR-05 và IA ghi "Home hôm nay"; IA thắng. Designer vẽ khung app ba vùng xuất hiện ngay sau bước 5, wizard ở vùng chính.
- **Xác nhận lại (UC-02 A6) không rời dialog:** overlay MSG-49, nút Huỷ, hết 5 phút (MSG-50) và MSG-11 đều quay về dialog SCR-11 / SCR-12 đang mở, phiên không đổi. BR-25 và nơi hiện MSG-49 / MSG-50 / MSG-11 đang ghi "SCR-03", chờ sửa SRS. Brief vẽ overlay MSG-49 trên dialog và trạng thái lỗi inline trong dialog.
- **UC-10 xung đột 412 (A6 của UC-06):** bảng Lịch làm việc đổi theo giá trị server (thiết bị khác), không giữ giá trị cũ; cùng toast MSG-41 và cùng trạng thái như SCR-07. Vẽ một lần, dùng cho cả SCR-07 và SCR-14.
- **SCR-06 thiếu mục:** SRS SCR-06 chưa có "Workspace" (G12 SCR-12), "Task lặp" (G03 SCR-05), "Hoạt động AI" (G10 SCR-12); IA mục 5 có đủ. Brief vẽ cột trái theo IA. Thứ tự mục trong nhóm "Workspace" ở 1.0 chờ PO.
- **Banner lệch timezone (MSG-23) ưu tiên 4 theo IA-17:** có thể không hiện ngay khi mở app (offline, lịch cần kết nối lại, rollover lỗi đứng trước); khi chờ thì vào trung tâm thông báo (G12 SCR-11). Banner ở đầu vùng chính, không chỉ Home. SCR-13 #1 ghi "đầu Home", chờ sửa SRS.
- **SCR-15 là dialog chặn (IA mục 5), không phải màn toàn cửa sổ:** khung app mờ phía sau, không đóng bằng Esc / ×; chỉ các link Xuất dữ liệu / Xoá tài khoản / Đăng xuất thoát được. MSG-47 nơi hiện "Màn hình" chờ sửa SRS.
- **Menu Avatar:** theo IA mục 2 (Cài đặt (Ctrl+,) · Phím tắt (?) · Đăng xuất · Thoát app); flow gọi "Menu tài khoản" là tên cũ. G01 không có mã SCR cho menu này; brief G04 (sidebar) vẽ.
- **Timer dừng ngầm khi xoá tài khoản (UC-09 A2):** server dừng trong giao dịch, không có toast, thiết bị bị đăng xuất ngay; G07 UC-02 chưa có nhánh này, chờ SRS G07.


---

## G02 Quản lý task

Số # trùng bảng mục 3 của `docs/review/review-flow-vs-srs-2026-11-05.md`. Dòng trích dẫn lấy từ file ở commit đang review (`g02` = `docs/design-brief/flow/g02-quan-ly-task.md`, `srs-g02` = `docs/features/srs-g02-quan-ly-task.md`, `prd-g02` = `docs/features/prd-g02-quan-ly-task.md`, `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`, `QC` = `docs/01-quy-tac-dung-chung.md`, `_thu-g02` = `docs/design-brief/_thu-g02-tao-va-chi-tiet-task.md`, `_quy-uoc` = `docs/design-brief/flow/_quy-uoc.md`).

---

#### G02-1 · Cột ngày đã qua: thiếu nhánh IA-20, E6 vẽ sai bối cảnh — Cao

**Flow đang vẽ** (`g02:27-29`, `g02:84-85`):
```text
  start(["Board · cột ngày D"])
  u1[/"Bấm + Thêm task<br/>hoặc chọn cột rồi nhấn A"/]
  s1["SCR-01 Ô soạn task<br/>focus ô tiêu đề, ngày = D"]
  …
  p2 -.->|"E6 · cột D đã qua, PAST_DATE"| e6m>"MSG-20 · Inline<br/>Không thể đặt task chưa xong vào ngày đã qua"]
  e6m -.-> fail(["Không tạo, nội dung còn trong ô soạn"])
```

**Nguồn nói:**
- `IA:164`: "(IA-20) Cột ngày < hôm nay **không** có nút "+ Thêm task" và nút "Plan". Chọn cột đã qua rồi nhấn A → ô soạn mở ở cột **hôm nay**, board cuộn tới cột hôm nay."
- `IA:7`: "Mọi brief tính năng dựa vào đây; chỗ nào SRS còn ghi khác thì sửa ngược theo mục 13."
- `srs-g02:121`: "| 1 | Người dùng | Bấm "Thêm task" trên cột ngày D (hoặc phím A khi cột D đang chọn) |"
- `srs-g02:148`: "| E6 | Ngày D < hôm nay (cột ngày đã qua) | Server trả `VALIDATION_FAILED` · field startDate · `PAST_DATE` (QC-05); MSG-20, không tạo; nội dung còn trong ô soạn |"
- `_thu-g02:229`: "| CASE-05 | Cột ngày đã qua | SCR-01 | `[chờ O-02]`; nếu vẫn mở được ô soạn thì Enter → MSG-20, nội dung giữ trong ô | UC-01 E6, QC-05 |"
- `_thu-g02:356`: "| O-02 | Cột ngày đã qua có nút "Thêm task" không? | SCR-01, CASE-05 | **Đã chốt (IA-20):** không có nút; phím A trên cột đã qua mở ô soạn ở hôm nay |"

**Không ổn ở chỗ:** Flow chép đúng SRS, nhưng SRS UC-01 chưa được sửa ngược theo IA-20 (mục 13 của IA chỉ ghi sửa `srs-g04`). Theo IA, người dùng không thể đứng trên cột đã qua mà mở được ô soạn: nút "+ Thêm task" không có, phím A nhảy sang cột hôm nay. Designer đọc flow sẽ vẽ ô soạn trên cột cũ và trạng thái lỗi MSG-20 cho một tình huống không xảy ra, đồng thời bỏ sót hành vi "A trên cột đã qua → ô soạn ở hôm nay, board cuộn". E6 vẫn có thật nhưng ở bối cảnh khác: ô soạn còn mở khi qua mốc đầu ngày (QC-01) hoặc lệnh offline gửi muộn. IA thắng SRS vì IA đã duyệt 04/11/2026 và tự tuyên bố là nguồn cho brief.

**Sửa:**
1. SRS UC-01 thêm nhánh thay thế (đề xuất mã A6): "Chọn cột ngày < hôm nay rồi nhấn A | Ô soạn mở ở cột hôm nay, ngày = hôm nay; board cuộn tới cột hôm nay (IA-20). Cột đã qua không có nút "Thêm task"". Sửa E6 thành: "Ngày D trở thành quá khứ khi ô soạn còn mở (qua mốc đầu ngày, QC-01) hoặc lệnh \[TaskCreate\] offline gửi lên sau khi D đã qua | Server trả `PAST_DATE`; MSG-20; không tạo; nội dung còn trong ô soạn, ngày tự đổi sang hôm nay `[giả định]`".
2. Flow UC-01: `start` ghi "Board · cột ngày D ≥ hôm nay"; sơ đồ nhánh thêm:
```text
  start0(["Board · cột ngày đã qua, nhấn A"]) -->|"A6 · IA-20"| a6["SCR-01 mở ở cột hôm nay<br/>board cuộn tới hôm nay"]
  a6 --> u2
  p2 -.->|"E6 · D thành quá khứ khi ô soạn còn mở / lệnh offline muộn, PAST_DATE"| e6m
```
3. Brief `_thu-g02` CASE-05 bỏ `[chờ O-02]`, viết lại theo nhánh mới.

**Ai làm:** SRS rồi Flow.

---

#### G02-2 · Ô thêm nhanh toàn cục (Ctrl+Shift+A, khay) không có trong flow — Cao

**Flow đang vẽ** (`g02:27-28`): điểm vào duy nhất của UC-01:
```text
  start(["Board · cột ngày D"])
  u1[/"Bấm + Thêm task<br/>hoặc chọn cột rồi nhấn A"/]
```

**Nguồn nói:**
- `IA:122`: "| Ô thêm nhanh toàn cục | Ctrl+Shift+A ở bất kỳ đâu trên Windows | Cửa sổ nổi nhỏ, không viền, ở giữa màn hình đang dùng, luôn ở trên. Click ra ngoài thì đóng, giữ bản nháp. Enter: hiện "Đã thêm vào Hôm nay" ~1 giây rồi đóng, trả focus về app trước. Shift+Enter: thêm và giữ ô mở. Cửa sổ chính đang ở khay thì vẫn ở khay (IA-19) | G02 US1.1 AC07, D11 |"
- `IA:130`: "Menu chuột phải: Mở app · Thêm task (Ctrl+Shift+A) · Bật / dừng timer (kèm tên task) · Thoát."
- `IA:189`: điểm vào G02 gồm "Ctrl+Shift+A (cửa sổ riêng) · khay → Thêm task".
- `srs-g02:349`: "| Phím tắt toàn cục Ctrl+Shift+A | ✓ (có từ 1.0, D11) | … | Ngày = hôm nay; chạy cả khi cửa sổ app không ở trước; tắt phím tắt (G01 BR-15) thì ngừng. Cửa sổ nổi nhỏ, không viền, giữa màn hình đang dùng, luôn ở trên; click ra ngoài đóng, giữ bản nháp; Enter thêm, hiện "Đã thêm vào Hôm nay" ~1 giây rồi đóng, trả focus về app trước; Shift+Enter thêm và giữ ô mở; cửa sổ chính ở khay thì vẫn ở khay (IA-19) |"
- `_thu-g02:201` (F-06): "Đang ở app khác → Ctrl+Shift+A → SCR-N01.S01 → gõ → Enter → SCR-N01.S03 → cửa sổ đóng, focus trả về app trước. Task nằm ở Hôm nay."
- `_thu-g02:372`: "- [x] Mỗi flow ở mục 5 trỏ tới sơ đồ UC trong `flow/` (F-01 … F-06 → UC-01; F-07, F-08 → UC-02)."

**Không ổn ở chỗ:** SRS chỉ ghi ô thêm nhanh ở bảng "Điểm vào", không có bước / nhánh nào trong UC-01, nên flow không vẽ. Brief lại khẳng định F-06 đã được vẽ ở UC-01, tức là brief trỏ tới một sơ đồ không tồn tại. Designer sẽ không vẽ cửa sổ riêng SCR-N01 với bốn lối ra khác nhau (Enter đóng, Shift+Enter giữ, click ngoài giữ nháp, Esc đóng), cũng không vẽ dòng xác nhận "Đã thêm vào Hôm nay" (UI-09 của brief). Đây là điểm vào cấp app duy nhất của G02 chạy ngoài khung ba vùng (IA mục 6), nên thiếu nó là thiếu cả một bề mặt.

**Sửa:**
1. SRS UC-01: thêm nhánh thay thế (đề xuất mã A7) chép nội dung dòng `srs-g02:349` vào cột "Xử lý", và ghi "SCR-N01 Ô thêm nhanh toàn cục" vào mục 7 (hiện brief tự đặt mã `SCR-N01`, SRS chưa có).
2. Flow UC-01: thêm sơ đồ con "Ô thêm nhanh toàn cục":
```text
  g(["Bất kỳ đâu trên Windows · Ctrl+Shift+A<br/>hoặc khay → Thêm task"])
  g -->|"A7 · IA-19"| n1["SCR-N01 Ô thêm nhanh<br/>cửa sổ nổi, luôn ở trên, ngày = hôm nay"]
  n1 -->|"Enter"| n2>"UI · Đã thêm vào Hôm nay · ~1 giây"]
  n2 --> n3(["Cửa sổ đóng, focus về app trước"])
  n1 -->|"Shift+Enter"| n4(["Task thêm, ô giữ mở"])
  n1 -->|"click ra ngoài"| n5(["Đóng, giữ bản nháp"])
  g -.->|"phím tắt đã tắt G01 BR-15"| n6(["Không mở gì"])
```
   Nhánh E1–E4 (tiêu đề trống, > 500, mất mạng, 5xx) dùng lại như SCR-01; ghi một dòng ở bảng đối chiếu.
3. Mục lục `g02:10` thêm SCR-N01 vào cột "Màn chính".

**Ai làm:** SRS rồi Flow.

---

#### G02-3 · Xoá task có timebox liên kết sự kiện: xoá luôn cuộc họp thật — Cao

**Flow đang vẽ** (`g02:420`, `g02:391`):
```text
  p1 -->|"A2 · task có timebox"| a2["Timebox tương lai gỡ, sự kiện ngoài bị xoá<br/>timebox quá khứ chỉ gỡ liên kết QC-05"]
  …
  p2[["TaskRestore undo=true<br/>về vị trí cũ, khôi phục timebox,<br/>tạo lại sự kiện ngoài QC-05"]]
```

**Nguồn nói:**
- `QC:131`: "**Ngoại lệ: timebox liên kết sự kiện** (G05 BR-21, B8). Timebox gắn với sự kiện có sẵn trên lịch ngoài không theo các cột Timebox / Sự kiện ngoài ở trên: ở mọi đường (đổi ngày, rollover, đưa vào backlog, xoá) chỉ gỡ liên kết, **không** dời và **không** xoá sự kiện ngoài"
- `docs/features/srs-g05-lich-timebox.md:58` BR-21 (f): "xoá / rollover / đổi ngày task: chỉ gỡ liên kết, không xoá sự kiện ngoài"
- `QC:5`: "PRD/SRS của từng nhóm **tham chiếu** tới mã `QC-xx` ở đây, **không định nghĩa lại**."
- `srs-g02:53` BR-11: "timebox tương lai bị gỡ, sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, giữ sự kiện. Hoàn tác (toast / Ctrl+Z) khôi phục cả liên kết timebox, tạo lại sự kiện ngoài đã xoá với giờ cũ (QC-05)."
- `srs-g02:256` A2: "Xoá: theo QC-05 dòng "Xoá" (timebox tương lai gỡ, sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết). Hoàn tác (bước 4): khôi phục liên kết."

**Không ổn ở chỗ:** Timebox liên kết sự kiện có ở 1.0: G05 UC-10 tạo nó khi người dùng kéo cuộc họp từ lịch thành task trong Daily planning (`g05-lich-timebox.md:930-932`). Flow (và SRS BR-11, A2) viết "sự kiện ngoài bị xoá" không có ngoại lệ, nên đi theo flow thì xoá task sẽ xoá luôn cuộc họp thật trên Google / Outlook của người dùng; Hoàn tác lại "tạo lại sự kiện ngoài" thành một sự kiện mới do app tạo, không phải cuộc họp gốc. QC-05 thắng SRS G02 vì SRS chỉ được tham chiếu QC, không định nghĩa lại.

**Sửa:**
1. SRS BR-11 và UC-04 A2 thêm câu: "Timebox liên kết sự kiện (G05 BR-21): chỉ gỡ liên kết, không xoá sự kiện ngoài; Hoàn tác liên kết lại qua \[TimeboxLink\], không tạo sự kiện mới (ngoại lệ của QC-05)."
2. Flow UC-04 nhánh: tách a2 thành hai nút:
```text
  p1 -->|"A2 · task có timebox thường"| a2["Timebox tương lai gỡ, sự kiện ngoài bị xoá<br/>timebox quá khứ chỉ gỡ liên kết QC-05"]
  p1 -->|"A2 · timebox liên kết sự kiện B8"| a2l["Chỉ gỡ liên kết<br/>sự kiện trên lịch ngoài giữ nguyên QC-05 ngoại lệ"]
  a2 --> m1
  a2l --> m1
```
   Nút `p2` ở happy case (`g02:391`) sửa nhãn thành "khôi phục timebox; sự kiện ngoài đã xoá tạo lại giờ cũ;<br/>timebox liên kết: liên kết lại, không tạo sự kiện".

**Ai làm:** SRS rồi Flow.

---

#### G02-4 · AI xoá task: nhánh "đủ" đi vào toast của người dùng — TB

**Flow đang vẽ** (`g02:416-418`, `g02:424-426`):
```text
  m1>"MSG-09 · Toast · Hoàn tác"]
  …
  u1 ==> p1 ==> m1 ==> ok
  …
  ai0(["Trợ lý AI qua MCP local"]) -->|"A7"| d7{"BR-21 a, b, c đủ?"}
  d7 -->|"đủ"| p1
  d7 -->|"TOGGLE_OFF / LINKED_TASK"| a7f(["403 AI_ACTION_FORBIDDEN<br/>task không đổi"])
```
So với UC-03 A7 cùng file (`g02:329-331`):
```text
  d7 -->|"đủ"| a7["Như bước 2-3, tác nhân ai<br/>chip AI, Hoàn tác"]
  a7 --> a7x{{"→ G10 receipt và Hoàn tác"}}
```

**Nguồn nói:**
- `srs-g02:261` A7: "đủ điều kiện → như bước 2, tác nhân `ai`, chip "AI", Hoàn tác (G10)"
- `QC:205` (QC-12 mục 5): "Mọi thay đổi qua MCP được áp dụng ngay, gắn chip "AI" trên task, ghi nhật ký, và có Hoàn tác (từng thay đổi và "Hoàn tác kế hoạch AI" cho cả lượt)."
- `docs/design-brief/flow/g10-tro-ly-ai.md:1111` (UC-11 happy): `m1>"MSG-29 · Toast<br/>Claude Code (terminal) đã thay đổi {n} task · Xem · Hoàn tác"]`; `g10:510` (UC-04 A9): `p2 -->|"A9 · xoá của AI"| a9["Khôi phục từ Thùng rác QC-03 mục 3<br/>quá 30 ngày thì bỏ qua như A3"]`
- `_quy-uoc:123`: "Nhánh giống nhau ở nhiều UC … vẫn vẽ ở từng UC, vì designer vẽ theo màn; nhưng nhãn phải giống hệt nhau."

**Không ổn ở chỗ:** Nhánh "đủ" đi thẳng về `p1 → m1`, tức AI xoá xong thì hiện toast MSG-09 "Đã xoá · Hoàn tác (Ctrl+Z)" như người dùng tự xoá. Theo SRS và G10, thay đổi do AI có chip "AI", toast MSG-29 của G10 và Hoàn tác đi qua G10 UC-04 (A9 "xoá của AI"). Ngay trong cùng file, UC-03 A7 đã vẽ đúng kiểu này. Designer sẽ vẽ hai trải nghiệm khác nhau cho cùng một việc "AI làm thay".

**Sửa:** Flow UC-04 nhánh, thay `d7 -->|"đủ"| p1` bằng:
```text
  d7 -->|"đủ"| a7["Như bước 2, tác nhân ai<br/>chip AI trên task"]
  a7 --> a7x{{"→ G10 · UC-11 toast MSG-29<br/>→ G10 · UC-04 A9 Hoàn tác"}}
```
Bảng đối chiếu `g02:471` A7 sửa "Như xoá thường hoặc 403" thành "Xoá, tác nhân ai, chip AI → [G10 UC-11] / Hoàn tác [G10 UC-04]; thiếu công tắc → 403". Đồng thời UC-03 `g02:331` đổi "→ G10 receipt và Hoàn tác" thành cùng nhãn (xem G02-5).

**Ai làm:** Flow.

---

#### G02-5 · Nút sang flow khác thiếu mã UC — TB

**Flow đang vẽ** (`g02:78`, `g02:217`, `g02:331`, `g02:427`, `g02:627`):
```text
  a2m -->|"bấm Mở Backlog"| a2x{{"→ G06 Backlog"}}
  a12 --> a12x{{"→ G04 tính lại projection, sức chứa"}}
  a7 --> a7x{{"→ G10 receipt và Hoàn tác"}}
  ai1(["Khung chat G10 · Hoàn tác<br/>task do AI tạo"]) -->|"A3"| ok
  g01(["G01 · lịch làm việc chung đổi"]) -->|"A8"| a8["Channel không có khung riêng theo lịch chung mới<br/>channel có khung riêng không đổi"]
```

**Nguồn nói:**
- `_quy-uoc:70`: "| Sang flow khác | Lục giác `id{{"…"}}` | `x1{{"→ G06 · UC-02"}}` | Trỏ tới tính năng và UC; trong cùng file thì `→ UC-04` |"
- `_quy-uoc:133`: "| Flow | Flow | Nút lục giác `→ Gyy · UC-zz`; ở bảng đối chiếu thêm link markdown tới mục đó |"

**Không ổn ở chỗ:** Năm nút trỏ sang nhóm khác mà không ghi UC, nên người đọc không biết mở mục nào; hai nút (`ai1`, `g01`) còn vẽ bằng hình "điểm vào" thay vì lục giác, nên không ai nhận ra đó là flow của nhóm khác đã vẽ sẵn (G10 UC-04 đã vẽ "task AI tạo vào Thùng rác", `g10:468`; G01 UC-10 đã vẽ "Đặt khung giờ cho channel" trỏ ngược về G02 UC-06, `g01-tai-khoan.md:1135`).

**Sửa:** đổi nhãn và hình:
- `g02:78`: `a2x{{"→ G06 · UC-02 panel Backlog"}}` (brief F-05: "bấm "Mở Backlog" mở panel Backlog").
- `g02:217`: `a12x{{"→ G04 · UC-05 tính lại projection, sức chứa"}}`.
- `g02:331`: `a7x{{"→ G10 · UC-11 toast MSG-29<br/>→ G10 · UC-04 A8 Hoàn tác"}}`.
- `g02:427`: `ai1{{"→ G10 · UC-04 Hoàn tác task AI tạo"}}` nối từ `p1` bằng cạnh `"A3"`, class `link`.
- `g02:627`: `g01{{"→ G01 · UC-10 lịch làm việc chung đổi"}}` class `link`, cạnh `"A8"` tới `a8`.
- Bảng đối chiếu `g02:116, 264, 369, 467, 666` thêm link markdown tới đúng mục (`g06-backlog-rollover.md#uc-02-xem-và-tổ-chức-backlog`, `g04-board-ngay.md#uc-05-tính-projection-và-khối-lượng-ngày`, `g10-tro-ly-ai.md#uc-04-hoàn-tác-hành-động-ai`, `g01-tai-khoan.md#uc-10-cài-đặt-lịch-làm-việc`).

**Ai làm:** Flow.

---

#### G02-6 · Nhánh `LINKED_TASK` vẽ như 1.0 — TB

**Flow đang vẽ** (`g02:332`, `g02:426`, `g02:369`, `g02:471`):
```text
  d7 -->|"TOGGLE_OFF / LINKED_TASK"| a7f(["403 AI_ACTION_FORBIDDEN<br/>task không đổi"])
  …
| A7 | AI hoàn thành | Xong (tác nhân ai) hoặc 403 → [G10](g10-tro-ly-ai.md) | – |
| A7 | AI xoá | Như xoá thường hoặc 403 | – |
```

**Nguồn nói:**
- `srs-g02:63` BR-21 (c): "cả hoàn thành lẫn xoá: task (với subtask: task cha) **không** có liên kết tích hợp (G11), kể cả khi đã bật công tắc (D10)"
- `docs/02-tinh-nang-ban-sau.md:38`: "| Tích hợp Gmail / Jira / Notion | 1.1 | G11 |"
- `IA:87`: "| Tích hợp | – | Từ 1.1 | G11 |"
- `g10-tro-ly-ai.md:434`: "| A4 (phần task có liên kết tích hợp) | Hoàn thành / xoá task liên kết | Bỏ (1.1) | MSG-07 |"
- `_quy-uoc:19`: "Nhánh chỉ có từ 1.1 (chế độ chỉ đọc, trial, web…) không vẽ, ghi một dòng "Bỏ (1.1)" ở bảng đối chiếu"

**Không ổn ở chỗ:** "Liên kết tích hợp" chỉ sinh ra từ G11, mà G11 là 1.1. Flow G10 đã ghi phần này là "Bỏ (1.1)", còn flow G02 vẽ `LINKED_TASK` cùng hàng với `TOGGLE_OFF`, nên hai file không thống nhất và designer không biết ở 1.0 có gì để vẽ. Phần "chờ duyệt sau khi đọc dữ liệu tích hợp" (BR-21 cuối, D8) cũng là 1.1 và cũng chưa ghi "Bỏ".

**Sửa:**
- PO xác nhận: ở 1.0 có loại "liên kết tích hợp" nào ngoài G11 không (ví dụ link nguồn `externalRef` của task tạo từ URL, A1 UC-01, có tính là liên kết không)? Mặc định đề xuất: **không**, `externalRef` không phải liên kết tích hợp.
- Nếu không: `d7` ở UC-03 và UC-04 chỉ giữ nhãn `"TOGGLE_OFF"`; bảng đối chiếu thêm dòng "A7 (phần `LINKED_TASK`, chờ duyệt D8) | Task có liên kết tích hợp G11 | Bỏ (1.1) | –". SRS BR-21 thêm "(từ 1.1)" trước (c).

**Ai làm:** PO rồi Flow.

---

#### G02-7 · Khung giờ channel: "sửa khung đã bật" và khung chờ không được vẽ — TB

**Flow đang vẽ** (`g02:619-620`, `g02:623-624`):
```text
  s1 -->|"A5 · bật Khung giờ riêng"| a5["SCR-06 #7-#10 · 7 dòng Thứ Hai - Chủ Nhật<br/>điền sẵn theo lịch chung"]
  s1 -->|"A6 · sửa khung đã bật"| a5
  …
  p1 --> m1>"MSG-27 · Inline dưới phần Khung giờ<br/>Áp dụng từ ngày làm việc kế tiếp (ngày)"]
  m1 --> ok(["Khung mới hiệu lực từ ngày làm việc kế tiếp<br/>hôm nay vẫn dùng khung cũ BR-24"])
```

**Nguồn nói:**
- `srs-g02:326` A6: "| A6 | Sửa khung giờ đã bật | Như A5; khung mới là khung chờ, có hiệu lực từ ngày làm việc kế tiếp; hôm nay vẫn dùng khung cũ (BR-24); MSG-27 |"
- `srs-g02:64` BR-22: "Bật lần đầu → điền sẵn bằng lịch chung hiện tại `[giả định]`."
- `srs-g02:66` BR-24: "Server lưu khung đang áp và khung chờ (`pendingWorkWindow`, `workWindowEffectiveFrom`); tới mốc đầu ngày của `workWindowEffectiveFrom` thì khung chờ thành khung đang áp. Sửa tiếp trước ngày hiệu lực → ghi đè khung chờ."
- `srs-g02:433` SCR-06 #9: "| 9 | Ghi chú hiệu lực | Text | – | Sau khi lưu: MSG-27; khi có khung chờ: "Khung mới áp dụng từ {ngày}" (BR-24) |"

**Không ổn ở chỗ:** A6 dùng chung nút với A5, nhưng nút ghi "điền sẵn theo lịch chung", điều chỉ đúng khi bật lần đầu; khi sửa, 7 dòng phải hiện khung hiện có. Flow cũng không có trạng thái "đang có khung chờ" (SCR-06 #9 hiện "Khung mới áp dụng từ {ngày}") và nhánh "sửa tiếp khi đang có khung chờ → ghi đè khung chờ". Designer sẽ thiếu hai trạng thái của dòng channel: (a) khung đang áp + ghi chú khung chờ, (b) mở phần Khung giờ khi đã có khung chờ. SRS chưa nói khi mở lại phần Khung giờ lúc đang có khung chờ thì 7 dòng hiện khung đang áp hay khung chờ.

**Sửa:**
1. Flow UC-06 (sơ đồ khung giờ):
```text
  s1 -->|"A5 · bật Khung giờ riêng lần đầu"| a5["SCR-06 #7-#10 · 7 dòng<br/>điền sẵn theo lịch chung BR-22"]
  s1 -->|"A6 · sửa khung đã bật"| a6["SCR-06 #7-#10 · 7 dòng hiện khung chờ<br/>nếu có, ngược lại khung đang áp"]
  a5 --> u1
  a6 --> u1
  m1 --> s9["SCR-06 #9 · Khung mới áp dụng từ {ngày}<br/>dòng channel vẫn chạy khung cũ tới mốc đầu ngày"]
  s9 -->|"A6 · sửa tiếp trước ngày hiệu lực"| a6
  s9 --> ok
```
2. SRS A6 bỏ "Như A5", viết: "Mở phần Khung giờ với khung chờ nếu có, ngược lại khung đang áp `[giả định]`; sửa và Lưu → ghi đè khung chờ (BR-24); SCR-06 #9 hiện "Khung mới áp dụng từ {ngày}"". PO xác nhận giả định "hiện khung chờ"; mặc định đề xuất: hiện khung chờ, vì đó là cái người dùng vừa lưu.

**Ai làm:** Flow; SRS bổ sung một câu (PO xác nhận giả định).

---

#### G02-8 · Khôi phục task Kế hoạch có ngày đã qua: thiếu "về hôm nay" — TB

**Flow đang vẽ** (`g02:431-432`):
```text
  a1p --> a6["A6 · về trạng thái trước khi xoá:<br/>Kế hoạch / Hoàn thành / Lưu trữ / Backlog bucket<br/>timebox không tạo lại A2"]
  a6 --> a1m>"MSG-13 · Toast<br/>Đã khôi phục tiêu đề về nơi đến"]
```

**Nguồn nói:**
- `QC:95-96` (QC-03 mục 3): "| `KE_HOACH`, ngày dự định ≥ hôm nay | Giữ ngày |" / "| `KE_HOACH`, ngày dự định < hôm nay | Về hôm nay, số ngày bị hoãn = 0 |"
- `prd-g02:259` AC02: "task Kế hoạch giữ ngày nếu ≥ hôm nay, ngược lại về hôm nay với số ngày bị hoãn = 0."
- `srs-g02:260` A6: "| A6 | Khôi phục task trước đó `HOAN_THANH` / `LUU_TRU` / `BACKLOG` | Về đúng trạng thái trước khi xoá theo QC-03 mục 3: giữ ngày dự định và `completedAt`; về Lưu trữ với lý do cũ; về đúng bucket. MSG-13 nêu nơi đến |"
- `srs-g02:504` MSG-13: "Đã khôi phục "{tiêu đề}" về {ngày / Backlog · {bucket} / Lưu trữ}"

**Không ổn ở chỗ:** Thùng rác giữ 30 ngày, nên trường hợp phổ biến nhất khi khôi phục là task Kế hoạch có ngày dự định đã qua. QC-03 và PRD nói task về hôm nay, số ngày bị hoãn = 0; SRS A6 và flow bỏ sót trường hợp này ("Kế hoạch" ghi chung chung). Designer sẽ không biết MSG-13 "về {ngày}" phải hiện ngày nào, và không vẽ nhãn "Dời n ngày" bị xoá.

**Sửa:**
1. SRS A6 thêm: "`KE_HOACH` ngày dự định < hôm nay → về hôm nay, số ngày bị hoãn = 0 (QC-03 mục 3); ngày ≥ hôm nay → giữ ngày".
2. Flow: tách nút a6:
```text
  a1p --> d6{"Trạng thái trước khi xoá?"}
  d6 -->|"Kế hoạch, ngày ≥ hôm nay"| a6a["Giữ ngày QC-03 mục 3"]
  d6 -->|"Kế hoạch, ngày < hôm nay"| a6b["Về hôm nay, số ngày bị hoãn = 0"]
  d6 -->|"Hoàn thành / Lưu trữ / Backlog"| a6["Giữ ngày và completedAt / lý do cũ / bucket cũ<br/>timebox không tạo lại A2"]
  a6a --> a1m
  a6b --> a1m
  a6 --> a1m
```

**Ai làm:** SRS rồi Flow.

---

#### G02-9 · Happy case UC-01 đọc như phải chờ gợi ý AI mới Enter được — TB

**Flow đang vẽ** (`g02:32-34`, `g02:38-41`):
```text
  p1[["TaskSuggest qua Claude Code<br/>sau 400 ms ngừng gõ"]]
  s2["SCR-01<br/>chip Thời lượng, Channel<br/>có dấu gợi ý AI"]
  u3[/"Tuỳ chọn sửa chip, nhấn Enter"/]
  …
  d1 ==>|"có"| p1 ==> s2 ==> u3
  d1 ==>|"không · A4"| u3
```

**Nguồn nói:**
- `srs-g02:527` (NFR Hiệu năng): "ô soạn không bao giờ chờ \[TaskSuggest\] (Claude Code chạy trên máy, có thể chậm)"
- `srs-g02:136` A4: "ô soạn không chờ, tạo task bình thường"
- `_thu-g02:66` S04: "Đang chờ gợi ý | Đủ điều kiện AI, đã ngừng gõ 400 ms, chưa có kết quả (tối đa 2 giây) | … **Enter vẫn tạo được ngay** | Có gợi ý → S05; quá 2 giây / lỗi → S03"
- `_thu-g02:235` CASE-09: "Claude Code chậm > 2 giây | SCR-01.S04 → S03 | Bỏ gợi ý, không báo lỗi; gợi ý về muộn **không** điền vào task đã tạo `[đề xuất]`"

**Không ổn ở chỗ:** Trên sơ đồ, Enter (`u3`) chỉ đến sau khi `TaskSuggest` trả kết quả (`s2`), nên designer hiểu ô soạn có trạng thái "chờ AI" chặn Enter, trái NFR và trái trạng thái S04 của brief ("Enter vẫn tạo được ngay"). Flow cũng không nói gợi ý về muộn (sau khi task đã tạo) thì bỏ hay điền vào task, điều brief mới chỉ `[đề xuất]`.

**Sửa:**
1. Flow UC-01 nhánh thêm:
```text
  u2 -->|"Enter trước khi có gợi ý"| u3
  p1 -.->|"gợi ý về sau khi đã tạo"| a4b["Bỏ gợi ý, không sửa task đã tạo"]
```
   Happy case: nhãn `p1` thêm "chạy nền, không chặn Enter".
2. SRS bước 4 thêm "chạy nền; Enter trong lúc chờ vẫn tạo task; gợi ý về sau khi đã tạo thì bỏ `[giả định]`". PO xác nhận giả định; mặc định đề xuất: bỏ (như CASE-09).

**Ai làm:** Flow; SRS thêm một câu (PO xác nhận).

---

#### G02-10 · UC-02 E3: MSG-09 không nói task bị xoá ở thiết bị khác — Thấp

**Flow đang vẽ** (`g02:229-230`):
```text
  s1 -.->|"E3 · task bị xoá ở thiết bị khác khi đang mở"| e3(["SCR-03 đóng"])
  e3 -.-> e3m>"MSG-09 · Toast<br/>Đã xoá · Hoàn tác (Ctrl+Z)"]
```

**Nguồn nói:**
- `srs-g02:191` E3: "| E3 | Task bị xoá ở thiết bị khác khi đang mở | Đóng SCR-03, MSG-09 kèm "Hoàn tác" |"
- `srs-g02:500` MSG-09: "Đã xoá · Hoàn tác (Ctrl+Z)"
- `srs-g02:513` MSG-22: "Task này đã bị xoá trên thiết bị khác. Thay đổi chưa được lưu"

**Không ổn ở chỗ:** Flow đúng SRS. Nhưng người dùng đang đọc chi tiết thì dialog tự đóng và hiện "Đã xoá · Hoàn tác" như thể chính họ vừa xoá; không có chữ nào nói thiết bị khác đã làm, trong khi E5 cùng UC đã có câu riêng cho tình huống thiết bị khác (MSG-22). Ngoài ra chưa rõ "Hoàn tác" ở đây gọi \[TaskRestore\] `undo=true` có hợp lệ không khi lệnh xoá đến từ thiết bị khác.

**Sửa:** SRS thêm MSG mới (dùng MSG-05 đang "dự phòng"): "Task này đã bị xoá trên thiết bị khác · Hoàn tác", dùng ở E3; flow đổi mã. PO xác nhận "Hoàn tác" ở thiết bị này có được không; mặc định đề xuất: có, gọi \[TaskRestore\] `undo=true` như Ctrl+Z.

**Ai làm:** SRS rồi Flow (PO xác nhận Hoàn tác).

---

#### G02-11 · Esc lần đầu trên ô soạn: IA-16 và SRS A3 nói khác nhau — Thấp

**Flow đang vẽ** (`g02:79`):
```text
  s1 -->|"A3 · Esc khi đã gõ"| a3(["Ô soạn đóng, bản nháp giữ trên máy<br/>mở lại cùng ngày thấy nội dung cũ"])
```

**Nguồn nói:**
- `IA:154-156`: "**Esc** đóng lớp trên cùng, mỗi lần một lớp (IA-16):" … "2. Ô nhập đang focus: bỏ focus, giữ bản nháp"
- `srs-g02:135` A3: "| A3 | Người dùng nhấn Esc khi đã gõ | Đóng ô soạn, giữ bản nháp trên máy; mở lại ô soạn của cùng ngày thấy nội dung cũ |"
- `_thu-g02:64` S02: "Esc → S01" (S01 = "Đóng | Mặc định trên cột ngày | Chỉ có nút "+ Thêm task"")

**Không ổn ở chỗ:** Flow và brief theo SRS: Esc đóng hẳn ô soạn về nút "+ Thêm task". IA-16 nói Esc trên ô nhập đang focus chỉ bỏ focus và giữ nháp, tức ô soạn vẫn mở. Hai cách cho hai trạng thái khác nhau sau Esc (ô soạn mở-không-focus, hay ô soạn đóng), designer phải biết vẽ cái nào. IA mới hơn và tự tuyên bố thắng, nhưng ô soạn nằm inline trong cột, "mở mà không focus" có thể không phải trạng thái có ích.

**Sửa:** PO chốt: Esc lần 1 trên ô soạn (a) bỏ focus, ô soạn vẫn mở (IA-16 nguyên văn) hay (b) đóng ô soạn, giữ nháp (SRS A3, coi ô soạn là một "lớp" của IA-16). Mặc định đề xuất theo bảng tổng hợp: (a) theo IA-16; khi đó SRS A3 sửa thành "Esc: bỏ focus, ô soạn vẫn mở, giữ nháp; bấm ra ngoài / Esc lần 2 đóng ô soạn, giữ nháp", flow `a3` thêm một bước trung gian "SCR-01 mở, không focus".

**Ai làm:** PO rồi SRS rồi Flow.

---

#### G02-12 · Hết hạn mức Claude Code khi gợi ý: im lặng (SRS) hay báo (QC-12)? — Thấp

**Flow đang vẽ** (`g02:74`):
```text
  u2 -->|"A4 · AI tắt, chưa đồng ý, không có Claude Code,<br/>tắt gợi ý, chậm > 2s, lỗi, hết hạn mức"| a4["Không gợi ý: thời lượng trống,<br/>channel mặc định BR-05"]
```

**Nguồn nói:**
- `QC:208` (QC-12 mục 8): "Lỗi hết hạn mức đến từ Claude Code thì app hiện thông báo của Claude Code và chuyển sang luồng thủ công (EC-39)."
- `srs-g02:136` A4: "\[TaskSuggest\] lỗi / chậm > 2s / tắt gợi ý / trợ lý AI tắt hoặc chưa đồng ý / máy không có Claude Code (QC-12 mục 2) / Claude Code báo hết hạn mức | Không có gợi ý AI, không gọi LLM nào khác (Q33); thời lượng trống, channel mặc định (BR-05); ô soạn không chờ, tạo task bình thường |"
- `_thu-g02:235` CASE-09: "Bỏ gợi ý, không báo lỗi"

**Không ổn ở chỗ:** Flow theo SRS: hết hạn mức gộp chung với "lỗi", im lặng. QC-12 (nguồn cao hơn, G10 sở hữu) nói app phải hiện thông báo của Claude Code. Nếu im lặng ở ô soạn thì người dùng không biết vì sao gợi ý biến mất cả ngày; nếu hiện ở ô soạn thì vi phạm "ô soạn không chờ, không làm phiền". Cần một chỗ hiện.

**Sửa:** PO chốt. Mặc định đề xuất theo bảng tổng hợp: ô soạn im lặng (giữ A4), nhưng G10 hiện thông báo hết hạn mức một lần ở mục Trợ lý (panel phải) hoặc toast của G10; SRS G02 A4 ghi "hết hạn mức: ô soạn như lỗi; thông báo của Claude Code do G10 hiện (QC-12 mục 8)" và flow G02 thêm lục giác `→ G10 · UC-10` trên cạnh "hết hạn mức". G10 UC-12 E1 (`g10-tro-ly-ai.md:1241`) hiện cũng im lặng, cần thêm nhánh tương ứng.

**Ai làm:** PO rồi SRS (G02, G10) rồi Flow.

---

#### G02-13 · UC-03 thiếu "hiệu ứng chúc mừng" — Thấp

**Flow đang vẽ** (`g02:286`):
```text
  s1["SCR-02 card Hoàn thành<br/>task thường sang cột hôm nay<br/>hiện actual / planned"]
```

**Nguồn nói:** `srs-g02:211` bước 3: "Card chuyển `HOAN_THANH`; task thường chuyển sang cột hôm nay (ngày làm việc) nếu khác ngày cũ, instance lặp ở nguyên cột; hiện "actual / planned"; hiệu ứng chúc mừng nếu bật"

**Không ổn ở chỗ:** Hiệu ứng chúc mừng là một trạng thái hình ảnh designer phải vẽ (và tắt được), nhưng flow bỏ. Cũng thiếu vế "nếu khác ngày cũ".

**Sửa:** nhãn `s1` thành "SCR-02 card Hoàn thành<br/>task thường sang cột hôm nay nếu khác ngày, instance lặp giữ cột<br/>hiện actual / planned; hiệu ứng chúc mừng nếu bật".

**Ai làm:** Flow.

---

#### G02-14 · UC-03 E1 (412) không vẽ "card về trạng thái server" — Thấp

**Flow đang vẽ** (`g02:334-336`):
```text
  p1 -.->|"E1 · mất mạng"| e1["Áp ngay trên máy, hàng đợi"]
  e1 -.->|"gửi lên, cụm vị trí đã đổi, 412"| e1m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e1 -.->|"gửi lên thành công"| s1
```

**Nguồn nói:** `srs-g02:230` E1: "Khi gửi lên mà cụm vị trí trên server đã đổi (ví dụ rollover đã chạy) → 412 `VERSION_CONFLICT`, card về trạng thái server, MSG-23 (QC-08 mục 2)"

**Không ổn ở chỗ:** Nhánh 412 kết thúc ở toast, không có nút kết thúc nói task **không** Hoàn thành và card vẽ lại theo server (ví dụ đã bị rollover sang hôm nay). Designer có thể vẽ card vẫn tích xong kèm toast. UC-04 E4 cùng file (`g02:439-441`) đã vẽ đúng kiểu "→ Trạng thái trước đó".

**Sửa:** thêm `e1m -.-> e1f(["Card về trạng thái server<br/>task chưa Hoàn thành"])`, class `fail`; bảng đối chiếu E1 ghi "Hàng đợi; xung đột → card theo server, không xong".

**Ai làm:** Flow.

---

#### G02-15 · UC-06: thiếu "Huỷ" ở SCR-07, hệ quả lịch của task, xoá context rỗng, điểm vào từ G01 — Thấp

**Flow đang vẽ** (`g02:557`, `g02:590-593`):
```text
  start(["Cài đặt → Context & channel<br/>hoặc Quản lý channel trong bộ lọc"])
  …
  s1 -->|"A3 · xoá channel"| a3["SCR-07 chọn channel nhận task"]
  a3 -->|"Xác nhận"| a3p[["ChannelDelete moveTasksTo<br/>chuyển mọi task, kể cả Lưu trữ, Đã xoá, mẫu series"]]
  a3p --> a3m>"MSG-19 · Toast<br/>Đã xoá channel tên, n task chuyển sang channel nhận"]
  s1 -->|"A4 · xoá context còn channel"| a4m>"MSG-16 · Inline<br/>Hãy chuyển hoặc xoá các channel trong context trước"]
```

**Nguồn nói:**
- `srs-g02:323` A3: "Task đã chuyển dùng lịch làm việc của channel nhận ngay (BR-24); khung giờ của channel bị xoá mất theo channel"
- `srs-g02:442-443` SCR-07: "| 3 | "Xoá channel" | Button (nguy hiểm) | Gọi \[ChannelDelete\]; toast MSG-19 |" / "| 4 | "Huỷ" | Button | Đóng |"
- `srs-g02:324` A4: "| A4 | Xoá context | Chỉ cho xoá context rỗng; còn channel → MSG-16 |"
- `docs/design-brief/flow/g01-tai-khoan.md:1135`: `s1 -->|"A3 · Đặt khung giờ cho channel, SCR-14 #4"| a3x{{"→ G02 · UC-06<br/>khung giờ channel"}}`

**Không ổn ở chỗ:** (a) SCR-07 là dialog xác nhận có hai nút "Xoá channel" / "Huỷ"; flow chỉ có cạnh "Xác nhận", thiếu lối "Huỷ" và tên nút không đúng. (b) Sau khi xoá, task chuyển channel dùng lịch mới ngay → G04 tính lại projection; flow không nối. (c) A4 chỉ vẽ trường hợp chặn, không có đường xoá context rỗng thành công. (d) G01 UC-10 A3 trỏ vào G02 UC-06 "khung giờ channel" nhưng `start` của UC-06 không có điểm vào này.

**Sửa:**
```text
  a3 -->|"Xoá channel"| a3p
  a3 -->|"Huỷ"| s1
  a3m --> a3x{{"→ G04 · UC-05 task chuyển dùng lịch channel nhận"}}
  s1 -->|"A4 · xoá context rỗng"| a4(["Context biến khỏi SCR-06"])
```
`start` thêm dòng "hoặc G01 SCR-14 #4 Đặt khung giờ cho channel → phần Khung giờ".

**Ai làm:** Flow.

---

### Ghi chú cho brief — cần thêm (dán vào `g02:681` "Ghi chú cho brief G02 đầy đủ (#11)")

- SRS UC-01 chưa theo IA-20: không có nhánh "nhấn A trên cột đã qua → ô soạn mở ở cột hôm nay, board cuộn tới"; E6 (`PAST_DATE`) chỉ còn đúng khi ngày D trở thành quá khứ lúc ô soạn còn mở hoặc lệnh offline gửi muộn. Chờ sửa SRS rồi vẽ. Brief CASE-05 bỏ `[chờ O-02]`.
- Ô thêm nhanh toàn cục Ctrl+Shift+A / khay → Thêm task (IA-19, SRS mục 6) chưa có nhánh trong SRS UC-01 nên chưa vẽ; brief F-06 đang trỏ tới UC-01 mà sơ đồ không có. Cần SRS cấp mã A# và mã SCR (brief tạm dùng SCR-N01).
- UC-04 A2 và BR-11 viết "sự kiện ngoài bị xoá" không có ngoại lệ timebox liên kết sự kiện (QC-05 ngoại lệ, G05 BR-21 f: chỉ gỡ liên kết). Flow sẽ sửa theo QC-05 sau khi SRS sửa.
- `LINKED_TASK` (BR-21 c) chỉ có khi có tích hợp G11 (1.1); G10 đã ghi "Bỏ (1.1)". Chờ PO xác nhận 1.0 không có loại liên kết nào khác rồi đổi d7 chỉ còn `TOGGLE_OFF`.
- UC-04 A6 (SRS) thiếu trường hợp khôi phục task Kế hoạch có ngày < hôm nay → về hôm nay, số ngày bị hoãn = 0 (QC-03 mục 3, PRD AC02). MSG-13 "về {ngày}" cần ngày này.
- UC-02 E3 dùng MSG-09 "Đã xoá · Hoàn tác (Ctrl+Z)" cho task bị xoá ở **thiết bị khác**; chữ không nói rõ, khác MSG-22 cùng tình huống. Đề xuất MSG riêng (dùng MSG-05 dự phòng).
- Esc lần 1 trên ô soạn: IA-16 nói bỏ focus giữ nháp, SRS A3 nói đóng ô soạn. Chờ PO chốt trước khi vẽ trạng thái sau Esc.
- Hết hạn mức Claude Code khi gợi ý: SRS A4 im lặng, QC-12 mục 8 nói hiện thông báo của Claude Code. Chờ PO chốt nơi hiện (đề xuất: panel Trợ lý của G10, ô soạn im lặng).


---

## G03 Task lặp lại

Số # trùng bảng mục 3 của `docs/review/review-flow-vs-srs-2026-11-05.md`. Viết tắt: `g03` = `docs/design-brief/flow/g03-task-lap-lai.md`, `srs-g03` = `docs/features/srs-g03-task-lap-lai.md`, `prd-g03` = `docs/features/prd-g03-task-lap-lai.md`, `g06` = `docs/design-brief/flow/g06-backlog-rollover.md`, `srs-g06` = `docs/features/srs-g06-backlog-rollover.md`, `QC` = `docs/01-quy-tac-dung-chung.md`, `_quy-uoc` = `docs/design-brief/flow/_quy-uoc.md`.

---

#### G03-1 · Bật lặp cho task Backlog: "instance đầu hôm nay" trái BR-02 — Cao

**Flow đang vẽ** (`g03:73-74`, `g03:140`):
```text
  p2 -->|"A1 · task trong Backlog"| a1["Instance đầu đặt hôm nay BR-02"]
  a1 -->|"MSG-01 nêu ngày"| m1
  …
| A1 | Task trong Backlog | Instance đầu hôm nay | MSG-01 (nêu ngày) |
```

**Nguồn nói:**
- `srs-g03:123` A1: "| A1 | Task trong backlog | Instance đầu đặt hôm nay (BR-02); MSG-01 nêu ngày |"
- `prd-g03:145` AC05: "Task trong backlog (không có ngày) bật lặp → instance đầu đặt vào hôm nay `[giả định]`, toast nói rõ ngày."
- `srs-g03:40` BR-02: "Task không có ngày (backlog) → coi ngày dự định là hôm nay `[giả định]`. Tạo Series với `weekStart` (BR-03) và `anchorDate` = ngày khớp quy tắc **đầu tiên** ≥ max(ngày dự định của task, hôm nay). Task trở thành instance đầu: `seriesDate` = `startDate` = `anchorDate`; nếu ngày dự định đã khớp quy tắc thì giữ nguyên ngày, ngược lại task được dời theo đường "chọn ngày" của QC-05 `[giả định]`."
- `srs-g03:128` A6: "Ngày dự định của task không khớp quy tắc (ví dụ task Thứ Ba, quy tắc Hằng tuần Thứ Hai) | Instance đầu = ngày khớp đầu tiên sau đó (Thứ Hai kế tiếp); task dời sang ngày đó (BR-02); MSG-01 nêu ngày"
- `srs-g03:371` SCR-01 #9: "| 9 | Lần đầu | Hint | – | "Lần đầu: {ngày}" = `anchorDate` dự kiến (BR-02) |"

**Không ổn ở chỗ:** Flow chép A1 của SRS, nhưng SRS tự mâu thuẫn: BR-02 nói task backlog chỉ được *coi* ngày dự định là hôm nay rồi vẫn phải qua bước "ngày khớp quy tắc đầu tiên"; A1 lại kết luận thẳng "instance đầu hôm nay". Ví dụ hôm nay Thứ Năm, người dùng chọn Hằng tuần Thứ Hai: theo BR-02 instance đầu là Thứ Hai tới, theo A1 là Thứ Năm (sai quy tắc). Picker SCR-01 #9 cũng hiện "Lần đầu: {anchorDate}", nên nếu vẽ A1 như hiện nay thì hint và toast sẽ nói hai ngày khác nhau. Trên sơ đồ, nhánh A1 không bao giờ rẽ tới A6, designer sẽ không vẽ trạng thái "task backlog được kéo ra ngày khớp quy tắc". BR-02 nên thắng vì là quy tắc gốc và khớp với A6, SCR-01 #9.

**Sửa:**
1. SRS A1 sửa thành: "Task trong backlog | Coi ngày dự định = hôm nay; `anchorDate` = ngày khớp quy tắc đầu tiên ≥ hôm nay (BR-02); task rời backlog sang ngày đó theo đường "lấy ra ngày" của G06 (BR-05, reset số ngày bị hoãn); MSG-01 nêu ngày". PRD AC05 sửa "đặt vào hôm nay" thành "đặt vào ngày khớp quy tắc đầu tiên từ hôm nay". PO xác nhận vì cả hai câu đang `[giả định]`; mặc định đề xuất theo BR-02.
2. Flow UC-01 nhánh:
```text
  p2 -->|"A1 · task trong Backlog"| a1["Coi ngày dự định = hôm nay BR-02<br/>task rời Backlog, G06 BR-05"]
  a1 --> d6{"Ngày khớp quy tắc?"}
  d6 -->|"có"| m1
  d6 -->|"không · A6"| a6
```
   và cạnh A6 hiện tại (`g03:75`) đổi nguồn từ `p2` thành `d6` để một thoi dùng chung cho task thường và task backlog.

**Ai làm:** PO rồi SRS rồi Flow.

---

#### G03-2 · Bảng phạm vi sửa series không có cột cho instance ở Backlog — TB

**Flow đang vẽ** (`g03:416`, `g03:502`):
```text
  p1 -->|"A5 · instance quá khứ, hôm nay, đã xong,<br/>Lưu trữ, Đã xoá"| a5["Giữ nguyên EC-29, C12"]
  …
  p1[["SeriesStop: stoppedAt, áp BR-08 a<br/>xoá mềm instance tương lai chưa xong<br/>trừ instance có thời gian thực tế"]]
```

**Nguồn nói:**
- `srs-g03:91` (4.2): "| `BACKLOG` | Instance bị đưa vào backlog vẫn giữ ngày gốc | Panel Backlog (G06), biểu tượng lặp |"
- `srs-g03:57`: ""Hôm nay", "tương lai" so theo ngày dự định của instance."
- `srs-g03:59` (đầu bảng phạm vi), các cột: "`KE_HOACH` tương lai, chưa dời, chưa sửa riêng…" · "`KE_HOACH` tương lai đã dời / sửa riêng…" · "`KE_HOACH` hôm nay" · "`KE_HOACH` quá khứ (chưa rollover)" · "`HOAN_THANH`" · "`LUU_TRU`, `DA_XOA`" · "Mẫu"
- `srs-g03:46` BR-08: "Mọi thao tác (a)–(e) không đụng instance `LUU_TRU`, `DA_XOA` (C12)"

**Không ổn ở chỗ:** SRS cho phép instance nằm trong Backlog (không có ngày dự định), nhưng bảng phạm vi chỉ có cột cho `KE_HOACH` (xếp theo ngày dự định), `HOAN_THANH`, `LUU_TRU`, `DA_XOA`. Instance Backlog không thuộc cột nào, nên Dừng lặp (xoá mềm hay giữ?), Xoá mọi instance chưa xong (xoá, có tạo ngày ngoại lệ?), Đổi tần suất (ngày gốc không khớp thì xoá hẳn hay tách?), Áp mẫu, Đặt giờ đều không có câu trả lời. Flow chỉ chép được bảng nên không vẽ; designer không biết panel Backlog có gì thay đổi sau các thao tác này, và toast MSG-07/09/11 đếm `{n}` có tính instance Backlog không.

**Sửa:** PO chốt: instance ở Backlog xếp vào cột nào. Mặc định đề xuất: cột "`KE_HOACH` tương lai đã dời / sửa riêng" (đưa vào backlog là đã rời ngày gốc: Dừng lặp → xoá mềm; Đổi tần suất, ngày gốc không khớp → giữ và tách; Xoá mọi instance chưa xong → xoá mềm, ngày ngoại lệ; Áp mẫu, Đặt giờ → áp). Sau khi chốt: SRS thêm cột "`BACKLOG`" vào bảng `srs-g03:59-65` và sửa dòng `srs-g03:57`; flow UC-04 A5 / A6 và UC-05 happy thêm "instance Backlog" vào nhãn tương ứng.

**Ai làm:** PO rồi SRS rồi Flow.

---

#### G03-3 · UC-04: `SeriesApplyFrom` (A1) và đặt giờ (A2) không có nhánh lỗi — TB

**Flow đang vẽ** (`g03:410-414`, `g03:452-458`):
```text
  s1 -->|"A1 · Cập nhật mọi instance chưa xong theo task này"| a1[["SeriesApplyFrom id instance đang mở<br/>BR-08 c, subtask gộp theo tiêu đề"]]
  a1 --> a1m>"MSG-08 · Toast<br/>Đã cập nhật {n} lần chưa xong theo task này · Hoàn tác"]
  s1 -->|"A2 · Đặt giờ bắt đầu"| a2["SCR-03 · chọn giờ bước 15 phút<br/>và Xoá giờ"]
  a2 --> a2p[["SeriesUpdate approxTime, BR-08 e"]]
  …
  p1[["SeriesUpdate kèm If-Match version"]]
  p1 -.->|"E1 · 412 VERSION_CONFLICT,<br/>series vừa sửa ở thiết bị khác"| e1[["Tải lại series"]]
  p1 -.->|"E3 · 5xx / timeout"| e3m>"MSG-12 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
```

**Nguồn nói:**
- `srs-g03:249` E1: "| E1 | Version lệch (series vừa sửa ở thiết bị khác) | 412 → tải lại series, MSG-16, giữ SCR-01 mở với quy tắc mới nhất |"
- `srs-g03:251` E3: "| E3 | Lỗi 5xx / timeout | MSG-12; series không đổi |"
- `srs-g03:421`: "| \[SeriesUpdate\] `PATCH /series/{id}` | rule và / hoặc approxTime, If-Match | …"
- `srs-g03:422`: "| \[SeriesApplyFrom\] `POST /series/{id}/apply-from/{taskId}` | Idempotency-Key | …"
- `srs-g03:442`: "| 5xx / timeout | MSG-12 |"

**Không ổn ở chỗ:** E1 và E3 của SRS viết cho cả UC-04, không giới hạn ở "Đổi tần suất", nhưng sơ đồ lỗi chỉ mọc nhánh từ `p1` (đổi quy tắc). A2 cũng gọi `SeriesUpdate` kèm If-Match nên gặp cả 412 lẫn 5xx; A1 gọi `SeriesApplyFrom` (không If-Match) nên gặp 5xx. Designer sẽ không vẽ trạng thái lỗi cho bộ chọn giờ và cho thao tác áp mẫu. SRS E1 chỉ nói "giữ SCR-01 mở", chưa nói bộ chọn giờ của A2 giữ mở hay đóng khi 412.

**Sửa:**
1. Flow UC-04 sơ đồ lỗi thêm `a1` và `a2p` vào xương sống rút gọn, rồi:
```text
  a2p -.->|"E1 · 412 VERSION_CONFLICT"| e1
  e1m -.->|"A2: bộ chọn giờ giữ mở với giờ mới nhất"| a2
  a1 -.->|"E3 · 5xx / timeout"| e3m
  a2p -.->|"E3 · 5xx / timeout"| e3m
```
   Bảng đối chiếu E1 ghi "Tải lại, SCR-01 / bộ chọn giờ giữ mở"; E3 ghi "Series không đổi (đổi tần suất, áp mẫu, đặt giờ)".
2. SRS E1 thêm "(A2: giữ bộ chọn giờ mở với giờ mới nhất)"; E3 thêm "(áp cho cả A1, A2)".

**Ai làm:** Flow; SRS thêm hai cụm từ.

---

#### G03-4 · UC-06 vẽ lại job rollover của G06; G06 UC-04 thiếu timebox của instance `skipped` — TB

(Bảng mục 3 ghi vị trí "538"; đúng là `g03:581-651`, khối UC-06 happy case và "Nhánh thay thế và lỗi: rollover".)

**Flow đang vẽ** (`g03:591-595`, `g03:632-633`; `g06:369`):
```text
  start(["Job rollover G06 lúc mốc đầu ngày"])
  p1[["Nhóm instance chưa xong quá khứ theo seriesId"]]
  p2[["Hôm nay đã có instance của series QC-06 mục 1<br/>mọi instance quá khứ: Lưu trữ,<br/>archiveReason = skipped BR-10"]]
  p3[["Nhật ký system: Bị bỏ qua vì đã có lần lặp hôm nay<br/>không có toast; phát task.upserted"]]
  …
  p2 -.->|"E1 · lỗi giữa chừng"| e1[["Rollback theo người dùng<br/>G06 BR-18: thử lại lượt sau, 3 lần lỗi THAT_BAI"]]
  e1 -.->|"chạy bù khi mở app, G06 BR-19"| e1x{{"→ G06 · UC-07"}}
```
```text
  p3[["Lấy task Kế hoạch có startDate < hôm nay BR-06<br/>nhóm instance lặp theo series, áp BR-11 trước<br/>xem G03 UC-06"]]
```

**Nguồn nói:**
- `_quy-uoc:22`: "| Flow liên tính năng | Vẽ ở file của tính năng **khởi phát**. File khác chỉ có nút "sang flow khác" trỏ tới đó |"
- `g03:585`: "G06 thực thi rollover: xem [G06 UC-04](g06-backlog-rollover.md#uc-04-rollover-hằng-ngày-job-rollover)."
- `srs-g03:54` BR-16: "Nhóm sở hữu từng đường thực thi, G03 không tự chặn"
- `srs-g06:47` BR-11: "Timebox, sự kiện ngoài, timer của instance `skipped` theo dòng "lưu trữ do trùng series (`skipped`)" của QC-05, tức như "Đưa vào backlog" (D6): timebox tương lai bị gỡ và sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ; timer không dừng; timebox liên kết sự kiện theo ngoại lệ của QC-05."
- `srs-g06:239` bước 7: "task vừa lưu trữ (`stale`, `skipped`) xử lý timebox như "Đưa vào backlog" (BR-11, BR-12; Q42, D6)"

**Không ổn ở chỗ:** Rollover là job của G06; G03 chỉ sở hữu *quy tắc* QC-06. Flow G03 UC-06 vẽ lại cả xương sống job (nhóm instance, nhật ký, phát sự kiện) lẫn nhánh lỗi E1 với cơ chế lease / 3 lần lỗi / chạy bù, tức là chép G06 BR-18, BR-19 sang file G03. Hai file sẽ lệch nhau khi G06 sửa (G06 đã có trạng thái lượt `DANG_CHAY`/`XONG`/`THAT_BAI`, lease 5 phút, mà G03 chỉ ghi một phần). Ngược lại, chỗ phải có thì thiếu: cả `g03:593` lẫn G06 UC-04 (`g06:369`) không nói instance `skipped` xử lý timebox thế nào, dù G06 BR-11 quy định rõ (timebox tương lai gỡ, sự kiện ngoài xoá, timer không dừng, timebox liên kết chỉ gỡ liên kết). Designer vẽ Lưu trữ sẽ không biết timebox của instance bị bỏ qua biến mất khỏi lịch.

**Sửa:**
1. Flow G03 UC-06: giữ đúng phần là quy tắc QC-06 — thoi `d1` "Hôm nay đã có instance của series?" với hai lối "có → mọi instance quá khứ `skipped`" / "chưa có → instance mới nhất rollover, cũ hơn `skipped`", A2 (series đã dừng), A6 (đã tách), nhãn G06 MSG-13, và sơ đồ "đường đổi ngày khác". Bỏ `p1`, `p3`, `E1` (lease, THAT_BAI, chạy bù); thay bằng một lục giác `{{"→ G06 · UC-04 job rollover, lỗi và chạy bù UC-07"}}`. Nút `p2` thêm "timebox như Đưa vào backlog D6, G06 BR-11". Bảng đối chiếu E1 đổi thành "Theo G06 UC-04 E1".
2. Flow G06 UC-04: `p3` bỏ chữ "xem G03 UC-06", thêm lục giác `{{"→ G03 · UC-06 quy tắc QC-06"}}` nối từ `p3`; thêm nút sau `p4` (hoặc trong UC-05): "Instance `skipped` / task `stale`: timebox tương lai gỡ, sự kiện ngoài xoá; quá khứ gỡ liên kết; timer không dừng; timebox liên kết chỉ gỡ liên kết (BR-11, BR-12, D6)".

**Ai làm:** Flow (cả hai file).

---

#### G03-5 · Mã thông báo "Ngày này đã có {tên series}": G03 ghi MSG-21 cho đường do G02 / G04 / G06 hiện — Thấp

**Flow đang vẽ** (`g03:315-316`, `g03:661`):
```text
  d4 -->|"có · kéo thả / chọn ngày"| a4m>"MSG-21 · Toast<br/>Ngày này đã có {tên series}"]
  a4m --> ok
  …
  d2 -->|"A3 · khôi phục instance skipped từ Lưu trữ<br/>hoặc instance từ Thùng rác"| a35m>"MSG-21 · Toast<br/>Ngày này đã có {tên series}"]
```
Cùng tình huống ở file khác: `g04:304` `a4m>"MSG-23 · Toast cảnh báo<br/>Ngày này đã có {tên series}"]`; `g02:213` `a11m>"MSG-24 · Toast<br/>Ngày này đã có tên series"]`; `g02:433` `a5m>"MSG-13 kèm MSG-24 · Toast<br/>Ngày này đã có tên series"]`.

**Nguồn nói:**
- `srs-g03:54` BR-16: "thông báo gốc là G03 MSG-21; G02 MSG-24, G04 MSG-23, G06 MSG-21 dùng lại nội dung này. Nhóm sở hữu từng đường thực thi, G03 không tự chặn"
- `QC:142` (QC-06 mục 3): "Thông báo gốc là **G03 MSG-21**; các nhóm khác (G02 MSG-24, G04 MSG-23, G06 MSG-21) giữ mã riêng nhưng dùng đúng nội dung này."
- `docs/features/srs-g02-quan-ly-task.md:182` A11: "instance lặp vào ngày đã có instance cùng series → cho phép, cảnh báo MSG-24 (QC-06 đường thủ công)"
- `docs/features/srs-g02-quan-ly-task.md:259` A5: "Vẫn khôi phục; toast MSG-13 kèm cảnh báo MSG-24 (QC-06 mục 3)"
- `_quy-uoc:123`: "nhãn phải giống hệt nhau"

**Không ổn ở chỗ:** Nội dung một câu nhưng bốn mã; G03 vẽ MSG-21 cho cả những đường mà SRS nói do G02 / G04 / G06 hiện (kéo thả: G04 MSG-23; chọn ngày trong header chi tiết: G02 MSG-24; khôi phục Thùng rác: G02 MSG-13 kèm MSG-24; khôi phục Lưu trữ: G06 MSG-21). Designer đối chiếu G03 với G02 / G04 sẽ tưởng là bốn toast khác nhau và vẽ bốn lần, hoặc không biết toast khôi phục từ Thùng rác là một toast hai ý (MSG-13 + MSG-24) chứ không phải toast riêng. Thêm nữa `g03:315` gộp "kéo thả / chọn ngày" thành một nhánh nhưng chỉ nối phím D sang G04, không nối "chọn ngày" sang G02 UC-02 A11.

**Sửa:** Flow G03:
- `g03:315`: nhãn `a4m` đổi thành `"Cảnh báo QC-06 · Toast<br/>Ngày này đã có {tên series}<br/>= G03 MSG-21; G04 hiện MSG-23 (kéo thả), G02 MSG-24 (chọn ngày)"`, và thêm `a4m --> a4y{{"→ G04 · UC-03 A4 · G02 · UC-02 A11"}}`.
- `g03:661`: nhãn `a35m` đổi thành `"Cảnh báo QC-06 · Toast<br/>Ngày này đã có {tên series}<br/>G06 MSG-21 (Lưu trữ); G02 MSG-13 kèm MSG-24 (Thùng rác)"`.
- Bảng đối chiếu A4 / A3 / A5 ghi mã của nhóm hiện toast thay vì "MSG-21".

**Ai làm:** Flow.

---

### Ghi chú cho brief — cần thêm (dán vào `g03:778` "Ghi chú cho brief G03")

- UC-01 A1 "instance đầu đặt hôm nay" (task backlog) mâu thuẫn BR-02 (`anchorDate` = ngày khớp quy tắc đầu tiên ≥ hôm nay) và hint SCR-01 #9 "Lần đầu: {anchorDate}". Sơ đồ đang theo A1; chờ PO chốt theo BR-02 rồi nối A1 vào thoi "khớp quy tắc?" chung với A6.
- Bảng phạm vi sửa series (BR-08) không có cột cho instance ở `BACKLOG`, dù mục 4.2 cho phép instance nằm trong Backlog. UC-04 A5, UC-05 chưa vẽ được instance Backlog; chờ PO chốt (đề xuất: xử lý như cột "đã dời / sửa riêng").
- UC-04 E1 (412) và E3 (5xx) chỉ vẽ cho "Đổi tần suất"; `SeriesApplyFrom` (A1) và đặt giờ (A2, có If-Match) cũng gặp các lỗi này. SRS E1 chưa nói bộ chọn giờ giữ mở hay đóng khi 412. Sẽ bổ sung nhánh.
- Toast "Ngày này đã có {tên series}" có bốn mã (G03 MSG-21, G02 MSG-24, G04 MSG-23, G06 MSG-21) cùng một nội dung (QC-06 mục 3); khôi phục từ Thùng rác là một toast MSG-13 kèm MSG-24, không phải toast riêng. Designer vẽ một toast, ghi đủ mã.
- UC-06 chỉ là quy tắc QC-06; cơ chế job rollover (lease, lượt lỗi, chạy bù) và timebox của instance `skipped` (G06 BR-11, D6) thuộc G06 UC-04 / UC-05. Sơ đồ sẽ rút phần job về lục giác → G06.


---

## G04 Board ngày (`docs/design-brief/flow/g04-board-ngay.md`)

Số # trùng bảng mục 3 của `docs/review/review-flow-vs-srs-2026-11-05.md`. Viết tắt: `g04` = file flow; `srs-g04` = `docs/features/srs-g04-board-ngay.md`; `srs-g06` = `docs/features/srs-g06-backlog-rollover.md`; `QC` = `docs/01-quy-tac-dung-chung.md`; `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`.

---

#### G04-1 · Kéo task có timebox liên kết sự kiện sang ngày khác (UC-03 A7) — Cao

**Flow đang vẽ** (`g04-board-ngay.md:301-303`, bảng `:384`):
```text
  p1 -->|"A7 · timebox liên kết sự kiện B8"| a7["BR-09 giả định: timebox liên kết giữ nguyên<br/>card cờ Lệch ngày"]
  a7 --> a7m>"MSG-26 · Tooltip<br/>Lệch ngày: timebox ở {ngày timebox}, task dự định {ngày dự định}. Dời task hoặc dời timebox"]
  a7 --> m1
| A7 | Timebox liên kết sự kiện | Theo BR-09 `[giả định]`, cờ Lệch ngày | MSG-26 |
```

**Nguồn nói:**
- `srs-g04:45` BR-09: "Timebox liên kết sự kiện (B8) đi theo sự kiện gốc, không đẩy ra lịch nên không dời theo task; hành vi khi kéo task loại này sang ngày khác chờ chốt (câu hỏi mở PRD) `[giả định: timebox liên kết giữ nguyên, task hiện cờ "Lệch ngày" theo BR-24]`".
- `docs/01-quy-tac-dung-chung.md:131` QC-05, ngoại lệ: "ở mọi đường (đổi ngày, rollover, đưa vào backlog, xoá) chỉ gỡ liên kết, **không** dời và **không** xoá sự kiện ngoài; timebox đi theo sự kiện gốc".
- `docs/features/srs-g05-lich-timebox.md:58` G05 BR-21 (f): "xoá / rollover / đổi ngày task: chỉ gỡ liên kết, không xoá sự kiện ngoài".
- `docs/features/prd-g04-board-ngay.md:359` câu hỏi mở: "Kéo task có timebox liên kết sự kiện (B8) sang ngày khác: … gỡ liên kết hay giữ và gắn cờ "Lệch ngày"? SRS tạm giữ liên kết và gắn cờ."

**Không ổn ở chỗ:** Flow chép đúng G04 BR-09, nhưng BR-09 chỉ là `[giả định]` còn mở, trong khi QC-05 (quy tắc chung do G06 sở hữu, SRS không được định nghĩa lại) và G05 BR-21 (f) đã trả lời: đổi ngày thì **gỡ liên kết**. Theo flow hiện tại, designer sẽ vẽ card mang cờ "Lệch ngày" và tooltip MSG-26 sau khi kéo — trạng thái không bao giờ xảy ra nếu làm theo QC-05 (timebox đã bị gỡ thì không còn gì để lệch). Người dùng cũng sẽ thấy hai hành vi khác nhau giữa G04 (giữ) và G05 (gỡ) cho cùng một thao tác. QC-05 thắng vì là nguồn chung đã chốt 04/11/2026; BR-09 là giả định tạm.

**Sửa:**
- Flow: đổi nhánh A7 thành
  ```mermaid
  p1 -->|"A7 · timebox liên kết sự kiện B8"| a7[["Gỡ liên kết timebox, sự kiện gốc giữ nguyên<br/>task sang ngày mới, không cờ Lệch ngày · QC-05"]]
  a7 --> a7x{{"→ G05 · UC-04 A7"}}
  a7 --> m1
  ```
  Bảng đối chiếu A7: "Gỡ liên kết, sự kiện ngoài giữ nguyên → G05 UC-04 | MSG-01". Bỏ nút `a7m` (MSG-26) khỏi nhánh này.
- SRS: `srs-g04:45` BR-09 sửa đoạn cuối thành "Timebox liên kết sự kiện (B8): theo ngoại lệ của QC-05 — chỉ gỡ liên kết, không dời, không xoá sự kiện ngoài; task sang ngày mới không mang cờ "Lệch ngày"". Đóng câu hỏi mở `prd-g04:359`: "Đã chốt: theo QC-05, gỡ liên kết".
- PO chỉ cần xác nhận nếu muốn **đi ngược** QC-05 (giữ liên kết); khi đó phải sửa QC-05 và G05 BR-21 (f) trước.

**Ai làm:** SRS rồi Flow.

---

#### G04-2 · UC-01 không rẽ theo kết quả RolloverEnsure; A7 rollover tạm vô điều kiện — Cao

**Flow đang vẽ** (`g04-board-ngay.md:32, 43` happy case; `:77-81` nhánh A7):
```text
  p2[["RolloverEnsure BR-25<br/>G06 UC-07"]]
  d1 ==>|"có"| p2 ==> p3
  s1 -->|"A7 · qua mốc đầu ngày khi đang mở app"| a7["Hôm nay chuyển sang ngày mới<br/>cột cũ thành DA_QUA"]
  a7 --> d7{"Đã nhận kết quả rollover<br/>qua realtime G06?"}
  d7 -->|"có"| s1
  d7 -->|"chưa"| a7b[["Như BR-25: RolloverEnsure<br/>rollover tạm trên máy"]]
```

**Nguồn nói:**
- `srs-g04:61` BR-25: "Trong lúc chờ, hoặc khi kết quả là `DANG_CHAY`, board hiện rollover tạm trên máy … Kết quả `CHO_SHUTDOWN`: task ngày cũ ở yên cột ngày cũ. Kết quả lỗi: banner MSG-27 có "Thử lại"".
- `docs/features/prd-g04-board-ngay.md:141` AC06: "Nếu người dùng còn đang shutdown ngày cũ, việc dở ở yên ngày cũ tới khi phiên xong hoặc tối đa 2 giờ sau mốc (Q18)".
- `srs-g06:98-99` bảng 4.2: `CHO` → "Board hiện rollover tạm trên máy"; `CHO_SHUTDOWN` → "Task ngày cũ ở yên cột ngày cũ".
- `srs-g06:459` response RolloverEnsure: `status: XONG | DANG_CHAY | CHO_SHUTDOWN | DONG_BANG | THAT_BAI`.
- `docs/design-brief/flow/g08-daily-rituals.md:454` UC-02 A8: "Rollover cho D của người dùng hoãn BR-21<br/>danh sách bước 2 không đổi dưới tay".

**Không ổn ở chỗ:** Happy case và A7 chỉ có hai nhánh "đã có kết quả / chưa có → rollover tạm". Không có nhánh cho `CHO_SHUTDOWN`: người dùng đang làm Daily shutdown của hôm qua lúc 04:05, mở board lên thì flow này sẽ kéo task hôm qua sang hôm nay (rollover tạm) trong khi G08 đang giữ danh sách "không đổi dưới tay". Hai màn mâu thuẫn ngay trên cùng một thiết bị. Nhánh `THAT_BAI` và `DANG_CHAY` cũng không được phân biệt; E4 chỉ bắt `ROLLOVER_FAILED` (lỗi request), không bắt `status = THAT_BAI`. Designer sẽ không vẽ trạng thái "cột hôm qua vẫn còn task, cột hôm nay chưa có, không có banner".

**Sửa (Flow):** sau `p2` thêm thoi rẽ theo trạng thái trả về; nhánh A7 nối vào cùng thoi:
```mermaid
  p2 --> d2{"RolloverEnsure trả?"}
  d2 -->|"XONG"| p3
  d2 -->|"DANG_CHAY / đang chờ"| r1["Rollover tạm trên máy BR-25<br/>chỉ hiển thị QC-08 mục 5"]
  d2 -->|"CHO_SHUTDOWN"| r2["Task ngày cũ ở yên cột ngày cũ<br/>tới khi phiên xong hoặc mốc + 2 giờ"]
  d2 -->|"THAT_BAI / ROLLOVER_FAILED"| e4
  r1 --> p3
  r2 --> p3
  r2 --> r2x{{"→ G08 · UC-02"}}
```
A7: thay `d7`/`a7b` bằng cạnh `a7 --> d2`. Bảng đối chiếu A7 ghi thêm "đang shutdown ngày cũ → giữ cột cũ". Vẽ `r2` màu `alt`, `r1` màu `sync`.
Câu hỏi cho PO (mặc định đề xuất): `status = THAT_BAI` trong response có hiện banner MSG-27 như `ROLLOVER_FAILED` không? Mặc định: có, cùng banner, cùng nút "Thử lại".

**Ai làm:** Flow (PO chốt câu `THAT_BAI`).

---

#### G04-3 · Câu lỗi TaskMove khác G06 cho cùng một lỗi (UC-03 E1, E3, E4, E7) — TB

**Flow đang vẽ** (`g04-board-ngay.md:340-356`):
```text
  e1 -.-> e1m>"MSG-09 · Toast<br/>Không thể chuyển task chưa xong về ngày đã qua"]
  e3 -.-> e3m>"MSG-17 · Toast<br/>Task đã thay đổi trên thiết bị khác, đã cập nhật lại"]
  e4 -.-> e4m>"MSG-14 · Toast<br/>Task này đã bị xoá"]
  e7 -.-> e7m>"MSG-15 · Toast<br/>Chưa tải / lưu được thay đổi. Thử lại"]
```
So với G06 cho cùng API `TaskMove` (`g06-backlog-rollover.md:102-107, 317-321`):
```text
  e5m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e2m>"MSG-20 · Toast<br/>Task này không còn tồn tại"]
  e3m>"MSG-17 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e3m>"MSG-24 · Toast<br/>Không thể đặt task chưa xong vào ngày đã qua"]
```

**Nguồn nói:**
- `srs-g04:565, 570, 571, 573`: MSG-09 "Không thể chuyển task chưa xong về ngày đã qua"; MSG-14 "Task này đã bị xoá"; MSG-15 "Chưa tải / lưu được thay đổi. Thử lại"; MSG-17 "Task đã thay đổi trên thiết bị khác, đã cập nhật lại".
- `srs-g06:496, 499, 502, 503`: MSG-17 "Chưa lưu được thay đổi. Thử lại"; MSG-20 "Task này không còn tồn tại"; MSG-23 "Task đã thay đổi trên thiết bị khác"; MSG-24 "Không thể đặt task chưa xong vào ngày đã qua".
- `docs/01-quy-tac-dung-chung.md:159` QC-08 mục 2: "người dùng thấy "Task đã thay đổi trên thiết bị khác"".
- `docs/design-brief/flow/_quy-uoc.md:123`: "Nhánh giống nhau ở nhiều UC (mất mạng, `VERSION_CONFLICT`, task bị xoá ở thiết bị khác) vẫn vẽ ở từng UC … nhưng nhãn phải giống hệt nhau."

**Không ổn ở chỗ:** Cả hai flow đều chép đúng SRS của mình, nhưng hai SRS đặt bốn câu khác nhau cho cùng một mã lỗi của cùng một API. Kéo task sang ngày khác (G04) và kéo task từ backlog ra ngày (G06) cùng gọi `TaskMove`, cùng gặp `VERSION_CONFLICT`, nhưng người dùng sẽ đọc hai câu khác nhau tuỳ task đến từ đâu. Designer phải vẽ 8 toast thay vì 4, và không có cơ sở chọn câu nào khi cùng một màn (panel Backlog trên Home) gặp lỗi. Câu của QC-08 khớp G06, không khớp G04 ("…, đã cập nhật lại" là phần thêm).

**Sửa:**
- SRS: thống nhất một bộ câu dùng chung cho `TaskMove`, đặt ở QC-08 (hoặc G02 vì G02 sở hữu `PAST_DATE`, `TASK_DELETED`). Đề xuất lấy chữ của G06 vì khớp QC-08: `VERSION_CONFLICT` → "Task đã thay đổi trên thiết bị khác"; task đã xoá → "Task này không còn tồn tại"; 5xx → "Chưa lưu được thay đổi. Thử lại" (G04 giữ "Chưa tải / lưu được" cho DayList, vì đó là lỗi tải); `PAST_DATE` → "Không thể đặt task chưa xong vào ngày đã qua". Sửa `srs-g04:565, 570, 573` theo đó, giữ mã MSG riêng của G04.
- Flow: sau khi SRS sửa, cập nhật nhãn `e1m`, `e3m`, `e4m` (và `e7m` nếu đổi) cho giống hệt G06.

**Ai làm:** SRS rồi Flow.

---

#### G04-4 · Phím S / D trên task backlog: G04 và G06 mô tả khác nhau (UC-03 A1) — TB

**Flow đang vẽ** (`g04-board-ngay.md:290-293`):
```text
  start2(["Task đang chọn / hover"]) -->|"A1 · phím D / lệnh Hoãn 1 tuần / phím S"| a1[["TaskMove snooze: day / snooze: week /<br/>startDate = hôm nay<br/>server tính ngày đích BR-10"]]
  a1 -->|"S"| a1s>"MSG-07 · Toast<br/>Đã chuyển về hôm nay · Hoàn tác"]
```
G06 cho cùng phím S trên task backlog (`g06-backlog-rollover.md:305, 309`):
```text
  start -->|"A1 · phím S"| a1["startDate = hôm nay"]
  p1 -->|"A1 / A2"| m3>"MSG-03 · Toast<br/>Đã chuyển #quot;{tiêu đề}#quot; sang {ngày} · Hoàn tác"]
```

**Nguồn nói:**
- `srs-g04:197` tiền điều kiện UC-03: "Task ở `KE_HOACH`, `BACKLOG` hoặc `HOAN_THANH`"; `srs-g04:214` A1: "Phím D / lệnh "Hoãn 1 tuần" / phím S | … toast MSG-05 / MSG-06 / MSG-07".
- `srs-g04:46` BR-10: "task backlog: ngày làm việc kế tiếp theo lịch của task của hôm nay (C15, QC-05)".
- `srs-g06:206` UC-03 A1: "Phím S trên task backlog | `startDate` = hôm nay; toast MSG-03".

**Không ổn ở chỗ:** Cùng một thao tác (S trên task backlog) có hai UC sở hữu và hai toast khác chữ: G04 MSG-07 "Đã chuyển về hôm nay" và G06 MSG-03 "Đã chuyển "{tiêu đề}" sang {ngày}". Phím D trên task backlog (BR-10 có quy định riêng: ngày làm việc kế tiếp của hôm nay) không được vẽ ở flow nào — G04 A1 gom chung với task có ngày, G06 UC-03 không có D. Designer sẽ không biết D trên panel Backlog có hoạt động không và hiện toast gì.

**Sửa:**
- SRS: chốt G06 UC-03 sở hữu "task backlog ra ngày" (vì G06 sở hữu QC-05 và trạng thái `BACKLOG`). `srs-g04:197` bỏ `BACKLOG` khỏi tiền điều kiện UC-03, A1 ghi "task backlog: theo G06 UC-03". `srs-g06:206` thêm "Phím D trên task backlog: `startDate` = ngày làm việc kế tiếp theo lịch của task của hôm nay (G04 BR-10, C15); toast MSG-03".
- Flow G04: ở `start2` thêm nhãn "task Kế hoạch"; thêm cạnh `start2 -->|"A1 · task backlog"| a1bx{{"→ G06 · UC-03"}}`.
- Flow G06 UC-03: thêm nhánh `start -->|"A1 · phím D"| a1d["startDate = ngày làm việc kế tiếp của hôm nay<br/>theo lịch của task BR-10 G04"]` → `p1` → `m3`.

**Ai làm:** SRS rồi Flow.

---

#### G04-5 · UC-05 thiếu ba trạng thái ngày và thứ tự ưu tiên BR-21 — TB

**Flow đang vẽ** (`g04-board-ngay.md:565-567`):
```text
  p1[["Tính sức chứa BR-04, quá tải BR-05,<br/>projection BR-06"]]
  s1["SCR-02 BINH_THUONG<br/>tổng màu thường, card có giờ dự kiến"]
  p1 ==> s1
```
Sơ đồ chỉ rẽ ra `QUA_TAI` (qa, qb) từ `dq`.

**Nguồn nói:**
- `srs-g04:57` BR-21: "mỗi ngày có đúng một trạng thái chính, xét lần lượt `DA_QUA` > `TRONG` > `XONG_HET` > `QUA_TAI` > `BINH_THUONG`; điều kiện đầu tiên thoả thì dừng".
- `srs-g04:93` `TRONG`: "Header tổng "0:00"; thân cột chỉ có "Thêm task"".
- `srs-g04:96` `XONG_HET`: "Thanh tiến độ đầy; không hiện cảnh báo".
- `srs-g04:97` `DA_QUA`: "Không tính projection, không cảnh báo; card hiện "actual / planned"".

**Không ổn ở chỗ:** UC-05 là UC duy nhất định nghĩa trạng thái ngày, nhưng flow chỉ vẽ 2 trong 5 trạng thái chính. Designer sẽ thiếu ba trạng thái cột: cột rỗng, cột xong hết (thanh tiến độ đầy, **không** đỏ dù tổng vượt sức chứa), cột đã qua (card đổi sang "actual / planned", không có giờ dự kiến). Thứ tự ưu tiên cũng quan trọng cho designer: ngày đã qua mà còn task chưa xong vẫn là `DA_QUA`, không phải `QUA_TAI`.

**Sửa (Flow):** ở sơ đồ "Nhánh thay thế: sức chứa, quá tải, vượt giờ làm", chèn thoi ưu tiên trước `p1`:
```mermaid
  d0{"Trạng thái chính BR-21<br/>xét lần lượt"}
  d0 -->|"ngày < hôm nay"| sdq(["SCR-02 DA_QUA<br/>card actual / planned, không projection, không cảnh báo"])
  d0 -->|"không có task"| str(["SCR-02 TRONG<br/>tổng 0:00, chỉ có Thêm task"])
  d0 -->|"mọi task đã xong"| sxh(["SCR-02 XONG_HET<br/>tiến độ đầy, không cảnh báo"])
  d0 -->|"còn task chưa xong"| p1
```
Bảng đối chiếu thêm một dòng "BR-21 | Thứ tự ưu tiên | 5 trạng thái chính | –". Gán class `done` cho ba nút kết thúc mới.

**Ai làm:** Flow.

---

#### G04-6 · Nút sang flow thiếu mã UC (UC-03 A2, UC-08 A5) — Thấp

**Flow đang vẽ** (`g04-board-ngay.md:299`, `:858-859`):
```text
  a2 --> a2x{{"→ G05 cập nhật sự kiện ngoài"}}
  a1 -->|"A5 · lệnh thuộc nhóm khác<br/>lệnh chưa có ở 1.0 không hiện"| a5a{{"→ G08 · P, O"}}
  a1 -->|"A5"| a5b{{"→ G07 · F, Space"}}
```

**Nguồn nói:** `docs/design-brief/flow/_quy-uoc.md:70`: nút lục giác "Trỏ tới tính năng và UC; trong cùng file thì `→ UC-04`". Flow G05 vẽ tương tác này ở UC-04 A7 (`docs/design-brief/flow/g05-lich-timebox.md:464` nút `g04d` "Phím D, kéo sang ngày khác, shutdown Ngày mai, AI dời ngày · G04, G08, G10"). Ngoài ra nhánh A1 (D / Hoãn 1 tuần / S) cũng dời timebox theo QC-05 (`srs-g04:46`: "Timebox, sự kiện ngoài, timer của "Hoãn 1 tuần" và S theo dòng … của QC-05") nhưng trong flow không nối đi đâu.

**Không ổn ở chỗ:** Designer bấm vào nút không biết mở section nào của G05 / G07 / G08. Nhánh A1 có timebox cũng dời theo nhưng sơ đồ chỉ vẽ cho A2 (kéo thả) nên designer dễ hiểu D / S không đụng timebox.

**Sửa (Flow):**
- `:299` đổi thành `a2x{{"→ G05 · UC-04 A7"}}`; thêm cạnh `a1 --> a2x` với nhãn "task đã timebox".
- `:858-859` đổi thành `a5a{{"→ G08 · UC-01 (P), UC-02 (O)"}}` và `a5b{{"→ G07 · UC-01 (Space), UC-04 (F)"}}`.
- Bảng đối chiếu A2, A5 thêm link markdown tới đúng mục.

**Ai làm:** Flow.

---

#### G04-7 · Cờ "Lệch ngày" không dẫn tới cách xử lý (UC-01 A8, UC-03 A7) — Thấp

**Flow đang vẽ** (`g04-board-ngay.md:84`, `:302`):
```text
  a8 --> a8m>"MSG-26 · Tooltip<br/>Lệch ngày: timebox ở {ngày timebox}, task dự định {ngày dự định}. Dời task hoặc dời timebox"]
  a7 --> a7m>"MSG-26 · Tooltip<br/>Lệch ngày: timebox ở {ngày timebox}, task dự định {ngày dự định}. Dời task hoặc dời timebox"]
```
Cả hai nút đều là nút lá, không có cạnh ra.

**Nguồn nói:**
- `srs-g04:60` BR-24: "Hệ thống không tự sửa; người dùng tự dời task hoặc dời timebox."
- `docs/features/srs-g05-lich-timebox.md:59` BR-22: "Người dùng chọn: "Dời task sang {ngày timebox}" … hoặc "Dời timebox về {ngày dự định}"" — G05 UC-11 (`docs/design-brief/flow/g05-lich-timebox.md:1003` "## UC-11 Xử lý cờ "Lệch ngày"") vẽ popover hai lựa chọn.

**Không ổn ở chỗ:** Tooltip bảo "Dời task hoặc dời timebox" nhưng flow G04 không chỉ ra bấm vào đâu. G05 BR-22 / UC-11 đã đặc tả popover hai lựa chọn khi bấm nhãn trên card. Designer vẽ G04 sẽ làm nhãn "Lệch ngày" thành tooltip tĩnh, không bấm được; designer vẽ G05 lại làm popover. (Sau khi sửa G04-1, nút `a7m` ở `:302` biến mất; chỉ còn `a8m`.)

**Sửa (Flow):** thêm `a8m --> a8y{{"→ G05 · UC-11"}}` với nhãn cạnh "bấm nhãn Lệch ngày"; class `link`. Bảng A8 ghi "cờ Lệch ngày → [G05 UC-11]". SRS: `srs-g04:60` BR-24 thêm "bấm nhãn → G05 UC-11".

**Ai làm:** Flow (SRS thêm một câu).

---

#### G04-8 · UC-01 E3 thiếu banner "Lịch cần kết nối lại" — Thấp

**Flow đang vẽ** (`g04-board-ngay.md:120-122`):
```text
  p3 -.->|"E3 · CalendarEvents lỗi hoặc chưa kết nối lịch"| e3["SCR-02 cờ CHUA_TINH_LICH<br/>sức chứa = giờ làm còn lại, chưa trừ sự kiện"]
  e3 -.-> e3m>"MSG-18 · Tooltip tổng<br/>Chưa tính lịch: chưa kết nối hoặc lịch đang lỗi"]
  e3m -.-> s1
```

**Nguồn nói:**
- `srs-g04:435` SCR-01 #5: "thứ tự ưu tiên: offline → workspace chỉ đọc (MSG-20, bản 1.1) → lịch cần kết nối lại (G05 SCR-09) → rollover lỗi (MSG-27) → lệch timezone (G01 MSG-23)".
- `IA:67-70` mục 3 Banner: "2. Lịch cần kết nối lại (G05 SCR-09)".

**Không ổn ở chỗ:** Khi lịch lỗi vì token bị thu hồi (EC-15), board vừa có cờ `CHUA_TINH_LICH` vừa có banner G05 SCR-09 ở đầu vùng chính. Flow chỉ vẽ tooltip, designer sẽ không vẽ banner trên Home cho ca này và không biết nó xếp trước banner rollover lỗi (E4).

**Sửa (Flow):** thêm `e3 -.->|"token lỗi / bị thu hồi EC-15"| e3x{{"→ G05 · UC-08 banner SCR-09"}}` class `link`; bảng E3 ghi "cờ `CHUA_TINH_LICH`; cần kết nối lại → banner G05 SCR-09 (ưu tiên 2, IA-17)".

**Ai làm:** Flow.

---

#### G04-9 · Phím tắt IA-15 chưa vào SRS G04 (UC-08) — Thấp

**Flow đang vẽ** (`g04-board-ngay.md:851`):
```text
  k0 -->|"A1 · gõ thẳng phím tắt: H, T, P, O, B, Tab, D, S, F,<br/>Shift+F, Shift+C/T/B/A, <, >, Shift+L…"| a1[["Chạy lệnh như bước 4<br/>không mở menu"]]
```

**Nguồn nói:**
- `IA:146` "Ctrl+\\ | Ẩn / hiện panel phải | **Mới** (IA-15)"; `IA:148` "Ctrl+J | Mở / đóng mục Trợ lý | **Chốt** …"; `IA:149` "Ctrl+, | Mở Cài đặt | **Mới** (IA-15)"; `IA:150` "Ctrl+K | Command menu (gồm "Task đã xoá gần đây", "Thông báo")".
- `srs-g04:53` BR-17: "Ctrl/Cmd+K, Ctrl+F luôn chạy" (không có Ctrl+J, Ctrl+,, Ctrl+\\).
- `srs-g04:510-511` SCR-08 #9, #10: nhóm Điều hướng trang "H, T, P, O, B, Tab, Shift+C/T/B/A, < >, Shift+L"; nhóm Chung "? bảng phím tắt, Ctrl+F tìm kiếm, Shift+F lọc" — không có ba phím mới và hai lệnh mới.

**Không ổn ở chỗ:** IA đã duyệt và ghi mục 13 "Đã sửa ngược vào PRD / SRS" cho SCR-01 #4 (có Ctrl+\\), nhưng SCR-08, SCR-09 và BR-17 chưa được sửa. Command menu và bảng phím tắt (hai màn designer vẽ từ SRS) sẽ thiếu Ctrl+J, Ctrl+,, Ctrl+\\ và hai lệnh "Task đã xoá gần đây", "Thông báo". BR-17 cũng không nói ba phím Ctrl mới có "luôn chạy" trong ô nhập như Ctrl+K hay không.

**Sửa:**
- SRS: `srs-g04:53` BR-17 thêm "Ctrl+J, Ctrl+,, Ctrl+\\ luôn chạy (IA-15)". `srs-g04:510` nhóm Điều hướng trang thêm "Ctrl+\\ panel phải, Ctrl+J Trợ lý, Ctrl+, Cài đặt"; `srs-g04:511` nhóm Chung thêm "Task đã xoá gần đây (G02), Thông báo (G12)". SCR-09 kế thừa.
- Flow: nhãn A1 thêm "Ctrl+J, Ctrl+,, Ctrl+\\"; nhánh A5 thêm nút `{{"→ G02 · UC-04 (Task đã xoá gần đây)"}}` và `{{"→ G12 · UC-09 (Thông báo)"}}`.

**Ai làm:** SRS rồi Flow.

---

#### G04-10 · S / "Hoãn 1 tuần" đưa instance lặp vào ngày đã có instance cùng series (UC-03 A4) — Thấp, cần PO chốt

**Flow đang vẽ** (`g04-board-ngay.md:304-307`):
```text
  p1 -->|"A4 · instance lặp, kéo / chọn ngày vào ngày<br/>đã có instance cùng series; chỉ đổi instance này"| a4m>"MSG-23 · Toast cảnh báo<br/>Ngày này đã có {tên series}"]
  a1 -->|"A4 · phím D vào ngày đã có instance cùng series"| a4d["Instance được dời chuyển LUU_TRU<br/>lý do skipped"]
```
Không có nhánh cho S hoặc "Hoãn 1 tuần".

**Nguồn nói:**
- `docs/01-quy-tac-dung-chung.md:141` QC-06 mục 2: "**Đường tự động hoặc hàng loạt** … Các đường này gồm: rollover, phím D, shutdown "Ngày mai"."
- `docs/01-quy-tac-dung-chung.md:142` QC-06 mục 3: "**Đường thủ công từng task** (kéo thả, chọn ngày, khôi phục): vẫn cho đặt, kèm cảnh báo".
- `srs-g04:217` A4 chỉ nói "Kéo / chọn ngày …" và "Phím D …".

**Không ổn ở chỗ:** Phím S (về hôm nay) và "Hoãn 1 tuần" (+7 ngày, có thể trùng ngày instance tuần sau) không nằm trong danh sách của mục 2 lẫn mục 3 của QC-06. SRS G04 và flow đều bỏ qua. Người dùng nhấn "Hoãn 1 tuần" trên instance lặp hằng tuần sẽ chắc chắn trùng ngày với instance kế; hệ thống không có quy tắc. Designer không biết hiện MSG-23 (cảnh báo, cho phép) hay MSG-24 (chuyển Lưu trữ, có Hoàn tác).

**Sửa:**
- PO chốt: S và "Hoãn 1 tuần" theo đường **thủ công** (cho đặt, cảnh báo MSG-23) hay **tự động** (lưu trữ `skipped`, MSG-24)? Mặc định đề xuất: thủ công — vì là thao tác từng task do người dùng chủ động, như "chọn ngày"; và theo QC-04 mục 3 hai đường này reset số ngày bị hoãn như đường thủ công.
- SRS: QC-06 mục 3 thêm "phím S, "Hoãn 1 tuần"" (G03 sở hữu QC-06); `srs-g04:217` A4 ghi tương ứng.
- Flow: thêm cạnh `a1 -->|"A4 · S / Hoãn 1 tuần vào ngày đã có instance cùng series"| a4m`.

**Ai làm:** PO rồi SRS rồi Flow.

---

### Ghi chú cho brief — cần thêm vào `g04-board-ngay.md` (mục "Ghi chú cho brief G04")

Sửa ghi chú 8 (`g04:910`) thành:

> 8. **UC-03 A7 / BR-09:** BR-09 còn `[giả định]` "giữ liên kết, cờ Lệch ngày", nhưng QC-05 (ngoại lệ timebox liên kết sự kiện) và G05 BR-21 (f) đã chốt "đổi ngày task: chỉ gỡ liên kết, không dời, không xoá sự kiện ngoài". Sơ đồ vẽ theo QC-05; BR-09 và câu hỏi mở PRD cần đóng theo đó.

Thêm các dòng:

> 12. **UC-01 kết quả RolloverEnsure.** BR-25 có 4 kết quả (`XONG`, `DANG_CHAY`, `CHO_SHUTDOWN`, lỗi); `CHO_SHUTDOWN` thì task ngày cũ ở yên cột cũ (người dùng đang làm Daily shutdown qua mốc, G08 UC-02 A8). Brief cần trạng thái "cột hôm qua còn task, hôm nay chưa có, không banner". Chưa rõ `status = THAT_BAI` trong response có hiện banner MSG-27 như `ROLLOVER_FAILED` không; cần PO chốt.
> 13. **Câu lỗi TaskMove khác G06.** `VERSION_CONFLICT`, task đã xoá, 5xx, `PAST_DATE` cùng API nhưng G04 (MSG-17, 14, 15, 09) và G06 (MSG-23, 20, 17, 24) đặt chữ khác nhau; QC-08 mục 2 khớp G06. Cần một bộ câu chung trước khi viết brief.
> 14. **Phím S / D trên task backlog** có ở cả G04 UC-03 A1 (MSG-07) và G06 UC-03 A1 (MSG-03); phím D trên task backlog (BR-10) chưa flow nào vẽ. Đề xuất G06 UC-03 sở hữu.
> 15. **UC-05 trạng thái ngày:** sơ đồ chưa vẽ `TRONG`, `XONG_HET`, `DA_QUA` và thứ tự ưu tiên BR-21; brief cần đủ 5 trạng thái cột và 2 cờ phụ.
> 16. **Phím tắt IA-15** (Ctrl+J, Ctrl+,, Ctrl+\\) và lệnh Ctrl+K "Task đã xoá gần đây", "Thông báo" chưa có trong SCR-08, SCR-09, BR-17; brief command menu và bảng phím tắt lấy theo IA mục 8.
> 17. **Nhãn "Lệch ngày"** trên card: G05 BR-22 / UC-11 nói bấm mở popover hai lựa chọn; G04 BR-24 chỉ có tooltip MSG-26. Brief vẽ nhãn bấm được, dẫn sang G05 UC-11.
> 18. **S / "Hoãn 1 tuần" trên instance lặp** vào ngày đã có instance cùng series: QC-06 chưa xếp vào đường tự động hay thủ công; chờ PO.


---

## G05 Lịch và timebox

Số # trùng bảng mục 3 của `docs/review/review-flow-vs-srs-2026-11-05.md`. Dòng trích là dòng trong file tại commit đang review (flow ghi nguồn `8fac830`).

---

#### G05-1 · Đường đổi ngày / xoá / backlog xoá luôn sự kiện gốc của timebox liên kết — Cao

**Flow đang vẽ** (`g05-lich-timebox.md:463-473`):
```text
  g02d(["G02 · UC-04 xoá task"]) -->|"A5"| a5[["Theo dòng Xoá QC-05"]]
  g06b(["Đưa task vào backlog · G04, G06"]) -->|"A8"| a8[["Theo QC-05: như Đưa vào backlog"]]
  g04d(["Phím D, kéo sang ngày khác, shutdown Ngày mai,<br/>AI dời ngày · G04, G08, G10"]) -->|"A7"| a7[["Timebox giữ giờ, dời sang ngày mới<br/>cập nhật sự kiện ngoài, timer không dừng"]]
  a5 --> fut[["Timebox tương lai CHO_XOA<br/>xoá sự kiện ngoài"]]
  a8 --> fut
```

**Nguồn nói:**
- `docs/01-quy-tac-dung-chung.md:131`: "**Ngoại lệ: timebox liên kết sự kiện** (G05 BR-21, B8). Timebox gắn với sự kiện có sẵn trên lịch ngoài không theo các cột Timebox / Sự kiện ngoài ở trên: ở mọi đường (đổi ngày, rollover, đưa vào backlog, xoá) chỉ gỡ liên kết, **không** dời và **không** xoá sự kiện ngoài".
- `docs/features/srs-g05-lich-timebox.md:58` BR-21 (f): "xoá / rollover / đổi ngày task: chỉ gỡ liên kết, không xoá sự kiện ngoài".
- `docs/features/srs-g04-board-ngay.md:45` BR-09 lại ghi: "`[giả định: timebox liên kết giữ nguyên, task hiện cờ "Lệch ngày" theo BR-24]`"; `g04-board-ngay.md:301` vẽ theo giả định này.

**Không ổn ở chỗ:** Sơ đồ chỉ có một đường cho mọi timebox. Một task tạo từ cuộc họp (G08 bước Thêm task) có timebox liên kết với **cuộc họp thật** trên lịch công ty; designer vẽ theo sơ đồ sẽ hiểu xoá task hoặc đưa vào backlog thì xoá luôn cuộc họp đó, còn phím D / kéo sang ngày khác thì dời cuộc họp. Hai nguồn cao hơn (QC-05 và chính BR-21 của G05) nói ngược lại: chỉ gỡ liên kết trong app, cuộc họp không bị đụng. G04 BR-09 đưa ra giả định thứ ba (giữ liên kết, gắn cờ Lệch ngày). Nguồn thắng là **QC-05**: D1 (`quyet-dinh-chot-2026-11-04.md:9`) quy định nhóm chỉ tham chiếu quy tắc chung, không tự định nghĩa lại; B8 chỉ nói "đi theo sự kiện gốc", không trao cho G04 quyền giữ liên kết khi task đổi ngày.

**Sửa:**
- Flow: tách nhánh liên kết ra khỏi `a5`, `a7`, `a8`:
```mermaid
  a5 -->|"timebox liên kết sự kiện BR-21 f"| lk[["Chỉ gỡ liên kết<br/>sự kiện ngoài giữ nguyên, không dời"]]
  a7 -->|"timebox liên kết sự kiện"| lk
  a8 -->|"timebox liên kết sự kiện"| lk
  lk --> lkok(["Task không còn timebox liên kết<br/>cuộc họp vẫn trên lịch ngoài"])
```
  Đổi nhãn `a7` thành "Timebox thường: giữ giờ, dời sang ngày mới…".
- SRS G04 BR-09 (`srs-g04:45`): bỏ giả định, thay bằng "Timebox liên kết sự kiện: theo ngoại lệ QC-05, gỡ liên kết, task sang ngày mới, không cờ Lệch ngày"; đóng câu hỏi mở tương ứng trong PRD G04; sửa `g04-board-ngay.md:301-302` cùng lúc.
- Ghi chú `g05:1108` sửa thành: QC-05 đã quyết, G04 BR-09 là chỗ sai.
- PO xác nhận (đề xuất mặc định: theo QC-05).

**Ai làm:** PO xác nhận → SRS (G04 BR-09) → Flow (G05, G04).

---

#### G05-2 · Ctrl+X trên timebox liên kết: kết thúc và Hoàn tác vẽ như timebox thường — Cao

**Flow đang vẽ** (`g05-lich-timebox.md:416-422`):
```text
  start -->|"A1 · Ctrl+X / Gỡ khỏi lịch SCR-06"| a1[["TimeboxDelete<br/>timebox CHO_XOA, task về projection G04"]]
  start -->|"A1 · timebox liên kết sự kiện"| a1l["Chỉ gỡ liên kết<br/>không xoá sự kiện ngoài BR-21"]
  a1l --> a1m
  a1 --> a1m>"MSG-10 · Toast<br/>Đã gỡ #quot;{tiêu đề}#quot; khỏi lịch · Hoàn tác"]
  a1m --> a1ok(["Block ẩn khỏi lịch app<br/>job xoá sự kiện ngoài"])
  a1m -->|"Hoàn tác"| a1u[["Tạo lại timebox với giờ cũ"]]
```

**Nguồn nói:**
- `srs-g05:58` BR-21 (a): "không bao giờ đẩy ra lịch ngoài, không có `sync_status` đẩy"; (c): "Ctrl+X chỉ gỡ liên kết, không đụng sự kiện ngoài".
- `srs-g05:232` UC-04 A1: "toast MSG-10 có "Hoàn tác" (tạo lại timebox với giờ cũ). Timebox liên kết sự kiện: chỉ gỡ liên kết, không xoá sự kiện ngoài (BR-21)".

**Không ổn ở chỗ:** Nhánh `a1l` đã đúng ở bước đầu nhưng rồi nhập vào `a1m` và kết thúc ở `a1ok` "job xoá sự kiện ngoài" — mâu thuẫn với chính nhãn của nó. Nặng hơn: Hoàn tác đi qua `a1u` "Tạo lại timebox với giờ cũ"; nếu tạo lại như timebox thường thì timebox mới có `sync_status` và bị đẩy ra lịch, sinh một sự kiện trùng với cuộc họp gốc. SRS UC-04 A1 cũng chưa nói Hoàn tác của trường hợp liên kết làm gì, nên flow kế thừa lỗ hổng.

**Sửa:**
- Flow:
```mermaid
  a1l --> a1lm>"MSG-10 · Toast<br/>Đã gỡ #quot;{tiêu đề}#quot; khỏi lịch · Hoàn tác"]
  a1lm --> a1lok(["Task không còn timebox liên kết<br/>sự kiện ngoài giữ nguyên"])
  a1lm -->|"Hoàn tác"| a1lu[["TimeboxLink lại với sự kiện gốc<br/>không tạo timebox mới, không đẩy"]]
```
- SRS `srs-g05:232` thêm câu: "Hoàn tác của timebox liên kết: gọi \[TimeboxLink\] lại với `eventId` cũ (UC-10); không tạo timebox thường."

**Ai làm:** SRS rồi Flow.

---

#### G05-3 · UC-11 A3 "Dời task" với timebox liên kết: kết thúc không đúng — TB

**Flow đang vẽ** (`g05-lich-timebox.md:1056-1057`, kết thúc dùng chung `:1049`):
```text
  s1 -->|"A3 · timebox liên kết sự kiện"| a3["Popover chỉ có Dời task"]
  a3 --> p1
  ...
  ok(["Cờ bỏ"])
```
và happy case `:1020`: `ok(["Cờ Lệch ngày bỏ<br/>task và timebox cùng ngày"])`.

**Nguồn nói:**
- `srs-g05:492` UC-11 A3: "Timebox liên kết sự kiện | Chỉ có "Dời task" (BR-21)".
- `srs-g05:483` bước 3: "Dời task: đổi `startDate` như "kéo sang ngày khác" (QC-05)".
- `01-quy-tac-dung-chung.md:131`: với timebox liên kết, "ở mọi đường (đổi ngày, …) chỉ gỡ liên kết".

**Không ổn ở chỗ:** "Dời task" là đổi ngày task. Theo QC-05 và BR-21 (f), đổi ngày task có timebox liên kết thì timebox bị gỡ liên kết. Vậy sau khi bấm "Dời task sang {ngày timebox}", task sang ngày mới nhưng timebox liên kết biến mất; cờ mất vì không còn timebox, không phải vì "task và timebox cùng ngày" như ô kết thúc. Người dùng muốn gom task về đúng ngày cuộc họp lại mất liên kết với cuộc họp — trái mục đích của UC-11. SRS tự mâu thuẫn, flow chép đúng SRS.

**Sửa:**
- PO chốt một trong hai: (a) "Dời task" từ UC-11 là ngoại lệ của ngoại lệ: giữ liên kết (đề xuất mặc định, vì ngày mới chính là ngày của sự kiện); (b) giữ QC-05, sửa kết thúc A3 thành "task sang ngày sự kiện, timebox liên kết bị gỡ".
- Nếu (a): thêm vào QC-05 ngoại lệ câu "trừ "Dời task" của G05 UC-11: timebox liên kết giữ nguyên"; SRS UC-11 A3 ghi rõ. Flow: `a3` → nút riêng "Đổi startDate, giữ liên kết" → `p3`.
- Nếu (b): flow `a3` → `p1` → kết thúc riêng `a3f(["Task sang ngày sự kiện<br/>timebox liên kết bị gỡ, cờ mất"])`.

**Ai làm:** PO → SRS (QC-05 hoặc UC-11 A3) → Flow.

---

#### G05-4 · Thả task đã có timebox vào ngày khác / kéo một trong nhiều timebox: thiếu hệ quả Lệch ngày — TB

**Flow đang vẽ** (`g05-lich-timebox.md:281-282` UC-03; `:424-425` UC-04):
```text
  p1 -->|"A10 · task đã có timebox"| a10["Thêm timebox mới, giữ timebox cũ C19<br/>startDate theo BR-06, badge +n SCR-06"]
  a10 --> s2
  ...
  p1 -->|"A2 · kéo sang ngày khác"| a2[["startDate = workday(startsAt)<br/>G04 tính lại 2 ngày"]]
  a2 --> s1
```

**Nguồn nói:**
- `srs-g05:42` BR-05: "Một task có nhiều timebox; kéo task đã có timebox vào lịch → thêm timebox mới, không thay timebox cũ (C19)".
- `srs-g05:43` BR-06: "Kéo timebox sang giờ / ngày khác: `startDate` = `workday(startsAt)` của timebox vừa kéo".
- `srs-g05:59` BR-22: "Task `KE_HOACH` có timebox mà `workday(startsAt)` ≠ `startDate` → gắn cờ `LECH_NGAY` trên task và timebox … Tính lại cờ … khi đổi `startDate`, khi timebox đổi giờ".
- `01-quy-tac-dung-chung.md:120` dòng "Kéo sang ngày khác, chọn ngày": "Giữ giờ, dời sang ngày mới | Cập nhật theo".

**Không ổn ở chỗ:** Task có timebox ngày 5/11 được thả thêm vào lưới ngày 7/11 (A10 + A4) hoặc một trong hai timebox được kéo sang 7/11 (A2): `startDate` đổi thành 7/11 nhưng timebox cũ vẫn ở 5/11. Theo BR-22, timebox cũ và task lập tức mang cờ `LECH_NGAY`; sơ đồ kết thúc ở `s2`/`s1` không có cờ, designer sẽ không vẽ trạng thái card "+n" kèm nhãn Lệch ngày. Mặt khác, QC-05 nói đổi ngày task thì timebox "dời sang ngày mới" — nếu áp cho đường này thì timebox cũ phải nhảy theo, nhưng BR-05/BR-06 không nói thế. SRS G05 và QC-05 chưa khớp cho trường hợp nhiều timebox.

**Sửa:**
- PO chốt: khi `startDate` đổi vì thả / kéo **một** timebox, các timebox khác của task (a) đi theo ngày mới, giữ giờ (áp QC-05) hay (b) ở lại và gắn cờ Lệch ngày (áp BR-22). Đề xuất mặc định: (b), vì người dùng chủ động đặt từng khối; QC-05 bổ sung dòng ghi chú "kéo / thả timebox không phải đường đổi ngày task của bảng này; timebox khác theo BR-22".
- Flow (nếu b): sau `a10` và `a2` thêm `d{"Timebox khác ở ngày khác?"}` → `x11{{"→ UC-11"}}` với nhãn "cờ LECH_NGAY BR-22".
- SRS: BR-06 thêm câu "timebox khác của task không dời; nếu khác ngày thì gắn `LECH_NGAY` (BR-22)".

**Ai làm:** PO → SRS → Flow.

---

#### G05-5 · UC-08 điểm vào: kênh thông báo "Windows" không có nguồn — TB

**Flow đang vẽ** (`g05-lich-timebox.md:820`):
```text
  start(["Tài khoản CAN_KET_NOI_LAI<br/>SCR-01 chấm đỏ, thông báo trong app / Windows G12"])
```

**Nguồn nói:**
- `srs-g05:510` (điểm vào): "Banner "Cần kết nối lại" / thông báo (G12; ở app Windows là thông báo trong app và thông báo Windows, có từ 1.0 — D12)".
- `docs/review/quyet-dinh-chot-2026-11-04.md:235` D12: "Nhắc ritual và nhắc timer > 4 giờ bằng thông báo Windows và trong app, từ 1.0".
- `docs/features/prd-g12-workspace-billing.md:137`: "Lịch / tích hợp mất kết nối | Người đã kết nối | Trong app + email | 1.0 (lịch), 1.1 (tích hợp) | G05, G11".

**Không ổn ở chỗ:** Flow chép đúng SRS G05 §6, nhưng SRS dẫn D12 sai phạm vi: D12 chỉ chốt hai sự kiện (ritual, timer > 4 giờ). Bảng thông báo của G12 — nhóm sở hữu kênh — ghi kênh của "lịch mất kết nối" là trong app + email. Designer sẽ vẽ một thông báo Windows không có trong đặc tả G12 và bỏ sót email.

**Sửa:**
- SRS `srs-g05:510` sửa thành "thông báo trong app + email (G12, bảng sự kiện × kênh)".
- Flow: nhãn `start` đổi thành "SCR-01 chấm đỏ, thông báo trong app + email G12 · UC-09"; thêm nút `{{"→ G12 · UC-09"}}`.
- Nếu PO muốn thêm kênh Windows cho sự kiện này thì mở rộng D12 và sửa bảng G12 trước.

**Ai làm:** SRS rồi Flow.

---

#### G05-6 · UC-01 từ onboarding không có đường quay về — TB

**Flow đang vẽ** (`g05-lich-timebox.md:32, 42, 90`):
```text
  start(["SCR-01 Cài đặt → Lịch<br/>hoặc onboarding bước Kết nối lịch · G01"])
  ...
  ok(["SCR-01 tài khoản Đã kết nối + giờ đồng bộ<br/>lịch chính hiển thị, là lịch ghi mặc định"])
  ...
  e1m -.-> fail(["Về SCR-01, không có tài khoản mới<br/>trạng thái cũ giữ nguyên"])
```

**Nguồn nói:**
- `srs-g05:112` bước 6: "Mở **SCR-02** của tài khoản; toast MSG-01"; `srs-g05:127` E1: "Về SCR-01, MSG-03".
- `g01-tai-khoan.md:511-513`: `s2["SCR-05 bước 2 · kết nối lịch"]` → `x1{{"→ G05 · UC-01<br/>kết nối qua trình duyệt hệ thống BR-25"}}`; `:564`: `x1 -.->|"E1 · kết nối lịch lỗi / bị từ chối quyền"| e1["SCR-05 bước 2, thông báo của G05<br/>vẫn Tiếp hoặc Bỏ qua được"]`.
- `docs/design-brief/00-kien-truc-thong-tin.md:214` IA-12: "Đăng nhập và onboarding toàn cửa sổ, không có sidebar"; `:206` IA-04: "Cài đặt là lớp phủ gần kín cửa sổ".

**Không ổn ở chỗ:** Điểm vào thứ hai là onboarding (màn toàn cửa sổ, chưa có khung app), nhưng mọi kết thúc đều ở SCR-01 / SCR-02 là trang trong lớp phủ Cài đặt. G01 vẽ là sau khi G05 xong (hoặc lỗi) thì quay về SCR-05 bước 2. Hai file không khớp; designer sẽ không biết sau OAuth từ onboarding thì người dùng đứng ở đâu, và SCR-02 (chọn lịch) có hiện trong onboarding không.

**Sửa:**
- SRS bước 6 (`srs-g05:112`) thêm: "Từ onboarding: không mở SCR-02, về G01 SCR-05 bước 2 với trạng thái "Đã kết nối {email}"; E1–E5 về bước 2 với thông báo tương ứng."
- Flow: thêm nút `d0{"Điểm vào?"}` sau `p4`: "Cài đặt" → `ok`; "onboarding" → `okob{{"→ G01 · UC-05 SCR-05 bước 2"}}`; nhánh `fail` cũng rẽ về G01 khi vào từ onboarding.

**Ai làm:** SRS rồi Flow.

---

#### G05-7 · UC-01 E4 giới hạn số tài khoản: không có nguồn giới hạn ở 1.0 — TB (cần PO xác nhận)

**Flow đang vẽ** (`g05-lich-timebox.md:82-83`):
```text
  start -.->|"E4 · đã đủ số tài khoản tối đa BR-01"| e4["SCR-01 nút kết nối disabled"]
  e4 -.-> e4m>"MSG-05 · Inline<br/>Đã đạt tối đa {n} tài khoản lịch"]
```

**Nguồn nói:**
- `srs-g05:38` BR-01: "Số tài khoản tối đa / người dùng đọc từ bảng quyền theo gói (QC-10), không viết cứng; giá trị 5 `[giả định]`".
- `srs-g05:5`: "quyền theo gói (QC-10, 1.1)".
- `docs/features/srs-g12-workspace-billing.md:58` BR-24: "**Quyền theo gói (1.1).** G12 sở hữu bảng cấu hình quyền theo gói (QC-10), chỉ gồm: số tài khoản lịch kết nối (G05)".
- `docs/features/prd-g05-lich-timebox.md:370`: "Còn mở: bản 1.0 (miễn phí, không giới hạn) có áp giới hạn kỹ thuật này không?"

**Không ổn ở chỗ:** Nguồn duy nhất của con số giới hạn là bảng QC-10, mà bảng này chỉ có từ 1.1. Ở 1.0 không có gói nào, nên E4 không có cách nào xảy ra trừ khi tech viết cứng. Flow vẽ trạng thái nút disabled + MSG-05 mà designer có thể vẽ vô ích, hoặc ngược lại tech sẽ hiểu phải tạo bảng quyền sớm.

**Sửa:**
- PO chốt: 1.0 có giới hạn kỹ thuật không? Đề xuất mặc định: không; E4 ghi "Bỏ (1.1)" ở bảng đối chiếu, bỏ hai nút khỏi sơ đồ; SRS BR-01 thêm "1.0: không giới hạn (Q10)".
- Nếu có: SRS BR-01 ghi con số cố định cho 1.0 và nguồn (không phải QC-10); flow giữ nguyên.

**Ai làm:** PO → SRS → Flow.

---

#### G05-8 · Nhãn "Lệch ngày" trên card: G04 và G05 đặc tả hai kiểu — TB

**Flow đang vẽ** (`g05-lich-timebox.md:1011-1014`):
```text
  start(["Nhãn Lệch ngày trên card,<br/>SCR-05 block hoặc SCR-06 chi tiết task"])
  u1[/"Bấm nhãn Lệch ngày"/]
  s1["SCR-06 popover Lệch ngày"]
  m1>"MSG-30 · Popover<br/>Lệch ngày: timebox ở {ngày timebox}, task ở {ngày dự định}<br/>· Dời task sang {ngày timebox} · Dời timebox về {ngày dự định}"]
```
Trong khi `g04-board-ngay.md:84` (và `:302`): `a8m>"MSG-26 · Tooltip<br/>Lệch ngày: timebox ở {ngày timebox}, task dự định {ngày dự định}. Dời task hoặc dời timebox"]` — kết thúc ở tooltip, không nối đi đâu.

**Nguồn nói:**
- `srs-g05:59` BR-22: "Người dùng chọn: "Dời task sang {ngày timebox}" … hoặc "Dời timebox về {ngày dự định}"… Chỉ banner MSG-23 của G01 thông báo đổi timezone; G05 không có banner riêng".
- `srs-g05:581` SCR-06 #5: ""Lệch ngày" | Badge + popover | MSG-30, hai lựa chọn của UC-11".
- `srs-g04:60` BR-24: "card hiện cờ "Lệch ngày", tooltip MSG-26. Hệ thống không tự sửa; người dùng tự dời task hoặc dời timebox".

**Không ổn ở chỗ:** Cùng một nhãn trên card có hai hành vi: G04 cho tooltip chỉ nhắc "dời task hoặc dời timebox" mà không có nút; G05 cho popover với hai nút hành động. Chữ hai MSG gần giống nhưng khác nhau. Designer của G04 sẽ vẽ card dừng ở tooltip, designer của G05 vẽ popover; không ai biết cái nào đúng. Flow G05 đúng với chủ sở hữu quy tắc (BR-22 thuộc G05), nhưng flow G04 chưa nối sang.

**Sửa:**
- SRS G04 BR-24 (`srs-g04:60`): thay "tooltip MSG-26" bằng "bấm → G05 UC-11 (popover MSG-30)"; bỏ MSG-26 hoặc giữ làm tooltip hover với chữ y hệt MSG-30 phần đầu.
- Flow G04 `:84, 302`: sau `a8m` thêm `{{"→ G05 · UC-11"}}`.
- Flow G05: giữ; ở ghi chú brief ghi rõ G05 sở hữu nhãn.

**Ai làm:** SRS (G04) rồi Flow (G04).

---

#### G05-9 · UC-10 E1 trỏ sang nhánh không có trong flow G08 — TB

**Flow đang vẽ** (`g05-lich-timebox.md:972-974`):
```text
  p2 -.->|"E1 · sự kiện không còn / tài khoản CAN_KET_NOI_LAI"| e1[["EVENT_NOT_FOUND"]]
  e1 -.-> e1x{{"→ G08 · UC-01 tạo task không có timebox"}}
  e1x -.-> fail(["Task không có timebox liên kết"])
```
Bên G08 (`g08-daily-rituals.md:36`): `p3[["TaskCreate G02, TaskMove G06, TimeboxLink G05, BR-07<br/>day.recomputed G04<br/>RitualUpdate current_step = 3"]]` — là nút xử lý trong happy case; sơ đồ nhánh `g08:196-215` không có nút sang G05 UC-10 và không có nhánh "TimeboxLink lỗi".

**Nguồn nói:**
- `srs-g05:467` UC-10 E1: "`EVENT_NOT_FOUND`; G08 tạo task không có timebox `[giả định]`".
- `_quy-uoc.md:22`: "Flow liên tính năng | Vẽ ở file của tính năng **khởi phát**. File khác chỉ có nút "sang flow khác" trỏ tới đó".

**Không ổn ở chỗ:** G08 là tính năng khởi phát (kéo sự kiện thành task), nên theo quy ước G08 phải có nút sang G05 UC-10 và nhánh xử lý khi link lỗi. Hiện G05 trỏ ngược về một nhánh G08 chưa vẽ; designer mở G08 sẽ không thấy trạng thái "task vừa tạo từ cuộc họp nhưng không có khối giờ" và không biết có thông báo gì. SRS G08 cũng chưa có chữ cho trường hợp này.

**Sửa:**
- Flow G08 (sơ đồ nhánh UC-01 bước 2): thêm `p3 --> x10{{"→ G05 · UC-10 TimeboxLink"}}` và `x10 -.->|"E · EVENT_NOT_FOUND"| e10["Task tạo xong, không có timebox<br/>MSG chưa có mã"]`.
- SRS G08 UC-01: thêm nhánh lỗi tương ứng và MSG (ví dụ "Không liên kết được với sự kiện, task vẫn được tạo"); bỏ `[giả định]` ở G05 UC-10 E1 sau khi G08 chốt.
- Flow G05: giữ, đổi nhãn `e1x` thành "→ G08 · UC-01 nhánh TimeboxLink lỗi" khi G08 đã có.

**Ai làm:** SRS (G08) rồi Flow (G08).

---

#### G05-10 · UC-04 A4/A5 thiếu hai ý của BR-17 — Thấp

**Flow đang vẽ** (`g05-lich-timebox.md:461-463`):
```text
  g02c(["G02 · UC-03 hoàn thành task"]) -->|"A4 · thời điểm xong trong startsAt – endsAt<br/>bật Tự dời khi xong sớm"| a4[["Rút endsAt = thời điểm xong làm tròn lên 5 phút<br/>cập nhật sự kiện BR-17"]]
  g02c -->|"A4 · ngoài khoảng hoặc tắt"| a4n(["Timebox giữ nguyên"])
  g02d(["G02 · UC-04 xoá task"]) -->|"A5"| a5[["Theo dòng Xoá QC-05"]]
```

**Nguồn nói** (`srs-g05:54` BR-17): "Bỏ hoàn thành trong cùng ngày làm việc → trả `endsAt` cũ (QC-03 mục 4)… Hoàn tác trên toast khôi phục liên kết (BR-25); khôi phục từ Thùng rác không tạo lại timebox".

**Không ổn ở chỗ:** Hai trạng thái người dùng thấy bị bỏ: (1) bỏ hoàn thành cùng ngày thì khối giờ dài lại như cũ và sự kiện ngoài được cập nhật lại; (2) khôi phục task từ Thùng rác thì task về mà **không** có khối giờ (khác với Hoàn tác trên toast). Designer sẽ không vẽ trạng thái "task khôi phục, mục Timebox trống" trong SCR-06.

**Sửa:** Flow thêm:
```mermaid
  g02c -->|"A4 · bỏ hoàn thành cùng ngày làm việc QC-03"| a4u[["Trả endsAt cũ, cập nhật sự kiện"]]
  a4u --> x6
  g02d -->|"A5 · khôi phục từ Thùng rác"| a5r(["Task về, không tạo lại timebox<br/>SCR-06 mục Timebox trống"])
```
Bảng đối chiếu A4/A5 ghi thêm hai dòng này.

**Ai làm:** Flow.

---

#### G05-11 · UC-08 kết nối lại thiếu nhánh huỷ OAuth / `state` sai — Thấp

**Flow đang vẽ** (`g05-lich-timebox.md:850, 864-865`):
```text
  p1[["OAuth, CalendarCallback"]]
  ...
  p1 -.->|"E1 · vẫn thiếu scope"| e1m>"MSG-02 · Inline<br/>…"]
  e1m -.-> e1(["Giữ CAN_KET_NOI_LAI"])
```

**Nguồn nói:**
- `srs-g05:383` UC-08 bước 2: "Như bước 2–4 UC-01 với cùng tài khoản (A1 UC-01)".
- `srs-g05:127, 131` UC-01 E1: "Người dùng huỷ ở màn OAuth | Về SCR-01, MSG-03"; E5: "`state` sai / callback quá 10 phút | Huỷ, MSG-21".

**Không ổn ở chỗ:** Bước 2 chạy lại toàn bộ OAuth của UC-01, nên người dùng cũng có thể huỷ ở trang OAuth hoặc callback hết hạn. Flow UC-08 chỉ vẽ E1 thiếu scope; designer sẽ không có trạng thái "huỷ kết nối lại, banner vẫn còn" và không biết dùng MSG-03 hay MSG-21.

**Sửa:** Flow thêm `p1 -.->|"huỷ OAuth / state sai · như UC-01 E1, E5"| e01x{{"→ UC-01 E1, E5"}}` và `e01x -.-> e1` (giữ `CAN_KET_NOI_LAI`, banner SCR-09 còn). Bảng đối chiếu thêm dòng "(UC-01 E1/E5) | huỷ hoặc hết hạn | giữ CAN_KET_NOI_LAI | MSG-03 / MSG-21".

**Ai làm:** Flow.

---

#### G05-12 · UC-08 A5 điểm vào sai màn — Thấp

**Flow đang vẽ** (`g05-lich-timebox.md:861`):
```text
  start5(["SCR-01 · kết nối lại tài khoản đã ngắt DA_NGAT"]) -->|"A5"| a5[["Như UC-01; sự kiện mồ côi bị bỏ qua<br/>không liên kết lại timebox CHI_TRONG_APP"]]
```

**Nguồn nói:**
- `srs-g05:76` bảng 4.1: "`DA_NGAT` | Người dùng ngắt kết nối (BR-19) | Không còn trong danh sách".
- `srs-g05:524` SCR-01 #3: ""Kết nối lại" | Button | Chỉ hiện khi `CAN_KET_NOI_LAI`".
- `srs-g05:395` A5: "Kết nối lại một tài khoản đã ngắt trước đó (`DA_NGAT`) | Như UC-01".

**Không ổn ở chỗ:** Tài khoản `DA_NGAT` không hiện trong SCR-01 và không có nút "Kết nối lại"; người dùng chỉ có thể bấm "Kết nối Google Calendar / Outlook" (UC-01) rồi chọn cùng email. Nhãn hiện tại gợi ý designer vẽ một dòng tài khoản đã ngắt với nút kết nối lại — màn không tồn tại.

**Sửa:** Đổi nhãn `start5` thành "SCR-01 · bấm Kết nối Google / Outlook, chọn lại email đã ngắt (UC-01)"; nhãn cạnh A5 giữ, nút `a5x` giữ "→ UC-01".

**Ai làm:** Flow.

---

### Ghi chú cho brief — cần thêm vào `g05-lich-timebox.md` (mục "Ghi chú cho brief G05")

Dán các dòng sau; dòng hiện có ở `:1108` thay bằng dòng đầu tiên.

- (thay `:1108`) Timebox liên kết sự kiện khi task đổi ngày / xoá / vào backlog: QC-05 (ngoại lệ, dòng 131) và BR-21 (f) đã quyết "chỉ gỡ liên kết, không dời, không xoá sự kiện ngoài". G04 BR-09 còn giả định "giữ liên kết, gắn cờ Lệch ngày" là chỗ sai cần sửa theo QC-05. Sơ đồ UC-04 A5 / A7 / A8 và A1 đã (sẽ) tách nhánh riêng cho loại này; Hoàn tác của A1 với timebox liên kết phải gọi lại `TimeboxLink`, không tạo timebox thường.
- UC-11 A3 "Dời task" với timebox liên kết: đổi ngày task thì theo QC-05 timebox liên kết bị gỡ, nên cờ mất vì timebox mất, không phải "task và timebox cùng ngày". Cần PO chốt: miễn trừ đường này (giữ liên kết) hay sửa kết thúc A3.
- UC-03 A10 (thả task đã có timebox vào ngày khác) và UC-04 A2 (kéo một trong nhiều timebox sang ngày khác): `startDate` đổi theo timebox vừa đặt, timebox cũ ở ngày khác sẽ mang cờ `LECH_NGAY` (BR-22). QC-05 "kéo sang ngày khác" lại nói timebox đi theo task. Cần PO chốt timebox khác của task đi theo hay ở lại; sơ đồ sẽ nối sang UC-11 khi chốt.
- UC-08 điểm vào: SRS §6 ghi "thông báo trong app và thông báo Windows (D12)" nhưng D12 chỉ chốt cho ritual và timer > 4 giờ; bảng thông báo G12 ghi "Lịch mất kết nối: trong app + email". Brief dùng trong app + email, sửa SRS §6.
- UC-01 vào từ onboarding (G01 SCR-05 bước 2, toàn cửa sổ) nhưng SRS bước 6 / E1 chỉ nói mở SCR-02 / về SCR-01 (Cài đặt). Cần SRS bổ sung "từ onboarding thì về bước 2 của G01"; sơ đồ sẽ thêm kết thúc này.
- Nhãn "Lệch ngày" trên card: G04 BR-24 cho tooltip MSG-26 không có hành động; G05 SCR-06 #5 / UC-11 cho popover MSG-30 hai lựa chọn. G05 sở hữu (BR-22); G04 BR-24 nên trỏ sang G05 UC-11.
- UC-10 E1 trỏ "→ G08 · UC-01 tạo task không có timebox" nhưng flow và SRS G08 chưa có nhánh này. G08 là tính năng khởi phát nên phải vẽ nút sang G05 UC-10 và nhánh lỗi, kèm MSG.
- UC-01 E4 (đủ số tài khoản) dựa trên bảng quyền theo gói QC-10 chỉ có từ 1.1; ở 1.0 chưa có nguồn giới hạn. Cần PO chốt có giới hạn kỹ thuật ở 1.0 không; mặc định đề xuất "Bỏ (1.1)".


---

## G06 Backlog, rollover, lưu trữ (`docs/design-brief/flow/g06-backlog-rollover.md`)

Số # trùng bảng mục 3 của `docs/review/review-flow-vs-srs-2026-11-05.md`. Viết tắt: `g06` = file flow; `srs-g06` = `docs/features/srs-g06-backlog-rollover.md`; `srs-g04` = `docs/features/srs-g04-board-ngay.md`; `QC` = `docs/01-quy-tac-dung-chung.md`; `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`.

---

#### G06-1 · UC-07 A2/A3: rollover tạm không được trả lại khi `CHO_SHUTDOWN`; thiếu nhánh `THAT_BAI` — TB

**Flow đang vẽ** (`g06-backlog-rollover.md:749-751`):
```text
  p1 -->|"A2 · trong lúc chờ phản hồi"| a2["Board hiện rollover tạm trên máy<br/>chỉ hiển thị QC-08 mục 5"]
  a1r -->|"A2"| a2
  d1 -->|"A3 · CHO_SHUTDOWN"| a3(["Trả CHO_SHUTDOWN, waitUntil = mốc + 2 giờ<br/>task ngày cũ ở cột ngày cũ"])
```
Thoi `d1` ở `:719` chỉ liệt kê "CHO, LOI, THAT_BAI, chưa có bản ghi, DANG_CHAY hết lease" là ca chạy trong request; không có nhánh cho response `status = THAT_BAI`.

**Nguồn nói:**
- `srs-g06:351` A2: "Trong lúc chờ phản hồi hoặc khi trả `DANG_CHAY` | Board hiện rollover tạm trên máy, chỉ để hiển thị".
- `srs-g06:352` A3: "`CHO_SHUTDOWN` … task ngày cũ hiển thị ở cột ngày cũ".
- `srs-g06:98-99` bảng 4.2: `CHO` → "Board hiện rollover tạm trên máy (UC-07 A2)"; `CHO_SHUTDOWN` → "Task ngày cũ ở yên cột ngày cũ".
- `srs-g06:459` API: "`{date, status: XONG | DANG_CHAY | CHO_SHUTDOWN | DONG_BANG | THAT_BAI, …}` … client không tự retry khi nhận `THAT_BAI`".

**Không ổn ở chỗ:** A2 cho board hiện rollover tạm **ngay khi gửi request** (trước khi biết trạng thái). Nếu server trả `CHO_SHUTDOWN`, nút `a3` kết thúc ở "task ngày cũ ở cột ngày cũ" nhưng không có bước "bỏ rollover tạm đã hiện" — người dùng vừa thấy task nhảy sang hôm nay rồi phải nhảy ngược về hôm qua. Designer cần vẽ chuyển trạng thái này (hoặc tốt hơn: không hiện tạm cho tới khi có phản hồi). Response `status = THAT_BAI` (job đã hỏng 3 lần, request này cũng không chạy được) không có nhánh nào; flow chỉ bắt `ROLLOVER_FAILED` ở E1. Ghi chú 3 của file đã nêu chỗ mơ hồ, nhưng sơ đồ chưa vẽ.

**Sửa:**
- Flow: đổi `a3` thành `a3[["Trả CHO_SHUTDOWN, waitUntil = mốc + 2 giờ<br/>bỏ rollover tạm nếu đã hiện; task ngày cũ ở cột ngày cũ"]]` → `a3e(["Board: cột ngày cũ còn task, hôm nay chưa có<br/>chờ ritual.shutdown.closed hoặc waitUntil"])` → `a3x{{"→ G08 · UC-02"}}`. Thêm nhánh `d1 -->|"A6 · THAT_BAI, request cũng lỗi"| e1m` (dùng chung banner lỗi, xem G06-2).
- SRS: `srs-g06:351` A2 sửa "Trong lúc chờ phản hồi" thành "Khi trả `DANG_CHAY`, hoặc trong lúc chờ nếu lượt gần nhất không phải `CHO_SHUTDOWN`"; bảng API `:459` ghi rõ khi nào trả `status = THAT_BAI` (request chạy bù mà vẫn lỗi) và client hiện gì.
- PO chốt: `status = THAT_BAI` hiện banner như `ROLLOVER_FAILED`? Mặc định: có, cùng banner G04 MSG-27, cùng nút "Thử lại".

**Ai làm:** SRS rồi Flow (PO chốt `THAT_BAI`).

---

#### G06-2 · Banner rollover lỗi có hai mã (UC-07 E1: G06 MSG-25 so với G04 MSG-27); ghi chú 2 hỏi điều IA đã chốt — TB

**Flow đang vẽ** (`g06-backlog-rollover.md:755-757`; ghi chú `:796`):
```text
  p3 -.->|"E1 · chạy trong request lỗi"| e1[["Rollback, tăng số lần lỗi BR-18<br/>trả ROLLOVER_FAILED"]]
  e1 -.-> e1m>"MSG-25 · Banner<br/>Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại"]
  e1m -.->|"Thử lại"| p1
- Lỗi `ROLLOVER_FAILED` có hai thông báo cùng chữ: G06 MSG-25 (UC-07 E1) và G04 MSG-27 … Cần chốt nhóm nào sở hữu banner trên board.
```

**Nguồn nói:**
- `srs-g06:360` E1: "trả `ROLLOVER_FAILED` → MSG-25 có "Thử lại"". `srs-g06:504` MSG-25 | Banner | "Chưa chuyển được việc dở từ hôm trước sang hôm nay. Thử lại".
- `srs-g04:583` MSG-27 | Banner | cùng chữ. `srs-g04:61` BR-25: "Kết quả lỗi: banner MSG-27 có "Thử lại"".
- `srs-g04:435` SCR-01 #5: "thứ tự ưu tiên: offline → … → rollover lỗi (MSG-27) → lệch timezone".
- `IA:70` mục 3 Banner: "3. Rollover lỗi (G04 MSG-27)".

**Không ổn ở chỗ:** Banner nằm trên Home, do G04 sở hữu vùng banner (SCR-01 #5) và IA mục 3 đã ghi đích danh "G04 MSG-27". G06 là API, không có màn riêng (UC-07 "Không có màn riêng", `g06:16`), nên không nên tự khai một banner trùng chữ. Hai mã cho một banner làm designer có thể vẽ hai lần, và khi đổi chữ sẽ chỉ đổi một chỗ. Ghi chú 2 của file viết "cần chốt nhóm nào sở hữu" là không đúng: IA đã chốt ngày 04/11/2026 và IA thắng SRS theo chính câu đầu của IA ("chỗ nào SRS còn ghi khác thì sửa ngược").

**Sửa:**
- Flow: `e1m` đổi thành `e1x{{"→ G04 · UC-01 E4 · banner MSG-27"}}` class `link`; cạnh "Thử lại" vẽ ở G04. Bảng E1: "Rollback → banner G04 MSG-27 [G04 UC-01 E4]". Ghi chú 2 viết lại (xem cuối file).
- SRS: `srs-g06:360` E1 đổi "→ MSG-25" thành "→ banner G04 MSG-27 (G04 BR-25, IA-17)"; `srs-g06:504` MSG-25 đổi thành "(Bỏ — dùng G04 MSG-27)"; bảng map lỗi `:472` sửa theo.

**Ai làm:** SRS rồi Flow.

---

#### G06-3 · Câu lỗi TaskMove / TaskRestore khác G04 cho cùng mã lỗi (UC-01 E2/E3/E5, UC-03 E1/E3/E4, UC-06 E1/E2/E4) — TB

**Flow đang vẽ** (`g06-backlog-rollover.md:102-107`, `:317-321`, `:659-664`):
```text
  e5m>"MSG-23 · Toast<br/>Task đã thay đổi trên thiết bị khác"]
  e2m>"MSG-20 · Toast<br/>Task này không còn tồn tại"]
  e3m>"MSG-17 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e3m>"MSG-24 · Toast<br/>Không thể đặt task chưa xong vào ngày đã qua"]
```
G04 cho cùng mã lỗi của cùng API (`g04-board-ngay.md:341, 347, 350, 355`): MSG-09 "Không thể chuyển task chưa xong về ngày đã qua"; MSG-17 "Task đã thay đổi trên thiết bị khác, đã cập nhật lại"; MSG-14 "Task này đã bị xoá"; MSG-15 "Chưa tải / lưu được thay đổi. Thử lại".

**Nguồn nói:**
- `srs-g06:496, 499, 502, 503`: MSG-17 "Chưa lưu được thay đổi. Thử lại"; MSG-20 "Task này không còn tồn tại"; MSG-23 "Task đã thay đổi trên thiết bị khác"; MSG-24 "Không thể đặt task chưa xong vào ngày đã qua".
- `srs-g04:565, 570, 571, 573`: MSG-09, MSG-14, MSG-15, MSG-17 như trên.
- `QC:159` QC-08 mục 2: "người dùng thấy "Task đã thay đổi trên thiết bị khác"".
- `docs/design-brief/flow/_quy-uoc.md:123`: "Nhánh giống nhau ở nhiều UC (mất mạng, `VERSION_CONFLICT`, task bị xoá ở thiết bị khác) … nhãn phải giống hệt nhau."

**Không ổn ở chỗ:** Flow G06 chép đúng SRS G06, và chữ của G06 khớp QC-08. Vấn đề là G04 đặt chữ khác cho cùng mã lỗi; kéo task từ panel Backlog ra board (G06 UC-03) và kéo task giữa hai cột (G04 UC-03) xảy ra trên cùng một màn Home, cùng API `TaskMove`, nhưng gặp `VERSION_CONFLICT` thì một bên "…khác", một bên "…khác, đã cập nhật lại". Designer vẽ 8 toast thay vì 4. Nguồn thắng: QC-08 (chữ của G06).

**Sửa:**
- SRS: đặt bộ câu chung ở QC-08 (hoặc G02, nhóm sở hữu `PAST_DATE` / `TASK_DELETED`), lấy chữ của G06. Sửa SRS G04 (`srs-g04:565, 570, 573`) theo đó; G06 giữ nguyên.
- Flow G06: không đổi; sau khi G04 sửa thì hai file có nhãn giống hệt. Thêm vào ghi chú brief để designer biết đây là một bộ toast dùng chung.

**Ai làm:** SRS (G04) rồi Flow (G04); G06 ghi chú.

---

#### G06-4 · Phím S / D trên task backlog: G06 UC-03 A1 so với G04 UC-03 A1 — TB

**Flow đang vẽ** (`g06-backlog-rollover.md:305, 309`):
```text
  start -->|"A1 · phím S"| a1["startDate = hôm nay"]
  p1 -->|"A1 / A2"| m3>"MSG-03 · Toast<br/>Đã chuyển #quot;{tiêu đề}#quot; sang {ngày} · Hoàn tác"]
```
G04 cho cùng phím S trên task backlog (`g04-board-ngay.md:290, 293`): `start2(["Task đang chọn / hover"]) -->|"A1 · phím D / lệnh Hoãn 1 tuần / phím S"| …` → `a1s>"MSG-07 · Toast<br/>Đã chuyển về hôm nay · Hoàn tác"]`.

**Nguồn nói:**
- `srs-g06:206` UC-03 A1: "Phím S trên task backlog | `startDate` = hôm nay; toast MSG-03".
- `srs-g04:197` UC-03 tiền điều kiện: "Task ở `KE_HOACH`, `BACKLOG` hoặc `HOAN_THANH`"; `srs-g04:214` A1: "Phím D / lệnh "Hoãn 1 tuần" / phím S | … toast MSG-05 / MSG-06 / MSG-07".
- `srs-g04:46` BR-10: "task backlog: ngày làm việc kế tiếp theo lịch của task của hôm nay (C15, QC-05)" — quy tắc riêng cho phím **D** trên task backlog.

**Không ổn ở chỗ:** Hai UC cùng sở hữu "S trên task backlog" với hai toast khác chữ (MSG-03 "Đã chuyển "{tiêu đề}" sang {ngày}" và MSG-07 "Đã chuyển về hôm nay"). Phím D trên task backlog có quy tắc riêng ở G04 BR-10 nhưng không có trong G06 UC-03 (SRS lẫn flow), còn G04 A1 gom chung với task có ngày. Designer panel Backlog không biết D có chạy không, ra ngày nào, toast gì.

**Sửa:**
- SRS: chốt G06 UC-03 sở hữu mọi đường "task backlog ra ngày" (G06 sở hữu QC-05 và trạng thái `BACKLOG`). `srs-g06:206` thêm dòng "Phím D trên task backlog | `startDate` = ngày làm việc kế tiếp của hôm nay theo lịch của task (G04 BR-10, C15); toast MSG-03". `srs-g04:197` bỏ `BACKLOG`; `srs-g04:214` thêm "task backlog → G06 UC-03".
- Flow G06: thêm `start -->|"A1 · phím D"| a1d["startDate = ngày làm việc kế tiếp của hôm nay<br/>theo lịch của task BR-10 G04"]` → `p1`; bảng A1 ghi "S: hôm nay; D: ngày làm việc kế tiếp | MSG-03".
- Flow G04: `start2` thêm nhãn "task Kế hoạch"; thêm `start2 -->|"A1 · task backlog"| {{"→ G06 · UC-03"}}`.

**Ai làm:** SRS rồi Flow.

---

#### G06-5 · Điểm kéo task vào / ra backlog lệch IA (UC-01 A2, UC-03 bước 1) — TB, cần PO xác nhận

**Flow đang vẽ** (`g06-backlog-rollover.md:275` UC-03; `:66` UC-01 A2):
```text
  u1[/"Kéo task vào cột ngày D<br/>ở panel ngày SCR-01 hoặc board G04"/]
  start2(["Board · task card"]) -->|"A2 · kéo vào trang / panel Backlog"| a2["Thả vào bucket hoặc folder nào<br/>thì chuyển vào đó"]
```

**Nguồn nói:**
- `srs-g06:198` UC-03 bước 1: "Kéo task từ SCR-01 vào cột ngày D ở panel ngày bên phải (hoặc board, G04)"; `srs-g06:390` SCR-01 #8: "Panel ngày | Cột ngày (G04) | Mặc định hôm nay, ‹ › đổi ngày; thả task → UC-03".
- `srs-g06:133` UC-01 A2: "Kéo task vào trang / panel Backlog".
- `IA:62` vùng chính: "Trang Backlog | B; sidebar | Khác panel Backlog ở panel phải: trang đầy đủ có folder, bucket".
- `IA:83` panel phải: "Backlog | Shift+B | Panel Backlog gọn, kéo task ra board".
- `IA:77` "App nhớ trên máy panel đang mở hay đóng và đang ở mục nào".

**Không ổn ở chỗ:** Theo IA, trang Backlog (SCR-01) chiếm **vùng chính**, tức board không còn trên màn; không thể kéo từ SCR-01 "hoặc board G04". Chiều ngược lại cũng vậy: kéo card từ board vào "trang Backlog" là bất khả, chỉ kéo được vào **panel** Backlog (Shift+B). Flow và SRS gộp hai bề mặt làm một, designer sẽ vẽ một màn vừa có trang Backlog vừa có board. "Panel ngày bên phải" của SCR-01 #8 là một cột ngày nằm trong trang Backlog — IA mục 4 chỉ liệt kê Calendar / Tasks / Backlog / Lưu trữ / Search / Trợ lý ở panel phải, không có "panel ngày"; IA-02 giữ trang Backlog riêng với panel Backlog nhưng không nói trang có cột ngày. Ghi chú cuối file (`g06:805`) đã nêu một nửa (panel gọn dùng màn nào), chưa nêu "panel ngày".

**Sửa:**
- PO xác nhận: SCR-01 #8 "panel ngày" còn giữ không? Mặc định đề xuất: bỏ; cách đưa task ra ngày khi đang ở trang Backlog là S / menu Ngày dự định; kéo thả ra ngày dùng panel Backlog (Shift+B) trên Home.
- Flow UC-03: tách `u1` thành hai điểm vào: `start(["Home · panel Backlog Shift+B · task Backlog"])` → kéo vào cột ngày trên board; và (nếu PO giữ) `start2(["SCR-01 Trang Backlog · task Backlog"])` → kéo vào panel ngày SCR-01 #8. UC-01 A2 đổi nhãn thành "A2 · kéo vào panel Backlog (Shift+B)".
- SRS: `srs-g06:198`, `:133`, `:390` sửa theo quyết định PO; UC-02 thêm mô tả panel Backlog gọn (màn nào, có folder không).

**Ai làm:** PO rồi SRS rồi Flow.

---

#### G06-6 · UC-04 thiếu phần timebox của instance `skipped`, và chỉ trỏ G03 UC-06 bằng chữ — TB

**Flow đang vẽ** (`g06-backlog-rollover.md:369, 373`):
```text
  p3[["Lấy task Kế hoạch có startDate < hôm nay BR-06<br/>nhóm instance lặp theo series, áp BR-11 trước<br/>xem G03 UC-06"]]
  p7[["Phát task.upserted, day.recomputed<br/>G05 gỡ liên kết timebox quá khứ, bất đồng bộ"]]
```
Flow G03 (`docs/design-brief/flow/g03-task-lap-lai.md:581` "## UC-06 Xử lý instance trùng series trong một ngày (QC-06; rollover G06, phím D G04, shutdown G08)") vẽ lại toàn bộ job rollover với điểm vào "Job rollover G06 lúc mốc đầu ngày".

**Nguồn nói:**
- `srs-g06:47` BR-11: "Timebox, sự kiện ngoài, timer của instance `skipped` theo dòng "lưu trữ do trùng series (`skipped`)" của QC-05, tức như "Đưa vào backlog" (D6): timebox tương lai bị gỡ và sự kiện ngoài bị xoá; timebox quá khứ chỉ gỡ liên kết, sự kiện giữ".
- `srs-g06:239` UC-04 bước 7: "gửi G05 yêu cầu gỡ liên kết timebox quá khứ (bất đồng bộ, không xoá sự kiện ngoài); task vừa lưu trữ (`stale`, `skipped`) xử lý timebox như "Đưa vào backlog" (BR-11, BR-12; Q42, D6)".
- `docs/design-brief/flow/_quy-uoc.md:22`: "Flow liên tính năng | Vẽ ở file của tính năng **khởi phát**. File khác chỉ có nút "sang flow khác" trỏ tới đó".

**Không ổn ở chỗ:** Bước 7 có hai hành vi timebox khác nhau: task rollover thường → gỡ liên kết timebox quá khứ, **giữ** sự kiện; task `stale` / `skipped` → timebox tương lai bị gỡ và sự kiện ngoài bị **xoá**. Flow `p7` chỉ vẽ vế đầu. Người đọc sơ đồ sẽ tin rollover không bao giờ xoá sự kiện trên lịch ngoài, trong khi với instance `skipped` có timebox ngày mai thì sự kiện đó bị xoá. Ngoài ra "xem G03 UC-06" ghi bằng chữ trong nút xử lý, không phải nút lục giác, nên không tạo được link; và G03 lại vẽ toàn bộ rollover (file khởi phát là G06), hai bản sẽ lệch nhau khi một bên sửa.

**Sửa:**
- Flow G06: `p3` bỏ chữ "xem G03 UC-06", thêm `p3 --> p3x{{"→ G03 · UC-06 · instance trùng series"}}` class `link`. `p7` đổi thành `p7[["Phát task.upserted, day.recomputed<br/>G05: task rollover → gỡ liên kết timebox quá khứ, giữ sự kiện<br/>task stale / skipped → như Đưa vào backlog: timebox tương lai gỡ, sự kiện xoá"]]` và thêm `p7 --> p7x{{"→ G05 · UC-04 A6, A8"}}`.
- Flow G03 (ngoài phạm vi review này, ghi để phối hợp): rút phần job rollover thành nút → G06 · UC-04, chỉ giữ phần quy tắc BR-10 (series đã có / chưa có instance hôm nay).

**Ai làm:** Flow.

---

#### G06-7 · Nút sang flow thiếu mã UC hoặc dễ đọc nhầm (UC-01 bước 5, UC-04 A11) — Thấp

**Flow đang vẽ** (`g06-backlog-rollover.md:33`, `:418`):
```text
  p2[["Server áp BR-02<br/>G05 xử lý timebox, sự kiện ngoài theo QC-05"]]
  a11 --> a11x{{"→ G04 · UC-03 · UC-01"}}
```

**Nguồn nói:** `docs/design-brief/flow/_quy-uoc.md:70`: nút lục giác "Trỏ tới tính năng và UC; trong cùng file thì `→ UC-04`". `srs-g06:255` A11: "người dùng kéo / chọn ngày (G04) hoặc đưa vào backlog (UC-01)". Flow G05 vẽ tương tác backlog ở UC-04 A8 (`docs/design-brief/flow/g05-lich-timebox.md:464` nút `g06b` "Đưa task vào backlog · G04, G06").

**Không ổn ở chỗ:** `:33` nói "G05 xử lý timebox" bằng chữ trong nút xử lý, không có nút sang flow, nên designer không có đường tới G05 UC-04 A8 (nơi vẽ timebox tương lai `CHO_XOA`, sự kiện bị xoá). `:418` "→ G04 · UC-03 · UC-01" đọc như "G04 UC-03 và G04 UC-01" (UC-01 của G04 là Xem board), trong khi ý là G06 UC-01 (đưa vào backlog).

**Sửa (Flow):**
- `:33` thêm `p2 --> p2x{{"→ G05 · UC-04 A8"}}` class `link`.
- `:418` tách thành `a11 --> a11x{{"→ G04 · UC-03"}}` và `a11 --> a11y{{"→ UC-01"}}`; bảng A11 đã có hai link, giữ nguyên.

**Ai làm:** Flow.

---

#### G06-8 · Tự lưu trữ task đang chạy timer (UC-05 A2) — Thấp, cần PO chốt

**Flow đang vẽ** (`g06-backlog-rollover.md:540`):
```text
  start -->|"A2 · task đang chạy timer"| a2(["Không lưu trữ ở lượt này<br/>xét lại ở lượt ngày sau"])
```

**Nguồn nói:**
- `srs-g06:287` UC-05 A2: "Task đang chạy timer | Không lưu trữ ở lượt này `[giả định]`; xét lại ở lượt ngày sau".
- `srs-g06:48` BR-12: "Timebox, sự kiện ngoài, timer theo dòng "Tự lưu trữ (`stale`)" của QC-05, tức như "Đưa vào backlog" (Q42): … timer không dừng".
- `QC:128` dòng QC-05 "Tự lưu trữ (`stale`), lưu trữ do trùng series (`skipped`, D6) | Như "Đưa vào backlog" | Như "Đưa vào backlog" | Không dừng | —".

**Không ổn ở chỗ:** Flow chép đúng A2, nhưng BR-12 và QC-05 nói tự lưu trữ gặp timer đang chạy thì **vẫn lưu trữ, timer không dừng** (cột "Timer đang chạy: Không dừng" chỉ có nghĩa khi đường đó vẫn xảy ra). A2 lại nói bỏ qua. Hai cách cho hai trạng thái card khác nhau sáng hôm sau: task vẫn ở hôm nay với nhãn "Dời {n} ngày" + timer, hay task nằm trong Lưu trữ với timer vẫn chạy (và Focus vẫn chỉ vào task đã lưu trữ). A2 còn `[giả định]` nên QC-05 thắng, nhưng ca "timer chạy trên task trong Lưu trữ" cần PO xác nhận có chấp nhận được không.

**Sửa:**
- PO chốt: tự lưu trữ task đang chạy timer → lưu (theo QC-05, timer chạy tiếp) hay bỏ qua lượt này (A2)? Mặc định đề xuất: lưu, timer không dừng — nhất quán với mọi đường khác của QC-05 (kể cả rollover A5 cùng UC-04).
- Nếu "lưu": SRS `srs-g06:287` A2 đổi thành "Task đang chạy timer | Vẫn lưu trữ; timer không dừng (QC-05); Focus / card timer hiện task đã lưu trữ"; flow `a2` đổi thành `a2(["Lưu trữ stale, timer không dừng<br/>G07 timer vẫn hiện task"])` và nối → G07 · UC-02. Nếu "bỏ qua": sửa QC-05 dòng Tự lưu trữ cột Timer thành "Không lưu trữ khi timer đang chạy".

**Ai làm:** PO rồi SRS rồi Flow.

---

#### G06-9 · UC-01 A1 thiếu nửa sau BR-03 (Shift+Z trên task đã ở backlog) — Thấp

**Flow đang vẽ** (`g06-backlog-rollover.md:64-65`):
```text
  u1 -->|"A1 · Shift+Z hoặc SCR-03 Lên đầu backlog"| a1[["TaskMove next_week, position top BR-03<br/>bỏ qua SCR-02"]]
  a1 --> a1m>"MSG-02 · Toast<br/>Đã đưa #quot;{tiêu đề}#quot; lên đầu Backlog · Hoàn tác"]
```

**Nguồn nói:** `srs-g06:39` BR-03: "**Shift+Z** đưa task lên đầu bucket `next_week`, không hỏi `[giả định]`; task đã ở backlog → lên đầu bucket hiện tại". `srs-g06:132` A1: "\[TaskMove\] `{backlogBucket: next_week, position: top}` (BR-03)".

**Không ổn ở chỗ:** Flow (và SRS A1) chỉ vẽ vế "next_week". Người dùng nhấn Shift+Z trên task đang ở bucket "Tháng tới" sẽ, theo flow, bị chuyển sang "Tuần tới"; theo BR-03 thì chỉ lên đầu "Tháng tới". Designer vẽ trang Backlog cần biết Shift+Z trong trang không đổi bucket.

**Sửa (Flow):** đổi nhãn `a1` thành `a1[["TaskMove position top BR-03<br/>task Kế hoạch: bucket next_week<br/>task đã ở backlog: giữ bucket hiện tại<br/>bỏ qua SCR-02"]]`. Bảng A1: "Đầu bucket Tuần tới; task đã ở backlog: đầu bucket hiện tại". SRS `srs-g06:132` A1 thêm "task đã ở backlog: `backlogBucket` giữ nguyên".

**Ai làm:** Flow (SRS thêm một vế).

---

#### G06-10 · SRS UC-03 thiếu nhánh mất mạng và `TASK_DELETED` — Thấp

**Flow đang vẽ** (`g06-backlog-rollover.md:317-322`): chỉ có E1 TaskMove lỗi, E3 `PAST_DATE`, E4 `VERSION_CONFLICT`. So với UC-01 cùng file (`:100-105`):
```text
  p1 -.->|"E1 · mất mạng"| e1["Áp trên máy, hàng đợi QC-08<br/>đồng bộ sau cùng idempotency key"]
  p1 -.->|"E2 · 404 / TASK_DELETED"| e2m>"MSG-20 · Toast<br/>Task này không còn tồn tại"]
```

**Nguồn nói:**
- `srs-g06:216-219` UC-03 luồng lỗi: E1 "\[TaskMove\] lỗi", E2 chỉ đọc (1.1), E3 `PAST_DATE`, E4 `VERSION_CONFLICT` — không có mất mạng, không có task đã xoá.
- `srs-g06:142-143` UC-01: E1 "Mất mạng | Áp trên máy, xếp hàng đợi…"; E2 "Task đã bị xoá ở thiết bị khác | 404 / `TASK_DELETED` → MSG-20".
- `srs-g06:516` NFR Offline: "chuyển vào / ra backlog chạy được khi mất mạng; cụm vị trí ghi nguyên khối, lệnh trên phiên bản cũ bị từ chối".

**Không ổn ở chỗ:** Flow đúng SRS, nhưng SRS UC-03 thiếu hai nhánh mà UC-01 (thao tác ngược lại, cùng API) có và NFR khẳng định phải chạy offline. Designer vẽ panel Backlog sẽ không có trạng thái "đã kéo ra ngày, đang chờ đồng bộ" và toast khi task đó đã bị xoá ở máy khác, trong khi màn board (G04 UC-03 E4, E5) có.

**Sửa:**
- SRS: `srs-g06` UC-03 thêm "E5 | Mất mạng | Áp trên máy, xếp hàng đợi, đồng bộ sau (QC-08); cụm vị trí trên phiên bản cũ bị từ chối → E4" và "E6 | Task đã bị xoá ở thiết bị khác | 404 / `TASK_DELETED` → MSG-20, gỡ khỏi bucket".
- Flow: sau khi SRS sửa, vẽ hai nhánh với nhãn giống hệt UC-01 (`e1` class `sync`, `e2m` MSG-20).

**Ai làm:** SRS rồi Flow.

---

#### G06-11 · Nhãn "Dời {n} ngày" có trạng thái cảnh báo n = ngưỡng − 1, không có trong flow (UC-04, SCR-07) — Thấp

**Flow đang vẽ** (`g06-backlog-rollover.md:374-375`):
```text
  m1>"MSG-09 · Tooltip trên SCR-07 nhãn Dời {n} ngày<br/>Dời {n} ngày · dự định từ {ngày dự định đầu tiên}"]
  ok(["Board hôm nay: task dở ở đầu / cuối danh sách,<br/>sau instance lặp hôm nay, có SCR-07 nhãn Dời {n} ngày"])
```

**Nguồn nói:** `srs-g06:441` SCR-07 #2: "Màu | Trạng thái | n = ngưỡng Tự lưu trữ − 1 đổi màu cảnh báo (lượt sau sẽ lưu trữ nếu bật) `[giả định]`". `srs-g06:440` #1: "Hiện khi số ngày bị hoãn n ≥ 1 (QC-04 mục 4); tooltip MSG-09".

**Không ổn ở chỗ:** SCR-07 có hai trạng thái màu (thường, cảnh báo khi n = 3 với ngưỡng 4) nhưng flow chỉ có một nút kết thúc chung "có nhãn Dời {n} ngày". Đây là trạng thái duy nhất báo trước cho người dùng rằng task sẽ biến khỏi hôm nay vào sáng mai; designer bỏ sót thì không có cảnh báo nào trước khi tự lưu trữ. Ghi chú brief cũng không nhắc. Điều kiện "nếu bật" cũng cần vẽ: Tự lưu trữ tắt thì không đổi màu.

**Sửa (Flow):** tách `ok` thành thoi: `ok --> dn{"n = ngưỡng − 1 và Tự lưu trữ bật?"}`; `dn -->|"có"| okw(["SCR-07 nhãn Dời {n} ngày màu cảnh báo<br/>lượt sau sẽ lưu trữ"])` class `warn`; `dn -->|"không"| ok`. Bảng đối chiếu thêm dòng "SCR-07 #2 | n = ngưỡng − 1, Tự lưu trữ bật | Nhãn màu cảnh báo | MSG-09". Câu hỏi nhỏ cho PO: tooltip MSG-09 ở trạng thái cảnh báo có thêm câu "sẽ lưu trữ vào ngày mai" không? Mặc định: có thêm một dòng.

**Ai làm:** Flow (PO chốt chữ tooltip).

---

### Ghi chú cho brief — cần thêm vào `g06-backlog-rollover.md` (mục "Ghi chú cho brief G06")

Sửa ghi chú 2 (`g06:796`) thành:

> - Lỗi `ROLLOVER_FAILED`: G06 MSG-25 và G04 MSG-27 trùng chữ. IA mục 3 và G04 SCR-01 #5 đã chốt banner trên board là **G04 MSG-27**; SRS G06 nên bỏ MSG-25 và trỏ sang G04. G08 hiện MSG-32 inline trong wizard là thông báo riêng của G08, không phải banner.

Thêm các dòng:

> - **UC-07 `CHO_SHUTDOWN`:** nếu board đã hiện rollover tạm trong lúc chờ (A2) mà server trả `CHO_SHUTDOWN` thì phải bỏ hiển thị tạm, task về cột ngày cũ; brief cần trạng thái "cột hôm qua còn task, hôm nay chưa có, không banner" (cùng ca với G04 UC-01 và G08 UC-02 A8). Response `status = THAT_BAI` chưa có nhánh; đề xuất dùng chung banner G04 MSG-27, chờ PO.
> - **Câu lỗi dùng chung với G04:** MSG-17, MSG-20, MSG-23, MSG-24 của G06 khớp QC-08; G04 đặt chữ khác cho cùng mã lỗi (MSG-15, 14, 17, 09). Brief dùng một bộ toast chung cho `TaskMove` trên Home, chờ SRS G04 sửa.
> - **Phím S / D trên task backlog** có ở cả G06 UC-03 A1 (MSG-03) và G04 UC-03 A1 (MSG-07); phím D trên task backlog (G04 BR-10) chưa có ở G06. Đề xuất G06 UC-03 sở hữu, brief panel Backlog vẽ cả S và D với MSG-03.
> - **"Panel ngày" của SCR-01 #8** không có trong IA (panel phải chỉ có Calendar / Tasks / Backlog / Lưu trữ / Search / Trợ lý). Kéo task ra board chỉ làm được từ panel Backlog (Shift+B) trên Home, không từ trang Backlog (trang thay vùng chính). Cần PO chốt bỏ hay giữ "panel ngày".
> - **Rollover và sự kiện ngoài:** task rollover thường giữ sự kiện ngoài; nhưng instance `skipped` và task `stale` xử lý như "Đưa vào backlog" — timebox tương lai bị gỡ, sự kiện ngoài bị **xoá** (BR-11, BR-12, UC-04 bước 7). Brief Lưu trữ cần nói rõ khôi phục không tạo lại timebox.
> - **Tự lưu trữ khi timer đang chạy:** UC-05 A2 (`[giả định]`) nói bỏ qua lượt; BR-12 và QC-05 nói vẫn lưu, timer không dừng. Chờ PO; nếu lưu thì Focus / card timer phải hiện được task đã lưu trữ.
> - **SCR-07 #2 màu cảnh báo** khi n = ngưỡng − 1 và Tự lưu trữ bật (lượt sau sẽ lưu trữ) là trạng thái nhãn thứ hai; brief cần vẽ cả hai màu và tooltip MSG-09 tương ứng.
> - **Shift+Z trên task đã ở backlog** giữ bucket hiện tại, chỉ lên đầu (BR-03); không chuyển sang "Tuần tới".


---

## G07 Focus và timer

Số # trùng bảng mục 3 của `docs/review/review-flow-vs-srs-2026-11-05.md`. Dòng trích là dòng trong file tại commit đang review (flow ghi nguồn `8fac830`).

---

#### G07-1 · Phím toàn cục và menu khay chỉ vẽ chiều "bật" — TB

**Flow đang vẽ** (`g07-focus-timer.md:69-70` UC-01; `:127` UC-02):
```text
  win(["Bất kỳ đâu trên Windows<br/>app ở khay hoặc nền"]) -->|"A4 · Ctrl+Shift+Space toàn cục"| a4[["Chọn task gần nhất đã chạy<br/>hoặc task đầu tiên chưa xong của hôm nay"]]
  a4 --> p1
  ...
  u1[/"Space hoặc nút dừng trên card,<br/>chi tiết task, Focus mode"/]
```
Ghi chú `:612`: "UC-01 A4 chỉ mô tả bật; UC-02 không có điểm vào nào là phím toàn cục hay menu khay… Sơ đồ chỉ vẽ phần SRS có."

**Nguồn nói:**
- `docs/design-brief/00-kien-truc-thong-tin.md:152`: "Ctrl+Shift+A · Ctrl+Shift+Space | Toàn cục: thêm task · bật / dừng timer | D11"; `:130`: "Menu chuột phải: Mở app · Thêm task (Ctrl+Shift+A) · Bật / dừng timer (kèm tên task) · Thoát".
- `docs/features/prd-g07-focus-timer.md:138` US1.1 AC06: "Ctrl+Shift+Space (toàn cục) bật / dừng timer task gần nhất đã chạy (D11)".
- `docs/features/srs-g07-focus-timer.md:51` BR-17: "Ctrl+Shift+Space toàn cục (desktop, 1.0, D11…)"; `:57` BR-23: "Menu khay: Mở app · Thêm task (Ctrl+Shift+A) · Bật / dừng timer (kèm tên task) · Thoát".
- `srs-g07:112` UC-01 A4: "Bật timer task gần nhất đã chạy, hoặc task đầu tiên chưa xong của hôm nay" — và UC-02 bước 1 (`:136`) không nhắc phím toàn cục / khay.
- `00-kien-truc-thong-tin.md:7`: "chỗ nào SRS còn ghi khác thì sửa ngược theo mục 13".

**Không ổn ở chỗ:** IA (đã duyệt, thắng SRS), PRD và cả BR-17 / BR-23 của SRS đều nói phím toàn cục và menu khay là **bật / dừng**. Chỉ phần use case của SRS (UC-01 A4, UC-02) thiếu chiều dừng, và ghi chú flow kết luận ngược (vẽ theo phần thiếu). Hệ quả: người dùng đang có timer, bấm Ctrl+Shift+Space từ ứng dụng khác — theo sơ đồ sẽ "bật timer task gần nhất", tức là mở lại chính task đó hoặc nhảy sang task khác thay vì dừng. Designer cũng không có trạng thái menu khay khi có / không có timer. Ngoài ra khi app ở khay, toast MSG-01 / MSG-02 của nhánh A4 không ai nhìn thấy.

**Sửa:**
- SRS UC-01 A4 (`srs-g07:112`) sửa thành: "Ctrl+Shift+Space / khay "Bật timer": không có timer → bật task gần nhất đã chạy, hoặc task đầu tiên chưa xong của hôm nay; không có task ứng viên → không làm gì, thông báo Windows `[MSG mới]`". UC-02 bước 1 (`:136`) thêm: "Ctrl+Shift+Space toàn cục hoặc khay "Dừng timer" khi đang có timer".
- Flow UC-01: `win` thêm điều kiện "không có timer"; thêm `win -->|"khay → Bật timer"| a4`.
- Flow UC-02: thêm điểm vào
```mermaid
  win(["Bất kỳ đâu trên Windows · đang có timer"]) -->|"Ctrl+Shift+Space / khay Dừng timer"| p1
  g08(["G08 · UC-02 shutdown bước 1<br/>banner MSG-27 Dừng timer"]) -->|"bấm Dừng timer"| p1
```
- Ghi chú `:612` sửa kết luận: IA thắng, sơ đồ vẽ cả chiều dừng; SRS cần sửa ngược.
- PO chốt: khi app ở khay, phản hồi của phím toàn cục (thông báo Windows ngắn "Đã bật / dừng timer {tiêu đề}"?). Đề xuất mặc định: có, như "Đã thêm vào Hôm nay" của IA-19.

**Ai làm:** SRS rồi Flow; PO chốt phản hồi ở khay.

---

#### G07-2 · UC-02 A1 thiếu các đường khác cũng dừng timer — TB

**Flow đang vẽ** (`g07-focus-timer.md:164-165`):
```text
  g02{{"→ G02 · UC-03 / UC-04<br/>hoàn thành / xoá task đang chạy"}} -->|"A1"| a1[["Server dừng timer trước<br/>trong cùng giao dịch BR-06"]]
  a1 --> s2
```

**Nguồn nói:**
- `srs-g07:40` BR-06: "**Không đường nào khác dừng timer** (Q14, QC-05): phím D, kéo sang ngày khác, rollover, đưa vào backlog, shutdown "Ngày mai"…, AI dời ngày, lưu trữ do trùng series".
- `docs/review/quyet-dinh-chot-2026-11-04.md:173` C13: "Đổi hoặc dừng series: instance đang chạy timer thì dừng timer; instance đã có thời gian thực tế thì giữ lại".
- `docs/features/srs-g03-task-lap-lai.md:55` BR-17: "Instance trong phạm vi BR-08 (a), (b), (d) đang chạy timer → dừng timer (G07) trước khi áp thao tác".
- `g03-task-lap-lai.md:418`: `a6[["Dừng timer nếu đang chạy<br/>giữ instance, tách khỏi series BR-17"]]`; `:538`: `a2[["Dừng timer G07<br/>instance có thời gian thực tế: giữ BR-17"]]`.
- `g01-tai-khoan.md:1042`: `a2x{{"→ G07 · UC-02<br/>dừng và lưu bản ghi thời gian trước khi xoá"}}` (xoá tài khoản).

**Không ổn ở chỗ:** BR-06 liệt kê "không đường nào khác" nhưng C13 (đã chốt) và G03 BR-17 cho đổi / dừng series dừng timer, G01 cho xoá tài khoản dừng timer. Hai flow kia đã trỏ sang G07 UC-02, còn UC-02 không có nhánh nhận: designer đọc G07 sẽ nghĩ chỉ hoàn thành / xoá task mới dừng timer, và không có trạng thái "timer bị dừng bởi thao tác series" (toast nào? MSG-07 "trên thiết bị khác" không đúng ngữ cảnh).

**Sửa:**
- SRS BR-06 (`srs-g07:40`) sửa: "Dừng timer khi: hoàn thành / xoá task (G02); đổi hoặc dừng series làm instance bị xoá / tách (G03 BR-17, C13); xoá tài khoản (G01 BR-20). Không đường đổi ngày nào dừng timer (Q14, QC-05): …". UC-02 A1 ghi thêm hai nguồn và MSG hiển thị (đề xuất dùng toast của nhóm gọi: G03 MSG-24, G01 không cần).
- Flow UC-02 A1:
```mermaid
  g03{{"→ G03 · UC-04 / UC-05<br/>đổi / dừng series, instance đang chạy timer"}} -->|"A1 · C13, G03 BR-17"| a1
  g01{{"→ G01 · UC-09 xoá tài khoản"}} -->|"A1"| a1
```
  Bảng đối chiếu A1 thêm hai nguồn.

**Ai làm:** SRS rồi Flow.

---

#### G07-3 · Focus mở task nào khi đang có timer ở task khác — TB (cần PO xác nhận)

**Flow đang vẽ** (`g07-focus-timer.md:323-324`):
```text
  u1[/"Phím F hoặc mục Focus ở sidebar"/]
  p1[["Chọn task BR-12: task đang chọn,<br/>không có thì task đầu tiên chưa xong của hôm nay"]]
```

**Nguồn nói:**
- `srs-g07:46` BR-12: "Không có task chọn → task đầu tiên chưa xong của hôm nay".
- `srs-g07:392` SCR-01 #3: "Badge Focus | Badge ở sidebar | Hiện khi có timer chạy; bấm mở SCR-03 của task đang chạy".
- `srs-g07:211` UC-04 bước 2: "Chọn task theo BR-12".

**Không ổn ở chỗ:** Mục "Focus" ở sidebar và badge trên chính mục đó là một nút. Khi timer đang chạy ở task A, người dùng đang chọn task B rồi bấm Focus: BR-12 cho mở B, SCR-01 #3 cho mở A. Flow chỉ vẽ BR-12 nên designer sẽ không có trạng thái "Focus mở task đang chạy timer" — là trường hợp thường gặp nhất (bấm badge để quay lại việc đang làm).

**Sửa:**
- PO chốt thứ tự ưu tiên. Đề xuất mặc định: có timer đang chạy → task đang chạy; không → task đang chọn; không → task đầu tiên chưa xong của hôm nay.
- SRS BR-12 (`srs-g07:46`) ghi thứ tự này.
- Flow: `p1` đổi thành thoi `d0{"Có timer đang chạy?"}` → "có" `pA[["Task đang chạy timer SCR-01 #3"]]`; "không" → `p1` cũ.

**Ai làm:** PO → SRS → Flow.

---

#### G07-4 · Âm báo theo kế hoạch (MSG-10) vẽ như chỉ có trong Focus — TB (cần PO chốt)

**Flow đang vẽ** (`g07-focus-timer.md:329-330`, nằm trong happy case UC-04 sau `u3[/"Làm việc: tích subtask, ghi notes"/]`):
```text
  d1{"Còn lại chạm mức cài đặt<br/>10 / 5 / 0 phút? BR-07"}
  m1>"MSG-10 · Toast + âm báo<br/>Còn {n} phút cho #quot;{tiêu đề}#quot; / Đã hết thời lượng kế hoạch cho #quot;{tiêu đề}#quot;"]
```

**Nguồn nói:**
- `srs-g07:41` BR-07: "**Âm báo theo kế hoạch.** Còn lại = kế hoạch − thực tế (gồm lượt đang chạy). Chạm mức cài đặt (10 / 5 / 0 phút, mặc định 0) → âm báo (nếu bật) + MSG-10, tối đa một lần / lượt chạy" — không giới hạn ở Focus.
- `00-kien-truc-thong-tin.md:128`: "**Bấm ×** luôn thu app về khay, có timer hay không"; `:235` (quyết định) D12 chỉ có thông báo Windows cho "nhắc ritual và nhắc timer > 4 giờ".
- `prd-g07:206` US3.2 đặt âm báo dưới UC3 Focus mode.

**Không ổn ở chỗ:** BR-07 là quy tắc của timer, chạy ở mọi màn (Home, Today, chi tiết task) và cả khi app thu về khay. Flow chỉ vẽ MSG-10 trong UC-04, nên designer sẽ không vẽ toast này ở Home / Today và không có gì cho lúc app ẩn: âm báo kêu nhưng toast không ai thấy, nội dung "còn {n} phút cho task nào" mất. PRD cũng đặt nó dưới Focus nên SRS kế thừa sự mơ hồ.

**Sửa:**
- PO chốt: MSG-10 khi app ở khay dùng thông báo Windows không (mở rộng D12)? Đề xuất mặc định: có, cùng cài đặt Thông báo của G12.
- SRS BR-07 thêm "hiện ở mọi màn; cửa sổ ẩn → thông báo Windows (G12)". UC-04 bước 4 ghi "(cũng xảy ra ngoài Focus, UC-01 bước 4)".
- Flow: chuyển `d1`/`m1` thành nhánh chung của UC-01 (sau `s2` "timer đang chạy") với nhãn "BR-07 · mọi màn"; UC-04 giữ nút tham chiếu "→ UC-01 BR-07". Thêm rẽ "cửa sổ ẩn ở khay → thông báo Windows G12".

**Ai làm:** PO → SRS → Flow.

---

#### G07-5 · UC-02 thiếu điểm vào từ banner shutdown G08 — TB

**Flow đang vẽ** (`g07-focus-timer.md:126-128`):
```text
  start(["Timer DANG_CHAY / CHAY_LAU"])
  u1[/"Space hoặc nút dừng trên card,<br/>chi tiết task, Focus mode"/]
  s1["SCR-01 đồng hồ dừng ngay"]
```

**Nguồn nói:**
- `g08-daily-rituals.md:374-375`: `a1m>"MSG-27 · Banner SCR-08 #4<br/>Timer đang chạy cho #quot;{tiêu đề}#quot; · Dừng timer<br/>hệ thống không tự dừng"]` → `a1x{{"→ G07 · UC-02 Dừng timer"}}`.
- `srs-g07:40` BR-06: "shutdown "Ngày mai" (G08 chỉ nhắc ở bước đầu)".
- `_quy-uoc.md:22`: file khác chỉ có nút sang flow; file nhận phải có nhánh tương ứng.

**Không ổn ở chỗ:** G08 trỏ sang UC-02 từ nút "Dừng timer" trong banner của wizard shutdown, nhưng UC-02 chỉ liệt kê card / chi tiết / Focus. Designer của G07 không biết SCR-01 có thể bị gọi từ wizard (không có card nào đang hiện) và sau khi dừng thì người dùng ở lại wizard, không về SCR-01.

**Sửa:** Flow UC-02 thêm `g08(["G08 · UC-02 shutdown bước 1 · banner MSG-27"]) -->|"bấm Dừng timer"| p1` và kết thúc riêng "về wizard, banner ẩn". Bảng đối chiếu thêm dòng "(G08 MSG-27)". SRS UC-02 bước 1 (`srs-g07:136`) thêm "banner nhắc của Daily shutdown (G08)". (Cùng chỗ với điểm vào phím toàn cục / khay ở G07-1.)

**Ai làm:** Flow (SRS bổ sung một câu).

---

#### G07-6 · UC-06 E1 vẽ như gửi thông báo lỗi thì timer tự đóng — Thấp

**Flow đang vẽ** (`g07-focus-timer.md:473-474`):
```text
  p1 -.->|"E1 · gửi thông báo lỗi"| e1["Thử lại 3 lần<br/>không chặn bước tự đóng"]
  e1 -.-> p2
```
với `p2[["Tự đóng BR-09"]]`.

**Nguồn nói** (`srs-g07:301` UC-06 E1): "Gửi thông báo lỗi | Thử lại 3 lần; không chặn bước 3" — bước 3 (`:282`) là "Chạy > 24 giờ → đóng theo BR-09".

**Không ổn ở chỗ:** "Không chặn bước 3" nghĩa là lỗi gửi thông báo không ngăn việc tự đóng **khi** timer tới 24 giờ; nhưng cạnh `e1 -.-> p2` đọc như lỗi thông báo (ở mốc 4 giờ) dẫn thẳng tới tự đóng. Designer không cần vẽ gì ở đây, nhưng người đọc sơ đồ sẽ hiểu sai vòng đời timer.

**Sửa:** Đổi `e1 -.-> p2` thành `e1 -.->|"lượt 5 phút sau, vẫn chờ 24 giờ"| m1` hoặc nối về nút `start` ("job mỗi 5 phút") như happy case; nhãn `e1` sửa "Thử lại 3 lần · timer vẫn chạy, tới 24 giờ mới tự đóng".

**Ai làm:** Flow.

---

#### G07-7 · Khối thực tế trên lịch vẽ như luôn có — Thấp

**Flow đang vẽ** (`g07-focus-timer.md:133`, happy case UC-02):
```text
  s2["SCR-01 thực tế H:MM<br/>G05 vẽ block thực tế trên lịch"]
```

**Nguồn nói:**
- `docs/features/srs-g05-lich-timebox.md:55` BR-18: "Bật "Hiện actual trên lịch" → mỗi bản ghi thời gian (QC-07) **có giờ thật** vẽ một khối thực tế trên lịch app".
- `srs-g07:38` BR-04: "Thời lượng < 10 giây → xoá bản ghi"; flow `:130-131` đã vẽ nhánh "< 10 giây → Bỏ bản ghi" nhưng cả hai nhánh đều đổ về `p3 → s2`.

**Không ổn ở chỗ:** Khối thực tế chỉ xuất hiện khi cài đặt G05 bật (mặc định chưa ghi) và khi bản ghi còn tồn tại. Theo sơ đồ, lượt chạy 5 giây bị bỏ vẫn đi tới "G05 vẽ block thực tế"; designer sẽ vẽ khối cho mọi lần dừng.

**Sửa:** Tách `s2` thành `s2["SCR-01 thực tế H:MM"]` và `s2c["Lưới lịch G05 SCR-04: khối thực tế<br/>chỉ khi bật Hiện actual trên lịch G05 BR-18"]` nối từ `p3` bằng cạnh thường; nhánh `p2` (bỏ bản ghi) nối thẳng `p3 → s2`, không qua `s2c`.

**Ai làm:** Flow.

---

#### G07-8 · Bộ chọn giờ "Dừng lúc…" chưa có mã SCR — Thấp

**Flow đang vẽ** (`g07-focus-timer.md:463-464`):
```text
  m1 -->|"A6 · bấm Dừng lúc…"| a6["Bộ chọn giờ như SCR-06 #2<br/>trong (startedAt, now], mặc định giờ hoạt động cuối"]
  a6 -->|"Lưu"| a6p[["TimerStop endedAt, áp BR-04"]]
```

**Nguồn nói:**
- `srs-g07:295` UC-06 A6: "Mở bộ chọn giờ (như SCR-06 #2) trong khoảng (`startedAt`, now], mặc định giờ hoạt động cuối trên app; "Lưu" → \[TimerStop\] `{endedAt}`".
- `srs-g07:443` SCR-06 #2: "Giờ dừng | Date + time picker | Trong khoảng (`startedAt`, `startedAt` + 24 giờ]".
- `_quy-uoc.md:57`: "Mọi nút màn hình có mã SCR".

**Không ổn ở chỗ:** Nút `a6` là một màn (dialog chọn giờ mở từ thông báo, kể cả từ thông báo Windows khi cửa sổ đang ẩn) nhưng không có mã SCR; nó khác SCR-06 ở khoảng giờ, nút ("Lưu" thay vì "Giữ 24 giờ / Xoá bản ghi") và ngữ cảnh (timer còn chạy). Designer không có mã để đặt tên màn và không biết có dùng lại SCR-06 hay không. Ghi chú `:614` mới nêu khoảng giờ khác, chưa nêu thiếu mã.

**Sửa:** SRS thêm SCR-08 "Chọn giờ dừng (từ MSG-11)" với #1 nội dung, #2 picker (`startedAt`, now], #3 "Lưu", #4 "Huỷ"; hoặc mở rộng SCR-06 thành hai biến thể. Flow đổi nhãn `a6` thành "SCR-08 Chọn giờ dừng · dialog"; ghi chú #3 bổ sung "thiếu mã SCR".

**Ai làm:** SRS rồi Flow.

---

### Ghi chú cho brief — cần thêm vào `g07-focus-timer.md` (mục "Ghi chú cho brief G07")

Dán các dòng sau; dòng 1 hiện có (`:612`) thay bằng dòng đầu tiên.

1. (thay `:612`) **Phím toàn cục và menu khay là bật / dừng.** IA mục 7–8 (IA-05, D11), PRD US1.1 AC06 và BR-17 / BR-23 đều ghi Ctrl+Shift+Space và menu khay "Bật / dừng timer"; chỉ UC-01 A4 và UC-02 của SRS thiếu chiều dừng. IA thắng SRS, sơ đồ vẽ cả hai chiều (UC-01 A4 khi không có timer; UC-02 thêm điểm vào phím toàn cục / khay / banner shutdown G08). SRS cần sửa ngược. Còn mở: phản hồi khi app ở khay (toast MSG-01 / MSG-02 không ai thấy) và khi không có task ứng viên để bật.
2. **Các đường khác cũng dừng timer.** BR-06 ghi "không đường nào khác dừng timer" nhưng C13 / G03 BR-17 (đổi hoặc dừng series) và G01 UC-09 (xoá tài khoản) đều dừng timer và đã trỏ sang UC-02. Sơ đồ UC-02 A1 thêm hai nguồn này; SRS BR-06 cần sửa.
3. **Focus mở task nào khi có timer ở task khác.** BR-12 (task đang chọn) và SCR-01 #3 (badge mở task đang chạy timer) cho hai kết quả khác nhau. Cần PO chốt thứ tự ưu tiên; đề xuất: task đang chạy timer trước.
4. **MSG-10 không chỉ ở Focus.** BR-07 áp cho mọi timer ở mọi màn, kể cả khi app thu về khay (IA-05); D12 không có thông báo Windows cho trường hợp này nên lúc đó chỉ có âm báo, không có chữ. Cần PO chốt có dùng thông báo Windows cho MSG-10 không.
5. (bổ sung vào ghi chú 3 hiện có) Bộ chọn giờ "Dừng lúc…" (UC-06 A6) là một dialog riêng nhưng chưa có mã SCR; cần SRS đặt mã hoặc gộp vào SCR-06 với hai biến thể.


---

## G08 Daily planning và Daily shutdown

Số # trùng bảng mục 3 "G08" của `docs/review/review-flow-vs-srs-2026-11-05.md`. Viết tắt: `g08` = `docs/design-brief/flow/g08-daily-rituals.md`, `srs-g08` = `docs/features/srs-g08-daily-rituals.md`, `srs-g10` = `docs/features/srs-g10-tro-ly-ai.md`, `srs-g06` = `docs/features/srs-g06-backlog-rollover.md`, `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`, `QC` = `docs/01-quy-tac-dung-chung.md`, `prd-g08` = `docs/features/prd-g08-daily-rituals.md`.

---

#### G08-1 · A6 Plan cho ngày tương lai kết thúc sai chỗ — Cao

**Flow đang vẽ** (`g08:110-111, 117-118`):
```text
  ok(["Bắt đầu ngày · Home / Today"])
  u1 ==> p1 ==> s1 ==> ok
  p1 -->|"A6 · nút Plan trên cột D > hôm nay"| a6["Bước 1 liệt kê task chưa xong của<br/>ngày làm việc liền trước D, BR-06<br/>nút Bắt đầu ngày đổi thành Xong, không chuyển trang"]
  a6 --> s1
```
Bảng đối chiếu `g08:292`: `| A6 | D > hôm nay (nút Plan cột tương lai) | Bước 1 là task của ngày trước D; nút "Xong", không chuyển trang | – |`

**Nguồn nói** (`srs-g08:125`): `| A6 | D > hôm nay (nút "Plan" trên cột tương lai) | Bước 1 liệt kê task chưa xong của ngày trước D (BR-06); "Bắt đầu ngày" đổi thành "Xong", không chuyển trang |`
(`srs-g08:394`): `| 6 | "Bắt đầu ngày" / "Hoàn tất" | Button chính | – | UC-01 bước 14 / UC-02 bước 10; disabled khi đang gửi |`
(`srs-g08:42`, BR-06): `D = hôm nay → gọi API "đảm bảo rollover" [RolloverEnsure] của G06 (B6) trước khi tải`

**Không ổn ở chỗ:** Nhánh A6 chỉ ghi chữ "không chuyển trang" trong nút rồi nối thẳng về `s1`, mà `s1` lại chạy tới `ok` "Bắt đầu ngày · Home / Today". Đọc sơ đồ, designer sẽ hiểu phiên cho ngày tương lai cũng kết thúc bằng "Bắt đầu ngày" và nhảy về Home / Today — ngược với SRS. Ngoài ra SCR-07 #6 chỉ liệt kê hai nhãn "Bắt đầu ngày" / "Hoàn tất", nhãn thứ ba "Xong" không có trong mô tả màn, nên brief sẽ thiếu một trạng thái của nút chính. Flow cũng gọi `RolloverEnsure` vô điều kiện ở `p1` (`g08:30`), trong khi BR-06 chỉ gọi khi D = hôm nay.

**Sửa:**
1. Flow: tách kết thúc riêng cho A6, không nối về `s1` → `ok`:
```mermaid
  a6 --> s1f["SCR-01 các bước cho ngày D<br/>SCR-07 nút chính là Xong"]
  s1f -->|"bấm Xong"| p7f[["RitualComplete, không gọi RolloverEnsure"]]
  p7f --> okf(["Wizard đóng, ở lại màn trước (board, cột D)<br/>task ghi chép Daily planning đã xong ở ngày D"])
```
   và sửa nút `p1` ở happy case (`g08:30`) thành "D = hôm nay: RolloverEnsure G06, BR-06" (đã có) kèm chú "D > hôm nay: không gọi".
2. SRS: SCR-07 #6 (`srs-g08:394`) bổ sung: `"Bắt đầu ngày" / "Xong" (D > hôm nay, A6 UC-01) / "Hoàn tất"`.
3. Bảng đối chiếu A6: "Kết thúc ở" ghi "Xong → wizard đóng, ở lại board, không chuyển Home / Today".

**Ai làm:** Flow, rồi SRS (một dòng SCR-07 #6).

---

#### G08-2 · A13 (412) quay về sai bước, thiếu điểm phát sinh từ RitualComplete — Cao

**Flow đang vẽ** (`g08:252-256`):
```text
  pu -->|"A13 · 412 PRECONDITION_FAILED"| a13[["Tải lại phiên, gộp data theo từng trường QC-08<br/>gửi lại một lần BR-26"]]
  a13 --> d13{"Trường của người dùng<br/>bị ghi đè?"}
  d13 -->|"có"| a13m>"MSG-29 · Toast<br/>Ritual vừa được sửa trên thiết bị khác. Đã gộp thay đổi; #quot;{tên trường}#quot; lấy theo bản mới nhất"]
  d13 -->|"không"| s6
  a13m --> s6
```
(`s6` là `"SCR-07 Bước 6 Chia sẻ"`, `g08:243`; `pu` là `"RitualUpdate, If-Match"` mọc từ `s1` "SCR-01 · bước bất kỳ".)

**Nguồn nói** (`srs-g08:132`): `| A13 | Phiên bị sửa ở thiết bị khác (412) | Tải lại phiên, gộp `data` theo từng trường, gửi lại; trường bị ghi đè → MSG-29 (BR-26) |`
(`srs-g08:62`, BR-26): `[RitualUpdate] / [RitualComplete] gửi `If-Match`. … 412 `PRECONDITION_FAILED` (khác phiên bản) → tải lại phiên, gộp `data` theo từng trường (…), gửi lại một lần; trường của người dùng bị ghi đè → MSG-29`

**Không ổn ở chỗ:** `RitualUpdate` chạy mỗi lần chuyển bước hay sửa nội dung (BR-05), nên 412 có thể xảy ra ở bước 1, 3, 5… Sơ đồ lại đưa mọi trường hợp về bước 6 Chia sẻ — designer sẽ hiểu sau khi gộp, wizard nhảy tới bước cuối, người dùng mất chỗ đang làm. Thứ hai, BR-26 nói rõ `RitualComplete` cũng gửi `If-Match` và cũng có thể trả 412, nhưng A13 chỉ mọc từ `pu`; A12 (409) thì đã mọc từ cả `pu` và `p7` (`g08:249-250`), nên A13 bị vẽ thiếu một nửa.

**Sửa:** Flow:
```mermaid
  p7 -->|"A13 · 412"| a13
  d13 -->|"không"| s1
  a13m --> s1
```
tức là đổi hai cạnh đích `s6` thành `s1` ("SCR-01 · bước bất kỳ" = ở lại bước hiện tại với dữ liệu đã gộp), thêm cạnh từ `p7`. Bảng đối chiếu A13 ghi "Kết thúc ở: ở lại bước hiện tại, dữ liệu đã gộp; nếu 412 ở RitualComplete thì gửi lại cùng Idempotency-Key".

**Ai làm:** Flow.

---

#### G08-3 · Điều kiện hiện "Plan my day" ghi thiếu và sai — TB

**Flow đang vẽ** (`g08:123-124`):
```text
  s1 -->|"trợ lý AI bật · Plan my day"| g10{{"→ G10 · UC-02 Planning Agent"}}
  g10 -->|"xong: sang bước 5 Daily plan<br/>lỗi, Dừng, Hoàn tác kế hoạch AI: về bước 1"| s1
```
Bảng đối chiếu `g08:310`: `| – | Plan my day (trợ lý AI bật) | → G10 · UC-02; xong về bước 5, lỗi về bước 1 | – |`

**Nguồn nói** (`srs-g10:564`, Điểm vào): `| Daily planning (G08) → "Plan my day" | ✓ | Chỉ khi bật Beta; SCR-02; không sẵn sàng → SCR-11 ở cùng chỗ |`
(`srs-g10:593`, SCR-02 #3): `"Plan my day" … chưa đồng ý → SCR-10; Claude Code không `SAN_SANG` → thay bằng SCR-11`
(`srs-g10:55`, BR-14): `Chỉ chạy khi trợ lý bật, đã đồng ý (BR-19), Claude Code sẵn sàng (BR-25) và bật Beta "Agentic Daily Planning".`
(`srs-g10:60`, BR-19): `Lần đầu bật (✨, "Plan my day", "Soạn bằng AI", toggle "Trợ lý") khi `aiConsentAt` trống → mở SCR-10`

**Không ổn ở chỗ:** Nhãn "trợ lý AI bật" bỏ sót điều kiện quyết định là **Beta "Agentic Daily Planning" bật** (mặc định tắt, SCR-09 #8), nên designer sẽ vẽ nút Plan my day cho mọi người đã bật trợ lý. Ngược lại, nút vẫn hiện khi chưa đồng ý (bấm thì mở SCR-10) và vẫn có chỗ (thẻ SCR-11 thay nút) khi Claude Code chưa sẵn sàng — hai trạng thái này của wizard không có trên sơ đồ G08, trong khi G08 là màn chứa nút.

**Sửa:** Flow, thay hai dòng trên bằng:
```mermaid
  s1 -->|"Beta Agentic Daily Planning bật · Plan my day"| d10{"Claude Code SAN_SANG,<br/>đã đồng ý?"}
  d10 -->|"có"| g10{{"→ G10 · UC-02 Planning Agent"}}
  d10 -->|"chưa đồng ý"| g9{{"→ G10 · UC-09 Đồng ý, xong chạy UC-02"}}
  d10 -->|"Claude Code chưa sẵn sàng"| g11{{"→ G10 · UC-10<br/>thẻ SCR-11 thay chỗ nút Plan my day"}}
  g10 -->|"xong: sang bước 5 Daily plan<br/>lỗi, Dừng, Hoàn tác kế hoạch AI: về bước 1"| s1
```
Bảng đối chiếu: đổi điều kiện thành "Plan my day (Beta bật)" và thêm hai dòng → G10 · UC-09, → G10 · UC-10. Vị trí nút trong wizard vẫn là câu hỏi mở (đã có ở ghi chú dòng 825).

**Ai làm:** Flow.

---

#### G08-4 · BR-06: kết quả RolloverEnsure chỉ xét hai trạng thái — TB

**Flow đang vẽ** (`g08:199-201`):
```text
  s1 -->|"BR-06 · RolloverEnsure trả CHO_SHUTDOWN / THAT_BAI"| b6m>"MSG-32 · Inline<br/>Việc từ hôm qua đang được chuyển sang. Danh sách sẽ tự cập nhật"]
  b6m --> b6["Hiện danh sách đang có<br/>tự tải lại khi rollover xong, realtime"]
  b6 --> s1
```

**Nguồn nói** (`srs-g08:42`, BR-06): `API chạy bù hoặc chờ lượt rollover xong rồi mới trả. Trả `CHO_SHUTDOWN` (phiên shutdown hôm qua còn trong ân hạn, BR-21) hoặc `THAT_BAI` → vẫn tải danh sách hiện có, hiện MSG-32, tự tải lại khi rollover xong (realtime).`
(`srs-g06:55`, BR-19 — nhóm sở hữu API): `[RolloverEnsure] idempotent theo người dùng + ngày: `XONG` → trả kết quả đã có; `CHO`, `LOI`, `THAT_BAI` hoặc `DANG_CHAY` hết lease → chạy UC-04 bước 2–7 ngay trong request; `DANG_CHAY` còn lease → chờ tối đa 10 giây `[giả định]` rồi trả trạng thái hiện tại; `CHO_SHUTDOWN` → không ép chạy, trả trạng thái kèm `waitUntil` (BR-20).`
(`srs-g06:360`, UC-07 E1): `| E1 | Chạy trong request lỗi | Rollback; … trả `ROLLOVER_FAILED` → MSG-25 có "Thử lại" |`
(`srs-g06:459`): response `status: XONG | DANG_CHAY | CHO_SHUTDOWN | DONG_BANG | THAT_BAI`

**Không ổn ở chỗ:** Flow vẽ đúng SRS G08, nhưng SRS G08 BR-06 lệch với G06 (nhóm sở hữu API, thắng theo quy tắc nhóm sở hữu): (a) khi nhận `THAT_BAI` thì API **chạy bù ngay trong request**, nên client gần như không bao giờ nhận lại `THAT_BAI`; thứ client nhận khi chạy bù lỗi là mã lỗi `ROLLOVER_FAILED`; (b) `DANG_CHAY` (lượt đang chạy, API chờ 10 giây rồi trả) là trường hợp thường gặp nhất mà G08 không nói tới; (c) request timeout / mất mạng (G06 UC-07 E2) cũng không có. Hệ quả: bước 1 Xem lại hôm qua có 3 trường hợp "danh sách chưa chuẩn" mà sơ đồ chỉ vẽ 1 nhãn, designer không biết có cần trạng thái lỗi riêng (nút Thử lại) hay chỉ MSG-32. Cùng vấn đề với G04 / G06 (mục R2 của báo cáo tổng).

**Sửa:**
1. SRS G08 BR-06 (`srs-g08:42`), thay câu "Trả `CHO_SHUTDOWN` … hoặc `THAT_BAI` → …" bằng: "Trả `DANG_CHAY` (lượt đang chạy, API đã chờ 10 giây) hoặc `CHO_SHUTDOWN` (phiên shutdown hôm qua còn trong ân hạn, BR-21) → vẫn tải danh sách hiện có, hiện MSG-32, tự tải lại khi rollover xong (realtime). API trả lỗi `ROLLOVER_FAILED`, timeout hoặc mất mạng → tải danh sách hiện có, hiện MSG-32; banner lỗi rollover thuộc G04 (MSG-27, IA-17), G08 không hiện thêm."
2. Flow: đổi nhãn cạnh thành `"BR-06 · RolloverEnsure trả DANG_CHAY / CHO_SHUTDOWN,<br/>hoặc ROLLOVER_FAILED / timeout"`, thêm nút lục giác `{{"→ G06 · UC-07 Đảm bảo rollover"}}` ngay sau `p1` của happy case để designer biết G06 sở hữu các trạng thái này.

**Ai làm:** SRS rồi Flow. Cần PO xác nhận: khi `ROLLOVER_FAILED`, bước 1 có nút "Thử lại" riêng hay chỉ dựa vào banner G04 MSG-27 (mặc định đề xuất: chỉ MSG-32, banner của G04 lo phần thử lại).

---

#### G08-5 · UC-02 A11 trỏ sang UC-01 A12/A13 nhưng màn đích khác — TB

**Flow đang vẽ** (`g08:460`):
```text
  p5 -->|"A11 · 409 / 412 thiết bị khác, BR-26"| a11{{"→ UC-01 A12, A13<br/>MSG-15 / MSG-29"}}
```
(`p5` là `"RitualComplete"`, `g08:450`.) Bảng `g08:501`: `| A11 | Thiết bị khác sửa / hoàn tất | Như UC-01 A12, A13 | MSG-15 / MSG-29 |`. UC-01 A12 kết thúc ở `g08:251`: `a12(["SCR-06 chế độ xem bản đã chốt<br/>…"])`.

**Nguồn nói** (`srs-g08:186`): `| A11 | Phiên bị sửa / hoàn tất ở thiết bị khác | Như UC-01 A12, A13 (BR-26) |`
(`srs-g08:179`, UC-02 A4): `Mở SCR-10 chế độ xem + "Làm lại"`
(`srs-g08:420`, SCR-10 #3): `| 3 | Chế độ xem (phiên `HOAN_TAT`) | Read-only + button | – | "Làm lại" → A4 UC-02 |`
(`srs-g08:62`, BR-26): `[RitualUpdate] / [RitualComplete] gửi `If-Match`.`

**Không ổn ở chỗ:** "Như UC-01 A12" chỉ đúng về xử lý (MSG-15, mở bản đã chốt ở chế độ xem), nhưng màn đích của shutdown là **SCR-10 Highlights chế độ xem** (có nút "Làm lại"), không phải SCR-06 Daily plan. Designer đọc link sẽ vẽ shutdown nhảy sang màn của planning. Thêm nữa, 412 từ `RitualUpdate` xảy ra ở mọi bước shutdown (1–3), nhưng flow chỉ mọc A11 từ `p5` RitualComplete nên thiếu trường hợp gộp dữ liệu giữa chừng (ví dụ highlights đang gõ bị thiết bị khác ghi đè).

**Sửa:** Flow, thay dòng 460 bằng nhánh vẽ riêng:
```mermaid
  s1 -->|"A11 · RitualUpdate 409 RITUAL_ALREADY_COMPLETED"| a11m>"MSG-15 · Toast<br/>Ritual này vừa được hoàn tất trên thiết bị khác"]
  p5 -->|"A11 · 409"| a11m
  a11m --> a11e(["SCR-10 chế độ xem bản đã chốt, nút Làm lại<br/>nội dung đang sửa giữ nháp trên máy tới hết ngày D"])
  s1 -->|"A11 · 412 PRECONDITION_FAILED"| a11g[["Tải lại phiên, gộp data theo trường QC-08<br/>gửi lại một lần BR-26"]]
  p5 -->|"A11 · 412"| a11g
  a11g -->|"trường bị ghi đè"| a11w>"MSG-29 · Toast<br/>Ritual vừa được sửa trên thiết bị khác. Đã gộp thay đổi; #quot;{tên trường}#quot; lấy theo bản mới nhất"]
  a11w --> s1
  a11g -->|"không"| s1
```
Bảng đối chiếu A11: "Kết thúc ở: 409 → SCR-10 chế độ xem; 412 → ở lại bước hiện tại, dữ liệu đã gộp".

**Ai làm:** Flow.

---

#### G08-6 · UC-02 A7 highlights AI thiếu đường "Soạn bằng AI" và thẻ SCR-11 — TB

**Flow đang vẽ** (`g08:382-384`):
```text
  s3 -->|"A7 · trợ lý AI bật, G10 đã soạn nháp"| a7["SCR-10 điền nháp AI, nhãn Nháp AI<br/>chưa có nháp, lỗi, chậm > 10 giây: giữ danh sách sinh sẵn"]
  a7 --> a7x{{"→ G10 · UC-05 Highlights AI"}}
  a7 --> s4
```
Bảng `g08:497`: `| A7 | Trợ lý AI bật, có nháp highlights | Nháp AI trong SCR-10 → G10 · UC-05; không có nháp → danh sách sinh sẵn | – |`

**Nguồn nói** (`srs-g08:182`, A7): `Bước 3 điền nháp AI, nhãn "Nháp AI"; chưa có nháp, lỗi / chậm > 10 giây → dùng danh sách sinh sẵn của BR-17`
(`srs-g10:332`, UC-05 A1): `| A1 | Mở shutdown trước giờ kết thúc của lịch chung, ngày không có trong lịch làm việc, job tự soạn chưa xong / lỗi, hoặc tắt "Tóm tắt tự động" | Nút "Soạn bằng AI" trên SCR-07 → bước 2 ngay |`
(`srs-g10:339`, A8): `| A8 | Claude Code không `SAN_SANG` | Nút "Soạn bằng AI" ẩn; bước highlights dùng danh sách sinh sẵn (G08 BR-17) |`
(`srs-g10:345`, E1): `MSG-05 (bị đóng: MSG-27); hiện danh sách việc đã xong để biên tập tay (G08); "Thử lại"`
(`srs-g10:703`): `Hiện ở SCR-09, chỗ của "Plan my day" (SCR-02), khi mở khung chat từ Command menu, và chỗ "Soạn bằng AI" (SCR-07) khi Claude Code khác `SAN_SANG` (BR-25).`

**Không ổn ở chỗ:** Theo G10, bước Highlights của shutdown có ít nhất 4 trạng thái khi trợ lý bật: (1) có nháp AI; (2) chưa có nháp → nút "Soạn bằng AI" (mở shutdown sớm hơn giờ kết thúc là trường hợp rất thường gặp); (3) Claude Code chưa sẵn sàng → thẻ SCR-11 ở chỗ nút; (4) đang soạn / lỗi → MSG-05 + "Thử lại". Flow G08 gộp (2)(3)(4) thành "giữ danh sách sinh sẵn" nên designer vẽ SCR-10 thiếu nút "Soạn bằng AI" và chỗ cho thẻ SCR-11. Ngoài ra cùng một bước có hai mã màn (G08 SCR-10 và G10 SCR-07) mà không ai nói chúng là một — brief hai nhóm có thể vẽ hai màn khác nhau.

**Sửa:** Flow, thay ba dòng trên bằng:
```mermaid
  s3 -->|"A7 · trợ lý AI bật, G10 đã có nháp"| a7["SCR-10 điền nháp AI, nhãn Nháp AI<br/>= G10 SCR-07"]
  a7 --> a7x{{"→ G10 · UC-05 duyệt, Soạn lại, Hữu ích / Chưa tốt"}}
  s3 -->|"A7 · trợ lý AI bật, chưa có nháp"| a7b["SCR-10 danh sách sinh sẵn<br/>+ nút Soạn bằng AI, G10 SCR-07 #4"]
  a7b -->|"Soạn bằng AI"| a7c{{"→ G10 · UC-05 A1"}}
  s3 -->|"A7 · trợ lý AI bật, Claude Code chưa sẵn sàng"| a7d["SCR-10 danh sách sinh sẵn<br/>thẻ SCR-11 thay chỗ nút Soạn bằng AI, G10 UC-05 A8"]
  a7 --> s4
  a7b --> s4
  a7d --> s4
```
Bảng đối chiếu A7 tách ba dòng tương ứng. Ghi chú brief: "G10 SCR-07 là trạng thái AI của G08 SCR-10, cùng một màn".

**Ai làm:** Flow. SRS G08 A7 (`srs-g08:182`) nên thêm "chưa có nháp → nút 'Soạn bằng AI' (G10 UC-05 A1); Claude Code chưa sẵn sàng → SCR-11 (G10 A8)".

---

#### G08-7 · UC-04 A3 "đang ở Focus → banner SCR-12" — TB (PO chốt)

**Flow đang vẽ** (`g08:660-661`):
```text
  p3 -->|"A3 · đang gõ trong ô nhập hoặc đang ở Focus"| a3["Không tự mở<br/>autoPromptedAt vẫn ghi"]
  a3 --> a3m>"MSG-01 · SCR-12 dạng banner<br/>Đến giờ lên kế hoạch cho hôm nay · Bắt đầu (P) · Bỏ qua hôm nay"]
```
Bảng `g08:722`: `| A3 | Đang gõ / đang ở Focus | Không tự mở, banner | MSG-01 |`

**Nguồn nói** (`srs-g08:259`): `| A3 | Tới giờ khi người dùng đang gõ trong ô nhập hoặc đang ở Focus (G07) | Không tự mở; hiện SCR-12 dạng banner MSG-01; `autoPromptedAt` vẫn ghi `[giả định]` |`
(`IA:35`): `| **Toàn cửa sổ** | Đăng nhập, onboarding, Focus mode | Không có khung |`
(`IA:121`): `| Focus mode | F; sidebar Focus | Ẩn sidebar và panel phải. Esc / nút thoát về màn trước, timer vẫn chạy (IA-03) |`
(`IA:67`): `**Banner** nằm ở đầu vùng chính, **tối đa một** cùng lúc, theo thứ tự ưu tiên (IA-17)`

**Không ổn ở chỗ:** Flow vẽ đúng SRS, nhưng SRS viết trước IA. Theo IA-03, Focus mode chiếm trọn cửa sổ, không có khung ba vùng, nên không có "đầu vùng chính" để đặt banner; SCR-12 dạng banner cũng không nằm trong thứ tự ưu tiên IA-17. Designer G08 sẽ vẽ một banner không có chỗ đặt trong màn Focus của G07; đồng thời `autoPromptedAt` đã ghi nên lượt tự mở duy nhất trong ngày bị dùng mất mà người dùng có thể không thấy gì. IA thắng vì IA mục 13 là nơi ghi ngược vào SRS.

**Sửa:** PO chốt một trong hai: (a) đang ở Focus → chỉ gửi thông báo Windows + chấm nhắc sidebar, banner SCR-12 hiện khi thoát Focus về khung app; **hoặc** (b) đang ở Focus → không coi là "đã nhắc", `autoPromptedAt` chưa ghi, tự mở khi thoát Focus. Mặc định đề xuất: (a), vì đơn giản và nhất quán với "tối đa 1 lần / ngày". Sau đó sửa SRS A3 (`srs-g08:259`) và tách nhánh flow: "đang gõ → banner SCR-12" / "đang ở Focus → thông báo Windows, banner khi thoát Focus". Thêm SCR-12 banner vào thứ tự ưu tiên IA-17 (đã có ở ghi chú dòng 829).

**Ai làm:** PO, rồi SRS, rồi Flow.

---

#### G08-8 · Tự mở Daily planning khi app chạy ẩn ở khay — TB (PO chốt)

**Flow đang vẽ** (`g08:619-620, 627`):
```text
  p3[["Client đang mở, hoặc lần đầu mở app sau giờ plan, gọi RitualGet<br/>server trả autoOpen = true, ghi autoPromptedAt nguyên tử"]]
  s1["SCR-01 wizard Daily planning tự mở<br/>thay vùng chính"]
  start ==> p1 ==> p2 ==> m1 ==> p3 ==> s1 ==> x1 ==> ok
```

**Nguồn nói** (`srs-g08:249`): `| 3 | Hệ thống | Client đang mở (hoặc lần đầu mở app sau giờ plan) gọi [RitualGet]; server trả `autoOpen = true` và ghi `autoPromptedAt` nguyên tử |`
(`IA:128`): `**Bấm ×** luôn thu app về khay, có timer hay không.`
(`IA:131`): `**Tự chạy khi Windows khởi động**: bật mặc định, chạy ẩn ở khay`
(`IA:133`): `**Mở lại cửa sổ**: luôn vào Home ở hôm nay với view cuối; … Wizard ritual tự mở thì thay vùng chính.`

**Không ổn ở chỗ:** Theo IA-05 (chốt sau SRS), app mặc định đang chạy nền ở khay từ lúc Windows khởi động. "Client đang mở" lúc này là đúng theo nghĩa tiến trình, nên client sẽ gọi `RitualGet`, server trả `autoOpen = true` và ghi `autoPromptedAt` trong khi **cửa sổ chưa hiện**. Lượt tự mở duy nhất trong ngày bị tiêu mất; khi người dùng mở cửa sổ, chỉ còn chấm nhắc. Flow vẽ theo SRS nên không sai so với SRS, nhưng SRS chưa tính tới trạng thái khay; designer cần biết wizard có tự nhảy ra khi người dùng mở cửa sổ từ khay hay không.

**Sửa:** PO chốt. Mặc định đề xuất: client chỉ gọi `RitualGet` với mục đích tự mở khi **cửa sổ đang hiện** (hoặc ngay lúc cửa sổ được đưa lên từ khay / thông báo Windows, IA-10); khi cửa sổ ẩn thì chỉ có thông báo Windows MSG-01 + chấm nhắc, chưa ghi `autoPromptedAt`. Sau đó sửa SRS bước 3 (`srs-g08:249`): "Client có cửa sổ đang hiện (hoặc lần đầu hiện cửa sổ sau giờ plan, kể cả từ khay / thông báo Windows) gọi [RitualGet]…". Flow: đổi chữ nút `p3` theo, thêm nhánh "cửa sổ ở khay → thông báo Windows, chờ cửa sổ hiện".

**Ai làm:** PO, rồi SRS, rồi Flow.

---

#### G08-9 · Thiếu điểm vào từ onboarding "Daily planning có hướng dẫn" — TB

**Flow đang vẽ** (`g08:22, 28`):
```text
**Mở đầu:** phím P, sidebar "Daily planning", nút "Plan" trên cột ngày D ≥ hôm nay, hoặc lời nhắc MSG-01 (UC-04).
  start(["Sidebar, phím P, nút Plan trên cột D<br/>hoặc lời nhắc MSG-01"])
```

**Nguồn nói** (`docs/features/srs-g01-tai-khoan.md:48`, BR-11): `Hoàn tất → mở Daily planning hôm nay ở chế độ có hướng dẫn (G08).`
(`srs-g01:254`): `| 7 | Hệ thống | Tạo task (G02); gọi [OnboardingComplete]; mở Daily planning hôm nay ở chế độ có hướng dẫn (G08) |`
(`docs/design-brief/flow/g01-tai-khoan.md:522`): `x2{{"→ G08 · UC-01<br/>Daily planning hôm nay, có hướng dẫn"}}`
SRS G08: không có cụm "có hướng dẫn" ở bất kỳ UC / SCR nào; mục 6 Điểm vào (`srs-g08:309-318`) không có dòng onboarding.

**Không ổn ở chỗ:** G01 trỏ sang một trạng thái của wizard mà G08 không định nghĩa (hướng dẫn là gì: popover "Đây là gì?" tự mở? coach-mark? bỏ qua bước?). Flow G08 không có điểm vào này, nên designer G08 không vẽ trạng thái "lần đầu" và designer G01 không có đích để nối. Người dùng mới — đối tượng quan trọng nhất của ritual — là người duy nhất đi qua đường này.

**Sửa:** SRS G08 trước: thêm dòng vào mục 6 Điểm vào `| Kết thúc onboarding (G01 BR-11) | ✓ | … | Ngày = hôm nay; chế độ có hướng dẫn: … |` và một nhánh A# ở UC-01 mô tả "chế độ có hướng dẫn" (PO chốt nội dung; mặc định đề xuất: popover "Đây là gì?" (SCR-01 #3) tự mở ở mỗi bước lần đầu, tắt sau khi hoàn tất lần đầu). Rồi Flow: thêm "kết thúc onboarding G01" vào nút `start` và một nhánh `a_onb` từ `s1`.

**Ai làm:** PO (nội dung hướng dẫn), SRS, rồi Flow.

---

#### G08-10 · E1 và "xem phiên ngày đã qua" không có đường tới — TB (PO chốt)

**Flow đang vẽ** (`g08:126-127`):
```text
  p1 -.->|"E1 · D < hôm nay, chưa có phiên"| e1m>"MSG-20 · Toast<br/>Không lên kế hoạch được cho ngày đã qua"]
  e1m -.-> e1(["Không mở wizard"])
```
Bảng `g08:302`: `| E1 | D < hôm nay, chưa có phiên | Không mở wizard | MSG-20 |`

**Nguồn nói** (`srs-g08:140`): `| E1 | D < hôm nay và chưa có phiên | MSG-20, không mở wizard (BR-02) |`
(`srs-g08:38`, BR-02): `D < hôm nay → chỉ xem phiên đã có, không tạo phiên mới.`
(`prd-g08:138`, AC05): `Mở cho ngày tương lai qua nút "Plan" trên cột ngày được; ngày đã qua chỉ xem bản đã có.`
(`IA:164`, IA-20): `Cột ngày < hôm nay **không** có nút "+ Thêm task" và nút "Plan".`
(`srs-g08:311`, Điểm vào): `| Phím P / O, command menu … | … | Ngày = hôm nay |`

**Không ổn ở chỗ:** Sau IA-20, không còn điểm vào nào mở wizard với D < hôm nay: P / sidebar luôn là hôm nay, nút Plan chỉ có ở cột ≥ hôm nay. Vậy E1 gần như chết (chỉ còn khả năng qua mốc đầu ngày khi đang hover). Ngược lại, PRD AC05 và BR-02 hứa "ngày đã qua chỉ xem bản đã có" nhưng không có điểm vào nào dẫn tới việc xem đó, và flow không vẽ. Designer sẽ hoặc vẽ thừa MSG-20, hoặc bỏ mất màn "xem bản đã chốt của ngày cũ" (SCR-06 / SCR-10 chế độ xem với D < hôm nay).

**Sửa:** PO chốt: có cho xem phiên ngày đã qua ở 1.0 không? Nếu có, điểm vào là gì (mặc định đề xuất: mở task ghi chép ritual trên board → nút "Xem kế hoạch / highlights đã chốt" → SCR-06 / SCR-10 chế độ xem, read-only; đã có dòng "Mở task ghi chép ritual" ở `srs-g08:316`). Nếu không, bỏ AC05 vế sau và BR-02 câu "chỉ xem phiên đã có". Sau đó: SRS thêm nhánh A# "mở từ task ghi chép, D < hôm nay → chế độ xem, không có Lên kế hoạch lại"; flow thêm nhánh và đổi E1 thành "chỉ xảy ra khi qua mốc đầu ngày trong lúc thao tác / lệnh offline gửi muộn".

**Ai làm:** PO, rồi SRS, rồi Flow.

---

#### G08-11 · Bước 2 gọi TimeboxLink nhưng không nối sang G05 UC-10, thiếu nhánh lỗi — TB

**Flow đang vẽ** (`g08:36`):
```text
  p3[["TaskCreate G02, TaskMove G06, TimeboxLink G05, BR-07<br/>day.recomputed G04<br/>RitualUpdate current_step = 3"]]
```
Sơ đồ "Nhánh thay thế và lỗi: trong các bước" (`g08:189-235`) từ `s2` chỉ có A8 (sự kiện đã có task) và hint lịch chưa kết nối; không có nhánh TimeboxLink lỗi.

**Nguồn nói** (`docs/design-brief/flow/g05-lich-timebox.md:972-974`, G05 UC-10 E1):
```text
  p2 -.->|"E1 · sự kiện không còn / tài khoản CAN_KET_NOI_LAI"| e1[["EVENT_NOT_FOUND"]]
  e1 -.-> e1x{{"→ G08 · UC-01 tạo task không có timebox"}}
  e1x -.-> fail(["Task không có timebox liên kết"])
```
(`g05:969`, A1): `a1(["Trả timebox đã có, không tạo thêm<br/>G08 BR-07: một sự kiện một task"])`
(`srs-g08:43`, BR-07): `Kéo sự kiện lịch → tạo task tiêu đề = tên sự kiện, planned = thời lượng sự kiện, kèm **timebox liên kết sự kiện** của G05 (G05 [TimeboxLink], B8)`

**Không ổn ở chỗ:** G05 vẽ tương tác này đầy đủ (UC-10) và trỏ ngược về G08 "tạo task không có timebox", nhưng G08 không có nút sang G05 · UC-10 và không có nhánh nhận lỗi — trái quy ước `_quy-uoc.md` dòng 22 "File khác chỉ có nút sang flow khác trỏ tới đó". Designer G08 không biết bước 2 có trạng thái "task đã tạo nhưng không gắn được giờ" (card không có timebox, có cần toast không?).

**Sửa:** Flow G08, trong sơ đồ "trong các bước":
```mermaid
  s2 -->|"kéo sự kiện lịch vào D, BR-07"| x10{{"→ G05 · UC-10 Tạo timebox liên kết sự kiện"}}
  x10 -.->|"E1 của G05 · sự kiện không còn / cần kết nối lại"| x10f["Task vẫn tạo, không có timebox<br/>chưa có MSG"]
  x10f --> s2
```
Bảng đối chiếu thêm dòng `| – | Kéo sự kiện lịch | → G05 · UC-10; lỗi → task không có timebox | – (chưa có MSG) |`. SRS G08 BR-07 bổ sung một câu: "[TimeboxLink] lỗi (G05 UC-10 E1) → task vẫn tạo, không có timebox, hiện MSG-xx `[cần đặt]`".

**Ai làm:** Flow; SRS thêm một MSG.

---

#### G08-12 · UC-01 bước 1 thiếu nhánh instance lặp trùng series — Thấp

**Flow đang vẽ** (`g08:189-235`): từ `s1["SCR-02 Bước 1 Xem lại hôm qua"]` chỉ có hai nhánh BR-06 (rollover) và A7 (không có task). Trong khi UC-02 có (`g08:381`):
```text
  s2 -->|"A9 · Ngày mai đưa instance lặp vào ngày<br/>đã có instance cùng series"| a9["Instance vào LUU_TRU lý do skipped, QC-06<br/>timebox xử lý như Đưa vào backlog, toast Hoàn tác"]
```

**Nguồn nói** (`srs-g08:42`, BR-06): `Dời "Ngày mai" / phím D (= ngày làm việc kế tiếp theo lịch của task, …) … Instance lặp rơi vào ngày đã có instance cùng series → QC-06. Thao tác áp ngay, có Hoàn tác`
(`QC:141`, QC-06 mục 2): `**Đường tự động hoặc hàng loạt** đưa một instance của S vào ngày đã có instance của S: instance được đưa vào chuyển sang `LUU_TRU` với lý do `skipped`, kèm toast Hoàn tác … Các đường này gồm: rollover, phím D, shutdown "Ngày mai".`

**Không ổn ở chỗ:** Bước 1 Daily planning dùng phím D / "Dời" cho task bị hoãn — đúng đường "phím D" của QC-06. Khi task đó là instance lặp và ngày kế tiếp đã có instance cùng series, task biến mất khỏi danh sách và vào Lưu trữ với toast Hoàn tác. UC-02 vẽ (A9) nhưng UC-01 không, nên designer vẽ bước 1 thiếu toast này; SRS không đặt mã A# riêng cho UC-01.

**Sửa:** Flow, thêm vào sơ đồ "trong các bước":
```mermaid
  s1 -->|"BR-06 · Dời (D) đưa instance lặp vào ngày<br/>đã có instance cùng series, QC-06"| q6["Instance vào LUU_TRU lý do skipped<br/>timebox như Đưa vào backlog, toast Hoàn tác"]
  q6 --> s1
```
Nhãn phải giống hệt A9 của UC-02 (quy ước `_quy-uoc.md` dòng 123). Bảng đối chiếu thêm dòng `| BR-06 | Dời đưa instance lặp vào ngày trùng series | LUU_TRU (skipped), Hoàn tác | – |`. Đề xuất SRS đặt mã A16 cho rõ.

**Ai làm:** Flow (SRS thêm mã A16 nếu muốn).

---

#### G08-13 · Ghi chú Esc bỏ sót UC-02 A5 và PRD — Thấp

**Flow đang vẽ** (`g08:824`):
```text
- **Esc trong wizard mâu thuẫn.** BR-20 ghi "Esc thoát (lưu tiến độ)"; UC-01 A5 "Esc / × giữa chừng"; BR-21 "đóng wizard shutdown (Esc / ×)". SCR-01 #7 và IA-16 chốt Esc **không** thoát wizard. Flow vẽ theo IA (chỉ ×). Đề xuất sửa BR-20, UC-01 A5, BR-21.
```

**Nguồn nói** (`srs-g08:180`, UC-02 A5): `| A5 | Esc / × giữa chừng | Như UC-01 A5; toast MSG-16 (phím O). Sau mốc đầu ngày D+1 → coi là bỏ dở (BR-21): phiên `QUA_HAN`, rollover chạy ngay |`
(`prd-g08:343`): `- "Bỏ dở" phiên shutdown sau mốc đầu ngày có bao gồm việc đóng wizard (Esc / ×) không, hay chỉ "Bỏ qua hôm nay"? (Đề xuất: có, `[giả định]`.)`
(`srs-g08:336`, SCR-01 #7): `Esc **không** thoát wizard (IA-16)`

**Không ổn ở chỗ:** Ghi chú đúng nhưng liệt kê thiếu hai chỗ còn ghi "Esc / ×": UC-02 A5 và câu hỏi mở trong PRD. Ai sửa SRS theo ghi chú sẽ bỏ sót, SRS vẫn tự mâu thuẫn.

**Sửa:** Flow, sửa câu cuối ghi chú thành: "Đề xuất sửa BR-20, UC-01 A5, UC-02 A5, BR-21 và câu hỏi mở cuối PRD G08 (dòng 343) thành chỉ ×."

**Ai làm:** Flow (ghi chú), sau đó SRS / PRD.

---

#### G08-14 · "Bước shutdown chưa kiểm chứng" đã lỗi thời — Thấp

**Flow đang vẽ** (`g08:319`):
```text
Các bước Daily shutdown là **đề xuất, chưa kiểm chứng trên Sunsama** (SRS).
```

**Nguồn nói** (`docs/research/kiem-chung-sunsama-chrome.md:137`): `- **Shutdown là *một trang* highlights (#26-C1):**`
(`kiem-chung-sunsama-chrome.md:141`): `- **Không có bước xử lý task chưa xong (#26-C2):** task tự rollover. ⇒ Cần chốt: app giữ SCR-09 (phần tự thêm, khác có chủ đích) hay bỏ?`
(`srs-g08:154`): `Các bước dưới đây là **đề xuất, chưa kiểm chứng trên Sunsama**.`

**Không ổn ở chỗ:** Đã kiểm chứng: Sunsama không có wizard 5 bước, shutdown là một trang highlights, không có bước xử lý task chưa xong. Flow và SRS vẫn ghi "chưa kiểm chứng", nên designer tưởng còn đang chờ dữ liệu, trong khi thật ra đang chờ **PO quyết** giữ 5 bước (khác Sunsama có chủ đích) hay không. Nếu PO bỏ SCR-09 thì UC-02 A2, A3, A9 và BR-16 đều thay đổi.

**Sửa:** Flow: đổi dòng 319 thành "Các bước Daily shutdown là đề xuất, **khác Sunsama có chủ đích** (Sunsama: một trang highlights, không có bước xử lý task chưa xong — `kiem-chung-sunsama-chrome.md` #26-C1, C2). PO chốt giữ SCR-09 hay bỏ." và thêm vào Ghi chú cho brief. SRS `srs-g08:154` sửa cùng câu.

**Ai làm:** PO chốt; Flow và SRS sửa chữ.

---

### Ghi chú cho brief — cần thêm

Dán vào cuối mục "Ghi chú cho brief G08" (`g08:823+`):

- **Nút chính khi D > hôm nay.** UC-01 A6: "Bắt đầu ngày" đổi thành "Xong", không chuyển trang, không gọi RolloverEnsure. SCR-07 #6 chưa liệt kê nhãn "Xong". Flow vẽ kết thúc riêng; brief cần trạng thái nút thứ ba.
- **Kết quả RolloverEnsure ở bước 1.** G06 BR-19 trả `DANG_CHAY` / `CHO_SHUTDOWN` / `ROLLOVER_FAILED` (THAT_BAI được chạy bù ngay trong request). SRS G08 BR-06 chỉ nói `CHO_SHUTDOWN` / `THAT_BAI`. Flow gộp các trường hợp này vào MSG-32; banner lỗi rollover thuộc G04 MSG-27 (IA-17). Cần PO chốt bước 1 có nút "Thử lại" riêng không.
- **Bước Highlights có 4 trạng thái khi trợ lý AI bật** (G10 UC-05): có nháp AI; chưa có nháp → nút "Soạn bằng AI"; Claude Code chưa sẵn sàng → thẻ SCR-11 thay chỗ nút; đang soạn / lỗi → MSG-05 + "Thử lại". G10 SCR-07 là trạng thái AI của G08 SCR-10, cùng một màn. SRS G08 A7 mới nói trạng thái đầu.
- **Nhắc Daily planning khi đang ở Focus.** UC-04 A3 hiện banner SCR-12, nhưng Focus toàn cửa sổ không có vùng banner (IA-03). Cần PO chốt: thông báo Windows + banner khi thoát Focus (đề xuất), hay chưa ghi `autoPromptedAt`.
- **Tự mở khi app chạy ẩn ở khay (IA-05).** UC-04 bước 3 "client đang mở gọi RitualGet" sẽ tiêu lượt tự mở duy nhất trong ngày khi cửa sổ đang ẩn. Cần PO chốt: chỉ ghi `autoPromptedAt` khi cửa sổ đang hiện; ở khay chỉ thông báo Windows + chấm nhắc (đề xuất).
- **Điểm vào từ onboarding.** G01 BR-11 mở "Daily planning hôm nay ở chế độ có hướng dẫn"; SRS G08 chưa định nghĩa chế độ này và chưa có điểm vào. Cần PO chốt nội dung hướng dẫn (đề xuất: popover "Đây là gì?" tự mở ở mỗi bước lần đầu).
- **Xem phiên ngày đã qua.** Sau IA-20 không còn điểm vào mở wizard với D < hôm nay, nên E1 (MSG-20) gần như không xảy ra; ngược lại PRD AC05 / BR-02 "ngày đã qua chỉ xem bản đã có" chưa có điểm vào và chưa vẽ. Cần PO chốt (đề xuất: từ task ghi chép ritual → chế độ xem).
- **Kéo sự kiện lịch ở bước 2 đi qua G05 UC-10.** G05 UC-10 E1 trả về "task không có timebox"; G08 chưa có nhánh nhận và chưa có MSG cho trường hợp này.
- **Shutdown 5 bước là khác Sunsama có chủ đích**, không còn "chưa kiểm chứng": Sunsama là một trang highlights, không có bước xử lý task chưa xong (`kiem-chung-sunsama-chrome.md` #26-C1, C2). PO chốt giữ SCR-09 hay bỏ.
- (Sửa dòng Esc hiện có) thêm UC-02 A5 và câu hỏi mở cuối PRD G08 vào danh sách chỗ cần sửa.


---

## G10 Trợ lý AI

Số # trùng bảng mục 3 "G10" của `docs/review/review-flow-vs-srs-2026-11-05.md`. Viết tắt: `g10` = `docs/design-brief/flow/g10-tro-ly-ai.md`, `g08` = `docs/design-brief/flow/g08-daily-rituals.md`, `srs-g10` = `docs/features/srs-g10-tro-ly-ai.md`, `srs-g08` = `docs/features/srs-g08-daily-rituals.md`, `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`, `ADR-0009` = `docs/adr/0009-rui-ro-dieu-khoan-claude-code-va-che-do-api-key.md`.

---

#### G10-1 · UC-02 thiếu nhánh nút "Dừng" khi agent đang chạy — Cao

**Flow đang vẽ** (`g10:133`, happy case; `g10:210`, nhánh lỗi):
```text
  s2["SCR-02 #5 Tiến độ<br/>danh sách bước, bộ đếm thời gian<br/>Thường mất 2–4 phút"]
  p2[["Claude Code chạy<br/>SCR-02 #5 Tiến độ"]]
```
Sơ đồ "Nhánh thay thế" (`g10:158-201`) và "Nhánh lỗi" (`g10:205-256`) không có cạnh nào xuất phát từ người dùng bấm "Dừng". Flow G08 lại đang trông chờ vào nó (`g08:124`): `g10 -->|"xong: sang bước 5 Daily plan<br/>lỗi, Dừng, Hoàn tác kế hoạch AI: về bước 1"| s1`.

**Nguồn nói** (`srs-g10:596`, SCR-02 #6): `| 6 | "Dừng" | Button | – | Dừng Claude Code → luồng thủ công; thay đổi đã áp dụng giữ, có "Hoàn tác kế hoạch AI" (BR-09) |`
(`srs-g10:50`, BR-09): `Dừng / `LOI` khi đã có thay đổi áp dụng → giữ các thay đổi đó, báo số thay đổi kèm Hoàn tác cả lượt (D9; áp cho cả Planning Agent và chat)`

**Không ổn ở chỗ:** Agent chạy 2–4 phút và đang ghi thẳng vào board (áp dụng ngay, BR-06). "Dừng" là thao tác duy nhất của người dùng trong suốt thời gian đó, và là nhánh an toàn quan trọng nhất của Planning Agent. SRS mô tả ở SCR-02 #6 và BR-09 nhưng không đặt mã A# cho UC-02, nên flow (đi theo bảng A/E) bỏ sót. Designer sẽ vẽ SCR-02 trạng thái Tiến độ mà không biết bấm Dừng đi đâu, có hỏi xác nhận không, và thông báo nào hiện (SRS cũng không nói MSG nào dùng khi người dùng chủ động dừng). UC-03 chat thì đã vẽ A8 "bấm Dừng" (`g10:350-352`), nên UC-02 thiếu là không nhất quán.

**Sửa:**
1. Flow, sơ đồ "Nhánh lỗi" (vì dùng chung thoi `d1`):
```mermaid
  p2 -->|"SCR-02 #6 · người dùng bấm Dừng"| e1
```
   (nối vào nút `e1[["Dừng Claude Code"]]` hiện có, từ đó qua `d1` "Đã áp dụng thay đổi nào?"). Thêm cạnh riêng từ `dm`: `dm -->|"Dừng"| stopm["Không có MSG riêng, chưa có mã<br/>về G08 bước 1, giữ Điều quan trọng nhất"]`. Bảng đối chiếu thêm dòng `| – (SCR-02 #6) | Bấm Dừng | Như E1: LOI hoặc giữ phần đã áp dụng, về G08 bước 1 | – (chưa có MSG) |`.
2. SRS: thêm A11 vào UC-02: "Bấm 'Dừng' (SCR-02 #6) | Dừng Claude Code; như E1 nhưng không hiện MSG-05; đã áp dụng một phần → MSG-xx 'Đã dừng. {n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác kế hoạch AI' `[cần đặt]`".
3. PO chốt: có hỏi xác nhận trước khi dừng không (Sunsama: nút × dừng ngay). Mặc định đề xuất: không hỏi, vì mọi thay đổi hoàn tác được.

**Ai làm:** Flow (nhánh), SRS (mã A#, MSG), PO (xác nhận).

---

#### G10-2 · E1 / E6 khi agent đã áp dụng một phần: nút "Hoàn tác kế hoạch AI" không có chỗ hiện — Cao

**Flow đang vẽ** (`g10:228, 231-232, 235`):
```text
  d1 -.->|"có"| e1b["Giữ thay đổi, đề xuất DA_AP_DUNG<br/>kèm Hoàn tác kế hoạch AI BR-09"]
  dm -.->|"E1, E2"| e1m>"MSG-05 · Banner<br/>AI đang gặp sự cố. Bạn tiếp tục lập kế hoạch thủ công, nội dung đã nhập vẫn được giữ"]
  dm -.->|"E6"| e6m>"MSG-28 · Banner<br/>Claude Code báo: #quot;{thông báo của Claude Code}#quot;. Bạn tiếp tục thủ công, nội dung đã nhập vẫn được giữ"]
  e1m -.-> fail(["G08 Daily planning thủ công bước 1<br/>Điều quan trọng nhất đưa vào ô Obstacles in my way"])
```

**Nguồn nói** (`srs-g10:211`, E1): `đã áp dụng một phần → giữ, đề xuất `DA_AP_DUNG`, thông báo kèm "Hoàn tác kế hoạch AI" (BR-09); MSG-05; mở Daily planning thủ công (G08) bước 1`
(`srs-g10:790`): `| MSG-05 | Banner | AI đang gặp sự cố. Bạn tiếp tục lập kế hoạch thủ công, nội dung đã nhập vẫn được giữ |`
(`srs-g10:813`): `| MSG-28 | Khung chat / banner | Claude Code báo: "{thông báo của Claude Code}". Bạn tiếp tục thủ công, nội dung đã nhập vẫn được giữ |`
(`srs-g10:812`, để so sánh): `| MSG-27 | … | Claude Code đã dừng giữa chừng. {n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác · Gửi lại |`
(`srs-g08:60`, BR-24): `… bước Daily plan (SCR-06) hiện nút "Hoàn tác kế hoạch AI" → G10 UC-04`
(`srs-g08:383`, SCR-06 #5): `| 5 | "Hoàn tác kế hoạch AI" (bản 1.0) | Button phụ | – | Chỉ hiện khi trợ lý AI đang bật (QC-12), Planning Agent đã áp dụng kế hoạch cho D và còn thay đổi chưa hoàn tác (BR-24); A14 UC-01 |`

**Không ổn ở chỗ:** Với E1 (timeout / lỗi) và E6 (hết hạn mức), khi agent đã kịp tạo / dời vài task, SRS hứa "thông báo kèm Hoàn tác kế hoạch AI", nhưng MSG-05 và MSG-28 không có nút đó và không nói số thay đổi (chỉ MSG-27 cho E7 có). Người dùng bị đưa về **bước 1** của wizard thủ công, trong khi nút "Hoàn tác kế hoạch AI" chỉ tồn tại ở **bước 5** (G08 SCR-06 #5). Vậy người dùng thấy board đã bị AI sửa dở, không biết có bao nhiêu thay đổi và phải đi 4 bước nữa mới có nút hoàn tác. Flow vẽ đúng SRS nên lỗ hổng nằm ở SRS; nút `e1b` của flow đang hứa thứ không màn nào có.

**Sửa:**
1. SRS G10, mục 9: MSG-05 và MSG-28 thêm biến thể khi n > 0: "… nội dung đã nhập vẫn được giữ. {n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác kế hoạch AI" (cùng mẫu với MSG-27). Hoặc, nếu PO muốn giữ câu ngắn: SRS G08 BR-24 / SCR-01 thêm "nút 'Hoàn tác kế hoạch AI' hiện ở header SCR-01 mọi bước khi ngày D có đề xuất Planning Agent `DA_AP_DUNG`". Mặc định đề xuất: cách 1 (sửa MSG), ít chạm G08.
2. Flow: sau khi SRS sửa, nút `e1m` / `e6m` thêm dòng "· Hoàn tác kế hoạch AI (khi n > 0)" và cạnh `e1m -->|"Hoàn tác kế hoạch AI"| a4{{"→ UC-04 mọi thay đổi của đề xuất"}}`.

**Ai làm:** PO chọn cách, SRS, rồi Flow.

---

#### G10-3 · UC-03 E9 "Nút Trợ lý ẩn" trái IA — TB

**Flow đang vẽ** (`g10:391-392`):
```text
  start -.->|"E9 · Claude Code không SAN_SANG"| e9["Nút Trợ lý ẩn<br/>mở từ Command menu thì hiện SCR-11"]
  e9 -.-> e9x{{"→ UC-10"}}
```
Bảng `g10:452`: `| E9 | Claude Code không SAN_SANG | Nút ẩn; Command menu → SCR-11 (UC-10) | MSG-24 / 25 / 26 |`

**Nguồn nói** (`srs-g10:269`, E9): `| E9 | Claude Code không `SAN_SANG` (chưa cài, chưa đăng nhập, phiên bản cũ) | Nút ✨ ẩn; mở từ Command menu → SCR-11 (UC-10) |`
(`srs-g10:66`, BR-25): `Khác `SAN_SANG` → ẩn mọi điểm vào AI (✨, "Plan my day", "Soạn bằng AI", gợi ý task, công cụ MCP), hiện **SCR-11** đúng trạng thái`
(`srs-g10:562`, Điểm vào — cùng SRS): `| Nút ✨ "Trợ lý" ở cụm dưới sidebar (không nổi ở góc màn hình) | ✓ | … Claude Code không sẵn sàng → SCR-11 ngay trong mục này |`
(`IA:50`): `| Công cụ (dưới cùng) | ✨ Trợ lý | Ctrl+J | Mục Trợ lý ở panel phải (IA-08) |`
(`IA:86`): `| Trợ lý | Ctrl+J; ✨ ở sidebar; Ctrl+K "Hỏi trợ lý" | Khung chat. Chưa đồng ý → dialog đồng ý (G10 SCR-10). Claude Code chưa sẵn sàng → thẻ hướng dẫn cài (G10 SCR-11) ngay trong mục này (IA-08) |`
(`IA:203`, IA-01): `Sidebar có cụm dưới cùng: ✨ Trợ lý, chuông, avatar. Không có nút ✨ nổi ở góc màn`

**Không ổn ở chỗ:** IA (duyệt 04/11, ghi ngược vào SRS G10 ở mục 13 dòng 237 nhưng chỉ sửa điểm vào, chưa sửa E9 / BR-25) chốt ✨ là mục cố định của sidebar; khi Claude Code chưa sẵn sàng, bấm ✨ / Ctrl+J / Ctrl+K vẫn mở mục Trợ lý ở panel phải và thấy thẻ SCR-11 ở đó. SRS E9 và BR-25 vẫn ghi "ẩn ✨", chỉ cho vào SCR-11 qua Command menu. Flow vẽ theo E9 nên sidebar của designer sẽ có một mục lúc có lúc không, và Ctrl+J không có đích. IA thắng (IA là nguồn về "màn nào ở đâu", SRS chỗ này chưa được ghi ngược).

**Sửa:**
1. SRS G10: E9 (`srs-g10:269`) đổi thành "✨ vẫn hiện ở sidebar; ✨ / Ctrl+J / Ctrl+K 'Hỏi trợ lý' mở mục Trợ lý ở panel phải với thẻ SCR-11 (UC-10) thay khung chat". BR-25 (`srs-g10:66`) đổi "ẩn mọi điểm vào AI (✨, …)" thành "điểm vào AI trong màn (Plan my day, Soạn bằng AI, gợi ý task, công cụ MCP) ẩn hoặc thay bằng SCR-11; ✨ ở sidebar giữ nguyên và dẫn tới SCR-11 (IA-08)". Đồng thời sửa bước 1 UC-03 (`srs-g10:232`) "nút ✨ góc dưới" thành "nút ✨ ở cụm dưới sidebar" (ghi chú 2 của flow đã nêu).
2. Flow: đổi `e9` thành `e9["Mục Trợ lý ở panel phải hiện SCR-11<br/>thay khung chat; ✨ vẫn ở sidebar"]`; bảng đối chiếu E9 "Kết thúc ở: SCR-11 trong mục Trợ lý (UC-10)".

**Ai làm:** SRS rồi Flow.

---

#### G10-4 · Banner AI (MSG-05 / 06 / 27 / 28) chưa có chỗ trong thứ tự banner IA-17 — TB (PO chốt)

**Flow đang vẽ** (`g10:218, 231-233, 396`):
```text
  u1 -.->|"E4 · mất mạng"| e4m>"MSG-06 · Banner<br/>Mất kết nối. AI cần mạng để hoạt động"]
  dm -.->|"E1, E2"| e1m>"MSG-05 · Banner<br/>AI đang gặp sự cố. …"]
  dm -.->|"E6"| e6m>"MSG-28 · Banner<br/>Claude Code báo: …"]
  dm -.->|"E7"| e7m>"MSG-27 · Banner<br/>Claude Code đã dừng giữa chừng. …"]
  p1 -.->|"E5 · mất mạng"| e5m>"MSG-06 · Banner<br/>Mất kết nối. AI cần mạng để hoạt động"]
```

**Nguồn nói** (`srs-g10:790-791, 812-813`): MSG-05 "Banner", MSG-06 "Banner", MSG-27 / MSG-28 "Khung chat / banner".
(`IA:67-71`): `**Banner** nằm ở đầu vùng chính, **tối đa một** cùng lúc, theo thứ tự ưu tiên (IA-17): 1. Offline (G04 SCR-01 #5) … 4. Lệch timezone (G01 SCR-13)`
(`IA:219`, IA-17): `Tối đa một banner, theo thứ tự ưu tiên; banner chờ vào trung tâm thông báo`

**Không ổn ở chỗ:** IA-17 liệt kê đúng 4 banner của vùng chính; bốn banner của G10 không có trong danh sách nên không biết xếp thứ mấy, có vào trung tâm thông báo không. Riêng MSG-06 (mất mạng) sẽ luôn trùng với banner Offline của G04 (ưu tiên 1) — hai banner cùng nói "mất kết nối". Trong UC-02, lỗi xảy ra **bên trong wizard** (SCR-02 nằm trong wizard, IA mục 3 dòng 65), còn UC-03 lỗi nằm trong **panel phải**; đặt banner ở "đầu vùng chính" cho lỗi của panel phải là sai chỗ. Flow vẽ đúng SRS nhưng designer sẽ không biết đặt bốn banner này ở đâu.

**Sửa:** PO chốt. Mặc định đề xuất: (a) MSG-05 / 27 / 28 của UC-02 là **inline trong SCR-02** (chỗ tiến độ #5), không phải banner vùng chính; của UC-03 là inline trong khung chat (SCR-04 #11 đã có "Thông báo lỗi Claude Code · Inline · MSG-27 / MSG-28", `srs-g10:628` — tức SRS đã tự mâu thuẫn với mục 9); (b) MSG-06 bỏ, dùng banner Offline chung của G04, và ở chỗ nút Plan my day / ô chat chỉ disable kèm chú thích ngắn (SCR-02 #3 đã ghi "Disabled khi offline"). Sau đó sửa cột "Nơi hiện" mục 9 SRS G10 và đổi chữ "Banner" trong 5 nút flow thành "Inline SCR-02" / "Inline SCR-04".

**Ai làm:** PO, rồi SRS, rồi Flow. Thêm vào Ghi chú G10 (chưa có).

---

#### G10-5 · Toast MSG-29 của phiên terminal khi app ở khay — TB (PO chốt)

**Flow đang vẽ** (`g10:1111`):
```text
  m1>"MSG-29 · Toast<br/>Claude Code (terminal) đã thay đổi {n} task · Xem · Hoàn tác"]
```
và `g10:1116`: `start ==> u1 ==> p1 ==> p2 ==> p3 ==> m1 ==> s1 ==> u2 ==> ok` — toast là bước bắt buộc của happy case.

**Nguồn nói** (`srs-g10:511`): `| 5 | App | Toast MSG-29 "Claude Code (terminal) đã thay đổi {n} task · Xem · Hoàn tác" (gộp theo phiên); board, lịch cập nhật; phiên hiện ở SCR-12 |`
(`srs-g10:69`, BR-28): `Thay đổi áp dụng ngay → toast MSG-29 (gộp theo phiên, tối đa 1 toast / 10 giây `[giả định]`)`
(`IA:128`): `**Bấm ×** luôn thu app về khay, có timer hay không.`
(`IA:129`): `Lý do: phím toàn cục (D11), nhắc ritual bằng thông báo Windows (D12) và MCP local cho Claude Code trong terminal (G10 UC-11) đều cần app đang chạy.`

**Không ổn ở chỗ:** IA-05 thiết kế đúng để UC-11 chạy khi app ở khay — tức là trường hợp **phổ biến** của UC-11 là người dùng đang ở terminal, cửa sổ app thu về khay. Khi đó toast trong app không ai thấy; người dùng không biết AI vừa đổi n task và không có đường "Hoàn tác" nhanh. SRS G10 viết trước IA-05 nên chỉ có toast. Flow vẽ đúng SRS nhưng designer cần biết có thông báo Windows hay không (và bấm vào thì mở SCR-12 theo IA-10).

**Sửa:** PO chốt. Mặc định đề xuất: cửa sổ đang hiện → toast MSG-29 như hiện tại; cửa sổ ở khay → thông báo Windows cùng nội dung, bấm vào đưa cửa sổ lên và mở SCR-12 (IA-10); gộp theo phiên như BR-28. Sau đó SRS bước 5 (`srs-g10:511`) và BR-28 thêm vế "cửa sổ ở khay → thông báo Windows"; flow thêm thoi "Cửa sổ đang hiện?" trước `m1`, nhánh "ở khay" → `m1w>"MSG-29 · Thông báo Windows<br/>…"]` → `s1`.

**Ai làm:** PO, rồi SRS, rồi Flow. Thêm vào Ghi chú G10.

---

#### G10-6 · E1 ghi "Obstacles in my way", ô này ở bước 5 — Thấp

**Flow đang vẽ** (`g10:235`):
```text
  e1m -.-> fail(["G08 Daily planning thủ công bước 1<br/>Điều quan trọng nhất đưa vào ô Obstacles in my way"])
```

**Nguồn nói** (`srs-g10:211`, E1): `mở Daily planning thủ công (G08) bước 1; nội dung "Điều quan trọng nhất" đưa vào ô "Obstacles in my way"`
(`srs-g08:380`, SCR-06 #2): `| 2 | "Trở ngại" | Text nhiều dòng | Không | 0–5.000 ký tự; quá → MSG-22 |`
(`g08:825`, ghi chú đã có): `Ngoài ra G10 UC-02 E1 gọi ô là "Obstacles in my way", G08 gọi là "Trở ngại".`

**Không ổn ở chỗ:** "Obstacles in my way" là nhãn của Sunsama, không có trong SRS G08. Ô tương ứng là "Trở ngại" ở SCR-06, **bước 5** của wizard, nhưng E1 đưa người dùng về **bước 1** — tức nội dung được đổ vào một ô 4 bước sau, người dùng không thấy ngay và có thể gõ đè. Designer G10 sẽ tìm một ô không tồn tại; designer G08 không biết ô Trở ngại có thể được điền sẵn từ G10.

**Sửa:** SRS G10 E1 (`srs-g10:211`): "nội dung 'Điều quan trọng nhất' được điền sẵn vào ô 'Trở ngại' (G08 SCR-06 #2, bước 5), có nhãn 'Từ Plan my day'". Flow: nút `fail` đổi thành `"G08 Daily planning thủ công bước 1<br/>Điều quan trọng nhất điền sẵn vào ô Trở ngại, G08 SCR-06 #2 bước 5"`. SRS G08 SCR-06 #2 thêm "điền sẵn từ G10 UC-02 E1 khi có".

**Ai làm:** SRS (G10, một dòng G08) rồi Flow.

---

#### G10-7 · UC-05 highlights dùng MSG-05 / MSG-27 viết cho Planning Agent — Thấp

**Flow đang vẽ** (`g10:655-657`):
```text
  p2 -.->|"E1 · Claude Code lỗi / > 10 giây<br/>khi người dùng đang mở bước"| e1m>"MSG-05 · SCR-07 #6<br/>AI đang gặp sự cố. Bạn tiếp tục lập kế hoạch thủ công, nội dung đã nhập vẫn được giữ"]
  p2 -.->|"E1 · Claude Code bị đóng giữa chừng"| e1c>"MSG-27 · SCR-07 #6<br/>Claude Code đã dừng giữa chừng. {n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác · Gửi lại"]
  e1m -.-> e1(["Danh sách việc đã xong để biên tập tay G08<br/>nút Thử lại"])
```

**Nguồn nói** (`srs-g10:345`, UC-05 E1): `| E1 | Claude Code lỗi / bị đóng giữa chừng / > 10 giây khi người dùng đang mở bước | MSG-05 (bị đóng: MSG-27); hiện danh sách việc đã xong để biên tập tay (G08); "Thử lại" |`
(`srs-g10:790`): `MSG-05 … AI đang gặp sự cố. Bạn tiếp tục lập kế hoạch thủ công, nội dung đã nhập vẫn được giữ`
(`srs-g10:812`): `MSG-27 … Claude Code đã dừng giữa chừng. {n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác · Gửi lại`
(`srs-g10:658`, SCR-07 #6): `| 6 | Trạng thái đang soạn / lỗi | Inline | "Đang soạn…" / MSG-05 + "Thử lại" |`

**Không ổn ở chỗ:** Highlights là lượt chỉ ghi nháp, không "lập kế hoạch", không có "thay đổi đã áp dụng", không có "Hoàn tác" hay "Gửi lại" (UC-05 dùng "Thử lại"). Hai câu này hiện trong bước Highlights của Daily shutdown sẽ sai ngữ cảnh và gợi ý nút không tồn tại. Flow chép nguyên văn đúng quy ước nên lỗi nằm ở SRS.

**Sửa:** SRS G10 mục 9 thêm MSG-33 "Inline SCR-07 · Chưa soạn được nháp highlights. Bạn dùng danh sách việc đã xong · Thử lại" dùng cho cả ba trường hợp E1 (lỗi / bị đóng / quá 10 giây); UC-05 E1 và SCR-07 #6 trỏ sang MSG-33. Flow: gộp `e1m` và `e1c` thành một nút MSG-33.

**Ai làm:** SRS rồi Flow.

---

#### G10-8 · UC-05 A4 trỏ tới "trạng thái rỗng của G08" không tồn tại ở SCR-10 — Thấp

**Flow đang vẽ** (`g10:608`):
```text
  p1 -->|"A4 · ngày không có task xong"| a4(["Không soạn<br/>SCR-07 trạng thái rỗng của G08"])
```
Bảng `g10:687`: `| A4 | Ngày không có task xong | Không soạn, trạng thái rỗng G08 | – |`

**Nguồn nói** (`srs-g10:335`, A4): `| A4 | Ngày không có task xong | Không soạn; SCR-07 hiện trạng thái rỗng của G08 |`
(`srs-g08:418`, SCR-10 #1): `| 1 | Highlights | Rich text | Không | Sinh sẵn theo BR-17; 0–5.000 ký tự; quá → MSG-22 |` — SCR-10 (`srs-g08:414-420`) chỉ có 3 thành phần, không có "Trạng thái rỗng".
(`srs-g08:404`, SCR-08 #5): `| 5 | Trạng thái rỗng | Empty state | MSG-18 |` — MSG-18 "Hôm nay chưa có task nào xong" thuộc bước 1 Việc đã xong.

**Không ổn ở chỗ:** Trạng thái rỗng duy nhất của shutdown nằm ở SCR-08 (bước 1), không ở SCR-10 (bước 3 Highlights). Khi không có task xong, bước 3 theo BR-17 chỉ là ô rich text trống (danh sách sinh sẵn rỗng). Designer G10 sẽ đi tìm một empty state G08 chưa vẽ; designer G08 không biết SCR-10 cần empty state.

**Sửa:** Chọn một: (a) SRS G10 A4 sửa thành "Không soạn; SCR-07 không hiện nhãn AI, ô highlights trống theo G08 BR-17 (G08 SCR-10 không có trạng thái rỗng)"; hoặc (b) SRS G08 SCR-10 thêm #4 "Trạng thái rỗng · Empty state · MSG-18 (không có task xong)". Mặc định đề xuất (b), vì ô trống không giải thích gì cho người dùng. Flow: nút `a4` đổi theo lựa chọn.

**Ai làm:** SRS (G10 hoặc G08) rồi Flow.

---

#### G10-9 · UC-11 "đóng app" không khớp với × thu về khay — Thấp

**Flow đang vẽ** (`g10:1153, 1156`):
```text
  start -.->|"E1 · app không mở / chưa đăng nhập"| e1(["Claude Code không kết nối được McpServer<br/>không có thay đổi"])
  p3 -.->|"E3 · tắt trợ lý / rút lại đồng ý / đóng app giữa phiên"| e3[["McpServer cắt phiên<br/>thay đổi đã áp dụng giữ, hoàn tác được"]]
```
Bảng `g10:1191, 1193`: `| E1 | App không mở / chưa đăng nhập | …` và `| E3 | Tắt trợ lý / rút đồng ý / đóng app giữa phiên | …`

**Nguồn nói** (`srs-g10:528`, E1): `| E1 | App không mở / chưa đăng nhập | Claude Code không kết nối được [McpServer]; không có thay đổi |`
(`srs-g10:530`, E3): `| E3 | Người dùng tắt trợ lý / rút lại đồng ý / đóng app giữa phiên | [McpServer] cắt phiên; …`
(`srs-g10:69`, BR-28): `App đóng / đăng xuất → [McpServer] tắt, Claude Code không còn thấy công cụ của app`
(`IA:128`): `**Bấm ×** luôn thu app về khay, có timer hay không. … Cài đặt Chung có lựa chọn "Bấm × để thoát hẳn" (mặc định tắt).`
(`IA:129`): `Lý do: … MCP local cho Claude Code trong terminal (G10 UC-11) đều cần app đang chạy.`
(`IA:130`): `Menu chuột phải: Mở app · Thêm task (Ctrl+Shift+A) · Bật / dừng timer (kèm tên task) · Thoát.`

**Không ổn ở chỗ:** Với người dùng Windows, "đóng app" = bấm ×. Theo IA-05, × chỉ thu về khay và MCP vẫn chạy — phiên terminal **không** bị cắt. Chỉ "Thoát" (menu khay / avatar → Thoát app, hoặc bật "Bấm × để thoát hẳn") mới tắt McpServer. Nhãn "đóng app" trong E1 / E3 làm designer (và người viết hướng dẫn SCR-09 #13) hiểu sai điều kiện; SRS viết trước IA-05.

**Sửa:** Flow: E1 đổi nhãn thành `"E1 · app chưa chạy (đã Thoát) / chưa đăng nhập"`, E3 thành `"E3 · tắt trợ lý / rút lại đồng ý / Thoát app giữa phiên<br/>× chỉ thu về khay, phiên vẫn chạy IA-05"`. SRS G10 E1, E3 (`srs-g10:528, 530`) và BR-28 (`srs-g10:69`) đổi "đóng app" thành "thoát app (khay / avatar → Thoát; × chỉ thu về khay, IA-05)". SCR-09 #13 ghi chú "App phải đang mở" đổi thành "App phải đang chạy (kể cả ở khay)".

**Ai làm:** Flow; SRS sửa chữ.

---

#### G10-10 · Ghi chú chưa nhắc phương án dự phòng ADR-0009 — Thấp

**Flow đang vẽ** (`g10:1274-1284`): 9 ghi chú, không có mục nào về cách đăng nhập của Claude Code (gói hay API key). UC-10 (`g10:1009-1095`) chỉ có 4 trạng thái của SRS mục 4.3.

**Nguồn nói** (`ADR-0009:19`): `- Cần một cách phát hiện Claude Code đang đăng nhập bằng gói hay bằng API key, để bật phương án dự phòng khi cần (`[cần kiểm chứng]` khi làm G10).`
(`ADR-0009`, đoạn đầu): `**Phương án dự phòng:** app chỉ bật AI khi Claude Code đăng nhập bằng **API key của người dùng** … app chỉ hướng dẫn, **không nhận, không đọc, không lưu key hay token**`

**Không ổn ở chỗ:** Nếu phương án dự phòng được bật, UC-10 có thêm một trạng thái Claude Code mới (ví dụ `DANG_NHAP_BANG_GOI` → điểm vào AI ẩn, SCR-11 với thông báo mới "Đăng nhập Claude Code bằng API key để bật trợ lý"), và SCR-09 #12 / SCR-11 cần một biến thể nữa. SRS G10 và flow chưa chuẩn bị chỗ cho trạng thái này; designer nên biết để SCR-11 chứa được thông báo thứ tư mà không phải vẽ lại.

**Sửa:** Flow, thêm ghi chú số 10: "**Dự phòng ADR-0009.** Nếu Anthropic chặn đường đăng nhập bằng gói, UC-10 có thêm trạng thái 'đăng nhập bằng gói, chưa có API key' → ẩn điểm vào AI, SCR-11 với MSG mới hướng dẫn đăng nhập bằng API key (app không nhận / lưu key). SRS chưa có trạng thái này `[cần kiểm chứng]`; brief SCR-11 nên để chỗ cho thông báo thứ tư." Không cần sửa sơ đồ cho tới khi PO bật dự phòng.

**Ai làm:** Flow (ghi chú).

---

### Ghi chú cho brief — cần thêm

Dán vào cuối mục "Ghi chú cho brief G10" (`g10:1274+`):

10. **Nút "Dừng" của Planning Agent chưa có mã A#.** SCR-02 #6 và BR-09 mô tả, nhưng UC-02 không có nhánh; không có MSG cho trường hợp người dùng chủ động dừng khi đã áp dụng một phần. Sơ đồ nối Dừng vào thoi "Đã áp dụng thay đổi nào?" như E1. Cần PO chốt có hỏi xác nhận trước khi dừng không (đề xuất: không).
11. **E1 / E6 đã áp dụng một phần: "Hoàn tác kế hoạch AI" không có chỗ hiện.** MSG-05 và MSG-28 không có nút; người dùng về G08 bước 1 trong khi nút chỉ ở bước 5 (G08 SCR-06 #5). Đề xuất thêm vế "{n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác kế hoạch AI" vào MSG-05 / MSG-28 như MSG-27.
12. **E9 trái IA-01 / IA-08.** SRS E9, BR-25 ghi "ẩn ✨"; IA giữ ✨ cố định ở sidebar, Claude Code chưa sẵn sàng thì mục Trợ lý ở panel phải hiện SCR-11. Sơ đồ cần vẽ theo IA sau khi SRS sửa.
13. **Banner của G10 chưa có trong thứ tự IA-17.** MSG-05 / 06 / 27 / 28 ghi "Banner" ở mục 9, nhưng SCR-04 #11 lại ghi inline; MSG-06 trùng banner Offline của G04. Cần PO chốt: lỗi của UC-02 inline trong SCR-02, của UC-03 inline trong SCR-04, bỏ MSG-06 dùng banner Offline chung (đề xuất).
14. **Toast MSG-29 khi app ở khay (IA-05).** Phiên terminal thường chạy khi cửa sổ app đã thu về khay; toast không ai thấy. Cần PO chốt: ở khay thì thông báo Windows, bấm mở SCR-12 (IA-10) (đề xuất). Cùng lý do, UC-11 E1 / E3 "đóng app" phải hiểu là "Thoát app", vì × chỉ thu về khay.
15. **MSG cho highlights.** UC-05 E1 dùng MSG-05 ("lập kế hoạch thủ công") và MSG-27 ("thay đổi đã áp dụng · Hoàn tác · Gửi lại") — sai ngữ cảnh bước Highlights. Đề xuất MSG riêng "Chưa soạn được nháp highlights. Bạn dùng danh sách việc đã xong · Thử lại".
16. **UC-05 A4 "trạng thái rỗng của G08"**: G08 SCR-10 không có empty state (MSG-18 ở SCR-08). Đề xuất G08 thêm empty state cho SCR-10.
17. **Dự phòng ADR-0009.** Nếu bật, UC-10 có thêm trạng thái "đăng nhập bằng gói, chưa có API key" và SCR-11 có thông báo thứ tư `[cần kiểm chứng]`. Brief SCR-11 nên để chỗ.
18. (Sửa ghi chú 2 hiện có) UC-02 E1 "ô Obstacles in my way" → ô "Trở ngại" G08 SCR-06 #2 ở bước 5, trong khi E1 đưa người dùng về bước 1; cần SRS nói rõ "điền sẵn".


---

## G12 Workspace, thông báo (`docs/design-brief/flow/g12-workspace-billing.md`)

Số thứ tự # trùng bảng mục 3 "G12" của `docs/review/review-flow-vs-srs-2026-11-05.md`. Mọi trích dẫn chép đúng chữ, đúng dòng tại thời điểm review (commit flow `8fac830`).

Viết tắt file nguồn: `srs-g12` = `docs/features/srs-g12-workspace-billing.md`; `srs-g01` = `docs/features/srs-g01-tai-khoan.md`; `IA` = `docs/design-brief/00-kien-truc-thong-tin.md`; `g01` = `docs/design-brief/flow/g01-tai-khoan.md`.

---

#### G12-1 · Trung tâm thông báo thiếu nguồn "banner chờ lượt" — Cao

**Flow đang vẽ** (`g12-workspace-billing.md:185, 191`; sơ đồ nhánh `:218–246` chỉ có các nguồn dưới):
```text
**Mở đầu:** sự kiện từ nhóm phát sinh (G05, G07, G08…); người dùng bấm chuông ở cụm dưới sidebar, hoặc bấm thông báo Windows.
  start(["Sự kiện từ nhóm phát sinh<br/>G05, G07, G08…"])
  p1[["Áp cài đặt người nhận BR-18, gộp 5 phút BR-19<br/>tạo thông báo CHUA_DOC, notification.created<br/>gửi email, thông báo Windows nếu kênh bật"]]
```

**Nguồn nói:**
- `IA:67–72`: "**Banner** nằm ở đầu vùng chính, **tối đa một** cùng lúc, theo thứ tự ưu tiên (IA-17): 1. Offline (G04 SCR-01 #5) 2. Lịch cần kết nối lại (G05 SCR-09) 3. Rollover lỗi (G04 MSG-27) 4. Lệch timezone (G01 SCR-13)"
- `IA:73`: "Banner thấp hơn chờ tới lượt và đồng thời vào trung tâm thông báo."
- `IA:219`: "| IA-17 | Tối đa một banner, theo thứ tự ưu tiên; banner chờ vào trung tâm thông báo | Q17 |"
- `srs-g12:399` (UC-09 bước 1): "Nhận sự kiện từ nhóm phát sinh; áp cài đặt người nhận (BR-18), gộp 5 phút (BR-19); tạo thông báo `CHUA_DOC`; phát `notification.created`; gửi email nếu kênh bật"
- `srs-g12:402` (UC-09 bước 4): "Bấm một thông báo → mở đúng đích (task, Billing, Cài đặt lịch…); \[NotificationRead\] đánh dấu `DA_DOC`"

**Không ổn ở chỗ:** IA-17 tạo thêm một loại thông báo mới: khi một banner (lịch cần kết nối lại, rollover lỗi, lệch timezone) không được hiện vì có banner ưu tiên hơn, nó phải xuất hiện như một dòng trong trung tâm thông báo. SRS G12 UC-09 bước 1 chỉ nhận "sự kiện từ nhóm phát sinh" và chưa có dòng nào cho "banner chờ lượt": không nói ai tạo (G12 hay nhóm sở hữu banner), có đi qua cài đặt sự kiện × kênh (BR-18) không, có gửi email không, bấm vào thì mở đích gì (dialog kết nối lại lịch? Cài đặt Chung?). Flow chép SRS nên thiếu nguồn này. Designer vẽ SCR-11 sẽ không có dòng "Lịch Google cần kết nối lại" hay "Máy bạn đang ở múi giờ khác" với hai nút như MSG-23. Đây là loại thông báo chắc chắn xuất hiện ở 1.0 (ba banner đều 1.0).

**Sửa:**
- SRS G12 UC-09 bước 1 thêm: "hoặc nhận banner bị xếp sau theo IA-17 (G05 SCR-09, G04 MSG-27, G01 MSG-23): tạo thông báo trong app **không qua cài đặt BR-18, không gửi email, không gộp BR-19**; đích mở ra là nơi banner đó dẫn tới (G05 SCR-08 kết nối lại / G04 Home hôm nay / G01 SCR-07 Timezone); khi banner được hiện hoặc người dùng xử lý xong thì thông báo tự `DA_DOC` `[giả định]`". Thêm vào mục 6 (điểm vào) một dòng "Banner chờ lượt (IA-17)". Thêm bảng "Loại thông báo 1.0 → đích mở ra" (hiện bước 4 còn ghi "Billing" là 1.1).
- Flow UC-09, happy case và nhánh: thêm điểm vào thứ hai
```text
  ban(["Banner bị xếp sau theo IA-17<br/>G05 SCR-09 · G04 MSG-27 · G01 MSG-23"]) -->|"IA-17 · chờ lượt"| pb[["Tạo thông báo CHUA_DOC trong app<br/>không qua BR-18 / BR-19, không email"]]
  pb --> s1
  class ban,pb alt
```
và ở nút `ok` ghi "Mở đúng đích theo loại: task, Cài đặt lịch, kết nối lại lịch, Cài đặt Chung (timezone)…".
- **PO chốt:** (a) banner chờ lượt có gửi email / thông báo Windows không — mặc định đề xuất: không, chỉ trong app; (b) thông báo đó tự đọc khi banner hiện / xử lý xong hay người dùng tự đọc — mặc định: tự `DA_DOC`.

**Ai làm:** PO (hai câu), rồi SRS, rồi Flow.

---

#### G12-2 · UC-09 E1 lỗi tải danh sách dùng câu "Chưa lưu được thay đổi" — TB

**Flow đang vẽ** (`g12-workspace-billing.md:242–244`):
```text
  p2 -.->|"E1 · NotificationList lỗi / mất mạng"| e1["SCR-11 hiện danh sách đã cache"]
  e1 -.-> e1m>"MSG-38 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  e1m -.->|"Thử lại"| p2
```

**Nguồn nói:**
- `srs-g12:417` (UC-09 E1): "| E1 | \[NotificationList\] lỗi / mất mạng | SCR-11 hiện danh sách đã cache + MSG-38 "Thử lại" |"
- `srs-g12:678`: "| MSG-38 | Toast | Chưa lưu được thay đổi. Thử lại |"
- `srs-g12:635` (map lỗi): "| 5xx / timeout | MSG-38 |"

**Không ổn ở chỗ:** Flow chép đúng SRS, nhưng MSG-38 được viết cho lỗi **ghi** (đổi tên workspace, bật tắt ô thông báo). Ở E1 người dùng chỉ mở popover để **đọc**; không có "thay đổi" nào để "chưa lưu được". Toast này sẽ làm người dùng nghĩ mình vừa làm hỏng gì đó. Ngoài ra popover SCR-11 đang hiện "danh sách đã cache" nên toast chồng lên popover; nên là dòng inline đầu danh sách có nút "Thử lại" hơn là toast. Nguồn sai là SRS (dùng chung một MSG cho hai ngữ cảnh).

**Sửa:**
- SRS G12 mục 9 thêm `MSG-39` (đang để "(dự phòng)" ở `srs-g12:679`): "| MSG-39 | Inline đầu SCR-11 | Không tải được thông báo mới. Đang hiện bản đã lưu · Thử lại |". UC-09 E1 (`srs-g12:417`) → "SCR-11 hiện danh sách đã cache + MSG-39". Map lỗi: "5xx / timeout ở \[NotificationList\] → MSG-39".
- Flow: `e1m>"MSG-39 · Inline đầu SCR-11<br/>Không tải được thông báo mới. Đang hiện bản đã lưu · Thử lại"]`; bảng đối chiếu E1 đổi MSG-38 → MSG-39.
- Thêm trường hợp "chưa có cache lần đầu" vào E1: inline MSG-39 trên empty state, không hiện MSG-37 "Chưa có thông báo nào" (tránh hiểu nhầm là không có gì).

**Ai làm:** SRS rồi Flow.

---

#### G12-3 · UC-09 thiếu nhánh lỗi khi đánh dấu đã đọc — TB

**Flow đang vẽ** (`g12-workspace-billing.md:226–228, 233`; sơ đồ nhánh `:218–262` không có nhánh E nào từ `p3` hay `a1`):
```text
  p3[["NotificationRead"]]
  ok(["Mở đúng đích"])
  p1 ==> s1 ==> u1 ==> p2 ==> s2 ==> u2 ==> p3 ==> ok
  s2 -->|"A1 · Đánh dấu tất cả đã đọc"| a1[["NotificationRead all=true<br/>badge về 0 trên mọi thiết bị"]]
```

**Nguồn nói:**
- `srs-g12:393` (UC-09): "| Hậu điều kiện thất bại | Thông báo giữ `CHUA_DOC` |"
- `srs-g12:413–418` (UC-09 luồng lỗi): chỉ có "E1 \[NotificationList\] lỗi / mất mạng" và "E2 Email bị trả về cứng".
- `srs-g12:604` (API): "| \[NotificationRead\] `POST /notifications/read` | ids[] \| all | unreadCount | 5s / 2 lần |"
- `srs-g12:54` (BR-20): "đọc trên một thiết bị → đồng bộ thiết bị khác qua realtime ≤ 5 giây"

**Không ổn ở chỗ:** SRS tự nêu hậu điều kiện thất bại "thông báo giữ `CHUA_DOC`" nhưng không có nhánh E nào dẫn tới nó: \[NotificationRead\] lỗi hoặc mất mạng (sau 2 lần retry) khi bấm một dòng, hoặc khi bấm "Đánh dấu tất cả đã đọc". Với bấm một dòng, câu hỏi là có mở đích không khi chưa đánh dấu được (mặc định nên mở; chấm chưa đọc còn, gửi lại sau). Với A1, badge có về 0 tạm (lạc quan) rồi quay lại không. Flow không vẽ nên designer không có trạng thái "chấm chưa đọc vẫn còn sau khi bấm" và không biết có toast hay không.

**Sửa:**
- SRS G12 UC-09 thêm "E3 · \[NotificationRead\] lỗi / mất mạng: vẫn mở đích (bước 4); dòng giữ chấm chưa đọc, badge không đổi; lệnh đánh dấu vào hàng đợi, gửi lại khi có mạng (QC-08); không toast `[giả định]`. Với A1: badge về 0 lạc quan, lỗi thì trả lại số cũ + MSG-38".
- Flow UC-09, thêm
```text
  p3 -.->|"E3 · NotificationRead lỗi / mất mạng"| e3["Vẫn mở đích<br/>dòng giữ chấm chưa đọc, badge không đổi<br/>xếp hàng đợi, gửi lại khi có mạng"]
  a1 -.->|"E3 · lỗi"| e3b["Badge trả về số cũ"]
  e3b -.-> e3m>"MSG-38 · Toast<br/>Chưa lưu được thay đổi. Thử lại"]
  class e3 sync
  class e3b,e3m err
```
- **PO chốt:** bấm một dòng mà không đánh dấu được thì vẫn mở đích (đề xuất: có) và có báo gì không (đề xuất: không, chỉ giữ chấm).

**Ai làm:** SRS (một dòng E3) rồi Flow; PO xác nhận mặc định.

---

#### G12-4 · UC-08 thiếu nhánh xung đột cài đặt giữa hai thiết bị — TB

**Flow đang vẽ** (`g12-workspace-billing.md:136–140`; nhánh lỗi chỉ có E2 ở `:152–153`):
```text
  s1["SCR-10 Cài đặt Thông báo"]
  u1[/"Bật / tắt một ô"/]
  p2[["SettingsUpdate"]]
  s2["SCR-10 dấu Đã lưu"]
  s1 ==> u1 ==> p2 ==> s2
  p2 -.->|"E2 · SettingsUpdate lỗi"| e2["Ô về giá trị cũ"]
```

**Nguồn nói:**
- `srs-g12:52` (BR-18): "lưu trong cài đặt người dùng (\[SettingsUpdate\] của G01, xung đột theo G01 BR-12)"
- `srs-g01:49` (BR-12): "thiết bị có lệnh bị từ chối (412) lấy giá trị server **của trường đó** và hiện MSG-41; các trường khác trong cùng lệnh vẫn được lưu"
- `srs-g01:302` (UC-06 A6): "Trường đó lấy giá trị server, hiện MSG-41; các trường khác trong lệnh vẫn lưu"
- `g01:691–692` (UC-06 A6 đã vẽ): "p2 -->|"A6 · 412, trường đã đổi ở thiết bị khác"| a6["Trường đó lấy giá trị server<br/>các trường khác trong lệnh vẫn lưu"]" → MSG-41, class warn.
- `_quy-uoc.md:123`: "Nhánh giống nhau ở nhiều UC … vẫn vẽ ở từng UC, vì designer vẽ theo màn; nhưng nhãn phải giống hệt nhau."

**Không ổn ở chỗ:** BR-18 nói rõ bảng sự kiện × kênh dùng chung cơ chế cài đặt và xung đột của G01, tức có trường hợp 412: ô vừa bật trên máy này bị thiết bị khác đổi trước, ô nhảy về giá trị server và toast MSG-41 (của G01). SRS G12 UC-08 không có mã A/E cho nó, flow cũng không vẽ. Theo quy ước, designer vẽ theo màn: màn SCR-10 cần trạng thái "ô đổi theo thiết bị khác + toast", giống SCR-07/SCR-14 của G01. Cũng thiếu "nhận giá trị mới qua realtime khi thiết bị khác đổi" (G01 UC-06 A5) và "mất mạng → áp dụng trên máy, xếp hàng đợi" (G01 UC-06 E3; G01 mục 10 cho đổi cài đặt offline, chưa rõ áp cho nhóm Thông báo không).

**Sửa:**
- Flow UC-08, thêm với nhãn giống hệt G01:
```text
  p2 -->|"A6 · 412, trường đã đổi ở thiết bị khác"| a6["Ô đó lấy giá trị server<br/>các ô khác trong lệnh vẫn lưu"]
  a6 --> a6m>"G01 MSG-41 · Toast<br/>#quot;{tên cài đặt}#quot; vừa được đổi trên thiết bị khác thành {giá trị}.<br/>Thay đổi của bạn ở mục này chưa được lưu"]
  s1 -->|"A5 · thiết bị khác vừa đổi cùng ô"| a5["Ô nhận giá trị mới qua realtime"]
  class a6,a5 alt
  class a6m warn
```
Bảng đối chiếu thêm hai dòng "A5 / A6 (mượn mã G01 UC-06)".
- SRS G12 UC-08 thêm "A5 · Xung đột / thiết bị khác đổi: như G01 UC-06 A5, A6 (MSG-41 của G01)" để có mã riêng.
- **PO chốt:** nhóm Thông báo có đổi được khi mất mạng không (G01 mục 10 chỉ kể Chung / Hiển thị / Lịch làm việc / Phím tắt). Mặc định đề xuất: có, như các nhóm cài đặt khác.

**Ai làm:** Flow (nhãn mượn G01); SRS thêm mã; PO một câu.

---

#### G12-5 · "Nhóm Workspace" không có mục Workspace trong SCR-06 của G01 — TB

**Flow đang vẽ** (`g12-workspace-billing.md:34`):
```text
  start(["Avatar → Cài đặt hoặc Ctrl+,<br/>nhóm Workspace"])
```

**Nguồn nói:**
- `srs-g01:566` (SCR-06 #3, nhóm "Workspace"): "Context & channel (G02, gồm khung giờ channel) · Thành viên (G12, bản sau) · Privacy (G12, bản sau) · Billing (G12, 1.1) · Tích hợp (G05 / G11)"
- `srs-g12:430` (điểm vào): "| Cài đặt → Workspace | ✓ | ✓ | SCR-12 (bản 1: chỉ đổi tên) |"
- `IA:105`: "Gồm mọi nhóm của G01 SCR-06, kể cả … Thông báo (G12 SCR-10), Workspace (G12 SCR-12)"

**Không ổn ở chỗ:** "Workspace" trong SCR-06 là **tên nhóm** (cột trái chia ba nhóm: Cá nhân, Tài khoản, Workspace), và danh sách mục bên trong nhóm đó không có mục nào mở SCR-12. SRS G12 và IA đều cần một mục "Workspace" (đổi tên workspace) nhưng khung Cài đặt của G01 chưa có chỗ. Flow G12 viết "nhóm Workspace" vì không có tên mục để trỏ, designer không biết SCR-12 treo vào đâu. Đây là cùng lỗi với G01 #7, ghi ở đây để brief G12 thấy.

**Sửa:**
- SRS G01 SCR-06 #3 (`srs-g01:566`): thêm "Workspace (G12, SCR-12 — 1.0 chỉ đổi tên)" đầu danh sách.
- Flow G12 `g12:34`: `start(["Avatar → Cài đặt hoặc Ctrl+,<br/>nhóm Workspace → mục Workspace (SCR-12)"])`. Phần "Mở đầu" UC-05 (`g12:28`) ghi "Cài đặt → nhóm Workspace → Workspace (SCR-12)".
- **PO chốt:** thứ tự mục trong nhóm Workspace ở 1.0 — đề xuất: Workspace · Context & channel · Tích hợp.

**Ai làm:** SRS G01 rồi Flow G12.

---

#### G12-6 · UC-09 thiếu điểm vào Ctrl+K "Thông báo"; nhánh A2 từ thông báo Windows kết thúc sai — Thấp

**Flow đang vẽ** (`g12-workspace-billing.md:191, 231, 239–240`):
```text
  start(["Sự kiện từ nhóm phát sinh<br/>G05, G07, G08…"])
  win(["Thông báo Windows của app"]) -->|"điểm vào · bấm thông báo, IA-10"| wa["Đưa cửa sổ app lên trước<br/>kể cả từ khay"]
  p3 -->|"A2 · đích không còn, task đã xoá"| a2m>"MSG-30 · Toast<br/>Nội dung này đã bị xoá hoặc bạn không còn quyền xem"]
  a2m --> a2(["SCR-11 giữ mở"])
```
(`wa --> p3` ở `:232`: từ thông báo Windows đi thẳng vào `p3`, rồi A2 từ `p3`.)

**Nguồn nói:**
- `IA:51` (sidebar): "| | 🔔 Thông báo | – (Ctrl+K) | Popover trung tâm thông báo (G12 SCR-11, IA-10) |"
- `IA:150`: "| Ctrl+K | Command menu (gồm "Task đã xoá gần đây", "Thông báo") | G04 |"
- `IA:134`: "**Bấm thông báo Windows**: đưa cửa sổ lên trước (kể cả từ khay) và mở đúng đích như bấm dòng đó trong trung tâm thông báo (IA-10)."
- `srs-g12:409` (UC-09 A2): "| A2 | Đích không còn (task đã xoá, mất quyền xem) | Giữ SCR-11 mở, toast MSG-30 |"
- `srs-g12:436` (điểm vào): "| Chuông ở cụm dưới sidebar | ✓ | ✓ | SCR-11 dạng popover cạnh chuông (IA-10) |" — không có Ctrl+K.

**Không ổn ở chỗ:** (a) IA có lệnh "Thông báo" trong command menu Ctrl+K mở popover SCR-11; SRS G12 mục 6 và flow không có. (b) Khi người dùng bấm thông báo Windows (app ở khay) mà đích đã bị xoá, flow đi `wa → p3 → A2 → "SCR-11 giữ mở"`, nhưng SCR-11 chưa từng mở: app vừa được đưa lên trước ở Home. Kết thúc đúng là "cửa sổ lên trước, Home, toast MSG-30". Designer sẽ không có trạng thái này.

**Sửa:**
- Flow: nút `start`/`u1` thêm "hoặc Ctrl+K → Thông báo (IA mục 8)". Tách A2 theo điểm vào:
```text
  a2m -->|"từ SCR-11"| a2(["SCR-11 giữ mở"])
  a2m -->|"từ thông báo Windows"| a2w(["Cửa sổ lên trước ở Home<br/>chỉ có toast, SCR-11 không mở"])
```
- SRS G12 mục 6 thêm dòng "Ctrl+K → "Thông báo"" (IA); UC-09 A2 thêm "từ thông báo Windows: chỉ toast, không mở SCR-11".

**Ai làm:** Flow; SRS thêm một dòng điểm vào.

---

#### G12-7 · UC-08 A2 sau "Bật lại" trang không biết hiện gì — Thấp

**Flow đang vẽ** (`g12-workspace-billing.md:147–148`):
```text
  a2 --> a2m>"MSG-35 · SCR-14 Trang huỷ đăng ký email<br/>Đã huỷ nhận email #quot;{loại}#quot; · Bật lại"]
  a2m -->|"Bật lại"| a2u[["Unsubscribe undo=true"]]
```
(`a2u` không có cạnh đi tiếp; không có nhánh lỗi cho `undo`.)

**Nguồn nói:**
- `srs-g12:376` (UC-08 A2): "\[Unsubscribe\] với token → tắt đúng sự kiện × email → **SCR-14** MSG-35, nút "Bật lại""
- `srs-g12:577` (SCR-14 #2): "| 2 | "Bật lại" | Button | \[Unsubscribe\] `undo=true` |"
- `srs-g12:576–578` (SCR-14): #1 "Kết quả · MSG-35 / MSG-36", #3 ""Mở cài đặt thông báo" · SCR-10 (cần đăng nhập)". Không có MSG cho trạng thái đã bật lại.
- `srs-g12:605` (API): "| \[Unsubscribe\] `POST /notifications/unsubscribe` `[giả định]` | token, undo? | eventType, channel, enabled | 5s / 1 lần |"

**Không ổn ở chỗ:** Sau khi bấm "Bật lại", SRS không nói trang hiện gì (câu xác nhận? nút đổi thành "Huỷ nhận" để bấm lại? token còn dùng được lần nữa không?) và không có MSG. Flow dừng ở nút `a2u` nên designer thiếu trạng thái thứ ba của SCR-14 (đã huỷ → đã bật lại), và cũng thiếu lỗi khi `undo` thất bại (token đã dùng, 5xx) — hiện E1 chỉ gắn vào lần huỷ đầu. Đây là trang web tối giản (tech), nên không có toast của app.

**Sửa:**
- SRS G12 mục 9 thêm MSG mới (dùng số còn trống, ví dụ MSG-39 nếu #2 không dùng, hoặc MSG-56): "| SCR-14 | Đã bật lại email "{loại}" · Huỷ nhận |"; SCR-14 #1 "Kết quả · MSG-35 / MSG-36 / MSG-mới"; SCR-14 #2 "…`undo=true` → MSG-mới; token dùng lại được trong 30 ngày `[giả định]`"; E1 áp cho cả `undo`.
- Flow: thêm `a2u --> a2um>"MSG-mới · SCR-14<br/>Đã bật lại email #quot;{loại}#quot; · Huỷ nhận"]` và `a2u -.->|"E1 · token hết hạn / 5xx"| e1m`.
- **PO chốt:** token huỷ đăng ký dùng được bao lâu và bao nhiêu lần (ảnh hưởng nút "Bật lại" / "Huỷ nhận" qua lại). Mặc định: 30 ngày, không giới hạn số lần.

**Ai làm:** PO (hạn token), rồi SRS, rồi Flow.

---

#### G12-8 · Đổi tên workspace ở 1.0 không hiện ở đâu ngoài SCR-12 — Thấp

**Flow đang vẽ** (`g12-workspace-billing.md:35–38`):
```text
  s1["SCR-12 Workspace<br/>Tên workspace 1–80 ký tự<br/>nút Xoá workspace ẩn ở 1.0"]
  u1[/"Sửa tên workspace"/]
  p1[["WorkspaceUpdate name<br/>lưu ngay"]]
  ok(["SCR-12 hiện tên workspace mới"])
```

**Nguồn nói:**
- `srs-g12:559` (SCR-12 #1): "| 1 | Tên workspace | Text | 1–80 ký tự `[giả định]`; `OWNER` / `ADMIN` sửa được; lưu ngay (1.0 và 1.1) |"
- `srs-g12:56` (BR-22): "G12 ở 1.0 chỉ gồm: workspace cá nhân (đổi tên, SCR-12 #1), cài đặt Thông báo (UC-08), trung tâm thông báo (UC-09), huỷ đăng ký email"
- `IA:13–27` (khung app) và `IA:40–53` (sidebar): không có chỗ nào hiện tên workspace; sidebar cụm dưới chỉ có ✨, chuông, avatar.
- `srs-g12:559`: "`OWNER` / `ADMIN` sửa được" — `ADMIN` là bản sau (BR-28).

**Không ổn ở chỗ:** Flow kết thúc "SCR-12 hiện tên workspace mới" là chỗ duy nhất tên này xuất hiện. Ở 1.0 chỉ có một người, một workspace, không có bộ chọn workspace, không có tiêu đề cửa sổ hay sidebar hiện tên (theo IA). Người dùng đổi tên xong không thấy tác dụng ở đâu, và designer không có nơi nào khác để dùng giá trị này. Nếu PO vẫn giữ, brief cần nói tên dùng ở đâu (tiêu đề cửa sổ? email thông báo "Workspace {tên}" như MSG-51 ở 1.1?). Không phải lỗi flow, là câu hỏi phạm vi.

**Sửa:**
- **PO chốt:** (a) giữ đổi tên workspace ở 1.0 không? Nếu giữ, tên hiện ở đâu trong app 1.0 (đề xuất: tiêu đề cửa sổ Windows "{tên workspace} — Wakeup" và tên file bản xuất G01) — IA cần thêm; nếu không, dời A5 sang 1.1 và SCR-12 ẩn hẳn ở 1.0 (mục Workspace trong Cài đặt cũng ẩn, liên quan G12 #5). (b) SCR-12 #1 ghi "`ADMIN` sửa được" → thêm "(bản sau)".
- Flow: sau khi chốt, nút `ok` ghi nơi hiện tên; hoặc toàn bộ UC-05 ghi "Bỏ (1.1)".

**Ai làm:** PO, rồi SRS / IA, rồi Flow.

---

### Ghi chú cho brief — cần thêm (`g12-workspace-billing.md`, mục "Ghi chú cho brief G12", sau dòng 284)

Dán các dòng sau vào cuối danh sách:

- **Trung tâm thông báo nhận cả banner chờ lượt (IA-17):** lịch cần kết nối lại (G05 SCR-09), rollover lỗi (G04 MSG-27), lệch timezone (G01 MSG-23) khi bị banner ưu tiên hơn chặn thì thành một dòng trong SCR-11, bấm mở đúng nơi banner dẫn tới. SRS UC-09 bước 1 chưa có nguồn này; brief cần vẽ dòng có hai nút (như MSG-23 "Đổi sang · Giữ") trong popover.
- **UC-09 E1 dùng MSG-38 "Chưa lưu được thay đổi"** cho lỗi tải danh sách; chữ không hợp ngữ cảnh đọc. Đề nghị SRS thêm MSG riêng (inline đầu popover, "Không tải được thông báo mới. Đang hiện bản đã lưu · Thử lại"); brief vẽ inline, không toast.
- **Thiếu nhánh lỗi khi đánh dấu đã đọc** (`NotificationRead` lỗi / mất mạng, cả bấm một dòng và "Đánh dấu tất cả"): SRS chỉ có hậu điều kiện "giữ `CHUA_DOC`". Brief vẽ trạng thái "đã bấm nhưng chấm chưa đọc còn, badge không đổi"; A1 lỗi thì badge trả về số cũ + MSG-38.
- **SCR-10 dùng chung cơ chế cài đặt của G01:** có trạng thái "ô đổi theo thiết bị khác" (412 → G01 MSG-41) và "ô nhận giá trị mới qua realtime" như SCR-07 / SCR-14 của G01; vẽ một lần cho cả ba màn. Nhóm Thông báo có đổi được khi mất mạng không: chờ PO.
- **Mục "Workspace" chưa có trong SCR-06 của G01:** SRS G01 SCR-06 #3 chỉ có Context & channel, Thành viên, Privacy, Billing, Tích hợp. Brief G12 vẽ SCR-12 treo vào mục "Workspace" theo IA mục 5; chờ sửa SRS G01 và PO chốt thứ tự mục trong nhóm.
- **Điểm vào Ctrl+K → "Thông báo"** (IA mục 2, 8) mở popover SCR-11; SRS mục 6 chưa có. Từ thông báo Windows mà đích đã bị xoá: cửa sổ lên trước ở Home + toast MSG-30, SCR-11 không mở.
- **SCR-14 sau "Bật lại":** SRS không có MSG và không nói nút đổi thành gì; token dùng lại được không chờ PO. Brief vẽ ba trạng thái: đã huỷ (MSG-35), lỗi (MSG-36), đã bật lại (MSG mới).
- **Tên workspace ở 1.0 chỉ thấy trong SCR-12:** IA không có chỗ hiện tên workspace. Chờ PO chốt giữ A5 ở 1.0 hay dời 1.1; nếu giữ, IA cần nói tên hiện ở đâu (đề xuất: tiêu đề cửa sổ).


---

