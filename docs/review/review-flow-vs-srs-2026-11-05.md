# Review sơ đồ user flow so với PRD/SRS — bản 1.0

Ngày review: 05/11/2026. Phạm vi: 10 file flow trong `docs/design-brief/flow/` (PR #29, commit `6d5702e`; flow trích SRS ở commit `8fac830`, SRS không đổi kể từ đó). Nguồn đối chiếu: PRD/SRS trong `docs/features/`, `docs/01-quy-tac-dung-chung.md` (QC), `docs/design-brief/00-kien-truc-thong-tin.md` (IA), `docs/review/quyet-dinh-chot-2026-11-04.md`, `docs/adr/`, `docs/tech/01-quyet-dinh-tech-stack-va-api.md`, `docs/design-brief/_thu-g02-tao-va-chi-tiet-task.md`.

## 1. Tóm tắt

**Phần máy kiểm — sạch.**
- 181/181 sơ đồ Mermaid parse không lỗi (mermaid 11).
- Mọi mã `SCR-xx` / `MSG-xx` trên sơ đồ đều có trong SRS của đúng nhóm; nội dung MSG khớp bảng SRS (chỉ bỏ `{placeholder}` và dấu ngoặc kép theo quy ước).
- Mọi nút `→ Gxx · UC-yy` trỏ tới UC có thật trong file đích.
- Không có emoji, `:::`, id `end`; không sơ đồ nào quá 25 nút.
- Bảng tổng trong `flow/README.md` (74 UC, 181 sơ đồ) khớp số đếm thực tế. Số nhánh A/E ở mục lục mỗi file khớp SRS. Không thiếu UC 1.0 nào, không vẽ nhầm UC 1.1+.

**Phần nghiệp vụ — 5 reviewer độc lập theo cặp nhóm, ~107 phát hiện, 11 mức Cao.** Flow nhìn chung bám SRS tốt; lỗi nằm ở ba chỗ:

1. **Flow chép theo SRS nhưng SRS đã bị nguồn cao hơn thay thế** (QC-05, IA, quyết định tech). Nặng nhất là **timebox liên kết sự kiện (B8)**: QC-05 nói mọi đường đổi ngày / xoá / backlog chỉ *gỡ liên kết*, nhưng G02, G04, G05 đều vẽ "xoá / dời sự kiện ngoài" — đi theo flow thì xoá task sẽ xoá luôn cuộc họp thật của người dùng.
2. **IA chưa được ghi ngược vào SRS** nên flow bỏ sót: cột ngày đã qua (IA-20), ô thêm nhanh toàn cục (IA-19), app chạy ẩn ở khay (IA-05), hàng đợi banner (IA-17), Focus không có khung (IA-03), phím tắt mới (IA-15).
3. **Cùng một tương tác, hai nhóm vẽ hai kiểu**: rollover trạng thái `CHO_SHUTDOWN` / `DANG_CHAY` / `THAT_BAI`; câu lỗi `VERSION_CONFLICT` khác nhau giữa G04 và G06; phím S/D trên task backlog; AI xoá task; "Lệch ngày" có hai đặc tả.

Mục 2 gom các lỗi lặp theo **nguyên nhân gốc** — sửa một chỗ đóng được nhiều phát hiện. Mục 3 liệt kê **từng file** (bảng tóm tắt); **bản chi tiết từng mục** — flow đang vẽ gì, nguồn nói gì, không ổn ở đâu, sửa thế nào — ở [`review-flow-vs-srs-2026-11-05-chi-tiet.md`](review-flow-vs-srs-2026-11-05-chi-tiet.md), cùng số `Gxx-#`, và được đăng thành comment inline trên [PR #29](https://github.com/tannguyenho/personal-app/pull/29). Mục 4 là danh sách việc **PO phải chốt**. Mục 5 là thứ tự sửa đề xuất.

Quy ước mức độ:
- **Cao:** sai nghiệp vụ, hoặc designer sẽ vẽ thiếu / vẽ sai một trạng thái.
- **TB:** lệch nguồn, link sai, nhánh thiếu nhưng suy ra được.
- **Thấp:** nhất quán, tham chiếu, nhãn.

Cột "Sửa ở": **Flow** = sửa sơ đồ; **SRS** = sửa SRS/PRD trước rồi sửa flow cùng commit; **PO** = cần PO chốt trước.

Viết tắt: `g05:459` = `docs/design-brief/flow/g05-lich-timebox.md` dòng 459; `srs-g05:58` = `docs/features/srs-g05-lich-timebox.md` dòng 58; `QC:131` = `docs/01-quy-tac-dung-chung.md` dòng 131; `IA:164` = `docs/design-brief/00-kien-truc-thong-tin.md` dòng 164.

---

## 2. Lỗi lặp theo nguyên nhân gốc

### R1. Timebox liên kết sự kiện (B8) — **Cao**

**Quy tắc đã chốt:** QC-05 ngoại lệ (`QC:131`) và G05 BR-21 (f) (`srs-g05:58`): ở mọi đường (đổi ngày, rollover, backlog, xoá) chỉ **gỡ liên kết**, không dời và không xoá sự kiện ngoài. QC thắng SRS theo D1.

**Chỗ vẽ sai:**

| Vị trí | Đang vẽ | Phải là |
|---|---|---|
| `g02:420` UC-04 A2 (xoá task) | "Timebox tương lai gỡ, sự kiện ngoài bị xoá" không ngoại lệ | Timebox liên kết: chỉ gỡ liên kết, sự kiện giữ. Hoàn tác (`g02:391`) không được "tạo lại sự kiện" |
| `g04:301-303, 384` UC-03 A7 (kéo task sang ngày khác) | Giữ liên kết, gắn cờ Lệch ngày — theo G04 BR-09 `[giả định]` | Gỡ liên kết, sự kiện gốc giữ nguyên, task sang ngày mới, không cờ. Nối → G05 · UC-04 A7 |
| `g05:459-481` UC-04 (A5 xoá, A7 dời, A8 backlog) | Đi vào nút `fut` "xoá sự kiện ngoài" / "dời, cập nhật sự kiện ngoài" | Thêm nhánh "timebox liên kết → chỉ gỡ liên kết" cho cả ba |
| `g05:416-422` UC-04 A1 (Ctrl+X trên timebox liên kết) | Nhập vào nhánh thường, kết thúc "job xoá sự kiện ngoài"; Hoàn tác "tạo lại timebox" | Kết thúc riêng "task không còn timebox, sự kiện giữ nguyên"; Hoàn tác liên kết lại qua `TimeboxLink`, không tạo timebox mới (tránh đẩy ra lịch sinh họp trùng, BR-21 (a)) |
| `g05:1055-1058` UC-11 A3 | "Dời task" → kết thúc "task và timebox cùng ngày" | Theo QC-05, dời task thì timebox liên kết bị gỡ → cờ mất vì timebox mất. **PO chốt:** miễn trừ đường UC-11 hay sửa kết thúc |

**Sửa SRS:** G02 BR-11 (`srs-g02:53`), UC-04 A2 (`srs-g02:256`); G04 BR-09 (`srs-g04:45`) và đóng câu hỏi mở `prd-g04:359`; G05 UC-04 A1 (`srs-g05:232`) tách Hoàn tác cho loại liên kết. Ghi chú `g04:910` và `g05:1108` sửa lại: QC-05 đã có câu trả lời, không phải "hai SRS mâu thuẫn".

### R2. Trạng thái lượt rollover — **Cao**

**Nguồn:** G06 bảng 4.2 (`srs-g06:98-99`), BR-19 (`srs-g06:55`), G04 BR-25 (`srs-g04:61`), PRD G04 AC06 (`prd-g04:141`). Kết quả `RolloverEnsure` có `XONG` / `DANG_CHAY` / `CHO_SHUTDOWN` / `THAT_BAI`; API chờ tối đa 10 giây, gặp `THAT_BAI` thì chạy bù trong request, lỗi thì `ROLLOVER_FAILED`.

| Vị trí | Vấn đề | Đề xuất |
|---|---|---|
| `g04:32, 43, 77-81` UC-01 happy + A7 | A7 "chưa nhận kết quả → rollover tạm" vô điều kiện; không xét `CHO_SHUTDOWN` (đang shutdown qua mốc đầu ngày → task **ở yên cột cũ**, không rollover tạm) | Sau `RolloverEnsure` thêm thoi rẽ 4 trạng thái: `XONG` → vẽ theo server; `DANG_CHAY`/đang chờ → rollover tạm; `CHO_SHUTDOWN` → giữ cột cũ; `THAT_BAI` → banner MSG-27. A7 nối vào thoi này |
| `g06:749-751` UC-07 A2/A3 | A2 hiện rollover tạm khi chờ; A3 (`CHO_SHUTDOWN`) không nói bỏ rollover tạm. Thiếu nhánh `THAT_BAI` (`srs-g06:459`) | a3 ghi "bỏ rollover tạm, task về cột cũ"; thêm nhánh `THAT_BAI` |
| `g08:199` UC-01 (BR-06) | Chỉ xử lý `CHO_SHUTDOWN` / `THAT_BAI`; thiếu `DANG_CHAY`, `ROLLOVER_FAILED`, offline; `THAT_BAI` có lẽ không bao giờ được trả về | Sửa SRS G08 BR-06 (`srs-g08:42`); flow gộp "DANG_CHAY / CHO_SHUTDOWN / lỗi" → MSG-32 |
| `g06:755-757` UC-07 E1 + ghi chú `g06:796` | Banner lỗi dùng G06 MSG-25, nhưng IA mục 3 (`IA:70`) và G04 SCR-01 #5 (`srs-g04:435`) đã chốt là **G04 MSG-27**. Ghi chú 2 hỏi "nhóm nào sở hữu" là thừa | E1 đổi thành G04 MSG-27 hoặc → G04 · UC-01 E4; SRS G06 bỏ MSG-25 (`srs-g06:504`) |

### R3. IA chưa ghi ngược vào SRS → flow bỏ sót — **Cao / TB**

| IA | Vị trí flow | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|
| IA-20 cột ngày đã qua (`IA:164, 222`) | `g02:27-29, 84-85` UC-01 | Không có nhánh "nhấn A trên cột đã qua → ô soạn mở ở cột **hôm nay**, board cuộn tới". E6 (`PAST_DATE`) vẽ như thể mở được ô soạn trên cột cũ | Thêm nhánh A mới vào SRS UC-01 (`srs-g02:121, 148`); E6 viết lại "ngày D thành quá khứ khi ô soạn còn mở / lệnh offline gửi muộn". Brief CASE-05 (`_thu-g02:229`) bỏ `[chờ O-02]` | SRS |
| IA-19 ô thêm nhanh toàn cục (`IA:122, 130, 179`) | `g02:27-28` UC-01 | Ctrl+Shift+A (SCR-N01) và "Thêm task" trên menu khay không có trong flow nào, dù brief F-06 trỏ về UC-01 | Thêm điểm vào + sơ đồ nhỏ: Enter → "Đã thêm vào Hôm nay" ~1s, đóng, trả focus; Shift+Enter giữ ô; click ngoài đóng giữ nháp; Esc đóng; phím bị tắt (G01 BR-15) không mở. Xin SRS mã A# | SRS |
| IA-05 app chạy ẩn ở khay, × = thu về khay (`IA:128-133`) | `g08:619, 627`; `g10:1111`; `g10:1156, 1191`; `g07:69-70, 127`; `g07:329-330` | (a) `RitualGet → autoOpen, ghi autoPromptedAt` có thể dùng mất lượt tự mở duy nhất trong ngày khi cửa sổ đang ẩn; (b) toast MSG-29 (G10), MSG-01/02, MSG-10 (G07) không ai thấy khi ở khay; (c) G10 UC-11 E1/E3 ghi "đóng app" nhưng × không cắt phiên MCP, chỉ "Thoát app" mới cắt; (d) Ctrl+Shift+Space và menu khay là **bật / dừng** (`IA:130, 152`, `prd-g07:138`) nhưng G07 chỉ vẽ chiều bật, ghi chú `g07:612` kết luận ngược | (a)(b) **PO chốt**: chỉ ghi autoPromptedAt khi cửa sổ hiện; khi ẩn dùng thông báo Windows? (c) sửa nhãn "thoát app (khay / avatar → Thoát)"; (d) thêm điểm vào UC-02 từ phím toàn cục, khay "Dừng timer", banner shutdown G08 (`g08:374-375`); thêm "khay → Bật timer" cho UC-01; sửa SRS G07 UC-01 A4, UC-02 | PO / SRS |
| IA-17 hàng đợi banner (`IA:67-73, 219`) | `g01:660` UC-06 A2; `g10:218, 231-233, 396`; `g12:191, 218-246` UC-09 | (a) banner lệch timezone vẽ như luôn hiện ngay, thực ra ưu tiên 4, chờ lượt; (b) MSG-05/06/27/28 của G10 là banner nhưng không có trong thứ tự ưu tiên, MSG-06 trùng banner offline G04; (c) trung tâm thông báo thiếu nguồn "banner chờ lượt" (G05 SCR-09, G04 MSG-27, G01 MSG-23) | (a) thêm nhánh "có banner ưu tiên hơn → chờ, vào trung tâm → G12 · UC-09", SCR-13 sửa "đầu Home" thành "đầu vùng chính"; (b) **PO chốt** banner AI đặt inline trong wizard / panel thay vì vùng chính; (c) thêm điểm vào UC-09 và bảng loại thông báo SRS G12 | Flow / PO / SRS |
| IA-03 Focus toàn cửa sổ (`IA:35, 121`) | `g08:660-661, 722` UC-04 A3 | "Đang ở Focus → banner SCR-12" — Focus không có khung nên không có vùng banner | **PO chốt** cách nhắc khi đang Focus (thông báo Windows / chờ thoát Focus) | PO |
| IA-12 onboarding xong → Home (`IA:120, 214`) | `g01:523, 552` UC-05 | Kết thúc "mở Daily planning" theo BR-11; IA và chính SCR-05 (`srs-g01:545`) ghi Home hôm nay | Kết thúc "Khung app, Home hôm nay; wizard Daily planning tự mở thay vùng chính"; sửa một câu SRS | PO |
| IA §5 SCR-15 là dialog chặn (`IA:110`) | `g01:1185-1186` UC-11 | Vẽ là "Màn hình" | Sửa nhãn flow và nơi hiện MSG-47 trong SRS | SRS |
| IA-15 phím tắt (`IA:146-150`) | G04 SCR-08/09 | Ctrl+J, Ctrl+, Ctrl+\\ và lệnh Ctrl+K "Task đã xoá gần đây", "Thông báo" chưa vào SRS G04 và BR-17 | Sửa SRS, ghi chú G04 | SRS |
| IA mục 2 menu Avatar (`IA:52`) | `g01:362, 616` | Gọi "Menu tài khoản"; nút bắt đầu thiếu Ctrl+, | Đổi tên, thêm phím; ghi chú trỏ IA mục 2 | Flow |
| IA-16 Esc không thoát wizard | `g08:824` ghi chú | Bỏ sót UC-02 A5 "Esc / ×" (`srs-g08:180`, `prd-g08:343`) | Bổ sung vào danh sách cần sửa SRS/PRD | Flow |
| IA-16 Esc trên ô nhập (`IA:156`) | `g02:79` UC-01 A3 | IA: Esc bỏ focus giữ nháp; SRS A3 (`srs-g02:135`): Esc đóng ô soạn | **PO chốt** Esc lần 1 | PO |

### R4. Trang web tối giản thay deep link (tech đã chốt) — **Cao**

`docs/tech/01:22` chốt: xác minh email, đặt lại mật khẩu, "Không phải tôi", tải bản xuất, huỷ đăng ký đều mở trên **trang web tối giản**. Flow G01 vẫn ghi `[giả định]` và kết thúc trong app:

| Vị trí | Vấn đề | Đề xuất |
|---|---|---|
| `g01:422-427, 450-454` UC-04 | Sau khi đặt mật khẩu mới trên web: "cấp token → MSG-19 toast → Home, đã đăng nhập" — không thể xảy ra từ trang web | SRS UC-04 bước 3–4 (`srs-g01:218-219`): SCR-04 phần 2 và MSG-18 là trang web; xong thì trang báo "Đã đặt lại, mở app để đăng nhập"; app về SCR-03. Sửa flow theo |
| `g01:873` UC-07 A5; `g01:929` UC-08 bước 4 | Còn `[giả định]` | Bỏ `[giả định]`. "Đăng nhập nếu cần" trên web cần **PO/tech** nói cách kiểm "đúng tài khoản" (BR-19, UC-08 E3) vì đăng nhập web từ 1.1 |

### R5. "Daily planning có hướng dẫn" không tồn tại ở G08 — **Cao**

`g01:522` UC-05 trỏ → G08 · UC-01 "có hướng dẫn" (theo G01 BR-11 `srs-g01:48`, PRD G01 US2.2 AC01). SRS G08 không có chế độ này; flow G08 UC-01 (`g08:22-28`) không có điểm vào từ onboarding. Designer G08 sẽ bỏ sót trạng thái. **Sửa SRS G08** (điểm vào + UC-01), rồi thêm vào nút `start` của flow G08; ghi chú brief G01.

### R6. Cùng tương tác, hai nhóm hai kiểu — **TB**

| Tương tác | G… | G… | Đề xuất |
|---|---|---|---|
| Lỗi `TaskMove` (`g04:340-356` vs `g06:102-107, 317-321, 659-664`) | G04: MSG-17 "…đã cập nhật lại", MSG-14 "Task này đã bị xoá", MSG-15 "Chưa tải / lưu được…", MSG-09 "…chuyển…về ngày đã qua" | G06: MSG-23 "Task đã thay đổi trên thiết bị khác", MSG-20 "Task này không còn tồn tại", MSG-17 "Chưa lưu được…", MSG-24 "…đặt…vào ngày đã qua" | QC-08 (`QC:159`) khớp G06. Một bộ câu chung đặt ở QC-08 hoặc G02; sửa SRS G04; `_quy-uoc:123` yêu cầu nhãn giống hệt |
| Phím S / D trên task backlog (`g04:290-293` vs `g06:305, 309`) | G04 UC-03 A1: MSG-07 "Đã chuyển về hôm nay" | G06 UC-03 A1: MSG-03 "Đã chuyển … sang {ngày}". Phím D trên task backlog (G04 BR-10) không flow nào vẽ | G06 UC-03 sở hữu; G04 A1 nối sang; thêm biến thể D |
| AI xoá task (`g02:424-426` UC-04 A7) | "đủ" → `p1 → m1` toast người dùng MSG-09 | G02 UC-03 A7 và G10 UC-11: toast MSG-29, Hoàn tác qua G10 UC-04 A9 | "đủ" → "như bước 2, tác nhân ai, chip AI" → G10 · UC-11 / UC-04. Bỏ cạnh về m1 |
| Nhãn "Lệch ngày" trên card (`g04:84, 302` vs `g05:1011`) | G04 BR-24: tooltip MSG-26, không hành động | G05 SCR-06 #5: bấm mở popover MSG-30 hai lựa chọn | G05 sở hữu (BR-22); G04 BR-24 trỏ sang G05 UC-11; `g04:84, 302` thêm → G05 · UC-11 |
| Dừng timer (`g07:164` UC-02 A1) | G07 BR-06 "không đường nào khác dừng timer" | C13, G03 BR-17 (`g03:418, 538`): đổi / dừng series dừng timer; `g01:1042` xoá tài khoản dừng timer; G07 UC-02 không có nhánh này | Sửa BR-06; A1 thêm → G03 · UC-04/05 và → G01 · UC-09; G07 UC-02 thêm nhánh server tự dừng |
| Mã thông báo trùng series (`g03:315-316, 661`) | G03 ghi MSG-21 | Đổi ngày ở header là G02 UC-02 A11 → G02 MSG-24; khôi phục Thùng rác G02 hiện MSG-13 + MSG-24 | Ghi chú G03: cùng nội dung (QC-06 mục 3), mã khác, designer vẽ một lần |
| Plan my day từ G08 (`g08:123-124` vs `srs-g10:564, 703`, BR-14, BR-19) | Nhãn "trợ lý AI bật" | Nút chỉ hiện khi Beta bật; chưa đồng ý vẫn hiện, mở SCR-10; Claude Code chưa sẵn sàng → thẻ SCR-11 thay chỗ | Nhãn "Beta bật · Plan my day"; thêm nhánh → G10 · UC-10 (SCR-11) và → G10 · UC-09 (đồng ý) |
| Highlights từ shutdown (`g08:382-384, 497` UC-02 A7 vs G10 UC-05 A1/A8/E1) | Chỉ "có nháp → G10" / "chưa có → giữ danh sách" | G10 còn nút "Soạn bằng AI", SCR-11 thay chỗ, MSG-05 + Thử lại; cùng bước hai mã màn G08 SCR-10 / G10 SCR-07 | Thêm nhánh "chưa có nháp → Soạn bằng AI → G10 · UC-05 A1"; ghi chú G10 SCR-07 là trạng thái AI của G08 SCR-10 |
| TimeboxLink ở bước 2 planning (`g08:36, 189-235` vs `g05:930-999` UC-10, `g05:972-974` E1) | G08 không có nút sang G05 UC-10, không nhánh "TimeboxLink lỗi → task không timebox" | G05 UC-10 E1 trỏ → G08 · UC-01 "tạo task không có timebox" nhưng G08 không có nhánh đó | G08 thêm → G05 · UC-10 và nhánh lỗi |

### R7. Nút sang flow thiếu mã UC (trái `_quy-uoc:70, 133`) — **Thấp**

`g02:78` "→ G06 Backlog" → `G06 · UC-02`; `g02:217` "→ G04 tính lại projection" → `G04 · UC-05`; `g02:331` "→ G10 receipt và Hoàn tác" → `G10 · UC-04`; `g02:427` A3 vẽ như điểm bắt đầu → lục giác `G10 · UC-04`; `g02:627` A8 "G01 ·" → `G01 · UC-10`; `g04:299` "→ G05 cập nhật sự kiện ngoài" → `G05 · UC-04 A7`; `g04:858-859` "→ G08 · P, O" / "→ G07 · F, Space" → `G08 UC-01/UC-02`, `G07 UC-01/UC-04`; `g06:33` thêm → `G05 · UC-04 A8`; `g06:373` p3 "xem G03 UC-06" bằng chữ → nút `G03 · UC-06`; `g06:418` "→ G04 · UC-03 · UC-01" dễ đọc nhầm → tách hai nút.

### R8. Nhãn phiên bản — **Thấp**

`g01:6, 124, 261, 397, 1079, 1081, 1264, 1270`: nhánh nhiều thành viên ghi "Bỏ (1.1)"; BR-26 và Q47 (`srs-g01:63`) xếp 1.2, file G12 đã ghi "Bỏ (1.2)". Giữ "Bỏ (1.1)" cho UC-03 A3 (2FA) và UC-08 A1 (chỉ đọc). `g02:332, 426, 369, 471`: nhánh 403 `LINKED_TASK` vẽ như 1.0 nhưng G11 là 1.1 (`02-tinh-nang-ban-sau:38`, `IA:87`); G10 đã ghi "Bỏ (1.1)" (`g10:431, 434`) → d7 chỉ giữ `TOGGLE_OFF` (cần PO xác nhận 1.0 không có loại liên kết nào khác). `g05:82-83` UC-01 E4 giới hạn số tài khoản đọc từ QC-10 (1.1) → ghi "Bỏ (1.1)" trừ khi PO chốt giới hạn cứng.

---

## 3. Theo từng file

Các phát hiện đã nằm trong mục 2 chỉ ghi mã R#.

### G01 Tài khoản (`g01-tai-khoan.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 422-454 | R4 | | SRS |
| 2 | Cao | 522 | R5 | | SRS |
| 3 | TB | 523, 552 | R3 IA-12 | | PO |
| 4 | TB | 146, 180, 194, 233-235 | UC-02 A6 (xác nhận lại) dùng chung kết thúc của đăng nhập: lỗi / Huỷ đẩy về SCR-01/03 dù người dùng đang đăng nhập, đang ở dialog SCR-11/12. Nguồn sai: BR-25 (`srs-g01:62`), MSG-49/50 (`:785-786`) | SRS: khi xác nhận lại, mọi lỗi và Huỷ về dialog đang mở. Flow thêm kết thúc riêng cho A6 | SRS |
| 5 | TB | 1140-1149 | UC-10 E3 (412) kết thúc "Giữ lịch làm việc cũ", class err. BR-12, UC-06 A6 (`srs-g01:49, 302`): trường lấy **giá trị server**, UC-06 vẽ class warn | Nối sang "workSchedule theo giá trị server", warn, nhãn giống UC-06 A6 | Flow |
| 6 | TB | 6, 124, 261… | R8 | | Flow |
| 7 | TB | 651, 724; `g12:34` | SCR-06 #3 (`srs-g01:566`) thiếu mục Workspace (G12 SCR-12); #1 thiếu "Task lặp" (G03 SCR-05), "Hoạt động AI" (G10 SCR-12). IA mục 5 (`IA:105`) đủ | Sửa SRS SCR-06; UC-06 A1 thêm G03; G12 ghi "nhóm Workspace → mục Workspace (SCR-12)" | SRS |
| 8 | TB | 660 | R3 IA-17 (a) | | Flow |
| 9 | TB | 1185-1186 | R3 IA §5 | | SRS |
| 10 | Thấp | 88 | UC-01 E7 (429/5xx/mất mạng) chỉ gắn vào form SCR-01; `AuthVerifyEmail` (72), `AuthResendCode` (79) trên SCR-02 không có; kết thúc "SCR-01 giữ form" sai khi lỗi ở SCR-02 | Thêm E7 cho SCR-02, kết thúc "ở SCR-02, giữ mã" | Flow |
| 11 | Thấp | 564-565 | UC-05 E1 đi thẳng sang bước 3; SRS (`srs-g01:270`) "quay lại bước 2" | Nối về `s2` | Flow |
| 12 | Thấp | 1042 | UC-09 A2 → G07 · UC-02 nhưng G07 UC-02 không có nhánh "xoá tài khoản" | Xem R6 dừng timer | Flow G07 |
| 13 | Thấp | 362, 616 | R3 menu Avatar | | Flow |
| — | | 1273+ | Ghi chú: 9 mục đúng nguồn; thiếu #1, 2, 4, 5, 7, 8, 9 | | |

### G02 Quản lý task (`g02-quan-ly-task.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 27-29, 84-85 | R3 IA-20 | | SRS |
| 2 | Cao | 27-28 | R3 IA-19 | | SRS |
| 3 | Cao | 420, 391 | R1 | | SRS |
| 4 | TB | 424-426 | R6 AI xoá | | Flow |
| 5 | TB | 78, 217, 331, 427, 627 | R7 | | Flow |
| 6 | TB | 332, 426, 369, 471 | R8 `LINKED_TASK` | | PO |
| 7 | TB | 619-620 | UC-06 A6 "Sửa khung đã bật" dẫn vào a5 "điền sẵn theo lịch chung" — sai với sửa. Thiếu trạng thái khung chờ SCR-06 #9 "Khung mới áp dụng từ {ngày}" (`srs-g02:433`) và ghi đè khung chờ (BR-24 `:66`) | Tách nút a6 "khung đang áp / khung chờ"; thêm nhánh sửa lại khi có khung chờ | Flow |
| 8 | TB | 431 | UC-04 A6 khôi phục: thiếu task Kế hoạch ngày < hôm nay → về hôm nay, số ngày hoãn = 0 (QC-03 mục 3 `QC:96`, `prd-g02:259`). SRS A6 (`srs-g02:260`) cũng thiếu | Sửa SRS A6 và nút a6 | SRS |
| 9 | TB | 38-41 | UC-01 happy: chuỗi `d1 → TaskSuggest → s2 → u3` đọc như phải chờ gợi ý mới Enter được, trái NFR (`srs-g02:527`), brief S04, CASE-09 | Thêm cạnh "Enter trước khi có gợi ý → p2", ghi "gợi ý về muộn bị bỏ" | Flow |
| 10 | Thấp | 229-230 | UC-02 E3: MSG-09 "Đã xoá · Hoàn tác" dùng cho task bị xoá ở **thiết bị khác**, chữ không nói rõ | Ghi chú; cân nhắc MSG riêng như MSG-22 | SRS |
| 11 | Thấp | 79 | R3 Esc | | PO |
| 12 | Thấp | 74 | UC-01 A4 hết hạn mức: QC-12 mục 8 (`QC:208`) hiện thông báo của Claude Code; SRS A4 và CASE-09 xử lý im lặng | PO chốt | PO |
| 13 | Thấp | 286 | UC-03 thiếu "hiệu ứng chúc mừng nếu bật" (`srs-g02:211`) | Thêm | Flow |
| 14 | Thấp | 334-335 | UC-03 E1 (412) không vẽ "card về trạng thái server" (`srs-g02:230`) | Thêm | Flow |
| 15 | Thấp | 590-593 | UC-06 A3 thiếu "Huỷ" của SCR-07 và "task dùng lịch channel nhận → G04 tính lại"; A4 thiếu đường xoá context rỗng thành công; điểm vào thiếu G01 SCR-14 #4 (`g01:1135`) | Thêm | Flow |
| — | | 681-682 | Ghi chú: mục MSG-12 đúng; thiếu #1, 2, 3, 6, 8, 10, 11, 12 | | |

### G03 Task lặp lại (`g03-task-lap-lai.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 73-74 | UC-01 A1 "Instance đầu đặt hôm nay" theo SRS A1 (`srs-g03:123`), PRD AC05 (`prd-g03:145`). BR-02 (`srs-g03:40`): `anchorDate` = ngày khớp quy tắc **đầu tiên** ≥ max(ngày dự định, hôm nay) — hôm nay Thứ Năm, lặp Thứ Hai thì instance đầu là Thứ Hai tới | Sửa SRS A1 và PRD AC05 theo BR-02; flow nối a1 sang "khớp quy tắc?" để rẽ A6 | PO |
| 2 | TB | 416, 502 | Bảng phạm vi (`srs-g03:59-65`) không có cột instance ở `BACKLOG` dù mục 4.2 (`:91`) cho phép → UC-04 A5 / UC-05 không nói Dừng lặp, Đổi tần suất, Áp mẫu làm gì với instance backlog | PO quyết, sửa SRS | PO |
| 3 | TB | 410-414, 452-458 | UC-04: E3 (5xx) chỉ gắn vào `SeriesUpdate` đổi quy tắc; `SeriesApplyFrom` (A1) và `SeriesUpdate approxTime` (A2) cũng gặp; A2 dùng If-Match nên gặp E1 412 | Thêm cạnh E3 từ a1, a2p; E1 từ a2p | Flow |
| 4 | TB | 538; `g06:369, 373` | UC-06 vẽ lại toàn bộ job rollover, trái quy ước "vẽ ở file khởi phát" (G06). G06 UC-04 thiếu timebox của instance `skipped` (BR-11/D6 `srs-g06:47, 239`: timebox tương lai gỡ, sự kiện xoá) | G03 rút thành nút → G06; G06 thêm → G03 · UC-06 và phần timebox | Flow |
| 5 | Thấp | 315-316, 661 | R6 mã MSG trùng | | Flow |
| — | | 778-789 | Ghi chú: đúng nguồn; thiếu #1, 2, 3 | | |

### G04 Board ngày (`g04-board-ngay.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 301-303, 384 | R1 | | SRS |
| 2 | Cao | 32, 43, 77-81 | R2 | | Flow |
| 3 | TB | 340-356 | R6 câu lỗi TaskMove | | SRS |
| 4 | TB | 290-293 | R6 phím S/D backlog | | SRS |
| 5 | TB | 566 | UC-05 chỉ vẽ `BINH_THUONG` / `QUA_TAI`; BR-21 (`srs-g04:57`) và bảng 4.1 (`:91-99`) còn `TRONG`, `XONG_HET` (không cảnh báo), `DA_QUA` (actual / planned) và thứ tự ưu tiên | Thoi rẽ theo BR-21, năm kết thúc | Flow |
| 6 | Thấp | 299, 858-859 | R7 | | Flow |
| 7 | Thấp | 84, 302 | R6 Lệch ngày: MSG-26 bảo "Dời task hoặc dời timebox" nhưng không nối → G05 · UC-11 | Thêm nút | Flow |
| 8 | Thấp | 120 | UC-01 E3 thiếu banner "Lịch cần kết nối lại" (G05 SCR-09, `srs-g04:435`, IA ưu tiên 2) | Thêm → G05 · UC-08 | Flow |
| 9 | Thấp | — | R3 IA-15 phím tắt | | SRS |
| 10 | Thấp | UC-03 A4 | S / "Hoãn 1 tuần" đưa instance lặp vào ngày đã có instance cùng series; QC-06 (`QC:141-142`) không xếp hai đường này vào tự động hay thủ công | PO chốt, thêm nhánh | PO |
| — | | 902+ | Ghi chú: 1–7, 9–11 đúng; sửa 8 (QC-05 đã quyết); thiếu #2, 3, 4, 9 | | |

### G05 Lịch và timebox (`g05-lich-timebox.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 459-481 | R1 | | SRS |
| 2 | Cao | 416-422 | R1 UC-04 A1 | | SRS |
| 3 | TB | 1055-1058 | R1 UC-11 A3 | | PO |
| 4 | TB | 281-282, 424 | UC-03 A10/A4, UC-04 A2: thả task đã có timebox vào ngày khác (BR-05, C19 `srs-g05:42, 197`) hoặc kéo một trong nhiều timebox → timebox cũ bị cờ `LECH_NGAY` (BR-22 `:59`); QC-05 dòng "kéo sang ngày khác" (`QC:120`) lại nói timebox đi theo task. Flow kết thúc ở `s2`, không sang UC-11 | Thêm cạnh → UC-11; ghi chú lỗ hổng SRS | PO |
| 5 | TB | 820 | UC-08 điểm vào "thông báo trong app / Windows G12" theo SRS §6 (`srs-g05:510`, dẫn D12). D12 (`quyet-dinh:235`) chỉ áp cho nhắc ritual và timer > 4 giờ; `prd-g12:137` ghi "Lịch mất kết nối: trong app + email" | Sửa SRS §6 và nút start | SRS |
| 6 | TB | 42, 68, 90 | UC-01 mọi kết thúc ở SCR-01/02 (Cài đặt), nhưng G01 vào từ onboarding bước 2 (`g01:511-513, 564`) — toàn cửa sổ (IA-12) — và cần quay lại đó; SRS bước 6 (`srs-g05:112`) không tính đường này | Thêm kết thúc "về G01 SCR-05 bước 2"; sửa SRS bước 6 / E1 | SRS |
| 7 | TB | 82-83 | R8 E4 | | PO |
| 8 | TB | 1011 | R6 Lệch ngày | | SRS |
| 9 | TB | 972-974 | R6 TimeboxLink | | Flow G08 |
| 10 | Thấp | 461-463 | UC-04 A4/A5 thiếu BR-17 (`srs-g05:54`): bỏ hoàn thành cùng ngày trả lại `endsAt` cũ; khôi phục Thùng rác không tạo lại timebox | Thêm | Flow |
| 11 | Thấp | 846-865 | UC-08 kết nối lại thiếu nhánh huỷ OAuth / `state` sai (UC-01 E1/E5) dù bước 2 nói "như UC-01" | Thêm | Flow |
| 12 | Thấp | 861 | UC-08 A5 "SCR-01 · kết nối lại tài khoản đã ngắt", nhưng `DA_NGAT` không còn trong danh sách (`srs-g05:76`) | Đường vào thực là nút kết nối UC-01 | Flow |
| — | | 1095+ | Ghi chú: đúng nguồn; thiếu #2, 3, 4, 5, 8, 9; dòng 1108 sửa "QC-05 đã quyết" | | |

### G06 Backlog, rollover, lưu trữ (`g06-backlog-rollover.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | TB | 749-751 | R2 | | Flow |
| 2 | TB | 755-757, 796 | R2 MSG-25 / MSG-27 | | SRS |
| 3 | TB | 102-107, 317-321, 659-664 | R6 câu lỗi | | SRS |
| 4 | TB | 305, 309 | R6 phím S/D | | SRS |
| 5 | TB | 275, 66 | UC-03 "kéo ra ở panel ngày SCR-01 hoặc board G04"; UC-01 A2 "kéo vào trang / panel". IA (`IA:62, 77-87`): trang Backlog thay vùng chính nên không kéo từ trang ra board; "panel ngày" của SCR-01 #8 (`srs-g06:390`) không có trong IA | Tách hai điểm vào: SCR-01 #8 và panel Backlog (Shift+B); UC-01 A2 bỏ "trang". PO xác nhận "panel ngày" | PO |
| 6 | TB | 369, 373 | Xem G03 #4 | | Flow |
| 7 | Thấp | 33, 418 | R7 | | Flow |
| 8 | Thấp | 540 | UC-05 A2 (`srs-g06:287`) "không lưu trữ task đang chạy timer" nhưng BR-12 (`:48`) và QC-05 "Tự lưu trữ: timer không dừng" ngụ ý vẫn lưu trữ | PO chốt | PO |
| 9 | Thấp | 64 | UC-01 A1 thiếu nửa BR-03 (`srs-g06:39`): task đã ở backlog → lên đầu bucket hiện tại | Thêm | Flow |
| 10 | Thấp | UC-03 | SRS thiếu nhánh mất mạng và `TASK_DELETED` dù UC-01 có và NFR (`srs-g06:516`) nói chạy offline được | Sửa SRS rồi vẽ | SRS |
| 11 | Thấp | SCR-07 | Nhãn "Dời {n} ngày" đổi màu cảnh báo khi n = ngưỡng − 1 (`srs-g06:441`) không có trong flow và ghi chú | Thêm trạng thái | Flow |
| — | | 794+ | Ghi chú: 1, 3–10 đúng; sửa 2 (IA đã chốt); thiếu #3, 4, 5 | | |

### G07 Focus và timer (`g07-focus-timer.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | TB | 69-70, 127 | R3 IA-05 (d) phím toàn cục / khay hai chiều | | SRS |
| 2 | TB | 164 | R6 dừng timer | | SRS |
| 3 | TB | 324 | UC-04 chọn task cho Focus: BR-12 (`srs-g07:46`) task đang chọn / task đầu tiên chưa xong; SCR-01 #3 (`:392`) badge Focus mở **task đang chạy timer** — hai quy tắc, hai task | Thêm nhánh "có timer đang chạy → task đang chạy"; PO xác nhận | PO |
| 4 | TB | 329-330 | MSG-10 âm báo theo kế hoạch vẽ như chỉ trong Focus; BR-07 (`:41`) áp mọi timer ở mọi màn; ở khay không ai thấy, D12 không có thông báo Windows | Ghi chú; PO quyết thông báo Windows | PO |
| 5 | TB | 128 | Điểm vào "Dừng timer" thiếu banner MSG-27 G08 SCR-08 #4 (`g08:375` trỏ sang) | Thêm | Flow |
| 6 | Thấp | 473-474 | UC-06 E1 cạnh `e1 → p2` đọc như gửi thông báo lỗi thì timer tự đóng; "không chặn bước 3" (`srs-g07:301`) nghĩa là bước tự đóng vẫn chạy khi > 24 giờ | Nối về vòng "lượt sau" | Flow |
| 7 | Thấp | 133 | Khối thực tế chỉ vẽ khi bật "Hiện actual trên lịch" (G05 BR-18) và không có khi < 10 giây; flow vẽ như luôn có | Thêm điều kiện | Flow |
| 8 | Thấp | 463 | UC-06 A6 bộ chọn "Dừng lúc…" chưa có mã SCR | Ghi chú | SRS |
| — | | 611+ | Ghi chú: 10 mục đúng; #1 đổi kết luận (IA thắng, vẽ cả chiều dừng); thiếu #2, 3, 4 | | |

### G08 Daily planning và shutdown (`g08-daily-rituals.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 110-118, 292 | UC-01 A6 (Plan cho ngày D > hôm nay) nối về `s1` rồi chạy tới `ok` "Bắt đầu ngày · Home / Today". SRS (`srs-g08:125`): nút đổi thành "Xong", **không chuyển trang**; SCR-07 #6 (`:394`) có hai nhãn | Kết thúc riêng: "Xong → RitualComplete → wizard đóng, ở lại board / cột D". Ghi chú: không gọi RolloverEnsure khi D > hôm nay | Flow |
| 2 | Cao | 252-256 | UC-01 A13 (412): sau gộp nhảy tới `s6` (bước 6); đúng là ở lại **bước đang làm** vì RitualUpdate ở mọi bước. 412 cũng đến từ RitualComplete (BR-26 `srs-g08:62`) nhưng A13 chỉ mọc từ `pu` | Nối `a13`/`a13m` về `s1` "bước hiện tại"; thêm cạnh `p7 -->\|A13 · 412\|` | Flow |
| 3 | TB | 123-124 | R6 Plan my day | | Flow |
| 4 | TB | 199 | R2 BR-06 | | SRS |
| 5 | TB | 460, 501 | UC-02 A11 trỏ sang UC-01 A12/A13. Shutdown nhận 409 phải mở SCR-10 chế độ xem (UC-02 A4, SCR-10 #3 `srs-g08:420`), không phải SCR-06; A11 chỉ mọc từ `p5` trong khi 412 ở mọi bước | Vẽ A11 riêng: MSG-15 → "SCR-10 chế độ xem"; 412 từ bước bất kỳ | Flow |
| 6 | TB | 382-384, 497 | R6 highlights | | Flow |
| 7 | TB | 660-661, 722 | R3 IA-03 | | PO |
| 8 | TB | 619, 627 | R3 IA-05 (a) | | PO |
| 9 | TB | 22, 28 | R5 | | SRS |
| 10 | TB | 126-127, 302 | E1 và xem phiên ngày đã qua: IA-20 (`IA:164`) cột đã qua không có nút "Plan", P / sidebar luôn hôm nay → E1 gần như không có đường tới; ngược lại PRD AC05 (`prd-g08:138`), BR-02 "ngày đã qua chỉ xem bản đã có" không có điểm vào, không vẽ | PO chốt điểm vào xem phiên cũ (từ task ghi chép?) hoặc bỏ AC05; E1 ghi "chỉ khi qua mốc" | PO |
| 11 | TB | 36, 189-235 | R6 TimeboxLink | | Flow |
| 12 | Thấp | 189-235 | UC-01 bước 1 thiếu nhánh instance lặp: D đưa instance vào ngày đã có instance cùng series → QC-06 (BR-06). UC-02 có A9, UC-01 không | Thêm nhánh "BR-06 · QC-06" | Flow |
| 13 | Thấp | 824 | R3 IA-16 ghi chú Esc | | Flow |
| 14 | Thấp | 319 | "Bước shutdown chưa kiểm chứng" đã lỗi thời: `kiem-chung-sunsama-chrome.md:137-140` kiểm chứng shutdown Sunsama là một trang, không có bước xử lý task chưa xong | Ghi chú "PO chốt giữ SCR-09 (khác có chủ đích)" | Flow |
| — | | 823+ | Ghi chú: 7 mục đúng; thiếu #1, 4, 6, 7, 8, 9, 10, 14 | | |

### G10 Trợ lý AI (`g10-tro-ly-ai.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 158-256 | UC-02 thiếu nhánh nút "Dừng" (SCR-02 #6 `srs-g10:596`, BR-09 `:50`): Dừng → luồng thủ công, thay đổi đã áp dụng giữ, có "Hoàn tác kế hoạch AI". G08 (`g08:124`) có nhắc, G10 (sở hữu) không vẽ | Thêm `s2 -->\|SCR-02 #6 · Dừng\|` vào thoi `d1` "Đã áp dụng thay đổi nào?". Ghi chú SRS chưa đặt mã A# | Flow |
| 2 | Cao | 228-237 | E1/E6 khi agent đã áp dụng một phần: `e1b` hứa "kèm Hoàn tác kế hoạch AI" nhưng MSG-05, MSG-28 (`srs-g10:790, 813`) không có nút; kết thúc "G08 thủ công bước 1" nhưng G08 chỉ đặt nút Hoàn tác ở bước 5 (BR-24, SCR-06 #5 `srs-g08:383`). Lỗ hổng SRS | SRS: thêm "Hoàn tác kế hoạch AI" vào MSG-05/28 khi n > 0 (như MSG-27), hoặc G08 hiện nút ở bước 1 khi có đề xuất `DA_AP_DUNG` | SRS |
| 3 | TB | 391, 452 | UC-03 E9 "Nút Trợ lý ẩn" trái IA-01 (`IA:203`), IA mục 2, 4 (`IA:50, 86`): ✨ cố định; Claude Code chưa sẵn sàng → SCR-11 trong mục Trợ lý, mở bằng ✨ / Ctrl+J / Ctrl+K. SRS E9 (`:269`), BR-25 (`:66`) ghi ẩn; Điểm vào của chính SRS (`:562`) giống IA | Flow: "✨ / Ctrl+J / Ctrl+K → SCR-11". Sửa SRS E9, BR-25 | SRS |
| 4 | TB | 218, 231-233, 396 | R3 IA-17 (b) | | PO |
| 5 | TB | 1111 | R3 IA-05 (b) | | PO |
| 6 | Thấp | 235 | E1 nhãn "Obstacles in my way" là chữ Sunsama; G08 gọi "Trở ngại" (SCR-06 #2), ô ở bước 5 trong khi kết thúc là bước 1 | Sửa SRS E1 (`:211`) rồi flow | SRS |
| 7 | Thấp | 655-656 | UC-05 highlights dùng MSG-05 "lập kế hoạch thủ công", MSG-27 "thay đổi đã áp dụng · Hoàn tác" — sai ngữ cảnh (`srs-g10:345, 790, 812`) | SRS thêm MSG riêng cho highlights | SRS |
| 8 | Thấp | 608, 687 | UC-05 A4 "trạng thái rỗng của G08" — G08 SCR-10 không có trạng thái rỗng, MSG-18 ở SCR-08 | Sửa SRS A4 hoặc thêm trạng thái rỗng SCR-10 | SRS |
| 9 | Thấp | 1156, 1191 | R3 IA-05 (c) | | Flow |
| 10 | Thấp | 1274+ | Ghi chú chưa nhắc dự phòng ADR-0009 (phát hiện đăng nhập gói / API key → thêm trạng thái SCR-11 / UC-10) | Thêm dòng `[cần kiểm chứng]` | Flow |
| — | | 1274+ | Ghi chú: 9 mục đúng; thiếu #1, 2, 3, 4, 7, 10. Không vi phạm ADR-0004 | | |

### G12 Workspace, thông báo (`g12-workspace-billing.md`)

| # | Mức | Vị trí | Vấn đề | Đề xuất | Sửa ở |
|---|---|---|---|---|---|
| 1 | Cao | 191, 218-246 | R3 IA-17 (c) | | SRS |
| 2 | TB | 242-244 | UC-09 E1 lỗi tải danh sách dùng MSG-38 "Chưa lưu được thay đổi. Thử lại" (`srs-g12:417, 678`) — chữ nói về lưu | SRS thêm MSG "Không tải được thông báo. Thử lại" | SRS |
| 3 | TB | 218-262 | UC-09 thiếu nhánh lỗi khi `NotificationRead` lỗi / mất mạng (bấm dòng và A1 "Đánh dấu tất cả"); hậu điều kiện thất bại (`srs-g12:393`) ngầm có nhưng không mã E | SRS thêm E3 (giữ chấm, badge không đổi, hàng đợi); vẽ | SRS |
| 4 | TB | 134-167 | UC-08 thiếu nhánh xung đột: BR-18 (`srs-g12:52`) theo G01 BR-12 (412 → MSG-41) nhưng không vẽ | Thêm nhánh giống G01 UC-06 A6 | Flow |
| 5 | TB | 34 | Xem G01 #7 | | SRS |
| 6 | Thấp | 191, 231, 239-240 | UC-09 thiếu điểm vào Ctrl+K "Thông báo" (`IA:51, 150`); đi từ thông báo Windows gặp A2 thì kết thúc "SCR-11 giữ mở" sai vì SCR-11 chưa mở | Thêm điểm vào; kết thúc riêng | Flow |
| 7 | Thấp | 148 | UC-08 A2 sau "Bật lại" flow dừng; SCR-14 #2 (`srs-g12:577`) không nói hiện gì, không MSG | Ghi chú | SRS |
| 8 | Thấp | 38 | UC-05 tên workspace ở 1.0 không hiện ở đâu ngoài SCR-12 | PO xác nhận A5 có tác dụng thấy được | PO |
| — | | 284+ | Ghi chú: 7 mục đúng; thiếu #1, 2, 3, 4, 5, 7 | | |

---

## 4. Việc PO phải chốt (trước khi sửa flow)

Sắp theo tác động tới số màn / nhánh phải vẽ.

| # | Câu hỏi | Liên quan | Mặc định tôi đề xuất |
|---|---|---|---|
| P1 | Timebox liên kết sự kiện khi đổi ngày / xoá / backlog: theo QC-05 (chỉ gỡ liên kết)? | R1 — G02, G04, G05 | **Theo QC-05.** Sửa G04 BR-09, G02 BR-11; UC-11 A3 kết thúc "cờ mất vì timebox mất" |
| P2 | App ở khay: lượt tự mở ritual và toast không ai thấy. Chỉ ghi `autoPromptedAt` khi cửa sổ hiện? Khi ẩn dùng thông báo Windows? Nhắc khi đang Focus thế nào? | R3 IA-05, IA-03 — G07, G08, G10 | Chỉ ghi khi cửa sổ hiện; khi ẩn hoặc Focus → thông báo Windows (mở rộng D12) |
| P3 | Banner AI (G10 MSG-05/06/27/28) đặt ở đâu? | R3 IA-17 — G10 | Inline trong wizard / panel Trợ lý, không vào hàng đợi banner vùng chính |
| P4 | Onboarding xong → Home hôm nay (IA-12) hay mở Daily planning (G01 BR-11)? "Chế độ có hướng dẫn" của G08 là gì? | R3, R5 — G01, G08 | Home hôm nay, wizard tự mở thay vùng chính; G08 định nghĩa "có hướng dẫn" = thêm tooltip theo ngữ cảnh ở từng bước |
| P5 | Trang web tối giản: cách kiểm "đúng tài khoản" khi không có đăng nhập web ở 1.0? | R4 — G01 | Token trong link đủ; không kiểm thêm |
| P6 | Instance lặp: ngày đầu = hôm nay (A1) hay ngày khớp quy tắc đầu tiên (BR-02)? Instance ở backlog chịu Dừng lặp / Đổi tần suất / Áp mẫu thế nào? | G03 #1, #2 | Theo BR-02; instance backlog xử lý như instance tương lai |
| P7 | Esc lần 1 trên ô soạn: bỏ focus giữ nháp (IA-16) hay đóng (SRS A3)? | G02 #11 | Theo IA-16 |
| P8 | Hết hạn mức khi gợi ý AI ở ô soạn: im lặng (SRS A4) hay hiện thông báo Claude Code (QC-12)? | G02 #12 | Im lặng ở ô soạn; hiện ở panel Trợ lý |
| P9 | `LINKED_TASK` ở 1.0: có loại liên kết nào ngoài G11 không? | R8 — G02 | Không → Bỏ (1.1) |
| P10 | E4 giới hạn số tài khoản lịch ở 1.0 khi chưa có QC-10? | G05 #7 | Bỏ (1.1) |
| P11 | "Panel ngày" ở G06 SCR-01 #8 là gì trong IA? | G06 #5 | Bỏ; chỉ còn panel Backlog (Shift+B) |
| P12 | Tự lưu trữ task đang chạy timer: lưu (BR-12, QC-05) hay không (UC-05 A2)? | G06 #8 | Lưu, timer không dừng |
| P13 | S / "Hoãn 1 tuần" đưa instance lặp vào ngày trùng series: tự động hay thủ công theo QC-06? | G04 #10 | Thủ công (có toast Hoàn tác) |
| P14 | Focus mở task nào khi có timer đang chạy ở task khác task đang chọn? | G07 #3 | Task đang chạy timer |
| P15 | G08: điểm vào xem phiên ritual ngày đã qua (PRD AC05)? | G08 #10 | Từ task ghi chép ritual |
| P16 | Thả task đã có timebox vào ngày khác: timebox cũ đi theo (QC-05) hay ở lại và cờ Lệch ngày (G05 BR-05/BR-22)? | G05 #4 | Đi theo (QC-05); BR-05 chỉ áp khi thả **lên lịch**, không phải cột ngày |

## 5. Thứ tự sửa đề xuất

1. **PO trả lời mục 4** (một buổi, 16 câu, có mặc định).
2. **Sửa SRS/PRD/QC** theo R1, R2, R4, R5, R6 và các dòng "Sửa ở: SRS" — mỗi nhóm một commit, ghi ngược quyết định IA còn thiếu (IA-19, IA-20, IA-05, IA-15, IA-17).
3. **Sửa flow** cùng commit với SRS tương ứng (quy ước `_quy-uoc.md` mục 2): ưu tiên 11 phát hiện Cao, rồi R6 (thống nhất giữa nhóm), rồi R7/R8 (nhãn).
4. **Cập nhật "Ghi chú cho brief"** mỗi file theo dòng "—" ở mục 3.
5. Chạy lại kiểm máy (cú pháp, mã, link) rồi mới bắt đầu brief G02 đầy đủ (#11).

Việc 2–5 agent làm được; việc 1 cần PO.
