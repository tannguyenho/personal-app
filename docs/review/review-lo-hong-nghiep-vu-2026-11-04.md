# Review lỗ hổng nghiệp vụ — bộ PRD/SRS G01–G12

Ngày review: 04/11/2026. Phạm vi: 24 file trong `docs/features/` (bản nháp, commit `6912aeb`).

## 1. Tóm tắt

Có 7 reviewer độc lập: 6 người review theo cặp nhóm, 1 người chuyên dò mâu thuẫn giữa các nhóm. Tổng cộng có **~107 phát hiện**. Sau khi gộp các phát hiện trùng còn khoảng **85 lỗ hổng**. Các lỗ hổng mức Cao được kiểm tra lại trực tiếp trong tài liệu trước khi đưa vào báo cáo.

**Nhận định chung.** Từng nhóm viết chặt, đúng khuôn, luồng chính kiểm thử được, và mã BR/UC/SCR/MSG trong nội bộ từng file gần như không hỏng. Lỗ hổng nằm chủ yếu ở **chỗ các nhóm giao nhau**. Các quy tắc dùng chung (ranh giới ngày, đổi ngày task, trạng thái task, chế độ chỉ đọc, TimeEntry) đang được mỗi nhóm tự định nghĩa lại theo cách riêng, thay vì cùng tham chiếu về một nhóm sở hữu.

**Khuyến nghị số 1.** Trước khi PO duyệt từng nhóm, nên thêm một tài liệu **`docs/01-quy-tac-dung-chung.md`** gồm:

- hàm `workday(instant)`;
- bộ enum trạng thái task;
- bảng "đổi ngày task" theo từng tác nhân;
- bảng job/webhook khi workspace ở chế độ chỉ đọc;
- mô hình TimeEntry;
- danh mục EC;
- bảng entitlement theo gói.

Phần lớn các lỗ hổng ở mục 2 sẽ được đóng nhờ tài liệu này.

Quy ước mức độ:
- **Cao:** gây sai hoặc mất dữ liệu, mất tiền, lộ dữ liệu, ghi sai lên hệ thống ngoài, hoặc dev không thể hiện thực vì tài liệu thiếu hay mâu thuẫn.
- **TB:** làm sai số liệu hoặc trải nghiệm, hoặc có cách hiểu mơ hồ.
- **Thấp:** nhất quán tài liệu, tham chiếu.

Đường dẫn bên dưới tính từ `docs/features/`, viết tắt `srs-g06:44` = `srs-g06-backlog-rollover.md` dòng 44.

---

## 2. Vấn đề xuyên nhóm (ưu tiên chốt trước)

### X1. [Cao] Ranh giới "ngày" chưa thống nhất: ngày làm việc (04:00) hay ngày lịch (00:00)

- **Dùng `day_start_time`:** srs-g04:35 (BR-01), srs-g06:40, srs-g08:35, srs-g09:35.
- **Dùng ngày lịch / nửa đêm:**
  - srs-g02:43 (BR-08d: hoàn thành thì `startDate` = "ngày hoàn thành theo timezone");
  - srs-g05:40 (BR-06), srs-g05:49 (EC-04);
  - srs-g04:253;
  - srs-g09:55 (recap gửi Thứ Bảy 00:00).
- **Thời điểm áp dụng khi đổi cài đặt:**
  - srs-g01:48 (BR-14): "áp dụng từ ngày làm việc kế tiếp";
  - srs-g06:212 (UC-04 A2): "dùng ngày theo cài đặt mới" (áp dụng ngay).
- **Kịch bản:**
  - 02:00 ngày 05/11 (ngày làm việc vẫn là 04/11), người dùng tích xong một task. Task bị gán sang 05/11 và nhảy sang cột ngày mai.
  - Recap tuần gửi lúc ngày làm việc Thứ Sáu chưa kết thúc.
- **Liên quan:** G10 BR-05 (srs-g10:40). Hai lựa chọn khi người dùng nói "ngày mai" trong khung 00:00–04:00 đang mâu thuẫn với chính ví dụ trong PRD (prd-g10:188), nên bộ đánh giá ca EC-01 có hai đáp án.
- **Đề xuất:**
  - G01 sở hữu hàm `workday(instant)` và thời điểm áp dụng.
  - G02 BR-08d, G05 BR-06/BR-15/EC-04, G04, G06 A2, G09 BR-21 và G10 BR-05 đều tham chiếu hàm này.
  - Thêm bảng ví dụ biên: 02:00, đổi timezone ±12h, đổi 04:00 → 00:00 lúc 02:00.

### X2. [Cao] Đổi múi giờ: G04 giữ `startDate`, G05 tính lại `startDate`

- **Vị trí:** srs-g04:113 (A8: "task giữ `startDate`"), srs-g05:49 (BR-15: tính lại theo ngày địa phương mới), srs-g05:334.
- **Banner:** có hai banner cho cùng một tình huống, G01 MSG-23 (srs-g01:618) và G04 MSG-16 (srs-g04:524).
- **Kịch bản:** Người dùng bay sang châu Âu. Task đã timebox đổi ngày, còn task thường giữ nguyên ngày, nên hai task vốn cùng ngày bị tách sang hai cột. Với task lặp, việc này có thể đẩy hai instance vào cùng một ngày (srs-g03:45).
- **Đề xuất:** Chốt một quy tắc, sửa đồng thời G04 A8 và G05 BR-15. Chỉ giữ banner MSG-23 của G01.

### X3. [Cao] Shutdown "Ngày mai" đặt `rolloverCount = 0`, làm hỏng cơ chế phát hiện việc bị dời và tự lưu trữ

- **Vị trí:**
  - srs-g08:50 (BR-16: "Ngày mai… `rolloverCount = 0`");
  - srs-g06:44 (BR-10: đổi ngày bằng tay thì reset);
  - srs-g06:46 (BR-12: tự lưu trữ khi ≥ 4);
  - srs-g08:40 (BR-06: bước "Xem lại hôm qua" chỉ lấy task có `rolloverCount ≥ 1`);
  - phím D ở G04 BR-08.
- **Kịch bản:**
  - Người dùng shutdown mỗi tối với mặc định "Ngày mai". Một việc bị dời 10 ngày vẫn không hiện nhãn "Dời n ngày" và không bao giờ vào Archive.
  - Sáng hôm sau, bước "Xem lại hôm qua" báo "Không còn việc nào từ hôm qua", dù thực tế còn 6 task.
  - Kết quả là đúng nhóm người dùng chăm làm ritual lại mất tính năng.
