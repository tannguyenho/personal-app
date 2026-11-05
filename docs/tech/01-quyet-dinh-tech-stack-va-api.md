# Quyết định tech stack & API — Wakeup 1.0

Trạng thái: **đã chốt** qua buổi grill tech ngày 05/11/2026 (Q1–Q41). Tài liệu này trả lời các câu hỏi ở [`00-cau-hoi-tech-stack-va-api.md`](00-cau-hoi-tech-stack-va-api.md). Quyết định khó đảo ngược ghi thêm ở [ADR-0006](../adr/0006-backend-dart-va-dong-bo-theo-lenh.md), [ADR-0007](../adr/0007-ha-tang-vps-singapore.md), [ADR-0008](../adr/0008-hop-dong-design-code-thay-code-connect.md), [ADR-0009](../adr/0009-rui-ro-dieu-khoan-claude-code-va-che-do-api-key.md).

Phần "API", "mã lỗi", "job" trong các SRS vẫn là hợp đồng nghiệp vụ. Tài liệu này quy định cách hiện thực các hợp đồng đó.

## 0. Bối cảnh

| Mục | Giá trị |
|---|---|
| Người làm | Một người, cùng AI (Q1) |
| Quy mô Beta | Khoảng 20 người dùng (Q2) |
| Hạ tầng | VPS Ubuntu 2 CPU / 2 GB RAM có sẵn, đặt ở **Singapore**; tăng cấu hình khi cần (Q2, Q11) |
| Tên sản phẩm | **Wakeup** (Q39). Mã tài liệu giữ `PLN-PRD-Gxx` / `PLN-SRS-Gxx` |

Nguyên tắc chọn: ít thành phần nhất có thể, một ngôn ngữ chính (Dart) để dùng chung logic giữa client và server, mọi thứ chạy vừa VPS 2 GB.

## 1. Domain và môi trường

| Mục đích | Địa chỉ |
|---|---|
| Trang web tối giản (xác minh email, đặt lại mật khẩu, "Không phải tôi", tải bản xuất, huỷ đăng ký email, chính sách quyền riêng tư); web 1.1 sau này | `wakeup.tannguyenho.tech` |
| API, WebSocket, webhook lịch | `api.wakeup.tannguyenho.tech` |
| Staging | `staging.wakeup.tannguyenho.tech`, `api.staging.wakeup.tannguyenho.tech` |
| Email gửi đi | `no-reply@wakeup.tannguyenho.tech` (SPF, DKIM, DMARC) |

- Hai môi trường **prod** và **staging** chạy trên cùng VPS, mỗi môi trường một stack Docker Compose và một database riêng. Staging dùng OAuth client và webhook riêng (Q30).
- Máy dev: Postgres chạy bằng Docker.
- `tannguyenho.tech` phải được xác minh trên Google Search Console để nộp xác minh OAuth (Q38).

## 2. Cấu trúc repo

Monorepo ngay trong repo này, dùng pub workspaces (Q28):

```
apps/
  desktop/        # app Flutter Windows (wakeup_desktop)
    lib/ds/       # thư viện widget design system (ADR-0008)
  server/         # backend shelf (wakeup_server), migration ở db/migrations
  web-mini/       # trang web tối giản, HTML tĩnh do Caddy phục vụ
packages/
  core/           # wakeup_core: logic nghiệp vụ, DTO, lệnh, mã lỗi dùng chung
  ds_tokens/      # wakeup_ds_tokens: tokens.json, script xuất Figma, code sinh ra
deploy/           # Docker Compose, Caddyfile, sao lưu
docs/             # PRD, SRS, ADR, tech
```

## 3. Client — app Windows (Flutter)

