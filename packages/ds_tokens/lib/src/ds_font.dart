/// Font của design system (DS-05): Inter 4.1 đóng gói trong package này
/// (`fonts/inter/`, SIL OFL 1.1). Dùng `fontFamily: DsFont.family` kèm
/// `package: DsFont.package` để app nào phụ thuộc package cũng nạp được.
abstract final class DsFont {
  /// Tên họ font khai báo trong pubspec.
  static const family = 'Inter';

  /// Package chứa file font.
  static const package = 'wakeup_ds_tokens';
}
