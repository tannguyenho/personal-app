> **Mã:** PLN-SRS-G01 · **Trạng thái:** Đã chốt mâu thuẫn — chờ duyệt · **Người viết:** Tan Ho (soạn cùng Claude) · **PRD:** prd-g01-tai-khoan.md

# UC-G01 - Tài khoản, onboarding & cài đặt trên app Windows (ứng dụng lập kế hoạch ngày)

> **Bản nháp.** Giá trị `[giả định]` cần BA / PO xác nhận. SRS này mô tả đăng ký, đăng nhập, phiên, quên mật khẩu, onboarding, khung trang Cài đặt và các nhóm Chung, Hiển thị, Lịch làm việc, Phím tắt, Hồ sơ, Tài khoản (đổi mật khẩu / email, đăng xuất mọi phiên, xuất dữ liệu, xoá tài khoản, đồng ý xử lý dữ liệu), cùng điểm vào nhóm Trợ lý AI. Bản 1.0 là app Windows (Flutter) cho một người dùng ([ADR-0005](../adr/0005-nen-tang-windows-truoc.md), Q35, Q45); phần nhiều thành viên là bản sau (BR-26, [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md)). G01 sở hữu QC-01 (ngày làm việc) và QC-02 phần lịch làm việc chung (mục 1–4) trong [`docs/01-quy-tac-dung-chung.md`](../01-quy-tac-dung-chung.md); khung giờ channel (QC-02 mục 5–9) thuộc G02. Context & channel, khung giờ channel (G02), kết nối lịch (G05), Focus (G07), Daily planning (G08), Ritual (G08 / G09), Trợ lý AI (hành vi, phát hiện Claude Code, MCP local, màn đồng ý — G10, QC-12) và Beta (G10), Tích hợp (G11), Thông báo (G12, 1.0), trial, thanh toán gói cá nhân một người dùng (G12, 1.1, Q47), Thành viên, ghế, Privacy (G12, bản sau — 1.2 trở đi) đặc tả ở SRS riêng của từng nhóm. Cập nhật theo [quyết định chốt 04/11/2026](../review/quyet-dinh-chot-2026-11-04.md), gồm vòng 5–7 (Q32–Q48, D1–D16). Mã API, CSDL tham chiếu tài liệu "Thiết kế kỹ thuật & đặc tả API — MVP 1.0"; tech stack và API của app Windows: tech chốt — `docs/tech/`.

## 1. Tổng quan

| **Mục** | **Nội dung** |
| --- | --- |
| Mục tiêu | Người dùng đăng ký và vào được ngày đầu tiên đã lên kế hoạch trong vài phút; đăng nhập an toàn; tự chỉnh cài đặt và quản lý tài khoản, dữ liệu của mình |
| Actor | Khách (chưa đăng nhập) · Người dùng đã đăng nhập · Hệ thống · Nhà cung cấp danh tính (Google, Microsoft) · Dịch vụ gửi email |
| Phạm vi | Đăng ký email / Google / Microsoft (trên app desktop qua trình duyệt hệ thống, BR-25), xác minh email, đăng nhập, phiên và token, đăng xuất, khoá tạm, quên mật khẩu, onboarding 5 bước, tooltip theo ngữ cảnh, khung trang Cài đặt, nhóm Chung / Hiển thị / Lịch làm việc / Phím tắt / Hồ sơ / Tài khoản, điểm vào nhóm Trợ lý AI (BR-24), ngày làm việc (QC-01), lịch làm việc chung (QC-02 mục 1–4), xuất dữ liệu, xoá tài khoản, rút lại / xin lại đồng ý |
| Ngoài phạm vi | 2FA TOTP (1.1), lời mời, thành viên và ghế (G12, bản sau 1.2 trở đi — BR-26), trial / thanh toán gói cá nhân một người dùng (G12, 1.1, Q47), Thông báo (G12), khung giờ channel (G02), hành vi Trợ lý AI và màn đồng ý AI (G10, QC-12), nội dung các nhóm cài đặt khác, SSO doanh nghiệp, ngày lễ |
| Nền tảng | **App Windows (Flutter)** ở 1.0, một người dùng, tài khoản và dữ liệu trên cloud (Q45, ADR-0005). Web và macOS từ 1.1, iOS / Android từ 1.2, dùng cùng đặc tả. Chi tiết kỹ thuật (lưu phiên, OAuth trên desktop, phiên bản Windows tối thiểu): tech chốt — `docs/tech/` |
| Figma | `[chưa có]` |

## 2. User Story

| **ID** | **As a** | **I want** | **So that** |
| --- | --- | --- | --- |
| US-01 | Khách | Đăng ký bằng email + mật khẩu hoặc Google / Microsoft | Bắt đầu dùng ngay |
| US-02 | Người dùng mới | Được dẫn qua 5 bước có sẵn giá trị gợi ý | App đúng giờ, đúng lịch, có task ngay ngày đầu |
| US-03 | Người dùng | Đăng nhập một lần, phiên tự gia hạn | Không phải đăng nhập lại mỗi ngày |
| US-04 | Người dùng | Đặt lại mật khẩu khi quên | Không mất tài khoản |
| US-05 | Người dùng | Đổi cài đặt và thấy tác dụng ngay | App khớp cách làm việc của tôi |
| US-06 | Người dùng | Được hỏi khi timezone máy khác cài đặt | "Hôm nay" và giờ nhắc luôn đúng |
| US-07 | Người dùng | Đổi mật khẩu, email, đăng xuất mọi thiết bị | Giữ tài khoản an toàn |
| US-08 | Người dùng | Xuất và xoá dữ liệu của mình | Kiểm soát dữ liệu cá nhân |
| US-09 | Người dùng | Chọn ngày làm việc trong tuần và giờ làm từng ngày | App không đẩy việc, không nhắc ritual vào ngày nghỉ |
| US-10 | Người dùng | Xem, rút lại đồng ý và được hỏi lại khi điều khoản đổi | Kiểm soát việc xử lý dữ liệu cá nhân |
| US-11 | Người dùng | Tìm mọi cài đặt trợ lý AI ở một nhóm trong Cài đặt | Bật / tắt trợ lý và giới hạn việc AI được làm (G10) |

## 3. Business Rules

