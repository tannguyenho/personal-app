> **Mã:** PLN-SRS-G10-WEB · **Trạng thái:** nháp · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g10-tro-ly-ai.md

# UC-G10 - Trợ lý AI trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả Planning Agent, trợ lý chat Sunny, highlights AI cuối ngày, rào chắn, cài đặt AI và bộ đánh giá (bản 1.2). Gợi ý thời lượng / channel khi tạo task (G02, 1.0), Daily planning / Daily shutdown thủ công và chia sẻ (G08), timebox (G05), Weekly planning / objective (G09), kết nối công cụ (G11), hạn mức theo gói và Privacy (G12) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng lập kế hoạch ngày với agent, thao tác task bằng ngôn ngữ tự nhiên và có nháp highlights cuối ngày; mọi thay đổi AI nhìn thấy được, đúng ngày và hoàn tác được |
| Actor | Người dùng đã đăng nhập · Hệ thống · Dịch vụ AI (\[AiGateway\] → nhà cung cấp LLM) · Bộ thực thi hành động AI (\[AiActionExecutor\]) · Kỹ sư AI (bộ đánh giá) |
| Phạm vi | Thiết lập và chạy Planning Agent, Review Plan, chat Sunny (hỏi đáp, ra lệnh, lịch sử), xác nhận thay đổi > 3 task, hoàn tác hành động AI, highlights AI, phản hồi, cài đặt AI / Beta, bộ đánh giá |
| Ngoài phạm vi | Gợi ý planned / channel (G02), ritual thủ công và chia sẻ (G08), kết nối công cụ (G11), agent chạy nền, nhập giọng nói, AI cho nhóm |
| Nền tảng | Bản 1.2: Web (desktop, mobile web), App iOS / Android, desktop dùng cùng đặc tả |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Thiết lập agent một lần (công cụ, thông tin về tôi, theme days) | Agent lập kế hoạch đúng thói quen của tôi |
| US-02 | Người dùng | Nói điều quan trọng hôm nay rồi bấm "Plan my day" | Có kế hoạch ngày trong vài phút |
| US-03 | Người dùng | Xem và chọn từng thay đổi của agent trước khi áp dụng | Giữ quyền quyết định kế hoạch |
| US-04 | Người dùng | Hỏi và ra lệnh cho Sunny bằng tiếng Việt hoặc tiếng Anh | Thao tác nhiều task nhanh |
| US-05 | Người dùng làm khuya | "Ngày mai" được hiểu đúng hoặc được hỏi lại | Task không rơi vào ngày sai (EC-01) |
| US-06 | Người dùng | Hoàn tác thay đổi của AI mà không mất phần mình đã sửa | Không sợ thử AI |
| US-07 | Người dùng | Có nháp highlights cuối ngày để duyệt | Đỡ viết tóm tắt từ đầu |
| US-08 | Người dùng | Bật / tắt từng tính năng AI | Dùng AI ở mức mình muốn |
| US-09 | Kỹ sư AI | Chạy bộ đánh giá trước khi đổi model / prompt | Không phát hành bản AI kém hơn |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Hành động được phép.** AI chỉ được: tạo task, sửa tiêu đề / planned / channel / priority / due, thêm subtask, dời ngày / vào backlog, sắp thứ tự, timebox / gỡ timebox (G05), gắn objective (G09), đánh dấu xong `[giả định]`. Mọi hành động đi qua \[AiActionExecutor\] ở server, kiểm danh sách này độc lập với model |
| BR-02 | **Hành động bị cấm.** Xoá task / subtask, gửi tin ra ngoài (email, Slack, Teams, chia sẻ ritual), đổi cài đặt, kết nối / ngắt tích hợp, đọc / sửa dữ liệu người khác. Yêu cầu loại này → trả lời từ chối MSG-07 kèm cách tự làm; \[AiActionExecutor\] trả `AI_ACTION_FORBIDDEN` nếu model vẫn sinh hành động |
| BR-03 | **Ngữ cảnh thời gian bắt buộc.** Mọi lượt gọi LLM gửi: `now` (ISO 8601 có offset), timezone IANA, `dayStartTime`, `currentWorkday` (ngày làm việc hiện tại theo day_start_time), giờ làm việc, locale. Thiếu trường nào → không gọi LLM, ghi lỗi `AI_CONTEXT_MISSING` |
| BR-04 | **Ngày tuyệt đối.** Hành động có ngày phải mang ngày `YYYY-MM-DD` và giờ tuyệt đối; server từ chối ngày ngoài ± 1 năm so với hôm nay `[giả định]`. Chip, thẻ xác nhận, Review Plan luôn hiện ngày cụ thể ("Thứ Năm, 5/11") |
| BR-05 | **Khung mơ hồ (EC-01).** Khi `now` trong khoảng 00:00 → day_start_time (04:00 `[giả định]`; nếu day_start_time = 00:00 thì 00:00 → 04:00) và yêu cầu chứa "hôm nay / ngày mai / tối nay / sáng mai / today / tomorrow / tonight" → không thực hiện, hỏi lại bằng 2 lựa chọn: ngày làm việc hiện tại và ngày lịch hiện tại (nếu trùng nhau thì ngày kế tiếp) |
| BR-06 | **Ngưỡng xác nhận (EC-37).** Đếm số task khác nhau bị ảnh hưởng. > 3 task → đề xuất ở `CHO_DUYET`, hiện **SCR-05**. ≤ 3 → áp dụng ngay, hiện chip kèm Hoàn tác. Đề xuất của Planning Agent luôn ở `CHO_DUYET` (Review Plan) bất kể số task. Ngưỡng lấy từ \[AppConfig\] |
| BR-07 | **Nhật ký.** Mọi thay đổi AI ghi \[ActivityLog\] (G02) với tác nhân `ai`, `aiAgent` (`assistant` / `planning_agent` / `highlights`) và `proposalId`. Hiển thị: "Planning Agent đã tạo task này", "Sunny đã dời sang Thứ Năm, 5/11" |
| BR-08 | **Hoàn tác (EC-38).** Hoàn tác theo từng thay đổi hoặc cả đề xuất, trong 7 ngày `[giả định]` kể từ khi áp dụng. Chỉ trả lại các trường AI đã đổi về giá trị trước AI. Trường người dùng đã sửa sau AI, hoặc task AI tạo đã được người dùng thêm subtask / notes / comment / thời gian thực tế → thay đổi đó ở `XUNG_DOT`, hỏi qua **SCR-06**. Hoàn tác "tạo task" = xoá mềm vào Thùng rác (G02 UC-04 A3). Hoàn tác "đánh dấu xong" = bỏ hoàn thành (G02 BR-09) |
| BR-09 | **Thời gian chờ.** Kết quả đầu tiên (token chữ hoặc bước tiến độ) ≤ 10 giây. Chat: quá 10 giây vẫn chờ, hiện "Vẫn đang xử lý…" và nút Dừng; quá 60 giây `[giả định]` → `LOI`. Planning Agent: lỗi, hoặc 10 giây chưa có bước đầu, hoặc tổng > 5 phút `[giả định]` → `LOI` và chuyển luồng thủ công G08 (EC-39) |
| BR-10 | **Dữ liệu gửi LLM tối thiểu.** Chỉ gửi: tiêu đề, planned, actual, channel (tên), ngày, trạng thái task trong khoảng ngày cần (mặc định hôm nay ± 7 ngày `[giả định]`); sự kiện lịch (tiêu đề, giờ, busy); tiêu đề item tích hợp. Notes / comment chỉ gửi khi người dùng nhắc đích danh task đó. Không gửi nội dung email, email người khác, token. Hợp đồng nhà cung cấp: không lưu, không huấn luyện |
| BR-11 | **Dữ liệu ngoài là dữ liệu.** Tiêu đề task, notes, email, item tích hợp không được coi là lệnh; BR-01, BR-02, BR-06 kiểm ở \[AiActionExecutor\], không dựa vào model |
| BR-12 | **Ngôn ngữ.** Chat trả lời theo ngôn ngữ tin nhắn gần nhất của người dùng. Highlights theo cài đặt "Ngôn ngữ tóm tắt"; Auto = ngôn ngữ giao diện `[giả định]` |
| BR-13 | **Highlights.** Bật "Tóm tắt tự động" → \[HighlightsDraft\] chạy 17:00 T2–T6 theo timezone người dùng; ngày không có task xong → không soạn. Nguồn: task `HOAN_THANH` trong ngày làm việc + hoạt động công cụ (\[IntegrationActivity\], G11). Nháp ở `CHO_DUYET`, chỉ thành highlights của ritual khi người dùng hoàn tất bước highlights (G08). Đã có bản người dùng sửa → không ghi đè, chỉ gợi ý thêm |
| BR-14 | **Planning Agent.** Chỉ chạy khi bật Beta "Agentic Daily Planning". Tối đa 5 lượt / ngày `[giả định]`. Một ngày chỉ có 1 đề xuất agent ở `DANG_XU_LY` / `CHO_DUYET`; "Lập lại" đóng đề xuất cũ (`DA_HOAN_TAC`, `rejected = true`) rồi tạo đề xuất mới |
| BR-15 | **Chat.** Tin nhắn 1–2.000 ký tự; 100 tin / ngày / người dùng `[giả định]` (theo gói → G12); lịch sử giữ 90 ngày `[giả định]`; người dùng xoá được cuộc trò chuyện (xoá nội dung chat, không đụng task đã tạo) |
| BR-16 | **Tắt AI.** Tắt "Trợ lý" → ẩn nút ✨, không gọi LLM cho chat, highlights tự động; Planning Agent chỉ theo cài đặt Beta. Gợi ý planned / channel có cài đặt riêng (G02) |
| BR-17 | Workspace chỉ đọc (G12) → AI chỉ trả lời câu hỏi, không tạo đề xuất có hành động (MSG-12) |
| BR-18 | **Bộ đánh giá.** ≥ 200 câu Việt / Anh; đạt ≥ 95% tổng và 100% nhóm "rào chắn" và "ngày giờ" `[giả định]`; chạy trước mỗi lần đổi model hoặc prompt; không đạt → chặn phát hành cấu hình đó |

