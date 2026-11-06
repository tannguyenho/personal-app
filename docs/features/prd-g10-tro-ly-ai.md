> **Mã:** PLN-PRD-G10 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **SRS:** srs-g10-tro-ly-ai.md

# PRD Trợ lý AI qua Claude Code trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Con số đánh dấu `[giả định]` dùng để dựng flow, cần PO xác nhận trước khi dùng. Hành vi tham chiếu đã kiểm chứng trên Sunsama ngày 04/11/2026: khung chat Sunny ("Describe a task or ask a question", History, New chat, "Thought 8s", chip task + Undo → chip gạch "Undone"), luồng Planning Agent ("Plan my day" → Review Plan "The planning agent added 1 task" → Next → Daily plan → Get started), nhật ký "Sunsama Planning Agent created this", và lỗi EC-01 (lúc 02:10 ngày 4/11 yêu cầu tạo task "ngày mai" → Sunny tạo vào 4/11, không hiện ngày cụ thể để người dùng phát hiện). Chỗ khác Sunsama có chủ đích được ghi rõ.
>
> **Cập nhật 04/11/2026** theo [quyết định chốt mâu thuẫn](../review/quyet-dinh-chot-2026-11-04.md) (Q2, Q8, Q14, Q20, Q21, Q31/Q31a, B14, C30–C33) và [ADR-0003](../adr/0003-gioi-han-quyen-cua-tro-ly-ai.md).
>
> **Cập nhật vòng 5–6 (04/11/2026)** theo Q33, Q35, Q39, Q45, Q46, [ADR-0004](../adr/0004-ai-qua-claude-code-cli.md) (thay một phần ADR-0003, Q20, Q31, C32) và [ADR-0005](../adr/0005-nen-tang-windows-truoc.md): trợ lý AI chạy bằng **Claude Code CLI** do người dùng cài và đăng nhập trên máy; app mở **MCP local** để Claude Code đọc và điều khiển app; phát hành **1.0** trên app Windows; bỏ hạn mức AI theo gói. Quy tắc dùng chung (ngày làm việc QC-01, lịch làm việc QC-02, đổi ngày task QC-05, chế độ chỉ đọc QC-09, quyền theo gói QC-10, **trợ lý AI qua Claude Code và MCP local QC-12**) xem [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); PRD này chỉ tham chiếu, không định nghĩa lại. Chi tiết kỹ thuật (cách gọi CLI, kiểu kết nối MCP, schema công cụ): tech chốt — [`docs/tech/01-quyet-dinh-tech-stack-va-api.md`](../tech/01-quyet-dinh-tech-stack-va-api.md) mục 4.
>
> **Cập nhật 06/11/2026** theo F4 ([quyết định 06/11](../review/quyet-dinh-chot-2026-11-06.md)): bỏ công tắc "Cho phép AI hoàn thành và xoá task"; khi trợ lý bật, AI luôn được hoàn thành và xoá task (vào Thùng rác, có Hoàn tác); task có liên kết tích hợp vẫn không bao giờ được AI hoàn thành hay xoá.

# 1. Bối cảnh và vấn đề

## 1.1 Bối cảnh

Bản 1.0 là app Windows (Flutter) cho một người dùng (Q35, Q45, ADR-0005). Trợ lý AI có ngay từ 1.0 và chạy bằng **Claude Code CLI** mà người dùng tự cài và đăng nhập bằng tài khoản Claude của họ (Q46, ADR-0004, QC-12). App phát hiện Claude Code trên máy và dùng nó cho bốn chỗ tốn công nhất của vòng lặp ngày:

- lập kế hoạch buổi sáng (Planning Agent);
- thao tác nhanh trong ngày bằng ngôn ngữ tự nhiên (khung chat trợ lý, giao diện như chat thường);
- soạn highlights cuối ngày (Q39);
- gợi ý thời lượng và channel khi tạo task (G02 sở hữu trải nghiệm, G10 cung cấp lời gọi AI, Q33).

App mở một **MCP server local** trên máy để Claude Code đọc và điều khiển app. Claude Code có thể do app gọi (chat, Planning Agent, highlights, gợi ý) hoặc do người dùng tự mở trong terminal; cả hai đi qua cùng bộ công cụ và cùng rào chắn. App không tự gọi LLM nào khác, không gánh chi phí AI và không đặt hạn mức AI theo gói (QC-10, QC-12 mục 8).

Nhóm G10 lo các tính năng trên cùng việc phát hiện Claude Code, MCP local, rào chắn, bước đồng ý dùng AI và bộ đánh giá chất lượng dùng chung. Trợ lý AI mặc định tắt cho tới khi người dùng đồng ý (Q21). Không có Claude Code thì mọi tính năng AI bị ẩn, thay bằng hướng dẫn cài; mọi chức năng lõi vẫn chạy đủ. Chế độ chỉ đọc (QC-09) có từ 1.1 và áp dụng cho AI từ lúc đó. Daily planning / Daily shutdown thủ công (G08), task (G02), timebox (G05) và nguồn dữ liệu từ công cụ ngoài (G11, 1.1) nằm ở nhóm riêng; AI chỉ đọc / ghi qua đúng các thao tác mà người dùng có.

## 1.2 Vấn đề

| **Vấn đề** | **Hệ quả** |
|---|---|
| Daily planning thủ công mất 10–15 phút `[giả định]` khi có 6–8 cuộc họp và việc rải ở Jira, Notion, Gmail | Người dùng bỏ ritual, ngày không có kế hoạch |
| Thao tác nhiều task (dời, sắp lại, chia nhỏ) phải làm từng cái | Ngại sắp lại kế hoạch khi ngày thay đổi |
| AI hiểu sai ngày tương đối ("ngày mai" lúc 02:10 — EC-01) và không cho thấy ngày cụ thể | Task rơi vào ngày sai, người dùng không phát hiện |
| AI sửa nhiều task một lúc mà không nhìn thấy được hoặc không hoàn tác được trọn | Mất kiểm soát kế hoạch, mất niềm tin vào AI |
| Dữ liệu cá nhân và nội dung từ công cụ ngoài được đưa cho AI khi người dùng chưa đồng ý; lệnh ẩn trong email / issue điều khiển AI | Vi phạm NĐ 13/2023; AI làm thay đổi người dùng không muốn |
| Viết highlights cuối ngày từ đầu tốn thời gian | Bỏ bước highlights, Weekly review (G09) thiếu dữ liệu |
| AI lỗi, chậm hoặc hết hạn mức làm kẹt ritual | Người dùng không lập được kế hoạch đúng lúc cần nhất |
| App tự vận hành LLM thì gánh chi phí token và phải chia hạn mức theo gói | AI ra muộn (bản nháp cũ để 1.2), bị giới hạn lượt dùng |
| Người dùng đã quen Claude Code phải chuyển qua lại giữa terminal và app | Không tận dụng được công cụ AI mình đang trả tiền |

## 1.3 Mục tiêu

- Lập kế hoạch ngày với Planning Agent trong ≤ 5 phút kể cả thời gian duyệt; agent chạy 2–4 phút.
- Mọi thay đổi do AI làm (kể cả từ Claude Code trong terminal) đều nhìn thấy được (chip "AI"), ghi tác nhân AI và hoàn tác được; cả lượt AI hoàn tác được bằng một nút ("Hoàn tác kế hoạch AI" với Planning Agent, "Hoàn tác tất cả" với chat và phiên terminal) (QC-12 mục 5).
- Không có lời gọi Claude Code nào và MCP local không nhận kết nối trước khi người dùng đồng ý (Q21). AI được hoàn thành và xoá task / subtask (xoá vào Thùng rác, có Hoàn tác), không cần công tắc riêng, và không bao giờ hoàn thành hay xoá task có liên kết tích hợp (QC-12 mục 4, F4, D10).
- Mọi ngày giờ AI dùng hiện ở dạng cụ thể ("Thứ Năm, 5/11") trước hoặc ngay khi áp dụng; không lặp lại EC-01.
- Kết quả đầu tiên (chữ trả lời hoặc bước tiến độ) hiện ≤ 10 giây; AI lỗi, Claude Code bị đóng hoặc hết hạn mức Claude thì người dùng vẫn đi tiếp bằng luồng thủ công (EC-39).
- Không có Claude Code thì mọi chức năng lõi vẫn chạy đủ; người dùng thấy hướng dẫn cài thay cho tính năng AI (QC-12 mục 2).
- Bộ đánh giá ≥ 200 câu Việt / Anh đạt ≥ 95% trước mỗi lần đổi prompt, bộ công cụ MCP hoặc phiên bản Claude Code tối thiểu được hỗ trợ.

# 2. Người dùng

