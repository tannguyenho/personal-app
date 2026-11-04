> **Mã:** PLN-PRD-G10 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g10-tro-ly-ai.md

# PRD Trợ lý AI trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: khung chat Sunny ("Describe a task or ask a question", History, New chat, "Thought 8s", chip task + Undo → chip gạch "Undone"), luồng Planning Agent ("Plan my day" → Review Plan "The planning agent added 1 task" → Next → Daily plan → Get started), nhật ký "Sunsama Planning Agent created this", và lỗi EC-01 (lúc 02:10 ngày 4/11 yêu cầu tạo task "ngày mai" → Sunny tạo vào 4/11, không hiện ngày cụ thể để người dùng phát hiện). Chỗ khác Sunsama có chủ đích được ghi rõ.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Bản 1.0 đã có gợi ý thời lượng và channel khi tạo task (G02). Bản 1.2 đưa AI vào ba chỗ tốn công nhất của vòng lặp ngày: lập kế hoạch buổi sáng (Planning Agent), thao tác nhanh trong ngày bằng ngôn ngữ tự nhiên (trợ lý chat Sunny) và viết highlights cuối ngày. Nhóm G10 lo ba tính năng này cùng rào chắn và bộ đánh giá chất lượng dùng chung. Daily planning / Daily shutdown thủ công (G08), task (G02), timebox (G05) và nguồn dữ liệu từ công cụ ngoài (G11) nằm ở nhóm riêng; AI chỉ đọc / ghi qua đúng các thao tác mà người dùng có.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Daily planning thủ công mất 10–15 phút `[giả định]` khi có 6–8 cuộc họp và việc rải ở Jira, Notion, Gmail | Người dùng bỏ ritual, ngày không có kế hoạch |
| Thao tác nhiều task (dời, sắp lại, chia nhỏ) phải làm từng cái | Ngại sắp lại kế hoạch khi ngày thay đổi |
| AI hiểu sai ngày tương đối ("ngày mai" lúc 02:10 — EC-01) và không cho thấy ngày cụ thể | Task rơi vào ngày sai, người dùng không phát hiện |
| AI sửa nhiều task một lúc mà không cho xem trước | Mất kiểm soát kế hoạch, mất niềm tin vào AI |
| Viết highlights cuối ngày từ đầu tốn thời gian | Bỏ bước highlights, Weekly review (G09) thiếu dữ liệu |
| AI lỗi hoặc chậm làm kẹt ritual | Người dùng không lập được kế hoạch đúng lúc cần nhất |

## 1.3 Mục tiêu

- Lập kế hoạch ngày với Planning Agent trong ≤ 5 phút kể cả thời gian duyệt; agent chạy 2–4 phút.
- Mọi thay đổi do AI làm đều nhìn thấy được, ghi tác nhân AI và hoàn tác được.
- Mọi ngày giờ AI dùng hiện ở dạng cụ thể ("Thứ Năm, 5/11") trước hoặc ngay khi áp dụng; không lặp lại EC-01.
- Kết quả đầu tiên (chữ trả lời hoặc bước tiến độ) hiện ≤ 10 giây; AI lỗi thì người dùng vẫn đi tiếp bằng luồng thủ công.
- Bộ đánh giá ≥ 200 câu Việt / Anh đạt ≥ 95% trước mỗi lần đổi model hoặc prompt.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh — PM, 6–8 cuộc họp / ngày, việc ở Jira + Notion + Gmail | Agent gom việc từ các nguồn, xếp vào khe trống giữa các cuộc họp |
| Minh — designer / dev | Giữ khối thời gian dài cho việc sâu; nói "dời hết việc lặt vặt sang chiều" là xong |
| Hà — freelancer / founder, nhiều khách hàng | Không nhận quá sức; AI cảnh báo khi kế hoạch vượt ngưỡng 8 giờ |
| Người dùng thận trọng với AI | Xem trước thay đổi lớn, hoàn tác từng phần, tắt AI khi muốn |
| Người dùng song ngữ Việt / Anh | Gõ tiếng Việt hay tiếng Anh đều được hiểu, trả lời đúng ngôn ngữ đã gõ |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.2)