## 4. Trạng thái

### 4.1. Trạng thái đề xuất AI

Mỗi lượt AI có hành động (một tin chat, một lượt Planning Agent, một nháp highlights) tạo một \[AiProposal\].

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_XU_LY` | Đã gửi tới \[AiGateway\], chưa có kết quả cuối | Chat: "Đang nghĩ…" + bộ đếm giây. Agent: danh sách bước tiến độ. Highlights: "Đang soạn…" |
| `CHO_DUYET` | Có kết quả, chưa áp dụng (> 3 task, Planning Agent, highlights, hoặc khung mơ hồ BR-05) | SCR-05 / SCR-03 / nháp có ✨ trong SCR-07 |
| `DA_AP_DUNG` | Ít nhất một thay đổi đã áp dụng, chưa hoàn tác hết | Chip task có "Hoàn tác"; nhật ký task ghi tác nhân AI |
| `DA_HOAN_TAC` | Mọi thay đổi đã hoàn tác, hoặc người dùng Huỷ / Lập lại ở `CHO_DUYET` (`rejected = true`) | Chip gạch ngang "Đã hoàn tác" / thẻ xám "Đã huỷ" |
| `LOI` | LLM lỗi, quá thời gian (BR-09), hoặc mọi hành động bị \[AiActionExecutor\] từ chối | MSG-04 / MSG-05; Planning Agent → luồng thủ công |

Chuyển trạng thái: `DANG_XU_LY` → `CHO_DUYET` | `DA_AP_DUNG` (≤ 3 task) | `LOI` · `CHO_DUYET` → `DA_AP_DUNG` (Áp dụng / Tiếp) | `DA_HOAN_TAC` (Huỷ, Lập lại) · `DA_AP_DUNG` → `DA_HOAN_TAC` (hoàn tác hết). Đề xuất chỉ trả lời (không hành động) không lưu trạng thái. `CHO_DUYET` quá 24 giờ `[giả định]` → tự đóng `DA_HOAN_TAC`.

### 4.2. Trạng thái từng thay đổi trong đề xuất

`CHUA_AP_DUNG` → `DA_AP_DUNG` → `DA_HOAN_TAC`. `DA_AP_DUNG` → `XUNG_DOT` khi hoàn tác gặp sửa đổi của người dùng (BR-08); người dùng chọn "Trả về trước AI" → `DA_HOAN_TAC`, chọn "Giữ bản của tôi" → giữ `DA_AP_DUNG`, cờ `keptByUser`. Đề xuất ở `DA_AP_DUNG` khi còn ≥ 1 thay đổi `DA_AP_DUNG`.

## 5. Use Case

### UC-01 Thiết lập Planning Agent

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã bật Beta "Agentic Daily Planning"; chưa có hồ sơ agent hoặc người dùng mở lại thiết lập |
| Hậu điều kiện thành công | Lưu \[AgentProfile\] (giới thiệu, theme days, nguồn dữ liệu được dùng); `setupCompletedAt` có giá trị |
| Hậu điều kiện thất bại | Không có hồ sơ; lần sau bấm "Plan my day" mở lại thiết lập |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Plan my day" lần đầu, hoặc Cài đặt → AI → "Thiết lập Planning Agent" |
| 2 | Hệ thống | Mở **SCR-01** phần 1 "Công cụ": liệt kê lịch (G05) và công cụ (G11) với trạng thái kết nối; nút "Kết nối" trỏ luồng của nhóm sở hữu |
| 3 | Người dùng | Phần 2 "Kể về bạn": vai trò, giờ làm việc ưa thích, việc cần tránh (≤ 1.000 ký tự `[giả định]`) |
| 4 | Người dùng | Phần 3 "Theme days": mỗi thứ T2–CN một chủ đề tuỳ chọn (ví dụ "Thứ Sáu: không họp, deep work") |
| 5 | Hệ thống | Gọi \[AgentProfileSave\]; quay lại SCR-02 nếu mở từ "Plan my day" |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bỏ qua một phần | "Bỏ qua" → phần đó trống; agent vẫn chạy với dữ liệu có |
| A2 | Chưa kết nối công cụ nào | Hiện gợi ý MSG-01; agent chỉ dùng task trong app và lịch (nếu có) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Văn bản quá dài | MSG-02 tại ô, chặn lưu |
| E2 | \[AgentProfileSave\] lỗi | MSG-14, giữ nội dung đã nhập |

### UC-02 Lập kế hoạch ngày với Planning Agent

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Beta bật; hồ sơ agent đã có (UC-01); người dùng đang ở Daily planning ngày D (G08); workspace không chỉ đọc |
| Hậu điều kiện thành công | Thay đổi được chọn đã áp dụng; đề xuất `DA_AP_DUNG`; nhật ký ghi `planning_agent`; ritual sang bước Daily plan (G08) |
| Hậu điều kiện thất bại | Không thay đổi nào áp dụng; người dùng ở luồng Daily planning thủ công (G08), giữ nội dung đã nhập |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Trên **SCR-02** gõ "Điều quan trọng nhất hôm nay" (tuỳ chọn), bấm "Plan my day" |
| 2 | Hệ thống | Gọi \[AgentPlanStart\] với ngữ cảnh BR-03; tạo đề xuất `DANG_XU_LY`; hiện bước tiến độ (realtime `ai.proposal.updated`) |
| 3 | Dịch vụ AI | Đọc lịch ngày D, task hôm nay / rollover / backlog tới kỳ (G06), objective tuần (G09), item công cụ (G11), hồ sơ agent; sinh danh sách hành động trong BR-01 |
| 4 | Hệ thống | \[AiActionExecutor\] kiểm BR-01, BR-02, BR-04 cho từng hành động; hành động hợp lệ thành thay đổi `CHUA_AP_DUNG`; đề xuất → `CHO_DUYET` (BR-06) |
| 5 | Hệ thống | Mở **SCR-03** Review Plan: "Planning Agent đề xuất n thay đổi", danh sách "HÔM NAY · n thay đổi", tổng planned so ngưỡng khối lượng (G04) |
| 6 | Người dùng | Bỏ chọn dòng không muốn; bấm "Tiếp" |
| 7 | Hệ thống | Gọi \[ProposalApply\] với các thay đổi được chọn trong một giao dịch; đề xuất → `DA_AP_DUNG`; chuyển bước Daily plan (G08) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Lập lại" ở bước 6 | Mở ô "Muốn agent đổi gì?"; đề xuất cũ → `DA_HOAN_TAC` (`rejected`); quay lại bước 2 với chỉ dẫn thêm (BR-14) |
| A2 | "Huỷ tất cả" ở bước 6 | \[ProposalReject\]; đề xuất → `DA_HOAN_TAC`; về bước 1 của Daily planning thủ công (G08) |
| A3 | "Gửi phản hồi" | Mở **SCR-08**, không đổi trạng thái đề xuất |
| A4 | Hoàn tác sau khi đã "Tiếp" | Từ nhật ký task hoặc nút "Hoàn tác kế hoạch AI" trong Daily plan → UC-04 |
| A5 | Agent không đề xuất thay đổi nào | Review Plan hiện MSG-03; "Tiếp" sang Daily plan |
| A6 | Một số hành động bị \[AiActionExecutor\] từ chối | Bỏ các hành động đó, ghi log; Review Plan chỉ hiện hành động hợp lệ |
| A7 | Hết 5 lượt trong ngày | Nút "Plan my day" disabled, MSG-11 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | 10 giây chưa có bước tiến độ đầu, LLM lỗi, hoặc tổng > 5 phút (EC-39) | Huỷ lượt, đề xuất → `LOI`, không áp dụng gì; MSG-05; mở Daily planning thủ công (G08) bước 1; nội dung "Điều quan trọng nhất" đưa vào ô "Obstacles in my way" |
| E2 | Thiếu ngữ cảnh thời gian (BR-03) | Như E1, log `AI_CONTEXT_MISSING` |
| E3 | \[ProposalApply\] lỗi một phần (task đã bị xoá / sửa ở thiết bị khác) | Giao dịch huỷ toàn bộ; đề xuất giữ `CHO_DUYET`; MSG-15 "Kế hoạch vừa thay đổi" và nút "Lập lại" |
| E4 | Mất mạng | MSG-06; Daily planning thủ công vẫn dùng offline (G08) |

### UC-03 Trò chuyện và ra lệnh cho Sunny

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Cài đặt "Trợ lý" bật; người dùng đã đăng nhập |
| Hậu điều kiện thành công | Câu trả lời hiện trong cuộc trò chuyện; nếu có hành động: áp dụng (≤ 3 task) hoặc chờ duyệt (> 3 task); nhật ký ghi `assistant` |
| Hậu điều kiện thất bại | Không thay đổi task; tin nhắn của người dùng còn trong ô / lịch sử để gửi lại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm nút ✨ góc dưới → **SCR-04**; gõ tin nhắn, Enter |
| 2 | Hệ thống | Kiểm BR-15; gọi \[ChatSend\] kèm ngữ cảnh BR-03 và màn hình đang xem (ngày đang xem, task đang chọn); hiện "Đang nghĩ…" |
| 3 | Dịch vụ AI | Trả lời dạng luồng (stream); nếu cần hành động, sinh danh sách hành động có ngày tuyệt đối (BR-04) |
| 4 | Hệ thống | \[AiActionExecutor\] kiểm BR-01, BR-02, BR-04, BR-05; đếm task bị ảnh hưởng (BR-06) |
| 5 | Hệ thống | ≤ 3 task: áp dụng ngay, đề xuất `DA_AP_DUNG`; câu trả lời kèm chip mỗi task: tiêu đề, "Thứ Năm, 5/11 · 14:00", "Hoàn tác" |
| 6 | Hệ thống | Hiện "Đã nghĩ {n}s"; board, lịch cập nhật qua realtime `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Câu hỏi không cần hành động ("chiều nay còn trống bao lâu?") | Chỉ trả lời, có số liệu từ G04 (thời gian trống, tổng planned); không tạo đề xuất |
| A2 | > 3 task bị ảnh hưởng (EC-37) | Đề xuất `CHO_DUYET`; hiện **SCR-05** trong khung chat; "Áp dụng" → \[ProposalApply\] các dòng được chọn; "Huỷ" → \[ProposalReject\] |
| A3 | Khung mơ hồ BR-05 (EC-01: 02:10 ngày 4/11, "tạo task gọi khách ngày mai") | Không tạo; Sunny hỏi MSG-08 với 2 nút "Thứ Tư, 4/11" / "Thứ Năm, 5/11"; chọn → tiếp bước 4 với ngày đã chọn |
| A4 | Yêu cầu hành động bị cấm (BR-02) | Trả lời MSG-07 kèm cách tự làm (ví dụ "Xoá: chọn task, Ctrl+Backspace"); không tạo đề xuất |
| A5 | Bấm "Hoàn tác" trên chip | → UC-04 |
| A6 | "Lịch sử" | Danh sách cuộc trò chuyện (\[ChatThreadList\]) mới nhất trước; mở lại cuộc cũ, chip vẫn hoàn tác được trong thời hạn BR-08 |
| A7 | "Cuộc trò chuyện mới" | \[ChatThreadCreate\]; ngữ cảnh cuộc cũ không gửi kèm |
| A8 | Quá 10 giây chưa xong | Hiện "Vẫn đang xử lý…" và nút "Dừng"; Dừng → huỷ lượt, `LOI` không áp dụng gì |
| A9 | Yêu cầu nhắc tới task không tìm thấy hoặc khớp nhiều task | Sunny hỏi lại, liệt kê tối đa 5 task khớp để chọn |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | LLM lỗi / quá 60 giây | Đề xuất `LOI`; MSG-04 có nút "Gửi lại" |
| E2 | Hết hạn mức ngày | MSG-11, ô nhập disabled tới ngày làm việc kế tiếp |
| E3 | Tin nhắn > 2.000 ký tự | MSG-02, chặn gửi |
| E4 | Workspace chỉ đọc (G12) | Chỉ trả lời câu hỏi; yêu cầu hành động → MSG-12 |
| E5 | Mất mạng | MSG-06; tin nhắn giữ trong ô, không xếp hàng đợi offline |
| E6 | Hành động hợp lệ nhưng ghi thất bại (task vừa bị xoá ở thiết bị khác) | Chip của task đó hiện "Không thực hiện được"; các task khác vẫn áp dụng |

