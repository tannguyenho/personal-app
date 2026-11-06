# Quyết định chốt mâu thuẫn — 04/11/2026

Kết quả các vòng hỏi đáp với PO, dựa trên [báo cáo review](review-lo-hong-nghiep-vu-2026-11-04.md). File này là nguồn duy nhất khi sửa PRD/SRS. Mã X/G trong ngoặc trỏ về lỗ hổng tương ứng trong báo cáo.

Thuật ngữ: [`CONTEXT.md`](../../CONTEXT.md). Quyết định khó đảo ngược: [`docs/adr/`](../adr/).

## Cách làm

- **D1.** Quy tắc dùng chung đặt ở `docs/01-quy-tac-dung-chung.md`. PRD/SRS tham chiếu tới file này, không tự định nghĩa lại.
- **D2.** Giá trị đã chốt thì bỏ nhãn `[giả định]` và đóng câu hỏi mở tương ứng (ghi "Đã chốt 04/11/2026: …"). Trạng thái trong `docs/00` chuyển thành "Đã chốt mâu thuẫn — chờ duyệt".
- **D3.** Mọi thay đổi nằm trên nhánh làm việc và vào `main` qua PR.

## Thời gian & ngày

- **Q2.** Mốc đầu ngày mặc định 04:00, chỉnh trong khoảng 00:00–06:00. Mọi nhóm dùng **ngày làm việc** (X1). Cụ thể:
  - G02: khi hoàn thành task;
  - G05: khi gán ngày cho timebox;
  - G09: khi gửi recap;
  - G10: khi hiểu "hôm nay / ngày mai".
- **Q3.** Đổi mốc đầu ngày hoặc timezone có hiệu lực từ ngày làm việc kế tiếp. Không chạy lại rollover cho ngày đã có lượt xong. Sửa G06 UC-04 A2.
- **Q4.** Khi đổi timezone (X2):
  - ngày dự định giữ nguyên;
  - timebox giữ thời điểm tuyệt đối;
  - nếu timebox rơi khác ngày dự định thì gắn cờ "lệch ngày", hệ thống không tự sửa.

  Sửa G05 BR-15 và UC-07 A7. Chỉ giữ banner MSG-23 của G01, bỏ G04 MSG-16.
- **Q19.** G01 sở hữu **Lịch làm việc**: các ngày làm việc trong tuần và giờ làm từng ngày. Mặc định Thứ Hai–Thứ Sáu, cho thêm Thứ Bảy.
  - G04 đọc để tính sức chứa.
  - G08 đọc để không tự mở ritual vào ngày nghỉ; "Ngày mai" đổi thành "ngày làm việc kế tiếp".
  - G09 đọc để dựng cột ngày và giờ gửi recap.
  - Recap tuần gửi tại mốc đầu ngày của ngày sau ngày làm việc cuối tuần.

## Task, rollover, task lặp

- **Q5.** Thay `rolloverCount` bằng **số ngày bị hoãn** = hôm nay − ngày dự định đầu tiên, tính theo ngày làm việc (X3).
  - Tiếp tục đếm khi: rollover, phím D, shutdown chọn "Ngày mai".
  - Reset về 0 khi: chọn ngày cụ thể hoặc kéo sang ngày khác, đưa vào backlog, hoàn thành, khôi phục từ Lưu trữ.
  - Tự lưu trữ khi ≥ 4 `[giả định]`.
- **Q9.** Một enum trạng thái do G02 sở hữu: `KE_HOACH`, `BACKLOG`, `HOAN_THANH`, `LUU_TRU` (kèm `archiveReason`: `stale` / `skipped` / `manual`), `DA_XOA` (X6). "Đã dời" là thuộc tính suy ra, không phải trạng thái. Khôi phục từ Thùng rác đưa task về đúng trạng thái trước khi xoá:
  - task đã hoàn thành giữ ngày;
  - task lưu trữ về lại Lưu trữ;
  - task kế hoạch ở quá khứ chuyển về hôm nay;
  - instance lặp áp quy tắc Q11.