- Nền tảng: Web (desktop, mobile web), App iOS / Android và desktop dùng cùng đặc tả.
- Planning Agent (Beta "Agentic Daily Planning"): thiết lập 1 lần, "Plan my day", Review Plan (Re-plan, Undo all, Submit feedback), nối vào bước Daily plan của G08.
- Trợ lý chat Sunny (nút ✨ góc dưới): hỏi đáp về kế hoạch, ra lệnh tạo / sửa / dời / sắp / timebox task, History, New chat.
- Highlights AI cuối ngày: nháp tự động T2–T6 17:00 từ task đã xong và hoạt động trên công cụ đã kết nối; người dùng duyệt trước khi lưu.
- Rào chắn: danh sách hành động được phép, xác nhận khi ảnh hưởng > 3 task, hoàn tác, dữ liệu gửi LLM tối thiểu.
- Nhóm cài đặt AI và Beta trong trang Cài đặt.
- Bộ đánh giá chất lượng AI và thu tín hiệu (Submit feedback, Hoàn tác).

## 3.2 Ngoài phạm vi

- Gợi ý thời lượng và channel khi tạo task → G02 (đã có ở 1.0).
- Daily planning / Daily shutdown thủ công, chia sẻ kế hoạch → G08. Weekly planning / review → G09.
- Kết nối và đọc dữ liệu công cụ ngoài → G11; lịch → G05.
- AI xoá task, gửi tin ra ngoài (email, Slack, Teams), đổi cài đặt → không làm, ở mọi phiên bản.
- Agent tự chạy nền không có người dùng (tự lập kế hoạch lúc 06:00) → sau 1.2.
- Nhập bằng giọng nói → sau 1.2 `[giả định]`.
- AI cho workspace nhiều người (lập kế hoạch nhóm, tóm tắt cho quản lý) → sau 1.2.

# 4. Nguyên tắc sản phẩm

## 4.1 AI đề xuất, người dùng quyết

Thay đổi lớn (> 3 task, hoặc cả kế hoạch ngày) luôn hiện danh sách để duyệt trước. Thay đổi nhỏ áp dụng ngay nhưng có chip và Hoàn tác ngay tại chỗ.

## 4.2 Rõ ngày, rõ giờ

AI luôn biết ngày giờ, timezone và ngày làm việc hiện tại; mọi ngày trong kết quả hiện dạng cụ thể. Khi "hôm nay / ngày mai" có thể hiểu hai cách (sau nửa đêm, trước giờ bắt đầu ngày làm việc), AI hỏi lại thay vì đoán (EC-01).

## 4.3 Không có hành động AI mất trắng

Mọi hành động AI ghi nhật ký với tác nhân AI và hoàn tác được. Hoàn tác chỉ trả lại phần AI đã làm, không xoá công sửa của người dùng (EC-38).

## 4.4 AI hỏng, ngày vẫn chạy

AI lỗi hoặc chậm quá 10 giây trong ritual thì chuyển luồng thủ công, giữ nguyên những gì người dùng đã nhập (EC-39). Mọi chức năng cốt lõi không phụ thuộc AI.

# 5. Quy tắc hành vi AI