### UC-04 Hoàn tác hành động AI

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đề xuất `DA_AP_DUNG`; thay đổi cần hoàn tác áp dụng chưa quá 7 ngày `[giả định]` |
| Hậu điều kiện thành công | Thay đổi được chọn → `DA_HOAN_TAC`; trường AI đổi trả về giá trị trước AI; sửa đổi của người dùng giữ nguyên; nhật ký ghi "hoàn tác thay đổi của AI" |
| Hậu điều kiện thất bại | Task giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Hoàn tác" trên chip (một thay đổi), "Hoàn tác tất cả" trong đề xuất, hoặc "Hoàn tác" ở dòng nhật ký AI trong chi tiết task (G02 SCR-03) |
| 2 | Hệ thống | Gọi \[ProposalUndo\] với `changeIds` |
| 3 | Hệ thống | Với từng thay đổi: so `version` và lịch sử trường; không có sửa đổi của người dùng sau AI → trả giá trị trước AI (BR-08) |
| 4 | Hệ thống | Chip gạch ngang "Đã hoàn tác"; task AI tạo → Thùng rác; toast MSG-09 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng đã sửa trường khác của task (ví dụ AI dời ngày, người dùng đổi priority) | Chỉ trả ngày; priority của người dùng giữ (EC-38) |
| A2 | Người dùng đã sửa chính trường AI đổi, hoặc thêm nội dung vào task AI tạo (EC-38) | Thay đổi → `XUNG_DOT`; mở **SCR-06** liệt kê trường xung đột: "Giữ bản của tôi" / "Trả về trước khi AI sửa" (áp cho từng dòng hoặc tất cả) |
| A3 | Task đã bị người dùng xoá | Bỏ qua thay đổi đó, ghi "không còn task" |
| A4 | Hoàn tác "đánh dấu xong" | Bỏ hoàn thành theo G02 BR-09 |
| A5 | Hoàn tác timebox | Gỡ timebox, xoá sự kiện ngoài (G05) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Quá thời hạn hoàn tác | Nút Hoàn tác ẩn; gọi API trả `AI_UNDO_EXPIRED` → MSG-10 |
| E2 | \[ProposalUndo\] lỗi | Giữ nguyên, MSG-14 |

