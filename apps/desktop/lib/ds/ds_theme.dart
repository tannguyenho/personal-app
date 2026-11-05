import 'package:flutter/material.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';

/// Theme dựng từ token sinh ra ở `wakeup_ds_tokens` (ADR-0008). Không hardcode
/// màu ở đây hay trong widget.
abstract final class DsTheme {
  static ThemeData light() => _build(Brightness.light, DsColors.light);

  static ThemeData dark() => _build(Brightness.dark, DsColors.dark);

  static ThemeData _build(Brightness brightness, DsColors colors) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.bgPrimary,
        brightness: brightness,
      ),
      extensions: [colors],
    );
  }
}