- **Ngữ nghĩa bộ đếm cũng lệch:** `rolloverCount` đếm số lượt job đã chạy, nhưng nhãn hiển thị là "n ngày liên tiếp". Khi job lỗi 3 ngày rồi chạy bù, gộp lại chỉ được +1 (srs-g06:41, :211, :399).
- **Đề xuất:**
  - Tách bộ đếm "số ngày bị hoãn liên tiếp" (tăng khi rollover, D, hoặc shutdown chọn "Ngày mai") khỏi các hành động reset có chủ đích (chọn ngày cụ thể, đưa vào backlog, hoàn thành).
  - Lưu `firstRolledFrom` để tính số ngày theo lịch.

### X4. [Cao] "Lập lịch cứng cho task lặp": G03 và G05 đẩy cho nhau, không nhóm nào đặc tả

- **Vị trí:** prd-g05:60 ("→ G03"), srs-g03:40 (BR-06: "cài đặt Timebox, G05"), srs-g03:136. SRS G05 không có toggle, BR hay UC nào cho tính năng này. prd-g03:240 có giới hạn "7 ngày" nhưng không có chỗ thực thi.
- **Kịch bản:** Dev G03 gọi một API không tồn tại. Các câu hỏi sau không có câu trả lời, và rủi ro là sinh hàng loạt sự kiện trên Google:
  - xung đột giờ;
  - sửa hoặc dừng series;
  - instance bị dời hoặc bị bỏ qua.
- **Đề xuất:** Giao cho G05 sở hữu: thêm toggle vào SCR-01, BR "tạo timebox cho instance trong N ngày", và hành vi khi sửa hoặc dừng series. G03 chỉ giữ `approxTime`.

### X5. [Cao] Chế độ chỉ đọc (hết trial / thanh toán lỗi) chỉ chặn API người dùng; job nền và webhook vẫn ghi dữ liệu

- **Vị trí:**
  - srs-g12:40 (BR-06: chỉ chặn "mọi API ghi");
  - rollover srs-g06:199; sinh instance srs-g03:126;
  - G05 BR-13/BR-20: đồng bộ chiều vào vẫn sửa block và `startDate`;
  - G11 BR-09: nguồn đóng thì task hoàn thành; BR-18 chỉ chặn tạo task;
  - job highlights G10 BR-13 lúc 17:00 vẫn tốn token.
- **Mâu thuẫn về timer:**
  - G12 BR-06: "timer đang chạy bị dừng và lưu".
  - G07 BR-19 (srs-g07:53): "timer đang chạy vẫn dừng được", tức người dùng tự dừng.
  - Ân hạn 2 giờ (srs-g12:41) không khớp với G08 BR-19, nơi ritual được hoàn tất nhưng các thao tác bên trong vẫn bị trả 402.
- **Thiếu với dữ liệu offline:** Thao tác ghi được tạo offline trước mốc hết hạn nhưng đồng bộ sau mốc thì bị trả 402.
- **Kịch bản:** Sau 90 ngày ở chế độ chỉ đọc, rollover vẫn dời và lưu trữ task mỗi ngày, Jira vẫn đóng task. Trong khi đó người dùng không thể hoàn tác vì mọi API đều trả 402.
- **Đề xuất:** G12 thêm bảng "job/webhook nào chạy, job nào dừng khi `CHI_DOC`" và quy định hành vi khi thoát chỉ đọc (chạy bù một lần). G03, G05, G06, G07, G10, G11 tham chiếu bảng này.

### X6. [Cao] Mô hình trạng thái task và quy tắc khôi phục từ Thùng rác lệch giữa G02, G03 và G06

- **Tập trạng thái:**
  - G02 (srs-g02:60–65) có 5 trạng thái. `LUU_TRU` là mọi task có `archivedAt`, và không có cạnh `LUU_TRU → DA_XOA`.
  - G06 (srs-g06:60–66) tách thành `LUU_TRU`, `BI_BO_QUA`, `DA_CHUYEN_NGAY`, và có cạnh sang `DA_XOA` qua "Xoá tất cả".
  - srs-g03:70 viết "`BI_BO_QUA` là `LUU_TRU`".
- **Quy tắc khôi phục:** G02 BR-12 (srs-g02:47) nói "về trạng thái trước" và cũng nói "`startDate` < hôm nay thì chuyển về hôm nay". Hai câu này mâu thuẫn nhau.
- **Kịch bản:**
  - (a) Task trong Archive bị "Xoá tất cả" rồi được khôi phục. Không rõ task về Archive hay về hôm nay. Nếu về hôm nay với `rolloverCount = 6` thì task bị lưu trữ lại ngay.
  - (b) Task đã xong ngày 01/10, xoá rồi khôi phục. Task nhảy sang hôm nay trong khi `completedAt` vẫn là 01/10, làm sai analytics.
  - (c) Khôi phục một instance lặp cũ khi hôm nay đã có instance khác của cùng series, sinh ra 2 bản.
- **Liên quan:** G04 BR-02 (srs-g04:36) không loại `BI_BO_QUA` khỏi tổng thời lượng của ngày.
- **Đề xuất:**
  - G02 sở hữu bộ enum chuẩn: `LUU_TRU` kèm `archiveReason`, `DA_CHUYEN_NGAY` là cờ phụ.
  - Thêm bảng khôi phục theo trạng thái trước khi xoá: task đã xong giữ ngày; task lưu trữ về Archive; instance lặp áp quy tắc X8.

### X7. [Cao] "Đổi ngày task" có 3 cách xử lý khác nhau cho timebox, timer và sự kiện lịch ngoài

- **Timebox:**
  - Rollover gỡ timebox quá khứ và **xoá sự kiện Google/Outlook** (srs-g06:43, srs-g05:224 A6 "như A1").
  - Phím D trên board giữ nguyên giờ (srs-g04:43).
  - Shutdown "Ngày mai" không nói gì (srs-g08:50).
  - Task đã hoàn thành thì giữ sự kiện (srs-g05:51).
  - prd-g06:230 vẫn để là câu hỏi mở, trong khi G05 đã ngầm chốt là xoá.
- **Hoàn tác:**
  - G06 UC-01 A4 (srs-g06:105): "timebox không tự tạo lại".
  - G05 (srs-g05:219): "tạo lại block với giờ cũ".