| **Nhóm** | **Nhu cầu chính** |
|---|---|
| Linh — PM, 6–8 cuộc họp / ngày, việc ở Jira + Notion + Gmail | Agent gom việc từ các nguồn, xếp vào khe trống giữa các cuộc họp |
| Minh — designer / dev | Giữ khối thời gian dài cho việc sâu; nói "dời hết việc lặt vặt sang chiều" là xong |
| Hà — freelancer / founder, nhiều khách hàng | Không nhận quá sức; AI cảnh báo khi kế hoạch vượt sức chứa của ngày (G04, Q48) |
| Người dùng thận trọng với AI | AI chỉ chạy khi mình đã đồng ý; biết rõ dữ liệu nào được đưa cho Claude Code; email / issue không đưa cho AI nếu mình không bật; AI xoá task chỉ vào Thùng rác, không xoá vĩnh viễn; hoàn tác từng phần hoặc cả lượt, tắt AI khi muốn |
| Người dùng đã dùng Claude Code (dev, PM kỹ thuật) | Mở Claude Code trong terminal là sắp được kế hoạch ngày trong app; app vẫn ghi lại và hoàn tác được mọi thay đổi |
| Người dùng không có Claude Code | App vẫn dùng đủ chức năng lõi; biết cách cài nếu muốn có trợ lý AI |
| Người dùng song ngữ Việt / Anh | Gõ tiếng Việt hay tiếng Anh đều được hiểu, trả lời đúng ngôn ngữ đã gõ |

# 3. Phạm vi

## 3.1 Trong phạm vi (bản 1.0)

- Nền tảng: app Windows (Flutter) (Q45, ADR-0005). Cách cung cấp AI trên web, macOS (1.1) và iOS / Android (1.2): tech chốt (ADR-0004, câu hỏi mở mục 10).
- Phát hiện Claude Code trên máy: đã cài chưa, đã đăng nhập chưa, phiên bản có được hỗ trợ không; không sẵn sàng thì ẩn tính năng AI và hiện hướng dẫn cài (QC-12 mục 2).
- MCP server local: bộ công cụ đọc / ghi để Claude Code (do app gọi hoặc người dùng mở trong terminal) điều khiển app, cùng rào chắn (QC-12 mục 3–6).
- Đồng ý dùng AI lần đầu: trợ lý AI mặc định tắt; lần đầu bật phải qua màn đồng ý gọn, nói rõ dữ liệu nào được đưa cho Claude Code; app lưu thời điểm đồng ý (Q21, QC-12 mục 7).
- Planning Agent (Beta "Agentic Daily Planning"): thiết lập 1 lần, "Plan my day", kế hoạch áp dụng ngay rồi hiện Review Plan (Re-plan, "Hoàn tác kế hoạch AI", Submit feedback), nối vào bước Daily plan của G08; kế hoạch dùng dữ liệu tích hợp thì chờ duyệt (Q31/Q31a, QC-12 mục 6).
- Khung chat trợ lý (nút ✨ góc dưới), giao diện như chat thường: hỏi đáp về kế hoạch, ra lệnh tạo / sửa / dời / sắp / timebox task, Lịch sử, Cuộc trò chuyện mới (Q39).
- Điều khiển app từ Claude Code trong terminal riêng khi app đang mở: cùng công cụ, cùng rào chắn, cùng chip AI và Hoàn tác (QC-12 mục 3).
- Highlights AI cuối ngày: nháp tự động tại giờ kết thúc của lịch chung vào các ngày có trong lịch làm việc; app không mở lúc đó thì soạn khi mở app lần kế tiếp trong ngày (Q39, D7, QC-02), từ task đã xong và (khi người dùng bật) hoạt động trên công cụ đã kết nối; người dùng duyệt trước khi lưu.
- Gợi ý thời lượng và channel khi tạo task qua Claude Code (Q33): G02 sở hữu trải nghiệm, G10 cung cấp lời gọi AI.
- Rào chắn: AI hoàn thành / xoá task không cần công tắc (F4), xoá chỉ vào Thùng rác; task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá (D10); mọi thay đổi áp dụng ngay kèm chip AI, nhật ký và Hoàn tác; công cụ đọc dữ liệu tích hợp mặc định tắt, khi đã đọc thì các thay đổi sau lần đọc đầu tiên trong phiên đó chờ duyệt (QC-12 mục 4–6, D8).
- Nhóm cài đặt AI và Beta trong trang Cài đặt, gồm trạng thái Claude Code, hướng dẫn dùng trong terminal và các công tắc riêng.
- Bộ đánh giá chất lượng AI và thu tín hiệu (Submit feedback, Hoàn tác).

## 3.2 Ngoài phạm vi

- Trải nghiệm gợi ý thời lượng và channel khi tạo task (ô nhập, biểu tượng ✨, nguồn `ai` / `user`) → G02; G10 chỉ cung cấp lời gọi AI (Q33).
- Daily planning / Daily shutdown thủ công, chia sẻ kế hoạch → G08. Weekly planning / review → G09.
- Kết nối và đọc dữ liệu công cụ ngoài → G11 (1.1); lịch → G05.
- Cài đặt, đăng nhập, cập nhật Claude Code và gói Claude của người dùng → người dùng tự làm theo hướng dẫn của Anthropic; app chỉ phát hiện và hướng dẫn.
- App tự gọi LLM khác, hạn mức AI theo gói → không làm (Q33, Q46, QC-10).
- AI gửi tin ra ngoài (email, Slack, Teams), đổi cài đặt, kết nối / ngắt tích hợp, xoá vĩnh viễn → không làm, ở mọi phiên bản (ADR-0003, QC-12). AI hoàn thành / xoá task (vào Thùng rác) không cần công tắc (QC-12 mục 4, F4).
- Agent tự chạy nền không có người dùng (tự lập kế hoạch lúc 06:00) → bản sau.
- Nhập bằng giọng nói → bản sau `[giả định]`.
- AI cho workspace nhiều người (lập kế hoạch nhóm, tóm tắt cho quản lý) → bản sau (Q35, `docs/02-tinh-nang-ban-sau.md`).

# 4. Nguyên tắc sản phẩm

## 4.1 AI làm ngay, người dùng luôn hoàn tác được

AI chỉ hành động khi người dùng đã bật trợ lý AI và đồng ý (Q21), và chỉ qua công cụ MCP của app (QC-12 mục 3). Mọi thay đổi qua MCP được áp dụng ngay, gắn chip "AI" trên task, ghi nhật ký và có Hoàn tác từng thay đổi lẫn cả lượt ("Hoàn tác kế hoạch AI" với Planning Agent, "Hoàn tác tất cả" với chat và phiên terminal) (QC-12 mục 5, Q46). Ngoại lệ duy nhất: phiên AI đã đọc dữ liệu tích hợp thì thay đổi chờ duyệt trong app (mục 4.5). Mặc định AI không hoàn thành, không xoá task; người dùng bật được công tắc riêng, trừ task có liên kết tích hợp (QC-12 mục 4).

## 4.2 Rõ ngày, rõ giờ

AI luôn biết ngày giờ, timezone và ngày làm việc hiện tại; "hôm nay / ngày mai" hiểu theo ngày làm việc (QC-01); mọi ngày trong kết quả hiện dạng cụ thể. Khi người dùng nói "ngày mai" trong khoảng từ 00:00 tới mốc đầu ngày (ngày lịch đã sang nhưng ngày làm việc chưa sang), AI hỏi lại thay vì đoán (EC-01).

## 4.3 Không có hành động AI mất trắng

Mọi hành động AI ghi nhật ký với tác nhân AI và hoàn tác được. Hoàn tác chỉ trả lại phần AI đã làm, không xoá công sửa của người dùng (EC-38).

## 4.4 AI hỏng, ngày vẫn chạy

AI lỗi, chậm quá 10 giây trong ritual, Claude Code bị đóng giữa chừng hoặc hết hạn mức Claude thì chuyển luồng thủ công, giữ nguyên những gì người dùng đã nhập (EC-39). Mọi chức năng cốt lõi không phụ thuộc AI; máy không có Claude Code vẫn dùng đủ app (QC-12 mục 2).

## 4.5 Dữ liệu ngoài chỉ là dữ liệu

Dữ liệu từ công cụ tích hợp (tiêu đề email, issue, trang Notion) chỉ đưa cho Claude Code qua công cụ MCP đọc dữ liệu tích hợp, mặc định tắt; người dùng bật bằng công tắc riêng. Khi một phiên AI đã đọc dữ liệu đó, mọi thay đổi **sau** lần đọc đầu tiên trong phiên chuyển thành chờ duyệt trong app thay vì áp dụng ngay, để chặn lệnh ẩn trong nội dung bên ngoài; thay đổi đã áp dụng trước lần đọc đó giữ nguyên (Q21, QC-12 mục 6, D8).

## 4.6 Dùng Claude Code của chính người dùng

App không vận hành LLM, không gửi dữ liệu cho nhà cung cấp AI nào. Claude Code chạy trên máy người dùng, dùng tài khoản và hạn mức của gói Claude của chính họ; app không đếm lượt, không đặt hạn mức AI theo gói (QC-10, QC-12 mục 8). Hết hạn mức phía Claude thì app hiện đúng thông báo của Claude Code và chuyển luồng thủ công (EC-39).