- **Q11.** Hai instance cùng series trong một ngày (X8):
  - Đường tự động hoặc hàng loạt (rollover, phím D, shutdown "Ngày mai"): instance cũ chuyển sang `LUU_TRU` với lý do `skipped`, kèm toast Hoàn tác.
  - Đường thủ công từng task (kéo thả, chọn ngày, khôi phục): cho phép, kèm cảnh báo "Ngày này đã có {series}".
- **Q12.** Hoàn thành task của ngày tương lai:
  - task thường: chuyển về hôm nay (ngày làm việc);
  - instance lặp: giữ nguyên ngày dự định.
- **Q25.** Bỏ hoàn thành:
  - trong cùng ngày làm việc với lúc hoàn thành: trả lại mọi tác dụng phụ (subtask, thời gian thực tế tự gán, ngày dự định hoặc bucket);
  - sang ngày khác: chỉ xoá thời điểm hoàn thành, task ở lại hôm nay.
- **Q26.** Series lưu danh sách **ngày ngoại lệ**.
  - Người dùng xoá một instance thì ngày gốc của instance đó thành ngày ngoại lệ vĩnh viễn, độc lập với Thùng rác.
  - Instance do hệ thống xoá khi đổi quy tắc thì xoá hẳn, không tạo ngoại lệ.
  - Đổi quy tắc thì so khớp theo **ngày gốc**. Instance đã dời hoặc sửa riêng được giữ và tách khỏi series.
- **Q28.** Thùng rác giữ **30 ngày** (khác có chủ đích so với 7 ngày của Sunsama).

## Lịch & timebox

- **Q6.** Rollover gặp timebox quá khứ: giữ sự kiện trên lịch ngoài, chỉ gỡ liên kết trong app. Hoàn tác khôi phục lại liên kết (X7).
- **Q7.** Lập lịch cứng cho task lặp do **G05** sở hữu, phát hành **1.1**. Bản 1.0 chỉ hiện `approxTime` (X4).
- **Q14.** Bảng đổi ngày task, do G06 sở hữu và đặt trong `01-quy-tac-dung-chung.md`:

  | Đường | Timebox | Timer |
  |---|---|---|
  | Phím D, kéo sang ngày khác, shutdown "Ngày mai" | Giữ giờ, dời sang ngày mới | Không dừng |
  | Rollover | Quá khứ: gỡ liên kết, giữ sự kiện ngoài | Không dừng |
  | Đưa vào backlog | Tương lai: xoá cả sự kiện ngoài | Không dừng |
  | Hoàn thành | Giữ (rút ngắn theo B10) | Dừng |
  | Xoá | Tương lai: xoá | Dừng |

  Shutdown không còn tự dừng timer. Bước đầu của shutdown nhắc khi có timer đang chạy.
- **Q15.** App và lịch ngoài cùng sửa (G05-4):
  - giờ: lần sửa muộn hơn thắng;
  - sự kiện bị xoá ở lịch ngoài: gỡ timebox, task giữ nguyên;
  - tiêu đề: app thắng, ghi đè ra lịch ngoài ở lần đồng bộ kế tiếp;
  - sự kiện bị chuyển sang lịch khác: cập nhật lịch đích của timebox.
- **Q17.** Ẩn nút "Dời sang khe trống" ở 1.0. Cảnh báo xung đột chỉ có "Giữ nguyên" và "Mở lịch".

## Thời gian thực tế

- **Q13.** Về bản ghi thời gian (X9):
  - Bản ghi thuộc về ngày làm việc của thời điểm bắt đầu, không chia khi vắt qua mốc ngày.
  - Ritual tạo bản ghi (nguồn `ritual`) chỉ khi không có timer đang chạy.
  - "Tính planned là actual" chỉ là giá trị hiển thị, không tạo bản ghi. Giá trị cài đặt được chốt trên task tại lúc hoàn thành.
  - G09 là nơi duy nhất cộng các số liệu này.

## Đồng bộ

- **Q16.** Xung đột offline / nhiều thiết bị (X12):
  - Cụm vị trí {ngày dự định, bucket backlog, trạng thái, số ngày bị hoãn} luôn được ghi cùng nhau.
  - "Sau" tính theo thứ tự server nhận. Job hệ thống cũng tăng phiên bản.
  - Lệnh offline sửa trên phiên bản cũ của cụm bị từ chối, người dùng thấy "Task đã thay đổi trên thiết bị khác".
  - Các trường khác gộp theo từng trường.