### UC-05 Soạn và duyệt highlights AI cuối ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Trợ lý bật; ngày làm việc D có ≥ 1 task `HOAN_THANH` |
| Hậu điều kiện thành công | Highlights người dùng đã duyệt lưu vào ritual Daily shutdown ngày D (G08); đề xuất `DA_AP_DUNG` |
| Hậu điều kiện thất bại | Bước highlights dùng danh sách việc đã xong biên tập tay như bản 1.0 (G08) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job `ai.highlights.draft` chạy 17:00 T2–T6 theo timezone người dùng (BR-13) |
| 2 | Hệ thống | Gọi \[HighlightsDraft\]: task xong trong ngày D, thời gian theo channel, \[IntegrationActivity\] (G11); ngôn ngữ theo BR-12 |
| 3 | Hệ thống | Lưu nháp `CHO_DUYET`; không gửi thông báo riêng (lời nhắc shutdown thuộc G08) |
| 4 | Người dùng | Mở Daily shutdown (G08) → bước highlights → **SCR-07** hiện nháp có ✨, mỗi ý có link về task / item nguồn |
| 5 | Người dùng | Sửa, xoá ý, thêm ý; bấm "Tiếp" của bước |
| 6 | Hệ thống | Lưu highlights vào ritual (G08 \[RitualUpdate\]); đề xuất → `DA_AP_DUNG` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Mở shutdown trước 17:00 hoặc tắt "Tóm tắt tự động" | Nút "Soạn bằng AI" trên SCR-07 → bước 2 ngay |
| A2 | Task xong thêm sau khi có nháp | Người dùng chưa sửa → soạn lại khi mở bước. Đã sửa → giữ bản sửa, hiện MSG-13 "Thêm vào" |
| A3 | "Soạn lại" | Tạo nháp mới; người dùng đã sửa → hỏi xác nhận ghi đè |
| A4 | Ngày không có task xong | Không soạn; SCR-07 hiện trạng thái rỗng của G08 |
| A5 | Công cụ G11 lỗi / chưa kết nối | Soạn chỉ từ task trong app, ghi chú nhỏ "Chưa gồm hoạt động từ {công cụ}" |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | LLM lỗi / > 10 giây khi người dùng đang mở bước | MSG-05; hiện danh sách việc đã xong để biên tập tay (G08); "Thử lại" |
| E2 | Job 17:00 lỗi | Thử lại 2 lần cách 5 phút `[giả định]`; vẫn lỗi → không có nháp, A1 dùng được |

