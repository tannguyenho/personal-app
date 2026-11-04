> **Mã:** PLN-SRS-G10-WEB · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g10-tro-ly-ai.md

# UC-G10 - Trợ lý AI trên Web / App (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này chỉ mô tả Planning Agent, trợ lý chat Sunny, highlights AI cuối ngày, rào chắn, cài đặt AI và bộ đánh giá (bản 1.2). Gợi ý thời lượng / channel khi tạo task (G02, 1.0), Daily planning / Daily shutdown thủ công và chia sẻ (G08), timebox (G05), Weekly planning / objective (G09), kết nối công cụ (G11), hạn mức theo gói và Privacy (G12) đặc tả ở SRS riêng của từng nhóm. Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0".
>
> **Cập nhật 04/11/2026** theo [quyết định chốt mâu thuẫn](../review/quyet-dinh-chot-2026-11-04.md) và [ADR-0003](../adr/0003-gioi-han-quyen-cua-tro-ly-ai.md). Quy tắc dùng chung tham chiếu [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md): ngày làm việc QC-01, lịch làm việc QC-02, đổi ngày task QC-05, đồng bộ QC-08, chế độ chỉ đọc QC-09 và quyền theo gói QC-10 (cả hai có từ 1.1 nên áp dụng ngay cho bản 1.2).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng lập kế hoạch ngày với agent, thao tác task bằng ngôn ngữ tự nhiên và có nháp highlights cuối ngày; mọi thay đổi AI nhìn thấy được, đúng ngày và hoàn tác được |
| Actor | Người dùng đã đăng nhập · Hệ thống · Dịch vụ AI (\[AiGateway\] → nhà cung cấp LLM) · Bộ thực thi hành động AI (\[AiActionExecutor\]) · Kỹ sư AI (bộ đánh giá) |
| Phạm vi | Đồng ý dùng AI lần đầu, công tắc dữ liệu tích hợp, thiết lập và chạy Planning Agent, Review Plan, "Hoàn tác kế hoạch AI", chat Sunny (hỏi đáp, ra lệnh, lịch sử), duyệt thay đổi > 3 task hoặc có dữ liệu ngoài, hoàn tác hành động AI, highlights AI, phản hồi, cài đặt AI / Beta, xoá dữ liệu tích hợp khỏi lịch sử AI, bộ đánh giá |
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
| US-10 | Người dùng | Đồng ý trước khi dữ liệu của tôi được gửi cho AI, và tự quyết có cho AI đọc dữ liệu công cụ đã kết nối không | Dữ liệu không bị gửi đi khi tôi chưa biết; email lạ không điều khiển được AI |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Hành động được phép.** AI chỉ được: tạo task, sửa tiêu đề / planned / channel / priority / due, thêm subtask, dời ngày / vào backlog, sắp thứ tự, timebox / gỡ timebox (G05), gắn objective (G09) (Q20, ADR-0003). Dời ngày và đưa vào backlog theo QC-05 (dòng "AI dời ngày" và "Đưa vào backlog", Q14). Tạo task từ item tích hợp theo BR-24. Mọi hành động đi qua \[AiActionExecutor\] ở server, kiểm danh sách này độc lập với model |
| BR-02 | **Hành động bị cấm.** Xoá task / subtask, đánh dấu hoặc bỏ đánh dấu hoàn thành task / subtask (Q20), gửi tin ra ngoài (email, Slack, Teams, chia sẻ ritual), đổi cài đặt, kết nối / ngắt tích hợp, đọc / sửa dữ liệu người khác. Yêu cầu loại này → trả lời từ chối MSG-07 kèm cách tự làm; \[AiActionExecutor\] trả `AI_ACTION_FORBIDDEN` nếu model vẫn sinh hành động |
| BR-03 | **Ngữ cảnh thời gian bắt buộc.** Mọi lượt gọi LLM gửi: `now` (ISO 8601 có offset), timezone IANA, `dayStartTime` (mốc đầu ngày), `currentWorkday` = `workday(now)` (QC-01), lịch làm việc (QC-02), locale. Thiếu trường nào → không gọi LLM, ghi lỗi `AI_CONTEXT_MISSING` |
| BR-04 | **Ngày tuyệt đối.** Hành động có ngày phải mang ngày `YYYY-MM-DD` và giờ tuyệt đối; server từ chối ngày ngoài ± 1 năm so với hôm nay `[giả định]` và từ chối đặt task chưa xong vào ngày < hôm nay (QC-05). Chip, thẻ xác nhận, Review Plan luôn hiện ngày cụ thể ("Thứ Năm, 5/11") |
| BR-05 | **Ngày tương đối (EC-01, Q2, C33).** "Hôm nay / tối nay / today / tonight" = `workday(now)`; "ngày mai / sáng mai / tomorrow" = `workday(now)` + 1 ngày (QC-01). **Khung mơ hồ:** khi ngày lịch của `now` khác `workday(now)` (từ 00:00 tới mốc đầu ngày) và yêu cầu chứa "ngày mai / sáng mai / tomorrow" → không thực hiện, hỏi lại MSG-08 bằng 2 lựa chọn: `workday(now)` + 1 và `workday(now)` + 2. Mốc đầu ngày = 00:00 thì không có khung mơ hồ. Bảng ví dụ của QC-01 là ca chuẩn (ví dụ mốc 04:00, 02:10 ngày 4/11: "hôm nay" = Thứ Ba 3/11; "ngày mai" → hỏi "Thứ Tư, 4/11" / "Thứ Năm, 5/11") |
| BR-06 | **Áp dụng ngay hay chờ duyệt (EC-37, Q31/Q31a, Q21).** Đếm số task khác nhau bị ảnh hưởng; `hasExternalData` = ngữ cảnh lượt đó có dữ liệu tích hợp G11 (BR-20). **Chat:** ≤ 3 task và `hasExternalData = false` → áp dụng ngay, hiện chip kèm Hoàn tác; > 3 task hoặc `hasExternalData = true` → `CHO_DUYET`, hiện **SCR-05**. **Planning Agent:** `hasExternalData = false` → áp dụng ngay bất kể số task (ngoại lệ có chủ đích của EC-37), hiện **SCR-03** chế độ "Đã áp dụng" kèm "Hoàn tác kế hoạch AI"; `hasExternalData = true` → `CHO_DUYET`, SCR-03 chế độ "Chờ duyệt". Ngưỡng 3 lấy từ \[AppConfig\] |
| BR-07 | **Nhật ký.** Mọi thay đổi AI ghi \[ActivityLog\] (G02) với tác nhân `ai`, `aiAgent` (`assistant` / `planning_agent` / `highlights`) và `proposalId`. Hiển thị: "Planning Agent đã tạo task này", "Sunny đã dời sang Thứ Năm, 5/11" |
| BR-08 | **Hoàn tác (EC-38).** Hoàn tác theo từng thay đổi hoặc cả đề xuất, trong 7 ngày `[giả định]` kể từ khi áp dụng. Chỉ trả lại các trường AI đã đổi về giá trị trước AI. Trường người dùng đã sửa sau AI, hoặc task AI tạo đã được người dùng thêm subtask / notes / comment / thời gian thực tế → thay đổi đó ở `XUNG_DOT`, hỏi qua **SCR-06**. Hoàn tác "tạo task" = xoá mềm vào Thùng rác (G02 UC-04 A3). Hoàn tác "dời ngày" / "vào backlog" = trả ngày dự định hoặc bucket cũ và khôi phục liên kết timebox theo QC-05 (mục Hoàn tác); ngày cũ < hôm nay → về hôm nay `[giả định]` (QC-05 chặn ngày quá khứ). "Hoàn tác kế hoạch AI" = hoàn tác mọi thay đổi `DA_AP_DUNG` của một đề xuất Planning Agent |
| BR-09 | **Thời gian chờ.** Kết quả đầu tiên (token chữ hoặc bước tiến độ) ≤ 10 giây. Chat: quá 10 giây vẫn chờ, hiện "Vẫn đang xử lý…" và nút Dừng; quá 60 giây `[giả định]` → `LOI`. Planning Agent: lỗi, hoặc 10 giây chưa có bước đầu, hoặc tổng > 5 phút `[giả định]` → `LOI` và chuyển luồng thủ công G08 (EC-39) |
| BR-10 | **Dữ liệu gửi LLM tối thiểu.** Chỉ gửi: tiêu đề, planned, actual, channel (tên), ngày, trạng thái task trong khoảng ngày cần (mặc định hôm nay ± 7 ngày `[giả định]`); sự kiện lịch (tiêu đề, giờ, busy); tiêu đề item tích hợp chỉ khi bật BR-20. Notes / comment chỉ gửi khi người dùng nhắc đích danh task đó. Không gửi nội dung email, email người khác, token. Chỉ gửi sau khi có đồng ý (BR-19). Hợp đồng nhà cung cấp: không lưu, không huấn luyện |
| BR-11 | **Dữ liệu ngoài là dữ liệu.** Tiêu đề task, notes, email, item tích hợp không được coi là lệnh; BR-01, BR-02, BR-06 kiểm ở \[AiActionExecutor\], không dựa vào model. \[AiGateway\] gắn `hasExternalData` cho lượt có dữ liệu G11 trong ngữ cảnh, và \[AiActionExecutor\] buộc mọi hành động của lượt đó vào `CHO_DUYET` (BR-06) |
| BR-12 | **Ngôn ngữ.** Chat trả lời theo ngôn ngữ tin nhắn gần nhất của người dùng. Highlights theo cài đặt "Ngôn ngữ tóm tắt"; Auto = ngôn ngữ giao diện `[giả định]` |
| BR-13 | **Highlights.** Trợ lý bật, đã đồng ý (BR-19) và bật "Tóm tắt tự động" → \[HighlightsDraft\] chạy 17:00 T2–T6 `[giả định]` theo timezone người dùng; ngày không có task xong → không soạn. Nguồn: task `HOAN_THANH` trong ngày làm việc (QC-01) + hoạt động công cụ (\[IntegrationActivity\], G11) chỉ khi bật BR-20; hoạt động chỉ gồm việc do chính tài khoản đã kết nối thực hiện, Gmail không có hoạt động "đóng" (C28, G11 BR-19). Nháp ở `CHO_DUYET`, chỉ thành highlights của ritual khi người dùng hoàn tất bước highlights (G08). Đã có bản người dùng sửa → không ghi đè, chỉ gợi ý thêm |
| BR-14 | **Planning Agent.** Chỉ chạy khi trợ lý bật, đã đồng ý (BR-19) và bật Beta "Agentic Daily Planning". Số lượt / ngày theo BR-22. Một ngày chỉ có 1 lượt agent ở `DANG_XU_LY` / `CHO_DUYET`. "Lập lại": đề xuất cũ đang `CHO_DUYET` → `DA_HOAN_TAC` (`rejected = true`); đề xuất cũ đã `DA_AP_DUNG` → hoàn tác cả kế hoạch (UC-04) trước; rồi tạo đề xuất mới |
| BR-15 | **Chat.** Tin nhắn 1–2.000 ký tự `[giả định]`; số tin / ngày theo BR-22; lịch sử giữ 90 ngày `[giả định]`; người dùng xoá được cuộc trò chuyện (xoá nội dung chat, không đụng task đã tạo); ngắt tích hợp → BR-23 |
| BR-16 | **Tắt AI.** Tắt "Trợ lý" → ẩn nút ✨, không gọi LLM cho chat, Planning Agent và highlights (kể cả job 17:00); `aiConsentAt` giữ nguyên. Planning Agent cần thêm Beta bật. Gợi ý planned / channel có cài đặt riêng (G02) |
| BR-17 | **Chế độ chỉ đọc (QC-09, Q8).** Workspace chỉ đọc → \[AiGateway\] không gọi AI cho mọi tính năng, kể cả job highlights; khung chat hiện MSG-12, ô nhập disabled; "Plan my day" disabled. Đề xuất `CHO_DUYET` không áp dụng được (402) |
| BR-18 | **Bộ đánh giá.** ≥ 200 câu Việt / Anh; đạt ≥ 95% tổng `[giả định]` và 100% nhóm "rào chắn", "ngày giờ" và "lệnh ẩn trong dữ liệu" (Q21); nhóm "ngày giờ" chứa mọi dòng của bảng ví dụ QC-01 làm ca chuẩn (C33); chạy trước mỗi lần đổi model hoặc prompt; không đạt → chặn phát hành cấu hình đó |
| BR-19 | **Đồng ý dùng AI (Q21, ADR-0003).** `ai.assistantEnabled` mặc định `false` với mọi người dùng. Lần đầu bật (✨, "Plan my day", "Soạn bằng AI", toggle "Trợ lý") khi `aiConsentAt` trống → mở **SCR-10**; "Đồng ý và bật" lưu `aiConsentAt` (thời điểm server nhận) và `aiConsentVersion`, bật trợ lý, tiếp tục thao tác đang dở; "Để sau" → không đổi gì. Khi `aiConsentAt` trống, \[AiGateway\] từ chối mọi lời gọi với `AI_CONSENT_REQUIRED`, kể cả job `ai.highlights.draft`. Bật lại sau khi tắt không hỏi lại `[giả định]`. **Rút lại đồng ý** (G01 BR-23c giao cho G10, C5): "Rút lại đồng ý dùng AI" ở SCR-09 → xoá `aiConsentAt`, tắt trợ lý, huỷ lượt đang chạy, đóng đề xuất `CHO_DUYET`; lần bật sau phải qua SCR-10. Lịch sử chat có bị xoá khi rút lại không: `[giả định: giữ, người dùng tự xoá]`. Mọi lần đồng ý / rút lại ghi nhật ký bảo mật G01 BR-21 |
| BR-20 | **Dữ liệu tích hợp trong ngữ cảnh AI (Q21).** Cài đặt `ai.useIntegrationData` mặc định `false`. `false` → \[AiGateway\] không đưa item, tiêu đề item hay \[IntegrationActivity\] của G11 vào bất kỳ ngữ cảnh nào (chat, Planning Agent, highlights). `true` → được đưa vào; lượt có dữ liệu này gắn `hasExternalData = true` và theo BR-06 |
| BR-21 | **Áp dụng đề xuất (C31).** \[ProposalApply\] kiểm `version` từng task: task đã đổi sau khi đề xuất, hoặc thay đổi có giờ bắt đầu đã qua, hoặc ngày < hôm nay → chỉ loại dòng đó (`SKIPPED_STALE` / `SKIPPED_PAST`), các dòng khác vẫn áp dụng; báo MSG-19. Mọi dòng bị loại → đề xuất giữ `CHO_DUYET`, MSG-15 kèm "Lập lại"; "Lập lại" vì lỗi thời không trừ lượt. Đề xuất `CHO_DUYET` hết hạn ở mốc đầu ngày của ngày làm việc kế tiếp (cuối ngày làm việc tạo đề xuất) → `DA_HOAN_TAC` (`expired = true`) |
| BR-22 | **Hạn mức (C32, QC-10).** Ba bộ đếm riêng theo ngày làm việc: tin nhắn chat, lượt Planning Agent, lượt "Soạn bằng AI" / "Soạn lại" highlights do người dùng bấm. Con số đọc từ bảng quyền theo gói của G12, không viết cứng. Lượt kết thúc `LOI` không trừ; "Lập lại" vì đề xuất lỗi thời không trừ (BR-21); lượt người dùng bấm "Dừng" có trừ `[giả định]`. Job nháp 17:00 không trừ `[giả định]`. Hết lượt → `AI_QUOTA_EXCEEDED`, MSG-11 nêu đúng loại hạn mức |
| BR-23 | **Ngắt tích hợp (C30).** Nhận sự kiện ngắt tích hợp từ G11 (`integration.disconnected`) → job `ai.history.purgeIntegration` xoá dữ liệu của tích hợp đó trong lịch sử AI: ngữ cảnh lưu kèm đề xuất, `itemRef` và nội dung item trong câu trả lời, nháp highlights; chỗ bị xoá hiện MSG-21. Tin nhắn người dùng tự gõ giữ nguyên `[giả định]`. Task đã tạo và \[ActivityLog\] giữ nguyên |
| BR-24 | **Task từ item tích hợp (B14).** Hành động "tạo task từ item" của AI gọi G11 \[TaskFromItem\] với `actor = ai`, không tạo task thường. G11 trả `ALREADY_LINKED` → bỏ dòng "Thêm", thay bằng dòng "Đã có trong {ngày}" (không tính là thay đổi). AI không hoàn thành task nên không bao giờ đẩy trạng thái ra nguồn |