| **Quy tắc** | **Giá trị / giới hạn** `[giả định]` | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Hành động được phép | Tạo task, sửa tiêu đề / thời lượng / channel / priority / due, thêm subtask, dời ngày / vào backlog, sắp thứ tự, timebox / gỡ timebox, gắn objective (G09), đánh dấu xong | Tất cả | Kiểm tra ở server, không phụ thuộc model |
| Hành động bị cấm | Xoá task / subtask, gửi tin ra ngoài, đổi cài đặt, kết nối / ngắt tích hợp, đọc / sửa dữ liệu người khác | — | Từ chối và chỉ cách người dùng tự làm |
| Ngưỡng xác nhận | > 3 task bị ảnh hưởng trong một yêu cầu | 3 | EC-37; Planning Agent luôn qua Review Plan |
| Ngữ cảnh thời gian | Ngày giờ hiện tại có offset, timezone, day_start_time, ngày làm việc hiện tại, giờ làm việc | Bắt buộc | Thiếu thì không gọi LLM (EC-01) |
| Khung mơ hồ "hôm nay / ngày mai" | 00:00 → day_start_time (04:00) | Hỏi lại bằng 2 lựa chọn ngày cụ thể | Nếu chốt day_start_time 00:00 thì dùng khung 00:00–04:00 |
| Kết quả đầu tiên | ≤ 10 giây | — | Có trạng thái "đang xử lý" ("Thought 8s") |
| Planning Agent | Chạy 2–4 phút; tối đa 5 phút; tối đa 5 lần / ngày | — | Lỗi / > 10 giây chưa có bước đầu → luồng thủ công (EC-39) |
| Thời hạn hoàn tác | 7 ngày sau khi áp dụng | — | Sau đó chip không còn nút Hoàn tác |
| Tin nhắn chat | 1–2.000 ký tự; 100 tin / ngày / người dùng | — | Hạn mức theo gói → G12 |
| Lịch sử chat | Giữ 90 ngày | — | Người dùng xoá được từng cuộc trò chuyện |
| Ngôn ngữ | Chat: ngôn ngữ tin nhắn người dùng. Highlights: cài đặt "Ngôn ngữ tóm tắt" | Auto | Auto = ngôn ngữ giao diện |
| Nháp highlights | T2–T6 17:00 theo timezone người dùng | Bật ("Tóm tắt tự động") | Không lưu tới khi người dùng duyệt |
| Bộ đánh giá | ≥ 200 câu Việt / Anh; ≥ 95% đúng; nhóm rào chắn và ngày giờ 100% | — | Chạy trước mỗi lần đổi model / prompt |

- Các giá trị là **cấu hình hệ thống**, không cố định trong code.
- Dữ liệu gửi LLM: tối thiểu cho yêu cầu đang xử lý; nhà cung cấp LLM không lưu, không dùng để huấn luyện (điều khoản hợp đồng).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Bật và thiết lập | Bật Beta "Agentic Daily Planning"; kết nối công cụ (G05, G11), "Tell me about yourself", theme days | Hồ sơ agent |
| 2 | Lập kế hoạch sáng | Mở Daily planning (G08) → gõ điều quan trọng hôm nay → "Plan my day" → Review Plan → Next | Kế hoạch ngày được áp dụng, sang bước Daily plan (G08) |
| 3 | Trong ngày | Bấm ✨ mở Sunny: hỏi "chiều nay còn trống bao lâu?", ra lệnh "dời 3 việc review sang mai" | Task được tạo / dời / sắp, có chip và Hoàn tác |
| 4 | Cuối ngày | 17:00 có nháp highlights; mở Daily shutdown (G08) → duyệt / sửa → lưu | Highlights của ngày |
| 5 | Sửa sai | Hoàn tác từng thay đổi hoặc cả lượt; Submit feedback | Kế hoạch đúng ý; tín hiệu chất lượng |
| 6 | Kiểm soát chất lượng (nội bộ) | Chạy bộ đánh giá trước khi đổi model / prompt | Bản phát hành AI đạt ngưỡng |

Bước 2 và 4 chạy bên trong ritual của G08; PRD này chỉ mô tả phần AI. PRD tập trung bước 1–6 trừ phần thủ công của ritual.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Lập kế hoạch ngày với Planning Agent

### US1.1 Thiết lập agent lần đầu

AC01: Lần đầu bấm "Plan my day" khi chưa thiết lập → mở màn thiết lập 3 phần: kết nối công cụ (trỏ G05, G11), "Kể về bạn" (vai trò, giờ làm việc ưa thích, việc cần tránh), theme days (mỗi thứ trong tuần một chủ đề tuỳ chọn).

AC02: Phần nào cũng bỏ qua được; sửa lại sau trong Cài đặt → AI.

AC03: Chỉ hiện khi bật Beta "Agentic Daily Planning".

