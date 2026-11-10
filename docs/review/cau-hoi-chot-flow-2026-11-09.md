# Câu hỏi cần chốt trước khi viết brief — 09/11/2026

> **Nguồn:** mục "Ghi chú cho brief" cuối 10 file [`docs/design-brief/flow/`](../design-brief/flow/README.md) (89 ghi chú còn mở) và các câu "Cần chốt thêm" trong issue brief #12, #13, #16, #17, #18, #19 (18 câu).
> **Đã loại:** các điểm đã sửa trước đây: G04 ghi chú 8 và G05 BR-21 (timebox liên kết sự kiện, QC-05); G06 hai ghi chú về banner rollover thất bại (F2, G06 BR-24); "Lệch ngày" (F5); công tắc AI hoàn thành / xoá (F4).
> **Trạng thái:** **PO đã chốt ngày 09/11/2026**: A đồng ý hết, B theo phương án đề xuất, C đồng ý (bảng cuối file). Đã ghi vào QC-08 mục 7, QC-13, IA (banner), SRS / PRD và flow của từng nhóm.

## Cách trả lời

Danh sách có ba phần:

| Phần | Số mục | Cần làm gì |
|---|---|---|
| **A. Quy tắc chung** | 10 | Mỗi quy tắc áp cho nhiều chỗ ở nhiều nhóm. Đồng ý hoặc sửa từng quy tắc |
| **B. Câu cần chọn** | 48 | Mỗi câu có phương án, **phương án in đậm là đề xuất**. Chọn A / B / C hoặc ghi ý khác |
| **C. Sửa tài liệu** | 52 | Không cần chọn: thêm mã thiếu, sửa chữ sai ngữ cảnh, sửa SRS theo nguồn đã chốt (IA, ADR, QC). Đồng ý cả gói hoặc nêu mục muốn khác |

Trả lời ngắn được, ví dụ: *"A: đồng ý hết. B: theo đề xuất, trừ B05 chọn B, B36 chọn B. C: đồng ý."*

Phần B xếp theo thứ tự viết brief: G02 → G04 → G06 → G03 → G05 → G07 → G08 → G01 → G10 → G12.

---

## A. Quy tắc chung