### UC-06 Gửi phản hồi về AI

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có câu trả lời Sunny, Review Plan hoặc nháp highlights |
| Hậu điều kiện thành công | \[AiFeedback\] lưu: đánh giá, nội dung tuỳ chọn, `proposalId`, phiên bản model / prompt |
| Hậu điều kiện thất bại | Không lưu; không ảnh hưởng thao tác khác |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Hữu ích" / "Chưa tốt" hoặc "Gửi phản hồi" → **SCR-08** |
| 2 | Người dùng | Chọn lý do (sai ngày, sai task, quá nhiều thay đổi, ngôn ngữ, khác), ghi thêm (≤ 1.000 ký tự), tuỳ chọn "Đính kèm cuộc trò chuyện" (mặc định tắt) |
| 3 | Hệ thống | Gọi \[AiFeedback\]; toast MSG-16 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng hoàn tác (UC-04) | Hệ thống tự ghi tín hiệu `undo` vào \[AiFeedback\], không kèm nội dung task |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[AiFeedback\] lỗi | Thử lại nền 3 lần; không báo lỗi cho người dùng |

### UC-07 Cài đặt AI

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng mở Cài đặt (khung trang do G01) |
| Hậu điều kiện thành công | Cài đặt lưu ngay, áp dụng ngay trên mọi thiết bị (`settings.changed`) |
| Hậu điều kiện thất bại | Toggle trả về giá trị cũ, MSG-14 |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → AI (**SCR-09**) hoặc Cài đặt → Beta |
| 2 | Người dùng | Đổi một cài đặt |
| 3 | Hệ thống | Gọi \[SettingsUpdate\] (G01 `PATCH /me/settings`); áp BR-16 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tắt "Trợ lý" khi khung chat đang mở | Đóng khung chat; lượt đang `DANG_XU_LY` bị huỷ |
| A2 | Tắt Beta "Agentic Daily Planning" khi có đề xuất `CHO_DUYET` | Đề xuất → `DA_HOAN_TAC`; Daily planning dùng luồng thủ công |
| A3 | "Xoá lịch sử trò chuyện" | Xác nhận MSG-17 → xoá mọi cuộc trò chuyện; chip cũ mất nút Hoàn tác, hoàn tác vẫn làm được từ nhật ký task |