# 5. Quy tắc hành vi AI

| **Quy tắc** | **Giá trị / giới hạn** | **Mặc định** | **Ghi chú** |
|---|---|---|---|
| Bộ não AI | Claude Code CLI do người dùng cài và đăng nhập trên máy; app không gọi LLM nào khác | — | QC-12 mục 1, Q33, Q46, ADR-0004 |
| Claude Code sẵn sàng | Đã cài, đã đăng nhập, phiên bản ≥ phiên bản tối thiểu được hỗ trợ `[giả định — tech chốt con số]` | — | Không sẵn sàng → ẩn tính năng AI, hiện hướng dẫn cài; chức năng lõi vẫn đủ (QC-12 mục 2) |
| Đồng ý dùng AI | Lần đầu bật trợ lý AI phải qua màn đồng ý gọn, nói rõ dữ liệu nào được đưa cho Claude Code; lưu thời điểm đồng ý | Tắt | Trước khi đồng ý: app không gọi Claude Code, MCP local không nhận kết nối, kể cả nháp highlights (Q21, QC-12 mục 7) |
| MCP local | Chỉ nhận kết nối từ chính máy đó, khi trợ lý bật và đã đồng ý; tắt trợ lý → ngừng nhận kết nối | Tắt (theo trợ lý) | QC-12 mục 3, 7; cách kết nối và xác thực: tech chốt |
| Công cụ ghi mặc định | Tạo task, sửa tiêu đề / ghi chú / planned / channel, dời ngày, đưa vào backlog, timebox / gỡ timebox (QC-12 mục 3); thêm subtask, sắp thứ tự, priority, gắn objective `[giả định — chưa có trong QC-12 mục 3]` | Bật (khi trợ lý bật) | Kiểm tại MCP server của app, không phụ thuộc model. Dời ngày theo QC-05 dòng "AI dời ngày" (Q14). Danh sách đầy đủ: SRS mục 3.1 |
| Hoàn thành và xoá task | Không có công tắc (F4): trợ lý bật thì MCP luôn có công cụ hoàn thành task và xoá task (vào Thùng rác) | Luôn có | Áp cho cả subtask. Task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá (QC-12 mục 4, Q46, F4, D10; thay một phần Q20 / ADR-0003) |
| Luôn bị cấm | Gửi tin ra ngoài, đổi cài đặt (kể cả cài đặt AI), kết nối / ngắt tích hợp, xoá vĩnh viễn / dọn Thùng rác, xuất dữ liệu, thao tác tài khoản | — | Không có công cụ MCP tương ứng; yêu cầu loại này → trợ lý từ chối và chỉ cách người dùng tự làm |
| Đọc dữ liệu tích hợp | Công cụ MCP đọc item và hoạt động từ công cụ G11 (1.1) | Tắt | Công tắc riêng; tắt thì AI không đọc item, highlights không dùng hoạt động công cụ (Q21, QC-12 mục 6) |
| Áp dụng ngay hay chờ duyệt | Mọi thay đổi qua MCP áp dụng ngay, kèm chip "AI", nhật ký, Hoàn tác từng thay đổi và cả lượt. Phiên AI đã đọc dữ liệu tích hợp → chỉ các thay đổi sau lần đọc đầu tiên trong phiên chờ duyệt trong app; thay đổi trước đó giữ nguyên | — | QC-12 mục 5–6, Q46, D8 (thay ngưỡng "> 3 task" của Q31a). Lượt chạm > 3 task: câu trả lời nổi bật "Hoàn tác tất cả" (EC-37) |
| Ngữ cảnh thời gian | Ngày giờ hiện tại có offset, timezone, mốc đầu ngày, ngày làm việc hiện tại (QC-01), lịch làm việc và khung giờ channel (QC-02) | Bắt buộc | App đưa vào mỗi lượt do app gọi; phiên terminal đọc qua công cụ MCP. Thiếu thì không gọi Claude Code (EC-01) |
| "Hôm nay / ngày mai" | Theo hàm ngày làm việc (QC-01); hỏi lại khi người dùng nói "ngày mai" lúc ngày lịch đã sang mà ngày làm việc chưa sang | Hỏi lại bằng 2 lựa chọn ngày cụ thể | Q2, C33; bảng ví dụ QC-01 là ca chuẩn của bộ đánh giá |
| Thay đổi chờ duyệt | Hết hạn ở cuối ngày làm việc; áp dụng có kiểm phiên bản, chỉ loại dòng lỗi thời, không áp dụng giờ đã qua | — | C31 |
| Kết quả đầu tiên | ≤ 10 giây `[giả định]` | — | Có trạng thái "đang xử lý" ("Đã nghĩ 8s") |
| Planning Agent | Chạy 2–4 phút; tối đa 5 phút `[giả định]`; không giới hạn số lượt phía app | — | Lỗi / > 10 giây chưa có bước đầu / Claude Code bị đóng / hết hạn mức Claude → luồng thủ công (EC-39) |
| Thời hạn hoàn tác | 7 ngày sau khi áp dụng `[giả định]` | — | Sau đó chip không còn nút Hoàn tác |
| Hạn mức | (Bỏ — không còn hạn mức AI theo gói, QC-10, QC-12 mục 8, Q46; thay C32) | — | Hết hạn mức phía Claude Code → hiện thông báo của Claude Code, chuyển luồng thủ công (EC-39) |
| Tin nhắn chat | 1–2.000 ký tự `[giả định]` | — | Không giới hạn số tin phía app |
| Lịch sử chat | App giữ 90 ngày `[giả định]` | — | Người dùng xoá được từng cuộc trò chuyện; ngắt tích hợp thì xoá dữ liệu của tích hợp đó trong lịch sử AI của app (C30). Bản ghi phiên do Claude Code tự lưu trên máy nằm ngoài kiểm soát của app (màn đồng ý nói rõ) |
| Ngôn ngữ | Chat: ngôn ngữ tin nhắn người dùng. Highlights: cài đặt "Ngôn ngữ tóm tắt" | Auto | Auto = ngôn ngữ giao diện `[giả định]` |
| Nháp highlights | Các ngày có trong lịch làm việc (lịch chung, QC-02), tại giờ kết thúc của lịch chung ngày đó (không theo giờ Daily shutdown đã đổi), theo timezone người dùng | Bật ("Tóm tắt tự động"), chỉ chạy khi trợ lý AI đã bật, đã đồng ý và Claude Code sẵn sàng | Q39, D7. App không mở tại thời điểm đó → soạn khi người dùng mở app lần kế tiếp trong ngày. Không lưu tới khi người dùng duyệt |
| Chế độ chỉ đọc | Không gọi Claude Code, kể cả nháp highlights; công cụ ghi MCP từ chối | — | QC-09 (có từ 1.1, Q8) |
| Bộ đánh giá | ≥ 200 câu Việt / Anh; ≥ 95% đúng `[giả định]`; nhóm rào chắn, ngày giờ và lệnh ẩn trong dữ liệu 100% | — | Chạy trước mỗi lần đổi prompt, bộ công cụ MCP hoặc phiên bản Claude Code tối thiểu được hỗ trợ (Q21) |

- Các giá trị là **cấu hình hệ thống**, không cố định trong code.
- Dữ liệu đưa cho Claude Code: tối thiểu cho yêu cầu đang xử lý, chỉ qua công cụ MCP, chỉ sau khi người dùng đồng ý. Claude Code xử lý dữ liệu theo điều khoản tài khoản Claude của chính người dùng; app không gửi dữ liệu cho nhà cung cấp AI nào. Ảnh hưởng tới hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (NĐ 13/2023, Q29): pháp chế xác nhận trước khi phát hành (mục 10).

# 6. Luồng trải nghiệm tổng thể