## Ritual

- **Q18.** Ritual vắt qua mốc ngày:
  - Phiên mở trước mốc được hoàn tất cho ngày cũ, tối đa 2 giờ sau mốc.
  - Rollover của người dùng đó chờ phiên shutdown hoàn tất, bỏ dở, hoặc hết 2 giờ.
  - "Lên kế hoạch lại" rồi bỏ dở thì phiên quay về đã hoàn tất với nội dung cũ.

## Gói, workspace, quyền riêng tư

- **Q8.** Chế độ chỉ đọc "đóng băng" (X5):
  - Dừng mọi job và webhook ghi dữ liệu nghiệp vụ: rollover, sinh instance, đồng bộ ngược vào task, tích hợp, job AI. Chỉ cập nhật cache hiển thị lịch.
  - Timer tự dừng tại mốc hết hạn.
  - Thao tác offline tạo trước mốc được nhận nếu đồng bộ trong 2 giờ.
  - Khi thoát chỉ đọc: rollover chạy bù một lần, không tăng số ngày bị hoãn cho khoảng đóng băng.
- **Q10.** Bản 1.0 miễn phí, không giới hạn, gắn nhãn Beta. Trial, thanh toán và chế độ chỉ đọc chuyển sang **1.1**. Người dùng 1.0 nhận trial 14 ngày tính từ ngày phát hành 1.1. Ở 1.0, G12 chỉ còn workspace cá nhân và cài đặt thông báo. Xem ADR-0002.
- **Q22.** Ghế mua trước. Lời mời và link chung chỉ cho vào khi còn ghế trống; hết ghế thì chờ OWNER mua thêm. Không trừ tiền khi OWNER không chủ động bấm. Bỏ "lời mời đang chờ" khỏi công thức số ghế.
- **Q23.** Người đã có workspace nhận lời mời:
  - workspace một người, miễn phí hoặc trial: chuyển task cá nhân sang workspace mới ở chế độ "chỉ mình tôi", đóng workspace cũ;
  - workspace đang trả phí hoặc có thành viên khác: chặn, yêu cầu huỷ gói hoặc chuyển quyền trước.

  Nhiều workspace cho một người để bản sau.
- **Q24.** Task được giao hoặc có người follow luôn hiển thị với người giao và người follow (tiêu đề, trạng thái, comment). Privacy chỉ áp cho task tự tạo.
- **Q27.** Xoá tài khoản:
  - không phải OWNER: rời workspace trước, theo G12 BR-13 (trả task được giao về người giao, giảm ghế), rồi mới xoá; không huỷ gói của nhóm;
  - OWNER: phải chuyển quyền hoặc xoá workspace trước.

  Chuyển quyền: gỡ thẻ chủ cũ ngay. Chủ mới nhập thẻ trước kỳ kế tiếp, nếu không gói chuyển sang "thu lại tiền".
- **Q29.** Bản 1.0 không bắt buộc lưu tại Việt Nam, dùng máy chủ khu vực châu Á. Thêm yêu cầu hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (NĐ 13/2023). Giữ câu hỏi mở để pháp chế xác nhận trước khi phát hành.
- **Q30.** Cổng thanh toán là câu hỏi mở của G12, chốt trước 1.1. Gợi ý: Stripe cho thẻ quốc tế, VNPay/MoMo cho thanh toán nội địa.

## Trợ lý AI

- **Q20.** AI không được đánh dấu xong. AI chỉ được tạo task, dời ngày, timebox và ước lượng. Xem ADR-0003.
- **Q21.** Về đồng ý và dữ liệu:
  - Trợ lý AI mặc định tắt. Bật lần đầu phải qua màn đồng ý; hệ thống lưu thời điểm đồng ý.
  - Không gọi AI trước khi có đồng ý, kể cả job highlights 17:00.
  - Dữ liệu tích hợp mặc định không vào ngữ cảnh AI; có công tắc bật riêng.
  - Hành động AI đề xuất khi ngữ cảnh có dữ liệu ngoài phải chờ duyệt.
