# wakeup_desktop

App Windows của Wakeup (Flutter). Quyết định kỹ thuật: [`docs/tech/01`](../../docs/tech/01-quyet-dinh-tech-stack-va-api.md) mục 3.

```
lib/
  main.dart            # điểm vào: nạp dữ liệu múi giờ, ProviderScope
  app/                 # MaterialApp, router, provider dùng chung
  ds/                  # thư viện widget design system (ADR-0008)
  features/<nhóm>/     # theo nhóm tính năng G01..G10: data/, domain/, ui/
```

Chạy trên Windows:

```
flutter run -d windows
```

Chưa có trong khung (thêm khi làm tính năng): Drift + SQLCipher, tray / hotkey / thông báo, tự cập nhật.