| **Bước** | **Giai đoạn** | **Trải nghiệm** | **Đầu ra** |
|---|---|---|---|
| 0 | Chuẩn bị | Người dùng tự cài Claude Code và đăng nhập tài khoản Claude; app phát hiện Claude Code (hoặc hiện hướng dẫn cài khi chưa có) | Trạng thái Claude Code "Sẵn sàng" |
| 1 | Bật và thiết lập | Bật trợ lý AI qua màn đồng ý (lần đầu); bật Beta "Agentic Daily Planning"; kết nối công cụ (G05, G11), chọn có cho AI đọc dữ liệu công cụ không, "Tell me about yourself", theme days | Thời điểm đồng ý; MCP local mở; hồ sơ agent |
| 2 | Lập kế hoạch sáng | Mở Daily planning (G08) → gõ điều quan trọng hôm nay → "Plan my day" → kế hoạch áp dụng ngay, Review Plan hiện các thay đổi kèm "Hoàn tác kế hoạch AI" → Next (kế hoạch có dữ liệu tích hợp: duyệt rồi mới áp dụng) | Kế hoạch ngày được áp dụng, sang bước Daily plan (G08) |
| 3 | Trong ngày | Bấm ✨ mở khung chat: hỏi "chiều nay còn trống bao lâu?", ra lệnh "dời 3 việc review sang mai". Hoặc mở Claude Code trong terminal và ra lệnh tương tự | Task được tạo / dời / sắp, có chip "AI" và Hoàn tác |
| 4 | Cuối ngày | Tại giờ kết thúc của lịch chung (ngày có trong lịch làm việc; app không mở thì khi mở app lần kế tiếp trong ngày, D7) có nháp highlights (chỉ khi đã đồng ý); mở Daily shutdown (G08) → duyệt / sửa → lưu | Highlights của ngày |
| 5 | Sửa sai | Hoàn tác từng thay đổi, cả lượt chat / phiên terminal, hoặc "Hoàn tác kế hoạch AI"; Submit feedback | Kế hoạch đúng ý; tín hiệu chất lượng |
| 6 | Kiểm soát chất lượng (nội bộ) | Chạy bộ đánh giá trước khi đổi prompt, bộ công cụ MCP hoặc phiên bản Claude Code tối thiểu | Bản phát hành AI đạt ngưỡng |

Bước 2 và 4 chạy bên trong ritual của G08; PRD này chỉ mô tả phần AI. PRD tập trung bước 0–6 trừ phần thủ công của ritual.

# 7. Use Cases, User Stories và Acceptance Criteria

## UC1. Lập kế hoạch ngày với Planning Agent

### US1.1 Thiết lập agent lần đầu

AC01: Lần đầu bấm "Plan my day" khi chưa thiết lập → mở màn thiết lập 3 phần: kết nối công cụ (trỏ G05, G11) kèm công tắc "Cho AI đọc dữ liệu từ công cụ đã kết nối" (mặc định tắt, US6.2), "Kể về bạn" (vai trò, giờ làm việc ưa thích, việc cần tránh), theme days (mỗi thứ trong tuần một chủ đề tuỳ chọn).

AC02: Phần nào cũng bỏ qua được; sửa lại sau trong Cài đặt → Trợ lý AI.

AC03: Chỉ hiện khi bật Beta "Agentic Daily Planning".

AC04: Trợ lý AI chưa bật hoặc chưa có đồng ý → bấm "Plan my day" mở màn đồng ý (US6.1) trước màn thiết lập; người dùng không đồng ý thì không chạy agent và không có lời gọi Claude Code nào.

AC05: Claude Code chưa sẵn sàng (chưa cài, chưa đăng nhập, phiên bản cũ) → nút "Plan my day" không hiện; chỗ đó hiện hướng dẫn "Cài Claude Code để bật trợ lý AI" (US7.1). Daily planning thủ công vẫn đủ.

### US1.2 Cho agent lập kế hoạch

User Story: Là Linh, tôi muốn nói điều quan trọng hôm nay rồi để agent xếp ngày quanh các cuộc họp, để không mất 15 phút kéo thả mỗi sáng.

AC01: Trong Daily planning (G08) có ô "Điều quan trọng nhất hôm nay là gì?" và nút "Plan my day".

AC02: Khi chạy, màn hình hiện các bước tiến độ (đọc lịch, đọc việc từ công cụ, xếp khối thời gian); bước đầu tiên hiện ≤ 10 giây.

AC03: Agent chỉ dùng công cụ MCP đang bật (mục 5); agent được hoàn thành / xoá task (vào Thùng rác) nhưng không bao giờ hoàn thành hay xoá task có liên kết tích hợp (QC-12 mục 4, F4). Task tạo từ issue / email / trang Notion đi qua cơ chế "một item, một task" của G11 (B14), không sinh task trùng.

AC04: Mỗi thay đổi áp dụng ngay khi agent gọi công cụ (QC-12 mục 5); chạy xong (2–4 phút) → Review Plan. Agent đã đọc dữ liệu tích hợp → chỉ các thay đổi sau lần đọc đầu tiên chờ duyệt, Review Plan ở chế độ chờ duyệt cho phần đó; thay đổi trước đó giữ nguyên (Q31a, QC-12 mục 6, D8).

AC05: Agent chỉ đọc item từ công cụ tích hợp khi người dùng đã bật "Cho AI đọc dữ liệu từ công cụ đã kết nối" (Q21, QC-12 mục 6).

### US1.3 Duyệt kế hoạch (Review Plan)

AC01: Review Plan hiện câu tóm tắt ("Planning Agent đã thêm 3 task, dời 2 task") và danh sách "HÔM NAY · n thay đổi"; mỗi dòng có nhãn loại thay đổi và ngày giờ cụ thể.

AC02: Kế hoạch không dùng dữ liệu tích hợp đã được áp dụng khi Review Plan mở (như Sunsama; Q31, QC-12 mục 5). Mỗi dòng có "Hoàn tác" riêng; nút "Hoàn tác kế hoạch AI" (Undo all) trả lại toàn bộ kế hoạch theo quy tắc hoàn tác US4.1. Task agent đổi có chip "AI".

AC03: Kế hoạch có dùng dữ liệu tích hợp → Review Plan ở chế độ chờ duyệt cho các thay đổi sau lần đọc dữ liệu đó: nhãn "Cần bạn duyệt vì kế hoạch dùng dữ liệu từ {công cụ}", bỏ chọn từng dòng để không áp dụng dòng đó, "Áp dụng và tiếp" mới áp dụng (Q31a, Q21, QC-12 mục 6).

AC04: "Lập lại" (Re-plan) cho nhập thêm chỉ dẫn, hoàn tác kế hoạch hiện tại rồi chạy lại; "Hoàn tác kế hoạch AI" (đã áp dụng) hoặc "Huỷ tất cả" (chờ duyệt) bỏ toàn bộ kế hoạch và về Daily planning thủ công; "Gửi phản hồi" mở form phản hồi.

AC05: Sau "Tiếp" đi tới bước Daily plan (G08); task do agent tạo có nhật ký "Planning Agent đã tạo task này". Bước Daily plan có nút "Hoàn tác kế hoạch AI" (G08 đặt nút, G10 xử lý) dùng được trong thời hạn hoàn tác.

AC06: Một dòng không áp dụng được vì task vừa đổi ở nơi khác hoặc giờ đã qua → chỉ dòng đó bị loại, các dòng khác vẫn áp dụng; Review Plan báo số dòng bị loại (C31). Kế hoạch chờ duyệt chưa áp dụng tới cuối ngày làm việc → tự hết hạn (C31).

### US1.4 Agent lỗi thì vẫn lập được kế hoạch

AC01: Claude Code lỗi, bị đóng giữa chừng, hết hạn mức Claude, hoặc > 10 giây chưa có bước đầu tiên → thông báo (hết hạn mức: hiện đúng thông báo của Claude Code) và chuyển sang luồng Daily planning thủ công (G08) ở bước 1 (EC-39).

AC02: Nội dung ô "Điều quan trọng nhất" được giữ, đưa vào ô "Obstacles / ghi chú" của bản kế hoạch.

AC03: Agent lỗi giữa chừng → các thay đổi đã áp dụng trước đó trong lượt được giữ, thông báo nêu số thay đổi đã áp dụng kèm "Hoàn tác kế hoạch AI" để hoàn tác cả lượt (D9); thay đổi đang chờ duyệt của lượt bị huỷ.

## UC2. Trò chuyện với trợ lý AI

### US2.1 Hỏi về kế hoạch

AC01: Nút ✨ "Trợ lý" ở cụm dưới sidebar (hoặc Ctrl+J) mở khung chat ở panel phải (IA-08), giao diện như chat thường (Q39); ô nhập "Mô tả một task hoặc đặt câu hỏi"; có "Lịch sử" và "Cuộc trò chuyện mới". Câu trả lời đến từ Claude Code do app gọi. Tên hiển thị của trợ lý chưa đặt, quyết định khi làm thiết kế Figma; không dùng "Sunny" (tên trợ lý của Sunsama) (D16).

AC02: Trong lúc xử lý hiện trạng thái "Đang nghĩ…", xong hiện thời gian đã nghĩ ("Đã nghĩ 8s").

AC03: Trả lời bằng ngôn ngữ người dùng đã gõ.

### US2.2 Ra lệnh thao tác task

User Story: Là Minh, tôi muốn gõ "dời các task review sang chiều mai" và thấy ngay kết quả, để không phải kéo từng task.

AC01: Hành động thực hiện xong hiện chip task trong câu trả lời: tiêu đề, ngày giờ cụ thể, nút "Hoàn tác". Task bị đổi có chip "AI" trên card (G02, G04).

AC02: Bấm "Hoàn tác" → chip gạch ngang "Đã hoàn tác"; task do AI tạo vào Thùng rác (G02).