- **Q31 / Q31a.** Planning Agent **áp dụng ngay**, kèm nút "Hoàn tác kế hoạch AI". Ngoại lệ: kế hoạch có dùng dữ liệu tích hợp thì chờ duyệt (theo Q21). Chat áp dụng ngay khi thay đổi ≤ 3 task và không có dữ liệu ngoài.

## Lô B (đã duyệt)

| # | Quyết định |
|---|---|
| B1 | Đổi email: trong 72 giờ, link "Không phải tôi" huỷ việc đổi email, đăng xuất mọi thiết bị và gửi link đặt lại mật khẩu tới email cũ. Google/Microsoft gắn theo `provider + sub` |
| B2 | OAuth với email đã xác minh thay thế bản đăng ký chưa xác minh và huỷ mật khẩu cũ. PRD sửa theo SRS. Thêm chuyển trạng thái chưa xác minh → tự xoá sau 24 giờ |
| B3 | Bị đăng xuất từ xa: giữ hàng đợi offline (mã hoá, gắn userId), gửi lên khi đăng nhập lại đúng tài khoản. Chỉ xoá khi người dùng chủ động đăng xuất, có cảnh báo |
| B4 | Khi đăng ký, tạo channel hệ thống "Chưa phân loại" (không xoá được) làm channel mặc định. `work` / `personal` chỉ là context |
| B5 | "Series đã có instance hôm nay" = instance có ngày gốc hoặc ngày dự định bằng hôm nay, trạng thái Kế hoạch hoặc Hoàn thành |
| B6 | Lượt rollover chạy quá 5 phút coi như chưa chạy. Sau 3 lần lỗi chuyển "thất bại" và chạy bù khi người dùng mở app (API "đảm bảo rollover", G08 dùng chung). Mục tiêu: 95% xong trong 15 phút |
| B7 | Quá tải = planned của task chưa xong > thời gian trống còn lại. Thứ tự ưu tiên: Đã qua > Trống > Xong hết > Quá tải > Bình thường. Thêm cờ "vượt giờ làm" |
| B8 | Timebox liên kết sự kiện: không đẩy ra lịch, đi theo sự kiện gốc, không tính xung đột, không trừ thời gian trống hai lần |
| B9 | Lịch đích ghi cố định trên timebox từ lần đẩy đầu. Timebox chờ xoá vẫn được đẩy khi kết nối lại. Sau khi ngắt kết nối thì tách liên kết, bỏ qua sự kiện mồ côi. Đồng bộ lại toàn bộ có bước so sánh |
| B10 | Chỉ rút ngắn timebox khi thời điểm hoàn thành nằm trong khoảng giờ của nó |
| B11 | Nhập theo thời lượng: không kiểm tra chồng lấn, không vẽ lên lịch. Nhập theo khoảng giờ: có kiểm tra. Nhắc "quên tắt timer" cho chọn giờ dừng thật |
| B12 | Từ 1.0, lúc hoàn tất Daily planning lưu ảnh chụp kế hoạch: task, planned, quá tải, thời gian trống |
| B13 | Objective chỉ chuyển "Không đạt" khi Weekly planning tuần mới hoàn tất, hoặc hết ngày làm việc đầu tuần |
| B14 | Agent tạo task từ item qua `[TaskFromItem]`. Khoá chống trùng gồm tài khoản/site và id bất biến (Jira dùng id số). Liên kết đã ngắt không giữ khoá |
| B15 | Chỉ nhập item được giao cho mình (Jira assignee; Notion bắt buộc có trường Person). Item đổi người giao thì liên kết chuyển chỉ đọc và ngừng đẩy ngược |

## Lô C (đã duyệt)

