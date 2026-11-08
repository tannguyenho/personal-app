// GENERATED CODE - DO NOT MODIFY BY HAND.
// Sinh từ components.json bằng `dart run tool/generate.dart`.

import 'package:flutter/widgets.dart';

/// `Button` · `variant`.
enum DsButtonVariant {
  primary('primary'),
  secondary('secondary');

  const DsButtonVariant(this.figmaValue);

  /// Giá trị variant trong Figma.
  final String figmaValue;
}

/// `Button` · `size`.
enum DsButtonSize {
  md('md'),
  sm('sm');

  const DsButtonSize(this.figmaValue);

  /// Giá trị variant trong Figma.
  final String figmaValue;
}

/// Hợp đồng tham số của component Figma `Button`.
///
/// Wakeup DsButton (Flutter: apps/desktop/lib/ds/ds_button.dart)
///
/// Widget `DsButton` phải `extends` lớp này.
abstract class DsButtonBase extends StatelessWidget {
  const DsButtonBase({
    super.key,
    required this.label,
    this.disabled = false,
    this.size = DsButtonSize.md,
    this.variant = DsButtonVariant.primary,
  });

  /// `label` (TEXT).
  final String label;

  /// `disabled` (BOOLEAN).
  final bool disabled;

  /// `size` (VARIANT).
  final DsButtonSize size;

  /// `variant` (VARIANT).
  final DsButtonVariant variant;
}