- **Timer:** Shutdown "Ngày mai/Backlog" dừng timer (srs-g08:50), còn Z và rollover thì không dừng (srs-g06:36, :215).
- **Kịch bản:** Người dùng nhấn nhầm Z trên task đã timebox rồi bấm Ctrl+Z. Task quay về nhưng block bị mất, và sự kiện trên lịch công ty đã bị xoá vĩnh viễn.
- **Đề xuất:**
  - G06 sở hữu bảng "đổi ngày" theo tác nhân (người dùng / rollover / ritual) × (timebox / timer / sự kiện ngoài).
  - Gợi ý: giữ sự kiện quá khứ làm lịch sử, chỉ gỡ liên kết. Định nghĩa block "quá khứ" là `endsAt ≤ thời điểm rollover`.

### X8. [TB–Cao] Task lặp có thể thành 2 bản trong cùng một ngày qua các đường đổi ngày bằng tay

- **Vị trí:** prd-g03:21 nêu chính lỗi này. Chỉ có rollover chặn (srs-g06:45 BR-11). Các đường sau không chặn:
  - G04 A4 (srs-g04:180);
  - shutdown "Ngày mai" (srs-g08:50);
  - khôi phục từ Archive (srs-g06:48);
  - hoàn thành sớm instance ngày mai, khiến G02 BR-08d kéo nó về hôm nay (srs-g03:44).
- **Đề xuất:**
  - G03 định nghĩa quy tắc "trùng `seriesId` trong cùng ngày" (cảnh báo hoặc gộp). Mọi đường đổi ngày đều áp quy tắc này.
  - Cân nhắc ngoại lệ cho instance lặp ở G02 BR-08d: hoàn thành không đổi `startDate`.

### X9. [Cao] TimeEntry: chưa định nghĩa ngày quy thuộc, các nguồn và chồng lấn

- **Vị trí:**
  - G07 không có BR cho TimeEntry vắt qua mốc ngày; srs-g06:43 chỉ nói "giữ ở ngày cũ".
  - G08 BR-12 (srs-g08:46) tự tạo TimeEntry khi làm ritual, có thể chồng lên timer đang chạy, trong khi G07 chỉ có `source` timer/manual/auto_closed.
  - G02 BR-08c gán actual = planned, và G09 BR-17a (srs-g09:51) lại cộng planned thêm một lần.
- **Kịch bản:**
  - Timer 22:00–02:00 cho một task đã bị rollover: shutdown và analytics thiếu giờ hoặc tính trùng.
  - Đang chạy timer task A mà làm Daily planning 20 phút: 20 phút này bị đếm 2 lần.
- **Đề xuất:**
  - G07 sở hữu TimeEntry: thêm quy tắc gán ngày (theo `startedAt` hoặc chia theo mốc ngày), thêm `source = ritual`, thêm quy tắc chồng lấn.
  - G02 BR-08c ghi rõ actual = planned chỉ là giá trị hiển thị, không tạo TimeEntry.

### X10. [Cao — bản 1.1] Workspace nhiều thành viên (G12) chưa ghi tác động lên G01–G06

- **Vị trí:**
  - srs-g01:54 (BR-20): một MEMBER xoá tài khoản cũng "huỷ gói";
  - srs-g12:50 (BR-16): task được giao vào backlog nhưng không có `backlogBucket`, trong khi srs-g06:35 bắt buộc trường này;
  - G02/G03/G04 giả định một người dùng (srs-g02:50, srs-g03:48, srs-g04:54);
  - G02 cho mọi người tạo channel, còn ma trận quyền prd-g12:105 chỉ cho OWNER/ADMIN;
  - Privacy "Lịch" (srs-g12:49) không có quy tắc tương ứng ở G05.
- **Kịch bản:** Một thành viên xoá tài khoản làm cả nhóm mất gói trả phí. Task giao cho thành viên khác bị lỗi validate.
- **Đề xuất:** G12 thêm mục "Tác động lên G01–G06" và nhánh "xoá tài khoản khi không phải OWNER = rời workspace theo BR-13, rồi mới xoá".

### X11. [TB] Tính năng bản 1.0 phụ thuộc vào tính năng bản 1.1

- Nút "Dời sang khe trống" trong cảnh báo xung đột (G05, 1.0; srs-g05:330, :459) gọi auto-schedule (UC-05, bản 1.1, srs-g05:234).
- G09 (1.1) cần snapshot kế hoạch mà G08 (1.0) không lưu (xem G08-3).
- G09 BR-04 ghi đè G08 BR-03 nhưng G08 không nhắc tới. Weekly review gọi `/rituals/weekly_review/{Thứ Hai}`, mà theo G08 BR-02 ngày đó đã qua nên bị chặn.
- **Đề xuất:** Ẩn nút ở 1.0, hoặc đưa riêng thuật toán Shift+X lên 1.0. G08 khai báo trước các điểm mở rộng cho G09.

### X12. [TB] Đồng bộ offline / nhiều thiết bị: "xung đột theo trường, bản sau thắng" phá ràng buộc giữa các trường

- **Vị trí:** srs-g04:539, prd-g02:250, srs-g01:46 (BR-12) so với map lỗi 412 (srs-g01:589), srs-g06:214.
- **Kịch bản:**
  - Offline, người dùng đưa task vào backlog (`startDate = null`, có bucket). Trong lúc đó server rollover task (`startDate` = hôm nay). Khi gộp theo từng trường, task vừa có ngày vừa có bucket.
  - Hai máy offline cùng bật lặp một task, sinh ra 2 series.
  - Máy A sửa một instance mà máy B đã xoá mềm.
- **Đề xuất:**
  - Gộp theo **cụm trường nguyên tử**, ví dụ `{startDate, backlogBucket, archivedAt, rolloverCount}`.
  - Job hệ thống phải tăng `version`.
  - Lấy thứ tự theo thời điểm server.
  - Thêm ma trận xung đột theo cặp thao tác và các mã lỗi `TASK_DELETED`, `ALREADY_REPEATING`.

### X13. [Thấp–TB] Các mục được tham chiếu nhưng không nhóm nào sở hữu