| Mục | Quyết định |
|---|---|
| Hệ điều hành | Windows 10 22H2 trở lên và Windows 11, chỉ **x64**; ARM64 làm sau (Q7) |
| State | Riverpod (Q15) |
| Điều hướng | go_router |
| Lưu trữ trên máy | Drift (SQLite) + **SQLCipher**, khoá bảo vệ bằng Windows DPAPI. Hàng đợi offline nằm trong DB này, đã mã hoá và gắn `userId` (QC-08 mục 6) |
| Kiến trúc thư mục | Theo nhóm tính năng G01..G10, mỗi nhóm có `data/`, `domain/`, `ui/`. Logic dùng chung với server nằm trong `wakeup_core` |
| Khay hệ thống, cửa sổ | `tray_manager` + `window_manager`. Đóng cửa sổ khi timer đang chạy thì thu về khay, timer chạy tiếp (D13) |
| Phím tắt toàn cục | `hotkey_manager`: Ctrl+Shift+A thêm task, Ctrl+Shift+Space timer (D11) |
| Thông báo | `local_notifier`: thông báo Windows cho nhắc ritual và nhắc timer > 4 giờ (D12) |
| Mở cùng Windows | `launch_at_startup`, tuỳ chọn trong Cài đặt |
| Projection, sức chứa | Tính ngay trong app từ dữ liệu Drift, không có tiến trình nền riêng (Q34) |
| Token trên máy | Windows Credential Manager |

### Đóng gói, ký số, cập nhật

- Bộ cài **Inno Setup**, cài theo từng người dùng (không cần quyền admin). Chưa lên Microsoft Store (Q6).
- Ký số bằng **Azure Trusted Signing** cho cả bộ cài và file exe.
- Tự cập nhật: app gọi `GET /v1/app/latest`; bộ cài đã ký và feed appcast đặt trên R2, dùng package `auto_updater` (WinSparkle). Cập nhật là tuỳ chọn, trừ khi server trả `CLIENT_TOO_OLD` (Q33).

## 4. AI — Claude Code CLI và MCP local

Áp dụng QC-12 và ADR-0004.

### Phát hiện CLI

- Tìm bằng `where claude`, kiểm tra phiên bản tối thiểu bằng `claude --version`.
- Trạng thái đăng nhập: gọi thử một lệnh rất nhỏ, đọc mã lỗi trả về.

### App gọi CLI (chat, Planning Agent, highlights, gợi ý)

```
claude -p --output-format stream-json --input-format stream-json \
  --mcp-config <file tạm chứa URL + token> --strict-mcp-config \
  --allowedTools "mcp__wakeup__*"
```

- Phiên do app mở **tắt mọi công cụ khác** (Bash, đọc / ghi file, web). Claude chỉ điều khiển được app, không chạm vào máy người dùng.
- Model theo cấu hình Claude Code của người dùng; bản 1.0 chưa có màn chọn model.

### MCP server local

- App chạy MCP server qua **HTTP** trên `127.0.0.1`, cổng ngẫu nhiên, có **token riêng cho mỗi lượt cài** (Q8). Không nghe trên địa chỉ nào khác.
- Phiên do app mở: truyền URL + token qua `--mcp-config`.
- Dùng từ terminal: app đăng ký server tên `wakeup` vào Claude Code ở phạm vi người dùng (kèm header token). Khi app tắt, Claude Code báo không kết nối được.
- Tắt trợ lý AI thì MCP server ngừng nhận kết nối (QC-12 mục 7).

### Chip AI và Hoàn tác theo lượt

- Mọi lệnh do AI gửi (MCP → app → hàng đợi lệnh) mang `actor = ai` và `aiTurnId` (Q25).
- Server lưu trạng thái trước của từng thay đổi. "Hoàn tác lượt" sinh lệnh nghịch cho cả `aiTurnId`, giữ đúng D9 (lỗi giữa chừng thì giữ phần đã áp dụng, Hoàn tác được cả lượt).
- Mục nào người dùng đã sửa tay sau đó thì Hoàn tác mục đó bị từ chối kiểu `VERSION_CONFLICT`.
- Chip AI trên card hiển thị dựa trên `actor`.

### Điều khoản Anthropic và phương án dự phòng