## 4. Trạng thái

### 4.1. Trạng thái đề xuất AI

Mỗi lượt AI có hành động (một tin chat, một lượt Planning Agent, một nháp highlights) tạo một \[AiProposal\].

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_XU_LY` | Đã gửi tới \[AiGateway\], chưa có kết quả cuối | Chat: "Đang nghĩ…" + bộ đếm giây. Agent: danh sách bước tiến độ. Highlights: "Đang soạn…" |
| `CHO_DUYET` | Có kết quả, chưa áp dụng: chat > 3 task hoặc `hasExternalData`; Planning Agent có `hasExternalData`; highlights; hoặc khung mơ hồ BR-05 | SCR-05 / SCR-03 chế độ "Chờ duyệt" / nháp có ✨ trong SCR-07 |
| `DA_AP_DUNG` | Ít nhất một thay đổi đã áp dụng, chưa hoàn tác hết | Chip task có "Hoàn tác"; SCR-03 chế độ "Đã áp dụng"; nhật ký task ghi tác nhân AI |
| `DA_HOAN_TAC` | Mọi thay đổi đã hoàn tác, hoặc người dùng Huỷ / Lập lại ở `CHO_DUYET` (`rejected = true`), hoặc `CHO_DUYET` hết hạn (`expired = true`, BR-21) | Chip gạch ngang "Đã hoàn tác" / thẻ xám "Đã huỷ" / "Đã hết hạn" |
| `LOI` | LLM lỗi, quá thời gian (BR-09), hoặc mọi hành động bị \[AiActionExecutor\] từ chối | MSG-04 / MSG-05; Planning Agent → luồng thủ công |

Chuyển trạng thái: `DANG_XU_LY` → `CHO_DUYET` | `DA_AP_DUNG` (chat ≤ 3 task không có dữ liệu ngoài; Planning Agent không có dữ liệu ngoài, BR-06) | `LOI` · `CHO_DUYET` → `DA_AP_DUNG` (Áp dụng / Áp dụng và tiếp) | `DA_HOAN_TAC` (Huỷ, Lập lại, hết hạn cuối ngày làm việc — BR-21) · `DA_AP_DUNG` → `DA_HOAN_TAC` (hoàn tác hết, gồm "Hoàn tác kế hoạch AI"). Đề xuất chỉ trả lời (không hành động) không lưu trạng thái.

### 4.2. Trạng thái từng thay đổi trong đề xuất

`CHUA_AP_DUNG` → `DA_AP_DUNG` → `DA_HOAN_TAC`. `CHUA_AP_DUNG` → `BO_QUA` khi bị loại lúc áp dụng vì lỗi thời hoặc giờ đã qua (BR-21). `DA_AP_DUNG` → `XUNG_DOT` khi hoàn tác gặp sửa đổi của người dùng (BR-08); người dùng chọn "Trả về trước AI" → `DA_HOAN_TAC`, chọn "Giữ bản của tôi" → giữ `DA_AP_DUNG`, cờ `keptByUser`. Đề xuất ở `DA_AP_DUNG` khi còn ≥ 1 thay đổi `DA_AP_DUNG`.

## 5. Use Case

### UC-01 Thiết lập Planning Agent

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Trợ lý bật và đã đồng ý (BR-19, nếu chưa → UC-09 trước); đã bật Beta "Agentic Daily Planning"; chưa có hồ sơ agent hoặc người dùng mở lại thiết lập |
| Hậu điều kiện thành công | Lưu \[AgentProfile\] (giới thiệu, theme days, nguồn dữ liệu được dùng); `setupCompletedAt` có giá trị |
| Hậu điều kiện thất bại | Không có hồ sơ; lần sau bấm "Plan my day" mở lại thiết lập |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Plan my day" lần đầu, hoặc Cài đặt → AI → "Thiết lập Planning Agent" |
| 2 | Hệ thống | Mở **SCR-01** phần 1 "Công cụ": liệt kê lịch (G05) và công cụ (G11) với trạng thái kết nối; nút "Kết nối" trỏ luồng của nhóm sở hữu; công tắc "Dùng dữ liệu từ công cụ đã kết nối" (BR-20, mặc định tắt) kèm MSG-20 |
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
| Tiền điều kiện | Trợ lý bật và đã đồng ý (BR-19); Beta bật; hồ sơ agent đã có (UC-01); người dùng đang ở Daily planning ngày D (G08); workspace không chỉ đọc (QC-09) |
| Hậu điều kiện thành công | Thay đổi hợp lệ đã áp dụng (hoặc, khi chờ duyệt, các dòng được chọn); đề xuất `DA_AP_DUNG`; nhật ký ghi `planning_agent`; ritual sang bước Daily plan (G08), nút "Hoàn tác kế hoạch AI" dùng được |
| Hậu điều kiện thất bại | Không thay đổi nào áp dụng; người dùng ở luồng Daily planning thủ công (G08), giữ nội dung đã nhập |

**Luồng chính** (kế hoạch không dùng dữ liệu tích hợp — áp dụng ngay, Q31)

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Trên **SCR-02** gõ "Điều quan trọng nhất hôm nay" (tuỳ chọn), bấm "Plan my day" |
| 2 | Hệ thống | Kiểm BR-19, BR-22; gọi \[AgentPlanStart\] với ngữ cảnh BR-03; tạo đề xuất `DANG_XU_LY`; hiện bước tiến độ (realtime `ai.proposal.updated`) |
| 3 | Dịch vụ AI | Đọc lịch ngày D, task hôm nay / rollover / backlog tới kỳ (G06), objective tuần (G09), hồ sơ agent, và item công cụ (G11) chỉ khi bật BR-20; sinh danh sách hành động trong BR-01 |
| 4 | Hệ thống | \[AiActionExecutor\] kiểm BR-01, BR-02, BR-04 cho từng hành động; hành động "tạo task từ item" theo BR-24; hành động hợp lệ thành thay đổi `CHUA_AP_DUNG`; `hasExternalData = false` → áp dụng ngay theo BR-21, đề xuất → `DA_AP_DUNG` (BR-06) |
| 5 | Hệ thống | Mở **SCR-03** Review Plan chế độ "Đã áp dụng": "Planning Agent đã thêm n task, dời m task", danh sách "HÔM NAY · n thay đổi" mỗi dòng có "Hoàn tác", tổng planned so ngưỡng khối lượng (G04), nút "Hoàn tác kế hoạch AI"; dòng bị loại (BR-21) hiện MSG-19 |
| 6 | Người dùng | Xem, hoàn tác dòng không muốn (UC-04); bấm "Tiếp" |
| 7 | Hệ thống | Chuyển bước Daily plan (G08); G08 hiện nút "Hoàn tác kế hoạch AI" gắn `proposalId` trong thời hạn hoàn tác (BR-08) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Lập lại" ở bước 6 | Mở ô "Muốn agent đổi gì?"; hoàn tác kế hoạch hiện tại theo UC-04 (gặp `XUNG_DOT` → SCR-06 trước); đề xuất cũ → `DA_HOAN_TAC`; quay lại bước 2 với chỉ dẫn thêm (BR-14) |
| A2 | "Hoàn tác kế hoạch AI" ở bước 6 (chế độ "Đã áp dụng") hoặc "Huỷ tất cả" (chế độ "Chờ duyệt") | Đã áp dụng → \[ProposalUndo\] mọi thay đổi `DA_AP_DUNG` (UC-04); chờ duyệt → \[ProposalReject\]. Đề xuất → `DA_HOAN_TAC`; về bước 1 của Daily planning thủ công (G08) |
| A3 | "Gửi phản hồi" | Mở **SCR-08**, không đổi trạng thái đề xuất |
| A4 | Hoàn tác sau khi đã "Tiếp" | Từ nhật ký task hoặc nút "Hoàn tác kế hoạch AI" ở bước Daily plan (G08) → UC-04 với mọi thay đổi `DA_AP_DUNG` của đề xuất; ở lại bước Daily plan, bản kế hoạch làm mới theo G08 |
| A5 | Agent không đề xuất thay đổi nào | Review Plan hiện MSG-03; "Tiếp" sang Daily plan |
| A6 | Một số hành động bị \[AiActionExecutor\] từ chối | Bỏ các hành động đó, ghi log; Review Plan chỉ hiện hành động hợp lệ |
| A7 | Hết lượt Planning Agent trong ngày (BR-22) | Nút "Plan my day" disabled, MSG-11 |
| A8 | Kế hoạch dùng dữ liệu tích hợp (`hasExternalData = true`, Q31a) | Bước 4: đề xuất → `CHO_DUYET`, không áp dụng gì. Bước 5: SCR-03 chế độ "Chờ duyệt" với MSG-22, mỗi dòng có checkbox (mặc định chọn hết). Bước 6: bỏ chọn dòng không muốn, bấm "Áp dụng và tiếp" → \[ProposalApply\] các dòng được chọn theo BR-21; đề xuất → `DA_AP_DUNG`; tiếp bước 7 |
| A9 | Đề xuất `CHO_DUYET` chưa duyệt tới cuối ngày làm việc (BR-21) | Job `ai.proposal.expire` → `DA_HOAN_TAC` (`expired`); SCR-03 hiện "Đã hết hạn", nút áp dụng disabled |
| A10 | Item đã có task (G11 trả `ALREADY_LINKED`, BR-24) | Dòng "Thêm" được thay bằng "Đã có trong {ngày}", không áp dụng gì cho dòng đó |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | 10 giây chưa có bước tiến độ đầu, LLM lỗi, hoặc tổng > 5 phút (EC-39) | Huỷ lượt, đề xuất → `LOI`, không áp dụng gì; MSG-05; mở Daily planning thủ công (G08) bước 1; nội dung "Điều quan trọng nhất" đưa vào ô "Obstacles in my way" |
| E2 | Thiếu ngữ cảnh thời gian (BR-03) | Như E1, log `AI_CONTEXT_MISSING` |
| E3 | \[ProposalApply\] gặp task đã bị xoá / sửa ở thiết bị khác, hoặc giờ đã qua (C31) | Chỉ loại các dòng đó (`BO_QUA`), các dòng khác vẫn áp dụng, MSG-19 (BR-21). Mọi dòng bị loại → đề xuất giữ `CHO_DUYET`; MSG-15 "Kế hoạch vừa thay đổi" và nút "Lập lại" (không trừ lượt) |
| E4 | Mất mạng | MSG-06; Daily planning thủ công vẫn dùng offline (G08) |
| E5 | Chưa có đồng ý (`AI_CONSENT_REQUIRED`) | Không gọi AI; mở UC-09 |

### UC-03 Trò chuyện và ra lệnh cho Sunny

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Cài đặt "Trợ lý" bật và đã đồng ý (BR-19); người dùng đã đăng nhập |
| Hậu điều kiện thành công | Câu trả lời hiện trong cuộc trò chuyện; nếu có hành động: áp dụng (≤ 3 task, không có dữ liệu ngoài) hoặc chờ duyệt (> 3 task hoặc có dữ liệu ngoài, BR-06); nhật ký ghi `assistant` |
| Hậu điều kiện thất bại | Không thay đổi task; tin nhắn của người dùng còn trong ô / lịch sử để gửi lại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm nút ✨ góc dưới → **SCR-04**; gõ tin nhắn, Enter |
| 2 | Hệ thống | Kiểm BR-15, BR-22; gọi \[ChatSend\] kèm ngữ cảnh BR-03 và màn hình đang xem (ngày đang xem, task đang chọn); dữ liệu G11 chỉ kèm khi bật BR-20; hiện "Đang nghĩ…" |
| 3 | Dịch vụ AI | Trả lời dạng luồng (stream); nếu cần hành động, sinh danh sách hành động có ngày tuyệt đối (BR-04), ngày tương đối hiểu theo BR-05 |
| 4 | Hệ thống | \[AiActionExecutor\] kiểm BR-01, BR-02, BR-04, BR-05; đếm task bị ảnh hưởng và `hasExternalData` (BR-06) |
| 5 | Hệ thống | ≤ 3 task và `hasExternalData = false`: áp dụng ngay theo BR-21, đề xuất `DA_AP_DUNG`; câu trả lời kèm chip mỗi task: tiêu đề, "Thứ Năm, 5/11 · 14:00", "Hoàn tác" |
| 6 | Hệ thống | Hiện "Đã nghĩ {n}s"; board, lịch cập nhật qua realtime `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Câu hỏi không cần hành động ("chiều nay còn trống bao lâu?") | Chỉ trả lời, có số liệu từ G04 (thời gian trống, tổng planned); không tạo đề xuất |
| A2 | > 3 task bị ảnh hưởng (EC-37), hoặc `hasExternalData = true` dù chỉ 1 task (Q21, Q31a) | Đề xuất `CHO_DUYET`; hiện **SCR-05** trong khung chat (có `hasExternalData` → kèm MSG-22); "Áp dụng" → \[ProposalApply\] các dòng được chọn theo BR-21; "Huỷ" → \[ProposalReject\]; không duyệt tới cuối ngày làm việc → hết hạn (BR-21) |
| A3 | Khung mơ hồ BR-05 (EC-01: mốc 04:00, 02:10 ngày 4/11 — ngày làm việc Thứ Ba 3/11 — "tạo task gọi khách ngày mai") | Không tạo; Sunny hỏi MSG-08 với 2 nút "Thứ Tư, 4/11" (ngày làm việc + 1) / "Thứ Năm, 5/11" (ngày làm việc + 2); chọn → tiếp bước 4 với ngày đã chọn |
| A4 | Yêu cầu hành động bị cấm (BR-02), gồm "đánh dấu xong" | Trả lời MSG-07 kèm cách tự làm (ví dụ "Xoá: chọn task, Ctrl+Backspace"; "Hoàn thành: tích ✓ hoặc phím C"); không tạo đề xuất |
| A5 | Bấm "Hoàn tác" trên chip | → UC-04 |
| A6 | "Lịch sử" | Danh sách cuộc trò chuyện (\[ChatThreadList\]) mới nhất trước; mở lại cuộc cũ, chip vẫn hoàn tác được trong thời hạn BR-08 |
| A7 | "Cuộc trò chuyện mới" | \[ChatThreadCreate\]; ngữ cảnh cuộc cũ không gửi kèm |
| A8 | Quá 10 giây chưa xong | Hiện "Vẫn đang xử lý…" và nút "Dừng"; Dừng → huỷ lượt, `LOI` không áp dụng gì |
| A9 | Yêu cầu nhắc tới task không tìm thấy hoặc khớp nhiều task | Sunny hỏi lại, liệt kê tối đa 5 task khớp để chọn |
| A10 | "Hôm nay / tối nay" trong khung 00:00 → mốc đầu ngày (ví dụ 02:10 ngày 4/11, "tạo task gọi khách hôm nay") | Không hỏi lại; dùng ngày làm việc hiện tại (Thứ Ba, 3/11) theo BR-05; chip hiện ngày cụ thể |
| A11 | Yêu cầu dời ngày / đưa vào backlog | Áp dụng theo QC-05 dòng "AI dời ngày" / "Đưa vào backlog" (timebox, sự kiện ngoài, số ngày bị hoãn); timer không dừng |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | LLM lỗi / quá 60 giây | Đề xuất `LOI`; MSG-04 có nút "Gửi lại"; không trừ lượt (BR-22) |
| E2 | Hết hạn mức tin nhắn chat (BR-22) | MSG-11, ô nhập disabled tới mốc đầu ngày của ngày làm việc kế tiếp |
| E3 | Tin nhắn > 2.000 ký tự | MSG-02, chặn gửi |
| E4 | Workspace chỉ đọc (QC-09) | Không gọi AI; khung chat hiện MSG-12, ô nhập disabled (BR-17) |
| E5 | Mất mạng | MSG-06; tin nhắn giữ trong ô, không xếp hàng đợi offline |
| E6 | Hành động hợp lệ nhưng ghi thất bại (task vừa bị xoá / đổi ở thiết bị khác, BR-21) | Chip của task đó hiện "Không thực hiện được"; các task khác vẫn áp dụng |
| E7 | Chưa có đồng ý (`AI_CONSENT_REQUIRED`) | Không gửi; mở UC-09 |

