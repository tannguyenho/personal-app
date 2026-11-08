# Knowledge base cho agent — Design system: Component & Snowflake

> Tài liệu này là **nguồn quy tắc cho agent** (Claude, Figma MCP, các skill `uxf-*`) khi đọc, vẽ, đặt tên, phân loại hay bàn giao bất cứ thứ gì trên Figma của dự án **Wakeup** (team Figma `0.1 [App] Multiverse`).
> Nền tảng lý thuyết: Brad Frost — [Design system components, recipes, and snowflakes](https://bradfrost.com/blog/post/design-system-components-recipes-and-snowflakes/).
> **Khác có chủ đích so với bài gốc:** dự án **không dùng tầng Recipe**. Mọi thứ không đủ chuẩn để vào design system đều là **Snowflake**.

---

## 1. Hai tầng duy nhất

| Tầng | Định nghĩa | Ví dụ | Nằm ở đâu trên Figma |
|---|---|---|---|
| **Design system component** (gọi tắt **DS component**) | Khối giao diện dùng chung, **không phụ thuộc nội dung** (content-agnostic) và **không phụ thuộc ngữ cảnh** (context-agnostic), thiết kế để tái sử dụng tối đa ở nhiều sản phẩm. | Button, Input, Select, Checkbox, Card, Accordion, Table, Modal, Toast, Avatar | Team **`0. [Design System] Multiverse`** |
| **Snowflake** | Mọi component **gắn với sản phẩm / nghiệp vụ** của app: ghép từ DS component, mang nội dung hoặc ngữ cảnh cụ thể, dù dùng 1 lần hay nhiều lần trong app. | TaskCard, TimeboxBlock, DayColumn, RolloverBadge ("Dời n ngày"), RitualStepper, FocusTimer, ChannelPill | Team **`0.1 [App] Multiverse`** → folder **`[Library] Snowflake`** |

Quy tắc gộp Recipe: trong bài gốc, "Recipe" là tổ hợp DS component dùng lặp lại trong một sản phẩm (ProductCard, AddressField). Ở dự án này, **Recipe được xếp vào Snowflake**. Không tạo tầng, thư mục, page hay tiền tố tên "Recipe".

Câu nhắc: *"Everything is a component."* — mọi thứ đều phải là component; câu hỏi chỉ là nó thuộc tầng nào.

---

## 2. Bản đồ Figma

```
Figma
├── Team: 0. [Design System] Multiverse          ← DS component (library publish)
│
└── Team: 0.1 [App] Multiverse
    ├── 📁 [Library] Snowflake                    ← Snowflake (library publish, dùng DS library)
    │     └── ❄️ [Snowflake] Wakeup
    ├── 📁 [Concept] Sandbox                      ← nháp, khám phá, thử ý tưởng
    │     └── 🖼️ [Concept] Wakeup
    └── 📁 [Handoff] App                          ← file bàn giao cho dev
          └── ✅ [Handoff] Wakeup
```

| File | Folder | Link |
|---|---|---|
| ❄️ [Snowflake] Wakeup | [Library] Snowflake (`684592635`) | https://www.figma.com/design/gIBgLQIAiWUjZ1wHb04tZb |
| 🖼️ [Concept] Wakeup | [Concept] Sandbox (`684598335`) | https://www.figma.com/design/FJZvjhtEzGYGSLFGugHOUz |
| ✅ [Handoff] Wakeup | [Handoff] App (`684598523`) | https://www.figma.com/design/CUyptdjG4M9V33uELkgImV |

Tên file theo mẫu `<emoji> [<Loại>] <Tên dự án>`: ❄️ Snowflake, 🖼️ Concept, ✅ Handoff.

### 2.1 Vai trò từng folder

| Folder | Mục đích | Được phép | Không được phép |
|---|---|---|---|
| **[Library] Snowflake** | Thư viện snowflake của app, **publish** thành library | Tạo main component snowflake; dùng instance DS component; variant, property, description đầy đủ | Định nghĩa lại DS component (copy Button rồi sửa); detach DS instance để chỉnh style; để màn hình/flow lẫn vào page component (màn hình đặt ở nhóm `🖥️ SCREEN`) |
| **[Concept] Sandbox** | Thử ý tưởng, concept, wireframe, khám phá hướng | Mọi thứ: detach, vẽ tay, component local tạm, nhiều phương án | Publish library; để file Handoff hay Snowflake tham chiếu sang Sandbox |
| **[Handoff] App** | Màn hình chốt để dev làm | Chỉ dùng **instance** từ DS library và Snowflake library | Tạo main component local; detach instance; dùng giá trị màu/chữ/khoảng cách cứng thay vì variable / style |

### 2.2 Chiều phụ thuộc (chỉ đi một chiều)

```
DS library  ──►  Snowflake library  ──►  Handoff App
     ▲                  ▲
     └──── Sandbox (được dùng cả hai, nhưng không ai được dùng Sandbox)
```

- DS library **không bao giờ** dùng snowflake.
- Snowflake dùng DS, không dùng snowflake của sản phẩm khác.
- Handoff chỉ dùng DS + Snowflake.

---

## 3. Cây quyết định: thứ này thuộc tầng nào?

Agent hỏi lần lượt, dừng ở câu trả lời đầu tiên khớp:

1. **Đây có phải một màn hình / flow hoàn chỉnh không?**
   → Có: không phải component. Đặt ở `🖥️ SCREEN` (Snowflake file) hoặc `🦶 USER FLOW` (Handoff file).
2. **DS library đã có component đáp ứng được (kể cả qua variant / property / slot) chưa?**
   → Có: dùng instance DS. Không tạo mới.
3. **Component này có mang tên, nội dung, dữ liệu hay luật nghiệp vụ của app không?** (ví dụ: task, timebox, ritual, channel, rollover, objective)
   → Có: **Snowflake**.
4. **Có ít nhất 2 sản phẩm / ngữ cảnh khác nhau cần dùng nó, và nó có thể đặt tên mà không nhắc tới nghiệp vụ không?**
   → Có: đề xuất **DS component** (xem mục 4 — quy trình đề xuất).
   → Không: **Snowflake**.

Mặc định khi phân vân: **Snowflake**. Đưa nhầm một thứ đặc thù sản phẩm vào DS làm thư viện "noisy and messy" và tốn công dọn sau; đưa nhầm vào Snowflake thì nâng cấp lên dễ.

Mặc định khi *thiết kế*: dù đặt ở tầng nào, luôn hỏi "làm sao để nó tái sử dụng và trung lập nhất có thể" — tách nội dung ra property / slot, không gắn text cứng.

---

## 4. Di chuyển giữa các tầng

### 4.1 Nâng Snowflake → DS component (promote)

Điều kiện, phải thoả **tất cả**:

- Đã có ≥ 2 nơi dùng thật (2 sản phẩm, hoặc 2 nhóm nghiệp vụ không liên quan).
- Đặt được tên chung, không chứa thuật ngữ nghiệp vụ (`TaskCard` → không đạt; `ListItemCard` → đạt).
- Mọi nội dung là property / slot; không còn text hay icon cố định.
- Chỉ dùng variable / style của DS (không giá trị cứng).

Các bước:

1. Ghi đề xuất (tên mới, lý do, nơi đang dùng) vào page `🚧 DESIGN QA` của file Handoff hoặc gửi DS owner.
2. DS owner dựng component ở team `0. [Design System] Multiverse`, publish.
3. Trong `[Library] Snowflake`: snowflake cũ được viết lại thành **instance của DS component mới** hoặc bị deprecate; swap instance ở Handoff (dùng skill `uxf-component-migrator`).
4. Ghi vào `📋 CHANGE LOG` của file Handoff.

### 4.2 Hạ DS component → Snowflake (demote)

Khi một DS component bị phát hiện chỉ một sản phẩm dùng, hoặc mang luật nghiệp vụ: chuyển sang `[Library] Snowflake`, swap instance, rồi deprecate trong DS. Không xoá DS component trước khi swap xong.

### 4.3 Từ Sandbox ra ngoài

Ý tưởng ở Sandbox **không được copy-paste** sang Snowflake hay Handoff. Khi concept được chốt:

1. Phân loại từng phần theo mục 3.
2. Phần DS: dùng instance có sẵn hoặc đề xuất DS mới.
3. Phần snowflake: dựng lại sạch trong `[Library] Snowflake` (theo skill `uxf-component-manager`), publish.
4. Lắp màn hình trong `[Handoff] App` chỉ bằng instance.

---

## 5. Cấu trúc page trong từng file

### 5.1 File trong `[Library] Snowflake` — theo skill `uxf-snowflake-page-manager`

```
🖼️ COVER
---
📦 BASE
    → [Base Component]
---
🍀 COMPONENT
    → [Component]          (A–Z)
---
🖥️ SCREEN
    → [Screen]
```

- `📦 BASE`: component nền `Base / ...` dùng để dựng snowflake khác (ẩn khỏi người dùng library nếu được).
- `🍀 COMPONENT`: snowflake người dùng library kéo ra dùng.
- `🖥️ SCREEN`: màn hình ví dụ lắp từ snowflake để kiểm tra, không phải component.

### 5.2 File trong `[Handoff] App` — theo skill `uxf-handoff-page-manager`

```
📋 CHANGE LOG
---
🦶 USER FLOW
    🔹 Gxx. [Nhóm nghiệp vụ]
        → Gxx.n - [Flow]
---
📐 UI GUIDELINE
    → [Guideline]
---
🚧 DESIGN QA
---
🖼️ COVER
```

Nhóm nghiệp vụ dùng mã nhóm tính năng của dự án (`G01`…`G12` trong `docs/00-danh-muc-nhom-tinh-nang.md`) để dev đối chiếu với PRD / SRS. Thuật ngữ trên màn hình theo `CONTEXT.md`.

### 5.3 File trong `[Concept] Sandbox`

Không ép cấu trúc bên trong. File mặc định:

```
🖼️ COVER          ← ghi trạng thái: Đang khám phá / Đã chốt → chuyển Handoff / Bỏ
---
💡 EXPLORATION    ← thêm sub-page `→ <chủ đề>` tuỳ ý
```

---

## 6. Đặt tên

| Thứ | Quy tắc | Ví dụ |
|---|---|---|
| DS component | Tên chung, tiếng Anh, PascalCase, không chứa thuật ngữ nghiệp vụ | `Button`, `ListItem`, `DatePicker` |
| Snowflake | Tiếng Anh, PascalCase, **được phép** chứa thuật ngữ nghiệp vụ | `TaskCard`, `TimeboxBlock`, `RolloverBadge` |
| Base của snowflake | `Base / <Tên>` | `Base / TaskRow` |
| Widget Flutter tương ứng | DS component thêm tiền tố `Ds`; Snowflake giữ đúng tên, không tiền tố; Base và element không có widget riêng ([`packages/ds_tokens`](../../packages/ds_tokens/README.md)) | `Button` → `DsButton`, `TaskCard` → `TaskCard` |
| Page | Emoji ở page nhóm; sub-page dùng `→ ` (mũi tên), Title Case | `→ Task Card` |
| Component | **Cấm** emoji, cấm chữ `Recipe` | — |

Chi tiết property / variant / description của từng component: theo skill `uxf-component-manager`.

---

## 7. Checklist agent chạy trước khi báo "xong"

**Khi tạo / sửa component**

- [ ] Đã chạy cây quyết định (mục 3) và ghi tầng vào description.
- [ ] Không định nghĩa lại thứ DS đã có.
- [ ] Không detach instance DS.
- [ ] Màu, chữ, khoảng cách, bo góc dùng variable / style của DS.
- [ ] Nội dung là property / slot, không text cứng.
- [ ] Đặt đúng file, đúng page nhóm.

**Khi dựng màn hình Handoff**

- [ ] 100 % là instance từ DS library hoặc Snowflake library; 0 main component local.
- [ ] Không tham chiếu file trong Sandbox.
- [ ] Màn hình nằm đúng nhóm `Gxx` và có ghi chú link PRD / SRS tương ứng.
- [ ] Đã cập nhật `📋 CHANGE LOG`.

---

## 8. Sai lầm thường gặp (anti-pattern)

| Sai | Đúng |
|---|---|
| Thêm `TaskCard` vào DS vì "dùng ở nhiều màn hình" | Nhiều màn hình trong **cùng app** vẫn là Snowflake |
| Tạo thư mục / page "Recipes" | Không có tầng Recipe; xếp vào Snowflake |
| Copy Button từ DS vào Snowflake rồi đổi màu | Dùng variant có sẵn, hoặc đề xuất variant mới cho DS |
| Vẽ component trực tiếp trong file Handoff | Dựng ở `[Library] Snowflake`, publish, rồi dùng instance |
| Kéo frame từ Sandbox sang Handoff | Dựng lại sạch theo mục 4.3 |
| Đặt màn hình ví dụ vào page `🍀 COMPONENT` | Đặt ở `🖥️ SCREEN` |

---

## 9. Thuật ngữ

| Thuật ngữ | Nghĩa trong dự án | Tránh dùng |
|---|---|---|
| DS component | Component trong team `0. [Design System] Multiverse` | atom/molecule (khi nói về tầng lưu trữ) |
| Snowflake | Component đặc thù app, trong `[Library] Snowflake` | recipe, pattern, custom component |
| Instance | Bản dùng của một main component | bản copy |
| Promote / Demote | Nâng snowflake lên DS / hạ DS xuống snowflake | — |
| Sandbox | Không gian nháp, không có giá trị ràng buộc | — |
| Handoff | File bàn giao dev, nguồn sự thật về giao diện | final, bản chốt (khi chưa qua Design QA) |
