> **Mã:** PLN-PRD-G10 · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g10-tro-ly-ai.md

# PRD Trợ lý AI trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: khung chat Sunny ("Describe a task or ask a question", History, New chat, "Thought 8s", chip task + Undo → chip gạch "Undone"), luồng Planning Agent ("Plan my day" → Review Plan "The planning agent added 1 task" → Next → Daily plan → Get started), nhật ký "Sunsama Planning Agent created this", và lỗi EC-01 (lúc 02:10 ngày 4/11 yêu cầu tạo task "ngày mai" → Sunny tạo vào 4/11, không hiện ngày cụ thể để người dùng phát hiện). Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> **Cập nhật 04/11/2026** theo [quyết định chốt mâu thuẫn](../review/quyet-dinh-chot-2026-11-04.md) (Q2, Q8, Q14, Q20, Q21, Q31/Q31a, B14, C30–C33) và [ADR-0003](../adr/0003-gioi-han-quyen-cua-tro-ly-ai.md). Quy tắc dùng chung (ngày làm việc QC-01, lịch làm việc QC-02, đổi ngày task QC-05, chế độ chỉ đọc QC-09, quyền theo gói QC-10) xem [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); PRD này chỉ tham chiếu, không định nghĩa lại.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Bản 1.0 đã có gợi ý thời lượng và channel khi tạo task (G02). Bản 1.2 đưa AI vào ba chỗ tốn công nhất của vòng lặp ngày: lập kế hoạch buổi sáng (Planning Agent), thao tác nhanh trong ngày bằng ngôn ngữ tự nhiên (trợ lý chat Sunny) và viết highlights cuối ngày. Nhóm G10 lo ba tính năng này cùng rào chắn, bước đồng ý dùng AI và bộ đánh giá chất lượng dùng chung. Trợ lý AI mặc định tắt cho tới khi người dùng đồng ý chia sẻ dữ liệu với nhà cung cấp AI (ADR-0003). Bản 1.2 ra sau 1.1 nên chế độ chỉ đọc (QC-09) và hạn mức theo gói (QC-10) đã có sẵn và áp dụng ngay cho AI (Q10, ADR-0002). Daily planning / Daily shutdown thủ công (G08), task (G02), timebox (G05) và nguồn dữ liệu từ công cụ ngoài (G11) nằm ở nhóm riêng; AI chỉ đọc / ghi qua đúng các thao tác mà người dùng có.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Daily planning thủ công mất 10–15 phút `[giả định]` khi có 6–8 cuộc họp và việc rải ở Jira, Notion, Gmail | Người dùng bỏ ritual, ngày không có kế hoạch |
| Thao tác nhiều task (dời, sắp lại, chia nhỏ) phải làm từng cái | Ngại sắp lại kế hoạch khi ngày thay đổi |
| AI hiểu sai ngày tương đối ("ngày mai" lúc 02:10 — EC-01) và không cho thấy ngày cụ thể | Task rơi vào ngày sai, người dùng không phát hiện |
| AI sửa nhiều task một lúc mà không cho xem trước hoặc không hoàn tác được trọn | Mất kiểm soát kế hoạch, mất niềm tin vào AI |
| Dữ liệu cá nhân và nội dung từ công cụ ngoài bị gửi cho AI khi người dùng chưa đồng ý; lệnh ẩn trong email / issue điều khiển AI | Vi phạm NĐ 13/2023; AI làm thay đổi người dùng không muốn |
| Viết highlights cuối ngày từ đầu tốn thời gian | Bỏ bước highlights, Weekly review (G09) thiếu dữ liệu |
| AI lỗi hoặc chậm làm kẹt ritual | Người dùng không lập được kế hoạch đúng lúc cần nhất |

## 1.3 Mục tiêu

- Lập kế hoạch ngày với Planning Agent trong ≤ 5 phút kể cả thời gian duyệt; agent chạy 2–4 phút.
- Mọi thay đổi do AI làm đều nhìn thấy được, ghi tác nhân AI và hoàn tác được; cả kế hoạch của Planning Agent hoàn tác được bằng một nút ("Hoàn tác kế hoạch AI").
- Không có lời gọi AI nào trước khi người dùng đồng ý; AI không bao giờ đánh dấu task hoàn thành (Q20, Q21).
- Mọi ngày giờ AI dùng hiện ở dạng cụ thể ("Thứ Năm, 5/11") trước hoặc ngay khi áp dụng; không lặp lại EC-01.
- Kết quả đầu tiên (chữ trả lời hoặc bước tiến độ) hiện ≤ 10 giây; AI lỗi thì người dùng vẫn đi tiếp bằng luồng thủ công.
- Bộ đánh giá ≥ 200 câu Việt / Anh đạt ≥ 95% trước mỗi lần đổi model hoặc prompt.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh — PM, 6–8 cuộc họp / ngày, việc ở Jira + Notion + Gmail | Agent gom việc từ các nguồn, xếp vào khe trống giữa các cuộc họp |
| Minh — designer / dev | Giữ khối thời gian dài cho việc sâu; nói "dời hết việc lặt vặt sang chiều" là xong |
| Hà — freelancer / founder, nhiều khách hàng | Không nhận quá sức; AI cảnh báo khi kế hoạch vượt ngưỡng 8 giờ |
| Người dùng thận trọng với AI | AI chỉ chạy khi mình đã đồng ý; email / issue không gửi cho AI nếu mình không bật; xem trước thay đổi lớn, hoàn tác từng phần, tắt AI khi muốn |
| Người dùng song ngữ Việt / Anh | Gõ tiếng Việt hay tiếng Anh đều được hiểu, trả lời đúng ngôn ngữ đã gõ |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.2)

