> **Mã:** PLN-SRS-G10 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g10-tro-ly-ai.md

# UC-G10 - Trợ lý AI qua Claude Code trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này mô tả việc phát hiện Claude Code, MCP server local, Planning Agent, khung chat trợ lý, điều khiển app từ Claude Code trong terminal, highlights AI cuối ngày, lời gọi AI cho gợi ý task, rào chắn, cài đặt AI và bộ đánh giá (bản **1.0**, app Windows). Trải nghiệm gợi ý thời lượng / channel khi tạo task (G02), Daily planning / Daily shutdown thủ công và chia sẻ (G08), timebox (G05), Weekly planning / objective (G09), kết nối công cụ (G11, 1.1), chế độ chỉ đọc (G12, 1.1) đặc tả ở SRS riêng của từng nhóm. Phần API, mã lỗi, job ở mục 8 là **hợp đồng nghiệp vụ tham khảo**; cách gọi CLI, kiểu kết nối MCP (stdio / HTTP cục bộ), xác thực và schema công cụ: tech chốt — [`docs/tech/01-quyet-dinh-tech-stack-va-api.md`](../tech/01-quyet-dinh-tech-stack-va-api.md) mục 4.
>
> **Cập nhật 04/11/2026** theo [quyết định chốt mâu thuẫn](../review/quyet-dinh-chot-2026-11-04.md) và [ADR-0003](../adr/0003-gioi-han-quyen-cua-tro-ly-ai.md). **Cập nhật vòng 5–6 (04/11/2026)** theo Q33, Q35, Q39, Q45, Q46, [ADR-0004](../adr/0004-ai-qua-claude-code-cli.md) (thay một phần ADR-0003, Q20, Q31, C32) và [ADR-0005](../adr/0005-nen-tang-windows-truoc.md). Quy tắc dùng chung tham chiếu [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md): ngày làm việc QC-01, lịch làm việc và khung giờ channel QC-02, trạng thái task QC-03, đổi ngày task QC-05, đồng bộ QC-08, chế độ chỉ đọc QC-09 (từ 1.1), quyền theo gói QC-10 (AI không có hạn mức), **trợ lý AI qua Claude Code CLI và MCP local QC-12** (G10 sở hữu).

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng lập kế hoạch ngày với agent, thao tác task bằng ngôn ngữ tự nhiên (trong app hoặc từ Claude Code trong terminal) và có nháp highlights cuối ngày; mọi thay đổi AI nhìn thấy được, đúng ngày và hoàn tác được; máy không có Claude Code vẫn dùng đủ chức năng lõi |
| Actor | Người dùng đã đăng nhập · App Windows · Claude Code CLI (do người dùng cài và đăng nhập trên máy; app gọi, hoặc người dùng mở trong terminal) · MCP server local của app (\[McpServer\], gồm bộ thực thi hành động AI \[AiActionExecutor\]) · Hệ thống (server cloud: lưu task, nhật ký, thay đổi AI) · Kỹ sư AI (bộ đánh giá) |
| Phạm vi | Phát hiện Claude Code, đồng ý dùng AI lần đầu, MCP local và bộ công cụ, công tắc dữ liệu tích hợp, công tắc hoàn thành / xoá, thiết lập và chạy Planning Agent, Review Plan, "Hoàn tác kế hoạch AI", khung chat (hỏi đáp, ra lệnh, lịch sử), phiên Claude Code từ terminal, duyệt thay đổi của phiên có dữ liệu tích hợp, hoàn tác hành động AI, highlights AI, lời gọi AI cho gợi ý task (G02), phản hồi, cài đặt AI / Beta, xoá dữ liệu tích hợp khỏi lịch sử AI, bộ đánh giá |
| Ngoài phạm vi | Trải nghiệm gợi ý planned / channel (G02), ritual thủ công và chia sẻ (G08), kết nối công cụ (G11), cài đặt / đăng nhập / cập nhật Claude Code (người dùng tự làm), app tự gọi LLM khác, hạn mức AI theo gói, agent chạy nền, nhập giọng nói, AI cho nhóm (bản sau, Q35) |
| Nền tảng | Bản 1.0: app Windows (Flutter) (Q45, ADR-0005). Web, macOS (1.1) và iOS / Android (1.2): cách cung cấp AI do tech chốt (ADR-0004) |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Người dùng | Thiết lập agent một lần (công cụ, thông tin về tôi, theme days) | Agent lập kế hoạch đúng thói quen của tôi |
| US-02 | Người dùng | Nói điều quan trọng hôm nay rồi bấm "Plan my day" | Có kế hoạch ngày trong vài phút |
| US-03 | Người dùng | Xem và chọn từng thay đổi của agent trước khi áp dụng | Giữ quyền quyết định kế hoạch |
| US-04 | Người dùng | Hỏi và ra lệnh cho trợ lý bằng tiếng Việt hoặc tiếng Anh | Thao tác nhiều task nhanh |
| US-05 | Người dùng làm khuya | "Ngày mai" được hiểu đúng hoặc được hỏi lại | Task không rơi vào ngày sai (EC-01) |
| US-06 | Người dùng | Hoàn tác thay đổi của AI mà không mất phần mình đã sửa | Không sợ thử AI |
| US-07 | Người dùng | Có nháp highlights cuối ngày để duyệt | Đỡ viết tóm tắt từ đầu |
| US-08 | Người dùng | Bật / tắt từng tính năng AI | Dùng AI ở mức mình muốn |
| US-09 | Kỹ sư AI | Chạy bộ đánh giá trước khi đổi prompt, bộ công cụ MCP hoặc phiên bản Claude Code tối thiểu | Không phát hành bản AI kém hơn |
| US-10 | Người dùng | Đồng ý trước khi dữ liệu của tôi được đưa cho Claude Code, và tự quyết có cho AI đọc dữ liệu công cụ đã kết nối không | Dữ liệu không bị đưa đi khi tôi chưa biết; email lạ không điều khiển được AI |
| US-11 | Người dùng | App tự nhận ra Claude Code trên máy, hoặc chỉ tôi cách cài khi chưa có | Bật trợ lý AI không cần cấu hình; không có Claude Code vẫn dùng đủ app |
| US-12 | Người dùng đã dùng Claude Code | Điều khiển app từ Claude Code trong terminal | Không phải chuyển qua khung chat của app |
| US-13 | Người dùng | Tự quyết có cho AI hoàn thành và xoá task không | AI chỉ làm việc có hậu quả khi tôi cho phép |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Hành động được phép = công cụ ghi MCP đang bật (QC-12 mục 3).** AI chỉ thay đổi app qua công cụ ghi của \[McpServer\] (mục 3.1): tạo task, sửa tiêu đề / ghi chú / planned / channel, dời ngày, đưa vào backlog, timebox / gỡ timebox (G05); thêm subtask, sắp thứ tự, priority, gắn objective (G09) `[giả định — chưa có trong QC-12 mục 3]`; tạo task từ item tích hợp (BR-24, chỉ khi bật BR-20); hoàn thành / xoá task chỉ khi bật BR-26. Dời ngày và đưa vào backlog theo QC-05 (dòng "AI dời ngày" và "Đưa vào backlog", Q14). \[AiActionExecutor\] trong app kiểm danh sách này độc lập với model; server kiểm quy tắc nghiệp vụ như với thao tác của người dùng (`PAST_DATE`, `VERSION_CONFLICT`…) |
| BR-02 | **Hành động bị cấm.** Luôn cấm (không có công cụ MCP): gửi tin ra ngoài (email, Slack, Teams, chia sẻ ritual), đổi cài đặt (kể cả cài đặt AI và công tắc của G10), kết nối / ngắt tích hợp, xoá vĩnh viễn / dọn Thùng rác, xuất dữ liệu, thao tác tài khoản, đọc token / mật khẩu, hoàn thành hoặc xoá task có liên kết tích hợp còn hiệu lực (D10). Cấm khi BR-26 tắt (mặc định): hoàn thành / bỏ hoàn thành, xoá task / subtask (thay một phần Q20, Q46; công tắc áp cho cả subtask, D10). Yêu cầu loại này → trợ lý từ chối MSG-07 kèm cách tự làm; Claude Code vẫn gọi công cụ không có / không được phép → \[McpServer\] trả `AI_ACTION_FORBIDDEN` (reason `NO_TOOL` / `TOGGLE_OFF` / `LINKED_TASK`, dùng chung với G02 BR-21) |
| BR-03 | **Ngữ cảnh thời gian bắt buộc.** Mọi lượt app gọi Claude Code kèm: `now` (ISO 8601 có offset), timezone IANA, `dayStartTime` (mốc đầu ngày), `currentWorkday` = `workday(now)` (QC-01), lịch làm việc và khung giờ channel (QC-02), locale. Thiếu trường nào → không gọi Claude Code, ghi lỗi `AI_CONTEXT_MISSING`. Phiên terminal (BR-28) lấy các giá trị này qua công cụ "Xem ngữ cảnh thời gian"; mô tả công cụ của \[McpServer\] yêu cầu Claude Code đọc ngữ cảnh trước khi ghi `[giả định — tech chốt cách đưa chỉ dẫn]` |
| BR-04 | **Ngày tuyệt đối.** Hành động có ngày phải mang ngày `YYYY-MM-DD` và giờ tuyệt đối; server từ chối ngày ngoài ± 1 năm so với hôm nay `[giả định]` và từ chối đặt task chưa xong vào ngày < hôm nay (QC-05). Chip, thẻ xác nhận, Review Plan luôn hiện ngày cụ thể ("Thứ Năm, 5/11") |
| BR-05 | **Ngày tương đối (EC-01, Q2, C33).** "Hôm nay / tối nay / today / tonight" = `workday(now)`; "ngày mai / sáng mai / tomorrow" = `workday(now)` + 1 ngày (QC-01). **Khung mơ hồ:** khi ngày lịch của `now` khác `workday(now)` (từ 00:00 tới mốc đầu ngày) và yêu cầu chứa "ngày mai / sáng mai / tomorrow" → không thực hiện, hỏi lại MSG-08 bằng 2 lựa chọn: `workday(now)` + 1 và `workday(now)` + 2. Mốc đầu ngày = 00:00 thì không có khung mơ hồ. Bảng ví dụ của QC-01 là ca chuẩn (ví dụ mốc 04:00, 02:10 ngày 4/11: "hôm nay" = Thứ Ba 3/11; "ngày mai" → hỏi "Thứ Tư, 4/11" / "Thứ Năm, 5/11") |
| BR-06 | **Áp dụng ngay hay chờ duyệt (QC-12 mục 5–6, Q46, Q31/Q31a, Q21).** Mọi thay đổi qua công cụ ghi MCP **áp dụng ngay** (qua \[ProposalApply\] theo BR-21), gắn chip "AI" trên task, ghi nhật ký (BR-07), có Hoàn tác từng thay đổi và cả lượt (BR-08) — với chat, Planning Agent, highlights và phiên terminal; không còn ngưỡng "> 3 task phải duyệt" (thay Q31a). `hasExternalData` của một phiên AI (mục 4.4) chuyển `true` khi phiên gọi công cụ đọc dữ liệu tích hợp (BR-20); từ thời điểm đó mọi thay đổi ghi trong phiên vào `CHO_DUYET` thay vì áp dụng: chat hiện **SCR-05**, Planning Agent hiện **SCR-03** chế độ "Chờ duyệt", terminal hiện ở **SCR-12** kèm MSG-31. Chỉ các thay đổi **sau** lần đầu đọc dữ liệu tích hợp trong phiên đó chờ duyệt; thay đổi đã áp dụng trước lần đọc đó giữ nguyên (D8). Lượt chạm > 3 task: câu trả lời / Review Plan có tóm tắt và "Hoàn tác tất cả" / "Hoàn tác kế hoạch AI" nổi bật (EC-37) |
| BR-07 | **Nhật ký và chip AI.** Mọi thay đổi AI ghi \[ActivityLog\] (G02) với tác nhân `ai`, `aiAgent` (`assistant` / `planning_agent` / `highlights` / `task_suggest` / `terminal`), `aiSessionId` và `proposalId`. Task có thay đổi AI còn hiệu lực hiện chip "AI" trên card (G02, G04) và trong chi tiết task, tới khi người dùng sửa task hoặc hết thời hạn hoàn tác `[giả định]`. Hiển thị: "Planning Agent đã tạo task này", "Trợ lý đã dời sang Thứ Năm, 5/11", "Claude Code (terminal) đã hoàn thành task này" |
| BR-08 | **Hoàn tác (EC-38).** Hoàn tác theo từng thay đổi hoặc cả đề xuất / phiên, trong 7 ngày `[giả định]` kể từ khi áp dụng. Chỉ trả lại các trường AI đã đổi về giá trị trước AI. Trường người dùng đã sửa sau AI, hoặc task AI tạo đã được người dùng thêm subtask / notes / comment / thời gian thực tế → thay đổi đó ở `XUNG_DOT`, hỏi qua **SCR-06**. Hoàn tác "tạo task" = xoá mềm vào Thùng rác (G02 UC-04 A3). Hoàn tác "dời ngày" / "vào backlog" = trả ngày dự định hoặc bucket cũ và khôi phục liên kết timebox theo QC-05 (mục Hoàn tác); ngày cũ < hôm nay → về hôm nay `[giả định]` (QC-05 chặn ngày quá khứ). Hoàn tác "hoàn thành" = bỏ hoàn thành theo QC-03 mục 4; timer đã dừng không chạy lại. Hoàn tác "xoá" = khôi phục từ Thùng rác theo QC-03 mục 3. "Hoàn tác kế hoạch AI" = hoàn tác mọi thay đổi `DA_AP_DUNG` của một đề xuất Planning Agent; "Hoàn tác tất cả" = của một lượt chat hoặc một phiên terminal |
| BR-09 | **Thời gian chờ.** Kết quả đầu tiên (chữ hoặc bước tiến độ từ Claude Code) ≤ 10 giây. Chat: quá 10 giây vẫn chờ, hiện "Vẫn đang xử lý…" và nút Dừng; quá 60 giây `[giả định]` → `LOI`. Planning Agent: lỗi, hoặc 10 giây chưa có bước đầu, hoặc tổng > 5 phút `[giả định]` → `LOI` và chuyển luồng thủ công G08 (EC-39). Dừng / `LOI` khi đã có thay đổi áp dụng → giữ các thay đổi đó, báo số thay đổi kèm Hoàn tác cả lượt (D9; áp cho cả Planning Agent và chat); thay đổi `CHO_DUYET` của lượt bị huỷ |
| BR-10 | **Dữ liệu đưa cho Claude Code tối thiểu.** Dữ liệu chỉ ra khỏi app qua kết quả của công cụ đọc MCP (mục 3.1) và ngữ cảnh BR-03, chỉ sau khi có đồng ý (BR-19). Công cụ trả: tiêu đề, planned, actual, channel (tên), ngày, trạng thái task trong khoảng ngày được hỏi (mặc định hôm nay ± 7 ngày `[giả định]`); sự kiện lịch (tiêu đề, giờ, busy); objective; ghi chú / subtask chỉ qua công cụ "Xem chi tiết task"; metadata item tích hợp chỉ khi bật BR-20. Không trả nội dung email, đoạn trích Gmail, email người khác, token. App không gửi dữ liệu cho nhà cung cấp AI nào; Claude Code xử lý dữ liệu theo tài khoản Claude của người dùng (QC-12 mục 1) |
| BR-11 | **Dữ liệu ngoài là dữ liệu.** Tiêu đề task, notes, email, item tích hợp không được coi là lệnh; BR-01, BR-02, BR-06, BR-26 kiểm ở \[McpServer\] / \[AiActionExecutor\], không dựa vào model. \[McpServer\] tự gắn `hasExternalData` cho phiên khi phiên gọi công cụ đọc dữ liệu tích hợp (không do model khai báo), và \[AiActionExecutor\] buộc mọi thay đổi sau đó của phiên vào `CHO_DUYET` (BR-06, QC-12 mục 6) |
| BR-12 | **Ngôn ngữ.** Chat trả lời theo ngôn ngữ tin nhắn gần nhất của người dùng. Highlights theo cài đặt "Ngôn ngữ tóm tắt"; Auto = ngôn ngữ giao diện `[giả định]` |
| BR-13 | **Highlights (Q39).** Trợ lý bật, đã đồng ý (BR-19), Claude Code sẵn sàng (BR-25) và bật "Tóm tắt tự động" → app chạy \[HighlightsDraft\] vào các ngày có trong lịch làm việc (lịch chung, QC-02 mục 8), tại **giờ kết thúc của lịch chung** của ngày đó theo timezone người dùng (không theo giờ Daily shutdown người dùng đã đổi, D7); ngày không có trong lịch làm việc hoặc không có task xong → không soạn. App không mở tại thời điểm đó → soạn khi người dùng mở app lần kế tiếp trong cùng ngày làm việc D (trước mốc đầu ngày D+1); qua ngày D mà chưa soạn → không có nháp tự động, người dùng vẫn dùng "Soạn bằng AI" (UC-05 A1) (D7). Một ngày làm việc chỉ có một nháp tự động cho mỗi người dùng, kể cả khi có nhiều máy (server giữ khoá user + ngày) `[giả định]`. Nguồn: task `HOAN_THANH` trong ngày làm việc (QC-01) + hoạt động công cụ (\[IntegrationActivity\], G11) chỉ khi bật BR-20; hoạt động chỉ gồm việc do chính tài khoản đã kết nối thực hiện, Gmail không có hoạt động "đóng" (C28, G11 BR-19). Nháp ở `CHO_DUYET`, chỉ thành highlights của ritual khi người dùng hoàn tất bước highlights (G08). Đã có bản người dùng sửa → không ghi đè, chỉ gợi ý thêm |
| BR-14 | **Planning Agent.** Chỉ chạy khi trợ lý bật, đã đồng ý (BR-19), Claude Code sẵn sàng (BR-25) và bật Beta "Agentic Daily Planning". App không giới hạn số lượt (QC-12 mục 8). Một ngày chỉ có 1 lượt agent ở `DANG_XU_LY`. "Lập lại": đề xuất cũ đang `CHO_DUYET` → `DA_HOAN_TAC` (`rejected = true`); đề xuất cũ đã `DA_AP_DUNG` → hoàn tác cả kế hoạch (UC-04) trước; rồi tạo đề xuất mới |
| BR-15 | **Chat (Q39).** Giao diện như chat thường. Tin nhắn 1–2.000 ký tự `[giả định]`; không giới hạn số tin phía app; app giữ lịch sử 90 ngày `[giả định]`; người dùng xoá được cuộc trò chuyện (xoá nội dung chat trong app, không đụng task đã tạo, không đụng bản ghi phiên Claude Code tự lưu trên máy); ngắt tích hợp → BR-23 |
| BR-16 | **Tắt AI.** Tắt "Trợ lý" → ẩn nút ✨, không gọi Claude Code cho chat, Planning Agent, highlights và gợi ý task (BR-30); \[McpServer\] ngừng nhận kết nối mới và cắt phiên đang mở (phiên terminal nhận MSG-30) (QC-12 mục 7); `aiConsentAt` giữ nguyên. Planning Agent cần thêm Beta bật. Gợi ý planned / channel có thêm công tắc riêng (G02) |
| BR-17 | **Chế độ chỉ đọc (QC-09, Q8, bản 1.1).** Workspace chỉ đọc → app không gọi Claude Code cho mọi tính năng, kể cả nháp highlights; công cụ ghi MCP trả `WORKSPACE_READ_ONLY`, công cụ đọc vẫn dùng được; khung chat hiện MSG-12, ô nhập disabled; "Plan my day" disabled. Thay đổi `CHO_DUYET` không áp dụng được (402) |
| BR-18 | **Bộ đánh giá.** ≥ 200 câu Việt / Anh, chạy qua Claude Code với \[McpServer\] thật trên dữ liệu thử; đạt ≥ 95% tổng `[giả định]` và 100% nhóm "rào chắn", "ngày giờ" và "lệnh ẩn trong dữ liệu" (Q21); nhóm "ngày giờ" chứa mọi dòng của bảng ví dụ QC-01 làm ca chuẩn (C33); chạy trước mỗi lần đổi prompt / chỉ dẫn, bộ công cụ hoặc mô tả công cụ MCP, và trước khi đổi phiên bản Claude Code tối thiểu được hỗ trợ (BR-25); không đạt → chặn phát hành cấu hình đó. App không chọn model cho người dùng; bộ đánh giá chạy với model mặc định của Claude Code `[giả định]` |
| BR-19 | **Đồng ý dùng AI (Q21, QC-12 mục 7).** `ai.assistantEnabled` mặc định `false`. Lần đầu bật (✨, "Plan my day", "Soạn bằng AI", toggle "Trợ lý") khi `aiConsentAt` trống → mở **SCR-10** (màn gọn, nói rõ dữ liệu nào đưa cho Claude Code); "Đồng ý và bật" lưu `aiConsentAt` (thời điểm server nhận) và `aiConsentVersion`, bật trợ lý, mở \[McpServer\], tiếp tục thao tác đang dở; "Để sau" → không đổi gì. Khi `aiConsentAt` trống: app không gọi Claude Code, \[McpServer\] không nhận kết nối, mọi lời gọi trả `AI_CONSENT_REQUIRED`, kể cả nháp highlights. Bật lại sau khi tắt không hỏi lại `[giả định]`. **Rút lại đồng ý** (G01 BR-23c giao cho G10, C5): "Rút lại đồng ý dùng AI" ở SCR-09 → xoá `aiConsentAt`, tắt trợ lý, đóng \[McpServer\], huỷ lượt đang chạy, đóng thay đổi `CHO_DUYET`; lần bật sau phải qua SCR-10. Lịch sử chat có bị xoá khi rút lại không: `[giả định: giữ, người dùng tự xoá]`. Mọi lần đồng ý / rút lại ghi nhật ký bảo mật G01 BR-21 |
| BR-20 | **Công cụ đọc dữ liệu tích hợp (Q21, QC-12 mục 6, bản 1.1 khi có G11).** Cài đặt `ai.useIntegrationData` ("Cho AI đọc dữ liệu từ công cụ đã kết nối") mặc định `false`. `false` → \[McpServer\] không có công cụ đọc dữ liệu tích hợp; không đưa item, tiêu đề item hay \[IntegrationActivity\] của G11 vào bất kỳ lượt nào (chat, Planning Agent, highlights, terminal). `true` → có công cụ "Xem việc từ công cụ đã kết nối" và "Xem hoạt động trên công cụ trong ngày" (mục 3.1; dữ liệu theo G11 BR-26); phiên gọi một trong hai công cụ → `hasExternalData = true` và theo BR-06. Bản 1.0 chưa có G11 → công tắc ẩn `[giả định]` |
| BR-21 | **Áp dụng thay đổi (C31).** \[ProposalApply\] kiểm `version` từng task: task đã đổi sau khi Claude Code đọc (thay đổi chờ duyệt) hoặc phiên bản Claude Code gửi kèm đã cũ (áp dụng ngay), hoặc thay đổi có giờ bắt đầu đã qua, hoặc ngày < hôm nay → chỉ loại dòng đó (`SKIPPED_STALE` / `SKIPPED_PAST`), các dòng khác vẫn áp dụng; báo MSG-19; với áp dụng ngay, công cụ MCP trả lỗi để Claude Code đọc lại và thử lại. Mọi dòng của thay đổi chờ duyệt bị loại → đề xuất giữ `CHO_DUYET`, MSG-15 kèm "Lập lại". Đề xuất `CHO_DUYET` hết hạn ở mốc đầu ngày của ngày làm việc kế tiếp (cuối ngày làm việc tạo đề xuất) → `DA_HOAN_TAC` (`expired = true`) |
| BR-22 | (Bỏ — không còn hạn mức AI theo gói; xem QC-10, QC-12 mục 8, Q46 (thay C32). Lỗi hết hạn mức phía Claude Code: BR-29) |
| BR-23 | **Ngắt tích hợp (C30).** Nhận sự kiện ngắt tích hợp từ G11 (`integration.disconnected`) → job `ai.history.purgeIntegration` xoá dữ liệu của tích hợp đó trong lịch sử AI của app: kết quả công cụ lưu kèm đề xuất, `itemRef` và nội dung item trong câu trả lời, nháp highlights; chỗ bị xoá hiện MSG-21. Tin nhắn người dùng tự gõ giữ nguyên `[giả định]`. Task đã tạo và \[ActivityLog\] giữ nguyên. Bản ghi phiên do Claude Code tự lưu trên máy nằm ngoài phạm vi xoá của app; SCR-10 nói rõ điều này. Từ lúc ngắt, công cụ đọc dữ liệu tích hợp không trả dữ liệu của tích hợp đó nữa |
| BR-24 | **Task từ item tích hợp (B14).** Công cụ "Tạo task từ item" chỉ có khi bật BR-20; vì phiên đã đọc dữ liệu tích hợp nên thay đổi luôn `CHO_DUYET` (BR-06); khi người dùng duyệt, \[ProposalApply\] gọi G11 \[TaskFromItem\] với `actor = ai`, `source = ai`, không tạo task thường. G11 trả `ALREADY_LINKED` → bỏ dòng "Thêm", thay bằng dòng "Đã có trong {ngày}" (không tính là thay đổi). Task có liên kết tích hợp không bao giờ được AI hoàn thành (BR-26) nên AI không bao giờ đẩy trạng thái ra nguồn |
| BR-25 | **Phát hiện Claude Code (QC-12 mục 1–2).** App kiểm tra Claude Code khi khởi động, khi mở SCR-09, khi bấm "Kiểm tra lại", và khi một lời gọi lỗi vì CLI. Kết quả theo mục 4.3: `CHUA_CAI`, `CHUA_DANG_NHAP`, `PHIEN_BAN_CU` (< phiên bản tối thiểu được hỗ trợ, `[giả định — tech chốt con số]`), `SAN_SANG`. Khác `SAN_SANG` → ẩn mọi điểm vào AI (✨, "Plan my day", "Soạn bằng AI", gợi ý task, công cụ MCP), hiện **SCR-11** đúng trạng thái (MSG-24 / MSG-25 / MSG-26); mọi chức năng lõi vẫn chạy đủ. Trạng thái Claude Code là của từng máy, không đồng bộ giữa thiết bị. Cách phát hiện, đọc phiên bản, trạng thái đăng nhập: tech chốt |
| BR-26 | **Cho phép AI hoàn thành và xoá task (QC-12 mục 4, Q46).** Cài đặt `ai.allowCompleteDelete` mặc định `false`; bật cần xác nhận MSG-32. `true` → \[McpServer\] có thêm công cụ "Hoàn thành task" và "Xoá task" (vào Thùng rác). Hoàn thành theo G02 (QC-05 dòng "Hoàn thành": dừng timer, rút ngắn timebox; task tương lai về hôm nay, instance lặp giữ ngày). Công tắc tắt → `AI_ACTION_FORBIDDEN` · reason `TOGGLE_OFF`. **Task có liên kết tích hợp còn hiệu lực** (G11 \[TaskLink\] khác `DA_NGAT_LIEN_KET`) → công cụ hoàn thành trả `AI_ACTION_FORBIDDEN` · reason `LINKED_TASK` (mã dùng chung với G02 BR-21), trợ lý nói người dùng tự hoàn thành (MSG-07). Công cụ xoá cũng từ chối task có liên kết tích hợp còn hiệu lực với cùng reason `LINKED_TASK`; AI không bao giờ hoàn thành hay xoá task có liên kết tích hợp (D10). Bỏ hoàn thành không có trong MCP (G02 BR-21) `[giả định]`; hoàn thành / xoá subtask theo cùng công tắc (D10). Không có xoá vĩnh viễn. Tắt công tắc → hai công cụ biến mất từ lượt kế tiếp; thay đổi đã áp dụng vẫn hoàn tác được |
| BR-27 | **MCP server local (QC-12 mục 3, 7).** App chạy \[McpServer\] trên máy, chỉ nhận kết nối từ chính máy đó, chỉ khi: người dùng đã đăng nhập app, trợ lý bật và đã đồng ý (BR-19). Phiên terminal không cần app phát hiện được Claude Code (BR-25) `[giả định]`. Mỗi kết nối là một **phiên AI** (mục 4.4). Bộ công cụ theo mục 3.1, lọc theo BR-20, BR-26. Công cụ ghi cần app đang kết nối được server (để kiểm phiên bản và ghi Hoàn tác); mất kết nối server → trả `AI_OFFLINE` `[giả định]`. Kiểu kết nối, đăng ký với Claude Code, xác thực tiến trình hợp lệ: HTTP cục bộ `127.0.0.1` cổng ngẫu nhiên + token theo lượt cài ([`docs/tech/01`](../tech/01-quyet-dinh-tech-stack-va-api.md) mục 4) |
| BR-28 | **Phiên từ terminal (QC-12 mục 3).** Người dùng tự mở Claude Code trong terminal và kết nối tới \[McpServer\] theo hướng dẫn ở SCR-09 #13 khi app đang mở. Phiên terminal dùng cùng bộ công cụ, rào chắn, nhật ký (`aiAgent = terminal`), chip "AI" và Hoàn tác. Thay đổi áp dụng ngay → toast MSG-29 (gộp theo phiên, tối đa 1 toast / 10 giây `[giả định]`); thay đổi chờ duyệt (BR-06) → MSG-31 và hiện ở **SCR-12**. Một phiên terminal kết thúc khi Claude Code ngắt kết nối hoặc app đóng; "Hoàn tác tất cả" của phiên làm ở SCR-12. Thao tác song song với khung chat hoặc người dùng trên cùng task theo QC-08 (thứ tự server nhận; cụm vị trí trên phiên bản cũ bị từ chối, công cụ trả `VERSION_CONFLICT` để Claude Code đọc lại). App đóng / đăng xuất → \[McpServer\] tắt, Claude Code không còn thấy công cụ của app |
| BR-29 | **Lỗi phía Claude Code (EC-39, QC-12 mục 8).** (a) Hết hạn mức gói Claude: app hiện nguyên văn thông báo của Claude Code (MSG-28), không tự đếm hay chặn lượt; chat giữ tin nhắn để gửi lại; Planning Agent / highlights chuyển luồng thủ công. (b) Claude Code bị đóng / dừng giữa lượt (tiến trình thoát, bị tắt, máy treo): lượt → `LOI` theo BR-09, MSG-27; app kiểm tra lại BR-25. (c) Chưa đăng nhập / phiên đăng nhập Claude hết hạn giữa chừng: `LOI`, trạng thái → `CHUA_DANG_NHAP`, SCR-11. (d) Mất mạng phía Claude Code: MSG-06. Mọi trường hợp: thay đổi đã áp dụng giữ nguyên, vẫn hoàn tác được |
| BR-30 | **Lời gọi AI cho gợi ý task (Q33).** G02 \[TaskSuggest\] được app thực hiện bằng một lượt Claude Code ngắn (`aiAgent = task_suggest`), chỉ đọc (không có công cụ ghi), trả thời lượng và channel. Chỉ gọi khi trợ lý bật, đã đồng ý, `SAN_SANG` và bật "Gợi ý channel" / "Gợi ý thời lượng"; ngược lại không gọi, G02 bỏ qua gợi ý. Lỗi, hết hạn mức hoặc quá ngưỡng thời gian của G02 → bỏ qua gợi ý, không báo lỗi. Gợi ý không tạo đề xuất, không có Hoàn tác (G02 BR-04 xử lý nguồn `ai` / `user`) |