### US1.2 Cho agent lập kế hoạch

User Story: Là Linh, tôi muốn nói điều quan trọng hôm nay rồi để agent xếp ngày quanh các cuộc họp, để không mất 15 phút kéo thả mỗi sáng.

AC01: Trong Daily planning (G08) có ô "Điều quan trọng nhất hôm nay là gì?" và nút "Plan my day".

AC02: Khi chạy, màn hình hiện các bước tiến độ (đọc lịch, đọc việc từ công cụ, xếp khối thời gian); bước đầu tiên hiện ≤ 10 giây.

AC03: Agent chỉ dùng các hành động được phép (mục 5); không xoá task.

AC04: Chạy xong (2–4 phút) chuyển sang Review Plan.

### US1.3 Duyệt kế hoạch (Review Plan)

AC01: Review Plan hiện câu tóm tắt ("Planning Agent đã thêm 3 task, dời 2 task") và danh sách "HÔM NAY · n thay đổi"; mỗi dòng có nhãn loại thay đổi và ngày giờ cụ thể.

AC02: Kế hoạch chỉ áp dụng khi bấm "Tiếp" (Sunsama áp dụng ngay rồi cho Undo all; khác có chủ đích vì kế hoạch thường đổi > 3 task, EC-37).

AC03: Bỏ chọn từng dòng để không áp dụng dòng đó.

AC04: "Lập lại" (Re-plan) cho nhập thêm chỉ dẫn và chạy lại; "Huỷ tất cả" (Undo all) bỏ toàn bộ đề xuất; "Gửi phản hồi" mở form phản hồi.

AC05: Sau "Tiếp" đi tới bước Daily plan (G08); task do agent tạo có nhật ký "Planning Agent đã tạo task này".

### US1.4 Agent lỗi thì vẫn lập được kế hoạch

AC01: LLM lỗi hoặc > 10 giây chưa có bước đầu tiên → thông báo và chuyển sang luồng Daily planning thủ công (G08) ở bước 1 (EC-39).

AC02: Nội dung ô "Điều quan trọng nhất" được giữ, đưa vào ô "Obstacles / ghi chú" của bản kế hoạch.

AC03: Agent lỗi giữa chừng → không áp dụng thay đổi nào.

## UC2. Trò chuyện với trợ lý Sunny

### US2.1 Hỏi về kế hoạch

AC01: Nút ✨ góc dưới mở khung chat; ô nhập "Mô tả một task hoặc đặt câu hỏi"; có "Lịch sử" và "Cuộc trò chuyện mới".

AC02: Trong lúc xử lý hiện trạng thái "Đang nghĩ…", xong hiện thời gian đã nghĩ ("Đã nghĩ 8s").

AC03: Trả lời bằng ngôn ngữ người dùng đã gõ.

### US2.2 Ra lệnh thao tác task

User Story: Là Minh, tôi muốn gõ "dời các task review sang chiều mai" và thấy ngay kết quả, để không phải kéo từng task.

AC01: Hành động thực hiện xong hiện chip task trong câu trả lời: tiêu đề, ngày giờ cụ thể, nút "Hoàn tác".

AC02: Bấm "Hoàn tác" → chip gạch ngang "Đã hoàn tác"; task do AI tạo vào Thùng rác (G02).

AC03: Yêu cầu hành động bị cấm (ví dụ "xoá task X", "gửi kế hoạch cho sếp", "bật chế độ tối") → Sunny từ chối, nói cách tự làm (Ctrl+Backspace, Chia sẻ trong G08, Cài đặt).

### US2.3 Ngày giờ tương đối luôn đúng

User Story: Là người dùng làm khuya, tôi muốn "ngày mai" được hiểu đúng hoặc được hỏi lại, để task không rơi vào ngày sai như EC-01.

AC01: Mọi yêu cầu gửi AI có ngày giờ hiện tại, timezone, day_start_time và ngày làm việc hiện tại.

AC02: Chip và câu trả lời luôn hiện ngày cụ thể ("Thứ Năm, 5/11"), không chỉ "ngày mai".

