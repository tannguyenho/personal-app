# Kiểm chứng Sunsama bằng Chrome: tổng hợp cho design brief

Ngày 04/11/2026. Kiểm chứng trên web app Sunsama bằng tài khoản dùng thử. Kết quả gốc nằm trong comment của 4 ticket:
- [lịch, timebox và focus / timer](https://github.com/tannguyenho/personal-app/issues/21)
- [task, board, backlog, rollover và task lặp](https://github.com/tannguyenho/personal-app/issues/22)
- [onboarding, cài đặt và trợ lý AI](https://github.com/tannguyenho/personal-app/issues/23)
- [Daily planning và Daily shutdown](https://github.com/tannguyenho/personal-app/issues/26)

File này **không thay** kết quả gốc. Nó chỉ gom những gì từng brief cần biết. Các mã như "#21-5" trỏ tới câu số 5 trong ticket #21.

Cách ghi:
- **Giống** = app đang làm giống Sunsama.
- **App khác (có chủ đích)** = đã có quyết định trong `docs/` hoặc QC.
- **⇒ Cần chốt** = câu hỏi đưa vào ticket brief.

---

## G02 Quản lý task

- **Hoàn thành tự tích mọi subtask (#22-C1):** giống. Bỏ hoàn thành thì subtask *không* trở lại như cũ và actual vẫn giữ. App khác có chủ đích: trong cùng ngày làm việc thì trả lại mọi tác dụng phụ (Q25).
- **Hoàn thành task ở ngày tương lai thì task về hôm nay (#22-C2):** giống với task thường. Instance lặp cũng về hôm nay và ngày gốc để trống; app giữ ngày dự định của instance (Q12), khác có chủ đích.
- **Toast và Hoàn tác (#22-C3):**
  - Chỉ thao tác xoá có toast kèm UNDO, hiện khoảng 10 giây.
  - D và Z có toast nhưng không có nút; hoàn thành không có toast.
  - Ctrl+Z là ngăn xếp chung cho D, Z, C, xoá.
  - Kéo thả **không** hoàn tác được.
  - ⇒ Cần chốt: quy ước toast và Hoàn tác của app. Gợi ý: mọi thao tác phá huỷ hoặc đổi chỗ đều có toast kèm Hoàn tác (PRD G02 đã cam kết), kéo thả cũng hoàn tác được.
- **Thùng rác giữ 7 ngày; khôi phục bằng chuột phải → Restore, task về đúng chỗ cũ, kể cả task đã xong (#22-C4):** app giữ 30 ngày (Q28) và có bảng khôi phục QC-03, khác có chủ đích. Instance lặp tương lai bị xoá **không vào** Thùng rác (#22-C20); app có ngày ngoại lệ (Q26).
- **Gợi ý AI cho channel và planned (chấm cam) chạy cả khi trợ lý AI tắt (#22 ghi nhận thêm, #23-S11):** app chỉ gợi ý khi trợ lý AI bật (Q33), khác có chủ đích.
- **Bài học về phím tắt:** gõ khi ô nhập chưa nhận focus thì kích hoạt nhầm phím tắt; phím tác động lên task *đang chọn*. ⇒ Brief cần quy định rõ: phím tắt chỉ chạy khi không có ô nhập nào đang focus (EC-25), và trạng thái "task đang chọn" phải nhìn thấy được.

## G03 Task lặp lại

- **Instance mới chép priority, planned, channel, notes, subtask (#22-C16):** giống C11 / bảng phạm vi.
- **Bộ chọn lặp (#22-C17):**
  - Có Daily, Weekdays, Weekly (every / every other / third, fourth, sixth, seventh, eighth week, **không có fifth**), Monthly on day…, Monthly on the first…, Yearly.
  - Không có "mỗi N ngày", không có ngày kết thúc. Có ô "At roughly".
  - ⇒ Cần chốt: có ngày kết thúc hoặc số lần lặp không (câu hỏi mở cũ của G03).
- **Stop repeating (#22-C19):** giữ instance hôm nay và các instance tới instance đang mở, xoá các instance sau đó. Không hỏi xác nhận, không có Hoàn tác. ⇒ Cần chốt cách dừng lặp của app và có Hoàn tác không.
- **Delete all incomplete instances (#22-C19):** xoá cả instance hôm nay, giữ instance đã xong. Toast không có nút Hoàn tác. ⇒ App nên có xác nhận hoặc Hoàn tác.
- Chưa kiểm được: instance bị lỡ, instance đã sửa riêng bị lỡ (#22-C18, C21). Câu hỏi "có miễn trừ instance `customized`" vẫn dựa vào tài liệu công khai.

## G04 Board ngày

- **6 view: Board, Calendar · One day / Three days / Weekdays / Week / Month (#22-C7).** Tab chuyển qua lại giữa Board và view lịch dùng gần nhất. ⇒ Đưa vào ticket kiến trúc điều hướng.
- **Trạng thái rỗng tối giản (#22-C5):**
  - Cột ngày: chỉ có nút "+".
  - Backlog: "No tasks."
  - Archive: "Empty."
  - Tìm kiếm: "No matches. Expecting results? Try re-wording your search query."
  - Ngày đã xong hết: không có trạng thái riêng; hôm nay có thanh tiến độ.
  - ⇒ Brief tự quyết copy rỗng theo giọng văn của design system.
- **Cảnh báo khối lượng (#22-C22):**
  - Vàng khi đạt ≥ 75% ngưỡng (6 giờ / 8 giờ), đỏ khi vượt ngưỡng.
  - Áp cho cả ngày tương lai; bộ đếm tính theo bộ lọc channel (#22-C8).
  - ⇒ Trả lời câu "có mức sắp chạm ngưỡng không": Sunsama **có**. Cần chốt con số cho app (gợi ý 75% sức chứa).
- **Ngày đã qua (#22-C23):**
  - Kéo task vào ngày đã qua thì task tự thành *đã xong*.
  - Bỏ tích ở ngày đã qua thì task về hôm nay, và cột cũ giữ "breadcrumb" (bản mờ không có ô tick).
  - ⇒ Cần chốt: app đang chặn `PAST_DATE`. Có cho "kéo vào ngày đã qua = ghi là đã làm ngày đó" và có breadcrumb không?
- **Phím D đi từ ngày của task, không bỏ qua cuối tuần (#22-C6):** app dùng ngày làm việc kế tiếp theo lịch của task (QC-02), khác có chủ đích.
- **Mặc định cài đặt (#22-C13):** rollover position Top, Priority rollover None, ngưỡng 8 giờ, Hide completed tắt, Auto-sort bật, New task position Top, Count planned as actual bật.

## G05 Lịch và timebox

- **Lịch nội bộ:** khi đã kết nối Google, timebox của Sunsama mặc định vẫn ghi vào "Sunsama Calendar" nội bộ (#21-2). Lần xếp lịch đầu tiên hiện tooltip "Pick calendar for tasks". ⇒ Cần chốt: app không có lịch nội bộ, vậy chưa chọn lịch ghi thì timebox ghi vào đâu? Gợi ý: hỏi chọn ở lần timebox đầu tiên.
- **Màn quản lý lịch (#21-3):**
  - Mỗi tài khoản một khối.
  - Bảng các cột Calendar / Import channel / Timebox channel / Enable.
  - Màn "Edit calendar" có tên, màu, mặc định cho task, mặc định cho event, channel, bật / tắt.
- **Ẩn lịch bằng nút "Calendars" thì auto-schedule không né lịch đó nữa (#21-4):** giống app (lịch hiển thị mới trừ sức chứa).
- **Phím D trên task có timebox: Sunsama gỡ timebox và xoá sự kiện Google; Ctrl+Z không khôi phục timebox (#21-5):** app khác có chủ đích, giữ giờ và dời theo (QC-05).
- **D trên timebox đã qua: để lại breadcrumb, giữ sự kiện Google (#21-6):** giống Q6.
- **Hoàn thành trước giờ bắt đầu (#21-7):**
  - Task về hôm nay, timebox và sự kiện bị xoá.
  - Toast "2 tasks auto-rescheduled" kèm UNDO / LEARN MORE / DISMISS.
  - Các task sau được dồn lên.
  - App khác: giữ timebox (B10), không dồn.
- **Hoàn thành giữa timebox: Sunsama xoá *cả* khối timebox, chỉ còn khối actual (#21-7):** app rút ngắn (B10). ⇒ Giữ B10.
- **Bỏ hoàn thành không khôi phục timebox (#21-7):** app khác (Q25).
- **Xoá task có timebox đã qua thì sự kiện Google bị xoá (#21-8):** app giữ sự kiện quá khứ (QC-05), khác có chủ đích.
- **Đổi channel thì sự kiện ở lại lịch cũ (#21-9):** giống B9.
- **Xung đột mà hết chỗ (#21-10):**
  - Task bị **gỡ khỏi lịch** nhưng toast vẫn ghi "rescheduled".
  - Ctrl+Z chỉ hoàn tác một phần, làm hai task đè nhau.
  - ⇒ Bài học cho auto-schedule 1.1: copy phải đúng với việc đã xảy ra, và Hoàn tác phải trả lại toàn bộ.
- **Màn "Overcommitted?" (#21-11):** "Schedule anyway" / "Schedule another day" / "Defer", nút Cancel, link "Adjust your schedules". Dùng làm mẫu cho auto-schedule 1.1.
- **Sửa từ lịch ngoài (#21-12):**
  - Đổi giờ: cập nhật trong khoảng 10 giây.
  - Đổi tiêu đề: tên task **không đổi** (giống Q15, app thắng).
  - Xoá sự kiện: task giữ nguyên, mất timebox (giống).
  - Đổi thành sự kiện cả ngày: card có badge ngày (app gỡ timebox, C18).
- **Họp mới đè lên timebox: không cảnh báo (#21-13):** app có cờ xung đột (BR-14), điểm hơn.
- **Sự kiện free và cả ngày không chặn (#21-14), nhưng sự kiện free được vẽ giống hệt sự kiện busy:** ⇒ Brief nên phân biệt free / tentative / declined bằng ký hiệu.
- **Lỗi mất kết nối lịch, Focus time, OOO:** chưa kiểm được (#21-1, #21-15). Brief tự thiết kế theo B9 / BR-16.

## G06 Backlog, rollover và lưu trữ

- **Phím Z mở menu bucket (#22-C9):**
  - Các bucket: Next week (1), Next month (2), Next quarter (3), Next year (4), Someday (5), Never (0).
  - "Next week" được chọn sẵn; task vào **đầu bucket**.
  - Menu chuột phải có "Move to top of backlog ⇧Z".
  - Tên bucket trên UI: "Someday in the next week or two / next month / …".
- **Toast sau khi đưa vào backlog có OPEN TASK / DISMISS (#22-C3).**
- **Folder được nhớ lại khi đưa task về backlog (#22-C10).**
- **Lưu trữ tự động (#22-C15):**
  - Bật mặc định, ngưỡng 4 ngày.
  - Dropdown "Archive inactivity period": tắt, hoặc 1–14 ngày.
  - ⇒ Trả lời câu "có cho chỉnh ngưỡng trên UI không": Sunsama **có** (1–14 ngày). Cần chốt cho app.
- **Bỏ qua, chưa kiểm được:** bucket có tự chuyển theo thời gian không (#22-C11); số ngày rollover có reset không (#22-C12, C14).

## G07 Focus và timer

- **Bật timer task khác khi đang có timer chạy: timer cũ tự dừng, không có toast (#21-17).** Lượt chạy ngắn vẫn được vẽ lên lịch. ⇒ Cần chốt: có báo người dùng "đã dừng timer task X" không. Gợi ý: có, bằng toast nhẹ.
- **Nhắc timer chạy lâu (#21-18):** sau 4 giờ, kênh Mobile. Giống app (4 giờ), nhưng app nhắc bằng thông báo Windows (D12).
- **Phím E nhập *thời lượng* và ghi đè bản ghi (#21-19).** Popover Actual có mốc nhanh 5–30 phút, 1 giờ…, phần History và link "Edit entries". Màn Actual time là bảng DATE / START / END / DURATION có "+ Add an entry". ⇒ Mẫu tốt cho màn bản ghi thời gian; app phân biệt nhập theo thời lượng và theo khoảng giờ (B11).
- **Timer chạy vài giây vẫn được lưu và vẽ lên lịch (#21-20):** app bỏ lượt dưới 10 giây (G07), khác có chủ đích.
- **Focus (#21-21):**
  - Hai tab Focus / Pomodoro; có tên task, Add subtask, Notes, ACTUAL, PLANNED, START / STOP.
  - Không chọn task thì lấy task chưa xong đầu tiên.
  - Bật timer thì tự vào Focus.
  - ⇒ Cần chốt: app có tự vào Focus khi bật timer không, có Pomodoro ở 1.0 không (README xếp Pomodoro ở 1.1).
- **Nhắc nghỉ (#21-22):** 25 / 5 phút, chỉ có trên desktop. ⇒ Cân nhắc cho app Windows.

## G08 Daily planning và Daily shutdown

- **Planning cổ điển có 5 bước (#26-C7):**
  1. "Yesterday in review"
  2. "What do you want to get done today?"
  3. "What can wait?"
  4. "Finalize your plan for today" (nút "Looks good")
  5. "Daily plan"
- **Cảnh báo khối lượng không chặn (#26-C11):** "Caution: Unrealistic workload — There's not enough time before your shutdown time for all of your tasks." kèm nút **"Defer work to tomorrow"**. Task không còn chỗ có badge ⚠ "No time available". ⇒ Nút "Defer work to tomorrow" đáng học.
- **Finalize không có giờ shutdown, không tạo sự kiện shutdown (#26-C12).**
- **Daily plan (#26-C13):** "Planned for today" và "Obstacles in my way", Share (Sunsama notes luôn bật, email bản sao tắt), Get started. "Skip this step in the future" chỉ có ở bước này (#26-C14).
- **Làm lại: notes của task ritual bị ghi đè, actual không cộng, chỉ có một task ritual (#26-C10, C5).** ⇒ Trả lời câu "nối thêm hay ghi đè": Sunsama **ghi đè**. Cần chốt cho app.
- **Shutdown là *một trang* highlights (#26-C1):**
  - Gồm vibe emoji, ô "Today was…", Highlights (AI Summary), Other activities (chỉ mình thấy).
  - Cột phải WORKED / PLANNED và TIMELINE.
  - Nút "Done for the day" = Publish (#26-C15).
- **Không có bước xử lý task chưa xong (#26-C2):** task tự rollover. ⇒ Cần chốt: app giữ SCR-09 (phần tự thêm, khác có chủ đích) hay bỏ?
- **⚠ Phần suy ngẫm "Today was…" CÓ nằm trong bản publish, và link công khai mặc định BẬT (#26-C15).** ⇒ App nên tách rõ phần riêng tư khỏi phần chia sẻ. Đây là câu "tách highlights khỏi suy ngẫm cá nhân" đã có trong brief G08.
- **Timer không dừng khi shutdown và không có cảnh báo (#26-C16):** app không tự dừng nhưng có nhắc (Q14), điểm hơn.
- **Màn "Done for the day.": "Kick back! 🏖", toast Published; không thấy confetti (#26-C21).**
- **Ritual không tự hiện prompt trên web (#26-C3, C4).** Bản Wayback của trang help Daily Shutdown không có nội dung (#26-C20).
- **Highlights (#23-S19):**
  - Onboarding riêng gồm "Generate your daily highlights" → chọn công cụ → "Draft your first highlights — After today, we'll email you a draft at 17:00, when your work day ends."
  - Khi hover có Remove / Highlight / Hide summary / Resummarize / Edit title.

## G10 Trợ lý AI

- **Sunny hoàn thành và xoá task không hỏi xác nhận, nhưng luôn có "receipt" kèm Undo (#23-S10).** Undo hoàn thành không trả task về ngày cũ. ⇒ Mẫu "receipt" đáng học. App: công tắc hoàn thành / xoá mặc định tắt (QC-12 mục 4).
- **Autoplan áp dụng *trước* rồi mới cho xem lại (#23-S13):** giống Q31 (áp dụng ngay, có Hoàn tác).
- **Thiết lập Agentic lần đầu (#23-S13):** 3 màn ("Connect your tools", "Tell me about yourself", "Theme days"). Màn Plan có ô braindump, và để trống thì bị chặn ("Tell the planning agent what matters today — a few words is enough."). Các thẻ ngữ cảnh: SHUTDOWN, WEEKLY OBJECTIVES, DAILY THEME, INTEGRATIONS, TODAY SO FAR, RULES. Lúc chạy hiện 5 bước kèm đồng hồ và nút ×.
- **Judgement calls (#23-S14):** thẻ "DIDN'T FIT" có 3 lựa chọn (giữ sang mai / làm thêm giờ / tự sắp chỗ). "Undo all" hỏi xác nhận: "Undo everything the planning agent did? This will revert N changes." ⇒ Cần chốt: app có "judgement calls" không.
- **Rules (#23-S20):** tự lưu từ braindump, không hỏi xác nhận; có công tắc tạm dừng và Delete. ⇒ Cần chốt: app có Rules không, có hỏi xác nhận khi học rule không.
- **Chạy muộn trong ngày (#23-S18):** hộp "You're out of time today · Shutdown 17:00." kèm "Plan Thursday / Plan today anyway". Không trả lời trong vài phút thì tự chọn "Plan today anyway".
- **Tốc độ (#23-S17):** 7–30 giây, dù nhãn ghi "usually 2–4 min"; bản tóm tắt viết thêm khoảng 1 phút.
- **Tắt trợ lý thì nút chat biến mất, nhưng gợi ý AI và highlights AI vẫn chạy (#23-S11):** app tắt mọi gọi AI (QC-12 mục 7), khác có chủ đích.

## G01 Tài khoản, onboarding và cài đặt

- **Onboarding (#23-S1):**
  - 7 màn có URL riêng: chào → chọn công cụ (Skip) → kết nối lịch (Skip) → giờ bắt đầu → giờ kết thúc → lên kế hoạch "đầu ngày / tối hôm trước" → "Plan today / Plan tomorrow" (gợi ý "tomorrow" khi đã muộn).
  - Sau đó là "Planning your first day" 6 bước, trong đó 2 bước tự bỏ qua.
- **Không có nút Back (#23-S2); mở lại app thì về đúng bước đang làm; bắt buộc nhập ít nhất 1 task (#23-S3).** ⇒ Trả lời câu "onboarding có bắt nhập task không": Sunsama **có**. Cần chốt cho app (gợi ý: có, như G01 hiện tại đang nghiêng).
- **Không hỏi timezone, tự lấy theo máy (#23-S1):** app hỏi timezone (khác có chủ đích). Có thể đổi thành "tự lấy theo Windows, cho sửa".
- **Task "Set up Sunsama" kèm 5 subtask hướng dẫn (#23-S1).** ⇒ Cân nhắc mẫu checklist làm quen.
- **Schedules (#23-S4):** mỗi ngày một khoảng, bước 15 phút; lịch theo channel (không theo context). Giống D1 / QC-02.
- **Ngưỡng khối lượng là cài đặt riêng, có "Custom by day" (#23-S5).**
- **Notifications (#23-S6):** nhóm Tasks (Slack / Email / Mobile), Recap, Timers, General; không có cột desktop. App có thông báo Windows (D12).
- **Phím tắt toàn cục đổi được, chỉ có trên desktop (#23-S9).** Giống D11.
- **Time zone alert mặc định bật (#23-S8).**

## G12 Thông báo (phần 1.0)

- Xem nhóm Notifications ở G01. Sunsama không có thông báo hệ thống cho web; app Windows tự thiết kế (D12).