| # | Nhóm | Quyết định |
|---|---|---|
| C1 | G01 | Xung đột cài đặt xử lý theo từng trường; báo cho người dùng khi trường của họ bị ghi đè |
| C2 | G01 | Luôn trả một thông báo chung; email cảnh báo ≤ 1 lần / 24 giờ; khoá theo cặp tài khoản + IP |
| C3 | G01 | Đang xuất dữ liệu thì không cho xoá tài khoản. Phạm vi xuất = dữ liệu mình sở hữu + task được giao cho mình |
| C4 | G01/G12 | Chuyển quyền và đổi email chấp nhận xác nhận lại qua Google/Microsoft (`reauthToken`) |
| C5 | G01/G12 | Hoá đơn và chứng từ giữ 10 năm; log bảo mật 1 năm, ẩn danh. Thêm UC rút lại đồng ý và xin đồng ý lại |
| C6 | G12 | Bổ sung chuyển "thu lại tiền" → "chờ huỷ", hoàn tiền, tranh chấp. Kỳ đầu bắt đầu khi trial kết thúc. Hoàn tiền khi xoá tài khoản `[giả định — chờ pháp chế]`. Hoá đơn điện tử theo NĐ 123/2020, thu mã số thuế |
| C7 | G12 | Trial 1 lần mỗi email. Người bị xoá khỏi workspace: task cá nhân chuyển sang workspace cá nhân mới |
| C8 | G12 | Hết 90 ngày chỉ đọc: chỉ xoá dữ liệu workspace, không xoá tài khoản; báo mọi thành viên; email bắt buộc |
| C9 | G02 | Subtask 1 cấp. Tích subtask cuối không tự xong task. Thêm subtask vào task đã xong không mở lại task. Xoá subtask có Hoàn tác |
| C10 | G02 | Xoá channel: chuyển mọi task, kể cả Thùng rác, Lưu trữ và series |
| C11 | G02 | Nhân bản: chép tiêu đề, ghi chú, subtask chưa xong, channel, planned, priority; không chép series; vị trí theo cài đặt. Sửa tham chiếu MSG sai |
| C12 | G03 | Có bảng phạm vi cho từng thao tác sửa series; không đụng `LUU_TRU` / `DA_XOA`; giữ tiến độ subtask theo tiêu đề |
| C13 | G03 | Đổi hoặc dừng series: instance đang chạy timer thì dừng timer; instance đã có thời gian thực tế thì giữ lại |
| C14 | G03 | Ngày đầu tuần cố định theo series. Instance đầu là ngày khớp quy tắc đầu tiên từ ngày dự định. Không sinh ngày trước hôm nay. Không bật lặp trên task đã xong |
| C15 | G04/G06 | Không đặt task chưa xong vào ngày đã qua, kiểm ở server. Phím D = ngày làm việc kế tiếp của max(ngày dự định, hôm nay) |
| C16 | G06 | Thứ tự sau rollover: ngày cũ tăng dần, rồi vị trí cũ; đặt sau instance lặp hôm nay. Cấu hình "giữ priority" theo tập mức |
| C17 | G04 | Tìm kiếm có kết quả Lưu trữ, gắn nhãn. Weekdays dịch 1 tuần. Ngày ở xa hiện instance lặp dự kiến |
| C18 | G05 | Sự kiện chặn: busy, tentative. Không chặn: đã từ chối, free, cả ngày. Timebox bị đổi thành cả ngày thì gỡ. Không tạo timebox xa hơn 90 ngày |
| C19 | G05 | Một task được nhiều timebox; kéo task đã có timebox thì thêm timebox mới |
| C20 | G07 | Timer offline bị chồng thì cắt phần chồng theo thứ tự server. Timer chạy trên task cha. Phím tắt Focus thuộc 1.1 |
| C21 | G08 | Task ghi chép của ritual không tính vào phép đếm task |
| C22 | G08 | Plan muộn tính trên thời gian trống còn lại. Không tự mở sau giờ shutdown hoặc khi shutdown đã hoàn tất |
| C23 | G08 | Tách 409 (đã hoàn tất) và 412 (xung đột phiên bản); với 412 tải lại và gộp theo trường |
| C24 | G08 | Không cho ẩn bước Chia sẻ. Shutdown có "Bỏ qua hôm nay". Khai báo điểm mở rộng cho G09 |
| C25 | G09 | Gộp review vào planning: chèn trước bước 1, một bước Chia sẻ, gửi một email |
| C26 | G09 | Tiến độ objective hiện cả % giờ và x/y task; cố định khi objective đóng; có tuỳ chọn gắn cho cả series |
| C27 | G11 | Nhãn "Lệch với nguồn" và nút đồng bộ lại. Không có transition ngược thì chỉ báo. Hàng đợi đẩy tối đa 7 ngày, đọc trạng thái hiện tại |
| C28 | G11 | Highlights chỉ tính hoạt động của tài khoản đã kết nối. Gmail không có "đóng" |
| C29 | G11 | Scope OAuth tối thiểu, xin thêm khi bật tính năng (`gmail.readonly` mặc định; Teams chỉ quyền gửi tin) |
| C30 | G11/G10 | Ngắt tích hợp: xoá cache trên mọi thiết bị, huỷ hàng đợi offline, xoá dữ liệu tích hợp trong lịch sử AI |
| C31 | G10 | Áp dụng đề xuất AI phải kiểm tra phiên bản. Không áp dụng giờ đã qua. Đề xuất hết hạn cuối ngày làm việc. Chỉ loại dòng lỗi thời. "Lập lại" vì lỗi thời không trừ lượt |
| C32 | G10/G12 | Hạn mức AI tách riêng chat / agent / highlights, đặt trong bảng quyền theo gói của G12; lượt lỗi không trừ |
| C33 | G10 | "Hôm nay / ngày mai" lấy từ hàm ngày làm việc, kèm bảng ví dụ làm ca chuẩn đánh giá |
| C34 | G11/G08 | G11 đặc tả tab Tích hợp trong Daily planning và kéo item vào Backlog (1.1) |
| C35 | Chung | Liệt kê các mã EC đang dùng kèm mô tả, đánh dấu "cần đối chiếu SRS tổng". Sửa EC-25 dùng sai ở G07 |
| C36 | Chung | Bỏ "Ghi chú cuộc họp" khỏi Privacy, bỏ "Latest updates" khỏi phạm vi. Đồng bộ README; sửa UC-20 bị gán cho hai nhóm |