- Nền tảng: Web (desktop, mobile web), App iOS / Android và desktop dùng cùng đặc tả.
- Đồng ý dùng AI lần đầu: trợ lý AI mặc định tắt; lần đầu bật phải qua màn đồng ý, hệ thống lưu thời điểm đồng ý (Q21).
- Planning Agent (Beta "Agentic Daily Planning"): thiết lập 1 lần, "Plan my day", kế hoạch áp dụng ngay rồi hiện Review Plan (Re-plan, "Hoàn tác kế hoạch AI", Submit feedback), nối vào bước Daily plan của G08; kế hoạch có dùng dữ liệu tích hợp thì chờ duyệt (Q31/Q31a).
- Trợ lý chat Sunny (nút ✨ góc dưới): hỏi đáp về kế hoạch, ra lệnh tạo / sửa / dời / sắp / timebox task, History, New chat.
- Highlights AI cuối ngày: nháp tự động T2–T6 17:00 từ task đã xong và (khi người dùng bật) hoạt động trên công cụ đã kết nối; người dùng duyệt trước khi lưu.
- Rào chắn: danh sách hành động được phép (không gồm đánh dấu xong), xác nhận khi ảnh hưởng > 3 task hoặc khi ngữ cảnh có dữ liệu ngoài, hoàn tác, dữ liệu gửi LLM tối thiểu, dữ liệu tích hợp mặc định không gửi.
- Nhóm cài đặt AI và Beta trong trang Cài đặt, gồm công tắc riêng "Dùng dữ liệu từ công cụ đã kết nối".
- Bộ đánh giá chất lượng AI và thu tín hiệu (Submit feedback, Hoàn tác).

## 3.2 Ngoài phạm vi

- Gợi ý thời lượng và channel khi tạo task → G02 (đã có ở 1.0).
- Daily planning / Daily shutdown thủ công, chia sẻ kế hoạch → G08. Weekly planning / review → G09.
- Kết nối và đọc dữ liệu công cụ ngoài → G11; lịch → G05.
- AI xoá task, đánh dấu hoặc bỏ đánh dấu hoàn thành task, gửi tin ra ngoài (email, Slack, Teams), đổi cài đặt → không làm, ở mọi phiên bản (Q20, ADR-0003).
- Agent tự chạy nền không có người dùng (tự lập kế hoạch lúc 06:00) → sau 1.2.
- Nhập bằng giọng nói → sau 1.2 `[giả định]`.
- AI cho workspace nhiều người (lập kế hoạch nhóm, tóm tắt cho quản lý) → sau 1.2.

# 4. Nguyên tắc sản phẩm

## 4.1 AI đề xuất, người dùng quyết

AI chỉ hành động khi người dùng đã bật trợ lý AI và đồng ý (Q21). Chat: thay đổi ≤ 3 task và không có dữ liệu ngoài trong ngữ cảnh thì áp dụng ngay, có chip và Hoàn tác tại chỗ; > 3 task hoặc ngữ cảnh có dữ liệu ngoài thì hiện danh sách để duyệt trước. Planning Agent: áp dụng ngay cả kế hoạch, có nút "Hoàn tác kế hoạch AI"; riêng kế hoạch có dùng dữ liệu tích hợp thì chờ duyệt (Q31/Q31a). AI không bao giờ đánh dấu task hoàn thành (Q20).

## 4.2 Rõ ngày, rõ giờ

AI luôn biết ngày giờ, timezone và ngày làm việc hiện tại; "hôm nay / ngày mai" hiểu theo ngày làm việc (QC-01); mọi ngày trong kết quả hiện dạng cụ thể. Khi người dùng nói "ngày mai" trong khoảng từ 00:00 tới mốc đầu ngày (ngày lịch đã sang nhưng ngày làm việc chưa sang), AI hỏi lại thay vì đoán (EC-01).

## 4.3 Không có hành động AI mất trắng

Mọi hành động AI ghi nhật ký với tác nhân AI và hoàn tác được. Hoàn tác chỉ trả lại phần AI đã làm, không xoá công sửa của người dùng (EC-38).

## 4.4 AI hỏng, ngày vẫn chạy

AI lỗi hoặc chậm quá 10 giây trong ritual thì chuyển luồng thủ công, giữ nguyên những gì người dùng đã nhập (EC-39). Mọi chức năng cốt lõi không phụ thuộc AI.

## 4.5 Dữ liệu ngoài chỉ là dữ liệu