- "Lịch làm việc theo ngày" (srs-g01:463 trỏ G04/G05): không có SCR nào. Đây là đầu vào cho sức chứa (G04), auto-schedule (G05) và ritual (G08).
- "Ghi chú cuộc họp" (prd-g05:58 trỏ G08): G08 không có, nhưng G12 Privacy lại liệt kê.
- "Latest updates" (prd-g04:61 trỏ G12): G12 không có.
- Tab "Tích hợp" trong Daily planning (srs-g08:41 trỏ G11): G11 không đặc tả.
- Hạn mức AI "theo gói" (srs-g10:50 trỏ G12): G12 chưa định nghĩa gói (prd-g12:63, :128).
- Danh mục EC-xx nằm ngoài repo. Mã EC-25 bị dùng sai nghĩa ở prd-g07:84. EC-29/EC-30 không có định nghĩa.
- Trong `docs/00`, UC-20 được gán cho cả G01 và G04.

---

## 3. Lỗ hổng theo nhóm

Các mục đã nêu ở phần 2 không lặp lại ở đây.

### G01 — Tài khoản & G12 — Workspace, thanh toán

| # | Mức | Vị trí | Lỗ hổng | Đề xuất |
|---|---|---|---|---|
| 1 | Cao | srs-g12:37, :45–46 (BR-03, 11, 12) | Link mời chung + "chấp nhận → +1 ghế, tính tiền theo tỷ lệ" không có trần ghế, không cần OWNER duyệt. Dán link vào nhóm 200 người → thẻ OWNER bị trừ 200 lần. BR-03 tính ghế ≥ thành viên + lời mời chờ, mâu thuẫn với "+1 ghế khi chấp nhận" | Trần ghế / hạn mức chi do OWNER đặt; chốt một mốc tính tiền duy nhất; luồng lỗi "hết ghế" |
| 2 | Cao | srs-g12:48 (BR-14), :431, :562 | Chuyển quyền sở hữu không nói gì về thẻ, khách hàng trên cổng thanh toán, người nhận hoá đơn. Chủ cũ không còn thấy Billing nhưng vẫn bị trừ tiền | Chủ mới nhập phương thức thanh toán trước kỳ kế; gỡ thẻ chủ cũ; luồng khi đang `THU_LAI` / `CHO_HUY` |
| 3 | Cao | srs-g01:39, :175; srs-g12:47; prd-g12:64 | Người đã có workspace riêng (có thể đang trả phí) nhận lời mời: chưa định nghĩa dữ liệu cũ, gói cũ, hoàn tiền | Chốt: chặn và yêu cầu xử lý workspace cũ trước, hoặc cho thuộc nhiều workspace |
| 4 | Cao | srs-g12:49–54 (BR-15–20) | Privacy "Chỉ mình tôi" mâu thuẫn với giao task / follow: email MSG-41 vẫn gửi nguyên văn comment | Định nghĩa ngoại lệ chia sẻ có phạm vi; ngừng MSG-41 khi người nhận mất quyền xem |
| 5 | Cao | srs-g01:51 (BR-17), :35, :43 | Đổi email: link "Không phải tôi" dẫn tới đặt lại mật khẩu, nhưng link đặt lại gửi tới email **mới** (của kẻ tấn công), nên không lấy lại được tài khoản. Không rõ OAuth gắn theo `sub` hay theo email | "Không phải tôi" huỷ việc đổi email (72h), thu hồi phiên; OAuth gắn theo `provider + sub` |
| 6 | Cao | srs-g01:37, :91, :139; prd-g01:143 | Chiếm trước tài khoản: kẻ gian đăng ký email nạn nhân rồi bỏ đó. SRS đòi nạn nhân nhập mật khẩu khi đăng nhập Google (bị chặn); PRD lại tự liên kết (kẻ gian giữ mật khẩu). Thiếu chuyển `CHUA_XAC_MINH` → xoá sau 24h | OAuth có email đã xác minh → ghi đè bản ghi chưa xác minh; thống nhất PRD theo SRS |
| 7 | Cao | srs-g01:176 (A5), :185 (E4), :52 (BR-18) | Nhận `session.revoked` (đổi mật khẩu trên điện thoại) → xoá dữ liệu offline chưa đồng bộ, trái với E4 "giữ hàng đợi" | Giữ hàng đợi đã mã hoá gắn userId; chỉ xoá khi chủ động đăng xuất và đã cảnh báo |
| 8 | Cao | srs-g12:40 (BR-06), :69 | Xoá dữ liệu sau 90 ngày chỉ đọc "theo quy trình xoá của G01" (đó là xoá **tài khoản**). Không rõ phạm vi xoá, thành viên có mất dữ liệu riêng không. Email nhắc chỉ gửi OWNER và không thuộc nhóm email bắt buộc | Trạng thái `DA_XOA_DU_LIEU`; xoá workspace chứ không xoá tài khoản; báo mọi thành viên; khoá job khi có thanh toán đang chờ |
| 9 | TB | srs-g01:46 (BR-12), :589 | Xung đột cài đặt: BR nói "bản sau thắng", map lỗi 412 lại lấy giá trị server và bỏ im lặng bản sau | Version theo trường; báo khi trường bị thua |
| 10 | TB | srs-g12:69, :156, :43 | Máy trạng thái gói thiếu chuyển `THU_LAI → CHO_HUY`, nâng cấp giữa trial (mất ngày trial?), refund / chargeback; xoá tài khoản không hoàn phần còn lại của gói năm (rủi ro Luật BVQLNTD 2023) | Bảng chuyển đầy đủ có sự kiện `refund` / `dispute`; kỳ đầu bắt đầu khi trial kết thúc |
| 11 | TB | srs-g01:54, :646–647; srs-g12:44 | "Xoá mọi dữ liệu ≤ 30 ngày" mâu thuẫn với log audit giữ 1 năm và nghĩa vụ lưu chứng từ kế toán. Hoá đơn chưa theo NĐ 123/2020 (không thu MST). Thiếu luồng rút lại đồng ý (NĐ 13/2023) | Liệt kê ngoại lệ lưu giữ kèm cơ sở pháp lý; trường xuất hoá đơn; UC rút / xin lại đồng ý |
| 12 | TB | srs-g01:53–54, :383 | Xuất dữ liệu mất tới 24h, còn xoá tài khoản thì khoá đăng nhập ngay, nên link xuất không tải được. Phạm vi xuất ở 1.1 chưa rõ | Chặn xoá khi đang xuất, hoặc token tải một lần |
| 13 | TB | srs-g12:481, :562; srs-g01:555 | Chuyển quyền và đổi email chỉ nhận mật khẩu: tài khoản chỉ dùng Google / Microsoft không làm được | Thêm `reauthToken` |
| 14 | TB | srs-g01:67; srs-g12:47 | Lách trial (xoá rồi đăng ký lại, mời rồi xoá nhau). Người bị xoá khỏi workspace mất task cá nhân sau 30 ngày, không được xuất | Trial gắn theo định danh; dữ liệu cá nhân đi theo tài khoản / gửi link xuất |
| 15 | Thấp | srs-g01:41, :173, :183 | Lộ email đã đăng ký qua thông báo khoá (MSG-15) / SCR-02; có thể bị lợi dụng để khoá và spam tài khoản người khác | Thông báo chung; giới hạn email cảnh báo; khoá theo tài khoản + IP |