## Vòng 5–6 (phát sinh khi sửa tài liệu)

| # | Quyết định |
|---|---|
| Q32 | Số ngày bị hoãn chỉ đếm các ngày có trong lịch làm việc của task (lịch chung hoặc khung giờ channel). Rollover vẫn chạy hằng ngày (QC-04) |
| Q33 | Gợi ý task dùng trợ lý AI qua Claude Code CLI (QC-12), không gọi LLM nào khác |
| Q34 | Bỏ lưu trữ thủ công (`manual`) khỏi 1.0; người dùng đưa vào backlog hoặc xoá. Để bản sau |
| Q35 | Bản 1 chỉ cho một người dùng. Mọi tính năng nhiều thành viên (workspace, mời, giao task, Privacy, quyền tạo channel chung) để bản sau, gom ở `docs/02-tinh-nang-ban-sau.md` |
| Q36 | (Bản sau) Task được giao vào bucket "Tuần sau" (`next_week`, nhãn hiển thị theo G06), đặt lên đầu |
| Q37 | Privacy "Lịch" và các tính năng nhiều thành viên chưa làm ở bản 1, ghi vào `docs/02-tinh-nang-ban-sau.md` |
| Q38 / Q38a | Giữ **khung giờ channel**: mỗi channel đặt được ngày và giờ riêng (G02 sở hữu cài đặt); lịch của task = khung channel nếu có, ngược lại lịch chung; sức chứa ngày = hợp lịch chung và các khung channel; số ngày bị hoãn và "ngày làm việc kế tiếp" theo lịch của task; auto-schedule (1.1) xếp trong khung channel. Cài đặt, sức chứa, projection ở 1.0 (QC-02 mục 5–9) |
| Q39 | Highlights do AI soạn qua Claude Code CLI; soạn vào các ngày trong lịch làm việc, tại giờ kết thúc làm việc; UI chat như chat thường |
| Q40 | "Hoãn 1 tuần" và phím S reset số ngày bị hoãn; thêm vào bảng QC-05 |
| Q41 | Rollover và tự lưu trữ không có Hoàn tác; Hoàn tác khôi phục liên kết chỉ áp cho đường do người dùng / AI làm |
| Q42 | Tự lưu trữ `stale` xử lý timebox như "Đưa vào backlog" |
| Q43 | Nhãn quy tắc lặp `WEEKDAYS` đổi thành "Thứ Hai–Thứ Sáu"; quy tắc lặp không theo lịch làm việc |
| Q44 | Sửa giờ timebox của instance lặp tính là sửa riêng (`customized`) |
| Q45 | Nền tảng: 1.0 app **Windows (Flutter)**, 1.1 web + macOS, 1.2 iOS / Android. Có tài khoản và dữ liệu trên cloud từ 1.0. Giao diện theo design system Figma riêng. Tech stack và API chốt trong buổi grill riêng (`docs/tech/`). ADR-0005 |
| Q46 | Trợ lý AI chạy bằng **Claude Code CLI** của người dùng, app mở **MCP local** để Claude Code điều khiển; có ở **1.0**; mặc định tắt, màn đồng ý gọn; MCP mặc định không có hoàn thành / xoá, có công tắc bật (trừ task có liên kết tích hợp); thay đổi áp dụng ngay + chip AI + Hoàn tác; bật đọc dữ liệu tích hợp thì thay đổi trong phiên đó chờ duyệt; bỏ hạn mức AI. QC-12, ADR-0004 (thay một phần Q20, Q31, C32) | _(Phần công tắc hoàn thành / xoá thay bởi F4, [06/11/2026](quyet-dinh-chot-2026-11-06.md))_