Dữ liệu từ công cụ tích hợp (tiêu đề email, issue, trang Notion) mặc định không vào ngữ cảnh AI; người dùng bật bằng công tắc riêng. Khi đã bật, mọi hành động AI đề xuất trong ngữ cảnh có dữ liệu đó đều chờ người dùng duyệt, để chặn lệnh ẩn trong nội dung bên ngoài (Q21, ADR-0003).

# 5. Quy tắc hành vi AI

| **Quy tắc** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Đồng ý dùng AI | Lần đầu bật trợ lý AI phải qua màn đồng ý; lưu thời điểm đồng ý | Tắt | Trước khi đồng ý không có lời gọi AI nào, kể cả nháp highlights 17:00 (Q21, ADR-0003) |
| Dữ liệu tích hợp trong ngữ cảnh AI | Tiêu đề item và hoạt động từ công cụ G11 | Tắt | Công tắc riêng; tắt thì AI không đọc item, highlights không dùng hoạt động công cụ (Q21) |
| Hành động được phép | Tạo task (từ item tích hợp thì qua G11, B14), sửa tiêu đề / thời lượng / channel / priority / due, thêm subtask, dời ngày / vào backlog, sắp thứ tự, timebox / gỡ timebox, gắn objective (G09) | Tất cả | Kiểm tra ở server, không phụ thuộc model. Dời ngày theo QC-05 dòng "AI dời ngày" (Q14) |
| Hành động bị cấm | Xoá task / subtask, đánh dấu / bỏ đánh dấu hoàn thành, gửi tin ra ngoài, đổi cài đặt, kết nối / ngắt tích hợp, đọc / sửa dữ liệu người khác | — | Từ chối và chỉ cách người dùng tự làm (Q20) |
| Áp dụng ngay hay chờ duyệt | Chat: ≤ 3 task và không có dữ liệu ngoài → áp dụng ngay; > 3 task hoặc có dữ liệu ngoài → chờ duyệt. Planning Agent: áp dụng ngay, kèm "Hoàn tác kế hoạch AI"; có dùng dữ liệu tích hợp → chờ duyệt | 3 task | Q31/Q31a, Q21; EC-37 (Planning Agent là ngoại lệ có chủ đích của EC-37) |
| Ngữ cảnh thời gian | Ngày giờ hiện tại có offset, timezone, mốc đầu ngày, ngày làm việc hiện tại (QC-01), lịch làm việc (QC-02) | Bắt buộc | Thiếu thì không gọi LLM (EC-01) |
| "Hôm nay / ngày mai" | Theo hàm ngày làm việc (QC-01); hỏi lại khi người dùng nói "ngày mai" lúc ngày lịch đã sang mà ngày làm việc chưa sang | Hỏi lại bằng 2 lựa chọn ngày cụ thể | Q2, C33; bảng ví dụ QC-01 là ca chuẩn của bộ đánh giá |
| Đề xuất chờ duyệt | Hết hạn ở cuối ngày làm việc; áp dụng có kiểm phiên bản, chỉ loại dòng lỗi thời, không áp dụng giờ đã qua | — | C31 |
| Kết quả đầu tiên | ≤ 10 giây `[giả định]` | — | Có trạng thái "đang xử lý" ("Thought 8s") |
| Planning Agent | Chạy 2–4 phút; tối đa 5 phút `[giả định]`; số lượt / ngày theo bảng quyền G12 (QC-10) | — | Lỗi / > 10 giây chưa có bước đầu → luồng thủ công (EC-39) |
| Thời hạn hoàn tác | 7 ngày sau khi áp dụng `[giả định]` | — | Sau đó chip không còn nút Hoàn tác |
| Hạn mức | Chat, Planning Agent, soạn lại highlights đếm riêng; con số đọc từ bảng quyền G12 (QC-10) | — | Lượt lỗi và "Lập lại" vì đề xuất lỗi thời không trừ (C32, C31) |
| Tin nhắn chat | 1–2.000 ký tự `[giả định]` | — | Số tin / ngày theo QC-10 |
| Lịch sử chat | Giữ 90 ngày `[giả định]` | — | Người dùng xoá được từng cuộc trò chuyện; ngắt tích hợp thì xoá dữ liệu của tích hợp đó trong lịch sử AI (C30) |
| Ngôn ngữ | Chat: ngôn ngữ tin nhắn người dùng. Highlights: cài đặt "Ngôn ngữ tóm tắt" | Auto | Auto = ngôn ngữ giao diện `[giả định]` |
| Nháp highlights | T2–T6 17:00 theo timezone người dùng `[giả định]` | Bật ("Tóm tắt tự động"), chỉ chạy khi trợ lý AI đã bật và đã đồng ý | Không lưu tới khi người dùng duyệt |
| Chế độ chỉ đọc | Không gọi AI, kể cả job highlights | — | QC-09 (có từ 1.1, Q8) |
| Bộ đánh giá | ≥ 200 câu Việt / Anh; ≥ 95% đúng `[giả định]`; nhóm rào chắn, ngày giờ và lệnh ẩn trong dữ liệu 100% | — | Chạy trước mỗi lần đổi model / prompt (Q21) |