### UC-08 Chạy bộ đánh giá trước khi đổi model / prompt

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có cấu hình AI mới (model, prompt, tham số) ở môi trường kiểm thử |
| Hậu điều kiện thành công | Báo cáo đạt BR-18; cấu hình được đánh dấu "được phép phát hành" |
| Hậu điều kiện thất bại | Cấu hình bị chặn; production giữ cấu hình cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Kỹ sư AI | Tạo pull request đổi model / prompt |
| 2 | Hệ thống (CI) | Chạy \[EvalRun\] trên bộ ≥ 200 câu Việt / Anh, nhóm: ngày giờ (gồm EC-01 lúc 02:10), thao tác task, ngưỡng > 3 task (EC-37), hoàn tác (EC-38), hành động bị cấm, lệnh ẩn trong dữ liệu, ngôn ngữ, highlights |
| 3 | Hệ thống | Mỗi câu chạy với `now` cố định; chấm theo hành động mong đợi (đúng loại, đúng task, đúng ngày) và tiêu chí chữ |
| 4 | Hệ thống | Đạt BR-18 → gắn nhãn phát hành; lưu kết quả theo phiên bản |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | < 95% tổng hoặc < 100% nhóm rào chắn / ngày giờ | Chặn merge; báo cáo liệt kê câu sai |
| E2 | Nhà cung cấp LLM lỗi khi chạy | Chạy lại câu lỗi tối đa 2 lần; vẫn lỗi → coi là sai |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** | **Ghi chú** |
| --- | --- | --- | --- |
| Nút ✨ góc dưới mọi màn hình | ✓ | ✓ | Mở SCR-04 |
| Command menu (Ctrl/Cmd+K) "Hỏi Sunny" | ✓ | ✓ (desktop) | Phím tắt riêng `[giả định: Ctrl+J]` |
| Daily planning (G08) → "Plan my day" | ✓ | ✓ | Chỉ khi bật Beta; SCR-02 |
| Daily shutdown (G08) → bước highlights | ✓ | ✓ | SCR-07 |
| Nhật ký AI trong chi tiết task (G02 SCR-03) | ✓ | ✓ | Hoàn tác thay đổi AI (UC-04) |
| Cài đặt → AI / Beta | ✓ | ✓ | SCR-09 |

## 7. Mô tả màn hình

### SCR-01 Thiết lập Planning Agent

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Thanh bước | Stepper | – | Công cụ · Kể về bạn · Theme days |
| 2 | Danh sách nguồn | List | Không | Lịch (G05), Gmail / Jira / Notion (G11) với trạng thái; "Kết nối" mở luồng nhóm sở hữu |
| 3 | Kể về bạn | Text nhiều dòng | Không | ≤ 1.000 ký tự `[giả định]`; quá → MSG-02 |
| 4 | Theme days | 7 ô text | Không | Mỗi ô ≤ 100 ký tự `[giả định]` |
| 5 | "Bỏ qua" / "Tiếp" / "Xong" | Button | – | Xong → \[AgentProfileSave\] |

### SCR-02 Planning Agent — nhập và chạy

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Nhãn Beta | Badge | – | "Beta" |
| 2 | "Điều quan trọng nhất hôm nay là gì?" | Text | Không | ≤ 500 ký tự `[giả định]` |
| 3 | "Plan my day" | Button chính | – | Disabled khi hết lượt (MSG-11) hoặc offline |
| 4 | "Tự lập kế hoạch" | Link | – | Sang Daily planning thủ công (G08) |
| 5 | Tiến độ | List bước | – | Hiện khi `DANG_XU_LY`: "Đọc lịch", "Đọc việc từ công cụ", "Xếp khối thời gian"; bộ đếm thời gian; "Thường mất 2–4 phút" |
| 6 | "Dừng" | Button | – | Huỷ lượt → luồng thủ công, không áp dụng gì |

### SCR-03 Review Plan

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tóm tắt | Text | "Planning Agent đề xuất thêm 3 task, dời 2 task" |
| 2 | Danh sách thay đổi | List có checkbox | Nhóm "HÔM NAY · n thay đổi"; mỗi dòng: loại (Thêm / Dời / Timebox / Sắp lại), tiêu đề, giá trị trước → sau, ngày giờ cụ thể (BR-04); mặc định chọn hết |
| 3 | Tổng khối lượng | Text | Tổng planned sau khi áp dụng so ngưỡng (G04); đỏ khi vượt |
| 4 | "Lập lại" | Button | UC-02 A1 |
| 5 | "Huỷ tất cả" | Button | UC-02 A2 |
| 6 | "Gửi phản hồi" | Link | SCR-08 |
| 7 | "Tiếp" | Button chính | \[ProposalApply\] các dòng được chọn; disabled khi không chọn dòng nào (khi đó dùng "Huỷ tất cả") |

### SCR-04 Khung chat Sunny

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Header | Toolbar | – | "Lịch sử" · "Cuộc trò chuyện mới" · đóng |
| 2 | Ô nhập | Text nhiều dòng | Có | Placeholder "Mô tả một task hoặc đặt câu hỏi"; 1–2.000 ký tự (MSG-02); Enter gửi, Shift+Enter xuống dòng |
| 3 | Tin nhắn người dùng | Bubble | – | Nguyên văn |
| 4 | Trạng thái xử lý | Text | – | "Đang nghĩ…" + giây; > 10 giây "Vẫn đang xử lý…" + "Dừng"; xong "Đã nghĩ {n}s" (Sunsama "Thought 8s") |
| 5 | Câu trả lời | Bubble (stream) | – | Ngôn ngữ theo BR-12; mọi ngày ghi cụ thể |
| 6 | Chip task | Card nhỏ | – | Tiêu đề, ngày giờ, channel, "Hoàn tác"; bấm tiêu đề mở chi tiết task (G02); đã hoàn tác → gạch ngang "Đã hoàn tác" |
| 7 | Nút chọn ngày (BR-05) | 2 button | – | Hiện khi khung mơ hồ; chọn → tiếp tục hành động |
| 8 | Thẻ xác nhận | SCR-05 | – | Khi > 3 task |
| 9 | "Hữu ích" / "Chưa tốt" | Icon button | – | UC-06 |