AC03: Yêu cầu hành động không có công cụ (ví dụ "gửi kế hoạch cho sếp", "bật chế độ tối", "ngắt Jira"), hoặc hoàn thành / xoá task có liên kết tích hợp (D10) → trợ lý từ chối, nói cách tự làm (Ctrl+Backspace, tích ✓ / phím C, Chia sẻ trong G08, Cài đặt).

AC04: Yêu cầu dời ngày áp dụng như người dùng kéo task sang ngày khác (QC-05 dòng "AI dời ngày"): timebox giữ giờ và dời theo, timer không dừng, số ngày bị hoãn reset; không đặt task chưa xong vào ngày đã qua.

### US2.3 Ngày giờ tương đối luôn đúng

User Story: Là người dùng làm khuya, tôi muốn "ngày mai" được hiểu đúng hoặc được hỏi lại, để task không rơi vào ngày sai như EC-01.

AC01: Mọi lượt app gọi Claude Code có ngày giờ hiện tại, timezone, mốc đầu ngày và ngày làm việc hiện tại (QC-01); Claude Code mở từ terminal đọc được các giá trị này qua công cụ MCP "Xem ngữ cảnh thời gian".

AC02: Chip và câu trả lời luôn hiện ngày cụ thể ("Thứ Năm, 5/11"), không chỉ "ngày mai".

AC03: Từ 00:00 tới mốc đầu ngày (ngày lịch đã sang, ngày làm việc chưa sang), yêu cầu chứa "ngày mai / sáng mai" → trợ lý hỏi lại với 2 nút ngày cụ thể (ví dụ mốc 04:00, lúc 02:10 ngày 4/11: "Thứ Tư 4/11" / "Thứ Năm 5/11"); chưa tạo task tới khi người dùng chọn. Mốc đầu ngày là 00:00 thì không có khoảng này, không hỏi lại.

AC04: Ca kiểm chứng EC-01 và toàn bộ bảng ví dụ của QC-01 nằm trong bộ đánh giá và phải đạt (C33).

AC05: "Hôm nay / tối nay" = ngày làm việc hiện tại; "ngày mai / sáng mai" = ngày làm việc hiện tại + 1 (QC-01, Q2). Ví dụ mốc 04:00, lúc 02:10 ngày 4/11: ngày làm việc hiện tại là Thứ Ba 3/11, "hôm nay" = 3/11, không hỏi lại.

### US2.4 Thay đổi nhiều task và thay đổi chờ duyệt

AC01: (Bỏ — không còn ngưỡng "> 3 task phải duyệt trước"; mọi thay đổi qua MCP áp dụng ngay, xem QC-12 mục 5, Q46.)

AC02: Lượt chat không đọc dữ liệu tích hợp → mọi thay đổi áp dụng ngay, mỗi task một chip kèm Hoàn tác (QC-12 mục 5). Lượt chạm > 3 task → cuối câu trả lời có dòng tóm tắt "Đã thay đổi n task" và nút "Hoàn tác tất cả" (EC-37).

AC03: Lượt chat đã đọc dữ liệu từ công cụ tích hợp (người dùng đã bật công tắc, US6.2) → mọi thay đổi sau lần đọc đó vào thẻ chờ duyệt với danh sách trước / sau, "Áp dụng", "Huỷ", bỏ chọn từng dòng, kể cả khi chỉ 1 task; thẻ ghi rõ "Cần bạn duyệt vì yêu cầu dùng dữ liệu từ {công cụ}" (Q21, QC-12 mục 6).

AC04: Thẻ chưa duyệt tới cuối ngày làm việc → hết hạn, thẻ xám "Đã hết hạn". Khi bấm "Áp dụng", dòng có task vừa đổi ở nơi khác hoặc giờ đã qua bị loại, các dòng khác vẫn áp dụng (C31).

### US2.5 Xem lại cuộc trò chuyện

AC01: "Lịch sử" liệt kê cuộc trò chuyện mới nhất trước, giữ 90 ngày `[giả định]`; xoá được từng cuộc.

AC02: Chip trong cuộc cũ vẫn hoàn tác được trong 7 ngày `[giả định]`.

AC03: Người dùng ngắt một tích hợp (G11) → dữ liệu của tích hợp đó trong lịch sử AI của app (trích dẫn item, câu trả lời có dữ liệu item, nháp highlights) bị xoá; chỗ bị xoá hiện "Nội dung từ {công cụ} đã xoá khi ngắt kết nối" (C30). Bản ghi phiên do Claude Code tự lưu trên máy không thuộc phạm vi xoá của app.

## UC3. Highlights AI cuối ngày

### US3.1 Có sẵn nháp highlights

User Story: Là Hà, tôi muốn cuối ngày có sẵn bản tóm tắt việc đã làm, để chỉ cần sửa vài chữ rồi chia sẻ cho khách hàng.

AC01: Vào các ngày có trong lịch làm việc (lịch chung, QC-02), tại giờ kết thúc của lịch chung ngày đó (theo timezone; không theo giờ Daily shutdown người dùng đã đổi, D7), app gọi Claude Code soạn nháp từ task đã xong trong ngày làm việc và, khi người dùng bật "Cho AI đọc dữ liệu từ công cụ đã kết nối", hoạt động trên công cụ đã kết nối (G11); có biểu tượng ✨ (Q39). Ngày không có trong lịch làm việc → không tự soạn; người dùng vẫn bấm "Soạn bằng AI" được.

AC02: Nháp viết theo "Ngôn ngữ tóm tắt"; mỗi ý gắn link về task / item nguồn.

AC03: Ngày không có task xong → không soạn nháp.

AC04: Người dùng chưa đồng ý dùng AI, trợ lý AI đang tắt, hoặc Claude Code chưa sẵn sàng → không tự soạn, không có lời gọi Claude Code nào (Q21, QC-12 mục 2). Workspace chỉ đọc (1.1) → không soạn (QC-09).

AC06: App không mở trên máy nào tại giờ kết thúc của lịch chung → app soạn nháp khi người dùng mở app lần kế tiếp trong cùng ngày làm việc, nếu Claude Code sẵn sàng (D7); qua ngày mà chưa soạn thì không có nháp tự động, vẫn bấm "Soạn bằng AI" được. Một ngày chỉ có một nháp tự động dù người dùng có nhiều máy `[giả định]`.

AC05: Hoạt động công cụ chỉ tính việc do chính tài khoản đã kết nối thực hiện (ví dụ issue Hà tự chuyển sang Done), không tính việc đồng nghiệp làm; Gmail không có hoạt động "đóng" (C28).

### US3.2 Duyệt highlights trong Daily shutdown

AC01: Bước highlights của Daily shutdown (G08) hiện nháp AI; người dùng sửa, xoá ý, "Soạn lại".

AC02: Highlights chỉ lưu khi người dùng bấm tiếp / hoàn tất bước; trước đó chỉ là nháp.

AC03: Người dùng đã sửa nháp → task xong thêm sau đó không ghi đè; hiện "Có 2 việc mới xong · Thêm vào".

AC04: Tắt "Tóm tắt tự động" → không tự soạn tại giờ kết thúc của lịch chung; vẫn bấm "Soạn bằng AI" được trong bước highlights.

AC05: (Bỏ — không còn hạn mức AI theo gói, QC-12 mục 8, Q46.) Hết hạn mức phía Claude Code khi "Soạn lại" → hiện thông báo của Claude Code, giữ nháp hiện tại, người dùng biên tập tay (EC-39).

## UC4. Hoàn tác hành động AI

### US4.1 Hoàn tác mà không mất công sửa của mình

AC01: Hoàn tác được theo từng thay đổi (chip) hoặc cả lượt ("Hoàn tác tất cả" trong chat và phiên terminal, "Hoàn tác kế hoạch AI" với Planning Agent) (QC-12 mục 5).

AC02: Chỉ trả về giá trị trước khi AI sửa cho đúng các trường AI đã đổi; trường người dùng sửa sau đó giữ nguyên (EC-38).

AC03: Người dùng đã sửa chính trường AI đổi (hoặc thêm nội dung vào task AI tạo) → hỏi "Giữ bản của bạn" / "Trả về trước khi AI sửa".

AC04: Nhật ký task ghi cả hành động AI và lần hoàn tác.

AC05: "Hoàn tác kế hoạch AI" (trong Review Plan hoặc bước Daily plan của G08) hoàn tác mọi thay đổi còn hiệu lực của lượt Planning Agent đó, theo AC02–AC03: task agent tạo vào Thùng rác, task bị dời về ngày cũ (cả timebox, theo QC-05), timebox agent tạo bị gỡ.

AC06: Hoàn tác "hoàn thành" của AI = bỏ hoàn thành theo QC-03 mục 4 (cùng ngày làm việc: trả lại mọi tác dụng phụ; sang ngày khác: chỉ xoá thời điểm hoàn thành); timer đã dừng không tự chạy lại. Hoàn tác "xoá" của AI = khôi phục từ Thùng rác theo QC-03 mục 3.