## Vòng 7

| # | Quyết định |
|---|---|
| Q47 | Bản 1.1 có trial và thanh toán **cho một người dùng** (gói cá nhân, không tính ghế). Nhiều thành viên, ghế và mọi thứ liên quan để bản sau (1.2 trở đi). Sửa ADR-0002 |
| Q48 | Sức chứa ngày không còn lấy min với ngưỡng khối lượng: quá tải khi planned của task chưa xong > thời gian trống trong hợp lịch chung và các khung channel. Ngưỡng khối lượng chỉ là giới hạn riêng của lịch chung, áp cho task không có khung channel (QC-02 mục 7) |
| D1 | Khung giờ channel: một khoảng mỗi ngày, không vắt qua nửa đêm, bước 15 phút |
| D2 | Đổi khung giờ channel có hiệu lực từ ngày làm việc kế tiếp |
| D3 | Channel "Chưa phân loại" không có khung giờ riêng, luôn theo lịch chung |
| D4 | Số ngày bị hoãn tính theo lịch hiện tại của task (đổi lịch / khung / channel thì số có thể thay đổi) |
| D5 | "Hoãn 1 tuần" = max(ngày dự định, hôm nay) + 7 ngày; rơi vào ngày nghỉ thì giữ nguyên ngày đó |
| D6 | Instance lưu trữ `skipped` (trùng series) xử lý timebox như "Đưa vào backlog" |
| D7 | Highlights soạn tại giờ kết thúc của lịch chung; app không mở lúc đó thì soạn khi mở app lần kế tiếp trong ngày |
| D8 | Khi bật đọc dữ liệu tích hợp: chỉ các thay đổi **sau** lần đầu đọc dữ liệu tích hợp trong phiên đó chờ duyệt |
| D9 | Planning Agent lỗi giữa chừng: giữ phần đã áp dụng, có Hoàn tác cả lượt |
| D10 | Công tắc AI hoàn thành / xoá áp cho cả subtask; AI không bao giờ hoàn thành hay xoá task có liên kết tích hợp |
| D11 | Phím tắt toàn cục (Ctrl+Shift+A thêm task, Ctrl+Shift+Space timer) có ở 1.0 |
| D12 | Nhắc ritual và nhắc timer > 4 giờ bằng thông báo Windows và trong app, từ 1.0 |
| D13 | Đóng cửa sổ khi timer đang chạy: thu về khay hệ thống, timer chạy tiếp |
| D14 | Mã tài liệu bỏ hậu tố nền tảng: `PLN-SRS-Gxx` |
| D15 | G09: tắt "Gồm ngày nghỉ" chỉ ẩn / hiện cột; giờ của khung channel vào ngày nghỉ vẫn tính vào tổng tuần |
| D16 | Tên hiển thị của trợ lý AI chưa đặt; quyết định khi làm thiết kế Figma |