### G02 — Quản lý task & G03 — Task lặp lại

| # | Mức | Vị trí | Lỗ hổng | Đề xuất |
|---|---|---|---|---|
| 1 | Cao | prd-g02:95; srs-g02:40, :49; srs-g01:39 | `uncategorized` lúc là context, lúc là channel. G01 chỉ seed 3 context, không seed channel nào, trong khi BR-05 bắt mỗi task có đúng 1 channel → tạo task đầu tiên bị lỗi | Ghi rõ dữ liệu seed lúc đăng ký; channel hệ thống `isSystem`; nơi đặt channel mặc định |
| 2 | Cao | srs-g03:38 (BR-04), :42; srs-g02:46 | Khoá duy nhất `(series, series_date)` tính cả instance đã xoá. Đổi tần suất qua lại → T2 bị khoá vĩnh viễn. Sau khi thùng rác purge 30 ngày → ngày người dùng đã bỏ bị sinh lại | Lưu danh sách ngày ngoại lệ trên series, tách khỏi vòng đời task |
| 3 | Cao | srs-g03:41–42 | Đổi quy tắc lúc so `startDate`, lúc so `seriesDate`. Instance đã dời sang T5 + quy tắc mới T3/T5 → T5 có 2 bản, T3 không có bản nào | So theo `seriesDate`; định nghĩa xử lý instance đã dời / sửa riêng |
| 4 | Cao | srs-g03:44 (BR-10) | "Series đã có instance hôm nay" không rõ tính những trạng thái nào (đã xong, đã xoá, đã dời) | Định nghĩa theo `seriesDate = hôm nay` và liệt kê trạng thái |
| 5 | Cao | srs-g02:43–44 (BR-08, 09), :174 | Bỏ hoàn thành bằng ✓ chỉ xoá `completedAt`. Subtask vẫn xong, actual giả vẫn còn, `startDate` không trả lại. Khác hẳn Hoàn tác trên toast | BR-09 trả lại mọi tác dụng phụ (đánh dấu actual `auto`), hoặc gộp hai đường thành một |
| 6 | TB | srs-g02:69, :379 | Quan hệ subtask ↔ task chỉ một chiều. Xoá subtask (đã có 40 phút TimeEntry) không có UC, không có Hoàn tác | UC xoá subtask kèm toast; bảng quy tắc subtask → task; ghi rõ chỉ 1 cấp |
| 7 | TB | srs-g02:214, :261 | Xoá channel: task trong Thùng rác / Archive / mẫu series có được chuyển theo không; E2 khôi phục về channel mặc định chứ không về channel nhận | `ChannelDelete` chuyển mọi task, gồm cả mẫu series |
| 8 | TB | srs-g03:42 (a–e); prd-g03:76 | Phạm vi "Sửa series" không nhất quán; (c) chép subtask đè lên instance đang làm dở → mất tiến độ; có đụng cả `BI_BO_QUA` | Bảng phạm vi theo trạng thái / ngày; giữ tiến độ subtask |
| 9 | TB | srs-g03:42–43, :238 | Đổi tần suất / xoá hàng loạt chưa xử lý instance đang chạy timer, có actual, có timebox; Hoàn tác không dựng lại được sự kiện ngoài | Áp quy tắc dừng timer; cảnh báo khi instance có actual; ghi rõ giới hạn của Hoàn tác |
| 10 | TB | srs-g03:37 (BR-03); prd-g03:84; srs-g01:478 | SRS cứng "tuần bắt đầu Thứ Hai", PRD nói theo cài đặt → "mỗi 2 tuần" cho ra lịch khác nhau. Anchor không khớp quy tắc | Cố định ngày đầu tuần theo series lúc tạo |
| 11 | TB | srs-g03:36, :78, :138 | Bật lặp cho task ở quá khứ hoặc task đã xong: thiếu giá trị khởi tạo `generatedUntil` → có thể sinh hàng loạt instance quá khứ | `generatedUntil = max(anchor, hôm qua)`; không sinh ngày < hôm nay |
| 12 | Thấp | srs-g03:178; srs-g02:45, :222; prd-g02:198 | Tham chiếu G02 UC-02 E4 sai MSG (MSG-12 thay vì MSG-10); PRD và SRS lệch về việc nhân bản có chép notes / vị trí bản sao; đánh số UC lệch giữa PRD và SRS | Sửa mã; chốt các trường được nhân bản |

### G04 — Board ngày & G06 — Backlog, rollover