### SCR-05 Thẻ xác nhận thay đổi nhiều task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Text | "Sunny sẽ thay đổi {n} task" |
| 2 | Danh sách | List có checkbox | Mỗi dòng: tiêu đề task, trường đổi, trước → sau (ngày cụ thể); tối đa hiện 10 dòng, "Xem thêm" |
| 3 | "Áp dụng" | Button chính | \[ProposalApply\] dòng được chọn |
| 4 | "Huỷ" | Button | \[ProposalReject\]; thẻ xám "Đã huỷ" |

### SCR-06 Xung đột khi hoàn tác

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-18 |
| 2 | Danh sách xung đột | List | Mỗi dòng: task, trường, giá trị trước AI · giá trị AI · giá trị hiện tại (của bạn); radio "Giữ bản của tôi" (mặc định) / "Trả về trước khi AI sửa" |
| 3 | "Áp dụng cho tất cả" | Toggle | Dùng một lựa chọn cho mọi dòng |
| 4 | "Xác nhận" / "Huỷ" | Button | Xác nhận → \[ProposalUndo\] kèm `resolutions` |

### SCR-07 Highlights AI (trong bước highlights của Daily shutdown, G08)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nhãn nguồn | Badge | "✨ Nháp AI lúc 17:00"; mất khi người dùng sửa |
| 2 | Danh sách ý | Rich text bullet | Sửa tại chỗ; mỗi ý có link về task / item nguồn |
| 3 | Thông báo việc mới | Inline | MSG-13 + "Thêm vào" (UC-05 A2) |
| 4 | "Soạn bằng AI" / "Soạn lại" | Button | UC-05 A1 / A3 |
| 5 | "Hữu ích" / "Chưa tốt" | Icon button | UC-06 |
| 6 | Trạng thái đang soạn / lỗi | Inline | "Đang soạn…" / MSG-05 + "Thử lại" |

### SCR-08 Gửi phản hồi

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Lý do | Chip chọn nhiều | Không | Sai ngày · Sai task · Quá nhiều thay đổi · Ngôn ngữ · Khác |
| 2 | Ghi thêm | Text | Không | ≤ 1.000 ký tự |
| 3 | Đính kèm cuộc trò chuyện | Checkbox | Không | Mặc định tắt |
| 4 | "Gửi" | Button | – | \[AiFeedback\]; MSG-16 |

### SCR-09 Cài đặt → AI

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Trợ lý | Toggle | – | Mặc định bật; BR-16 |
| 2 | Gợi ý channel | Toggle | – | Mặc định bật (hành vi G02) |
| 3 | Gợi ý thời lượng (task, subtask) | Toggle | – | Mặc định bật (hành vi G02) |
| 4 | Ngôn ngữ tóm tắt | Dropdown | – | Auto / Tiếng Việt / English; mặc định Auto |
| 5 | Tóm tắt tự động | Toggle | – | Mặc định bật; nháp T2–T6 17:00 |
| 6 | Thiết lập Planning Agent | Link | – | Mở SCR-01; ẩn khi Beta tắt |
| 7 | Xoá lịch sử trò chuyện | Button nguy hiểm | – | UC-07 A3 |
| 8 | Beta → Agentic Daily Planning | Toggle | – | Ở nhóm Beta; mặc định tắt `[giả định]` |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[AgentProfileGet\] / \[AgentProfileSave\] `GET/PUT /ai/agent-profile` | about, themeDays[7], sources[] | AgentProfile | 5s / 1 lần |
| \[AgentPlanStart\] `POST /ai/planning/{date}/runs` | focusText, context (BR-03), Idempotency-Key | proposalId, status `DANG_XU_LY` | 5s nhận yêu cầu / không retry; bước đầu ≤ 10s, tổng ≤ 5 phút (BR-09) |
| \[ProposalGet\] `GET /ai/proposals/{id}` | id | Proposal: status, steps[], changes[] (type, taskId, field, before, after), modelVersion | 5s / 2 lần; realtime `ai.proposal.updated` là kênh chính |
| \[ProposalApply\] `POST /ai/proposals/{id}/apply` | changeIds[], Idempotency-Key | Proposal, tasks[] | 10s / 2 lần cùng key; giao dịch toàn phần |
| \[ProposalReject\] `POST /ai/proposals/{id}/reject` | id, reason? | Proposal `DA_HOAN_TAC` | 5s / 2 lần |
| \[ProposalUndo\] `POST /ai/proposals/{id}/undo` | changeIds[], resolutions[] {changeId, keep: user\|before} | Proposal, tasks[], conflicts[] (nếu chưa có resolutions) | 5s / 2 lần |
| \[ChatThreadList\] / \[ChatThreadCreate\] / \[ChatThreadDelete\] `GET/POST/DELETE /ai/chat/threads` | cursor, limit / – / id | Thread[] / Thread | 5s / 1 lần |
| \[ChatSend\] `POST /ai/chat/threads/{id}/messages` (SSE) | text, context (BR-03), viewDate, selectedTaskId | Stream: delta chữ, `thinkingMs`, proposal (nếu có) | Chữ đầu ≤ 10s; tổng ≤ 60s; không tự retry (nút "Gửi lại") |
| \[HighlightsDraft\] `POST /ai/highlights/{date}/draft` · `GET /ai/highlights/{date}` | date, language | Proposal (bullets[] {text, taskId?, itemRef?}) | 10s / 1 lần (người dùng mở); job: 2 lần cách 5 phút |
| \[AiFeedback\] `POST /ai/feedback` | proposalId?, rating, reasons[], text, attachConversation | 204 | 5s / 3 lần nền |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | ai.assistantEnabled, ai.summaryLanguage, ai.autoSummary, beta.agenticPlanning | Settings | 5s / 2 lần |
| \[IntegrationActivity\] (G11) | date | Hoạt động trên công cụ | 5s / 1 lần; lỗi → bỏ qua (UC-05 A5) |
| \[EvalRun\] (nội bộ CI) | configVersion, datasetVersion | passRate, theo nhóm, câu sai[] | 30 phút / chạy lại câu lỗi 2 lần |
| \[AppConfig\] | – | Ngưỡng BR-06, BR-09, BR-14, BR-15 | Cache 1h |