### 3.1. Danh sách công cụ MCP (mức nghiệp vụ)

Tên nghiệp vụ dưới đây là hợp đồng giữa sản phẩm và tech; tên kỹ thuật, tham số và schema: tech chốt (`docs/tech/01` mục 4). Mọi công cụ chỉ có khi \[McpServer\] nhận kết nối (BR-27). Công cụ ghi chỉ nhận ngày `YYYY-MM-DD` và giờ tuyệt đối (BR-04), mang `version` của task đã đọc (BR-21), và áp dụng / chờ duyệt theo BR-06.

| **Công cụ** | **Loại** | **Điều kiện có** | **Ghi chú** |
| --- | --- | --- | --- |
| Xem ngữ cảnh thời gian | Đọc | Luôn | `now`, timezone, mốc đầu ngày, `currentWorkday`, lịch làm việc, khung giờ channel (BR-03) |
| Xem board ngày | Đọc | Luôn | Task của một ngày làm việc, planned, thời gian trống, sức chứa, cờ quá tải (G04) |
| Xem backlog | Đọc | Luôn | Task `BACKLOG` theo bucket (G06) |
| Xem lịch | Đọc | Luôn | Timebox và sự kiện lịch ngoài trong khoảng ngày (tiêu đề, giờ, busy) (G05) |
| Tìm task | Đọc | Luôn | Theo từ khoá / channel / khoảng ngày; tối đa 50 kết quả `[giả định]` |
| Xem chi tiết task | Đọc | Luôn | Ghi chú, subtask, planned, actual, timebox, liên kết tích hợp (chỉ loại nguồn, không nội dung) |
| Xem channel | Đọc | Luôn | Tên, khung giờ channel (G02) |
| Xem objective tuần | Đọc | Khi có G09 (1.1) | Objective và tiến độ (G09) |
| Xem hồ sơ agent | Đọc | Luôn | Giới thiệu, theme days (\[AgentProfile\]) |
| Tạo task | Ghi | Luôn | Kèm subtask `[giả định]`; nhật ký `ai` |
| Sửa task | Ghi | Luôn | Tiêu đề, ghi chú, planned, channel (QC-12 mục 3); priority `[giả định]` |
| Thêm subtask, sắp thứ tự, gắn objective | Ghi | Luôn `[giả định — chưa có trong QC-12 mục 3]` | Gắn objective khi có G09 |
| Dời ngày | Ghi | Luôn | QC-05 dòng "AI dời ngày"; chặn `PAST_DATE` |
| Đưa vào backlog | Ghi | Luôn | QC-05 dòng "Đưa vào backlog" |
| Timebox / gỡ timebox | Ghi | Luôn | Theo G05 |
| Ghi nháp highlights | Ghi | Chỉ trong lượt highlights do app gọi | Nháp `CHO_DUYET` (BR-13) |
| Xem việc từ công cụ đã kết nối | Đọc dữ liệu tích hợp | BR-20 bật | Metadata item (G11 BR-26); gọi → `hasExternalData = true` |
| Xem hoạt động trên công cụ trong ngày | Đọc dữ liệu tích hợp | BR-20 bật | \[IntegrationActivity\] (G11 BR-19); gọi → `hasExternalData = true` |
| Tạo task từ item | Ghi | BR-20 bật | Luôn `CHO_DUYET`; qua G11 \[TaskFromItem\] (BR-24) |
| Hoàn thành task | Ghi | BR-26 bật | Gồm subtask (D10). Từ chối task có liên kết tích hợp (`AI_ACTION_FORBIDDEN` · `LINKED_TASK`); qua G02 \[TaskComplete\] tác nhân `ai` (G02 BR-21) |
| Xoá task | Ghi | BR-26 bật | Từ chối task có liên kết tích hợp (`AI_ACTION_FORBIDDEN` · `LINKED_TASK`, D10); vào Thùng rác (QC-03); không xoá vĩnh viễn; qua G02 \[TaskDelete\] tác nhân `ai` (G02 BR-21) |
| (Không có) Gửi tin / chia sẻ, đổi cài đặt, kết nối / ngắt tích hợp, xoá vĩnh viễn, xuất dữ liệu, tài khoản | — | Không bao giờ | BR-02 |