| # | Mức | Vị trí | Lỗ hổng | Đề xuất |
|---|---|---|---|---|
| 1 | Cao | srs-g06:72–75, :222, :374; prd-g06:26 | Lượt rollover kẹt ở `DANG_CHAY` (worker chết) hoặc `LOI` sau 3 lần thử không có trạng thái kết thúc → người dùng cả ngày không có việc dở chuyển sang. Mục tiêu "100% ≤ 15 phút" không đạt được | Lease timeout; trạng thái `THAT_BAI` + chạy bù khi người dùng mở app; đổi mục tiêu thành p95 |
| 2 | Cao | srs-g04:36, :39, :41, :60–69 | Trạng thái ngày chồng nhau (`XONG_HET` + `QUA_TAI`) và không có thứ tự ưu tiên. "Quá tải" cộng cả task đã xong, nên điểm vượt ngưỡng có thể rơi vào task đã xong | Thứ tự ưu tiên trạng thái; quá tải tính trên phần chưa xong |
| 3 | TB | srs-g08:40; srs-g06:12, :374 | G08 gọi "rollover theo yêu cầu" nhưng G06 không có UC / API nào cho việc này; khoảng 04:00 → lúc job chạy board hiển thị gì | Thêm `POST /rollover/ensure` (idempotent, chờ khi đang `DANG_CHAY`) |
| 4 | TB | srs-g04:42 (BR-08); srs-g06:176, :272 | Chặn chuyển task về ngày đã qua chỉ có ở G04. Từ backlog / Archive vẫn đặt được ngày quá khứ; phím D cho `startDate + 1` vẫn có thể < hôm nay | Quy tắc server chung; D = `max(startDate, hôm nay) + 1` |
| 5 | TB | srs-g04:38 (BR-04), :40 | Sức chứa không trừ giờ đã qua, còn projection tính từ "bây giờ". 16:00 còn 4h việc → không cảnh báo, dù projection kết thúc lúc 20:00 | Thêm cờ "vượt giờ làm" |
| 6 | Thấp | srs-g06:41; srs-g01:484 | Thứ tự task khi rollover từ nhiều ngày / so với instance lặp chưa đủ để kiểm thử; G01 cấu hình priority theo ngưỡng, G06 theo tập mức | Quy tắc sắp xếp cụ thể; thống nhất kiểu cấu hình |
| 7 | Thấp | prd-g06:232 vs srs-g04:50; prd-g04:158 vs srs-g04:48; srs-g03:38 vs srs-g04:42 | PRD còn câu hỏi mở mà SRS đã chốt (tìm trong Archive); Weekdays dịch 5 ngày hay 1 tuần; instance lặp chỉ sinh 60 ngày trong khi board cho xem ±5 năm → ngày xa trông "trống" | Đóng câu hỏi mở; ghi chú về phạm vi instance đã sinh |

### G05 — Lịch & timebox & G07 — Focus, timer

| # | Mức | Vị trí | Lỗ hổng | Đề xuất |
|---|---|---|---|---|
| 1 | Cao | srs-g08:41 (BR-07); srs-g05:38, :45, :47, :48 | Task tạo từ sự kiện lịch (G08) gắn `calendarEventId`, nhưng G05 không có loại block nào như vậy → push tạo sự kiện **trùng** trên lịch công ty, tự `XUNG_DOT` với chính cuộc họp gốc | Loại block "liên kết sự kiện": không push, đi theo sự kiện gốc |
| 2 | Cao | srs-g05:50 (BR-16), :361, :274 | Block bị gỡ khi đang mất kết nối (`CHO_XOA`) không bao giờ được xoá trên lịch ngoài, vì UC-08 chỉ đẩy các block `CHO_DONG_BO` / `LOI` | Bao gồm `CHO_XOA` trong UC-08 bước 4 |
| 3 | Cao | srs-g05:53 (BR-19), :80, :321 | Sau khi ngắt kết nối, sự kiện mồ côi vẫn kích hoạt BR-13 → xoá sự kiện cũ trên Outlook làm gỡ luôn block đang dùng trong app | Tách liên kết (xoá `externalEventId`); bỏ qua BR-13 với `CHI_TRONG_APP` |
| 4 | Cao | srs-g05:293, :370, :231, :47 | Hai phía cùng sửa: 3 chỗ nói 3 quy tắc khác nhau (lịch ngoài thắng / app thắng / vẽ theo server); đổi tiêu đề bên ngoài thì lệch nhau vô thời hạn | Một quy tắc duy nhất áp cho cả 3 chỗ |
| 5 | Cao | srs-g05:38 (BR-04), :45, :147, :292 | Lịch đích của block tính động; đổi channel khi block đang `LOI` → sự kiện trùng trên 2 lịch; chuyển sự kiện sang lịch khác trên Google bị hiểu là xoá | Lưu `calendarId` cố định trên block; tìm `appBlockId` trên mọi lịch |
| 6 | TB–Cao | srs-g05:51 (BR-17), :40 | "Tự dời khi xong sớm": hoàn thành trước `startsAt` → `endsAt < startsAt` (block hỏng); chưa xử lý nhiều block / bỏ hoàn thành; lệch với G02 BR-08d | Chỉ rút ngắn khi `startsAt` < giờ xong < `endsAt` |
| 7 | TB | srs-g05:37 (BR-03), :332, :360 | Block ngoài cửa sổ 90 ngày không nhận thay đổi từ lịch ngoài; đồng bộ lại toàn bộ không đối chiếu sự kiện đã bị xoá | Bước diff khi đồng bộ toàn bộ; giới hạn ngày tạo timebox |
| 8 | TB | srs-g05:47, :39, :43, :48 | Sự kiện timebox bị đổi thành cả ngày / > 24h / thành sự kiện lặp; chưa phân loại sự kiện lặp, đã từ chối, tentative, OOO khi tính xung đột | Luồng thay thế + bảng phân loại sự kiện chặn / không chặn |
| 9 | TB | prd-g05:277 vs srs-g05:40, :449 | PRD còn mở câu hỏi một task nhiều block, SRS đã giả định có; kéo task đã có block vào lịch chưa định nghĩa | Chốt và thêm luồng vào UC-03 |
| 10 | Cao | srs-g07:39 (BR-05), :385, :477 | Nhập theo thời lượng khi đang có timer chạy **luôn** bị từ chối vì chồng lấn; bản ghi nhập tay vẫn bị vẽ thành block thực tế sai giờ; mức tối thiểu 1 phút không có trong BR | Bỏ kiểm tra chồng lấn với chế độ thời lượng / neo vào ngày; G05 chỉ vẽ bản ghi có giờ thật |
| 11 | TB | srs-g07:280, :43, :44 | Nhắc "quên tắt timer" sau 4h → `endedAt = now`, không cho chọn giờ dừng thật; timer offline đồng bộ lên chồng với bản ghi đã đóng → tính trùng; subtask đang chạy timer bị xoá / hoàn thành | Cho chọn giờ dừng; cắt chồng lấn khi đồng bộ; luồng cho subtask |
| 12 | Thấp | prd-g07:209 vs :49; srs-g07:51 | Ctrl+Shift+Space: PRD ghi bản 1.2, chỗ khác ghi bản 1.1 | Thống nhất |

### G08 — Daily rituals & G09 — Weekly, objective, analytics