- PO **chấp nhận rủi ro điều khoản** và không chờ xác nhận pháp lý (ADR-0004, ticket #25).
- App **không xử lý đăng nhập Claude**: không nhúng trang đăng nhập, không nhận, đọc hay lưu token hoặc API key; chỉ hướng dẫn người dùng tự chạy lệnh đăng nhập của Claude Code.
- Phương án dự phòng nếu Anthropic chặn dùng gói claude.ai: chỉ bật AI trong app khi Claude Code đăng nhập bằng API key của người dùng, do người dùng tự cấu hình trong Claude Code (ADR-0009).
- Không dùng tên hoặc logo Claude Code / Anthropic làm tên sản phẩm, tính năng hay nút; chỉ ghi chữ thường "chạy bằng Claude Code".

### Bản ghi phiên của Claude Code (C30)

Khi bật trợ lý AI và ở màn xoá tài khoản, app hiện dòng: "Bản ghi phiên do Claude Code lưu trên máy (`~/.claude/projects`) không bị app xoá", kèm nút mở thư mục (Q36).

### AI trên web và di động

**Chưa chốt** (Q37). Hai hướng: AI phía server dùng API key của app, hoặc web gọi tới app desktop đang chạy. Cần quyết trước khi làm 1.1.

## 5. Backend và dữ liệu

| Mục | Quyết định |
|---|---|
| Ngôn ngữ | **Dart** (Q9, ADR-0006) |
| Framework | `shelf` + `shelf_router` + `shelf_web_socket` (Q17) |
| Truy cập DB | Package `postgres`, viết **SQL tay** |
| Migration | File SQL đánh số, chạy bằng **dbmate** |
| Database | PostgreSQL chạy cùng VPS, giới hạn khoảng 512 MB RAM; VPS thêm swap 2 GB (Q10) |
| Sao lưu | `pg_dump` mỗi đêm, đẩy lên Cloudflare R2 hoặc Backblaze B2, giữ 30 ngày. Thử khôi phục ít nhất một lần trước Beta |
| Triển khai | Docker Compose: backend + Postgres + **Caddy** (TLS tự động, phục vụ `web-mini`). Đẩy tag thì GitHub Actions build image và SSH deploy (Q12) |

### Thời gian

- Mọi thời điểm lưu `timestamptz` theo UTC. Timezone người dùng lưu tên IANA (Q31).
- Ngày dự định của task lưu kiểu `date`, không có giờ.
- `workday()` (QC-01) nằm trong `wakeup_core`, dùng package `timezone` với **cùng một phiên bản dữ liệu tz** ở client và server.

### Job nền

- Scheduler chạy ngay trong tiến trình backend, mỗi phút quét bảng `jobs`. Lease bằng `SELECT … FOR UPDATE SKIP LOCKED`, có retry và chạy bù. Không dùng Redis hay hàng đợi riêng (Q21).
- **Rollover**: mỗi phút tìm người dùng vừa qua mốc đầu ngày theo timezone của họ. Lượt chạy quá 5 phút coi như chưa chạy; sau 3 lần lỗi chuyển "thất bại" (B6).
- Khi mở app, client gọi `RolloverEnsure` để chạy bù nếu job trễ.
- Sinh instance lặp, gia hạn webhook lịch cũng là job trong bảng `jobs`.
- **Healthchecks.io** nhận nhịp từ job rollover để cảnh báo, phục vụ mục tiêu 95% xong trong 15 phút.

### Xoá dữ liệu

Xoá tài khoản thì hard-delete ngay trong DB. Dữ liệu còn trong bản sao lưu tự hết sau 30 ngày; chính sách quyền riêng tư ghi rõ điều này (Q36).

## 6. Đồng bộ và API

### Mô hình đồng bộ: hàng đợi lệnh (Q4, ADR-0006)

1. Client ghi lệnh nghiệp vụ vào hàng đợi trên máy, áp lạc quan lên Drift.
2. Client gửi lô lệnh `POST /v1/commands`. Mỗi lệnh có `{commandId, type, payload, baseVersion, schemaVersion}`.
3. Server kiểm tra từng lệnh theo QC-08: từ chối `VERSION_CONFLICT` khi cụm vị trí đã đổi, `TASK_DELETED`, `ALREADY_REPEATING`…; các trường khác gộp theo từng trường, bản server nhận sau thắng.
4. Lệnh hợp lệ được áp và gán **số thứ tự toàn cục** của server. Thao tác của job hệ thống cũng tăng phiên bản (QC-08 mục 1).
5. Client kéo thay đổi bằng `GET /v1/changes?cursor=N`.
6. Một **WebSocket** chỉ báo "có thay đổi, cursor=N"; client tự kéo về (Q18).
7. Rollover tạm trên máy chỉ để hiển thị, không vào hàng đợi (QC-08 mục 5).

### Quy ước API

| Mục | Quyết định |
|---|---|
| Kiểu | Đồng bộ qua `commands` / `changes`; phần còn lại (auth, cài đặt, kết nối lịch, xuất dữ liệu, `app/latest`) là REST thường, tiền tố `/v1` |
| Hợp đồng | DTO và lệnh định nghĩa trong `wakeup_core` (freezed + json_serializable khi DTO nhiều lên; khung hiện viết tay `toJson` / `fromJson`). Bản 1.0 **không** làm OpenAPI vì client duy nhất là Dart |
| Lỗi | `{error: {code, message, details}}`. `code` là enum trong `wakeup_core` (`VERSION_CONFLICT`, `TASK_DELETED`, `PAST_DATE`, `CLIENT_TOO_OLD`…). Client ánh xạ `code` sang MSG của SRS; `message` chỉ để debug (Q19) |
| Idempotency | `commandId` (UUIDv7) là khoá idempotency, server lưu 30 ngày. Gửi lại cùng lệnh nhận lại đúng kết quả cũ (Q20) |
| Phân trang | Cursor, không dùng offset |
| Rate limit | Chặn trong tiến trình cho đăng nhập, đặt lại mật khẩu, gửi email. Chưa cần Redis |
| Tương thích | Client gửi header `X-App-Version`. Server có `minClientVersion`; app cũ hơn nhận `CLIENT_TOO_OLD` và bị buộc cập nhật. Lệnh offline mang `schemaVersion` (Q32) |

## 7. Xác thực và tích hợp

### Xác thực (Q13)

- Tự viết. Mật khẩu băm **argon2id**.
- Access token khoảng 15 phút; refresh token xoay vòng, lưu theo từng phiên trong DB để thu hồi được (`session.revoked`, "Không phải tôi").
- Google / Microsoft đăng nhập trên desktop theo luồng **loopback + PKCE** (mở trình duyệt hệ thống, app nghe trên `127.0.0.1`).
- Link trong email mở trang tối giản trên `wakeup.tannguyenho.tech`, xử lý xong thì gợi ý mở app (Q5).

### Email (Q14)

**Resend** (gói miễn phí 3.000 email/tháng), địa chỉ gửi `no-reply@wakeup.tannguyenho.tech`, cấu hình SPF, DKIM, DMARC.

### Lịch Google / Outlook (Q22)

| Nguồn | Cách nhận thay đổi | Gia hạn |
|---|---|---|
| Google Calendar | Watch channel (push) + `syncToken` để đồng bộ dần | Gia hạn channel trước khi hết hạn (khoảng 7 ngày) |
| Outlook (Microsoft Graph) | Subscription + delta query | Gia hạn subscription (khoảng 3 ngày) |
| Cả hai | Poll dự phòng mỗi 15 phút | — |

Webhook nhận qua `api.wakeup.tannguyenho.tech` sau Caddy.

### Xác minh OAuth (Q16)

- **Google**: Beta để ứng dụng ở chế độ **Production nhưng chưa xác minh** (người dùng thấy màn cảnh báo, giới hạn 100 người). Không dùng chế độ Testing vì refresh token hết hạn sau 7 ngày. Chủ dự án tự nộp hồ sơ xác minh ngay sau khi dựng xong trang web tối giản và chính sách quyền riêng tư. Scope Calendar là "sensitive", không cần CASA. Gmail (1.1) là "restricted", cần CASA.
- **Microsoft**: đăng ký ứng dụng đa tenant; xác minh nhà phát hành nếu muốn bỏ cảnh báo "unverified publisher".

## 8. Design system — Figma ↔ Flutter

Code Connect **không dùng được** trên gói Figma hiện tại (Education). Đã chạy thử ngày 05/11/2026: CLI template với `label: Flutter`, `language: dart` parse đúng, nhưng mọi lệnh Code Connect đều bị từ chối vì cần gói Organization / Enterprise. Thay bằng lớp hợp đồng design ↔ code (Q35, Q40, ADR-0008):

1. **Token 1-1.** Script Plugin API xuất toàn bộ Variables (collection, mode, alias) ra `packages/ds_tokens/tokens.json`. Bộ sinh code map tên 1-1: bỏ tên collection, các đoạn còn lại nối camelCase, `color/bg/primary` → `DsColors.bgPrimary`. Mỗi mode (light / dark) là một `ThemeExtension`; alias giữ là tham chiếu, không làm phẳng.
2. **Component 1-1.** Script Plugin API xuất component set (tên, property, variant, giá trị mặc định, slot) ra `components.json`. Bộ sinh code tạo enum và kiểu tham số Dart (`DsButtonVariant { primary, secondary }`); widget bắt buộc dùng các kiểu này. Quy ước tên: component `Button` ↔ widget `DsButton`, property / variant trùng tên tham số, slot ↔ `child` / `leading`.
3. **CI chặn lệch**: so `tokens.json` / `components.json` với code đã sinh; lệch thì báo đỏ. Lint cấm `Color(0x…)` và số khoảng cách cứng bên ngoài `ds_tokens`.
4. **Plugin Codegen** riêng hiện snippet Dart trong Dev Mode Inspect. Nếu gói Education chặn plugin codegen thì nâng lên gói Organization để dùng Code Connect.
5. **Description** của mỗi component ghi tên widget và đường dẫn file `.dart`, để AI đọc qua Figma MCP.
6. **Widgetbook** cho thư viện widget, kèm golden test để so hình.

File sandbox: [Wakeup – Code Connect pilot](https://www.figma.com/design/zWidv5HFfFRIR9IrrFFObb) (team "1. Test Init"), giữ lại làm nền cho script xuất hợp đồng và plugin codegen (Q41).

## 9. Chất lượng và vận hành

### Kiểm thử và CI (GitHub Actions — Q26)

| Lớp | Nội dung |
|---|---|
| `wakeup_core` | Unit test; các ca chuẩn QC-01 là golden test |
| Backend | Test tích hợp với Postgres trong service container |
| Desktop | Widget test; bộ `integration_test` smoke trên `windows-latest` |
| Design system | Kiểm tra hợp đồng token / component, golden test Widgetbook |
| Phát hành | Đẩy tag thì build bộ cài Inno, ký số, đẩy lên R2, cập nhật appcast |
| AI | Bộ đánh giá là kịch bản prompt chạy tay trước mỗi bản phát hành (không chạy trong CI vì tốn phí) |

### Giám sát, log, tracking (Q27)

- **Sentry** gói miễn phí cho client và server, bật lọc PII. Dữ liệu lỗi chuyển ra nước ngoài nên ghi vào hồ sơ Nghị định 13/2023.
- Log JSON ra stdout, Docker xoay vòng file log.
- Tracking sản phẩm: ghi sự kiện vào một bảng Postgres riêng, chưa gắn SDK analytics. Chỉ số trong PRD tính bằng SQL.
- Healthchecks.io cho job rollover; kiểm tra uptime cho `api.wakeup.tannguyenho.tech`.

## 10. Còn mở

| Câu hỏi | Cần chốt trước |
|---|---|
| AI trên web và di động (Q37) | Làm 1.1 |
| Cách phát hiện Claude Code đăng nhập bằng gói hay API key, cho phương án dự phòng (ADR-0009) | Làm G10 |
| Chạy thử lại Code Connect trên team Figma thật của Wakeup (`0.1 [App] Multiverse`, xem [`docs/design-system/`](../design-system/00-knowledge-base-components-snowflakes.md)); nếu team đó thuộc gói Organization thì xem lại ADR-0008 | Dựng thư viện widget |
| Gói Education có chạy được plugin Codegen trong Dev Mode không (ADR-0008) | Dựng thư viện widget |
| Hồ sơ Nghị định 13/2023: VPS Singapore, Sentry, Resend, R2 là bên xử lý ở nước ngoài | Phát hành 1.0 |
| Phiên bản Claude Code tối thiểu | Làm G10 |
| Danh sách công cụ MCP và schema chi tiết | Làm G10 (thiết kế trong code, theo SRS G10 mục 3.1) |