| Mã | Quy tắc đề xuất | Áp cho | Chốt |
|---|---|---|---|
| A1 | **Lỗi tải khác lỗi lưu.** Thêm vào QC hai câu chung có mã riêng: lỗi lưu "Chưa lưu được thay đổi. Thử lại", lỗi tải "Chưa tải được. Thử lại". Các nhóm trỏ về mã chung, không khai báo lại cùng một câu | G03 UC-07 E1, G06 UC-02 E4 (đang dùng câu lỗi lưu cho lỗi tải); G02 MSG-10 và G03 MSG-12 (cùng chữ, hai mã) | |
| A2 | **Kéo thả và Hoàn tác.** Kéo đổi chỗ trong cùng một cột: không toast, Ctrl+Z hoàn tác. Kéo sang nơi khác (ngày khác, vào / ra Backlog, lên lịch): có toast Hoàn tác như khi làm bằng phím hay menu | G04 UC-04 A1, A2; G04 UC-03 A3; G06 UC-01 A2; G06 UC-03 | |
| A3 | **Hai thông báo cùng lúc thì gộp một toast.** Dòng 1 là kết quả thao tác chính, giữ nút Hoàn tác của nó; dòng 2 là thông tin phụ | G04 UC-03 A4 (MSG-23 + MSG-01); G03 UC-04 A6, UC-05 A2 (MSG-24 + MSG-07 / 09 / 11); G05 UC-03 A1 (MSG-23 + MSG-09); G08 hoàn tất ritual (MSG-09 / 26 + MSG-10) | |
| A4 | **Không có ký hiệu trong chữ.** Dấu tích là icon đặt cạnh chữ ("Đã lưu", "Đã kết nối"), không nằm trong nội dung MSG | G01 MSG-22, SCR-05 bước 2; G05 SCR-05 #6 | |
| A5 | **Banner.** Chỉ một banner offline chung của board (G04 SCR-01 #5, thêm mã MSG). Daily planning không có banner offline riêng: bỏ G08 MSG-23. Banner nhắc ritual (G08 SCR-12) vào hàng chờ IA-17, đứng sau mọi banner lỗi và offline | G04 UC-01 E1; G08 UC-01 E3, UC-04 A3 | |
| A6 | **Mất mạng.** Theo QC-08: thao tác đơn lẻ (đổi cài đặt, dời / gỡ timebox) chạy trên máy, vào hàng đợi, có dấu "Chờ đồng bộ". Thao tác trên cả chuỗi lặp cần mạng: nút mờ kèm tooltip "Cần có mạng để sửa cả chuỗi". Thêm nhánh E# mất mạng vào các UC còn thiếu | G01 UC-06, UC-10; G03 UC-04, UC-05, UC-07; G05 UC-04 | |
| A7 | **Chữ chưa có mã MSG.** Brief đặt mã `UI-xx [đề xuất]` cho mọi chữ còn thiếu (trạng thái, nhãn, banner, tooltip); PO duyệt brief thì ghi ngược thành MSG trong SRS | Các mục C ghi "(A7)" | |
| A8 | **Màn chưa có mã SCR.** Brief đặt mã `SCR-Nxx`, ghi ngược vào SRS khi duyệt | Các mục C ghi "(A8)" | |
| A9 | **Phần của 1.1 / 1.2 trong SRS 1.0.** Ẩn hẳn ở 1.0 (không hiện mờ); SRS ghi nhãn "(1.1)" / "(1.2)" | G05 MSG-13; G04 UC-04 "chỉ đọc"; G06 UC-03 A4 (Weekly); G10 `CHO_DUYET`, `LINKED_TASK`, chữ Gmail / Jira / Notion; G12 UC-06 Privacy, UC-08 A1 | |
| A10 | **Hoàn tác đưa về đúng trạng thái ngay trước thao tác:** ngày, vị trí, bucket, lý do lưu trữ; bản ghi thời gian vừa tạo thì xoá | G06 MSG-03, MSG-14, MSG-16; G07 MSG-03 | |

---

## B. Câu cần chọn

### G02 Quản lý task

Không có câu cần chọn. Một mục sửa tài liệu ở C01.

### G04 Board ngày

**B01 · Cửa sổ hẹp thì board chuyển 1 cột ở mốc nào?** (UC-01 A9; IA mục 4)
SRS ghi "< 768 px → 1 cột", nhưng cửa sổ tối thiểu là 800 px nên trường hợp này không bao giờ xảy ra.
- **A. Không có chế độ 1 cột ở 1.0.** Board giữ cột ngày tối thiểu 200 px và cuộn ngang. Ở 800 px, sidebar đã thu thành cột icon, vùng chính vẫn đủ 3 cột.
- B. Dưới 1024 px chuyển 1 cột, Shift+← / → đổi ngày.

**B02 · Ctrl+F khi đang gõ trong một ô nhập?** (BR-17 trái UC-08 A6)
- **A. Luôn mở Search (giữ BR-17), sửa UC-08 A6.** Ô nhập trong app không có chức năng tìm trong ô.
- B. Giữ hành vi của ô nhập, Ctrl+F chỉ mở Search khi không gõ.

**B03 · Lỗi tải một ngày (MSG-15) hiện ở đâu?** (UC-02 E2)
- **A. Ngay trong cột đó:** khung cột rỗng có chữ lỗi và nút "Thử lại".
- B. Toast.

**B04 · Có cho đánh dấu xong task ở cột ngày đã qua, và có "bản mờ" ở cột cũ không?** (#12)
- **A. Giữ chặn (`PAST_DATE`), không có bản mờ ở 1.0.** Rollover đã chuyển việc dở sang hôm nay, nên cột cũ chỉ còn việc đã xong.
- B. Cho đánh dấu xong ở ngày cũ, và hiện bản mờ ở cột cũ chỉ chỗ task đã bị dời đi.

**B05 · Có mức cảnh báo "sắp chạm ngưỡng" không?** (#12; Q48)
Ngưỡng theo từng ngày đã có sẵn: Q48 tính theo thời gian trống của lịch làm việc ngày đó.
- **A. Chỉ một mức "quá tải"**, cho giao diện điềm tĩnh (DS-01).
- B. Thêm mức vàng khi khối lượng đạt 85 % sức chứa.

### G06 Backlog, rollover, lưu trữ

**B06 · Toast sau phím Z (đưa vào Backlog) có nút "Hoàn tác" không?** (MSG-01 trái BR-17)
- **A. Có, thêm "Hoàn tác" vào MSG-01.** BR-17 đã nói Z luôn có toast Hoàn tác.
- B. Không, chỉ hoàn tác được bằng Ctrl+Z.

**B07 · Toast tự lưu trữ (MSG-11) khi rollover chạy ngay lúc mở app thì hiện khi nào?** (UC-05 bước 4)
- **A. Hiện ngay khi lượt chạy xong.**
- B. Đợi lần mở app sau.

**B08 · Instance lặp bị lỡ nhưng đã sửa riêng hoặc đã có thời gian thực tế: có được miễn tự lưu trữ (QC-06) không?** (#13, #17)
- **A. Có.** Instance đó giữ lại và rollover như task thường.
- B. Không, vẫn vào Lưu trữ như mọi instance bị lỡ.

**B09 · Instance bị bỏ qua (`skipped`) có hiện trong Lưu trữ không?** (#13)
- **A. Hiện, kèm nhãn "Đã bỏ qua".**
- B. Ẩn.

**B10 · Có cho chỉnh ngưỡng tự lưu trữ trên giao diện không?** (#13)
- **A. Không ở 1.0, ngưỡng cố định.**
- B. Có, trong Cài đặt.

**B11 · Subtask đã tích hoặc thời gian thực tế có tính là "có hoạt động" (nên không bị tự lưu trữ) không?** (#13)
- **A. Có.**
- B. Không.

**B12 · Có khôi phục thẳng từ Lưu trữ vào Backlog được không?** (#13)
- **A. Có, hai lựa chọn: "Khôi phục vào hôm nay" và "Khôi phục vào Backlog".**
- B. Chỉ khôi phục vào ngày.

**B13 · Backlog có mức ưu tiên (priority) riêng không?** (#13)
- **A. Không ở 1.0.**
- B. Có.

### G03 Task lặp lại

**B14 · "Dừng lặp" xử lý các instance tương lai thế nào?** (#17; câu hỏi mở PRD G03)
- **A. Xoá các instance tương lai chưa động tới; giữ các instance đã sửa riêng, đã dời hoặc đã có thời gian thực tế.**
- B. Xoá hết các instance tương lai (cách Sunsama làm).
- C. Giữ hết, chỉ ngừng sinh instance mới.

**B15 · Đổi tần suất hoặc dừng lặp từ danh sách chuỗi lặp trong Cài đặt?** (UC-07 trái tiền điều kiện UC-04)
- **A. Làm ngay trên dòng của danh sách:** mở bộ chọn tần suất hoặc hộp xác nhận, không cần mở instance.
- B. Mở instance kế tiếp trước, rồi làm như UC-04.

**B16 · Nút Trước / Sau giữa các lần lặp khi chuỗi đã dừng?** (UC-03 A5)
- **A. Vẫn hiện, bỏ qua các instance đã xoá.**
- B. Ẩn.

### G05 Lịch và timebox

**B17 · Ở 1.0 có giới hạn số tài khoản lịch không?** (UC-01 E4; BR-01, giá trị 5 `[giả định]`)
- **A. Có, giới hạn kỹ thuật 5 tài khoản**, đọc từ bảng quyền nên sau này đổi được.
- B. Không giới hạn.

**B18 · "Lịch ghi mặc định" chọn ở đâu?** (SCR-01 #5 và SCR-02 #4 trùng nhau)
- **A. Chỉ ở Cài đặt → Lịch (SCR-01), có lựa chọn "Không ghi ra lịch ngoài".** Màn chọn lịch lúc kết nối (SCR-02) bỏ phần này.
- B. Cả hai chỗ, luôn cùng một giá trị; SCR-02 thêm lựa chọn "Không ghi".

**B19 · Đổi giờ một timebox mà sự kiện không còn trên lịch ngoài (lỗi 404)?** (UC-06 E5)
- **A. Gỡ timebox và báo MSG-14**, giống UC-07 A1.
- B. Gỡ timebox, không báo gì.

**B20 · Có lệnh "Timebox…" trong command menu không?** (UC-03 A9; G04 chưa có lệnh này)
- **A. Có, thêm vào command menu G04.** DS-08 yêu cầu mọi thao tác kéo thả đều làm được bằng phím.
- B. Không, bỏ A9.

**B21 · Kéo timebox sang ngày khác đúng lúc thiết bị khác cũng vừa sửa task?** (UC-04 E2 trái bảng lỗi mục 8)
- **A. Báo câu xung đột chung (QC-08) và tải lại.**
- B. Không báo, lấy bản mới nhất.

**B22 · Task có nhiều timebox, bấm "Gỡ khỏi lịch"?** (BR-06; C19)
- **A. Bấm trên một block thì chỉ gỡ block đó; Ctrl+X trên task thì gỡ hết.**
- B. Luôn gỡ hết.

### G07 Focus và timer

**B23 · Menu khay khi chưa có timer nào chạy?** (BR-23)
Đi kèm: khi đang có timer, Ctrl+Shift+Space và menu khay sẽ **dừng** timer (sửa ở C25).
- **A. Có mục "Bật timer: {task kế tiếp hôm nay}".**
- B. Chỉ có "Mở Wakeup" và "Thêm task".

**B24 · Timer tự đóng sau 24 giờ thì màn hỏi giờ dừng (SCR-06) hiện khi nào?** (UC-06 bước 4)
- **A. Hiện ngay nếu cửa sổ đang mở; nếu app đang ở khay thì hiện lần đầu cửa sổ được mở lên.** Giờ dừng chọn trong khoảng từ lúc bắt đầu tới lúc sớm hơn trong hai mốc "bây giờ" và "bắt đầu + 24 giờ". Áp chung cho SCR-06 và "Dừng lúc…".
- B. Chỉ hiện khi mở lại app.

**B25 · Trong Focus mode, xong một task rồi bấm "Bắt đầu"?** (UC-04 A1)
- **A. Chuyển sang task kế tiếp và bật timer luôn.**
- B. Chỉ chuyển sang task kế tiếp, chờ bấm bật timer.

**B26 · Lượt timer dưới 10 giây bị bỏ, có báo người dùng không?** (BR-04)
- **A. Không báo.** Lượt này thường là bấm nhầm.
- B. Toast "Lượt dưới 10 giây không được ghi".

**B27 · Các nút trong nhắc "timer chạy quá 4 giờ" (MSG-11)?** (SRS và PRD lệch nhau)
- **A. "Dừng · Dừng lúc… · Vẫn đang làm" (theo SRS), sửa PRD.**
- B. "Dừng · Dừng lúc… · Tiếp tục" (theo PRD).

### G08 Daily planning và Daily shutdown

**B28 · Nút "Plan my day" (Planning Agent) nằm ở đâu trong wizard?**
- **A. Ở đầu bước 1.** Chạy xong thì nhảy thẳng tới bước "Daily plan"; lỗi hoặc bấm Dừng thì về lại bước 1.
- B. Thành một bước riêng, trước bước 1.

**B29 · Cột ngày xa hơn hôm nay + 7 ngày?** (BR-02; MSG-20 sai nghĩa)
- **A. Không hiện nút "Plan" trên các cột đó;** thêm câu lỗi riêng cho trường hợp API từ chối.
- B. Vẫn hiện nút, bấm thì báo lỗi.

**B30 · "Gửi bản sao cho chính tôi" có tính là gửi email (để hiện MSG-10) không?** (UC-03 bước 5)
- **A. Có.**
- B. Không.

**B31 · Có "chế độ buổi tối" không, tức mở Daily planning sau 15:00 thì mặc định lên kế hoạch cho ngày mai?** (#16, #19)
- **A. Không ở 1.0.** Muốn lên kế hoạch ngày mai thì bấm "Plan" trên cột ngày mai (UC-01 A6 đã có).
- B. Có.

**B32 · Bước "Xem lại hôm qua" khi hôm qua đã làm Daily shutdown?** (#16)
- A. Vẫn hiện.
- **B. Bỏ qua bước này,** vì việc xem lại đã làm lúc shutdown.

**B33 · Daily shutdown có bước xử lý từng task chưa xong không?** (#16)
- **A. Giữ bước này, kèm nút "Để tự chuyển sang mai" để bỏ qua cả bước.**
- B. Bỏ bước, để rollover tự xử lý như Sunsama.

**B34 · Có tách highlights khỏi ghi chú suy ngẫm riêng không?** (#16)
- **A. Tách hai ô:** highlights chia sẻ được; ghi chú suy ngẫm chỉ mình thấy, không bao giờ gửi đi.
- B. Một ô chung.

**B35 · Làm lại ritual trong cùng ngày thì ghi chú cũ xử lý thế nào?** (#16)
- **A. Mở lại ghi chú lần trước để sửa (ghi đè).**
- B. Nối thêm vào ghi chú cũ.

### G01 Tài khoản, onboarding, cài đặt

**B36 · Onboarding có bắt nhập ít nhất 1 task không?** (#19; PRD G01 AC05 `[giả định]`)
- **A. Không bắt, có nút "Bỏ qua".**
- B. Bắt nhập ít nhất 1 task.

**B37 · Xoá tài khoản khi tài khoản chỉ đăng nhập bằng Google / Microsoft?** (SCR-12 chỉ có ô Mật khẩu)
- **A. Thay ô mật khẩu bằng nút "Xác nhận bằng Google / Microsoft"** (theo UC-09 bước 3); thêm nhánh lỗi khi xác nhận thất bại.
- B. Bắt đặt mật khẩu trước khi xoá.

**B38 · Đổi mật khẩu hoặc đổi email có đăng xuất mọi thiết bị khác không?** (BR-09 `[giả định]`; MSG-19, MSG-30 đang báo là có)
- **A. Có.**
- B. Không, và sửa chữ của MSG-19, MSG-30.

**B39 · Link đặt lại mật khẩu hết hạn, bấm "Gửi link mới" (MSG-18)?** (UC-04 E1)
- **A. Về màn nhập email, điền sẵn email.**
- B. Gửi link mới ngay tới email cũ.

**B40 · Bản xuất dữ liệu bị lỗi?** (UC-08: mục 4.2 và E2 nói khác nhau)
- **A. Tự thử lại 3 lần; vẫn lỗi thì hiện nút "Tạo bản xuất mới".**
- B. Hiện nút "Thử lại" ngay từ lần lỗi đầu.

**B41 · Nút ở bước nhập liệu của onboarding khi ô chưa hợp lệ?** (UC-05 E3)
- **A. Luôn bấm được; bấm thì hiện MSG-21,** giống UC-01 E3.
- B. Mờ đi tới khi ô hợp lệ.

### G10 Trợ lý AI

**B42 · Đặt lại các nhãn đang có chữ "Claude Code"** (ADR-0004 chỉ cho dùng "chạy bằng Claude Code" làm chữ phụ)
- **A.**
  - SCR-09 #13: "Dùng trợ lý từ terminal".
  - Tiêu đề SCR-10: "Bật trợ lý AI".
  - Tên SCR-11: "Cài đặt để dùng trợ lý AI".
  - Chữ phụ nhỏ "chạy bằng Claude Code" ở những chỗ cần.
- B. Nhãn khác (ghi rõ).

**B43 · Một thay đổi của AI không thực hiện được?** (UC-03 E6 trái BR-21)
- **A. Chip "Không thực hiện được" trên thay đổi đó, kèm một dòng MSG-19 trong khung chat.**
- B. Chỉ có chip.

**B44 · Claude Code chưa sẵn sàng (chưa cài, chưa đăng nhập…)?** (UC-09 tiền điều kiện `[giả định]`)
- **A. Ẩn mọi điểm vào AI, thay bằng thẻ hướng dẫn cài (SCR-11).**
- B. Vẫn hiện điểm vào, bấm thì báo.

**B45 · Bộ trạng thái lỗi của trợ lý?** (#18)
- **A. Đủ 6 trạng thái:**
  - đăng nhập hết hạn;
  - tài khoản bị chặn;
  - hết hạn mức (kèm giờ reset);
  - đang thử lại;
  - câu trả lời bị cắt;
  - mất kết nối với app.

  Chữ chốt sau khi thử thật trên Windows (#24).
- B. Giữ 4 trạng thái hiện có.

**B46 · Có học theo các tính năng AI của Sunsama không?** (#18)
- **A.**
  - Có "biên nhận": màn Hoạt động AI và chip AI (đã có).
  - Có hỏi lại khi AI không chắc.
  - "Rules" (luật người dùng đặt cho AI) để bản 1.1.
- B. Có cả Rules ở 1.0.

### G12 Workspace và thông báo (phần 1.0)

**B47 · Có nút "Xoá workspace" không?** (SCR-12 #2 ghi 1.1; BR-14, BR-28 nói khác)
- **A. Không có ở 1.1.** Workspace một người thì xoá bằng cách xoá tài khoản (G01); xét lại ở 1.2 khi có nhiều thành viên.
- B. Có ở 1.1, chỉ cho `OWNER`.

**B48 · Trang huỷ đăng ký email có link "Mở cài đặt thông báo", mà 1.0 chưa có web app?** (SCR-14 #3)
- **A. Ẩn link này ở 1.0, bật khi có web (1.1).**
- B. Link mở app Windows (deep link) tới Cài đặt → Thông báo.

---

## C. Sửa tài liệu (không cần chọn)

| Mã | Nhóm | Sửa | Theo |
|---|---|---|---|
| C01 | G02 | Thêm MSG riêng cho xung đột khung giờ channel (UC-06 A9), thôi dùng MSG-12 "Task vừa được cập nhật…" | Chữ sai ngữ cảnh |
| C02 | G04 | Đặt mã SCR cho Today view (UC-01 A1) và panel Tasks (Shift+T) | A8 |
| C03 | G04 | Thêm MSG cho banner "Đang offline" và dòng "Kết quả trên máy" (UC-07 A3) | A5, A7 |
| C04 | G04 | Bỏ phím K (nghỉ, G07) khỏi danh sách phím 1.0 ở UC-08 A1, SCR-08 #7 | G07 BR-14: K là 1.1 |
| C05 | G04 | Tiền điều kiện UC-04 "workspace không chỉ đọc" ghi "(1.1)" | A9; BR-20 |
| C06 | G06 | MSG-11 và MSG-12 cùng viết "ngày làm việc" | BR-10 |
| C07 | G06 | Lỗi tải Backlog (UC-02 E4) dùng câu lỗi tải chung | A1 |
| C08 | G06 | Đặt mã SCR cho chi tiết task ở chế độ chỉ xem, mở từ Lưu trữ (UC-06 A7) | A8 |
| C09 | G06 | Đặt mã SCR cho panel Backlog gọn ở panel phải (Shift+B, IA): cùng bucket với trang Backlog, bỏ phần lọc | A8; IA |
| C10 | G03 | Thêm nhánh mất mạng cho thao tác trên cả chuỗi, kèm chữ tooltip | A6 |
| C11 | G03 | Dùng MSG-17 (`NOT_FOUND`) khi mở instance / chuỗi đã bị xoá ở thiết bị khác; thêm E# | MSG có nhưng chưa UC nào dùng |
| C12 | G03 | Đặt mã SCR cho bộ chọn giờ bắt đầu (UC-04 A2) | A8 |
| C13 | G03 | Nhãn nút thống nhất "Xoá và dừng lặp" (UC-05 A1 đang ghi "Xoá và dừng") | SCR-04 |
| C14 | G03 | Lỗi tải danh sách chuỗi (UC-07 E1) dùng câu lỗi tải chung; G02 MSG-10 và G03 MSG-12 trỏ về câu lỗi lưu chung | A1 |
| C15 | G03 | Toast khi instance vào Lưu trữ do phím D / shutdown: G03 chỉ trỏ sang G04 MSG-24 và G08, không định nghĩa lại | Chủ sở hữu thông báo |
| C16 | G03 | MSG-14 hiện ngay dưới ô chọn quy tắc lặp; "Quản lý mọi task lặp" là link mở Cài đặt → Task lặp lại | UC-01 E3 |
| C17 | G05 | MSG-13 ở 1.0 chỉ có "Giữ nguyên · Mở lịch" | A9 |
| C18 | G05 | Sự kiện gốc đổi thành cả ngày (UC-07 A11) dùng MSG-31, không dùng MSG-14 ("bị xoá") | Chữ sai ngữ cảnh |
| C19 | G05 | Đặt mã MSG cho "Cập nhật lúc {giờ}", "Cập nhật mỗi 15 phút", "Đang chờ xác nhận…", "Đang đồng bộ…" | A7 |
| C20 | G05 | Thêm MSG riêng cho lỗi kết nối OAuth (UC-01 E5), thôi dùng MSG-21 "Chưa lưu được thay đổi" | Chữ sai ngữ cảnh |
| C21 | G05 | UC-01 E1–E5 kết thúc ở SCR-01; MSG-02 hiện ngay dưới dòng tài khoản lịch | Hậu điều kiện thất bại |
| C22 | G05 | Thêm nhánh mất mạng cho UC-04 (dời / gỡ timebox) | A6 |
| C23 | G05 | Thêm `EVENT_NOT_FOUND` vào bảng map lỗi mục 8 → MSG-14 | UC-10 E1 |
| C24 | G05 | Dấu tích ở SCR-05 #6 là icon | A4 |
| C25 | G07 | Ctrl+Shift+Space và menu khay có cả chiều **dừng** khi đang có timer; thêm vào UC-02 | BR-17, BR-23, IA mục 8 |
| C26 | G07 | Bỏ khỏi tiền điều kiện UC-04 điều kiện "có ≥ 1 task chưa xong", vì A3 xử lý đúng trường hợp đó | Mâu thuẫn nội bộ |
| C27 | G07 | Chữ cho gợi ý kiểm tra âm thanh lần đầu (UC-04 E2) | A7 |
| C28 | G07 | Thêm MSG riêng khi bật timer thất bại (UC-01 E2), thôi dùng MSG-16 "…timer đã dừng" | Chữ sai ngữ cảnh |
| C29 | G07 | Hoàn tác của MSG-03 xoá bản ghi vừa nhập; sửa bản ghi (UC-03 A1) hiện "Đã lưu" | A10 |
| C30 | G07 | `[TimeEntryList]` chốt khi viết code (việc kỹ thuật, không cần PO) | API |
| C31 | G08 | Esc **không** thoát wizard: sửa BR-20, BR-21, UC-01 A5, UC-02 A5 | IA-16, SCR-01 #7 |
| C32 | G08 | Thống nhất tên ô "Trở ngại" (G10 UC-02 E1 đang ghi "Obstacles in my way") | G08 |
| C33 | G08 | Thêm MSG cho "Không còn việc nào dở" (UC-02 A2) | A7 |
| C34 | G08 | Bỏ banner offline riêng MSG-23 của ritual | A5 |
| C35 | G08 | Sửa câu "6 bước theo help center Sunsama" thành 5 chặng | #16, research |
| C36 | G01 | Dấu tích trong MSG-22, SCR-05 bước 2 là icon | A4 |
| C37 | G01 | Đặt mã SCR: menu tài khoản; Home; SCR-01 bản rút gọn; trang web của link tải bản xuất và link "Không phải tôi"; màn MSG-38, MSG-42 / 43; dialog xác nhận lại sau MSG-48 | A8 |
| C38 | G01 | Đặt mã MSG: lỗi xuất dữ liệu (UC-08 E2); trang 403 "Link này thuộc tài khoản khác" (E3); nhãn "Tạo bản xuất mới" (A2); lỗi kết nối lịch trong onboarding (UC-05 E1, trỏ sang G05) | A7 |
| C39 | G01 | MSG-11, MSG-14 thêm nơi hiện là dialog xác nhận lại (SCR-11, SCR-12) | UC-02 A6, E4; UC-07 E7 |
| C40 | G01 | Đổi cài đặt khi mất mạng: thêm nhánh, dấu "Chờ đồng bộ" trên màn Cài đặt | A6 |
| C41 | G01 | Thêm MSG riêng cho "rút lại đồng ý khi đang xuất" (UC-11 E2), thôi dùng MSG-44 | Chữ sai ngữ cảnh |
| C42 | G10 | Nút Trợ lý ở cụm dưới sidebar, sửa UC-03 bước 1 "góc dưới" | Mục 6; IA |
| C43 | G10 | Thêm E1 cho UC-07: công tắc về giá trị cũ, kèm MSG-14 | Hậu điều kiện thất bại |
| C44 | G10 | UC-07 A2, UC-05 A6, `LINKED_TASK` ghi "(1.1)"; ẩn chữ Gmail / Jira / Notion ở 1.0 (SCR-01 #2, SCR-02 #5) | A9 |
| C45 | G10 | Tách câu cho `AI_CONSENT_REQUIRED`: nói rõ cần đồng ý, bấm thì mở SCR-10 (MSG-30 chỉ còn cho `AI_ASSISTANT_DISABLED`) | Chữ sai ngữ cảnh |
| C46 | G10 | Chữ và đích còn thiếu: hỏi trước khi ghi đè hồ sơ (UC-05 A3, MSG mới); lưu hồ sơ mở từ Cài đặt thì ở lại Cài đặt; theme ngày > 100 ký tự dùng MSG-02; "không còn task" hiện trong khung chat; "Hữu ích" chỉ ghi đánh giá, "Chưa tốt" mở SCR-08 để góp ý; khi lưu lỗi vẫn hiện MSG-16 | A7 và đề xuất của brief |
| C47 | G12 | UC-06 Privacy là 1.2, không vẽ ở 1.0 | A9 |
| C48 | G12 | Đổi tên workspace dùng chung "Đã lưu" và câu lỗi độ dài như G01 | G01 |
| C49 | G12 | Ô email bắt buộc (UC-08 A1) ẩn ở 1.0 | A9; BR-18 |
| C50 | G12 | Chuông ở cụm dưới sidebar, danh sách là popover (sửa UC-09 bước 2) | IA-10 |
| C51 | G12 | Brief G12 liệt kê bảng "loại thông báo 1.0 → màn được mở" (bỏ Billing vì là 1.1) | UC-09 bước 4 |
| C52 | G12 | Đặt mã cho chữ UC-09 E2 "Email của bạn không nhận được thư" | A7 |

---

## Kết quả chốt

PO trả lời ngày 09/11/2026: "A đồng ý hết, B theo đề xuất, C đồng ý".

| Mã | Chốt | Ngày | Câu hỏi |
|---|---|---|---|
| A1–A10 | Đồng ý tất cả (QC-08 mục 7, QC-13, IA mục 3 banner) | 09/11/2026 | |
| B01 | A (đề xuất) | 09/11/2026 | Cửa sổ hẹp thì board chuyển 1 cột ở mốc nào |
| B02 | A (đề xuất) | 09/11/2026 | Ctrl+F khi đang gõ trong một ô nhập |
| B03 | A (đề xuất) | 09/11/2026 | Lỗi tải một ngày (MSG-15) hiện ở đâu |
| B04 | A (đề xuất) | 09/11/2026 | Có cho đánh dấu xong task ở cột ngày đã qua, và có "bản mờ" ở cột cũ không |
| B05 | A (đề xuất) | 09/11/2026 | Có mức cảnh báo "sắp chạm ngưỡng" không |
| B06 | A (đề xuất) | 09/11/2026 | Toast sau phím Z (đưa vào Backlog) có nút "Hoàn tác" không |
| B07 | A (đề xuất) | 09/11/2026 | Toast tự lưu trữ (MSG-11) khi rollover chạy ngay lúc mở app thì hiện khi nào |
| B08 | A (đề xuất) | 09/11/2026 | Instance lặp bị lỡ nhưng đã sửa riêng hoặc đã có thời gian thực tế: có được miễn tự lưu trữ (QC-06) không |
| B09 | A (đề xuất) | 09/11/2026 | Instance bị bỏ qua (`skipped`) có hiện trong Lưu trữ không |
| B10 | A (đề xuất) | 09/11/2026 | Có cho chỉnh ngưỡng tự lưu trữ trên giao diện không |
| B11 | A (đề xuất) | 09/11/2026 | Subtask đã tích hoặc thời gian thực tế có tính là "có hoạt động" (nên không bị tự lưu trữ) không |
| B12 | A (đề xuất) | 09/11/2026 | Có khôi phục thẳng từ Lưu trữ vào Backlog được không |
| B13 | A (đề xuất) | 09/11/2026 | Backlog có mức ưu tiên (priority) riêng không |
| B14 | A (đề xuất) | 09/11/2026 | "Dừng lặp" xử lý các instance tương lai thế nào |
| B15 | A (đề xuất) | 09/11/2026 | Đổi tần suất hoặc dừng lặp từ danh sách chuỗi lặp trong Cài đặt |
| B16 | A (đề xuất) | 09/11/2026 | Nút Trước / Sau giữa các lần lặp khi chuỗi đã dừng |
| B17 | A (đề xuất) | 09/11/2026 | Ở 1.0 có giới hạn số tài khoản lịch không |
| B18 | A (đề xuất) | 09/11/2026 | "Lịch ghi mặc định" chọn ở đâu |
| B19 | A (đề xuất) | 09/11/2026 | Đổi giờ một timebox mà sự kiện không còn trên lịch ngoài (lỗi 404) |
| B20 | A (đề xuất) | 09/11/2026 | Có lệnh "Timebox…" trong command menu không |
| B21 | A (đề xuất) | 09/11/2026 | Kéo timebox sang ngày khác đúng lúc thiết bị khác cũng vừa sửa task |
| B22 | A (đề xuất) | 09/11/2026 | Task có nhiều timebox, bấm "Gỡ khỏi lịch" |
| B23 | A (đề xuất) | 09/11/2026 | Menu khay khi chưa có timer nào chạy |
| B24 | A (đề xuất) | 09/11/2026 | Timer tự đóng sau 24 giờ thì màn hỏi giờ dừng (SCR-06) hiện khi nào |
| B25 | A (đề xuất) | 09/11/2026 | Trong Focus mode, xong một task rồi bấm "Bắt đầu" |
| B26 | A (đề xuất) | 09/11/2026 | Lượt timer dưới 10 giây bị bỏ, có báo người dùng không |
| B27 | A (đề xuất) | 09/11/2026 | Các nút trong nhắc "timer chạy quá 4 giờ" (MSG-11) |
| B28 | A (đề xuất) | 09/11/2026 | Nút "Plan my day" (Planning Agent) nằm ở đâu trong wizard |
| B29 | A (đề xuất) | 09/11/2026 | Cột ngày xa hơn hôm nay + 7 ngày |
| B30 | A (đề xuất) | 09/11/2026 | "Gửi bản sao cho chính tôi" có tính là gửi email (để hiện MSG-10) không |
| B31 | A (đề xuất) | 09/11/2026 | Có "chế độ buổi tối" không, tức mở Daily planning sau 15:00 thì mặc định lên kế hoạch cho ngày mai |
| B32 | B (đề xuất) | 09/11/2026 | Bước "Xem lại hôm qua" khi hôm qua đã làm Daily shutdown |
| B33 | A (đề xuất) | 09/11/2026 | Daily shutdown có bước xử lý từng task chưa xong không |
| B34 | A (đề xuất) | 09/11/2026 | Có tách highlights khỏi ghi chú suy ngẫm riêng không |
| B35 | A (đề xuất) | 09/11/2026 | Làm lại ritual trong cùng ngày thì ghi chú cũ xử lý thế nào |
| B36 | A (đề xuất) | 09/11/2026 | Onboarding có bắt nhập ít nhất 1 task không |
| B37 | A (đề xuất) | 09/11/2026 | Xoá tài khoản khi tài khoản chỉ đăng nhập bằng Google / Microsoft |
| B38 | A (đề xuất) | 09/11/2026 | Đổi mật khẩu hoặc đổi email có đăng xuất mọi thiết bị khác không |
| B39 | A (đề xuất) | 09/11/2026 | Link đặt lại mật khẩu hết hạn, bấm "Gửi link mới" (MSG-18) |
| B40 | A (đề xuất) | 09/11/2026 | Bản xuất dữ liệu bị lỗi |
| B41 | A (đề xuất) | 09/11/2026 | Nút ở bước nhập liệu của onboarding khi ô chưa hợp lệ |
| B42 | A (đề xuất) | 09/11/2026 | Đặt lại các nhãn đang có chữ "Claude Code" |
| B43 | A (đề xuất) | 09/11/2026 | Một thay đổi của AI không thực hiện được |
| B44 | A (đề xuất) | 09/11/2026 | Claude Code chưa sẵn sàng (chưa cài, chưa đăng nhập…) |
| B45 | A (đề xuất) | 09/11/2026 | Bộ trạng thái lỗi của trợ lý |
| B46 | A (đề xuất) | 09/11/2026 | Có học theo các tính năng AI của Sunsama không |
| B47 | A (đề xuất) | 09/11/2026 | Có nút "Xoá workspace" không |
| B48 | A (đề xuất) | 09/11/2026 | Trang huỷ đăng ký email có link "Mở cài đặt thông báo", mà 1.0 chưa có web app |
| C01–C52 | Đồng ý tất cả | 09/11/2026 | |

## Điểm phát sinh khi ghi vào tài liệu (cần PO xem)

Khi ghi quyết định vào SRS / PRD / flow, một số chỗ quyết định chưa nói đủ. **PO đồng ý cả D01–D09 ngày 10/11/2026**: tài liệu giữ đúng cách ghi ở cột "Đang ghi", đã bỏ nhãn `[giả định]` ở D01–D06 (ghi "chốt 10/11/2026, Dxx"). D08 vẫn là tên tạm cho tech chốt; D09 duyệt cùng brief.

| Mã | Chỗ | Đang ghi (đã chốt) | Nơi |
|---|---|---|---|
| D01 | "Khôi phục vào Backlog" (B12) vào bucket nào | Bucket "Tuần tới", đầu bucket, giống Shift+Z | G06 BR-14, UC-06 A8 |
| D02 | Con số ngưỡng tự lưu trữ (B10 chỉ chốt "cố định") | Vẫn là 4 ngày `[giả định]` | QC-04 mục 5 |
| D03 | "Xoá tất cả" trong Lưu trữ khi mất mạng (thao tác hàng loạt) | Nút mờ, MSG-27 "Cần có mạng để xoá tất cả" | G06 SCR-05 #3 |
| D04 | Vị trí nút "Gỡ khỏi lịch" trên một block (B22) | Hiện khi hover hoặc chọn block | G05 SCR-05 #9 |
| D05 | "Task kế tiếp hôm nay" ở menu khay (B23) | Task chưa xong đầu tiên của hôm nay; không còn thì ẩn mục | G07 BR-23 |
| D06 | Bấm thông báo "timer chạy quá 4 giờ" (G07 MSG-11) và nhắc ritual (G08 MSG-11) | Mở chi tiết task (task đang chạy timer / task ghi chép ritual) | G12 bảng loại thông báo 1.0 |
| D07 | "Hỏi trước khi ghi đè" ở G10 UC-05 A3 (C46) | Áp cho việc soạn lại nháp highlights (MSG-39) | G10 UC-05 A3 |
| D08 | Mã lỗi mới của B45 và G01 (`CLAUDE_CODE_ACCOUNT_BLOCKED`, `CLAUDE_CODE_RETRYING`, `CLAUDE_CODE_OUTPUT_TRUNCATED`, `MCP_DISCONNECTED`, `EXPORT_FORBIDDEN`) | Tên tạm; tech chốt khi viết code | G10, G01 bảng mã lỗi |
| D09 | Chữ của các MSG mới (khoảng 40 câu) | Viết theo giọng văn DS-07; duyệt cùng brief từng nhóm | SRS các nhóm |