| # | Mức | Vị trí | Lỗ hổng | Đề xuất |
|---|---|---|---|---|
| 1 | Cao | srs-g08:63–68, :121, :36, :47 | Ritual vắt qua mốc ngày: UC-01 A11 "giữ ngày D", trong khi bảng trạng thái chuyển `QUA_HAN` (theo BR-13 thì không tạo task ghi chép). Shutdown lúc 03:50 → rollover 04:00 thay đổi danh sách ngay dưới tay người dùng → "Hoàn tất" bị lỗi | `QUA_HAN` trừ phiên đang làm; ân hạn cho shutdown; rollover hoãn khi đang có phiên shutdown |
| 2 | Cao | srs-g08:68, :112, :64, :45 | "Lên kế hoạch lại" rồi bỏ dở → ngày đã hoàn tất bị biến thành `QUA_HAN`: đứt chuỗi, sai chỉ số, snapshot không có mốc | `firstCompletedAt` bất biến; bỏ dở thì quay về `HOAN_TAT` |
| 3 | Cao | srs-g09:51 (BR-17c, e), :54; srs-g08:45 | Analytics 1.1 cần snapshot (task, planned, overloaded) lúc hoàn tất planning / 12:00, nhưng G08 (1.0) không lưu và không có job nào chụp → không tính được dữ liệu các tuần chạy 1.0 | Lưu `planned_snapshot` ngay từ 1.0; thêm job 12:00 |
| 4 | Cao | srs-g09:42 (BR-08), :79, :83, :411 | Job chuyển objective tuần trước sang `KHONG_DAT` khi hết tuần, nhưng Weekly planning Thứ Hai lại cần chúng còn `DANG_MO` để "chuyển sang tuần này" → nhóm "Từ tuần trước" luôn trống | Chỉ đóng sau Weekly planning W+1 / sau ân hạn; hoặc cho `KHONG_DAT → DA_CHUYEN` |
| 5 | Cao | srs-g09:35, :40, :43, :55; srs-g01:478 | Tuần bắt đầu cấu hình được, nhưng ngày trong tuần lại hard-code T2–T6 và recap Thứ Bảy 00:00. Không hỗ trợ người làm T2–T7 (phổ biến ở VN) | Lấy ngày làm việc từ G01; gửi recap tại `day_start_time` sau ngày cuối tuần |
| 6 | TB | srs-g08:37–38, :50; srs-g01:454 | Ritual bỏ qua lịch làm việc / ngày nghỉ: shutdown Thứ Sáu đẩy task sang Thứ Bảy; Daily planning tự mở vào Thứ Bảy | "Ngày làm việc kế tiếp"; không nhắc vào ngày nghỉ |
| 7 | TB | srs-g09:51–52, :386; srs-g08:46 | Task ghi chép ritual có TimeEntry, được tính vào số task xong → ngưỡng "ít dữ liệu" (< 3) gần như không bao giờ bật | Loại task ghi chép khỏi mọi phép đếm |
| 8 | TB | srs-g09:51 (BR-17a), :47 | Bật / tắt "Tính planned là actual" làm thay đổi số liệu quá khứ; TimeEntry của task đã xoá có tính hay không chưa rõ | Cố định giá trị tại thời điểm hoàn thành; chốt quy tắc cho task đã xoá |
| 9 | TB | srs-g08:42–43, :37; prd-g08:83 | Plan lúc 15:00: bước 3 báo "đủ 8h", bước 4 báo xong lúc 23:00; tự mở cả khi đã shutdown; giờ plan 00:00–03:59 thuộc ngày nào | Tính thời gian trống còn lại; không tự mở sau shutdown |
| 10 | TB | srs-g08:122, :454 | 412 (hai thiết bị cùng sửa) bị gộp vào thông báo "vừa hoàn tất trên thiết bị khác" → mất phần đang sửa | Tách 409 / 412; gộp theo trường hoặc khoá phiên |
| 11 | TB | prd-g09:85; srs-g09:39 vs :162 | Gộp review vào planning: 3 chỗ nêu 3 vị trí chèn khác nhau; không rõ gửi một hay hai email chia sẻ | Chốt "trước bước 1" + một bước Chia sẻ |
| 12 | TB | srs-g09:47–50 | Tiến độ objective: 1 task có planned đã xong + 3 task chưa ước lượng → 100%; task dời sang tuần sau rồi xong làm thay đổi báo cáo tuần cũ; instance lặp không mang theo objective | Hiện cả giờ lẫn số task; cố định khi objective đóng |
| 13 | Thấp | srs-g08:52, :371, :38 | Theo câu chữ BR-18, bước Chia sẻ của shutdown ẩn được, nhưng đó là nơi có nút Hoàn tất; shutdown không có đường vào `BO_QUA` | Sửa BR-18; thêm "Bỏ qua hôm nay" |
| 14 | Thấp | srs-g08:41 vs srs-g04:38 | Task tạo từ sự kiện lịch vẫn bị trừ thời gian trống → quá tải bị tính đôi; PRD vẫn còn để mở câu hỏi này | Chốt quy tắc và đóng câu hỏi |

### G10 — Trợ lý AI & G11 — Tích hợp