| **Mã** | **Quy tắc** |
| --- | --- |
| BR-01 | **Định danh.** Tài khoản định danh bằng email chính (cắt khoảng trắng, không phân biệt hoa thường). Một email = một tài khoản; một tài khoản liên kết được nhiều phương thức đăng nhập (mật khẩu, Google, Microsoft). Phương thức Google / Microsoft gắn theo `provider + sub` của nhà cung cấp, không theo email: đổi email bên nhà cung cấp không làm mất liên kết, đổi email chính trong app không đổi liên kết |
| BR-02 | **Mật khẩu.** 10–128 ký tự (tối đa 128 `[giả định]`); không nằm trong danh sách mật khẩu bị lộ; băm Argon2id; không ghi log, không gửi lại qua email |
| BR-03 | **Mã xác minh email.** 6 số, hết hạn 10 phút, dùng 1 lần; nhập sai 5 lần → mã vô hiệu `[giả định]`; "Gửi lại mã" sau 60 giây, ≤ 5 lần / giờ / email `[giả định]`; mã mới làm mã cũ vô hiệu. Tài khoản `CHUA_XAC_MINH` quá 24 giờ bị xoá hẳn (không qua `CHO_XOA`). Đăng nhập Google / Microsoft có email đã xác minh trùng email của tài khoản `CHUA_XAC_MINH` → bản ghi chưa xác minh bị thay thế: huỷ mật khẩu và mã đang chờ, tạo tài khoản theo UC-02 A1 |
| BR-04 | **Chống dò email.** Đăng ký bằng email đã có và quên mật khẩu bằng email chưa có trả response, thời gian phản hồi và giao diện giống trường hợp hợp lệ. Thông tin thật chỉ gửi qua email: email đã có tài khoản nhận thư "Bạn đã có tài khoản" kèm link đăng nhập / quên mật khẩu |
| BR-05 | **Khởi tạo khi đăng ký** (một giao dịch): User; workspace cá nhân với người dùng là chủ sở hữu (G12); 2 context `work`, `personal` (G02); channel hệ thống "Chưa phân loại" (`isSystem`, không xoá được, là channel mặc định của task — G02); cài đặt mặc định (BR-12) gồm lịch làm việc mặc định (BR-22); onboarding `CHUA_BAT_DAU`. **Gói:** bản 1.0 không tạo trial, workspace dùng miễn phí không giới hạn, nhãn Beta; từ 1.1 tạo trial 14 ngày của gói cá nhân cho một người dùng, không tính ghế (G12, Q47), mỗi email chỉ được trial 1 lần; tài khoản có từ 1.0 nhận trial 14 ngày tính từ ngày phát hành 1.1 (G12). Đăng ký qua lời mời (bản sau — BR-26): không tạo workspace cá nhân, gia nhập workspace mời (G12) |
| BR-06 | **Đồng ý xử lý dữ liệu.** Tài khoản mới (mọi phương thức) phải tick đồng ý Điều khoản sử dụng và Chính sách quyền riêng tư (không tick sẵn); lưu phiên bản văn bản và thời điểm đồng ý (Nghị định 13/2023/NĐ-CP, GDPR — chờ pháp chế xác nhận). Rút lại và xin lại đồng ý theo BR-23 |
| BR-07 | **Khoá đăng nhập.** Sai mật khẩu 5 lần trong 15 phút từ cùng IP → khoá đăng nhập bằng mật khẩu 15 phút cho **cặp tài khoản + IP**; IP khác không bị ảnh hưởng. Phản hồi luôn là một thông báo chung MSG-14, không phân biệt sai mật khẩu, email không tồn tại hay đang bị khoá. Email cảnh báo gửi chủ tài khoản tối đa 1 lần / 24 giờ. Google / Microsoft và quên mật khẩu vẫn dùng được `[giả định]`. Giới hạn 10 lần gọi đăng nhập / phút / IP (429) |
| BR-08 | **Phiên.** Access token JWT 15 phút. Refresh token 30 ngày, gắn với thiết bị đã đăng nhập; trên app Windows lưu trong kho bảo mật của hệ điều hành, trên web (1.1) trong cookie httpOnly, Secure, SameSite=Lax `[giả định — cách lưu: tech chốt, docs/tech/]`; mỗi lần làm mới phát token mới, token cũ hết hiệu lực. Token cũ bị dùng lại → thu hồi cả chuỗi token của phiên đó, phát `session.revoked` |
| BR-09 | **Đặt lại mật khẩu.** Link hiệu lực 30 phút, dùng 1 lần, link mới làm link cũ vô hiệu. Đặt lại thành công → mở khoá BR-07, thu hồi mọi phiên khác (chốt 09/11/2026, B38), gửi email thông báo |
| BR-10 | **Xác nhận lại.** Đổi mật khẩu, đổi email, xoá tài khoản và chuyển quyền sở hữu workspace (G12, bản sau) cần một trong hai: nhập mật khẩu hiện tại, hoặc `reauthToken` có được khi đăng nhập lại qua Google / Microsoft đã liên kết (trên app desktop cũng qua trình duyệt hệ thống, BR-25). `reauthToken` dùng 1 lần, hiệu lực 5 phút `[giả định]`. Tài khoản chỉ có Google / Microsoft chỉ dùng được `reauthToken` |
| BR-11 | **Onboarding.** 5 bước theo thứ tự: (1) ngôn ngữ + timezone → (2) kết nối lịch → (3) công cụ công việc → (4) lịch làm việc (BR-22) + giờ plan ngày → (5) task đầu tiên. Mọi trường điền sẵn; bước 2 và bước 5 bỏ qua được, không bắt nhập task (chốt 09/11/2026, B36); lưu tiến độ sau mỗi bước; mở lại app tiếp tục bước dở. Hoàn tất → mở Daily planning hôm nay ở chế độ có hướng dẫn (G08). Chỉ hiện một lần / tài khoản |
| BR-12 | **Cài đặt.** Mỗi trường lưu ngay qua \[SettingsUpdate\] (chỉ trường đổi, kèm `version` của từng trường), áp dụng ngay, không khởi động lại app; phát `settings.changed` tới thiết bị khác ≤ 5 giây. Xung đột xử lý theo từng trường (QC-08 mục 3): bản server nhận sau thắng; thiết bị có lệnh bị từ chối (412) lấy giá trị server **của trường đó** và hiện MSG-41; các trường khác trong cùng lệnh vẫn được lưu. Mặc định và giới hạn theo PRD mục 5, lấy từ \[AppConfig\] |
| BR-13 | **Timezone.** Mặc định theo thiết bị lúc đăng ký. Mỗi lần mở app so timezone thiết bị với cài đặt; lệch → banner MSG-23, không tự đổi; chọn "Giữ" thì không hỏi lại tới khi timezone thiết bị đổi tiếp. MSG-23 là banner duy nhất cho lệch timezone trong toàn app (G04 MSG-16 bỏ). Đổi timezone có hiệu lực từ ngày làm việc kế tiếp (QC-01 mục 3); ngày dự định giữ nguyên, timebox giữ thời điểm tuyệt đối, không gắn cờ, không tự sửa (QC-01 mục 4, F5) |
| BR-14 | **Mốc đầu ngày và ngày làm việc.** Ngày làm việc và hàm `workday(t)` theo QC-01 (G01 sở hữu). Mốc đầu ngày mặc định 04:00, chỉnh trong 00:00–06:00. Đổi mốc có hiệu lực từ ngày làm việc kế tiếp, hiện MSG-24; không chạy lại rollover cho ngày đã có lượt xong (QC-01 mục 3) |
| BR-15 | **Phím tắt.** Tắt phím tắt → mọi phím một ký tự ngừng; Ctrl+K (Cmd+K trên macOS, 1.1) và Esc vẫn chạy `[giả định]`. Phím một ký tự chỉ chạy khi không focus ô nhập; gõ ≥ 4 ký tự / 1 giây ngoài ô nhập → khoá phím tắt 1 giây (EC-25). Phím toàn cục Ctrl+Shift+A (thêm task), Ctrl+Shift+Space (bật / dừng timer) trên app Windows, có từ 1.0 (D11, thay C20); web không có phím toàn cục |
| BR-16 | **Tooltip theo ngữ cảnh** hiện tối đa 1 lần / tài khoản (lưu trong cài đặt, đồng bộ mọi thiết bị); đánh dấu đã xem khi đóng hoặc khi làm hành động được gợi ý. 1.0: "Task projections" (lần đầu thấy projection, G04), "Your first keyboard shortcut" (lần đầu dùng phím tắt, G04); danh sách khác `[giả định]` |
| BR-17 | **Đổi email.** Xác nhận lại theo BR-10. Gửi mã 6 số (BR-03) tới email mới; chỉ đổi khi nhập đúng mã. Email mới đã thuộc tài khoản khác → vẫn hiện bước nhập mã, bước xác nhận báo MSG-32 (BR-04). Đổi xong, thu hồi mọi phiên khác, giữ phiên hiện tại (chốt 09/11/2026, B38); email cũ nhận thư thông báo có link "Không phải tôi", hiệu lực **72 giờ**, dùng 1 lần. Bấm link → huỷ việc đổi email (email cũ trở lại là email chính), thu hồi mọi phiên trên mọi thiết bị (phát `session.revoked`), gửi link đặt lại mật khẩu (BR-09) tới **email cũ**, ghi BR-21 (UC-07 A5) |
| BR-18 | **Đăng xuất mọi phiên.** Thu hồi mọi refresh token trừ phiên hiện tại; phát `session.revoked`; thiết bị khác về SCR-03 ≤ 1 phút `[giả định]`. **Bị đăng xuất từ xa** (`session.revoked`, refresh 401): giữ hàng đợi offline đã mã hoá, gắn `userId`, gửi lên khi đăng nhập lại đúng tài khoản; đăng nhập tài khoản khác thì hàng đợi không được gửi, không hiển thị (QC-08 mục 6). **Chủ động đăng xuất** trên thiết bị (1.0: máy Windows): còn thay đổi chưa đồng bộ → cảnh báo MSG-40; người dùng xác nhận thì xoá token, hàng đợi và dữ liệu offline của app trên thiết bị đó |
| BR-19 | **Xuất dữ liệu.** Phạm vi: dữ liệu người dùng sở hữu; thêm task được giao cho người dùng khi có giao task (bản sau — BR-26). Gói zip: JSON đầy đủ (task, subtask, notes, comment, channel, context, bản ghi thời gian, ritual, cài đặt) + CSV (task, bản ghi thời gian). Sẵn sàng ≤ 24 giờ; link tải 7 ngày, cần đăng nhập đúng tài khoản; tối đa 1 yêu cầu đang xử lý. Dùng được khi workspace chỉ đọc (1.1, QC-09) |
| BR-20 | **Xoá tài khoản.** Điều kiện: không có yêu cầu xuất `DANG_XU_LY` (MSG-44). **Theo vai trò:** (c) `OWNER` của workspace chỉ có mình (mọi tài khoản khi chưa có tính năng nhiều thành viên, BR-26) → xoá workspace cùng lúc; từ 1.1 huỷ gói ngay (G12 BR-09; hoàn tiền theo G12). **Bản sau — workspace nhiều người (BR-26):** (a) không phải `OWNER` → trong cùng thao tác, rời workspace theo G12 BR-13 trước (task được giao chưa xong trả về người giao, giảm ghế), **không** huỷ gói của nhóm; (b) `OWNER` của workspace còn thành viên khác → chặn, phải chuyển quyền sở hữu hoặc xoá workspace trước (G12 BR-14, EC-36). Ngay lập tức: tài khoản `CHO_XOA`, đăng xuất mọi phiên, thu hồi token lịch (G05) và tích hợp (G11), gửi email xác nhận. Xoá vĩnh viễn mọi dữ liệu ≤ 30 ngày, trừ ngoại lệ lưu giữ: hoá đơn và chứng từ giữ 10 năm (G12 BR-10); nhật ký bảo mật giữ 1 năm, ẩn danh (BR-21) |
| BR-21 | **Nhật ký bảo mật.** Ghi đăng ký, đăng nhập (thành công / thất bại), khoá, đặt lại / đổi mật khẩu, đổi email, "Không phải tôi", đăng xuất mọi phiên, xuất, xoá, đồng ý / rút lại đồng ý: thời điểm, IP, user agent, kết quả. Không ghi mật khẩu, mã, token. Giữ 1 năm; khi tài khoản bị xoá, bản ghi được ẩn danh (bỏ email, tên, gắn mã ngẫu nhiên) thay vì xoá |
| BR-22 | **Lịch làm việc chung** (QC-02 mục 1–4, G01 sở hữu). Các ngày làm việc trong tuần, mỗi ngày có giờ bắt đầu < giờ kết thúc. Mặc định Thứ Hai–Thứ Sáu, 09:00–17:00 `[giả định giờ]`; thêm được Thứ Bảy hoặc ngày bất kỳ. Cần ≥ 1 ngày làm việc `[giả định]` (MSG-46). Lưu như mọi cài đặt (BR-12) trong trường `workSchedule`; đổi có hiệu lực từ ngày làm việc kế tiếp `[giả định]`. Ngày làm việc kế tiếp, nhóm đọc và cách dùng theo QC-02 mục 2–3; G09 gửi recap tuần tại mốc đầu ngày của ngày sau ngày làm việc cuối cùng trong tuần. Ngày lễ chưa hỗ trợ ở 1.0. **Khung giờ channel** do G02 sở hữu (QC-02 mục 5–9), G01 không đặc tả lại: lịch làm việc của task = khung giờ channel của task nếu có, ngược lại lịch chung (QC-02 mục 6); sức chứa ngày (G04) = hợp lịch chung và các khung channel (QC-02 mục 7); ritual (G08) và cột ngày G09 theo lịch chung (QC-02 mục 8) |
| BR-23 | **Rút lại và xin lại đồng ý** (Nghị định 13/2023/NĐ-CP). (a) Văn bản Điều khoản / Chính sách có phiên bản mới đánh dấu "cần đồng ý lại" → lần mở app kế tiếp hiện **SCR-15** (MSG-47); chưa đồng ý thì API trả `CONSENT_REQUIRED` cho mọi thao tác trừ đọc cài đặt Tài khoản, xuất dữ liệu, xoá tài khoản, đăng xuất `[giả định]`. (b) "Rút lại đồng ý xử lý dữ liệu" ở SCR-11 → MSG-48 → xác nhận lại (BR-10) → chạy UC-09 (xoá tài khoản) `[giả định — chờ pháp chế]`. (c) **Đồng ý dùng Trợ lý AI** là đồng ý riêng do G10 sở hữu: màn gọn khi bật trợ lý lần đầu, nói rõ dữ liệu nào được đưa cho Claude Code, lưu thời điểm đồng ý (QC-12 mục 7); xem và rút lại ở Cài đặt → Trợ lý AI (SCR-16, G10). Không nằm trên SCR-01 / SCR-15 và không đổi trạng thái đồng ý xử lý dữ liệu của tài khoản. (d) Đồng ý nhận email Product updates (G12) là đồng ý riêng, rút lại ở Cài đặt → Thông báo. Mọi lần đồng ý / rút lại lưu phiên bản, thời điểm (BR-06) và ghi BR-21 |
| BR-24 | **Nhóm cài đặt Trợ lý AI** (điểm vào; Q46, QC-12, ADR-0004). Khung trang Cài đặt có nhóm "Trợ lý AI" (SCR-16); G01 chỉ đặt vị trí và lối vào, **G10 sở hữu** nội dung, giá trị mặc định, hành vi, API và thông báo. Nhóm gồm: (1) bật / tắt trợ lý, mặc định tắt; tắt thì MCP server local ngừng nhận kết nối (QC-12 mục 7); (2) trạng thái phát hiện Claude Code CLI (đã cài, đã đăng nhập, phiên bản hỗ trợ); không có → ẩn tính năng AI, hiện hướng dẫn "Cài Claude Code để bật trợ lý AI" (QC-12 mục 2); (3) (bỏ — F4: không còn công tắc "Cho phép AI hoàn thành và xoá task"; khi trợ lý bật, AI luôn được hoàn thành và xoá task, QC-12 mục 4); (4) công tắc cho AI đọc dữ liệu tích hợp, mặc định tắt; bật thì các thay đổi sau lần đầu đọc dữ liệu tích hợp trong phiên AI đó chờ duyệt (QC-12 mục 6, D8); (5) thời điểm đồng ý và "Rút lại đồng ý dùng AI" (BR-23 c). Bật trợ lý lần đầu → màn đồng ý gọn của G10 (QC-12 mục 7). Không hiện hạn mức AI: AI không có hạn mức theo gói (QC-10, QC-12 mục 8) |
| BR-25 | **Đăng nhập Google / Microsoft trên app desktop** (Q45). App mở **trình duyệt hệ thống** tới trang của nhà cung cấp; không đăng nhập trong cửa sổ nhúng của app. Trong lúc chờ, app hiện trạng thái chờ (MSG-49) có nút "Huỷ". Nhà cung cấp trả kết quả về app → app tự đưa cửa sổ lên trước và tiếp tục UC-02 bước 4. Hết thời gian chờ `[giả định: 5 phút]` hoặc không mở được trình duyệt → về SCR-03 với MSG-50. Áp dụng cả cho xác nhận lại (`purpose=reauth`, BR-10) và kết nối lịch ở onboarding (G05). Cách trả kết quả về app (loopback / deep link), PKCE, lưu token: tech chốt — `docs/tech/` |
| BR-26 | **Phạm vi một người dùng** (Q35, Q37). Bản 1 chỉ cho một người dùng, mỗi tài khoản một workspace cá nhân. Các phần nhiều thành viên trong SRS này giữ nguyên đặc tả nhưng **chưa làm**, phát hành ở bản sau (1.2 trở đi; bản 1.1 vẫn chỉ một người dùng, Q47) — xem [`docs/02-tinh-nang-ban-sau.md`](../02-tinh-nang-ban-sau.md): đăng ký / đăng nhập qua lời mời (BR-05, UC-01 A4, UC-02 A3, UC-03 A4), task được giao trong bản xuất (BR-19), xoá tài khoản khi ở workspace nhiều người (BR-20 a, b; UC-09 A3, E1; MSG-37, MSG-45), chuyển quyền sở hữu (BR-10). Trước khi phát hành các phần này, API tương ứng không nhận `inviteToken` |

## 4. Trạng thái

### 4.1. Trạng thái tài khoản

