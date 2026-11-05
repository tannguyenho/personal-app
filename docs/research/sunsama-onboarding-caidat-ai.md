# Research: Sunsama làm gì với onboarding, cài đặt và trợ lý AI; Claude Code CLI / MCP cho G10

> **Ticket:** [#6](https://github.com/tannguyenho/personal-app/issues/6) · **Ngày:** 04/11/2026 · **Người soạn:** Claude (research)
> **Phạm vi:** chỉ tài liệu công khai: help center, changelog, roadmap của Sunsama; docs Claude Code (code.claude.com). Mỗi ý có URL. Ý nào tài liệu không nói thì ghi rõ "không nêu" và chuyển sang mục 3 để kiểm chứng.
> **Đối chiếu:** `docs/features/{prd,srs}-g01-*`, `{prd,srs}-g10-*`, `prd-g12-*` (phần 1.0), `docs/01-quy-tac-dung-chung.md` (QC-02, QC-12), `docs/adr/0004-ai-qua-claude-code-cli.md`.
> **Cách đánh giá:** **Giống**: ta làm như Sunsama. **Khác có chủ đích**: tài liệu của ta đã có quyết định hoặc lý do (ghi mã). **Khác chưa chủ đích**: ta khác hoặc thiếu mà chưa thấy quyết định nào.

---

## 1. Tóm tắt

1. **Onboarding Sunsama theo help center có 3 bước** (chọn công cụ → kết nối lịch → "When do you plan your day?"), phải làm hết mới vào được workspace, rồi tới lượt Daily planning có hướng dẫn 7 bước. Sunsama **không hỏi timezone hay giờ làm** khi onboarding. Changelog 26/10/2026 ghi "A smoother onboarding with Autoplan for new users", nên help có thể đã cũ. Cần kiểm chứng bằng Chrome.
2. Onboarding 5 bước của ta (G01 BR-11) dài hơn Sunsama, và hỏi thêm timezone và lịch làm việc là **có chủ đích** (PRD G01 mục 4.2, QC-01, QC-02). Hai chỗ **chưa có quyết định**: ta bắt nhập ≥ 1 task, và ta chưa có quy tắc "đặt giờ plan sau 15:00 thì plan cho ngày mai" như Sunsama.
3. **Cài đặt Sunsama** chia nhóm: General, Display, Rituals, Timeboxing, Keyboard Shortcuts, Focus, Focus Bar, Focus Sounds, AI, Profile, Account Management, Mobile App. Thêm trang riêng **Schedules** (giờ làm mặc định theo ngày và lịch theo channel), **Integrations → AI Assistant** (bật / tắt Sunny) và **Beta**. Help **không có nhóm Notifications** và **không có cài đặt mốc đầu ngày**.
4. Ở Sunsama, **giờ làm / lịch channel chỉ phục vụ auto-scheduling**: lịch channel thắng lịch mặc định. Ở ta, lịch làm việc dùng rộng hơn nhiều: ngày làm việc kế tiếp, ritual, sức chứa, số ngày bị hoãn (QC-02). Khác này có chủ đích.
5. **Sunny** (trợ lý chat) bật sẵn theo mặc định. Sunny tạo / sửa / **hoàn thành / xoá** task, nhận / từ chối lời mời họp, đổi giờ shutdown và cài đặt import lịch. Mỗi thay đổi có "receipt" kèm Undo một chạm. Sunny hỏi lại khi yêu cầu mơ hồ. Từ 05/10/2026 Sunny đọc được công cụ đã kết nối. Ta khác có chủ đích ở bốn điểm: mặc định tắt, có màn đồng ý, không hoàn thành / xoá trừ khi bật công tắc, không đổi cài đặt (QC-12, G10 BR-02, BR-26).
6. **Planning Agent / Autoplan** (Beta "Agentic Daily Planning", bật cho cả workspace) có các phần: thiết lập 3 phần, "Plan my day", màn **Review Plan** (Undo từng dòng, "Undo all" có xác nhận, "Re-plan", **"judgement calls to review"**), **Rules** (trang riêng, "Learned from your braindump"), Sunny mở bên cạnh để tóm tắt lượt chạy. Help không nói rõ thay đổi được áp dụng trước hay sau khi duyệt, cũng không nói gì về xử lý lỗi. Ta **thiếu** "judgement calls" và Rules. Hai chỗ này chưa có quyết định.
7. **Claude Code: phát hiện được bằng lệnh có sẵn.** `claude --version` cho biết đã cài và phiên bản nào. `claude auth status` trả JSON, exit 0 nếu đã đăng nhập, 1 nếu chưa, kèm `authMethod`. `claude doctor` chẩn đoán cài đặt. Chế độ không tương tác `claude -p` có `--output-format json|stream-json`. Kết quả cuối có `is_error`, `subtype`. Có sự kiện `system/api_retry` và `rate_limit_event` (`allowed_warning` / `rejected`, `resetsAt`).
8. **Lỗi thực tế nhiều trạng thái hơn 4 trạng thái hiện tại** (`CHUA_CAI`, `CHUA_DANG_NHAP`, `PHIEN_BAN_CU`, `SAN_SANG`). Còn có: đăng nhập hết hạn ("Login expired · Please run /login"), tổ chức hoặc tài khoản bị chặn, hết hạn mức phiên / tuần / theo model (kèm giờ reset), cần mua usage credits, đang thử lại khi API quá tải, mất mạng, câu trả lời bị cắt giữa chừng. Lệnh `/login` **không dùng được trong `-p`**, nên app phải hướng người dùng sang terminal (hoặc `claude auth login`).
9. **MCP local** đăng ký bằng `claude mcp add [--scope user] <name> -- <command>` (stdio) hoặc `--transport http`. App tự gọi thì dùng `--mcp-config` + `--strict-mcp-config`. Trạng thái server: `✔ Connected` / `✘ Failed to connect` / `! Needs authentication`... Server có thể đổi bộ công cụ giữa phiên (`list_changed`).
10. **Rủi ro pháp lý cần đưa lên PO / pháp chế (ADR-0004).** Trang Legal của Claude Code có ba điều liên quan. (a) Không cho bên thứ ba "route requests through Free, Pro, Max, or Ultra plan credentials on behalf of their users". (b) Vẫn cho "an end user ... signing in to the unmodified Claude Code binary with their own Claude subscription". (c) "Preinstalling or running Claude Code in your products" phải theo Commercial Terms. Ngoài ra, ta không được dùng tên hoặc logo Claude Code làm tên tính năng.

---

## 2. Theo chủ đề

### 2.1 Onboarding

**Nguồn chính:**
- Setting Up Your Sunsama Account: https://help.sunsama.com/docs/setting-up-your-sunsama
- Changelog 26/10/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-october-26-2026
- Account Settings (Rituals): https://help.sunsama.com/docs/user-settings

**Sunsama làm gì (theo help):**
- **Bước 1 "Pick your task management tools"**: chọn các công cụ đang dùng. Kết nối thật để tới buổi planning đầu tiên.
- **Bước 2 "Connect your calendars"**: Google, Outlook, iCloud. Có lịch nội bộ để timebox.
- **Bước 3 "When do you plan your day?"**: chọn giờ nhắc plan. Trong thời gian trial có email nhắc hằng ngày. Help khuyên: chọn trước 3 PM nếu plan buổi sáng, sau 3 PM nếu plan buổi tối. Đổi được trong Account Settings.
- **Không bỏ qua được:** help ghi phải làm hết các bước mới vào được workspace. Help **không nhắc** giờ làm hay timezone.
- **Sau onboarding là "guided daily planning" bản lần đầu**, gồm: "Plan today or tomorrow" → "Add tasks for today" → "Set time estimates" (cảnh báo khi vượt workload threshold) → "Fill in tasks from other tools" → "Push back non-essential tasks" → "Finalize your plan" (sắp xếp, timebox, phím `X` auto-schedule, đặt **Shutdown time**, "Looks good") → "Share your plan and get started" ("Get Started"; "Skip this step in the future" chỉ áp cho các lần plan sau).
- **Changelog 26/10/2026:** "A smoother onboarding with Autoplan for new users." Help hiện không mô tả luồng này.
- **Rituals → "When do you plan your day":** giờ sau 3 PM thì plan cho ngày hôm sau, giờ sớm hơn thì plan cho hôm nay (https://help.sunsama.com/docs/user-settings).

**Đối chiếu với ta:**

| Sunsama (nguồn ở trên) | App ta | Đánh giá |
|---|---|---|
| 3 bước: công cụ → lịch → giờ plan | 5 bước: ngôn ngữ + timezone → lịch → công cụ → lịch làm việc + giờ plan → 3 task (G01 BR-11, US2.1) | **Khác có chủ đích**: hỏi timezone và lịch làm việc ngay từ đầu vì "Thời gian phải đúng" (PRD G01 mục 4.2, QC-01, QC-02). Thứ tự lịch trước công cụ không có lý do ghi lại, đổi được. |
| Chọn công cụ trước, kết nối sau | Bước 3 chỉ lưu lựa chọn, 1.0 chưa có tích hợp (US2.1 AC03) | **Giống** |
| Lịch Google / Outlook / iCloud; có lịch nội bộ | Google / Outlook, có "Bỏ qua" (US2.1 AC02) | **Khác chưa chủ đích** về iCloud / CalDAV. Sunsama mở CalDAV cho mọi người từ 19/10/2026 (https://sunsama.canny.io/changelog/weekly-product-changelog-october-19-2026). Việc này thuộc G05. Chuyện Sunsama có cho bỏ qua bước lịch không thì help không rõ, xem mục 3. |
| Phải làm hết các bước | Bước 2 bỏ qua được; bước 5 bắt ≥ 1 task `[giả định]` (US2.1 AC05) | **Khác chưa chủ đích**: PRD G01 mục 10 vẫn còn mở "Bước 5 bắt buộc ít nhất 1 task hay cho bỏ qua?". Sunsama không bắt nhập task trong onboarding; việc thêm task nằm ở Daily planning. |
| Giờ plan sau 3 PM thì plan cho ngày mai; có "Plan today or tomorrow" | Giờ plan 00:00–23:55, mặc định 09:00 (G01 mục 5). Không có quy tắc plan cho ngày mai | **Khác chưa chủ đích**: G01 và G08 chưa đặc tả "plan buổi tối cho ngày mai". Cần G08 quyết định. |
| Sau onboarding vào Daily planning có hướng dẫn | Bước 5 xong mở Daily planning có hướng dẫn (US2.2) | **Giống** |
| Shutdown time đặt ở bước cuối của planning đầu tiên | Không thấy trong onboarding của G01 (thuộc G08) | Cần G08 đối chiếu; không kết luận ở đây. |
| Autoplan (AI) trong onboarding người dùng mới (26/10/2026) | Trợ lý AI mặc định tắt, chỉ bật qua màn đồng ý (QC-12 mục 7). Onboarding không có bước AI | **Khác có chủ đích** (QC-12 mục 7, Q21). Ghi chú cho design ở mục 4. |
| Tooltip theo ngữ cảnh ("Task projections", "Your first keyboard shortcut") | G01 BR-16 | **Giống**: đã kiểm chứng trên Sunsama ngày 04/11/2026 (header PRD G01). |

### 2.2 Cài đặt

**Nguồn chính:**
- Account Settings: https://help.sunsama.com/docs/user-settings
- Customizing Your Timeboxing Settings: https://help.sunsama.com/docs/usage-guides/timeboxing/timeboxing-customizing-settings
- Auto-scheduling: https://help.sunsama.com/docs/usage-guides/timeboxing/timeboxing-auto-scheduling
- Changelog "control your schedule by channel": https://roadmap.sunsama.com/changelog/control-your-schedule-by-channel
- Roadmap "Set Schedules and Working Hours" (đã xong; trả lời của Sunsama ngày 26/04/2022): https://roadmap.sunsama.com/improvements/p/set-schedules-and-working-hours
- Roadmap đổi giờ rollover sau nửa đêm (Closed): https://roadmap.sunsama.com/improvements/p/option-to-change-rollover-time-end-of-day-time-to-after-midnight
- Keyboard Shortcuts: https://help.sunsama.com/docs/usage-guides/keyboard-driven-actions/keyboard-shortcuts

**Các nhóm cài đặt của Sunsama (theo help Account Settings):**
- **General:** Time zone, Time zone alert, Time format, Start of week, Count planned time as actual time, Auto-sort tasks, New task position, Task rollover position, Priority rollover, Workload threshold (có "Custom by day"; chỉ tính task thuộc context work).
- **Display:** Calendar event color, Hide completed tasks (in task list / in calendar), Support chat bubble, Dark mode, Enabled celebration animations và Celebration type, Disable spellcheck.
- **Rituals:** When do you plan your day, Automated daily planning, After daily planning (Home / Today / Focus), Automatically rollover tasks during evening planning, When do you end your day, Automated daily shutdown, End of day message, các cài đặt ritual tuần, Default channel for rituals tasks, "When do you want to receive the draft of your daily highlights?".
- **Timeboxing:** Pick which calendars, Calendar reminders / availability / privacy, Auto-scheduling gap, Default duration when scheduling tasks, Auto-reschedule tasks when they conflict, Auto-reschedule when a task is completed ahead of schedule, "Set up your working hours".
- **Keyboard Shortcuts:** công tắc tổng (khi tắt, CMD K và Escape vẫn chạy). Phím toàn cục trên desktop: Add Task (CMD/Ctrl Shift A), Toggle focus bar timer (CMD/Ctrl Shift Space), Toggle focus bar (CMD/Ctrl Shift F).
- **Focus, Focus Bar, Focus Sounds.**
- **AI:** Channel recommendations (mặc định tự áp dụng), Planned time recommendations, Planned time recommendations for subtasks, AI Summary Language, Automatic summaries (mặc định bật). Sunsama ghi rằng họ không dùng dữ liệu khách hàng để train model.
- **Profile, Account Management:** đổi / đặt mật khẩu, 2FA, đổi email chính, Export my data (CSV / JSON), "Logout all sessions" (ngắt cả "connected apps and agents, such as MCP clients"), Delete account.
- **Mobile App.**

**Giờ làm việc ở Sunsama:**
- Có trang **Schedules** (mở qua "Edit Schedules" hoặc Settings → Schedules). Trang này đặt "default schedules by day" và lịch riêng cho channel. Help ghi: "Channel-specific auto-scheduling schedules override your default scheduling hours."
- Mọi tài liệu chỉ nói lịch này dùng cho **auto-scheduling**: "Sunsama will not schedule tasks outside of your schedules unless you tell it to"; có tuỳ chọn "Schedule anyway".
- Help không nói một ngày có được nhiều khoảng giờ không.

**Mốc đầu ngày:**
- Help Account Settings không có cài đặt này.
- Đề xuất "đổi giờ rollover sang sau nửa đêm" trên roadmap có trạng thái **Closed** và không có câu trả lời chính thức.
- Kết luận: theo tài liệu công khai, Sunsama không có mốc đầu ngày tuỳ chỉnh. Sunsama coi ngày kết thúc lúc nửa đêm hay giờ khác thì phải kiểm chứng.

**Thông báo:**
- Help Account Settings **không có nhóm Notifications**.
- Có nhắc plan theo giờ "When do you plan your day", và có ritual tự mở theo giờ.
- Nhắc nghỉ giải lao cần app desktop (nhóm Focus trong https://help.sunsama.com/docs/user-settings).

**Đối chiếu với ta:**

| Sunsama | App ta | Đánh giá |
|---|---|---|
| General: timezone, ngày đầu tuần, planned = actual, auto-sort, vị trí task mới / rollover, priority rollover, workload threshold | SCR-07 Chung (G01): đủ các mục tương ứng, thêm Ngôn ngữ và **Mốc đầu ngày** | **Giống** phần lớn. Có mốc đầu ngày là **khác có chủ đích** (QC-01, BR-14). |
| Workload threshold có "Custom by day" | Ngưỡng khối lượng ngày là một con số (SCR-07 #5); sức chứa theo lịch làm việc (QC-02 mục 7) | **Khác có chủ đích**: QC-02 mục 7 / Q48 tính sức chứa từ lịch. Ngưỡng theo từng ngày thì chưa nhắc tới. |
| Time zone alert (bật / tắt) | Banner lệch timezone, chọn "Giữ" thì không hỏi lại (G01 BR-13) | **Giống** về ý. Sunsama có công tắc tắt cảnh báo; ta không có. **Khác chưa chủ đích** nhưng nhỏ. |
| Time format 12h / 24h | Không thấy | **Khác chưa chủ đích**: 1.0 theo ngôn ngữ Windows? Cần PO. |
| Display: Hide completed (list / calendar), Dark mode, celebration và kiểu celebration, spellcheck, support bubble | SCR-08 Hiển thị: Giao diện, Màu sự kiện, Ẩn task đã xong, Hiệu ứng chúc mừng | **Giống** phần cốt lõi. Phần còn thiếu không quan trọng. |
| Schedules: lịch mặc định theo ngày và lịch channel thắng lịch mặc định; **chỉ dùng cho auto-scheduling** | Lịch làm việc chung (G01 BR-22, SCR-14) và khung giờ channel (G02 BR-22, QC-02 mục 5). Dùng cho ngày làm việc kế tiếp, ritual, sức chứa, số ngày bị hoãn, auto-schedule (1.1) | **Khác có chủ đích** (QC-02, Q38 / Q38a, D1–D4). Lưu ý cho design: người quen Sunsama sẽ nghĩ giờ làm chỉ ảnh hưởng xếp lịch, nên ghi chú trên SCR-14 cần nói rõ tác dụng rộng hơn. |
| Schedules là trang riêng, mở từ Timeboxing ("Set up your working hours") | Nhóm "Lịch làm việc" riêng; khung channel nằm ở Context & channel (SCR-06) | **Giống** về cấu trúc. |
| Keyboard Shortcuts: công tắc tổng, CMD K / Esc vẫn chạy, 3 phím toàn cục (gồm Toggle focus bar) | BR-15: công tắc, Ctrl+K / Esc vẫn chạy, 2 phím toàn cục | **Giống**. Thiếu "Toggle focus bar" vì 1.0 không có focus bar (G07): khác có chủ đích nếu G07 xác nhận. Đổi phím toàn cục được không thì help không rõ (mục 3). |
| Rituals: giờ plan, tự mở, sau planning đi đâu, rollover lúc plan buổi tối, giờ kết thúc ngày, lời nhắn cuối ngày | Nhóm Ritual thuộc G08 | Ngoài phạm vi đối chiếu sâu. Riêng "After daily planning" (Today / Focus): ta chưa có (G08 cần xem). |
| Không có nhóm Notifications trong help | Cài đặt → Thông báo, bảng sự kiện × kênh, có thông báo Windows từ 1.0 (G12 BR-18, D12) | **Khác có chủ đích** (D12). Sunsama thật sự có nhóm này hay không: mục 3. |
| AI: gợi ý channel (tự áp), gợi ý planned time (task, subtask), AI Summary Language, Automatic summaries; Sunny bật / tắt ở Integrations → AI Assistant | Một nhóm "Trợ lý AI" (G01 BR-24 → G10 SCR-09) gom: trạng thái Claude Code, Trợ lý, gợi ý channel / thời lượng, ngôn ngữ tóm tắt, tóm tắt tự động, quyền hoàn thành / xoá, đọc dữ liệu tích hợp, terminal | **Khác có chủ đích**: gom một chỗ (US4.5). Ở ta mọi gợi ý AI cần Claude Code và trợ lý đang bật (Q33, BR-30). Ở Sunsama gợi ý không phụ thuộc Sunny. |
| Logout all sessions ngắt cả MCP clients | Đăng xuất mọi phiên (G01 BR-18); MCP local chỉ chạy khi app đăng nhập (G10 BR-27) | **Giống** về ý. |
| Delete account xoá cả hội thoại Sunny và AI feedback (changelog 05/10/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-october-5-2026) | G01 BR-20 xoá tài khoản; G10 lịch sử chat 90 ngày | **Khác chưa chủ đích**: chưa thấy câu nói rõ xoá tài khoản có xoá lịch sử chat AI và phản hồi AI. Cần G01 và G10 bổ sung một dòng. |
| Bộ chọn timezone có ô tìm và gợi ý timezone thiết bị (changelog 05/10/2026) | SCR-07 #2 "Dropdown có tìm", hiện "Theo thiết bị" | **Giống** |

### 2.3 Trợ lý AI của Sunsama (Sunny, Planning Agent / Autoplan, Highlights)

**Nguồn chính:**
- Sunny the AI Assistant: https://help.sunsama.com/docs/usage-guides/sunny
- Daily Planning (mục Agentic Daily Planning): https://help.sunsama.com/docs/usage-guides/daily-planning
- Daily Highlights: https://help.sunsama.com/docs/usage-guides/daily-highlights
- MCP của Sunsama: https://help.sunsama.com/docs/integrations/mcp
- Các changelog:
  - 23/09/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-4
  - 29/09/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-september-29-2026
  - 05/10/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-october-5-2026
  - 12/10/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-october-12-2026
  - 19/10/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-october-19-2026
  - 26/10/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-october-26-2026
  - 02/11/2026: https://sunsama.canny.io/changelog/weekly-product-changelog-nov-2-2026

**Sunny làm được gì (theo help Sunny):**
- **Task:** tạo, sửa, chuyển, **hoàn thành, xoá** task; subtask, thời lượng, timer, task lặp.
- **Sắp xếp kế hoạch:** gán channel, gắn weekly objective, timebox; xem lịch, sắp thứ tự, kéo sự kiện lịch thành task.
- **Lịch họp:** **nhận / từ chối lời mời họp**.
- **Backlog:** xem backlog, đưa vào folder hoặc vào một ngày cụ thể.
- **Tổng hợp:** tóm tắt việc đã làm.
- **Cài đặt:** **đổi giờ shutdown và cài đặt import lịch**.

**Cách mở và tắt Sunny:**
- Desktop: bấm nút ✦ góc dưới phải, ô nhập "Say something…".
- Có "New chat", "History", xoá từng hội thoại; hội thoại dài bị cắt từ phần cũ nhất.
- Sunny **bật sẵn**, tắt ở Settings → Integrations → AI Assistant. Admin enterprise tắt được cho cả workspace.

**Duyệt và hoàn tác (theo changelog):**
- 29/09/2026: "Sunny now shows a receipt for every change it makes, with one-click undo and a link to what it changed"; "Sunny asks for clarification when a request is ambiguous instead of guessing"; "Undoing an Autoplan (beta) run now also restores task priorities".
- 02/11/2026: "Each change has an Undo"; khung chat mới có New chat / History rõ hơn.
- 12/10/2026: Sunny gửi đề xuất lên roadmap "only after you say go". Sunny lưu "standing rule" "after repeating it back and checking with you first". Bộ nhớ chỉ giữ "durable facts about who you are".
- 05/10/2026: Sunny đọc công cụ đã kết nối ngay trong chat (Gmail, Slack, Jira, GitHub, Linear, Google Tasks, Todoist, Trello, Notion, ClickUp, monday.com, Microsoft 365) và tạo task từ đó.

**Giới hạn:**
- Help **không nêu** hạn mức, gói, model, cũng không nêu cơ chế duyệt trước khi áp dụng.
- Sunsama MCP server (https://api.sunsama.com/mcp, OAuth) cho Claude Code, ChatGPT, Cursor... điều khiển Sunsama. Help MCP **không nói** gì về undo hay duyệt.

**Planning Agent / Autoplan (theo help Daily Planning):**
- **Bật:** Beta "Agentic Daily Planning" ở Settings > Beta, **áp cho cả workspace**. Mở bằng `P` hoặc Daily rituals → Daily planning.
- **Thiết lập lần đầu** gồm "Connect your tools" (có Next mà không cần kết nối), "Tell me about yourself", "Theme days".
- **Luồng:** mô tả ngày → "Plan my day" (thường 2–4 phút; rời trang được; menu hiện "Ready"; nếu agent cần giờ kết thúc ngày thì hỏi, không trả lời vẫn chạy tiếp) → **Review Plan**.
- **Dữ liệu agent dùng:** shutdown time, weekly objectives, daily theme, công cụ đã kết nối, task trong ngày, backlog, rules. Agent xếp quanh sự kiện và giờ làm.
- **Hành động:** tạo task, ưu tiên, dời sang ngày khác, sắp thứ tự, đặt thời lượng. Help **không nhắc** hoàn thành hay xoá.
- **Màn Review Plan:**
  - danh sách hành động theo ngày, bên cạnh là panel kế hoạch;
  - **"judgement calls to review"**: giữ chỗ agent đặt, chuyển về hôm nay và dọn chỗ, hoặc bỏ; nút "Keep the agent's plan for all";
  - "New rule saved";
  - Undo từng dòng khi hover; **"Undo all"** có xác nhận, xong quay về đầu luồng;
  - "Re-plan"; Next → Daily plan → "Get started".
- **Áp dụng trước hay sau khi duyệt:** help nói agent "shows you everything it did so you can keep it, adjust it, or undo it". Cách nói này **gợi ý** thay đổi đã được áp dụng trước khi duyệt, nhưng help không nói thẳng.
- **Sunny cạnh Review Plan:** Sunny mở bên cạnh để tóm tắt lượt chạy: thứ tự đã chọn, chỗ cần kiểm tra lại, yêu cầu không làm và lý do, item công cụ bị bỏ qua. Theo changelog 23/09/2026, từ đó Sunny "can undo any change or start a fresh run".
- **Rules:** chỉ dẫn cố định, có trang riêng (xem, sửa, tạo, tạm dừng, xoá; changelog 23/09/2026). Câu kiểu "from now on…" trong ô nhập có thể thành rule "Learned from your braindump".
- **Lỗi:** help **không nêu** chuyện gì xảy ra khi lượt chạy lỗi.
- **Changelog 19/10/2026:** "Your plan is ready in seconds instead of about half a minute", mâu thuẫn với help "2–4 minutes". Agent có "open loops" (review, tin nhắn, email đang chờ). Briefing nêu việc không làm và lý do.
- **Changelog 26/10/2026:** "It only adds items from your tools when your braindump asks for them"; có thể re-plan một ngày từ màn review.
- **Changelog 02/11/2026:** "If you start Autoplan late in the day, it asks whether to plan tomorrow or extend today."

**Highlights (theo help Daily Highlights và Account Settings):**
- **Khi nào sinh:** bấm Next ở bước đầu của Daily shutdown thì highlights được tạo.
- **Từng highlight:** xoá, gắn sao, sửa tiêu đề, ẩn / hiện tóm tắt AI, **"Resummarize" cho từng highlight**; kéo để sắp xếp và lồng nhau; "Add a highlight"; thêm từ "Other activities".
- **Lưu và chia sẻ:** "Done for the day" lưu và chia sẻ.
- **Nháp email:** Rituals có "When do you want to receive the draft of your daily highlights?" (chọn ngày và giờ); nhóm AI có "Automatic summaries" (mặc định bật).

**Đối chiếu với ta:**

| Sunsama | App ta | Đánh giá |
|---|---|---|
| Sunny bật sẵn, tắt trong Integrations | Trợ lý mặc định tắt, lần đầu bật phải qua màn đồng ý (QC-12 mục 7, G10 BR-19) | **Khác có chủ đích** (Q21) |
| Sunny hoàn thành và xoá task | Mặc định không; có công tắc "Cho phép AI hoàn thành và xoá task"; task có liên kết tích hợp thì không bao giờ (QC-12 mục 4, BR-26, D10) | **Khác có chủ đích** |
| Sunny đổi giờ shutdown và cài đặt import lịch | AI không được đổi cài đặt (G10 BR-02) | **Khác có chủ đích** |
| Sunny nhận / từ chối lời mời họp | Không có công cụ MCP; "gửi tin ra ngoài" bị cấm (BR-02) | **Khác có chủ đích** theo tinh thần BR-02, nhưng BR-02 chưa ghi rõ "trả lời lời mời họp". Nên thêm một dòng. |
| Receipt cho mỗi thay đổi, Undo một chạm, link tới đối tượng | Chip "AI", Hoàn tác từng thay đổi và cả lượt, nhật ký (QC-12 mục 5, BR-07, BR-08) | **Giống**. Ta có thêm thời hạn 7 ngày và câu hỏi giữ bản người dùng đã sửa (EC-38). |
| Hỏi lại khi yêu cầu mơ hồ | Hỏi lại "ngày mai" lúc giữa đêm bằng 2 lựa chọn ngày (G10 BR-05) | **Giống một phần**: ta mới quy định cho ngày giờ, chưa có quy tắc chung "mơ hồ thì hỏi lại". **Khác chưa chủ đích.** |
| Sunny đọc công cụ đã kết nối (từ 05/10/2026), không thấy cơ chế duyệt | Công tắc riêng, mặc định tắt; sau lần đọc đầu thì thay đổi chuyển sang chờ duyệt (QC-12 mục 6, D8) | **Khác có chủ đích** |
| Standing rules (Sunny lưu sau khi nhắc lại và hỏi xác nhận), bộ nhớ "durable facts" | "Kể về bạn", theme days (G10 US1.1); không có rules hay bộ nhớ | **Khác chưa chủ đích**: chưa có quyết định thêm hay không. |
| Lịch sử chat: New chat, History, xoá từng hội thoại | Lịch sử 90 ngày, xoá từng hội thoại (G10 BR-15) | **Giống** |
| Beta Agentic Daily Planning cho cả workspace | Beta "Agentic Daily Planning" (SCR-09 #8); 1.0 chỉ một người dùng | **Giống** (phạm vi người dùng không quan trọng ở 1.0) |
| Thiết lập: Connect your tools / Tell me about yourself / Theme days; phần nào cũng bỏ qua được | US1.1 AC01–AC02 | **Giống** |
| "Plan my day" 2–4 phút, rời trang được, menu "Ready" | 2–4 phút, tối đa 5 phút; bước đầu ≤ 10 giây (G10 mục 5) | **Giống** về thời lượng. **Khác chưa chủ đích**: ta chưa có trạng thái "Ready" khi người dùng rời trang. Changelog 19/10 nói Sunsama nay chỉ mất vài giây; con số 2–4 phút có thể cần xem lại. |
| Agent hỏi giờ kết thúc ngày nếu thiếu | Không có (ta có lịch làm việc, highlights theo giờ kết thúc lịch chung) | Không cần: ta luôn có giờ kết thúc từ lịch làm việc (QC-02). |
| Review Plan: Undo từng dòng, Undo all có xác nhận rồi về đầu, Re-plan | US1.3 AC02, AC04: Hoàn tác từng dòng, "Hoàn tác kế hoạch AI", "Lập lại" | **Giống**. Xác nhận trước "Undo all": ta chưa ghi. **Khác chưa chủ đích** nhưng nhỏ. |
| **"judgement calls to review"** (giữ / về hôm nay và dọn chỗ / bỏ; "Keep the agent's plan for all") | Không có. Chỉ có chế độ chờ duyệt khi dùng dữ liệu tích hợp (US1.3 AC03) | **Khác chưa chủ đích**: đáng cân nhắc cho design Review Plan. |
| Sunny mở cạnh Review Plan với briefing (việc không làm và lý do; item bị bỏ qua) | Câu tóm tắt "Planning Agent đã thêm 3 task, dời 2 task" (US1.3 AC01) | **Khác chưa chủ đích**: ta chưa có phần "việc không làm và lý do". |
| Late day: hỏi plan ngày mai hay kéo dài hôm nay | QC-01 ngày làm việc, BR-05 hỏi lại "ngày mai" | **Giống một phần**: ta chưa quy định khi "Plan my day" chạy muộn trong ngày. |
| Áp dụng ngay hay chờ duyệt: help chỉ ngụ ý áp dụng trước | Áp dụng ngay; có dữ liệu tích hợp thì chờ duyệt (QC-12 mục 5–6) | Ta đã chốt (Q31 / Q31a). PRD G10 viết "như Sunsama" dựa trên kiểm chứng Chrome 04/11/2026. |
| Lỗi giữa chừng: help không nêu | Giữ phần đã áp dụng, Hoàn tác cả lượt, chuyển sang thủ công (D9, EC-39) | Ta đặc tả kỹ hơn. Không cần đổi. |
| Highlights: sinh khi bấm Next ở shutdown; nháp email theo ngày / giờ tự chọn; Automatic summaries | Nháp tự động tại giờ kết thúc lịch chung vào ngày làm việc (D7, Q39); "Soạn bằng AI"; "Tóm tắt tự động" | **Khác có chủ đích** (D7, Q39) |
| Highlights: Resummarize từng mục, gắn sao, lồng nhau, ẩn tóm tắt AI, "Include" từ Other activities | Sửa, xoá ý, "Soạn lại" (cả bản), "Thêm vào" việc mới xong (US3.2) | **Khác chưa chủ đích**: chưa có soạn lại từng mục, gắn sao, lồng nhau. |
| Sunsama mở MCP server cho Claude Code / ChatGPT (OAuth, remote) | App mở MCP local; Claude Code của người dùng vừa là bộ não vừa là terminal (ADR-0004, QC-12 mục 3) | **Khác có chủ đích** (ADR-0004) |
| Help không nêu hạn mức Sunny | Không có hạn mức theo gói; dùng hạn mức gói Claude (QC-12 mục 8) | **Khác có chủ đích** |

### 2.4 Claude Code CLI và MCP: hệ quả cho màn hình / trạng thái của G10

**Nguồn chính (docs Claude Code):**
- CLI reference: https://code.claude.com/docs/en/cli-reference
- Run Claude Code programmatically (headless, `-p`): https://code.claude.com/docs/en/headless
- MCP: https://code.claude.com/docs/en/mcp
- Error reference: https://code.claude.com/docs/en/errors
- Authentication: https://code.claude.com/docs/en/authentication
- Setup (cài đặt): https://code.claude.com/docs/en/setup
- Agent SDK TypeScript reference (kiểu message trong stream): https://code.claude.com/docs/en/agent-sdk/typescript
- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance
- Permissions: https://code.claude.com/docs/en/permissions

#### a. Phát hiện đã cài, phiên bản, đăng nhập

- **Cài đặt trên Windows:**
  - Yêu cầu Windows 10 1809+. Cài bằng PowerShell `irm https://claude.ai/install.ps1 | iex`, CMD, hoặc `winget install Anthropic.ClaudeCode` (bản WinGet **không tự cập nhật**).
  - Sau khi cài: "open a new terminal window and run `claude --version`". Nếu `claude` không được nhận ra thì thư mục cài chưa có trong PATH.
  - Git for Windows là tuỳ chọn.
  - Nguồn: https://code.claude.com/docs/en/setup
- **Phiên bản:** `claude --version` / `-v` "Output the version number". Cập nhật bằng `claude update` (https://code.claude.com/docs/en/cli-reference).
- **Đăng nhập:**
  - `claude auth status` "Show authentication status as JSON... Exits with code 0 if logged in, 1 if not."
  - `authMethod` là một trong `none`, `claude.ai`, `oauth_token`, `api_key`, `api_key_helper`, `third_party`.
  - Đăng nhập bằng `claude auth login`, đăng xuất bằng `claude auth logout`.
  - Nguồn: https://code.claude.com/docs/en/cli-reference
- **Chẩn đoán:** `claude doctor` in chẩn đoán cài đặt và cài đặt hiện tại, chỉ đọc, không mở phiên (cùng nguồn).
- **Loại tài khoản:**
  - Claude Pro / Max / Ultra; Teams / Enterprise; Console (API); nhà cung cấp cloud (Bedrock, Vertex, Foundry).
  - Lần đầu chạy `claude` thì mở trình duyệt để đăng nhập.
  - Trên Windows, thông tin đăng nhập nằm ở `%USERPROFILE%\.claude\.credentials.json`.
  - Nguồn: https://code.claude.com/docs/en/authentication
- **Sắp hết hạn đăng nhập:**
  - Cảnh báo "Your login expires in 3 days · run /login to renew".
  - `/status` hiện "Expired — log in again" khi đã hết hạn.
  - Khi hết hạn hẳn, mọi lời gọi lỗi với "Login expired · Please run /login".
  - Nguồn: https://code.claude.com/docs/en/authentication

**Hệ quả cho G10 (SCR-09 #12, SCR-11, BR-25):**
- Bốn trạng thái hiện có ánh xạ được vào lệnh công khai:
  - `CHUA_CAI`: không chạy được `claude --version`.
  - `PHIEN_BAN_CU`: so sánh với số `--version` trả về.
  - `CHUA_DANG_NHAP`: `auth status` exit 1 hoặc `authMethod: none`.
  - `SAN_SANG`.
- **Nên thêm trạng thái (hoặc biến thể thông báo) cho design:**
  - **"Đăng nhập Claude đã hết hạn"**: khác "chưa đăng nhập". Cùng hành động nhưng câu chữ khác.
  - **"Tài khoản / tổ chức không dùng được"**: "This organization has been disabled", "Your account is on hold", "Your organization has disabled Claude subscription access" (https://code.claude.com/docs/en/errors).
  - **"Đã đăng nhập bằng API key / nhà cung cấp khác"**: `authMethod` khác `claude.ai`. Màn đồng ý SCR-10 #3 đang viết "tài khoản Claude của bạn", có thể không đúng với người dùng API key; tính phí cũng khác.
  - **"Đang kiểm tra…"**: trạng thái tạm khi bấm "Kiểm tra lại".
- **"Chưa cài" có thể báo sai:** docs nói phải mở terminal **mới** thì PATH mới có `claude`. App đang chạy có thể chưa thấy `claude` ngay sau khi người dùng cài. Thẻ SCR-11 cần dự phòng câu "Đã cài mà vẫn báo chưa? Khởi động lại app". Phải kiểm chứng (mục 3).
- **Hướng dẫn trong thẻ:** dùng được lệnh copy cho PowerShell / CMD. Gợi ý "Xem hướng dẫn" trỏ về https://code.claude.com/docs/en/setup.

#### b. Chạy không tương tác (headless / print mode) và luồng output

- **Lệnh chạy:** `claude -p "<prompt>"` (hoặc `--print`) chạy xong thì thoát.
- **Định dạng đầu ra:**
  - `--output-format text|json|stream-json`.
  - Muốn stream từng token: `--output-format stream-json --verbose --include-partial-messages`.
  - "The last line of the stream is a `result` message with the final response text, cost, and session metadata".
  - Nguồn: https://code.claude.com/docs/en/headless
- **Exit code và lỗi:**
  - "Claude Code exits with code 0 on success and a non-zero code when the run fails".
  - "When a failure happens inside the run, such as missing authentication, Claude Code prints the failure as the result on stdout" (cùng nguồn).
- **Lệnh tương tác:** "Built-in commands that only run in the terminal interface, such as `/login`, aren't available" trong `-p` (cùng nguồn).
- **Tiếp tục hội thoại:** `--continue` / `--resume <session_id>`; lấy `session_id` từ JSON (cùng nguồn).
- **Message `result`:**
  - Các trường: `subtype` (`success` | `error_max_turns` | `error_during_execution` | `error_max_budget_usd` | …), `is_error`, `result`, `session_id`, `total_cost_usd`, `permission_denials`, `errors`.
  - `startup_failure_reason` có giá trị như `cli_version_too_old`.
  - Nguồn: https://code.claude.com/docs/en/agent-sdk/typescript
- **Sự kiện thử lại:** `system/api_retry` có `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, và `error` thuộc nhóm `authentication_failed`, `billing_error`, `rate_limit`, `overloaded`, `server_error`... (https://code.claude.com/docs/en/headless)
- **Sự kiện hạn mức:**
  - `rate_limit_event` có `status: "allowed" | "allowed_warning" | "rejected"`, `resetsAt`, `utilization`.
  - `errorCode: "credits_required"` khi gói claude.ai đã hết lượt đi kèm.
  - Nguồn: https://code.claude.com/docs/en/agent-sdk/typescript
- **Bare mode:** `--bare` khởi động nhanh hơn nhưng "doesn't use your subscription login" (cần `ANTHROPIC_API_KEY`) (https://code.claude.com/docs/en/headless).
- **Quyền:**
  - Trong `-p`, công cụ cần duyệt sẽ bị từ chối nếu không được cho phép trước (`--allowedTools`, `--permission-mode`).
  - Từ v2.1.302, `-p` mặc định chạy ở Manual mode.
  - `--permission-prompts none` cho lượt chạy không có người trông.
  - Nguồn: https://code.claude.com/docs/en/headless

**Hệ quả cho G10:**
- **"Đang xử lý" có tiến độ thật:** stream-json cho phép hiện chữ ngay khi có, đáp ứng mục tiêu "kết quả đầu tiên ≤ 10 giây" (BR-09). Design cần trạng thái **"đang nghĩ / đang gọi công cụ"** (giống "Thought 8s" đã thấy ở Sunsama).
- **Trạng thái "Đang thử lại"** (từ `api_retry`): ví dụ "Claude đang quá tải, đang thử lại (lần 2/10)". Như vậy người dùng không phải nhìn spinner vô hạn. Claude Code tự thử lại 529 và 429 tạm thời tới 10 lần (https://code.claude.com/docs/en/errors).
- **Trạng thái "Câu trả lời bị cắt":** docs có "The response above may be incomplete". Khi lỗi giữa chừng, phần chữ đã có vẫn giữ lại. Khớp với MSG-27 "đã dừng giữa chừng · Gửi lại".
- **Đăng nhập không làm trong app được:** `-p` không có `/login`. Thẻ "Chưa đăng nhập / Hết hạn" phải hướng người dùng **mở terminal chạy `claude`** (hoặc `claude auth login`). App không được tự thu thông tin đăng nhập (xem e).

#### c. Đăng ký MCP server local cho Claude Code

- **Stdio:** `claude mcp add [options] <name> -- <command> [args...]`. Mọi thứ sau `--` truyền thẳng cho server.
- **HTTP:** `claude mcp add --transport http <name> <url>`.
- **Scope:**

  | Scope | Lưu ở | Dùng ở |
  |---|---|---|
  | `local` (mặc định) | `~/.claude.json` | dự án hiện tại |
  | `project` | `.mcp.json` | dự án hiện tại, chia sẻ qua git |
  | `user` | `~/.claude.json` | mọi dự án |

- **Quản lý:** `claude mcp list` / `get` / `remove`. In-session dùng `/mcp`.
- **Trạng thái server:** `✔ Connected`, `! Needs authentication`, `✘ Failed to connect`, `⏸ Pending approval`, `⊘ Disabled for this project`, `✘ Blocked by enterprise managed policy`. Tên dành riêng (`workspace`, `computer-use`…) bị từ chối.
- **Đổi bộ công cụ giữa phiên:** server gửi `list_changed` thì Claude Code tải lại danh sách công cụ, kể cả trong `-p`.
- **Duyệt mỗi lần gọi:** đánh dấu `_meta["anthropic/requiresUserInteraction"]` thì công cụ phải được duyệt **mỗi lần gọi**, kể cả ở chế độ auto.
- **Giới hạn đầu ra:** cảnh báo khi output công cụ > 10.000 token, cắt ở 25.000 (`MAX_MCP_OUTPUT_TOKENS`).
- **Server stdio thoát giữa chừng:** trong `-p`, Claude Code tự khởi động lại ở lần gọi kế tiếp.
- Nguồn cho cả mục: https://code.claude.com/docs/en/mcp
- **App tự gọi:**
  - `--mcp-config <file-or-json>` + `--strict-mcp-config` để chỉ dùng server của app.
  - Với `-p`, Claude Code chờ server tối đa `MCP_TIMEOUT` (mặc định 30 giây).
  - `system/init` có `mcp_servers` (tên + `status`) và `mcp_server_errors`.
  - Nguồn: https://code.claude.com/docs/en/cli-reference và https://code.claude.com/docs/en/headless
- **Tên quyền:** quy tắc quyền viết theo dạng `mcp__<server>__<tool>` hoặc `mcp__<server>__*` (https://code.claude.com/docs/en/permissions).

**Hệ quả cho G10:**
- **SCR-09 #13 "Dùng Claude Code trong terminal":**
  - Có thể là **một lệnh copy** dạng `claude mcp add --scope user <tên-app> -- <lệnh>` hoặc `--transport http`. Tech chọn stdio hay HTTP.
  - Nên có nút **"Kiểm tra kết nối"** phản ánh các trạng thái của `claude mcp list` (Đã kết nối / Không kết nối được / Chưa thêm).
  - Ghi chú "App phải đang mở" vẫn cần.
- **Hỏi quyền trong terminal:**
  - Trong phiên terminal tương tác, Claude Code sẽ **hỏi quyền** khi gọi công cụ của app, trừ khi người dùng thêm allow rule `mcp__<server>__*`.
  - Hướng dẫn trên SCR-09 #13 nên báo trước để người dùng không bất ngờ.
  - Docs không nói việc này ảnh hưởng tới Hoàn tác thế nào. Nhưng nó cho thêm một lớp duyệt ở phía terminal mà khung chat trong app không có.
- **Bật / tắt quyền hoàn thành, xoá (BR-26 "biến mất từ lượt kế tiếp"):** docs cho thấy có thể áp dụng **ngay trong phiên** nhờ `list_changed`. Design không cần câu "khởi động lại Claude Code". Phải kiểm chứng (mục 3).
- **Lỗi MCP khi app tự gọi:** server MCP của app không lên (status khác connected trong `system/init`) phải là **một trạng thái lỗi riêng** ("Trợ lý không kết nối được với app"), khác lỗi Claude Code.
- **Ngày nhiều task (EC-40, 500 task):** dễ chạm trần 25.000 token mỗi lần gọi công cụ. Đây là việc của tech (phân trang). Với design, Planning Agent có thể chậm hoặc thiếu dữ liệu ở ngày rất dày.
- **`requiresUserInteraction`:** nếu dùng cho công cụ "Hoàn thành / Xoá" thì terminal luôn hỏi. Đây là một lựa chọn cho tech và PO, đi cùng D10.

#### d. Lỗi thường gặp (chưa đăng nhập, hết hạn mức…)

Nguồn: https://code.claude.com/docs/en/errors

| Nhóm | Thông báo nguyên văn (docs) | Ghi chú | Trạng thái / màn đề xuất cho G10 |
|---|---|---|---|
| Chưa đăng nhập | `Not logged in · Please run /login` | | SCR-11 MSG-25 |
| Phiên hết hạn | `Login expired · Please run /login`; trong `-p`: `Failed to authenticate: OAuth session expired and could not be refreshed` | mã `authentication_failed` | SCR-11, biến thể "hết hạn" |
| Token bị thu hồi | `OAuth token revoked · Please run /login`; trong `-p`: `Failed to authenticate: OAuth token revoked. Please log in again or contact your administrator.` | | SCR-11, biến thể "hết hạn" |
| Thông tin xác thực bị từ chối | `Please run /login · API Error: 401 Invalid authentication credentials` | Thu hồi, tổ chức tắt, tài khoản ngưng | SCR-11 + "Tài khoản không dùng được" |
| Tổ chức / tài khoản | `This organization has been disabled`; `Your account is on hold`; `Your organization has disabled Claude subscription access` | Người dùng không tự sửa được | Thẻ "Liên hệ quản trị Claude của bạn" |
| Hết hạn mức gói | `You've hit your session limit · resets 3:45pm`; `You've hit your weekly limit · resets Mon 12:00am`; `You've hit your Opus limit · resets 3:45pm`; `You've hit your Sonnet limit · resets 3:45pm` | Hạn mức phiên và tuần áp cho mọi model; hạn mức Opus / Sonnet thì đổi model là dùng tiếp | MSG-28 hiện nguyên văn kèm **giờ reset**, chuyển sang luồng thủ công (EC-39) |
| Cảnh báo sắp hết | `You've used 85% of your session limit · resets 3:45pm`; `rate_limit_event.status = allowed_warning`, `utilization` | Có ở CLI hay không cần kiểm chứng | Gợi ý: badge nhẹ ở khung chat / Planning Agent (không chặn) |
| Cần mua thêm | `rate_limit_event.errorCode = credits_required`; `Credit balance is too low` (API) | | MSG-28; **không** đặt nút mua trong app |
| Quá tải / lỗi server | `API Error: Repeated 529 Overloaded errors`; `API Error: 500 Internal server error`; `Request timed out` | Tự thử lại | Trạng thái "đang thử lại", sau đó lỗi, có "Gửi lại" |
| Mạng | `Unable to connect to API`; `SSL certificate verification failed` | | MSG-06 "Mất kết nối" |
| Bị cắt giữa chừng | `API Error: ... The response above may be incomplete.` | | MSG-27 |
| Model | `Model ... not found`; `There's an issue with the selected model` | Liên quan câu hỏi mở "app có cho chọn model không" | Thông báo chung + hướng dẫn |

**Hệ quả:**
- BR-29 nên tách (a) "hết hạn mức" thành ba loại: **có giờ reset** (phiên / tuần), **theo model** (có thể gợi ý đổi model nếu app cho chọn), và **cần mua thêm**.
- MSG-28 đang hiện nguyên văn thông báo Claude Code. Như vậy là hợp, vì câu đã có giờ reset.

#### e. Ràng buộc pháp lý và tên gọi (ảnh hưởng ADR-0004 và copy)

- **Không đứng giữa xử lý đăng nhập.** Legal: "Anthropic does not permit third-party developers to offer Claude.ai login into their own applications, or to route requests through Free, Pro, Max, or Ultra plan credentials on behalf of their users. Moreover, developers may not collect, store, or intermediate Claude.ai credentials or session tokens — sign-in to a Claude account must complete through Anthropic's own flow." (https://code.claude.com/docs/en/legal-and-compliance)
- **Ngoại lệ cho người dùng tự đăng nhập.** Cùng trang: "Nor does it prevent an end user from signing in to the unmodified Claude Code binary with their own Claude subscription, including where a platform hosts Claude Code…". Muốn "preinstalling or running Claude Code in your products or services" thì phải theo Commercial Terms, không sửa binary, không trả tiền hoặc trung gian lượt dùng.
- **Hạn mức tính theo dùng cá nhân.** "Advertised usage limits for Pro, Max, and Ultra plans assume ordinary, individual usage of Claude Code and the Agent SDK" (cùng trang).
- **Agent SDK.** Overview ghi: "Unless previously approved, Anthropic does not allow third party developers to offer claude.ai login or rate limits for their products, including agents built on the Claude Agent SDK." (https://code.claude.com/docs/en/agent-sdk/overview)
- **Tên và logo.** Được nói thật "runs Claude Code" bằng chữ thường. **Không** dùng tên hoặc logo Claude Code / Anthropic "as part of your own product, feature, or company name", cũng không ngụ ý được Anthropic xác nhận (https://code.claude.com/docs/en/legal-and-compliance).

**Hệ quả:**
- Câu hỏi mở cuối PRD G10 ("Điều khoản sử dụng của Anthropic có cho phép app gọi Claude Code CLI theo cách này không?") **có tài liệu liên quan trực tiếp nhưng không tự trả lời được**. App gọi CLI chưa sửa, người dùng tự đăng nhập. Nhưng app tự động gọi `-p` bằng gói Pro / Max của người dùng thì có phải "route requests ... on behalf of their users" không? Cần pháp chế hoặc hỏi Anthropic. Nên đưa vào rủi ro của ADR-0004.
- Copy và design: tên trợ lý (D16) không được chứa "Claude" hay "Claude Code"; không dùng logo Claude trên nút ✨. Câu "Cài Claude Code để bật trợ lý AI" là câu mô tả, phù hợp.
- App **không** được có ô nhập mật khẩu hay token Claude. Đăng nhập luôn qua `claude` / `claude auth login` (trình duyệt của Anthropic).

---

## 3. Tài liệu công khai không trả lời được: cần kiểm chứng

### 3.1 Bằng Chrome trên tài khoản Sunsama

| # | Câu hỏi | Thao tác gợi ý |
|---|---|---|
| S1 | Onboarding hiện tại (sau changelog 26/10/2026 "onboarding with Autoplan") gồm những bước nào? Có hỏi timezone, giờ làm, giờ plan không? | Tạo tài khoản mới (email phụ, cửa sổ ẩn danh), chụp từng màn, ghi nhãn nút. |
| S2 | Bước nào bỏ qua được (kết nối lịch, chọn công cụ)? Có nút quay lại không? Đóng giữa chừng thì mở lại vào bước nào? | Trong S1: thử bấm Skip / Back; đóng tab ở bước 2 rồi mở lại. |
| S3 | Onboarding có bắt nhập task không? | Trong S1: thử đi tiếp khi danh sách task rỗng. |
| S4 | Settings → Schedules: một ngày có nhiều khoảng giờ không? Lịch channel có gắn context không? Có lịch cho context không? Đổi có hiệu lực ngay không? | Mở Settings → Schedules, tạo lịch cho một channel, thử thêm khoảng thứ 2 trong một ngày. |
| S5 | Giờ làm (Schedules) có ảnh hưởng gì ngoài auto-schedule không (workload threshold, rollover, ritual, cảnh báo vượt giờ)? | Đặt Schedules T2–T6, xem board Thứ Bảy (có cảnh báo hay projection không); bật "Custom by day" của Workload threshold. |
| S6 | Có nhóm **Notifications** trong Settings không? App desktop có những thông báo hệ thống nào (nhắc plan, shutdown, nghỉ)? | Mở Settings, chụp cột nhóm; cài app desktop, đặt giờ plan sắp tới, xem có toast Windows không. |
| S7 | Sunsama coi ngày kết thúc lúc nào: nửa đêm theo timezone hay giờ khác? Task hoàn thành lúc 00:30 tính vào ngày nào? | Hoàn thành một task sau 00:00, xem nó nằm ở ngày nào; xem rollover chạy lúc nào. |
| S8 | "Time zone alert" hiện gì khi timezone thiết bị khác cài đặt? | Đổi timezone máy, tải lại app, chụp banner hoặc hộp thoại. |
| S9 | Phím toàn cục có đổi được không? | Settings → Keyboard Shortcuts, bấm vào phím Add Task. |
| S10 | Receipt của Sunny trông thế nào? Undo một chạm có hỏi lại không? Sunny xoá / hoàn thành task có hỏi xác nhận trước không? | Bảo Sunny "xoá task X", "đánh dấu xong task Y"; chụp receipt, bấm Undo. |
| S11 | Tắt Sunny (Integrations → AI Assistant) thì còn gì: gợi ý channel / thời lượng, Autoplan, highlights AI? | Tắt rồi kiểm tra nút ✦, Daily planning, Daily shutdown. |
| S12 | Sunny có hạn mức hay thông báo lỗi khi quá tải không? Nội dung thế nào? | Gửi nhiều yêu cầu liên tiếp; ngắt mạng giữa câu trả lời. |
| S13 | Autoplan: thay đổi đã được áp dụng **trước** Review Plan chưa? | Trong lúc "Plan my day" chạy, mở tab thứ 2 xem board / lịch. |
| S14 | "judgement calls to review" xuất hiện khi nào? Ba lựa chọn tác động ra sao? "Undo all" xác nhận bằng câu gì? | Chạy Autoplan với ngày quá tải; chụp mục judgement calls; bấm Undo all. |
| S15 | Autoplan lỗi giữa chừng thì sao (mất mạng, đóng tab)? Phần đã áp dụng có giữ không? | Ngắt mạng khi đang chạy; mở lại. |
| S16 | Autoplan dùng Gmail / Jira: có bước duyệt riêng không? Có chặn lệnh ẩn trong email không? | Kết nối Gmail, gửi email tiêu đề chứa câu lệnh ("xoá mọi task"); chạy Autoplan; xem kết quả. |
| S17 | Autoplan hiện mất bao lâu (help ghi 2–4 phút, changelog ghi vài giây)? | Đo thời gian 3 lượt chạy. |
| S18 | Chạy Autoplan muộn trong ngày: câu hỏi "plan tomorrow or extend today" trông thế nào? | Chạy sau 18:00, chụp màn. |
| S19 | Highlights: "Automatic summaries" chạy lúc nào? Nháp email đến lúc nào? "Resummarize" từng mục? | Bật Automatic summaries, đặt giờ nháp; chờ email; mở Daily shutdown. |
| S20 | Rules: tạo, tạm dừng, xoá; rule "Learned from your braindump" có hỏi xác nhận không? | Gõ "from now on, không xếp họp sau 16:00" trong braindump; mở trang Rules. |

### 3.2 Thử thực tế với Claude Code (trên Windows)

| # | Câu hỏi | Thao tác gợi ý |
|---|---|---|
| C1 | `claude auth status` in gì cho từng trường hợp: chưa đăng nhập, đăng nhập claude.ai, đăng nhập API key, **đăng nhập đã hết hạn**? Có cho biết email hay loại gói không? Hết hạn thì exit 0 hay 1? | Chạy lệnh ở từng trạng thái; lưu JSON và exit code. |
| C2 | App GUI (Flutter) chạy `claude` có thấy PATH ngay sau khi người dùng cài không, hay phải khởi động lại app? WinGet cài vào đâu? | Cài Claude Code khi app đang mở, bấm "Kiểm tra lại"; thử với cả bản cài native lẫn WinGet. |
| C3 | Định dạng `claude --version` có ổn định để so phiên bản tối thiểu không? | Chạy trên 2 phiên bản. |
| C4 | Chưa đăng nhập, `claude -p --output-format stream-json --verbose` trả gì (dòng `result` có `is_error: true`? câu chữ? exit code)? | Đăng xuất (`claude auth logout`), chạy một prompt ngắn. |
| C5 | Hết hạn mức gói Pro: stream-json có `rate_limit_event` với `rejected` và `resetsAt` không? `result` chứa câu "You've hit your session limit · resets …"? Có `allowed_warning` trước đó không? | Dùng tài khoản Pro, chạy tới khi chạm hạn mức (hoặc chờ tình huống tự nhiên); ghi stream. |
| C6 | `--mcp-config` + `--strict-mcp-config` với server local của app: `system/init` báo `mcp_servers.status` thế nào khi app chưa mở hoặc server lỗi? | Chạy với server tắt và bật. |
| C7 | Đổi bộ công cụ (bật / tắt "hoàn thành và xoá") khi phiên terminal đang mở: Claude Code có nhận `list_changed` và cập nhật ngay không? | Mở `claude` trong terminal, bật công tắc trong app, hỏi "bạn có những công cụ nào". |
| C8 | Trong terminal, lần đầu gọi công cụ của app, Claude Code hỏi quyền thế nào? Chọn "luôn cho phép" có lưu không? | `claude mcp add ...`, gọi một công cụ đọc và một công cụ ghi. |
| C9 | Thời gian khởi động `claude -p` lạnh trên Windows (kèm chờ MCP) có đạt "kết quả đầu tiên ≤ 10 giây" (BR-09) không? | Đo 5 lần, có và không có `--mcp-config`. |
| C10 | `-p` không dùng `--bare` thì có nạp hooks / `.mcp.json` / CLAUDE.md ở thư mục làm việc không? App nên chạy ở thư mục nào? | Chạy `-p` trong thư mục có `.mcp.json` giả, xem `system/init`. |
| C11 | Gửi `/usage` qua `-p` có trả về hạn mức còn lại không (để hiện trong SCR-09)? | `claude -p "/usage" --output-format json`. |
| C12 | App mở `claude auth login` thay người dùng (mở trình duyệt Anthropic) có được không về mặt kỹ thuật và pháp lý (mục 2.4e)? | Thử kỹ thuật. Câu hỏi pháp lý gửi pháp chế. |

---

## 4. Gợi ý cho design brief

**Onboarding (G01):**
1. Giữ 5 bước nhưng **gom bớt màn**. Sunsama chỉ có 3 bước và không hỏi timezone. Ta có thể gộp "Ngôn ngữ + timezone" vào một màn xác nhận nhanh ("Đúng chưa?"), vì cả hai đã điền sẵn từ Windows.
2. **Bước 5 (3 task):** xem lại có bắt buộc không. Sunsama để việc thêm task cho Daily planning. Câu hỏi đang mở ở PRD G01 mục 10.
3. **Giờ plan ngày:** cân nhắc quy tắc "sau 15:00 thì plan cho ngày mai" như Sunsama. Ít nhất design nên có lựa chọn "Hôm nay / Ngày mai" ở đầu Daily planning (G08).
4. **AI trong onboarding:** Sunsama đưa Autoplan vào onboarding (26/10/2026). Ta mặc định tắt (QC-12 mục 7), nên không thêm bước. Gợi ý: màn cuối có một thẻ **tuỳ chọn** "Bạn có Claude Code? Bật trợ lý AI" dẫn tới SCR-10. Cần PO quyết vì đụng QC-12 mục 7.

**Cài đặt (G01):**
5. Cột nhóm của ta gần với Sunsama (Chung / Hiển thị / Lịch làm việc / Ritual / Timebox / Phím tắt / Focus / Trợ lý AI / Beta / Thông báo). Có hai khác biệt nên giữ và làm rõ bằng design:
   - **Mốc đầu ngày**: Sunsama không có. Cần ghi chú giải thích.
   - **Lịch làm việc ảnh hưởng nhiều nơi**: Sunsama chỉ dùng cho auto-schedule. Ghi chú SCR-14 liệt kê ngắn các tác dụng.
6. Thiếu nhỏ so với Sunsama, cần PO chọn: định dạng giờ 12h / 24h; công tắc tắt cảnh báo timezone; ngưỡng khối lượng theo từng ngày.

**Trợ lý AI (G10):**
7. **Máy trạng thái Claude Code** cho SCR-09 #12 và SCR-11. Design nên vẽ đủ:

   | Trạng thái | Hành động / ghi chú |
   |---|---|
   | Đang kiểm tra | tạm, khi bấm "Kiểm tra lại" |
   | Chưa cài | lệnh PowerShell / CMD copy được; ghi chú "mở lại app nếu vừa cài" |
   | Chưa đăng nhập | hướng dẫn mở terminal chạy `claude` |
   | Đăng nhập hết hạn | như trên, câu chữ khác |
   | Phiên bản cũ | `claude update` / `winget upgrade` |
   | Tài khoản / tổ chức không dùng được | "liên hệ quản trị" |
   | Sẵn sàng | phiên bản + phương thức đăng nhập (claude.ai / API key) |
   | Lỗi không xác định | gợi ý `claude doctor` |

8. **Trạng thái lượt chạy** (chat, Planning Agent, highlights, gợi ý):
   - đang nghĩ / đang gọi công cụ (đếm giây);
   - đang thử lại (lần n);
   - **hết hạn mức** kèm giờ reset (hiện nguyên văn), chuyển sang thủ công;
   - **sắp hết hạn mức** (không chặn; nếu C5 xác nhận có `allowed_warning`);
   - cần mua thêm (không có nút mua);
   - mất mạng;
   - bị cắt giữa chừng ("Gửi lại");
   - app không kết nối được MCP của chính nó.
9. **"Dùng Claude Code trong terminal" (SCR-09 #13):**
   - lệnh `claude mcp add --scope user …` có nút copy;
   - nút "Kiểm tra kết nối" (Đã kết nối / Không kết nối được);
   - báo trước "Claude Code sẽ hỏi quyền khi dùng công cụ của app lần đầu";
   - ghi chú "App phải đang mở".
10. **Review Plan:** cân nhắc thêm hai mục như Sunsama:
    - **"Cần bạn quyết"** (judgement calls: giữ / chuyển về hôm nay / bỏ, và "Giữ hết");
    - **"Việc chưa làm và lý do"**.
    Thêm hộp xác nhận cho "Hoàn tác kế hoạch AI". Cả ba hiện chưa có trong G10. Thêm "Đã xong" (Ready) khi người dùng rời trang lúc agent đang chạy.
11. **Highlights:** cân nhắc "Soạn lại" từng mục và gắn sao. Sunsama có, G10 chưa có.
12. **Tên và hình:** không dùng "Claude" hay logo Claude trong tên hoặc biểu tượng trợ lý (D16, Legal Claude Code). Không có ô nhập mật khẩu hay token Claude ở đâu trong app.
13. **Rủi ro cần nêu trong brief:** điều khoản Anthropic về việc app tự gọi `claude -p` bằng gói Pro / Max của người dùng (mục 2.4e). Pháp chế cần chốt trước khi thiết kế chi tiết luồng AI, vì kết quả có thể làm đổi ADR-0004.