| # | Mức | Vị trí | Lỗ hổng | Đề xuất |
|---|---|---|---|---|
| 1 | Cao | srs-g10:36, :43, :218; srs-g11:43–44 | AI "đánh dấu xong" → G11 đẩy Done sang Jira / lưu trữ Gmail (tác động ra ngoài, trái BR-02). Hoàn tác 7 ngày ở G10 trong khi G11 chỉ đẩy ngược trong 5 phút; Hoàn tác chỉ xoá `completedAt` | AI không hoàn thành task có TaskLink (hoặc bắt duyệt); lưu snapshot để hoàn tác |
| 2 | Cao | srs-g10:123, :36; srs-g11:40, :204; prd-g11:73 | Planning Agent tạo task từ issue / email không đi qua `[TaskFromItem]` → không có liên kết, sinh **task trùng**, phá chỉ số "Task trùng = 0" | Hành động "tạo task từ item" đi qua G11 BR-04 |
| 3 | Cao | prd-g11:90–91; srs-g11:137, :290, :43; srs-g10:37, :45 | "Dữ liệu của người khác" chưa định nghĩa: JQL tự do kéo việc của đồng nghiệp vào app và vào LLM; issue đã giao lại cho Minh vẫn đồng bộ hai chiều → Linh tích ✓ làm issue của Minh thành Done | Định nghĩa "của tôi" theo từng nhà cung cấp; đổi người giao → liên kết chỉ đọc |
| 4 | Cao | srs-g10:46, :53, :329; prd-g10:254; srs-g11:41 | Prompt injection: tiêu đề email do người lạ viết đi thẳng vào LLM; executor chỉ kiểm loại hành động và ngưỡng 3 task, nên ≤ 3 thay đổi độc hại vẫn được áp dụng; highlights có thể chứa URL của kẻ tấn công rồi được chia sẻ cho khách | Hành động sinh ra khi ngữ cảnh có dữ liệu ngoài → `CHO_DUYET`; highlights chỉ dùng link nội bộ; đưa "lệnh ẩn" vào nhóm phải đạt 100% |
| 5 | Cao | srs-g10:442, :446, :45; prd-g10:277 | Không có bước xin đồng ý gửi dữ liệu cho LLM bên thứ ba; AI mặc định bật và tự soạn highlights lúc 17:00 cho người chưa từng mở AI (NĐ 13/2023) | UC đồng ý lần đầu; không gọi LLM trước khi có đồng ý; tắt được từng nguồn |
| 6 | Cao | srs-g11:40 (BR-04), :38, :52, :323 | Khoá chống trùng `(user, provider, externalId)` thiếu site / account; key Jira đổi khi issue chuyển project; liên kết đã ngắt vẫn giữ khoá → không tạo lại task được | Khoá gồm `accountId` / `siteId` + id bất biến; chỉ tính liên kết còn hiệu lực |
| 7 | TB | srs-g11:44–45, :250, :262 | Đồng bộ hai chiều bất đối xứng: sau 5 phút bỏ hoàn thành chỉ đổi trong app → lệch nhau mãi; Jira không có transition ngược; hàng đợi đẩy chờ vô thời hạn, khi chạy sẽ đẩy trạng thái cũ | Nhãn "Lệch với nguồn" + nút đồng bộ lại; job đọc trạng thái hiện tại; giới hạn hàng đợi 7 ngày |
| 8 | TB | srs-g11:55 (BR-19); srs-g10:48 | Hoạt động tích hợp cho highlights: cache không có actor → "Hà đã hoàn thành PROJ-5" dù người đóng là đồng nghiệp | Actor = tài khoản đã kết nối; định nghĩa theo từng nhà cung cấp |
| 9 | TB | prd-g11:81, :89, :93 | Scope OAuth vượt "quyền tối thiểu": `gmail.modify` xin cả khi không bật lưu trữ thư, Teams `Chat.ReadWrite` | Incremental auth; dùng scope chỉ gửi tin |
| 10 | TB | srs-g11:52, :190, :526; srs-g10:50 | Ngắt tích hợp chỉ xoá cache trên server; cache trên thiết bị (đoạn trích Gmail) và lịch sử chat AI 90 ngày vẫn còn | Sự kiện realtime "purge"; ghi rõ G10 giữ / xoá những gì |
| 11 | TB | srs-g10:166, :192, :147, :69 | Áp dụng đề xuất AI không kiểm `version` → ghi đè trường người dùng vừa sửa; thẻ đề xuất 24h vẫn áp được với giờ đã qua; một task bị sửa làm huỷ cả kế hoạch | Kiểm version; chặn giờ đã qua; chỉ loại các dòng lỗi thời |
| 12 | TB | srs-g10:49–50, :503 | Đếm lượt AI mơ hồ (lỗi / Dừng / Lập lại có trừ lượt không); "Soạn lại" highlights không giới hạn; MSG-11 dùng chung cho chat và agent | Bảng hạn mức riêng cho chat / agent / highlights, đặt ở G12 |
| 13 | Thấp | README; prd-g10:144, :286; srs-g10:41, :136, :269 | README vẫn ghi "áp dụng ngay hay chờ duyệt" là câu hỏi mở, nhưng SRS đã chốt `CHO_DUYET`; nút "Hoàn tác kế hoạch AI" không có trong G08; phản hồi kèm cuộc trò chuyện chưa có thời hạn lưu | Đồng bộ README; bổ sung G08; chính sách lưu |

---

## 4. Quyết định PO cần chốt (theo thứ tự ảnh hưởng)

1. **Ranh giới ngày** 04:00 hay 00:00, kèm hàm `workday()` dùng chung và thời điểm áp dụng khi đổi cài đặt (X1). Đổi điều này sau bản 1.0 sẽ phải chuyển đổi dữ liệu.
2. **Đổi múi giờ:** giữ hay tính lại `startDate` (X2).
3. **Bộ đếm rollover:** shutdown "Ngày mai" và phím D có reset bộ đếm không (X3).
4. **Sự kiện lịch quá khứ** khi rollover: xoá hay giữ trên Google/Outlook (X7, prd-g06:230).
5. **Chính sách xung đột hai phía** cho lịch (G05-4) và cho đồng bộ offline (X12).
6. **AI có được đánh dấu xong không**, và có được động vào task có liên kết tích hợp không (G10-1); **cơ chế đồng ý dùng AI** (G10-5).
7. **Tính tiền ghế:** mốc tính tiền, trần ghế, chuyển quyền kéo theo thanh toán (G12-1, 2); người đã có workspace nhận lời mời (G12-3).
8. **Chế độ chỉ đọc:** bảng job/webhook chạy hay dừng; timer tự dừng hay để người dùng dừng (X5).
9. Bản 1.0 có nút "Dời sang khe trống" không (X11).
10. Tuần làm việc T2–T6 hay cấu hình được, và hỗ trợ T2–T7 thế nào (G09-5).

## 5. Phương pháp

- 6 reviewer, mỗi người đọc trọn một cặp nhóm (PRD + SRS, 4 file) và đối chiếu sang nhóm khác bằng tìm kiếm. 1 reviewer chỉ dò mâu thuẫn giữa các nhóm, theo 10 chủ đề dùng chung.
- Mỗi phát hiện đều có trích dẫn file:dòng. Phát hiện xuyên nhóm cần ít nhất 2 vị trí.
- Một số phát hiện mức Cao (G08 BR-16, G06 BR-10/A2, G01 BR-14, prd-g05:60, G03 BR-06, G02 BR-08, G12 BR-03/11/06, G07 BR-19, G09 BR-08) được người tổng hợp kiểm tra lại trực tiếp trong tài liệu, và đều đúng như mô tả.
- Không kiểm chứng được: định nghĩa các mã EC-xx (nằm ở SRS tổng ngoài repo).
- Bỏ qua lỗi chính tả và định dạng.