| **Trạng thái** | **Điều kiện** | **Hiển thị** |
| --- | --- | --- |
| `CHUA_XAC_MINH` | Đăng ký bằng email, chưa nhập đúng mã | Đăng nhập → mở SCR-02 |
| `HOAT_DONG` | Đã xác minh (hoặc tạo qua Google / Microsoft) | Dùng bình thường |
| `TAM_KHOA` | (Bỏ khỏi trạng thái tài khoản — khoá đăng nhập theo cặp tài khoản + IP, là cờ riêng, không đổi trạng thái tài khoản; xem BR-07) | SCR-03 hiện MSG-14 |
| `CHO_XOA` | Đã xác nhận xoá, chưa quá 30 ngày | Không đăng nhập được; dữ liệu ẩn |
| `DA_XOA` | Đã xoá vĩnh viễn | Không còn bản ghi (trừ ngoại lệ lưu giữ BR-20); email dùng đăng ký lại được |

Chuyển trạng thái: `CHUA_XAC_MINH` → `HOAT_DONG` (UC-01) · `CHUA_XAC_MINH` → `DA_XOA` (job sau 24 giờ, hoặc bị thay thế khi đăng nhập Google / Microsoft có email đã xác minh — BR-03, UC-02 A4) · `HOAT_DONG` → `CHO_XOA` (UC-09, UC-11) → `DA_XOA` (job xoá vĩnh viễn). Khoá đăng nhập BR-07 hết sau 15 phút hoặc khi đặt lại mật khẩu (UC-04).

### 4.2. Trạng thái onboarding và yêu cầu xuất

Onboarding: `CHUA_BAT_DAU` → `DANG_LAM` (lưu bước 1–5) → `HOAN_TAT`. Yêu cầu xuất dữ liệu: `DANG_XU_LY` → `SAN_SANG` (có link) → `HET_HAN` (sau 7 ngày); job lỗi thì tự thử lại 3 lần; vẫn lỗi → `LOI`, báo người dùng MSG-51 kèm nút "Tạo bản xuất mới" (MSG-53, UC-08 E2; chốt 09/11/2026, B40). Khi có yêu cầu `DANG_XU_LY`, tài khoản không xoá được (BR-20).

Đồng ý xử lý dữ liệu (BR-23): `DA_DONG_Y` (phiên bản hiện hành) → `CAN_DONG_Y_LAI` (có phiên bản mới cần đồng ý lại) → `DA_DONG_Y` (UC-11). Rút lại đồng ý → tài khoản `CHO_XOA` `[giả định — chờ pháp chế]`.

## 5. Use Case

### UC-01 Đăng ký bằng email và mật khẩu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Khách chưa đăng nhập |
| Hậu điều kiện thành công | Tài khoản `HOAT_DONG`, dữ liệu khởi tạo theo BR-05; người dùng đã đăng nhập, ở SCR-05 bước 1 |
| Hậu điều kiện thất bại | Không có tài khoản `HOAT_DONG`; nội dung đã nhập còn trên form |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | Mở **SCR-01**, nhập email, mật khẩu, tick đồng ý, bấm "Tạo tài khoản" |
| 2 | Hệ thống | Kiểm tra định dạng email, độ dài mật khẩu, ô đồng ý ở client; gọi \[AuthSignup\] |
| 3 | Hệ thống | Server kiểm tra BR-02 (danh sách bị lộ); tạo bản ghi `CHUA_XAC_MINH`, lưu đồng ý (BR-06), gửi mã (BR-03); mở **SCR-02** với MSG-05 |
| 4 | Khách | Nhập hoặc dán mã 6 số (đủ 6 số tự gửi) |
| 5 | Hệ thống | Gọi \[AuthVerifyEmail\]; đúng → khởi tạo theo BR-05, cấp token (BR-08), mở **SCR-05** bước 1 |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Email đã có tài khoản | Bước 3 trả response như thường, mở SCR-02 (BR-04); email nhận thư "Bạn đã có tài khoản" |
| A2 | Bấm "Gửi lại mã" (bật sau 60 giây) | Gọi \[AuthResendCode\]; mã cũ vô hiệu; đếm ngược 60 giây lại |
| A3 | Bấm "Đổi email" trên SCR-02 | Về SCR-01, giữ email đã nhập để sửa |
| A4 | Mở từ link mời workspace (bản sau — BR-26) | Email điền sẵn và khoá; bước 5 gia nhập workspace mời thay vì tạo workspace mới (BR-05, G12) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Email sai định dạng | MSG-01 dưới ô, không gửi |
| E2 | Mật khẩu ngoài 10–128 ký tự / nằm trong danh sách bị lộ | MSG-02 / MSG-03, không gửi mã |
| E3 | Chưa tick đồng ý | MSG-04, nút "Tạo tài khoản" vẫn bấm được để hiện lỗi |
| E4 | Mã sai | MSG-06 kèm số lần còn lại |
| E5 | Mã hết hạn / sai quá 5 lần | MSG-07, ô mã bị khoá tới khi gửi mã mới |
| E6 | Gửi lại quá 5 lần / giờ | MSG-08 |
| E7 | Quá giới hạn gọi (429) / 5xx / mất mạng | MSG-09 / MSG-10, giữ nội dung form |

### UC-02 Đăng ký / đăng nhập bằng Google hoặc Microsoft

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Khách chưa đăng nhập |
| Hậu điều kiện thành công | Tài khoản mới (BR-05) hoặc tài khoản có sẵn được đăng nhập; phương thức Google / Microsoft được liên kết |
| Hậu điều kiện thất bại | Không tạo, không đăng nhập; khách ở SCR-03 kèm thông báo |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | Bấm "Tiếp tục với Google" / "Tiếp tục với Microsoft" trên SCR-01 hoặc SCR-03 |
| 2 | Hệ thống | Gọi \[AuthOAuthStart\]; mở **trình duyệt hệ thống** tới trang nhà cung cấp kèm `state` và PKCE (BR-25); app hiện MSG-49 có nút "Huỷ" |
| 3 | Khách | Chọn tài khoản, đồng ý trên trang nhà cung cấp trong trình duyệt |
| 4 | Hệ thống | Nhà cung cấp trả kết quả về app; app đưa cửa sổ lên trước; \[AuthOAuthCallback\] kiểm tra `state`, lấy `sub` và email đã xác minh |
| 5 | Hệ thống | `provider + sub` đã liên kết với một tài khoản (BR-01) → cấp token (BR-08), mở Home (G04 SCR-01) hoặc bước onboarding dở |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | `provider + sub` chưa liên kết, email chưa có tài khoản | Hiện **SCR-18** (SCR-01 rút gọn chỉ có ô đồng ý, BR-06) → bấm "Tạo tài khoản" → khởi tạo BR-05 → SCR-05 bước 1 |
| A2 | `provider + sub` chưa liên kết, email trùng tài khoản `HOAT_DONG` có mật khẩu | Hỏi mật khẩu tài khoản hiện có (MSG-13); đúng → liên kết `provider + sub` rồi đăng nhập. Không tự liên kết theo email |
| A3 | Từ link mời workspace (bản sau — BR-26) | Sau bước 5 gia nhập workspace mời (G12 UC-04); tài khoản đã có workspace → G12 BR-25 |
| A4 | `provider + sub` chưa liên kết, email trùng tài khoản `CHUA_XAC_MINH` | Thay thế bản ghi chưa xác minh (BR-03): huỷ mật khẩu, mã đang chờ, rồi tiếp tục như A1; ghi BR-21 |
| A5 | Đã liên kết, email bên nhà cung cấp khác email chính trong app | Đăng nhập bình thường theo `provider + sub`; không đổi email chính |
| A6 | `purpose=reauth` (xác nhận lại, BR-10) | Cũng qua trình duyệt hệ thống (BR-25). Không cấp phiên mới; `provider + sub` phải khớp tài khoản đang đăng nhập → trả `reauthToken` về màn đang mở; không khớp → MSG-11 |
| A7 | Bấm "Huỷ" trên màn chờ MSG-49 | Bỏ `state` đang chờ; về màn trước (SCR-01 / SCR-03), không hiện lỗi; kết quả trình duyệt trả về sau đó bị bỏ qua |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Khách huỷ trên trang nhà cung cấp / `state` sai hoặc hết hạn | Về SCR-03, MSG-11 |
| E2 | Nhà cung cấp không trả email đã xác minh | Về SCR-03, MSG-12 |
| E3 | Nhà cung cấp lỗi / timeout | Về SCR-03, MSG-11 |
| E4 | A2 nhập sai mật khẩu | MSG-14; tính vào BR-07 |
| E5 | Không mở được trình duyệt hệ thống / quá thời gian chờ (BR-25) | Về SCR-03, MSG-50; đường email + mật khẩu vẫn dùng được |

### UC-03 Đăng nhập, duy trì phiên và đăng xuất

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Tài khoản `HOAT_DONG` (đang bị khoá BR-07 thì chỉ OAuth / quên mật khẩu) |
| Hậu điều kiện thành công | Có phiên hợp lệ (BR-08); mở Home hoặc bước onboarding dở |
| Hậu điều kiện thất bại | Không có phiên; khách ở SCR-03 |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | Mở **SCR-03**, nhập email, mật khẩu, bấm "Đăng nhập" |
| 2 | Hệ thống | Gọi \[AuthLogin\]; kiểm tra BR-07 |
| 3 | Hệ thống | Đúng → cấp access token + refresh token, lưu trên thiết bị theo BR-08; onboarding chưa `HOAN_TAT` → SCR-05 bước dở, ngược lại → Home (G04 SCR-01) |
| 4 | Hệ thống | Trước khi access token hết hạn 1 phút `[giả định]` gọi \[AuthRefresh\] |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Đăng xuất | Menu tài khoản (**SCR-17**) → "Đăng xuất"; còn thay đổi chưa đồng bộ → MSG-40 ("Huỷ" giữ nguyên phiên); xác nhận → \[AuthLogout\]; xoá token, hàng đợi và dữ liệu offline của app trên thiết bị (BR-18); về SCR-03 |
| A2 | Tài khoản `CHUA_XAC_MINH` | Gửi mã mới (BR-03), mở SCR-02 với MSG-05 |
| A3 | Tài khoản bật 2FA (1.1) | Sau mật khẩu đúng hỏi mã TOTP 6 số |
| A4 | Mở từ link mời workspace (bản sau — BR-26) | Sau bước 3 gia nhập workspace mời (G12 UC-04); đã có workspace → theo G12 BR-25 (chuyển task cá nhân hoặc chặn), hết ghế → G12 BR-27 |
| A5 | Nhận `session.revoked` | Xoá token; **giữ** hàng đợi offline đã mã hoá, gắn `userId` (BR-18); về SCR-03 với MSG-16 |
| A6 | Đăng nhập lại sau A5 / E4 | Đúng tài khoản có hàng đợi → gửi hàng đợi lên theo QC-08 (lệnh sửa cụm vị trí trên phiên bản cũ bị từ chối như QC-08 mục 2); khác tài khoản → hàng đợi giữ nguyên, không gửi, không hiển thị |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Sai email hoặc mật khẩu | MSG-14, không nói sai trường nào |
| E2 | Sai lần thứ 5 trong 15 phút từ cùng IP / cặp tài khoản + IP đang bị khoá | Khoá cặp tài khoản + IP (BR-07); email cảnh báo nếu 24 giờ qua chưa gửi; vẫn hiện MSG-14 (thông báo chung) |
| E3 | 429 theo IP | MSG-09 |
| E4 | \[AuthRefresh\] trả 401 (hết hạn / dùng lại token) | Thu hồi chuỗi (BR-08), về SCR-03 với MSG-16; thay đổi chưa đồng bộ giữ trong hàng đợi tới khi đăng nhập lại đúng tài khoản |
| E5 | 5xx / mất mạng | MSG-10 |