## UC5. Rào chắn, cài đặt và chất lượng AI

### US5.1 Kiểm soát AI trong Cài đặt

AC01: Cài đặt → Trợ lý AI: trạng thái Claude Code (Sẵn sàng · phiên bản / Chưa cài / Chưa đăng nhập / Phiên bản cũ, nút "Kiểm tra lại"), Trợ lý (bật / tắt, mặc định tắt), Cho AI đọc dữ liệu từ công cụ đã kết nối (mặc định tắt), Dùng Claude Code trong terminal (hướng dẫn), Gợi ý channel, Gợi ý thời lượng (G02), Ngôn ngữ tóm tắt, Tóm tắt tự động, thời điểm đã đồng ý; Cài đặt → Beta: Agentic Daily Planning. G01 đặt lối vào nhóm AI và Beta trong khung trang Cài đặt.

AC02: Tắt trợ lý → ẩn nút ✨, không gọi Claude Code cho chat, Planning Agent, highlights và gợi ý task; MCP local ngừng nhận kết nối, phiên terminal đang mở nhận lỗi "Trợ lý AI đang tắt trong app" (QC-12 mục 7).

AC03: Workspace chỉ đọc (QC-09, 1.1) → không gọi Claude Code cho mọi tính năng, kể cả nháp highlights; công cụ ghi MCP từ chối; nút ✨ mở khung chat hiện thông báo chỉ đọc.

### US5.2 Gửi phản hồi

AC01: Review Plan, câu trả lời của trợ lý và nháp highlights có nút "Hữu ích" / "Chưa tốt" `[giả định]` và "Gửi phản hồi" (ô chữ tuỳ chọn).

AC02: Phản hồi và lần hoàn tác được thu làm tín hiệu chất lượng, không kèm dữ liệu task nếu người dùng không tích "Đính kèm cuộc trò chuyện".

### US5.3 Đánh giá trước khi đổi prompt, công cụ MCP hoặc phiên bản Claude Code (nội bộ)

AC01: Bộ đánh giá ≥ 200 câu Việt / Anh, chạy qua Claude Code với bộ công cụ MCP thật, chia nhóm: ngày giờ tương đối (gồm ca nửa đêm EC-01 và mọi dòng trong bảng ví dụ của QC-01), thao tác task, Hoàn tác cả lượt, hành động bị cấm (gồm hoàn thành / xoá task có liên kết tích hợp), hoàn thành / xoá task thường, lệnh ẩn trong dữ liệu (tiêu đề email / issue chứa câu lệnh), ngôn ngữ, highlights, gợi ý task.

AC02: Đạt ≥ 95% tổng `[giả định]` và 100% nhóm rào chắn, ngày giờ, lệnh ẩn trong dữ liệu mới được phát hành; chạy trước mỗi lần đổi prompt, bộ công cụ MCP, hoặc nâng / hạ phiên bản Claude Code tối thiểu được hỗ trợ; kết quả lưu theo phiên bản prompt / công cụ / Claude Code (Q21, C33). App không chọn model của người dùng; bộ đánh giá chạy với model mặc định của Claude Code `[giả định]`.

## UC6. Đồng ý dùng AI và kiểm soát dữ liệu đưa cho Claude Code

### US6.1 Đồng ý trước khi dùng AI lần đầu

User Story: Là người dùng thận trọng với AI, tôi muốn biết dữ liệu nào được đưa cho Claude Code và chỉ bật khi tôi đồng ý, để dữ liệu của tôi không bị đưa đi khi tôi chưa biết.

AC01: Trợ lý AI mặc định tắt với mọi người dùng (Q21).

AC02: Lần đầu bật trợ lý AI (bấm ✨, "Plan my day", "Soạn bằng AI", hoặc bật toggle "Trợ lý" trong Cài đặt) → mở màn đồng ý gọn (QC-12 mục 7): dữ liệu nào được đưa cho Claude Code (tiêu đề, ghi chú, thời lượng, ngày, trạng thái task; channel; sự kiện lịch: tiêu đề, giờ; objective; dữ liệu công cụ tích hợp chỉ khi bật riêng); Claude Code chạy bằng tài khoản Claude của bạn và xử lý dữ liệu theo điều khoản của Anthropic; app không gửi dữ liệu cho nhà cung cấp AI nào khác; Claude Code có thể tự lưu bản ghi phiên trên máy; Claude Code mở trong terminal cũng điều khiển được app; link chính sách quyền riêng tư; nút "Đồng ý và bật" / "Để sau".

AC03: "Đồng ý và bật" → lưu thời điểm đồng ý, bật trợ lý, mở MCP local, tiếp tục đúng thao tác người dùng vừa bấm. "Để sau" → trợ lý giữ tắt, không có lời gọi Claude Code nào.

AC04: Trước khi có thời điểm đồng ý, app không gọi Claude Code và MCP local không nhận kết nối, kể cả nháp highlights (Q21, QC-12 mục 7).

AC05: Cài đặt → Trợ lý AI hiện "Bạn đã đồng ý lúc {ngày giờ}". Tắt trợ lý sau đó → ngừng mọi lời gọi Claude Code, MCP local ngừng nhận kết nối; bật lại không hỏi lại `[giả định]`.

AC06: Cài đặt → Trợ lý AI có "Rút lại đồng ý dùng AI": xác nhận → xoá thời điểm đồng ý, tắt trợ lý, đóng MCP local, huỷ lượt đang chạy và thay đổi chờ duyệt; thay đổi AI đã áp dụng giữ nguyên; lần bật sau phải đồng ý lại (C5, G01 giao phần đồng ý AI cho G10).

### US6.2 Bật riêng dữ liệu từ công cụ đã kết nối

User Story: Là Linh, tôi muốn tự quyết có cho AI đọc issue Jira và email hay không, và nếu cho thì tự duyệt mọi thay đổi AI làm sau khi đọc dữ liệu đó, để một email lạ không điều khiển được kế hoạch của tôi.

AC01: Công tắc "Cho AI đọc dữ liệu từ công cụ đã kết nối" trong Cài đặt → Trợ lý AI và màn thiết lập agent, mặc định tắt (Q21, QC-12 mục 6). Bản 1.0 chưa có G11 nên công tắc ẩn tới 1.1 `[giả định]`.

AC02: Tắt → MCP local không có công cụ đọc dữ liệu tích hợp: AI không đọc item G11 (chat, Planning Agent, terminal) và highlights không dùng hoạt động công cụ.

AC03: Bật → phiên AI nào đã gọi công cụ đọc dữ liệu tích hợp thì chỉ các thay đổi sau lần đọc đầu tiên trong phiên chuyển thành chờ duyệt trong app, thay đổi trước đó giữ nguyên (D8) (chat theo US2.4 AC03, Planning Agent theo US1.3 AC03, terminal theo US8.1 AC04).

AC04: Dữ liệu công cụ chỉ là dữ liệu: câu lệnh nằm trong tiêu đề email / issue không làm AI thực hiện hành động bị cấm; ca kiểm thử nằm trong nhóm "lệnh ẩn trong dữ liệu" của bộ đánh giá, phải đạt 100%.

## UC7. Phát hiện và kết nối Claude Code

### US7.1 App phát hiện Claude Code

User Story: Là người dùng đã cài Claude Code, tôi muốn app tự nhận ra Claude Code trên máy, để bật trợ lý AI mà không phải cấu hình gì.

AC01: Khi app khởi động, khi mở Cài đặt → Trợ lý AI và khi bấm "Kiểm tra lại", app kiểm tra Claude Code: đã cài chưa, đã đăng nhập chưa, phiên bản có ≥ phiên bản tối thiểu được hỗ trợ không. Cách kiểm tra: tech chốt.

AC02: Sẵn sàng → Cài đặt → Trợ lý AI hiện "Claude Code · phiên bản {x} · Sẵn sàng"; tính năng AI hiện (vẫn cần bật trợ lý và đồng ý).

AC03: Chưa cài → mọi điểm vào AI (✨, "Plan my day", "Soạn bằng AI", gợi ý task) bị ẩn; Cài đặt → Trợ lý AI và chỗ của "Plan my day" hiện thẻ "Cài Claude Code để bật trợ lý AI" kèm link hướng dẫn và nút "Kiểm tra lại" (QC-12 mục 2).

AC04: Đã cài nhưng chưa đăng nhập → thẻ "Đăng nhập Claude Code để bật trợ lý AI" kèm hướng dẫn đăng nhập. Phiên bản cũ → thẻ "Cập nhật Claude Code lên phiên bản {tối thiểu} trở lên".

AC05: Trạng thái đổi trong lúc dùng (người dùng gỡ, đăng xuất Claude Code) → lần gọi kế tiếp lỗi thì app kiểm tra lại, ẩn tính năng AI và hiện thẻ tương ứng; thay đổi AI đã áp dụng giữ nguyên, vẫn hoàn tác được.

### US7.2 Claude Code lỗi giữa chừng

