# Quy ước vẽ user flow

> **Trạng thái:** nháp, chờ PO duyệt ([ticket #10](https://github.com/tannguyenho/personal-app/issues/10)) · **Bản đồ:** [issue #2](https://github.com/tannguyenho/personal-app/issues/2)
>
> PO chốt ngày 05/11/2026: vẽ user flow bằng **Mermaid trong repo trước**, mỗi SRS một file, đi từ happy case tới edge case. **Chưa tạo FigJam.** Khi chuyển sang FigJam, quy ước ở mục 7 áp dụng.

## 1. Flow dùng để làm gì

Brief (`gxx-*.md`) nói **màn nào, trạng thái nào, chữ gì**. File flow nói **người dùng đi từ đâu tới đâu, bấm gì thì rẽ đi đâu**. Designer đọc sơ đồ để biết phải vẽ những màn / trạng thái nào nối với nhau, và không bỏ sót nhánh lỗi.

Flow **không** định nghĩa lại nghiệp vụ. Mỗi nút trên sơ đồ mang mã của SRS (`UC`, `A#`, `E#`, `SCR`, `MSG`, `BR`) để ai cần thì mở nguồn.

## 2. Tổ chức file

| Quy ước | Ý nghĩa |
|---|---|
| Thư mục | `docs/design-brief/flow/` |
| Tên file | Trùng phần tên của SRS: `srs-g02-quan-ly-task.md` → `flow/g02-quan-ly-task.md` |
| Phạm vi | Chỉ bản 1.0. Nhánh chỉ có từ 1.1 (chế độ chỉ đọc, trial, web…) không vẽ, ghi một dòng "Bỏ (1.1)" ở bảng đối chiếu |
| Đơn vị | **Một use case = một flow.** Tiêu đề mục là `## UC-xx <Tên>`, giữ đúng mã và tên trong SRS |
| Thứ tự trong mỗi UC | 1. **Happy case** (luồng chính) → 2. **Nhánh thay thế và lỗi** (A#, E#) → 3. **Bảng đối chiếu** |
| Flow liên tính năng | Vẽ ở file của tính năng **khởi phát**. File khác chỉ có nút "sang flow khác" trỏ tới đó |
| Nguồn | Đầu file ghi SRS và commit đã đọc. SRS đổi thì sửa flow trong cùng commit |

### Khung một file flow

````markdown
# Flow Gxx <Tên tính năng>

> **Nguồn:** [srs-gxx](../../features/srs-gxx-....md) (commit `xxxxxxx`) · **Brief:** [gxx](../gxx-....md) `[chờ #n]`
> **Quy ước:** [_quy-uoc.md](_quy-uoc.md) · **FigJam:** `[chờ]`

## Mục lục
| UC | Flow | Màn chính | Số nhánh A / E (1.0) |

## UC-01 <Tên>

**Mở đầu:** … **Kết thúc thành công:** … **Kết thúc thất bại:** …

### Happy case
```mermaid
flowchart TD
  …
```

### Nhánh thay thế và lỗi
```mermaid
flowchart TD
  …
```

### Đối chiếu
| Mã | Điều kiện (ngắn) | Kết thúc ở | Thông báo |

## Kiểm tra
- [ ] Mọi A# / E# của UC bản 1.0 có trên sơ đồ hoặc ghi "Bỏ (1.1)".
- [ ] Mọi nút màn hình có mã SCR; mọi nút thông báo có mã MSG.
````

## 3. Ký hiệu

| Loại nút | Cú pháp Mermaid | Ví dụ | Ghi chú |
|---|---|---|---|
| Điểm vào / bắt đầu | Stadium `id(["…"])` | `start(["Cột D · bấm + Thêm task"])` | Ghi **ở đâu** người dùng đang đứng |
| Hành động người dùng | Hình bình hành `id[/"…"/]` | `u1[/"Gõ tiêu đề, Enter"/]` | Động từ, có phím tắt nếu có |
| Màn hình / trạng thái màn | Chữ nhật `id["…"]` | `s1["SCR-01 Ô soạn task<br/>focus ô tiêu đề"]` | Bắt đầu bằng mã `SCR-xx` (hoặc `SCR-xx.Syy` khi brief đã đặt mã trạng thái) |
| Hệ thống xử lý (người dùng không thấy) | Subroutine `id[["…"]]` | `p1[["TaskCreate<br/>cập nhật lạc quan"]]` | Tên API trong SRS, không có ngoặc vuông |
| Rẽ nhánh | Thoi `id{"…?"}` | `d1{"Tiêu đề trống?"}` | Câu hỏi có / không, hoặc liệt kê các trường hợp ở nhãn cạnh |
| Thông báo | Cờ `id>"…"]` | `m1>"MSG-07 · Toast<br/>Đã thêm vào Backlog · Mở Backlog"]` | `MSG-xx · <nơi hiện>` rồi nội dung **nguyên văn** SRS |
| Sang flow khác | Lục giác `id{{"…"}}` | `x1{{"→ G06 · UC-02"}}` | Trỏ tới tính năng và UC; trong cùng file thì `→ UC-04` |
| Kết thúc | Stadium `id(["…"])` + class `done` / `fail` | `ok(["Task trên đầu cột D"])` | Ghi cái người dùng **thấy** khi xong |

**Cạnh (mũi tên)**

| Cạnh | Cú pháp | Dùng cho |
|---|---|---|
| Đậm | `a ==> b` | Bước của happy case |
| Thường | `a -->\|"A1 · dán URL"\| b` | Nhánh thay thế. Nhãn bắt đầu bằng mã A# |
| Đứt | `a -.->\|"E3 · mất mạng"\| b` | Nhánh lỗi. Nhãn bắt đầu bằng mã E# |

**Đặt id nút.** Chữ thường, ngắn, không dấu: `start`, `u1`, `s1`, `p1`, `d1`, `m1`, `x1`, `ok`, `fail`. Nút của nhánh mang mã nhánh: `a1`, `a1m`, `e3`, `e3m`. Không dùng từ `end` làm id hay tên class (Mermaid hiểu là từ khoá).

**Nhãn.** Luôn để trong ngoặc kép. Xuống dòng bằng `<br/>`. Dấu ngoặc kép bên trong nhãn (ví dụ trong MSG) viết `#quot;`. Không dùng emoji hay ký hiệu ✨ / ✓ / ▶ trong nhãn (FigJam import không đọc được); viết chữ thay: "gợi ý AI", "dấu xong".

**Kiểm cú pháp.** Trước khi commit, render mọi khối Mermaid (mermaid-cli hoặc dán vào mermaid.live). Sơ đồ lỗi cú pháp thì GitHub hiện khung báo lỗi thay cho sơ đồ.

## 4. Màu

Màu theo nghĩa của [nền tảng design system](../01-nen-tang-design-system.md) mục 4 (DS-10, DS-11). Màu **luôn đi kèm mã** (A# / E# / MSG) trên nhãn, không dựa vào màu để phân biệt (DS-08).

| Class | Nghĩa | Màu (Mermaid) | Dùng cho |
|---|---|---|---|
| `happy` | Luồng chính | Nền teal nhạt, viền teal | Mọi nút của happy case |
| `alt` | Nhánh thay thế | Nền xám nhạt, viền xám | Nút chỉ có ở nhánh A# |
| `err` | Lỗi | Nền đỏ nhạt, viền đỏ | Nút của nhánh E#, thông báo lỗi |
| `warn` | Cảnh báo, vẫn cho làm | Nền hổ phách nhạt, viền hổ phách | Ví dụ MSG-24 "Ngày này đã có …", due sớm hơn ngày dự định |
| `ai` | AI làm hoặc gợi ý | Nền tím nhạt, viền tím | Bước do trợ lý AI / Claude Code chạy |
| `sync` | Chờ đồng bộ, offline | Nền trắng, viền xám đứt | Hàng đợi trên máy, gửi lại khi có mạng |
| `link` | Sang flow khác | Nền trắng, viền teal đứt | Nút lục giác |
| `done` / `fail` | Kết thúc thành công / thất bại | Viền đậm teal / đỏ | Nút kết thúc |

Chép nguyên khối dưới đây vào **cuối mỗi sơ đồ** (không sửa mã màu ở từng file; muốn đổi thì đổi ở đây rồi thay hàng loạt):

```text
  classDef happy fill:#E6F4F1,stroke:#0F766E,color:#0B3B36
  classDef alt fill:#F1F3F5,stroke:#6B7280,color:#1F2937
  classDef err fill:#FDECEC,stroke:#B42318,color:#5C1010
  classDef warn fill:#FEF4E2,stroke:#B45309,color:#4A2604
  classDef ai fill:#F1ECFD,stroke:#6D28D9,color:#2E1065
  classDef sync fill:#FFFFFF,stroke:#6B7280,stroke-dasharray:4 3,color:#1F2937
  classDef link fill:#FFFFFF,stroke:#0F766E,stroke-dasharray:4 3,color:#0B3B36
  classDef done fill:#E6F4F1,stroke:#0F766E,stroke-width:3px,color:#0B3B36
  classDef fail fill:#FDECEC,stroke:#B42318,stroke-width:3px,color:#5C1010
```

Gán class bằng `class id1,id2 happy` (không dùng `:::` để dòng nút dễ đọc).

## 5. Happy case và edge case

- **Happy case** chỉ có luồng chính của SRS: các bước theo thứ tự, mọi cạnh `==>`, mọi nút class `happy`, kết thúc `done`. Không có thoi rẽ nhánh, trừ khi luồng chính tự rẽ (ví dụ "đủ điều kiện AI?" ở bước 4 UC-01 G02).
- **Nhánh thay thế và lỗi** vẽ lại xương sống của luồng chính **rút gọn** (gộp các bước không có nhánh), rồi mọc nhánh A# / E# ra từ đúng bước mà SRS nói. Nhánh quay về luồng chính thì nối mũi tên về nút đó; không vẽ lại.
- Một sơ đồ quá **25 nút** thì tách: "Nhánh thay thế" và "Nhánh lỗi" thành hai sơ đồ.
- Nhánh giống nhau ở nhiều UC (mất mạng, `VERSION_CONFLICT`, task bị xoá ở thiết bị khác) vẫn vẽ ở từng UC, vì designer vẽ theo màn; nhưng nhãn phải giống hệt nhau.
- Hai điều kiện dẫn tới **cùng một kết quả** thì gộp một cạnh: `"A4 · AI tắt / chậm > 2s / lỗi"`.

## 6. Liên kết qua lại

| Từ | Tới | Cách ghi |
|---|---|---|
| Flow | SRS | Đầu file: link SRS + commit. Trong nút: mã `UC`, `A#`, `E#`, `SCR`, `MSG`, `BR` |
| Flow | Brief | Đầu file: link brief của tính năng (`[chờ #n]` khi chưa có) |
| Brief | Flow | Khuôn brief, mục 5: mỗi `F-xx` ghi dòng `Sơ đồ: [UC-xx](flow/gxx-....md#uc-xx-ten)`. Một UC có thể ứng với nhiều F-xx của brief |
| Flow | Flow | Nút lục giác `→ Gyy · UC-zz`; ở bảng đối chiếu thêm link markdown tới mục đó |
| Flow | FigJam | Đầu file: `**FigJam:** <link>`; mỗi mục UC thêm link section (mục 7). Hiện là `[chờ]` |

## 7. Khi chuyển sang FigJam `[đề xuất, chưa làm]`

- Một file FigJam cho bản 1.0, **mỗi tính năng một trang** (`G02 Quản lý task`), mỗi UC một **section** tên giống hệt tiêu đề markdown (`UC-01 Tạo task`), trong section để happy case bên trái, nhánh bên phải.
- Dựng bằng cách import Mermaid của từng mục, rồi chỉnh tay bố cục; ký hiệu và màu giữ như mục 3–4.
- Repo vẫn là nguồn: sửa flow thì sửa Mermaid trong repo trước, rồi cập nhật FigJam.
- Chọn team Figma và tạo file: PO quyết khi tới bước này.

## 8. Ví dụ đầy đủ

[`g02-quan-ly-task.md`](g02-quan-ly-task.md) là file mẫu theo quy ước này.