### UC-04 Quên và đặt lại mật khẩu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Khách chưa đăng nhập |
| Hậu điều kiện thành công | Mật khẩu mới có hiệu lực (BR-09); khách quay lại app và đăng nhập bằng mật khẩu mới (UC-03) |
| Hậu điều kiện thất bại | Mật khẩu không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Khách | SCR-03 → "Quên mật khẩu" → **SCR-04** phần 1, nhập email, bấm "Gửi link" |
| 2 | Hệ thống | Gọi \[AuthPasswordForgot\]; luôn hiện MSG-17 (BR-04); email có tài khoản nhận link 30 phút |
| 3 | Khách | Mở link trong email → **SCR-04** phần 2 trên **trang web tối giản** (`wakeup.tannguyenho.tech`, [tech mục 1](../tech/01-quyet-dinh-tech-stack-va-api.md)), nhập mật khẩu mới |
| 4 | Hệ thống | Gọi \[AuthPasswordReset\]; áp BR-02, BR-09; trang web hiện MSG-19. Trang web không cấp token cho app: khách mở app và đăng nhập ở **SCR-03** bằng mật khẩu mới (UC-03) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Tài khoản chỉ có Google / Microsoft | Link vẫn gửi; đặt mật khẩu xong thêm phương thức mật khẩu vào tài khoản |
| A2 | Tài khoản đang bị khoá đăng nhập (BR-07) | Đặt lại thành công gỡ mọi khoá của tài khoản trên mọi IP |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Link hết hạn / đã dùng / bị link mới thay | MSG-18 có nút "Gửi link mới" → về màn nhập email (SCR-04 phần 1), điền sẵn email; bấm "Gửi link" chạy lại bước 2 (chốt 09/11/2026, B39) |
| E2 | Mật khẩu mới không đạt BR-02 | MSG-02 / MSG-03 |
| E3 | 429 / 5xx | MSG-09 / MSG-10 |

### UC-05 Onboarding lần đầu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập; onboarding `CHUA_BAT_DAU` hoặc `DANG_LAM` |
| Hậu điều kiện thành công | Onboarding `HOAN_TAT`; cài đặt ngôn ngữ, timezone, lịch làm việc, giờ plan đã lưu; task nhập ở bước 5 (nếu có) nằm ở hôm nay; Daily planning (G08) đang mở |
| Hậu điều kiện thất bại | Onboarding giữ ở bước đang làm; dữ liệu bước trước đã lưu |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Mở **SCR-05** bước 1: ngôn ngữ (theo ngôn ngữ của Windows), timezone (theo thiết bị) |
| 2 | Người dùng | Giữ hoặc sửa, bấm "Tiếp"; hệ thống gọi \[SettingsUpdate\] (giá trị + `onboardingStep`) |
| 3 | Người dùng | Bước 2: chọn Google Calendar / Outlook → luồng kết nối của G05 (qua trình duyệt hệ thống như BR-25) → quay lại bước 2 có icon dấu tích kèm "Đã kết nối" → "Tiếp" |
| 4 | Người dùng | Bước 3: chọn công cụ đang dùng (chọn nhiều) → "Tiếp"; lưu `workTools` để gợi ý tích hợp khi phát hành (G11) |
| 5 | Người dùng | Bước 4: chỉnh lịch làm việc (BR-22; mặc định Thứ Hai–Thứ Sáu, 09:00–17:00) và giờ plan ngày (mặc định 09:00) → "Tiếp" |
| 6 | Người dùng | Bước 5: nhập 1–3 task cho hôm nay (thời lượng, channel gợi ý theo G02; không có gợi ý → channel "Chưa phân loại") → "Bắt đầu ngày đầu tiên". Không bắt nhập task: có nút "Bỏ qua" (A6) |
| 7 | Hệ thống | Tạo task (G02); gọi \[OnboardingComplete\]; mở Daily planning hôm nay ở chế độ có hướng dẫn (G08) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Bỏ qua" ở bước 2 | Sang bước 3; Cài đặt → Lịch (G05) có lời nhắc kết nối |
| A2 | Bấm ← | Về bước trước, giữ giá trị đã nhập |
| A3 | Đóng app / mất phiên giữa chừng | Lần mở sau vào đúng bước `onboardingStep` |
| A4 | Bước 3 chọn "Không dùng công cụ nào" | Bỏ chọn các ô khác, sang bước 4 |
| A5 | Timezone bước 1 khác timezone thiết bị khi mở lại | Không hiện banner MSG-23 trong lúc onboarding |
| A6 | Bấm "Bỏ qua" ở bước 5 | Không tạo task; gọi \[OnboardingComplete\]; mở Daily planning hôm nay ở chế độ có hướng dẫn (G08) như bước 7 (chốt 09/11/2026, B36) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Kết nối lịch lỗi / bị từ chối quyền | Quay lại bước 2, hiện thông báo của G05 theo G05 UC-01 E1–E5: G05 MSG-03 (huỷ), MSG-02 (thiếu quyền), MSG-36 (lỗi kết nối OAuth); G01 không đặt MSG riêng (C38); vẫn "Tiếp" hoặc "Bỏ qua" được |
| E2 | Giờ kết thúc ≤ giờ bắt đầu / không chọn ngày làm việc nào | MSG-20 / MSG-46, chặn "Tiếp" |
| E3 | Bước 5 bấm "Bắt đầu ngày đầu tiên" khi chưa ô nào có task | Nút luôn bấm được; bấm thì hiện MSG-21 dưới ô, không gửi, giống UC-01 E3 (chốt 09/11/2026, B41). Muốn bắt đầu không có task thì bấm "Bỏ qua" (A6) |
| E4 | Lưu bước / tạo task lỗi | MSG-10, giữ ở bước hiện tại, giữ nội dung |

### UC-06 Xem và đổi cài đặt

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | Giá trị mới lưu, áp dụng ngay, đồng bộ thiết bị khác (BR-12) |
| Hậu điều kiện thất bại | Trường giữ giá trị cũ, có thông báo |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Menu tài khoản (**SCR-17**) → "Cài đặt" (hoặc command menu "Mở cài đặt") |
| 2 | Hệ thống | Gọi \[SettingsGet\]; mở **SCR-06**, chọn sẵn nhóm Chung (**SCR-07**) |
| 3 | Người dùng | Chọn nhóm (Chung / Hiển thị **SCR-08** / Phím tắt **SCR-09**; Lịch làm việc theo UC-10; Trợ lý AI theo A7), đổi một giá trị |
| 4 | Hệ thống | Kiểm tra giới hạn; gọi \[SettingsUpdate\] chỉ với trường đổi; áp dụng ngay; MSG-22 cạnh trường |
| 5 | Hệ thống | Phát `settings.changed`; thiết bị khác cập nhật ≤ 5 giây |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Chọn nhóm do nhóm khác sở hữu | Mở trang con của nhóm đó (G02, G05, G07, G08, G10, G11, G12) |
| A2 | Mở app, timezone thiết bị khác cài đặt | Banner MSG-23: "Đổi sang…" → \[SettingsUpdate\], hiện MSG-24 (có hiệu lực từ ngày làm việc kế tiếp); "Giữ…" → lưu timezone thiết bị đã bỏ qua (BR-13) |
| A3 | Đổi mốc đầu ngày / timezone ở SCR-07 | Lưu; hiện MSG-24 (BR-13, BR-14) |
| A4 | Đổi ngôn ngữ | Tải gói chuỗi mới, đổi giao diện không khởi động lại app |
| A5 | Thiết bị khác vừa đổi cùng trường | Nhận giá trị mới qua realtime; trường đang mở dropdown không bị đóng |
| A6 | Lệnh đổi của thiết bị này tới server sau và bị từ chối do trường đã đổi ở thiết bị khác (412, BR-12) | Trường đó lấy giá trị server, hiện MSG-41; các trường khác trong lệnh vẫn lưu |
| A7 | Chọn nhóm "Trợ lý AI" | Mở **SCR-16**; nội dung, đồng ý và hành vi theo G10 (BR-24, QC-12). G01 không xử lý giá trị của nhóm này |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Ngưỡng khối lượng ngoài 1–24 giờ | MSG-25, không gửi |
| E2 | \[SettingsUpdate\] lỗi | Trả trường về giá trị cũ, MSG-26 |
| E3 | Mất mạng | Áp dụng ngay trên máy, xếp hàng đợi; cạnh trường hiện dấu "Chờ đồng bộ" thay MSG-22 (QC-08 mục 7). Có mạng thì gửi lên, dấu đổi thành MSG-22; xung đột theo A6 (chốt 09/11/2026, C40, A6) |

### UC-07 Hồ sơ và bảo mật tài khoản

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | Hồ sơ / mật khẩu / email được đổi, hoặc các phiên khác bị thu hồi; ghi nhật ký (BR-21) |
| Hậu điều kiện thất bại | Không thay đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → "Hồ sơ" (**SCR-10**) |
| 2 | Người dùng | Sửa tên hiển thị hoặc tải ảnh đại diện |
| 3 | Hệ thống | Kiểm tra giới hạn; gọi \[MeUpdate\]; MSG-22; tên / ảnh mới hiện ở menu tài khoản, comment (G02) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Đổi mật khẩu | **SCR-11** → "Đổi mật khẩu" → nhập mật khẩu hiện tại (hoặc "Xác nhận bằng Google / Microsoft" lấy `reauthToken`) + mật khẩu mới → \[MeUpdate\] (BR-02, BR-10); thu hồi phiên khác (chốt 09/11/2026, B38); MSG-30 |
| A2 | Đổi email | SCR-11 → "Đổi email" → nhập email mới + mật khẩu (hoặc `reauthToken`, BR-10) → \[MeUpdate\] → MSG-31, nhập mã → \[AuthVerifyEmail\] (`purpose=change_email`) → thu hồi phiên khác (B38) → MSG-33; email cũ nhận thư có link "Không phải tôi" 72 giờ (BR-17) |
| A3 | Đăng xuất mọi thiết bị khác | SCR-11 → nút → \[AuthLogout\] `?all=true` (giữ phiên hiện tại) → MSG-34 (BR-18) |
| A4 | Tài khoản chỉ có Google / Microsoft | "Đổi mật khẩu" đổi thành "Tạo mật khẩu"; xác nhận lại qua nhà cung cấp (`reauthToken`, BR-10, UC-02 A6) |
| A5 | Chủ email cũ bấm "Không phải tôi" trong thư (≤ 72 giờ) | Mở **SCR-20**, trang không cần đăng nhập trong trình duyệt (1.0: trang web tối giản `[giả định — tech chốt, docs/tech/]`) → \[EmailChangeRevert\]: email cũ trở lại là email chính, thu hồi mọi phiên, gửi link đặt lại mật khẩu tới email cũ (BR-17) → SCR-20 hiện MSG-42 |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tên ngoài 1–80 ký tự / ảnh sai định dạng hoặc > 2 MB | MSG-27 / MSG-28 |
| E2 | Mật khẩu hiện tại sai | MSG-29; tính vào BR-07 |
| E3 | Mật khẩu mới không đạt BR-02 | MSG-02 / MSG-03 |
| E4 | Email mới không dùng được | MSG-32 ở bước nhập mã (BR-17) |
| E5 | Lỗi 5xx | MSG-10, giữ giá trị cũ |
| E6 | Link "Không phải tôi" quá 72 giờ / đã dùng | SCR-20 hiện MSG-43, không thay đổi gì |
| E7 | `reauthToken` hết hạn / không khớp tài khoản | MSG-11, yêu cầu xác nhận lại |

### UC-08 Xuất dữ liệu

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập; không có yêu cầu xuất `DANG_XU_LY` |
| Hậu điều kiện thành công | Yêu cầu `DANG_XU_LY`; khi xong `SAN_SANG`, người dùng nhận email có link |
| Hậu điều kiện thất bại | Không tạo yêu cầu |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-11 → "Xuất dữ liệu" |
| 2 | Hệ thống | Gọi \[DataExport\]; SCR-11 hiện MSG-35 và trạng thái yêu cầu |
| 3 | Hệ thống | Job tạo gói theo BR-19 trong ≤ 24 giờ; gửi email có link (hiệu lực 7 ngày) |
| 4 | Người dùng | Bấm link → **SCR-19** (trang tải bản xuất) → đăng nhập nếu cần → tải file; SCR-11 cũng có nút "Tải xuống" khi `SAN_SANG` |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Workspace chỉ đọc (1.1, QC-09) | Vẫn xuất được như luồng chính |
| A2 | Link quá 7 ngày | Trạng thái `HET_HAN`; nút "Tạo bản xuất mới" (MSG-53) → chạy lại luồng chính |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Đã có yêu cầu đang xử lý | MSG-36 |
| E2 | Job lỗi | Tự thử lại 3 lần; vẫn lỗi → trạng thái `LOI`, email báo, SCR-11 hiện MSG-51 kèm nút "Tạo bản xuất mới" (MSG-53) → chạy lại luồng chính (chốt 09/11/2026, B40) |
| E3 | Mở link bằng tài khoản khác | 403, SCR-19 hiện MSG-52 |