- Các giá trị là **cấu hình hệ thống**, không cố định trong code. Hạn mức theo gói đọc từ bảng quyền của G12 (QC-10), không viết cứng.
- Dữ liệu gửi LLM: tối thiểu cho yêu cầu đang xử lý, chỉ sau khi người dùng đồng ý; nhà cung cấp LLM không lưu, không dùng để huấn luyện (điều khoản hợp đồng). Dữ liệu gửi nhà cung cấp LLM ở ngoài Việt Nam được đưa vào hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (NĐ 13/2023, Q29); pháp chế xác nhận trước khi phát hành.

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 1 | Bật và thiết lập | Bật trợ lý AI qua màn đồng ý (lần đầu); bật Beta "Agentic Daily Planning"; kết nối công cụ (G05, G11), chọn có dùng dữ liệu công cụ cho AI không, "Tell me about yourself", theme days | Thời điểm đồng ý; hồ sơ agent |
| 2 | Lập kế hoạch sáng | Mở Daily planning (G08) → gõ điều quan trọng hôm nay → "Plan my day" → kế hoạch áp dụng ngay, Review Plan hiện các thay đổi kèm "Hoàn tác kế hoạch AI" → Next (kế hoạch có dữ liệu tích hợp: duyệt rồi mới áp dụng) | Kế hoạch ngày được áp dụng, sang bước Daily plan (G08) |
| 3 | Trong ngày | Bấm ✨ mở Sunny: hỏi "chiều nay còn trống bao lâu?", ra lệnh "dời 3 việc review sang mai" | Task được tạo / dời / sắp, có chip và Hoàn tác |
| 4 | Cuối ngày | 17:00 có nháp highlights (chỉ khi đã đồng ý); mở Daily shutdown (G08) → duyệt / sửa → lưu | Highlights của ngày |
| 5 | Sửa sai | Hoàn tác từng thay đổi, cả lượt chat, hoặc "Hoàn tác kế hoạch AI"; Submit feedback | Kế hoạch đúng ý; tín hiệu chất lượng |
| 6 | Kiểm soát chất lượng (nội bộ) | Chạy bộ đánh giá trước khi đổi model / prompt | Bản phát hành AI đạt ngưỡng |

Bước 2 và 4 chạy bên trong ritual của G08; PRD này chỉ mô tả phần AI. PRD tập trung bước 1–6 trừ phần thủ công của ritual.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Lập kế hoạch ngày với Planning Agent

### US1.1 Thiết lập agent lần đầu

AC01: Lần đầu bấm "Plan my day" khi chưa thiết lập → mở màn thiết lập 3 phần: kết nối công cụ (trỏ G05, G11) kèm công tắc "Dùng dữ liệu từ công cụ đã kết nối" (mặc định tắt, US6.2), "Kể về bạn" (vai trò, giờ làm việc ưa thích, việc cần tránh), theme days (mỗi thứ trong tuần một chủ đề tuỳ chọn).

AC02: Phần nào cũng bỏ qua được; sửa lại sau trong Cài đặt → AI.

AC03: Chỉ hiện khi bật Beta "Agentic Daily Planning".

AC04: Trợ lý AI chưa bật hoặc chưa có đồng ý → bấm "Plan my day" mở màn đồng ý (US6.1) trước màn thiết lập; người dùng không đồng ý thì không chạy agent và không có lời gọi AI nào.

### US1.2 Cho agent lập kế hoạch

User Story: Là Linh, tôi muốn nói điều quan trọng hôm nay rồi để agent xếp ngày quanh các cuộc họp, để không mất 15 phút kéo thả mỗi sáng.

AC01: Trong Daily planning (G08) có ô "Điều quan trọng nhất hôm nay là gì?" và nút "Plan my day".

AC02: Khi chạy, màn hình hiện các bước tiến độ (đọc lịch, đọc việc từ công cụ, xếp khối thời gian); bước đầu tiên hiện ≤ 10 giây.

AC03: Agent chỉ dùng các hành động được phép (mục 5); không xoá task, không đánh dấu task xong. Task tạo từ issue / email / trang Notion đi qua cơ chế "một item, một task" của G11 (B14), không sinh task trùng.

AC04: Chạy xong (2–4 phút): kế hoạch không dùng dữ liệu tích hợp → áp dụng ngay rồi chuyển sang Review Plan; có dùng dữ liệu tích hợp → chuyển sang Review Plan ở chế độ chờ duyệt, chưa áp dụng gì (Q31/Q31a).

AC05: Agent chỉ đọc item từ công cụ tích hợp khi người dùng đã bật "Dùng dữ liệu từ công cụ đã kết nối" (Q21).

### US1.3 Duyệt kế hoạch (Review Plan)

AC01: Review Plan hiện câu tóm tắt ("Planning Agent đã thêm 3 task, dời 2 task") và danh sách "HÔM NAY · n thay đổi"; mỗi dòng có nhãn loại thay đổi và ngày giờ cụ thể.