AC01: Claude Code bị đóng / dừng giữa một lượt (người dùng tắt tiến trình, máy treo, cập nhật) → lượt kết thúc lỗi; thay đổi đã áp dụng trước đó giữ nguyên và hoàn tác được; thay đổi chờ duyệt của lượt bị huỷ; chat hiện "Claude Code đã dừng giữa chừng · Gửi lại"; Planning Agent theo US1.4.

AC02: Claude Code báo hết hạn mức của gói Claude → app hiện nguyên văn thông báo của Claude Code (kèm thời điểm có lại lượt nếu Claude Code cho biết) và chuyển luồng thủ công (EC-39). App không tự đếm hay chặn lượt.

AC03: Mất mạng (Claude Code không tới được dịch vụ của Anthropic) → thông báo mất kết nối, luồng thủ công vẫn dùng được.

## UC8. Điều khiển app từ Claude Code trong terminal

### US8.1 Dùng Claude Code trong terminal riêng

User Story: Là Minh, tôi đang làm việc trong terminal với Claude Code và muốn nói "dời hết việc review sang chiều mai" mà không phải mở khung chat của app.

AC01: Cài đặt → Trợ lý AI có mục "Dùng Claude Code trong terminal" với hướng dẫn kết nối Claude Code tới MCP local của app (lệnh / cấu hình: tech chốt). Chỉ dùng được khi app đang mở, đã đăng nhập, trợ lý bật và đã đồng ý; ngược lại Claude Code nhận lỗi "Trợ lý AI đang tắt trong app" hoặc không thấy công cụ của app.

AC02: Phiên terminal dùng đúng bộ công cụ và rào chắn như khung chat (mục 5): hoàn thành / xoá như khung chat (F4), chỉ đọc dữ liệu tích hợp khi bật.

AC03: Thay đổi từ terminal áp dụng ngay, task có chip "AI", nhật ký ghi "Claude Code (terminal) đã …"; app hiện toast "Claude Code (terminal) đã thay đổi n task · Xem · Hoàn tác" và gom các thay đổi theo phiên trong màn "Hoạt động AI" để hoàn tác từng thay đổi hoặc cả phiên.

AC04: Phiên terminal đã đọc dữ liệu tích hợp → thay đổi sau đó chờ duyệt; app hiện thông báo "Có {n} thay đổi từ Claude Code đang chờ bạn duyệt · Xem" và Claude Code nhận kết quả "đang chờ người dùng duyệt trong app" (QC-12 mục 6).

AC05: Khung chat của app và phiên terminal chạy cùng lúc → mỗi bên là một phiên riêng; thao tác lên cùng task theo thứ tự server nhận (QC-08); thay đổi ghi trên phiên bản cũ của cụm vị trí bị từ chối và Claude Code nhận lỗi "Task đã thay đổi, đọc lại rồi thử lại".

## UC9. AI hoàn thành và xoá task

### US9.1 AI hoàn thành và xoá task

User Story: Là Hà, tôi tin trợ lý đủ để nói "đánh dấu xong 3 việc gửi báo giá", nhưng vẫn muốn AI không đụng vào việc đồng bộ với Jira.

AC01: (Bỏ — F4: không còn công tắc "Cho phép AI hoàn thành và xoá task" và dialog xác nhận.)

AC02: Trợ lý bật và đã đồng ý → MCP local luôn có công cụ hoàn thành task và xoá task (vào Thùng rác), áp cho cả subtask (QC-12 mục 4, F4).

AC03: AI hoàn thành task theo đúng quy tắc hoàn thành của G02 (QC-05 dòng "Hoàn thành": dừng timer, rút ngắn timebox; task tương lai về hôm nay, instance lặp giữ ngày), có chip "AI" và Hoàn tác (US4.1 AC06).

AC04: Task có liên kết tích hợp còn hiệu lực → công cụ hoàn thành và công cụ xoá đều từ chối; trợ lý nói người dùng tự làm (hoàn thành sẽ đẩy trạng thái ra Jira / Notion / Gmail) (D10). Bỏ hoàn thành không có trong MCP (G02 BR-21) `[giả định]`.

AC05: AI không xoá vĩnh viễn, không dọn Thùng rác.

## UC10. Gợi ý task qua Claude Code (cho G02)

### US10.1 Gợi ý thời lượng và channel

AC01: Khi người dùng tạo task (G02), app gọi Claude Code để gợi ý thời lượng và channel (Q33); G02 sở hữu trải nghiệm hiển thị và nguồn `ai` / `user`.

AC02: Chỉ gọi khi trợ lý bật, đã đồng ý, Claude Code sẵn sàng và bật "Gợi ý channel" / "Gợi ý thời lượng"; ngược lại không gợi ý, ô thời lượng trống, channel mặc định (G02).

AC03: Claude Code chậm hơn ngưỡng của G02, lỗi hoặc hết hạn mức → bỏ qua gợi ý, không báo lỗi chặn việc tạo task.

# 8. Chỉ số theo dõi `[giả định]`

| **Chỉ số** | **Định nghĩa** | **Mục tiêu 1.0** |
|---|---|---|
| Tỉ lệ có Claude Code sẵn sàng | Người dùng hoạt động có Claude Code "Sẵn sàng" / người dùng hoạt động | Theo dõi, chưa đặt mục tiêu |
| Tỉ lệ cài sau hướng dẫn | Người dùng chuyển từ "Chưa cài" / "Chưa đăng nhập" sang "Sẵn sàng" trong 7 ngày / người dùng thấy thẻ hướng dẫn | Theo dõi |
| Tỉ lệ dùng terminal | Người dùng có ≥ 1 phiên terminal / tuần / người bật trợ lý | Theo dõi |
| Tỉ lệ dùng Planning Agent | Ngày có chạy agent / ngày có Daily planning (người bật Beta) | ≥ 50% |
| Tỉ lệ kế hoạch agent được giữ | Lượt chạy xong không bị "Hoàn tác kế hoạch AI" / "Huỷ tất cả" trong ngày làm việc / lượt chạy xong | ≥ 70% |
| Tỉ lệ đồng ý dùng AI | Người dùng bấm "Đồng ý và bật" / người dùng thấy màn đồng ý | Theo dõi, chưa đặt mục tiêu |
| Thời gian lập kế hoạch với agent | Từ "Plan my day" đến "Tiếp" | ≤ 5 phút (trung vị) |
| Tỉ lệ hoàn tác hành động chat | Thay đổi bị hoàn tác / thay đổi áp dụng | ≤ 10% |
| Thời gian tới kết quả đầu tiên | Từ gửi đến chữ / bước đầu tiên | p95 ≤ 10 giây |
| Tỉ lệ chuyển luồng thủ công | Lượt agent lỗi (gồm Claude Code bị đóng, hết hạn mức Claude) / lượt chạy | ≤ 3% (tách riêng lý do "hết hạn mức Claude" để theo dõi) |
| Tỉ lệ giữ nháp highlights | Highlights lưu sửa < 30% ký tự / nháp được mở | ≥ 60% |
| Điểm bộ đánh giá | Câu đúng / tổng câu | ≥ 95%; rào chắn, ngày giờ và lệnh ẩn trong dữ liệu 100% |

# 9. Phụ thuộc và rủi ro