### UC-09 Xoá tài khoản

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập; không có yêu cầu xuất `DANG_XU_LY`; (bản sau) không phải `OWNER` của workspace còn thành viên khác (BR-20) |
| Hậu điều kiện thành công | Tài khoản `CHO_XOA`, áp BR-20 (workspace một người: đã xoá workspace cá nhân, từ 1.1 huỷ gói nếu có; bản sau: đã rời workspace nhóm); người dùng ở SCR-21 (MSG-38) |
| Hậu điều kiện thất bại | Tài khoản và workspace không đổi |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | SCR-11 → "Xoá tài khoản" → **SCR-12** |
| 2 | Hệ thống | Hiện hậu quả theo BR-20: số task, kết nối lịch / tích hợp sẽ bị thu hồi; 1.1 thêm gói bị huỷ; bản sau: MSG-45 (không phải `OWNER`); gợi ý "Xuất dữ liệu trước" |
| 3 | Người dùng | Nhập mật khẩu (hoặc xác nhận lại qua nhà cung cấp, BR-10; A5), gõ "XOÁ", bấm "Xoá vĩnh viễn" |
| 4 | Hệ thống | Gọi \[AccountDelete\]; áp BR-20; về **SCR-21** (MSG-38) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bấm "Xuất dữ liệu trước" | Đóng SCR-12, chạy UC-08 |
| A2 | Đang có timer chạy | Dừng và lưu bản ghi thời gian trước khi xoá (G07) |
| A3 | Không phải `OWNER` (bản sau — BR-26) | Bước 4: server chạy rời workspace theo G12 BR-13 (task được giao chưa xong trả về người giao, giảm ghế từ kỳ sau) rồi mới chuyển `CHO_XOA`, trong một giao dịch; gói của nhóm giữ nguyên |
| A4 | `OWNER` của workspace chỉ có mình (mọi tài khoản khi chưa có tính năng nhiều thành viên) | Bước 4: xoá workspace cá nhân cùng giao dịch; từ 1.1 huỷ gói ngay (G12 BR-09, BR-14) |
| A5 | Tài khoản chỉ đăng nhập bằng Google / Microsoft | SCR-12 #3 là nút "Xác nhận bằng Google / Microsoft" thay ô mật khẩu → UC-02 A6 lấy `reauthToken` → về SCR-12, ô #3 hiện đã xác nhận; tiếp bước 3 (chốt 09/11/2026, B37) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | `OWNER`, workspace còn thành viên khác (bản sau — BR-26) | MSG-37 có link "Chuyển quyền sở hữu" và "Xoá workspace" (G12); nút xoá disabled |
| E2 | Mật khẩu sai / chưa gõ đúng "XOÁ" | MSG-29 / MSG-39 |
| E3 | Lỗi 5xx | MSG-10, tài khoản giữ nguyên |
| E4 | Có yêu cầu xuất `DANG_XU_LY` | MSG-44; nút xoá disabled tới khi yêu cầu `SAN_SANG` hoặc `LOI` |
| E5 | Xác nhận lại qua nhà cung cấp thất bại: `reauthToken` hết hạn / không khớp tài khoản (A5) | MSG-11 trong SCR-12, yêu cầu xác nhận lại; tài khoản giữ nguyên (B37) |

### UC-10 Cài đặt Lịch làm việc

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | `workSchedule` mới lưu theo BR-22, đồng bộ thiết bị khác (BR-12); G04, G05, G08, G09 đọc giá trị mới |
| Hậu điều kiện thất bại | Giữ lịch làm việc cũ |