AC02: Kế hoạch không dùng dữ liệu tích hợp đã được áp dụng khi Review Plan mở (như Sunsama; Q31). Mỗi dòng có "Hoàn tác" riêng; nút "Hoàn tác kế hoạch AI" (Undo all) trả lại toàn bộ kế hoạch theo quy tắc hoàn tác US4.1. Planning Agent là ngoại lệ có chủ đích của ngưỡng > 3 task (EC-37).

AC03: Kế hoạch có dùng dữ liệu tích hợp → Review Plan ở chế độ chờ duyệt: nhãn "Cần bạn duyệt vì kế hoạch dùng dữ liệu từ {công cụ}", bỏ chọn từng dòng để không áp dụng dòng đó, "Áp dụng và tiếp" mới áp dụng (Q31a, Q21).

AC04: "Lập lại" (Re-plan) cho nhập thêm chỉ dẫn, hoàn tác kế hoạch hiện tại rồi chạy lại; "Hoàn tác kế hoạch AI" (đã áp dụng) hoặc "Huỷ tất cả" (chờ duyệt) bỏ toàn bộ kế hoạch và về Daily planning thủ công; "Gửi phản hồi" mở form phản hồi.

AC05: Sau "Tiếp" đi tới bước Daily plan (G08); task do agent tạo có nhật ký "Planning Agent đã tạo task này". Bước Daily plan có nút "Hoàn tác kế hoạch AI" (G08 đặt nút, G10 xử lý) dùng được trong thời hạn hoàn tác.

AC06: Một dòng không áp dụng được vì task vừa đổi ở nơi khác hoặc giờ đã qua → chỉ dòng đó bị loại, các dòng khác vẫn áp dụng; Review Plan báo số dòng bị loại (C31). Kế hoạch chờ duyệt chưa áp dụng tới cuối ngày làm việc → tự hết hạn (C31).

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

AC03: Yêu cầu hành động bị cấm (ví dụ "xoá task X", "đánh dấu xong task Y", "gửi kế hoạch cho sếp", "bật chế độ tối") → Sunny từ chối, nói cách tự làm (Ctrl+Backspace, tích ✓ / phím C, Chia sẻ trong G08, Cài đặt).

AC04: Yêu cầu dời ngày áp dụng như người dùng kéo task sang ngày khác (QC-05 dòng "AI dời ngày"): timebox giữ giờ và dời theo, timer không dừng, số ngày bị hoãn reset; không đặt task chưa xong vào ngày đã qua.

### US2.3 Ngày giờ tương đối luôn đúng

User Story: Là người dùng làm khuya, tôi muốn "ngày mai" được hiểu đúng hoặc được hỏi lại, để task không rơi vào ngày sai như EC-01.

AC01: Mọi yêu cầu gửi AI có ngày giờ hiện tại, timezone, mốc đầu ngày và ngày làm việc hiện tại (QC-01).

AC02: Chip và câu trả lời luôn hiện ngày cụ thể ("Thứ Năm, 5/11"), không chỉ "ngày mai".

AC03: Từ 00:00 tới mốc đầu ngày (ngày lịch đã sang, ngày làm việc chưa sang), yêu cầu chứa "ngày mai / sáng mai" → Sunny hỏi lại với 2 nút ngày cụ thể (ví dụ mốc 04:00, lúc 02:10 ngày 4/11: "Thứ Tư 4/11" / "Thứ Năm 5/11"); chưa tạo task tới khi người dùng chọn. Mốc đầu ngày là 00:00 thì không có khoảng này, không hỏi lại.

AC04: Ca kiểm chứng EC-01 và toàn bộ bảng ví dụ của QC-01 nằm trong bộ đánh giá và phải đạt (C33).

AC05: "Hôm nay / tối nay" = ngày làm việc hiện tại; "ngày mai / sáng mai" = ngày làm việc hiện tại + 1 (QC-01, Q2). Ví dụ mốc 04:00, lúc 02:10 ngày 4/11: ngày làm việc hiện tại là Thứ Ba 3/11, "hôm nay" = 3/11, không hỏi lại.

### US2.4 Thay đổi nhiều task phải duyệt

AC01: Yêu cầu ảnh hưởng > 3 task → hiện thẻ "Sunny sẽ thay đổi n task" với danh sách trước / sau, nút "Áp dụng", "Huỷ", bỏ chọn từng dòng (EC-37).

AC02: ≤ 3 task và ngữ cảnh không có dữ liệu ngoài → áp dụng ngay, có chip và Hoàn tác (Q31a).

AC03: Ngữ cảnh lượt chat có dữ liệu từ công cụ tích hợp (người dùng đã bật công tắc, US6.2) → mọi hành động đều qua thẻ duyệt như AC01, kể cả khi chỉ 1 task; thẻ ghi rõ "Cần bạn duyệt vì yêu cầu dùng dữ liệu từ {công cụ}" (Q21).

AC04: Thẻ chưa duyệt tới cuối ngày làm việc → hết hạn, thẻ xám "Đã hết hạn". Khi bấm "Áp dụng", dòng có task vừa đổi ở nơi khác hoặc giờ đã qua bị loại, các dòng khác vẫn áp dụng (C31).

### US2.5 Xem lại cuộc trò chuyện