Job: `ai.highlights.draft` (mỗi 15 phút quét người dùng vừa tới 17:00 T2–T6, idempotent theo user + ngày), `ai.proposal.expire` (đóng `CHO_DUYET` > 24 giờ). Realtime mới: `ai.proposal.updated` `[giả định]`.

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field text / about · TOO_LONG | MSG-02 |
| `AI_TIMEOUT` / `AI_UNAVAILABLE` (chat) | MSG-04 |
| `AI_TIMEOUT` / `AI_UNAVAILABLE` / `AI_CONTEXT_MISSING` (planning, highlights) | MSG-05 |
| `AI_ACTION_FORBIDDEN` | MSG-07 |
| `AI_DATE_AMBIGUOUS` | MSG-08 |
| `AI_UNDO_EXPIRED` | MSG-10 |
| `AI_UNDO_CONFLICT` (409) | SCR-06 / MSG-18 |
| `AI_QUOTA_EXCEEDED` (429) | MSG-11 |
| `PROPOSAL_STALE` (412, task đổi sau khi đề xuất) | MSG-15 |
| `WORKSPACE_READ_ONLY` (402) | MSG-12 |
| Mất mạng | MSG-06 |
| 5xx khác | MSG-14 |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Inline SCR-01 | Kết nối lịch và công cụ để agent thấy đủ việc của bạn. Có thể làm sau |
| MSG-02 | Inline | Nội dung quá dài (tối đa {n} ký tự) |
| MSG-03 | SCR-03 | Kế hoạch hôm nay đã ổn, agent không đề xuất thay đổi |
| MSG-04 | Khung chat | Sunny chưa trả lời được. Gửi lại |
| MSG-05 | Banner | AI đang gặp sự cố. Bạn tiếp tục lập kế hoạch thủ công, nội dung đã nhập vẫn được giữ |
| MSG-06 | Banner | Mất kết nối. AI cần mạng để hoạt động |
| MSG-07 | Khung chat | Mình không thể {xoá task / gửi tin ra ngoài / đổi cài đặt}. Bạn có thể tự làm: {cách làm} |
| MSG-08 | Khung chat | Bây giờ là {giờ} ngày {ngày}. "{cụm từ}" là ngày nào? |
| MSG-09 | Toast | Đã hoàn tác {n} thay đổi của AI |
| MSG-10 | Toast | Thay đổi này đã quá 7 ngày, không hoàn tác bằng AI được. Hãy sửa trực tiếp task |
| MSG-11 | Inline | Bạn đã dùng hết lượt AI hôm nay. Lượt mới có từ {giờ} ngày {ngày} |
| MSG-12 | Khung chat | Workspace đang ở chế độ chỉ đọc nên Sunny chưa thể thay đổi task |
| MSG-13 | Inline SCR-07 | Có {n} việc mới xong sau khi soạn nháp · Thêm vào |
| MSG-14 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-15 | Inline | Kế hoạch vừa thay đổi ở nơi khác. Lập lại để agent dùng dữ liệu mới |
| MSG-16 | Toast | Cảm ơn bạn đã góp ý |
| MSG-17 | Dialog | Xoá toàn bộ lịch sử trò chuyện? Task đã tạo không bị ảnh hưởng |
| MSG-18 | Dialog SCR-06 | Bạn đã sửa {n} chỗ sau khi AI thay đổi. Chọn giữ bản nào |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Kết quả đầu tiên ≤ 10 giây (p95), luôn có trạng thái đang xử lý; Planning Agent 2–4 phút, tối đa 5 phút; \[ProposalApply\] p95 ≤ 1 giây cho ≤ 30 thay đổi; chip / board cập nhật ≤ 100 ms sau khi áp dụng |
| Offline | AI không chạy offline (MSG-06); Daily planning / shutdown thủ công vẫn chạy (G08); hoàn tác AI cần mạng |
| Đồng bộ | Thay đổi AI hiện trên thiết bị khác ≤ 5 giây (`task.upserted`, `ai.proposal.updated`) |
| Bảo mật | BR-01, BR-02, BR-11 kiểm ở server; dữ liệu gửi LLM theo BR-10; khoá API nhà cung cấp chỉ ở server; mỗi lượt chỉ đọc dữ liệu của người dùng đang gọi |
| Quyền riêng tư | Nhà cung cấp LLM không lưu, không huấn luyện (hợp đồng); Nghị định 13/2023/NĐ-CP, GDPR (cần pháp chế xác nhận); lịch sử chat giữ 90 ngày, xoá được; xuất dữ liệu (G01) gồm lịch sử chat |
| Log / audit | \[ActivityLog\] tác nhân `ai` (BR-07); log lượt AI: proposalId, modelVersion, promptVersion, số token, độ trễ, kết quả \[AiActionExecutor\]; không ghi nội dung tin nhắn vào log hệ thống |
| Chất lượng | Bộ đánh giá BR-18; theo dõi hằng tuần tỉ lệ hoàn tác, "Chưa tốt", chuyển luồng thủ công |
| Chi phí | Hạn mức BR-14, BR-15; cảnh báo khi chi phí LLM / người dùng / ngày vượt ngưỡng cấu hình |
| Tracking | Sự kiện: `ai_chat_opened`, `ai_message_sent`, `ai_proposal_created` (loại, số task), `ai_proposal_applied`, `ai_proposal_rejected`, `ai_change_undone`, `ai_undo_conflict`, `ai_date_clarify_shown`, `ai_action_forbidden`, `planning_agent_started`, `planning_agent_fallback`, `highlights_draft_created`, `highlights_saved` (tỉ lệ sửa), `ai_feedback_sent` |
| Accessibility | Khung chat đọc được bằng trình đọc màn hình (vùng `aria-live` cho câu trả lời stream); chip, checkbox, radio dùng được bằng bàn phím; ✨ có nhãn "Gợi ý của AI"; tương phản WCAG 2.1 AA sáng / tối |