### UC-04 Hoàn tác hành động AI

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đề xuất `DA_AP_DUNG`; thay đổi cần hoàn tác áp dụng chưa quá 7 ngày `[giả định]` |
| Hậu điều kiện thành công | Thay đổi được chọn → `DA_HOAN_TAC`; trường AI đổi trả về giá trị trước AI; sửa đổi của người dùng giữ nguyên; nhật ký ghi "hoàn tác thay đổi của AI" |
| Hậu điều kiện thất bại | Task giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Hoàn tác" trên chip hoặc dòng SCR-03 (một thay đổi), "Hoàn tác tất cả" trong đề xuất, "Hoàn tác kế hoạch AI" (SCR-03 hoặc bước Daily plan của G08), hoặc "Hoàn tác" ở dòng nhật ký AI trong chi tiết task (G02 SCR-03) |
| 2 | Hệ thống | Gọi \[ProposalUndo\] với `changeIds` |
| 3 | Hệ thống | Với từng thay đổi: so `version` và lịch sử trường; không có sửa đổi của người dùng sau AI → trả giá trị trước AI (BR-08) |
| 4 | Hệ thống | Chip gạch ngang "Đã hoàn tác"; task AI tạo → Thùng rác; toast MSG-09 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng đã sửa trường khác của task (ví dụ AI dời ngày, người dùng đổi priority) | Chỉ trả ngày; priority của người dùng giữ (EC-38) |
| A2 | Người dùng đã sửa chính trường AI đổi, hoặc thêm nội dung vào task AI tạo (EC-38) | Thay đổi → `XUNG_DOT`; mở **SCR-06** liệt kê trường xung đột: "Giữ bản của tôi" / "Trả về trước khi AI sửa" (áp cho từng dòng hoặc tất cả) |
| A3 | Task đã bị người dùng xoá | Bỏ qua thay đổi đó, ghi "không còn task" |
| A4 | (Bỏ — AI không đánh dấu xong, xem BR-02 / Q20) | — |
| A5 | Hoàn tác timebox | Gỡ timebox, xoá sự kiện ngoài (G05) |
| A6 | Hoàn tác dời ngày / vào backlog | Trả ngày dự định / bucket cũ, khôi phục liên kết timebox; sự kiện ngoài đã bị xoá thì tạo lại với giờ cũ (QC-05). Ngày cũ < hôm nay → về hôm nay `[giả định]` |
| A7 | "Hoàn tác kế hoạch AI" | `changeIds` = mọi thay đổi `DA_AP_DUNG` của đề xuất Planning Agent; áp bước 3 và A1–A6 cho từng thay đổi; các dòng `XUNG_DOT` gom vào một SCR-06 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Quá thời hạn hoàn tác | Nút Hoàn tác ẩn; gọi API trả `AI_UNDO_EXPIRED` → MSG-10 |
| E2 | \[ProposalUndo\] lỗi | Giữ nguyên, MSG-14 |