AC01: "Lịch sử" liệt kê cuộc trò chuyện mới nhất trước, giữ 90 ngày `[giả định]`; xoá được từng cuộc.

AC02: Chip trong cuộc cũ vẫn hoàn tác được trong 7 ngày `[giả định]`.

AC03: Người dùng ngắt một tích hợp (G11) → dữ liệu của tích hợp đó trong lịch sử AI (trích dẫn item, câu trả lời có dữ liệu item, nháp highlights) bị xoá; chỗ bị xoá hiện "Nội dung từ {công cụ} đã xoá khi ngắt kết nối" (C30).

## UC3. Highlights AI cuối ngày

### US3.1 Có sẵn nháp highlights

User Story: Là Hà, tôi muốn cuối ngày có sẵn bản tóm tắt việc đã làm, để chỉ cần sửa vài chữ rồi chia sẻ cho khách hàng.

AC01: 17:00 T2–T6 (theo timezone) hệ thống soạn nháp từ task đã xong trong ngày làm việc và, khi người dùng bật "Dùng dữ liệu từ công cụ đã kết nối", hoạt động trên công cụ đã kết nối (G11); có biểu tượng ✨.

AC02: Nháp viết theo "Ngôn ngữ tóm tắt"; mỗi ý gắn link về task / item nguồn.

AC03: Ngày không có task xong → không soạn nháp.

AC04: Người dùng chưa đồng ý dùng AI hoặc trợ lý AI đang tắt → job 17:00 không chạy, không có lời gọi AI nào cho người dùng đó (Q21). Workspace chỉ đọc → không soạn (QC-09).

AC05: Hoạt động công cụ chỉ tính việc do chính tài khoản đã kết nối thực hiện (ví dụ issue Hà tự chuyển sang Done), không tính việc đồng nghiệp làm; Gmail không có hoạt động "đóng" (C28).

### US3.2 Duyệt highlights trong Daily shutdown

AC01: Bước highlights của Daily shutdown (G08) hiện nháp AI; người dùng sửa, xoá ý, "Soạn lại".

AC02: Highlights chỉ lưu khi người dùng bấm tiếp / hoàn tất bước; trước đó chỉ là nháp.

AC03: Người dùng đã sửa nháp → task xong thêm sau đó không ghi đè; hiện "Có 2 việc mới xong · Thêm vào".

AC04: Tắt "Tóm tắt tự động" → không soạn lúc 17:00; vẫn bấm "Soạn bằng AI" được trong bước highlights.

AC05: "Soạn lại" bị giới hạn số lượt / ngày theo bảng quyền G12 (QC-10); lượt lỗi không trừ (C32).

## UC4. Hoàn tác hành động AI

### US4.1 Hoàn tác mà không mất công sửa của mình

AC01: Hoàn tác được theo từng thay đổi (chip) hoặc cả lượt ("Hoàn tác tất cả" trong chat, "Hoàn tác kế hoạch AI" với Planning Agent).

AC02: Chỉ trả về giá trị trước khi AI sửa cho đúng các trường AI đã đổi; trường người dùng sửa sau đó giữ nguyên (EC-38).

AC03: Người dùng đã sửa chính trường AI đổi (hoặc thêm nội dung vào task AI tạo) → hỏi "Giữ bản của bạn" / "Trả về trước khi AI sửa".

AC04: Nhật ký task ghi cả hành động AI và lần hoàn tác.

AC05: "Hoàn tác kế hoạch AI" (trong Review Plan hoặc bước Daily plan của G08) hoàn tác mọi thay đổi còn hiệu lực của lượt Planning Agent đó, theo AC02–AC03: task agent tạo vào Thùng rác, task bị dời về ngày cũ (cả timebox, theo QC-05), timebox agent tạo bị gỡ.

## UC5. Rào chắn, cài đặt và chất lượng AI

### US5.1 Kiểm soát AI trong Cài đặt

AC01: Cài đặt → AI: Trợ lý (bật / tắt, mặc định tắt), Dùng dữ liệu từ công cụ đã kết nối (mặc định tắt), Gợi ý channel, Gợi ý thời lượng (G02), Ngôn ngữ tóm tắt, Tóm tắt tự động, thời điểm đã đồng ý; Cài đặt → Beta: Agentic Daily Planning.

AC02: Tắt trợ lý → ẩn nút ✨, không gọi AI cho chat, Planning Agent và highlights.

AC03: Workspace chỉ đọc (QC-09) → không gọi AI cho mọi tính năng, kể cả job highlights; nút ✨ mở khung chat hiện thông báo chỉ đọc.

### US5.2 Gửi phản hồi

AC01: Review Plan, câu trả lời Sunny và nháp highlights có nút "Hữu ích" / "Chưa tốt" `[giả định]` và "Gửi phản hồi" (ô chữ tuỳ chọn).

AC02: Phản hồi và lần hoàn tác được thu làm tín hiệu chất lượng, không kèm dữ liệu task nếu người dùng không tích "Đính kèm cuộc trò chuyện".

### US5.3 Đánh giá trước khi đổi model / prompt (nội bộ)