## 4. Trạng thái

### 4.1. Trạng thái đề xuất AI

Mỗi lượt AI có hành động (một tin chat, một lượt Planning Agent, một nháp highlights) và mỗi phiên terminal (BR-28) tạo một \[AiProposal\] gom các thay đổi để hoàn tác cả lượt. Một đề xuất có thể có cả thay đổi đã áp dụng (trước khi phiên đọc dữ liệu tích hợp) và thay đổi chờ duyệt (sau đó) (BR-06).

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_XU_LY` | App đã gọi Claude Code (hoặc phiên terminal đang mở), chưa có kết quả cuối | Chat: "Đang nghĩ…" + bộ đếm giây. Agent: danh sách bước tiến độ. Highlights: "Đang soạn…". Terminal: dòng phiên "Đang hoạt động" ở SCR-12 |
| `CHO_DUYET` | Có thay đổi chưa áp dụng: phiên có `hasExternalData` (BR-06); nháp highlights; hoặc khung mơ hồ BR-05 | SCR-05 / SCR-03 chế độ "Chờ duyệt" / SCR-12 / nháp có ✨ trong SCR-07 |
| `DA_AP_DUNG` | Ít nhất một thay đổi đã áp dụng, chưa hoàn tác hết | Chip task có "Hoàn tác"; chip "AI" trên card; SCR-03 chế độ "Đã áp dụng"; nhật ký task ghi tác nhân AI |
| `DA_HOAN_TAC` | Mọi thay đổi đã hoàn tác, hoặc người dùng Huỷ / Lập lại ở `CHO_DUYET` (`rejected = true`), hoặc `CHO_DUYET` hết hạn (`expired = true`, BR-21) | Chip gạch ngang "Đã hoàn tác" / thẻ xám "Đã huỷ" / "Đã hết hạn" |
| `LOI` | Claude Code lỗi, bị đóng giữa chừng, hết hạn mức Claude (BR-29), quá thời gian (BR-09), hoặc mọi hành động bị \[AiActionExecutor\] từ chối; không có thay đổi nào đã áp dụng | MSG-04 / MSG-05 / MSG-27 / MSG-28; Planning Agent → luồng thủ công |

Chuyển trạng thái: `DANG_XU_LY` → `DA_AP_DUNG` (có thay đổi áp dụng ngay, BR-06) | `CHO_DUYET` (chỉ có thay đổi chờ duyệt) | `LOI` (lỗi khi chưa áp dụng gì; lỗi khi đã áp dụng một phần → `DA_AP_DUNG`, BR-09) · `CHO_DUYET` → `DA_AP_DUNG` (Áp dụng / Áp dụng và tiếp) | `DA_HOAN_TAC` (Huỷ, Lập lại, hết hạn cuối ngày làm việc — BR-21) · `DA_AP_DUNG` → `DA_HOAN_TAC` (hoàn tác hết, gồm "Hoàn tác kế hoạch AI", "Hoàn tác tất cả"). Đề xuất chỉ trả lời (không hành động) không lưu trạng thái.

### 4.2. Trạng thái từng thay đổi trong đề xuất

`CHUA_AP_DUNG` → `DA_AP_DUNG` → `DA_HOAN_TAC`. `CHUA_AP_DUNG` → `BO_QUA` khi bị loại lúc áp dụng vì lỗi thời hoặc giờ đã qua (BR-21). `DA_AP_DUNG` → `XUNG_DOT` khi hoàn tác gặp sửa đổi của người dùng (BR-08); người dùng chọn "Trả về trước AI" → `DA_HOAN_TAC`, chọn "Giữ bản của tôi" → giữ `DA_AP_DUNG`, cờ `keptByUser`. Đề xuất ở `DA_AP_DUNG` khi còn ≥ 1 thay đổi `DA_AP_DUNG`.

### 4.3. Trạng thái Claude Code trên máy (BR-25)

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `DANG_KIEM_TRA` | App đang kiểm tra | SCR-09 #12 "Đang kiểm tra Claude Code…" |
| `CHUA_CAI` | Không tìm thấy Claude Code CLI trên máy | Ẩn điểm vào AI; SCR-11 với MSG-24 |
| `CHUA_DANG_NHAP` | Có CLI nhưng chưa đăng nhập tài khoản Claude, hoặc phiên đăng nhập hết hạn | Ẩn điểm vào AI; SCR-11 với MSG-25 |
| `PHIEN_BAN_CU` | Phiên bản < phiên bản tối thiểu được hỗ trợ `[giả định — tech chốt]` | Ẩn điểm vào AI; SCR-11 với MSG-26 |
| `SAN_SANG` | Có CLI, đã đăng nhập, phiên bản được hỗ trợ | SCR-09 #12 "Claude Code · {phiên bản} · Sẵn sàng"; điểm vào AI hiện khi trợ lý bật |

Chuyển: `DANG_KIEM_TRA` → một trong bốn trạng thái còn lại; mọi trạng thái → `DANG_KIEM_TRA` (khởi động app, mở SCR-09, "Kiểm tra lại", lời gọi lỗi vì CLI — BR-29). Trạng thái lưu trên máy, không đồng bộ giữa thiết bị.

### 4.4. Phiên AI và nguồn

Một **phiên AI** là một kết nối của Claude Code tới \[McpServer\]: một lượt app gọi (chat, Planning Agent, highlights, gợi ý task) hoặc một phiên terminal (từ lúc kết nối tới lúc ngắt). Thuộc tính: `aiSessionId`, `aiAgent` (`assistant` / `planning_agent` / `highlights` / `task_suggest` / `terminal`), `hasExternalData` (mặc định `false`; chuyển `true` một chiều khi phiên gọi công cụ đọc dữ liệu tích hợp, BR-06, BR-20), thời điểm bắt đầu / kết thúc. Một cuộc trò chuyện chat có nhiều phiên (mỗi tin nhắn một phiên) `[giả định]`.

## 5. Use Case

### UC-01 Thiết lập Planning Agent

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Claude Code `SAN_SANG` (BR-25, nếu chưa → UC-10); trợ lý bật và đã đồng ý (BR-19, nếu chưa → UC-09 trước); đã bật Beta "Agentic Daily Planning"; chưa có hồ sơ agent hoặc người dùng mở lại thiết lập |
| Hậu điều kiện thành công | Lưu \[AgentProfile\] (giới thiệu, theme days, nguồn dữ liệu được dùng); `setupCompletedAt` có giá trị |
| Hậu điều kiện thất bại | Không có hồ sơ; lần sau bấm "Plan my day" mở lại thiết lập |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Plan my day" lần đầu, hoặc Cài đặt → Trợ lý AI → "Thiết lập Planning Agent" |
| 2 | Hệ thống | Mở **SCR-01** phần 1 "Công cụ": liệt kê lịch (G05) và công cụ (G11) với trạng thái kết nối; nút "Kết nối" trỏ luồng của nhóm sở hữu; công tắc "Cho AI đọc dữ liệu từ công cụ đã kết nối" (BR-20, mặc định tắt; ẩn ở 1.0) kèm MSG-20 |
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
| Tiền điều kiện | Claude Code `SAN_SANG` (BR-25); trợ lý bật và đã đồng ý (BR-19); Beta bật; hồ sơ agent đã có (UC-01); người dùng đang ở Daily planning ngày D (G08); workspace không chỉ đọc (QC-09, 1.1) |
| Hậu điều kiện thành công | Thay đổi hợp lệ đã áp dụng (hoặc, khi chờ duyệt, các dòng được chọn); đề xuất `DA_AP_DUNG`; nhật ký ghi `planning_agent`; ritual sang bước Daily plan (G08), nút "Hoàn tác kế hoạch AI" dùng được |
| Hậu điều kiện thất bại | Không thay đổi nào áp dụng (hoặc thay đổi đã áp dụng một phần được giữ, có "Hoàn tác kế hoạch AI", BR-09); người dùng ở luồng Daily planning thủ công (G08), giữ nội dung đã nhập |

**Luồng chính** (kế hoạch không dùng dữ liệu tích hợp — áp dụng ngay, Q31, QC-12 mục 5)

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Trên **SCR-02** gõ "Điều quan trọng nhất hôm nay" (tuỳ chọn), bấm "Plan my day" |
| 2 | App | Kiểm BR-19, BR-25; tạo đề xuất `DANG_XU_LY` (\[AgentPlanStart\]) và phiên AI `planning_agent`; gọi Claude Code với ngữ cảnh BR-03, chỉ dẫn lập kế hoạch và hồ sơ agent (\[ClaudeCodeRun\], tech chốt); hiện bước tiến độ |
| 3 | Claude Code | Gọi công cụ đọc MCP (mục 3.1): lịch ngày D, board, backlog tới kỳ (G06), objective tuần (G09, 1.1), hồ sơ agent, và việc từ công cụ (G11) chỉ khi bật BR-20; rồi gọi công cụ ghi trong BR-01 |
| 4 | \[McpServer\] | Với mỗi lời gọi ghi: \[AiActionExecutor\] kiểm BR-01, BR-02, BR-04, BR-26; "tạo task từ item" theo BR-24; hợp lệ và `hasExternalData = false` → áp dụng ngay theo BR-21, gắn chip "AI", ghi nhật ký; đề xuất → `DA_AP_DUNG` (BR-06); kết quả trả về cho Claude Code |
| 5 | App | Claude Code kết thúc → mở **SCR-03** Review Plan chế độ "Đã áp dụng": "Planning Agent đã thêm n task, dời m task", danh sách "HÔM NAY · n thay đổi" mỗi dòng có "Hoàn tác", tổng planned so sức chứa của ngày (G04, QC-02 mục 7, Q48), nút "Hoàn tác kế hoạch AI"; dòng bị loại (BR-21) hiện MSG-19 |
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
| A6 | Một số hành động bị \[AiActionExecutor\] từ chối (BR-02, BR-26) | Công cụ trả lỗi cho Claude Code, ghi log; Review Plan chỉ hiện hành động hợp lệ |
| A7 | (Bỏ — không còn hạn mức lượt Planning Agent, BR-22; hết hạn mức phía Claude xem E6) | — |
| A8 | Kế hoạch dùng dữ liệu tích hợp (`hasExternalData = true`, Q31a, QC-12 mục 6) | Bước 4: thay đổi ghi sau lần đọc dữ liệu tích hợp → `CHUA_AP_DUNG`, đề xuất `CHO_DUYET` (thay đổi trước lần đọc đầu tiên đã áp dụng thì giữ nguyên, D8). Bước 5: SCR-03 chế độ "Chờ duyệt" với MSG-22, mỗi dòng chờ duyệt có checkbox (mặc định chọn hết). Bước 6: bỏ chọn dòng không muốn, bấm "Áp dụng và tiếp" → \[ProposalApply\] các dòng được chọn theo BR-21; đề xuất → `DA_AP_DUNG`; tiếp bước 7 |
| A9 | Đề xuất `CHO_DUYET` chưa duyệt tới cuối ngày làm việc (BR-21) | Job `ai.proposal.expire` → `DA_HOAN_TAC` (`expired`); SCR-03 hiện "Đã hết hạn", nút áp dụng disabled |
| A10 | Item đã có task (G11 trả `ALREADY_LINKED`, BR-24) | Dòng "Thêm" được thay bằng "Đã có trong {ngày}", không áp dụng gì cho dòng đó |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | 10 giây chưa có bước tiến độ đầu, Claude Code lỗi, hoặc tổng > 5 phút (EC-39) | Dừng Claude Code; chưa áp dụng gì → đề xuất `LOI`; đã áp dụng một phần → giữ, đề xuất `DA_AP_DUNG`, thông báo kèm "Hoàn tác kế hoạch AI" (BR-09); MSG-05; mở Daily planning thủ công (G08) bước 1; nội dung "Điều quan trọng nhất" đưa vào ô "Obstacles in my way" |
| E2 | Thiếu ngữ cảnh thời gian (BR-03) | Không gọi Claude Code; như E1, log `AI_CONTEXT_MISSING` |
| E3 | \[ProposalApply\] gặp task đã bị xoá / sửa ở thiết bị khác, hoặc giờ đã qua (C31) | Chỉ loại các dòng đó (`BO_QUA`), các dòng khác vẫn áp dụng, MSG-19 (BR-21). Mọi dòng chờ duyệt bị loại → đề xuất giữ `CHO_DUYET`; MSG-15 "Kế hoạch vừa thay đổi" và nút "Lập lại" |
| E4 | Mất mạng | MSG-06; Daily planning thủ công vẫn dùng offline (G08) |
| E5 | Chưa có đồng ý (`AI_CONSENT_REQUIRED`) | Không gọi Claude Code; mở UC-09 |
| E6 | Claude Code báo hết hạn mức gói Claude (BR-29a) | Như E1, nhưng hiện MSG-28 (nguyên văn thông báo của Claude Code) thay MSG-05 |
| E7 | Claude Code bị đóng / dừng giữa chừng (BR-29b) | Như E1, hiện MSG-27; app kiểm tra lại Claude Code (UC-10) |
| E8 | Claude Code không `SAN_SANG` lúc bấm (gỡ, đăng xuất sau lần kiểm tra trước) | Không chạy; SCR-02 thay "Plan my day" bằng SCR-11 (UC-10) |

### UC-03 Trò chuyện và ra lệnh cho trợ lý

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Claude Code `SAN_SANG` (BR-25); cài đặt "Trợ lý" bật và đã đồng ý (BR-19); người dùng đã đăng nhập |
| Hậu điều kiện thành công | Câu trả lời hiện trong cuộc trò chuyện; nếu có hành động: áp dụng ngay, hoặc chờ duyệt khi phiên đã đọc dữ liệu tích hợp (BR-06); nhật ký ghi `assistant` |
| Hậu điều kiện thất bại | Không thay đổi task (hoặc thay đổi đã áp dụng trước khi lỗi được giữ, hoàn tác được); tin nhắn của người dùng còn trong ô / lịch sử để gửi lại |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm nút ✨ góc dưới → **SCR-04** (giao diện như chat thường, Q39); gõ tin nhắn, Enter |
| 2 | App | Kiểm BR-15, BR-19, BR-25; tạo phiên AI `assistant`; gọi Claude Code (\[ChatSend\] / \[ClaudeCodeRun\]) kèm ngữ cảnh BR-03, lịch sử cuộc trò chuyện và màn hình đang xem (ngày đang xem, task đang chọn); hiện "Đang nghĩ…" |
| 3 | Claude Code | Gọi công cụ đọc MCP cần thiết (công cụ đọc dữ liệu tích hợp chỉ có khi bật BR-20); trả lời dạng luồng (stream); nếu cần hành động, gọi công cụ ghi với ngày tuyệt đối (BR-04), ngày tương đối hiểu theo BR-05 |
| 4 | \[McpServer\] | \[AiActionExecutor\] kiểm BR-01, BR-02, BR-04, BR-05, BR-26 cho mỗi lời gọi ghi; `hasExternalData = false` → áp dụng ngay theo BR-21, chip "AI", nhật ký; đề xuất `DA_AP_DUNG` (BR-06) |
| 5 | App | Câu trả lời kèm chip mỗi task: tiêu đề, "Thứ Năm, 5/11 · 14:00", "Hoàn tác"; lượt chạm > 3 task → dòng tóm tắt "Đã thay đổi n task" kèm "Hoàn tác tất cả" (EC-37) |
| 6 | App | Hiện "Đã nghĩ {n}s"; board, lịch cập nhật qua realtime `task.upserted` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Câu hỏi không cần hành động ("chiều nay còn trống bao lâu?") | Chỉ trả lời, có số liệu từ G04 (thời gian trống, tổng planned); không tạo đề xuất |
| A2 | Phiên đã gọi công cụ đọc dữ liệu tích hợp (`hasExternalData = true`, Q21, QC-12 mục 6), dù chỉ 1 task | Mọi lời gọi ghi sau đó → `CHUA_AP_DUNG`, đề xuất `CHO_DUYET`; công cụ trả cho Claude Code "đang chờ người dùng duyệt"; hiện **SCR-05** trong khung chat kèm MSG-22; "Áp dụng" → \[ProposalApply\] các dòng được chọn theo BR-21; "Huỷ" → \[ProposalReject\]; không duyệt tới cuối ngày làm việc → hết hạn (BR-21) |
| A3 | Khung mơ hồ BR-05 (EC-01: mốc 04:00, 02:10 ngày 4/11 — ngày làm việc Thứ Ba 3/11 — "tạo task gọi khách ngày mai") | Không tạo; trợ lý hỏi MSG-08 với 2 nút "Thứ Tư, 4/11" (ngày làm việc + 1) / "Thứ Năm, 5/11" (ngày làm việc + 2); chọn → tiếp bước 3 với ngày đã chọn |
| A4 | Yêu cầu hành động bị cấm (BR-02), gồm "đánh dấu xong" / "xoá" khi BR-26 tắt, hoặc hoàn thành / xoá task có liên kết tích hợp (D10) | Trả lời MSG-07 kèm cách tự làm (ví dụ "Xoá: chọn task, Ctrl+Backspace"; "Hoàn thành: tích ✓ hoặc phím C"); với hoàn thành / xoá khi BR-26 tắt, nhắc công tắc ở Cài đặt → Trợ lý AI; không tạo đề xuất |
| A5 | Bấm "Hoàn tác" trên chip | → UC-04 |
| A6 | "Lịch sử" | Danh sách cuộc trò chuyện (\[ChatThreadList\]) mới nhất trước; mở lại cuộc cũ, chip vẫn hoàn tác được trong thời hạn BR-08 |
| A7 | "Cuộc trò chuyện mới" | \[ChatThreadCreate\]; ngữ cảnh cuộc cũ không gửi kèm |
| A8 | Quá 10 giây chưa xong | Hiện "Vẫn đang xử lý…" và nút "Dừng"; Dừng → dừng Claude Code; chưa áp dụng gì → `LOI`; đã áp dụng một phần → giữ, kèm "Hoàn tác tất cả" (BR-09) |
| A9 | Yêu cầu nhắc tới task không tìm thấy hoặc khớp nhiều task | Trợ lý hỏi lại, liệt kê tối đa 5 task khớp để chọn |
| A10 | "Hôm nay / tối nay" trong khung 00:00 → mốc đầu ngày (ví dụ 02:10 ngày 4/11, "tạo task gọi khách hôm nay") | Không hỏi lại; dùng ngày làm việc hiện tại (Thứ Ba, 3/11) theo BR-05; chip hiện ngày cụ thể |
| A11 | Yêu cầu dời ngày / đưa vào backlog | Áp dụng theo QC-05 dòng "AI dời ngày" / "Đưa vào backlog" (timebox, sự kiện ngoài, số ngày bị hoãn); timer không dừng |
| A12 | Yêu cầu hoàn thành / xoá khi BR-26 bật | Áp dụng ngay theo BR-26 (task có liên kết tích hợp: từ chối cả hoàn thành lẫn xoá, MSG-07, D10); chip "Đã hoàn thành" / "Đã chuyển vào Thùng rác" kèm "Hoàn tác" (BR-08) |
| A13 | Một phiên terminal đang thay đổi cùng task (BR-28) | Theo QC-08; lời gọi ghi trên phiên bản cũ nhận `VERSION_CONFLICT`, Claude Code đọc lại rồi thử lại hoặc báo người dùng |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Claude Code lỗi / quá 60 giây | Đề xuất `LOI` (hoặc giữ phần đã áp dụng, BR-09); MSG-04 có nút "Gửi lại" |
| E2 | Claude Code báo hết hạn mức gói Claude (BR-29a) | Hiện MSG-28 (nguyên văn thông báo của Claude Code) trong khung chat; tin nhắn giữ để gửi lại; app không khoá ô nhập |
| E3 | Tin nhắn > 2.000 ký tự | MSG-02, chặn gửi |
| E4 | Workspace chỉ đọc (QC-09, 1.1) | Không gọi Claude Code; khung chat hiện MSG-12, ô nhập disabled (BR-17) |
| E5 | Mất mạng | MSG-06; tin nhắn giữ trong ô, không xếp hàng đợi offline |
| E6 | Hành động hợp lệ nhưng ghi thất bại (task vừa bị xoá / đổi ở thiết bị khác, BR-21) | Chip của task đó hiện "Không thực hiện được"; các task khác vẫn áp dụng |
| E7 | Chưa có đồng ý (`AI_CONSENT_REQUIRED`) | Không gửi; mở UC-09 |
| E8 | Claude Code bị đóng / dừng giữa chừng (BR-29b) | MSG-27 kèm "Gửi lại"; thay đổi đã áp dụng giữ nguyên; app kiểm tra lại Claude Code (UC-10) |
| E9 | Claude Code không `SAN_SANG` (chưa cài, chưa đăng nhập, phiên bản cũ) | Nút ✨ ẩn; mở từ Command menu → SCR-11 (UC-10) |

### UC-04 Hoàn tác hành động AI

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đề xuất `DA_AP_DUNG`; thay đổi cần hoàn tác áp dụng chưa quá 7 ngày `[giả định]` |
| Hậu điều kiện thành công | Thay đổi được chọn → `DA_HOAN_TAC`; trường AI đổi trả về giá trị trước AI; sửa đổi của người dùng giữ nguyên; nhật ký ghi "hoàn tác thay đổi của AI" |
| Hậu điều kiện thất bại | Task giữ nguyên |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm "Hoàn tác" trên chip hoặc dòng SCR-03 / SCR-12 (một thay đổi), "Hoàn tác tất cả" trong đề xuất / phiên terminal (khung chat, toast MSG-29, SCR-12), "Hoàn tác kế hoạch AI" (SCR-03 hoặc bước Daily plan của G08), hoặc "Hoàn tác" ở dòng nhật ký AI trong chi tiết task (G02 SCR-03) |
| 2 | Hệ thống | Gọi \[ProposalUndo\] với `changeIds` |
| 3 | Hệ thống | Với từng thay đổi: so `version` và lịch sử trường; không có sửa đổi của người dùng sau AI → trả giá trị trước AI (BR-08) |
| 4 | Hệ thống | Chip gạch ngang "Đã hoàn tác"; task AI tạo → Thùng rác; toast MSG-09 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Người dùng đã sửa trường khác của task (ví dụ AI dời ngày, người dùng đổi priority) | Chỉ trả ngày; priority của người dùng giữ (EC-38) |
| A2 | Người dùng đã sửa chính trường AI đổi, hoặc thêm nội dung vào task AI tạo (EC-38) | Thay đổi → `XUNG_DOT`; mở **SCR-06** liệt kê trường xung đột: "Giữ bản của tôi" / "Trả về trước khi AI sửa" (áp cho từng dòng hoặc tất cả) |
| A3 | Task đã bị người dùng xoá | Bỏ qua thay đổi đó, ghi "không còn task" |
| A4 | (Bỏ — AI không đánh dấu xong, xem BR-02 / Q20.) Thay bằng A8 khi BR-26 bật (Q46) | — |
| A5 | Hoàn tác timebox | Gỡ timebox, xoá sự kiện ngoài (G05) |
| A6 | Hoàn tác dời ngày / vào backlog | Trả ngày dự định / bucket cũ, khôi phục liên kết timebox; sự kiện ngoài đã bị xoá thì tạo lại với giờ cũ (QC-05). Ngày cũ < hôm nay → về hôm nay `[giả định]` |
| A7 | "Hoàn tác kế hoạch AI" / "Hoàn tác tất cả" | `changeIds` = mọi thay đổi `DA_AP_DUNG` của đề xuất Planning Agent / lượt chat / phiên terminal; áp bước 3 và A1–A9 cho từng thay đổi; các dòng `XUNG_DOT` gom vào một SCR-06 |
| A8 | Hoàn tác "hoàn thành" của AI (BR-26) | Bỏ hoàn thành theo QC-03 mục 4: cùng ngày làm việc với lúc hoàn thành → trả lại mọi tác dụng phụ; sang ngày khác → chỉ xoá `completedAt`, task ở hôm nay. Timer đã dừng không chạy lại. Người dùng đã sửa task sau đó → `XUNG_DOT` (A2) |
| A9 | Hoàn tác "xoá" của AI (BR-26) | Khôi phục từ Thùng rác theo QC-03 mục 3 (instance lặp áp QC-06). Task đã bị xoá vĩnh viễn (quá 30 ngày) → bỏ qua, như A3 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Quá thời hạn hoàn tác | Nút Hoàn tác ẩn; gọi API trả `AI_UNDO_EXPIRED` → MSG-10 |
| E2 | \[ProposalUndo\] lỗi | Giữ nguyên, MSG-14 |

### UC-05 Soạn và duyệt highlights AI cuối ngày

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Claude Code `SAN_SANG` (BR-25); trợ lý bật và đã đồng ý (BR-19); workspace không chỉ đọc (QC-09, 1.1); ngày làm việc D có ≥ 1 task `HOAN_THANH` |
| Hậu điều kiện thành công | Highlights người dùng đã duyệt lưu vào ritual Daily shutdown ngày D (G08); đề xuất `DA_AP_DUNG` |
| Hậu điều kiện thất bại | Bước highlights dùng danh sách việc đã xong biên tập tay (G08 BR-17) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | App | Job `ai.highlights.draft` trên máy: ngày D có trong lịch làm việc (lịch chung) và tới giờ kết thúc của lịch chung ngày D theo timezone người dùng, hoặc app mở lần kế tiếp trong ngày D sau giờ đó (BR-13, Q39, D7); bỏ qua khi chưa có `aiConsentAt`, đã tắt trợ lý hoặc "Tóm tắt tự động", Claude Code không `SAN_SANG`, workspace chỉ đọc, hoặc server báo ngày D đã có nháp tự động |
| 2 | App | Tạo phiên AI `highlights`; gọi Claude Code (\[HighlightsDraft\]) với chỉ dẫn soạn highlights, ngôn ngữ theo BR-12; Claude Code đọc task xong trong ngày D, thời gian theo channel, và \[IntegrationActivity\] (G11) chỉ khi bật BR-20, rồi gọi công cụ "Ghi nháp highlights" |
| 3 | Hệ thống | Lưu nháp `CHO_DUYET` trên server (đồng bộ mọi thiết bị); không gửi thông báo riêng (lời nhắc shutdown thuộc G08) |
| 4 | Người dùng | Mở Daily shutdown (G08) → bước highlights → **SCR-07** hiện nháp có ✨, mỗi ý có link về task / item nguồn |
| 5 | Người dùng | Sửa, xoá ý, thêm ý; bấm "Tiếp" của bước |
| 6 | Hệ thống | Lưu highlights vào ritual (G08 \[RitualUpdate\]); đề xuất → `DA_AP_DUNG` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Mở shutdown trước giờ kết thúc của lịch chung, ngày không có trong lịch làm việc, job tự soạn chưa xong / lỗi, hoặc tắt "Tóm tắt tự động" | Nút "Soạn bằng AI" trên SCR-07 → bước 2 ngay |
| A2 | Task xong thêm sau khi có nháp | Người dùng chưa sửa → soạn lại khi mở bước. Đã sửa → giữ bản sửa, hiện MSG-13 "Thêm vào" |
| A3 | "Soạn lại" | Tạo nháp mới (không giới hạn lượt phía app); người dùng đã sửa → hỏi xác nhận ghi đè |
| A4 | Ngày không có task xong | Không soạn; SCR-07 hiện trạng thái rỗng của G08 |
| A5 | Công cụ G11 lỗi / chưa kết nối | Soạn chỉ từ task trong app, ghi chú nhỏ "Chưa gồm hoạt động từ {công cụ}" |
| A6 | Tắt "Cho AI đọc dữ liệu từ công cụ đã kết nối" (BR-20) | Soạn chỉ từ task trong app; không có ghi chú lỗi |
| A7 | Chưa có đồng ý, bấm "Soạn bằng AI" | Mở UC-09; đồng ý xong → bước 2 |
| A8 | Claude Code không `SAN_SANG` | Nút "Soạn bằng AI" ẩn; bước highlights dùng danh sách sinh sẵn (G08 BR-17) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Claude Code lỗi / bị đóng giữa chừng / > 10 giây khi người dùng đang mở bước | MSG-05 (bị đóng: MSG-27); hiện danh sách việc đã xong để biên tập tay (G08); "Thử lại" |
| E2 | Job tự soạn lỗi | Thử lại 2 lần cách 5 phút `[giả định]`; vẫn lỗi → không có nháp, A1 dùng được |
| E3 | Claude Code báo hết hạn mức gói Claude (BR-29a) | Job: bỏ qua, không thử lại. Người dùng đang mở bước: MSG-28, dùng danh sách sinh sẵn để biên tập tay |

### UC-06 Gửi phản hồi về AI

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có câu trả lời của trợ lý, Review Plan hoặc nháp highlights |
| Hậu điều kiện thành công | \[AiFeedback\] lưu: đánh giá, nội dung tuỳ chọn, `proposalId`, phiên bản prompt / bộ công cụ MCP, phiên bản Claude Code |
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
| 1 | Người dùng | Cài đặt → Trợ lý AI (**SCR-09**) hoặc Cài đặt → Beta |
| 2 | Người dùng | Đổi một cài đặt |
| 3 | Hệ thống | Gọi \[SettingsUpdate\] (G01 `PATCH /me/settings`); áp BR-16, BR-20, BR-26 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tắt "Trợ lý" khi khung chat đang mở hoặc có phiên terminal | Đóng khung chat; lượt đang `DANG_XU_LY` bị huỷ (thay đổi đã áp dụng giữ nguyên); \[McpServer\] cắt mọi phiên, phiên terminal nhận MSG-30 (BR-16) |
| A2 | Tắt Beta "Agentic Daily Planning" khi có đề xuất `CHO_DUYET` | Đề xuất → `DA_HOAN_TAC`; Daily planning dùng luồng thủ công. Đề xuất đã `DA_AP_DUNG` giữ nguyên, vẫn hoàn tác được từ nhật ký task |
| A3 | "Xoá lịch sử trò chuyện" | Xác nhận MSG-17 → xoá mọi cuộc trò chuyện; chip cũ mất nút Hoàn tác, hoàn tác vẫn làm được từ nhật ký task |
| A4 | Bật "Trợ lý" khi `aiConsentAt` trống | Toggle chưa đổi; mở UC-09; đồng ý → toggle bật |
| A5 | Bật / tắt "Cho AI đọc dữ liệu từ công cụ đã kết nối" | Lưu `ai.useIntegrationData`; bộ công cụ đổi từ phiên AI kế tiếp (phiên terminal đang mở: từ lời gọi kế tiếp `[giả định]`). Tắt khi có đề xuất `CHO_DUYET` có `hasExternalData` → đề xuất giữ nguyên, người dùng vẫn duyệt / huỷ được `[giả định]` |
| A6 | "Rút lại đồng ý dùng AI" (SCR-09 #11) | Xác nhận MSG-23 → \[AiConsent\] `DELETE`; xoá `aiConsentAt`, `ai.assistantEnabled = false`; đóng \[McpServer\]; huỷ lượt `DANG_XU_LY`, đề xuất `CHO_DUYET` → `DA_HOAN_TAC`; thay đổi đã áp dụng giữ nguyên, vẫn hoàn tác được từ nhật ký task (BR-19) |
| A7 | Bật "Cho phép AI hoàn thành và xoá task" (SCR-09 #14) | Dialog MSG-32; "Bật" → lưu `ai.allowCompleteDelete = true`; \[McpServer\] thêm hai công cụ từ phiên kế tiếp (BR-26). Tắt → lưu ngay, không hỏi; hai công cụ biến mất từ lời gọi kế tiếp |
| A8 | "Kiểm tra lại" Claude Code (SCR-09 #12) | → UC-10 |

### UC-08 Chạy bộ đánh giá trước khi đổi prompt, công cụ MCP hoặc phiên bản Claude Code

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Có cấu hình AI mới (prompt / chỉ dẫn, bộ công cụ hoặc mô tả công cụ MCP, phiên bản Claude Code tối thiểu được hỗ trợ) ở môi trường kiểm thử |
| Hậu điều kiện thành công | Báo cáo đạt BR-18; cấu hình được đánh dấu "được phép phát hành" |
| Hậu điều kiện thất bại | Cấu hình bị chặn; bản phát hành giữ cấu hình cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Kỹ sư AI | Tạo pull request đổi prompt / công cụ MCP, hoặc đổi phiên bản Claude Code tối thiểu |
| 2 | Hệ thống (CI) | Chạy \[EvalRun\] qua Claude Code với \[McpServer\] thật trên dữ liệu thử, bộ ≥ 200 câu Việt / Anh, nhóm: ngày giờ (gồm EC-01 lúc 02:10 và mọi dòng của bảng ví dụ QC-01; cả phiên kiểu terminal không có ngữ cảnh do app đưa vào), thao tác task, áp dụng ngay / chờ duyệt khi phiên đọc dữ liệu tích hợp (BR-06), hoàn tác cả lượt (EC-37, EC-38), hành động bị cấm (gồm đánh dấu xong khi BR-26 tắt, hoàn thành task có liên kết khi BR-26 bật), lệnh ẩn trong dữ liệu (câu lệnh trong tiêu đề email / issue / trang Notion), ngôn ngữ, highlights, gợi ý task |
| 3 | Hệ thống | Mỗi câu chạy với `now` cố định; chấm theo hành động mong đợi (đúng loại, đúng task, đúng ngày) và tiêu chí chữ |
| 4 | Hệ thống | Đạt BR-18 → gắn nhãn phát hành; lưu kết quả theo phiên bản |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | < 95% tổng hoặc < 100% nhóm rào chắn / ngày giờ / lệnh ẩn trong dữ liệu | Chặn merge; báo cáo liệt kê câu sai |
| E2 | Claude Code lỗi / hết hạn mức khi chạy | Chạy lại câu lỗi tối đa 2 lần; vẫn lỗi → coi là sai |

### UC-09 Đồng ý dùng AI lần đầu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập; Claude Code `SAN_SANG` (BR-25) `[giả định — có cho đồng ý trước khi cài Claude Code không: câu hỏi mở]`; `aiConsentAt` trống; người dùng bấm ✨, "Plan my day", "Soạn bằng AI", hoặc bật toggle "Trợ lý" (SCR-09) |
| Hậu điều kiện thành công | `aiConsentAt`, `aiConsentVersion` lưu; `ai.assistantEnabled = true`; \[McpServer\] nhận kết nối; thao tác ban đầu tiếp tục |
| Hậu điều kiện thất bại | Không lưu gì; `ai.assistantEnabled = false`; không có lời gọi Claude Code nào; \[McpServer\] không nhận kết nối |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Bấm một điểm vào AI khi chưa đồng ý |
| 2 | Hệ thống | Mở **SCR-10** (màn gọn, QC-12 mục 7): dữ liệu nào được đưa cho Claude Code, Claude Code chạy bằng tài khoản Claude của người dùng, app không gửi cho nhà cung cấp AI nào khác, Claude Code có thể tự lưu bản ghi phiên trên máy, Claude Code trong terminal cũng điều khiển được app, dữ liệu công cụ tích hợp không đưa trừ khi bật riêng, AI không hoàn thành / xoá task trừ khi bật riêng, link chính sách quyền riêng tư |
| 3 | Người dùng | Bấm "Đồng ý và bật" |
| 4 | Hệ thống | Gọi \[AiConsent\]; lưu `aiConsentAt` (thời điểm server nhận), `aiConsentVersion`; bật `ai.assistantEnabled`; phát `settings.changed`; app mở \[McpServer\] (BR-27) |
| 5 | App | Đóng SCR-10, tiếp tục thao tác ở bước 1 (mở khung chat, chạy UC-02, soạn highlights, hoặc giữ toggle bật) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | "Để sau" / đóng SCR-10 | Không lưu; toggle giữ tắt; Daily planning dùng luồng thủ công; bước highlights dùng danh sách sinh sẵn (G08 BR-17) |
| A2 | Đã đồng ý trên thiết bị khác | `settings.changed` cập nhật; không hiện SCR-10 lần nữa |
| A3 | Workspace chỉ đọc (QC-09, 1.1) | Vẫn lưu được đồng ý (cài đặt tài khoản); AI vẫn không chạy tới khi thoát chỉ đọc (BR-17) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | \[AiConsent\] lỗi / mất mạng | Không bật trợ lý; MSG-14 |

### UC-10 Phát hiện và kết nối Claude Code

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Người dùng đã đăng nhập app trên Windows |
| Hậu điều kiện thành công | Trạng thái Claude Code `SAN_SANG` (mục 4.3); điểm vào AI hiện (khi trợ lý bật và đã đồng ý) |
| Hậu điều kiện thất bại | Trạng thái `CHUA_CAI` / `CHUA_DANG_NHAP` / `PHIEN_BAN_CU`; điểm vào AI ẩn; SCR-11 hiện hướng dẫn; chức năng lõi không bị ảnh hưởng |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | App | Khởi động, người dùng mở SCR-09, bấm "Kiểm tra lại", hoặc một lời gọi lỗi vì CLI (BR-29) → trạng thái `DANG_KIEM_TRA` |
| 2 | App | Tìm Claude Code CLI trên máy, đọc phiên bản, kiểm tra trạng thái đăng nhập (\[ClaudeCodeDetect\], tech chốt) |
| 3 | App | Có CLI, đã đăng nhập, phiên bản ≥ tối thiểu → `SAN_SANG`; SCR-09 #12 "Claude Code · {phiên bản} · Sẵn sàng" |
| 4 | App | Trợ lý bật và đã đồng ý → hiện điểm vào AI, mở \[McpServer\] (BR-27); chưa → toggle "Trợ lý" dùng được, bật thì vào UC-09 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Không tìm thấy CLI | `CHUA_CAI`; ẩn điểm vào AI; SCR-11 với MSG-24, link hướng dẫn cài (trang của Anthropic), "Kiểm tra lại" |
| A2 | Có CLI, chưa đăng nhập | `CHUA_DANG_NHAP`; SCR-11 với MSG-25 và hướng dẫn đăng nhập |
| A3 | Phiên bản < tối thiểu | `PHIEN_BAN_CU`; SCR-11 với MSG-26 và hướng dẫn cập nhật |
| A4 | Trạng thái xấu đi trong lúc dùng (gỡ, đăng xuất, phiên Claude hết hạn) | Lượt đang chạy lỗi theo BR-29; chuyển trạng thái tương ứng; ẩn điểm vào AI; thay đổi đã áp dụng vẫn hoàn tác được từ nhật ký task và SCR-12 |
| A5 | Người dùng cài / đăng nhập xong rồi quay lại app | Bấm "Kiểm tra lại", hoặc app tự kiểm tra khi được focus lại `[giả định]` → bước 2 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Kiểm tra quá 10 giây `[giả định]` hoặc lỗi không rõ | Coi như không `SAN_SANG` với trạng thái gần nhất đã biết (lần đầu: `CHUA_CAI`); SCR-11 kèm "Kiểm tra lại"; ghi log |

### UC-11 Điều khiển app từ Claude Code trong terminal

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | App đang mở và đã đăng nhập; trợ lý bật và đã đồng ý (BR-19); người dùng đã cấu hình Claude Code kết nối tới \[McpServer\] theo SCR-09 #13 |
| Hậu điều kiện thành công | Thay đổi áp dụng ngay (hoặc chờ duyệt khi phiên đã đọc dữ liệu tích hợp); chip "AI", nhật ký `terminal`, hoàn tác được ở SCR-12 |
| Hậu điều kiện thất bại | Không thay đổi task; Claude Code nhận lỗi từ công cụ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Mở Claude Code trong terminal, ra lệnh ("dời các task review sang chiều mai") |
| 2 | Claude Code | Kết nối \[McpServer\]; \[McpServer\] kiểm BR-27, tạo phiên AI `terminal` và đề xuất `DANG_XU_LY` |
| 3 | Claude Code | Gọi "Xem ngữ cảnh thời gian" và công cụ đọc cần thiết; gọi công cụ ghi với ngày tuyệt đối (BR-03, BR-04) |
| 4 | \[McpServer\] | Kiểm BR-01, BR-02, BR-04, BR-26; `hasExternalData = false` → áp dụng ngay (BR-06, BR-21), chip "AI", nhật ký "Claude Code (terminal) đã …"; trả kết quả cho Claude Code |
| 5 | App | Toast MSG-29 "Claude Code (terminal) đã thay đổi {n} task · Xem · Hoàn tác" (gộp theo phiên); board, lịch cập nhật; phiên hiện ở SCR-12 |
| 6 | Claude Code | Ngắt kết nối / người dùng thoát → phiên kết thúc; đề xuất `DA_AP_DUNG` (hoặc không lưu nếu không có thay đổi) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Phiên gọi công cụ đọc dữ liệu tích hợp (BR-20) | `hasExternalData = true`; lời gọi ghi sau đó → `CHO_DUYET`, công cụ trả "đang chờ người dùng duyệt trong app"; app hiện MSG-31 → SCR-12 để duyệt (BR-06, QC-12 mục 6) |
| A2 | "Hoàn tác" trên toast / "Hoàn tác tất cả" trong SCR-12 | → UC-04 với các thay đổi của phiên |
| A3 | Khung chat của app cũng đang chạy | Hai phiên độc lập; xung đột theo QC-08 (BR-28) |
| A4 | Yêu cầu hành động bị cấm / công cụ không có | \[McpServer\] trả `AI_ACTION_FORBIDDEN` kèm MSG-07 dạng chữ để Claude Code báo lại người dùng |
| A5 | Ngày tương đối trong khung mơ hồ (BR-05) | Công cụ ghi chỉ nhận ngày tuyệt đối; mô tả công cụ yêu cầu Claude Code hỏi lại người dùng `[giả định — không kiểm soát được hoàn toàn với phiên terminal]`; server vẫn chặn `PAST_DATE` |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | App không mở / chưa đăng nhập | Claude Code không kết nối được \[McpServer\]; không có thay đổi |
| E2 | Trợ lý tắt hoặc chưa đồng ý | \[McpServer\] từ chối kết nối, trả MSG-30 (`AI_ASSISTANT_DISABLED` / `AI_CONSENT_REQUIRED`) |
| E3 | Người dùng tắt trợ lý / rút lại đồng ý / đóng app giữa phiên | \[McpServer\] cắt phiên; thay đổi đã áp dụng giữ nguyên, hoàn tác được; thay đổi `CHO_DUYET` của phiên → `DA_HOAN_TAC` khi rút lại đồng ý, giữ để duyệt khi chỉ tắt trợ lý hoặc đóng app `[giả định]` |
| E4 | Ghi trên phiên bản cũ (`VERSION_CONFLICT`) / `PAST_DATE` / workspace chỉ đọc (1.1) | Công cụ trả lỗi; không thay đổi task |
| E5 | App mất kết nối server | Công cụ ghi trả `AI_OFFLINE` (BR-27); công cụ đọc trả dữ liệu trên máy kèm thời điểm `[giả định]` |

### UC-12 Gợi ý thời lượng và channel qua Claude Code (cho G02)

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | G02 gọi \[TaskSuggest\] khi người dùng tạo task (G02 UC tạo task bước 4); BR-30 thoả |
| Hậu điều kiện thành công | Trả `plannedMin`, `channelId`, `confidence` cho G02 trong ngưỡng thời gian của G02 |
| Hậu điều kiện thất bại | Không trả gợi ý; G02 bỏ qua (G02 A4) |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | App (G02) | Gọi \[TaskSuggest\] với tiêu đề, ngày dự định |
| 2 | App (G10) | Kiểm BR-30; gọi Claude Code một lượt ngắn, chỉ đọc (danh sách channel, thời lượng các task tương tự) |
| 3 | App (G10) | Trả gợi ý cho G02; G02 hiển thị với nguồn `ai` (G02 BR-04) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Không thoả BR-30, Claude Code lỗi / chậm hơn ngưỡng G02 / hết hạn mức | Không trả gợi ý, không báo lỗi; không chuyển trạng thái Claude Code trừ khi lỗi vì CLI (BR-25) |

## 6. Điểm vào

Mọi điểm vào AI chỉ hiện khi Claude Code `SAN_SANG` (BR-25); ngược lại thay bằng SCR-11 hoặc ẩn.

| **Điểm vào** | **App Windows (1.0)** | **Ghi chú** |
| --- | --- | --- |
| Nút ✨ "Trợ lý" ở cụm dưới sidebar (không nổi ở góc màn hình) | ✓ | Mở SCR-04 ở mục "Trợ lý" của panel phải (IA-01, IA-08); chưa đồng ý → SCR-10 (UC-09); Claude Code không sẵn sàng → SCR-11 ngay trong mục này |
| Command menu (Ctrl+K) "Hỏi trợ lý" / phím Ctrl+J | ✓ | Ctrl+J mở / đóng mục Trợ lý (IA-15); Claude Code không sẵn sàng → SCR-11 |
| Daily planning (G08) → "Plan my day" | ✓ | Chỉ khi bật Beta; SCR-02; không sẵn sàng → SCR-11 ở cùng chỗ |
| Daily shutdown (G08) → bước highlights | ✓ | SCR-07 |
| Nhật ký AI và chip "AI" trong chi tiết task (G02 SCR-03) | ✓ | Hoàn tác thay đổi AI (UC-04) |
| Daily planning (G08) → bước Daily plan → "Hoàn tác kế hoạch AI" | ✓ | UC-02 A4, UC-04 A7; G08 đặt nút, hiện khi ngày D có đề xuất Planning Agent `DA_AP_DUNG` còn trong thời hạn hoàn tác |
| Toast MSG-29 / MSG-31 khi Claude Code trong terminal thay đổi app | ✓ | SCR-12 (UC-11) |
| Cài đặt → Trợ lý AI → "Hoạt động AI" | ✓ | SCR-12 |
| Tạo task (G02) — gợi ý thời lượng / channel | ✓ | UC-12, không có giao diện riêng của G10 |
| Claude Code trong terminal (ngoài app) | ✓ (app phải đang mở) | UC-11 |
| Cài đặt → Trợ lý AI / Beta | ✓ | SCR-09 |

## 7. Mô tả màn hình

### SCR-01 Thiết lập Planning Agent

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Thanh bước | Stepper | – | Công cụ · Kể về bạn · Theme days |
| 2 | Danh sách nguồn | List | Không | Lịch (G05), Gmail / Jira / Notion (G11) với trạng thái; "Kết nối" mở luồng nhóm sở hữu |
| 3 | Kể về bạn | Text nhiều dòng | Không | ≤ 1.000 ký tự `[giả định]`; quá → MSG-02 |
| 4 | Theme days | 7 ô text | Không | Mỗi ô ≤ 100 ký tự `[giả định]` |
| 5 | "Bỏ qua" / "Tiếp" / "Xong" | Button | – | Xong → \[AgentProfileSave\] |
| 6 | Cho AI đọc dữ liệu từ công cụ đã kết nối | Toggle | – | Phần "Công cụ"; mặc định tắt (BR-20); ẩn ở 1.0; bên dưới MSG-20; cùng giá trị với SCR-09 #9 |

### SCR-02 Planning Agent — nhập và chạy

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Nhãn Beta | Badge | – | "Beta" |
| 2 | "Điều quan trọng nhất hôm nay là gì?" | Text | Không | ≤ 500 ký tự `[giả định]` |
| 3 | "Plan my day" | Button chính | – | Disabled khi offline hoặc workspace chỉ đọc (MSG-12, 1.1); chưa đồng ý → SCR-10; Claude Code không `SAN_SANG` → thay bằng SCR-11 |
| 4 | "Tự lập kế hoạch" | Link | – | Sang Daily planning thủ công (G08) |
| 5 | Tiến độ | List bước | – | Hiện khi `DANG_XU_LY`: "Đọc lịch", "Đọc việc từ công cụ", "Xếp khối thời gian"; bộ đếm thời gian; "Thường mất 2–4 phút" |
| 6 | "Dừng" | Button | – | Dừng Claude Code → luồng thủ công; thay đổi đã áp dụng giữ, có "Hoàn tác kế hoạch AI" (BR-09) |

### SCR-03 Review Plan

Hai chế độ (BR-06): **Đã áp dụng** (mặc định, Q31) và **Chờ duyệt** (kế hoạch có dữ liệu tích hợp, Q31a).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tóm tắt | Text | Đã áp dụng: "Planning Agent đã thêm 3 task, dời 2 task". Chờ duyệt: "Planning Agent đề xuất thêm 3 task, dời 2 task" + MSG-22 |
| 2 | Danh sách thay đổi | List | Nhóm "HÔM NAY · n thay đổi"; mỗi dòng: loại (Thêm / Dời / Timebox / Sắp lại), tiêu đề, giá trị trước → sau, ngày giờ cụ thể (BR-04). Đã áp dụng: mỗi dòng có "Hoàn tác" (UC-04), dòng đã hoàn tác gạch ngang. Chờ duyệt: checkbox, mặc định chọn hết. Dòng bị loại (BR-21) hiện xám kèm lý do |
| 3 | Tổng khối lượng | Text | Tổng planned của task chưa xong sau khi áp dụng so sức chứa của ngày (G04, QC-02 mục 7; không lấy min với ngưỡng khối lượng, Q48); đỏ khi quá tải |
| 4 | "Lập lại" | Button | UC-02 A1 |
| 5 | "Huỷ tất cả" / "Hoàn tác kế hoạch AI" | Button | Chờ duyệt: "Huỷ tất cả". Đã áp dụng: "Hoàn tác kế hoạch AI". UC-02 A2 |
| 6 | "Gửi phản hồi" | Link | SCR-08 |
| 7 | "Tiếp" / "Áp dụng và tiếp" | Button chính | Đã áp dụng: "Tiếp" sang Daily plan (G08). Chờ duyệt: "Áp dụng và tiếp" → \[ProposalApply\] các dòng được chọn (BR-21); disabled khi không chọn dòng nào (khi đó dùng "Huỷ tất cả") hoặc khi đề xuất hết hạn |

### SCR-04 Khung chat trợ lý

Giao diện như chat thường (Q39). Nằm ở mục "Trợ lý" của panel phải, để vừa chat vừa thấy board; bấm chip task mở dialog chi tiết task (IA-08, [IA](../design-brief/00-kien-truc-thong-tin.md)). Tên hiển thị trợ lý chưa đặt, quyết định khi làm thiết kế Figma (D16); không dùng "Sunny" (tên trợ lý của Sunsama).

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Header | Toolbar | – | "Lịch sử" · "Cuộc trò chuyện mới" · đóng; dòng nhỏ "Chạy bằng Claude Code" |
| 2 | Ô nhập | Text nhiều dòng | Có | Placeholder "Mô tả một task hoặc đặt câu hỏi"; 1–2.000 ký tự (MSG-02); Enter gửi, Shift+Enter xuống dòng |
| 3 | Tin nhắn người dùng | Bubble | – | Nguyên văn |
| 4 | Trạng thái xử lý | Text | – | "Đang nghĩ…" + giây; > 10 giây "Vẫn đang xử lý…" + "Dừng"; xong "Đã nghĩ {n}s" (Sunsama "Thought 8s") |
| 5 | Câu trả lời | Bubble (stream) | – | Ngôn ngữ theo BR-12; mọi ngày ghi cụ thể |
| 6 | Chip task | Card nhỏ | – | Tiêu đề, ngày giờ, channel, loại thay đổi (gồm "Đã hoàn thành" / "Đã chuyển vào Thùng rác" khi BR-26 bật), "Hoàn tác"; bấm tiêu đề mở chi tiết task (G02); đã hoàn tác → gạch ngang "Đã hoàn tác" |
| 7 | Nút chọn ngày (BR-05) | 2 button | – | Hiện khi khung mơ hồ; chọn → tiếp tục hành động |
| 8 | Thẻ chờ duyệt | SCR-05 | – | Khi phiên đã đọc dữ liệu tích hợp (BR-06) |
| 9 | "Hữu ích" / "Chưa tốt" | Icon button | – | UC-06 |
| 10 | Tóm tắt lượt | Text + button | – | Lượt chạm > 3 task: "Đã thay đổi {n} task · Hoàn tác tất cả" (EC-37) |
| 11 | Thông báo lỗi Claude Code | Inline | – | MSG-27 / MSG-28 (nguyên văn thông báo của Claude Code) kèm "Gửi lại" |

### SCR-05 Thẻ chờ duyệt (phiên có dữ liệu tích hợp)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Text | "Trợ lý muốn thay đổi {n} task" + MSG-22 |
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
| 1 | Nhãn nguồn | Badge | "✨ Nháp AI lúc {giờ soạn}"; mất khi người dùng sửa |
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

### SCR-09 Cài đặt → Trợ lý AI

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Trợ lý | Toggle | – | Mặc định tắt (Q21); disabled khi #12 khác `SAN_SANG`; bật lần đầu khi chưa đồng ý → SCR-10 (UC-07 A4); BR-16 |
| 2 | Gợi ý channel | Toggle | – | Mặc định bật (hành vi G02); chỉ có tác dụng khi #1 bật (BR-30) |
| 3 | Gợi ý thời lượng (task, subtask) | Toggle | – | Mặc định bật (hành vi G02); chỉ có tác dụng khi #1 bật (BR-30) |
| 4 | Ngôn ngữ tóm tắt | Dropdown | – | Auto / Tiếng Việt / English; mặc định Auto |
| 5 | Tóm tắt tự động | Toggle | – | Mặc định bật; nháp tại giờ kết thúc của lịch chung vào các ngày có trong lịch làm việc, hoặc khi mở app lần kế tiếp trong ngày (BR-13, Q39, D7); chỉ chạy khi #1 bật và đã đồng ý |
| 6 | Thiết lập Planning Agent | Link | – | Mở SCR-01; ẩn khi Beta tắt |
| 7 | Xoá lịch sử trò chuyện | Button nguy hiểm | – | UC-07 A3 |
| 8 | Beta → Agentic Daily Planning | Toggle | – | Ở nhóm Beta (hiện từ 1.0); mặc định tắt `[giả định]` |
| 9 | Cho AI đọc dữ liệu từ công cụ đã kết nối | Toggle | – | Mặc định tắt (BR-20); disabled khi #1 tắt; ẩn ở 1.0 (chưa có G11); mô tả MSG-20 |
| 10 | Thời điểm đồng ý | Text | – | "Bạn đã đồng ý dùng AI lúc {ngày giờ}"; ẩn khi chưa đồng ý |
| 11 | Rút lại đồng ý dùng AI | Button nguy hiểm | – | Hiện khi đã đồng ý; xác nhận MSG-23 → UC-07 A6 |
| 12 | Trạng thái Claude Code | Text + button | – | Theo mục 4.3: "Claude Code · {phiên bản} · Sẵn sàng" / "Chưa cài" / "Chưa đăng nhập" / "Phiên bản cũ"; nút "Kiểm tra lại" (UC-10); khác `SAN_SANG` → kèm SCR-11 |
| 13 | Dùng Claude Code trong terminal | Mục mở rộng | – | Hướng dẫn kết nối Claude Code tới MCP local của app (lệnh / cấu hình có nút sao chép: tech chốt); ghi chú "App phải đang mở"; hiện khi #1 bật |
| 14 | Cho phép AI hoàn thành và xoá task | Toggle | – | Mặc định tắt (BR-26); disabled khi #1 tắt; bật → MSG-32 (UC-07 A7); mô tả "Task đồng bộ với Jira / Notion / Gmail không bao giờ được AI hoàn thành" |
| 15 | Hoạt động AI | Link | – | Mở SCR-12 |

### SCR-10 Đồng ý dùng AI (dialog gọn)

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Tiêu đề | Text | "Bật trợ lý AI với Claude Code" |
| 2 | Dữ liệu đưa cho Claude Code | Text + danh sách | Tiêu đề, ghi chú, thời lượng, ngày, trạng thái task; channel; sự kiện lịch (tiêu đề, giờ); objective; nội dung bạn gõ cho trợ lý. Không đưa nội dung email, token. Dữ liệu công cụ tích hợp chỉ khi bạn bật riêng (BR-10, BR-20) |
| 3 | Claude Code và tài khoản của bạn | Text | Claude Code chạy trên máy này bằng tài khoản Claude của bạn và xử lý dữ liệu theo điều khoản của Anthropic; app không gửi dữ liệu cho nhà cung cấp AI nào khác; Claude Code có thể tự lưu bản ghi phiên trên máy |
| 4 | Quyền của AI | Text | AI thay đổi task ngay, có chip "AI" và Hoàn tác; không hoàn thành / xoá task trừ khi bạn bật riêng; Claude Code mở trong terminal cũng điều khiển được app khi app đang mở |
| 5 | Link chính sách quyền riêng tư | Link | Mở trình duyệt |
| 6 | "Đồng ý và bật" | Button chính | \[AiConsent\] (UC-09 bước 4) |
| 7 | "Để sau" | Button | UC-09 A1 |

### SCR-11 Hướng dẫn cài Claude Code (thẻ thay điểm vào AI)

Hiện ở SCR-09, chỗ của "Plan my day" (SCR-02), khi mở khung chat từ Command menu, và chỗ "Soạn bằng AI" (SCR-07) khi Claude Code khác `SAN_SANG` (BR-25).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-24 / MSG-25 / MSG-26 theo trạng thái (mục 4.3) |
| 2 | "Xem hướng dẫn" | Link | Mở trang hướng dẫn cài / đăng nhập / cập nhật của Anthropic trong trình duyệt |
| 3 | "Kiểm tra lại" | Button | UC-10 |
| 4 | Ghi chú | Text nhỏ | "Bạn vẫn dùng đầy đủ app khi chưa có trợ lý AI" |
| 5 | "Ẩn" | Link | Ẩn thẻ ở board / ritual (vẫn hiện ở SCR-09) `[giả định]` |

### SCR-12 Hoạt động AI

Danh sách phiên AI có thay đổi (mục 4.4), mới nhất trước, trong thời hạn hoàn tác (BR-08).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Bộ lọc | Chip | Tất cả · Chờ duyệt · Terminal · Chat · Planning Agent |
| 2 | Dòng phiên | List item | Nguồn ("Claude Code (terminal)", "Trợ lý", "Planning Agent"), thời điểm, số thay đổi đã áp dụng / chờ duyệt, nhãn "Đang hoạt động" khi phiên còn mở; có `hasExternalData` → MSG-22 |
| 3 | Danh sách thay đổi | List | Như SCR-03 #2: loại, tiêu đề task, trước → sau, ngày giờ cụ thể; dòng đã áp dụng có "Hoàn tác"; dòng chờ duyệt có checkbox |
| 4 | "Hoàn tác tất cả" | Button | UC-04 A7 cho phiên |
| 5 | "Áp dụng" / "Huỷ" | Button | Cho dòng chờ duyệt: \[ProposalApply\] / \[ProposalReject\] (BR-21) |

## 8. API

Hợp đồng nghiệp vụ tham khảo. Đường dẫn, kiểu API, cách gọi CLI và kiểu kết nối MCP: tech chốt (`docs/tech/01` mục 4–5). Nhóm \[ClaudeCode…\] và \[McpServer\] chạy trong app trên máy; các API còn lại ở server (lưu đề xuất, nhật ký, hoàn tác, đồng ý, để đồng bộ giữa thiết bị).

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[ClaudeCodeDetect\] (trong app) | – | status (mục 4.3), version, minSupportedVersion | 10s / không retry (UC-10) |
| \[ClaudeCodeRun\] (trong app) | aiAgent, chỉ dẫn, context (BR-03), tin nhắn / lịch sử, aiSessionId | Luồng chữ, bước tiến độ, kết thúc / lỗi (`CLAUDE_CODE_EXITED`, `CLAUDE_CODE_USAGE_LIMIT` kèm nguyên văn thông báo, `CLAUDE_CODE_NOT_LOGGED_IN`) | Theo BR-09; tech chốt cách gọi (không tương tác, streaming) |
| \[McpServer\] (trong app) | Công cụ mục 3.1 | Kết quả công cụ / lỗi (`AI_ACTION_FORBIDDEN` kèm reason `TOGGLE_OFF` / `LINKED_TASK` / `NO_TOOL`, `VERSION_CONFLICT`, `PAST_DATE`, `AI_CONSENT_REQUIRED`, `AI_ASSISTANT_DISABLED`, `AI_OFFLINE`, `WORKSPACE_READ_ONLY`), trạng thái `applied` / `pending_review` | BR-27; schema: tech chốt |
| \[AgentProfileGet\] / \[AgentProfileSave\] `GET/PUT /ai/agent-profile` | about, themeDays[7], sources[] | AgentProfile | 5s / 1 lần |
| \[AgentPlanStart\] `POST /ai/planning/{date}/runs` | focusText, aiSessionId, Idempotency-Key | proposalId, status `DANG_XU_LY` | 5s / không retry; bước đầu ≤ 10s, tổng ≤ 5 phút (BR-09) |
| \[AiSessionStart\] / \[AiSessionEnd\] `POST /ai/sessions` · `POST /ai/sessions/{id}/end` | aiAgent, hasExternalData | aiSessionId, proposalId | 5s / 2 lần (mục 4.4) |
| \[ProposalGet\] `GET /ai/proposals/{id}` | id | Proposal: status, aiAgent, aiSessionId, hasExternalData, expiresAt, steps[], changes[] (type, taskId, field, before, after, baseVersion, status), promptVersion, claudeCodeVersion | 5s / 2 lần; realtime `ai.proposal.updated` là kênh chính |
| \[ProposalApply\] `POST /ai/proposals/{id}/apply` | changeIds[] (hoặc change mới từ \[McpServer\]), Idempotency-Key | Proposal, tasks[], skipped[] {changeId, reason: `SKIPPED_STALE` \| `SKIPPED_PAST`} | 10s / 2 lần cùng key; kiểm `baseVersion` từng task, chỉ loại dòng lỗi thời (BR-21); dùng chung cho áp dụng ngay (\[McpServer\] gọi) và áp dụng sau duyệt |
| \[AiConsent\] `POST /ai/consent` · `DELETE /ai/consent` (rút lại) | consentVersion | aiConsentAt, aiConsentVersion, Settings | 5s / 2 lần |
| \[ProposalReject\] `POST /ai/proposals/{id}/reject` | id, reason? | Proposal `DA_HOAN_TAC` | 5s / 2 lần |
| \[ProposalUndo\] `POST /ai/proposals/{id}/undo` | changeIds[], resolutions[] {changeId, keep: user\|before} | Proposal, tasks[], conflicts[] (nếu chưa có resolutions) | 5s / 2 lần |
| \[ChatThreadList\] / \[ChatThreadCreate\] / \[ChatThreadDelete\] `GET/POST/DELETE /ai/chat/threads` | cursor, limit / – / id | Thread[] / Thread | 5s / 1 lần |
| \[ChatSend\] (app → \[ClaudeCodeRun\]; lưu tin nhắn `POST /ai/chat/threads/{id}/messages`) | text, context (BR-03), viewDate, selectedTaskId | Stream: delta chữ, `thinkingMs`, proposal (nếu có) | Chữ đầu ≤ 10s; tổng ≤ 60s; không tự retry (nút "Gửi lại") |
| \[HighlightsDraft\] (app → \[ClaudeCodeRun\]) · `PUT/GET /ai/highlights/{date}` (lưu nháp, khoá user + ngày) | date, language | Proposal (bullets[] {text, taskId?, itemRef?}) | 10s chữ đầu (người dùng mở); job: 2 lần cách 5 phút |
| \[TaskSuggest\] (G02 gọi; G10 thực hiện qua \[ClaudeCodeRun\], BR-30) | title, startDate | plannedMin, channelId, confidence | Theo G02 (2s, không retry) |
| \[AiFeedback\] `POST /ai/feedback` | proposalId?, rating, reasons[], text, attachConversation | 204 | 5s / 3 lần nền |
| \[SettingsUpdate\] `PATCH /me/settings` (G01) | ai.assistantEnabled (bật khi `aiConsentAt` trống → 409 `AI_CONSENT_REQUIRED`), ai.useIntegrationData, ai.allowCompleteDelete, ai.summaryLanguage, ai.autoSummary, beta.agenticPlanning | Settings | 5s / 2 lần |
| \[IntegrationActivity\] (G11, 1.1) | date | Hoạt động do tài khoản đã kết nối thực hiện (G11 BR-19) | 5s / 1 lần; chỉ qua công cụ MCP khi bật BR-20; lỗi → bỏ qua (UC-05 A5) |
| \[IntegrationItems\] (G11, 1.1) | integrationId, q | Metadata item (G11 BR-26) | Theo G11; chỉ qua công cụ MCP khi bật BR-20 |
| \[TaskFromItem\] (G11, 1.1) | integrationId, externalId, startDate \| backlogBucket, actor = `ai`, source = `ai`, proposalId | Task + TaskLink, hoặc 409 `ALREADY_LINKED` {taskId} | Theo G11 (BR-24) |
| \[EvalRun\] (nội bộ CI) | promptVersion, toolsetVersion, claudeCodeVersion, datasetVersion | passRate, theo nhóm, câu sai[] | 30 phút / chạy lại câu lỗi 2 lần |
| \[AppConfig\] | – | Ngưỡng BR-09, phiên bản Claude Code tối thiểu (BR-25) | Cache 1h |
| \[BillingGet\] `entitlements` (G12 BR-24, QC-10) | (Bỏ — AI không còn hạn mức theo gói, BR-22) | — | — |

Job: `ai.highlights.draft` (chạy trong app trên máy: kiểm khi app mở và mỗi 15 phút: ngày làm việc hiện tại có trong lịch làm việc và đã tới giờ kết thúc của lịch chung (app mở muộn trong ngày thì soạn ngay, D7); chỉ khi có `aiConsentAt`, trợ lý bật, "Tóm tắt tự động" bật, Claude Code `SAN_SANG`, workspace không chỉ đọc; idempotent theo user + ngày ở server, BR-13), `ai.proposal.expire` (server: đóng `CHO_DUYET` khi tới mốc đầu ngày của ngày làm việc kế tiếp, BR-21), `ai.history.purgeIntegration` (server: theo `integration.disconnected` của G11, BR-23). Realtime mới: `ai.proposal.updated` `[giả định]`.

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field text / about · TOO_LONG | MSG-02 |
| `AI_TIMEOUT` / `AI_UNAVAILABLE` (chat) | MSG-04 |
| `AI_TIMEOUT` / `AI_UNAVAILABLE` / `AI_CONTEXT_MISSING` (planning, highlights) | MSG-05 |
| `AI_ACTION_FORBIDDEN` (reason `TOGGLE_OFF` / `LINKED_TASK` / `NO_TOOL`) | MSG-07 |
| `AI_DATE_AMBIGUOUS` | MSG-08 |
| `AI_UNDO_EXPIRED` | MSG-10 |
| `AI_UNDO_CONFLICT` (409) | SCR-06 / MSG-18 |
| `AI_QUOTA_EXCEEDED` | (Bỏ — BR-22) |
| `CLAUDE_CODE_USAGE_LIMIT` | MSG-28 |
| `CLAUDE_CODE_EXITED` | MSG-27 |
| `CLAUDE_CODE_NOT_INSTALLED` / `CLAUDE_CODE_NOT_LOGGED_IN` / `CLAUDE_CODE_OUTDATED` | SCR-11 với MSG-24 / MSG-25 / MSG-26 |
| `AI_ASSISTANT_DISABLED` (trả cho Claude Code trong terminal) | MSG-30 |
| `AI_OFFLINE` | MSG-06 |
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
| MSG-04 | Khung chat | Trợ lý chưa trả lời được. Gửi lại |
| MSG-05 | Banner | AI đang gặp sự cố. Bạn tiếp tục lập kế hoạch thủ công, nội dung đã nhập vẫn được giữ |
| MSG-06 | Banner | Mất kết nối. AI cần mạng để hoạt động |
| MSG-07 | Khung chat | Mình không thể {xoá task / đánh dấu xong task / gửi tin ra ngoài / đổi cài đặt}. Bạn có thể tự làm: {cách làm} |
| MSG-08 | Khung chat | Bây giờ là {giờ} ngày {ngày}. "{cụm từ}" là ngày nào? |
| MSG-09 | Toast | Đã hoàn tác {n} thay đổi của AI |
| MSG-10 | Toast | Thay đổi này đã quá 7 ngày, không hoàn tác bằng AI được. Hãy sửa trực tiếp task |
| MSG-11 | (Bỏ — không còn hạn mức AI theo gói, BR-22; xem MSG-28) | — |
| MSG-12 | Khung chat / SCR-02 | Workspace đang ở chế độ chỉ đọc nên trợ lý AI tạm ngừng |
| MSG-13 | Inline SCR-07 | Có {n} việc mới xong sau khi soạn nháp · Thêm vào |
| MSG-14 | Toast | Chưa lưu được thay đổi. Thử lại |
| MSG-15 | Inline | Kế hoạch vừa thay đổi ở nơi khác. Lập lại để agent dùng dữ liệu mới |
| MSG-16 | Toast | Cảm ơn bạn đã góp ý |
| MSG-17 | Dialog | Xoá toàn bộ lịch sử trò chuyện? Task đã tạo không bị ảnh hưởng |
| MSG-18 | Dialog SCR-06 | Bạn đã sửa {n} chỗ sau khi AI thay đổi. Chọn giữ bản nào |
| MSG-19 | Inline SCR-03 / SCR-05 / khung chat | Đã bỏ qua {n} thay đổi vì task vừa đổi ở nơi khác hoặc giờ đã qua. Các thay đổi còn lại đã áp dụng |
| MSG-20 | Inline SCR-01 / SCR-09 | Khi bật, AI đọc được tiêu đề việc từ Gmail, Jira, Notion. Sau khi AI đọc dữ liệu này, mọi thay đổi AI muốn làm trong lượt đó đều chờ bạn duyệt |
| MSG-21 | Khung chat / lịch sử | Nội dung từ {công cụ} đã được xoá khi bạn ngắt kết nối |
| MSG-22 | SCR-03 / SCR-05 / SCR-12 | Cần bạn duyệt vì {kế hoạch / yêu cầu / phiên Claude Code} dùng dữ liệu từ {công cụ} |
| MSG-23 | Dialog SCR-09 | Rút lại đồng ý? Trợ lý AI sẽ tắt và Claude Code không còn truy cập app nữa. Thay đổi AI đã làm vẫn giữ nguyên |
| MSG-24 | SCR-11 | Cài Claude Code để bật trợ lý AI. Bạn vẫn dùng đầy đủ app khi chưa có trợ lý · Xem hướng dẫn · Kiểm tra lại |
| MSG-25 | SCR-11 | Đã tìm thấy Claude Code nhưng chưa đăng nhập. Đăng nhập tài khoản Claude rồi bấm Kiểm tra lại |
| MSG-26 | SCR-11 | Claude Code phiên bản {x} chưa được hỗ trợ. Cập nhật lên {tối thiểu} trở lên rồi bấm Kiểm tra lại |
| MSG-27 | Khung chat / banner | Claude Code đã dừng giữa chừng. {n} thay đổi đã áp dụng vẫn được giữ · Hoàn tác · Gửi lại |
| MSG-28 | Khung chat / banner | Claude Code báo: "{thông báo của Claude Code}". Bạn tiếp tục thủ công, nội dung đã nhập vẫn được giữ |
| MSG-29 | Toast | Claude Code (terminal) đã thay đổi {n} task · Xem · Hoàn tác |
| MSG-30 | Trả cho Claude Code (terminal) | Trợ lý AI đang tắt trong Wakeup. Bật trong Cài đặt → Trợ lý AI để tiếp tục |
| MSG-31 | Toast / badge SCR-12 | Có {n} thay đổi từ Claude Code đang chờ bạn duyệt · Xem |
| MSG-32 | Dialog SCR-09 | Cho phép AI hoàn thành và chuyển task vào Thùng rác? Mọi thay đổi vẫn hoàn tác được. Task đồng bộ với Jira, Notion, Gmail không bao giờ được AI hoàn thành hay xoá · Bật · Huỷ |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Nền tảng | App Windows (Flutter) bản 1.0 (ADR-0005); cần Claude Code CLI trên cùng máy (QC-12); phiên bản Windows hỗ trợ: tech chốt |
| Hiệu năng | Kết quả đầu tiên ≤ 10 giây (p95, gồm thời gian khởi động Claude Code), luôn có trạng thái đang xử lý; Planning Agent 2–4 phút, tối đa 5 phút; \[ProposalApply\] p95 ≤ 1 giây cho ≤ 30 thay đổi; mỗi lời gọi công cụ ghi MCP p95 ≤ 1 giây; chip / board cập nhật ≤ 100 ms sau khi áp dụng; phát hiện Claude Code ≤ 3 giây (p95), không chặn khởi động app |
| Offline | AI không chạy khi mất mạng (MSG-06); công cụ ghi MCP trả `AI_OFFLINE` khi app mất kết nối server (BR-27); Daily planning / shutdown thủ công vẫn chạy (G08); hoàn tác AI cần mạng |
| Đồng bộ | Thay đổi AI hiện trên thiết bị khác ≤ 5 giây (`task.upserted`, `ai.proposal.updated`); trạng thái Claude Code và \[McpServer\] là của từng máy |
| Bảo mật | BR-01, BR-02, BR-11, BR-26 kiểm ở \[McpServer\] / \[AiActionExecutor\] trong app, không dựa vào model; server kiểm quy tắc nghiệp vụ như thao tác người dùng; `hasExternalData` do \[McpServer\] gắn, không do model khai báo (BR-06, BR-20); \[McpServer\] chỉ nhận kết nối trên máy, chỉ khi trợ lý bật và đã đồng ý, xác thực tiến trình hợp lệ (tech chốt); app không lưu thông tin đăng nhập Claude của người dùng; công cụ chỉ đọc / ghi dữ liệu của người dùng đang đăng nhập app |
| Quyền riêng tư | Không gọi Claude Code, \[McpServer\] không nhận kết nối trước `aiConsentAt` (BR-19); dữ liệu tích hợp mặc định không đưa (BR-20); dữ liệu đưa cho Claude Code tối thiểu (BR-10); app không gửi dữ liệu cho nhà cung cấp AI nào; Claude Code xử lý theo tài khoản Claude của người dùng và có thể tự lưu bản ghi phiên trên máy (nói rõ ở SCR-10); Nghị định 13/2023/NĐ-CP, GDPR, hồ sơ Q29 (cần pháp chế xác nhận trách nhiệm của app); lịch sử chat trong app giữ 90 ngày, xoá được; ngắt tích hợp xoá dữ liệu của tích hợp đó khỏi lịch sử AI của app (BR-23); xuất dữ liệu (G01) gồm lịch sử chat, nhật ký thay đổi AI và thời điểm đồng ý |
| Log / audit | \[ActivityLog\] tác nhân `ai`, `aiAgent`, `aiSessionId` (BR-07); log lượt AI: proposalId, promptVersion, toolsetVersion, claudeCodeVersion, độ trễ, mã lỗi Claude Code, kết quả \[AiActionExecutor\]; không ghi nội dung tin nhắn, kết quả công cụ vào log hệ thống |
| Chất lượng | Bộ đánh giá BR-18; theo dõi hằng tuần tỉ lệ hoàn tác, "Chưa tốt", chuyển luồng thủ công (tách lý do hết hạn mức Claude, Claude Code bị đóng) |
| Chi phí | App không chịu chi phí AI; không hạn mức theo gói (QC-10, QC-12 mục 8) |
| Tracking | Sự kiện: `claude_code_detected` (status, version), `claude_code_install_guide_opened`, `ai_consent_shown`, `ai_consent_given`, `ai_integration_data_toggled`, `ai_complete_delete_toggled`, `ai_session_started` (aiAgent), `ai_terminal_session_started`, `ai_plan_undone` (toàn bộ kế hoạch), `ai_session_undone` (cả lượt / phiên), `ai_proposal_expired`, `ai_change_skipped_stale`, `ai_chat_opened`, `ai_message_sent`, `ai_proposal_created` (loại, số task), `ai_proposal_applied`, `ai_proposal_rejected`, `ai_change_undone`, `ai_undo_conflict`, `ai_date_clarify_shown`, `ai_action_forbidden`, `ai_claude_usage_limit`, `ai_claude_exited`, `planning_agent_started`, `planning_agent_fallback` (lý do), `highlights_draft_created`, `highlights_saved` (tỉ lệ sửa), `task_suggest_served` / `_skipped`, `ai_feedback_sent` |
| Accessibility | Khung chat đọc được bằng trình đọc màn hình (Windows Narrator; vùng thông báo động cho câu trả lời stream); chip, checkbox, radio dùng được bằng bàn phím; ✨ và chip "AI" có nhãn "Thay đổi của AI"; tương phản WCAG 2.1 AA sáng / tối |