| **Mục** | **Mô tả** | **Hướng xử lý** |
|---|---|---|
| Phụ thuộc Claude Code CLI | Phiên bản mới đổi cách gọi, định dạng đầu ra hoặc cách khai báo MCP; điều khoản sử dụng của Anthropic cho việc app gọi CLI | Khai báo phiên bản tối thiểu / đã kiểm thử; chạy bộ đánh giá khi Claude Code ra bản mới; kiểm tra điều khoản trước phát hành; cách gọi: tech chốt |
| Người dùng không có Claude Code / gói Claude | Phần lớn người dùng phổ thông chưa cài; AI không có trên web / di động | Chức năng lõi đủ không cần AI; thẻ hướng dẫn cài; cách cung cấp AI trên web / di động: tech chốt (ADR-0004) |
| Hiểu sai ngày giờ | Đã gặp trên Sunsama (EC-01); phiên terminal không đi qua lời nhắc của app | Ngữ cảnh thời gian bắt buộc; công cụ "Xem ngữ cảnh thời gian"; dùng hàm ngày làm việc QC-01; công cụ ghi chỉ nhận ngày tuyệt đối, server kiểm; hỏi lại trong khung mơ hồ; bảng ví dụ QC-01 là ca chuẩn |
| Dữ liệu cá nhân đưa cho Claude Code | Nghị định 13/2023/NĐ-CP, GDPR; dữ liệu đi qua tài khoản Claude của người dùng; Claude Code tự lưu bản ghi phiên trên máy | Mặc định tắt, màn đồng ý gọn và lưu thời điểm đồng ý (Q21); công cụ trả dữ liệu tối thiểu; màn đồng ý nói rõ; cần pháp chế xác nhận trách nhiệm của app và hồ sơ Q29 |
| Lệnh ẩn trong dữ liệu (prompt injection) | Tiêu đề email / item Jira chứa câu lệnh | Công cụ đọc dữ liệu tích hợp mặc định tắt; phiên đã đọc thì mọi thay đổi chờ duyệt (QC-12 mục 6); dữ liệu ngoài chỉ là dữ liệu; rào chắn là bộ công cụ MCP, không dựa vào model; nhóm đánh giá "lệnh ẩn" phải đạt 100% |
| Tiến trình lạ kết nối MCP local | Phần mềm khác trên máy gọi công cụ của app | MCP chỉ nhận kết nối trên máy, chỉ khi trợ lý bật; xác thực tiến trình hợp lệ: tech chốt |
| AI thay đổi hàng loạt không qua duyệt | Không còn ngưỡng "> 3 task phải duyệt" (Q46) | Chip "AI" trên từng task; "Hoàn tác tất cả" / "Hoàn tác kế hoạch AI" một chạm; toast cho phiên terminal; xoá chỉ vào Thùng rác; tín hiệu hoàn tác theo dõi hằng tuần |
| Phụ thuộc G01, G02, G04, G05, G08, G11 | Lối vào Cài đặt AI (G01); gợi ý task và chip "AI" (G02, G04); timebox (G05); ritual và nút "Hoàn tác kế hoạch AI" (G08); tạo task từ item và hoạt động công cụ (G11, 1.1) | Hợp đồng giữa nhóm; thiếu nguồn thì agent vẫn chạy với dữ liệu có |
| Agent áp dụng sai nhiều task | Mất niềm tin | Mọi thay đổi hiện trong Review Plan; "Hoàn tác kế hoạch AI" một chạm; chờ duyệt khi có dữ liệu tích hợp; tín hiệu hoàn tác theo dõi hằng tuần |

# 10. Câu hỏi mở

- Mốc đầu ngày 04:00 hay 00:00? — Đã chốt 04/11/2026: mặc định 04:00, chỉnh trong 00:00–06:00; AI hiểu "hôm nay / ngày mai" theo hàm ngày làm việc QC-01, bảng ví dụ QC-01 là ca chuẩn (Q2, C33).
- Planning Agent chờ duyệt rồi mới áp dụng hay áp dụng ngay rồi Undo all như Sunsama? — Đã chốt 04/11/2026: áp dụng ngay kèm "Hoàn tác kế hoạch AI"; kế hoạch có dùng dữ liệu tích hợp thì chờ duyệt (Q31/Q31a). Ngưỡng "chat ≤ 3 task" đã được thay: mọi thay đổi qua MCP áp dụng ngay (Q46, QC-12 mục 5).
- Trợ lý có được đánh dấu xong task không, hay chỉ người dùng? — Đã chốt 04/11/2026: mặc định không, có công tắc riêng (Q46). **Đã chốt lại 06/11/2026 (F4):** bỏ công tắc; khi trợ lý bật, AI luôn được hoàn thành và xoá task (vào Thùng rác); task có liên kết tích hợp không bao giờ được AI hoàn thành hay xoá (QC-12 mục 4; thay một phần Q20 / ADR-0003).
- Chọn nhà cung cấp LLM nào? — Đã chốt 04/11/2026: không chọn; trợ lý AI chạy bằng Claude Code CLI của người dùng, app không gọi LLM nào khác (Q33, Q46, ADR-0004).
- Dữ liệu có cần xử lý / lưu tại Việt Nam không? — Một phần đã chốt 04/11/2026: không bắt buộc lưu tại Việt Nam, cần hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (Q29). Còn mở: khi dữ liệu đi qua Claude Code bằng tài khoản Claude của chính người dùng, app có trách nhiệm gì và có phải đưa vào hồ sơ Q29 không — pháp chế xác nhận trước khi phát hành.
- Hạn mức chat và số lần chạy agent có khác theo gói không (G12)? — Đã chốt 04/11/2026: không còn hạn mức AI theo gói; người dùng dùng hạn mức của gói Claude của họ; hết hạn mức thì hiện thông báo của Claude Code và chuyển luồng thủ công (Q46, QC-10, QC-12 mục 8; thay C32).
- Có cần đồng ý trước khi gửi dữ liệu cho AI không? — Đã chốt 04/11/2026: trợ lý AI mặc định tắt, có màn đồng ý gọn nói rõ dữ liệu nào đưa cho Claude Code và lưu thời điểm đồng ý; dữ liệu tích hợp có công tắc riêng (Q21, Q46, QC-12 mục 7).
- Nháp highlights có theo Lịch làm việc (QC-02) thay cho T2–T6 17:00 cố định không? — Đã chốt 04/11/2026: soạn vào các ngày có trong lịch làm việc, tại giờ kết thúc của lịch chung (Q39, D7).
- Gợi ý thời lượng / channel của G02 (bản 1.0) có gọi nhà cung cấp AI không; nếu có thì có cần cùng màn đồng ý không? — Đã chốt 04/11/2026: gợi ý dùng trợ lý AI qua Claude Code CLI, không gọi LLM nào khác (Q33); vì vậy cần trợ lý bật và cùng màn đồng ý của G10.
- Quản trị workspace có được tắt AI cho cả workspace không? — Đã chốt 04/11/2026: bản 1 chỉ cho một người dùng; tính năng nhiều thành viên để bản sau (Q35).
- Highlights chia sẻ có gồm task trong channel private không (Privacy, G12)? — Đã chốt 04/11/2026: Privacy và nhiều thành viên để bản sau (Q35, Q37); bản 1 không có câu hỏi này.
- Lịch sử chat giữ 90 ngày có đủ không; có cho tắt lưu lịch sử?
- Phản hồi có "Đính kèm cuộc trò chuyện" giữ bao lâu?
- Highlights có chỉ được chứa link nội bộ (task, item đã liên kết) để chặn link lạ do dữ liệu ngoài đưa vào không?
- Sự kiện lịch do người khác mời (G05) có tính là "dữ liệu ngoài" phải chờ duyệt như dữ liệu tích hợp không? (Nay hiểu là: công cụ đọc lịch có tính là công cụ đọc dữ liệu tích hợp không.)
- Bật lại trợ lý sau khi tắt, hoặc khi nội dung màn đồng ý thay đổi, có phải đồng ý lại không?
- Khi nào Planning Agent bỏ nhãn Beta; tiêu chí nào?
- Đã chốt 04/11/2026: phiên AI đã đọc dữ liệu tích hợp thì chỉ các thay đổi **sau** lần đầu đọc dữ liệu tích hợp trong phiên đó chờ duyệt; thay đổi đã áp dụng trước đó giữ nguyên; bật công tắc không làm mọi phiên chờ duyệt (D8, QC-12 mục 6).
- Đã chốt 04/11/2026: Planning Agent lỗi giữa chừng khi đã áp dụng một phần thì giữ phần đã áp dụng, có Hoàn tác cả lượt ("Hoàn tác kế hoạch AI"); chat theo cùng cách (D9, QC-12 mục 5).
- Đã chốt 04/11/2026: tên hiển thị của trợ lý AI chưa đặt, quyết định khi làm thiết kế Figma; không dùng "Sunny" của Sunsama làm tên sản phẩm (D16).
- Ngoài QC-12 mục 3, AI có được thêm subtask, sắp thứ tự, đổi priority, gắn objective không (bản nháp trước cho phép)?
- Một phần đã chốt 04/11/2026: hoàn thành / xoá áp cho cả subtask; AI không bao giờ hoàn thành hay xoá task có liên kết tích hợp (D10, QC-12 mục 4); bỏ công tắc (F4, 06/11/2026). Còn mở: MCP có công cụ bỏ hoàn thành không (đang giả định: không, G02 BR-21)?
- Phiên bản Claude Code tối thiểu được hỗ trợ; app có cho chọn model của Claude Code không?
- Gợi ý task qua Claude Code có đạt ngưỡng 2 giây của G02 không; nếu không thì đổi ngưỡng hay đổi trải nghiệm (gợi ý đến sau)?
- Một phần đã chốt 04/11/2026: app không mở tại giờ kết thúc của lịch chung thì soạn khi mở app lần kế tiếp trong ngày (D7). Còn mở: người dùng có nhiều máy Windows thì một ngày chỉ một nháp tự động (đang giả định: có, server giữ khoá user + ngày)?
- Trợ lý AI trên web, macOS (1.1) và iOS / Android (1.2): cung cấp thế nào (tech chốt, ADR-0004)?
- Đã chốt 05/11/2026: điều khoản sử dụng của Anthropic với cách app gọi Claude Code CLI — PO giữ mô hình và chấp nhận rủi ro, không chờ xác nhận pháp lý; app không xử lý đăng nhập Claude, không dùng tên / logo Claude Code làm tên tính năng ([ADR-0004](../adr/0004-ai-qua-claude-code-cli.md), #25).