AC01: Bộ đánh giá ≥ 200 câu Việt / Anh, chia nhóm: ngày giờ tương đối (gồm ca nửa đêm EC-01 và mọi dòng trong bảng ví dụ của QC-01), thao tác task, ngưỡng > 3 task, hành động bị cấm (gồm "đánh dấu xong"), lệnh ẩn trong dữ liệu (tiêu đề email / issue chứa câu lệnh), ngôn ngữ, highlights.

AC02: Đạt ≥ 95% tổng `[giả định]` và 100% nhóm rào chắn, ngày giờ, lệnh ẩn trong dữ liệu mới được phát hành; kết quả lưu theo phiên bản model / prompt (Q21, C33).

## UC6. Đồng ý dùng AI và kiểm soát dữ liệu gửi AI

### US6.1 Đồng ý trước khi dùng AI lần đầu

User Story: Là người dùng thận trọng với AI, tôi muốn biết dữ liệu nào được gửi cho nhà cung cấp AI và chỉ bật khi tôi đồng ý, để dữ liệu của tôi không bị gửi đi khi tôi chưa biết.

AC01: Trợ lý AI mặc định tắt với mọi người dùng, kể cả người dùng có từ bản trước (Q21).

AC02: Lần đầu bật trợ lý AI (bấm ✨, "Plan my day", "Soạn bằng AI", hoặc bật toggle "Trợ lý" trong Cài đặt) → mở màn đồng ý: dữ liệu nào được gửi (tiêu đề, thời lượng, ngày task, sự kiện lịch; không gửi nội dung email), nhà cung cấp AI, nhà cung cấp không lưu và không huấn luyện, link chính sách quyền riêng tư; nút "Đồng ý và bật" / "Để sau".

AC03: "Đồng ý và bật" → lưu thời điểm đồng ý, bật trợ lý, tiếp tục đúng thao tác người dùng vừa bấm. "Để sau" → trợ lý giữ tắt, không có lời gọi AI nào.

AC04: Trước khi có thời điểm đồng ý, server từ chối mọi lời gọi AI của người dùng đó, kể cả job highlights 17:00 (Q21, ADR-0003).

AC05: Cài đặt → AI hiện "Bạn đã đồng ý lúc {ngày giờ}". Tắt trợ lý sau đó → ngừng mọi lời gọi AI; bật lại không hỏi lại `[giả định]`.

### US6.2 Bật riêng dữ liệu từ công cụ đã kết nối

User Story: Là Linh, tôi muốn tự quyết có cho AI đọc issue Jira và email hay không, và nếu cho thì tự duyệt mọi thay đổi AI đề xuất từ dữ liệu đó, để một email lạ không điều khiển được kế hoạch của tôi.

AC01: Công tắc "Dùng dữ liệu từ công cụ đã kết nối" trong Cài đặt → AI và màn thiết lập agent, mặc định tắt (Q21).

AC02: Tắt → AI không đọc item G11 (chat, Planning Agent) và highlights không dùng hoạt động công cụ.

AC03: Bật → mọi hành động AI đề xuất trong lượt có dữ liệu công cụ đều chờ duyệt (chat theo US2.4 AC03, Planning Agent theo US1.3 AC03).