**Luồng chính**

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Người dùng | Cài đặt → "Lịch làm việc" (**SCR-14**) |
| 2 | Hệ thống | Gọi \[SettingsGet\]; hiện 7 ngày trong tuần, ngày làm việc bật kèm giờ bắt đầu / kết thúc |
| 3 | Người dùng | Bật / tắt một ngày hoặc đổi giờ của một ngày |
| 4 | Hệ thống | Kiểm tra BR-22; gọi \[SettingsUpdate\] (`workSchedule`); MSG-22 cạnh dòng; MSG-24 dưới bảng (có hiệu lực từ ngày làm việc kế tiếp `[giả định]`) |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Bật Thứ Bảy (hoặc ngày khác) | Ngày đó nhận giờ mặc định 09:00–17:00 `[giả định]`, sửa được |
| A2 | Từ onboarding bước 4 | Cùng thành phần SCR-14, lưu theo UC-05 bước 2 |
| A3 | Bấm "Đặt khung giờ cho channel" (SCR-14 #4) | Mở cài đặt channel của G02; khung giờ channel đặc tả ở G02 (QC-02 mục 5), G01 không lưu giá trị này |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Tắt ngày làm việc cuối cùng | MSG-46, không gửi |
| E2 | Giờ kết thúc ≤ giờ bắt đầu | MSG-20, không gửi |
| E3 | \[SettingsUpdate\] lỗi / xung đột | Như UC-06 E2 / A6 |
| E4 | Mất mạng | Như UC-06 E3: áp dụng ngay trên máy, xếp hàng đợi, dấu "Chờ đồng bộ" cạnh dòng (QC-08 mục 7); có mạng thì gửi lên, hiện MSG-22, MSG-24 (chốt 09/11/2026, C40, A6) |

### UC-11 Rút lại đồng ý và xin đồng ý lại

| **Mục** | **Nội dung** |
| --- | --- |
| Tiền điều kiện | Đã đăng nhập |
| Hậu điều kiện thành công | Đồng ý phiên bản mới được lưu (BR-06), hoặc đồng ý bị rút lại và tài khoản chuyển `CHO_XOA` `[giả định — chờ pháp chế]`; ghi BR-21 |
| Hậu điều kiện thất bại | Trạng thái đồng ý không đổi |

**Luồng chính** (xin đồng ý lại)

| **Bước** | **Actor** | **Mô tả** |
| --- | --- | --- |
| 1 | Hệ thống | Mở app, \[ConsentGet\] trả `CAN_DONG_Y_LAI` (hoặc API bất kỳ trả `CONSENT_REQUIRED`) → mở **SCR-15** với MSG-47 |
| 2 | Người dùng | Đọc tóm tắt thay đổi, tick đồng ý, bấm "Đồng ý và tiếp tục" |
| 3 | Hệ thống | Gọi \[ConsentUpdate\] (phiên bản, thời điểm); về màn đang mở |

**Luồng thay thế**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| A1 | Rút lại đồng ý | SCR-11 → "Rút lại đồng ý xử lý dữ liệu" → MSG-48 → xác nhận lại (BR-10) ở **SCR-22** → \[ConsentUpdate\] `withdraw=true` → chạy như UC-09 bước 4 (BR-20) `[giả định — chờ pháp chế]` |
| A2 | Trên SCR-15 chọn "Xuất dữ liệu" / "Xoá tài khoản" / "Đăng xuất" | Chạy UC-08 / UC-09 / UC-03 A1 mà không cần đồng ý phiên bản mới (BR-23) |
| A3 | Rút lại đồng ý Trợ lý AI / Product updates | Không ở đây: Cài đặt → Trợ lý AI (SCR-16, G10) / Cài đặt → Thông báo (G12) (BR-23 c, d) |

**Luồng lỗi**

| **Mã** | **Điều kiện** | **Xử lý** |
| --- | --- | --- |
| E1 | Chưa tick đồng ý | MSG-04 |
| E2 | Rút lại khi đang là `OWNER` workspace còn thành viên (bản sau) / đang xuất dữ liệu | Như UC-09 E1 (bản sau) / MSG-54, nút "Rút lại đồng ý" disabled tới khi yêu cầu xuất `SAN_SANG` hoặc `LOI` (C41) |
| E3 | Lỗi 5xx | MSG-10 |
| E4 | A1 xác nhận lại thất bại: mật khẩu sai / `reauthToken` hết hạn hoặc không khớp | MSG-29 (mật khẩu sai, tính vào BR-07) / MSG-11 trong SCR-22; đồng ý không đổi, xác nhận lại được (chốt 09/11/2026, B37) |

## 6. Điểm vào

iOS / Android (1.2) dùng cùng điểm vào với cột Web / macOS, trừ dòng ghi khác.

| **Điểm vào** | **App Windows** (1.0) | **Web / macOS** (1.1) | **Ghi chú** |
| --- | --- | --- | --- |
| Mở app lần đầu sau khi cài (1.0) / trang chủ → "Đăng ký" (web, 1.1) | ✓ | ✓ | SCR-01 |
| Link mời workspace (bản sau — BR-26) | – | – | SCR-01 / SCR-03 có email điền sẵn (G12) |
| Link trong email đặt lại mật khẩu / xuất dữ liệu | ✓ (deep link hoặc trang web tối giản `[giả định — tech chốt]`) | ✓ | SCR-04 / SCR-19. Xác minh email dùng mã 6 số, không dùng link |
| Trình duyệt hệ thống trả kết quả đăng nhập Google / Microsoft về app | ✓ | – (web: chuyển hướng thường) | UC-02 bước 4, BR-25 |
| Lần đăng nhập đầu, onboarding chưa xong | ✓ | ✓ | SCR-05 bước dở |
| Menu tài khoản (SCR-17) → "Cài đặt" / command menu "Mở cài đặt" | ✓ | ✓ | SCR-06 |
| Banner lệch timezone trên Home | ✓ | ✓ | SCR-13 |
| Bảng phím tắt (phím ?) → "Cài đặt phím tắt" | ✓ | ✓ (web, macOS) | SCR-09; không có trên iOS / Android |
| Cài đặt → "Lịch làm việc"; link từ G04 (sức chứa), G08 (cài đặt ritual) | ✓ | ✓ | SCR-14 |
| Cài đặt → "Trợ lý AI"; link từ G10 (✨, "Plan my day", hướng dẫn cài Claude Code) | ✓ | Theo G10 (AI trên web / di động: tech chốt) | SCR-16 → nội dung G10 (BR-24) |
| Link "Không phải tôi" trong thư gửi email cũ | ✓ (trang web tối giản `[giả định — tech chốt]`) | ✓ | SCR-20; UC-07 A5, MSG-42 / MSG-43 |
| Mở app khi có phiên bản Điều khoản mới cần đồng ý lại | ✓ | ✓ | SCR-15 |

## 7. Mô tả màn hình

### SCR-01 Đăng ký

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Tiếp tục với Google", "Tiếp tục với Microsoft" | Button | – | UC-02; app desktop mở trình duyệt hệ thống, hiện MSG-49 (BR-25) |
| 2 | Email | Text | Có | Định dạng email; sai → MSG-01 |
| 3 | Mật khẩu | Password + nút hiện / ẩn | Có | 10–128 ký tự (MSG-02); thanh độ mạnh `[giả định]` |
| 4 | Đồng ý Điều khoản và Chính sách quyền riêng tư | Checkbox + link | Có | Không tick sẵn; thiếu → MSG-04 |
| 5 | "Tạo tài khoản" | Button | – | Loading khi gửi; chặn bấm 2 lần |
| 6 | "Đã có tài khoản? Đăng nhập" | Link | – | SCR-03 |

### SCR-02 Nhập mã xác minh

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Mô tả | Text | – | MSG-05 |
| 2 | Mã 6 số | 6 ô số | Có | Dán 6 số tự điền và gửi; sai → MSG-06; hết hạn → MSG-07 |
| 3 | "Gửi lại mã" | Link | – | Đếm ngược 60 giây; quá giới hạn → MSG-08 |
| 4 | "Đổi email" | Link | – | A3 UC-01 |

### SCR-03 Đăng nhập

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | "Tiếp tục với Google", "Tiếp tục với Microsoft" | Button | – | UC-02; app desktop mở trình duyệt hệ thống, hiện MSG-49 (BR-25) |
| 2 | Email, Mật khẩu | Text, Password | Có | Lỗi chung MSG-14, kể cả khi đang bị khoá (BR-07) |
| 3 | "Đăng nhập" | Button | – | Loading khi gửi |
| 4 | "Quên mật khẩu?" | Link | – | SCR-04 |
| 5 | Vùng thông báo | Inline | – | MSG-11 / MSG-12 / MSG-16 / MSG-50 khi được chuyển về từ luồng khác |
| 6 | Màn chờ đăng nhập qua trình duyệt | Overlay | – | MSG-49 + nút "Huỷ" (UC-02 A7); hết thời gian chờ → MSG-50 (BR-25) |

### SCR-04 Quên / đặt lại mật khẩu

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | (Phần 1) Email + "Gửi link" | Text + Button | Có | Luôn hiện MSG-17 sau khi gửi |
| 2 | (Phần 2, trên trang web tối giản) Mật khẩu mới | Password | Có | BR-02 (MSG-02 / MSG-03); link hỏng → MSG-18 |
| 3 | (Phần 2) "Đặt mật khẩu" | Button | – | UC-04 bước 4 |

### SCR-05 Onboarding

Toàn cửa sổ, chưa có sidebar và panel phải, nội dung đặt giữa; các màn SCR-01 … SCR-04 cũng vậy. Bước nhập task trông giống ô soạn thật (G02 SCR-01). Xong onboarding → Home hôm nay (IA-12).

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Thanh tiến độ "Bước n / 5" | Progress | – | Có nút ← từ bước 2 |
| 2 | Bước 1: Ngôn ngữ, Timezone | Dropdown, Dropdown có tìm | Có | Điền sẵn theo cài đặt của Windows |
| 3 | Bước 2: "Kết nối Google Calendar", "Kết nối Outlook", "Bỏ qua" | Button | Không | Luồng G05; đã kết nối hiện icon dấu tích, "Đã kết nối" và email lịch (dấu tích là icon, không nằm trong chữ; C36) |
| 4 | Bước 3: Công cụ đang dùng | Lưới chọn nhiều (logo + tên) | Không | Gmail, Outlook, Jira, Notion, Asana, Trello, Linear, ClickUp, GitHub, Todoist, Slack, Teams, "Khác", "Không dùng công cụ nào" `[giả định danh sách]` |
| 5 | Bước 4: Lịch làm việc | Cùng thành phần SCR-14 | Có | Mặc định Thứ Hai–Thứ Sáu, 09:00–17:00; kết thúc ≤ bắt đầu → MSG-20; không ngày nào → MSG-46 |
| 6 | Bước 4: Giờ plan ngày | Time picker (bước 5 phút) | Có | Mặc định 09:00 |
| 7 | Bước 5: 3 ô task | Text ×3 | Không (B36) | Tiêu đề theo G02; thời lượng gợi ý có ✨; trống hết mà bấm "Bắt đầu ngày đầu tiên" → MSG-21 (UC-05 E3) |
| 8 | "Tiếp" / "Bắt đầu ngày đầu tiên" | Button | – | Luôn bấm được (B41); lưu bước; bước 5 → UC-05 bước 7 |
| 9 | Bước 5: "Bỏ qua" | Button | – | Không tạo task, hoàn tất onboarding (UC-05 A6, B36) |

### SCR-06 Khung trang Cài đặt

Lớp phủ gần kín cửa sổ, khung app mờ phía sau (IA-04). Mở bằng avatar → "Cài đặt", Ctrl+, (IA-15) hoặc command menu; link từ nơi khác mở thẳng đúng nhóm.

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Cột trái: nhóm "Cá nhân" | Nav list | Chung · Hiển thị · Lịch làm việc (G01, SCR-14) · Ritual (G08) · Timebox (G05) · Phím tắt · Focus (G07) · Trợ lý AI (SCR-16 → G10; mặc định tắt, bật lần đầu qua màn đồng ý gọn của G10, QC-12 mục 7) · Beta (G10) · Thông báo (G12) |
| 2 | Cột trái: nhóm "Tài khoản" | Nav list | Hồ sơ · Tài khoản |
| 3 | Cột trái: nhóm "Workspace" | Nav list | Context & channel (G02, gồm khung giờ channel) · Thành viên (G12, bản sau) · Privacy (G12, bản sau) · Billing (G12, 1.1) · Tích hợp (G05 / G11) |
| 4 | Vùng nội dung | Panel | Nội dung nhóm đang chọn; mỗi nhóm có đường dẫn riêng để mở thẳng từ nơi khác trong app `[giả định — tech chốt]` |
| 5 | Ô tìm cài đặt | Search `[giả định]` | Lọc theo tên cài đặt, mở đúng nhóm và cuộn tới trường |
| 6 | Đóng | Icon × / Esc | Về màn trước |

Cửa sổ app hẹp (và iOS / Android, 1.2): cột trái thành danh sách màn đầu, chọn nhóm mở màn nội dung có nút ←.

### SCR-07 Cài đặt Chung

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ngôn ngữ | Dropdown | Có | A4 UC-06 |
| 2 | Timezone | Dropdown có tìm | Có | Hiện "Theo thiết bị: {tz}" khi lệch |
| 3 | Ngày đầu tuần | Dropdown | Có | Thứ Hai / Chủ Nhật |
| 4 | Mốc đầu ngày | Time picker | Có | 00:00–06:00, mặc định 04:00 (BR-14); ghi chú MSG-24 |
| 5 | Ngưỡng khối lượng ngày | Ô giờ | Có | 1–24 giờ (MSG-25) |
| 6 | Tính planned là actual | Toggle | – | Mặc định bật |
| 7 | Tự sắp task | Toggle | – | Mặc định bật |
| 8 | Vị trí task mới · Vị trí task rollover | Segmented Đầu / Cuối | – | Mặc định Đầu · Đầu |
| 9 | Giữ priority khi rollover | Chọn nhiều (Urgent, Priority, Normal, Low — G02 BR-06) | – | Mặc định không chọn mức nào; lưu `keepPriorityLevels`, áp theo G06 BR-08 |
| 10 | Bấm × để thoát hẳn | Toggle | – | App Windows. Mặc định tắt: × thu app về khay hệ thống (IA-05, G07 BR-23) |
| 11 | Chạy khi Windows khởi động | Toggle | – | App Windows. Mặc định bật, chạy ẩn ở khay (IA-05) |

### SCR-08 Cài đặt Hiển thị

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Giao diện | Segmented Sáng / Tối / Hệ thống | – | Mặc định Hệ thống (theo Windows); đổi ngay ([DS](../design-brief/01-nen-tang-design-system.md) DS-03) |
| 2 | Màu sự kiện trên lịch | Dropdown | – | Theo channel (mặc định) / theo lịch |
| 3 | Ẩn task đã xong | Toggle | – | Mặc định tắt |
| 4 | Hiệu ứng chúc mừng | Toggle | – | Mặc định bật `[giả định]`; bật thì chạy thử 1 lần. ✓ nở nhẹ tại chỗ mỗi lần hoàn thành; xong task cuối của hôm nay thì có hiệu ứng lớn hơn một lần, không phủ kín màn hình; Windows tắt hoạt ảnh thì không có hiệu ứng lớn (DS-16) |

### SCR-09 Cài đặt Phím tắt

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Bật phím tắt | Toggle | – | BR-15 |
| 2 | Phím toàn cục (app desktop, từ 1.0 — D11) | Hiển thị phím | – | Ctrl+Shift+A thêm task · Ctrl+Shift+Space bật / dừng timer; ẩn trên web |
| 3 | Bảng phím tắt | Danh sách theo nhóm | – | Cùng dữ liệu với bảng phím ? (G04); chỉ xem ở 1.0 `[giả định]` |

### SCR-10 Hồ sơ

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Ảnh đại diện | Upload + crop | Không | JPG / PNG ≤ 2 MB (MSG-28); "Xoá ảnh" về chữ cái đầu |
| 2 | Tên hiển thị | Text | Có | 1–80 ký tự (MSG-27) |
| 3 | Email | Text chỉ đọc | – | Link "Đổi email" → SCR-11 |

### SCR-11 Tài khoản

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Phương thức đăng nhập | List | Mật khẩu / Google / Microsoft đã liên kết |
| 2 | "Đổi mật khẩu" / "Tạo mật khẩu" | Button → dialog | A1, A4 UC-07 |
| 3 | "Đổi email" | Button → dialog 2 bước | A2 UC-07 |
| 4 | Xác thực 2 lớp | Toggle | Ẩn ở 1.0 (1.1) |
| 5 | "Đăng xuất mọi thiết bị khác" | Button | A3 UC-07 |
| 6 | "Xuất dữ liệu" + trạng thái | Button + text | UC-08; hiện MSG-35 / "Tải xuống" / "Đã hết hạn" kèm MSG-53 / MSG-51 kèm MSG-53 |
| 7 | "Xoá tài khoản" | Button (nguy hiểm) | SCR-12 |
| 8 | Đồng ý xử lý dữ liệu | Text + link | Phiên bản Điều khoản / Chính sách đã đồng ý, thời điểm; link "Rút lại đồng ý xử lý dữ liệu" (UC-11 A1); ghi chú "Đồng ý dùng Trợ lý AI: Cài đặt → Trợ lý AI" (SCR-16, G10) |

### SCR-12 Xoá tài khoản

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | "Xoá tài khoản sẽ xoá {n} task, ngắt {m} kết nối{, huỷ gói hiện tại — từ 1.1, khi có gói}. Dữ liệu bị xoá vĩnh viễn trong 30 ngày, không khôi phục được. Hoá đơn được giữ theo quy định kế toán." Không phải `OWNER` (bản sau — BR-26): thêm MSG-45 |
| 2 | "Xuất dữ liệu trước" | Link | A1 UC-09 |
| 3 | Xác nhận lại (BR-10) | Password / Button | Tài khoản có mật khẩu: ô Mật khẩu, sai → MSG-29. Tài khoản chỉ có Google / Microsoft: nút "Xác nhận bằng Google / Microsoft" thay ô mật khẩu → UC-02 A6; xong hiện đã xác nhận, lỗi → MSG-11 (UC-09 A5, E5; B37) |
| 4 | Ô gõ "XOÁ" | Text | Khác "XOÁ" → MSG-39 |
| 5 | "Xoá vĩnh viễn" | Button (nguy hiểm) | Disabled tới khi 3 (đã nhập mật khẩu hoặc đã có `reauthToken`), 4 hợp lệ; `OWNER` workspace còn thành viên (bản sau) → disabled + MSG-37; đang xuất dữ liệu → disabled + MSG-44 |
| 6 | "Huỷ" | Button | Đóng |

### SCR-13 Banner timezone và tooltip theo ngữ cảnh

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Banner lệch timezone | Banner đầu Home | MSG-23; hai nút "Đổi sang…", "Giữ…" (BR-13); banner timezone duy nhất của app |
| 2 | Tooltip theo ngữ cảnh | Popover neo vào thành phần | Tiêu đề + 1–2 câu + "Đã hiểu"; hiện 1 lần (BR-16) |

### SCR-14 Lịch làm việc

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | 7 dòng Thứ Hai … Chủ Nhật, thứ tự theo ngày đầu tuần (SCR-07 #3) | Toggle + 2 time picker (bước 15 phút `[giả định]`) | ≥ 1 ngày bật | Mặc định bật Thứ Hai–Thứ Sáu, 09:00–17:00; tắt ngày cuối cùng → MSG-46; kết thúc ≤ bắt đầu → MSG-20 |
| 2 | Ghi chú | Text | – | MSG-24 sau khi đổi; "Ngày tắt không nhận task khi chọn 'Ngày mai', không nhắc ritual" (QC-02) |
| 3 | Ghi chú ngày lễ | Text | – | "Chưa hỗ trợ ngày lễ. Dùng 'Bỏ qua hôm nay' trong ritual" |
| 4 | Khung giờ channel | Text + link | – | "Đây là lịch chung. Channel có khung giờ riêng thì task của channel đó theo khung giờ riêng" + link "Đặt khung giờ cho channel" → cài đặt channel của G02 (UC-10 A3, QC-02 mục 5–6) |

### SCR-17 Menu tài khoản

Popover mở từ avatar ở cụm dưới sidebar (IA mục 2). Mã đặt ngày 09/11/2026 (C37).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Avatar, tên hiển thị, email | Text | Theo SCR-10 |
| 2 | "Cài đặt" (Ctrl+,) | Menu item | SCR-06 (UC-06 bước 1) |
| 3 | "Phím tắt" (?) | Menu item | Bảng phím tắt G04 SCR-09 |
| 4 | "Đăng xuất" | Menu item | UC-03 A1 |
| 5 | "Thoát app" | Menu item | App Windows: thoát hẳn, không thu về khay (IA-05) |

### SCR-18 Đăng ký rút gọn (Google / Microsoft)

SCR-01 bản rút gọn cho UC-02 A1: tài khoản Google / Microsoft chưa liên kết, email chưa có tài khoản. Mã đặt ngày 09/11/2026 (C37).

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Email từ nhà cung cấp | Text chỉ đọc | – | Email đã xác minh của Google / Microsoft |
| 2 | Đồng ý Điều khoản và Chính sách quyền riêng tư | Checkbox + link | Có | Như SCR-01 #4; thiếu → MSG-04 |
| 3 | "Tạo tài khoản" | Button | – | Khởi tạo BR-05 → SCR-05 bước 1 |

### SCR-19 Trang tải bản xuất dữ liệu

Trang web tối giản mở từ link trong email xuất dữ liệu (1.0: `[giả định — tech chốt]`). Mã đặt ngày 09/11/2026 (C37).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Đăng nhập | Form | Hiện khi chưa đăng nhập; như SCR-03 |
| 2 | "Tải xuống" | Button | Tải gói zip (UC-08 bước 4) |
| 3 | Thông báo | Text | Link quá 7 ngày → "Đã hết hạn" (UC-08 A2); tài khoản khác → MSG-52 (UC-08 E3) |

### SCR-20 Trang "Không phải tôi"

Trang web tối giản mở từ link "Không phải tôi" trong thư gửi email cũ, không cần đăng nhập (BR-17). Mã đặt ngày 09/11/2026 (C37).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Kết quả | Text | Thành công → MSG-42 (UC-07 A5); link quá hạn / đã dùng → MSG-43 (UC-07 E6) |

### SCR-21 Đã xoá tài khoản

Toàn cửa sổ, sau UC-09 bước 4 và UC-11 A1. Mã đặt ngày 09/11/2026 (C37).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Nội dung | Text | MSG-38 |
| 2 | "Đóng" | Button | Về SCR-03 (đã đăng xuất mọi phiên) |

### SCR-22 Dialog xác nhận lại

Dialog sau MSG-48 khi rút lại đồng ý (UC-11 A1, BR-10). Mã đặt ngày 09/11/2026 (C37).

| **#** | **Thành phần** | **Loại** | **Hành vi** |
| --- | --- | --- | --- |
| 1 | Mật khẩu | Password | Tài khoản có mật khẩu; sai → MSG-29 (UC-11 E4) |
| 2 | "Xác nhận bằng Google / Microsoft" | Button | Tài khoản chỉ có Google / Microsoft, thay ô mật khẩu → UC-02 A6; lỗi → MSG-11 (UC-11 E4) |
| 3 | "Rút lại đồng ý" / "Huỷ" | Button | \[ConsentUpdate\] `withdraw=true` (UC-11 A1) / đóng, đồng ý không đổi |

### SCR-16 Trợ lý AI (điểm vào, nội dung do G10 sở hữu)

G01 chỉ đặt nhóm này trong SCR-06 #1; bố cục chi tiết, giá trị mặc định, validate, API và thông báo theo SRS G10 SCR-09 (G10 đang gọi là "Cài đặt → AI"; tên nhóm cần thống nhất) và QC-12. Bảng dưới chỉ liệt kê các thành phần bắt buộc phải có để các nhóm khác tham chiếu (BR-24).

| **#** | **Thành phần** | **Loại** | **Nhóm sở hữu** | **Hành vi (tóm tắt, chi tiết ở G10)** |
| --- | --- | --- | --- | --- |
| 1 | Trợ lý AI | Toggle | G10 | Mặc định tắt; bật lần đầu → màn đồng ý gọn (QC-12 mục 7); tắt → MCP local ngừng nhận kết nối |
| 2 | Trạng thái Claude Code | Text + link | G10 | Đã cài / đã đăng nhập / phiên bản; chưa có → "Cài Claude Code để bật trợ lý AI" (QC-12 mục 2) |
| 3 | (Bỏ — F4: không còn công tắc hoàn thành / xoá, QC-12 mục 4) | – | – | – |
| 4 | Cho AI đọc dữ liệu tích hợp | Toggle | G10 | Mặc định tắt; bật thì các thay đổi sau lần đầu đọc dữ liệu tích hợp trong phiên AI đó chờ duyệt (QC-12 mục 6, D8); ẩn khi chưa có tích hợp (G11, 1.1) theo G10 |
| 5 | Đồng ý dùng AI | Text + link | G10 | Thời điểm đồng ý; "Rút lại đồng ý dùng AI" (BR-23 c) |

### SCR-15 Đồng ý phiên bản Điều khoản mới

| **#** | **Thành phần** | **Loại** | **Bắt buộc** | **Validate / hành vi** |
| --- | --- | --- | --- | --- |
| 1 | Tiêu đề, tóm tắt thay đổi | Text | – | MSG-47; link xem bản đầy đủ |
| 2 | Đồng ý Điều khoản và Chính sách quyền riêng tư | Checkbox | Có | Không tick sẵn; thiếu → MSG-04 |
| 3 | "Đồng ý và tiếp tục" | Button | – | \[ConsentUpdate\]; UC-11 bước 3 |
| 4 | "Xuất dữ liệu" · "Xoá tài khoản" · "Đăng xuất" | Link | – | UC-11 A2 |

## 8. API

| **API** | **Request chính** | **Response chính** | **Timeout / retry** `[giả định]` |
| --- | --- | --- | --- |
| \[AuthSignup\] `POST /auth/signup` | email, password, consentVersion, locale, timezone, inviteToken? (bản sau), Idempotency-Key | verificationId (202) | 10s / 1 lần cùng key |
| \[AuthVerifyEmail\] `POST /auth/verify-email` | verificationId, code, purpose (`signup` / `change_email`) | accessToken, user, onboardingState; refresh token (BR-08) | 5s / không retry |
| \[AuthResendCode\] `POST /auth/verify-email/resend` `[giả định]` | verificationId | nextAllowedAt | 5s / không retry |
| \[AuthLogin\] `POST /auth/login` | email, password, totp? (1.1), inviteToken? (bản sau) | accessToken, user, onboardingState; refresh token (BR-08) | 10s / không retry |
| \[AuthOAuthStart\] `GET /auth/oauth/{provider}/start` | provider (`google` / `microsoft`), redirectUri (app desktop: theo cách trả kết quả về app — tech chốt), inviteToken? (bản sau), purpose (`login` / `reauth`) | URL trang nhà cung cấp (state, PKCE) để mở trong trình duyệt hệ thống (BR-25) | 5s / 1 lần |
| \[AuthOAuthCallback\] `GET /auth/oauth/{provider}/callback` | code, state | Trả kết quả về app; `needsConsent` / `needsLink` nếu A1 / A2 UC-02; `replacedUnverified` nếu A4; `reauthToken` nếu `purpose=reauth` | 10s / không retry |
| \[AuthRefresh\] `POST /auth/refresh` | refresh token (BR-08) | accessToken; refresh token mới | 5s / 2 lần (lỗi mạng), 401 không retry |
| \[AuthLogout\] `POST /auth/logout(?all=true)` | refresh token (BR-08) | 204; `revokedCount` khi all | 5s / 1 lần |
| \[AuthPasswordForgot\] `POST /auth/password/forgot` | email | 202 (luôn) | 5s / 1 lần |
| \[AuthPasswordReset\] `POST /auth/password/reset` | token, newPassword | accessToken; refresh token (BR-08) | 10s / không retry |
| \[MeGet\] / \[MeUpdate\] `GET` / `PATCH /me` | displayName, avatar; (currentPassword \| reauthToken) + newPassword; (currentPassword \| reauthToken) + newEmail | User; `pendingEmailVerificationId` khi đổi email | 5s / 2 lần (GET), 1 lần (PATCH) |
| \[EmailChangeRevert\] `POST /auth/email-change/revert` `[giả định]` | token (từ link "Không phải tôi") | 200; email chính đã khôi phục | 5s / 1 lần |
| \[SettingsGet\] / \[SettingsUpdate\] `GET` / `PATCH /me/settings` | Trường thay đổi (kể cả `onboardingStep`, `tipsSeen`, `workTools`, `workSchedule`, `dayStartTime`, `timezone`, `keepPriorityLevels`), version theo từng trường | Settings, version; 412 trả danh sách trường bị từ chối kèm giá trị server | 5s / 2 lần |
| \[ConsentGet\] / \[ConsentUpdate\] `GET` / `POST /me/consents` `[giả định]` | documentVersion, accepted \| withdraw, (currentPassword \| reauthToken khi withdraw) | Trạng thái đồng ý (`DA_DONG_Y` / `CAN_DONG_Y_LAI`), acceptedAt | 5s / 1 lần |
| \[OnboardingComplete\] `POST /me/onboarding/complete` | Idempotency-Key | onboardingState, dailyPlanningUrl | 5s / 2 lần cùng key |
| \[DataExport\] `POST /me/export` · `GET /me/export/{id}` `[giả định]` | Idempotency-Key | exportId, status, downloadUrl?, expiresAt | 5s / 1 lần |
| \[AccountDelete\] `DELETE /me` | currentPassword hoặc reauthToken, confirmText | 202, purgeBefore, `deletedWorkspace`; `leftWorkspace` (bản sau) | 10s / không retry |
| \[AppConfig\] | – | Giới hạn BR-02, BR-03, mặc định cài đặt | Cache 1h |

**Map lỗi API → thông báo**

| **Mã lỗi** | **Message** |
| --- | --- |
| `VALIDATION_FAILED` · field email | MSG-01 |
| `VALIDATION_FAILED` · field password | MSG-02 |
| `PASSWORD_BREACHED` | MSG-03 |
| `CONSENT_REQUIRED` | MSG-04 (form đăng ký) / mở SCR-15 (đã đăng nhập, BR-23) |
| `CODE_INVALID` | MSG-06 |
| `CODE_EXPIRED` / `CODE_ATTEMPTS_EXCEEDED` | MSG-07 |
| `RESEND_LIMITED` (429) | MSG-08 |
| `RATE_LIMITED` (429) | MSG-09 |
| `OAUTH_FAILED` / `OAUTH_STATE_INVALID` | MSG-11 |
| Hết thời gian chờ trình duyệt / không mở được trình duyệt (phía app, BR-25) | MSG-50 |
| `OAUTH_EMAIL_UNVERIFIED` | MSG-12 |
| `ACCOUNT_LINK_REQUIRED` (409) | MSG-13 |
| `INVALID_CREDENTIALS` (401) | MSG-14 |
| `ACCOUNT_LOCKED` (403) | (Bỏ — cặp tài khoản + IP bị khoá vẫn trả `INVALID_CREDENTIALS`, MSG-14; BR-07) |
| `EMAIL_NOT_VERIFIED` (403) | Mở SCR-02, MSG-05 |
| `REFRESH_REUSED` / `SESSION_REVOKED` (401) | MSG-16 |
| `RESET_TOKEN_INVALID` | MSG-18 |
| `VALIDATION_FAILED` · field workHours | MSG-20 |
| `VALIDATION_FAILED` · field workloadThresholdMin | MSG-25 |
| `VALIDATION_FAILED` · field displayName / avatar | MSG-27 / MSG-28 |
| `WRONG_PASSWORD` (403) | MSG-29 |
| `EMAIL_CHANGE_REJECTED` (422) | MSG-32 |
| `EXPORT_IN_PROGRESS` (409) ở \[DataExport\] | MSG-36 |
| `EXPORT_IN_PROGRESS` (409) ở \[AccountDelete\] | MSG-44 |
| `EXPORT_IN_PROGRESS` (409) ở \[ConsentUpdate\] `withdraw` | MSG-54 |
| Yêu cầu xuất `LOI` (job lỗi sau 3 lần tự thử lại) | MSG-51 + MSG-53 |
| `EXPORT_FORBIDDEN` (403, link của tài khoản khác) `[giả định tên mã]` | MSG-52 |
| `OWNER_MUST_TRANSFER` (409) | MSG-37 |
| `VERSION_CONFLICT` (412) ở \[SettingsUpdate\] | Lấy giá trị server của trường bị từ chối, MSG-41 (BR-12) |
| `REAUTH_INVALID` (401) | MSG-11 |
| `EMAIL_REVERT_INVALID` (404 / 410) | MSG-43 |
| `VALIDATION_FAILED` · field workSchedule (không có ngày nào) | MSG-46 |
| 5xx / timeout | MSG-10 (xác thực, tài khoản) / MSG-26 (cài đặt) |

## 9. Danh sách thông báo

| **ID** | **Nơi hiện** | **Nội dung (VI)** |
| --- | --- | --- |
| MSG-01 | Inline | Email chưa đúng định dạng |
| MSG-02 | Inline | Mật khẩu cần từ 10 đến 128 ký tự |
| MSG-03 | Inline | Mật khẩu này đã bị lộ trong một vụ rò rỉ dữ liệu. Hãy chọn mật khẩu khác |
| MSG-04 | Inline | Bạn cần đồng ý với Điều khoản sử dụng và Chính sách quyền riêng tư |
| MSG-05 | SCR-02 | Chúng tôi đã gửi mã 6 số tới {email}. Mã có hiệu lực 10 phút. Đã có tài khoản? Đăng nhập · Quên mật khẩu |
| MSG-06 | Inline | Mã chưa đúng. Bạn còn {n} lần thử |
| MSG-07 | Inline | Mã đã hết hạn hoặc không còn dùng được. Gửi mã mới |
| MSG-08 | Inline | Bạn đã yêu cầu quá nhiều mã. Thử lại sau {m} phút |
| MSG-09 | Toast | Bạn thao tác quá nhanh. Thử lại sau ít phút |
| MSG-10 | Toast | Không kết nối được máy chủ. Thử lại |
| MSG-11 | SCR-03 · dialog xác nhận lại (SCR-11, SCR-12, SCR-22) | Đăng nhập bằng {Google / Microsoft} chưa thành công. Thử lại |
| MSG-12 | SCR-03 | Tài khoản {Google / Microsoft} chưa xác minh email. Hãy đăng nhập bằng email và mật khẩu |
| MSG-13 | Dialog | {email} đã có tài khoản. Nhập mật khẩu để liên kết với {Google / Microsoft} |
| MSG-14 | SCR-03 · dialog liên kết MSG-13 (UC-02 E4) | Email hoặc mật khẩu chưa đúng, hoặc đăng nhập tạm bị chặn. Thử lại sau ít phút hoặc dùng "Quên mật khẩu" |
| MSG-15 | – | (Bỏ — gộp vào MSG-14 để không lộ email đã đăng ký; BR-07) |
| MSG-16 | SCR-03 | Phiên đăng nhập đã kết thúc. Hãy đăng nhập lại |
| MSG-17 | SCR-04 | Nếu {email} có tài khoản, chúng tôi đã gửi link đặt lại mật khẩu. Link có hiệu lực 30 phút |
| MSG-18 | SCR-04 | Link đã hết hạn hoặc đã được dùng · Gửi link mới |
| MSG-19 | Trang web (SCR-04 phần 2) | Đã đặt lại mật khẩu. Các thiết bị khác đã được đăng xuất |
| MSG-20 | Inline | Giờ kết thúc phải sau giờ bắt đầu |
| MSG-21 | Inline | Thêm ít nhất 1 task, hoặc bấm Bỏ qua |
| MSG-22 | Inline cạnh trường, kèm icon dấu tích (C36) | Đã lưu |
| MSG-23 | Banner | Máy bạn đang ở múi giờ {tz thiết bị}, cài đặt đang là {tz}. Đổi sang {tz thiết bị} · Giữ {tz} |
| MSG-24 | Inline dưới trường | Áp dụng từ ngày làm việc kế tiếp ({ngày}) |
| MSG-25 | Inline | Ngưỡng khối lượng từ 1 đến 24 giờ |
| MSG-26 | Toast | Chưa lưu được cài đặt. Thử lại |
| MSG-27 | Inline | Tên hiển thị từ 1 đến 80 ký tự |
| MSG-28 | Inline | Ảnh đại diện JPG hoặc PNG, tối đa 2 MB |
| MSG-29 | Inline | Mật khẩu hiện tại chưa đúng |
| MSG-30 | Toast | Đã đổi mật khẩu. Các thiết bị khác đã được đăng xuất |
| MSG-31 | Inline | Đã gửi mã tới {email mới}. Email đăng nhập chỉ đổi khi bạn nhập đúng mã |
| MSG-32 | Inline | Không đổi được sang email này |
| MSG-33 | Toast | Đã đổi email đăng nhập thành {email}. Các thiết bị khác đã được đăng xuất |
| MSG-34 | Toast | Đã đăng xuất {n} thiết bị khác |
| MSG-35 | Inline | Đang chuẩn bị dữ liệu. Chúng tôi sẽ gửi email khi xong (tối đa 24 giờ) |
| MSG-36 | Inline | Đã có một yêu cầu xuất dữ liệu đang xử lý |
| MSG-37 | Inline (bản sau) | Bạn là chủ sở hữu của workspace còn thành viên khác. Hãy chuyển quyền sở hữu hoặc xoá workspace trước · Chuyển quyền sở hữu · Xoá workspace |
| MSG-38 | Màn hình | Tài khoản đã được xoá. Dữ liệu sẽ bị xoá vĩnh viễn trong vòng 30 ngày |
| MSG-39 | Inline | Gõ "XOÁ" để xác nhận |
| MSG-40 | Dialog | Còn {n} thay đổi chưa đồng bộ trên thiết bị này. Đăng xuất bây giờ sẽ xoá các thay đổi đó · Huỷ · Vẫn đăng xuất |
| MSG-41 | Toast | "{tên cài đặt}" vừa được đổi trên thiết bị khác thành {giá trị}. Thay đổi của bạn ở mục này chưa được lưu |
| MSG-42 | Màn hình | Đã huỷ việc đổi email. Mọi thiết bị đã được đăng xuất. Chúng tôi đã gửi link đặt lại mật khẩu tới {email cũ} |
| MSG-43 | Màn hình | Link đã hết hạn hoặc đã được dùng. Nếu bạn không yêu cầu đổi email, hãy liên hệ hỗ trợ |
| MSG-44 | Inline | Đang chuẩn bị bản xuất dữ liệu. Bạn có thể xoá tài khoản sau khi bản xuất sẵn sàng |
| MSG-45 | Inline (bản sau) | Bạn sẽ rời {workspace}. {n} task được giao cho bạn chưa xong sẽ trả về người giao. Gói của workspace không bị huỷ |
| MSG-46 | Inline | Chọn ít nhất 1 ngày làm việc |
| MSG-47 | Màn hình | Điều khoản sử dụng / Chính sách quyền riêng tư đã cập nhật ngày {ngày}. Đọc và đồng ý để tiếp tục dùng app |
| MSG-48 | Dialog | Rút lại đồng ý xử lý dữ liệu đồng nghĩa với việc chúng tôi không thể tiếp tục cung cấp dịch vụ. Tài khoản và dữ liệu sẽ bị xoá trong 30 ngày · Xuất dữ liệu trước · Huỷ · Rút lại đồng ý |
| MSG-49 | Overlay SCR-01 / SCR-03 | Hãy hoàn tất đăng nhập {Google / Microsoft} trong trình duyệt vừa mở. App sẽ tự tiếp tục khi xong · Huỷ |
| MSG-50 | SCR-03 | Chưa nhận được kết quả đăng nhập từ trình duyệt. Thử lại, hoặc đăng nhập bằng email và mật khẩu |
| MSG-51 | Inline SCR-11 #6 · email (UC-08 E2; B40) | Chưa tạo được bản xuất dữ liệu. Hãy tạo bản xuất mới |
| MSG-52 | Trang web SCR-19 (UC-08 E3; C38) | Link này thuộc tài khoản khác. Đăng nhập đúng tài khoản để tải |
| MSG-53 | Nhãn nút SCR-11 #6 (UC-08 A2, E2; C38) | Tạo bản xuất mới |
| MSG-54 | Inline dialog MSG-48 (UC-11 E2; C41) | Đang chuẩn bị bản xuất dữ liệu. Bạn có thể rút lại đồng ý sau khi bản xuất sẵn sàng |

Bản EN: `[chờ bổ sung]`.

## 10. Yêu cầu phi chức năng

| **Mục** | **Yêu cầu** `[giả định]` |
| --- | --- |
| Hiệu năng | \[AuthLogin\] / \[AuthSignup\] p95 ≤ 800 ms (gồm băm Argon2id); \[SettingsUpdate\] p95 ≤ 300 ms; cài đặt áp dụng trên giao diện ≤ 100 ms; mỗi bước onboarding chuyển ≤ 500 ms; email mã / link tới hộp thư ≤ 1 phút (p95) |
| Nền tảng | 1.0: app Windows (Flutter), một người dùng, dữ liệu trên cloud (ADR-0005). Phiên bản Windows tối thiểu, cách cài / cập nhật app: tech chốt — `docs/tech/`. Web, macOS (1.1) và iOS / Android (1.2) dùng cùng quy tắc nghiệp vụ |
| Offline | Đăng ký, đăng nhập, đổi mật khẩu / email, xuất, xoá, đồng ý cần mạng. Cài đặt nhóm Chung / Hiển thị / Lịch làm việc / Phím tắt đổi được khi mất mạng, đồng bộ sau. Dữ liệu offline của app trên máy Windows được mã hoá, gắn `userId`. Chủ động đăng xuất xoá dữ liệu offline sau cảnh báo; bị đăng xuất từ xa giữ hàng đợi đã mã hoá (BR-18, QC-08 mục 6) |
| Đồng bộ | `settings.changed`, `session.revoked` tới thiết bị khác ≤ 5 giây; xung đột cài đặt theo từng trường (BR-12, QC-08) |
| Bảo mật | HTTPS bắt buộc; Argon2id cho mật khẩu; PKCE + `state` cho OAuth; OAuth trên app desktop qua trình duyệt hệ thống, không dùng cửa sổ nhúng (BR-25); token trên app Windows lưu trong kho bảo mật của hệ điều hành (tech chốt); refresh token xoay vòng, phát hiện dùng lại (BR-08); chống CSRF cho endpoint dùng cookie (web, 1.1); rate limit 10 lần đăng nhập / phút / IP, 600 req / phút / user; mã và token chỉ lưu dạng băm; phản hồi đăng ký / quên mật khẩu không lộ email (BR-04) |
| Quyền riêng tư, tuân thủ | Lưu bản đồng ý, rút lại và xin lại đồng ý (BR-06, BR-23); xuất ≤ 24 giờ, xoá ≤ 30 ngày gồm cả bản sao lưu theo chu kỳ, trừ ngoại lệ lưu giữ BR-20 (hoá đơn, chứng từ 10 năm; nhật ký bảo mật 1 năm, ẩn danh); Nghị định 13/2023/NĐ-CP và GDPR chờ pháp chế xác nhận. Nơi lưu dữ liệu: bản 1.0 dùng máy chủ khu vực châu Á, không bắt buộc lưu tại Việt Nam; cần hồ sơ đánh giá tác động chuyển dữ liệu cá nhân ra nước ngoài (NĐ 13/2023); pháp chế xác nhận trước phát hành |
| Log / audit | Nhật ký bảo mật theo BR-21, giữ 1 năm, ẩn danh khi tài khoản bị xoá; log hệ thống không chứa mật khẩu, mã, token, nội dung task |
| Tracking | Sự kiện: `signup_started`, `signup_completed` (phương thức), `oauth_browser_cancelled` / `oauth_browser_timeout`, `email_verified`, `unverified_account_replaced`, `login_succeeded` / `login_failed`, `account_locked`, `password_reset_requested` / `_completed`, `email_change_reverted`, `onboarding_step_completed` (bước, bỏ qua?), `onboarding_completed`, `tip_shown` / `tip_dismissed`, `setting_changed` (tên cài đặt, không ghi giá trị cá nhân), `setting_conflict_overwritten`, `work_schedule_changed` (số ngày làm việc), `timezone_banner_action`, `data_export_requested`, `consent_accepted` / `consent_withdrawn`, `account_deleted` (vai trò, có rời / xoá workspace) |
| Accessibility | Form có nhãn, lỗi đọc được bằng trình đọc màn hình (Narrator trên Windows; aria-live trên web 1.1); theo tỉ lệ hiển thị của Windows; ô mã 6 số hỗ trợ dán; điều hướng toàn bộ bằng bàn phím; tương phản đạt WCAG 2.1 AA ở cả giao diện sáng / tối |