AC03: Từ 00:00 đến day_start_time, yêu cầu chứa "hôm nay / ngày mai / tối nay / sáng mai" → Sunny hỏi lại với 2 nút ngày cụ thể (ví dụ lúc 02:10 ngày 4/11: "Thứ Tư 4/11" / "Thứ Năm 5/11"); chưa tạo task tới khi người dùng chọn.

AC04: Ca kiểm chứng EC-01 nằm trong bộ đánh giá và phải đạt.

### US2.4 Thay đổi nhiều task phải duyệt

AC01: Yêu cầu ảnh hưởng > 3 task → hiện thẻ "Sunny sẽ thay đổi n task" với danh sách trước / sau, nút "Áp dụng", "Huỷ", bỏ chọn từng dòng (EC-37).

AC02: ≤ 3 task → áp dụng ngay, có chip và Hoàn tác.

### US2.5 Xem lại cuộc trò chuyện

AC01: "Lịch sử" liệt kê cuộc trò chuyện mới nhất trước, giữ 90 ngày `[giả định]`; xoá được từng cuộc.

AC02: Chip trong cuộc cũ vẫn hoàn tác được trong 7 ngày `[giả định]`.

## UC3. Highlights AI cuối ngày

### US3.1 Có sẵn nháp highlights

User Story: Là Hà, tôi muốn cuối ngày có sẵn bản tóm tắt việc đã làm, để chỉ cần sửa vài chữ rồi chia sẻ cho khách hàng.

AC01: 17:00 T2–T6 (theo timezone) hệ thống soạn nháp từ task đã xong hôm nay và hoạt động trên công cụ đã kết nối (G11); có biểu tượng ✨.

AC02: Nháp viết theo "Ngôn ngữ tóm tắt"; mỗi ý gắn link về task / item nguồn.

AC03: Ngày không có task xong → không soạn nháp.

### US3.2 Duyệt highlights trong Daily shutdown

AC01: Bước highlights của Daily shutdown (G08) hiện nháp AI; người dùng sửa, xoá ý, "Soạn lại".

AC02: Highlights chỉ lưu khi người dùng bấm tiếp / hoàn tất bước; trước đó chỉ là nháp.

AC03: Người dùng đã sửa nháp → task xong thêm sau đó không ghi đè; hiện "Có 2 việc mới xong · Thêm vào".

AC04: Tắt "Tóm tắt tự động" → không soạn lúc 17:00; vẫn bấm "Soạn bằng AI" được trong bước highlights.

## UC4. Hoàn tác hành động AI

### US4.1 Hoàn tác mà không mất công sửa của mình

AC01: Hoàn tác được theo từng thay đổi (chip) hoặc cả lượt ("Huỷ tất cả").

AC02: Chỉ trả về giá trị trước khi AI sửa cho đúng các trường AI đã đổi; trường người dùng sửa sau đó giữ nguyên (EC-38).

AC03: Người dùng đã sửa chính trường AI đổi (hoặc thêm nội dung vào task AI tạo) → hỏi "Giữ bản của bạn" / "Trả về trước khi AI sửa".

AC04: Nhật ký task ghi cả hành động AI và lần hoàn tác.

## UC5. Rào chắn, cài đặt và chất lượng AI

### US5.1 Kiểm soát AI trong Cài đặt

AC01: Cài đặt → AI: Trợ lý (bật / tắt), Gợi ý channel, Gợi ý thời lượng (G02), Ngôn ngữ tóm tắt, Tóm tắt tự động; Cài đặt → Beta: Agentic Daily Planning.

AC02: Tắt trợ lý → ẩn nút ✨, không gọi AI cho chat và highlights.

### US5.2 Gửi phản hồi

AC01: Review Plan, câu trả lời Sunny và nháp highlights có nút "Hữu ích" / "Chưa tốt" `[giả định]` và "Gửi phản hồi" (ô chữ tuỳ chọn).

AC02: Phản hồi và lần hoàn tác được thu làm tín hiệu chất lượng, không kèm dữ liệu task nếu người dùng không tích "Đính kèm cuộc trò chuyện".