AC04: Dữ liệu công cụ chỉ là dữ liệu: câu lệnh nằm trong tiêu đề email / issue không làm AI thực hiện hành động bị cấm; ca kiểm thử nằm trong nhóm "lệnh ẩn trong dữ liệu" của bộ đánh giá, phải đạt 100%.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu 1.2** |
|---|---|---|
| Tỉ lệ dùng Planning Agent | Ngày có chạy agent / ngày có Daily planning (người bật Beta) | ≥ 50% |
| Tỉ lệ kế hoạch agent được giữ | Lượt chạy xong không bị "Hoàn tác kế hoạch AI" / "Huỷ tất cả" trong ngày làm việc / lượt chạy xong | ≥ 70% |
| Tỉ lệ đồng ý dùng AI | Người dùng bấm "Đồng ý và bật" / người dùng thấy màn đồng ý | Theo dõi, chưa đặt mục tiêu |
| Thời gian lập kế hoạch với agent | Từ "Plan my day" đến "Tiếp" | ≤ 5 phút (trung vị) |
| Tỉ lệ hoàn tác hành động chat | Thay đổi bị hoàn tác / thay đổi áp dụng | ≤ 10% |
| Thời gian tới kết quả đầu tiên | Từ gửi đến chữ / bước đầu tiên | p95 ≤ 10 giây |
| Tỉ lệ chuyển luồng thủ công | Lượt agent lỗi / lượt chạy | ≤ 3% |
| Tỉ lệ giữ nháp highlights | Highlights lưu sửa < 30% ký tự / nháp được mở | ≥ 60% |
| Điểm bộ đánh giá | Câu đúng / tổng câu | ≥ 95%; rào chắn, ngày giờ và lệnh ẩn trong dữ liệu 100% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Nhà cung cấp LLM | Chưa chọn; độ trễ, chi phí, chất lượng tiếng Việt khác nhau | Lớp trung gian đổi được model; chọn theo bộ đánh giá |
| Hiểu sai ngày giờ | Đã gặp trên Sunsama (EC-01) | Ngữ cảnh thời gian bắt buộc; dùng hàm ngày làm việc QC-01; server kiểm ngày tuyệt đối; hỏi lại trong khung mơ hồ; bảng ví dụ QC-01 là ca chuẩn |
| Dữ liệu cá nhân gửi LLM | Nghị định 13/2023/NĐ-CP, GDPR; vùng lưu dữ liệu | Mặc định tắt, có màn đồng ý và lưu thời điểm đồng ý (Q21); gửi tối thiểu; hợp đồng không lưu, không huấn luyện; hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (Q29); cần pháp chế xác nhận |
| Lệnh ẩn trong dữ liệu (prompt injection) | Tiêu đề email / item Jira chứa câu lệnh | Dữ liệu tích hợp mặc định không vào ngữ cảnh; khi bật thì mọi hành động chờ duyệt (Q21); dữ liệu ngoài chỉ là dữ liệu; rào chắn kiểm ở server, không dựa vào model; nhóm đánh giá "lệnh ẩn" phải đạt 100% |
| Chi phí token | Agent đọc nhiều lịch, task, item | Hạn mức / ngày theo bảng quyền G12 (QC-10); cắt ngữ cảnh theo khoảng ngày cần |
| Phụ thuộc G08, G11, G05, G12 | Agent nối vào ritual và nút "Hoàn tác kế hoạch AI" ở bước Daily plan (G08); tạo task từ item qua G11; highlights đọc hoạt động công cụ; hạn mức ở bảng quyền G12 | Hợp đồng API giữa nhóm; thiếu nguồn thì agent vẫn chạy với dữ liệu có |
| Agent áp dụng sai nhiều task | Mất niềm tin | Mọi thay đổi hiện trong Review Plan; "Hoàn tác kế hoạch AI" một chạm; chờ duyệt khi có dữ liệu tích hợp; tín hiệu hoàn tác theo dõi hằng tuần |

# 10. Câu hỏi mở

- Mốc đầu ngày 04:00 hay 00:00? — Đã chốt 04/11/2026: mặc định 04:00, chỉnh trong 00:00–06:00; AI hiểu "hôm nay / ngày mai" theo hàm ngày làm việc QC-01, bảng ví dụ QC-01 là ca chuẩn (Q2, C33).
- Planning Agent chờ duyệt rồi mới áp dụng hay áp dụng ngay rồi Undo all như Sunsama? — Đã chốt 04/11/2026: áp dụng ngay kèm "Hoàn tác kế hoạch AI"; kế hoạch có dùng dữ liệu tích hợp thì chờ duyệt; chat áp dụng ngay khi ≤ 3 task và không có dữ liệu ngoài (Q31/Q31a).
- Sunny có được đánh dấu xong task không, hay chỉ người dùng? — Đã chốt 04/11/2026: AI không được đánh dấu xong; chỉ tạo task, dời ngày, timebox, ước lượng (Q20, ADR-0003).
- Chọn nhà cung cấp LLM nào; dữ liệu có cần xử lý / lưu tại Việt Nam không? — Một phần đã chốt 04/11/2026: không bắt buộc lưu tại Việt Nam, cần hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài, pháp chế xác nhận trước khi phát hành (Q29). Còn mở: chọn nhà cung cấp LLM.
- Hạn mức chat và số lần chạy agent có khác theo gói không (G12)? — Đã chốt 04/11/2026: hạn mức tách riêng chat / agent / highlights, đặt trong bảng quyền theo gói của G12; lượt lỗi không trừ (C32, QC-10). Con số vẫn là giả định trong QC-10.
- Có cần đồng ý trước khi gửi dữ liệu cho AI không? — Đã chốt 04/11/2026: trợ lý AI mặc định tắt, có màn đồng ý và lưu thời điểm đồng ý; dữ liệu tích hợp có công tắc riêng (Q21).
- Lịch sử chat giữ 90 ngày có đủ không; có cho tắt lưu lịch sử?
- Phản hồi có "Đính kèm cuộc trò chuyện" giữ bao lâu?
- Highlights chia sẻ có gồm task trong channel private không (Privacy, G12)?
- Highlights có chỉ được chứa link nội bộ (task, item đã liên kết) để chặn link lạ do dữ liệu ngoài đưa vào không?
- Sự kiện lịch do người khác mời (G05) có tính là "dữ liệu ngoài" phải chờ duyệt như dữ liệu tích hợp không?
- Nháp highlights có theo Lịch làm việc (QC-02) thay cho T2–T6 17:00 cố định không?
- Bật lại trợ lý sau khi tắt, hoặc khi nội dung màn đồng ý thay đổi, có phải đồng ý lại không?
- Gợi ý thời lượng / channel của G02 (bản 1.0) có gọi nhà cung cấp AI không; nếu có thì có cần cùng màn đồng ý không?
- Khi nào Planning Agent bỏ nhãn Beta; tiêu chí nào?
- Quản trị workspace có được tắt AI cho cả workspace không?
