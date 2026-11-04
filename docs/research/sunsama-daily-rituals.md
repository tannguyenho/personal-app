# Research: Sunsama làm gì trong Daily planning và Daily shutdown

> Ticket: [#5](https://github.com/tannguyenho/personal-app/issues/5). Tra cứu ngày 04/11/2026, **chỉ dùng tài liệu công khai** của Sunsama: help center, changelog / roadmap (Canny), trang tính năng, blog, video Pro Tips (bản chép lời chính thức). Không đăng nhập tài khoản Sunsama.
> Đối chiếu với [`prd-g08-daily-rituals.md`](../features/prd-g08-daily-rituals.md), [`srs-g08-daily-rituals.md`](../features/srs-g08-daily-rituals.md) và [`01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md) (QC-02, QC-04, QC-05).
>
> **Giới hạn nguồn.** Trang help "Daily Shutdown" ([link từ trang Legacy][S1]) hiện trả về trang chủ help center; `/docs/daily-shutdown` chuyển hướng sang trang Legacy Daily Planning; `/docs/evening-daily-planning` cũng trả về trang chủ (kiểm tra bằng curl ngày 04/11/2026). Wayback Machine có bản lưu (`help.sunsama.com/docs/usage-guides/daily-shutdown`, 21/05/2026) nhưng môi trường này không tải được web.archive.org → xem câu C20. Vì vậy **bước Daily shutdown dựng từ trang Daily Highlights, trang Settings, Slack integration, changelog và video Pro Tips**, không có một trang mô tả shutdown trọn vẹn.
>
> Ý nào lấy từ **câu trả lời của nhân viên Sunsama trên roadmap** hoặc **blog** thì ghi rõ, vì độ tin cậy thấp hơn help center.

Phân loại ở mục 2:

- **Giống**: cùng hành vi.
- **Khác có chủ đích**: tài liệu của ta đã ghi lý do, mã quyết định (Q / C / D) hoặc đã ghi "khác Sunsama".
- **Khác chưa chủ đích**: tài liệu của ta không nhắc tới hành vi này của Sunsama; cần PO quyết.
- **Chưa rõ**: tài liệu công khai không đủ để so; xem mục 3.

## 1. Tóm tắt

1. Daily planning thủ công (nay gọi là **Legacy**) có **5 chặng**: Reflect on yesterday → Add tasks → Check predicted workload → Finalize → Share your plan / Daily plan, kết thúc bằng "Get Started" ([S1], [S3], [S10]). App ta tách thành **6 bước** (Daily plan và Chia sẻ là hai bước); PRD ghi "lấy từ help center Sunsama" nên cần sửa lại câu này.
2. Bước "Reflect on yesterday" của Sunsama **chỉ hiện khi hôm qua chưa làm Daily shutdown** ([S1]). Đánh dấu xong ở cột "Didn't get to" thì task được tính **xong vào hôm qua** ([S26]). App ta làm ngược lại: bước này luôn hiện khi có task bị hoãn, và task được tính xong vào hôm nay (đã chốt Q2).
3. Kiểm tra khối lượng: Sunsama chỉ cộng task thuộc context **work** rồi so với ngưỡng khối lượng (có tuỳ chọn ngưỡng **riêng cho từng ngày**). Có timeline so giờ dự kiến xong với giờ shutdown, phím D / Z, mẹo khoảng 5,5 giờ ([S1], [S5], [S27]). App ta gần giống, nhưng tính trên mọi task theo sức chứa, ngưỡng chỉ áp cho task theo lịch chung, và chỉ có một ngưỡng.
4. Daily shutdown hiện tại là: **Day in review** (task đã làm, phân bổ thời gian) → **Highlights** (AI tóm tắt, "Other activities" chỉ mình thấy, "Personal reflection") → **Publish / "Done for the day"** → màn "Done for the day" có thông điệp cuối ngày ([S4], [S24], [S25], [S5]). **Không tài liệu công khai nào mô tả một bước riêng để xử lý từng task chưa xong**: task chưa xong tự rollover lúc nửa đêm ([S6]). App ta có bước "Xử lý task chưa xong" (SCR-09); bước này là đề xuất của ta.
5. Tự mở và nhắc: trong Settings > Rituals có giờ plan / giờ shutdown và hai công tắc "Automated daily planning" / "Automated daily shutdown". Theo help, cả hai ritual đều **"displays automatically"** ([S5]). Changelog 2021 mô tả shutdown là thông báo trong app, bấm vào thì mở ritual ([S11]). App ta chỉ nhắc shutdown, không tự mở (`[giả định]`).
6. Nếu giờ plan sau 15:00, Sunsama chuyển sang **evening mode** và lên kế hoạch cho ngày mai; nếu giờ plan trùng giờ shutdown thì chạy shutdown trước ([S1], [S5], [S12]). Tài liệu của ta **không nhắc tới evening mode**.
7. Làm lại: bấm P bất cứ lúc nào để vào lại ritual, chạy được nhiều lần trong ngày, có thể lọc theo context (Shift F). Ghi chú của các lần chạy được **gộp vào cùng một task ritual** ([S1], [S25]). Sunsama không có "vacation mode" và không có "bỏ qua hôm nay"; vắng mặt thì dựa vào rollover và archive ([S28]).
8. Chia sẻ: Daily plan lên Slack / Teams. Highlights có các đích: feed highlights của chính mình (không tắt được), gửi email cho chính mình, Slack / Teams, và luôn gửi email cho một người khác ([S8], [S21], [S24]). Thiết kế đích chia sẻ của ta (SCR-07) **gần như trùng**. Sunsama còn có unpublish, chia sẻ lại qua email / link / markdown, và feed nhóm có reaction ([S4], [S14], [S24]).
9. Cả hai ritual đều tạo task ritual trong channel "Default channel for rituals tasks". Muốn xem lại bản kế hoạch cũ thì mở task "Daily Planning" trên Kanban ([S1], [S5]), giống BR-11.
10. Về nhiều thiết bị, bỏ dở và làm muộn: tài liệu công khai **gần như không nói gì**. 21 câu hỏi cần kiểm chứng bằng Chrome nằm ở mục 3.

## 2. Đối chiếu từng bước

### 2.1 Daily planning

| # | Sunsama (nguồn) | App ta | Phân loại | Ghi chú |
|---|---|---|---|---|
| P0 | **Vào ritual.** Thủ công: phím P hoặc mục "Daily Planning" ở thanh trái ([S1], [S34]). Tự động: Settings > Rituals > "When do you plan your day"; "Sunsama will prompt you at that time" ([S1]). Công tắc "Automated daily planning" bật / tắt việc ritual "displays automatically at your scheduled time" ([S5]). | UC-01 bước 1, UC-04, BR-03, BR-20, SCR-12, SCR-13 #1–2 | Giống (cửa vào, phím P) / Chưa rõ (dạng hiển thị) | Sunsama không ghi giờ mặc định. Ta mặc định 09:00 `[giả định]`. Với Weekly review, Sunsama ghi rõ "an auto-prompt will appear in the top right corner" ([S9]); với daily thì không ghi → C4. |
| P1 | **Reflect on yesterday.** "If you didn't complete the Daily Shutdown yesterday, you'll first review yesterday's tasks. Mark incomplete items as done or edit past work" ([S1]). Video: màn "yesterday in review", task rollover nằm ở cột **"Didn't get to"**. Tick xong ở cột này thì task được tính xong **vào hôm qua** ("the one exception to the rule") ([S26]). Có thể đổi ngày về hôm qua bằng date picker ([S26]). | UC-01 bước 3, BR-06, SCR-02; QC-04 mục 4, QC-05 | **Khác chưa chủ đích** (điều kiện hiện bước) · **Khác có chủ đích** (ngày hoàn thành, đã chốt Q2) | (a) Bước 1 của ta luôn hiện, lấy task có số ngày bị hoãn n ≥ 1; Sunsama chỉ hiện khi hôm qua chưa shutdown. (b) Q2 chốt "xong = hôm nay" nhưng tài liệu của ta không ghi rằng Sunsama làm ngược lại → nên ghi rõ "khác Sunsama" hoặc xem lại. (c) Ta có Giữ / Dời / Backlog / Xong. Sunsama chỉ ghi "mark as done or edit past work" → thao tác đầy đủ cần xem ở C7. |
| P2 | **Add tasks to your day** ("What do you want to get done today?"). Sunsama có thể gợi ý nhập sự kiện lịch thành task. Nguồn: tích hợp (Jira, Asana, Trello…), backlog, weekly objectives, task mới ([S1], [S3]). Nhập họp thì họp được cộng vào bộ đếm khối lượng ([S23]). | UC-01 bước 5, BR-07, SCR-03 | Giống · **Khác có chủ đích** (Tích hợp, Objective ẩn ở 1.0 theo lộ trình C34, G09) | Sự kiện → task có timebox liên kết sự kiện, không trừ hai lần (B8). Cách này khớp ý "meetings increment your workload counter" ([S23]). |
| P3 | **Check predicted workload** ("What can wait?"). Cộng planned của **task thuộc context work** rồi so với ngưỡng khối lượng; vượt thì cảnh báo. Có timeline so giờ dự kiến xong với giờ shutdown. D = dời sang ngày sau, Z = backlog. Mẹo: người mới nên đặt khoảng 5,5 giờ cho ngày 9–5 có nghỉ trưa ([S1], [S3]). Ngưỡng có tuỳ chọn "Custom by day"; "Only tasks in 'work' contexts count" ([S5], [S27]). Schedules giới hạn khung giờ; task không vừa thì có chấm cảnh báo ([S27]). | UC-01 bước 7–8, BR-08, BR-09, SCR-04; G04 BR-04, BR-05, BR-22; QC-02 mục 7 | Giống (D / Z, mẹo 5,5 giờ, không chặn, cờ vượt giờ làm) · **Khác có chủ đích** (sức chứa theo hợp lịch, ngưỡng chỉ áp cho lịch chung, Q48) · **Khác chưa chủ đích** (ngưỡng theo từng ngày; loại task cá nhân khỏi phép tính) | Sunsama loại task cá nhân bằng context, ta làm bằng khung giờ channel. Hai cách cho kết quả khác nhau khi task `#Cá nhân` không đặt khung. |
| P4 | **Finalize your plan.** Sắp thứ tự, timebox vào lịch nếu muốn, chỉnh giờ shutdown và **tạo sự kiện lịch cho giờ shutdown** nếu muốn ([S1], [S3]). Giờ shutdown đặt trong Settings là "suggested shutdown time. This can be changed during daily planning" ([S5]). Trên lịch có "shutdown line" theo từng ngày ([S17]). | UC-01 bước 9–10, BR-09, SCR-05 | Giống (thứ tự, timebox, giờ kết thúc chỉ áp cho ngày D) · **Khác chưa chủ đích** (không tạo sự kiện shutdown trên lịch; không có shutdown line trên lịch) | Chưa rõ: đổi giờ ở bước này có dời giờ nhắc shutdown của hôm đó không → C12. Bên ta, SCR-05 #3 chỉ lưu `data.endOfDay`, không nối với BR-04. |
| P5 | **Share your plan / Daily plan.** Xem lại kế hoạch, ghi trở ngại có thể gặp ("note any potential obstacles"), tuỳ chỉnh cách hiện task ([S1]). Có thể sửa text, "click 'customize' to auto-generate lists", chia sẻ lên "Slack, Teams, or colleagues" ([S3]). Trên trang Slack: nút "Customize" / "Automate", "Apply", "Refresh"; text là rich text, sửa gì thì đăng đúng như vậy ([S8]). | UC-01 bước 11–14, BR-10, SCR-06, SCR-07 | Giống (Trở ngại, Tuỳ chỉnh, Làm mới, sửa tay) · **Khác chưa chủ đích** (6 bước thay vì 5: ta tách "Chia sẻ" thành bước riêng) | PRD dòng 5 ghi "Thứ tự 6 bước Daily planning lấy từ help center Sunsama", nhưng help chỉ có 5 chặng ([S1], [S3], [S10] "five Ps"). |
| P6 | **Đăng lên Slack / Teams.** "Post to Slack" là nút riêng. Đăng **không** hoàn tất ritual; vẫn phải bấm "Get Started". Đăng lại được nhiều lần ([S8]). Bài đăng hiện dưới tên người dùng ([S22]). Teams từ 07/2023 ([S21]). "Skip this step in the future" ẩn được trang này cho mọi ritual; muốn bật lại thì vào Settings > Rituals > "Daily journaling" ([S8]). | BR-14, SCR-07, PRD 4.4, BR-18 | **Khác có chủ đích**: chỉ gửi khi bấm "Bắt đầu ngày" (PRD 4.4); Slack / Teams ở bản 1.2 (G11); **không** cho ẩn bước Chia sẻ (C24) | Trang Settings hiện tại không có mục "Daily journaling" ([S5]) → C14. Email cho Daily plan: help chỉ nói Slack / Teams / "colleagues" → C13. |
| P7 | **Kết thúc.** Bấm "Get Started". "After daily planning" đưa tới Home (mặc định) / Today / **Focus on first task**; có thể đổi ngay ở bước cuối bằng cách bấm đích hiện dưới nút "Get started" ([S5], [S15], 19/10/2026). Từ 02/2026 có thể bật hiệu ứng ăn mừng khi xong planning / shutdown (Settings > Display) ([S18]). | UC-01 bước 14, SCR-13 #3 | Giống (Home / Today) · **Khác chưa chủ đích** (chưa có "Focus on first task", chưa đổi đích được ở bước cuối, chưa có hiệu ứng ăn mừng) | |
| P8 | **Làm lại / chạy nhiều lần.** "You can re-enter daily planning at any point during the day… Press P" ([S1]). Có thể chạy nhiều lần, mỗi lần lọc một context bằng Shift F ([S1], [S25]). | BR-22, SCR-06 #4 ("Lên kế hoạch lại") | Giống (vào lại được) · **Khác chưa chủ đích** (không lọc channel trong ritual; cách ghi chú của các lần chạy) | Sunsama gộp ghi chú của các lần chạy vào **cùng** task ritual ([S25], ví dụ ở shutdown). Ta "cập nhật task ghi chép cũ" (BR-11) nhưng không ghi rõ ghi đè hay nối thêm → C10. |
| P9 | **Lên kế hoạch ngày khác.** Dùng date picker ("Plan ahead") ([S1]). **Evening mode**: giờ plan sau 15:00 thì plan ngày mai. Nếu giờ plan trùng giờ shutdown thì chạy shutdown trước rồi tới planning ([S1], [S5]). Có setting "Automatically rollover tasks during evening planning": On thì tự chuyển task chưa xong sang mai; Off thì hiện prompt để chọn ([S5]). | BR-02 (D tới hôm nay + 7), BR-03 | Giống (plan ngày tương lai) · **Khác chưa chủ đích** (không có evening mode, không có setting rollover khi plan buổi tối) | Từ 11/2024 shutdown là ritual riêng kể cả với người plan buổi tối, "you will always be shutting down today before planning tomorrow" (nhân viên Sunsama trả lời trên roadmap, [S12]). |
| P10 | **Agentic Daily Planning (beta, "Autoplan").** Nhập điều quan trọng → "Plan my day" (2–4 phút) → "Review Plan": judgement calls, "Undo" / "Undo all" / "Re-plan" → màn "Daily plan" để chia sẻ → "Get started" ([S2], [S16]). | BR-24, SCR-06 #5; G10 | Giống về ý (hoàn tác toàn bộ kế hoạch AI) | Chi tiết thuộc G10, không đối chiếu ở đây. |
| P11 | **Thời lượng.** Ritual planning thường mất 10–15 phút ([S33]). | PRD mục 8 (chỉ số) | Tham khảo | |

### 2.2 Daily shutdown

| # | Sunsama (nguồn) | App ta | Phân loại | Ghi chú |
|---|---|---|---|---|
| S0 | **Vào ritual.** Phím O hoặc thanh trái ([S5], [S25]). Settings: "When do you end your day" và công tắc "Automated daily shutdown: Toggle whether the daily shutdown ritual displays automatically" ([S5]). Changelog 06/2021: tới giờ thì có "in-app notification to shut down your day", bấm vào thì mở ritual ([S11]). Changelog 01/2026 có sửa lỗi "Daily shutdown prompt still shows even when automated daily shutdown setting disabled" ([S19]) → tức là "automated" nghĩa là **hiện một prompt**. | UC-02 bước 1, UC-04 A5, BR-04, SCR-12 | Giống (phím O, công tắc tự nhắc) · **Chưa rõ / có thể khác** (ta chỉ nhắc, không tự mở `[giả định]`) | Câu hỏi mở của PRD ("Shutdown có tự mở không?") mới có câu trả lời một phần: Sunsama hiện prompt, chưa rõ có tự mở luôn flow không → C3. |
| S1 | **Day in review.** "The first step displays the tasks you worked on that day with a time breakdown. Click 'Next'…" ([S4]). Video: bước đầu là "day in review" ([S24]); ở bước highlights, panel phải có timeline task work (không private, không cá nhân) kèm planned / actual và công tắc ẩn tổng thời gian khi chia sẻ ([S4], [S24]). | UC-02 bước 3–4, BR-15, SCR-08 | Giống (danh sách đã làm, actual / planned, phân bổ) · **Khác chưa chủ đích** (Sunsama có công tắc riêng tư cho tổng thời gian khi chia sẻ; ta không có) | Banner timer đang chạy (MSG-27) là của ta; Sunsama không nhắc tới → C16. |
| S2 | **Task chưa xong.** Help center hiện tại **không mô tả** bước xử lý từng task. Task chưa xong tự rollover lúc nửa đêm ([S6]). Blog (độ tin cậy thấp hơn): "In Sunsama, incomplete tasks roll forward automatically, but you're the one who confirms whether each still deserves a spot tomorrow… During shutdown, let unfinished tasks roll to tomorrow — then immediately prune" ([S30]). Trong planning, phím D dời task sang ngày sau, Z đưa vào backlog ([S1]); tài liệu không nói hai phím này có dùng được trong shutdown không. | UC-02 bước 5–6, BR-16, SCR-09; QC-05 dòng "Shutdown 'Ngày mai'", QC-04 mục 2 | **Chưa rõ**; ta đang **đề xuất** bước này | Đây là khác biệt lớn nhất cần kiểm chứng (C2). Nếu Sunsama không có bước này thì bước SCR-09 là phần ta tự thêm. Cần ghi đúng như vậy chứ không ghi "theo Sunsama". |
| S3 | **Highlights.** Gồm: emoji; ô tóm tắt có mẫu câu hỏi tự đặt ("prompts"); danh sách highlights (một số tự chọn bằng "ranking algorithm", AI tự tóm tắt từng mục, có thể bỏ / gắn sao / ẩn tóm tắt / tóm tắt lại / sửa tiêu đề / kéo để xếp và lồng; "Add a highlight" tạo một task Sunsama mới); **"Other activities"** chỉ mình thấy, bấm "Include" để đưa vào ([S4], [S24]). Tắt AI: Settings → AI → "Automatic summaries" ([S24]). Mỗi tích hợp có công tắc cho phép đưa hoạt động vào highlights ([S24]). Ra mắt GA 14/01/2025 ([S13]). Bản trước 2025 là danh sách task đã xong đơn giản; người dùng xin trả lại bản cũ, nhân viên gợi ý dùng "copy markdown" ([S31]). | UC-02 bước 7–8, BR-17, SCR-10; G10 | **Khác chưa chủ đích** (ta chỉ có một ô rich text sinh sẵn "- {tiêu đề}"; không có Other activities, không chấm điểm, không có thao tác trên từng mục) · **Khác có chủ đích** (nháp AI qua Claude Code, D7, QC-12) | Nhãn "Nháp AI" của ta tương ứng với AI summary của Sunsama. |
| S4 | **Personal reflection.** "A manual section for reflecting on your workday, including what went well, concerns, and obstacles. You can select an emoji and optionally use custom prompt templates" ([S4]). Mẹo: ghi nhật ký trong notes của một task lặp rồi dán vào ([S29]). | Không có ô riêng; gộp vào Highlights (SCR-10) | **Khác chưa chủ đích** | Sunsama tách phần "đã làm gì" (chia sẻ được) khỏi phần "cảm thấy thế nào" (ở trang highlights, không ghi rõ phần này có được gửi đi không) → C15. |
| S5 | **Publish / "Done for the day".** "Clicking 'Done for the day' saves your highlights in Sunsama and optionally shares them via your configured destinations" ([S4]). Đích: feed highlights của chính mình (không tắt được), email bản sao cho mình, kênh Slack / Teams, luôn gửi email cho một người khác ([S24]). Đích cài trong Settings của highlights ([S4]). Nút đóng ritual ở các flow cũ là "Wrap up" / "Done" ([S8], [S25]). | UC-02 bước 9–10, UC-03, BR-14, SCR-07 | **Giống** (đích luôn bật + bản sao cho mình + email người khác) · **Khác có chủ đích** (Slack / Teams ở bản 1.2) | Chưa rõ: "Publish" và "Done for the day" là một nút hay hai → C15. |
| S6 | **Sau khi Publish.** Unpublish để sửa rồi đăng lại; chia sẻ lại qua email, link trực tiếp, copy markdown; "Daily highlights journal" ở panel trái ([S4], [S24]). Workspace nhóm: feed hằng ngày có reaction / comment ([S14]). | BR-22 ("Làm lại"), SCR-10 #3 | Giống một phần ("Làm lại") · **Khác chưa chủ đích** (copy markdown, link, nhật ký highlights) | Feed nhóm thuộc phạm vi workspace (G12) nếu sau này có. |
| S7 | **Màn "Done for the day".** Video: "you get the lovely done for the day screen" ([S25]). Thông điệp cuối ngày có ba lựa chọn: Daily encouragement (câu trích dẫn đổi mỗi ngày), No message, Custom message ([S5]). Có hiệu ứng ăn mừng khi xong shutdown (tuỳ chọn) ([S18]). | UC-02 bước 11, SCR-11, SCR-13 #6 | Giống (màn kết thúc + thông điệp) · **Khác chưa chủ đích** (không có câu trích dẫn đổi theo ngày; ô trống thì ta hiện MSG-19 chứ không phải "không có thông điệp"; không có hiệu ứng) | |
| S8 | **Chạy nhiều lần / làm lại.** Vào O nhiều lần, lọc work / personal; "notes for the flow are sort of maintained and combined" trên **cùng** task Daily Shutdown ([S25]). | BR-22, BR-11 | Giống (một task ghi chép / ngày) · **Chưa rõ** (gộp hay ghi đè) → C10 | |
| S9 | **Giờ nháp highlights.** "When do you want to receive the draft of your daily highlights?" chọn ngày và giờ để nhận **email nháp** ([S5]). Kéo "shutdown line" của một ngày thì chỉ đổi giờ nháp của ngày đó ([S17]). | BR-17, D7 | **Khác có chủ đích** (D7: theo giờ kết thúc của lịch chung, không theo giờ shutdown đã đổi) · **Khác chưa chủ đích** (không gửi email nháp) | |

### 2.3 Tình huống xuyên suốt

| Tình huống | Sunsama (nguồn) | App ta | Phân loại |
|---|---|---|---|
| Tự mở / nhắc | Có giờ và công tắc cho từng ritual. "This also determines when you receive reminders" ([S5]). Dạng prompt / modal không được mô tả rõ (S0, P0). | BR-03, BR-04, UC-04, SCR-12 | Giống về cấu hình · Chưa rõ về dạng hiển thị (C3, C4) |
| Bỏ dở giữa chừng | Không có tài liệu. | BR-05 (về `current_step`), BR-13 | Chưa rõ (C5) |
| Làm muộn / vắt qua nửa đêm | Rollover chạy lúc nửa đêm cho mọi task chưa xong ([S6]). Không có tài liệu về ritual dở dang qua nửa đêm. | BR-21 (ân hạn 2 giờ, rollover chờ shutdown), QC-01 (mốc 04:00) | **Khác có chủ đích** (mốc 04:00, QC-01; Q18) · Chưa rõ (C6) |
| Hôm qua chưa shutdown | Planning mở đầu bằng review hôm qua ([S1]). | BR-06 (luôn có bước 1) | Khác chưa chủ đích (P1) |
| Lên kế hoạch lại | P bất cứ lúc nào ([S1]); nhiều lần / ngày ([S25]); Autoplan có "Re-plan" ([S2], [S16]). | BR-22 | Giống · Chưa rõ (C10) |
| Bỏ qua một ngày / nghỉ phép | "No official vacation mode": task tự rollover, có thể dời hoặc xoá trước; tăng ngưỡng archive khi đi vắng ([S28]). Không tài liệu nào nhắc nút "skip today". "Include weekends during reviews" chỉ ảnh hưởng dữ liệu hiển thị trong reflection ([S5]). | "Bỏ qua hôm nay" (C24, QC-02 mục 4), BR-23 (theo lịch chung) | **Khác có chủ đích** (C24) · Chưa rõ: prompt có hiện vào cuối tuần không (C9) |
| Vắng nhiều ngày | Task rollover tới khi quay lại; sau N ngày liên tiếp (mặc định 4) thì vào Archive ([S6], [S7], [S28]). Task lặp không sửa gì mà trùng với instance kế tiếp thì bị xoá ([S6]). | EC-27, QC-04 mục 5 (n ≥ 4 → `LUU_TRU` `stale`), QC-06 | **Giống** (ngưỡng 4, xoá task lặp trùng) · Ta đếm theo ngày làm việc, Sunsama đếm "consecutive days" → chênh nhỏ; chưa rõ planning review ngày nào (C8) |
| Ngày quá tải | Cảnh báo, không chặn; có ngưỡng theo từng ngày; chỉ tính context work ([S1], [S5], [S27]). | BR-08, G04 BR-05 | Xem P3 |
| Việc chưa xong lúc shutdown | Không có bước được mô tả. Rollover tự động; blog gợi ý dọn ngay trong shutdown ([S6], [S30]). Rollover lên đầu hay cuối danh sách là tuỳ chọn ([S5]). | BR-16, SCR-09, QC-05 | Chưa rõ (C2) |
| Highlights / chia sẻ | Xem S3–S6, P6. | BR-14, BR-17 | Xem trên |
| Ghi chú cuối ngày | Personal reflection ([S4]); End of day message ([S5]). | SCR-10, SCR-11 | Xem S4, S7 |
| Task ghi chép ritual | "Default channel for rituals tasks" cho Daily Planning / Daily Shutdown / Weekly Planning / Weekly Review ([S5]); bản kế hoạch nằm trong task "Daily Planning" ([S1]). Từ 03/2023 có ghi chú "daily planning and daily shutdown notes" ([S35]). | BR-11, BR-27, SCR-13 #7 | **Giống**. "Chỉ tạo task khi hoàn tất" là **khác có chủ đích** (EC-26; PRD đã kiểm chứng trong app) |
| Nhiều thiết bị | Timezone dùng chung trên mọi thiết bị ([S5]). App mobile có planning / shutdown, "more polished" từ 03/2026 ([S20]). Không có tài liệu về prompt trên nhiều máy hay xung đột khi cùng làm. | BR-03 (`autoPromptedAt` nguyên tử), BR-26, UC-04 A1 | Chưa rõ (C17, C18) |
| Cài đặt bước | "Skip this step in the future" (trang chia sẻ) ([S8]). Đề xuất "chọn bước nào hiện và theo thứ tự nào" trên roadmap vẫn ở trạng thái `open` (173 vote) ([S32]). | BR-18 | Giống về ý; ta cấm ẩn bước Chia sẻ (C24) |

## 3. Tài liệu công khai không trả lời được (cần kiểm chứng bằng Chrome trên tài khoản Sunsama)

Gợi ý chung: dùng một tài khoản thử, lịch Google thật, đặt giờ ritual gần giờ hiện tại để không phải chờ, chụp màn hình từng bước và ghi đúng nhãn nút.

| Mã | Câu hỏi | Thao tác gợi ý |
|---|---|---|
| C1 | Daily shutdown hiện có những bước nào, tên bước / nút ở từng màn là gì ("Next", "Publish", "Done for the day", "Wrap up")? | Có vài task xong (có actual) và vài task chưa xong; bấm O; chụp từng màn tới màn cuối. |
| C2 | Shutdown có bước / khu vực xử lý **từng** task chưa xong không? Có các lựa chọn nào (ngày mai / chọn ngày / backlog / xoá / xong), mặc định là gì, có "áp dụng cho tất cả" không? Không xử lý thì task có tự rollover lúc 0h không? | Để 3 task chưa xong: 1 task có timebox, 1 task lặp, 1 task đã có actual. Mở O và đi hết flow. Sáng hôm sau xem task nằm ở đâu, timebox có đi theo không. |
| C3 | "Automated daily shutdown" mở thẳng flow hay chỉ hiện prompt (ở đâu trên màn hình)? Có Snooze / Dismiss / "Skip today" không? Nếu app đang đóng lúc tới giờ, mở lên sau đó thì sao? | Đặt "When do you end your day" = hiện tại + 3 phút, đợi khi app mở. Lặp lại khi app đóng rồi mở sau giờ. |
| C4 | Tương tự cho Daily planning: prompt hay tự mở flow; có snooze / dismiss không; lần đầu mở app sau giờ plan có tự mở không; đã qua giờ shutdown thì còn mở không? | Đặt "When do you plan your day" = hiện tại + 3 phút. Lặp lại với app đóng; lặp lại khi đã quá giờ shutdown. |
| C5 | Bỏ dở: thoát ở bước 3 rồi bấm P lại → quay về bước 3 hay bước 1? Task "Daily Planning" có được tạo **ngay khi mở** (PRD nói có) hay chỉ khi bấm "Get Started"? Thao tác task đã làm ở các bước có được giữ không? | Bấm P → đi tới Workload → Esc / chuyển view → xem Kanban có task "Daily Planning" chưa → bấm P lại. |
| C6 | Bắt đầu shutdown trước 0h, hoàn tất sau 0h: highlights và task ritual ghi vào ngày nào? Rollover lúc 0h có làm thay đổi danh sách đang mở không? | Đặt giờ máy hoặc làm thật lúc 23:55. |
| C7 | Planning khi hôm qua **đã** shutdown: có bỏ qua "Reflect on yesterday" không? Cột "Didn't get to" có những thao tác gì ngoài tick xong (D, Z, kéo, date picker)? Có cột nào khác (vd việc đã xong hôm qua) không? | Hai ngày liên tiếp: ngày 1 làm shutdown, ngày 2 bấm P; ngày 3 không shutdown, ngày 4 bấm P. So sánh. |
| C8 | Vắng 3 ngày làm việc: review hiển thị ngày nào (hôm qua theo lịch hay ngày làm việc cuối)? Có prompt bù cho các ngày đã qua không? | Không mở app 3 ngày (hoặc dùng tài khoản đã bỏ trống), rồi mở lại. |
| C9 | Cuối tuần / ngày không có trong Schedules: prompt planning / shutdown có hiện không? Ngày nào hiện thì phụ thuộc vào Schedules, "Include weekends" hay hiện mọi ngày? | Chờ tới Thứ Bảy, hoặc tạm bỏ ngày hôm nay khỏi Settings > Schedules. |
| C10 | Làm lại: sau "Get Started", bấm P → vào lại bước 1 hay mở bản đã chốt ở chế độ xem? Hoàn tất lần 2 thì notes của task ritual bị **ghi đè** hay **nối thêm**? Actual time của task ritual có cộng thêm không? | Hoàn tất planning, bấm P, đổi kế hoạch, hoàn tất lại; mở task "Daily Planning". Làm tương tự với O. |
| C11 | Bước Workload khi quá tải: màu, câu chữ, timeline hiển thị gì; có chặn "Next" không; task ở context personal có hiện trong danh sách không; ngưỡng theo từng ngày hiển thị thế nào? | Đặt ngưỡng 2 giờ (Custom by day), thêm 4 giờ task work và 2 giờ task personal. |
| C12 | Finalize: "create a calendar event" cho giờ shutdown có tạo sự kiện thật trên Google Calendar không? Đổi giờ shutdown ở đây có đổi giờ prompt shutdown của hôm đó không? "Shutdown line" trên lịch trông thế nào? | Đổi giờ shutdown ở Finalize thành hiện tại + 5 phút, bật tạo sự kiện; kiểm tra Google Calendar và prompt. |
| C13 | Daily plan có gửi **email** được không (cho mình / người khác), hay chỉ Slack / Teams? Bấm "Get Started" có tự gửi gì không nếu chưa bấm "Post to Slack"? | Ở bước cuối mở mọi menu chia sẻ / settings. |
| C14 | "Skip this step in the future" có ở những bước nào? Bật lại ở đâu (help Slack nói "Daily journaling", trang Settings không có mục này)? | Bấm skip ở một bước thử rồi tìm trong Settings > Rituals. |
| C15 | Highlights: "Publish" và "Done for the day" là một hay hai nút? Personal reflection có được gửi theo email / Slack không? Khi không có tích hợp và đã tắt AI thì highlights sinh sẵn gồm gì? | Tắt Settings → AI → Automatic summaries; làm shutdown; bấm Preview trước khi publish; gửi bản sao cho mình và đọc email. |
| C16 | Timer đang chạy lúc vào shutdown: Sunsama có nhắc, tự dừng hay bỏ qua? Thời gian làm ritual có thành actual của task ritual không khi đang chạy timer? | Bật timer trên một task, bấm O. |
| C17 | Nhiều thiết bị: desktop và web cùng mở lúc tới giờ → cả hai cùng hiện prompt / tự mở? Làm dở trên desktop, mở web → tiếp tục đúng bước? Hoàn tất trên máy A trong lúc máy B đang mở flow thì máy B thấy gì? | Mở app desktop và một tab web cùng tài khoản. |
| C18 | Mobile (iOS / Android): planning / shutdown có cùng bước và cùng nút như desktop không? Có thông báo push không? | Cài app mobile, bật thông báo, đặt giờ ritual gần hiện tại. |
| C19 | Evening mode: đặt giờ plan 16:00 → flow có xem lại hôm nay rồi mới plan ngày mai không? Tắt "Automatically rollover tasks during evening planning" thì prompt chọn task trông thế nào? | Settings > Rituals: giờ plan 16:00, thử cả On và Off. |
| C20 | Nội dung bản lưu help "Daily Shutdown" (Wayback 21/05/2026) mô tả những bước nào? (Đọc tài liệu, không cần tài khoản; môi trường research không truy cập được web.archive.org.) | Mở https://web.archive.org/web/20260521204525/https://help.sunsama.com/docs/usage-guides/daily-shutdown và bản 10/02/2026 của `/docs/daily-shutdown`. |
| C21 | Màn "Done for the day" hiển thị những gì (thông điệp, tóm tắt số task / thời gian, nút)? Hiệu ứng ăn mừng trông thế nào? | Bật Settings > Display > celebrations; hoàn tất shutdown. |

## 4. Gợi ý cho design brief

1. **Sửa câu nguồn trong PRD / SRS.** Bản Legacy của Sunsama có **5 chặng**, không phải 6 ([S1], [S3]). Ghi rõ việc tách "Daily plan" và "Chia sẻ" thành hai bước là lựa chọn của ta, kèm lý do (SCR-07 dùng chung cho hai ritual).
2. **Shutdown dựng theo cấu trúc Sunsama đã có tài liệu**: Day in review → Highlights → Publish → màn Done. Bước "Xử lý task chưa xong" đánh dấu "bổ sung của ta" cho tới khi kiểm chứng C2. Nên cân nhắc gộp việc xử lý task chưa xong vào màn Day in review để giữ shutdown khoảng 5 phút như blog Sunsama khuyên ([S30]).
3. **Tách "Highlights" (đã làm gì, chia sẻ được) khỏi "Suy ngẫm cá nhân"** (riêng tư, có mẫu câu hỏi). Sunsama tách hai phần này ([S4]); SCR-10 của ta đang gộp. Cho phép tuỳ chỉnh mẫu câu hỏi (Sunsama có "prompts").
4. **Quyết định rõ về bước "Xem lại hôm qua"**: (a) chỉ hiện khi hôm qua chưa shutdown như Sunsama, hay luôn hiện; (b) tick xong ở đây ghi ngày nào. Q2 đã chốt "hôm nay", nhưng người chuyển từ Sunsama sẽ quen "hôm qua" ([S26]). Nên ghi "khác Sunsama" vào BR-06.
5. **Evening mode**: ghi vào "Ngoài phạm vi" hoặc thiết kế. Hiện tài liệu ta im lặng, trong khi Sunsama có hẳn chế độ và setting rollover riêng ([S1], [S5]).
6. **Cách hiện prompt**: chọn rõ giữa banner / thông báo và tự mở. Sunsama dùng prompt (góc phải trên với weekly review, [S9]) và có công tắc riêng cho từng ritual. Shutdown của ta đang "chỉ nhắc", có thể giữ, nhưng cần ghi lý do.
7. **Chạy ritual theo channel / context**: Sunsama cho lọc bằng Shift F và chạy nhiều lần, ghi chú gộp vào cùng một task ([S25]). Brief nên có bộ lọc channel trong wizard và quy tắc nối thêm ghi chú khi "Lên kế hoạch lại" / "Làm lại".
8. **Workload**: cân nhắc ngưỡng theo từng ngày ([S5], [S27]), và cách loại task cá nhân khỏi phép tính (Sunsama dùng context; ta dùng khung channel). Nêu ví dụ cho trường hợp task `#Cá nhân` không đặt khung.
9. **Finalize**: thêm "giờ kết thúc ngày" hiển thị thành vạch trên lịch, và tuỳ chọn tạo sự kiện shutdown trên lịch ngoài ([S1], [S17]). Nếu không làm thì ghi ngoài phạm vi.
10. **Cuối flow**: thêm đích "Focus vào task đầu tiên" và cho đổi đích ngay ở bước cuối ([S5], [S15]). Thông điệp cuối ngày có ba chế độ (câu khích lệ đổi theo ngày / không có / tự viết) và hiệu ứng ăn mừng tuỳ chọn ([S5], [S18]).
11. **Chia sẻ**: giữ nguyên tắc "chỉ gửi khi bấm hoàn tất" (PRD 4.4), nhưng thêm xem trước, copy markdown và chia sẻ lại sau khi hoàn tất ([S4], [S24]). Sunsama tách "Post to Slack" khỏi "Get Started" ([S8]); UI của ta cần nói rõ bấm "Bắt đầu ngày" là sẽ gửi.
12. **"Bỏ qua hôm nay"** là phần ta thêm (Sunsama không có vacation mode, [S28]). Giữ lại, và ghi vào PRD là "khác Sunsama".

## Nguồn

Help center (help.sunsama.com), đọc ngày 04/11/2026:

- [S1]: Legacy Daily Planning
- [S2]: Daily Planning (Agentic, beta)
- [S3]: Daily Planning: the basics
- [S4]: Daily Highlights
- [S5]: Account Settings (mục Rituals, Workload threshold)
- [S6]: Task rollover: the basics
- [S7]: Archive
- [S8]: Slack Integration
- [S9]: Weekly Review
- [S34]: Keyboard Shortcuts

Trang sản phẩm và blog:

- [S10]: Trang tính năng "Daily planning and shutdown" (five Ps)
- [S30]: Blog "The Shutdown Ritual" (trang ghi ngày 30/12/2026, muộn hơn ngày tra cứu; nội dung mang tính hướng dẫn chung)
- [S33]: llms.txt của sunsama.com

Changelog và roadmap (roadmap.sunsama.com):

- [S11]: Daily shutdown (09/06/2021)
- [S12]: Roadmap "separate shutdown flow for evening daily planners" (trả lời của nhân viên Sunsama, 20/11/2024)
- [S13]: Daily Highlights GA (14/01/2025)
- [S14]: Daily Wraps beta (11/03/2024)
- [S15]: Weekly changelog 19/10/2026
- [S16]: Weekly changelog 26/10/2026
- [S17]: Weekly changelog 07/08/2026
- [S18]: Weekly changelog 13/02/2026
- [S19]: Weekly changelog 30/01/2026
- [S20]: Weekly changelog 13/03/2026
- [S21]: Weekly update 28/07/2023 (Teams)
- [S22]: Slack Integration Personalization (01/07/2022)
- [S23]: Add meetings to your task list (20/05/2020)
- [S31]: Roadmap "bring back Daily Shutdown option" (trả lời của nhân viên Sunsama, 17/01/2025)
- [S32]: Roadmap "Customize plan your day steps"
- [S35]: Weekly update 24/03/2023

Video Pro Tips (sunsama.com/pro-tips, có bản chép lời):

- [S24]: Daily highlights overview and refresher
- [S25]: Daily planning and shutdown for just work or personal tasks
- [S26]: Editing actual time on a previous day and other rollover tips
- [S27]: Protecting your hours with workload thresholds and schedules
- [S28]: How to manage your tasks ahead of vacation or OOO days
- [S29]: Use recurring task notes for accurate, quick, personalized reflections

[S1]: https://help.sunsama.com/docs/usage-guides/daily-planning/legacy
[S2]: https://help.sunsama.com/docs/usage-guides/daily-planning
[S3]: https://help.sunsama.com/docs/getting-started/basics/daily-planning-the-basics
[S4]: https://help.sunsama.com/docs/usage-guides/daily-highlights
[S5]: https://help.sunsama.com/docs/settings/user-settings
[S6]: https://help.sunsama.com/docs/getting-started/basics/task-rollover-and-recurring-tasks-the-basics
[S7]: https://help.sunsama.com/docs/usage-guides/archive
[S8]: https://help.sunsama.com/docs/integrations/slack
[S9]: https://help.sunsama.com/docs/usage-guides/weekly-objectives/weekly-review
[S10]: https://www.sunsama.com/features/daily-planning-and-shutdown
[S11]: https://roadmap.sunsama.com/changelog/daily-shutdown
[S12]: https://roadmap.sunsama.com/improvements/p/separate-shutdown-flow-for-evening-daily-planners
[S13]: https://roadmap.sunsama.com/changelog/daily-highlights
[S14]: https://roadmap.sunsama.com/changelog/beta-daily-wraps-share-your-progress-with-colleagues-and-managers
[S15]: https://roadmap.sunsama.com/changelog/weekly-product-changelog-october-19-2026
[S16]: https://roadmap.sunsama.com/changelog/weekly-product-changelog-october-26-2026
[S17]: https://roadmap.sunsama.com/changelog/weekly-product-changelog-august-7-2026
[S18]: https://roadmap.sunsama.com/changelog/weekly-product-changelog-feb-13-2026
[S19]: https://roadmap.sunsama.com/changelog/weekly-product-changelog-jan-30-2026
[S20]: https://roadmap.sunsama.com/changelog/weekly-product-changelog-march-13-2026
[S21]: https://roadmap.sunsama.com/changelog/weekly-update-july-28-2023
[S22]: https://roadmap.sunsama.com/changelog/slack-integration-personalization
[S23]: https://roadmap.sunsama.com/changelog/add-meetings-to-your-task-list
[S24]: https://www.sunsama.com/pro-tips/daily-highlights-overview-and-refresher
[S25]: https://www.sunsama.com/pro-tips/daily-planning-and-shutdown-for-just-work-or-personal-tasks
[S26]: https://www.sunsama.com/pro-tips/editing-actual-time-on-a-previous-day-and-other-rollover-tips
[S27]: https://www.sunsama.com/pro-tips/protecting-your-hours-with-workload-thresholds-and-schedules
[S28]: https://www.sunsama.com/pro-tips/how-to-manage-your-tasks-ahead-of-vacation-or-ooo-days
[S29]: https://www.sunsama.com/pro-tips/use-recurring-task-notes-for-accurate-quick-personalized-reflections
[S30]: https://sunsama.com/blog/the-shutdown-ritual
[S31]: https://roadmap.sunsama.com/improvements/p/ability-to-copy-list-of-completed-tasks-aka-bring-back-daily-shutdown-option
[S32]: https://roadmap.sunsama.com/improvements/p/customize-plan-your-day-steps-daily-planning-share-your-plan-prompts-template
[S33]: https://www.sunsama.com/llms.txt
[S34]: https://help.sunsama.com/docs/usage-guides/keyboard-driven-actions/keyboard-shortcuts
[S35]: https://roadmap.sunsama.com/changelog/weekly-update-march-24-2023