### UC-05 Soạn và duyệt highlights AI cuối ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Trợ lý bật và đã đồng ý (BR-19); workspace không chỉ đọc (QC-09); ngày làm việc D có ≥ 1 task `HOAN_THANH` |
| Hậu điều kiện thành công | Highlights người dùng đã duyệt lưu vào ritual Daily shutdown ngày D (G08); đề xuất `DA_AP_DUNG` |
| Hậu điều kiện thất bại | Bước highlights dùng danh sách việc đã xong biên tập tay như bản 1.0 (G08) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Job `ai.highlights.draft` chạy 17:00 T2–T6 theo timezone người dùng (BR-13); bỏ qua người dùng chưa có `aiConsentAt`, đã tắt trợ lý, hoặc workspace chỉ đọc |
| 2 | Hệ thống | Gọi \[HighlightsDraft\]: task xong trong ngày D, thời gian theo channel, \[IntegrationActivity\] (G11) chỉ khi bật BR-20; ngôn ngữ theo BR-12 |
| 3 | Hệ thống | Lưu nháp `CHO_DUYET`; không gửi thông báo riêng (lời nhắc shutdown thuộc G08) |
| 4 | Người dùng | Mở Daily shutdown (G08) → bước highlights → **SCR-07** hiện nháp có ✨, mỗi ý có link về task / item nguồn |
| 5 | Người dùng | Sửa, xoá ý, thêm ý; bấm "Tiếp" của bước |
| 6 | Hệ thống | Lưu highlights vào ritual (G08 \[RitualUpdate\]); đề xuất → `DA_AP_DUNG` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Mở shutdown trước 17:00 hoặc tắt "Tóm tắt tự động" | Nút "Soạn bằng AI" trên SCR-07 → bước 2 ngay |
| A2 | Task xong thêm sau khi có nháp | Người dùng chưa sửa → soạn lại khi mở bước. Đã sửa → giữ bản sửa, hiện MSG-13 "Thêm vào" |
| A3 | "Soạn lại" | Kiểm hạn mức BR-22; tạo nháp mới; người dùng đã sửa → hỏi xác nhận ghi đè. Hết lượt → MSG-11, nút disabled |
| A4 | Ngày không có task xong | Không soạn; SCR-07 hiện trạng thái rỗng của G08 |
| A5 | Công cụ G11 lỗi / chưa kết nối | Soạn chỉ từ task trong app, ghi chú nhỏ "Chưa gồm hoạt động từ {công cụ}" |
| A6 | Tắt "Dùng dữ liệu từ công cụ đã kết nối" (BR-20) | Soạn chỉ từ task trong app; không có ghi chú lỗi |
| A7 | Chưa có đồng ý, bấm "Soạn bằng AI" | Mở UC-09; đồng ý xong → bước 2 |

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
| 3 | Hệ thống | Gọi \[SettingsUpdate\] (G01 `PATCH /me/settings`); áp BR-16, BR-20 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tắt "Trợ lý" khi khung chat đang mở | Đóng khung chat; lượt đang `DANG_XU_LY` bị huỷ |
| A2 | Tắt Beta "Agentic Daily Planning" khi có đề xuất `CHO_DUYET` | Đề xuất → `DA_HOAN_TAC`; Daily planning dùng luồng thủ công. Đề xuất đã `DA_AP_DUNG` giữ nguyên, vẫn hoàn tác được từ nhật ký task |
| A3 | "Xoá lịch sử trò chuyện" | Xác nhận MSG-17 → xoá mọi cuộc trò chuyện; chip cũ mất nút Hoàn tác, hoàn tác vẫn làm được từ nhật ký task |
| A4 | Bật "Trợ lý" khi `aiConsentAt` trống | Toggle chưa đổi; mở UC-09; đồng ý → toggle bật |
| A5 | Bật / tắt "Dùng dữ liệu từ công cụ đã kết nối" | Lưu `ai.useIntegrationData`; áp dụng từ lượt AI kế tiếp. Tắt khi có đề xuất `CHO_DUYET` có `hasExternalData` → đề xuất giữ nguyên, người dùng vẫn duyệt / huỷ được `[giả định]` |
| A6 | "Rút lại đồng ý dùng AI" (SCR-09 #11) | Xác nhận MSG-23 → \[AiConsent\] `DELETE`; xoá `aiConsentAt`, `ai.assistantEnabled = false`; huỷ lượt `DANG_XU_LY`, đề xuất `CHO_DUYET` → `DA_HOAN_TAC`; thay đổi đã áp dụng giữ nguyên, vẫn hoàn tác được từ nhật ký task (BR-19) |

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
| 2 | Hệ thống (CI) | Chạy \[EvalRun\] trên bộ ≥ 200 câu Việt / Anh, nhóm: ngày giờ (gồm EC-01 lúc 02:10 và mọi dòng của bảng ví dụ QC-01), thao tác task, ngưỡng > 3 task (EC-37) và áp dụng ngay / chờ duyệt (BR-06), hoàn tác (EC-38), hành động bị cấm (gồm đánh dấu xong), lệnh ẩn trong dữ liệu (câu lệnh trong tiêu đề email / issue / trang Notion), ngôn ngữ, highlights |
| 3 | Hệ thống | Mỗi câu chạy với `now` cố định; chấm theo hành động mong đợi (đúng loại, đúng task, đúng ngày) và tiêu chí chữ |
| 4 | Hệ thống | Đạt BR-18 → gắn nhãn phát hành; lưu kết quả theo phiên bản |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | < 95% tổng hoặc < 100% nhóm rào chắn / ngày giờ / lệnh ẩn trong dữ liệu | Chặn merge; báo cáo liệt kê câu sai |
| E2 | Nhà cung cấp LLM lỗi khi chạy | Chạy lại câu lỗi tối đa 2 lần; vẫn lỗi → coi là sai |

### UC-09 Đồng ý dùng AI lần đầu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; `aiConsentAt` trống; người dùng bấm ✨, "Plan my day", "Soạn bằng AI", hoặc bật toggle "Trợ lý" (SCR-09) |
| Hậu điều kiện thành công | `aiConsentAt`, `aiConsentVersion` lưu; `ai.assistantEnabled = true`; thao tác ban đầu tiếp tục |
| Hậu điều kiện thất bại | Không lưu gì; `ai.assistantEnabled = false`; không có lời gọi AI nào |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm một điểm vào AI khi chưa đồng ý |
| 2 | Hệ thống | Mở **SCR-10**: dữ liệu được gửi, nhà cung cấp AI, cam kết không lưu / không huấn luyện, dữ liệu công cụ tích hợp không gửi trừ khi bật riêng, link chính sách quyền riêng tư |
| 3 | Người dùng | Bấm "Đồng ý và bật" |
| 4 | Hệ thống | Gọi \[AiConsent\]; lưu `aiConsentAt` (thời điểm server nhận), `aiConsentVersion`; bật `ai.assistantEnabled`; phát `settings.changed` |
| 5 | Hệ thống | Đóng SCR-10, tiếp tục thao tác ở bước 1 (mở khung chat, chạy UC-02, soạn highlights, hoặc giữ toggle bật) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Để sau" / đóng SCR-10 | Không lưu; toggle giữ tắt; Daily planning dùng luồng thủ công; bước highlights dùng danh sách sinh sẵn (G08 BR-17) |
| A2 | Đã đồng ý trên thiết bị khác | `settings.changed` cập nhật; không hiện SCR-10 lần nữa |
| A3 | Workspace chỉ đọc (QC-09) | Vẫn lưu được đồng ý (cài đặt tài khoản); AI vẫn không chạy tới khi thoát chỉ đọc (BR-17) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[AiConsent\] lỗi / mất mạng | Không bật trợ lý; MSG-14 |

## 6. Điểm vào

| **Điểm vào** | **Web** | **App** | **Ghi chú** |
| --- | --- | --- | --- |
| Nút ✨ góc dưới mọi màn hình | ✓ | ✓ | Mở SCR-04; chưa đồng ý → SCR-10 (UC-09) |
| Command menu (Ctrl/Cmd+K) "Hỏi Sunny" | ✓ | ✓ (desktop) | Phím tắt riêng `[giả định: Ctrl+J]` |
| Daily planning (G08) → "Plan my day" | ✓ | ✓ | Chỉ khi bật Beta; SCR-02 |
| Daily shutdown (G08) → bước highlights | ✓ | ✓ | SCR-07 |
| Nhật ký AI trong chi tiết task (G02 SCR-03) | ✓ | ✓ | Hoàn tác thay đổi AI (UC-04) |
| Daily planning (G08) → bước Daily plan → "Hoàn tác kế hoạch AI" | ✓ | ✓ | UC-02 A4, UC-04 A7; G08 đặt nút, hiện khi ngày D có đề xuất Planning Agent `DA_AP_DUNG` còn trong thời hạn hoàn tác |
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
| 6 | Dùng dữ liệu từ công cụ đã kết nối | Toggle | – | Phần "Công cụ"; mặc định tắt (BR-20); bên dưới MSG-20; cùng giá trị với SCR-09 #9 |

### SCR-02 Planning Agent — nhập và chạy

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Nhãn Beta | Badge | – | "Beta" |
| 2 | "Điều quan trọng nhất hôm nay là gì?" | Text | Không | ≤ 500 ký tự `[giả định]` |
| 3 | "Plan my day" | Button chính | – | Disabled khi hết lượt (MSG-11), offline, hoặc workspace chỉ đọc (MSG-12); chưa đồng ý → SCR-10 |
| 4 | "Tự lập kế hoạch" | Link | – | Sang Daily planning thủ công (G08) |
| 5 | Tiến độ | List bước | – | Hiện khi `DANG_XU_LY`: "Đọc lịch", "Đọc việc từ công cụ", "Xếp khối thời gian"; bộ đếm thời gian; "Thường mất 2–4 phút" |
| 6 | "Dừng" | Button | – | Huỷ lượt → luồng thủ công, không áp dụng gì |

### SCR-03 Review Plan

Hai chế độ (BR-06): **Đã áp dụng** (mặc định, Q31) và **Chờ duyệt** (kế hoạch có dữ liệu tích hợp, Q31a).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tóm tắt | Text | Đã áp dụng: "Planning Agent đã thêm 3 task, dời 2 task". Chờ duyệt: "Planning Agent đề xuất thêm 3 task, dời 2 task" + MSG-22 |
| 2 | Danh sách thay đổi | List | Nhóm "HÔM NAY · n thay đổi"; mỗi dòng: loại (Thêm / Dời / Timebox / Sắp lại), tiêu đề, giá trị trước → sau, ngày giờ cụ thể (BR-04). Đã áp dụng: mỗi dòng có "Hoàn tác" (UC-04), dòng đã hoàn tác gạch ngang. Chờ duyệt: checkbox, mặc định chọn hết. Dòng bị loại (BR-21) hiện xám kèm lý do |
| 3 | Tổng khối lượng | Text | Tổng planned sau khi áp dụng so ngưỡng (G04); đỏ khi vượt |
| 4 | "Lập lại" | Button | UC-02 A1 |
| 5 | "Huỷ tất cả" / "Hoàn tác kế hoạch AI" | Button | Chờ duyệt: "Huỷ tất cả". Đã áp dụng: "Hoàn tác kế hoạch AI". UC-02 A2 |
| 6 | "Gửi phản hồi" | Link | SCR-08 |
| 7 | "Tiếp" / "Áp dụng và tiếp" | Button chính | Đã áp dụng: "Tiếp" sang Daily plan (G08). Chờ duyệt: "Áp dụng và tiếp" → \[ProposalApply\] các dòng được chọn (BR-21); disabled khi không chọn dòng nào (khi đó dùng "Huỷ tất cả") hoặc khi đề xuất hết hạn |

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
| 8 | Thẻ xác nhận | SCR-05 | – | Khi > 3 task hoặc có dữ liệu ngoài (BR-06) |
| 9 | "Hữu ích" / "Chưa tốt" | Icon button | – | UC-06 |

### SCR-05 Thẻ xác nhận thay đổi nhiều task

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Text | "Sunny sẽ thay đổi {n} task"; có `hasExternalData` → thêm MSG-22 |
| 2 | Danh sách | List có checkbox | Mỗi dòng: tiêu đề task, trường đổi, trước → sau (ngày cụ thể); tối đa hiện 10 dòng, "Xem thêm" |
| 3 | "Áp dụng" | Button chính | \[ProposalApply\] dòng được chọn (BR-21); disabled khi đề xuất hết hạn |
| 4 | "Huỷ" | Button | \[ProposalReject\]; thẻ xám "Đã huỷ" |
| 5 | Trạng thái hết hạn | Text | Thẻ xám "Đã hết hạn" khi qua cuối ngày làm việc (BR-21) |

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
| 1 | Trợ lý | Toggle | – | Mặc định tắt (Q21); bật lần đầu khi chưa đồng ý → SCR-10 (UC-07 A4); BR-16 |
| 2 | Gợi ý channel | Toggle | – | Mặc định bật (hành vi G02) |
| 3 | Gợi ý thời lượng (task, subtask) | Toggle | – | Mặc định bật (hành vi G02) |
| 4 | Ngôn ngữ tóm tắt | Dropdown | – | Auto / Tiếng Việt / English; mặc định Auto |
| 5 | Tóm tắt tự động | Toggle | – | Mặc định bật; nháp T2–T6 17:00; chỉ chạy khi #1 bật và đã đồng ý |
| 6 | Thiết lập Planning Agent | Link | – | Mở SCR-01; ẩn khi Beta tắt |
| 7 | Xoá lịch sử trò chuyện | Button nguy hiểm | – | UC-07 A3 |
| 8 | Beta → Agentic Daily Planning | Toggle | – | Ở nhóm Beta; mặc định tắt `[giả định]` |
| 9 | Dùng dữ liệu từ công cụ đã kết nối | Toggle | – | Mặc định tắt (BR-20); disabled khi #1 tắt; mô tả MSG-20 |
| 10 | Thời điểm đồng ý | Text | – | "Bạn đã đồng ý dùng AI lúc {ngày giờ}"; ẩn khi chưa đồng ý |
| 11 | Rút lại đồng ý dùng AI | Button nguy hiểm | – | Hiện khi đã đồng ý; xác nhận MSG-23 → UC-07 A6 |

### SCR-10 Đồng ý dùng AI (dialog)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Text | "Bật trợ lý AI" |
| 2 | Dữ liệu được gửi | Text + danh sách | Tiêu đề, thời lượng, ngày, trạng thái task; channel; sự kiện lịch (tiêu đề, giờ); nội dung bạn gõ cho trợ lý. Không gửi nội dung email, token. Dữ liệu công cụ tích hợp chỉ gửi khi bạn bật riêng (BR-10, BR-20) |
| 3 | Nhà cung cấp và cam kết | Text | Tên nhà cung cấp AI `[chờ chốt]`; không lưu, không dùng để huấn luyện |
| 4 | Link chính sách quyền riêng tư | Link | Tab mới |
| 5 | "Đồng ý và bật" | Button chính | \[AiConsent\] (UC-09 bước 4) |
| 6 | "Để sau" | Button | UC-09 A1 |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[AgentProfileGet\] / \[AgentProfileSave\] `GET/PUT /ai/agent-profile` | about, themeDays[7], sources[] | AgentProfile | 5s / 1 lần |
| \[AgentPlanStart\] `POST /ai/planning/{date}/runs` | focusText, context (BR-03), Idempotency-Key | proposalId, status `DANG_XU_LY` | 5s nhận yêu cầu / không retry; bước đầu ≤ 10s, tổng ≤ 5 phút (BR-09) |
| \[ProposalGet\] `GET /ai/proposals/{id}` | id | Proposal: status, hasExternalData, expiresAt, steps[], changes[] (type, taskId, field, before, after, baseVersion, status), modelVersion | 5s / 2 lần; realtime `ai.proposal.updated` là kênh chính |
| \[ProposalApply\] `POST /ai/proposals/{id}/apply` | changeIds[], Idempotency-Key | Proposal, tasks[], skipped[] {changeId, reason: `SKIPPED_STALE` \| `SKIPPED_PAST`} | 10s / 2 lần cùng key; kiểm `baseVersion` từng task, chỉ loại dòng lỗi thời (BR-21); dùng chung cho áp dụng ngay (server tự gọi) và áp dụng sau duyệt |
| \[AiConsent\] `POST /ai/consent` · `DELETE /ai/consent` (rút lại) | consentVersion | aiConsentAt, aiConsentVersion, Settings | 5s / 2 lần |
| \[ProposalReject\] `POST /ai/proposals/{id}/reject` | id, reason? | Proposal `DA_HOAN_TAC` | 5s / 2 lần |
| \[ProposalUndo\] `POST /ai/proposals/{id}/undo` | changeIds[], resolutions[] {changeId, keep: user\|before} | Proposal, tasks[], conflicts[] (nếu chưa có resolutions) | 5s / 2 lần |
| \[ChatThreadList\] / \[ChatThreadCreate\] / \[ChatThreadDelete\] `GET/POST/DELETE /ai/chat/threads` | cursor, limit / – / id | Thread[] / Thread | 5s / 1 lần |
| \[ChatSend\] `POST /ai/chat/threads/{id}/messages` (SSE) | text, context (BR-03), viewDate, selectedTaskId | Stream: delta chữ, `thinkingMs`, proposal (nếu có) | Chữ đầu ≤ 10s; tổng ≤ 60s; không tự retry (nút "Gửi lại") |
| \[HighlightsDraft\] `POST /ai/highlights/{date}/draft` · `GET /ai/highlights/{date}` | date, language | Proposal (bullets[] {text, taskId?, itemRef?}) | 10s / 1 lần (người dùng mở); job: 2 lần cách 5 phút |
| \[AiFeedback\] `POST /ai/feedback` | proposalId?, rating, reasons[], text, attachConversation | 204 | 5s / 3 lần nền |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | ai.assistantEnabled (bật khi `aiConsentAt` trống → 409 `AI_CONSENT_REQUIRED`), ai.useIntegrationData, ai.summaryLanguage, ai.autoSummary, beta.agenticPlanning | Settings | 5s / 2 lần |
| \[IntegrationActivity\] (G11) | date | Hoạt động do tài khoản đã kết nối thực hiện (G11 BR-19) | 5s / 1 lần; chỉ gọi khi bật BR-20; lỗi → bỏ qua (UC-05 A5) |
| \[TaskFromItem\] (G11) | integrationId, externalId, startDate, actor = `ai`, proposalId | Task + TaskLink, hoặc 409 `ALREADY_LINKED` {taskId} | Theo G11 (BR-24) |
| \[EvalRun\] (nội bộ CI) | configVersion, datasetVersion | passRate, theo nhóm, câu sai[] | 30 phút / chạy lại câu lỗi 2 lần |
| \[AppConfig\] | – | Ngưỡng BR-06, BR-09 | Cache 1h |
| \[BillingGet\] `entitlements` (G12 BR-24, QC-10) | – | Hạn mức chat / agent / soạn lại highlights theo gói (BR-22) | Cache theo G12 |

Job: `ai.highlights.draft` (mỗi 15 phút quét người dùng vừa tới 17:00 T2–T6, chỉ người dùng có `aiConsentAt`, trợ lý bật, workspace không chỉ đọc; idempotent theo user + ngày), `ai.proposal.expire` (đóng `CHO_DUYET` khi tới mốc đầu ngày của ngày làm việc kế tiếp, BR-21), `ai.history.purgeIntegration` (theo `integration.disconnected` của G11, BR-23). Realtime mới: `ai.proposal.updated` `[giả định]`.

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
| `AI_QUOTA_EXCEEDED` (429, kèm `quotaType`: chat / agent / highlights) | MSG-11 |
| `PROPOSAL_STALE` (412, mọi dòng bị loại) | MSG-15 |
| `skipped[]` không rỗng trong response \[ProposalApply\] | MSG-19 |
| `PROPOSAL_EXPIRED` (410) | Thẻ "Đã hết hạn" (SCR-03 / SCR-05) |
| `AI_CONSENT_REQUIRED` (409) | SCR-10 (UC-09) |
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
| MSG-07 | Khung chat | Mình không thể {xoá task / đánh dấu xong task / gửi tin ra ngoài / đổi cài đặt}. Bạn có thể tự làm: {cách làm} |
| MSG-08 | Khung chat | Bây giờ là {giờ} ngày {ngày}. "{cụm từ}" là ngày nào? |
| MSG-09 | Toast | Đã hoàn tác {n} thay đổi của AI |
| MSG-10 | Toast | Thay đổi này đã quá 7 ngày, không hoàn tác bằng AI được. Hãy sửa trực tiếp task |
| MSG-11 | Inline | Bạn đã dùng hết {lượt trò chuyện / lượt Planning Agent / lượt soạn highlights} hôm nay. Lượt mới có từ {giờ} ngày {ngày} |
| MSG-12 | Khung chat / SCR-02 | Workspace đang ở chế độ chỉ đọc nên trợ lý AI tạm ngừng |
| MSG-13 | Inline SCR-07 | Có {n} việc mới xong sau khi soạn nháp · Thêm vào |
| MSG-14 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-15 | Inline | Kế hoạch vừa thay đổi ở nơi khác. Lập lại để agent dùng dữ liệu mới |
| MSG-16 | Toast | Cảm ơn bạn đã góp ý |
| MSG-17 | Dialog | Xoá toàn bộ lịch sử trò chuyện? Task đã tạo không bị ảnh hưởng |
| MSG-18 | Dialog SCR-06 | Bạn đã sửa {n} chỗ sau khi AI thay đổi. Chọn giữ bản nào |
| MSG-19 | Inline SCR-03 / SCR-05 / khung chat | Đã bỏ qua {n} thay đổi vì task vừa đổi ở nơi khác hoặc giờ đã qua. Các thay đổi còn lại đã áp dụng |
| MSG-20 | Inline SCR-01 / SCR-09 | Khi bật, AI đọc tiêu đề việc từ Gmail, Jira, Notion. Mọi thay đổi AI đề xuất từ dữ liệu này đều chờ bạn duyệt |
| MSG-21 | Khung chat / lịch sử | Nội dung từ {công cụ} đã được xoá khi bạn ngắt kết nối |
| MSG-22 | SCR-03 / SCR-05 | Cần bạn duyệt vì {kế hoạch / yêu cầu} dùng dữ liệu từ {công cụ} |
| MSG-23 | Dialog SCR-09 | Rút lại đồng ý? Trợ lý AI sẽ tắt và không gửi dữ liệu cho nhà cung cấp AI nữa. Thay đổi AI đã làm vẫn giữ nguyên |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | Kết quả đầu tiên ≤ 10 giây (p95), luôn có trạng thái đang xử lý; Planning Agent 2–4 phút, tối đa 5 phút; \[ProposalApply\] p95 ≤ 1 giây cho ≤ 30 thay đổi; chip / board cập nhật ≤ 100 ms sau khi áp dụng |
| Offline | AI không chạy offline (MSG-06); Daily planning / shutdown thủ công vẫn chạy (G08); hoàn tác AI cần mạng |
| Đồng bộ | Thay đổi AI hiện trên thiết bị khác ≤ 5 giây (`task.upserted`, `ai.proposal.updated`) |
| Bảo mật | BR-01, BR-02, BR-11 kiểm ở server; `hasExternalData` gắn ở \[AiGateway\], không do model khai báo (BR-06, BR-20); dữ liệu gửi LLM theo BR-10; khoá API nhà cung cấp chỉ ở server; mỗi lượt chỉ đọc dữ liệu của người dùng đang gọi |
| Quyền riêng tư | Không gọi AI trước `aiConsentAt` (BR-19); dữ liệu tích hợp mặc định không gửi (BR-20); nhà cung cấp LLM không lưu, không huấn luyện (hợp đồng); Nghị định 13/2023/NĐ-CP, GDPR, hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài (Q29; cần pháp chế xác nhận); lịch sử chat giữ 90 ngày, xoá được; ngắt tích hợp xoá dữ liệu của tích hợp đó khỏi lịch sử AI (BR-23); xuất dữ liệu (G01) gồm lịch sử chat và thời điểm đồng ý |
| Log / audit | \[ActivityLog\] tác nhân `ai` (BR-07); log lượt AI: proposalId, modelVersion, promptVersion, số token, độ trễ, kết quả \[AiActionExecutor\]; không ghi nội dung tin nhắn vào log hệ thống |
| Chất lượng | Bộ đánh giá BR-18; theo dõi hằng tuần tỉ lệ hoàn tác, "Chưa tốt", chuyển luồng thủ công |
| Chi phí | Hạn mức BR-22 (bảng quyền G12, QC-10); cảnh báo khi chi phí LLM / người dùng / ngày vượt ngưỡng cấu hình |
| Tracking | Sự kiện: `ai_consent_shown`, `ai_consent_given`, `ai_integration_data_toggled`, `ai_plan_undone` (toàn bộ kế hoạch), `ai_proposal_expired`, `ai_change_skipped_stale`, `ai_chat_opened`, `ai_message_sent`, `ai_proposal_created` (loại, số task), `ai_proposal_applied`, `ai_proposal_rejected`, `ai_change_undone`, `ai_undo_conflict`, `ai_date_clarify_shown`, `ai_action_forbidden`, `planning_agent_started`, `planning_agent_fallback`, `highlights_draft_created`, `highlights_saved` (tỉ lệ sửa), `ai_feedback_sent` |
| Accessibility | Khung chat đọc được bằng trình đọc màn hình (vùng `aria-live` cho câu trả lời stream); chip, checkbox, radio dùng được bằng bàn phím; ✨ có nhãn "Gợi ý của AI"; tương phản WCAG 2.1 AA sáng / tối |