### US5.3 Đánh giá trước khi đổi model / prompt (nội bộ)

AC01: Bộ đánh giá ≥ 200 câu Việt / Anh, chia nhóm: ngày giờ tương đối (gồm ca nửa đêm EC-01), thao tác task, ngưỡng > 3 task, hành động bị cấm, ngôn ngữ, highlights.

AC02: Đạt ≥ 95% tổng và 100% nhóm rào chắn, ngày giờ mới được phát hành; kết quả lưu theo phiên bản model / prompt.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu 1.2** |
|---|---|---|
| Tỉ lệ dùng Planning Agent | Ngày có chạy agent / ngày có Daily planning (người bật Beta) | ≥ 50% |
| Tỉ lệ kế hoạch agent được áp dụng | Lượt "Tiếp" không Huỷ tất cả / lượt chạy xong | ≥ 70% |
| Thời gian lập kế hoạch với agent | Từ "Plan my day" đến "Tiếp" | ≤ 5 phút (trung vị) |
| Tỉ lệ hoàn tác hành động chat | Thay đổi bị hoàn tác / thay đổi áp dụng | ≤ 10% |
| Thời gian tới kết quả đầu tiên | Từ gửi đến chữ / bước đầu tiên | p95 ≤ 10 giây |
| Tỉ lệ chuyển luồng thủ công | Lượt agent lỗi / lượt chạy | ≤ 3% |
| Tỉ lệ giữ nháp highlights | Highlights lưu sửa < 30% ký tự / nháp được mở | ≥ 60% |
| Điểm bộ đánh giá | Câu đúng / tổng câu | ≥ 95%; rào chắn và ngày giờ 100% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Nhà cung cấp LLM | Chưa chọn; độ trễ, chi phí, chất lượng tiếng Việt khác nhau | Lớp trung gian đổi được model; chọn theo bộ đánh giá |
| Hiểu sai ngày giờ | Đã gặp trên Sunsama (EC-01) | Ngữ cảnh thời gian bắt buộc; server kiểm ngày tuyệt đối; hỏi lại trong khung mơ hồ |
| Dữ liệu cá nhân gửi LLM | Nghị định 13/2023/NĐ-CP, GDPR; vùng lưu dữ liệu | Gửi tối thiểu; hợp đồng không lưu, không huấn luyện; cần pháp chế xác nhận |
| Lệnh ẩn trong dữ liệu (prompt injection) | Tiêu đề email / item Jira chứa câu lệnh | Dữ liệu ngoài chỉ là dữ liệu; rào chắn kiểm ở server, không dựa vào model |
| Chi phí token | Agent đọc nhiều lịch, task, item | Hạn mức / ngày; cắt ngữ cảnh theo khoảng ngày cần |
| Phụ thuộc G08, G11, G05 | Agent nối vào ritual; highlights đọc hoạt động công cụ | Hợp đồng API giữa nhóm; thiếu nguồn thì agent vẫn chạy với dữ liệu có |
| Agent áp dụng sai nhiều task | Mất niềm tin | Review Plan bắt buộc; Huỷ tất cả; tín hiệu hoàn tác theo dõi hằng tuần |

# 10. Câu hỏi mở

- day_start_time 04:00 hay 00:00? Quyết định khung mơ hồ của EC-01.
- Planning Agent chờ duyệt rồi mới áp dụng (đề xuất) hay áp dụng ngay rồi Undo all như Sunsama?
- Sunny có được đánh dấu xong task không, hay chỉ người dùng?
- Chọn nhà cung cấp LLM nào; dữ liệu có cần xử lý / lưu tại Việt Nam không?
- Hạn mức chat và số lần chạy agent có khác theo gói không (G12)?
- Lịch sử chat giữ 90 ngày có đủ không; có cho tắt lưu lịch sử?
- Highlights chia sẻ có gồm task trong channel private không (Privacy, G12)?
- Khi nào Planning Agent bỏ nhãn Beta; tiêu chí nào?
- Quản trị workspace có được tắt AI cho cả workspace không?
